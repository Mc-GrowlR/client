local BaseUIMediator = requireMediator("BaseUIMediator")
local GUIEditorMediator = class('GUIEditorMediator', BaseUIMediator)
GUIEditorMediator.NAME = "GUIEditorMediator"

function GUIEditorMediator:ctor()
    GUIEditorMediator.super.ctor(self)
end

function GUIEditorMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_GUIEditor_Open,
        noticeTable.Layer_GUIEditor_Close
    }
end

function GUIEditorMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_GUIEditor_Open == name then
        self:OpenLayer(data)
        
    elseif noticeTable.Layer_GUIEditor_Close == name then
        self:CloseLayer()
    end
end

function GUIEditorMediator:OpenLayer(data)
    self:setResolution({width = 1700, height = 768})

    if self._layer and not tolua.isnull(self._layer) then
        self:CloseLayer()
    else
        self._layer = nil
    end

    if not self._layer then
        self._layer = requireLayerGUI("GUIEditor").create(data)
        self._type  = global.UIZ.UI_MASK
        GUIEditorMediator.super.OpenLayer(self)
    end
end

function GUIEditorMediator:CloseLayer()
    if not self._layer then
        return false
    end

    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_BACKSPACE)
    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_ESCAPE)
    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_ENTER)
    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_KP_ENTER)
    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_DELETE)

    self._layer:onClose()
    GUIEditorMediator.super.CloseLayer(self)

    self:setResolution(global.DesignSize_Win)
end

function GUIEditorMediator:setResolution(size)
    if not global.isWindows then
        return false
    end

    local glview = global.Director:getOpenGLView()
    glview:setFrameSize(size.width, size.height)
    glview:setFrameZoomFactor(global.DeviceZoom_Win)

    local data = {}
    data.rType = global.DesignPolicy
    data.size  = size
    global.Facade:sendNotification( global.NoticeTable.ChangeResolution, data)
end

return GUIEditorMediator
