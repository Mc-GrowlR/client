local MainAssistMediator = class("MainAssistMediator", framework.Mediator)
MainAssistMediator.NAME = "MainAssistMediator"

function MainAssistMediator:ctor()
    MainAssistMediator.super.ctor(self, self.NAME)
end

function MainAssistMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Main_Init,
        noticeTable.Layer_Assist_Show,
        noticeTable.Layer_Assist_Hide,
        noticeTable.Layer_Assist_ChangeHide,
        noticeTable.ActorRevive,
        noticeTable.ActorInOfView,
        noticeTable.ActorOutOfView,
        noticeTable.ActorPlayerDie,
        noticeTable.ActorMonsterDie,
        noticeTable.ActorMonsterBirth,
        noticeTable.ActorMonsterCave,
        noticeTable.RefreshActorHP,
        noticeTable.TargetChange,
        noticeTable.PlayerPKModeChange,
        noticeTable.Layer_MainNear_Refresh,
    }
end

function MainAssistMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Main_Init == noticeID then
        self:OnMainInit()

    elseif noticeTable.Layer_Assist_Show == noticeID then
        self:OnShow(data)   

    elseif noticeTable.Layer_Assist_Hide == noticeID then
        self:OnHide(data)

    elseif noticeTable.Layer_Assist_ChangeHide == noticeID then
        self:ChangeHideStatus(data)

    elseif noticeTable.ActorRevive == noticeID then
        self:OnActorRevive(data)

    elseif noticeTable.ActorInOfView == noticeID then
        self:OnActorInOfView(data)

    elseif noticeTable.ActorOutOfView == noticeID then
        self:OnActorOutOfView(data)
        
    elseif noticeTable.ActorPlayerDie == noticeID then
        self:OnActorDie(data)

    elseif noticeTable.ActorMonsterDie == noticeID then
        self:OnActorDie(data)

    elseif noticeTable.ActorMonsterBirth == noticeID then
        self:OnActorMonsterBirth(data)

    elseif noticeTable.ActorMonsterCave == noticeID then
        self:OnActorMonsterCave(data)

    elseif noticeTable.RefreshActorHP == noticeID then
        self:OnRefreshActorHP(data)

    elseif noticeTable.TargetChange == noticeID then
        self:OnTargetChange(data)

    elseif noticeTable.PlayerPKModeChange == noticeID then
        self:OnPlayerPKStateChange(data)

    elseif noticeTable.Layer_MainNear_Refresh == noticeID then
      self:OnMainNearRefresh( data )

    end
end

function MainAssistMediator:OnMainInit()
    if not self._layer then
        self._layer = requireMainUI("MainAssistLayout").create()

        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_LT
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)
        
        ssr.GUI.ATTACH_PARENT = self._layer
        GUI.ATTACH_PARENT = self._layer
        
        self._layer:InitGUI()

        self._layer:setPositionY(-35)

        LoadLayerCUIConfig(global.CUIKeyTable.ASSIST, self._layer)
        -- 特殊刷新数值
        self._layer:ReloadCUISetWidget()

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer._ui_content.Panel_mission,
            index = global.SUIComponentTable.MainRootMission
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

        local componentData = 
        {
            root  = self._layer._layoutAssist,
            index = global.SUIComponentTable.MainRootAssist
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)  
    end

    ssr.ssrBridge:setGUIParent(110, self._layer._ui_content.Panel_mission)
    ssr.ssrBridge:setGUIParent(111, self._layer._layoutAssist)

    -- 开关
    if CHECK_SERVER_OPTION(global.MMO.SERVER_OPTION_MISSTION) ~= 1 then
        self._layer:setVisible(false)
    end
end

function MainAssistMediator:OnShow(data)
    if not self._layer then
        return
    end
    self._layer:setVisible(true)
end

function MainAssistMediator:OnHide(data)
    if not self._layer then
        return
    end
    self._layer:setVisible(false)
end

function MainAssistMediator:ChangeHideStatus(data)
    if not self._layer then
        return
    end
    self._layer:ChangeHideStatus(not data)
end

function MainAssistMediator:OnActorRevive(data)
    if not self._layer then
        return
    end
    self._layer:OnActorRevive(data)
end

function MainAssistMediator:OnActorInOfView(data)
    if not self._layer then
        return
    end
    self._layer:OnActorInOfView(data)
end

function MainAssistMediator:OnActorOutOfView(data)
    if not self._layer then
        return
    end
    self._layer:OnActorOutOfView(data)
end

function MainAssistMediator:OnActorDie(data)
    if not self._layer then
        return
    end
    self._layer:OnActorDie(data)
end

function MainAssistMediator:OnActorMonsterBirth(data)
    if not self._layer then
        return
    end
    self._layer:OnActorMonsterBirth(data)
end

function MainAssistMediator:OnActorMonsterCave(data)
    if not self._layer then
        return
    end
    self._layer:OnActorMonsterCave(data)
end

function MainAssistMediator:OnRefreshActorHP(data)
    if not self._layer then
        return
    end
    self._layer:OnRefreshActorHP(data)
end

function MainAssistMediator:OnTargetChange(data)
    if not self._layer then
        return
    end
    self._layer:OnTargetChange(data)
end

function MainAssistMediator:OnPlayerPKStateChange(data)
    if not self._layer then
        return
    end
    self._layer:OnPlayerPKStateChange(data)
end

function MainAssistMediator:OnMainNearRefresh( data )
   if self._layer then
      self._layer:OnMainNearRefresh( data )
   end
end

return MainAssistMediator