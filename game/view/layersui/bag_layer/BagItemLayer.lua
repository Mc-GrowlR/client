local CacheWidget = requireUtil("CacheWidget")
local BagItemLayer = class("BagItemLayer", CacheWidget)
local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)

-- 点击事件
local kTouchAll = 0
local kTouchPress = 1 -- 长按
local kTouchClick = 2 -- 点击
local kTouchWidget = 3 -- widget touch

local kDoubleTime = global.MMO.CLICK_DOUBLE_TIME
local itemMoveState = {
    begin = 1,
    moving = 2,
    end_move = 3,
}

function BagItemLayer:ctor()
    BagItemLayer.super.ctor(self)
    self._itemClass = nil
    self._data = nil
    self._itemData = nil
    self._from = nil
    self._canLooks = nil

    self._mouseEventCheckTimes = nil
    self._noSwallow = nil
    self._movable = nil
    self._movingState = false
    self._moveItem = nil

    self._pressCallback = nil
    self._clickCallback = nil
    self._replaceClickEvent = nil
    self._iconTouchEventListener = nil
    self._doubleEvent = nil
    self._lastClickTime = nil
    self._clickDelayHandler = nil

    self._moveBeginCallBack = nil
    self._moveEndCallBack = nil
    self._moveCancelCallBack = nil
end 

function BagItemLayer:init(data)
    local IsWinPlayMode = SL:GetMetaValue("WINPLAYMODE")
    local path = IsWinPlayMode and "bag_item/bag_item" or "bag_item/bag_item"
    self:InitWidgetConfig(path) -- 缓存读取
    self._quickUI = ui_delegate(self._widget)
    self:InitGUI(data)
end 

function BagItemLayer:InitGUI(data)
    self._itemClass = require(SLDefine.LUAFile.LUA_FILE_BAG_ITEM_LAYER).new(self, data)
    self:initData(data)
end 

function BagItemLayer:initData(data)
    if not data then 
        return 
    end 

    self._data = data
    self._itemData = data.itemData or ItemConfigProxy:GetItemDataByIndex(data.index)

    if data.from then
        self._from = data.from
    end

    self._moveItem = data.moveItem

    -- 是否注册鼠标tips
    self._mouseEventCheckTimes = data.mouseCheckTimes
    local isShowMouseTip = data.noMouseTips
    if not isShowMouseTip and global.isWinPlayMode then
        self:RegisterWin32MouseMove()
        global.mouseEventController:registerMouseButtonEvent(self)
    end

    -- 道具框是否吞噬触摸
    local noSwallow = data.noSwallow
    if type(noSwallow) == "boolean" then
        self:setItemTouchSwallow(noSwallow)
    end

    -- 是否查看道具信息
    local look = data.look
    -- 是否可移动
    local movable = data.movable
    if look or movable then
        self._movable = movable
        self._canLooks = look
        self:addLookItemInfoEvent(data.posType)
    end
end 

function BagItemLayer:OnEnter()
end

function BagItemLayer:OnExit()
    if self._clickDelayHandler then
        UnSchedule(self._clickDelayHandler)
        self._clickDelayHandler = nil
    end

    if not global.isWinPlayMode then
        if not self._moveItem and self._itemData and self._itemData.MakeIndex then
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel, {MakeIndex = self._itemData.MakeIndex})
        end
    end
    
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:removeEventListenersForTarget(self, true)
end

function BagItemLayer:addLookItemInfoEvent(posType, eventType)
    eventType = eventType or kTouchClick
    self:addTouchEventListener(function() 
        self:showIteminfo(posType)
    end, eventType)
end

function BagItemLayer:showIteminfo(posType, setPos)
    if not self._itemData or self._movingState then
        return nil
    end
    local result = true
    if self._replaceClickEvent then
        result = self._replaceClickEvent()
    end
    if result then
        local pos = self:getWorldPosition()
        if global.isWinPlayMode and self._movable then
            if setPos and next(setPos) then-- 交换道具位置后的
                pos = setPos
            end
            self:SetGoodItemState(itemMoveState.begin, pos)
        else
            if self._canLooks and not global.isWinPlayMode then
                if not self._itemData or next(self._itemData) == nil then
                    return
                end
                local data = {}
                data.itemData = self._itemData
                data.pos = pos
                data.from = self._from
                data.lookPlayer = self._data and self._data.lookPlayer
                global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, data)
            end
        end
    end
