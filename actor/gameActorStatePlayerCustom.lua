local gameActorState = require( "actor/gameActorState")
local gameActorStatePlayerCustom = class('gameActorStatePlayerCustom', gameActorState)
function gameActorStatePlayerCustom:ctor(actionID, animID)
    self._ACTION_ID = actionID
    self._ANIM_ID = animID

    gameActorStatePlayerCustom.super.ctor(self)
end

function gameActorStatePlayerCustom:GetStateID()
    return self._ACTION_ID
end
-----------------------------------------------------------------------------
function gameActorStatePlayerCustom:Tick(dt, player)  
    player.mCurrentActT = player.mCurrentActT - dt

    if 0 >= player.mCurrentActT and player.mIsConfirmed then
        if player.mActionHandler then
            player.mActionHandler:handleActionCompleted( player, self._ACTION_ID )
        end
    end

    -- confirmed timeout
    if player.mCurrentActT <= -5.0 then
        player:SetConfirmed(true)
    end
end
-----------------------------------------------------------------------------
function gameActorStatePlayerCustom:OnEnter(player)    
    if player.mActionHandler then
        player.mActionHandler:handleActionBegin( player, self._ACTION_ID, player.mOrient, 0 )
    end 

    local clothID       = player:GetAnimationID()
    local SkillPoxy     = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local sex           = player:GetValueByKey( global.MMO.BUFF_PLAYER_AVATAR_SEX ) or player:GetSexID()
    local defaultTime   = SkillPoxy:GetSkillActionTime(self._ACTION_ID, clothID, sex) or global.MMO.DEFAULT_BTXD_TIME
    local actionSpeed   = player:GetAttackSpeed()
    if SkillPoxy:GetSkillActionSpeed(self._ANIM_ID) == 1 then
        actionSpeed = player:GetMagicSpeed()
    end
    local animTime      = defaultTime / actionSpeed
    player.mAnimTime    = animTime
    player.mCurrentActT = animTime
    player:SetConfirmed(true)

    -- reset some data
    player:SetAnimPrepare( 0.0 )
    player:dirtyAnimFlag()
end
-----------------------------------------------------------------------------
function gameActorStatePlayerCustom:OnExit(player)    
    -- reset prepare time
    player:SetAnimPrepare(3)

    -- 
    player:SetAnimAct(global.MMO.ANIM_READY)
    player:dirtyAnimFlag()
end
-----------------------------------------------------------------------------
function gameActorStatePlayerCustom:ChangeState(newState, player, isTerminate)    
    player.mCurrentState = newState   

    return true
end
return gameActorStatePlayerCustom
-----------------------------------------------------------------------------

