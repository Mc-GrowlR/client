local BaseLayer = requireLayerUI("BaseLayer")
local SkillRankPanel = class("SkillRankPanel", BaseLayer)

function SkillRankPanel:ctor()
    SkillRankPanel.super.ctor(self)
end

function SkillRankPanel.create(...)
    local layer = SkillRankPanel.new()
    if layer:init(...) then
        return layer
    end
    return nil
end

function SkillRankPanel:init(data)
    self:InitGUI(self,data)
    return true
end

function SkillRankPanel:InitGUI(parent,data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SETTING_SKILL_RANK)
    SettingSkillRank.main(parent,data)
    self._quickUI =  ui_delegate(parent)
end
function SkillRankPanel:OnClose()
    SettingSkillRank.CloseCallback()
end


return SkillRankPanel
