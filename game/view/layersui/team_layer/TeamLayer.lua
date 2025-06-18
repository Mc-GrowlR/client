local BaseLayer = requireLayerUI( "BaseLayer" )
local TeamLayer = class( "TeamLayer", BaseLayer )

function TeamLayer:ctor()
    TeamLayer.super.ctor( self )
end

function TeamLayer.create(noticeData)
    local layer = TeamLayer.new()
    if layer:Init(noticeData) then
        return layer
    else
        return nil
    end
end

function TeamLayer:Init(data)
    return true
end

function TeamLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TEAM)
    Team.main(data.param or 1)
end

function TeamLayer:CloseLayer()
    Team.RemoveEvent()
end

return TeamLayer