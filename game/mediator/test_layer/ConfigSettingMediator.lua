local BaseUIMediator = requireMediator("BaseUIMediator")
local ConfigSettingMediator = class('ConfigSettingMediator', BaseUIMediator)
ConfigSettingMediator.NAME = "ConfigSettingMediator"

function ConfigSettingMediator:ctor()
    ConfigSettingMediator.super.ctor(self)
end

function ConfigSettingMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_ConfigSetting_Open,
        noticeTable.Layer_ConfigSetting_Close,
    }
end

function ConfigSettingMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_ConfigSetting_Open == name then
        self:OpenLayer(data)
        
    elseif noticeTable.Layer_ConfigSetting_Close == name then
        self:CloseLayer()
    end
end

function ConfigSettingMediator:OpenLayer(data)
    self:setResolution({width = 1136, height = 640})

    if not (self._layer) then
        self._layer    = SL:RequireFile("game/view/layersui/test_layer/configSetting/ConfigSettingLayer").create(data)
        self._type     = global.UIZ.UI_NORMAL
        self._escClose = true
        self._GUI_ID   = SLDefine.LAYERID.ConfigSettingGUI

        ConfigSettingMediator.super.OpenLayer(self)

        self._layer:InitGUI(data)
    end
end

function ConfigSettingMediator:CloseLayer()
    if self._layer then
        self._layer:OnClose()
        ConfigSettingMediator.super.CloseLayer(self)

        self:setResolution(global.DesignSize_Win)
    end
end

function ConfigSettingMediator:setResolution(size)
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

return ConfigSettingMediator