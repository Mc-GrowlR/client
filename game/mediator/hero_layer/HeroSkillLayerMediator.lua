local BaseUIMediator = requireMediator("BaseUIMediator")
local HeroSkillLayerMediator = class("HeroSkillLayerMediator", BaseUIMediator)
HeroSkillLayerMediator.NAME = "HeroSkillLayerMediator"

function HeroSkillLayerMediator:ctor()
    HeroSkillLayerMediator.super.ctor(self)
    self._layer = nil
end

function HeroSkillLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    local notics = {
        noticeTable.Layer_Player_Skill_Open_Hero,
        noticeTable.Layer_Player_Child_Del_Hero,
        noticeTable.SkillAdd_Hero,
        noticeTable.SkillDel_Hero,
        noticeTable.SkillUpdate_Hero,
        
    }
    local win_notics = {
        noticeTable.Layer_Player_Skill_Open_Hero,
        noticeTable.Layer_Player_Child_Del_Hero,
        noticeTable.SkillAdd_Hero,
        noticeTable.SkillDel_Hero,
        noticeTable.SkillUpdate_Hero,
    }

    local isWinPlayMode = SL:GetMetaValue("WINPLAYMODE")
    if isWinPlayMode then 
        return win_notics
    else
        return notics
    end
end

function HeroSkillLayerMediator:handleNotification(notification)
    local notices    = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Skill_Open_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL == noticeData then
            self:CloseLayer()
        end
    elseif noticeName == notices.SkillAdd_Hero then
        self:AddSkill(noticeData)
    elseif noticeName == notices.SkillDel_Hero then
        self:OnSkillDel(noticeData)
    elseif noticeName == notices.SkillUpdate_Hero then
        self:OnSkillUpdate(noticeData)
    end
end

function HeroSkillLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local isWinPlayMode = SL:GetMetaValue("WINPLAYMODE")
        local path = "hero_layer/HeroSkillLayer"
        if isWinPlayMode then 
            path = "hero_layer/HeroSkillLayer_win32"
        end
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL
        data.init = noticeData and noticeData.init

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.HERO_SKILL, self._layer)
        
        SL:onLUAEvent(LUA_EVENT_HERO_FRAME_PAGE_ADD,data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerSkill_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        -- 自定义组件挂接

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function HeroSkillLayerMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = {
        index = global.SUIComponentTable.PlayerSkill_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    -- 自定义组件挂接

    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

function HeroSkillLayerMediator:AddSkill(data)
    if self._layer then
        self._layer:UpdateSkillCells()
    end
end

function HeroSkillLayerMediator:OnSkillDel(data)
    if self._layer then
        self._layer:UpdateSkillCells()
    end
end

function HeroSkillLayerMediator:OnSkillUpdate(data)
    if self._layer then
        self._layer:UpdateSkillCell(data.skillID)
    end
end

return HeroSkillLayerMediator