local gameActorState = require( "actor/gameActorState")
local gameActorStatePlayerJY2 = class('gameActorStatePlayerJY2', gameActorState)
function gameActorStatePlayerJY2:ctor()
    gameActorStatePlayerJY2.super.ctor(self)
end

function gameActorStatePlayerJY2:GetStateID()
    return global.MMO.ACTION_JY2
end
-----------------------------------------------------------------------------
function gameActorStatePlayerJY2:Tick(dt, player)  
    player.mCurrentActT = player.mCurrentActT - dt

    if 0 >= player.mCurrentActT and player.mIsConfirmed then
        if player.mActionHandler then
            player.mActionHandler:handleActionCompleted( player, global.MMO.ACTION_JY2 )
        end
    end

    -- confirmed timeout
    if player.mCurrentActT <= -5.0 then
        player:SetConfirmed(true)
    end
end
-----------------------------------------------------------------------------
function gameActorStatePlayerJY2:OnEnter(player)    
    if player.mActionHandler then
        player.mActionHandler:handleActionBegin( player, global.MMO.ACTION_JY2, player.mOrient, 0 )
    end 

    local clothID       = player:GetAnimationID()
    local SkillPoxy     = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local sex           = player:GetValueByKey( global.MMO.BUFF_PLAYER_AVATAR_SEX ) or player:GetSexID()
    local defaultTime   = SkillPoxy:GetSkillActionTime(global.MMO.ACTION_JY2, clothID, sex) or global.MMO.DEFAULT_JY2_TIME
    local attackSpeed   = player:GetMagicSpeed()
    if SkillPoxy:GetSkillActionSpeed(global.MMO.ANIM_JY2) == 0 then
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
function gameActorStatePlayerJY2:OnExit(player)    
    -- reset prepare time
    player:SetAnimPrepare(3)

    -- 
    player:SetAnimAct(global.MMO.ANIM_READY)
    player:dirtyAnimFlag()
end
-----------------------------------------------------------------------------
function gameActorStatePlayerJY2:ChangeState(newState, player, isTerminate)    
    player.mCurrentState = newState   

    return true
end
return gameActorStatePlayerJY2
-----------------------------------------------------------------------------

