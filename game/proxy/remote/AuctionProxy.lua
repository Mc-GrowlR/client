local RemoteProxy = requireProxy("remote/RemoteProxy")
local AuctionProxy = class("AuctionProxy", RemoteProxy)
AuctionProxy.NAME = global.ProxyTable.AuctionProxy

local socket = require("socket")

-- useritem     道具基础数据
-- userid       归属者ID
-- type         货币ID
-- price        当前价格
-- lastprice    一口价
-- time         上架时间戳
-- lasttime     最后出价时间戳
-- endtime      下架时间戳
-- curruserid   当前竞价玩家ID
-- joinuser     是否参与过竞价
-- flag         0.正常 1.表示拍卖成功的物品 2.表示流拍的物品
-- page         0.世界 1.行会
-- index
-- meguildrate  同行会折扣率

local function getUnitNumber(n)
    if n >= 100000000 then
        return string.format("%.1f%s", n / 100000000, GET_STRING(1045))
    end
    if n >= 10000 then
        return string.format("%.1f%s", n / 10000, GET_STRING(1005))
    end
    return tostring(n)
end

local function parseItem(item)
    if not item then
        return nil
    end
    local titem = ChangeItemServersSendDatas(item.useritem)
    setmetatable( item, { __index = titem })
    return item
end

function fixAuctionPrice(price, unit)
    return unit and getUnitNumber(price) or price
end

AuctionProxy.INFINITY_PRICE = 100000000

function AuctionProxy:ctor()
    AuctionProxy.super.ctor(self)

    self._config_type  = {}

    self._currencies   = {}        -- 可拍卖货币
    self._qualities    = {}        -- 品阶

    self._biddinglist  = {}        -- 竞价列表
    self._putlist      = {}        -- 上架列表
    self._src          = 0         -- 最近一次请求来源 1.世界拍卖  2.行会拍卖
    self._page         = 0
    self._complete     = false

    self._jobAble      = {}        -- 职业过滤
    self._limitShelf   = 6         -- 货架数量

    self._lowBidPrice  = 1         -- 默认最低竞拍价
    self._lowBuyPrice  = 1         -- 默认最低一口价

    self._highBidPrice = nil
    self._highBuyPrice = nil

    self._itemConfig   = {}

    self._requestMinTime = 600       -- 拍卖行数据请求最小时间间隔(毫秒)
    self._lastRequestTime = nil

    self:Init()
end

function AuctionProxy:Init()
    self._config_type = requireGameConfig("cfg_auction_type")
end

function AuctionProxy:InitItemConfig(...)
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    self._itemConfig = ItemConfigProxy:GetItemConfigData()
end

function AuctionProxy:Clear()
    self._page = 0
    self._complete = false

    global.Facade:sendNotification(global.NoticeTable.AuctionItemListClear)
end

function AuctionProxy:IsComplete()
    return self._complete
end

function AuctionProxy:getCurrencies()
    return self._currencies
end

function AuctionProxy:addCurrency(item)
    table.insert(self._currencies, { id = item.Index, name = item.Name, item = item })
end

function AuctionProxy:clearCurrencies()
    self._currencies = {}
end

function AuctionProxy:getQualities()
    return self._qualities
end

function AuctionProxy:setQualities(rawData)
    if not rawData then
        return
    end
    for _, value in ipairs(rawData) do
        local slices = string.split(value, "#")
        table.insert(self._qualities, { id = tonumber(slices[1]), name = slices[2] })
    end
end

function AuctionProxy:getJobAble()
    return self._jobAble
end

function AuctionProxy:setJobAble(able)
    self._jobAble = able
end

function AuctionProxy:getLimitShelf()
    return self._limitShelf or 8
end

function AuctionProxy:setLimitShelf(count)
    self._limitShelf = count
end

function AuctionProxy:GetCTypeByID(id)
    return self._config_type[id]
end

function AuctionProxy:GetStdModeByID(id)
    local config = self:GetCTypeByID(id)
    if not config then
        return {}
    end
    local slices = string.split(tostring(config.stdmode), "#")
    local stdmode = {}
    for key, value in ipairs(slices) do
        table.insert(stdmode, tonumber(value))
    end
    return stdmode
