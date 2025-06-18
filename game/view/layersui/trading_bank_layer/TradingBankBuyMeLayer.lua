local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankBuyMeLayer = class("TradingBankBuyMeLayer", BaseLayer)
local QuickCell = requireUtil("QuickCell")
local cjson = require("cjson")
local SelectType ={
    [1] = nil, [2] = 1, [3] = 2 ,[4] = 3
}
function TradingBankBuyMeLayer:ctor()
    TradingBankBuyMeLayer.super.ctor(self)
    self._tradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    self._tradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
    self._commodityType = self._tradingBankProxy:GetCommodityType()
end

function TradingBankBuyMeLayer.create(...)
    local ui = TradingBankBuyMeLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end
function TradingBankBuyMeLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_buy_me")
    self._root = ui_delegate(self)
    self.m_page = 1
    self.m_maxpage = 1
    self.m_pagenum = 10
    self.m_data = {}
    self.m_selType = 1 -- 1全部 2 角色 3货币 4装备
    self.m_order_price = nil
    self:InitUI(data)
    local val = {
        page = self.m_page,
        pagenum = self.m_pagenum
    }
    self:ReqgetTargetGoodsInfo(val, handler(self, self.refListView))

    local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingBuyLayerMe)
    return true
end
function TradingBankBuyMeLayer:InitUI(data)
    self._root.Panel_item:setVisible(false)
    self._root.ListView_2:addScrollViewEventListener(function(sender, event)
        local itemnum = #sender:getItems()
        local Bottomitem = sender:getBottommostItemInCurrentView()
        local lastitem = sender:getItem(itemnum - 1)
        if (event == 1 or (event == 10 and lastitem == Bottomitem)) and self.m_page < self.m_maxpage and not self.m_reqState then
            self.m_reqState = true
            local val = {
                type = SelectType[self.m_selType],
                page = self.m_page + 1,
                pagenum = self.m_pagenum,
                order_price = self.m_order_price
            }
            self:ReqgetTargetGoodsInfo(val, handler(self, self.refListView))
        end
    end)


    self._root.Panel_type3:addTouchEventListener(function(sender, type)
        if type ~= 2 then
            return
        end
        local size = self._root.Panel_type3:getContentSize()
        local txt = { GET_STRING(600000110), GET_STRING(600000001), GET_STRING(600000002), GET_STRING(600000603) }
        local worldpos = cc.p(self._root.Panel_type3:getWorldPosition())
        worldpos.y = worldpos.y - size.height
        local callback = function(index)
            if self.m_selType ~= index then
                self._root.Text_type3:setString(txt[index])
                self.m_selType = index
                self.m_page = 1
                self.m_maxpage = 1
                self.m_order_price = nil
                self._root.ListView_2:removeAllChildren()
                local val = {
                    type = SelectType[self.m_selType],
                    page = self.m_page,
                    pagenum = self.m_pagenum,
                    order_price = self.m_order_price
                }
                self:ReqgetTargetGoodsInfo(val, handler(self, self.refListView))
            end
        end
        local val = {
            width = size.width,
            txt = txt,
            index = self.m_selType,
            pos = worldpos,
            callback = callback
        }
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyTipsLayer_Open, val)
    end)
    self._root.Panel_price3:addTouchEventListener(function(sender, type)--等级价格
        if type ~= 2 then
            return
        end
        if self.m_order_price == "desc" then
            self.m_order_price = "asc"
        else
            self.m_order_price = "desc"
        end
        self.m_page = 1
        self.m_maxpage = 1
        self._root.ListView_2:removeAllChildren()
        local val2 = {
            type = SelectType[self.m_selType],
            page = self.m_page,
            pagenum = self.m_pagenum,
            order_price = self.m_order_price,
        }
        self:ReqgetTargetGoodsInfo(val2, handler(self, self.refListView))
    end)
end
function TradingBankBuyMeLayer:ReqgetTargetGoodsInfo(val, func)
    self.m_reqState = true
    self._tradingBankProxy:getTargetGoodsInfo(self, val, func)
