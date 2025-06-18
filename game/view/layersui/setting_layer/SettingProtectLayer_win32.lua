local BaseLayer = requireLayerUI("BaseLayer")
local SettingProtectLayer = class("SettingProtectLayer", BaseLayer)

function SettingProtectLayer:ctor()
    SettingProtectLayer.super.ctor(self)
end

function SettingProtectLayer.create(...)
    local layer = SettingProtectLayer.new()
    if layer:init(...) then
        return layer
    end
    return nil
end

function SettingProtectLayer:init(data)
    self._ui = ui_delegate(self)
    return true
end

function SettingProtectLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SETTING_PROTECT_WIN32)
    SettingProtect.main()
    refPositionByParent(self)
end

function SettingProtectLayer:GetSUIParent()
    return self._ui.Panel_1
end

return SettingProtectLayer
