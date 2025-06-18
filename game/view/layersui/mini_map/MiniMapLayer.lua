local BaseLayer = requireLayerUI("BaseLayer")
local MiniMapLayer = class("MiniMapLayer", BaseLayer)

function MiniMapLayer:ctor()
    MiniMapLayer.super.ctor(self)
end

function MiniMapLayer.create()
    local layer = MiniMapLayer.new()
    if layer:Init() then
        return layer
    else
        return nil
    end
end

function MiniMapLayer:Init()
    return true
end

function MiniMapLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MINIMAP)
    MiniMap.main()
    self._ui = ui_delegate(self)
    self._layout = self._ui["Panel_1"]

    self:InitEditMode()
end

function MiniMapLayer:OnClose()
    MiniMap.close()
end

function MiniMapLayer:InitEditMode()
    local items = 
    {
        "FrameBG",
        "DressIMG",
        "TitleText",
        "CloseButton",
        "Image_mapNameBG",
        "Text_mapName",
        "Panel_map"
    }
    if global.isWinPlayMode then
        items = {
            "Panel_map",
            "Text_mouse_pos"
        }
    end
    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end

return MiniMapLayer
