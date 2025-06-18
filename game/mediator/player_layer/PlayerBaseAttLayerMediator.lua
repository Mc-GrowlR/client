local BaseUIMediator = requireMediator("BaseUIMediator")
local PlayerBaseAttLayerMediator = class("PlayerBaseAttLayerMediator", BaseUIMediator)
PlayerBaseAttLayerMediator.NAME = "PlayerBaseAttLayerMediator"

function PlayerBaseAttLayerMediator:ctor()
    PlayerBaseAttLayerMediator.super.ctor(self)
    self._layer = nil
end

function PlayerBaseAttLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Base_Att_Open,
        noticeTable.Layer_Player_Child_Del,
        noticeTable.PlayerManaChange,
        noticeTable.PlayerPropertyChange,
        noticeTable.PlayerExpChange
    }
end

function PlayerBaseAttLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Base_Att_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Player_Child_Del then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI == noticeData then
            self:CloseLayer()
        end
    elseif noticeName == notices.PlayerManaChange or 
    noticeName == notices.PlayerExpChange or
    noticeName == notices.PlayerPropertyChange then
        self:UpdateBaseAttriLayer()
    end
end

function PlayerBaseAttLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "player_layer/PlayerBaseAttLayer"
        if global.isWinPlayMode then
            path = "player_layer/PlayerBaseAttLayer_win32"
        end
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI
        data.init = noticeData and noticeData.init

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.PLAYER_BASEATTR, self._layer)

        SL:onLUAEvent(LUA_EVENT_PLAYER_FRAME_PAGE_ADD, data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerState
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end

end

function PlayerBaseAttLayerMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.PlayerState
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    
    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

function PlayerBaseAttLayerMediator:UpdateBaseAttriLayer()
    if self._layer then
        self._layer:UpdateBaseAttriLayer()
    end
end

return PlayerBaseAttLayerMediator
