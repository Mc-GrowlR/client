local BaseUIMediator = requireMediator("BaseUIMediator")
local LoginRoleMediator = class('LoginRoleMediator', BaseUIMediator)
LoginRoleMediator.NAME = "LoginRoleMediator"

function LoginRoleMediator:ctor()
    LoginRoleMediator.super.ctor(self)
end

function LoginRoleMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
    {
        noticeTable.Layer_Login_Role_Open,
        noticeTable.Layer_Login_Role_Close,
        noticeTable.Layer_Login_Role_Update,
        noticeTable.Layer_Login_Role_RandNameResp,
        noticeTable.LoginServerSuccess,
        noticeTable.Layer_Login_Role_RestoreSuccess,
        noticeTable.Layer_Login_Role_EnterGame_Delay,
        noticeTable.Refresh_RestoreRole_UI
    }
end

function LoginRoleMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_Login_Role_Open == noticeID then
        self:Open(data)

    elseif noticeTable.Layer_Login_Role_Close == noticeID then
        self:Close()

    elseif noticeTable.Layer_Login_Role_Update == noticeID then
        self:OnUpdateRoles()
    
    elseif noticeTable.Layer_Login_Role_RandNameResp == noticeID then
        self:OnRandNameResp(data)

    elseif noticeTable.LoginServerSuccess == noticeID then
        self:OnLoginServerSuccess()

    elseif noticeTable.Layer_Login_Role_RestoreSuccess == noticeID then
        self:onRestoreRoleSuccess()

    elseif noticeTable.Layer_Login_Role_EnterGame_Delay == noticeID then
        self:onRoleEnterGameDelay()
    
    elseif noticeTable.Refresh_RestoreRole_UI == noticeID then
        self:onRefreshRestoreRoleUI()
    end
end

function LoginRoleMediator:Open(data)
    if not self._layer then
        self._layer = requireLayerUI("login_layer/LoginRoleLayer").create(data)
        self._type = global.UIZ.UI_NORMAL
        self._voice = false
        self._GUI_ID = SLDefine.LAYERID.LoginRoleGUI
        
        LoginRoleMediator.super.OpenLayer(self)
        self._layer:InitGUI(data)

        global.Facade:sendNotification(global.NoticeTable.Audio_Stop_All)
        global.Facade:sendNotification(global.NoticeTable.Audio_Play_BGM, {type = global.MMO.SND_TYPE_BGM_SELECT})
    end
end

function LoginRoleMediator:Close()
    if self._layer then
        local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
        TradingBankProxy:removeLayer(self._layer)
        local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
        OtherTradingBankProxy:removeLayer(self._layer)
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_Login_RoleLock_Close)
    LoginRoleMediator.super.CloseLayer(self)
end

function LoginRoleMediator:handlePressedEnter()
    if self._layer then
        self._layer:handlePressedEnter()
    end
    return true
end

function LoginRoleMediator:OnUpdateRoles()
    if self._layer then
        self._layer:OnUpdateRoles()
    end
end

function LoginRoleMediator:OnRandNameResp(data)
    if self._layer then
        self._layer:OnRandNameResp(data)
    end
end

function LoginRoleMediator:OnLoginServerSuccess(data)
    if self._layer then
        self._layer:OnLoginServerSuccess(data)
    end
end

function LoginRoleMediator:onRestoreRoleSuccess()
    if self._layer then
        if LoginRolePanel.HideRestoreList then
            LoginRolePanel.HideRestoreList()
        end
    end
end

function LoginRoleMediator:onRoleEnterGameDelay()
    if self._layer then
        self._layer:onRoleEnterGameDelay()
    end
end

function LoginRoleMediator:onRefreshRestoreRoleUI()
    if self._layer then
        self._layer:onRefreshRestoreRoleUI()
    end
end

return LoginRoleMediator