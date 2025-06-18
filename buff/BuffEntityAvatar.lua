local BuffEntityAnim = require("buff/BuffEntityAnim")
local BuffEntityAvatar = class("BuffEntityAvatar",BuffEntityAnim)

function BuffEntityAvatar:ctor(data)
    BuffEntityAvatar.super.ctor(self,data)

    local BuffProxy     = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    self._cfgColor      = BuffProxy:GetBuffColorByID( self._buffID )
    self._cfgSacle      = BuffProxy:GetBuffScaleByID( self._buffID )
    self._cfgAvatar     = BuffProxy:GetBuffAvatarByID( self._buffID )
    self._avatarScales  = {}
end

function BuffEntityAvatar:OnEnter()
    BuffEntityAvatar.super.OnEnter(self)
    self:FeatureActor()
end

function BuffEntityAvatar:OnExit()
    BuffEntityAvatar.super.OnExit(self)
    self:UnFeatureActor()
end

function BuffEntityAvatar:updatePosition()
    BuffEntityAvatar.super.updatePosition(self)
end

function BuffEntityAvatar:FeatureActor()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return
    end

    if self._cfgAvatar then
        if actor:IsMonster() and self._cfgAvatar.avatarType == 1 and self._cfgAvatar.avatarID then
            self._originClothID = actor:GetAnimationID()
            actor:SetClothID(self._cfgAvatar.avatarID)
            actor:dirtyFeature()
        elseif actor:IsPlayer() and not actor:GetHorseMasterID() and not actor:IsHoreseCopilot() then
            if global.BuffManager:CheckRmvBuffAvatar(actor:GetID(), self._cfgAvatar) then
                actor:SetMonsterFeatureID(0)
                actor:updateMonster(0)
            end
            actor:SetMonsterFeatureID( self._cfgAvatar.avatarID )
            actor:dirtyFeature()
        end
    end

    self._cfgColor = global.BuffManager:CheckBuffColor(self._actorID, self._buffID)
    self._cfgSacle = global.BuffManager:CheckBuffScale(self._actorID, self._buffID)
    self:OnRefreshFeature( self._cfgColor, self._cfgSacle )
end

function BuffEntityAvatar:UnFeatureActor()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return
    end

    local cfgAvatar = global.BuffManager:CheckBuffAvatar(self._actorID,self._buffID)
    if actor:IsMonster() then
        if cfgAvatar and cfgAvatar.avatarType == 1 and cfgAvatar.avatarID then
            actor:SetClothID(cfgAvatar.avatarID)
            actor:dirtyFeature()
        elseif self._originClothID then
            actor:SetClothID(self._originClothID)
            actor:dirtyFeature()
            self._originClothID = nil
        end
    elseif actor:IsPlayer() and not actor:GetHorseMasterID() and not actor:IsHoreseCopilot() then
        local id = cfgAvatar and cfgAvatar.avatarID
        if global.BuffManager:CheckRmvBuffAvatar(actor:GetID(), cfgAvatar) or not id then
            actor:SetMonsterFeatureID(0)
            actor:updateMonster(0)
        end
        if id and id > 0 then
            actor:SetMonsterFeatureID( id )
            actor:dirtyFeature()
        end
    end

    
    self._avatarScales = {}
    self._cfgColor = global.BuffManager:CheckBuffColor(self._actorID, self._buffID)
    self._cfgSacle = global.BuffManager:CheckBuffScale(self._actorID, self._buffID)
    self:OnRefreshFeature( self._cfgColor, self._cfgSacle, true )
end


function BuffEntityAvatar:OnRefreshFeature( color, scale, isUnFeat )
    if not color and not scale then
        return
    end

    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return
    end

    if actor:IsPlayer() and (actor:GetHorseMasterID() or actor:IsHoreseCopilot()) then
        scale = 1
    end

    local function featureColor( anim )
        if not color then
            return
        end
        local p = global.GLProgramCache:getGLProgram("ShaderPositionTextureColor_noMVP")
        anim:setGLProgram(p)
        anim:setColor( color )
    end

    local function featureScale( anim )
        if not scale then
            return
        end

        local animID  = anim:GetID()
        local enlarge = anim:GetEnlarge()
        local avatarScale  = enlarge * scale

        if self._avatarScales[animID] == avatarScale then
            return
        end

        local aScale  = anim:getScale()

        self._avatarScales[animID] = avatarScale
        anim:setScale( avatarScale )
        local avatarOffset = global.MMO.PLAYER_AVATAR_OFFSET
        local offx = (scale * enlarge - aScale) * avatarOffset.x
        local offy = (scale * enlarge - aScale) * avatarOffset.y
        local x,y  = anim:getPosition()
        anim:setPosition(x+offx, y+offy)
    end

    local function featureShader( anim )

        featureColor( anim )
        featureScale( anim )

    end

    local anim = actor:GetAnimation()
    if anim then
        featureShader(anim)
    end

    if actor.GetAnimationShield then
        anim = actor:GetAnimationShield()
        if anim then
            featureShader(anim)
        end
    end

    if actor.GetAnimationWings then
        anim = actor:GetAnimationWings()
        if anim then
            featureShader(anim)
        end
    end

    if actor.GetAnimationMount then
        anim = actor:GetAnimationMount()
        if anim then
            featureShader(anim)
        end
    end

    if actor.GetAnimationHair then
        anim = actor:GetAnimationHair()
        if anim then
            featureShader(anim)
        end
    end

    if actor.GetAnimationWeapon then
        anim = actor:GetAnimationWeapon()
        if anim then
            featureShader(anim)
        end
    end

    if actor.GetAnimationMonster then
        anim = actor:GetAnimationMonster()
        if anim then
            featureShader(anim)
        end
    end
end

function BuffEntityAvatar:UpdatePresent()
    self:OnRefreshFeature( self._cfgColor, self._cfgSacle )
end

return BuffEntityAvatar