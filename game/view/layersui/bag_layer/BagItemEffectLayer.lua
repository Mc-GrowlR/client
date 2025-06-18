local CacheWidget = requireUtil("CacheWidget")
local BagItemEffectLayer = class("BagItemEffectLayer", CacheWidget)

function BagItemEffectLayer:ctor()
    BagItemEffectLayer.super.ctor(self)
    self._data = nil
    self._itemData = nil
    self._itemClass = nil
end 

function BagItemEffectLayer:init(data)
    local path = "bag_item/bag_item_effect"
    self:InitWidgetConfig(path) -- 缓存读取
    self._quickUI = ui_delegate(self._widget)
    self:InitGUI(data)
end 

function BagItemEffectLayer:InitGUI(data)
    self._itemClass = require(SLDefine.LUAFile.LUA_FILE_BAG_ITEM_EFFECT_LAYER).new(self, data)
end 

function BagItemEffectLayer:resetMoveState(bool)
    self:setVisible(not bool)
end

function BagItemEffectLayer:setItemPowerTag()
    self._itemClass:SetItemPowerFlag()
end

function BagItemEffectLayer:UpdateItemEffect(itemData)
    self._itemClass:UpdateItemEffect(itemData)
end

return BagItemEffectLayer