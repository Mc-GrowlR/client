local RemoteProxy = requireProxy("remote/RemoteProxy")
local BagProxy = class("BagProxy", RemoteProxy)
BagProxy.NAME = global.ProxyTable.Bag

local tinsert = table.insert

local function MAKE_OPER_DATA(item, isHad, number)
    local operator = {}
    operator.item = item
    operator.isHad = isHad
    operator.change = number
    operator.MakeIndex = item.MakeIndex
    return operator
end

BagProxy.BAG_SELECT_TYPE = {
    TYPE_ALL   = 0, -- 全部
    TYPE_EQUIP = 1, -- 装备
    TYPE_EXP   = 2, -- 经验
    TYPE_REIN  = 3, -- 转生
    TYPE_PET   = 4, -- 宠物
    TYPE_OTHER = 5  -- 其他
}

function BagProxy:ctor()
    BagProxy.super.ctor(self)

    local BagVO = requireVO("remote/BagVO")
    self.VOdata = BagVO.new()

    self._maxBagNum            = 0      -- 服务端发的最大背包格子数（不包括快捷栏）
    self._init_count           = 0      -- 初始数量
    self._curSelPage           = 1      -- 当前选中切页
    self._prompt_data          = nil    -- cfg_game_data的prompt
    self._selfDropItems        = {}     -- 自己丢弃的物品
    self._on_sell_repaire      = nil    -- 正在交易或者修理中物品
    self._collimator_MakeIndex = nil    -- 记录背包选中的准星道具
    self._reconnect            = false  -- 是否重连
    self._customAttrs          = {}     -- 自定义属性 key: makeindex   value: attrs
    self._receiveBagData       = false  -- 是否已经收到背包数据
    self._bigPerPageNum        = nil    -- 大背包单页大小
end

function BagProxy:SetServerBagNum(maxBag)
    self._maxBagNum = maxBag
end

function BagProxy:GetServerBagNum()
    return self._maxBagNum
end

function BagProxy:SetMaxBag(maxBag)
    self.VOdata:SetMaxBag(maxBag)
    self.VOdata:SetNewPosMark()
end

function BagProxy:GetMaxBag()
    return self.VOdata:GetMaxBag()
end

function BagProxy:SetCurPage(curPage)
    self._curSelPage = curPage
end

function BagProxy:GetCurPage(curPage)
    return self._curSelPage
end

function BagProxy:GetSelfDropItems()
    return self._selfDropItems
end

-- item提示：类似右上角满 获取cfg_game_data表的prompt字段的数据
function BagProxy:GetPromptGameData()
    if not self._prompt_data then
        self._prompt_data = {}
        local prompt = SL:GetMetaValue("GAME_DATA","prompt")
        if prompt and string.len(prompt) then
            local promptArray = string.split(prompt, "|")
            for _, v in ipairs(promptArray) do
                if v and string.len(v) > 0 then
                    local valueArray = string.split(v, "#")
                    tinsert(self._prompt_data, {
                        resPath = valueArray[1],
                        posX = valueArray[2] and tonumber(valueArray[2]) or nil,
                        posY = valueArray[3] and tonumber(valueArray[3]) or nil,
                        resScale = valueArray[4] and tonumber(valueArray[4]) or nil
                    })
                end
            end
        end
    end

    if global.isWinPlayMode then
        return self._prompt_data[1] or {}
    end

    return self._prompt_data[2] or {}
end

function BagProxy:Inited(bool)
    self.VOdata:Inited(bool)
end

function BagProxy:SetReconnect(bool)
    self._reconnect = bool
end

function BagProxy:GetBagData()
    return self.VOdata:GetBagData()
end

function BagProxy:GetTotalItemCount()
    return self.VOdata:GetItemCount()
end

function BagProxy:isToBeFull(tips)
    if tips and self.VOdata:isFull() then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(800050))
    end
    return self.VOdata:isFull()
end

function BagProxy:CheckNeedSpace(itemID, itemCount, tips)
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local itemData = ItemConfigProxy:GetItemDataByIndex(itemID)
    local isLap = ItemConfigProxy:CheckItemOverLap(itemData)
    local needPos = itemCount
    if isLap then
        needPos = math.ceil(itemCount / itemData.OverLap)
    end
    local bagItemNum = self:GetTotalItemCount()
    local maxBag = self:GetMaxBag()
    local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
    local onTradingNum = TradeProxy:GetSelfItemNum()
    local totalBagItemNum = bagItemNum + onTradingNum
    if bagItemNum + needPos > maxBag then
        if tips then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(1021))
        end
        return false
    end
    return true
