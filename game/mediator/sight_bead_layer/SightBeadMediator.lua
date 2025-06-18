--[[
    author:yzy
    time:2021-03-03 20:30:26
]]
local BaseUIMediator = requireMediator("BaseUIMediator")
local SightBeadMediator = class("SightBeadMediator", BaseUIMediator)
SightBeadMediator.NAME = "SightBeadMediator"

function SightBeadMediator:ctor()
    SightBeadMediator.super.ctor(self)
end

function SightBeadMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Moved_Open,
        noticeTable.Layer_Sight_Bead_Show,
        noticeTable.Layer_Sight_Bead_Hide
    }
end

function SightBeadMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Moved_Open == name then
        self:OpenLayer()
    elseif noticeTable.Layer_Sight_Bead_Show == name then
        self:OnShow(data)
    elseif noticeTable.Layer_Sight_Bead_Hide == name then
        self:OnHide()
    end
end

function SightBeadMediator:OpenLayer(data)
    if not self._layer then
        self._layer = requireLayerUI("sight_bead_layer/SightBeadLayer").create()
        self._type = global.UIZ.UI_MOUSE

        local function onMouseMoving(pos)
            if self._layer then
                self._layer:SetMoveBeginPos(pos)
            end
        end

        local function onMouseDownR( )
            local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
            if BagProxy:GetBagCollimator() then
                BagProxy:ClearBagCollimator()
                BagProxy:RequestCanceCollimator()
                global.Facade:sendNotification(global.NoticeTable.Layer_Sight_Bead_Hide)
            end
        end

        self._mouseBtnParam = {
            moving = onMouseMoving,
            moveTouch = true,
            down_r = onMouseDownR,
            swallow = -1
        }

        SightBeadMediator.super.OpenLayer(self)
    end
end

function SightBeadMediator:OnShow(data)
    if self._layer then
        self._layer:OnShow(data)
    end
end

function SightBeadMediator:OnHide()
    if self._layer then
        self._layer:OnHide()
    end
end

return SightBeadMediator
