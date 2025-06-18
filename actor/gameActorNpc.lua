local gameActorMoveable = require( "actor/gameActorMoveable")
local gameActorNpc      = class('gameActorNpc', gameActorMoveable)

local mmo = global.MMO
local mapActAnim = {
    [mmo.ACTION_IDLE] = mmo.ANIM_IDLE,
    [mmo.ACTION_BORN] = mmo.ANIM_BORN,
}

local fixAnimDirection = {
    [59]      = 0,
}

function gameActorNpc:ctor()
    gameActorNpc.super.ctor(self)
end

function gameActorNpc:init()
    gameActorNpc.super.init(self)

    self.mClothID            = nil
    self.mFeatureDirty       = false
    self.mUseMonsterAnim     = nil
    self.mAnimAct            = global.MMO.ANIM_IDLE
    self.mIsAnimNeedToUpdate = false
    self.mStopAnimFrameIndex = nil
    self.mBubbleName         = nil
end

function gameActorNpc:destory()
    gameActorNpc.super.destory(self)

    -- remove hud
    global.HUDManager:RemoveActorAllHUD( self.mID )
end

function gameActorNpc:Tick(dt)
    if self.mFeatureDirty then
        self.mFeatureDirty = false
        self:checkFeature()
    end

    if self.mIsAnimNeedToUpdate then
        self:updateAnimation()
        self.mIsAnimNeedToUpdate = false
    end
end

function gameActorNpc:setPosition(x, y)
    gameActorNpc.super.setPosition(self, x, y)

    -- refresh zOrder
    self:GetNode():setLocalZOrder( math.floor(-y) )

    -- update hud pos
    local hudTop = self:GetHUDTop()
    global.HUDManager:setPosition( self.mID, x, y + hudTop )

    -- update buff pos
    global.BuffManager:setPosition(self:GetID(), x, y)
    global.ActorEffectManager:setPosition(self:GetID(), x, y)
end

function gameActorNpc:SetAction(newAction, isTerminate)
    local actAnim = mapActAnim[newAction] or global.MMO.ANIM_IDLE
    self:SetAnimAct( actAnim )
    self:dirtyAnimFlag()
end

function gameActorNpc:SetAnimAct(newAnim)
    if self.mAnimAct ~= newAnim then
        self.mAnimAct = newAnim

        -- in die anim, zOrder is lowest
        if newAnim == global.MMO.ANIM_DIE then
            self:GetNode():setLocalZOrder( -self:GetNode():getPositionY() + self:GetAdditionZorder() + global.MMO.DieAddZorder )
        end

        self:dirtyAnimFlag()
    end
end

function gameActorNpc:SetDirection( dir )
    gameActorNpc.super.SetDirection(self, dir)
end

function gameActorNpc:onSequAnimLoadCompleted(npcID, animID, seqAnim)
    -- There is a strange bug that *this* pointer will be invalid in sometime.
    local _this = global.actorManager:GetActor( npcID ) 
    if nil == _this then
        return 
    end

    -- Refresh npc name label hud top
    local pos = _this:getPosition()
    local hudTop = _this:GetHUDTop()
    global.HUDManager:setPosition( _this.mID, pos.x, pos.y + hudTop )
end

function gameActorNpc:InitParam( param )
    self.mCurrActorNode = cc.Node:create()

    self.mCurrMountNode = cc.Node:create()
    self.mCurrActorNode:addChild(self.mCurrMountNode)
    self.mCurrMountNode:setTag(mmo.NPC_MOUNT_TAG)
    self.mCurrMountNode:setPosition(mmo.PLAYER_AVATAR_OFFSET)

    return 1
end


function gameActorNpc:SetClothID(clothID)
    self.mClothID = clothID
    self.mUseMonsterAnim = false

    if clothID and clothID > global.MMO.NPC_MONSTER_ID_PART then
        clothID = clothID % global.MMO.NPC_MONSTER_ID_PART
        self.mClothID = clothID
        self.mUseMonsterAnim = true
    end
end

function gameActorNpc:dirtyFeature()
    self.mFeatureDirty = true
end

function gameActorNpc:checkFeature()
    self:updateCloth()
end

function gameActorNpc:updateCloth()
    local function loadCompleted(animID, seqAnim)
        self:onSequAnimLoadCompleted(self:GetID(), animID, seqAnim)
    end

    local anim = nil
    if not self.mUseMonsterAnim then
        anim = global.FrameAnimManager:CreateActorNpcAnim( self.mClothID, loadCompleted )
    else
        anim = global.FrameAnimManager:CreateActorMonsterAnim( self.mClothID, self.mAnimAct, loadCompleted )
    end

    if self.mAnimation then
        self.mAnimation:removeFromParent()
        self.mAnimation = nil
    end

    self.mAnimation = anim
    self.mAnimation:setPosition( global.MMO.PLAYER_AVATAR_OFFSET )
    self.mCurrActorNode:addChild( anim )

    -- Refresh npc name label hud top
    local pos = self:getPosition()
    global.HUDManager:setPosition( self:GetID(), pos.x, pos.y + self:GetHUDTop() )

    self:dirtyAnimFlag()
end

function gameActorNpc:updateAnimation()
    local animDir = self:getFixAnimDir() or self.mOrient

    if self.mAnimation then
        self.mAnimation:Play( self.mAnimAct, animDir, true )
    end

    if self.mStopAnimFrameIndex then
        self:StopAllAnimation( self.mStopAnimFrameIndex )
    end
end

function gameActorNpc:getFixAnimDir()
    if fixAnimDirection[self.mClothID] then
        if type(fixAnimDirection[self.mClothID]) == "table" then
            return fixAnimDirection[self.mClothID][self.mAnimAct]
        else
            return fixAnimDirection[self.mClothID]
        end
    end
    return nil
end

function gameActorNpc:dirtyAnimFlag()
    if self.mStopAnimFrameIndex then
        return
    end

    self.mIsAnimNeedToUpdate = true
end

function gameActorNpc:stopAnimToFrame( frameIndex )
    self.mStopAnimFrameIndex = frameIndex
end

function gameActorNpc:StopAllAnimation( frameIndex )
    local animDir = self:getFixAnimDir() or self.mOrient
    if self.mAnimation then
        self.mAnimation:Stop( frameIndex, self.mAnimAct, animDir )
    end
end

function gameActorNpc:GetType()
    return global.MMO.ACTOR_NPC
end

function gameActorNpc:GetAnimationID()
    return self.mClothID
end

function gameActorNpc:GetHUDTop()
    if not self.mAnimation then
        return 20
    end
    return self.mAnimation:GetHUDTop() or 20
end

function gameActorNpc:GetBubbleName()
    return self.mBubbleName
end

function gameActorNpc:SetBubbleName( value )
    self.mBubbleName = value
end

return gameActorNpc
