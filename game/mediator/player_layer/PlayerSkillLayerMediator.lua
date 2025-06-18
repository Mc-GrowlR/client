local BaseUIMediator = requireMediator("BaseUIMediator")
local PlayerSkillLayerMediator = class("PlayerSkillLayerMediator", BaseUIMediator)
PlayerSkillLayerMediator.NAME = "PlayerSkillLayerMediator"

function PlayerSkillLayerMediator:ctor()
    PlayerSkillLayerMediator.super.ctor(self)
    self._layer = nil
end

function PlayerSkillLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    local notics = {
        noticeTable.Layer_Player_Skill_Open,
        noticeTable.Layer_Player_Child_Del,
        noticeTable.SkillAdd,
        noticeTable.SkillDel,
        noticeTable.SkillUpdate,
        
    }
    local win_notics = {
        noticeTable.Layer_Player_Skill_Open,
        noticeTable.Layer_Player_Child_Del,
        noticeTable.SkillAdd,
        noticeTable.SkillDel,
        noticeTable.SkillUpdate,
        noticeTable.SkillChangeKey,
        noticeTable.SkillDeleteKey,
    }
    local isWinPlayMode = SL:GetMetaValue("WINPLAYMODE")
    if isWinPlayMode then 
        return win_notics
    else
        return notics
    end
end

function PlayerSkillLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Skill_Open then
        self:OpenLayer(noticeData)

    elseif noticeName == notices.Layer_Player_Child_Del then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL == noticeData then
            self:CloseLayer()
        end
    elseif noticeName == notices.SkillAdd then
        self:AddSkill(noticeData)

    elseif noticeName == notices.SkillDel then
        self:OnSkillDel(noticeData)

    elseif noticeName == notices.SkillUpdate then
        self:OnSkillUpdate(noticeData)

    elseif noticeName == notices.SkillChangeKey then
        self:OnSkillChangeKey(noticeData)

    elseif noticeName == notices.SkillDeleteKey then
        self:OnSkillDeleteKey(noticeData)
    end
end

function PlayerSkillLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local isWinPlayMode = SL:GetMetaValue("WINPLAYMODE")
        local path = "player_layer/PlayerSkillLayer"
        if isWinPlayMode then 
            path = "player_layer/PlayerSkillLayer_win32"
        end
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL
        data.init = noticeData and noticeData.init
        
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.PLAYER_SKILL, self._layer)
        
        SL:onLUAEvent(LUA_EVENT_PLAYER_FRAME_PAGE_ADD,data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerSkill
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

        if self._layer and self._layer.RefreshSkillCells then
            self._layer:RefreshSkillCells()
        end
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function PlayerSkillLayerMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.PlayerSkill
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

function PlayerSkillLayerMediator:AddSkill(data)
    if self._layer then
        self._layer:UpdateSkillCells()
    end
end

function PlayerSkillLayerMediator:OnSkillDel(data)
    if self._layer then
        self._layer:UpdateSkillCells()
    end
end

function PlayerSkillLayerMediator:OnSkillUpdate(data)
    if self._layer then
        self._layer:UpdateSkillCell(data.skillID)
    end
end

function PlayerSkillLayerMediator:OnSkillChangeKey(data)
    if self._layer then
        self._layer:UpdateSkillCell(data.skill.MagicID)
    end
end

function PlayerSkillLayerMediator:OnSkillDeleteKey(data)
    if self._layer then
        self._layer:UpdateSkillCell(data.skill.MagicID, data.change)
    end
end
return PlayerSkillLayerMediator