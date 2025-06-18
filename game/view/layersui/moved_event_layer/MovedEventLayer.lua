local BaseLayer = requireLayerUI("BaseLayer")
local MovedEventLayer = class("MovedEventLayer", BaseLayer)

--[[
    README:
    在移动端时 本层内的节点移动响应于目标节点的触摸事件 所以不能直接移出目标节点
]]
function MovedEventLayer:ctor()
    MovedEventLayer.super.ctor(self)
    self.onMoving = false
    self.moveBegin = {}
    self.moveNode = nil
    self.goodsItem = nil
    self.beginPos = nil
    self.cancelCallBack = nil
end

function MovedEventLayer.create()
    local layer = MovedEventLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function MovedEventLayer:Init()
    self._root = CreateExport("moved_layer/moved_event_layer.lua")
    if not self._root then
        return false
    end
    self:addChild(self._root)

    self.panel = self._root:getChildByName("Panel_1")
    self.panel:setSwallowTouches(false)
    
    return true
end

function MovedEventLayer:CreateMovingItem( data )
    if self.onMoving then --替换
        self:OnMoveCancelEvent()
    end
    local pos = data.pos
    self.moveBegin = self.beginPos or pos
    self.from = data.from
    
    if data.movingNode then
        local node = data.movingNode
        node:removeFromParent()
        node:setTouchEnabled(false)
        node:setPosition(self.moveBegin.x,self.moveBegin.y)
        self.panel:addChild(node)
        self.moveNode = node
    end

    if data.itemData then
        local info = {}
        info.itemData = data.itemData
        info.index = data.itemData.Index
        info.noMouseTips = true
        info.noLockTips = true
        info.noFullTips = true
        info.moveItem = true
        local goodItem = GoodsItem:create( info )
        goodItem:setPosition(self.moveBegin.x,self.moveBegin.y)
        self.panel:addChild(goodItem)
        self.moveNode = goodItem

        global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type=global.MMO.SND_TYPE_CLICK_ITEM, param=data.itemData})
    end

    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    ItemMoveProxy:SetMoveItemData(data.itemData, self.from, data.skillId)
    ItemMoveProxy:SetLinkFunc(data.linkFunc)

    self.goodsItem = data.goodsItem

    self.cancelCallBack = data.cancelCallBack

    self.onMoving = true
end

function MovedEventLayer:setMoveBeginPos(pos)
    self.beginPos = pos
end

function MovedEventLayer:OnMoveItemUpDate( data )
    if not data or not next(data) then
        return
    end
    if data.cancelCallBack then
        self.cancelCallBack = data.cancelCallBack
    end
    if data.goodItem then
        self.goodsItem = data.goodItem
    end
end

function MovedEventLayer:UpdatePostion(data)
    if self.moveNode and next(self.moveBegin) and next(data.pos) and data.pos then
        local movePos = data.pos
        self.moveNode:setPosition(movePos.x, movePos.y)
    end
end

function MovedEventLayer:OnMoveCancelEvent(data)
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    local movedData = ItemMoveProxy:GetMovingItemData()
    local needMove = true
    if data then
        if data.MakeIndex then
            if not movedData or data.MakeIndex ~= movedData.MakeIndex then
                needMove  = false
            end
        elseif data.from then
            if data.from ~= self.from then
                needMove = false
            end
        end
    end
    if not needMove then
        return
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel_Notice)
    if self.goodsItem and not tolua.isnull(self.goodsItem) then
        self.goodsItem:resetMoveState()
    end
    if self.cancelCallBack then
        self.cancelCallBack()
    end
    self:RemoveChildrenAndCleanNode()
end

function MovedEventLayer:RemoveChildrenAndCleanNode()
    self.panel:removeAllChildren()
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    ItemMoveProxy:SetMoveItemData(nil, nil)
    self.onMoving = false
    self.moveBegin = {}
    self.moveNode = nil
    self.goodsItem = nil
    self.cancelCallBack = nil
    self.beginPos = nil
end

function MovedEventLayer:CleanData(data)
    -- 除开window端手动发送鼠标事件 模拟点击
    if not global.isWinPlayMode and data then
        local mouseEventType_Down = 1
        local mouseButtonType_right = 1
        local mouseEvent = cc.EventMouse:new(mouseEventType_Down)
        mouseEvent:setCursorPosition(data.x,data.y)
        mouseEvent:setMouseButton(mouseButtonType_right)
        mouseEvent.specialRight = true

        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
        eventDispatcher:dispatchEvent(mouseEvent)
    end

    self:RemoveChildrenAndCleanNode()

end

function MovedEventLayer:OnSpecialCanel(type)
    if type and self.from then
        if type == self.from then
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        end
    end
end

return MovedEventLayer