end

function AuctionProxy:GetCTypeInGroup()
    local items = {}
    for i, v in pairs(self._config_type) do
        if not items[v.firstlevel] then
            items[v.firstlevel] = {}
        end
        table.insert(items[v.firstlevel], v)
    end

    for i, v in pairs(items) do 
        table.sort(v, function(a, b) return a.id < b.id end)
    end 
    return items
end

function AuctionProxy:GetCTypeItemsByGroup(g)
    local items = {}
    for i, v in pairs(self._config_type) do
        if v.secondlevel and v.firstlevel == g then
            table.insert(items, v)
        end
    end

    table.sort(items, function(a, b) return a.id < b.id end)
    return items
end

function AuctionProxy:GetPutListCount()
    return #self._putlist
end

function AuctionProxy:checkBidAble(item)
    if not item then
        return false
    end
    return item.price and item.price > 0
end

function AuctionProxy:checkBuyAble(item)
    if not item then
        return false
    end
    return item.lastprice and item.lastprice > 0
end

function AuctionProxy:calcItemStatus(item)
    if not item then
        return 3, 0
    end
    local status    = 0     -- 2.竞拍中 3.已超时
    local endTime = item.endtime or GetServerTime() + 1
    local remaining = 0

    if GetServerTime() >= endTime then
        -- 已超时
        status = 3
        remaining = 0
    else
        --竞拍中
        status = 2
        remaining = endTime - GetServerTime()
    end

    remaining = math.max(remaining, 0)
    return status, remaining
end

function AuctionProxy:IsAuctioningItem(item)
    return item.flag == 0
end

function AuctionProxy:IsExistAcquireItem()
    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    for _, item in ipairs(self._biddinglist) do
        if item.flag == 1 and item.curruserid == mainPlayerID then
            return true
        end
    end
    return false
end

function AuctionProxy:setLowBidPrice(price)
    self._lowBidPrice = price
end

function AuctionProxy:setLowBuyPrice(price)
    self._lowBuyPrice = price
end

function AuctionProxy:setHighBidPrice(price)
    self._highBidPrice = price
end

function AuctionProxy:setHighBuyPrice(price)
    self._highBuyPrice = price
end

function AuctionProxy:GetLowBidPrice()
    return self._lowBidPrice
end

function AuctionProxy:GetLowBuyPrice()
    return self._lowBuyPrice
end

function AuctionProxy:GetHighBidPrice()
    return self._highBidPrice
end

function AuctionProxy:GetHighBuyPrice()
    return self._highBuyPrice
end

function AuctionProxy:GetItemConfig()
    return self._itemConfig
end

function AuctionProxy:GetShowBagItems()
    local BagProxy          = global.Facade:retrieveProxy(global.ProxyTable.Bag)   
    local QuickUseProxy     = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
    local ItemConfigProxy   = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)

    local bagData           = BagProxy:GetBagData()
    local quickData         = QuickUseProxy:GetQuickUseData()
    local articleType       = ItemConfigProxy:GetArticleType()
    local checkArticleType  = {[articleType.TYPE_TRADE_AUCTIONA] = true}
    local bagItems          = {}
    local itemMaps          = {}
    for _, vItem in pairs(quickData) do
        if not ItemConfigProxy:GetItemArticle(vItem.Index, checkArticleType) then
            table.insert(bagItems, vItem)
            itemMaps[vItem.MakeIndex] = vItem
        end
    end

    for _, vItem in pairs(bagData) do
        if not ItemConfigProxy:GetItemArticle(vItem.Index, checkArticleType) then
            table.insert(bagItems, vItem)
            itemMaps[vItem.MakeIndex] = vItem
        end
    end

    return bagItems, itemMaps
end

function AuctionProxy:SetRequestMinTime(time)
    self._requestMinTime = time
