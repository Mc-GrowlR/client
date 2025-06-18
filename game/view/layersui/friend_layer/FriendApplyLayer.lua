local BaseLayer = requireLayerUI("BaseLayer")
local FriendApplyLayer = class("FriendApplyLayer",BaseLayer)


function FriendApplyLayer:ctor()
    FriendApplyLayer.super.ctor(self)
end

function FriendApplyLayer.create( data )
    local layer = FriendApplyLayer.new()
    if layer and layer:Init() then
        return layer
    end
    return nil
end

function FriendApplyLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function FriendApplyLayer:InitGUI( )
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_FRIEND_APPLY)
    FriendApply.main()
end

return FriendApplyLayer