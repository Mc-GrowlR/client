local BaseUIMediator = requireMediator("BaseUIMediator")
local PlayerExtraAttLayerMediator = class("PlayerExtraAttLayerMediator", BaseUIMediator)
PlayerExtraAttLayerMediator.NAME = "PlayerExtraAttLayerMediator"

function PlayerExtraAttLayerMediator:ctor()
    PlayerExtraAttLayerMediator.super.ctor(self)
    self._layer = nil
end

function PlayerExtraAttLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Extra_Att_Open,
        noticeTable.Layer_Player_Child_Del,
        noticeTable.PlayerExpChange,
        noticeTable.PlayerPropertyChange,
        noticeTable.PlayerWeightChange,
        noticeTable.PlayerManaChange,
    }
end

function PlayerExtraAttLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Extra_Att_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Player_Child_Del then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO == noticeData then
            self:CloseLayer()
        end
    elseif noticeName == notices.PlayerPropertyChange
    or noticeName == notices.PlayerWeightChange then
        self:UpdateBaseAttriLayer()
    elseif noticeName == notices.PlayerManaChange then
        self:OnRefreshHPMP()
    end
end

function PlayerExtraAttLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "player_layer/PlayerExtraAttLayer"
        if global.isWinPlayMode then
            path = "player_layer/PlayerExtraAttLayer_win32"
        end
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO
        data.init = noticeData and noticeData.init

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.PLAYER_EXTRAATTR, self._layer)

        SL:onLUAEvent(LUA_EVENT_PLAYER_FRAME_PAGE_ADD, data)
        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerAttr
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function PlayerExtraAttLayerMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.PlayerAttr
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:OnClose()
        self._layer:removeFromParent()
        self._layer = nil
    end
end

function PlayerExtraAttLayerMediator:UpdateBaseAttriLayer()
    if self._layer then
        self._layer:OnRefreshAttri()
    end
end

-- 刷新HP MP
function PlayerExtraAttLayerMediator:OnRefreshHPMP()
    if self._layer then
        self._layer:OnRefreshHPMP()
    end
end

return PlayerExtraAttLayerMediator