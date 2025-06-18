
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
    return true
end

function PlayerSkillLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TRADE_PLAYER_SKILL)
    PlayerSkill_Look_TradingBank.main(data)
    self._root = PlayerSkill_Look_TradingBank._ui.Panel_1
end

function PlayerSkillLayer:UpdateSkillCell(data)
    PlayerSkill_Look_TradingBank.UpdateSkillCell(data)
end

function PlayerSkillLayer:UpdateSkillCells(data)
    PlayerSkill_Look_TradingBank.UpdateSkillCells(data)
end

function PlayerSkillLayer:RefreshSkillCells(data)
    PlayerSkill_Look_TradingBank.RefreshSkillCells(data)
end


return PlayerSkillLayer

