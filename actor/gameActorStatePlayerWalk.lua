local gameActorStateMoveBase = require( "actor/gameActorStateMoveBase")
local gameActorStatePlayerWalk = class('gameActorStatePlayerWalk', gameActorStateMoveBase)

function gameActorStatePlayerWalk:ctor()
    self.super.ctor(self)
end

function gameActorStatePlayerWalk:GetStateID()
    return global.MMO.ACTION_WALK
end

function gameActorStatePlayerWalk:GetMoveTime( actor )
    return actor:GetWalkStepTime() / actor:GetWalkSpeed()
end

function gameActorStatePlayerWalk:OnEnter( actor )    
    self.super.OnEnter( self, actor )

    -- reset some data
    actor:SetAnimPrepare( 0.0 )
    actor:dirtyAnimFlag()
end

function gameActorStatePlayerWalk:OnExit( actor )    
    actor:SetAnimPrepare(0.1)

    if SL:GetMetaValue("GAME_DATA","gameOption_WalkOnly") ~= 1 or (actor:IsHumanoid() or actor:IsHero()) then
        actor:StopAllAnimation(6)
    end
end

return gameActorStatePlayerWalk