end

-- 通过唯一id获取在背包中的切页
function BagProxy:GetBagPageByMakeIndex(MakeIndex)
    local posPage = nil
    MakeIndex = MakeIndex and tonumber(MakeIndex) or nil
    if MakeIndex then
        local pos = self:GetBagPosByMakeIndex(MakeIndex)
        if pos and type(pos) == "number" then
            posPage = math.ceil(pos / (self:GetBigPerPageNum() or global.MMO.MAX_ITEM_NUMBER))
        end
    end
    return posPage
end

function BagProxy:GetBigPerPageNum()
    local bag_row_col = SL:GetMetaValue("GAME_DATA", "bag_row_col_max")
    if not SL:GetMetaValue("WINPLAYMODE") or not bag_row_col or self._bigPerPageNum then
        return self._bigPerPageNum
    end
    local param = string.split(bag_row_col, "|") 
    local col = tonumber(param[1]) or 8
    local row = tonumber(param[2]) or 5
    self._bigPerPageNum = col * row
    return self._bigPerPageNum
end

-- 通过唯一id获取在背包中的位置
function BagProxy:GetBagPosByMakeIndex(MakeIndex)
    return self.VOdata:GetBagPosByMakeIndex(MakeIndex)
end

-- 通过在背包中的位置获取唯一id
function BagProxy:GetMakeIndexByBagPos(pos)
    return self.VOdata:GetMakeIndexByBagPos(pos)
end

-- 通过唯一id获取物品数据
function BagProxy:GetItemDataByMakeIndex(MakeIndex)
    return self.VOdata:GetItemByMakeIndex(MakeIndex)
end

-- 获取背包数据  startPos: 开始的位置   endPos: 结束的位置
function BagProxy:GetBagDataByBagPos(startPos, endPos)
    return self.VOdata:GetBagDataByBagPos(startPos, endPos)
end

-- 获取新位置
function BagProxy:NewItemPos()
    return self.VOdata:NewItemPos()
end

-- 修正历史数据与当前数据位置信息
function BagProxy:AmendHistoryPos(data, sort, startIndex, endIndex)
    self.VOdata:AmendHistoryPos(data, sort, startIndex, endIndex)
end

-- 清理背包数据及位置
function BagProxy:CleanBagPosData()
    self.VOdata:CleanBagPosData()
end

-- 通过itemIndex获取物品数据
function BagProxy:GetItemDataByItemIndex(itemIndex)
    local someItems = {}
    if not itemIndex then
        return someItems
    end
    local items = self:GetBagData()
    for _, v in pairs(items) do
        if v.Index == itemIndex then
            tinsert(someItems, v)
        end
    end
    return someItems
end

-- 通过物品名称获取物品数据
function BagProxy:GetItemDataByItemName(itemName)
    if not itemName then
        return nil
    end
    local someItems = {}
    local items = self:GetBagData()
    for _, v in pairs(items) do
        if v.Name == itemName then
            tinsert(someItems, v)
        end
    end
    if not next(someItems) then
        return nil
    end
    return someItems
end

-- 通过itemIndex获取物品数量 famlilar是否包含绑定数量
function BagProxy:GetItemCountByIndex(Index, famlilar)
    Index = Index or 0
    local count = 0
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local isBind, bindIndex = ItemConfigProxy:CheckItemBind(Index)
    local myCount = self.VOdata:GetItemCountByIndex(Index)
    local famlilarCount = 0
    if isBind and bindIndex ~= Index and famlilar then
        famlilarCount = self.VOdata:GetItemCountByIndex(bindIndex)
    end
    local totalCount = myCount + famlilarCount
    return totalCount
end

-- 设置正在交易或修理中
function BagProxy:SetOnSellOrRepaire(MakeIndex)
    self._on_sell_repaire = MakeIndex
    global.Facade:sendNotification(global.NoticeTable.Bag_Item_Pos_Change)
end

-- 获取是否在交易或修理
function BagProxy:GetOnSellOrRepaire()
    return self._on_sell_repaire
end

-- 清理交易或修理
function BagProxy:CleanOnSellOrRepaire()
    self._on_sell_repaire = nil
    global.Facade:sendNotification(global.NoticeTable.Bag_Item_Pos_Change)
end

