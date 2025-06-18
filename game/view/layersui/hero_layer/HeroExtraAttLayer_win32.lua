
local BaseLayer = requireLayerUI("BaseLayer")
local HeroExtraAttLayer = class("HeroExtraAttLayer", BaseLayer)

function HeroExtraAttLayer:ctor()
    HeroExtraAttLayer.super.ctor(self)
end


function HeroExtraAttLayer.create(...)
    local ui = HeroExtraAttLayer.new()
    if ui and ui:Init(...) then
        return ui
    end

    return nil
end

function HeroExtraAttLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function HeroExtraAttLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_EXTRA_ATT_WIN32)
    HeroExtraAtt.main(data)
    self._root = HeroExtraAtt._ui.Panel_1
    refPositionByParent(self)

    self:InitEditMode()
end

function HeroExtraAttLayer:InitEditMode()
    local items = {
        "Image_1",
        "ListView_extraAtt"
    }
    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end

--刷新 属性
function HeroExtraAttLayer:OnRefreshAttri()
    HeroExtraAtt.UpdateBaseAttri()
end
-- 刷新HP MP属性
function HeroExtraAttLayer:OnRefreshHPMP()
    HeroExtraAtt.OnRefreshHPMP()
end
-- 刷新HP MP属性
function HeroExtraAttLayer:OnClose()
    HeroExtraAtt.CloseCallback()
end
return HeroExtraAttLayer