end
function TradingBankBuyMeLayer:refListView(success, response, code)
    dump({ success, response, code }, "refListView__")
    -- local TradingBankBuyMeLayerMediator = global.Facade:retrieveMediator("TradingBankBuyMeLayerMediator")
    -- if not TradingBankBuyMeLayerMediator._layer then
    --     return 
    -- end
    self.m_reqState = false
    if success then
        local data = cjson.decode(response)
        if data.code == 200 then
            data = data.data
            self.m_page = data.current_page
            self.m_maxpage = data.last_page
            local listdata = data.data
            dump(listdata, "listdata__")
            local lastIndex = #self._root.ListView_2:getItems() - 1
            for i, v in ipairs(listdata) do
                local itemSize = self._root.Panel_item:getContentSize()
                local cell_data = {}
                cell_data.wid = itemSize.width
                cell_data.hei = itemSize.height
                cell_data.anchor = cc.p(0.5, 1)
                cell_data.tick_interval = 0.05
                cell_data.createCell = function()
                    local cell = self:createItem(v)
                    return cell
                end
                local item = QuickCell:Create(cell_data)
                -- local item = self:createItem(v)
                self._root.ListView_2:pushBackCustomItem(item)
            end
            self._root.ListView_2:jumpToItem(lastIndex, cc.p(0, 0), cc.p(0, 0))
        elseif data.code >= 50000 and data.code <= 50020 then--token失效
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open)
        end

    end
end
function TradingBankBuyMeLayer:createItem(data)
    local item = self._root.Panel_item:clone()
    item:setVisible(true)

    local Image_item = item:getChildByName("Image_item")
    local Text_goodname = item:getChildByName("Text_goodname")
    local Text_name = item:getChildByName("Text_name")
    -- local Text_num = item:getChildByName("Text_num")
    local Text_pirce = item:getChildByName("Text_pirce")
    local Button_buy = item:getChildByName("Button_buy")
    local Image_head = Image_item:getChildByName("Image_head")
    Text_name:setString(data.role or "")
    Text_pirce:setString(data.price or "0")
    local goodname = ""
    if data.type == self._commodityType.Money then
        goodname = string.format(GET_STRING(600000120), data.coin_config_type_name, data.coin_num)
        --Image_head:loadTexture(global.MMO.PATH_RES_PRIVATE.."trading_bank/img_cost.png")
        Image_item:setVisible(false)
        Text_goodname:setPositionX(Text_goodname:getPositionX() - 30)
        Text_goodname:setFontSize(20)
    elseif data.type == self._commodityType.Role then
        Text_goodname:setFontSize(16)
        local jobid = "0"
        if data.role_config_id and string.len(data.role_config_id) > 0 then
            jobid = data.role_config_id
        end
        local sex = data.sex or 0 -- 0-1 男女
        jobid = tonumber(jobid)
        local jobName = GET_STRING(600000111 + jobid)
        Image_head:loadTexture(global.MMO.PATH_RES_PRIVATE .. "trading_bank/img_0" .. (sex + 1) .. (jobid + 1) .. ".png")
        item:setTouchEnabled(true)
        item:addTouchEventListener(function(sender, type)
            if type ~= 2 then
                return
            end

            self._tradingBankLookPlayerProxy:RequestPlayerData(data.role_id, function()
                local TradingBankBuyMeLayerMediator = global.Facade:retrieveMediator("TradingBankBuyMeLayerMediator")
                if not TradingBankBuyMeLayerMediator._layer then
                    return
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerInfo_Open, { position = cc.p(150, 60) ,data = data})
            end)

        end)
        goodname = string.format(GET_STRING(600000120), GET_STRING(600000121), jobName)
    elseif data.type == self._commodityType.Equip then
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        local itemData = ItemConfigProxy:GetItemDataByIndex(data.equip_id)
        local goodparam = {index = data.equip_id}
        if data.equip_num and data.equip_num > 1 then 
            goodparam.count = data.equip_num
        end
        local goodsItem = GoodsItem:create(goodparam)
        Image_head:setVisible(false)
        Image_item:addChild(goodsItem)
        local size = Image_item:getContentSize()
        goodsItem:setPosition(size.width / 2, size.height / 2)
        local color = (itemData.Color and itemData.Color > 0) and itemData.Color or 255
        goodname = itemData.Name or ""
        Text_goodname:setTextColor(SL:GetColorByStyleId(color))
        goodsItem:addTouchEventListener(function()--点击tips
            self._tipsIndex = self._tradingBankProxy:GetTipsIndex() 
            self._tipsPos = Image_item:getWorldPosition()
            self._tradingBankProxy:ReqQueryItemData(data.id, self._tipsIndex)
        end, 2)
    end
    Text_goodname:setString(goodname)
    Button_buy:addTouchEventListener(function(sender, type)
        if type ~= 2 then
            return
        end
        local callback
        if data.type == 1 then --角色
            callback = function()
                local data = {}
                data.txt = GET_STRING(600000192)--
                data.btntext = { GET_STRING(600000139), GET_STRING(600000193) }
                data.callback = function(res)
                    if res == 1 then
                        self._root.ListView_2:removeAllChildren()
                        self.m_page = 1
                        local val = {
                            page = self.m_page,
                            pagenum = self.m_pagenum,
                            order_price = self.m_order_price,
                        }

                        self:ReqgetTargetGoodsInfo(val, handler(self, self.refListView))
                    elseif res == 2 then
                        global.gameWorldController:OnGameLeaveWorld()
                    end
                end
                dump("调用退出提示——————")
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, data)
            end

        else
            callback = function()
                self._root.ListView_2:removeAllChildren()
                self.m_page = 1
                local val = {
                    page = self.m_page,
                    pagenum = self.m_pagenum,
                    order_price = self.m_order_price,
                }

                self:ReqgetTargetGoodsInfo(val, handler(self, self.refListView))
            end
        end
        self:reqcommodityInfo({ data = data, callback = callback, role_id = data.role_id, type = data.type })
        
        local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
        TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingBuyClick)
    end)
    -- Text_num:setString(data.coin_num or "0")
    item.Data = data
    return item
