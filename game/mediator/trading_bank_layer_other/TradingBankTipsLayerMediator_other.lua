local BaseUIMediator        = requireMediator("BaseUIMediator")
local TradingBankTipsLayerMediator_other = class('TradingBankTipsLayerMediator_other', BaseUIMediator)
TradingBankTipsLayerMediator_other.NAME = "TradingBankTipsLayerMediator_other"

function TradingBankTipsLayerMediator_other:ctor()
    TradingBankTipsLayerMediator_other.super.ctor(self)
    self._mr = global.UIZ.UI_NORMAL
end

function TradingBankTipsLayerMediator_other:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBankTipsLayer_Open_other,
        noticeTable.Layer_TradingBankTipsLayer_Close_other,
        noticeTable.PlayerPropertyInited,
    }
end

function TradingBankTipsLayerMediator_other:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    if noticeTable.Layer_TradingBankTipsLayer_Open_other == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_TradingBankTipsLayer_Close_other == noticeName then
        self:CloseLayer()
    elseif noticeTable.PlayerPropertyInited == noticeName then
        self._mr = global.UIZ.UI_TOBOX
    end
end

function TradingBankTipsLayerMediator_other:OpenLayer(Data)
    if not (self._layer) then
        self._layer = requireLayerUI("trading_bank_layer_other/TradingBankTipsLayer").create(Data)
        self._type        = self._mr
        dump(Data, "open")
        if Data and Data.canmove then
            self._type        = global.UIZ.UI_NORMAL
            self._responseMoved = self._layer._root.Image_1
        else
            self._responseMoved = nil
        end
        TradingBankTipsLayerMediator_other.super.OpenLayer(self)
    end
end

function TradingBankTipsLayerMediator_other:CloseLayer()
    if not self._layer then
        return
    end
    TradingBankTipsLayerMediator_other.super.CloseLayer(self)
end

return TradingBankTipsLayerMediator_other