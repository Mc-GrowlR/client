local BuffEntityAnim = require("buff/BuffEntityAnim")
local BuffEntityFreezed = class("BuffEntityFreezed", BuffEntityAnim)

function BuffEntityFreezed:ctor(data)
    BuffEntityFreezed.super.ctor(self, data)
end

function BuffEntityFreezed:OnEnter()
    BuffEntityFreezed.super.OnEnter(self)

    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        self:disable()
        return false
    end

    if not (actor:IsPlayer() or actor:IsMonster()) then
        self:disable()
        return false
    end

    self:FreezeActor()
end

function BuffEntityFreezed:OnExit()
    BuffEntityFreezed.super.OnExit(self)

    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return nil
    end

    self:UnfreezeActor()
end

function BuffEntityFreezed:FreezeActor()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return nil
    end

    local function freeze(node)
        if self._buffID == global.MMO.BUFF_ID_FREEZED_GRAY then
            self:ShaderGray(node)
        end
    end

    if actor:IsPlayer() then
        local anim = actor:GetAnimation()
        if anim then
            freeze(anim)
        end

        anim = actor:GetAnimationWeapon()
        if anim then
            freeze(anim)
        end

        anim = actor:GetAnimationShield()
        if anim then
            freeze(anim)
        end

        anim = actor:GetAnimationWings()
        if anim then
            freeze(anim)
        end

        anim = actor:GetAnimationMount()
        if anim then
            freeze(anim)
        end

        anim = actor:GetAnimationHair()
        if anim then
            freeze(anim)
        end

        anim = actor:GetAnimationMonster()
        if anim then
            freeze(anim)
        end

    elseif actor:IsMonster() then
        local anim = actor:GetAnimation()
        if anim then
            freeze(anim)
        end
    end
end

function BuffEntityFreezed:UnfreezeActor()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return nil
    end

    local function unfreeze(node)
        self:ShaderNormal(node)
    end

    if actor:IsPlayer() then
        local anim = actor:GetAnimation()
        if anim then
            unfreeze(anim)
        end

        anim = actor:GetAnimationWeapon()
        if anim then
            unfreeze(anim)
        end

        anim = actor:GetAnimationShield()
        if anim then
            unfreeze(anim)
        end

        anim = actor:GetAnimationWings()
        if anim then
            unfreeze(anim)
        end

        anim = actor:GetAnimationMount()
        if anim then
            unfreeze(anim)
        end

        anim = actor:GetAnimationHair()
        if anim then
            unfreeze(anim)
        end

        anim = actor:GetAnimationMonster()
        if anim then
            unfreeze(anim)
        end

    elseif actor:IsMonster() then
        local anim = actor:GetAnimation()
        if anim then
            unfreeze(anim)
        end
    end
end

function BuffEntityFreezed:PauseActor()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return nil
    end

    local function pause(node)
        local AMgr = global.Director:getActionManager()
        AMgr:pauseTarget(node)
    end

    if actor:IsPlayer() then
        local anim = actor:GetAnimation()
        if anim then
            pause(anim)
        end

        anim = actor:GetAnimationWeapon()
        if anim then
            pause(anim)
        end

        anim = actor:GetAnimationShield()
        if anim then
            pause(anim)
        end

        anim = actor:GetAnimationWings()
        if anim then
            pause(anim)
        end

        anim = actor:GetAnimationMount()
        if anim then
            pause(anim)
        end

        anim = actor:GetAnimationHair()
        if anim then
            pause(anim)
        end

        anim = actor:GetAnimationMonster()
        if anim then
            pause(anim)
        end

    elseif actor:IsMonster() then
        local anim = actor:GetAnimation()
        if anim then
            pause(anim)
        end
    end
end

function BuffEntityFreezed:ResumeActor()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return nil
    end

    local function resume(node)
        local AMgr = global.Director:getActionManager()
        AMgr:resumeTarget(node)
    end

    if actor:IsPlayer() then
        local anim = actor:GetAnimation()
        if anim then
            resume(anim)
        end

        anim = actor:GetAnimationWeapon()
        if anim then
            resume(anim)
        end

        anim = actor:GetAnimationShield()
        if anim then
            resume(anim)
        end

        anim = actor:GetAnimationWings()
        if anim then
            resume(anim)
        end

        anim = actor:GetAnimationMount()
        if anim then
            resume(anim)
        end

        anim = actor:GetAnimationHair()
        if anim then
            resume(anim)
        end

        anim = actor:GetAnimationMonster()
        if anim then
            resume(anim)
        end

    elseif actor:IsMonster() then
        local anim = actor:GetAnimation()
        if anim then
            resume(anim)
        end
    end
end

function BuffEntityFreezed:ShaderGray(node)
    if not node then
        return
    end

    local p = global.GLProgramCache:getGLProgram("ShaderUIGrayScale")
    node:setGLProgram(p)
end

function BuffEntityFreezed:ShaderGold(node)
    if not node then
        return
    end

    global.Facade:sendNotification(global.NoticeTable.HighLightNodeShader, node, global.MMO.SHADER_TYPE_GOLDEN)
end

function BuffEntityFreezed:ShaderNormal(node)
    if not node then
        return
    end

    local p = global.GLProgramCache:getGLProgram("ShaderPositionTextureColor_noMVP")
    node:setGLProgram(p)
end

function BuffEntityFreezed:IsAllowAnimUpdate()
    return true
end

function BuffEntityFreezed:UpdatePresent()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return false
    end

    if not (actor:IsPlayer() or actor:IsMonster()) then
        return false
    end

    self:FreezeActor()
end

return BuffEntityFreezed
