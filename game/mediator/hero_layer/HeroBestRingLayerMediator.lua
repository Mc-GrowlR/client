local BaseUIMediator        = requireMediator("BaseUIMediator")
local HeroBestRingLayerMediator = class('HeroBestRingLayerMediator', BaseUIMediator)
HeroBestRingLayerMediator.NAME = "HeroBestRingLayerMediator"


function HeroBestRingLayerMediator:ctor()
    HeroBestRingLayerMediator.super.ctor(self)
end

function HeroBestRingLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_PlayerBestRing_Open_Hero,
        noticeTable.Layer_PlayerBestRing_Close_Hero,
        noticeTable.PlayEquip_Oper_Data_Hero,
        noticeTable.Layer_Player_Equip_State_Change_Hero,
        noticeTable.Layer_Player_Child_Del_Hero
    }
end

function HeroBestRingLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_PlayerBestRing_Open_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_PlayerBestRing_Close_Hero then
        self:CloseLayer()
    elseif noticeName == notices.PlayEquip_Oper_Data_Hero then
        if self._layer then
            self._layer:RefreshEquipList()
        end
    elseif noticeName == notices.Layer_Player_Equip_State_Change_Hero then
        self:ResetEquipState(noticeData)
    elseif noticeName == notices.Layer_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP == noticeData then
            self:CloseLayer()
        end
    end
end

function HeroBestRingLayerMediator:OpenLayer(noticeData)
    if not (self._layer) then
        local path = "hero_layer/HeroBestRingLayer"
        if global.isWinPlayMode then
            path = "hero_layer/HeroBestRingLayer_win32"
        end
        self._layer = requireLayerUI(path).create(noticeData)
        self._type = global.UIZ.UI_NORMAL

        self._GUI_ID = SLDefine.LAYERID.PlayerHeroBestRingGUI

        HeroBestRingLayerMediator.super.OpenLayer(self)

        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.HERO_BEST_RING, self._layer)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerBestRing_hero
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

function HeroBestRingLayerMediator:CloseLayer()
    -- 自定义组件卸下
    local componentData =     {
        index = global.SUIComponentTable.PlayerBestRing_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    HeroBestRingLayerMediator.super.CloseLayer(self)
end


function HeroBestRingLayerMediator:ResetEquipState(noticeData)
    if self._layer then
        self._layer:ResetEquipState(noticeData)
    end
end

return HeroBestRingLayerMediator