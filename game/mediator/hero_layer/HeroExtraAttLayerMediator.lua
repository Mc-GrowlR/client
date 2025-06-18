local BaseUIMediator = requireMediator("BaseUIMediator")
local HeroExtraAttLayerMediator = class("HeroExtraAttLayerMediator", BaseUIMediator)
HeroExtraAttLayerMediator.NAME = "HeroExtraAttLayerMediator"

function HeroExtraAttLayerMediator:ctor()
    HeroExtraAttLayerMediator.super.ctor(self)
    self._layer = nil
end

function HeroExtraAttLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Extra_Att_Open_Hero,
        noticeTable.Layer_Player_Child_Del_Hero,
        noticeTable.PlayerPropertyChange_Hero,
        noticeTable.PlayerManaChange_Hero
    }
end

function HeroExtraAttLayerMediator:handleNotification(notification)
    local notices    = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Extra_Att_Open_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO == noticeData then
            self:CloseLayer()
        end
    elseif noticeName == notices.PlayerPropertyChange_Hero then
        self:UpdateBaseAttriLayer()
    elseif noticeName == notices.PlayerManaChange_Hero then
        self:OnRefreshHPMP()
    end
end

function HeroExtraAttLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "hero_layer/HeroExtraAttLayer"
        if global.isWinPlayMode then
            path = "hero_layer/HeroExtraAttLayer_win32"
        end
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EXTRA_ATTRO
        data.init = noticeData and noticeData.init
        
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.HERO_EXTRAATTR, self._layer)
        
        SL:onLUAEvent(LUA_EVENT_HERO_FRAME_PAGE_ADD,data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerAttr_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        -- 自定义组件挂接
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function HeroExtraAttLayerMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = {
        index = global.SUIComponentTable.PlayerAttr_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    -- 自定义组件挂接

    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

function HeroExtraAttLayerMediator:UpdateBaseAttriLayer()
    if self._layer then
        self._layer:OnRefreshAttri()
    end
end

-- 刷新HP MP
function HeroExtraAttLayerMediator:OnRefreshHPMP()
    if self._layer then
        self._layer:OnRefreshHPMP()
    end
end

return HeroExtraAttLayerMediator