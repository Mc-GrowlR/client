local BaseUIMediator        = requireMediator("BaseUIMediator")
local TradingBankLookPlayerBestRingLayerMediator = class('TradingBankLookPlayerBestRingLayerMediator', BaseUIMediator)
TradingBankLookPlayerBestRingLayerMediator.NAME = "TradingBankLookPlayerBestRingLayerMediator"

function TradingBankLookPlayerBestRingLayerMediator:ctor()
    TradingBankLookPlayerBestRingLayerMediator.super.ctor(self)
end

function TradingBankLookPlayerBestRingLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBank_Look_PlayerBestRing_Open,
        noticeTable.Layer_TradingBank_Look_PlayerBestRing_Close,
    }
end

function TradingBankLookPlayerBestRingLayerMediator:handleNotification(notification)
    local notices    = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_TradingBank_Look_PlayerBestRing_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_TradingBank_Look_PlayerBestRing_Close then
        self:CloseLayer()
    end
end

function TradingBankLookPlayerBestRingLayerMediator:OpenLayer(noticeData)
    if not (self._layer) then
        local path = "player_tradingbank_layer/PlayerBestRingLayer"
        self._layer = requireLayerUI(path).create(noticeData)
        self._type = global.UIZ.UI_NORMAL

        self._GUI_ID = SLDefine.LAYERID.TradingBankBestRingGUI
        TradingBankLookPlayerBestRingLayerMediator.super.OpenLayer(self)

        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig("mobile_best_ring", self._layer)
        self._layer:InitHideIconPos()
    else
        if not noticeData.open then
            self:CloseLayer()
        else
            self._layer:setVisible(true)
        end
    end

end

function TradingBankLookPlayerBestRingLayerMediator:CloseLayer()
    TradingBankLookPlayerBestRingLayerMediator.super.CloseLayer(self)
end

return TradingBankLookPlayerBestRingLayerMediator