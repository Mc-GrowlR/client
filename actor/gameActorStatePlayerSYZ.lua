local gameActorState = require( "actor/gameActorState")
local gameActorStatePlayerSYZ = class('gameActorStatePlayerSYZ', gameActorState)
function gameActorStatePlayerSYZ:ctor()
    gameActorStatePlayerSYZ.super.ctor(self)
end

function gameActorStatePlayerSYZ:GetStateID()
    return global.MMO.ACTION_SYZ
end
-----------------------------------------------------------------------------
function gameActorStatePlayerSYZ:Tick(dt, player)  
    player.mCurrentActT = player.mCurrentActT - dt
    
    if 0 >= player.mCurrentActT and player.mIsConfirmed then
        if player.mActionHandler then
            player.mActionHandler:handleActionCompleted( player, global.MMO.ACTION_SYZ )
        end
    end

    -- confirmed timeout
    if player.mCurrentActT <= -5.0 then
        player:SetConfirmed(true)
    end
end
-----------------------------------------------------------------------------
function gameActorStatePlayerSYZ:OnEnter(player)    
    self.super.OnEnter( self, player )

    if player.mActionHandler then
        player.mActionHandler:handleActionBegin( player, global.MMO.ACTION_SYZ, player.mOrient, 0 )
    end 

    local clothID       = player:GetAnimationID()
    local SkillPoxy     = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local sex           = player:GetValueByKey( global.MMO.BUFF_PLAYER_AVATAR_SEX ) or player:GetSexID()
    local defaultTime   = SkillPoxy:GetSkillActionTime(global.MMO.ACTION_SYZ, clothID, sex) or global.MMO.DEFAULT_SYZ_TIME
    local attackSpeed   = player:GetMagicSpeed()
    if SkillPoxy:GetSkillActionSpeed(global.MMO.ANIM_SYZ) == 0 then
        attackSpeed = player:GetAttackSpeed()
    end
    local animTime      = defaultTime / attackSpeed
    player.mAnimTime    = animTime
    player.mCurrentActT = animTime
    player:SetConfirmed(true)

    -- reset some data
    player:SetAnimPrepare( 0.0 )
    player:dirtyAnimFlag()
end
-----------------------------------------------------------------------------
function gameActorStatePlayerSYZ:OnExit(player)    
    -- reset prepare time
    player:SetAnimPrepare(3)

    -- 
    player:SetAnimAct(global.MMO.ANIM_READY)
    player:dirtyAnimFlag()
end
-----------------------------------------------------------------------------
function gameActorStatePlayerSYZ:ChangeState(newState, player, isTerminate)    
    player.mCurrentState = newState   

    return true
end
return gameActorStatePlayerSYZ
-----------------------------------------------------------------------------

