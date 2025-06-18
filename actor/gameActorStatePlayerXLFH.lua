local gameActorState = require( "actor/gameActorState")
local gameActorStatePlayerXLFH = class('gameActorStatePlayerXLFH', gameActorState)
function gameActorStatePlayerXLFH:ctor()
    gameActorStatePlayerXLFH.super.ctor(self)
end

function gameActorStatePlayerXLFH:GetStateID()
    return global.MMO.ACTION_XLFH
end
-----------------------------------------------------------------------------
function gameActorStatePlayerXLFH:Tick(dt, player)  
    player.mCurrentActT = player.mCurrentActT - dt

    if 0 >= player.mCurrentActT and player.mIsConfirmed then
        if player.mActionHandler then
            player.mActionHandler:handleActionCompleted( player, global.MMO.ACTION_XLFH )
        end
    end

    -- confirmed timeout
    if player.mCurrentActT <= -5.0 then
        player:SetConfirmed(true)
    end
end
-----------------------------------------------------------------------------
function gameActorStatePlayerXLFH:OnEnter(player)    
    if player.mActionHandler then
        player.mActionHandler:handleActionBegin( player, global.MMO.ACTION_XLFH, player.mOrient, 0 )
    end 

    local clothID       = player:GetAnimationID()
    local SkillPoxy     = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local sex           = player:GetValueByKey( global.MMO.BUFF_PLAYER_AVATAR_SEX ) or player:GetSexID()
    local defaultTime   = SkillPoxy:GetSkillActionTime(global.MMO.ACTION_XLFH, clothID, sex) or global.MMO.DEFAULT_XLFH_TIME
    local attackSpeed   = player:GetAttackSpeed()
    if SkillPoxy:GetSkillActionSpeed(global.MMO.ANIM_XLFH) == 1 then
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
function gameActorStatePlayerXLFH:OnExit(player)    
    -- reset prepare time
    player:SetAnimPrepare(3)

    -- 
    player:SetAnimAct(global.MMO.ANIM_READY)
    player:dirtyAnimFlag()
end
-----------------------------------------------------------------------------
function gameActorStatePlayerXLFH:ChangeState(newState, player, isTerminate)    
    player.mCurrentState = newState   

    return true
end
return gameActorStatePlayerXLFH
-----------------------------------------------------------------------------

