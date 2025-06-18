local BaseLayer = requireLayerUI( "BaseLayer" )
local ItemTipsLayer = class( "ItemTipsLayer", BaseLayer )

function ItemTipsLayer:ctor()
    ItemTipsLayer.super.ctor(self)
end

function ItemTipsLayer.create(data)
    local layer = ItemTipsLayer.new()
    if layer:Init(data) then
        return layer
    else
        return nil
    end
end

function ItemTipsLayer:Init()
    return true
end

function ItemTipsLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_ITEM_TIPS)
    local meta = {}
    meta.SetTradeCapturePanel = function (panel)
        self._CaptureNode = panel
    end
    meta.__index = meta
    setmetatable(ItemTips, meta)
    ItemTips.main(data)
end

return ItemTipsLayer