local gameActorStateMoveBase = require( "actor/gameActorStateMoveBase")
local gameActorStatePlayerDashFail = class('gameActorStatePlayerWalk', gameActorStateMoveBase)

function gameActorStatePlayerDashFail:ctor()
    self.super.ctor(self)
end

function gameActorStatePlayerDashFail:GetStateID()
    return global.MMO.ACTION_DASH_FAIL
end

function gameActorStatePlayerDashFail:Tick(dt, actor)
    gameActorStatePlayerDashFail.super.Tick(self, dt, actor)

    if not self.mReBoundFinsh and actor.mIsArrived then
        local targPos = global.sceneManager:MapPos2WorldPos( actor:GetMapX(), actor:GetMapY(), true )
        actor:setPosition( targPos.x, targPos.y )

        self.mReBoundFinsh = true
        actor:SetConfirmed(true)
    end
end

function gameActorStatePlayerDashFail:OnEnter( actor )
    local currPos   = cc.p(actor:getPosition())
    local targPos   = global.sceneManager:MapPos2WorldPos( actor:GetMapX(), actor:GetMapY(), true )
    local actorDir  = actor:GetDirection()

    local gridFactor = 0.5
    if actorDir == global.MMO.ORIENT_U then
        targPos.y = targPos.y + global.MMO.MapGridHeight * gridFactor
    elseif actorDir == global.MMO.ORIENT_RU then
        targPos.x = targPos.x + global.MMO.MapGridWidth * gridFactor
        targPos.y = targPos.y + global.MMO.MapGridHeight * gridFactor
    elseif actorDir == global.MMO.ORIENT_R then
        targPos.x = targPos.x + global.MMO.MapGridWidth * gridFactor
    elseif actorDir == global.MMO.ORIENT_RB then
        targPos.x = targPos.x + global.MMO.MapGridWidth * gridFactor
        targPos.y = targPos.y - global.MMO.MapGridHeight * gridFactor
    elseif actorDir == global.MMO.ORIENT_B then
        targPos.y = targPos.y - global.MMO.MapGridHeight * gridFactor
    elseif actorDir == global.MMO.ORIENT_LB then
        targPos.x = targPos.x - global.MMO.MapGridWidth * gridFactor
        targPos.y = targPos.y - global.MMO.MapGridHeight * gridFactor
    elseif actorDir == global.MMO.ORIENT_L then
        targPos.x = targPos.x - global.MMO.MapGridWidth * gridFactor
    elseif actorDir == global.MMO.ORIENT_LU then
        targPos.x = targPos.x - global.MMO.MapGridWidth * gridFactor
        targPos.y = targPos.y + global.MMO.MapGridHeight * gridFactor
    end

    local animTime          = actor:GetRunStepTime() / actor:GetRunSpeed() / 4
    actor.mTargePos         = targPos
    actor.mMoveOrient       = cc.pSub(targPos, currPos)
    actor.mDistanceToTarget = cc.pGetLength( actor.mMoveOrient )
    actor.mMoveOrient       = cc.pNormalize(actor.mMoveOrient)
    actor.mIsArrived        = false
    actor.mCurrentActT      = animTime
    actor.mMoveTime         = animTime
    actor.originPosition    = actor:getPosition()

    self.mReBoundFinsh      = false

    if actor.mActionHandler then 
        actor.mActionHandler:handleActionBegin( actor, self:GetStateID() )
    end

    -- reset some data
    actor:SetConfirmed(false)
    actor:SetAnimPrepare( 0.0 )
    actor:dirtyAnimFlag()
end

function gameActorStatePlayerDashFail:OnExit( actor )    
    actor:SetAnimPrepare(0.1)
    actor:StopAllAnimation(6)
end

return gameActorStatePlayerDashFail