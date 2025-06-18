local BuffEntityAnim = require("buff/BuffEntityAnim")
local BuffEntityHorse = class("BuffEntitySneak", BuffEntityAnim)
local optionsUtils = requireProxy("optionsUtils")

function BuffEntityHorse:ctor(data)
    BuffEntityHorse.super.ctor(self,data)

    self._feature            = data.param and data.param.feature 
    self._bindMainHorseActor = nil

    self._isExit = data.param and data.param.isExit

end

function BuffEntityHorse:Tick(dt)
    BuffEntityHorse.super.Tick(self, dt)

    if self:IsInvalid() then
        return false
    end
    
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if mainPlayer and self._bindMainHorseActor then
        local mainPosXY         = mainPlayer:getPosition()
        local bindHorsePosXY    = self._bindMainHorseActor:getPosition()
        if mainPosXY.x ~= bindHorsePosXY.x or mainPosXY.y ~= bindHorsePosXY.y then
            mainPlayer:setPosition(bindHorsePosXY.x, bindHorsePosXY.y)
        end
        if mainPlayer:GetMapX() ~= self._bindMainHorseActor:GetMapX() or mainPlayer:GetMapY() ~= self._bindMainHorseActor:GetMapY() then
            global.actorManager:SetActorMapXY( mainPlayer, self._bindMainHorseActor:GetMapX(), self._bindMainHorseActor:GetMapY() )
            global.Facade:sendNotification(global.NoticeTable.SceneFollowMainPlayer)
        end
    end
end

function BuffEntityHorse:UpdateParam(data)
    if not data then
        data = {}
    end
    if data.isExit then
        self._feature = {}
        self:disable()
        return
    end
    self._feature = data.feature
    BuffEntityHorse.super.UpdateParam(self, data.param or data)

    local actor = global.actorManager:GetActor(self._actorID)
    if actor then
        self:HorseActor()
    end
end

function BuffEntityHorse:OnEnter()
    BuffEntityHorse.super.OnEnter(self)

    if self._isExit then
        self._feature = {}
        self:disable()
        return
    end
    
    self:HorseActor()

    -- 通知上马
    SLBridge:onLUAEvent(LUA_EVENT_HORSE_UP, {actorID = self._actorID})
end

function BuffEntityHorse:HorseActor()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor or not actor:IsPlayer() then
        return false
    end

    if actor:GetID() == actor:GetValueByKey(global.MMO.HORSE_MAIN) then
        self:MainHorseActor( actor )
    elseif actor:GetID() == actor:GetValueByKey(global.MMO.HORSE_COPILOT) then
        self:CopilotHorseActor( actor )
    end
end

function BuffEntityHorse:UpdateFeature( actor,feature )
    if not actor then
        return false
    end

    if not feature then
        feature = {}
    end
    
    local actorAttr = GetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE)
    actorAttr.mountID        = feature.mountID
    actorAttr.mountEff       = feature.mountEff
    actorAttr.mountCloth     = feature.mountCloth
    actorAttr.hairID         = feature.hairID

    -- 如果是双人马
    if actor:GetValueByKey(global.MMO.HORSE_COPILOT) then
        actorAttr.mountID = actorAttr.mountID > 0 and (actorAttr.mountID + actor:GetSexID() + 1) or actorAttr.mountID
        actorAttr.mountEff = actorAttr.mountEff > 0 and (actorAttr.mountEff + actor:GetSexID() + 1) or actorAttr.mountEff
        actorAttr.mountCloth = actorAttr.mountCloth > 0 and (actorAttr.mountCloth + actor:GetSexID() + 1) or actorAttr.mountCloth
    elseif feature.isDown then --如果是下马
        actorAttr.mountID = actorAttr.mountID > 0 and (actorAttr.mountID - actor:GetSexID() - 1) or actorAttr.mountID
        actorAttr.mountEff = actorAttr.mountEff > 0 and (actorAttr.mountEff - actor:GetSexID() - 1) or actorAttr.mountEff
        actorAttr.mountCloth = actorAttr.mountCloth > 0 and (actorAttr.mountCloth - actor:GetSexID() - 1) or actorAttr.mountCloth
    end

    SetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE, actorAttr)
    global.Facade:sendNotification( global.NoticeTable.DelayActorFeatureChange, actorAttr )
