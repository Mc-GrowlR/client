local BaseUIMediator = requireMediator("BaseUIMediator")
local PlayerInternalStateLayerMediator = class("PlayerInternalStateLayerMediator", BaseUIMediator)
PlayerInternalStateLayerMediator.NAME = "PlayerInternalStateLayerMediator"

function PlayerInternalStateLayerMediator:ctor()
    PlayerInternalStateLayerMediator.super.ctor(self)
    self._layer = nil
end

function PlayerInternalStateLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Internal_State_Open,
        noticeTable.Layer_Player_Internal_Child_Del,
    }
end

function PlayerInternalStateLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Internal_State_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Player_Internal_Child_Del then
        if SLDefine.InternalPage.State == noticeData then
            self:CloseLayer()
        end
    end
end

function PlayerInternalStateLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "internal_layer/PlayerInternalStateLayer"
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.InternalPage.State
        data.init = noticeData and noticeData.init
        data.isInternal = true

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_PLAYER_FRAME_PAGE_ADD, data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerInternalState
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end

end

function PlayerInternalStateLayerMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.PlayerInternalState
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    
    if self._layer then
        if PlayerInternalState.OnClose then
            PlayerInternalState.OnClose()
        end
        self._layer:removeFromParent()
        self._layer = nil
    end
end


return PlayerInternalStateLayerMediator