end

function BagItemLayer:SetGoodItemState( state, pos )
    if not self._from or not self._movable then
        return
    end
    if itemMoveState.begin == state then
        self:setVisible(false)
        self._movingState = true
        global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Begin,{
            pos = pos,
            itemData = self._itemData,
            cancelCallBack = self._moveCancelCallBack,
            goodsItem = self,
            from = self._from
        })
        if self._moveBeginCallBack then
            self._moveBeginCallBack()
        end
    elseif itemMoveState.moving == state then

    elseif itemMoveState.end_move == state then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End, pos)
        if self._moveEndCallBack then
            self._moveEndCallBack()
        end
    end
end

function BagItemLayer:SetMoveEable(enable)
    self._movable = enable
end

function BagItemLayer:resetMoveState(bool)
    self._movingState = bool
    self:setVisible(not bool)
end

function BagItemLayer:addReplaceClickEventListener(callback)
    self._replaceClickEvent = callback
end

function BagItemLayer:addDoubleEventListener(callback)
    self._doubleEvent = callback
end

function BagItemLayer:addMoveCancelCallBack(callback)
    self._moveCancelCallBack = callback
end

function BagItemLayer:addMoveBeginCallBack(callback)
    self._moveBeginCallBack = callback
end

function BagItemLayer:addMoveEndCallBack(callback)
    self._moveEndCallBack = callback
end

function BagItemLayer:addPressCallBack(callback)
    self._pressCallback = callback
end

-- 点击事件
function BagItemLayer:addTouchEventListener(callback, eventType)
    -- 0:长按,点击  1:长按  2:点击  3:touch响应回调
    eventType = eventType or kTouchClick

    if eventType == kTouchAll then
        self._pressCallback = callback
        self._clickCallback = callback
    elseif eventType == kTouchPress then
        self._pressCallback = callback
    elseif eventType == kTouchClick then
        self._clickCallback = callback
    elseif eventType == kTouchWidget then
        self._iconTouchEventListener = callback
    end

    local isEventPress = false
    local isMoved = true
    local canCallBack = true
    local isMobile = not global.isWinPlayMode

    local function delayCallback()
        isEventPress = true

        if self._pressCallback then
            if not self._pressCallback then
                return false
            end

            if not isMoved then
                self._pressCallback()
                return false
            end

            local movedPos = self._quickUI.Panel_bg:getTouchMovePosition()
            local beganPos = self._quickUI.Panel_bg:getTouchBeganPosition()

            local diff = cc.pSub(movedPos, beganPos)
            local distSq = cc.pLengthSQ(diff)
            if distSq <= 100 then
                self._pressCallback()
            end
        end
    end

    local function touchEvent(_, eventType)
        if not isMobile then
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            local itemMoving = ItemMoveProxy:GetMovingItemState()
            if itemMoving then --在道具移动中
                if eventType == 0 then
                    self:retain()
                    canCallBack = ItemMoveProxy:GetItemMoveFrome() ~= ItemMoveProxy.ItemGoTo.BAG or self._from ~= ItemMoveProxy.ItemGoTo.BAG
                end
                return
            end
            
            local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
            if BagProxy:GetBagCollimator() then
                self:retain()
                return
            end
        end
        if self._iconTouchEventListener then
            self._iconTouchEventListener(self, eventType)
        end
        if eventType == 0 then
            self:retain()
            isEventPress = false
            isMoved = false
            canCallBack = true

            if self._pressCallback then
                self._quickUI.Panel_bg:stopAllActions()
                performWithDelay(self._quickUI.Panel_bg, delayCallback, kDoubleTime)
            end
        elseif eventType == 1 then
            local movedPos = self._quickUI.Panel_bg:getTouchMovePosition()
            local beganPos = self._quickUI.Panel_bg:getTouchBeganPosition()

            local diff = cc.pSub(movedPos, beganPos)
            local distSq = cc.pLengthSQ(diff)
            if not isMoved and distSq > 100 then
                isMoved = true
                if isMobile and self._movable then
                    local beginMovePos = self:getWorldPosition()
                    self:SetGoodItemState(itemMoveState.begin, beginMovePos)
                end
            end
            if isMobile and self._movable then
                local movedPos = self._quickUI.Panel_bg:getTouchMovePosition()
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Moving,{pos = movedPos})
            end
        elseif eventType == 2 or eventType == 3 then
            self:autorelease()
            self._quickUI.Panel_bg:stopAllActions()

            if not isMoved then
                if not isEventPress then
                    -- 判断是否有双击事件
                    if self._doubleEvent then
                        -- 记录上一次点击时间
                        if not self._lastClickTime then
                            self._lastClickTime = true
                            -- 记录单击触发
                            self._clickDelayHandler =
                                PerformWithDelayGlobal(
                                function()
                                    if self._clickCallback and canCallBack then
                                        self._clickCallback(self, eventType)
                                    end

                                    self._lastClickTime = nil
                                end,
                                kDoubleTime
                            )
                        else
                            if self._clickDelayHandler then
                                UnSchedule(self._clickDelayHandler)
                                self._clickDelayHandler = nil
                            end

                            if self._doubleEvent then
                                self._doubleEvent()
                            end

                            self._lastClickTime = nil
                        end
                    else
                        if self._clickCallback and canCallBack then
                            self._clickCallback(self, eventType)
                        end
                    end
                end
            else
                if isMobile and self._movable then
                    local endPos = self._quickUI.Panel_bg:getTouchEndPosition()
                    self:SetGoodItemState(itemMoveState.end_move, endPos)
                end
            end
        end
    end

    RemoveAllWidgetTouchEventListener(self._quickUI.Panel_bg)
    self._quickUI.Panel_bg:addTouchEventListener(touchEvent)
    self._quickUI.Panel_bg:setTouchEnabled(true)
    self._quickUI.Panel_bg:setSwallowTouches(not self._noSwallow)
