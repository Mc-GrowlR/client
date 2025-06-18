local BaseUIMediator        = requireMediator("BaseUIMediator")
local PlayerBestRingLayerMediator = class('PlayerBestRingLayerMediator', BaseUIMediator)
PlayerBestRingLayerMediator.NAME = "PlayerBestRingLayerMediator"

function PlayerBestRingLayerMediator:ctor()
    PlayerBestRingLayerMediator.super.ctor(self)
end

function PlayerBestRingLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_PlayerBestRing_Open,
        noticeTable.Layer_PlayerBestRing_Close,
        noticeTable.PlayEquip_Oper_Data,
        noticeTable.Layer_Player_Equip_State_Change,
        noticeTable.Layer_Player_Child_Del
    }
end

function PlayerBestRingLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_PlayerBestRing_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_PlayerBestRing_Close then
        self:CloseLayer()
    elseif noticeName == notices.PlayEquip_Oper_Data then
        if self._layer then
            self._layer:RefreshEquipList()
        end
    elseif noticeName == notices.Layer_Player_Equip_State_Change then
        self:ResetEquipState(noticeData)
    elseif noticeName == notices.Layer_Player_Child_Del then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP == noticeData then
            self:CloseLayer()
        end
    end
end

function PlayerBestRingLayerMediator:OpenLayer(noticeData)
    if not (self._layer) then
        local path = "player_layer/PlayerBestRingLayer"
        if global.isWinPlayMode then
            path = "player_layer/PlayerBestRingLayer_win32"
        end
        self._layer = requireLayerUI(path).create(noticeData)
        self._type = global.UIZ.UI_NORMAL
        
        self._GUI_ID = SLDefine.LAYERID.PlayerBestRingGUI

        PlayerBestRingLayerMediator.super.OpenLayer(self)

        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.BEST_RING, self._layer)
        
        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerBestRing
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

        if self._layer.RefreshAddTouchSize then
            self._layer:RefreshAddTouchSize()
        end
        self._layer:InitHideIconPos()

    else
        if not noticeData.open then
            self:CloseLayer()
        else
            self._layer:setVisible(true)
        end
    end

end

function PlayerBestRingLayerMediator:CloseLayer()
    -- 自定义组件卸下
    local componentData =     {
        index = global.SUIComponentTable.PlayerBestRing
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    -- 自定义组件卸下

    PlayerBestRingLayerMediator.super.CloseLayer(self)
end


function PlayerBestRingLayerMediator:ResetEquipState(noticeData)
    if self._layer then
        self._layer:ResetEquipState(noticeData)
    end
end

return PlayerBestRingLayerMediator