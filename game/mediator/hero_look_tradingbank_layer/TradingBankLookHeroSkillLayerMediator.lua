local BaseUIMediator = requireMediator("BaseUIMediator")
local TradingBankLookHeroSkillLayerMediator = class("TradingBankLookHeroSkillLayerMediator", BaseUIMediator)
TradingBankLookHeroSkillLayerMediator.NAME = "TradingBankLookHeroSkillLayerMediator"

function TradingBankLookHeroSkillLayerMediator:ctor()
    TradingBankLookHeroSkillLayerMediator.super.ctor(self)
    self._layer = nil
end

function TradingBankLookHeroSkillLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBank_Look_Player_Skill_Open_Hero,
        noticeTable.Layer_TradingBank_Look_Player_Child_Del_Hero,
    }
end

function TradingBankLookHeroSkillLayerMediator:handleNotification(notification)
    local notices    = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_TradingBank_Look_Player_Skill_Open_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_TradingBank_Look_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL == noticeData then
            self:CloseLayer()
        end
    end
end

function TradingBankLookHeroSkillLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        self._layer = requireLayerUI("hero_tradingbank_layer/HeroSkillLayer").create(noticeData)
        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL
        data.init = noticeData and noticeData.init
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_TRAD_HERO_LOOK_FRAME_PAGE_ADD, data)

        if SL:GetMetaValue("GAME_DATA","TradingBankHideSUI") ~= 1 then
            -- 自定义组件挂接
            local componentData = {
                root = self._layer._root,
                index = global.SUIComponentTable.PlayerSkillO_hero
            }
            global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        end
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function TradingBankLookHeroSkillLayerMediator:CloseLayer()
    if SL:GetMetaValue("GAME_DATA","TradingBankHideSUI") ~= 1 then
        -- 自定义组件挂接
        local componentData = {
            index = global.SUIComponentTable.PlayerSkillO_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    end

    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return TradingBankLookHeroSkillLayerMediator