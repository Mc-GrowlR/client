local gameActorState = require( "actor/gameActorState")
local gameActorStateMoveBase = class('gameActorStateMoveBase', gameActorState)

local mMin = math.min
local mAbs = math.abs
local mFloor = math.floor
local mRound = math.round

function gameActorStateMoveBase:ctor()
    gameActorStateMoveBase.super.ctor(self)
end

function gameActorStateMoveBase:GetStateID()
    return global.MMO.ACTION_WALK
end

function gameActorStateMoveBase:GetMoveTime( actor )
    return 0.5
end

function gameActorStateMoveBase:Tick(dt, actor)    
    if IsSmoothMove(actor) then
        self:smooth_tick(dt, actor)
    else
        self:mir_tick(dt, actor)
    end
end

function gameActorStateMoveBase:mir_tick(dt, actor)
    actor.mCurrentActT = actor.mCurrentActT - dt
    if not actor.mIsArrived then
        if global.actorManager:IsMoveTime() then
            local percent   = (actor.mMoveTime - actor.mCurrentActT) / actor.mMoveTime
            -- percent     = mMin(1, percent)
            local disp  = percent * actor.mDistanceToTarget
            local dispV = cc.pAdd( cc.p(actor.originPosition), cc.pMul(actor.mMoveOrient, disp) )
            -- PC影子闪
            if actor:GetDirection() % 2 == 0 then
                dispV.x     = mFloor(dispV.x)
                dispV.y     = mFloor(dispV.y)
                -- dispV.x     = mRound(dispV.x)
                -- dispV.y     = mRound(dispV.y)
                dispV.x     = (dispV.x%2 == 0) and dispV.x or dispV.x-1
                dispV.y     = (dispV.y%2 == 0) and dispV.y or dispV.y-1
            else
                dispV.x     = mFloor(dispV.x)
                dispV.y     = mFloor(dispV.y)
            end
            actor:setPosition( dispV.x, dispV.y )
        end

        if actor.mCurrentActT <= 0.0 then
            -- actor:setPosition( actor.mTargePos.x, actor.mTargePos.y )
            actor:SetIsArrived(true)
        end
    end

    if actor.mActionHandler and actor.mIsArrived and actor.mIsConfirmed then
        actor.mActionHandler:handleActionCompleted( actor, self:GetStateID() )
    end

    -- confirmed timeout
    if actor.mCurrentActT <= -5.0 then
        actor:SetConfirmed(true)
    end
end

function gameActorStateMoveBase:smooth_tick(dt, actor)
    actor.mCurrentActT = actor.mCurrentActT - dt
    if not actor.mIsArrived then
        -- Timing...
        if actor.mCurrentActT <= 0.0  then
            actor.mIsArrived   = true       
        end

        -- displacement
        local percent   = (actor.mMoveTime - actor.mCurrentActT) / actor.mMoveTime
        -- percent     = mMin(1, percent)
        local disp      = percent * actor.mDistanceToTarget
        local dispV     = cc.pAdd( cc.p(actor.originPosition), cc.pMul(actor.mMoveOrient, disp) )       
        if global.isWinPlayMode and actor:IsPlayer() and actor:IsMainPlayer() then
            dispV.x     = mRound(dispV.x)
            dispV.y     = mRound(dispV.y)
            -- if actor:GetDirection() % 2 == 0 then
            --     dispV.x = (dispV.x%2 == 0) and dispV.x or dispV.x+1
            --     dispV.y = (dispV.y%2 == 0) and dispV.y or dispV.y+1
            -- end
        end
        actor:setPosition( dispV.x, dispV.y )
    end

    if actor.mActionHandler and actor.mIsArrived and actor.mIsConfirmed then
        actor.mActionHandler:handleActionCompleted( actor, self:GetStateID() )
    end


    -- confirmed timeout
    if actor.mCurrentActT <= -5.0 then
        actor:SetConfirmed(true)
    end
end

function gameActorStateMoveBase:OnEnter(actor)
    if actor.mMoveTo then
        self:moveToNextGrid( actor )
        actor.mIsArrived   = false
        actor:SetConfirmed(false)
        actor.mCurrentActT = self:GetMoveTime( actor )
        actor.mMoveTime    = self:GetMoveTime( actor )
        actor.originPosition = actor:getPosition()
    else
        actor.mIsArrived    = true
        actor.mIsConfirmed  = true

        actor:SetAction( global.MMO.ACTION_IDLE )
    end

    -- 试玩模式，直接确认
    if global.IsVisitor then
        actor:SetConfirmed(true)
    end
end

function gameActorStateMoveBase:OnExit(actor)    
    actor.mCurrentActT = 0
end

function gameActorStateMoveBase:ChangeState(newState, actor, isTerminate)   
    actor.mCurrentState = newState

    return true
end

function gameActorStateMoveBase:moveToNextGrid(actor)   
    local gridPoint = actor.mMoveTo
    local currPos   = cc.p(actor:getPosition())
    local targPos   = global.sceneManager:MapPos2WorldPos( gridPoint.x, gridPoint.y, true )

    actor.mTargePos         = targPos
    actor.mMoveOrient       = cc.pSub(targPos, currPos)
    actor.mDistanceToTarget = cc.pGetLength( actor.mMoveOrient )
    actor.mMoveOrient       = cc.pNormalize(actor.mMoveOrient)

    -- calcuating the orientation for Animation
    local currMapPos        = cc.p( global.sceneManager:WorldPos2MapPos( currPos ) )
    local lastOri           = actor.mOrient
    actor.mOrient           = CalcActorDirByPos( currMapPos, gridPoint, lastOri )

    -- store grid position
    global.actorManager:SetActorMapXY( actor, gridPoint.x, gridPoint.y )

    -- gird pos changed
    if actor.mActionHandler then 
        actor.mActionHandler:handleActionBegin( actor, self:GetStateID() )
    end

    if lastOri ~= actor.mOrient then
        actor:dirtyAnimFlag()
    end
end

return gameActorStateMoveBase