-- 添加物品
function BagProxy:AddItemData(item, noNotice)
    if not item then
        return
    end

    local itemPos = self.VOdata:GetHistoryPos(item.MakeIndex) or self:NewItemPos()
    if itemPos then
        self.VOdata:SetItemPosData(item.MakeIndex, itemPos)
    end

    if not noNotice then
        self:ShowGetOrCostItems(item.OverLap or 1, item.Name)
    end

    self.VOdata:AddItem(item, itemPos)

    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    ItemManagerProxy:SetItemBelong(item.MakeIndex, global.MMO.ITEM_FROM_BELONG_BAG)
end

-- 显示获得或消耗物品
function BagProxy:ShowGetOrCostItems(diff, name)
    if self.VOdata:IsInited() then
        return
    end

    local nData = {}
    nData.name = name
    nData.num = math.abs(diff)
    local notice = diff > 0 and global.NoticeTable.ShowGetBagItem or global.NoticeTable.ShowCostItem
    global.Facade:sendNotification(notice, nData)
end

-- 增加物品并通知
function BagProxy:AddItemDataAndNotice(item)
    self:AddItemData(item)

    local operator = {}
    operator.opera = global.MMO.Operator_Add
    operator.operID = {}
    tinsert(operator.operID, MAKE_OPER_DATA(item, false))

    ssr.ssrBridge:OnPreBagOperData(operator)
    global.Facade:sendNotification(global.NoticeTable.Bag_Oper_Data, operator)
    ssr.ssrBridge:OnBagOperData(operator)
    SLBridge:onLUAEvent(LUA_EVENT_BAG_ITEM_CHANGE, operator)

    -- 延迟通知
    self:DelayNotifyBagOper()
end

-- 延迟通知，部分系统不需要实时监听背包改变，并且不需要知道背包操作类型，节省性能
function BagProxy:DelayNotifyBagOper()
    if self._delayNotifyTimerID then
        UnSchedule(self._delayNotifyTimerID)
        self._delayNotifyTimerID = nil
    end

    self._delayNotifyTimerID = PerformWithDelayGlobal(function()
        global.Facade:sendNotification(global.NoticeTable.Bag_Oper_Data_Delay)
    end, 0.5)
end

-- 删除物品
function BagProxy:DelItemData(data, showTip, noCleanPos, noNotify, isBaitan)
    if not data or not next(data) then
        return
    end

    local MakeIndex = data.MakeIndex
    local itemHasPos = true
    local noPosData = self.VOdata:GetBagNoPosDataByMakeIndex(MakeIndex)
    local item = self:GetItemDataByMakeIndex(MakeIndex)

    if noPosData then
        itemHasPos = false
        item = noPosData
    end

    if item then
        if not self.VOdata:IsInited() then
            global.Facade:sendNotification(global.NoticeTable.Layer_Auto_Use_UnAttach, {
                id = item.MakeIndex
            })
        end

        local operator = {}
        operator.opera = global.MMO.Operator_Sub
        operator.operID = {}
        operator.isBaitan = isBaitan
        local operitem = self:BagOperItemByMakeIndex(MakeIndex, itemHasPos)
        tinsert(operator.operID, operitem)

        self.VOdata:SubItem(MakeIndex)

        if not noCleanPos then
            self.VOdata:CleanItemPosData(MakeIndex)
        end

        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
        ItemManagerProxy:SetItemBelong(item.MakeIndex, nil)

        if not noNotify then
            ssr.ssrBridge:OnPreBagOperData(operator)
            global.Facade:sendNotification(global.NoticeTable.Bag_Oper_Data, operator)
            ssr.ssrBridge:OnBagOperData(operator)
            SLBridge:onLUAEvent(LUA_EVENT_BAG_ITEM_CHANGE, operator)

            -- 延迟通知
            self:DelayNotifyBagOper()
        end

        if showTip then
            self:ShowGetOrCostItems(-(item.OverLap or 1), item.Name)
        end

        -- 缓存中的数据自动补充到背包
        local noPosData = self.VOdata:GetBagNoPosData()
        if noPosData and next(noPosData) and itemHasPos then
            for _, v in pairs(noPosData) do
                if v and next(v) then
                    self:DelItemData(v, nil, nil, true)
                    self:AddItemDataAndNotice(v)
                    break
                end
            end
        end

        -- 清理删除红点
        local RedDotProxy = global.Facade:retrieveProxy(global.ProxyTable.RedDotProxy)
        RedDotProxy:DeleteBagRedDot(MakeIndex)
    end
end

function BagProxy:BagOperItemByMakeIndex(MakeIndex, isShowInBag)
    local item = self:GetItemDataByMakeIndex(MakeIndex)
    if not isShowInBag then
        item = self.VOdata:GetBagNoPosDataByMakeIndex(MakeIndex)
    end

    local operator = {}
    if item then
        local MakeIndex = item.MakeIndex
        operator.MakeIndex = MakeIndex
        operator.item = item
    end
    return operator
