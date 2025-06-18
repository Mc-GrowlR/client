local BaseUIMediator = requireMediator("BaseUIMediator")
local LoginAccountMediator = class('LoginAccountMediator', BaseUIMediator)
LoginAccountMediator.NAME = "LoginAccountMediator"

function LoginAccountMediator:ctor()
    LoginAccountMediator.super.ctor(self)

    self._cache = {}
end

function LoginAccountMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
    {
        noticeTable.Layer_Login_Account_Open,
        noticeTable.Layer_Login_Account_Close,
        noticeTable.AuthRegisterSuccess,
        noticeTable.AuthLoginSuccess,
        noticeTable.AuthCheckTokenSuccess,
        noticeTable.AuthCheckTokenFailure,
        noticeTable.AuthChangePwdResp,
        noticeTable.AuthChangePwdByPhoneResp,
        noticeTable.AuthChangeMbResp,
        noticeTable.AuthBindPhoneResp,
        noticeTable.EnterLogin,
        noticeTable.Layer_IdentifyID_Open,
    }
end

function LoginAccountMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_Login_Account_Open == noticeID then
        self:OpenLayer()

    elseif noticeTable.Layer_Login_Account_Close == noticeID then
        self:CloseLayer()

    elseif noticeTable.AuthRegisterSuccess == noticeID then
        self:OnAuthRegisterSuccess(data)

    elseif noticeTable.AuthLoginSuccess == noticeID then
        self:OnAuthLoginSuccess(data)
        
    elseif noticeTable.AuthCheckTokenSuccess == noticeID then
        self:OnAuthCheckTokenSuccess(data)
        
    elseif noticeTable.AuthCheckTokenFailure == noticeID then
        self:OnAuthCheckTokenFailure(data)

    elseif noticeTable.AuthChangePwdResp == noticeID then
        self:OnAuthChangePwdResp(data)

    elseif noticeTable.AuthChangePwdByPhoneResp == noticeID then
        self:OnAuthChangePwdByPhoneResp(data)

    elseif noticeTable.AuthChangeMbResp == noticeID then
        self:OnAuthChangeMbResp(data)

    elseif noticeTable.AuthBindPhoneResp == noticeID then
        self:OnAuthBindPhoneResp(data)

    elseif noticeTable.EnterLogin == noticeID then
        self:OnEnterLogin(data)

    elseif noticeTable.Layer_IdentifyID_Open == noticeID then
        self:OnOpenIdentifyLayer(data)

    end
end

function LoginAccountMediator:OpenLayer()
    if not self._layer then
        self._layer = requireLayerUI("login_layer/LoginAccountLayer").create()
        self._type = global.UIZ.UI_NORMAL
        self._voice = false
        self._GUI_ID = SLDefine.LAYERID.LoginAccountGUI
        
        LoginAccountMediator.super.OpenLayer(self)

        -- for GUI
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()
    end

    -- play bgm
    global.Facade:sendNotification(global.NoticeTable.Audio_Play_BGM, {type = global.MMO.SND_TYPE_BGM_LOGIN})
end

function LoginAccountMediator:CloseLayer()
    LoginAccountMediator.super.CloseLayer(self)
end

function LoginAccountMediator:handlePressedEnter()
    if self._layer then
        self._layer:handlePressedEnter()
    end
    return true
end

function LoginAccountMediator:OnAuthRegisterSuccess(data)
    if not self._layer then
        return nil
    end
    self._layer:OnAuthRegisterSuccess()
end

function LoginAccountMediator:OnAuthLoginSuccess(data)
    if GET_GAME_STATE() ~= global.MMO.GAME_STATE_LOGIN then
        return 
    end

    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    AuthProxy:SaveLocalData()

    -- 进入服务器界面
    global.Facade:sendNotification(global.NoticeTable.Layer_Login_Server_Open)
    global.Facade:sendNotification(global.NoticeTable.RequestLoginServer)
    if global.OtherTradingBank then 
        local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
        OtherTradingBankProxy:setLoginSuccessTimes()
    else
        if global.L_GameEnvManager:GetEnvDataByKey("isBoxLogin") ~= 1 then 
            local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
            TradingBankProxy:clearToken()
        end
    end
end



function LoginAccountMediator:OnAuthCheckTokenSuccess(data)
    if GET_GAME_STATE() ~= global.MMO.GAME_STATE_LOGIN then
        return 
    end
    
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    AuthProxy:SaveLocalData()

    -- 进入服务器界面
    global.Facade:sendNotification(global.NoticeTable.Layer_Login_Server_Open)
    global.Facade:sendNotification(global.NoticeTable.RequestLoginServer)
end

function LoginAccountMediator:OnAuthCheckTokenFailure(data)
    global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg)
end

function LoginAccountMediator:OnAuthChangePwdResp(data)
    if GET_GAME_STATE() ~= global.MMO.GAME_STATE_LOGIN then
        return 
    end
    if not self._layer then
        return
    end
    self._layer:OnAuthChangePwdResp()
end

function LoginAccountMediator:OnAuthChangePwdByPhoneResp(data)
    if GET_GAME_STATE() ~= global.MMO.GAME_STATE_LOGIN then
        return 
    end
    if not self._layer then
        return
    end
    self._layer:OnAuthChangePwdByPhoneResp()
end

function LoginAccountMediator:OnAuthChangeMbResp(data)
    if GET_GAME_STATE() ~= global.MMO.GAME_STATE_LOGIN then
        return 
    end
    if not self._layer then
        return
    end
    self._layer:OnAuthChangeMbResp()
end

function LoginAccountMediator:OnAuthBindPhoneResp(data)
    if GET_GAME_STATE() ~= global.MMO.GAME_STATE_LOGIN then
        return 
    end
    if not self._layer then
        return
    end
    self._layer:OnAuthBindPhoneResp()
end



function LoginAccountMediator:OnEnterLogin(data)
    if not self._layer then
        return
    end
    self._layer:OnEnterLogin(data)
end

function LoginAccountMediator:OnOpenIdentifyLayer(data)
    if not self._layer then
        return
    end
    self._layer:ShowIdentifyID(data)
end

function LoginAccountMediator:onRegister()
    LoginAccountMediator.super.onRegister()

    local function onNativeStatusChangedCB(sender, jsonString)
        -- debug
        releasePrint("NativeStatusChanged 22222222:" .. tostring(jsonString))

        local cjson = require("cjson")
        local paramJson = cjson.decode(jsonString)

        local networkDesc = {[-1] = "unknown", [0] = "wifi", [1] = "2g", [2] = "3g", [3] = "4g"}
        releasePrint("NativeStatusChanged, network:" .. networkDesc[paramJson.network] .. ",battery:" .. paramJson.battery)

        local env = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
        env:SetNetType(paramJson.network)
        env:SetBatteryLevel(paramJson.battery)
    end

    -- register native status changing callback
    global.NativeBridgeCtl:removeSelectorsInGroup("NativeStatus")
    global.NativeBridgeCtl:addNativeSelector("NativeStatus", "NG_NativeStatusChanged", onNativeStatusChangedCB, nil)

    -- logout 
    local function onLogoutCB(sender, jsonString)
        -- debug
        releasePrint("LogoutCallback mod_fgcq :" .. tostring(jsonString))

        global.Facade:sendNotification(global.NoticeTable.RestartGame)
    end
    -- register logout status changing callback
    global.NativeBridgeCtl:removeSelectorsInGroup("AccountOperator")
    global.NativeBridgeCtl:addNativeSelector("AccountOperator", "NG_Logout", onLogoutCB, nil)
end

return LoginAccountMediator
