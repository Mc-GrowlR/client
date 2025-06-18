local gameActorState = require( "actor/gameActorState")
local gameActorStatePlayerStuck = class('gameActorStatePlayerStuck', gameActorState)

local MIN_PLAYER_STUCK_STATE_TIME    =0.1

function gameActorStatePlayerStuck:ctor()
    gameActorStatePlayerStuck.super.ctor(self)
end

function gameActorStatePlayerStuck:Tick(dt, player)    
    player.mCurrentActT = player.mCurrentActT - dt
    if player.mCurrentActT <= 0.00001 then 
        if player.mActionHandler then
            player.mActionHandler:handleActionCompleted( player, global.MMO.ACTION_STUCK )      
        end
    end  
end

function gameActorStatePlayerStuck:OnEnter(player)   
    if player.mActionHandler then
        player.mActionHandler:handleActionBegin( player, global.MMO.ACTION_STUCK, player.mOrient, 0 )
    end 
    local mapProxy          = global.Facade:retrieveProxy(global.ProxyTable.Map)
    local stuckTimeMS       = (mapProxy:GetStuckActionTime() or 200) / 1000
    local currentActT       = stuckTimeMS
    if player:GetIsFullSpeedup() then
        currentActT         = stuckTimeMS / global.MMO.DEFAULT_MUCH_FAST_TIME
    elseif player:GetIsSpeedup() then
        currentActT         = stuckTimeMS / global.MMO.DEFAULT_FAST_TIME_RATE
    end
    player.mCurrentActT     = currentActT

    --
    player:SetAnimPrepare( 0.0 )
    player:dirtyAnimFlag()
end

function gameActorStatePlayerStuck:OnExit(player)    
    player:dirtyAnimFlag()
end

function gameActorStatePlayerStuck:ChangeState(newState, player, isTerminate)    
    player.mCurrentState = newState

    return true
end

function gameActorStatePlayerStuck:GetStateID()    
    return global.MMO.ACTION_STUCK
end

return gameActorStatePlayerStuck