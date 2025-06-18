local BaseUIMediator = requireMediator("BaseUIMediator")
local SkillRankPanelMediator = class('SkillRankPanelMediator', BaseUIMediator)
SkillRankPanelMediator.NAME = "SkillRankPanelMediator"

function SkillRankPanelMediator:ctor()
    SkillRankPanelMediator.super.ctor(self)
end

function SkillRankPanelMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_SkillRankPanel_Open,
        noticeTable.Layer_SkillRankPanel_Close,
    }
end

function SkillRankPanelMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_SkillRankPanel_Open == name then
        self:OpenLayer(data)
    elseif noticeTable.Layer_SkillRankPanel_Close == name then
        self:CloseLayer()
    end
end

function SkillRankPanelMediator:OpenLayer(data)
    if not self._layer then
        local path =  "setting_layer/SkillRankPanel" 
        self._layer = requireLayerUI(path).create(data)
        self._type = global.UIZ.UI_NORMAL
        self._responseMoved = self._layer._quickUI.Panel_1
        SkillRankPanelMediator.super.OpenLayer( self )
    end
end

function SkillRankPanelMediator:CloseLayer()  
    if not self._layer then
        return 
    end 
    self._layer:OnClose()
    SkillRankPanelMediator.super.CloseLayer( self )
end

return SkillRankPanelMediator
