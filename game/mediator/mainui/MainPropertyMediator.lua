local MainPropertyMediator = class("MainPropertyMediator", framework.Mediator)
MainPropertyMediator.NAME = "MainPropertyMediator"

function MainPropertyMediator:ctor()
    MainPropertyMediator.super.ctor(self, self.NAME)
end

function MainPropertyMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.Layer_Main_Init,
        noticeTable.BubbleTipsStatusChange,
        noticeTable.QuickUseDataInit,
        noticeTable.QuickUseItemAdd,
        noticeTable.QuickUseItemRmv,
        noticeTable.QuickUseItemChange,
        noticeTable.QuickUseItemRefresh,
        noticeTable.Layer_ChatMini_AddItem,
        noticeTable.ShowChatExNotice,
        noticeTable.Main_Add_QuitTimeTips,
        noticeTable.Main_Remove_QuitTimeTips,
        noticeTable.MainExChatClean,
        noticeTable.Chat_Refresh_Mobile_AutoShout,
        noticeTable.WindowResized,
        noticeTable.Layer_ChatMini_RemoveItem,
    }
end

function MainPropertyMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Main_Init == noticeID then
        self:OnMainInit()

    elseif noticeTable.BubbleTipsStatusChange == noticeID then
        self:OnBubbleTipsStatusChange(data)

    elseif noticeTable.QuickUseDataInit == noticeID then
        self:OnQuickUseDataInit(data)

    elseif noticeTable.QuickUseItemAdd == noticeID then
        self:OnQuickUseItemAdd(data)

    elseif noticeTable.QuickUseItemRmv == noticeID then
        self:OnQuickUseItemRmv(data)

    elseif noticeTable.QuickUseItemChange == noticeID then
        self:OnQuickUseItemChange(data)

    elseif noticeTable.QuickUseItemRefresh == noticeID then
        self:OnQuickUseItemRefresh(data)

    elseif noticeTable.Layer_ChatMini_AddItem == noticeID then
        self:OnChatMiniAddItem(data)

    elseif noticeTable.ShowChatExNotice == noticeID then
        self:OnShowChatExNotice(data)

    elseif noticeTable.Main_Add_QuitTimeTips == noticeID then
        self:OnAddQuitTimeTips(data)
    
    elseif noticeTable.Main_Remove_QuitTimeTips == noticeID then
        self:OnRemoveQuitTimeTips(data)
    elseif noticeTable.MainExChatClean == noticeID then
        self:OnMainExChatClean(data)

    elseif noticeTable.Chat_Refresh_Mobile_AutoShout == noticeID then
        self:OnRefreshMobileAutoShout(data)
    
    elseif noticeTable.WindowResized == noticeID then
        self:OnWindowResized()

    elseif noticeTable.Layer_ChatMini_RemoveItem == noticeID then
        self:OnChatMiniRemoveItem(data)
    end
end

function MainPropertyMediator:OnMainInit()
    if not self._layer then
        self._layer = requireMainUI("MainPropertyLayout").create()
        self._layer:setPositionX(SL:GetMetaValue("SCREEN_WIDTH") / 2)
        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_EXTRA_LB

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()

        LoadLayerCUIConfig(global.CUIKeyTable.PROPERTY, self._layer)
        self._layer:AfterCUILoadFunc()

        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data) 

    end
end

function MainPropertyMediator:OnWindowResized()
    if self._layer then
        self._layer:setPositionX(SL:GetMetaValue("SCREEN_WIDTH") / 2)
    end
end

function MainPropertyMediator:GetBubbleButtonByID(id)
    if not self._layer or not MainProperty then
        return nil
    end

    if MainProperty.GetBubbleButtonByID then
        return MainProperty.GetBubbleButtonByID(id)
    end

    return nil
end

function MainPropertyMediator:OnBubbleTipsStatusChange(data)
    SLBridge:onLUAEvent(LUA_EVENT_BUBBLETIPS_STATUS_CHANGE, data)
end

function MainPropertyMediator:OnQuickUseDataInit(data)
    if not self._layer then
        return nil
    end
    self._layer:UpdateQuickUse(data)
end

function MainPropertyMediator:OnQuickUseItemAdd(data)
    if not self._layer then
        return nil
    end
    self._layer:AddQuickUseItem(data)
end

function MainPropertyMediator:OnQuickUseItemRmv(data)
    if not self._layer then
        return nil
    end
    self._layer:RmvQuickUseItem(data)
end

function MainPropertyMediator:OnQuickUseItemChange(data)
    if not self._layer then
        return nil
    end
    self._layer:ChangeQuickUseItem(data)
end

function MainPropertyMediator:OnQuickUseItemRefresh(data)
    if not self._layer then
        return nil
    end
    self._layer:RefreshQuickUseItem(data)
end

function MainPropertyMediator:OnChatMiniAddItem(data)
    if not self._layer then
        return nil
    end
    self._layer:PushMiniChatCell(data)
end

function MainPropertyMediator:OnShowChatExNotice(data)
    if not self._layer then
        return nil
    end
    self._layer:OnShowChatExNotice(data)
end

function MainPropertyMediator:OnAddQuitTimeTips(data)
    if not self._layer then
        return nil
    end
    self._layer:OnAddQuitTimeTips(data)
end

function MainPropertyMediator:OnRemoveQuitTimeTips()
    if not self._layer then
        return nil
    end
    self._layer:OnRemoveQuitTimeTips()
end

function MainPropertyMediator:OnMainExChatClean()
    if not self._layer then
        return nil
    end
    self._layer:OnMainExChatClean()
end

function MainPropertyMediator:OnRefreshMobileAutoShout(data)
    if not self._layer then
        return nil
    end
    self._layer:OnRefreshMobileAutoShout(data)
end

function MainPropertyMediator:OnChatMiniRemoveItem(data)
    if not self._layer then
        return nil
    end
    self._layer:OnRemoveItem(data)
end

return MainPropertyMediator
