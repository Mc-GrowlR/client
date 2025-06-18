local BaseUIMediator = requireMediator( "BaseUIMediator" )
local LookPlayerBuffMediator = class('LookPlayerBuffMediator', BaseUIMediator )
LookPlayerBuffMediator.NAME  = "LookPlayerBuffMediator"

function LookPlayerBuffMediator:ctor()
    LookPlayerBuffMediator.super.ctor( self )
end

function LookPlayerBuffMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Look_Player_Buff_Open,
        noticeTable.Layer_Look_Player_Child_Del,
    }
end

function LookPlayerBuffMediator:handleNotification(notification)
    local noticeID    = notification:getName()
    local noticeTable = global.NoticeTable
    local data        = notification:getBody()

    if noticeTable.Layer_Look_Player_Buff_Open == noticeID then
        self:OpenLayer(data)

    elseif noticeTable.Layer_Look_Player_Child_Del == noticeID then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BUFF == data then
            self:CloseLayer()
        end
    end
end

function LookPlayerBuffMediator:OpenLayer(noticeData)
    if not self._layer then
        self._layer = requireLayerUI("player_look_layer/PlayerBuffLayer").create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BUFF
        data.init = data and data.init

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)

        SL:onLUAEvent(LUA_EVENT_PLAYER_LOOK_FRAME_PAGE_ADD, data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerBuffO
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end    
end

function LookPlayerBuffMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.PlayerBuffO
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

return LookPlayerBuffMediator