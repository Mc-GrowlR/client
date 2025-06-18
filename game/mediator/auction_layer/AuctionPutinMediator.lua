local BaseUIMediator = requireMediator("BaseUIMediator")
local AuctionPutinMediator = class("AuctionPutinMediator", BaseUIMediator)
AuctionPutinMediator.NAME = "AuctionPutinMediator"

function AuctionPutinMediator:ctor()
    AuctionPutinMediator.super.ctor(self)
end

function AuctionPutinMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_AuctionPutin_Open,
        noticeTable.Layer_AuctionPutin_Close,
        noticeTable.AuctionPutinResp,
    }
end

function AuctionPutinMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_AuctionPutin_Open == name then
        self:OpenLayer(data)

    elseif noticeTable.Layer_AuctionPutin_Close == name or noticeTable.AuctionPutinResp == name then
        self:CloseLayer()
    end
end

function AuctionPutinMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer    = requireLayerUI("auction_layer/AuctionPutinLayer").create()
        self._type     = global.UIZ.UI_NORMAL
        self._escClose = true
        self._GUI_ID   = SLDefine.LAYERID.AuctionPutinGUI

        AuctionPutinMediator.super.OpenLayer(self)

        self._layer:InitGUI(data)

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer._quickUI.Panel_2,
            index = global.SUIComponentTable.AuctionPutin
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

function AuctionPutinMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = 
    {
        index = global.SUIComponentTable.AuctionPutin
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if not self._layer then
        return false
    end

    AuctionPutinMediator.super.CloseLayer(self)
end

return AuctionPutinMediator