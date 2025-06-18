
local BaseLayer = requireLayerUI("BaseLayer")
local HeroSkillLayer = class("HeroSkillLayer", BaseLayer)

function HeroSkillLayer:ctor()
    HeroSkillLayer.super.ctor(self)
end

function HeroSkillLayer.create(...)
    local ui = HeroSkillLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function HeroSkillLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function HeroSkillLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_SKILL)
    HeroSkill.main(data)
    self._root = HeroSkill._ui.Panel_1

    self:InitEditMode()
end

function HeroSkillLayer:InitEditMode()
    local items = {
        "Image_bg",
        "Image_5",
        "Button_setting",
        "ListView_cells",
    }

    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end

function HeroSkillLayer:UpdateSkillCell(data)
    HeroSkill.UpdateSkillCell(data)
end

function HeroSkillLayer:UpdateSkillCells(data)
    HeroSkill.UpdateSkillCells(data)
end

function HeroSkillLayer:RefreshSkillCells(data)
    HeroSkill.RefreshSkillCells(data)
end


return HeroSkillLayer

