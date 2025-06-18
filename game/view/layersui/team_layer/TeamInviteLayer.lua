local BaseLayer = requireLayerUI( "BaseLayer" )
local TeamInviteLayer = class( "TeamInviteLayer", BaseLayer )

function TeamInviteLayer:ctor()
    TeamInviteLayer.super.ctor( self )
end

function TeamInviteLayer.create(noticeData)
    local layer = TeamInviteLayer.new()
    if layer:Init(noticeData) then
        return layer
    else
        return nil
    end
end

function TeamInviteLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function TeamInviteLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TEAM_INVITE)
    TeamInvite.main()
end

return TeamInviteLayer