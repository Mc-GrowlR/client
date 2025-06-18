local BaseUIMediator = requireMediator("BaseUIMediator")
local SkillPanelMediator = class('SkillPanelMediator', BaseUIMediator)
SkillPanelMediator.NAME = "SkillPanelMediator"

function SkillPanelMediator:ctor()
    SkillPanelMediator.super.ctor(self)
end

function SkillPanelMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_SkillPanel_Open,
        noticeTable.Layer_SkillPanel_Close,
    }
end

function SkillPanelMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_SkillPanel_Open == name then
        self:OpenLayer(data)
    elseif noticeTable.Layer_SkillPanel_Close == name then
        self:CloseLayer()
    end
end

function SkillPanelMediator:OpenLayer(data)
    if not self._layer then
        local path =  "setting_layer/SkillPanel" 
        self._layer = requireLayerUI(path).create(data)
        self._type = global.UIZ.UI_NORMAL
        self._responseMoved = self._layer._quickUI.Panel_1
        SkillPanelMediator.super.OpenLayer( self )
    end
end

function SkillPanelMediator:CloseLayer()  
    if not self._layer then
        return 
    end 
    SkillPanelMediator.super.CloseLayer( self )
end




return SkillPanelMediator
