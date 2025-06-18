local BaseLayer = requireLayerUI("BaseLayer")
local TeamApplyLayer = class("TeamApplyLayer", BaseLayer)

function TeamApplyLayer:ctor()
end

function TeamApplyLayer.create()
    local layer = TeamApplyLayer.new()
    if layer:Init() then
        return layer
    else
        return nil
    end
end

function TeamApplyLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function TeamApplyLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TEAM_APPLY)
    TeamApply.main()

    return true
end

return TeamApplyLayer