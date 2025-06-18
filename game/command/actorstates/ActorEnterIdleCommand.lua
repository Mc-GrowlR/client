local ActorEnterIdleCommand = class('ActorEnterIdleCommand', framework.SimpleCommand)

function ActorEnterIdleCommand:ctor()
end

function ActorEnterIdleCommand:execute(note)
    local data = note:getBody()
    local actor = data.actor

    if not actor then
        return
    end

    if global.MMO.ACTION_IDLE == actor:GetAction() then
        return
    end

    actor:SetAction(global.MMO.ACTION_IDLE)
end

return ActorEnterIdleCommand