local RestartGameCommand = class('RestartGameCommand', framework.SimpleCommand)

function RestartGameCommand:ctor()
end

function RestartGameCommand:execute(note)
    --debug
    release_print( "RestartGameCommand" )
    
    --clean lua callfunc
    if global.sceneManager then
        global.sceneManager:Cleanup()
    end
    --语音通知退出
    local VoiceManagerProxy = global.Facade:retrieveProxy( global.ProxyTable.VoiceManagerProxy )
    if VoiceManagerProxy then
        VoiceManagerProxy:VoiceExit()
    end

    -- 数据上报 游戏时长
    local DataRePortProxy = global.Facade:retrieveProxy( global.ProxyTable.DataRePortProxy )
    DataRePortProxy:PlayGame()

    -- clear msg handler
    global.LuaBridgeCtl:SetModulesSwitch( global.MMO.Modules_Index_Enable_Disconnect_Msg, 0 )
    LuaNetworkController:Inst():UnregisterAllLuaHandler()
    local aNetclient = gameEnviroment:Inst():GetNetClient()
    if aNetclient then
        aNetclient:Disconnect()
        aNetclient:CleanAllMessageHandler()
    end

    -- clean
    global.ResDownloader:Cleanup()

    -- release sui caches
    global.SWidgetCache:releaseAll()

    -- auth cache
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    AuthProxy:SaveLocalCache()
    AuthProxy:releaseDownloader()
    
    local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    OtherTradingBankProxy:setGameToken("")--清理token
    OtherTradingBankProxy:LoginOut()--登出交易行
    if global.OtherTradingBankH5 then --隐藏取回
        local loginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
        local roleData = loginProxy:GetRoles()
        local lock = false
        for i, v in ipairs(roleData) do
            if v.LockChar and (v.LockChar == 1 or v.LockChar == 3)  then 
                lock = true 
                break
            end
        end
        if lock then 
            OtherTradingBankProxy:dismissBackToView()
        end
    end
    global.Facade:sendNotification( global.NoticeTable.EndGameState )

    -- cleanup anim mgr
    global.FrameAnimManager:Cleanup()

    -- cleanup user data
    UserData:Cleanup()
    UserData:setVersionPath("")


    local director = cc.Director:getInstance()
    local texCache = director:getTextureCache()
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    
    spriteFrameCache:removeSpriteFrames()
    texCache:removeAllTextures()

    -- clearAsyncCallback
    texCache:unbindAllImageAsync()

    -- clear cocos2d cache, issue: release res maybe crash.
    director:purgeCachedData()
    -- clear cocos2d event
    director:getEventDispatcher():removeAllEventListeners()
    -- clear cocos2d scheduler, but system scheduler( ActionManager )
    director:getScheduler():unscheduleAllWithMinPriority( cc.PRIORITY_NON_SYSTEM_MIN )
    -- clear cocos2d action
    director:getActionManager():removeAllActions()
    -- stop spriteframe async load task
    cc.AsyncTaskPool:getInstance():stopTasks(cc.AsyncTaskPool.TaskType.TASK_IO)
    cc.AsyncTaskPool:getInstance():stopTasks(cc.AsyncTaskPool.TaskType.TASK_NETWORK)
    -- clear cocos2d audio
    cc.SimpleAudioEngine:destroyInstance()
    ccexp.AudioEngine:uncacheAll()
    -- ccexp.AudioEngine:endToLua()

    -- reset downloader
    global.HttpDownloader:reset()

    -- ssr bridge
    ssr.ssrBridge:onRestartGame()


    -- record log
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_WINDOWS then
        -- nothing todo

    elseif platform == cc.PLATFORM_OS_ANDROID then
        if nil ~= note:getBody() then
        local cjson = require("cjson")
        local jData = {}
        jData.restartMode = note:getBody()
        global.L_NativeBridgeManager:GN_restartGame(jData)
        else 
        buglyLog( 0, "restart game", "Restart Lua VM!" )         
        end
    end

    releasePrint( "RestartGameCommand completed" )
    releasePrint( "Restart Lua VM!" )    
    -- restart luaVM
    LuaBridgeCtl:Inst():CreateNewState()

    -- end check game server heart beat
    global.LuaBridgeCtl:SetModulesSwitch( global.MMO.Modules_Index_Enable_Check_Heart_Beat, 0 )
end

return RestartGameCommand
