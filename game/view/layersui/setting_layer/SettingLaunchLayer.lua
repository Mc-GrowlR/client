local BaseLayer = requireLayerUI("BaseLayer")
local SettingLaunchLayer = class("SettingLaunchLayer", BaseLayer)

function SettingLaunchLayer:ctor()
    SettingLaunchLayer.super.ctor(self)
end

function SettingLaunchLayer.create(...)
    local layer = SettingLaunchLayer.new()
    if layer:init(...) then
        return layer
    end
    return nil
end

function SettingLaunchLayer:init(data)
    self._ui = ui_delegate(self)
    return true
end

function SettingLaunchLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SETTING_LAUNCH)
    SettingLaunch.main()
end

function SettingLaunchLayer:GetSUIParent()
    return self._ui.Panel_1
end

return SettingLaunchLayer
