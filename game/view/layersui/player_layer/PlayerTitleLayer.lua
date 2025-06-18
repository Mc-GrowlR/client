
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
    self._ui = ui_delegate(self)
    return true
end

function PlayerTitleLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_TITLE)
    PlayerTitle.main(data)
    self._root = PlayerTitle._ui.Panel_1

    self:InitEditMode()
end

function PlayerTitleLayer:InitEditMode()
    local items = {
        "Image_1",
        "Image_cur",
        "Button_curTitle",
        "Image_11",
        "Text_curTitle",
        "Image_12",
        "ListView_cells",
    }

    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end

function PlayerTitleLayer:refresh(data)
    PlayerTitle.refresh(data)
end

return PlayerTitleLayer