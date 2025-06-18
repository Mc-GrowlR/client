
local BaseLayer = requireLayerUI("BaseLayer")
local HeroTitleLayer = class("HeroTitleLayer", BaseLayer)

function HeroTitleLayer:ctor()
    HeroTitleLayer.super.ctor(self)
end

function HeroTitleLayer.create(...)
    local ui = HeroTitleLayer.new()
    if ui and ui:Init(...) then
        return ui
    end

    return nil
end

function HeroTitleLayer:Init(data)
    return true
end

function HeroTitleLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_LOOK_TITLE_WIN32)
    HeroTitle_Look.main(data)
    self._root = HeroTitle_Look._ui.Panel_1
    refPositionByParent(self)
end

function HeroTitleLayer:refresh(data)
    HeroTitle_Look.refresh(data)
end

return HeroTitleLayer