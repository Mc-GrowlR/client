local BaseLayer = requireLayerUI("BaseLayer")
local HurtTipsLayer = class("HurtTipsLayer", BaseLayer)

function HurtTipsLayer:ctor()
    HurtTipsLayer.super.ctor(self)
    self._path = global.MMO.PATH_RES_PRIVATE .. "hurt_tips/"
end

function HurtTipsLayer.create()
    local layer = HurtTipsLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function HurtTipsLayer:Init()
    local visibleSize = global.Director:getVisibleSize()
    local config = {
        [1] = {rotate=0, anchorX=0, anchorY=1, x=0, y=visibleSize.height, width=visibleSize.width, height = 95},
        [2] = {rotate=90, anchorX=0, anchorY=1, x=visibleSize.width, y=visibleSize.height, width=visibleSize.height, height = 95},
        [3] = {rotate=180, anchorX=0, anchorY=1, x=visibleSize.width, y=0, width=visibleSize.width, height = 95},
        [4] = {rotate=270, anchorX=0, anchorY=1, x=0, y=0, width=visibleSize.height, height = 95},
    }
    for k, v in pairs(config) do
        local image = ccui.ImageView:create()
        image:loadTexture(self._path .. "bg_blood_1.png")
        self:addChild(image)

        image:setAnchorPoint(cc.p(v.anchorX, v.anchorY))
        image:setPosition(cc.p(v.x, v.y))
        image:ignoreContentAdaptWithSize(false)
        image:setContentSize(cc.size(v.width, v.height))
        image:setRotation(v.rotate)

        image:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.FadeTo:create(0, 0),
            cc.FadeTo:create(1, 255),
            cc.DelayTime:create(0.5)
        )))
    end
    
    return true
end

return HurtTipsLayer
