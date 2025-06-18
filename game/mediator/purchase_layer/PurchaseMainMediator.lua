local BaseUIMediator = requireMediator("BaseUIMediator")
local PurchaseMainMediator = class('PurchaseMainMediator', BaseUIMediator)
PurchaseMainMediator.NAME = "PurchaseMainMediator"

function PurchaseMainMediator:ctor()
    PurchaseMainMediator.super.ctor(self)
end

function PurchaseMainMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_PurchaseMain_Open,
        noticeTable.Layer_PurchaseMain_Close,
    }
end

function PurchaseMainMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_PurchaseMain_Open == noticeID then
        self:OnOpen(data)

    elseif noticeTable.Layer_PurchaseMain_Close == noticeID then
        self:CloseLayer()
    end
end

function PurchaseMainMediator:OnOpen(data)
    if not (self._layer) then
        self._layer     = requireLayerUI("purchase_layer/PurchaseMainLayer").create()
        self._type      = global.UIZ.UI_NORMAL
        self._escClose  = true
        self._GUI_ID    = SLDefine.LAYERID.PurchaseMainGUI

        PurchaseMainMediator.super.OpenLayer(self)
        self._layer:InitGUI(data)

    end
end

function PurchaseMainMediator:CloseLayer()
    if not self._layer then
        return false
    end
    
    self._layer:OnClose()
    PurchaseMainMediator.super.CloseLayer(self)
end

return PurchaseMainMediator
