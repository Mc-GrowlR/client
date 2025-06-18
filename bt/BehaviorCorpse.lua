local Behavior = require("bt/Behavior")
local BehaviorCorpse = class("BehaviorCorpse", Behavior)

local facade            = global.Facade
local BehaviorConfig    = global.BehaviorConfig

function BehaviorCorpse:ctor(data)
    BehaviorCorpse.super.ctor(self, data)
end

function BehaviorCorpse:getType()
    return BehaviorConfig.BehaviorType.BehaviorCorpse
end

function BehaviorCorpse:update(player, actCompleted)
    local inputProxy    = global.Facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
    local corpseID      = inputProxy:GetCorpseID()

    local mainPlayer    = global.gamePlayerController:GetMainPlayer()
    local targetActor   = global.actorManager:GetActor(corpseID)
    if not mainPlayer then
        return BehaviorConfig.BTSTATUS_Failure
    end
    if not targetActor then
        return BehaviorConfig.BTSTATUS_Failure
    end

    local dest          = cc.p(targetActor:GetMapX(), targetActor:GetMapY())
    local src           = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    local dir           = inputProxy:calcMapDirection(dest, src)
    if not dir or dir == global.MMO.ORIENT_INVAILD then
        dir = mainPlayer:GetDirection()
    end
    mainPlayer:SetAction(global.MMO.ACTION_SITDOWN)
    mainPlayer:SetDirection(dir)

    -- 
    inputProxy:RequestDigCorpse(dir, corpseID)
    inputProxy:ClearCorpse()

    return BehaviorConfig.BTSTATUS_Running
end

return BehaviorCorpse