local BaseUIMediator        = requireMediator("BaseUIMediator")
local LookHeroBestRingLayerMediator = class('LookHeroBestRingLayerMediator', BaseUIMediator)
LookHeroBestRingLayerMediator.NAME = "LookHeroBestRingLayerMediator"


function LookHeroBestRingLayerMediator:ctor()
    LookHeroBestRingLayerMediator.super.ctor(self)
end

function LookHeroBestRingLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Look_PlayerBestRing_Open_Hero,
        noticeTable.Layer_Look_PlayerBestRing_Close_Hero,
        noticeTable.Layer_Look_Player_Child_Del_Hero,
    }
end

function LookHeroBestRingLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Look_PlayerBestRing_Open_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Look_PlayerBestRing_Close_Hero then
        self:CloseLayer()
    elseif noticeName == notices.Layer_Look_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP == noticeData then
            self:CloseLayer()
        end
    end
end

function LookHeroBestRingLayerMediator:OpenLayer(noticeData)
    if not (self._layer) then
        local path = "hero_look_layer/HeroBestRingLayer"
        if global.isWinPlayMode then
            path = "hero_look_layer/HeroBestRingLayer_win32"
        end
        self._layer = requireLayerUI(path).create(noticeData)
        self._type = global.UIZ.UI_NORMAL

        self._GUI_ID = SLDefine.LAYERID.LookHeroBestRingGUI

        LookHeroBestRingLayerMediator.super.OpenLayer(self)
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.HERO_BEST_RING, self._layer)
        self._layer:InitHideIconPos()

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerBestRingO_hero
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

function LookHeroBestRingLayerMediator:CloseLayer()
    -- 自定义组件卸下
    local componentData =     {
        index = global.SUIComponentTable.PlayerBestRingO_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    LookHeroBestRingLayerMediator.super.CloseLayer(self)
end

return LookHeroBestRingLayerMediator