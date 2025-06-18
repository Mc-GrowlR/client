local BaseUIMediator = requireMediator("BaseUIMediator")
local AuctionPutListMediator = class('AuctionPutListMediator', BaseUIMediator)
AuctionPutListMediator.NAME = "AuctionPutListMediator"

function AuctionPutListMediator:ctor()
    AuctionPutListMediator.super.ctor(self)
end

function AuctionPutListMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_AuctionPutList_Open,
        noticeTable.Layer_AuctionPutList_Close,
        noticeTable.Bag_Oper_Data,
        noticeTable.AuctionPutListResp,
        noticeTable.AuctionPutinResp,
        noticeTable.AuctionPutoutResp,
        noticeTable.QuickUseItemAdd,
        noticeTable.QuickUseItemRmv,
        noticeTable.QuickUseItemChange,
        noticeTable.QuickUseItemRefresh,
    }
end

function AuctionPutListMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_AuctionPutList_Open == noticeID then
        self:OnOpen(data)

    elseif noticeTable.Layer_AuctionPutList_Close == noticeID then
        self:OnClose()

    elseif noticeTable.AuctionPutListResp == noticeID then
        self:OnAuctionPutListResp(data)

    elseif noticeTable.AuctionPutinResp == noticeID then
        self:OnAuctionPutinResp(data)

    elseif noticeTable.AuctionPutoutResp == noticeID then
        self:OnAuctionPutoutResp(data)
        
    elseif noticeTable.Bag_Oper_Data == noticeID
        or noticeTable.QuickUseItemAdd == noticeID
            or noticeTable.QuickUseItemRefresh == noticeID then
        self:OnUpdateBag()
    end
end

function AuctionPutListMediator:OnOpen(data)
    if not (self._layer) then
        self._layer = requireLayerUI("auction_layer/AuctionPutListLayer").create()
        data.parent:addChild(self._layer)

        -- for GUI
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer._quickUI.Panel_1,
            index = global.SUIComponentTable.AuctionPutlist
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

function AuctionPutListMediator:OnClose()
    -- 自定义组件挂接
    local componentData = 
    {
        index = global.SUIComponentTable.AuctionPutlist
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if not self._layer then
        return false
    end
    self._layer:removeFromParent()
    self._layer = nil
end

function AuctionPutListMediator:OnAuctionPutListResp(data)
    if not self._layer then
        return false
    end
    self._layer:OnAuctionPutListResp(data)
end

function AuctionPutListMediator:OnAuctionPutinResp(data)
    if not self._layer then
        return false
    end
    self._layer:OnAuctionPutinResp(data)
end

function AuctionPutListMediator:OnAuctionPutoutResp(data)
    if not self._layer then
        return false
    end
    self._layer:OnAuctionPutoutResp(data)
end

function AuctionPutListMediator:OnUpdateBag()
    if not self._layer then
        return false
    end
    self._layer:UpdateBag()
end

return AuctionPutListMediator