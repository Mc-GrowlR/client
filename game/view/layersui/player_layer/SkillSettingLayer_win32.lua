local BaseLayer = requireLayerUI("BaseLayer")
local SkillSettingLayer = class("SkillSettingLayer", BaseLayer)

function  SkillSettingLayer:ctor()
    SkillSettingLayer.super.ctor(self)
end

function SkillSettingLayer.create(...)
    local ui = SkillSettingLayer.new()

    if ui and ui:Init(...) then
        return ui
    end

    return nil
end

function SkillSettingLayer:Init(data)
    return true
end

function SkillSettingLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_SKILL_SETTING_WIN32)
    PlayerSkillSetting.main(data)
    self._root = PlayerSkillSetting._ui.Panel_1
    refPositionByParent(self)
end

return SkillSettingLayer