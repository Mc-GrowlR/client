local BaseUIMediator = requireMediator("BaseUIMediator")
local TopTouchLayerMediator = class("TopTouchLayerMediator", BaseUIMediator)
TopTouchLayerMediator.NAME = "TopTouchLayerMediator"

local sformat = string.format

function TopTouchLayerMediator:ctor()
    TopTouchLayerMediator.super.ctor(self)
    self._ismoving = false
end

function TopTouchLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TopTouch_Open,
    }
end

function TopTouchLayerMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local id = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_TopTouch_Open == id then
        self:OpenLayer()
    end
end

function TopTouchLayerMediator:OpenLayer()
    if not (self._layer) then
        self._layer = requireLayerUI( "moved_event_layer/TopTouchEventLayer" ).create()
        self._type = global.UIZ.UI_NOTICE

        local function onSpecialR(touch)
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            local state = ItemMoveProxy:GetMovingItemState()
            if state then
                local goToName = ItemMoveProxy.ItemGoTo.TOPUI
                local data = {}
                data.target = goToName
                data.pos = touch
                ItemMoveProxy:CheckAndCallBack( data )
            end
            return -1
        end

        self._mouseBtnParam = {
            special_r = onSpecialR,
            moveTouch = true,
            swallow = -1
        }
        TopTouchLayerMediator.super.OpenLayer(self)
    end
end

function TopTouchLayerMediator:AddSkillToUI( data )
    if self._layer then
        self._layer:AddSkillToUI(data)
    end
end

function TopTouchLayerMediator:RemoveSkillToUI(data)
    if self._layer then
        self._layer:RemoveSkillToUI(data)
    end
end

function TopTouchLayerMediator:OnSkillCDTimeChange(data)
    if not self._layer then
        return false
    end
    self._layer:OnSkillCDTimeChange(data)
end

function TopTouchLayerMediator:OnSkillDel(data)
    if not self._layer then
        return
    end
    if not data or not data.MagicID then
        return
    end
    self._layer:RemoveSkillToUI({skill = data.MagicID})
end
    

return TopTouchLayerMediator
