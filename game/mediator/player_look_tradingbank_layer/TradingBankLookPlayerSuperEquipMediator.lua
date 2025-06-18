local BaseUIMediator = requireMediator("BaseUIMediator")
local TradingBankLookPlayerSuperEquipMediator = class("TradingBankLookPlayerSuperEquipMediator", BaseUIMediator)
TradingBankLookPlayerSuperEquipMediator.NAME = "TradingBankLookPlayerSuperEquipMediator"

function TradingBankLookPlayerSuperEquipMediator:ctor()
    TradingBankLookPlayerSuperEquipMediator.super.ctor(self)
    self._layer = nil
end

function TradingBankLookPlayerSuperEquipMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBank_Look_Player_Super_Equip_Open,
        noticeTable.Layer_TradingBank_Look_Player_Child_Del,
    }
end

function TradingBankLookPlayerSuperEquipMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_TradingBank_Look_Player_Super_Equip_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_TradingBank_Look_Player_Child_Del then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP == noticeData then
            self:CloseLayer()
        end
    end
end

function TradingBankLookPlayerSuperEquipMediator:OpenLayer(noticeData)
    if not self._layer then
        local PlayerEquipLayer = requireLayerUI("player_tradingbank_layer/PlayerSuperEquipLayer")
        local layer = PlayerEquipLayer.create(noticeData)

        local data = {}
        data.child = layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP
        data.init = noticeData and noticeData.init
        self._layer = layer
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_TRAD_PLAYER_LOOK_FRAME_PAGE_ADD, data)

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function TradingBankLookPlayerSuperEquipMediator:CloseLayer()
    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil

        -- 异常处理
        if not global.isWinPlayMode then
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel, { from = ItemMoveProxy.ItemFrom.PALYER_EQUIP })
        end
    end
end

return TradingBankLookPlayerSuperEquipMediator