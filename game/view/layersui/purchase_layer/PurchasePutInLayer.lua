local BaseLayer = requireLayerUI("BaseLayer")
local PurchasePutInLayer = class("PurchasePutInLayer", BaseLayer)

function PurchasePutInLayer:ctor()
    PurchasePutInLayer.super.ctor(self)
end

function PurchasePutInLayer.create()
    local ui = PurchasePutInLayer.new()
    if ui and ui:Init() then
        return ui
    end
    return nil
end

function PurchasePutInLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function PurchasePutInLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PURCHASE_PUTIN)
    PurchasePutIn.main(data)
end

return PurchasePutInLayer