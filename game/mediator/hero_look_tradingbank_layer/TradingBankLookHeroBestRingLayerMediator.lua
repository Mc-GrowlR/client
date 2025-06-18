local BaseUIMediator        = requireMediator("BaseUIMediator")
local TradingBankLookHeroBestRingLayerMediator = class('TradingBankLookHeroBestRingLayerMediator', BaseUIMediator)
TradingBankLookHeroBestRingLayerMediator.NAME = "TradingBankLookHeroBestRingLayerMediator"


function TradingBankLookHeroBestRingLayerMediator:ctor()
    TradingBankLookHeroBestRingLayerMediator.super.ctor(self)
end

function TradingBankLookHeroBestRingLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBank_Look_PlayerBestRing_Open_Hero,
        noticeTable.Layer_TradingBank_Look_PlayerBestRing_Close_Hero,
    }
end

function TradingBankLookHeroBestRingLayerMediator:handleNotification(notification)
    local notices    = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_TradingBank_Look_PlayerBestRing_Open_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_TradingBank_Look_PlayerBestRing_Close_Hero then
        self:CloseLayer()
    end
end

function TradingBankLookHeroBestRingLayerMediator:OpenLayer(noticeData)
    if not (self._layer) then
        local path = "hero_tradingbank_layer/HeroBestRingLayer"
        self._layer = requireLayerUI(path).create(noticeData)
        self._type = global.UIZ.UI_NORMAL

        self._GUI_ID = SLDefine.LAYERID.TradingBankHeroBestRingGUI
        TradingBankLookHeroBestRingLayerMediator.super.OpenLayer(self)

        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig("mobile_hero_best_ring", self._layer)
        self._layer:InitHideIconPos()
    else
        if not noticeData.open then
            self:CloseLayer()
        else
            self._layer:setVisible(true)
        end
    end

end

function TradingBankLookHeroBestRingLayerMediator:CloseLayer()
    TradingBankLookHeroBestRingLayerMediator.super.CloseLayer(self)
end

return TradingBankLookHeroBestRingLayerMediator