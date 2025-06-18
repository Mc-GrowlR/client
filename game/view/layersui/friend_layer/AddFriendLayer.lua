
local BaseLayer = requireLayerUI("BaseLayer")
local AddFriendLayer = class("AddFriendLayer", BaseLayer)

function AddFriendLayer:ctor()
    AddFriendLayer.super.ctor(self)
end

function AddFriendLayer.create()
    local layer = AddFriendLayer.new()
    if layer and layer:Init() then
        return layer
    end
    return nil
end

function AddFriendLayer:Init()
    return true
end

function AddFriendLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_FRIEND_ADD)
    FriendAdd.main()
end

return AddFriendLayer