local BaseUIMediator = requireMediator("BaseUIMediator")
local ExtraColorEditorMediator = class('ExtraColorEditorMediator', BaseUIMediator)
ExtraColorEditorMediator.NAME = "ExtraColorEditorMediator"

function ExtraColorEditorMediator:ctor()
    ExtraColorEditorMediator.super.ctor(self)
end

function ExtraColorEditorMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_ExtraColorEditor_Open,
        noticeTable.Layer_ExtraColorEditor_Close
    }
end

function ExtraColorEditorMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_ExtraColorEditor_Open == name then
        self:OpenLayer(data)
        
    elseif noticeTable.Layer_ExtraColorEditor_Close == name then
        self:CloseLayer()
    end
end

function ExtraColorEditorMediator:OpenLayer(data)
    if self._layer and not tolua.isnull(self._layer) then
        self:CloseLayer()
    else
        self._layer = nil
    end

    if not self._layer then
        self._layer = requireLayerGUI("ExtraColorEditor").create(data)
        self._type  = global.UIZ.UI_MASK
        ExtraColorEditorMediator.super.OpenLayer(self)
    end
end

function ExtraColorEditorMediator:CloseLayer()
    if not self._layer then
        return false
    end

    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_ESCAPE)

    ExtraColorEditorMediator.super.CloseLayer(self)
end

return ExtraColorEditorMediator
