local BaseUIMediator        = requireMediator("BaseUIMediator")
local TradingBankTipsLayerMediator = class('TradingBankTipsLayerMediator', BaseUIMediator)
TradingBankTipsLayerMediator.NAME = "TradingBankTipsLayerMediator"

function TradingBankTipsLayerMediator:ctor()
    TradingBankTipsLayerMediator.super.ctor(self)
    self._mr = global.UIZ.UI_NORMAL
end

function TradingBankTipsLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBankTipsLayer_Open,
        noticeTable.Layer_TradingBankTipsLayer_Close,
        noticeTable.PlayerPropertyInited,
    }
end

function TradingBankTipsLayerMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    if noticeTable.Layer_TradingBankTipsLayer_Open == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_TradingBankTipsLayer_Close == noticeName then
        self:CloseLayer()
    elseif noticeTable.PlayerPropertyInited == noticeName then
        self._mr = global.UIZ.UI_TOBOX
    end
end

function TradingBankTipsLayerMediator:OpenLayer(Data)
    if not (self._layer) then
        self._layer = requireLayerUI("trading_bank_layer/TradingBankTipsLayer").create(Data)
        self._type        = self._mr
        dump(Data, "open")
        if Data and Data.canmove then
            self._type        = global.UIZ.UI_NORMAL
            self._responseMoved = self._layer._root.Image_1
        else
            self._responseMoved = nil
        end
        TradingBankTipsLayerMediator.super.OpenLayer(self)
    end
end

function TradingBankTipsLayerMediator:CloseLayer()
    if not self._layer then
        return
    end
    TradingBankTipsLayerMediator.super.CloseLayer(self)
end

return TradingBankTipsLayerMediator