end

-- 更改物品数据
function BagProxy:ChangeItemData(item)
    local makeIndex = item.MakeIndex
    local newnum = item.OverLap or 1
    local diff = 0
    local data = self:GetItemDataByMakeIndex(makeIndex)
    if data then
        local oldnum = data.OverLap or 1
        diff = newnum - oldnum
        self.VOdata:ChangeItem(item)
        if diff ~= 0 then
            self:ShowGetOrCostItems(diff, item.Name)
        end
    end
    return diff
end

-- 清理背包
function BagProxy:ClearItemData(isReconnect)
    local array = self.VOdata:GetBagData()
    for key, var in pairs(array) do
        self:DelItemData(var, nil, true, isReconnect)
    end

    local arrayNoPos = self.VOdata:GetBagNoPosData()
    for _, item in pairs(arrayNoPos) do
        self:DelItemData(item, nil, nil, isReconnect)
    end

    self.VOdata:ClearItemData()
end

-- 换位
function BagProxy:ExchangePos(MakeIndex1, pos1, MakeIndex2, pos2)
    self.VOdata:CleanItemPosData(MakeIndex1)
    self.VOdata:CleanItemPosData(MakeIndex2)
    self.VOdata:SetItemPosData(MakeIndex1, pos1)
    self.VOdata:SetItemPosData(MakeIndex2, pos2)
    global.Facade:sendNotification(global.NoticeTable.Bag_Item_Pos_Change, {MakeIndex1, MakeIndex2})
end

-- 修改位置数据
function BagProxy:SetItemPosData(MakeIndex, pos)
    self.VOdata:CleanItemPosData(MakeIndex)
    self.VOdata:SetItemPosData(MakeIndex, pos)
    global.Facade:sendNotification(global.NoticeTable.Bag_Item_Pos_Change, {MakeIndex})
end

-- 获取背包道具的使用状态(0：使用 1：使用准星道具 2：取消准星 3：不可使用)
function BagProxy:GetOnBagItemUseState(data)
    if self._collimator_MakeIndex then
        if self._collimator_MakeIndex == -1 then -- 脚本
            return 1
        end

        if data and self._collimator_MakeIndex == data.MakeIndex then
            return 2
        end

        return 1
    end

    return 0
end

-- 设置准星道具
function BagProxy:SetBagCollimator(data)
    self._collimator_MakeIndex = data
end

-- 获取准星道具
function BagProxy:GetBagCollimator()
    return self._collimator_MakeIndex
end

-- 清理准星道具
function BagProxy:ClearBagCollimator()
    self._collimator_MakeIndex = nil
end

-- 获取自定义属性数据
function BagProxy:GetCustomAttrData(MakeIndex)
    if not MakeIndex then
        return
    end
    return self._customAttrs[MakeIndex]
end


-- 背包数据初始化
function BagProxy:handle_MSG_SC_RETURN_BAGDATA(msg)
    local msgHdr = msg:GetHeader()
    local data = ParseRawMsgToJson(msg)
    -- print("------------------------------------")
    -- print(" into here to get and set bag data")
    -- print("------------------------------------")
    if not data then
        return
    end

    local changedData = {}
    local dataCount = 0
    for _, v in ipairs(data) do
        local changeData = ChangeItemServersSendDatas(v)
        tinsert(changedData, changeData)
        dataCount = dataCount + 1
    end
    data = changedData

    -- 清理缓存
    if self.VOdata:IsInited() then
        self._init_count = 0
        self:Inited(false)
        self:ClearItemData()
    end

    local startIndex = self._init_count + 1
    local endIndex = self._init_count + dataCount

    -- 301 最后一次的数据
    if msgHdr.msgId == global.MsgType.MSG_SC_RETURN_BAGDATA_REMAINING then
        endIndex = self:GetMaxBag()
    end

    self._init_count = self._init_count + dataCount

    -- 修正本地位置信息数据
    self:AmendHistoryPos(data, false, startIndex, endIndex)

    local history = {}
    for key, var in pairs(self.VOdata:GetBagData()) do
        history[var.MakeIndex] = var.MakeIndex
    end

    local operator = {}
    operator.initbool = false
    operator.opera = global.MMO.Operator_Init
    operator.operID = {}

    local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
    for _, item in pairs(data) do
        local quickUsePos = QuickUseProxy:CheckIsInQucikUseList(item)
        if quickUsePos then -- 快捷栏道具
            QuickUseProxy:SetQuickUsePosData(quickUsePos, item)

        else
            self:AddItemData(item, true)

            if not history[item.MakeIndex] then
                tinsert(operator.operID, MAKE_OPER_DATA(item, false))
            end
        end
    end

    if msgHdr.msgId == global.MsgType.MSG_SC_RETURN_BAGDATA_REMAINING then -- 301 最后一次的数据
        QuickUseProxy:RequireHistoryQuickyUseList() -- 修正本地信息
    end

    if not self._reconnect then
        ssr.ssrBridge:OnPreBagOperData(operator)
        global.Facade:sendNotification(global.NoticeTable.Bag_Oper_Data, operator)
        ssr.ssrBridge:OnBagOperData(operator)
        SLBridge:onLUAEvent(LUA_EVENT_BAG_ITEM_CHANGE, operator)
        global.Facade:sendNotification(global.NoticeTable.QuickUseDataInit)
        ssr.ssrBridge:OnQuickUseOperData({
            opera = 0
        })
        SLBridge:onLUAEvent(LUA_EVENT_QUICKUSE_DATA_OPER, {opera = 0})

        -- 延迟通知
        self:DelayNotifyBagOper()
    end