end

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- 拉取拍卖数据：发送消息号：1120，第一个参数为页，世界=0，行会=1
function AuctionProxy:RequestItemList(data)
    local curTime = socket.gettime()
    local needDelay = false
    if self._lastRequestTime and self._requestMinTime then
        if (curTime - self._lastRequestTime) * 1000 < self._requestMinTime then
            needDelay = true
            SL:ShowSystemTips("<font color = '#00FF00'>正在读取数据中...</font>")
        end
    end

    local function callback()
        local filter = clone(data)
        filter.page = self._page
        self._lastRequestTime = socket.gettime()
        SendTableToServer(global.MsgType.MSG_CS_AUCTION_ITEM_LIST, filter)
    end
    PerformWithDelayGlobal(callback, needDelay and (self._requestMinTime / 1000) or 0)
end

function AuctionProxy:RespItemList(msg)
    HideLoadingBar()
    local header = msg:GetHeader()
    local len    = msg:GetDataLength()
    if len <= 0 then
        return false
    end
    self._page    = header.recog + 1
    local source = header.param1
    local jsonData = ParseRawMsgToJson(msg)

    -- complete
    if #jsonData == 0 then
        self._complete = true
        global.Facade:sendNotification(global.NoticeTable.AuctionItemListComplete, { source = source })
        return
    end

    local items = {}
    for _, v in ipairs(jsonData) do
        local item = parseItem(v)
        table.insert(items, item)
    end

    global.Facade:sendNotification(global.NoticeTable.AuctionItemListResp, { source = source, items = items })
end

-- 你发送1154号消息，第一个参数=1，表示查询自己上架的物品，=2表示查询参与过的。
function AuctionProxy:RequestItems(listType)
    LuaSendMsg(global.MsgType.MSG_CS_AUCTION_PUT_LIST, listType)
end

-- 返回1130号消息给你。第一个参数为对应的查询类型
function AuctionProxy:RespItems(msg)
    local header = msg:GetHeader()
    local len    = msg:GetDataLength()
    if len <= 0 then
        return false
    end
    local jsonData = ParseRawMsgToJson(msg)
    local items = {}
    for _, v in ipairs(jsonData) do
        local item = parseItem(v)
        table.insert(items, item)
    end

    local isMerge = header.msgId == global.MsgType.MSG_SC_AUCTION_PUT_LIST2

    if header.recog == 1 then
        if not isMerge then
            self._putlist = {}
        end
        self._putlist = table.order_merge(self._putlist or {}, items)

        if header.param1 ~= 11 or (isMerge and header.param1 == 11) then --第二次数据时通知更新界面或者是旧的消息
            global.Facade:sendNotification(global.NoticeTable.AuctionPutListResp, self._putlist)
        end

    elseif header.recog == 2 then
        if not isMerge then
            self._biddinglist = {}
        end
        self._biddinglist = table.order_merge(self._biddinglist or {}, items)

        if header.param1 ~= 11 or (isMerge and header.param1 == 11) then --第二次数据时通知更新界面或者是旧的消息
            global.Facade:sendNotification(global.NoticeTable.AuctionBiddingListResp, self._biddinglist)
        end
    end
end

function AuctionProxy:RequestPutin(data)
    SendTableToServer(global.MsgType.MSG_CS_AUCTION_PUT_IN, data)
end

function AuctionProxy:RequestReputin(data)
    SendTableToServer(global.MsgType.MSG_CS_AUCTION_REPUT_IN, data)
end

function AuctionProxy:RespPutin(msg)
    local header    = msg:GetHeader()
    local jsonData = ParseRawMsgToJson(msg)
    local item    = parseItem(jsonData)

    global.Facade:sendNotification(global.NoticeTable.AuctionPutinResp, { item = item })
end

function AuctionProxy:RequestPutout(data)
    local makeindex = data.makeindex
    LuaSendMsg(global.MsgType.MSG_CS_AUCTION_PUT_OUT, makeindex)
end

function AuctionProxy:RespPutout(msg)
    local header    = msg:GetHeader()
    local makeindex = header.recog
    global.Facade:sendNotification(global.NoticeTable.AuctionPutoutResp, { makeindex = makeindex })
end

function AuctionProxy:RequestBid(data)
    local sendData = { makeindex = data.makeindex, price = data.price }
    SendTableToServer(global.MsgType.MSG_CS_AUCTION_BID, sendData)
end

