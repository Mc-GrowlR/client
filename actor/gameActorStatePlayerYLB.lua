local gameActorState = require( "actor/gameActorState")
local gameActorStatePlayerYLB = class('gameActorStatePlayerYLB', gameActorState)
function gameActorStatePlayerYLB:ctor()
    gameActorStatePlayerYLB.super.ctor(self)
end

function gameActorStatePlayerYLB:GetStateID()
    return global.MMO.ACTION_XLFH
end
-----------------------------------------------------------------------------
function gameActorStatePlayerYLB:Tick(dt, player)  
    player.mCurrentActT = player.mCurrentActT - dt

    if 0 >= player.mCurrentActT and player.mIsConfirmed then
        if player.mActionHandler then
            player.mActionHandler:handleActionCompleted( player, global.MMO.ACTION_XLFH )
        end
    end

    -- confirmed timeout
    if player.mCurrentActT <= -5.0 then
        player:SetConfirmed(true)
    end
end
-----------------------------------------------------------------------------
function gameActorStatePlayerYLB:OnEnter(player)    
    if player.mActionHandler then
        player.mActionHandler:handleActionBegin( player, global.MMO.ACTION_XLFH, player.mOrient, 0 )
    end 

    local animTime      = global.MMO.DEFAULT_XLFH_TIME / player:GetMagicSpeed()
    player.mAnimTime    = animTime
    player.mCurrentActT = animTime
    player:SetConfirmed(true)

    -- reset some data
    player:SetAnimPrepare( 0.0 )
    player:dirtyAnimFlag()
end
-----------------------------------------------------------------------------
function gameActorStatePlayerYLB:OnExit(player)    
    -- reset prepare time
    player:SetAnimPrepare(3)

    -- 
    player:SetAnimAct(global.MMO.ANIM_READY)
    player:dirtyAnimFlag()
end
-----------------------------------------------------------------------------
function gameActorStatePlayerYLB:ChangeState(newState, player, isTerminate)    
    player.mCurrentState = newState   

    return true
end
return gameActorStatePlayerYLB
-----------------------------------------------------------------------------

