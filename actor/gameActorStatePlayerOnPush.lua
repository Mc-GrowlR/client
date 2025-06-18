local gameActorState = require( "actor/gameActorState")
local gameActorStatePlayerOnPush = class('gameActorStatePlayerOnPush', gameActorState)

local mMin = math.min
local mAbs = math.abs
local mFloor = math.floor
local mRound = math.round

function gameActorStatePlayerOnPush:ctor()
    gameActorStatePlayerOnPush.super.ctor(self)
end

function gameActorStatePlayerOnPush:GetStateID()
    return global.MMO.ACTION_ONPUSH
end

function gameActorStatePlayerOnPush:Tick(dt, actor)    
    actor.mCurrentActT = actor.mCurrentActT - dt
    if not actor.mIsArrived then
        -- Timing...
        if actor.mCurrentActT <= 0.0  then
            actor:SetIsArrived(true)       
        end

        -- displacement
        local percent   = (actor.mMoveTime - actor.mCurrentActT) / actor.mMoveTime
        percent         = mMin(1, percent)
        local disp  = percent * actor.mDistanceToTarget
        local dispV = cc.pAdd( cc.p(actor.originPosition), cc.pMul(actor.mMoveOrient, disp) )

        if global.isWinPlayMode and actor:IsPlayer() and actor:IsMainPlayer() then
            dispV.x = mRound(dispV.x)
            dispV.y = mRound(dispV.y)
        end
        
        actor:setPosition( dispV.x, dispV.y )
    end

    if actor.mActionHandler then
        if actor.mIsArrived then
            actor.mActionHandler:handleActionCompleted( actor, self:GetStateID() )
        else
            actor.mActionHandler:handleActionProcess( actor, self:GetStateID(), dt )
        end
    end
end

function gameActorStatePlayerOnPush:OnEnter(actor)
    if actor.mActionHandler then 
        actor.mActionHandler:handleActionBegin( actor, self:GetStateID() )
    end

    local currPos = cc.p(actor:getPosition())
    local targPos = global.sceneManager:MapPos2WorldPos( actor:GetMapX(), actor:GetMapY(), true )

    actor.mTargePos         = targPos
    actor.mMoveOrient       = cc.pSub(targPos, currPos)
    actor.mDistanceToTarget = cc.pGetLength(actor.mMoveOrient)
    actor.mMoveOrient       = cc.pNormalize(actor.mMoveOrient)

    actor.mMoveTime         = actor.mCurrentActT
    actor.originPosition    = actor:getPosition()
    actor.mIsArrived        = false

    -- reset some data
    actor:SetAnimPrepare( 0.0 )
    actor:dirtyAnimFlag()
end

function gameActorStatePlayerOnPush:OnExit(actor)    
    actor.mCurrentActT = 0
    -- reset some data
    actor:SetAnimPrepare( 0.0 )
    actor:dirtyAnimFlag()
end

function gameActorStatePlayerOnPush:ChangeState(newState, actor, isTerminate)   
    actor.mCurrentState = newState

    return true
end

return gameActorStatePlayerOnPush