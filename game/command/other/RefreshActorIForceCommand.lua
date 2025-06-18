local RefreshActorIForceCommand = class('RefreshActorIForceCommand', framework.SimpleCommand)

function RefreshActorIForceCommand:ctor()
end

function RefreshActorIForceCommand:execute(notification)
    local data     = notification:getBody()
    local actorID  = data.actorID
    local force    = data.curInternalForce
    local maxForce = data.maxInternalForce


    local propertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    local HeroPropertyProxy = global.Facade:retrieveProxy( global.ProxyTable.HeroPropertyProxy )
    local HeroID = HeroPropertyProxy:GetRoleUID()
    if mainPlayerID == actorID then
        if force or maxForce then
            propertyProxy:SetIForceData(force, maxForce)
        end

    elseif HeroID == actorID then
        if force or maxForce then
            HeroPropertyProxy:SetIForceData(force, maxForce)
        end
    end

    -- refresh hud bar
    local actor = global.actorManager:GetActor( actorID )
    if actor and (actor:IsPlayer() or actor:IsHero()) then
        if actor.SetNGHUD then
            actor:SetNGHUD(force, maxForce)
        end
    end
end


return RefreshActorIForceCommand
