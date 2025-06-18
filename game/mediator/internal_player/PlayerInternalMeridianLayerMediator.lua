local BaseUIMediator = requireMediator("BaseUIMediator")
local PlayerInternalMeridianLayerMediator = class("PlayerInternalMeridianLayerMediator", BaseUIMediator)
PlayerInternalMeridianLayerMediator.NAME = "PlayerInternalMeridianLayerMediator"

function PlayerInternalMeridianLayerMediator:ctor()
    PlayerInternalMeridianLayerMediator.super.ctor(self)
    self._layer = nil
end

function PlayerInternalMeridianLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Internal_Meridian_Open,
        noticeTable.Layer_Player_Internal_Child_Del,
    }
end

function PlayerInternalMeridianLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Internal_Meridian_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Player_Internal_Child_Del then
        if SLDefine.InternalPage.Meridian == noticeData then
            self:CloseLayer()
        end
    end
end

function PlayerInternalMeridianLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "internal_layer/PlayerInternalMeridianLayer"
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.InternalPage.Meridian
        data.init = noticeData and noticeData.init
        data.isInternal = true

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_PLAYER_FRAME_PAGE_ADD, data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerInternalMeridian
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

        for i = 1, 5 do
            local componentData = {
                root = self._layer._ui and self._layer._ui["Panel_show_" .. i],
                index = global.SUIComponentTable["PlayerInternalMeridian" .. i]
            }
            global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        end
        
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end

end

function PlayerInternalMeridianLayerMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.PlayerInternalMeridian
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    for i = 1, 5 do
        local componentData = {
            index = global.SUIComponentTable["PlayerInternalMeridian" .. i]
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    end
    
    if self._layer then
        if PlayerInternalMeridian.OnClose then
            PlayerInternalMeridian.OnClose()
        end
        self._layer:removeFromParent()
        self._layer = nil
    end
end


return PlayerInternalMeridianLayerMediator