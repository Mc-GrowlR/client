
local BaseLayer = requireLayerUI("BaseLayer")
local HeroTitleLayer = class("HeroTitleLayer", BaseLayer)

function HeroTitleLayer:ctor()
    HeroTitleLayer.super.ctor(self)
end

function HeroTitleLayer.create(...)
    local ui = HeroTitleLayer.new()
    if ui and ui:Init(...) then
        return ui
    end

    return nil
end

function HeroTitleLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function HeroTitleLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_TITLE)
    HeroTitle.main(data)
    self._root = HeroTitle._ui.Panel_1

    self:InitEditMode()
end

function HeroTitleLayer:InitEditMode()
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

function HeroTitleLayer:refresh(data)
    HeroTitle.refresh(data)
end

return HeroTitleLayer