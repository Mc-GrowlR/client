local gameActorStateMoveBase = require( "actor/gameActorStateMoveBase")
local gameActorStatePlayerRun = class('gameActorStatePlayerRun', gameActorStateMoveBase)

function gameActorStatePlayerRun:ctor()
    self.super.ctor(self)
end

function gameActorStatePlayerRun:GetStateID()
    return global.MMO.ACTION_RUN
end

function gameActorStatePlayerRun:GetMoveTime( actor )
    return actor:GetRunStepTime() / actor:GetRunSpeed()
end

function gameActorStatePlayerRun:OnEnter( actor )    
    self.super.OnEnter( self, actor )

    -- reset some data
    actor:SetAnimPrepare( 0.0 )
    actor:dirtyAnimFlag()
end

function gameActorStatePlayerRun:OnExit( actor )
    actor:SetAnimPrepare(0.1)

    if not actor:GetValueByKey(global.MMO.IS_RUN_ONE) then
        actor:StopAllAnimation(6)
    end
end

return gameActorStatePlayerRun