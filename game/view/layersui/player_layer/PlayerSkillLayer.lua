
local BaseLayer = requireLayerUI("BaseLayer")
local PlayerSkillLayer = class("PlayerSkillLayer", BaseLayer)

function PlayerSkillLayer:ctor()
    PlayerSkillLayer.super.ctor(self)
end

function PlayerSkillLayer.create(...)
    local ui = PlayerSkillLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end
function PlayerSkillLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function PlayerSkillLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_SKILL)
    PlayerSkill.main(data)
    self._root = PlayerSkill._ui.Panel_1

    self:InitEditMode()
end

function PlayerSkillLayer:InitEditMode()
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

function PlayerSkillLayer:UpdateSkillCell(data)
    PlayerSkill.UpdateSkillCell(data)
end

function PlayerSkillLayer:UpdateSkillCells(data)
    PlayerSkill.UpdateSkillCells(data)
end

function PlayerSkillLayer:RefreshSkillCells(data)
    PlayerSkill.RefreshSkillCells(data)
end


return PlayerSkillLayer

