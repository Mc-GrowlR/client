local MonsterCaveCommand = class('MonsterCaveCommand', framework.SimpleCommand)

local optionsUtils = requireProxy("optionsUtils")

function MonsterCaveCommand:ctor()
end

function MonsterCaveCommand:execute(notification)
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
    end
end

return MonsterCaveCommand
