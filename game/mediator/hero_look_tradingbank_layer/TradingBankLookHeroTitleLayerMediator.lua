local BaseUIMediator = requireMediator("BaseUIMediator")
local TradingBankLookHeroTitleLayerMediator = class("TradingBankLookHeroTitleLayerMediator", BaseUIMediator)
TradingBankLookHeroTitleLayerMediator.NAME = "TradingBankLookHeroTitleLayerMediator"

function TradingBankLookHeroTitleLayerMediator:ctor()
    TradingBankLookHeroTitleLayerMediator.super.ctor(self)
    self._layer = nil
end

function TradingBankLookHeroTitleLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBank_Look_Title_Attach_Hero,
        noticeTable.Layer_TradingBank_Look_Player_Child_Del_Hero,
    }
end

function TradingBankLookHeroTitleLayerMediator:handleNotification(notification)
    local notices    = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_TradingBank_Look_Title_Attach_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_TradingBank_Look_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE == noticeData then
            self:CloseLayer()
        end

    end
end

function TradingBankLookHeroTitleLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        self._layer = requireLayerUI("hero_tradingbank_layer/HeroTitleLayer").create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE
        data.init = noticeData and noticeData.init
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_TRAD_HERO_LOOK_FRAME_PAGE_ADD, data)

        if SL:GetMetaValue("GAME_DATA","TradingBankHideSUI") ~= 1 then
            -- 自定义组件挂接
            local componentData = {
                root = self._layer._root,
                index = global.SUIComponentTable.TitleO_hero
            }
            global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        end
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function TradingBankLookHeroTitleLayerMediator:CloseLayer()
    if SL:GetMetaValue("GAME_DATA","TradingBankHideSUI") ~= 1 then
        -- 自定义组件挂接
        local componentData = {
            index = global.SUIComponentTable.TitleO_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    end

    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_TitleTips_Close)
end

return TradingBankLookHeroTitleLayerMediator