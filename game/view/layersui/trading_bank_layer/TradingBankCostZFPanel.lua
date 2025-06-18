local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankCostZFPanel = class("TradingBankCostZFPanel", BaseLayer)
local loginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
local cjson = require("cjson")

local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
function TradingBankCostZFPanel:ctor()
    TradingBankCostZFPanel.super.ctor(self)
    self._tradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    self._commodityType = self._tradingBankProxy:GetCommodityType()
end

function TradingBankCostZFPanel.create(...)
    local ui = TradingBankCostZFPanel.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankCostZFPanel:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_cost_zf_panel")
    self._root = ui_delegate(self)
    self.m_data = data.data
    self.m_callback = data and data.callback
    self:InitUI(self.m_data)
    -- self:reqUserMoney()
    return true
end
function TradingBankCostZFPanel:InitUI(data)
    if data.type == self._commodityType.Money then
        self._root.Text_money:setString(data.coin_config_type_name .. ":" .. data.coin_num)
    elseif data.type == self._commodityType.Equip then
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        local itemData = ItemConfigProxy:GetItemDataByIndex(data.equip_id)
        local goodparam = { index = data.equip_id}
        if data.equip_num and data.equip_num > 1 then 
            goodparam.count = data.equip_num
        end
        local goodsItem = GoodsItem:create(goodparam)
        self._root.Image_icon:addChild(goodsItem)
        self._root.Image_head:setVisible(false)
        local size = self._root.Image_icon:getContentSize()
        goodsItem:setPosition(size.width / 2, size.height / 2)
        goodsItem:addTouchEventListener(function()--点击tips
            self._tipsIndex = self._tradingBankProxy:GetTipsIndex() 
            self._tipsPos = self._root.Image_icon:getWorldPosition()
            self._tradingBankProxy:ReqQueryItemData(data.id, self._tipsIndex)
        end, 2)
        local color = (itemData.Color and itemData.Color > 0) and itemData.Color or 255
        local name = itemData.Name or ""
        -- 道具名字
        self._root.Text_money:setString(name)
        self._root.Text_money:setTextColor(SL:GetColorByStyleId(color))
    end
    self._root.Text_name:setString(GET_STRING(600000157) .. ":" .. data.role)
    local price = data.price or 0
    self._root.Text_serverName:setString(loginProxy:GetSelectedServerName())
    self._root.Text_account:setString(AuthProxy:GetUsername())
    self._root.Text_money1:setString("￥" .. price)

    self._root.ButtonClose:addTouchEventListener(handler(self, self.onBtnClick))
    self._root.Button_buy:addTouchEventListener(handler(self, self.onBtnClick))
    self._root.Text_tips:setVisible(false)
    if data.status == 3 then
        self._root.Text_tips:setVisible(true)
        self._root.Button_buy:setVisible(false)
    end
end

function TradingBankCostZFPanel:OnTips(data)
    local itemData = data.itemData
    local tipsIndex = data.tipsIndex
    if self._tipsIndex == tipsIndex then 
        local param = {itemData = itemData, isHideFrom = true, pos = self._tipsPos}
        global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, param)
    end
end

function TradingBankCostZFPanel:onBtnClick(sender, type)
    if type ~= 2 then
        return
    end
    local name = sender:getName()
    if name == "ButtonClose" then
        self:CloseLayer()
    elseif name == "Button_buy" then
        --提交订单
        self:reqcommodityInfo()
    end
end
function TradingBankCostZFPanel:reqcommodityInfo()
    self._tradingBankProxy:reqcommodityInfo(self, { commodity_id = self.m_data.id }, handler(self, self.rescommodityInfo))
end
function TradingBankCostZFPanel:rescommodityInfo(success, response, code)
    if success then
        local data = cjson.decode(response)
        if data.code == 200 then
            data = data.data
            if data.status and data.status == 3 then--已出售
                self._root.Text_tips:setVisible(true)
                self._root.Button_buy:setVisible(false)
            else
                self._tradingBankProxy:reqOrderPlace(self, { commodity_id = self.m_data.id }, handler(self, self.resOrderPlace))--下单

            end
        elseif data.code >= 50000 and data.code <= 50020 then--token失效
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open, { callback = function(code)
                if code == 1 then
                    self:reqcommodityInfo()
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

end
function TradingBankCostZFPanel:resOrderPlace(success, response, code)
    dump({ success, response, code }, "resOrderPlace___")
    if success then
        local data = cjson.decode(response)
        if data.code == 200 then
            data = data.data
            self._root.ButtonClose:setVisible(false)
            self._root.Button_buy:setVisible(false)
            local order_id = data.order_id
            local data = self.m_data
            data.order_id = order_id
            data.state = 2
            -- self:retain()
            local parent = self:getParent()
            local Node1 = parent:getParent():getChildByName("Node_1")
            local Node2 = parent:getParent():getChildByName("Node_2")
            -- self:removeFromParent()
            -- self:addTo(parent:getParent():getChildByName("Node_2"))
            -- self:release()
            Node1:setPosition(cc.p(Node2:getPosition()))
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPanel_Open, { parent = parent:getParent():getChildByName("Node_3"), data = data, callback = self.m_callback })
        elseif data.code >= 50000 and data.code <= 50020 then--token失效
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open, { callback = function(code)
                if code == 1 then
                    self._tradingBankProxy:reqOrderPlace(self, { commodity_id = self.m_data.id }, handler(self, self.resOrderPlace))
                else
                    -- global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankGoodsLayer_Close)
                end
            end })
        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg or "")
        end

    else
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000158))
    end
end
function TradingBankCostZFPanel:onButtonClick(sender, type)
    if type ~= 2 then
        return
    end
    local tag = sender:getTag()
    self:setSelPayType(tag)
end

function TradingBankCostZFPanel:CloseLayer()
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFPanel_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFLayer_Close)
end

function TradingBankCostZFPanel:exitLayer()
    self._tradingBankProxy:removeLayer(self)
end
-------------------------------------
return TradingBankCostZFPanel