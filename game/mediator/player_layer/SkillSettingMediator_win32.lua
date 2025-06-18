local BaseUIMediator = requireMediator("BaseUIMediator")
local SkillSettingMediator_win32 = class('SkillSettingMediator_win32', BaseUIMediator)
SkillSettingMediator_win32.NAME = "SkillSettingMediator_win32"

function SkillSettingMediator_win32:ctor()
    SkillSettingMediator_win32.super.ctor(self)
end

function SkillSettingMediator_win32:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_SkillSetting_Open,
        noticeTable.Layer_SkillSetting_Close,
    }
end

function SkillSettingMediator_win32:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_SkillSetting_Open == noticeID then
        self:OpenLayer(data)
    elseif noticeTable.Layer_SkillSetting_Close == noticeID then
        self:CloseLayer()
    end
end

function SkillSettingMediator_win32:OpenLayer(data)
    if not (self._layer) then
        self._layer = requireLayerUI("player_layer/SkillSettingLayer_win32").create(data)
        self._type  = global.UIZ.UI_NORMAL 
        self._GUI_ID = SLDefine.LAYERID.PlayerSkillSetting
        SkillSettingMediator_win32.super.OpenLayer(self)
        self._layer:InitGUI(data)
    end
end

function SkillSettingMediator_win32:CloseLayer()
    SkillSettingMediator_win32.super.CloseLayer(self)
end

return SkillSettingMediator_win32
