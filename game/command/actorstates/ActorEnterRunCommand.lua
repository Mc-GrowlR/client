local ActorEnterRunCommand = class('ActorEnterWalkCommand', framework.SimpleCommand)

function ActorEnterRunCommand:ctor()
end

function ActorEnterRunCommand:execute(note)
    local data = note:getBody()
    local actor = data.actor

    if not actor then
        return
    end

    actor:SetAction(global.MMO.ACTION_RUN)
end

return ActorEnterRunCommand