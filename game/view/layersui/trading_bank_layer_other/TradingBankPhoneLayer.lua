local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankPhoneLayer = class("TradingBankPhoneLayer", BaseLayer)

local cjson = require("cjson")
local utf8 = require("util/utf8")
function TradingBankPhoneLayer:ctor()
    TradingBankPhoneLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankPhoneLayer.create(...)
    local ui = TradingBankPhoneLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankPhoneLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/bindIdentity/trading_bank_phone")
    self._root = ui_delegate(self)
    self:InitAdapt()

    self.m_callback = data and data.callback
    self.m_checkPhone = data and data.checkPhone--检测手机号模式
    self.m_openLock = data and data.openLock--开启寄售锁
    
    self:InitUI()
    return true
end

function TradingBankPhoneLayer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_cancel, winSizeW, winSizeH)
    GUI:setPosition(self._root.PMainUI, winSizeW / 2, winSizeH / 2)
    GUI:setContentSize(self._root.Panel_Photo, winSizeW, winSizeH)
end

function TradingBankPhoneLayer:InitUI()
    -- GUI:setVisible(self._root.Panel_Photo, false)
    -------------绑定手机---------------
    --输入框
    self.OtherTradingBankProxy:cancelEmpty(self._root.TextField_phone)
    self.OtherTradingBankProxy:cancelEmpty(self._root.TextField_Verification_Code)
    GUI:TextInput_setInputMode(self._root.TextField_phone, 2)
    GUI:TextInput_setInputMode(self._root.TextField_Verification_Code, 2)
    if self.OtherTradingBankProxy:getMobile() and  self.m_openLock then
        self._root.TextField_phone:setString(self.OtherTradingBankProxy:getMobile())
        self._root.TextField_phone:setTouchEnabled(false)
        self._root.TextField_phone._isBind = true
    end
    --协议
    local PrivacyPolicyStr
    if self.m_checkPhone or self.m_openLock then
        self._root.Panel_agreement:setVisible(false)
    else--首次绑定手机
        local RichTextHelp = requireUtil("RichTextHelp")
        local pstr = self.OtherTradingBankProxy.PrivacyPolicyList
        PrivacyPolicyStr = string.format(GET_STRING(600000466), pstr[1], pstr[2], pstr[3], pstr[4], pstr[5])

        local PrivacyPolicy = RichTextHelp:CreateRichTextWithXML(PrivacyPolicyStr, 600, 16)
        self._root.Panel_agreement:addChild(PrivacyPolicy)
        PrivacyPolicy:setAnchorPoint(0, 1)
        PrivacyPolicy:setPosition(26, 48)
        PrivacyPolicy:setOpenUrlHandler(function(sender, url)
            cc.Application:getInstance():openURL(url)
        end)
        self._root.CheckBox:setSelected(self:getAgreement())
        self._root.Panel_agreement:addClickEventListener(function(sender, type)--协议
            self._root.CheckBox:setSelected(not self._root.CheckBox:isSelected())
            self:saveAgreement()
        end)
    end

    --验证码
    self._root.Button_Verification_Code:addClickEventListener(function()
        self._getVerificationCode = true
        local phone = self._root.TextField_phone:getString()
        if self._root.TextField_phone._isBind then 
            self:ReqGetCode({ phone = "AUTO_FILL", type = self.m_openLock and 2 or 1 }, function()
                self:YZMButton_Ref(self._root.Button_Verification_Code)
            end)
        else
            if self:isGoodNumber(phone) and string.len(phone) == 11 then --
                --type 1 phoneLogin 2 verifyCode 
                self:ReqGetCode({ phone = phone, type = self.m_openLock and 2 or 1 }, function()
                    self:YZMButton_Ref(self._root.Button_Verification_Code)
                end)
            else
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000104))
                return
            end
        end
        
    end)
    --绑定手机 下一步
    self._root.Button_next1:addClickEventListener(function()
        if not (self.m_checkPhone or self.m_openLock) then
            if not self:getAgreement() then --未同意协议
                ShowSystemTips(GET_STRING(600000652))
                -- global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code)
                --     if code == 1 then--不同意
                --     elseif code == 2 then --同意
                --         self._root.CheckBox:setSelected(true)
                --         self:saveAgreement()
                --     end
                -- end, title = GET_STRING(600000467), notcancel = true, canmove = true, txt = PrivacyPolicyStr, btntext = { GET_STRING(600000469), GET_STRING(600000468) } })
                return
            end
        end
        if not self._getVerificationCode then --先获取验证码
            ShowSystemTips(GET_STRING(600000465))
            return
        end
        local phone = self._root.TextField_phone:getString()
        local code = self._root.TextField_Verification_Code:getString()
        if not self:isGoodNumber(code) then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000106))
            return
        end
        if self._root.TextField_phone._isBind then 
            local success = function()            
                if self.m_callback then
                    self.m_callback(1)
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Close_other)
            end
            self:reqYZPhone("AUTO_FILL", code, success)
        else
            if self:isGoodNumber(phone) and string.len(phone) == 11 then --未验证的要先验证
                local success = function()            
                    if self.m_callback then
                        self.m_callback(1)
                    end
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Close_other)
                end
                self:reqYZPhone(phone, code, success)
            else
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000104))
                return
            end
        end
    end)
    ------------------------------------------
    ------------------------------------------
    --关闭
    self._root.CloseButton:addClickEventListener(function()
        if self.m_callback then
            self.m_callback(0)
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Close_other)
    end)

    --------------------------------------------
    if self.m_checkPhone or self.m_openLock then --检测手机模式
        self._root.Text_phone_tips:setString(GET_STRING(600000410))
        self._root.Text_phone:setString(GET_STRING(600000411))
    end
