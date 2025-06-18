local BaseLayer = requireLayerUI("BaseLayer")
local PurchaseWorldLayer = class("PurchaseWorldLayer", BaseLayer)

local QuickCell = requireUtil("QuickCell")

function PurchaseWorldLayer:ctor()
    PurchaseWorldLayer.super.ctor(self)
end

function PurchaseWorldLayer.create(...)
    local ui = PurchaseWorldLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function PurchaseWorldLayer:Init(data)
    self._quickUI = ui_delegate(self)
    return true
end

function PurchaseWorldLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PURCHASE_WORLD)
    PurchaseWorld.main()

end

return PurchaseWorldLayer