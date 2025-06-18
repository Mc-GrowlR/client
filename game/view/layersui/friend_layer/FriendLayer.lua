
local BaseLayer = requireLayerUI("BaseLayer")
local FriendLayer = class("FriendLayer", BaseLayer)

function FriendLayer:ctor()
    FriendLayer.super.ctor(self)
end

function FriendLayer.create( data )
    local layer = FriendLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function FriendLayer:Init( data )
    self._ui = ui_delegate(self)
    return true
end

function FriendLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_FRIEND)
    Friend.main(data.param or 1)
end

function FriendLayer:CloseLayer()
    Friend.RemoveEvent()
end

return FriendLayer