local BaseUIMediator = requireMediator("BaseUIMediator")
local TradingBankLookHeroBaseAttLayerMediator = class("TradingBankLookHeroBaseAttLayerMediator", BaseUIMediator)
TradingBankLookHeroBaseAttLayerMediator.NAME = "TradingBankLookHeroBaseAttLayerMediator"

function TradingBankLookHeroBaseAttLayerMediator:ctor()
    TradingBankLookHeroBaseAttLayerMediator.super.ctor(self)
    self._layer = nil
end

function TradingBankLookHeroBaseAttLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBank_Look_Player_Base_Att_Open_Hero,
        noticeTable.Layer_TradingBank_Look_Player_Child_Del_Hero,
    }
end

function TradingBankLookHeroBaseAttLayerMediator:handleNotification(notification)
    local notices    = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_TradingBank_Look_Player_Base_Att_Open_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_TradingBank_Look_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI == noticeData then
            self:CloseLayer()
        end
    end
end

function TradingBankLookHeroBaseAttLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "hero_tradingbank_layer/HeroBaseAttLayer"
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI
        data.init = noticeData and noticeData.init
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_TRAD_HERO_LOOK_FRAME_PAGE_ADD, data)
        if SL:GetMetaValue("GAME_DATA","TradingBankHideSUI") ~= 1 then
            -- 自定义组件挂接
            local componentData = {
                root = self._layer._root,
                index = global.SUIComponentTable.PlayerState
            }
            global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        end
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function TradingBankLookHeroBaseAttLayerMediator:CloseLayer()
    if SL:GetMetaValue("GAME_DATA","TradingBankHideSUI") ~= 1 then
        -- 自定义组件挂接
        local componentData = {
            index = global.SUIComponentTable.PlayerState
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    end 
    
    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return TradingBankLookHeroBaseAttLayerMediator