end

-- 主驾
function BuffEntityHorse:MainHorseActor( actor )
    actor:GetNode():setVisible(true)

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

    optionsUtils:refreshLabelName(actor)

    -- 身上的特效
    global.ActorEffectManager:RefreshActorEffectVisible(self._actorID, true)

    -- 身上的buff特效
    global.BuffManager:UpdateBuffItemVisible(self._actorID, true)

    -- 颜色
    global.Facade:sendNotification(global.NoticeTable.DelayRefreshHUDLabel, {actor = actor, actorID = actor:GetID()})

    -- 调整hud位置
    global.HUDManager:SetHorseOffset(actor:GetID(), global.MMO.HUD_OFFSET_HORSE)
    global.HUDManager:SetHorseOffsetLabel(actor:GetID(), global.MMO.HUD_OFFSET_HORSE_LABEL)
    local hudTop = actor:GetHUDTop()
    local actorpos = actor:getPosition()
    global.HUDManager:setPosition(actor:GetID(), actorpos.x, actorpos.y + hudTop)

    self:UpdateFeature(actor, self._feature)
end

-- 副驾
function BuffEntityHorse:CopilotHorseActor( actor )
    
    if actor:IsMainPlayer() then
        local mainHorseID = actor:GetValueByKey(global.MMO.HORSE_MAIN)
        if mainHorseID then
            self._bindMainHorseActor = global.actorManager:GetActor(mainHorseID)
        end
    end

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

    optionsUtils:refreshLabelName(actor)

    -- 身上的特效
    global.ActorEffectManager:RefreshActorEffectVisible(self._actorID, false)

    -- 身上的buff特效
    global.BuffManager:UpdateBuffItemVisible(self._actorID, false)

    -- 颜色
    global.Facade:sendNotification(global.NoticeTable.DelayRefreshHUDLabel, {actor = actor, actorID = actor:GetID()})
end

function BuffEntityHorse:UnHorseActor()
    local actor = global.actorManager:GetActor(self._actorID)
    if not actor or not actor:IsPlayer() then
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        if self._actorID ~= mainPlayer:GetValueByKey(global.MMO.HORSE_MAIN) then
            return false
        end
        actor = mainPlayer
        self._actorID = mainPlayer:GetID()
    end

    actor:GetNode():setVisible(true)
    actor:dirtyAnimFlag()

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

    optionsUtils:refreshLabelName(actor)

    -- 身上的特效
    global.ActorEffectManager:RefreshActorEffectVisible(self._actorID, true)

    -- 身上的buff特效
    global.BuffManager:UpdateBuffItemVisible(self._actorID, true)

    -- 颜色
    global.Facade:sendNotification(global.NoticeTable.DelayRefreshHUDLabel, {actor = actor, actorID = actor:GetID()})

    -- 调整hud位置
    global.HUDManager:SetHorseOffset(actor:GetID())
    global.HUDManager:SetHorseOffsetLabel(actor:GetID())
    local hudTop = actor:GetHUDTop()
    local actorpos = actor:getPosition()
    global.HUDManager:setPosition(actor:GetID(), actorpos.x, actorpos.y + hudTop)

    self:UpdateFeature(actor, self._feature)
end

function BuffEntityHorse:OnExit()
    BuffEntityHorse.super.OnExit(self)

    self:UnHorseActor()

    -- 通知下马
    SLBridge:onLUAEvent(LUA_EVENT_HORSE_DOWN, {actorID = self._actorID})
end

return BuffEntityHorse