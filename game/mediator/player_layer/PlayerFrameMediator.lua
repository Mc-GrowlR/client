local BaseUIMediator        = requireMediator("BaseUIMediator")
local PlayerFrameMediator = class('PlayerFrameMediator', BaseUIMediator)
PlayerFrameMediator.NAME = "PlayerFrameMediator"

function PlayerFrameMediator:ctor()
    PlayerFrameMediator.super.ctor(self)
end

function PlayerFrameMediator:InitMultiPanel()
    self.super.InitMultiPanel(self)
end

function PlayerFrameMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Open,
        noticeTable.Layer_Player_Close,
    }
end

function PlayerFrameMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Open then
        if IsForbidOpenBagOrEquip() then
            return
        end
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Player_Close then
        self:CloseLayer()
    end
end

function PlayerFrameMediator:OpenLayer(noticeData)
    if not (self._layer) then
        local path = "player_layer/PlayerFrameLayer"
        if global.isWinPlayMode then
            path = "player_layer/PlayerFrameLayer_win32"
        end
        self._layer = requireLayerUI(path).create()

        if not self._layer then 
            return 
        end
        self._GUI_ID = SLDefine.LAYERID.PlayerMainGUI
        self._type = global.UIZ.UI_NORMAL
        PlayerFrameMediator.super.OpenLayer(self)
        
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.PLAYER_FRAME, self._layer)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer:GetSUIParent(),
            index = global.SUIComponentTable.PlayerMain
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

        global.Facade:sendNotification(global.NoticeTable.Layer_PlayerFrame_Load_Success)
    else
        local extent = noticeData and noticeData.extent or 1
        local type = noticeData and noticeData.type or 1
        local openedLayer = self._layer:GetOpenedLayer()
        local openedType = self._layer:GetOpenedType()      -- 内功/基础
        if openedType == type then
            if extent == openedLayer then
                global.Facade:sendNotification(global.NoticeTable.Layer_Player_Close)
            else
                self._layer:ChangeOpenedPage(extent)
            end
        else                                -- 基础/内功切换
            self._layer:ChangeType(type)
            self._layer:ChangeOpenedPage(extent)
        end
    end
end

function PlayerFrameMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.PlayerMain
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:OnCloseMainLayer()
    end
    PlayerFrameMediator.super.CloseLayer(self)
end



return PlayerFrameMediator