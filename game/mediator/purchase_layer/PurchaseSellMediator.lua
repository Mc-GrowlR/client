local BaseUIMediator = requireMediator("BaseUIMediator")
local PurchaseSellMediator = class('PurchaseSellMediator', BaseUIMediator)
PurchaseSellMediator.NAME = "PurchaseSellMediator"

function PurchaseSellMediator:ctor()
    PurchaseSellMediator.super.ctor(self)
end

function PurchaseSellMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_PurchaseSell_Open,
        noticeTable.Layer_PurchaseSell_Close,
    }
end

function PurchaseSellMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_PurchaseSell_Open == noticeID then
        self:OnOpen(data)

    elseif noticeTable.Layer_PurchaseSell_Close == noticeID then
        self:OnClose()
    end
end

function PurchaseSellMediator:OnOpen(data)
    if not (self._layer) then
        self._layer     = requireLayerUI("purchase_layer/PurchaseSellLayer").create()
        self._type      = global.UIZ.UI_NORMAL
        self._escClose  = true
        self._GUI_ID    = SLDefine.LAYERID.PurchaseSellGUI

        PurchaseSellMediator.super.OpenLayer(self)
        self._layer:InitGUI(data) 
    end
end

function PurchaseSellMediator:OnClose()
    if not self._layer then
        return false
    end

    PurchaseSellMediator.super.CloseLayer(self)
end

return PurchaseSellMediator
