local BaseLayer = requireLayerUI("BaseLayer")
local AuctionTimeoutLayer = class("AuctionTimeoutLayer", BaseLayer)

function AuctionTimeoutLayer:ctor()
    AuctionTimeoutLayer.super.ctor(self)
end

function AuctionTimeoutLayer.create()
    local ui = AuctionTimeoutLayer.new()
    if ui and ui:Init() then
        return ui
    end
    return nil
end

function AuctionTimeoutLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function AuctionTimeoutLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_AUCTION_TIMEOUT)
    AuctionTimeout.main(data)
end

return AuctionTimeoutLayer