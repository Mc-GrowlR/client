local BaseLayer = requireLayerUI("BaseLayer")
local StoreRechageLayer = class("StoreRechageLayer", BaseLayer)

function StoreRechageLayer:ctor()
    StoreRechageLayer.super.ctor(self)
end

function StoreRechageLayer.create()
    local ui = StoreRechageLayer.new()
    if ui and ui:Init() then
        return ui
    end
    return nil
end

function StoreRechageLayer:Init()
    self._quickUI = ui_delegate(self)

    return true
end

function StoreRechageLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_STORE_RECHARGE)
    StoreRecharge.main()
end

return StoreRechageLayer