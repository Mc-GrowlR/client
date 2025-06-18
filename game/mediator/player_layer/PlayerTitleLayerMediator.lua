local BaseUIMediator = requireMediator("BaseUIMediator")
local PlayerTitleLayerMediator = class("PlayerTitleLayerMediator", BaseUIMediator)
PlayerTitleLayerMediator.NAME = "PlayerTitleLayerMediator"

function PlayerTitleLayerMediator:ctor()
    PlayerTitleLayerMediator.super.ctor(self)
    self._layer = nil
end

function PlayerTitleLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Title_Attach,
        noticeTable.Layer_Player_Child_Del,
        noticeTable.Layer_Title_Refresh,
    }
end

function PlayerTitleLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Title_Attach then
        self:OpenLayer(noticeData)

    elseif noticeName == notices.Layer_Player_Child_Del then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE == noticeData then
            self:CloseLayer()
        end

    elseif noticeName == notices.Layer_Title_Refresh then
        self:Refresh()
    end
end

function PlayerTitleLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local isWinPlayMode = SL:GetMetaValue("WINPLAYMODE")
        local path = "player_layer/PlayerTitleLayer"
        if isWinPlayMode then 
            path = "player_layer/PlayerTitleLayer_win32"
        end
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE
        data.init = noticeData and noticeData.init
        
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.PLAYER_TITLE, self._layer)
        
        SL:onLUAEvent(LUA_EVENT_PLAYER_FRAME_PAGE_ADD,data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.Title
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        -- 自定义组件挂接

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function PlayerTitleLayerMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = {
        index = global.SUIComponentTable.Title
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    -- 自定义组件挂接

    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_TitleTips_Close)
end

function PlayerTitleLayerMediator:Refresh()
    if self._layer then
        self._layer:refresh()
    end
end

return PlayerTitleLayerMediator