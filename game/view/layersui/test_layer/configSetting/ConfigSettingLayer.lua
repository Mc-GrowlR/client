local BaseLayer = requireLayerUI("BaseLayer")
local ConfigSettingLayer = class("ConfigSettingLayer", BaseLayer)

function ConfigSettingLayer:ctor()
    ConfigSettingLayer.super.ctor(self)
end

function ConfigSettingLayer.create(...)
    local layer = ConfigSettingLayer.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function ConfigSettingLayer:Init()
    return true
end

function ConfigSettingLayer:InitGUI(index)
    SL:RequireFile("game/view/layersui/test_layer/configSetting/configLayout/ConfigSetting")
    ConfigSetting.main(index)
end

function ConfigSettingLayer:OnClose()
    if ConfigSetting then
        ConfigSetting.onClose()
    end
end

function loadConfigSettingExport(parent, filename)
    local luafile = "game/view/layersui/test_layer/configSetting/configExport/" .. filename
    local file = SL:RequireFile(luafile)
    file.init(parent)
end

return ConfigSettingLayer
