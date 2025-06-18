--[[
    author:yzy
    time:2022-04-20 11:16:04
    desc: 怪物石头状态,  就是置灰  设置SetStoneMode   停在动画第一帧
]]
local BuffEntityAnim = require("buff/BuffEntityAnim")
local BuffEntityStoneMode = class("BuffEntityStoneMode", BuffEntityAnim)

function BuffEntityStoneMode:ctor(data)
    BuffEntityStoneMode.super.ctor(self, data)
    self._autoRemove = false                    --强制不自动移除    
end

function BuffEntityStoneMode:OnEnter()
    BuffEntityStoneMode.super.OnEnter(self)

    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        self:disable()
        return false
    end

    if actor:IsMonster() then
        actor:SetStoneMode(true)
        actor:stopAnimToFrame(1)
    else
        self:disable()
        return false
    end

    self:StoneActor()
end

function BuffEntityStoneMode:OnExit()
    BuffEntityStoneMode.super.OnExit(self)

    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return nil
    end

    if actor:IsMonster() then
        actor:SetStoneMode(false)
        actor:stopAnimToFrame(nil)
    end
    
    self:UnStoneActor()
end

function BuffEntityStoneMode:StoneActor()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return nil
    end

    self.isDelayDirty = nil
    local function shaderNode(node)
        self:ShaderStone(node)
    end

    if actor:IsPlayer() then
        local anim = actor:GetAnimation()
        if anim then
            shaderNode(anim)
        end

        anim = actor:GetAnimationWeapon()
        if anim then
            shaderNode(anim)
        end

        anim = actor:GetAnimationShield()
        if anim then
            shaderNode(anim)
        end

        anim = actor:GetAnimationMount()
        if anim then
            shaderNode(anim)
        end

        anim = actor:GetAnimationHair()
        if anim then
            shaderNode(anim)
        end

    elseif actor:IsMonster() then
        local anim = actor:GetAnimation()
        if anim then
            shaderNode(anim)
        end

    elseif actor:IsNPC() then
        local anim = actor:GetAnimation()
        if anim then
            shaderNode(anim)
        end
    end
end

function BuffEntityStoneMode:UnStoneActor()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return nil
    end

    local function shaderNode(node)
        self:ShaderNormal(node)
    end

    if actor:IsPlayer() then
        local anim = actor:GetAnimation()
        if anim then
            shaderNode(anim)
        end

        anim = actor:GetAnimationWeapon()
        if anim then
            shaderNode(anim)
        end

        anim = actor:GetAnimationShield()
        if anim then
            shaderNode(anim)
        end

        anim = actor:GetAnimationMount()
        if anim then
            shaderNode(anim)
        end

        anim = actor:GetAnimationHair()
        if anim then
            shaderNode(anim)
        end

    elseif actor:IsMonster() then
        local anim = actor:GetAnimation()
        if anim then
            shaderNode(anim)
        end
        
    elseif actor:IsNPC() then
        local anim = actor:GetAnimation()
        if anim then
            shaderNode(anim)
        end
    end
end

function BuffEntityStoneMode:ShaderStone(node)
    if not node then
        return
    end
    
    local p = global.GLProgramCache:getGLProgram("ShaderUIGrayScale")
    node:setGLProgram(p)
end

function BuffEntityStoneMode:ShaderNormal(node)
    if not node then
        return
    end

    local p = global.GLProgramCache:getGLProgram("ShaderPositionTextureColor_noMVP")
    node:setGLProgram(p)
end

function BuffEntityStoneMode:UpdatePresent()
    self:StoneActor()
end

return BuffEntityStoneMode