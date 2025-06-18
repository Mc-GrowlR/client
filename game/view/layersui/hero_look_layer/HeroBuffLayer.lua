
local BaseLayer = requireLayerUI("BaseLayer")
local HeroBuffLayer = class("HeroBuffLayer", BaseLayer)

function HeroBuffLayer:ctor()
    HeroBuffLayer.super.ctor(self)
end

function HeroBuffLayer.create(...)
    local ui = HeroBuffLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function HeroBuffLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function HeroBuffLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_LOOK_BUFF)
    HeroBuff_Look.main(data)

    self._root = self._ui.Panel_1
end

function HeroBuffLayer:OnClose()
    if HeroBuff_Look and HeroBuff_Look.OnClose then
        HeroBuff_Look.OnClose()
    end
end


return HeroBuffLayer

