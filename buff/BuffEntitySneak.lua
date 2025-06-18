local BuffEntityAnim = require("buff/BuffEntityAnim")
local BuffEntitySneak = class("BuffEntitySneak", BuffEntityAnim)
local optionsUtils = requireProxy("optionsUtils")

function BuffEntitySneak:ctor(data)
    BuffEntitySneak.super.ctor(self, data)
    
    self._isSneak   = false --潜行状态
    self._range     = 2     --范围内显示
end

function BuffEntitySneak:OnEnter()
    BuffEntitySneak.super.OnEnter(self)

    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return false
    end

    actor:SetKeyValue(global.MMO.ACT_SNEAK, true)

    local isSneak = self:CheckSneak()
    if self._isSneak ~= isSneak then
        self._isSneak = isSneak
        if isSneak then
            self:SneakActor()
        else
            self:UnSneakActor()
        end
    end

   global.BuffManager:AddHandleOnMainActBegin(self._actorID, handler(self, self.OnMainPlayerHandle))
end

function BuffEntitySneak:OnExit()
    BuffEntitySneak.super.OnExit(self)

    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return false
    end

    actor:SetKeyValue(global.MMO.ACT_SNEAK, false)

    self:UnSneakActor()

    global.BuffManager:RemoveHandleOnMainActBegin(self._actorID)
end

function BuffEntitySneak:CheckSneak()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return false
    end

    if actor:IsPlayer() and actor:IsMainPlayer() then
        return false
    end

    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return false
    end

    local mainPlayerPos = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    local actorPos      = cc.p(actor:GetMapX(), actor:GetMapY())
    if cc.pGetDistance(actorPos, mainPlayerPos) > self._range then
        return true
    end
    return false
end

function BuffEntitySneak:OnMainPlayerHandle(actor, act)
    local isSneak = self:CheckSneak()
    if self._isSneak ~= isSneak then
        self._isSneak = isSneak
        if isSneak then
            self:SneakActor()
        else
            self:UnSneakActor()
        end
    end
end

function BuffEntitySneak:SneakActor()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return false
    end

    if not actor:IsPlayer() then
        return false
    end

    -- 判断目标是否是潜行者，如果是，就清理目标
    local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    if PlayerInputProxy:GetTargetID() == self._actorID then
        PlayerInputProxy:ClearTarget()
    end

    actor:SetKeyValue(global.MMO.HUD_SNEAK, true)
    actor:GetNode():setVisible(false)
    
    -- Hp、Mp
    optionsUtils:refreshHUDHMpLabelVisible(actor)
    -- 血条
    optionsUtils:CheckHUDHpBarVisible(actor)
    -- 蓝条
    optionsUtils:CheckHUDMpBarVisible(actor)
    -- 内功条
    optionsUtils:CheckHUDNGBarVisible(actor)
    -- 人名、行会、称号、顶戴
    optionsUtils:refreshLabelVisible(actor)

    optionsUtils:refreshPlayerVisible(actor)
    optionsUtils:refreshPlayerBVisible(actor)

    -- 身上的特效
    global.ActorEffectManager:RefreshActorEffectVisible(self._actorID, false)

    -- 身上的buff特效
    global.BuffManager:UpdateBuffItemVisible(self._actorID, false)

    -- 刷新附近
    global.Facade:sendNotification(global.NoticeTable.Layer_MainNear_Refresh, {actor = actor, actorID = self._actorID})

    -- 刷新灯光
    local lightID = actor:GetLightID()
    if lightID and not actor:IsMainPlayer() then
        local lightData = global.darkNodeManager:getNodeByLightID(lightID)
        if lightData then
            local DarkLayerProxy = global.Facade:retrieveProxy(global.ProxyTable.DarkLayerProxy)
            local darkSneak      = DarkLayerProxy.LIGHT_TYPE.Sneak
            global.darkNodeManager:updateNode(lightID, {r = darkSneak.r, w = darkSneak.w, isLast = true})
        end
    end
end

function BuffEntitySneak:UnSneakActor()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor then
        return false
    end

    if not actor:IsPlayer() then
        return false
    end

    actor:SetKeyValue(global.MMO.HUD_SNEAK, false)
    actor:GetNode():setVisible(true)
    actor:dirtyAnimFlag()

    -- 清理选中目标
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    if inputProxy:GetTargetID() == self._actorID then
        inputProxy:ClearTarget()
    end

    -- Hp、Mp
    optionsUtils:refreshHUDHMpLabelVisible(actor)
    -- 血条
    optionsUtils:CheckHUDHpBarVisible(actor)
    -- 蓝条
    optionsUtils:CheckHUDMpBarVisible(actor)
    -- 内功条
    optionsUtils:CheckHUDNGBarVisible(actor)
    -- 人名、行会、称号、顶戴
    optionsUtils:refreshLabelVisible(actor)

    optionsUtils:refreshPlayerVisible(actor)
    optionsUtils:refreshPlayerBVisible(actor)

    -- 身上的特效
    global.ActorEffectManager:RefreshActorEffectVisible(self._actorID, true)

    -- 身上的buff特效
    global.BuffManager:UpdateBuffItemVisible(self._actorID, true)

    -- 刷新附近
    global.Facade:sendNotification(global.NoticeTable.Layer_MainNear_Refresh, {actor = actor, actorID = self._actorID})

    local lightID = actor:GetLightID()
    if lightID and not actor:IsMainPlayer() then
        local lightData = global.darkNodeManager:getNodeByLightID(lightID)
        if lightData then
            global.darkNodeManager:updateNode(lightID, {r = lightData.last_r, w = lightData.last_w})
        end
    end
end

function BuffEntitySneak:setPosition(x, y)
    BuffEntitySneak.super.setPosition(self, x, y)

    local isSneak = self:CheckSneak()
    if self._isSneak ~= isSneak then
        self._isSneak = isSneak
        if isSneak then
            self:SneakActor()
        else
            self:UnSneakActor()
        end
    end
end

return BuffEntitySneak