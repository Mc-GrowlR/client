local gameActorState = require( "actor/gameActorState")
local gameActorStatePlayerJY = class('gameActorStatePlayerJY', gameActorState)
function gameActorStatePlayerJY:ctor()
    gameActorStatePlayerJY.super.ctor(self)
end

function gameActorStatePlayerJY:GetStateID()
    return global.MMO.ACTION_JY
end
-----------------------------------------------------------------------------
function gameActorStatePlayerJY:Tick(dt, player)  
    player.mCurrentActT = player.mCurrentActT - dt

    if 0 >= player.mCurrentActT and player.mIsConfirmed then
        if player.mActionHandler then
            player.mActionHandler:handleActionCompleted( player, global.MMO.ACTION_JY )
        end
    end

    -- confirmed timeout
    if player.mCurrentActT <= -5.0 then
        player:SetConfirmed(true)
    end
end
-----------------------------------------------------------------------------
function gameActorStatePlayerJY:OnEnter(player)    
    if player.mActionHandler then
        player.mActionHandler:handleActionBegin( player, global.MMO.ACTION_JY, player.mOrient, 0 )
    end 

    local clothID       = player:GetAnimationID()
    local SkillPoxy     = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local sex           = player:GetValueByKey( global.MMO.BUFF_PLAYER_AVATAR_SEX ) or player:GetSexID()
    local defaultTime   = SkillPoxy:GetSkillActionTime(global.MMO.ACTION_JY, clothID, sex) or global.MMO.DEFAULT_JY_TIME
    local attackSpeed   = player:GetMagicSpeed()
    if SkillPoxy:GetSkillActionSpeed(global.MMO.ANIM_JY) == 0 then
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
function gameActorStatePlayerJY:OnExit(player)    
    -- reset prepare time
    player:SetAnimPrepare(3)

    -- 
    player:SetAnimAct(global.MMO.ANIM_READY)
    player:dirtyAnimFlag()
end
-----------------------------------------------------------------------------
function gameActorStatePlayerJY:ChangeState(newState, player, isTerminate)    
    player.mCurrentState = newState   

    return true
end
return gameActorStatePlayerJY
-----------------------------------------------------------------------------

