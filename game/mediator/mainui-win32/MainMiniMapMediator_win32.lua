local MainMiniMapMediator = class("MainMiniMapMediator", framework.Mediator)
MainMiniMapMediator.NAME = "MainMiniMapMediator"

function MainMiniMapMediator:ctor()
    MainMiniMapMediator.super.ctor(self, self.NAME)
end

function MainMiniMapMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Main_Init,
        noticeTable.ChangeScene,
        noticeTable.Layer_MainMiniMapWin32_Tab,
        noticeTable.Layer_MiniMap_Close,
        noticeTable.ActorInOfView,
        noticeTable.ActorOutOfView,
        noticeTable.ActorDie,
        noticeTable.ActorRevive,
        noticeTable.ActorMonsterBirth,
        noticeTable.ActorMonsterCave,
        noticeTable.MiniMap_Download_Success,
        noticeTable.ReleaseMemory,
    }
end

function MainMiniMapMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Main_Init == noticeID then
        self:OnMainInit()

    elseif noticeTable.ChangeScene == noticeID then
        self:OnChangeScene(data)

    elseif noticeTable.Layer_MainMiniMapWin32_Tab == noticeID then
        self:OnEventTag(data)

    elseif noticeTable.Layer_MiniMap_Close == noticeID then
        self:OnMiniMapClose(data)

    elseif noticeTable.ActorInOfView == noticeID then
        self:OnActorInOfView(data)

    elseif noticeTable.ActorOutOfView == noticeID then
        self:OnActorOutOfView(data)

    elseif noticeTable.ActorDie == noticeID then
        self:OnActorDie(data)

    elseif noticeTable.ActorRevive == noticeID then
        self:OnActorRevive(data)
        
    elseif noticeTable.ActorMonsterBirth == noticeID then
        self:OnActorMonsterBirth(data)

    elseif noticeTable.ActorMonsterCave == noticeID then
        self:OnActorMonsterCave(data)

    elseif noticeTable.MiniMap_Download_Success == noticeID then
        self:OnMinimapDownloadSuccess(data)
        
    elseif noticeTable.ReleaseMemory == noticeID then
        self:OnReleaseMemory()

    end
end

function MainMiniMapMediator:OnMainInit()
    if not self._layer then
        self._layer = requireMainUIWIN32("MainMiniMapLayout_win32").create()

        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_TOP_RT
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)

        LoadLayerCUIConfig(global.CUIKeyTable.MAINMINIMAP, self._layer)
    end
end

function MainMiniMapMediator:OnChangeScene(data)
    if not self._layer then
        return nil
    end
    self._layer:OnChangeScene(data)
end

function MainMiniMapMediator:OnEventTag(data)
    if not self._layer then
        return nil
    end
    self._layer:OnEventTag(data)
end

function MainMiniMapMediator:OnMiniMapClose(data)
end

function MainMiniMapMediator:OnActorInOfView(data)
    if not self._layer then
        return nil
    end
    if data.actorID == global.gamePlayerController:GetMainPlayerID() then
        self._layer:OnMainPlayerInit()
    else
        self._layer:AddActorPoint(data.actor)
    end
end

function MainMiniMapMediator:OnActorOutOfView(data)
    if not self._layer then
        return nil
    end
    self._layer:RmvActorPoint(data.actor)
end

function MainMiniMapMediator:OnActorDie(data)
    if not self._layer then
        return nil
    end
    self._layer:RmvActorPoint(data.actor)
end

function MainMiniMapMediator:OnActorRevive(data)
    if not self._layer then
        return nil
    end
    self._layer:AddActorPoint(data.actor)
end

function MainMiniMapMediator:OnActorMonsterBirth(data)
    if not self._layer then
        return nil
    end
    self._layer:AddActorPoint(data.actor)
end

function MainMiniMapMediator:OnActorMonsterCave(data)
    if not self._layer then
        return nil
    end
    self._layer:RmvActorPoint(data.actor)
end

function MainMiniMapMediator:OnMinimapDownloadSuccess(dMinimapID)
    if not self._layer then
        return nil
    end
    self._layer:OnMinimapDownloadSuccess(dMinimapID)
end