end

-- 注册鼠标移动事件
function BagItemLayer:RegisterWin32MouseMove()
    local function UnScheduler()
        if self._delayFunc then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._delayFunc)
            self._delayFunc = nil
        end
    end

    local function onShowItemTips(touchPos)
        if self._movingState then
            return false
        end
        if not (self._itemData and next(self._itemData)) then
            return false
        end

        if not CheckNodeCanCallBack(self, touchPos, self._mouseEventCheckTimes) then
            return false
        end
        
        local data = {}
        data.itemData = self._itemData
        data.pos = self:getWorldPosition()
        data.from = self._from

        SL:OpenItemTips(data)
    end

    local function onLeaveFunc() 
        SL:CloseItemTips()
        UnScheduler()
    end

    local function onEnterFunc(touchPos)
        if self._delayFunc then
            return false
        end
        self._delayFunc = PerformWithDelayGlobal(function()
            onShowItemTips(touchPos)
        end, global.MMO.PC_TIPS_DELAY_TIME)
    end

    GUI:addMouseMoveEvent(self, {onEnterFunc = onEnterFunc, onLeaveFunc = onLeaveFunc, checkIsVisible = true})
    self.isSignMouListner = true
end

--注册鼠标滚动回调
function BagItemLayer:RegisterWin32MouseMoveScrollCall(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Mouse_Scroll, data)
end

function BagItemLayer:setItemTouchSwallow(bool)
    if not type(bool) == "boolean" then
        return false
    end
    self._noSwallow = not bool
    self._quickUI.Panel_bg:setSwallowTouches(bool)
end

-- 背包回收 选中状态显示
function BagItemLayer:SetChooseState(visible)
    self._itemClass:SetChooseState(visible)
end

function BagItemLayer:UpdateItemData(itemData)
    self._itemData = itemData
    self._itemClass:UpdateItemData(itemData)
end

return BagItemLayer