-- 竞拍返回 消息号：1112，recog=0，失败：recog=-1，表示已经有人出更高价，=-2表示已经被买走 =-3自己的物品
function AuctionProxy:RespBid(msg)
    local header    = msg:GetHeader()
    local errorcode = header.recog

    if errorcode == 0 then
        ShowSystemTips(GET_STRING(30103015))
    elseif errorcode == -1 then
        ShowSystemTips(GET_STRING(30103083))
    elseif errorcode == -2 then
        ShowSystemTips(GET_STRING(30103084))
    elseif errorcode == -3 then
        ShowSystemTips(GET_STRING(30103034))
    elseif errorcode == -4 then
        ShowSystemTips(GET_STRING(30103085))
    end
    global.Facade:sendNotification(global.NoticeTable.AuctionBidResp, { errorcode = errorcode,})
end

function AuctionProxy:RequestAcquireItem(data)
    local makeindex = data.makeindex
    LuaSendMsg(global.MsgType.MSG_CS_AUCTION_ACQUIRE, makeindex)
end

function AuctionProxy:RespAcquireItem(msg)
    local header = msg:GetHeader()
    local makeindex = header.recog
    global.Facade:sendNotification(global.NoticeTable.AuctionAcquireResp, { makeindex = makeindex })
end

function AuctionProxy:RequestLeaveAuction()
    LuaSendMsg(global.MsgType.MSG_CS_AUCTION_LEAVE)
end

-- 1115号消息，recog=1，表示新加，=2表示删除，=3表示更新
function AuctionProxy:RespItemUpdate(msg)
    local header = msg:GetHeader()
    local action = header.recog
    local jsonData = ParseRawMsgToJson(msg)
    local item    = parseItem(jsonData)

    -- 世界拍卖
    if action == 1 then
        global.Facade:sendNotification(global.NoticeTable.AuctionWorldItemAdd, { item = item })

    elseif action == 2 then
        for k, v in pairs(self._biddinglist) do
            if v.MakeIndex == item.MakeIndex then
                table.remove(self._biddinglist, k)
                break
            end
        end
        global.Facade:sendNotification(global.NoticeTable.AuctionWorldItemDel, { item = item })

    elseif action == 3 then
        for k, v in pairs(self._biddinglist) do
            if v.MakeIndex == item.MakeIndex then
                self._biddinglist[k] = item
                break
            end
        end
        global.Facade:sendNotification(global.NoticeTable.AuctionWorldItemChange, { item = item })
    end

    global.Facade:sendNotification(global.NoticeTable.AuctionItemUpdate, { item = item })

    local peopleproxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local myUid = peopleproxy:GetRoleUID()
    if jsonData.userid == myUid and action ~= 2 then
        global.Facade:sendNotification(global.NoticeTable.AuctionPutinResp, { item = item })
    end
end

function AuctionProxy:RespPutCount(msg)
    local header = msg:GetHeader()
    self:setLimitShelf(header.recog)
end

function AuctionProxy:RegisterMsgHandler()
    AuctionProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType
    
    LuaRegisterMsgHandler(msgType.MSG_SC_AUCTION_ITEM_LIST,     handler(self, self.RespItemList))
    LuaRegisterMsgHandler(msgType.MSG_SC_AUCTION_PUT_LIST,      handler(self, self.RespItems))
    LuaRegisterMsgHandler(msgType.MSG_SC_AUCTION_PUT_OUT,       handler(self, self.RespPutout))
    LuaRegisterMsgHandler(msgType.MSG_SC_AUCTION_PUT_IN,        handler(self, self.RespPutin))
    LuaRegisterMsgHandler(msgType.MSG_SC_AUCTION_BID,           handler(self, self.RespBid))
    LuaRegisterMsgHandler(msgType.MSG_SC_AUCTION_ACQUIRE,       handler(self, self.RespAcquireItem))
    LuaRegisterMsgHandler(msgType.MSG_SC_AUCTION_ITEM_UPDATE,   handler(self, self.RespItemUpdate))
    LuaRegisterMsgHandler(msgType.MSG_SC_AUCTION_PUT_COUNT,     handler(self, self.RespPutCount))
    LuaRegisterMsgHandler(msgType.MSG_SC_AUCTION_PUT_LIST2,     handler(self, self.RespItems))
end

return AuctionProxy