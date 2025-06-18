local BaseLayer = requireLayerUI("BaseLayer")
local PickSettingLayer = class("PickSettingLayer", BaseLayer)

function PickSettingLayer:ctor()
    PickSettingLayer.super.ctor(self)
end

function PickSettingLayer.create(...)
    local layer = PickSettingLayer.new()
    if layer:init(...) then
        return layer
    end
    return nil
end

function PickSettingLayer:init(data)
    self:InitGUI(self,data)
    return true
end

function PickSettingLayer:InitGUI(parent,data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SETTING_PICK_SETTING_WIN32)
    SettingPickSetting.main(parent,data)
    self._quickUI =  ui_delegate(parent)
    refPositionByParent(self)
end

return PickSettingLayer