end

function TradingBankBuyMeLayer:OnTips(data)
    local itemData = data.itemData
    local tipsIndex = data.tipsIndex
    if self._tipsIndex == tipsIndex then 
        local param = {itemData = itemData, isHideFrom = true, pos = self._tipsPos}
        global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, param)
    end
end

function TradingBankBuyMeLayer:reqcommodityInfo(val)
    self._tradingBankProxy:reqcommodityInfo(self, { commodity_id = val.data.id }, function(success, response, code)
        if success then
            local data = cjson.decode(response)
            if data.code == 200 then
                data = data.data
                -- local order_id = data.order_id
                -- self._order_id = order_id
                if data.status and data.status == 3 then--已出售
                    local data = {}
                    data.txt = GET_STRING(600000185)--
                    data.callback = function()
                    end
                    data.btntext = { GET_STRING(600000139) }
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, data)
                else
                    if val.type == self._commodityType.Role then--角色
                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPlayerLayer_Open, { data = data, callback = val.callback, role_id = val.role_id })
                    else
                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFLayer_Open, { data = data, callback = val.callback })
                    end
                end
            elseif data.code >= 50000 and data.code <= 50020 then--token失效
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open, { callback = function(code)
                    if code == 1 then
                        self:reqcommodityInfo(val)
                    else
                        -- global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankGoodsLayer_Close)
                    end
                end })
            else
                global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg or "")
            end
        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000137))
        end
    end)
end
function TradingBankBuyMeLayer:sortList(func)
    local items = self._root.ListView_2:getItems()
    for i, v in ipairs(items) do
        v:retain()
    end
    self._root.ListView_2:removeAllChildren()
    table.sort(items, func)
    for i, v in ipairs(items) do
        self._root.ListView_2:pushBackCustomItem(v)
    end

end

function TradingBankBuyMeLayer:exitLayer()
    self._tradingBankProxy:removeLayer(self)
end

return TradingBankBuyMeLayer