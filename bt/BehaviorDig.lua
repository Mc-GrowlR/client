local Behavior = require("bt/Behavior")
local BehaviorDig = class("BehaviorDig", Behavior)

local facade            = global.Facade
local BehaviorConfig    = global.BehaviorConfig

function BehaviorDig:ctor(data)
    BehaviorDig.super.ctor(self, data)
end

function BehaviorDig:getType()
    return BehaviorConfig.BehaviorType.BehaviorDig
end

function BehaviorDig:update(player, actCompleted)
    local inputProxy    = global.Facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
    local digDest       = inputProxy:GetDigDest()

    local mainPlayer    = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return BehaviorConfig.BTSTATUS_Failure
    end
    if not digDest then
        return BehaviorConfig.BTSTATUS_Failure
    end

    local mapX, mapY    = global.sceneManager:WorldPos2MapPos(digDest)
    local dest          = cc.p(mapX, mapY)
    local targetID      = nil
    local targetActor   = global.actorManager:Pick(digDest)
    
    if targetActor and targetActor:IsDie() then
        targetID        = targetActor:GetID()
        dest            = cc.p(targetActor:GetMapX(), targetActor:GetMapY())
    end
    local src           = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    local dir           = inputProxy:calcMapDirection(dest, src)
    if not dir or dir == global.MMO.ORIENT_INVAILD then
        dir = mainPlayer:GetDirection()
    end
    mainPlayer:SetAction(global.MMO.ACTION_SITDOWN)
    mainPlayer:SetDirection(dir)

    -- 
    inputProxy:RequestDigCorpse(dir, targetID)
    inputProxy:ClearDigDest()

    return BehaviorConfig.BTSTATUS_Running
end

return BehaviorDig