local gameActorState = require( "actor/gameActorState")
local gameActorStatePlayerDYZ = class('gameActorStatePlayerDYZ', gameActorState)
function gameActorStatePlayerDYZ:ctor()
    gameActorStatePlayerDYZ.super.ctor(self)
end

function gameActorStatePlayerDYZ:GetStateID()
    return global.MMO.ACTION_DYZ
end
-----------------------------------------------------------------------------
function gameActorStatePlayerDYZ:Tick(dt, player)  
    player.mCurrentActT = player.mCurrentActT - dt

    if 0 >= player.mCurrentActT and player.mIsConfirmed then
        if player.mActionHandler then
            player.mActionHandler:handleActionCompleted( player, global.MMO.ACTION_DYZ )
        end
    end

    -- confirmed timeout
    if player.mCurrentActT <= -5.0 then
        player:SetConfirmed(true)
    end
end
-----------------------------------------------------------------------------
function gameActorStatePlayerDYZ:OnEnter(player)    
    if player.mActionHandler then
        player.mActionHandler:handleActionBegin( player, global.MMO.ACTION_DYZ, player.mOrient, 0 )
    end 

    local clothID       = player:GetAnimationID()
    local SkillPoxy     = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local sex           = player:GetValueByKey( global.MMO.BUFF_PLAYER_AVATAR_SEX ) or player:GetSexID()
    local defaultTime   = SkillPoxy:GetSkillActionTime(global.MMO.ACTION_DYZ, clothID, sex) or global.MMO.DEFAULT_DYZ_TIME
    local attackSpeed   = player:GetAttackSpeed()
    if SkillPoxy:GetSkillActionSpeed(global.MMO.ANIM_DYZ) == 1 then
        attackSpeed = player:GetMagicSpeed()
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
function gameActorStatePlayerDYZ:OnExit(player)    
    -- reset prepare time
    player:SetAnimPrepare(3)

    -- 
    player:SetAnimAct(global.MMO.ANIM_READY)
    player:dirtyAnimFlag()
end
-----------------------------------------------------------------------------
function gameActorStatePlayerDYZ:ChangeState(newState, player, isTerminate)    
    player.mCurrentState = newState   

    return true
end
return gameActorStatePlayerDYZ
-----------------------------------------------------------------------------

