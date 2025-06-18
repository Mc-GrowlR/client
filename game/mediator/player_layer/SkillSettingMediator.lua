local BaseUIMediator = requireMediator("BaseUIMediator")
local SkillSettingMediator = class('SkillSettingMediator', BaseUIMediator)
SkillSettingMediator.NAME = "SkillSettingMediator"

function SkillSettingMediator:ctor()
    SkillSettingMediator.super.ctor(self)
end

function SkillSettingMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_SkillSetting_Open,
        noticeTable.Layer_SkillSetting_Close,
        noticeTable.SkillAdd,
        noticeTable.SkillDel,
        noticeTable.SkillChangeKey,
        noticeTable.SkillDeleteKey,
    }
end

function SkillSettingMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_SkillSetting_Open == name then
        self:OpenLayer(data)
        
    elseif noticeTable.Layer_SkillSetting_Close == name then
        self:CloseLayer()

    elseif noticeTable.SkillAdd == name then
        self:OnSkillAdd(data)

    elseif noticeTable.SkillDel == name then
        self:OnSkillDel(data)

    elseif noticeTable.SkillChangeKey == name then
        self:OnSkillChangeKey(data)

    elseif noticeTable.SkillDeleteKey == name then
        self:OnSkillDeleteKey(data)
    end
end

function SkillSettingMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer = requireLayerUI("player_layer/SkillSettingLayer").create()
        self._type     = global.UIZ.UI_NORMAL
        self._escClose = true
        self._GUI_ID   = SLDefine.LAYERID.PlayerSkillSetting

        SkillSettingMediator.super.OpenLayer(self)
        self._layer:InitGUI()
    end
end

function SkillSettingMediator:CloseLayer()
    SkillSettingMediator.super.CloseLayer(self)
end

function SkillSettingMediator:OnSkillAdd(data)
    if not self._layer then
        return
    end
    self._layer:UpdateSkillCells()
end

function SkillSettingMediator:OnSkillDel(data)
    if not self._layer then
        return
    end
    self._layer:UpdateSkillCells()
end

function SkillSettingMediator:OnSkillChangeKey(data)
    if not self._layer then
        return
    end
    self._layer:OnSkillChangeKey(data)
end

function SkillSettingMediator:OnSkillDeleteKey(data)
    if not self._layer then
        return
    end
    self._layer:OnSkillDeleteKey({key = data.delKey, skillID = data.skill.MagicID})
end

return SkillSettingMediator
