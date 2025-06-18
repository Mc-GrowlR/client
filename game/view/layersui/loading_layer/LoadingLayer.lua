local BaseLayer = requireLayerUI("BaseLayer")
local HotLoadingLayer = class("HotLoadingLayer", BaseLayer)

function HotLoadingLayer:ctor()
    HotLoadingLayer.super.ctor(self)
    self.index = 1
end

function HotLoadingLayer.create()
    local node = HotLoadingLayer.new()
    if node:Init() then
        return node
    else
        return nil
    end
end

function HotLoadingLayer:Init()
    self._root = CreateExport("loading/hotloading.lua")
    if not self._root then
        return false
    end
    self:addChild(self._root)

    self.Panel1 = self._root:getChildByName("Panel_1")
    
    self.TextPercent = self._root:getChildByName("Text_percent")
    self._bar_load_percent = self._root:getChildByName("LoadingBar_percent")
    self._node_percent_clip = self._bar_load_percent:getChildByName("Node_clip")
    
    self._bar_load_percent:setPercent(0)
    
    return true
end

function HotLoadingLayer:SetPercent(data)
    if not data then
        return
    end
    
    local percent = tonumber(data.percent) or 0
    local status = tonumber(data.status) or 0
    
    self._bar_load_percent:setPercent(percent)
    self._node_percent_clip:setPositionX(self._bar_load_percent:getContentSize().width * (percent / 100))
    
    local steIndex = 30010003
    if status == 7 then
        steIndex = 30010004
    end
    local percentString = string.format(GET_STRING(steIndex), percent, 100)
    self.TextPercent:setString(percentString)
end

return HotLoadingLayer
