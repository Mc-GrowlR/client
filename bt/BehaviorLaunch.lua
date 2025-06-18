local Behavior = require("bt/Behavior")
local BehaviorLaunch = class("BehaviorLaunch", Behavior)

local facade            = global.Facade
local BehaviorConfig    = global.BehaviorConfig


function BehaviorLaunch:ctor(data)
    BehaviorLaunch.super.ctor(self, data)
end

function BehaviorLaunch:getType()
    return BehaviorConfig.BehaviorType.BehaviorLaunch
end

function BehaviorLaunch:update(player, actCompleted)
    local inputProxy            = facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local skillProxy            = facade:retrieveProxy(global.ProxyTable.Skill)
    local autoProxy             = facade:retrieveProxy(global.ProxyTable.Auto)

    -- launch
    if inputProxy:GetLaunchSkillID() then
        local skillID           = inputProxy:GetLaunchSkillID()

        global.Facade:sendNotification(global.NoticeTable.RequestLaunchSkill, {skillID = skillID})

        -- 技能释放计算时，需要走位，当前无法释放，

        return BehaviorConfig.BTSTATUS_Running
    end

    return BehaviorConfig.BTSTATUS_Failure
end

return BehaviorLaunch