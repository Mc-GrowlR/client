local BaseUIMediator = requireMediator("BaseUIMediator")
local PurchasePutInMediator = class("PurchasePutInMediator", BaseUIMediator)
PurchasePutInMediator.NAME = "PurchasePutInMediator"

function PurchasePutInMediator:ctor()
    PurchasePutInMediator.super.ctor(self)
end

function PurchasePutInMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_PurchasePutIn_Open,
        noticeTable.Layer_PurchasePutIn_Close,
    }
end

function PurchasePutInMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_PurchasePutIn_Open == name then
        self:OpenLayer(data)

    elseif noticeTable.Layer_PurchasePutIn_Close == name then
        self:CloseLayer()
    end
end

function PurchasePutInMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer    = requireLayerUI("purchase_layer/PurchasePutInLayer").create()
        self._type     = global.UIZ.UI_NORMAL
        self._escClose = true
        self._GUI_ID   = SLDefine.LAYERID.PurchasePutInGUI

        PurchasePutInMediator.super.OpenLayer(self)

        self._layer:InitGUI(data)
    end
end

function PurchasePutInMediator:CloseLayer()
    if not self._layer then
        return false
    end

    PurchasePutInMediator.super.CloseLayer(self)
end

return PurchasePutInMediator