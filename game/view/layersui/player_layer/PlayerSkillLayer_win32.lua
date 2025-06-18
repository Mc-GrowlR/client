
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
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_SKILL_WIN32)
    PlayerSkill.main(data)
    self._root = PlayerSkill._ui.Panel_1
    refPositionByParent(self)

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

function PlayerSkillLayer:RegisterNodeMovable(skillID,deleteChange)
    local skillKey = SL:GetMetaValue("SKILL_KEY", skillID)  
    local skillMoveMain = (tonumber(SL:GetMetaValue("GAME_DATA", "skill_move_main")) or 1) == 1 
    if skillKey ~= 0 and skillMoveMain then
        local cell = PlayerSkill._cells[skillID]
        if not PlayerSkill._moveIconCells[skillID] or tolua.isnull(PlayerSkill._moveIconCells[skillID]) then
            PlayerSkill._moveIconCells[skillID] = cell.Image_icon
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            local param = {}
            param.nodeFrom = ItemMoveProxy.ItemFrom.SKILL_WIN
            param.moveNode = PlayerSkill._moveIconCells[skillID]
            param.skillId  = skillID
            param.cancelMoveCall = function()
                if PlayerSkill._moveIconCells[skillID] and not tolua.isnull(PlayerSkill._moveIconCells[skillID]) then
                    PlayerSkill._moveIconCells[skillID]._movingState = false
                end
            end
            PlayerSkill._moveIconCells[skillID]:setTouchEnabled(true)
            RegisterNodeMovable(PlayerSkill._moveIconCells[skillID],param) 
        end
    else
        if PlayerSkill._moveIconCells[skillID] and not deleteChange then
            PlayerSkill._moveIconCells[skillID] = nil
            global.Facade:sendNotification(global.NoticeTable.TopTouch_Remove_Child, {skill = skillID})
        end
    end
end

return PlayerSkillLayer

