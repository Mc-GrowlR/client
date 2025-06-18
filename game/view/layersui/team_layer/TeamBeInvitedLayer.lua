local BaseLayer = requireLayerUI("BaseLayer")
local TeamBeInvitedLayer = class("TeamBeInvitedLayer", BaseLayer)

function TeamBeInvitedLayer:ctor()
end

function TeamBeInvitedLayer.create(...)
    local layer = TeamBeInvitedLayer.new()
    if layer:Init(...) then
        return layer
    else
        return nil
    end
end

function TeamBeInvitedLayer:Init()
    return true
end

function TeamBeInvitedLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TEAM_BEINVITED_POP)
    TeamBeInvitedPop.main(data)
end

return TeamBeInvitedLayer