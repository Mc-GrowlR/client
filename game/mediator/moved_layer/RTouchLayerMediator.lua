local BaseUIMediator = requireMediator("BaseUIMediator")
local RTouchLayerMediator = class("RTouchLayerMediator", BaseUIMediator)
RTouchLayerMediator.NAME = "RTouchLayerMediator"

local sformat = string.format

function RTouchLayerMediator:ctor()
    RTouchLayerMediator.super.ctor(self)
    self._ismoving = false
end

function RTouchLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_RTouch_Open,
        noticeTable.Layer_RTouch_State_Change
    }
end

function RTouchLayerMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local id = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_RTouch_Open == id then
        self:OpenLayer()
    elseif noticeTable.Layer_RTouch_State_Change == id then
        self:ChangeState(data)
    end
end

function RTouchLayerMediator:OpenLayer()
    if not (self._layer) then
        self._layer = requireLayerUI( "moved_event_layer/RTouchEventLayer" ).create()
        self._type = global.UIZ.UI_RTOUCH

        local function onMouseDown(touch)
            local touchWay  = global.MMO.MOVE_EVENT_MOUSE_R
            local eventType = cc.Handler.EVENT_TOUCH_BEGAN
            self._ismoving  = true
            global.gamePlayerController:HandleTouchEndEvent( touch, touchWay, eventType )
            
            local data = {
                way = touchWay,
                pos = touch
            }
            global.Facade:sendNotification(global.NoticeTable.keepMovingBegin, data)
        end

        local function onMouseMoving(touch)
            if self._ismoving then
                local data = {
                    way = global.MMO.MOVE_EVENT_MOUSE_R,
                    pos = touch
                }
                global.Facade:sendNotification(global.NoticeTable.keepMovingUpdate, data)
            end

            local ActorPickerProxy = global.Facade:retrieveProxy(global.ProxyTable.ActorPicker)
            ActorPickerProxy:MouseMoveWorldEvent(touch)

        end

        local function onMouseUp()
            self:ChangeState(false)
        end

        local function onSpecialR(touch)
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            local state = ItemMoveProxy:GetMovingItemState()
            if state then
                local goToName = ItemMoveProxy.ItemGoTo.DROP
                local data = {}
                data.target = goToName
                data.pos = touch
                ItemMoveProxy:CheckAndCallBack( data )
            end
        end

        self._mouseBtnParam = {
            down_r = onMouseDown,
            moving = onMouseMoving,
            up_r = onMouseUp,
            special_r = onSpecialR,
            moveTouch = true
        }
        RTouchLayerMediator.super.OpenLayer(self)
    end
end

function RTouchLayerMediator:ChangeState(bool)
    self._ismoving = bool
    if not bool then
        global.Facade:sendNotification(global.NoticeTable.keepMovingEnded)
    end
end
    
return RTouchLayerMediator