end

-- 增加道具
function BagProxy:handle_MSG_SC_BAG_ADD_ITEM(msg)
    local header = msg:GetHeader()
    local recog = header.recog
    local data = ParseRawMsgToJson(msg)
    -- print("------------------------------------")
    -- print(" into here to add bag item")
    -- print("------------------------------------")
    if not recog or not data or next(data) == nil then
        return
    end

    -- 是否初始化 第一次进入的时候有可能请求了背包初始化而服务端不会发送
    local initbool = self.VOdata:IsInited()
    if initbool then
        self:Inited(false)
        global.Facade:sendNotification(global.NoticeTable.QuickUseDataInit)
        ssr.ssrBridge:OnQuickUseOperData({
            opera = 0
        })
        SLBridge:onLUAEvent(LUA_EVENT_QUICKUSE_DATA_OPER, {opera = 0})
    end

    if recog == -1 then
        data = ChangeItemServersSendDatas(data)

        if _DEBUG then
            local _ditem = self:GetItemDataByMakeIndex(data.MakeIndex)
            if _ditem then
                print("ERROR BAG ITEM EXIST, CAN'T ADD IT AGAIN", data.MakeIndex)
            end
        end

        local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
        local isCanAddToQuick = QuickUseProxy:CheckItemCanAddToQuickUse(data)
        local quickUsePos = QuickUseProxy:CheckQuickUseHasEmpty()
        -- 快捷栏道具
        if isCanAddToQuick and quickUsePos then
            self:ShowGetOrCostItems(data.OverLap or 1, data.Name)
            QuickUseProxy:SetQuickUsePosData(quickUsePos, data)

        else
            self:AddItemData(data)

            local operator = {}
            operator.opera = global.MMO.Operator_Add
            operator.operID = {}
            tinsert(operator.operID, MAKE_OPER_DATA(data, false))
            ssr.ssrBridge:OnPreBagOperData(operator)
            global.Facade:sendNotification(global.NoticeTable.Bag_Oper_Data, operator)
            ssr.ssrBridge:OnBagOperData(operator)
            SLBridge:onLUAEvent(LUA_EVENT_BAG_ITEM_CHANGE, operator)

            -- 延迟通知
            self:DelayNotifyBagOper()
        end

    else
        data = ChangeItemServersSendDatas(data)
        local proxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        data.Where = recog
        proxy:AddEquipData(data)
    end
end

