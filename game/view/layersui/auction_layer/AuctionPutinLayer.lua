local BaseLayer = requireLayerUI("BaseLayer")
local AuctionPutinLayer = class("AuctionPutinLayer", BaseLayer)

function AuctionPutinLayer:ctor()
    AuctionPutinLayer.super.ctor(self)
end

function AuctionPutinLayer.create()
    local ui = AuctionPutinLayer.new()
    if ui and ui:Init() then
        return ui
    end
    return nil
end

function AuctionPutinLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function AuctionPutinLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_AUCTION_PUTIN)
    AuctionPutin.main(data)
end

return AuctionPutinLayer