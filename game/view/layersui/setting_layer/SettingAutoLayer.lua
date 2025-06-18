local BaseLayer = requireLayerUI("BaseLayer")
local SettingAutoLayer = class("SettingAutoLayer", BaseLayer)

function SettingAutoLayer:ctor()
    SettingAutoLayer.super.ctor(self)
end

function SettingAutoLayer.create(...)
    local layer = SettingAutoLayer.new()
    if layer:init(...) then
        return layer
    end
    return nil
end

function SettingAutoLayer:init(data)
    self._ui = ui_delegate(self)
    return true
end

function SettingAutoLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SETTING_AUTO)
    SettingAuto.main()
end

function SettingAutoLayer:OnClose()
    SettingAuto.CloseCallback()
end

function SettingAutoLayer:GetSUIParent()
    return self._ui.Panel_1
end

return SettingAutoLayer
