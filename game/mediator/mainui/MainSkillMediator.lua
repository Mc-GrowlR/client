local MainSkillMediator = class("MainSkillMediator", framework.Mediator)
MainSkillMediator.NAME = "MainSkillMediator"

function MainSkillMediator:ctor()
    MainSkillMediator.super.ctor(self, self.NAME)
end

function MainSkillMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Main_Init,
        noticeTable.Skill_PanelActive_AddChild,
        noticeTable.Skill_PanelSkill_AddChild,
        noticeTable.SkillAdd,
        noticeTable.SkillDel,
        noticeTable.SkillUpdate,
        noticeTable.SkillChangeKey,
        noticeTable.SkillDeleteKey,
        noticeTable.SkillCDTimeChange,
        noticeTable.ClearSelectSkill,
        noticeTable.SkillOn,
        noticeTable.SkillOff,
        noticeTable.PlayEquip_Oper_Init,
        noticeTable.PlayEquip_Oper_Data,
        noticeTable.GuideEnterTransition,
        noticeTable.AutoPickBeginTips,
        noticeTable.AutoPickEndTips,
        noticeTable.PickupModeUpdate,
        noticeTable.SkillAdd_Hero,
        noticeTable.Layer_Hero_Logout,
        noticeTable.Layer_Hero_Login,
        noticeTable.TargetChange,
        noticeTable.HeroLock_Icon,
        noticeTable.Skill_Show_Distance_Change,
        noticeTable.ComboSkillCDTimeChange,
    }
end

function MainSkillMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Main_Init == noticeID then
        self:OnMainInit()

    elseif noticeTable.Skill_PanelActive_AddChild == noticeID then
        self:OnPanelActiveAdd(data)

    elseif noticeTable.Skill_PanelSkill_AddChild == noticeID then
        self:OnPanelSkillAdd(data)

    elseif noticeTable.SkillAdd == noticeID then
        self:OnSkillAdd(data)

    elseif noticeTable.SkillDel == noticeID then
        self:OnSkillDel(data)

    elseif noticeTable.SkillUpdate == noticeID then
        self:OnSkillSkillUpdate(data)

    elseif noticeTable.SkillChangeKey == noticeID then
        self:OnSkillChangeKey(data)

    elseif noticeTable.SkillDeleteKey == noticeID then
        self:OnSkillDeleteKey(data)

    elseif noticeTable.SkillCDTimeChange == noticeID then
        self:OnSkillCDTimeChange(data)

    elseif noticeTable.ClearSelectSkill == noticeID then
        self:OnClearSelectSkill(data)

    elseif noticeTable.SkillOn == noticeID then
        self:OnSkillOn(data)

    elseif noticeTable.SkillOff == noticeID then
        self:OnSkillOff(data)
        
    elseif noticeTable.PlayEquip_Oper_Init == noticeID then
        self:OnPlayerEquipChange(data)
        
    elseif noticeTable.PlayEquip_Oper_Data == noticeID then
        self:OnPlayerEquipChange(data)

    elseif noticeTable.GuideEnterTransition == noticeID then
        self:OnGuideEnterTransition(data)
        
    elseif noticeTable.AutoPickBeginTips == noticeID then
        self:OnAutoPickBeginTips(data)

    elseif noticeTable.AutoPickEndTips == noticeID then
        self:OnAutoPickEndTips(data)

    elseif noticeTable.PickupModeUpdate == noticeID then
        self:OnPickupModeUpdate(data)

    elseif noticeTable.SkillAdd_Hero == noticeID then
        self:OnHeroSkillAdd(data)

    elseif noticeTable.Layer_Hero_Login == noticeID then
        self:OnHeroSkillInit(data)

    elseif noticeTable.Layer_Hero_Logout == noticeID then
        self:OnHeroSkillRemove()

    elseif noticeTable.TargetChange == noticeID  or noticeTable.HeroLock_Icon == noticeID then
        SL:onLUAEvent(LUA_EVENT_HERO_LOCK_CHANGE)

    elseif noticeTable.Skill_Show_Distance_Change == noticeID then
        self:OnSkill_Show_Distance_Change(data)

    elseif noticeTable.ComboSkillCDTimeChange == noticeID then
        self:OnComboSkillCDChange(data)

    end
