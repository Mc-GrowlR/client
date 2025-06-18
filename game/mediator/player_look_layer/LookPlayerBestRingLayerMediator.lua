local BaseUIMediator        = requireMediator("BaseUIMediator")
local LookPlayerBestRingLayerMediator = class('LookPlayerBestRingLayerMediator', BaseUIMediator)
LookPlayerBestRingLayerMediator.NAME = "LookPlayerBestRingLayerMediator"


function LookPlayerBestRingLayerMediator:ctor()
    LookPlayerBestRingLayerMediator.super.ctor(self)
end

function LookPlayerBestRingLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Look_PlayerBestRing_Open,
        noticeTable.Layer_Look_PlayerBestRing_Close,
        noticeTable.Layer_Look_Player_Child_Del,
    }
end

function LookPlayerBestRingLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Look_PlayerBestRing_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Look_PlayerBestRing_Close then
        self:CloseLayer()
    elseif noticeName == notices.Layer_Look_Player_Child_Del then
        if global.MMO.MAIN_PLAYER_LAYER_EQUIP == noticeData then
            self:CloseLayer()
        end
    end
end

function LookPlayerBestRingLayerMediator:OpenLayer(noticeData)
    if not (self._layer) then
        local path = "player_look_layer/PlayerBestRingLayer"
        if global.isWinPlayMode then
            path = "player_look_layer/PlayerBestRingLayer_win32"
        end
        self._layer = requireLayerUI(path).create(noticeData)
        self._type = global.UIZ.UI_NORMAL

        self._GUI_ID = SLDefine.LAYERID.LookPlayerBestRingGUI
        LookPlayerBestRingLayerMediator.super.OpenLayer(self)

        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.BEST_RING, self._layer)
        self._layer:InitHideIconPos()

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerBestRingO
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

    else
        if not noticeData.open then
            self:CloseLayer()
        else
            self._layer:setVisible(true)
        end
    end

end

function LookPlayerBestRingLayerMediator:CloseLayer()
    -- 自定义组件卸下
    local componentData =     {
        index = global.SUIComponentTable.PlayerBestRingO
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    -- 自定义组件卸下

    LookPlayerBestRingLayerMediator.super.CloseLayer(self)
end

return LookPlayerBestRingLayerMediator