local BaseUIMediator        = requireMediator("BaseUIMediator")
local TradingBankPlayerPanelMediator_other = class('TradingBankPlayerPanelMediator_other', BaseUIMediator)
TradingBankPlayerPanelMediator_other.NAME = "TradingBankPlayerPanelMediator_other"

function TradingBankPlayerPanelMediator_other:ctor()
    TradingBankPlayerPanelMediator_other.super.ctor(self)
end

function TradingBankPlayerPanelMediator_other:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBankPlayerPanel_Open_other,
        noticeTable.Layer_TradingBankPlayerPanel_Close_other,
        noticeTable.Layer_TradingBank_Look_Player_LookShowPanel,
        noticeTable.Layer_TradingBank_Look_Player_LookShowPanel_Hero
    }
end

function TradingBankPlayerPanelMediator_other:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()

    if noticeTable.Layer_TradingBankPlayerPanel_Open_other == noticeName then

        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_TradingBankPlayerPanel_Close_other == noticeName then
        self:CloseLayer()
    elseif noticeTable.Layer_TradingBank_Look_Player_LookShowPanel == noticeName then
        self:ShowPlayerInfo(noticeData,1)
    elseif noticeTable.Layer_TradingBank_Look_Player_LookShowPanel_Hero == noticeName then
        self:ShowPlayerInfo(noticeData,2)
    
    end
end

function TradingBankPlayerPanelMediator_other:OpenLayer(noticeData)
    dump(noticeData,"TradingBankPlayerPanelMediator_other____")
    if not (self._layer) then
        if noticeData.parent then
            self._layer = requireLayerUI("trading_bank_layer_other/TradingBankPlayerPanel").create(noticeData)
            self._layer:addTo(noticeData.parent)
            GUI.ATTACH_PARENT = self._layer
            self._layer:InitGUI(noticeData)
            if noticeData.position and self._layer._panel then
                self._layer._panel:setPosition(noticeData.position)
            end

            LoadLayerCUIConfig(global.CUIKeyTable.TRADE_PLAYER_FRAME, self._layer)
        end
    end
end

function TradingBankPlayerPanelMediator_other:ShowPlayerInfo(data,type)
    if not (self._layer) then
        return
    end
    self._layer:ShowPlayerInfo(data,type)
end


function TradingBankPlayerPanelMediator_other:CloseLayer()
    if not self._layer then
        return
    end
    if self._layer then
        self._layer:OnCloseMainLayer()
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Player_Close_Hero)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Player_Close)
    self._layer:removeFromParent()
    self._layer = nil
end


return TradingBankPlayerPanelMediator_other