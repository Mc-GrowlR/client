local BaseUIMediator = requireMediator("BaseUIMediator")
local HeroBaseAttLayerMediator = class("HeroBaseAttLayerMediator", BaseUIMediator)
HeroBaseAttLayerMediator.NAME = "HeroBaseAttLayerMediator"

function HeroBaseAttLayerMediator:ctor()
    HeroBaseAttLayerMediator.super.ctor(self)
    self._layer = nil
end

function HeroBaseAttLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Base_Att_Open_Hero,
        noticeTable.Layer_Player_Child_Del_Hero,
        noticeTable.PlayerManaChange_Hero,
        noticeTable.PlayerPropertyChange_Hero,
        noticeTable.PlayerExpChange_Hero
    }
end

function HeroBaseAttLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Base_Att_Open_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI == noticeData then
            self:CloseLayer()
        end
    elseif noticeName == notices.PlayerManaChange_Hero
    or noticeName == notices.PlayerPropertyChange_Hero
    or noticeName == notices.PlayerExpChange_Hero then
        self:UpdateBaseAttriLayer()
    end
end

function HeroBaseAttLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "hero_layer/HeroBaseAttLayer"
        if global.isWinPlayMode then
            path = "hero_layer/HeroBaseAttLayer_win32"
        end
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_BASE_ATTRI
        data.init = noticeData and noticeData.init

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.HERO_BASEATTR, self._layer)
        
        SL:onLUAEvent(LUA_EVENT_HERO_FRAME_PAGE_ADD,data)

        -- -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerState_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        -- 自定义组件挂接

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function HeroBaseAttLayerMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = {
        index = global.SUIComponentTable.PlayerState_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    -- 自定义组件挂接
    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

function HeroBaseAttLayerMediator:UpdateBaseAttriLayer()
    if self._layer then
        self._layer:UpdateBaseAttriLayer()
    end
end

return HeroBaseAttLayerMediator