local BaseUIMediator = requireMediator("BaseUIMediator")
local PlayerInternalSkillLayerMediator = class("PlayerInternalSkillLayerMediator", BaseUIMediator)
PlayerInternalSkillLayerMediator.NAME = "PlayerInternalSkillLayerMediator"

function PlayerInternalSkillLayerMediator:ctor()
    PlayerInternalSkillLayerMediator.super.ctor(self)
    self._layer = nil
end

function PlayerInternalSkillLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Internal_Skill_Open,
        noticeTable.Layer_Player_Internal_Child_Del,
    }
end

function PlayerInternalSkillLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Internal_Skill_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Player_Internal_Child_Del then
        if SLDefine.InternalPage.Skill == noticeData then
            self:CloseLayer()
        end
    end
end

function PlayerInternalSkillLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "internal_layer/PlayerInternalSkillLayer"
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.InternalPage.Skill
        data.init = noticeData and noticeData.init
        data.isInternal = true

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_PLAYER_FRAME_PAGE_ADD, data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerInternalSkill
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end

end

function PlayerInternalSkillLayerMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.PlayerInternalSkill
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    
    if self._layer then
        if PlayerInternalSkill.OnClose then
            PlayerInternalSkill.OnClose()
        end
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return PlayerInternalSkillLayerMediator