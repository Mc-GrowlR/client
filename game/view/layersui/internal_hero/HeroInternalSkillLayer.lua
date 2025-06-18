
local BaseLayer = requireLayerUI("BaseLayer")
local HeroInternalSkillLayer = class("HeroInternalSkillLayer", BaseLayer)

function HeroInternalSkillLayer:ctor()
    HeroInternalSkillLayer.super.ctor(self)
end

function HeroInternalSkillLayer.create(...)
    local ui = HeroInternalSkillLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end
function HeroInternalSkillLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function HeroInternalSkillLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_INTERNAL_SKILL)
    HeroInternalSkill.main(data)
    self._root = HeroInternalSkill._ui.Panel_1

    self:InitEditMode()
end

function HeroInternalSkillLayer:InitEditMode()
    local items = {
        "Image_bg",
        "ListView_cells",
    }

    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end


return HeroInternalSkillLayer