-- 删除道具
function BagProxy:handle_MSG_SC_BAG_DEL_ITEM(msg)
    local header = msg:GetHeader()
    local makeIndex = header.recog
    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    local itemBelong = ItemManagerProxy:GetItemBelong(makeIndex)
    if not itemBelong then
        print("delete item error, can't find item belong")
        return
    end

    if itemBelong == global.MMO.ITEM_FROM_BELONG_BAG then
        local itemData = self:GetItemDataByMakeIndex(makeIndex)
        if not itemData then
            print("delete item error, can't find item")
            return
        end
        self:DelItemData(itemData, true)

    elseif itemBelong == global.MMO.ITEM_FROM_BELONG_EQUIP then
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local itemData = EquipProxy:GetEquipDataByMakeIndex(makeIndex)
        if not itemData then
            print("delete item error, can't find item")
            return
        end
        EquipProxy:DelEquipData(itemData)

    elseif itemBelong == global.MMO.ITEM_FROM_BELONG_QUICKUSE then
        local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
        local itemData = QuickUseProxy:GetQucikUseDataByMakeIndex(makeIndex)
        if not itemData then
            print("delete item error, can't find item")
            return
        end

        self:ShowGetOrCostItems(-(itemData.OverLap or 1), itemData.Name)

        -- 自动补充
        local pos = QuickUseProxy:GetQucikUsePosByMakeIndex(itemData.MakeIndex)
        QuickUseProxy:SetQuickUsePosData(pos, itemData, true)
        local function delayAutoAddd()
            QuickUseProxy:AutoAddBagItemToQuick(itemData, pos)
        end
        PerformWithDelayGlobal(delayAutoAddd, 0.5)

    elseif itemBelong == global.MMO.ITEM_FROM_BELONG_STALL then
        local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
        StallProxy:PutOutItem(makeIndex, true)
    end

    -- 清理一下自定义属性
    self._customAttrs[makeIndex] = nil
    SLBridge:onLUAEvent(LUA_EVENT_ITEM_CUSTOM_ATTR, {
        MakeIndex = makeIndex,
        data = nil
    })
end

-- 更新道具
function BagProxy:handle_MSG_SC_BAG_UPDATE_ITEM(msg)
    local data = ParseRawMsgToJson(msg)
    -- print("------------------------------------")
    -- print(" into here to update bag item")
    -- print("------------------------------------")
    if not data or next(data) == nil then
        return
    end

    local itemMakeIndex = data.MakeIndex or data.makeindex

    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    local itemBelong = ItemManagerProxy:GetItemBelong(itemMakeIndex)
    if not itemBelong then
        return
    end

    data = ChangeItemServersSendDatas(data)

    if global.MMO.ITEM_FROM_BELONG_BAG == itemBelong then
        local operator = {}
        operator.opera = global.MMO.Operator_Change
        operator.operID = {}
        local diff = self:ChangeItemData(data)
        tinsert(operator.operID, MAKE_OPER_DATA(data, true, diff))
        ssr.ssrBridge:OnPreBagOperData(operator)
        global.Facade:sendNotification(global.NoticeTable.Bag_Oper_Data, operator)
        ssr.ssrBridge:OnBagOperData(operator)
        SLBridge:onLUAEvent(LUA_EVENT_BAG_ITEM_CHANGE, operator)

        -- 延迟通知
        self:DelayNotifyBagOper()

    elseif global.MMO.ITEM_FROM_BELONG_EQUIP == itemBelong then
        local proxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        proxy:ChangeEquipData(data, true, true)

    elseif itemBelong == global.MMO.ITEM_FROM_BELONG_QUICKUSE then
        local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
        QuickUseProxy:UpDateQuickUseItemData(data)
    end

    -- for item update.
    local updateData = {
        from = itemBelong,
        item = data
    }
    global.Facade:sendNotification(global.NoticeTable.ItemUpdate, updateData)
end

function BagProxy:handle_MSG_SC_BAG_ITEM_USE_SUCCESS(msg)
    local header = msg:GetHeader()
    local ItemIndex = header.recog
end

-- 道具使用失败
function BagProxy:handle_MSG_SC_BAG_ITEM_USE_FAILED(msg)
    print("道具使用失败消息")
    local header = msg:GetHeader()
    local makeIndex = header.recog
    local itemData = self:GetItemDataByMakeIndex(makeIndex)
    if itemData and itemData.StdMode == 49 then
        -- 49类型道具使用失败提醒 0关闭  非0开启
        if SL:GetMetaValue("GAME_DATA","Pearl_on_off") ~= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000321))
        end
    end
end

-- 道具拾取失败 -1背包满 -2负重满 -3物品禁止拾取 -99假道具拾取
function BagProxy:handle_MSG_SC_DROP_ITEM_GET_FAILED(msg)
    local header = msg:GetHeader()
    local recog = header.recog
    if recog == -1 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(800050))
    elseif recog == -2 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(800052))
    elseif recog == -3 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(800056))
    elseif recog == -99 then
        local mapX = header.param1
        local mapY = header.param2
        local dItems = global.dropItemManager:FindDropItemAllInMapXY(mapX, mapY)
        if not dItems then
            return
        end
        for k, dItem in pairs(dItems) do
            if dItem:GetPickState() >= 1 or dItem:IsPickTimeout() then --移除
                global.gameMapController:rmvDropItem(dItem:GetID())
            end
        end
    end
end

