
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
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_LOOK_TITLE_WIN32)
    PlayerTitle_Look.main(data)
    self._root = PlayerTitle_Look._ui.Panel_1
    refPositionByParent(self)
end

function PlayerTitleLayer:refresh(data)
    PlayerTitle_Look.refresh(data)
end

return PlayerTitleLayer