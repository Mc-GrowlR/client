local BaseUIMediator = requireMediator("BaseUIMediator")
local AuctionBiddingMediator = class('AuctionBiddingMediator', BaseUIMediator)
AuctionBiddingMediator.NAME = "AuctionBiddingMediator"

function AuctionBiddingMediator:ctor()
    AuctionBiddingMediator.super.ctor(self)
end

function AuctionBiddingMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_AuctionBidding_Open,
        noticeTable.Layer_AuctionBidding_Close,
        noticeTable.AuctionBiddingListResp,
        noticeTable.AuctionWorldItemAdd,
        noticeTable.AuctionWorldItemDel,
        noticeTable.AuctionWorldItemChange,
    }
end

function AuctionBiddingMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_AuctionBidding_Open == noticeID then
        self:OnOpen(data)

    elseif noticeTable.Layer_AuctionBidding_Close == noticeID then
        self:OnClose()

    elseif noticeTable.AuctionBiddingListResp == noticeID then
        self:OnAuctionBiddingListResp(data)

    elseif noticeTable.AuctionWorldItemAdd == noticeID then
        self:OnAuctionWorldItemAdd(data)

    elseif noticeTable.AuctionWorldItemDel == noticeID then
        self:OnAuctionWorldItemDel(data)

    elseif noticeTable.AuctionWorldItemChange == noticeID then
        self:OnAuctionWorldItemChange(data)
    end
end

function AuctionBiddingMediator:OnOpen(data)
    if not (self._layer) then
        self._layer = requireLayerUI("auction_layer/AuctionBiddingLayer").create()
        data.parent:addChild(self._layer)

        -- for GUI
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer._quickUI.Panel_1,
            index = global.SUIComponentTable.AuctionBidding
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

function AuctionBiddingMediator:OnClose()
    -- 自定义组件挂接
    local componentData = 
    {
        index = global.SUIComponentTable.AuctionBidding
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if not self._layer then
        return false
    end
    self._layer:removeFromParent()
    self._layer = nil
end

function AuctionBiddingMediator:OnAuctionBiddingListResp(data)
    if not self._layer then
        return false
    end
    self._layer:OnAuctionBiddingListResp(data)
end

function AuctionBiddingMediator:OnAuctionWorldItemAdd(data)
    if not self._layer then
        return false
    end
    self._layer:OnAuctionItemAdd(data)
end

function AuctionBiddingMediator:OnAuctionWorldItemDel(data)
    if not self._layer then
        return false
    end
    self._layer:OnAuctionItemDel(data)
end

function AuctionBiddingMediator:OnAuctionWorldItemChange(data)
    if not self._layer then
        return false
    end
    self._layer:OnAuctionItemChange(data)
end

return AuctionBiddingMediator