-- 丢弃道具成功
function BagProxy:handle_MSG_SC_DROP_ITEM_SUCCESS(msg)
    local header = msg:GetHeader()
    local MakeIndex = header.recog
    if MakeIndex then
        tinsert(self._selfDropItems, MakeIndex)
        if #self._selfDropItems > 100 then -- 记录自己丢弃的物品   挂机拾取的时候忽略
            table.remove(self._selfDropItems, 1)
        end
        
        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
        local belong = ItemManagerProxy:GetItemBelong(MakeIndex)
        if global.MMO.ITEM_FROM_BELONG_BAG == belong then
            -- 背包中的重新刷出来
            local data = {
                dropping = {
                    MakeIndex = MakeIndex,
                    state = 1
                }
            }
            global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)

        elseif global.MMO.ITEM_FROM_BELONG_QUICKUSE == belong then
            local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
            local itemPos = QuickUseProxy:GetQucikUsePosByMakeIndex(MakeIndex)
            local data = {
                pos = itemPos,
                state = 1
            }
            global.Facade:sendNotification(global.NoticeTable.QuickUseItemRefresh, data)
            ssr.ssrBridge:OnQuickUseOperData({
                opera = 4,
                param = data
            })
        end
    end

    local AutoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    AutoProxy:ClearAutoMining()
end

-- 丢弃道具失败
function BagProxy:handle_MSG_SC_DROP_ITEM_FAILED(msg)
    local header = msg:GetHeader()
    local MakeIndex = header.recog
    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    local belong = ItemManagerProxy:GetItemBelong(MakeIndex)
    if global.MMO.ITEM_FROM_BELONG_BAG == belong then
        -- 背包中的重新刷出来
        local data = {
            dropping = {
                MakeIndex = MakeIndex,
                state = 1
            }
        }
        global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)

    elseif global.MMO.ITEM_FROM_BELONG_QUICKUSE == belong then
        local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
        local itemPos = QuickUseProxy:GetQucikUsePosByMakeIndex(MakeIndex)
        local data = {
            pos = itemPos,
            state = 1
        }
        global.Facade:sendNotification(global.NoticeTable.QuickUseItemRefresh, data)
        ssr.ssrBridge:OnQuickUseOperData({
            opera = 4,
            param = data
        })
    end
end

-- 移动到英雄背包失败
function BagProxy:handle_MSG_SC_HUMBAG_TO_HEROBAG_FAIL(msg)
    local header = msg:GetHeader()
    local MakeIndex = header.recog
    dump(header, "handle_MSG_SC_HUMBAG_TO_HEROBAG_FAIL")

    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    local belong = ItemManagerProxy:GetItemBelong(MakeIndex)
    if global.MMO.ITEM_FROM_BELONG_BAG == belong then
        -- 背包中的重新刷出来
        local data = {
            dropping = {
                MakeIndex = MakeIndex,
                state = 1
            }
        }
        global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)

    elseif global.MMO.ITEM_FROM_BELONG_QUICKUSE == belong then
        local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
        local itemPos = QuickUseProxy:GetQucikUsePosByMakeIndex(MakeIndex)
        local data = {
            pos = itemPos,
            state = 1
        }
        global.Facade:sendNotification(global.NoticeTable.QuickUseItemRefresh, data)
        ssr.ssrBridge:OnQuickUseOperData({
            opera = 4,
            param = data
        })
    end
end

-- 整理背包
function BagProxy:handle_MSG_SC_RESET_BAG_POS(msg)
    local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
    local bagData = self:GetBagData()
    for _, v in pairs(bagData) do
        local isCanAddToQuick = QuickUseProxy:CheckItemCanAddToQuickUse(v)
        local quickUsePos = QuickUseProxy:CheckQuickUseHasEmpty()
        -- 快捷栏道具
        if isCanAddToQuick and quickUsePos then
            QuickUseProxy:AutoAddBagItemToQuick(v, quickUsePos)
        end
    end

    local newData = self:GetBagData()
    self:CleanBagPosData()
    self:AmendHistoryPos(newData, true)

    global.Facade:sendNotification(global.NoticeTable.Bag_Pos_Reset)

    SLBridge:onLUAEvent(LUA_EVENT_REF_ITEM_LIST)
end

