local BaseLayer = requireLayerUI("BaseLayer")
local PurchaseSellLayer = class("PurchaseSellLayer", BaseLayer)

local QuickCell = requireUtil("QuickCell")

function PurchaseSellLayer:ctor()
    PurchaseSellLayer.super.ctor(self)
end

function PurchaseSellLayer.create(...)
    local ui = PurchaseSellLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function PurchaseSellLayer:Init(data)
    self._quickUI = ui_delegate(self)
    return true
end

function PurchaseSellLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PURCHASE_SELL)
    PurchaseSell.main(data)
    
end

return PurchaseSellLayer