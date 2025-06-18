local BaseUIMediator = requireMediator("BaseUIMediator")
local PreviewSkillMediator = class('PreviewSkillMediator', BaseUIMediator)
PreviewSkillMediator.NAME = "PreviewSkillMediator"

function PreviewSkillMediator:ctor()
    PreviewSkillMediator.super.ctor(self)
end

function PreviewSkillMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
    {
        noticeTable.PreviewSkillOpen,
        noticeTable.PreviewSkillClose,
    }
end

function PreviewSkillMediator:handleNotification(notification)
    local noticeName  = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData  = notification:getBody()
    
    if noticeTable.PreviewSkillOpen == noticeName then
        self:Open()

    elseif noticeTable.PreviewSkillClose == noticeName then
        self:Close()

    end
end

function PreviewSkillMediator:Open()
    if not self._layer then
        self:setResolution(cc.size(1136, 640))
        self._layer = requireLayerUI("test_layer/PreviewSkillLayout").create()
        self._type = global.UIZ.UI_TOBOX
        PreviewSkillMediator.super.OpenLayer(self)
    end
end

function PreviewSkillMediator:Close()
    if self._layer then
        self._layer:OnClose()
        self:setResolution(global.DesignSize_Win)
    end
    PreviewSkillMediator.super.CloseLayer(self)
end


function PreviewSkillMediator:setResolution(size)
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

return PreviewSkillMediator