end

function MainSkillMediator:OnSkill_Show_Distance_Change(data)
    if not self._layer then
        return nil
    end
    self._layer:OnSkill_Show_Distance_Change(data)
end

function MainSkillMediator:OnMainInit()
    if not self._layer then
        self._layer = requireMainUI("MainSkillLayout").create()

        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_RB
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)

        ssr.GUI.ATTACH_PARENT = self._layer
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()

        self._layer:setPositionY(25)

        LoadLayerCUIConfig(global.CUIKeyTable.MOBILE_SKILL, self._layer)

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer._layoutActive,
            index = global.SUIComponentTable.MainRootButton
        }

        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        -- 自定义组件挂接
        ssr.ssrBridge:setGUIParent(109, self._layer._layoutActive)

    end
end

function MainSkillMediator:OnPanelActiveAdd(widget)
    if not self._layer or tolua.isnull(widget) then
        return
    end

    if self._layer._layoutActive then
        self._layer._layoutActive:addChild(widget)
    end
end

function MainSkillMediator:OnPanelSkillAdd( widget )
    if not self._layer or tolua.isnull(widget) then
        return
    end

    if self._layer._layoutSkill then
        self._layer._layoutSkill:addChild(widget)
    end
end

function MainSkillMediator:OnSkillAdd(data)
    if not self._layer then
        return false
    end
    if not data.Key and data.Key == 0 then
        return false
    end
    self._layer:OnSkillAdd(data)
end

function MainSkillMediator:OnSkillDel(data)
    if not self._layer then
        return false
    end
    if not data.Key and data.Key == 0 then
        return false
    end
    self._layer:OnSkillDel(data)
end

function MainSkillMediator:OnSkillSkillUpdate(data)
    if not self._layer then
        return false
    end
    if not data.Key and data.Key == 0 then
        return false
    end
    self._layer:OnSkillSkillUpdate(data)
end

function MainSkillMediator:OnSkillChangeKey(data)
    if not self._layer then
        return false
    end
    self._layer:OnSkillChangeKey(data)
end

function MainSkillMediator:OnSkillDeleteKey(data)
    if not self._layer then
        return false
    end
    self._layer:OnSkillDeleteKey(data)
end

function MainSkillMediator:OnSkillCDTimeChange(data)
    if not self._layer then
        return false
    end
    self._layer:OnSkillCDTimeChange(data)
end

function MainSkillMediator:OnClearSelectSkill(data)
    if not self._layer then
        return false
    end
    self._layer:OnClearSelectSkill(data)
end

function MainSkillMediator:OnSkillOn(data)
    if not self._layer then
        return nil
    end
    self._layer:OnSkillOn(data)
end

function MainSkillMediator:OnSkillOff(data)
    if not self._layer then
        return nil
    end
    self._layer:OnSkillOff(data)
end

function MainSkillMediator:OnPlayerEquipChange(data)
    if not self._layer then
        return nil
    end
    self._layer:OnPlayerEquipChange(data)
end

function MainSkillMediator:OnGuideEnterTransition(data)
    if not self._layer then
        return false
    end
    self._layer:OnGuideEnterTransition(data)
end

function MainSkillMediator:OnAutoPickBeginTips(data)
    if not self._layer then
        return false
    end
    self._layer:UpdatePick(data)
end

function MainSkillMediator:OnAutoPickEndTips(data)
    if not self._layer then
        return false
    end
    self._layer:UpdatePick(data)
end

function MainSkillMediator:OnPickupModeUpdate(data)
    if not self._layer then
        return false
    end
    self._layer:UpdatePickupVisible(data)
end

function MainSkillMediator:OnHeroSkillInit(data)
    if not self._layer then
        return false
    end
    self._layer:OnHeroSkillInit()
end
function MainSkillMediator:OnHeroSkillAdd(data)
    if not self._layer then
        return false
    end
    self._layer:OnHeroSkillAdd(data)
end
function MainSkillMediator:OnHeroSkillRemove( ... )
    -- body
    if not self._layer then
        return false
    end
    self._layer:OnHeroSkillDel()
end

function MainSkillMediator:OnComboSkillCDChange(data)
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

return MainSkillMediator
