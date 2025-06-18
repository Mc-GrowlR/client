
local BaseLayer = requireLayerUI("BaseLayer")
local PlayerInternalStateLayer = class("PlayerInternalStateLayer", BaseLayer)

function PlayerInternalStateLayer:ctor()
    PlayerInternalStateLayer.super.ctor(self)
end

function PlayerInternalStateLayer:Init()
    return true
end

function PlayerInternalStateLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_INTERNAL_STATE)
    PlayerInternalState.main(data)
    self._ui = ui_delegate(self)
    self._root = self._ui.Panel_1
    self:InitEditMode()
end

function PlayerInternalStateLayer:InitEditMode()
    local items = {
        "Image_1",
        "Image_title",
        "ListView_state",
    }
    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end

return PlayerInternalStateLayer