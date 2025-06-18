local gameStateRole = class('gameStateRole')

function gameStateRole:ctor()
end


function gameStateRole:getStateType()
    return global.MMO.GAME_STATE_ROLE
end

function gameStateRole:onEnter()
    local function updater( delta )
        global.gameEnvironment:GetNetClient():Tick()
        global.FrameAnimManager:Tick( delta )
        global.ResDownloader:Tick( delta )
    end
    self._scheduleId = Schedule( updater, 0.05 )

    -- loading mediator
    local LoadingMediator = requireMediator( "loading_layer/LoadingMediator" )
    local loadingMediator = LoadingMediator.new()
    global.Facade:registerMediator( loadingMediator )

    global.Facade:sendNotification(global.NoticeTable.Layer_Notice_Open)
    global.Facade:sendNotification(global.NoticeTable.Layer_Login_Version_Open)
    global.Facade:sendNotification(global.NoticeTable.Layer_Login_Role_Open)

    global.userInputController:InitOnEnterRole()

    return 1
end

function gameStateRole:onEnd()--重启
    global.Facade:sendNotification( global.NoticeTable.ReleaseMemory)
end
function gameStateRole:onExit()
    if self._scheduleId ~= -1 then
        UnSchedule(self._scheduleId)
        self._scheduleId = -1
    end

    global.Facade:sendNotification(global.NoticeTable.Layer_Notice_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_Login_Version_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_Login_Role_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Close)

    -- release texture cache
    global.TextureCache:removeUnusedTextures()

    global.FrameAnimManager:unloadUnusedAnimData()

    return 1
end

return gameStateRole
