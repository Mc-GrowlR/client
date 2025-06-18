local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankZFPanel = class("TradingBankZFPanel", BaseLayer)

local cjson = require("cjson")

local utf8 = require("util/utf8")
function TradingBankZFPanel:ctor()
    TradingBankZFPanel.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    self.LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
end
local payChannel = {
    "ALIPAY",
    "HUABEI",
    "ALIPAY_EWM"
}
local payMax = 3
local getTimeStr = function (s)
    return string.format("%.2d:%.2d", s/60, s%60)
end
local BuyType = {
    ORDER = 1,
    PAY = 2,
}
function TradingBankZFPanel.create(...)
    local ui = TradingBankZFPanel.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankZFPanel:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_zf_panel")
    self._root = ui_delegate(self)
    dump(data,"data___")
    self.m_goodsData = data.goodsData
    -- self.m_orderData = data.orderData
    self.m_callback = data.callback
    self:InitUI()
    return true
end

function TradingBankZFPanel:InitUI()
    for i = 1, payMax do
        local btn = self._root["Panel_pay" .. i]
        btn:setTag(i)
        btn:addTouchEventListener(handler(self, self.onButtonClick))
    end
    self._initPayType = 1
    local isEMU    = global.L_GameEnvManager:IsEmulator()
    self.platform = global.isAndroid and "game_ad" or "game_ios"
    
    self._root.ButtonClose:addTouchEventListener(handler(self, self.onBtnClick))
    self._root.Button_buy2:addTouchEventListener(handler(self, self.onBtnClick))

    self._root.Text_money2:setString("￥" .. self.m_goodsData.price)
    self._root.Text_serverName:setString(utf8:show_sub(self.m_goodsData.serverName, 1, 16))
    self._root.Text_time:stopAllActions()
    self._root.Text_time:setVisible(false)
    self._root.Text_time_desc:setVisible(true)
    self._root.Text_time_desc2:setVisible(false)
    self._root.Text_time_desc3:setVisible(false)
    self._buyType = BuyType.ORDER
    self:setSelPayType(self._initPayType)
    ------协议
    local RichTextHelp = requireUtil("RichTextHelp")
    local pstr = self.OtherTradingBankProxy.PrivacyPolicyList
    local PrivacyPolicyStr = string.format(GET_STRING(600000659), pstr[1], pstr[2], pstr[3], pstr[4], pstr[5])

    local PrivacyPolicy = RichTextHelp:CreateRichTextWithXML(PrivacyPolicyStr, 600, 15)
    self._root.Panel_agreement:addChild(PrivacyPolicy)
    PrivacyPolicy:setAnchorPoint(0, 1)
    PrivacyPolicy:setPosition(26, 90)
    PrivacyPolicy:setOpenUrlHandler(function(sender, url)
        cc.Application:getInstance():openURL(url)
    end)
    self._root.CheckBox:setSelected(self:getAgreement())
    self._root.Panel_agreement:addClickEventListener(function(sender, type)--协议
        self._root.CheckBox:setSelected(not self._root.CheckBox:isSelected())
        self:saveAgreement()
    end)
    --检测是否自己下单
    self._root.Button_buy2:setVisible(false)
    self:commodityIsMyOrder()
end

function TradingBankZFPanel:commodityIsMyOrder()
    self.OtherTradingBankProxy:commodityIsMyOrder(self,{commodityId = tonumber(self.m_goodsData.id)},function (code ,data ,msg)
        if code == 200 then 
            self._root.Button_buy2:setVisible(true)
            if data then 
                self.m_orderData = data
                self._order_id = self.m_orderData.id
                self._time = math.max(self.m_orderData.expireTime - GetServerTime(), 0)
                self._root.Text_time:stopAllActions()
                self._root.Text_time:setVisible(true)
                self._root.Text_time_desc2:setVisible(true)
                self._root.Text_time_desc3:setVisible(true)
                self._root.Text_time_desc:setVisible(false)
                schedule(self._root.Text_time, function(sender)
                    self._time = math.max(self.m_orderData.expireTime - GetServerTime(), 0)
                    sender:setString(self._time.."S")
                    if self._time <= 0 then
                        self.OtherTradingBankProxy:reqCancelorder(self, { order_id = self._order_id }, handler(self, self.resCancelorder))
                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPowerfulLayer_Close_other)
                    end
                end, 1)
                self._root.Text_time:setString(self._time.."S")
                self._root.Button_buy2:setTitleText(GET_STRING(600000662))

                self._buyType = BuyType.PAY
            end
        elseif code == 40050 then --锁定中
            self._root.Button_buy2:setVisible(true)
        else
            ShowSystemTips(msg or GET_STRING(600000137))
        end      
    end)
