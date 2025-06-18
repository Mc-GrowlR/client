local BaseLayer = requireLayerUI("BaseLayer")
local ProtectSettingLayer = class("ProtectSettingLayer", BaseLayer)

function ProtectSettingLayer:ctor()
    ProtectSettingLayer.super.ctor(self)
end

function ProtectSettingLayer.create(...)
    local layer = ProtectSettingLayer.new()
    if layer:init(...) then
        return layer
    end
    return nil
end

function ProtectSettingLayer:init(data)
    self:InitGUI(self,data)
    return true
end

function ProtectSettingLayer:InitGUI(parent,data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SETTING_PROTECTSET)
    SettingProtectSetting.main(parent,data)
    self._quickUI =  ui_delegate(parent)
end

return ProtectSettingLayer
