local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankZFPanel = class("TradingBankZFPanel", BaseLayer)
local loginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
local cjson = require("cjson")
local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
function TradingBankZFPanel:ctor()
    TradingBankZFPanel.super.ctor(self)
    self.TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)

end
local payChannel = {
    "ALIPAY",
    "WEIXIN",
    "TRADE", --996盒币
    "GOLD", --996金币
    "ALIPAY_SCAN", --支付宝二维码
    "WEIXIN_SCAN", --微信二维码
}
function TradingBankZFPanel.create(...)
    local ui = TradingBankZFPanel.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankZFPanel:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_zf_panel")
    self._root = ui_delegate(self)
    self.m_data = data.data
    self.m_isrole = data.isrole
    self.m_callback = data and data.callback
    self:InitUI(self.m_data)
    self:reqUserMoney()
    return true
end
function TradingBankZFPanel:InitUI(data)
    self._root.Panel_11:setVisible(false)
    self._root.Panel_12:setVisible(false)
    self._root.Text_tips:setVisible(false)
    if data.status == 3 then
        self._root.Text_tips:setVisible(true)
        self._root.Button_buy1:setVisible(false)
    end
    for i = 1, 6 do
        local btn = self._root["Panel_pay" .. i]
        btn:setTag(i)
        btn:addTouchEventListener(handler(self, self.onButtonClick))

    end
    self._initPayType = 1
    local isEMU    = global.L_GameEnvManager:IsEmulator()
    self.platform = "game_ad"
    if global.isAndroid or global.isOHOS then 
        self.platform = "game_ad"
    elseif global.isIOS then  
        self.platform = "game_ios"
    end
    if global.isWindows then--pc  二维码支付
        self._root.Panel_pay1:setVisible(false)
        -- self._root.Panel_pay3:setVisible(false)
        self.platform = "game_pc"
        self._initPayType = 5
        self._root.Panel_more:setVisible(false)
        self._root.Panel_pay5:setPositionY(self._root.Panel_pay1:getPositionY())
        self._root.Panel_pay6:setPositionY(self._root.Panel_pay3:getPositionY())
        -- self._root.Panel_pay3:setPositionY(self._root.Panel_pay2:getPositionY())
    else
        self._root.Panel_pay5:setVisible(false)
        self._root.Panel_pay6:setVisible(false)
    end
    ----------微信暂无
    self._root.Panel_pay4:setVisible(false)
    self._root.Panel_pay6:setVisible(false)
    self._root.Panel_more:setVisible(false)
    ----------

    self._root.Panel_pay2:setVisible(false)
    self._root.Panel_more:addTouchEventListener(handler(self, self.onBtnClick))
    self._root.ButtonClose:addTouchEventListener(handler(self, self.onBtnClick))
    self._root.Button_buy1:addTouchEventListener(handler(self, self.onBtnClick))
    self._root.Button_buy2:addTouchEventListener(handler(self, self.onBtnClick))
    -- self._root.Panel_cancel:addTouchEventListener(handler(self,self.onBtnClick))
    self._state = self.m_data.state or 1
    self._time = self.m_data.time or 180
    self._order_id = self.m_data.order_id
    self:setPayState(self._state)

end
--1支付信息  2订单信息
function TradingBankZFPanel:setPayState(index)
    self._root.Panel_11:setVisible(index == 1)
    self._root.Panel_12:setVisible(index == 2)
    local price = self.m_data.price or 0
    if index == 1 then
        self._root.Text_serverName:setString(loginProxy:GetSelectedServerName())
        self._root.Text_account:setString(AuthProxy:GetUsername())
        self._root.Text_money1:setString("￥" .. price)
    elseif index == 2 then
        self._root.Text_money2:setString("￥" .. price)
        self._root.Text_time2:stopAllActions()
        schedule(self._root.Text_time2, function(sender)
            self._time = self._time - 1
            sender:setString(self._time .. "S")
            if self._time == 0 then
                self.TradingBankProxy:reqCancelorder(self, { order_id = self._order_id }, handler(self, self.resCancelorder))
            end
        end, 1)
        self:setSelPayType(self._initPayType)
    end
end
--1支付宝   2微信 -3-交易币 4-交易金币--5 支付宝二维码--6微信二维码 
function TradingBankZFPanel:setSelPayType(index)
    for i = 1, 6 do
        local btn = self._root["Panel_pay" .. i]
        local Image_1 = UIGetChildByName(btn, "Image_2", "Image_1")
        Image_1:setVisible(i == index)
    end
    self.m_selType = index
    self._payChannel = payChannel[index]

    local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    if index == 5 then 
        -- TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingBuyAlipayEWM)
    elseif index == 3 then 
        TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingBuyJYB)
    end
end

function TradingBankZFPanel:onBtnClick(sender, type)
    if type ~= 2 then
        return
    end
    local name = sender:getName()
    if name == "ButtonClose" then
        if self._state == 2 then
            self.TradingBankProxy:reqCancelorder(self, { order_id = self._order_id }, handler(self, self.resCancelorder))
        else
            self:CloseLayer()
            --global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPanel_Close)
        end

    elseif name == "Panel_cancel" then
        -- global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPanel_Close)
    elseif name == "Panel_more" then
        self._root.Panel_pay2:setVisible(true)
        self._root.Panel_more:setVisible(false)
    elseif name == "Button_buy1" then-- 提交订单
        self:reqcommodityInfo() -- 查询一下当前物品的信息
    elseif name == "Button_buy2" then -- 确认支付
        self:reqpayOrder()
    end
