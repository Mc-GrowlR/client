local gameActorState = require( "actor/gameActorState")
local gameActorStatePlayerZXC = class('gameActorStatePlayerZXC', gameActorState)

local mRound = math.round

function gameActorStatePlayerZXC:ctor()
    gameActorStatePlayerZXC.super.ctor(self)
end

function gameActorStatePlayerZXC:GetStateID()
    return global.MMO.ACTION_ZXC
end
-----------------------------------------------------------------------------
function gameActorStatePlayerZXC:Tick(dt, player)  
    player.mCurrentActT = player.mCurrentActT - dt
    if not player.mIsArrived then
        -- Timing...
        if player.mCurrentActT <= 0.0  then
            player:SetIsArrived(true)     
        end

        -- displacement
        local percent   = (player.mMoveTime - player.mCurrentActT) / player.mMoveTime
        percent         = math.min(1, percent)
        local disp  = percent * player.mDistanceToTarget
        local dispV = cc.pAdd( cc.p(player.originPosition), cc.pMul(player.mMoveOrient, disp) )

        if global.isWinPlayMode and player:IsPlayer() and player:IsMainPlayer() then
            dispV.x = mRound(dispV.x)
            dispV.y = mRound(dispV.y)
        end

        player:setPosition( dispV.x, dispV.y )
    end

    if player.mActionHandler then
        if player.mIsArrived then
            print("施法动作完成。。。。。。。。。。。。。。。。。。。。")
            player.mActionHandler:handleActionCompleted( player, self:GetStateID() )
        else
            player.mActionHandler:handleActionProcess( player, self:GetStateID(), dt )
        end
    end
end
-----------------------------------------------------------------------------
function gameActorStatePlayerZXC:OnEnter(player)    
    if player.mActionHandler then
        player.mActionHandler:handleActionBegin( player, self:GetStateID() )
    end 
    print("开始施法动作。。。。。。。。。。。。。")
    local clothID       = player:GetAnimationID()
    local SkillPoxy     = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local sex           = player:GetValueByKey( global.MMO.BUFF_PLAYER_AVATAR_SEX ) or player:GetSexID()
    local defaultTime   = SkillPoxy:GetSkillActionTime(global.MMO.ACTION_ZXC, clothID, sex) or global.MMO.DEFAULT_ZXC_TIME
    local attackSpeed   = player:GetAttackSpeed()
    if SkillPoxy:GetSkillActionSpeed(global.MMO.ANIM_ZXC) == 1 then
        attackSpeed = player:GetMagicSpeed()
    end
    local animTime      = defaultTime / attackSpeed
    player.mCurrentActT = animTime

    local currPos = cc.p(player:getPosition())
    local targPos = global.sceneManager:MapPos2WorldPos( player:GetMapX(), player:GetMapY(), true )
    player.mTargePos         = targPos
    player.mMoveOrient       = cc.pSub(targPos, currPos)
    player.mDistanceToTarget = cc.pGetLength(player.mMoveOrient)
    player.mMoveOrient       = cc.pNormalize(player.mMoveOrient)

    player.mMoveTime         = player.mCurrentActT
    player.originPosition    = player:getPosition()
    player.mIsArrived        = false   

    -- reset some data
    player:SetAnimPrepare( 0.0 )
    player:dirtyAnimFlag()
end
-----------------------------------------------------------------------------
function gameActorStatePlayerZXC:OnExit(player)    
    player.mCurrentActT = 0
    -- reset prepare time
    player:SetAnimPrepare( 0.0 )
    player:dirtyAnimFlag()
end
-----------------------------------------------------------------------------
function gameActorStatePlayerZXC:ChangeState(newState, player, isTerminate)    
    player.mCurrentState = newState   

    return true
end
return gameActorStatePlayerZXC
-----------------------------------------------------------------------------

