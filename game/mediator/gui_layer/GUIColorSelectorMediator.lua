local BaseUIMediator = requireMediator("BaseUIMediator")
local GUIColorSelectorMediator = class('GUIColorSelectorMediator', BaseUIMediator)
GUIColorSelectorMediator.NAME = "GUIColorSelectorMediator"

function GUIColorSelectorMediator:ctor()
    GUIColorSelectorMediator.super.ctor(self)
end

function GUIColorSelectorMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_GUIColorSelector_Open,
        noticeTable.Layer_GUIColorSelector_Close
    }
end

function GUIColorSelectorMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_GUIColorSelector_Open == name then
        self:OpenLayer(data)
    elseif noticeTable.Layer_GUIColorSelector_Close == name then
        self:CloseLayer()
    end
end

function GUIColorSelectorMediator:OpenLayer(data)
    if self._layer and not tolua.isnull(self._layer) then
        self:CloseLayer()
    else
        self._layer = nil
    end

    if not (self._layer) then
        self._layer = requireLayerGUI("GUIColorSelector").create(data)
        self._type = global.UIZ.UI_MASK
        GUIColorSelectorMediator.super.OpenLayer(self)
    end
end

function GUIColorSelectorMediator:CloseLayer()
    if not self._layer then
        return false
    end

    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_ESCAPE)
    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_DELETE)

    GUIColorSelectorMediator.super.CloseLayer(self)
end

return GUIColorSelectorMediator