local BaseUIMediator = requireMediator("BaseUIMediator")
local TradingBankLookHeroSuperEquipMediator = class("TradingBankLookHeroSuperEquipMediator", BaseUIMediator)
TradingBankLookHeroSuperEquipMediator.NAME = "TradingBankLookHeroSuperEquipMediator"

function TradingBankLookHeroSuperEquipMediator:ctor()
    TradingBankLookHeroSuperEquipMediator.super.ctor(self)
    self._layer = nil
end

function TradingBankLookHeroSuperEquipMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBank_Look_Player_Super_Equip_Open_Hero,
        noticeTable.Layer_TradingBank_Look_Player_Child_Del_Hero,
    }
end

function TradingBankLookHeroSuperEquipMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_TradingBank_Look_Player_Super_Equip_Open_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_TradingBank_Look_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP == noticeData then
            self:CloseLayer()
        end
    end
end

function TradingBankLookHeroSuperEquipMediator:OpenLayer(noticeData)
    if not self._layer then
        local PlayerEquipLayer = requireLayerUI("hero_tradingbank_layer/HeroSuperEquipLayer")
        local layer = PlayerEquipLayer.create(noticeData)

        local data = {}
        data.child = layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP
        data.init = noticeData and noticeData.init
        self._layer = layer
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_TRAD_HERO_LOOK_FRAME_PAGE_ADD, data)

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function TradingBankLookHeroSuperEquipMediator:CloseLayer()
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

return TradingBankLookHeroSuperEquipMediator