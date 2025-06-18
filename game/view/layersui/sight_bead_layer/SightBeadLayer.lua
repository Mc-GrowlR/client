--[[
    author:yzy
    time:2021-03-03 20:36:48
]]
local BaseLayer = requireLayerUI("BaseLayer")
local SightBeadLayer = class("SightBeadLayer", BaseLayer)

function SightBeadLayer:ctor()
    SightBeadLayer.super.ctor(self)
    self._sight_bead_img = nil --准星图标  没有触摸
end

function SightBeadLayer.create(data)
    local layer = SightBeadLayer.new()
    if layer and layer:Init() then
        return layer
    end
    return nil
end

function SightBeadLayer:Init(data)
    self._root = CreateExport("moved_layer/moved_event_layer.lua")
    if not self._root then
        return false
    end
    self:addChild(self._root)

    self.panel = self._root:getChildByName("Panel_1")
    self.panel:setSwallowTouches(false)

    self._is_show = false
    local publicRes = global.MMO.PATH_RES_PUBLIC
    if global.isWinPlayMode then
        publicRes = global.MMO.PATH_RES_PUBLIC_WIN32
    end
    local img = ccui.ImageView:create(publicRes .. "zhunxing.png")
    img:setTouchEnabled(false)
    img:setSwallowTouches(false)
    img:setVisible(false)
    self:addChild(img)
    self._sight_bead_img = img

    self:RegisterTouch(false)

    return true
end

--注册触摸
function SightBeadLayer:RegisterTouch( is_register )
    if is_register then
        local visibleSize = nil
        if not global.isWinPlayMode then
            visibleSize = global.Director:getVisibleSize()
        else
            visibleSize = { width=0, height=0 }
        end
        self.panel:setContentSize( cc.size(visibleSize.width, visibleSize.height) )
    else
        self.panel:setContentSize( cc.size(0,0) )
    end
end

--设置移动位置  pos: 位置
function SightBeadLayer:SetMoveBeginPos(pos)
    if self._is_show and pos then
        self._sight_bead_img:setPosition(pos)
    end
end

--显示准星  data：准星开始显示的位置
function SightBeadLayer:OnShow(data)
    if self._sight_bead_img then
        self._is_show = true
        self:RegisterTouch(true)
        local visibleSize = global.Director:getVisibleSize()
        local pos = data and data.pos or {x = visibleSize.width/2, y = visibleSize.height/2}
        self._sight_bead_img:setPosition(pos)
        self._sight_bead_img:setVisible(true)
    end
end

--隐藏准星
function SightBeadLayer:OnHide()
    if self._sight_bead_img then
        self._is_show = false
        self:RegisterTouch(false)
        self._sight_bead_img:setVisible(false)
    end
end

return SightBeadLayer
