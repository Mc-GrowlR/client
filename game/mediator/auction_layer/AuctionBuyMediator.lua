local BaseUIMediator = requireMediator("BaseUIMediator")
local AuctionBuyMediator = class("AuctionBuyMediator", BaseUIMediator)
AuctionBuyMediator.NAME = "AuctionBuyMediator"

function AuctionBuyMediator:ctor()
    AuctionBuyMediator.super.ctor(self)
end

function AuctionBuyMediator:InitMultiPanel()
    AuctionBuyMediator.super.InitMultiPanel(self)
end

function AuctionBuyMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_AuctionBuy_Open,
        noticeTable.Layer_AuctionBuy_Close,
        noticeTable.AuctionBidResp
    }
end

function AuctionBuyMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_AuctionBuy_Open == name then
        self:OpenLayer(data)

    elseif noticeTable.Layer_AuctionBuy_Close == name or noticeTable.AuctionBidResp == name then
        self:CloseLayer()
    end
end

function AuctionBuyMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer    = requireLayerUI("auction_layer/AuctionBuyLayer").create()
        self._type     = global.UIZ.UI_NORMAL
        self._hideLast = false
        self._GUI_ID   = SLDefine.LAYERID.AuctionBuyGUI

        AuctionBuyMediator.super.OpenLayer(self)

        self._layer:InitGUI(data)

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer._quickUI.Panel_2,
            index = global.SUIComponentTable.AuctionBuy
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

function AuctionBuyMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = 
    {
        index = global.SUIComponentTable.AuctionBuy
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    AuctionBuyMediator.super.CloseLayer(self)
end

return AuctionBuyMediator