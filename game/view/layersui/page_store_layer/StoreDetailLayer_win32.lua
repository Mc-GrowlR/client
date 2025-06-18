local BaseLayer = requireLayerUI("BaseLayer")
local StoreDetailLayer = class("StoreDetailLayer", BaseLayer)

function StoreDetailLayer:ctor()
    StoreDetailLayer.super.ctor(self)
end

function StoreDetailLayer.create()
    local layer = StoreDetailLayer.new()
    if layer:Init() then
        return layer
    else
        return nil
    end
end

function StoreDetailLayer:Init( data )
    self._ui = ui_delegate(self)
    return true
end

function StoreDetailLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_STORE_DETAIL)
    StoreDetail.main(data)
end

return StoreDetailLayer
