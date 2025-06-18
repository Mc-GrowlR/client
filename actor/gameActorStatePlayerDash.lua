local gameActorState = require( "actor/gameActorState")
local gameActorStatePlayerDash = class('gameActorStatePlayerDash', gameActorState)

local mMin = math.min
local mAbs = math.abs
local mFloor = math.floor
local mRound = math.round

local MOVETO_GHOST_FADEOUT_TIME     = 0.7
local MOVETO_GHOST_INTERVAL         = 0.15

function gameActorStatePlayerDash:ctor()
    gameActorStatePlayerDash.super.ctor(self)
end

function gameActorStatePlayerDash:GetStateID()
    return global.MMO.ACTION_DASH
end

function gameActorStatePlayerDash:Tick(dt, actor)    
    actor._ghostTime = actor._ghostTime - dt
    if actor._ghostTime <= 0.00001 then
        actor._ghostTime     = actor._ghostInterval
        
        local position  = cc.p(actor:getPosition())
        local anchorPos = cc.p(0.5, 0.5)
        local anim      = nil
        local isMonster = true

        -- monster
        anim = actor:GetAnimationMonster()
        if anim then
            anchorPos = anim:GetStandPoint()
            self:ghostSprite(anim:getSpriteFrame(), position, anchorPos, anim)
            isMonster = false
        end

        -- anchor pos is same of weapon/wings
        anim = actor:GetAnimation()
        if isMonster and anim then
            anchorPos = anim:GetStandPoint()
            self:ghostSprite(anim:getSpriteFrame(), position, anchorPos, anim)
            isMonster = false
        end
        
        anim = actor:GetAnimationWeapon()
        if isMonster and anim then
            anchorPos = anim:GetStandPoint()
            self:ghostSprite(anim:getSpriteFrame(), position, anchorPos, anim)
        end
        
        anim = actor:GetAnimationShield()
        if isMonster and anim then
            anchorPos = anim:GetStandPoint()
            self:ghostSprite(anim:getSpriteFrame(), position, anchorPos, anim)
        end
        
        anim = actor:GetAnimationWings()
        if isMonster and anim then
            anchorPos = anim:GetStandPoint()
            self:ghostSprite(anim:getSpriteFrame(), position, anchorPos, anim)
        end

        anim = actor:GetAnimationHair()
        if isMonster and anim then
            anchorPos = anim:GetStandPoint()
            self:ghostSprite(anim:getSpriteFrame(), position, anchorPos, anim)
        end
    end

    actor.mCurrentActT = actor.mCurrentActT - dt
    if not actor.mIsArrived then
        -- Timing...
        if actor.mCurrentActT <= 0.0  then
            actor:SetIsArrived(true)       
        end

        -- displacement
        local percent   = (actor.mMoveTime - actor.mCurrentActT) / actor.mMoveTime
        percent         = mMin(1, percent)
        local disp  = percent * actor.mDistanceToTarget
        local dispV = cc.pAdd( cc.p(actor.originPosition), cc.pMul(actor.mMoveOrient, disp) )

        if global.isWinPlayMode and actor:IsPlayer() and actor:IsMainPlayer() then
            dispV.x = mRound(dispV.x)
            dispV.y = mRound(dispV.y)
        end

        actor:setPosition( dispV.x, dispV.y )
    end

    if actor.mActionHandler then
        if actor.mIsArrived then
            actor.mActionHandler:handleActionCompleted( actor, self:GetStateID() )
        else
            actor.mActionHandler:handleActionProcess( actor, self:GetStateID(), dt )
        end
    end
end

function gameActorStatePlayerDash:OnEnter(actor,param)
    if actor.mActionHandler then 
        actor.mActionHandler:handleActionBegin( actor, self:GetStateID() )
    end
    
    local currPos = cc.p(actor:getPosition())
    local targPos = global.sceneManager:MapPos2WorldPos( actor:GetMapX(), actor:GetMapY(), true )

    actor.mTargePos         = targPos
    actor.mMoveOrient       = cc.pSub(targPos, currPos)
    actor.mDistanceToTarget = cc.pGetLength(actor.mMoveOrient)
    actor.mMoveOrient       = cc.pNormalize(actor.mMoveOrient)

    actor.mMoveTime         = actor.mCurrentActT
    actor.originPosition    = actor:getPosition()
    actor.mIsArrived        = false
    actor._ghostTime        = 0
    actor._ghostInterval    = MOVETO_GHOST_INTERVAL

    -- reset some data
    actor:SetAnimPrepare( 0.0 )
    actor:dirtyAnimFlag()
end

function gameActorStatePlayerDash:OnExit(actor)    
    actor.mCurrentActT = 0
    -- reset some data
    actor:SetAnimPrepare( 0.0 )
    actor:dirtyAnimFlag()
end

function gameActorStatePlayerDash:ChangeState(newState, actor, isTerminate)   
    actor.mCurrentState = newState

    return true
end

function gameActorStatePlayerDash:ghostSprite(frame, pos, anchorPos, anim)
    if not frame then
        return
    end
    
    local ghost = cc.Sprite:createWithSpriteFrame(frame)
    if ghost then
        local behind_sfx_node = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_ACTOR_SFX_FRONT)
        behind_sfx_node:addChild(ghost)
        local offset = anim:GetOffset()
        local pos = cc.pAdd(pos, offset)
        ghost:setPosition(cc.pAdd(pos, global.MMO.PLAYER_AVATAR_OFFSET))
        ghost:setAnchorPoint(anchorPos)
        ghost:setBlendFunc(anim:getBlendFunc())
        
        local function FadeOutEnd()
            ghost:removeFromParent()
        end
        
        local fo = cc.FadeOut:create(MOVETO_GHOST_FADEOUT_TIME)
        local seq = cc.Sequence:create(fo, cc.CallFunc:create(FadeOutEnd))
        
        ghost:runAction(seq)
    end
end

return gameActorStatePlayerDash