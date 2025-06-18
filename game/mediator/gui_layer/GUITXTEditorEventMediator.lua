local BaseUIMediator = requireMediator("BaseUIMediator")
local GUITXTEditorEventMediator = class('GUITXTEditorEventMediator', BaseUIMediator)
GUITXTEditorEventMediator.NAME = "GUITXTEditorEventMediator"

function GUITXTEditorEventMediator:ctor()
    GUITXTEditorEventMediator.super.ctor(self)
end

function GUITXTEditorEventMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_GUITXTEditorEvent_Open,
        noticeTable.Layer_GUITXTEditorEvent_Close
    }
end

function GUITXTEditorEventMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_GUITXTEditorEvent_Open == name then
        self:OpenLayer(data)
    elseif noticeTable.Layer_GUITXTEditorEvent_Close == name then
        self:CloseLayer()
    end
end

function GUITXTEditorEventMediator:OpenLayer(data)
    if self._layer and not tolua.isnull(self._layer) then
        self:CloseLayer()
    else
        self._layer = nil
    end

    if not (self._layer) then
        self._layer = requireLayerGUI("GUITXTEditorEvent").create(data)
        self._type = global.UIZ.UI_MASK
        GUITXTEditorEventMediator.super.OpenLayer(self)
    end
end

function GUITXTEditorEventMediator:CloseLayer()
    if not self._layer then
        return false
    end

    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_ESCAPE)

    GUITXTEditorEventMediator.super.CloseLayer(self)
end

return GUITXTEditorEventMediator