local BaseLayer = requireLayerUI("BaseLayer")
local RTouchEventLayer = class("RTouchEventLayer", BaseLayer)

function RTouchEventLayer:ctor()
    RTouchEventLayer.super.ctor(self)
end

function RTouchEventLayer.create()
    local layer = RTouchEventLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function RTouchEventLayer:Init()
    self._root = CreateExport("moved_layer/rtouch_layer.lua")
    if not self._root then
        return false
    end
    self:addChild(self._root)

    self.panel = self._root:getChildByName("Panel_1")
    
    self.panel:setSwallowTouches(false)

    return true
end

return RTouchEventLayer
