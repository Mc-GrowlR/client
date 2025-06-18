local Behavior = class("Behavior")
local BehaviorConfig = global.BehaviorConfig

function Behavior:ctor(data)
end

function Behavior:getType()
    return BehaviorConfig.BehaviorType.BehaviorBase
end

function Behavior:process(player, actCompleted)
end

function Behavior:update(player, actCompleted)
end

return Behavior