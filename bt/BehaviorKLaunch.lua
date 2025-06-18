local Behavior = require("bt/Behavior")
local BehaviorKLaunch = class("BehaviorKLaunch", Behavior)

local facade            = global.Facade
local BehaviorConfig    = global.BehaviorConfig


function BehaviorKLaunch:ctor(data)
    BehaviorKLaunch.super.ctor(self, data)
end

function BehaviorKLaunch:getType()
    return BehaviorConfig.BehaviorType.BehaviorKLaunch
end

function BehaviorKLaunch:update(player, actCompleted)
    -- launch
    local mainPlayer            = global.gamePlayerController:GetMainPlayer()
    local launchAble            = global.GameActorSkillController:CheckKLaunchAble()
    if launchAble and mainPlayer then
        global.GameActorSkillController:RequestLaunchServerSkill()
        return BehaviorConfig.BTSTATUS_Running
    end

    return BehaviorConfig.BTSTATUS_Failure
end

return BehaviorKLaunch