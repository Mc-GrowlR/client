local BaseUIMediator = requireMediator("BaseUIMediator")
local PreviewAnimMediator = class('PreviewAnimMediator', BaseUIMediator)
PreviewAnimMediator.NAME = "PreviewAnimMediator"

function PreviewAnimMediator:ctor()
    PreviewAnimMediator.super.ctor(self)
end

function PreviewAnimMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
    {
        noticeTable.PreviewAnimOpen,
        noticeTable.PreviewAnimClose
    }
end

function PreviewAnimMediator:handleNotification(notification)
    local noticeName  = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData  = notification:getBody()
    
    if noticeTable.PreviewAnimOpen == noticeName then
        self:Open()

    elseif noticeTable.PreviewAnimClose == noticeName then
        self:Close()
    end
end

function PreviewAnimMediator:Open()
    self:setResolution({width = 1136, height = 640})

    if self._layer and not tolua.isnull(self._layer) then
        self:CloseLayer()
    else
        self._layer = nil
    end

    if not self._layer then
        self._layer = requireLayerUI("test_layer/PreviewAnimLayout").create()
        self._type = global.UIZ.UI_TOBOX
        PreviewAnimMediator.super.OpenLayer(self)
    end
end

function PreviewAnimMediator:Close()
    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_ESCAPE)
    PreviewAnimMediator.super.CloseLayer(self)

    self:setResolution(global.DesignSize_Win)
end

function PreviewAnimMediator:setResolution(size)
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

return PreviewAnimMediator
