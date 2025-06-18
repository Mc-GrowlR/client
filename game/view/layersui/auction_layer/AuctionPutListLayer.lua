local BaseLayer = requireLayerUI("BaseLayer")
local AuctionPutListLayer = class("AuctionPutListLayer", BaseLayer)

local QuickCell = requireUtil("QuickCell")

function AuctionPutListLayer:ctor()
    AuctionPutListLayer.super.ctor(self)
 
    self._cells = {}
    self._items = {}

    self._bagCells = {}
    self._bagItems = {}
end

function AuctionPutListLayer.create(...)
    local ui = AuctionPutListLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function AuctionPutListLayer:Init(data)
    self._quickUI = ui_delegate(self)
    return true
end

function AuctionPutListLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_AUCTION_PUT_LIST)
    AuctionPutList.main()
    
    return true
end

function AuctionPutListLayer:OnAuctionPutListResp(items)
    if AuctionPutList and AuctionPutList.OnUpdatePutList then
        AuctionPutList.OnUpdatePutList(items)
    end
end

function AuctionPutListLayer:OnAuctionPutinResp(data)
    local item = data.item
    if AuctionPutList and AuctionPutList.OnPutInItem then
        AuctionPutList.OnPutInItem(item)
    end
end

function AuctionPutListLayer:OnAuctionPutoutResp(item)
    if AuctionPutList and AuctionPutList.OnPutOutItem then
        AuctionPutList.OnPutOutItem(item)
    end
end

function AuctionPutListLayer:UpdateBag()
    -- if AuctionPutList and AuctionPutList.UpdateShowBagList then
    --     AuctionPutList.UpdateShowBagList()
    -- end
end

return AuctionPutListLayer