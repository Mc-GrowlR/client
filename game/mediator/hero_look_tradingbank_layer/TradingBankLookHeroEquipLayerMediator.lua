local BaseUIMediator = requireMediator("BaseUIMediator")
local TradingBankLookHeroEquipLayerMediator = class("TradingBankLookHeroEquipLayerMediator", BaseUIMediator)
TradingBankLookHeroEquipLayerMediator.NAME = "TradingBankLookHeroEquipLayerMediator"

function TradingBankLookHeroEquipLayerMediator:ctor()
    TradingBankLookHeroEquipLayerMediator.super.ctor(self)
    self._layer = nil
end

function TradingBankLookHeroEquipLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBank_Look_Player_Equip_Open_Hero,
        noticeTable.Layer_TradingBank_Look_Player_Child_Del_Hero,
    }
end

function TradingBankLookHeroEquipLayerMediator:handleNotification(notification)
    local notices    = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_TradingBank_Look_Player_Equip_Open_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_TradingBank_Look_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP == noticeData then
            self:CloseLayer()
        end
    end
end

function TradingBankLookHeroEquipLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "hero_tradingbank_layer/HeroEquipLayer"
        local PlayerEquipLayer = requireLayerUI(path)
        local layer = PlayerEquipLayer.create(noticeData)
        self._layer = layer

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP
        data.init = noticeData and noticeData.init
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_TRAD_HERO_LOOK_FRAME_PAGE_ADD, data)
        
        if SL:GetMetaValue("GAME_DATA","TradingBankHideSUI") ~= 1 then
            -- 自定义组件挂接
            local componentData = {
                root = self._layer._root,
                index = global.SUIComponentTable.PlayerEquipO_hero
            }
            global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
            local componentData = {
                root = global.isWinPlayMode and self._layer._root:getChildByName("Image_equippanel") or self._layer._root:getChildByName("Image_20"),
                index = global.SUIComponentTable.PlayerEquipBO_hero
            }
            global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        end
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function TradingBankLookHeroEquipLayerMediator:CloseLayer()
    if SL:GetMetaValue("GAME_DATA","TradingBankHideSUI") ~= 1 then
        local componentData = {
            index = global.SUIComponentTable.PlayerEquipO_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
        local componentData = {
            index = global.SUIComponentTable.PlayerEquipBO_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    end

    if self._layer then
        self._layer:OnClose()
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return TradingBankLookHeroEquipLayerMediator