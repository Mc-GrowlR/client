local BaseUIMediator        = requireMediator("BaseUIMediator")
local TradingBankTips2LayerMediator_other = class('TradingBankTips2LayerMediator_other', BaseUIMediator)
TradingBankTips2LayerMediator_other.NAME = "TradingBankTips2LayerMediator_other"

function TradingBankTips2LayerMediator_other:ctor()
    TradingBankTips2LayerMediator_other.super.ctor(self)
    self._mr = global.UIZ.UI_NORMAL
end

function TradingBankTips2LayerMediator_other:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBankTips2Layer_Open_other,
        noticeTable.Layer_TradingBankTips2Layer_Close_other,
        noticeTable.PlayerPropertyInited,
    }
end

function TradingBankTips2LayerMediator_other:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    if noticeTable.Layer_TradingBankTips2Layer_Open_other == noticeName then

        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_TradingBankTips2Layer_Close_other == noticeName then
        self:CloseLayer()
    elseif noticeTable.PlayerPropertyInited == noticeName then
        self._mr = global.UIZ.UI_TOBOX
    end
end

function TradingBankTips2LayerMediator_other:OpenLayer(Data)
    if not (self._layer) then
        self._layer = requireLayerUI("trading_bank_layer_other/TradingBankTips2Layer").create(Data)
        self._type        = self._mr
        dump(Data, "open")
        if Data and Data.canmove then
            self._type        = global.UIZ.UI_NORMAL
            self._responseMoved = self._layer._root.Image_1
        else
            self._responseMoved = nil
        end
        TradingBankTips2LayerMediator_other.super.OpenLayer(self)
    end
end

function TradingBankTips2LayerMediator_other:CloseLayer()
    if not self._layer then
        return
    end
    TradingBankTips2LayerMediator_other.super.CloseLayer(self)
end


return TradingBankTips2LayerMediator_other