end 

----协议
function TradingBankZFPanel:saveAgreement()
    local mainPlayerID = self.LoginProxy:GetSelectedRoleID()
    local path    = "TradingBank" .. mainPlayerID
    local key    = "PrivacyPolicyAgreement"
    local userData = UserData:new(path)

    local writeData = { agree = self._root.CheckBox:isSelected() and 1 or 0 }
    local jsonStr = cjson.encode(writeData)
    userData:setStringForKey(key, jsonStr)
end

function TradingBankZFPanel:getAgreement()
    local mainPlayerID = self.LoginProxy:GetSelectedRoleID()
    local path    = "TradingBank" .. mainPlayerID
    local key    = "PrivacyPolicyAgreement"
    local userData = UserData:new(path)
    local jsonStr = userData:getStringForKey(key, "")
    if not jsonStr or string.len(jsonStr) == 0 then
        return true
    end

    local jsonData = cjson.decode(jsonStr)
    if not jsonData then
        return true
    end
    return jsonData.agree == 1
end
--1支付宝   2花呗   3 支付宝扫码
function TradingBankZFPanel:setSelPayType(index)
    for i = 1, payMax do
        local btn = self._root["Panel_pay" .. i]
        local Image_1 = UIGetChildByName(btn, "Image_2", "Image_1")
        Image_1:setVisible(i == index)
    end
    self.m_selType = index
    self._payChannel = payChannel[index]
end

function TradingBankZFPanel:onBtnClick(sender, type)
    if type ~= 2 then
        return
    end
    local name = sender:getName()
    if name == "ButtonClose" then
        --self.OtherTradingBankProxy:reqCancelorder(self, { order_id = self._order_id }, handler(self, self.resCancelorder))
        --v1.1 关闭  不取消订单 
        self:CloseLayer()
    elseif name == "Button_buy2" then -- 确认支付
        if not self._root.CheckBox:isSelected() then 
            ShowSystemTips(GET_STRING(600000652))
            return 
        end
        --下单 
        if self._buyType == BuyType.ORDER then 
            self.OtherTradingBankProxy:reqcommodityInfo(self, { commodity_id = self.m_goodsData.id }, function(code, data, msg)
                if code == 200 then
                    dump(data,"商品信息")
                    local mainServerId = self.LoginProxy:GetMainSelectedServerId()
                    local goodMainServerId =  tonumber(data.mainServerId)
                    local sameServer = false
                    if mainServerId and goodMainServerId then 
                        if  mainServerId == goodMainServerId then 
                            sameServer = true 
                        end
                    else
                        if tonumber(self.LoginProxy:GetSelectedServerId()) == tonumber(data.serverId) then 
                            sameServer = true 
                        end
                    end
                    if not sameServer then 
                        local params = {}
                        params.type = 1
                        params.btntext = {GET_STRING(600000653),GET_STRING(600000704)}
                        params.text = string.format(GET_STRING(600000705), self.m_goodsData.serverName or "") 
                        params.titleImg = global.MMO.PATH_RES_PRIVATE .. "trading_bank_other/img_tips.png"
                        params.callback = function(res)
                            if res == 1 or res == 2 or res == 3 then
                                if res == 2 then 
                                    self:reqOrderPlace()
                                end
                                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Close_other)
                            end
                        end
                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open_other, params)
                    else 
                        self:reqOrderPlace()
                    end
                else
                    ShowSystemTips(msg)
                end
            end)
        else 
            self.OtherTradingBankProxy:doTrack(self.OtherTradingBankProxy.UpLoadData.TraingBuyLayerOKBtnClick)
        --支付
            self:reqpayOrder()
        end
    end
