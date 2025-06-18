
local BaseLayer = requireLayerUI("BaseLayer")
local PlayerInternalSkillLayer = class("PlayerInternalSkillLayer", BaseLayer)

function PlayerInternalSkillLayer:ctor()
    PlayerInternalSkillLayer.super.ctor(self)
end

function PlayerInternalSkillLayer.create(...)
    local ui = PlayerInternalSkillLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end
function PlayerInternalSkillLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function PlayerInternalSkillLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_INTERNAL_SKILL)
    PlayerInternalSkill.main(data)
    self._root = self._ui.Panel_1

    self:InitEditMode()
end

function PlayerInternalSkillLayer:InitEditMode()
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


return PlayerInternalSkillLayer

