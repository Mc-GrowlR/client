local RoleEffectMediator = class('RoleEffectMediator', framework.Mediator)
RoleEffectMediator.NAME = "RoleEffectMediator"

function RoleEffectMediator:ctor()
    RoleEffectMediator.super.ctor(self, self.NAME)
end

function RoleEffectMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
    {
        noticeTable.PlayerPropertyInited,
        noticeTable.ReleaseMemory,
        noticeTable.TargetChange,
        noticeTable.PlayerLevelChange,
        noticeTable.ActorCollect,
        noticeTable.ActorFlyIn,
        noticeTable.ActorFlyOut,
        noticeTable.MouseMoveInActorSide,
        noticeTable.MouseMoveOutActorSide,
        noticeTable.Layer_Monster_Belong_TargetChange,
        noticeTable.PlayerInternalLevelChange,
        noticeTable.HeroInternalLevelChange,
    }
end


function RoleEffectMediator:handleNotification(notification)
    local noticeID = notification:getName()
    local notices = global.NoticeTable
    local data    = notification:getBody()

    if notices.ReleaseMemory == noticeID then
        self:OnClose()

    elseif notices.PlayerPropertyInited == noticeID then
        self:OnInit()

    elseif notices.TargetChange == noticeID then
        self:OnUpdateSelect(data)

    elseif notices.PlayerLevelChange == noticeID then
        self:OnRoleLevelUp(data)

    elseif notices.ActorCollect == noticeID then
        self:OnCollectActor(data)

    elseif notices.ActorFlyIn == noticeID then
        local stype = notification:getType()
        self:OnRoleFlyIn(data, stype)

    elseif notices.ActorFlyOut == noticeID then
        local stype = notification:getType()
        self:OnRoleFlyOut(data, stype)

    elseif notices.MouseMoveInActorSide == noticeID then
        self:OnMouseMoveInActorSide(data)

    elseif notices.MouseMoveOutActorSide == noticeID then
        self:OnMouseMoveOutActorSide(data)

    elseif notices.Layer_Monster_Belong_TargetChange == noticeID then
        self:OnUpdateSelect(data)

    elseif notices.PlayerInternalLevelChange == noticeID then
        self:OnInternalLevelUp()
    
    elseif notices.HeroInternalLevelChange == noticeID then
        self:OnHeroInternalLevelUp()
    end
end

function RoleEffectMediator:OnInit()
    if not (self._viewComponent) then
        local RoleEffectLayout = requireView("role/RoleEffectLayout")
        self._viewComponent    = RoleEffectLayout.create()
    end
end

function RoleEffectMediator:OnClose()
    if self._viewComponent then
        self._viewComponent:OnClose()
        self._viewComponent = nil
    end
end


function RoleEffectMediator:OnRoleLevelUp(data)
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if self._viewComponent and mainPlayer then

        self._viewComponent:OnRoleLevelUp(mainPlayer)

        global.Facade:sendNotification(global.NoticeTable.Audio_Play, { type = global.MMO.SND_TYPE_UPGRADE })
    end
end

function RoleEffectMediator:OnSelectRole(actor)
    if self._viewComponent then
        self._viewComponent:OnSelectRole(actor)
    end
end

function RoleEffectMediator:OnUpdateSelect(data)

    local targetID = data.targetID
    if targetID then
        local actor = global.actorManager:GetActor(targetID)
        if actor then
            self:OnSelectRole(actor)
        end
    else
        self:OnClearSelect()

    end
end

function RoleEffectMediator:OnClearSelect()
    if self._viewComponent then
        self._viewComponent:OnClearSelect()
    end
end

function RoleEffectMediator:OnCollectActor(data)
    local actor = data.actor
    local sfxID = data.sfxID
    if actor and self._viewComponent then
        self._viewComponent:OnCollect(actor, sfxID)
    end
end


function RoleEffectMediator:OnRoleFlyIn(data, stype)
    if data and self._viewComponent then
        self._viewComponent:OnFlyIn(data, stype)
    end
end

function RoleEffectMediator:OnRoleFlyOut(actor, stype)
    if actor and self._viewComponent then
        self._viewComponent:OnFlyOut(actor, stype)
    end
end

function RoleEffectMediator:OnMouseMoveInActorSide(actorID)
    if actorID == global.gamePlayerController:GetMainPlayerID() then
        return
    end
    if global.BuffManager:IsInColorBuff(actorID) then
        return
    end
    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return
    end
    
    actor:Bright()

    if actor:IsNPC() then
        setCusTomCursor(global.MMO.CURSOR_TYPE_NPC)
    else
        setCusTomCursor(global.MMO.CURSOR_TYPE_PK)
    end
end

function RoleEffectMediator:OnMouseMoveOutActorSide(actorID)
    if actorID == global.gamePlayerController:GetMainPlayerID() then
        return
    end
    if global.BuffManager:IsInColorBuff(actorID) then
        return
    end
    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return
    end

    actor:UnBright()
    
    setCusTomCursor(global.MMO.CURSOR_TYPE_NORMAL)
end

function RoleEffectMediator:OnInternalLevelUp()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if self._viewComponent and mainPlayer then

        self._viewComponent:OnRoleInternalLevelUp(mainPlayer)

        global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_UPGRADE})
    end
end

function RoleEffectMediator:OnHeroInternalLevelUp()
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    local heroActor = HeroPropertyProxy:GetHeroActor()
    if self._viewComponent and heroActor then

        self._viewComponent:OnHeroInternalLevelUp(heroActor, true)

        global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_UPGRADE})
    end
end

return RoleEffectMediator