function MainMiniMapMediator:OnReleaseMemory()
    if not self._layer then
        return nil
    end
    self._layer:OnReleaseMemory()
end

function MainMiniMapMediator:onRegister()
    MainMiniMapMediator.super.onRegister(self)

    ---------------------------------------------------------------
    -- 主玩家
    global.gamePlayerController:AddHandleOnActBegin(function(actor, act)
        if not actor then
            return
        end

        -- 同步至 SL框架
        SLBridge:onLUAEvent(LUA_EVENT_PLAYER_ACTION_BEGIN, {id = actor:GetID(), act = act})
    end)
    -- 主玩家
    global.gamePlayerController:AddHandleOnActCompleted(function(actor, act)
        if not actor then
            return
        end

        if IsMoveAction(act) then
            -- 主玩家移动，取消交易
            local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
            TradeProxy:CheckPlayerMove()
            
            if self._layer then
                self._layer:OnPlayerMoveCompleted()
                global.Facade:sendNotification(global.NoticeTable.PlayerMapPosChange)
                SLBridge:onLUAEvent(LUA_EVENT_PLAYER_MAPPOS_CHANGE)
            end

            -- 移动时，其他玩家的鼠标经过显示消失
            local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
            if inputProxy:GetMouseOverTargetID() then
                local actor = global.actorManager:GetActor(inputProxy:GetMouseOverTargetID())
                inputProxy:SetMouseOverTargetID(nil)
                if actor then
                    local hudParam = GetActorAttr(actor, global.MMO.ACTOR_ATTR_HUDPARAM)
                    if hudParam and next(hudParam) then
                        global.Facade:sendNotification(global.NoticeTable.DelayRefreshHUDLabel, { actor = actor, actorID = actor:GetID(), hudParam = hudParam })
                    end
                end
            end
        end

        -- 同步至 SL框架
        SLBridge:onLUAEvent(LUA_EVENT_PLAYER_BEHAVIOR_STATE_CAHNGE, act)
        SLBridge:onLUAEvent(LUA_EVENT_PLAYER_ACTION_COMPLETE, {id = actor:GetID(), act = act})
    end)

    ---------------------------------------------------------------
    -- 网络玩家 act begin
    global.netPlayerController:AddHandleOnActBegin(function(actor, act)
        if not actor then
            return
        end

        -- 同步至 SL框架
        SLBridge:onLUAEvent(LUA_EVENT_NET_PLAYER_ACTION_BEGIN, {id = actor:GetID(), act = act})
    end)

    -- 网络玩家
    global.netPlayerController:AddHandleOnActCompleted(function(actor, act)
        if not actor then
            return
        end

        if IsMoveAction(act) then
            if self._layer then
                self._layer:UpdateActorPoint(actor)
            end

            local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
            if inputProxy:GetMouseOverTargetID() == actor:GetID() then
                inputProxy:SetMouseOverTargetID(nil)
                local hudParam = GetActorAttr(actor, global.MMO.ACTOR_ATTR_HUDPARAM)
                if hudParam and next(hudParam) then
                    global.Facade:sendNotification(global.NoticeTable.DelayRefreshHUDLabel, { actor = actor, actorID = actor:GetID(), hudParam = hudParam })
                end
            end
        end

        -- 同步至 SL框架
        SLBridge:onLUAEvent(LUA_EVENT_NET_PLAYER_ACTION_COMPLETE, {id = actor:GetID(), act = act})
    end)

    ---------------------------------------------------------------
    -- 怪物
    global.netMonsterController:AddHandleOnActBegin(function(actor, act)
        if not actor then
            return
        end

        -- 同步至 SL框架
        SLBridge:onLUAEvent(LUA_EVENT_MONSTER_ACTION_BEGIN, {id = actor:GetID(), act = act})
    end)

    -- 怪物
    global.netMonsterController:AddHandleOnActCompleted(function(actor, act)
        if not actor then
            return
        end

        if IsMoveAction(act) then
            if self._layer then
                self._layer:UpdateActorPoint(actor)
            end
        end

        -- 同步至 SL框架
        SLBridge:onLUAEvent(LUA_EVENT_MONSTER_ACTION_COMPLETE, {id = actor:GetID(), act = act})
    end)
end

return MainMiniMapMediator
