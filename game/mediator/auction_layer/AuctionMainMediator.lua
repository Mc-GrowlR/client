local BaseUIMediator = requireMediator("BaseUIMediator")
local AuctionMainMediator = class('AuctionMainMediator', BaseUIMediator)
AuctionMainMediator.NAME = "AuctionMainMediator"

function AuctionMainMediator:ctor()
    AuctionMainMediator.super.ctor(self)
end

function AuctionMainMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_AuctionMain_Open,
        noticeTable.Layer_AuctionMain_Close,
        noticeTable.AuctionItemUpdate,
        noticeTable.AuctionPutinResp,
        noticeTable.AuctionPutoutResp,
        noticeTable.AuctionPutListResp,
        noticeTable.AuctionBiddingListResp,
    }
end

function AuctionMainMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_AuctionMain_Open == noticeID then
        self:OnOpen(data)

    elseif noticeTable.Layer_AuctionMain_Close == noticeID then
        self:CloseLayer()

    elseif noticeTable.AuctionItemUpdate == noticeID
        or noticeTable.AuctionPutinResp == noticeID
            or noticeTable.AuctionPutoutResp == noticeID
                or noticeTable.AuctionPutListResp == noticeID
                    or noticeTable.AuctionBiddingListResp == noticeID then
        self:OnAuctionItemUpdate()
    end
end

function AuctionMainMediator:OnOpen(data)
    if not (self._layer) then
        self._layer = requireLayerUI("auction_layer/AuctionMainLayer").create()
        self._type     = global.UIZ.UI_NORMAL
        self._escClose = true
        self._GUI_ID   = SLDefine.LAYERID.AuctionMainGUI

        AuctionMainMediator.super.OpenLayer(self)
        self._layer:InitGUI(data)        
        LoadLayerCUIConfig(global.CUIKeyTable.AUCTION_FRAME, self._layer)

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer._quickUI.AttachLayout,
            index = global.SUIComponentTable.AuctionMain
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        
    end
end

function AuctionMainMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = 
    {
        index = global.SUIComponentTable.AuctionMain
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if not self._layer then
        return false
    end

    local AuctionProxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)
    AuctionProxy:Clear()
    AuctionProxy:RequestLeaveAuction()
    
    self._layer:OnClose()
    AuctionMainMediator.super.CloseLayer(self)
end

function AuctionMainMediator:OnAuctionItemUpdate()
    if not self._layer then
        return false
    end
    self._layer:UpdateGroupCells()
end

return AuctionMainMediator
