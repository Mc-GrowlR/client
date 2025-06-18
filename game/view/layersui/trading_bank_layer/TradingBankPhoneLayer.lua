local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankPhoneLayer = class("TradingBankPhoneLayer", BaseLayer)

local cjson = require("cjson")

function TradingBankPhoneLayer:ctor()
    TradingBankPhoneLayer.super.ctor(self)
    self.TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
end

function TradingBankPhoneLayer.create(...)
    local ui = TradingBankPhoneLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankPhoneLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_phone")
    self._root = ui_delegate(self)
    self:InitAdapt()
    
    self.m_callback = data and data.callback
    self.TradingBankProxy:reqUserData(self, function(data)
        self:InitUI(data)
    end)
    return true
end

function TradingBankPhoneLayer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_cancel, winSizeW, winSizeH)
    GUI:setPosition(self._root.Image_1, winSizeW / 2, winSizeH / 2)
end

function TradingBankPhoneLayer:InitUI()
    --输入框
    for i = 5, 6 do

        self._root["TextField_" .. i] = (self._root["TextField_" .. i])
        self.TradingBankProxy:cancelEmpty(self._root["TextField_" .. i])
    end
    for i = 2, 3 do
        self._root["Button_" .. i]:addTouchEventListener(handler(self, self.onButtonClick))
    end
    -- if data.noclose then
    -- self._root.ButtonClose:setVisible(false)
    -- end
    self._root.ButtonClose:addTouchEventListener(handler(self, self.onButtonClick))
    if self.TradingBankProxy:isBindPhone(self) then
        self._root.Text_bindtip:setVisible(false)
        local phoneStr = self.TradingBankProxy:getPhone(self)
        phoneStr = phoneStr:sub(1,3).."****"..phoneStr:sub(-4,-1)
        self._root.TextField_5:setString(phoneStr)
        self._root.TextField_5:setTouchEnabled(false)
    else
        self._root.Text_bindtip:setVisible(true)
    end
end

function TradingBankPhoneLayer:onButtonClick(sender, type)
    if type ~= 2 then
        return
    end
    local name = sender:getName()
    if name == "Button_2" then
        if self.TradingBankProxy:isBindPhone(self) then --验证码
            self:ReqGetCode(function()
                self:YZMButton_Ref(sender)
            end)
        else--绑定手机
            local phone = self._root.TextField_5:getString()
            if self:isGoodNumber(phone) and string.len(phone) == 11 then
                self:ReqBindPhone(phone, function()
                    self:YZMButton_Ref(sender)
                end)
            else
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000104))
                return
            end
        end
    elseif name == "Button_3" then
        local phone = self._root.TextField_5:getString()
        local code = self._root.TextField_6:getString()
        if not self:isGoodNumber(code) then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000106))
            return
        end
        if self.TradingBankProxy:isBindPhone(self) then --验证码
            self:ReqYZPhone(nil,code, function()
                if self.m_callback then
                    self.m_callback(1)
                end
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000107))
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Close)

            end)
        else
            if self:isGoodNumber(phone) and string.len(phone) == 11 then --未验证的要先验证
                self:ReqYZPhone(phone, code, function()
                    if self.m_callback then
                        self.m_callback(1)
                    end
                    global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000107))
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Close)

                end)
            else
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000104))
                return
            end
        end
    elseif name == "ButtonClose" then
        if self.m_callback then
            self.m_callback(0)
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Close)

    end
    -- body
end
--验证手机
function TradingBankPhoneLayer:ReqYZPhone(phone, yzm, func)
    self.TradingBankProxy:reqYZPhone(self, phone, yzm, function(success, response, code)
        if success then
            local resData = cjson.decode(response)
            if resData.code ~= 200 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, resData.msg or "")
            else
                if func then
                    func()
                end
            end

        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000108))
        end
    end)
end
--验证码倒计时
function TradingBankPhoneLayer:YZMButton_Ref(sender)
    local t = 60
    sender:stopAllActions()
    sender:setTouchEnabled(false)
    sender:setTitleText(t)
    t = t - 1
    schedule(sender, function()
        sender:setTitleText(t)
        t = t - 1
        if t == 0 then
            sender:stopAllActions()
            sender:setTouchEnabled(true)
            sender:setTitleText(GET_STRING(600000103))
        end
    end, 1)
end
--验证码
function TradingBankPhoneLayer:ReqGetCode(func)
    self.TradingBankProxy:reqGetCode(self, function(success, response, code)
        if success then
            local resData = cjson.decode(response)
            if resData.code ~= 200 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, resData.msg or "")
            else
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000102))
                if func then
                    local TradingBankPhoneLayerMediator = global.Facade:retrieveMediator("TradingBankPhoneLayerMediator")
                    if not TradingBankPhoneLayerMediator._layer then
                        return
                    end
                    func()
                end
            end
        end
    end)
end
--绑定手机
function TradingBankPhoneLayer:ReqBindPhone(phone, func)
    self.TradingBankProxy:reqBindPhone(self, phone, function(success, response, code)
        if success then
            local resData = cjson.decode(response)
            if resData.code ~= 200 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, resData.msg or "")
            else
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000102))
                if func then
                    local TradingBankPhoneLayerMediator = global.Facade:retrieveMediator("TradingBankPhoneLayerMediator")
                    if not TradingBankPhoneLayerMediator._layer then
                        return
                    end
                    func()
                end
            end
        end
    end)
end
function TradingBankPhoneLayer:isGoodNumber(str)
    if not (string.len(str) > 0) then
        return false
    end
    if not self:IsNumber(str) then
        return false
    end
    return true
end
--是否纯数字
function TradingBankPhoneLayer:IsNumber(str)
    if string.find(str, "[^%d]") then
        return false
    end
    return true
end
function TradingBankPhoneLayer:exitLayer()
    self.TradingBankProxy:removeLayer(self)
end
-------------------------------------
return TradingBankPhoneLayer