local BuffEntityAnim = require("buff/BuffEntityAnim")
local BuffEntityIce = class("BuffEntityIce", BuffEntityAnim)

function BuffEntityIce:ctor(data)
    BuffEntityIce.super.ctor(self, data)
end

function BuffEntityIce:OnEnter()
    BuffEntityIce.super.OnEnter(self)

    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        self:disable()
        return false
    end

    if not (actor:IsPlayer() or actor:IsMonster()) then
        self:disable()
        return false
    end

    self:IceActor()
end

function BuffEntityIce:OnExit()
    BuffEntityIce.super.OnExit(self)

    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return nil
    end
    
    self:UnIceActor()
end

function BuffEntityIce:IceActor()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return nil
    end

    local function shaderNode(node)
        self:ShaderIce(node)
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

        anim = actor:GetAnimationMonster()
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

function BuffEntityIce:UnIceActor()
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

        anim = actor:GetAnimationMonster()
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

function BuffEntityIce:ShaderIce(node)
    if not node then
        return
    end

    local iceShader = global.MMO.SHADER_TYPE_ICE
    if node.GetBlendMode then
        local blendType = node:GetBlendMode()
        if 4 == blendType then
            iceShader = global.MMO.SHADER_TYPE_ICE_ALPHA_MULTIP
        end
    end

    global.Facade:sendNotification(global.NoticeTable.HighLightNodeShader, node, iceShader)
end

function BuffEntityIce:ShaderNormal(node)
    if not node then
        return
    end

    local p = global.GLProgramCache:getGLProgram("ShaderPositionTextureColor_noMVP")
    node:setGLProgram(p)
end

function BuffEntityIce:UpdatePresent()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return false
    end

    if not (actor:IsPlayer() or actor:IsMonster()) then
        return false
    end

    self:IceActor()
end

return BuffEntityIce