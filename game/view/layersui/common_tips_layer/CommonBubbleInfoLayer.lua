local BaseLayer = requireLayerUI( "BaseLayer" )
local CommonBubbleInfoLayer = class( "CommonBubbleInfoLayer", BaseLayer )

function CommonBubbleInfoLayer:ctor()
    CommonBubbleInfoLayer.super.ctor( self )
end

function CommonBubbleInfoLayer.create(noticeData)
    local layer = CommonBubbleInfoLayer.new()

    if layer:Init(noticeData) then
        return layer
    else
        return nil
    end
end

function CommonBubbleInfoLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function CommonBubbleInfoLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_COMMON_BUBBLE_INFO)
    CommonBubbleInfo.main(data)

end

return CommonBubbleInfoLayer