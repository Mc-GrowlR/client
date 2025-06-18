local netActorController = require("logic/netActorController")
local netPlayerController = class("netPlayerController",netActorController)
netPlayerController.NAME = "netPlayerController"

local moveStep = 
{
    [global.MMO.ACTION_WALK] = 1,
    [global.MMO.ACTION_RUN] = 2,
    [global.MMO.ACTION_RIDE_RUN] = 3,
}

function netPlayerController:ctor()
    netPlayerController.super.ctor(self)
end

function netPlayerController:destory()
    netPlayerController.super.ctor(self)

    if netPlayerController.instance then
        netPlayerController.instance = nil
    end
end

function netPlayerController:Inst()
    if not netPlayerController.instance then
        netPlayerController.instance = netPlayerController.new()
    end

    return netPlayerController.instance
end

---------------------------------------------------------------------------
function netPlayerController:handleActionBegin(actor, act, Param1, Param2)
    netPlayerController.super.handleActionBegin(self, actor, act)
end

-----------------------------------------------------------------------------
function netPlayerController:handleActionCompleted(actor, actCompleted)
    netPlayerController.super.handleActionCompleted(self, actor, actCompleted)

    -- 足迹特效
    if actor:IsMoveEff() and SL:GetMetaValue("GAME_DATA", "disable_footprint_effect") ~= 1 then
        if actCompleted == global.MMO.ACTION_WALK or actCompleted == global.MMO.ACTION_RUN or actCompleted == global.MMO.ACTION_RIDE_RUN then 
            local lastMapX = actor:GetLastMapX()
            local lastMapY = actor:GetLastMapY()
            local skipWalk = actor:GetMoveEffSkipWalk()
            local skipSwitch = actor:GetEffSkipWalkSwitch() or 0
            actor:SetMoveEffSkipWalk(not skipWalk and skipSwitch == 0)
            if lastMapX == 0xFFFF or lastMapY == 0xFFFF or (actCompleted == global.MMO.ACTION_WALK and skipWalk) then
                return
            end
            global.gameMapController:addEffectToMap(actor:GetMoveEff(), lastMapX, lastMapY)
        end 
    end
end

function netPlayerController:handleActionProcess(actor, act, dt)
end

function netPlayerController:AddNetPlayerToWorld( param )
    local id = param.actorID
    local netPlayer = global.actorManager:CreateActor( id, global.MMO.ACTOR_PLAYER )
    if nil == netPlayer then
        return nil
    end


    -- bind handler
    netPlayer:SetGameActorActionHandler( self )

    netPlayer:SetSexID( param.sex )
    netPlayer:SetDirection( param.dir )
    netPlayer:SetAction( global.MMO.ACTION_IDLE )
    netPlayer:SetClothID( 0 )


    -- 
    local refreshData = {}
    refreshData.actor = netPlayer
    refreshData.actorID = param.actorID
    global.Facade:sendNotification(global.NoticeTable.DelayCreateHUDBar, refreshData)
    
    return netPlayer
end

function netPlayerController:handle_Die( actor, msgHdr )
    netPlayerController.super.handle_Die(self, actor, msgHdr)
end

function netPlayerController:Cleanup( cleanHandler )
    netPlayerController.super.Cleanup(self, cleanHandler)
end

return netPlayerController
