local BaseUIMediator        = requireMediator("BaseUIMediator")
local TradingBankSearchServerLayerMediator_other = class('TradingBankSearchServerLayerMediator_other', BaseUIMediator)
TradingBankSearchServerLayerMediator_other.NAME = "TradingBankSearchServerLayerMediator_other"

function TradingBankSearchServerLayerMediator_other:ctor()
    TradingBankSearchServerLayerMediator_other.super.ctor(self)
end

function TradingBankSearchServerLayerMediator_other:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBankSearchServerLayer_Open_other,
        noticeTable.Layer_TradingBankSearchServerLayer_Close_other,
    }
end

function TradingBankSearchServerLayerMediator_other:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    if noticeTable.Layer_TradingBankSearchServerLayer_Open_other == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_TradingBankSearchServerLayer_Close_other == noticeName then
        self:CloseLayer()
    end
end

function TradingBankSearchServerLayerMediator_other:OpenLayer(data)
    if not (self._layer) then
        self._layer = requireLayerUI("trading_bank_layer_other/TradingBankSearchServerLayer").create(data)
        self._type        = global.UIZ.UI_NORMAL
        TradingBankSearchServerLayerMediator_other.super.OpenLayer(self)
    end
end

function TradingBankSearchServerLayerMediator_other:CloseLayer()
    if not self._layer then
        return
    end
    TradingBankSearchServerLayerMediator_other.super.CloseLayer(self)
end

return TradingBankSearchServerLayerMediator_other