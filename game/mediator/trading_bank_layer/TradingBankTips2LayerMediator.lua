local BaseUIMediator        = requireMediator("BaseUIMediator")
local TradingBankTips2LayerMediator = class('TradingBankTips2LayerMediator', BaseUIMediator)
TradingBankTips2LayerMediator.NAME = "TradingBankTips2LayerMediator"

function TradingBankTips2LayerMediator:ctor()
    TradingBankTips2LayerMediator.super.ctor(self)
    self._mr = global.UIZ.UI_NORMAL
end

function TradingBankTips2LayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBankTips2Layer_Open,
        noticeTable.Layer_TradingBankTips2Layer_Close,
        noticeTable.PlayerPropertyInited,
    }
end

function TradingBankTips2LayerMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    if noticeTable.Layer_TradingBankTips2Layer_Open == noticeName then

        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_TradingBankTips2Layer_Close == noticeName then
        self:CloseLayer()
    elseif noticeTable.PlayerPropertyInited == noticeName then
        self._mr = global.UIZ.UI_TOBOX
    end
end

function TradingBankTips2LayerMediator:OpenLayer(Data)
    if not (self._layer) then
        self._layer = requireLayerUI("trading_bank_layer/TradingBankTips2Layer").create(Data)
        self._type        = self._mr
        dump(Data, "open")
        if Data and Data.canmove then
            self._type        = global.UIZ.UI_NORMAL
            self._responseMoved = self._layer._root.Image_1
            dump(self._responseMoved, "ssss2")
        else 
            self._responseMoved = nil
        end
        TradingBankTips2LayerMediator.super.OpenLayer(self)
    end
end

function TradingBankTips2LayerMediator:CloseLayer()
    if not self._layer then
        return
    end
    TradingBankTips2LayerMediator.super.CloseLayer(self)
end


return TradingBankTips2LayerMediator