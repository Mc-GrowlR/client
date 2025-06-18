local ActorDieCommand = class('ActorDieCommand', framework.SimpleCommand)

local optionsUtils = requireProxy("optionsUtils")

function ActorDieCommand:ctor()
end

function ActorDieCommand:execute(notification)
    local data = notification:getBody()
    local actor = data.actor
    if not actor then
        return false
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    local actorID = actor:GetID()

    if inputProxy:GetTargetID() == actorID then
        inputProxy:ClearTarget()

        -- 挂机时目标死亡，标记一定时间
        if autoProxy:IsAFKState() or autoProxy:IsAutoFightState() then
            autoProxy:SetAFKTargetDeath(true)
        end
    end

    if inputProxy:GetAttackTargetID() == actorID then
        inputProxy:ClearAttackTargetID()
    end
    
    if inputProxy:GetMouseOverTargetID() == actorID then
        inputProxy:GetMouseOverTargetID(nil)
    end
    actor:SetKeyValue(global.MMO.HUD_PC_MOUSE_SHOW, false)

    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if mainPlayer and mainPlayer:GetHateID() == actorID then
        mainPlayer:SetHateID(nil)
    end

    global.actorInViewController:DelActor(actor)

    global.HUDHPManager:DelActor(actor, true)

    global.Facade:sendNotification(global.NoticeTable.RefreshActorSceneOptions, actor)

    if actor:IsMonster() or actor:IsHumanoid() then
        global.Facade:sendNotification(global.NoticeTable.RefreshBuffVisible, actor)
    end
end

return ActorDieCommand