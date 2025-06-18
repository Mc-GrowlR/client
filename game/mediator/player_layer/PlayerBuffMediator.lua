local BaseUIMediator = requireMediator( "BaseUIMediator" )
local PlayerBuffMediator = class('PlayerBuffMediator', BaseUIMediator )
PlayerBuffMediator.NAME  = "PlayerBuffMediator"

function PlayerBuffMediator:ctor()
    PlayerBuffMediator.super.ctor( self )
end

function PlayerBuffMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Buff_Open,
        noticeTable.Layer_Player_Child_Del,
    }
end

function PlayerBuffMediator:handleNotification(notification)
    local noticeID    = notification:getName()
    local noticeTable = global.NoticeTable
    local data        = notification:getBody()

    if noticeTable.Layer_Player_Buff_Open == noticeID then
        self:OpenLayer(data)

    elseif noticeTable.Layer_Player_Child_Del == noticeID then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BUFF == data then
            self:CloseLayer()
        end
    end
end

function PlayerBuffMediator:OpenLayer(noticeData)
    if not self._layer then
        self._layer = requireLayerUI("player_layer/PlayerBuffLayer").create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BUFF
        data.init = noticeData and noticeData.init

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)

        SL:onLUAEvent(LUA_EVENT_PLAYER_FRAME_PAGE_ADD, data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerBuff
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end    
end

function PlayerBuffMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.PlayerBuff
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

return PlayerBuffMediator