local BaseLayer = requireLayerUI("BaseLayer")
local LoginServerLayer = class("LoginServerLayer", BaseLayer)


function LoginServerLayer:ctor()
    LoginServerLayer.super.ctor(self)
end

function LoginServerLayer.create()
    local node = LoginServerLayer.new()
    if node:Init() then
        return node
    end
    return nil
end

function LoginServerLayer:Init()
    self._ui = ui_delegate(self)

    return true
end

function LoginServerLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_LOGIN_SERVER)
    LoginServer.main()

    local visibleSize   = global.Director:getVisibleSize()
    local path          = string.format(global.MMO.PATH_RES_PRIVATE .. "login/open_door/%02d.png", 0)
    self._imageLBG      = self._ui.Image_login_bg
    self._imageLBG:loadTexture(path)
    self._imageLBG:setContentSize(visibleSize)
    self._imageLBG:setPosition(visibleSize.width / 2, visibleSize.height / 2)
end

function LoginServerLayer:OnLoginServerSuccess()
    global.Facade:sendNotification( global.NoticeTable.Audio_Stop_BGM )
    global.Facade:sendNotification( global.NoticeTable.Audio_Play, {type=global.MMO.SND_TYPE_LOGIN_DOOR} )

    -- 开门动画
    self._imageLBG:stopAllActions()
    local index = 1
    local textureFile = nil
    local function callback()
        if textureFile then
            global.TextureCache:removeTextureForKey( textureFile )
        end
        textureFile = string.format(global.MMO.PATH_RES_PRIVATE .. "login/open_door/%02d.png", index)

        if global.FileUtilCtl:isFileExist(textureFile) then
            self._imageLBG:loadTexture(textureFile)
        else
            self._imageLBG:stopAllActions()

            global.Facade:sendNotification(global.NoticeTable.ChangeGameState, global.MMO.GAME_STATE_ROLE)
        end

        index = index + 1
    end
    schedule(self._imageLBG, callback, 0.1)
end

return LoginServerLayer
