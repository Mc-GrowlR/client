local gameActor = require("actor/gameActor")
local gameActorEffect = class('gameActorEffect', gameActor)

function gameActorEffect:ctor()
    gameActorEffect.super.ctor(self)
end

function gameActorEffect:init()
    gameActorEffect.super.init(self)

    self.mClothID           = nil
    self.mIsLoop            = true
    self.mEffectType        = 0
    self.stopFrameIndex     = 0
    self.mFeatureDirty      = false
    self.mDuranceID         = nil    
end

function gameActorEffect:destory()
    gameActorEffect.super.destory(self)
end

function gameActorEffect:Tick(dt)
    if self.mFeatureDirty then
        self.mFeatureDirty = false
        self:checkFeature()
    end
end

function gameActorEffect:setPosition(x, y)
    local offset = global.MMO.EFFECT_AVATAR_OFFSET
    x = x + offset.x
    y = y + offset.y
    gameActorEffect.super.setPosition(self, x, y)

    -- refresh zOrder
    self:GetNode():setLocalZOrder(math.floor(-y))
end

function gameActorEffect:setRotation(angle)
    self:GetNode():setRotation(angle)
end

function gameActorEffect:SetAction(newAction, isTerminate)
    self:updateAnimation()
end

function gameActorEffect:GetAnimationID()
    if self.mAnimation then
        return self.mAnimation:GetID()
    else
        return -1
    end
end

function gameActorEffect:InitParam(param)
    self.mCurrActorNode = cc.Node:create()

    self.mClothID       = param.sfxId
    self.mIsLoop        = param.isLoop
    self.mEffectType    = param.type
    self.stopFrameIndex = param.param
    self.mDuranceID     = param.DuranceID

    return 1
end

function gameActorEffect:dirtyFeature()
    self.mFeatureDirty = true
end

function gameActorEffect:checkFeature()
    if (self.mAnimation) then
        self.mAnimation:removeFromParent()
        self.mAnimation = nil
    end

    self.mAnimation = global.FrameAnimManager:CreateSFXAnim(self.mClothID)
    self.mAnimation:SetGlobalElapseEnable(self.mEffectType ~= global.MMO.EFFECT_TYPE_SFX and self.mIsLoop == true)
    self.mCurrActorNode:addChild(self.mAnimation)

    self:updateAnimation()
end

function gameActorEffect:updateAnimation()
    if self.mAnimation then
        self.mAnimation:Play(0, 0, self.mIsLoop)

        if self.stopFrameIndex and self.stopFrameIndex > 0 then
            self.mAnimation:Stop(self.stopFrameIndex, 0, 0)
        end
    end
end

function gameActorEffect:GetType()
    return global.MMO.ACTOR_SEFFECT
end

function gameActorEffect:GetAnimation()
    return self.mAnimation
end

function gameActorEffect:GetEffectType()
    return self.mEffectType
end

function gameActorEffect:GetDuranceID()
    return self.mDuranceID
end

return gameActorEffect