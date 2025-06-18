local BaseUIMediator = requireMediator("BaseUIMediator")
local CUIEditorMediator = class('CUIEditorMediator', BaseUIMediator)
CUIEditorMediator.NAME = "CUIEditorMediator"

function CUIEditorMediator:ctor()
    CUIEditorMediator.super.ctor(self)
end

function CUIEditorMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.CUIEditorOpen,
        noticeTable.CUIEditorClose,
    }
end

function CUIEditorMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.CUIEditorOpen == name then
        self:OpenLayer(data)
        
    elseif noticeTable.CUIEditorClose == name then
        self:CloseLayer()
    end
end

function CUIEditorMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer = requireLayerUI("test_layer/CUIEditor").create(data)
        self._type  = global.UIZ.UI_NOTICE
        
        CUIEditorMediator.super.OpenLayer(self)
    end
    global.Director:setDisplayStats(false)
end

function CUIEditorMediator:CloseLayer()
    if not self._layer then
        return nil
    end
    self._layer:onClose()
    CUIEditorMediator.super.CloseLayer(self)
    
    global.Facade:sendNotification(global.NoticeTable.QuestionLayer_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_Rank_Close)
    global.Facade:sendNotification(global.NoticeTable.VerificationLayer_Close)
end

return CUIEditorMediator
