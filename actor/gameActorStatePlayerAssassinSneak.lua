local gameActorStateMoveBase = require( "actor/gameActorStateMoveBase")
local gameActorStatePlayerAssassinSneak = class('gameActorStatePlayerAssassinSneak', gameActorStateMoveBase)

function gameActorStatePlayerAssassinSneak:ctor()
    self.super.ctor(self)
end

function gameActorStatePlayerAssassinSneak:GetStateID()
    return global.MMO.ACTION_ASSASSIN_SNEAK
end

function gameActorStatePlayerAssassinSneak:GetMoveTime( actor )
    return global.MMO.DEFAULT_ASSASSIN_SNEAK_TIME / actor:GetWalkSpeed()
end

function gameActorStatePlayerAssassinSneak:OnEnter( actor )    
    self.super.OnEnter( self, actor )

    -- reset some data
    actor:SetAnimPrepare( 0.0 )
    actor:dirtyAnimFlag()
end

function gameActorStatePlayerAssassinSneak:OnExit( actor )    
    actor:SetAnimPrepare(0.1)

    if SL:GetMetaValue("GAME_DATA","gameOption_WalkOnly") ~= 1 or (actor:IsHumanoid() or actor:IsHero()) then
        actor:StopAllAnimation(6)
    end
end

return gameActorStatePlayerAssassinSneak