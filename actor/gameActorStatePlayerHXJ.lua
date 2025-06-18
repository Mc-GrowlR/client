local gameActorState = require( "actor/gameActorState")
local gameActorStatePlayerHXJ = class('gameActorStatePlayerHXJ', gameActorState)
function gameActorStatePlayerHXJ:ctor()
    gameActorStatePlayerHXJ.super.ctor(self)
end

function gameActorStatePlayerHXJ:GetStateID()
    return global.MMO.ACTION_HXJ
end
-----------------------------------------------------------------------------
function gameActorStatePlayerHXJ:Tick(dt, player)  
    player.mCurrentActT = player.mCurrentActT - dt

    if 0 >= player.mCurrentActT and player.mIsConfirmed then
        if player.mActionHandler then
            player.mActionHandler:handleActionCompleted( player, global.MMO.ACTION_HXJ )
        end
    end

    -- confirmed timeout
    if player.mCurrentActT <= -5.0 then
        player:SetConfirmed(true)
    end
end
-----------------------------------------------------------------------------
function gameActorStatePlayerHXJ:OnEnter(player)    
    if player.mActionHandler then
        player.mActionHandler:handleActionBegin( player, global.MMO.ACTION_HXJ, player.mOrient, 0 )
    end 

    local clothID       = player:GetAnimationID()
    local SkillPoxy     = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local sex           = player:GetValueByKey( global.MMO.BUFF_PLAYER_AVATAR_SEX ) or player:GetSexID()
    local defaultTime   = SkillPoxy:GetSkillActionTime(global.MMO.ACTION_HXJ, clothID, sex) or global.MMO.DEFAULT_HXJ_TIME
    local attackSpeed   = player:GetMagicSpeed()
    if SkillPoxy:GetSkillActionSpeed(global.MMO.ANIM_HXJ) == 0 then
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
function gameActorStatePlayerHXJ:OnExit(player)    
    -- reset prepare time
    player:SetAnimPrepare(3)

    -- 
    player:SetAnimAct(global.MMO.ANIM_READY)
    player:dirtyAnimFlag()
end
-----------------------------------------------------------------------------
function gameActorStatePlayerHXJ:ChangeState(newState, player, isTerminate)    
    player.mCurrentState = newState   

    return true
end
return gameActorStatePlayerHXJ
-----------------------------------------------------------------------------

