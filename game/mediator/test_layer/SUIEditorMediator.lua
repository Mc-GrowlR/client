local BaseUIMediator = requireMediator("BaseUIMediator")
local SUIEditorMediator = class('SUIEditorMediator', BaseUIMediator)
SUIEditorMediator.NAME = "SUIEditorMediator"

function SUIEditorMediator:ctor()
    SUIEditorMediator.super.ctor(self)
end

function SUIEditorMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.SUIEditorOpen,
        noticeTable.SUIEditorClose,
    }
end

function SUIEditorMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.SUIEditorOpen == name then
        self:OpenLayer(data)
        
    elseif noticeTable.SUIEditorClose == name then
        self:CloseLayer()
    end
end

function SUIEditorMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer = requireLayerUI("test_layer/SUIEditor").create(data)
        self._type  = global.UIZ.UI_NORMAL
        
        SUIEditorMediator.super.OpenLayer(self)
    end
end

function SUIEditorMediator:CloseLayer()
    if not self._layer then
        return nil
    end
    self._layer:onClose()
    SUIEditorMediator.super.CloseLayer(self)
end

return SUIEditorMediator
