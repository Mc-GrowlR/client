local CacheWidget = requireUtil("CacheWidget")
local BagItemTextLayer = class("BagItemTextLayer", CacheWidget)

function BagItemTextLayer:ctor()
    BagItemTextLayer.super.ctor(self)
    self._data = nil
    self._itemData = nil
    self._itemClass = nil
end 

function BagItemTextLayer:init(data)
    local IsWinPlayMode = SL:GetMetaValue("WINPLAYMODE")
    local path = IsWinPlayMode and "bag_item/bag_item_num_win32" or "bag_item/bag_item_num"
    self:InitWidgetConfig(path) -- 缓存读取
    self._quickUI = ui_delegate(self._widget)
    self:InitGUI(data)
end 

function BagItemTextLayer:InitGUI(data)
    self._itemClass = require(SLDefine.LUAFile.LUA_FILE_BAG_ITEM_TEXT_LAYER).new(self, data)
end 

function BagItemTextLayer:resetMoveState(bool)
    self:setVisible(not bool)
end

function BagItemTextLayer:UpdateItemText(itemData)
    self._itemClass:Cleanup()
    self._itemClass:UpdateItemText(itemData)
end

return BagItemTextLayer