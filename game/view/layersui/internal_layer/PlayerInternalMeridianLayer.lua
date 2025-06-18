
local BaseLayer = requireLayerUI("BaseLayer")
local PlayerInternalMeridianLayer = class("PlayerInternalMeridianLayer", BaseLayer)

function PlayerInternalMeridianLayer:ctor()
    PlayerInternalMeridianLayer.super.ctor(self)
    self._proxy = global.Facade:retrieveProxy(global.ProxyTable.MeridianProxy)
end

function PlayerInternalMeridianLayer.create()
    local layer = PlayerInternalMeridianLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function PlayerInternalMeridianLayer:Init()
    return true
end

function PlayerInternalMeridianLayer:InitGUI(data)
    self._proxy:RequestGetMeridianInfo()
    
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_INTERNAL_MERIDIAN)
    PlayerInternalMeridian.main(data)
    self._ui = ui_delegate(self)
    self._root = self._ui.Panel_1
    self:InitEditMode()
end

function PlayerInternalMeridianLayer:InitEditMode()
    local items = {
        "Image_bg",
        "Image_show",
        "Button_1",
        "Button_2",
        "Button_3",
        "Button_4",
        "Button_5",
        "ListView_cells",
    }
    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end

return PlayerInternalMeridianLayer