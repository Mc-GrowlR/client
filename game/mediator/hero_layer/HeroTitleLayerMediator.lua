local BaseUIMediator = requireMediator("BaseUIMediator")
local HeroTitleLayerMediator = class("HeroTitleLayerMediator", BaseUIMediator)
HeroTitleLayerMediator.NAME = "HeroTitleLayerMediator"

function HeroTitleLayerMediator:ctor()
    HeroTitleLayerMediator.super.ctor(self)
    self._layer = nil
end

function HeroTitleLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Title_Attach_Hero,
        noticeTable.Layer_Player_Child_Del_Hero,
        noticeTable.Layer_Title_Refresh_Hero,
    }
end

function HeroTitleLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Title_Attach_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Player_Child_Del_Hero then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE == noticeData then
            self:CloseLayer()
        end
    elseif noticeName == notices.Layer_Title_Refresh_Hero then
        self:Refresh()
    end
end

function HeroTitleLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local isWinPlayMode = SL:GetMetaValue("WINPLAYMODE")
        local path = "hero_layer/HeroTitleLayer"
        if isWinPlayMode then 
            path = "hero_layer/HeroTitleLayer_win32"
        end
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE
        data.init = noticeData and noticeData.init
        
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.HERO_TITLE, self._layer)
        
        SL:onLUAEvent(LUA_EVENT_HERO_FRAME_PAGE_ADD,data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.Title_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function HeroTitleLayerMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.Title_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_TitleTips_Close)
end

function HeroTitleLayerMediator:Refresh()
    if self._layer then
        self._layer:refresh()
    end
end

return HeroTitleLayerMediator