local BaseLayer = requireLayerUI("BaseLayer")
local SkillPanel = class("SkillPanel", BaseLayer)
function SkillPanel:ctor()
    SkillPanel.super.ctor(self)
end

function SkillPanel.create(...)
    local layer = SkillPanel.new()
    if layer:init(...) then
        return layer
    end
    return nil
end

function SkillPanel:init(data)
    self:InitGUI(self,data)
    return true
end

function SkillPanel:InitGUI(parent,data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SETTING_SKILL_PANEl)
    SettingSkillPanel.main(parent,data)
    self._quickUI =  ui_delegate(parent)
end

return SkillPanel
