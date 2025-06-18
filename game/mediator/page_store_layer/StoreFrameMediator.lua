local BaseUIMediator = requireMediator("BaseUIMediator")
local StoreFrameMediator = class("StoreFrameMediator", BaseUIMediator)
StoreFrameMediator.NAME = "StoreFrameMediator"

function StoreFrameMediator:ctor()
    StoreFrameMediator.super.ctor( self )
end

function StoreFrameMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_StoreFrame_Open,
        noticeTable.Layer_StoreFrame_Close,
    }
end

function StoreFrameMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local id = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_StoreFrame_Open == id then
        self:OpenLayer(data)

    elseif noticeTable.Layer_StoreFrame_Close == id then
        self:CloseLayer()
    end
end

function StoreFrameMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer    = requireLayerUI("page_store_layer/StoreFrameLayer").create()
        self._type     = global.UIZ.UI_NORMAL
        self._escClose = true
        self._GUI_ID   = SLDefine.LAYERID.StoreFrameGUI

        StoreFrameMediator.super.OpenLayer(self)
        self._layer:InitGUI(data)
        LoadLayerCUIConfig(global.CUIKeyTable.STORE_FRAME, self._layer)
    else
        self._layer:PageTo(data)
    end
end

function StoreFrameMediator:CloseLayer()
    if self._layer then
        self._layer:OnClose()
    end
    StoreFrameMediator.super.CloseLayer(self)
end

return StoreFrameMediator
