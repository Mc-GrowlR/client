local BaseUIMediator = requireMediator("BaseUIMediator")
local AuctionPutoutMediator = class("AuctionPutoutMediator", BaseUIMediator)
AuctionPutoutMediator.NAME = "AuctionPutoutMediator"

function AuctionPutoutMediator:ctor()
    AuctionPutoutMediator.super.ctor(self)
end

function AuctionPutoutMediator:InitMultiPanel()
    AuctionPutoutMediator.super.InitMultiPanel(self)
end

function AuctionPutoutMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_AuctionPutout_Open,
        noticeTable.Layer_AuctionPutout_Close,
        noticeTable.AuctionPutoutResp
    }
end

function AuctionPutoutMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_AuctionPutout_Open == name then
        self:OpenLayer(data)

    elseif noticeTable.Layer_AuctionPutout_Close == name or noticeTable.AuctionPutoutResp == name then
        self:CloseLayer()
    end
end

function AuctionPutoutMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer    = requireLayerUI("auction_layer/AuctionPutoutLayer").create()
        self._type     = global.UIZ.UI_NORMAL
        self._hideLast = false
        self._GUI_ID   = SLDefine.LAYERID.AuctionPutoutGUI

        AuctionPutoutMediator.super.OpenLayer(self)

        self._layer:InitGUI(data)

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer._quickUI.Panel_2,
            index = global.SUIComponentTable.AuctionPutout
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

function AuctionPutoutMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = 
    {
        index = global.SUIComponentTable.AuctionPutout
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    AuctionPutoutMediator.super.CloseLayer(self)
end

return AuctionPutoutMediator