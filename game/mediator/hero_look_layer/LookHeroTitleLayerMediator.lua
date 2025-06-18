local BaseUIMediator = requireMediator("BaseUIMediator")
local LookHeroTitleLayerMediator = class("LookHeroTitleLayerMediator", BaseUIMediator)
LookHeroTitleLayerMediator.NAME  = "LookHeroTitleLayerMediator"

function LookHeroTitleLayerMediator:ctor()
    LookHeroTitleLayerMediator.super.ctor( self )
    self._layer = nil
end

function LookHeroTitleLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Look_Title_Attach_Hero,
        noticeTable.Layer_Look_Player_Child_Del_Hero,
    }
end

function LookHeroTitleLayerMediator:handleNotification(notification)
    local notices  = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()
    
    if noticeName == notices.Layer_Look_Title_Attach_Hero then
        self:OpenLayer(noticeData)

    elseif noticeName == notices.Layer_Look_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE == noticeData then
            self:CloseLayer()
        end
    
    end
end

function LookHeroTitleLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "hero_look_layer/HeroTitleLayer"
        if global.isWinPlayMode then
            path = "hero_look_layer/HeroTitleLayer_win32"
        end
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE
        data.init = noticeData and noticeData.init
        
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)
        
        LoadLayerCUIConfig(global.CUIKeyTable.HERO_TITLE, self._layer)

        SL:onLUAEvent(LUA_EVENT_HERO_LOOK_FRAME_PAGE_ADD,data)

        -- 自定义组件挂接
        local componentData = {
            root  = self._layer._root,
            index = global.SUIComponentTable.TitleO_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        -- 自定义组件挂接

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function LookHeroTitleLayerMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = {
        index = global.SUIComponentTable.TitleO_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    -- 自定义组件挂接

    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_Look_TitleTips_Close)
end

return LookHeroTitleLayerMediator
