
local BaseLayer = requireLayerUI("BaseLayer")
local HeroInternalComboLayer = class("HeroInternalComboLayer", BaseLayer)

function HeroInternalComboLayer:ctor()
    HeroInternalComboLayer.super.ctor(self)
end

function HeroInternalComboLayer.create(...)
    local ui = HeroInternalComboLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function HeroInternalComboLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function HeroInternalComboLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_INTERNAL_COMBO)
    HeroInternalCombo.main(data)
    self._root = self._ui.Panel_1

    self:InitEditMode()
end

function HeroInternalComboLayer:InitEditMode()
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


return HeroInternalComboLayer

