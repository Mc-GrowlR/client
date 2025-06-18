local RefreshActorShaBaKeZoneCommand = class('RefreshActorShaBaKeZoneCommand', framework.SimpleCommand)

function RefreshActorShaBaKeZoneCommand:ctor()
end

function RefreshActorShaBaKeZoneCommand:execute(notification)
    local actorID = notification:getBody()
    if not actorID then
        return nil
    end

    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return nil
    end

    -- 是否检测区域
    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    if not MapProxy:IsCheckShaBaKeZone() then
        return nil
    end

    -- 计算状态
    local lastShaBaKeZone = actor:GetShaBaKeZone()
    local inShaBaKeZone = MapProxy:CheckShaBeKeZone(actor:GetMapX(), actor:GetMapY())
    actor:SetShaBaKeZone(inShaBaKeZone)

    -- 与上次不同
    if lastShaBaKeZone ~= inShaBaKeZone then
        global.Facade:sendNotification(global.NoticeTable.DelayRefreshHUDLabel, {
            actor = actor,
            actorID = actorID
        })
    end
end

return RefreshActorShaBaKeZoneCommand
