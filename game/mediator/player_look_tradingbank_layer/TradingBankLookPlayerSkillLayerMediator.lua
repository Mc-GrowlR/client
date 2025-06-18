local BaseUIMediator = requireMediator("BaseUIMediator")
local TradingBankLookPlayerSkillLayerMediator = class("TradingBankLookPlayerSkillLayerMediator", BaseUIMediator)
TradingBankLookPlayerSkillLayerMediator.NAME = "TradingBankLookPlayerSkillLayerMediator"

function TradingBankLookPlayerSkillLayerMediator:ctor()
    TradingBankLookPlayerSkillLayerMediator.super.ctor(self)
    self._layer = nil
end

function TradingBankLookPlayerSkillLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TradingBank_Look_Player_Skill_Open,
        noticeTable.Layer_TradingBank_Look_Player_Child_Del,
    }
end

function TradingBankLookPlayerSkillLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_TradingBank_Look_Player_Skill_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_TradingBank_Look_Player_Child_Del then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL == noticeData then
            self:CloseLayer()
        end
    end
end

function TradingBankLookPlayerSkillLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        self._layer = requireLayerUI("player_tradingbank_layer/PlayerSkillLayer").create(noticeData)
        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SKILL
        data.init = noticeData and noticeData.init
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_TRAD_PLAYER_LOOK_FRAME_PAGE_ADD, data)

        if SL:GetMetaValue("GAME_DATA","TradingBankHideSUI") ~= 1 then
            -- 自定义组件挂接
            local componentData = {
                root = self._layer._root,
                index = global.SUIComponentTable.PlayerSkillO
            }
            global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        end
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function TradingBankLookPlayerSkillLayerMediator:CloseLayer()
    if SL:GetMetaValue("GAME_DATA","TradingBankHideSUI") ~= 1 then
        -- 自定义组件挂接
        local componentData = {
            index = global.SUIComponentTable.PlayerSkillO
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    end

    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return TradingBankLookPlayerSkillLayerMediator