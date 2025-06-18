local BaseUIMediator        = requireMediator("BaseUIMediator")
local TradingBankCostZFPanelMediator = class('TradingBankCostZFPanelMediator', BaseUIMediator)
TradingBankCostZFPanelMediator.NAME = "TradingBankCostZFPanelMediator"

function TradingBankCostZFPanelMediator:ctor()
    TradingBankCostZFPanelMediator.super.ctor(self)
end

function TradingBankCostZFPanelMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBankCostZFPanel_Open,
        noticeTable.Layer_TradingBankCostZFPanel_Close,
        noticeTable.Layer_TradingBankBuyEquip_Tips,
    }
end

function TradingBankCostZFPanelMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()

    if noticeTable.Layer_TradingBankCostZFPanel_Open == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_TradingBankCostZFPanel_Close == noticeName then
        self:CloseLayer()
    elseif noticeTable.Layer_TradingBankBuyEquip_Tips == noticeName then
        self:OnTips(noticeData)
    end
end

function TradingBankCostZFPanelMediator:OpenLayer(Data)
    if not (self._layer) then
        if Data.parent then
            self._layer = requireLayerUI("trading_bank_layer/TradingBankCostZFPanel").create(Data)
            self._layer:addTo(Data.parent)
        end
    end
end

function TradingBankCostZFPanelMediator:OnTips(data)
    if not self._layer then
        return
    end
    self._layer:OnTips(data)
end

function TradingBankCostZFPanelMediator:CloseLayer()
    if not self._layer then
        return
    end
    self._layer:exitLayer()
    self._layer:removeFromParent()
    self._layer = nil
end

return TradingBankCostZFPanelMediator