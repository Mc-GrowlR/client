local BaseUIMediator = requireMediator( "BaseUIMediator" )
local HeroBuffMediator = class('HeroBuffMediator', BaseUIMediator )
HeroBuffMediator.NAME  = "HeroBuffMediator"

function HeroBuffMediator:ctor()
    HeroBuffMediator.super.ctor( self )
end

function HeroBuffMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Buff_Open_Hero,
        noticeTable.Layer_Player_Child_Del_Hero,
    }
end

function HeroBuffMediator:handleNotification(notification)
    local noticeID    = notification:getName()
    local noticeTable = global.NoticeTable
    local data        = notification:getBody()

    if noticeTable.Layer_Player_Buff_Open_Hero == noticeID then
        self:OpenLayer(data)

    elseif noticeTable.Layer_Player_Child_Del_Hero == noticeID then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BUFF == data then
            self:CloseLayer()
        end
    end
end

function HeroBuffMediator:OpenLayer(noticeData)
    if not self._layer then
        self._layer = requireLayerUI("hero_layer/HeroBuffLayer").create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BUFF
        data.init = noticeData and noticeData.init

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)

        SL:onLUAEvent(LUA_EVENT_HERO_FRAME_PAGE_ADD, data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerBuff_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end    
end

function HeroBuffMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.PlayerBuff_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:OnClose()
    end
    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return HeroBuffMediator