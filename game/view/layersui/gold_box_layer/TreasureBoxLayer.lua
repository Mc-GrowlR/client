local BaseLayer = requireLayerUI("BaseLayer")

local TreasureBoxLayer = class("TreasureBoxLayer", BaseLayer)
local kDoubleTime = global.MMO.CLICK_DOUBLE_TIME

function TreasureBoxLayer:ctor()
    self._lastClickTime = nil
    self._startPosx = 0
    self._startPosy = 0
    self._boxNormalId = 4530
    self._boxAnimOpenId = 4511
    self._openAnimId = 4512
    self._animData = {}
    TreasureBoxLayer.super.ctor(self)
end

function TreasureBoxLayer.create(data)
    local layer = TreasureBoxLayer.new()
    if layer and layer:Init(data) then
        return layer
    end
    return nil
end

function TreasureBoxLayer:Init(data)
    self._ui = ui_delegate(self)

    local GoldBoxProxy = global.Facade:retrieveProxy(global.ProxyTable.GoldBoxProxy)
    GoldBoxProxy:setBoxItemData(data)
    return true
end

function TreasureBoxLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TREASURE_BOX)
    TreasureBox.main(data)

    self._boxMakeIndex = data.MakeIndex
    self:InitUI(data)
end

function TreasureBoxLayer:InitUI(itemData)
    self:InitTouchEventListener()

    self.addItemPanel = self._ui.Panel_key
    self.addItemPanel:setSwallowTouches(false)
    local function addKeyIntoBox(touchPos)
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        self._ui.Text_tips:setVisible(false)
        local state = ItemMoveProxy:GetMovingItemState()
        if state then
            local goToName = ItemMoveProxy.ItemGoTo.TreasureBox
            local data = {}
            data.target = goToName
            data.pos = touchPos
            data.boxLayer = self._ui.PanelPos
            data.boxData = itemData
            ItemMoveProxy:CheckAndCallBack(data)
        else
            return -1
        end
    end
    local function setNoswallowMouse()
        return -1
    end
    global.mouseEventController:registerMouseButtonEvent(self.addItemPanel, {down_r = setNoswallowMouse, special_r = addKeyIntoBox})
end

function TreasureBoxLayer:InitTouchEventListener()
    if global.isWinPlayMode then
        local function mouseMoveCallBack()
            self._ui.Text_tips:setVisible(true)
        end
        local function leaveItem()
            self._ui.Text_tips:setVisible(false)
        end
        global.mouseEventController:registerMouseMoveEvent(self._ui.Panel_key, {enter = mouseMoveCallBack, leave = leaveItem})
    end

    local function doubleEventCallBack()
        local data = {
            storage = {
                MakeIndex = self._boxMakeIndex,
                state = 1
            }
        }
        global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
        global.Facade:sendNotification(global.NoticeTable.Layer_Treasure_Box_Close)
    end
    local isEventPress = false
    local isMoved = true
    local function touchEvent(sender, eventType)
        if eventType == 0 then
            isEventPress = false
            isMoved = false
            self._basePosX, self._basePosy = self:getPosition()
        elseif eventType == 1 then
            local sPos = self._ui.PanelPos:getTouchBeganPosition()
            local ePos = self._ui.PanelPos:getTouchMovePosition()
            local x = self._basePosX + ePos.x - sPos.x
            local y = self._basePosy + ePos.y - sPos.y
            local frameSize = global.Director:getWinSize()
            local size = self._ui.PanelPos:getContentSize()
            if x >= frameSize.width / 2 - size.width / 2 then 
                x = frameSize.width / 2 - size.width / 2
            elseif x <= size.width / 2 - frameSize.width / 2 then 
                x = size.width / 2 - frameSize.width / 2
            end
            if y >= frameSize.height / 2 - size.height / 2 then 
                y = frameSize.height / 2 - size.height / 2
            elseif y <= size.height / 2 - frameSize.height / 2 then 
                y = size.height / 2 - frameSize.height / 2
            end
            self:setPosition(x, y)
            isMoved = true
        elseif eventType == 2 or eventType == 3 then
            if isMoved then     --移动端移动偏移判断太灵敏了
                local sPos = sender:getTouchBeganPosition()
                local ePos = sender:getTouchMovePosition()
                local movePosX,movePosY = ePos.x - sPos.x, ePos.y - sPos.y
                if math.abs(movePosX) <= 5 and math.abs(movePosY) <= 5 then
                    isMoved = false
                end
            end

            self._ui.PanelPos:stopAllActions()

            if not isMoved then
                if not isEventPress then
                    -- 判断是否有双击事件
                    if doubleEventCallBack then
                        -- 记录上一次点击时间
                        if not self._lastClickTime then
                            self._lastClickTime = true
                            -- 记录单击触发
                            self._clickDelayHandler =
                                PerformWithDelayGlobal(function()
                                    if self._clickCallback  then
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

                            if doubleEventCallBack then
                                doubleEventCallBack()
                            end

                            self._lastClickTime = nil
                        end
                    else
                        if self._clickCallback  then
                            self._clickCallback(self, eventType)
                        end
                    end
                end
            else
                local endPosX, endPosY = self:getPosition()
                self:GetMoveLayerPos(endPosX, endPosY)
            end
        end
    end
    self._ui.PanelPos:addTouchEventListener(touchEvent)
end

function TreasureBoxLayer:GetMoveTouch()
    return self._ui.PanelPos
end

function TreasureBoxLayer:GetMoveLayerPos(posx, posy)
    self._startPosx = posx
    self._startPosy = posy
    return self._startPosx, self._startPosy
end

function TreasureBoxLayer:OpenBoxAnim(data)
    if TreasureBox and TreasureBox.OpenBoxAnim then
        TreasureBox.OpenBoxAnim(data)
    end
end

return TreasureBoxLayer
