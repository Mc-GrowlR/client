local BaseUIMediator = requireMediator("BaseUIMediator")
local LookPlayerTitleLayerMediator = class("LookPlayerTitleLayerMediator", BaseUIMediator)
LookPlayerTitleLayerMediator.NAME  = "LookPlayerTitleLayerMediator"

function LookPlayerTitleLayerMediator:ctor()
    LookPlayerTitleLayerMediator.super.ctor( self )
    self._layer = nil
end

function LookPlayerTitleLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Look_Title_Attach,
        noticeTable.Layer_Look_Player_Child_Del,
    }
end

function LookPlayerTitleLayerMediator:handleNotification(notification)
    local notices  = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()
    
    if noticeName == notices.Layer_Look_Title_Attach then
        self:OpenLayer(noticeData)

    elseif noticeName == notices.Layer_Look_Player_Child_Del then
        if SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE == noticeData then
            self:CloseLayer()
        end
    
    end
end

function LookPlayerTitleLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "player_look_layer/PlayerTitleLayer"
        if global.isWinPlayMode then
            path = "player_look_layer/PlayerTitleLayer_win32"
        end
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE
        data.init = noticeData and noticeData.init

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.PLAYER_TITLE, self._layer)

        SL:onLUAEvent(LUA_EVENT_PLAYER_LOOK_FRAME_PAGE_ADD, data)
        -- 自定义组件挂接
        local componentData = {
            root  = self._layer._root,
            index = global.SUIComponentTable.TitleO
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end
end

function LookPlayerTitleLayerMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.TitleO
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_Look_TitleTips_Close)
end

return LookPlayerTitleLayerMediator
