local gameActorState = require( "actor/gameActorState")
local gameActorStatePlayerAssassinSmite = class('gameActorStatePlayerAssassinSmite', gameActorState)
function gameActorStatePlayerAssassinSmite:ctor()
    gameActorStatePlayerAssassinSmite.super.ctor(self)
end

function gameActorStatePlayerAssassinSmite:Tick(dt, player)    
    player.mCurrentActT = player.mCurrentActT-dt

    if 0 >= player.mCurrentActT and player.mIsConfirmed then
        if player.mActionHandler then
            player.mActionHandler:handleActionCompleted( player, global.MMO.ACTION_ASSASSIN_SMITE )
        end
    end

    -- confirmed timeout
    if player.mCurrentActT <= -5.0 then
        player:SetConfirmed(true)
    end
end

function gameActorStatePlayerAssassinSmite:OnEnter(player)    
    if player.mActionHandler then
        player.mActionHandler:handleActionBegin( player, global.MMO.ACTION_ASSASSIN_SMITE, player.mOrient, 0 )
    end

    local clothID       = player:GetAnimationID()
    local SkillPoxy     = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local sex           = player:GetValueByKey( global.MMO.BUFF_PLAYER_AVATAR_SEX ) or player:GetSexID()
    local defaultTime   = SkillPoxy:GetSkillActionTime(global.MMO.ACTION_ASSASSIN_SMITE, clothID, sex) or global.MMO.DEFAULT_ASSASSIN_ATTACK_TIME
    local attackSpeed   = player:GetAttackSpeed()
    if SkillPoxy:GetSkillActionSpeed(global.MMO.ANIM_ASSASSIN_SMITE) == 1 then
        attackSpeed = player:GetMagicSpeed()
    end
    local animTime      = defaultTime / attackSpeed
    player.mCurrentActT = animTime
    player.mIsConfirmed  = true

    -- reset some data
    player:SetAnimPrepare( 0.0 )
    player:dirtyAnimFlag()
end

function gameActorStatePlayerAssassinSmite:OnExit(player)    
    -- reset prepare time
    player:SetAnimPrepare(3)

    -- 
    player:SetAnimAct(global.MMO.ANIM_READY)
    player:dirtyAnimFlag()
end

function gameActorStatePlayerAssassinSmite:ChangeState(newState, player, isTerminate)    
    player.mCurrentState = newState

    return true
end

function gameActorStatePlayerAssassinSmite:GetStateID()  
    return global.MMO.ACTION_ASSASSIN_ATTACK
end

return gameActorStatePlayerAssassinSmite