end

function TradingBankZFPanel:resCancelorder(success, response, code)
    if success then
        local data = cjson.decode(response)
        dump({ success, response, code }, "resCancelorder___")
        if data.code == 200 then
        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg or "")
        end
    end
    self:CloseLayer()
    --global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPanel_Close)
end

function TradingBankZFPanel:reqpayOrder()
    if self._payChannel == "ALIPAY_SCAN" or self._payChannel == "WEIXIN_SCAN" then--二维码
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPowerfulLayer_Open, { type = 1, payinfo = { order_id = self._order_id, channel = self._payChannel, client_type = self.platform }, callback = self.m_callback })
    elseif self._payChannel == "ALIPAY" or self._payChannel == "WEIXIN" then--微信支付宝H5
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPowerfulLayer_Open, { type = 2, payinfo = { order_id = self._order_id, channel = self._payChannel, client_type = self.platform }, callback = self.m_callback })
    else    --交易币
        self.TradingBankProxy:reqpayOrder(self, { order_id = self._order_id, channel = self._payChannel, client_type = self.platform }, handler(self, self.respayOrder2))
    end
    local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingBuyConfirmPay)
end

function TradingBankZFPanel:reqcommodityInfo()
    self.TradingBankProxy:reqcommodityInfo(self, { commodity_id = self.m_data.id }, handler(self, self.rescommodityInfo))
end
function TradingBankZFPanel:rescommodityInfo(success, response, code)
    if success then
        local data = cjson.decode(response)
        if data.code == 200 then
            data = data.data
            -- local order_id = data.order_id
            -- self._order_id = order_id
            if data.status and data.status == 3 then--已出售
                self._root.Text_tips:setVisible(true)
                self._root.Button_buy1:setVisible(false)
            else
                self.TradingBankProxy:reqOrderPlace(self, { commodity_id = self.m_data.id }, handler(self, self.resOrderPlace2))--下单
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

function TradingBankZFPanel:resOrderPlace2(success, response, code)
    dump({ success, response, code }, "resOrderPlace___")
    if success then
        local data = cjson.decode(response)
        if data.code == 200 then
            data = data.data
            local order_id = data.order_id
            self._order_id = order_id
            self._state = 2
            self:setPayState(2)
        elseif data.code >= 50000 and data.code <= 50020 then--token失效
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open, { callback = function(code)
                if code == 1 then
                    self.TradingBankProxy:reqOrderPlace(self, { commodity_id = self.m_data.id }, handler(self, self.resOrderPlace2))
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
function TradingBankZFPanel:reqUserMoney()
    self.TradingBankProxy:reqUserMoney(self, {}, handler(self, self.resUserMoney))
end
function TradingBankZFPanel:resUserMoney(success, response, code)
    dump({ success, response, code }, "resUserMoney___")
    if success then
        local data = cjson.decode(response)
        if data.code == 200 then
            data = data.data
            local trade_coin = data.trade_coin
            -- local balance1 = data.balance
            local balance = self._root.Panel_pay3:getChildByName("Text_1")
            -- local gold = self._root.Panel_pay4:getChildByName("Text_1")
            balance:setString(string.format(GET_STRING(600000178), tonumber(trade_coin) / 100))
            -- gold:setString(string.format(GET_STRING(600000179),tonumber(gold1)/100))
        elseif data.code >= 50000 and data.code <= 50020 then--token失效
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open, { callback = function(code)
                if code == 1 then
                    self:reqUserMoney()
                else
                    -- global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankGoodsLayer_Close)
                end
            end })
        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg or "")
        end

    else
        -- global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING())
    end
end
function TradingBankZFPanel:showEWMImg(success, response, code)
end
function TradingBankZFPanel:respayOrder2(success, response, code)
    dump({ success, response, code }, "respayOrder2___")
    if success then
        local data = cjson.decode(response)
        if data.code == 200 then
            if self._payChannel == "TRADE" then
                self:ZFsuccess()
                -- elseif self._payChannel == payChannel[1] or self._payChannel == payChannel[2] then --微信 支付宝
                --     data = data.data
                --     if data and type(data) == "table" and data.pay_info  then
                --         -- cc.Application:getInstance():openURL(data.pay_info)
                --         self:openWebViewURL(data.pay_info)
                --     end
                -- else--二维码
            end

        elseif data.code >= 50000 and data.code <= 50020 then--token失效
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open, { callback = function(code)
                if code == 1 then
                    self.TradingBankProxy:reqpayOrder(self, { order_id = self._order_id, channel = self._payChannel, client_type = self.platform }, handler(self, self.respayOrder2))
                else

                end
            end })
        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg or "")
        end

    else
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000158))
    end
end

function TradingBankZFPanel:onButtonClick(sender, type)
    if type ~= 2 then
        return
    end
    local tag = sender:getTag()
    self:setSelPayType(tag)
end

function TradingBankZFPanel:ZFsuccess()
    if self.m_callback then
        self.m_callback()
    end
    global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000187))
    self:CloseLayer()

end
function TradingBankZFPanel:CloseLayer()
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPanel_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFLayer_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFPanel_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFLayer_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPlayerLayer_Close)
end
function TradingBankZFPanel:exitLayer()

    self.TradingBankProxy:removeLayer(self)
end

-------------------------------------
return TradingBankZFPanel