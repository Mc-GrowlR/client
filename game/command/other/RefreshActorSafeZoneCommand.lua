local RefreshActorSafeZoneCommand = class('RefreshActorSafeZoneCommand', framework.SimpleCommand)

function RefreshActorSafeZoneCommand:ctor()
end

function RefreshActorSafeZoneCommand:execute(notification)
    local actorID = notification:getBody()
    if not actorID then
        return nil
    end

    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return nil
    end

    local MapProxy = global.Facade:retrieveProxy( global.ProxyTable.Map )

    -- 计算状态
    local lastSafeZone = actor:GetInSafeZone()
    local inSafeZone = MapProxy:GetInSafeArea(actor:GetMapX(), actor:GetMapY() )
    actor:SetInSafeZone(inSafeZone)

    -- 与上次不同，通知刷新
    if inSafeZone ~= lastSafeZone then
        global.Facade:sendNotification(global.NoticeTable.ActorSafeZoneChange, {actorID = actorID, actor = actor})
        if actorID == global.gamePlayerController:GetMainPlayerID() then
            SLBridge:onLUAEvent(LUA_EVENT_PLAYER_IN_SAFEZONE_CHANGE)
        else
            SLBridge:onLUAEvent(LUA_EVENT_NET_PLAYER_IN_SAFEZONE_CHANGE, {id = actorID})
        end

        local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
        if GuildProxy:IsGuildWar() then
            global.Facade:sendNotification(global.NoticeTable.RefreshGuildActorColor)
        end

    end
end

return RefreshActorSafeZoneCommand
