local BaseUIMediator = requireMediator("BaseUIMediator")
local GUIResSelectorMediator = class('GUIResSelectorMediator', BaseUIMediator)
GUIResSelectorMediator.NAME = "GUIResSelectorMediator"

function GUIResSelectorMediator:ctor()
    GUIResSelectorMediator.super.ctor(self)
end

function GUIResSelectorMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_GUIResSelector_Open,
        noticeTable.Layer_GUIResSelector_Close
    }
end

function GUIResSelectorMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_GUIResSelector_Open == name then
        self:OpenLayer(data)
    elseif noticeTable.Layer_GUIResSelector_Close == name then
        self:CloseLayer()
    end
end

function GUIResSelectorMediator:OpenLayer(data)
    if self._layer and not tolua.isnull(self._layer) then
        self:CloseLayer()
    else
        self._layer = nil
    end

    if not (self._layer) then
        self._layer = requireLayerGUI("GUIResSelector").create(data)
        self._type = global.UIZ.UI_MASK
        GUIResSelectorMediator.super.OpenLayer(self)
    end
end

function GUIResSelectorMediator:CloseLayer()
    if not self._layer then
        return false
    end

    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_BACKSPACE)
    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_ESCAPE)
    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_ENTER)
    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_KP_ENTER)
    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_DELETE)

    GUIResSelectorMediator.super.CloseLayer(self)
end

return GUIResSelectorMediator