-- 开启准星
function BagProxy:handle_MSG_SM_COLLIMATOR_RESPONSE(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if jsonData and jsonData.UseMakeIndex then
        if jsonData.UseMakeIndex > -1 then
            self:SetBagCollimator(jsonData.UseMakeIndex)
            global.Facade:sendNotification(global.NoticeTable.Bag_Item_Collimator, jsonData.UseMakeIndex)

        elseif jsonData.UseMakeIndex == -1 then
            self:SetBagCollimator(jsonData.UseMakeIndex)
            global.Facade:sendNotification(global.NoticeTable.Layer_Sight_Bead_Show)
        end
    end
end

-- 物品自定义属性
function BagProxy:handle_MSG_SC_ITEM_PARAMS(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return
    end

    for i,v in pairs(jsonData) do
        self._customAttrs[v.m] = v.p
        SLBridge:onLUAEvent(LUA_EVENT_ITEM_CUSTOM_ATTR, {
            MakeIndex = v.m,
            data = v.p
        })
    end
end

-- 请求背包数据
function BagProxy:RequestBagData()
    self:Inited(true)

    LuaSendMsg(global.MsgType.MSG_CS_REQUEST_BAGDATA)
end

-- 叠加道具
function BagProxy:RequestItemTwoToOne(MakeIndex1, MakeIndex2)
    LuaSendMsg(global.MsgType.MSG_CS_ITEM_TWO_TO_ONE, MakeIndex1, MakeIndex2, 0, 0)
end

-- 拆分道具
function BagProxy:RequestCountItem(makeIndex, num)
    LuaSendMsg(global.MsgType.MSG_CS_ITEM_NUMBER_CHANGE, makeIndex, num, 0, 0)
end

-- 请求准星瞄准消息(使用)
function BagProxy:RequestCollimator(MakeIndex)
    if MakeIndex then
        LuaSendMsg(global.MsgType.MSG_CM_COLLIMATOR_REQUEST, MakeIndex)
    end
end

-- 请求取消准星瞄准
function BagProxy:RequestCanceCollimator()
    LuaSendMsg(global.MsgType.MSG_CM_CANCELCOLLIMATOR_REQUEST, 0, 0, 0, 0)
end

function BagProxy:onRegister()
    BagProxy.super.onRegister(self)
end

function BagProxy:RegisterMsgHandler()
    BagProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType
    LuaRegisterMsgHandler(msgType.MSG_SC_RETURN_BAGDATA, handler(self, self.handle_MSG_SC_RETURN_BAGDATA))
    LuaRegisterMsgHandler(msgType.MSG_SC_BAG_ADD_ITEM, handler(self, self.handle_MSG_SC_BAG_ADD_ITEM))
    LuaRegisterMsgHandler(msgType.MSG_SC_BAG_DEL_ITEM, handler(self, self.handle_MSG_SC_BAG_DEL_ITEM))
    LuaRegisterMsgHandler(msgType.MSG_SC_BAG_UPDATE_ITEM, handler(self, self.handle_MSG_SC_BAG_UPDATE_ITEM))
    LuaRegisterMsgHandler(msgType.MSG_SC_BAG_ITEM_USE_SUCCESS, handler(self, self.handle_MSG_SC_BAG_ITEM_USE_SUCCESS) )
    LuaRegisterMsgHandler(msgType.MSG_SC_BAG_ITEM_USE_FAILED, handler(self, self.handle_MSG_SC_BAG_ITEM_USE_FAILED))
    LuaRegisterMsgHandler(msgType.MSG_SC_DROP_ITEM_GET_FAILED, handler(self, self.handle_MSG_SC_DROP_ITEM_GET_FAILED))
    LuaRegisterMsgHandler(msgType.MSG_SC_DROP_ITEM_SUCCESS, handler(self, self.handle_MSG_SC_DROP_ITEM_SUCCESS))
    LuaRegisterMsgHandler(msgType.MSG_SC_DROP_ITEM_FAILED, handler(self, self.handle_MSG_SC_DROP_ITEM_FAILED))
    LuaRegisterMsgHandler(msgType.MSG_SC_HUMBAG_TO_HEROBAG_FAIL, handler(self, self.handle_MSG_SC_HUMBAG_TO_HEROBAG_FAIL))
    LuaRegisterMsgHandler(msgType.MSG_SC_RESET_BAG_POS, handler(self, self.handle_MSG_SC_RESET_BAG_POS))
    LuaRegisterMsgHandler(msgType.MSG_SM_COLLIMATOR_RESPONSE, handler(self, self.handle_MSG_SM_COLLIMATOR_RESPONSE))
    LuaRegisterMsgHandler(msgType.MSG_SC_RETURN_BAGDATA_REMAINING, handler(self, self.handle_MSG_SC_RETURN_BAGDATA))
    LuaRegisterMsgHandler(msgType.MSG_SC_ITEM_PARAMS, handler(self, self.handle_MSG_SC_ITEM_PARAMS))
end

return BagProxy