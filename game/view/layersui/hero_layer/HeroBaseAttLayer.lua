
local BaseLayer = requireLayerUI("BaseLayer")
local HeroBaseAttLayer = class("HeroBaseAttLayer", BaseLayer)

function HeroBaseAttLayer:ctor()
    HeroBaseAttLayer.super.ctor(self)
end

function HeroBaseAttLayer:Init(data)
    return true
end

function HeroBaseAttLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_BASE_ATT)
    HeroBaseAtt.main(data)
    self._root = HeroBaseAtt._ui.Panel_1
    self._ui = ui_delegate(self)
    self:InitEditMode()
end

function HeroBaseAttLayer:UpdateBaseAttriLayer(data)
    HeroBaseAtt.UpdateBaseAttri()
end

function HeroBaseAttLayer:InitEditMode()
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

return HeroBaseAttLayer