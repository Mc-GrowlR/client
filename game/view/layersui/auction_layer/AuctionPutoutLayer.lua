local BaseLayer = requireLayerUI("BaseLayer")
local AuctionPutoutLayer = class("AuctionPutoutLayer", BaseLayer)

function AuctionPutoutLayer:ctor()
    AuctionPutoutLayer.super.ctor(self)
end

function AuctionPutoutLayer.create()
    local ui = AuctionPutoutLayer.new()
    if ui and ui:Init() then
        return ui
    end
    return nil
end

function AuctionPutoutLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function AuctionPutoutLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_AUCTION_PUTOUT)
    AuctionPutout.main(data)
end

return AuctionPutoutLayer