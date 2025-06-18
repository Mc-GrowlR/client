local DeviceRotationChangedCommand = class("DeviceRotationChangedCommand", framework.SimpleCommand)

function DeviceRotationChangedCommand:ctor()
end

function DeviceRotationChangedCommand:execute(notification)
    global.Facade:sendNotification(global.NoticeTable.DRotationChanged)
    SLBridge:onLUAEvent(LUA_EVENT_DEVICE_ROTATION_CHANGED)
end

return DeviceRotationChangedCommand
