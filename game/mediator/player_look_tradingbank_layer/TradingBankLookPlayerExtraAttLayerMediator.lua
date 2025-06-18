local BaseUIMediator = requireMediator("BaseUIMediator")
local TradingBankLookPlayerExtraAttLayerMediator = class("TradingBankLookPlayerExtraAttLayerMediator", BaseUIMediator)
TradingBankLookPlayerExtraAttLayerMediator.NAME = "TradingBankLookPlayerExtraAttLayerMediator"

function TradingBankLookPlayerExtraAttLayerMediator:ctor()
    TradingBankLookPlayerExtraAttLayerMediator.super.ctor(self)
    self._layer = nil
end

function TradingBankLookPlayerExtraAttLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBank_Look_Player_Extra_Att_Open,
        noticeTable.Layer_TradingBank_Look_Player_Child_Del,
    }
end

function TradingBankLookPlayerExtraAttLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_TradingBank_Look_Player_Extra_Att_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_TradingBank_Look_Player_Child_Del then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO == noticeData then
            self:CloseLayer()
        end
    end
end

function TradingBankLookPlayerExtraAttLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "player_tradingbank_layer/PlayerExtraAttLayer"
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO
        data.init = noticeData and noticeData.init
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_TRAD_PLAYER_LOOK_FRAME_PAGE_ADD, data)
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function TradingBankLookPlayerExtraAttLayerMediator:CloseLayer()
    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return TradingBankLookPlayerExtraAttLayerMediator