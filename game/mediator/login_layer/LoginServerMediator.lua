local BaseUIMediator = requireMediator("BaseUIMediator")
local LoginServerMediator = class("LoginServerMediator", BaseUIMediator)
LoginServerMediator.NAME = "LoginServerMediator"

function LoginServerMediator:ctor()
    LoginServerMediator.super.ctor(self)

    self._sfxcache = {}
    self._fontcache = {}
end

function LoginServerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.Layer_Login_Server_Open,
        noticeTable.Layer_Login_Server_Close,
        noticeTable.RequestLoginServer,
        noticeTable.LoginServerSuccess,
        noticeTable.EnterLogin,
        noticeTable.LeaveRole,
        noticeTable.EndGameState,
        noticeTable.RequestLeaveWorld,
    }
end

function LoginServerMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Login_Server_Open == noticeID then
        self:OnOpen()
        
    elseif noticeTable.Layer_Login_Server_Close == noticeID then
        self:OnClose()

    elseif noticeTable.RequestLoginServer == noticeID then
        self:OnRequestLoginServer()

    elseif noticeTable.LoginServerSuccess == noticeID then
        self:OnLoginServerSuccess()

    elseif noticeTable.EnterLogin == noticeID then
        self:OnEnterLogin()

    elseif noticeTable.LeaveRole == noticeID then
        self:OnLeaveRole()
        
    elseif noticeTable.EndGameState == noticeID then
        self:OnEndGameState()
        
    elseif noticeTable.RequestLeaveWorld == noticeID then
        self:OnRequestLeaveWorld()
    end
end

function LoginServerMediator:OnOpen()
    if not self._layer then
        self._layer = requireLayerUI("login_layer/LoginServerLayer").create()
        self._type = global.UIZ.UI_NORMAL
        self._voice = false
        self._GUI_ID = SLDefine.LAYERID.LoginServerGUI

        LoginServerMediator.super.OpenLayer(self)

        -- for GUI
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()
    end
end

function LoginServerMediator:OnClose()
    LoginServerMediator.super.CloseLayer(self)
end

function LoginServerMediator:OnRequestLoginServer()
    local function callback()
        local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
        LoginProxy:RequestLoginServer()
    end
    PerformWithDelayGlobal(callback, 1/60)
end

function LoginServerMediator:OnLoginServerSuccess()
    global.Facade:sendNotification(global.NoticeTable.Layer_Login_Account_Close)
    if not self._layer then
        return nil
    end
    self._layer:OnLoginServerSuccess()
end

function LoginServerMediator:OnEnterLogin()
    if global.L_GameEnvManager:GetEnvDataByKey("isCloudLogin") then
    else
        local animID = {4121, 4127, 4123, 4129, 4125, 4131, 4122, 4128, 4124, 4130, 4126, 4132}
        for k, v in pairs(animID) do
            local anim = global.FrameAnimManager:CreateSFXAnim(v)
            anim:retain()
            self._sfxcache[v] = anim
        end
    end
end

function LoginServerMediator:OnLeaveRole()
    -- role anim cache
    for k, v in pairs(self._sfxcache) do
        v:autorelease()
    end
    self._sfxcache = {}

    -- open door cache
    local index = 0
    local path = string.format(global.MMO.PATH_RES_PRIVATE .. "login/open_door/%02d.png", index)
    while global.FileUtilCtl:isFileExist(path) do
        global.TextureCache:removeTextureForKey(path)

        index = index + 1
        path = string.format(global.MMO.PATH_RES_PRIVATE .. "login/open_door/%02d.png", index)
    end
end

function LoginServerMediator:OnEndGameState()
    for _, label in pairs(self._fontcache) do
        label:release()
    end
    self._fontcache = {}
end

function LoginServerMediator:OnRequestLeaveWorld()
    global.userInputController:RequestLeaveWorld()
end

function LoginServerMediator:onRegister()
    -----------------------------------------------------------------------------
    local function cacheFontAtlas( _fontSize, _outlineSize )
        local config =
        {
            fontFilePath         = global.MMO.PATH_FONT2,
            fontSize             = _fontSize,
            glyphs               = cc.GLYPHCOLLECTION_DYNAMIC,
            distanceFieldEnabled = false,
            outlineSize          = _outlineSize
        }

        local label = cc.Label:createWithTTF( config, "for cache")

        -- never release(warning, it will be repeated create)
        label:retain()
        table.insert(self._fontcache, label)
    end

    cacheFontAtlas( 16, 0 )

    cacheFontAtlas( 10, 1 )
    cacheFontAtlas( 14, 1 )
    cacheFontAtlas( 15, 1 )
    cacheFontAtlas( 16, 1 )
    cacheFontAtlas( 18, 1 )
    cacheFontAtlas( 20, 1 )
    cacheFontAtlas( 25, 1 )

    cacheFontAtlas( 18, 2 )

    cacheFontAtlas( 16, 3 )
    cacheFontAtlas( 18, 3 )
    cacheFontAtlas( 20, 3 )

    cacheFontAtlas( 18, 4 )


    if global.L_GameEnvManager:GetEnvDataByKey("isCloudLogin") then
    else
        --先加载一下bmpfont
        local fontZtPath = global.MMO.PATH_ST_FONT 
        cc.Label:createWithBMFont(fontZtPath,"")
    end
end

return LoginServerMediator