end

--验证手机
function TradingBankPhoneLayer:reqYZPhone(phone, yzm, func)
    if self.m_openLock then
        self.OtherTradingBankProxy:openLock(self, phone, yzm, function(code, data, msg)
            if code ~= 200 then
                ShowSystemTips(msg)
            else
                if func then
                    func()
                end
            end
        end)
    elseif self.m_checkPhone then 
        self.OtherTradingBankProxy:reqYZPhone(self, phone, yzm, function(code, data, msg)
            if code ~= 200 then
                ShowSystemTips(msg)
            else
                self.OtherTradingBankProxy:setMobile(data.mobile)
                self.OtherTradingBankProxy:setToken(data.token)
                if func then
                    func()
                end
            end
        end)
    else
        local params = {
            code = yzm,
            phone = phone
        }
        self.OtherTradingBankProxy:bindPhone(self, params, function(code, data, msg)
            dump({code, data, msg},"bindPhone____")
            -- self.OtherTradingBankProxy:doTrack(self.OtherTradingBankProxy.UpLoadData.TraingRegister)
            if code ~= 200 then
                ShowSystemTips(msg)
            else
                -- self.OtherTradingBankProxy:setMobile(data.mobile)
                -- self.OtherTradingBankProxy:setToken(data.token)
                self.OtherTradingBankProxy:LoginOut()
                self.OtherTradingBankProxy:Login1_2(function(code,msg)
                    if code ~= 200 then 
                        ShowSystemTips(msg)
                    else
                        if func then
                            func()
                        end
                    end
                end)
            end
        end)
    end
end
--验证码倒计时
function TradingBankPhoneLayer:YZMButton_Ref(sender)
    local t = 180--有效时间3分钟
    sender:stopAllActions()
    sender:setTouchEnabled(false)
    sender:setTitleText(t.."S")
    t = t - 1
    schedule(sender, function()
        sender:setTitleText(t.."S")
        t = t - 1
        if t == 0 then
            sender:stopAllActions()
            sender:setTouchEnabled(true)
            sender:setTitleText(GET_STRING(600000103))
        end
    end, 1)
end
--验证码
function TradingBankPhoneLayer:ReqGetCode(val, func)
    if self.m_openLock then --寄售锁
        self.OtherTradingBankProxy:reqGetCode(self, val, function(code, data, msg)
            if code ~= 200 then
                ShowSystemTips(msg)
            else
                ShowSystemTips(GET_STRING(600000102))
                if func then
                    func()
                end
            end
        end)
    else
        self.OtherTradingBankProxy:reqLoginGetCode(self, val, function(code, data, msg)
            if code ~= 200 then
                ShowSystemTips(msg)
            else
                ShowSystemTips(GET_STRING(600000102))
                if func then
                    func()
                end
            end
        end)
    end
end
----协议
function TradingBankPhoneLayer:saveAgreement()
    local LoginProxy    = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local mainPlayerID = LoginProxy:GetSelectedRoleID()
    local path    = "TradingBank" .. mainPlayerID
    local key    = "PrivacyPolicyAgreement"
    local userData = UserData:new(path)

    local writeData = { agree = self._root.CheckBox:isSelected() and 1 or 0 }
    local jsonStr = cjson.encode(writeData)
    userData:setStringForKey(key, jsonStr)
end

function TradingBankPhoneLayer:getAgreement()
    local LoginProxy    = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local mainPlayerID = LoginProxy:GetSelectedRoleID()
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
---
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
    self.OtherTradingBankProxy:removeLayer(self)
end
-------------------------------------
return TradingBankPhoneLayer