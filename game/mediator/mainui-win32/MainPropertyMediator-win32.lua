local MainPropertyMediator = class("MainPropertyMediator", framework.Mediator)
MainPropertyMediator.NAME = "MainPropertyMediator"

function MainPropertyMediator:ctor()
    MainPropertyMediator.super.ctor(self, self.NAME)
end

function MainPropertyMediator:onRegister()
    MainPropertyMediator.super.onRegister(self)

    local function ActCompleted(actor, act)
        if actor and IsMoveAction(act) then
            if self._layer then
                SLBridge:onLUAEvent("LUA_EVENT_PLAYER_MAPPOS_CHANGE")
            end
        end
    end
    global.gamePlayerController:AddHandleOnActCompleted(ActCompleted)
end

function MainPropertyMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Main_Init,
        noticeTable.Layer_ChatMini_AddItem,
        noticeTable.ShowChatExNotice,
        noticeTable.QuickUseDataInit,
        noticeTable.QuickUseItemAdd,
        noticeTable.QuickUseItemRmv,
        noticeTable.QuickUseItemChange,
        noticeTable.QuickUseItemRefresh,
        noticeTable.PrivateChatWithTarget,
        noticeTable.BubbleTipsStatusChange,
        noticeTable.ReleaseMemory,
        noticeTable.Main_Add_QuitTimeTips,
        noticeTable.Main_Remove_QuitTimeTips,
        noticeTable.PCFillChatInput,
        noticeTable.Layer_Chat_PushInput,
        noticeTable.WindowResized,
        noticeTable.MainExChatClean,
        noticeTable.ComboSkillCDTimeChange,
        noticeTable.PickupModeUpdate,
        noticeTable.RefreshRecoverEditBox,
        noticeTable.ChatFakeDropChange,
        noticeTable.Layer_ChatMini_RemoveItem,
    }
end

function MainPropertyMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Main_Init == noticeID then
        self:OnMainInit()

    elseif noticeTable.Layer_ChatMini_AddItem == noticeID then
        self:OnAddChatItem(data)

    elseif noticeTable.ShowChatExNotice == noticeID then
        self:OnShowChatExNotice(data)

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

    elseif noticeTable.PrivateChatWithTarget == noticeID then
        self:OnPrivateChatWithTarget(data)

    elseif noticeTable.BubbleTipsStatusChange == noticeID then
        self:OnBubbleTipsStatusChange(data)

    elseif noticeTable.ReleaseMemory == noticeID then
        self:OnReleaseMemory()
            
    elseif noticeTable.Main_Add_QuitTimeTips == noticeID then
        self:OnAddQuitTimeTips(data)
    
    elseif noticeTable.Main_Remove_QuitTimeTips == noticeID then
        self:OnRemoveQuitTimeTips(data)

    elseif noticeTable.PCFillChatInput == noticeID  then
        self:OnFillChatInput(data)
    
    elseif noticeTable.Layer_Chat_PushInput == noticeID then
        self:OnFillChatInput(data)

    elseif noticeTable.WindowResized == noticeID then 
        self:onWindowResized(data)
    elseif noticeTable.MainExChatClean == noticeID then
        self:OnMainExChatClean(data)

    elseif noticeTable.ComboSkillCDTimeChange == noticeID then
        self:OnComboSkillCDChange(data)

    elseif noticeTable.PickupModeUpdate == noticeID then
        self:OnPickupModeUpdate(data)

    elseif noticeTable.RefreshRecoverEditBox == noticeID then
        self:OnRefreshRecoverEditBox()

    elseif noticeTable.ChatFakeDropChange == noticeID then
        self:OnChatFakeDropChange()

    elseif noticeTable.Layer_ChatMini_RemoveItem == noticeID then
        self:OnChatMiniRemoveItem(data)
    end
end

function MainPropertyMediator:onWindowResized()
    if not self._layer then
        return nil
    end
    self._layer:InitAdapet()
    
    if MainProperty.RefreshListView then
        MainProperty.RefreshListView()
    end
    
end

function MainPropertyMediator:OnMainInit()
    if not self._layer then
        self._layer = requireMainUIWIN32("MainPropertyLayout-win32").create()

        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_MB
        data.mediator = self
        
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()

        LoadLayerCUIConfig(global.CUIKeyTable.PROPERTY, self._layer)
        self._layer:AfterCUILoadFunc()

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer._quickUI.Panel_chat_funcs,
            index = global.SUIComponentTable.PCMainPropertyFuncs
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)
    end
end

function MainPropertyMediator:handlePressedEnter()
    if self._layer then
        self._layer:handlePressedEnter()
    end
    return true
end

function MainPropertyMediator:OnAddChatItem(data)
    if not self._layer then
        return nil
    end
    self._layer:OnAddChatItem(data)
end

function MainPropertyMediator:OnShowChatExNotice(data)
    if not self._layer then
        return nil
    end
    self._layer:OnShowChatExNotice(data)
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

function MainPropertyMediator:OnPrivateChatWithTarget(data)
    if not self._layer then
        return nil
    end
    self._layer:OnPrivateChatWithTarget(data)
end

function MainPropertyMediator:OnBubbleTipsStatusChange(data)
    SLBridge:onLUAEvent(LUA_EVENT_BUBBLETIPS_STATUS_CHANGE, data)
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

function MainPropertyMediator:OnReleaseMemory()
    if not self._layer then
        return nil
    end
    self._layer:Cleanup()
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

function MainPropertyMediator:OnFillChatInput(data)
    if not self._layer then
        return nil
    end
    self._layer:OnFillChatInput(data)
end

function MainPropertyMediator:OnMainExChatClean()
    if not self._layer then
        return nil
    end
    self._layer:OnMainExChatClean()
end

function MainPropertyMediator:OnComboSkillCDChange(data)
    local selectSkills = SL:GetMetaValue("SET_COMBO_SKILLS")
    local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local canLaunch = true
    local num = #selectSkills
    if num and num >= 1 then
        for i = 1, num do
            local skillID = selectSkills[i]
            if skillID and skillID ~= 0 then
                if skillProxy:IsInCD(skillID) then
                    canLaunch = false
                end
            end
        end
        skillProxy:SetlaunchComboStatus(canLaunch)
        SLBridge:onLUAEvent(LUA_EVENT_PLAYER_COMBO_SKILLCD_STATE, canLaunch)
    end
end

function MainPropertyMediator:OnPickupModeUpdate(data)
    if not self._layer then
        return false
    end
    self._layer:UpdatePickupVisible(data)
end

function MainPropertyMediator:OnRefreshRecoverEditBox()
    if not self._layer then
        return nil
    end
    self._layer:OnRefreshRecoverEditBox()
end

function MainPropertyMediator:OnChatFakeDropChange()
    if not self._layer then
        return nil
    end
    if MainProperty and MainProperty.RefreshFakeDropType then
        MainProperty.RefreshFakeDropType()
    end
end

function MainPropertyMediator:OnChatMiniRemoveItem(data)
    if not self._layer then
        return nil
    end
    self._layer:OnRemoveItem(data)
end

return MainPropertyMediator
