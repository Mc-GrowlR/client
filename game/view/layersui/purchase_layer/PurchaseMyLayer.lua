local BaseLayer = requireLayerUI("BaseLayer")
local PurchaseMyLayer = class("PurchaseMyLayer", BaseLayer)

local QuickCell = requireUtil("QuickCell")

function PurchaseMyLayer:ctor()
    PurchaseMyLayer.super.ctor(self)
end

function PurchaseMyLayer.create(...)
    local ui = PurchaseMyLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function PurchaseMyLayer:Init(data)
    self._quickUI = ui_delegate(self)
    return true
end

function PurchaseMyLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PURCHASE_MY)
    PurchaseMy.main()
    
end

return PurchaseMyLayer