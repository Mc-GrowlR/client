local BaseLayer = requireLayerUI( "BaseLayer" )
local NearPlayerLayer = class( "NearPlayerLayer", BaseLayer )

function NearPlayerLayer:ctor()
    NearPlayerLayer.super.ctor( self )
end

function NearPlayerLayer.create(noticeData)
    local layer = NearPlayerLayer.new()
    if layer:Init(noticeData) then
        return layer
    else
        return nil
    end
end

function NearPlayerLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function NearPlayerLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_NEAR_PLAYER)
    NearPlayer.main()

end

return NearPlayerLayer