
local BaseLayer = requireLayerUI("BaseLayer")
local PlayerInternalComboLayer = class("PlayerInternalComboLayer", BaseLayer)

function PlayerInternalComboLayer:ctor()
    PlayerInternalComboLayer.super.ctor(self)
end

function PlayerInternalComboLayer.create(...)
    local ui = PlayerInternalComboLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function PlayerInternalComboLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function PlayerInternalComboLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_INTERNAL_COMBO)
    PlayerInternalCombo.main(data)
    self._root = self._ui.Panel_1

    self:InitEditMode()
end

function PlayerInternalComboLayer:InitEditMode()
    local items = {
        "Image_bg",
        "icon_1",
        "icon_2",
        "icon_3",
        "icon_4",
        "ListView_cells",
    }

    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end


return PlayerInternalComboLayer

