local ActorEnterSkillCommand = class('ActorEnterSkillCommand', framework.SimpleCommand)

function ActorEnterSkillCommand:ctor()

end

function ActorEnterSkillCommand:execute(note)
    local data = note:getBody()
    local actor = data.actor
    local actionId = data.ActionId

    if not actor then
        return
    end

    if data.dir then
        actor:SetDirection(data.dir)
    end

    if data.NoHitAct == 1 or actionId == -1 then --不需要播放攻击
        actor:SetAction(global.MMO.ACTION_IDLE)
    else
        local action = global.MMO.ACTION_SKILL
        if actionId and actionId > 0 then
            actionId = actionId + (global.MMO.ACTION_YTPD - 1)
            if actionId <= global.MMO.ACTION_MAX then
                action = actionId
            end
        end
        actor:SetAction(action, true)
    end 

end

return ActorEnterSkillCommand