local BaseLayer = requireLayerUI("BaseLayer")
local SettingWindowRangeLayer = class("SettingWindowRangeLayer", BaseLayer)

function SettingWindowRangeLayer:ctor()
    SettingWindowRangeLayer.super.ctor(self)
end

function SettingWindowRangeLayer.create(...)
    local layer = SettingWindowRangeLayer.new()
    if layer:init(...) then
        return layer
    end
    return nil
end

function SettingWindowRangeLayer:init(data)
    self._ui = ui_delegate(self)
    return true
end

function SettingWindowRangeLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SETTING_WINRANGE)
    SettingWinRange.main()
end

function SettingWindowRangeLayer:GetSUIParent()
    return self._ui.Panel_bg
end

return SettingWindowRangeLayer
