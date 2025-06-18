local gameActorState = require( "actor/gameActorState")
local gameActorStateMonsterOnPush = class('gameActorStateMonsterOnPush', gameActorState)

local mMin = math.min
local mAbs = math.abs
local mFloor = math.floor

function gameActorStateMonsterOnPush:ctor()
    gameActorStateMonsterOnPush.super.ctor(self)
end

function gameActorStateMonsterOnPush:GetStateID()
    return global.MMO.ACTION_ONPUSH
end

function gameActorStateMonsterOnPush:Tick(dt, actor)    
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
        actor:setPosition( dispV.x, dispV.y )
    end

    if actor.mActionHandler and actor.mIsArrived then
        actor.mActionHandler:handleActionCompleted( actor, self:GetStateID() )
    end
end

function gameActorStateMonsterOnPush:OnEnter(actor)
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
    actor:dirtyAnimFlag()
end

function gameActorStateMonsterOnPush:OnExit(actor)    
    actor.mCurrentActT = 0
end

function gameActorStateMonsterOnPush:ChangeState(newState, actor, isTerminate)   
    actor.mCurrentState = newState

    return true
end

return gameActorStateMonsterOnPush