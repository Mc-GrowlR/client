
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
    return true
end

function HeroSkillLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TRADE_HERO_SKILL)
    HeroSkill_Look_TradingBank.main(data)
    self._root = HeroSkill_Look_TradingBank._ui.Panel_1
end

function HeroSkillLayer:UpdateSkillCell(data)
    HeroSkill_Look_TradingBank.UpdateSkillCell(data)
end

function HeroSkillLayer:UpdateSkillCells(data)
    HeroSkill_Look_TradingBank.UpdateSkillCells(data)
end

function HeroSkillLayer:RefreshSkillCells(data)
    HeroSkill_Look_TradingBank.RefreshSkillCells(data)
end


return HeroSkillLayer

