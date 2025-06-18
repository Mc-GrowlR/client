local BaseLayer = requireLayerUI("BaseLayer")
local AuctionBidLayer = class("AuctionBidLayer", BaseLayer)

function AuctionBidLayer:ctor()
    AuctionBidLayer.super.ctor(self)
end

function AuctionBidLayer.create()
    local ui = AuctionBidLayer.new()
    if ui and ui:Init() then
        return ui
    end
    return nil
end

function AuctionBidLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function AuctionBidLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_AUCTION_BID)
    AuctionBid.main(data)
end

return AuctionBidLayer