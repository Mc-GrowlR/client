local ChangeSceneCommand = class('ChangeSceneCommand', framework.SimpleCommand)

function ChangeSceneCommand:ctor()
end

function ChangeSceneCommand:execute(notification)
    local mapID = notification:getBody()
    if not mapID then
        releasePrint( "error, change scene data is nil" )
    end


    local facade   = global.Facade
    local mapProxy = facade:retrieveProxy( global.ProxyTable.Map )
    local lastMapID = mapProxy:GetLastMapID()

    -- 切地图刷新主玩家的一些显示，
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    if mainPlayer and mainPlayerID then
        global.HUDHPManager:UpdateNow(mainPlayer)
        mainPlayer:SetInSafeZone(mapProxy:GetInSafeArea(mainPlayer:GetMapX(), mainPlayer:GetMapY()))
    end

    -- 清理技能特效
    global.skillManager:CleanupBehaviors()

    -- 关闭NPC面板
    local npcProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    npcProxy:Cleanup()

    -- 刷新主玩家安全区
    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    MapProxy:UpdateInSafeAreaState()

    -- first enter world
    if nil == lastMapID then
        ClearWorldLoadingProgress()

        local envProxy      = global.Facade:retrieveProxy( global.ProxyTable.GameEnvironment )
        local AuthProxy     = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
        local loginProxy    = global.Facade:retrieveProxy( global.ProxyTable.Login )
        local account       = AuthProxy:GetUID()
        local roleName      = loginProxy:GetSelectedRoleName()
        local serverID      = loginProxy:GetSelectedServerId()
        local channelID     = envProxy:GetChannelID()
        local currentModule = global.L_ModuleManager:GetCurrentModule()
        local currentSubMod = currentModule:GetCurrentSubMod()
        local displayVer    = currentModule:GetAllVersionForDisplay()

        local userValue = string.format( "%s|%s|%s|%s|%s|%s|%s|%s",
                                        tostring( displayVer ), 
                                        tostring( channelID ),
                                        tostring( account ), 
                                        tostring( roleName ),
                                        tostring( mapID ),
                                        tostring( serverID ),
                                        tostring( currentModule:GetID() ),
                                        tostring( currentSubMod:GetID() )
                                        )

        -- ver|channel|account|roleName|mapID|serverID
        if cc.PLATFORM_OS_ANDROID == global.Platform then
            buglyAddUserValue( "UserAccountData", userValue )
        else
            releasePrint( "__________user account data:" .. userValue )
        end
    end

    if lastMapID ~= mapID then
        -- stop all audio
        facade:sendNotification( global.NoticeTable.Audio_Stop_All )

        facade:sendNotification( global.NoticeTable.MapInfoChange, mapID, lastMapID )

        -- ssr
        ssr.ssrBridge:onMapInfoChange({mapID = mapID, lastMapID = lastMapID})

        -- SL
        if lastMapID then
            SLBridge:onLUAEvent(LUA_EVENT_MAPINFOCHANGE, {mapID = mapID, lastMapID = lastMapID})
        else
            SLBridge:onLUAEvent(LUA_EVENT_MAPINFOINIT, {mapID = mapID})
        end

        CheckNeedAddSLMapEffect(lastMapID, mapID)
    end
    
    -- ssr
    ssr.ssrBridge:onChangeScene({mapID = mapID, lastMapID = lastMapID})

    -- SL
    SLBridge:onLUAEvent(LUA_EVENT_CHANGESCENE, {mapID = mapID})
end


return ChangeSceneCommand

