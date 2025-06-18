local BaseUIMediator        = requireMediator("BaseUIMediator")
local TradingBankPlayerPanel = class('TradingBankPlayerPanel', BaseUIMediator)
TradingBankPlayerPanel.NAME = "TradingBankPlayerPanel"

function TradingBankPlayerPanel:ctor()
    TradingBankPlayerPanel.super.ctor(self)
end

function TradingBankPlayerPanel:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBankPlayerPanel_Open,
        noticeTable.Layer_TradingBankPlayerPanel_Close,
        noticeTable.Layer_TradingBank_Look_Player_LookShowPanel,
        noticeTable.Layer_TradingBank_Look_Player_LookShowPanel_Hero
    }
end

function TradingBankPlayerPanel:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()

    if noticeTable.Layer_TradingBankPlayerPanel_Open == noticeName then

        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_TradingBankPlayerPanel_Close == noticeName then
        self:CloseLayer()
    elseif noticeTable.Layer_TradingBank_Look_Player_LookShowPanel == noticeName then
        self:ShowPlayerInfo(noticeData,1)
    elseif noticeTable.Layer_TradingBank_Look_Player_LookShowPanel_Hero == noticeName then
        self:ShowPlayerInfo(noticeData,2)
    
    end
end

function TradingBankPlayerPanel:OpenLayer(noticeData)
    if not (self._layer) then
        if noticeData.parent then
            self._layer = requireLayerUI("trading_bank_layer/TradingBankPlayerPanel").create(noticeData)
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

function TradingBankPlayerPanel:ShowPlayerInfo(data,type)
    if not (self._layer) then
        return
    end
    self._layer:ShowPlayerInfo(data,type)
end


function TradingBankPlayerPanel:CloseLayer()
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


return TradingBankPlayerPanel