local ActorEnterWalkCommand = class('ActorEnterWalkCommand', framework.SimpleCommand)

function ActorEnterWalkCommand:ctor()
end

function ActorEnterWalkCommand:execute(note)
    local data = note:getBody()
    local actor = data.actor

    if not actor then
        return
    end

    actor:SetAction(global.MMO.ACTION_WALK)
end

return ActorEnterWalkCommand