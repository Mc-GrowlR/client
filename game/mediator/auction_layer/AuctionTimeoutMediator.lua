local BaseUIMediator = requireMediator("BaseUIMediator")
local AuctionTimeoutMediator = class("AuctionTimeoutMediator", BaseUIMediator)
AuctionTimeoutMediator.NAME = "AuctionTimeoutMediator"

function AuctionTimeoutMediator:ctor()
    AuctionTimeoutMediator.super.ctor(self)
end

function AuctionTimeoutMediator:InitMultiPanel()
    AuctionTimeoutMediator.super.InitMultiPanel(self)
end

function AuctionTimeoutMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_AuctionTimeout_Open,
        noticeTable.Layer_AuctionTimeout_Close,
        noticeTable.AuctionPutinResp,
        noticeTable.AuctionPutoutResp,
    }
end

function AuctionTimeoutMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_AuctionTimeout_Open == name then
        self:OpenLayer(data)

    elseif noticeTable.Layer_AuctionTimeout_Close == name
        or noticeTable.AuctionPutinResp == name
            or noticeTable.AuctionPutoutResp == name then
        self:CloseLayer()
    end
end

function AuctionTimeoutMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer    = requireLayerUI("auction_layer/AuctionTimeoutLayer").create()
        self._type     = global.UIZ.UI_NORMAL
        self._hideLast = false
        self._GUI_ID   = SLDefine.LAYERID.AuctionTimeoutGUI

        AuctionTimeoutMediator.super.OpenLayer(self)

        self._layer:InitGUI(data)

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer._quickUI.Panel_2,
            index = global.SUIComponentTable.AuctionTimeout
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

function AuctionTimeoutMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = 
    {
        index = global.SUIComponentTable.AuctionTimeout
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    AuctionTimeoutMediator.super.CloseLayer(self)
end

return AuctionTimeoutMediator