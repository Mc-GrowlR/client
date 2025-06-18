local gameStateWorld = class('gameStateWorld')

function gameStateWorld:ctor()
end


function gameStateWorld:getStateType()
    return global.MMO.GAME_STATE_WORLD
end

--- enter
function gameStateWorld:onEnter()
    self:RegisterWorld()
    self:SyncCppState()
    self:InitWorld()
    self:EnterWorld()

    return 1
end

function gameStateWorld:RegisterWorld()
    local facade = global.Facade

    -- command
    facade:removeCommand( global.NoticeTable.RegisterWorldController )
    facade:removeCommand( global.NoticeTable.RegisterWorldMediator )
    facade:removeCommand( global.NoticeTable.RegisterWorldProxy )

    -- loading mediator
    local LoadingMediator = requireMediator( "loading_layer/LoadingMediator" )
    facade:removeMediator(LoadingMediator.NAME)
end

function gameStateWorld:SyncCppState()
    local facade     = global.Facade

    local cppEnv     = global.gameEnvironment
    local AuthProxy  = facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local LoginProxy = facade:retrieveProxy(global.ProxyTable.Login)

    cppEnv:SetLoginAccount( AuthProxy:GetUID() )
    cppEnv:SetLoginServer( LoginProxy:GetSelectedServerId() )
end

function gameStateWorld:InitWorld()
    local facade = global.Facade

    -- laoding close
    facade:sendNotification(global.NoticeTable.Layer_LoadingBar_Close)

    -- init resolution size & policy
    local normalPolicy = global.DesignPolicy
    local designSize   = global.DesignSize_Oth
    local glview       = global.Director:getOpenGLView()
    if global.isWinPlayMode and glview then
        -- keep camera zoom(FrameSize == ViewPortSize)
        designSize = glview:getFrameSize()
    end
    local resolutionData     = {}
    resolutionData.rType     = normalPolicy
    resolutionData.size      = designSize
    facade:sendNotification(global.NoticeTable.ChangeResolution, resolutionData)

    -- init layer facade
    local LayerFacadeMediator = requireMediator( "LayerFacadeMediator" )
    local layerFacade = facade:retrieveMediator( LayerFacadeMediator.NAME )
    layerFacade:InitOnEnterWorld()

    global.JsonProtoHelper:init()
    global.BehaviorController:InitOnEnterWorld()
    global.userInputController:InitOnEnterWorld()
    global.actorManager:InitOnEnterWorld()
end

function gameStateWorld:EnterWorld()
    local facade = global.Facade

    -- notify server
    local loginProxy = facade:retrieveProxy( global.ProxyTable.Login )
    loginProxy:EnterWorld()

    -- register msg handler
    local noticeProxy = facade:retrieveProxy( global.ProxyTable.NoticeProxy )
    noticeProxy:RegisterMsgHandlerAfterEnterWorld()

    -- register msg handler
    global.SUIManager:RegisterMsgHandlerAfterEnterWorld()

    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    ChatProxy:RegisterMsgHandlerAfterEnterWorld()
end
function gameStateWorld:onEnd()--重启
    self:onExit()
end

--- exit world
function gameStateWorld:onExit()
    self:CleanWorld()
    global.Facade:sendNotification( global.NoticeTable.ReleaseMemory)--清理完再释放
    self:LeaveWorld()
    self:Destory()

    return 1
end

function gameStateWorld:LeaveWorld()
    local facade = global.Facade

    global.userInputController:ResetKeyboard()
    global.userInputController:ResetTouch()
    
    facade:sendNotification(global.NoticeTable.Layer_Notice_Close, SLBridge:CheckLuaEventCleaned())
    facade:sendNotification(global.NoticeTable.Layer_CommonTips_Close)

    -- 
    global.LuaBridgeCtl:SetModulesSwitch( global.MMO.Modules_Index_Enable_Check_Heart_Beat, 0 )

    -- unregister world
    facade:sendNotification( global.NoticeTable.UnRegisterOther )
    facade:sendNotification( global.NoticeTable.UnRegisterWorldProxy )
    facade:sendNotification( global.NoticeTable.UnRegisterWorldMediator )
    facade:sendNotification( global.NoticeTable.UnRegisterWorldController )
    
    --清理收货和试玩状态
    global.IsReceiveRole = false
    global.IsVisitor = false
    -- clear cocos2d event
    -- clear cocos2d scheduler, but system scheduler( ActionManager )
    -- clear cocos2d action
    -- clear cocos2d audio
    local director = cc.Director:getInstance()
    local currScene = global.Director:getRunningScene()
    director:getEventDispatcher():removeEventListenersForType(1)
    director:getEventDispatcher():removeEventListenersForType(2)
    director:getEventDispatcher():removeEventListenersForType(3)
    director:getEventDispatcher():removeEventListenersForType(4)
    director:getEventDispatcher():removeEventListenersForType(5)
    director:getEventDispatcher():removeEventListenersForTarget(currScene, true)
    director:getScheduler():unscheduleAllWithMinPriority( cc.PRIORITY_NON_SYSTEM_MIN )
    director:getActionManager():removeAllActions()
    cc.AsyncTaskPool:getInstance():stopTasks(cc.AsyncTaskPool.TaskType.TASK_IO)
    cc.SimpleAudioEngine:destroyInstance()
    ccexp.AudioEngine:uncacheAll()
    global.HttpDownloader:reset()

    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    AuthProxy:resetDownloader()

    -- unregister script handle
    if currScene then
        local function disableEvents(node)
            if tolua.type(node) == "cc.TableView" then
            else
                node:disableNodeEvents()
            end
            local children = node:getChildren()
            for k, v in pairs(children) do
                disableEvents(v)
            end
        end
        disableEvents(currScene)
    end

    -- replace scene
    local scene     = cc.Scene:create()
    local currScene = global.Director:getRunningScene()
    if not currScene then
        global.Director:runWithScene( scene )
    else
        global.Director:replaceScene( scene )
    end
    local LayerFacadeMediator = requireMediator( "LayerFacadeMediator" )
    local lFMediator = facade:retrieveMediator(LayerFacadeMediator.NAME)
    lFMediator:InitOnEnterActive(scene)

    director:getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()

    -- clear net msg
    local netClient  = global.gameEnvironment:GetNetClient()
    netClient:CleanAllMessageHandler()
    LuaNetworkController:Inst():UnregisterAllLuaHandler()
