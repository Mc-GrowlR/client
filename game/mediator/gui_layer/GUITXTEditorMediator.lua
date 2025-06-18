local BaseUIMediator = requireMediator("BaseUIMediator")
local GUITXTEditorMediator = class('GUITXTEditorMediator', BaseUIMediator)
GUITXTEditorMediator.NAME = "GUITXTEditorMediator"

function GUITXTEditorMediator:ctor()
    GUITXTEditorMediator.super.ctor(self)
end

function GUITXTEditorMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_GUITXTEditor_Open,
        noticeTable.Layer_GUITXTEditor_Close
    }
end

function GUITXTEditorMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_GUITXTEditor_Open == name then
        self:OpenLayer(data)
        
    elseif noticeTable.Layer_GUITXTEditor_Close == name then
        self:CloseLayer()
    end
end

function GUITXTEditorMediator:OpenLayer(data)
    self:setResolution({width = 1700, height = 768})

    if self._layer and not tolua.isnull(self._layer) then
        self:CloseLayer()
    else
        self._layer = nil
    end

    if not self._layer then
        self._layer = requireLayerGUI("GUITXTEditor").create(data)
        self._type  = global.UIZ.UI_MASK
        GUITXTEditorMediator.super.OpenLayer(self)

        SL.OpenGUITXTEditor = true
    end
end

function GUITXTEditorMediator:CloseLayer()
    if not self._layer then
        return false
    end

    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_BACKSPACE)
    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_ESCAPE)
    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_ENTER)
    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_KP_ENTER)

    self._layer:onClose()
    GUITXTEditorMediator.super.CloseLayer(self)

    self:setResolution(global.DesignSize_Win)

    SL.OpenGUITXTEditor = false
end

function GUITXTEditorMediator:setResolution(size)
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

return GUITXTEditorMediator
