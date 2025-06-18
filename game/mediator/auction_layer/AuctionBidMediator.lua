local BaseUIMediator = requireMediator("BaseUIMediator")
local AuctionBidMediator = class("AuctionBidMediator", BaseUIMediator)
AuctionBidMediator.NAME = "AuctionBidMediator"

function AuctionBidMediator:ctor()
    AuctionBidMediator.super.ctor(self)
end

function AuctionBidMediator:InitMultiPanel()
    AuctionBidMediator.super.InitMultiPanel(self)
end

function AuctionBidMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_AuctionBid_Open,
        noticeTable.Layer_AuctionBid_Close,
        noticeTable.AuctionBidResp,
    }
end

function AuctionBidMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_AuctionBid_Open == name then
        self:OpenLayer(data)

    elseif noticeTable.Layer_AuctionBid_Close == name or noticeTable.AuctionBidResp == name then
        self:CloseLayer()
    end
end

function AuctionBidMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer    = requireLayerUI("auction_layer/AuctionBidLayer").create()
        self._type     = global.UIZ.UI_NORMAL
        self._hideLast = false
        self._GUI_ID   = SLDefine.LAYERID.AuctionBidGUI

        AuctionBidMediator.super.OpenLayer(self)

        self._layer:InitGUI(data)

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer._quickUI.Panel_2,
            index = global.SUIComponentTable.AuctionBid
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

function AuctionBidMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = 
    {
        index = global.SUIComponentTable.AuctionBid
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    AuctionBidMediator.super.CloseLayer(self)
end

return AuctionBidMediator