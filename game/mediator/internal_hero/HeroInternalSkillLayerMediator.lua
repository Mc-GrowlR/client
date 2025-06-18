local BaseUIMediator = requireMediator("BaseUIMediator")
local HeroInternalSkillLayerMediator = class("HeroInternalSkillLayerMediator", BaseUIMediator)
HeroInternalSkillLayerMediator.NAME = "HeroInternalSkillLayerMediator"

function HeroInternalSkillLayerMediator:ctor()
    HeroInternalSkillLayerMediator.super.ctor(self)
    self._layer = nil
end

function HeroInternalSkillLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Hero_Internal_Skill_Open,
        noticeTable.Layer_Hero_Internal_Child_Del,
    }
end

function HeroInternalSkillLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Hero_Internal_Skill_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Hero_Internal_Child_Del then
        if SLDefine.InternalPage.Skill == noticeData then
            self:CloseLayer()
        end
    end
end

function HeroInternalSkillLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "internal_hero/HeroInternalSkillLayer"
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.InternalPage.Skill
        data.init = noticeData and noticeData.init
        data.isInternal = true

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_HERO_FRAME_PAGE_ADD, data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.HeroInternalSkill
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end

end

function HeroInternalSkillLayerMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.HeroInternalSkill
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    
    if self._layer then
        if HeroInternalSkill.OnClose then
            HeroInternalSkill.OnClose()
        end
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return HeroInternalSkillLayerMediator