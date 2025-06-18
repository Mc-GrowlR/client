local BaseLayer = requireLayerUI("BaseLayer")
local AuctionBiddingLayer = class("AuctionBiddingLayer", BaseLayer)

local QuickCell = requireUtil("QuickCell")

function AuctionBiddingLayer:ctor()
    AuctionBiddingLayer.super.ctor(self)

    self._proxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
    self._cells = {}
    self._items = {}
end

function AuctionBiddingLayer.create(...)
    local ui = AuctionBiddingLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function AuctionBiddingLayer:Init(data)
    self._quickUI = ui_delegate(self)
    return true
end

function AuctionBiddingLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_AUCTION_BIDDING)
    AuctionBidding.main()
end

function AuctionBiddingLayer:OnAuctionBiddingListResp(items)
    if AuctionBidding and AuctionBidding.UpdateBiddingList then
        AuctionBidding.UpdateBiddingList(items)
    end
end

function AuctionBiddingLayer:OnAuctionItemAdd(data)
    if data and data.item then
        if AuctionBidding and AuctionBidding.OnAuctionItemAdd then
            AuctionBidding.OnAuctionItemAdd(data.item)
        end
    end
end

function AuctionBiddingLayer:OnAuctionItemDel(data)
    if data and data.item then
        if AuctionBidding and AuctionBidding.OnAuctionItemDel then
            AuctionBidding.OnAuctionItemDel(data.item)
        end
    end
end

function AuctionBiddingLayer:OnAuctionItemChange(data)
    if data and data.item then
        if AuctionBidding and AuctionBidding.OnAuctionItemChange then
            AuctionBidding.OnAuctionItemChange(data.item)
        end
    end
end

return AuctionBiddingLayer