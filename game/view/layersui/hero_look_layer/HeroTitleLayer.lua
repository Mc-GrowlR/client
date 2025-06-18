
local BaseLayer = requireLayerUI("BaseLayer")
local PlayerTitleLayer = class("PlayerTitleLayer", BaseLayer)

function PlayerTitleLayer:ctor()
    PlayerTitleLayer.super.ctor(self)
end

function PlayerTitleLayer.create(...)
    local ui = PlayerTitleLayer.new()
    if ui and ui:Init(...) then
        return ui
    end

    return nil
end

function PlayerTitleLayer:Init(data)
    return true
end

function PlayerTitleLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_LOOK_TITLE)
    HeroTitle_Look.main(data)
    self._root = HeroTitle_Look._ui.Panel_1
end

function PlayerTitleLayer:refresh(data)
    HeroTitle_Look.refresh(data)
end

return PlayerTitleLayer