end

function gameStateWorld:CleanWorld()
    -- logic
    global.BuffManager:Cleanup()
    global.ActorEffectManager:Cleanup()
    global.gameMapController:Cleanup()
    global.netNpcController:Cleanup()
    global.netMonsterController:Cleanup()
    global.netPlayerController:Cleanup()
    global.gamePlayerController:Cleanup()   
    global.dropItemController:Cleanup()
    global.actorRefreshController:Cleanup()
    global.actorInViewController:Cleanup()

    -- actor
    global.actorManager:Cleanup()
    global.HUDManager:Cleanup()

    -- scene
    global.dropItemManager:Cleanup()
    global.monsterManager:Cleanup()
    global.npcManager:Cleanup()
    global.playerManager:Cleanup()
    global.sceneGraphCtl:Cleanup()
    global.sceneManager:Cleanup()
    global.sceneEffectManager:Cleanup()

    -- skill
    global.skillManager:Cleanup()
    global.GameActorSkillController:Cleanup()

    -- anim cleanup
    global.FrameAnimManager:unloadAllUnusedAnimData()

    -- clean
    global.ResDownloader:CleanupDownloadCount()
end

function gameStateWorld:Destory()
    if global.sceneManager then
        global.sceneManager:destory()
        global.sceneManager = nil
    end

    if global.mouseEventController then
        global.mouseEventController:destory()
        global.mouseEventController = nil
    end
    
    if global.gamePlayerController then
        global.gamePlayerController:destory()
        global.gamePlayerController = nil
    end

    if global.netPlayerController then
        global.netPlayerController:destory()
        global.netPlayerController = nil
    end

    if global.netMonsterController then
        global.netMonsterController:destory()
        global.netMonsterController = nil
    end
    
    if global.netNpcController then
        global.netNpcController:destory()
        global.netNpcController = nil
    end
    
    if global.dropItemController then
        global.dropItemController:destory()
        global.dropItemController = nil
    end
    
    if global.gameMapController then
        global.gameMapController:destory()
        global.gameMapController = nil
    end

    if global.actorRefreshController then
        global.actorRefreshController:destory()
        global.actorRefreshController = nil
    end
    
    if global.actorInViewController then
        global.actorInViewController:destory()
        global.actorInViewController = nil
    end

    if global.GameActorSkillController then
        global.GameActorSkillController:destory()
        global.GameActorSkillController = nil
    end

    if global.actorManager then
        global.actorManager:destory()
        global.actorManager = nil
    end

    if global.monsterManager then
        global.monsterManager:destory()
        global.monsterManager = nil
    end

    if global.playerManager then
        global.playerManager:destory()
        global.playerManager = nil
    end

    if global.npcManager then
        global.npcManager:destory()
        global.npcManager = nil
    end

    if global.dropItemManager then
        global.dropItemManager:destory()
        global.dropItemManager = nil
    end

    if global.sceneEffectManager then
        global.sceneEffectManager:destory()
        global.sceneEffectManager = nil
    end

    if global.skillManager then
        global.skillManager:destory()
        global.skillManager = nil
    end

    if global.HUDManager then
        global.HUDManager:destory()
        global.HUDManager = nil
    end
    
    if global.HUDHPManager then
        global.HUDHPManager:destory()
        global.HUDHPManager = nil
    end

    if global.BuffManager then
        global.BuffManager:destory()
        global.BuffManager = nil
    end
  
    if global.DObstacleController then
        global.DObstacleController:destory()
        global.DObstacleController = nil
    end
  
    if global.sceneGraphCtl then
        global.sceneGraphCtl:destory()
        global.sceneGraphCtl = nil
    end

    if global.gameWorldController then
        global.gameWorldController:destory()
        global.gameWorldController = nil
    end
    
    if global.PathFindController then
        global.PathFindController:destory()
        global.PathFindController = nil
    end
    
    if global.BehaviorController then
        global.BehaviorController:destory()
        global.BehaviorController = nil
    end
    
    if global.ActorEffectManager then
        global.ActorEffectManager:destory()
        global.ActorEffectManager = nil
    end

    global.WidgetCacheManager   = nil
end


return gameStateWorld
