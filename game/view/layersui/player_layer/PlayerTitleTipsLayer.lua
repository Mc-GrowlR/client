local BaseLayer = requireLayerUI( "BaseLayer" )
local PlayerTitleTipsLayer = class( "PlayerTitleTipsLayer", BaseLayer )
local RichTextHelp = require("util/RichTextHelp")

function  PlayerTitleTipsLayer:ctor()
    PlayerTitleTipsLayer.super.ctor( self )
end

function PlayerTitleTipsLayer.create(data)
    local layer = PlayerTitleTipsLayer.new()

    if layer:Init(data) then
        return layer
    else
        return nil
    end
end

function PlayerTitleTipsLayer:Init(data)
    return true
end

function PlayerTitleTipsLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TITLE_TIPS)
    TitleTips.main(data)
end

function PlayerTitleTipsLayer:InitLayer(data)
    TitleTips.InitLayer(data)
end

return PlayerTitleTipsLayer