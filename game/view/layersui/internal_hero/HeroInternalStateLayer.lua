
local BaseLayer = requireLayerUI("BaseLayer")
local HeroInternalStateLayer = class("HeroInternalStateLayer", BaseLayer)

function HeroInternalStateLayer:ctor()
    HeroInternalStateLayer.super.ctor(self)
end

function HeroInternalStateLayer:Init()
    return true
end

function HeroInternalStateLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_INTERNAL_STATE)
    HeroInternalState.main(data)
    self._ui = ui_delegate(self)
    self._root = self._ui.Panel_1
    self:InitEditMode()
end

function HeroInternalStateLayer:InitEditMode()
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

return HeroInternalStateLayer