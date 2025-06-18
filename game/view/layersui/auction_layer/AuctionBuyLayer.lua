local BaseLayer = requireLayerUI("BaseLayer")
local AuctionBuyLayer = class("AuctionBuyLayer", BaseLayer)

function AuctionBuyLayer:ctor()
    AuctionBuyLayer.super.ctor(self)
end

function AuctionBuyLayer.create()
    local ui = AuctionBuyLayer.new()
    if ui and ui:Init() then
        return ui
    end
    return nil
end

function AuctionBuyLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function AuctionBuyLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_AUCTION_BUY)
    AuctionBuy.main(data)
end

return AuctionBuyLayer