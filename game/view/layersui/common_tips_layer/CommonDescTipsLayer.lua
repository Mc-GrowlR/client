local BaseLayer = requireLayerUI( "BaseLayer" )
local CommonDescTipsLayer = class( "CommonDescTipsLayer", BaseLayer )

local RichTextHelp = require( "util/RichTextHelp" )

function  CommonDescTipsLayer:ctor()
    CommonDescTipsLayer.super.ctor( self )
end

function CommonDescTipsLayer.create(noticeData)
    local layer = CommonDescTipsLayer.new()
    if layer:Init(noticeData) then
        return layer
    else
        return nil
    end
end

function CommonDescTipsLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function CommonDescTipsLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_COMMON_DESC_TIPS)
    CommonDescTips.main(data)
end

return CommonDescTipsLayer