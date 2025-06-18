
local BaseLayer = requireLayerUI("BaseLayer")
local HeroInternalMeridianLayer = class("HeroInternalMeridianLayer", BaseLayer)

function HeroInternalMeridianLayer:ctor()
    HeroInternalMeridianLayer.super.ctor(self)
    self._proxy = global.Facade:retrieveProxy(global.ProxyTable.MeridianProxy)
end

function HeroInternalMeridianLayer:Init()
    return true
end

function HeroInternalMeridianLayer:InitGUI(data)
    self._proxy:RequestGetMeridianInfo(true)

    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_INTERNAL_MERIDIAN)
    HeroInternalMeridian.main(data)
    self._ui = ui_delegate(self)
    self._root = self._ui.Panel_1
    self:InitEditMode()
end

function HeroInternalMeridianLayer:InitEditMode()
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

return HeroInternalMeridianLayer