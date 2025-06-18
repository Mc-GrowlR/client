local BaseUIMediator = requireMediator("BaseUIMediator")
local TradingBankLookHeroExtraAttLayerMediator = class("TradingBankLookHeroExtraAttLayerMediator", BaseUIMediator)
TradingBankLookHeroExtraAttLayerMediator.NAME = "TradingBankLookHeroExtraAttLayerMediator"

function TradingBankLookHeroExtraAttLayerMediator:ctor()
    TradingBankLookHeroExtraAttLayerMediator.super.ctor(self)
    self._layer = nil
end

function TradingBankLookHeroExtraAttLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBank_Look_Player_Extra_Att_Open_Hero,
        noticeTable.Layer_TradingBank_Look_Player_Child_Del_Hero,
    }
end

function TradingBankLookHeroExtraAttLayerMediator:handleNotification(notification)
    local notices    = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_TradingBank_Look_Player_Extra_Att_Open_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_TradingBank_Look_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO == noticeData then
            self:CloseLayer()
        end
    end
end

function TradingBankLookHeroExtraAttLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "hero_tradingbank_layer/HeroExtraAttLayer"
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO
        data.init = noticeData and noticeData.init
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_TRAD_HERO_LOOK_FRAME_PAGE_ADD, data)

        if SL:GetMetaValue("GAME_DATA","TradingBankHideSUI") ~= 1 then
            -- 自定义组件挂接
            local componentData = {
                root = self._layer._root,
                index = global.SUIComponentTable.PlayerAttr
            }
            global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        end
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function TradingBankLookHeroExtraAttLayerMediator:CloseLayer()
    if SL:GetMetaValue("GAME_DATA","TradingBankHideSUI") ~= 1 then
        -- 自定义组件挂接
        local componentData = {
            index = global.SUIComponentTable.PlayerAttr
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    end

    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return TradingBankLookHeroExtraAttLayerMediator