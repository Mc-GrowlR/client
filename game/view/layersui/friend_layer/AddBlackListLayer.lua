local BaseLayer = requireLayerUI("BaseLayer")
local AddBlackListLayer = class("AddBlackListLayer", BaseLayer)

function AddBlackListLayer:ctor()
    self._friend_porxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)

    AddBlackListLayer.super.ctor(self)
end

function AddBlackListLayer.create()
    local layer = AddBlackListLayer.new()
    if layer and layer:Init() then
        return layer
    end
    return nil
end

function AddBlackListLayer:Init()
    return true
end

function AddBlackListLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_FRIEND_ADD_BLACKLIST)
    FriendAddBlacklist.main()
end

return AddBlackListLayer