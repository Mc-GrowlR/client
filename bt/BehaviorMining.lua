local Behavior = require("bt/Behavior")
local BehaviorMining = class("BehaviorMining", Behavior)

local facade            = global.Facade
local BehaviorConfig    = global.BehaviorConfig


function BehaviorMining:ctor(data)
    BehaviorMining.super.ctor(self, data)
end

function BehaviorMining:getType()
    return BehaviorConfig.BehaviorType.BehaviorMining
end

function BehaviorMining:update(player, actCompleted)
    local inputProxy        = facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)

    local dir               = inputProxy:GetMiningDir()
    local dest              = inputProxy:GetMiningDest()

    if not dir or not dest then
        return BehaviorConfig.BTSTATUS_Failure
    end

    global.Facade:sendNotification(global.NoticeTable.RequestLaunchSkill, {skillID = global.MMO.SKILL_INDEX_DIG, dest = dest, dir = dir, priority = global.MMO.LAUNCH_PRIORITY_USER})

    global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type=global.MMO.SND_TYPE_SKILL_ATTACK})
    
    inputProxy:ClearMining()

    return BehaviorConfig.BTSTATUS_Running
end

return BehaviorMining