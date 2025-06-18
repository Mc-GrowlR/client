
local BaseLayer = requireLayerUI("BaseLayer")
local PlayerBaseAttLayer = class("PlayerBaseAttLayer", BaseLayer)

function PlayerBaseAttLayer:ctor()
    PlayerBaseAttLayer.super.ctor(self)
end

function PlayerBaseAttLayer:Init(data)
    return true
end

function PlayerBaseAttLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_BASE_ATT_WIN32)
    PlayerBaseAtt.main(data)
    self._root = PlayerBaseAtt._ui.Panel_1
    refPositionByParent(self)
    self._ui = ui_delegate(self)
    self:InitEditMode()
end

function PlayerBaseAttLayer:UpdateBaseAttriLayer(data)
    PlayerBaseAtt.UpdateBaseAttri()
end

function PlayerBaseAttLayer:InitEditMode()
    local items = {
        "Image_1",
        "ListView_base",
    }
    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end

return PlayerBaseAttLayer