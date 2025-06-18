local BaseUIMediator        = requireMediator("BaseUIMediator")
local TradingBankZFPlayerLayerMediator = class('TradingBankZFPlayerLayerMediator', BaseUIMediator)
TradingBankZFPlayerLayerMediator.NAME = "TradingBankZFPlayerLayerMediator"

function TradingBankZFPlayerLayerMediator:ctor()
    TradingBankZFPlayerLayerMediator.super.ctor(self)
end

function TradingBankZFPlayerLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBankZFPlayerLayer_Open,
        noticeTable.Layer_TradingBankZFPlayerLayer_Close,
    }
end

function TradingBankZFPlayerLayerMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable    = global.NoticeTable
    local noticeData    = notification:getBody()

    if noticeTable.Layer_TradingBankZFPlayerLayer_Open == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_TradingBankZFPlayerLayer_Close == noticeName then
        self:CloseLayer()
    end
end

function TradingBankZFPlayerLayerMediator:OpenLayer(Data)
    if not (self._layer) then
        self._layer = requireLayerUI("trading_bank_layer/TradingBankZFPlayerLayer").create(Data)
        self._type = global.UIZ.UI_NORMAL
        TradingBankZFPlayerLayerMediator.super.OpenLayer(self)
    end
end

function TradingBankZFPlayerLayerMediator:CloseLayer()
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerPanel_Close)
    TradingBankZFPlayerLayerMediator.super.CloseLayer(self)
end

return TradingBankZFPlayerLayerMediator