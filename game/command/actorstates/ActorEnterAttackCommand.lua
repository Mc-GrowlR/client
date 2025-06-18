local ActorEnterAttackCommand = class('ActorEnterAttackCommand', framework.SimpleCommand)

function ActorEnterAttackCommand:ctor()
end

function ActorEnterAttackCommand:execute(note)
    local data = note:getBody()
    local actor = data.actor
    local actionId = data.ActionId

    if not actor then
        return
    end

    if data.dir then
        actor:SetDirection(data.dir)
    end

    if false == data.isMagic and actor:IsMonster() then
        local pos = global.sceneManager:MapPos2WorldPos(data.X, data.Y, true)
        actor:setPosition(pos.x, pos.y)
        global.actorManager:SetActorMapXY( actor, data.X, data.Y )
    end

    if data.NoHitAct == 1 or actionId == -1 then --不需要播放攻击
        actor:SetAction(global.MMO.ACTION_IDLE)
    else
        local action = global.MMO.ACTION_ATTACK
        if actionId and actionId > 0 then
            actionId = actionId + (global.MMO.ACTION_YTPD - 1)
            if actionId <= global.MMO.ACTION_MAX then
                action = actionId
            end
        end
        actor:SetAction(action, true)
    end
end

return ActorEnterAttackCommand