end
--下单
function TradingBankZFPanel:reqOrderPlace()
    local val = {}
    val.callback = function(res)
    end
    val.showPayTips = true
    val.notcancel = true
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, val)
    self.OtherTradingBankProxy:reqOrderPlace(self, { commodity_id = self.m_goodsData.id }, handler(self, self.resOrderPlace))--下单
end

function TradingBankZFPanel:resOrderPlace(code, data, msg)
    dump({ code, data, msg }, "resOrderPlace___")
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Close_other)
    if code == 200 then
        self.OtherTradingBankProxy:doTrack(self.OtherTradingBankProxy.UpLoadData.TraingCreateOrder,
                    {
                        properities = {
                            amount = string.format("%0.2f元",self.m_goodsData.price),
                            prodid = self.m_goodsData.id,
                            prod_name = self.m_goodsData.role
                        }
                    })
        ----下单成功
        self.m_orderData = data
        self._order_id = self.m_orderData.id
        self._time = math.max(self.m_orderData.expireTime - GetServerTime(), 0)
        self._root.Text_time:stopAllActions()
        self._root.Text_time:setVisible(true)
        self._root.Text_time_desc2:setVisible(true)
        self._root.Text_time_desc3:setVisible(true)
        self._root.Text_time_desc:setVisible(false)

        schedule(self._root.Text_time, function(sender)
            self._time = math.max(self.m_orderData.expireTime - GetServerTime(), 0)
            sender:setString(self._time.."S")
            if self._time <= 0 then
                self.OtherTradingBankProxy:reqCancelorder(self, { order_id = self._order_id }, handler(self, self.resCancelorder))
            end
        end, 1)
        self._root.Text_time:setString(self._time.."S")

        self._root.Button_buy2:setTitleText(GET_STRING(600000662))

        self._buyType = BuyType.PAY
    elseif code == 40050 then --锁定中
        local data = {}
        data.txt = GET_STRING(600000804)--
        data.lockTime = msg
        data.callback = function()
        end
        data.btntext = {}
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, data)
    elseif code == 40002 then --不买自己的商品
        local data = {}
        data.txt = GET_STRING(600000404)--
        data.callback = function()
        end
        data.btntext = {}
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, data)
    elseif code == 30060 then --角色位满了
        local data = {}
        data.txt = GET_STRING(600000406)--
        data.callback = function(res)
            if res == 2 then --切换角色
                global.userInputController:RequestLeaveWorld()
            end
        end
        data.btntext = { GET_STRING(600000407), GET_STRING(600000408) }
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, data)
    else
        ShowSystemTips(msg)
    end
end

function TradingBankZFPanel:resCancelorder(code, data, msg)
    dump({ code, data, msg }, "resCancelorder___")
    if code == 200 then
    else
        ShowSystemTips(msg)
    end
    self:CloseLayer()
end

function TradingBankZFPanel:reqpayOrder()
    local val = {  
                    payinfo = { 
                        order_id = self._order_id, 
                        channel = self._payChannel, 
                        client_type = self.platform, 
                        price = self.m_orderData.totalAmount, 
                        commodityType = "role",
                        commodityID = self.m_goodsData.id,
                        commodityName = self.m_goodsData.role
                    }, 
                    callback = self.m_callback 
                }
    if self._payChannel == "ALIPAY" or self._payChannel == "HUABEI" then--支付宝H5
        val.type = 2
    elseif self._payChannel == "ALIPAY_EWM" then 
        val.type = 1
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPowerfulLayer_Open_other, val)
end

function TradingBankZFPanel:onButtonClick(sender, type)
    if type ~= 2 then
        return
    end
    local tag = sender:getTag()
    self:setSelPayType(tag)
end

function TradingBankZFPanel:CloseLayer()
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPanel_Close_other)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFLayer_Close_other)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFPanel_Close_other)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFLayer_Close_other)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPlayerLayer_Close_other)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPowerfulLayer_Close_other)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankLookOtherServerPlayerLayer_Close_other)
end
function TradingBankZFPanel:exitLayer()

    self.OtherTradingBankProxy:removeLayer(self)
end

-------------------------------------
return TradingBankZFPanel