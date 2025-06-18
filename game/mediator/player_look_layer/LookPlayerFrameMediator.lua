local BaseUIMediator        = requireMediator("BaseUIMediator")
local LookPlayerFrameMediator = class('LookPlayerFrameMediator', BaseUIMediator)
LookPlayerFrameMediator.NAME = "LookPlayerFrameMediator"


function LookPlayerFrameMediator:ctor()
    LookPlayerFrameMediator.super.ctor(self)
    self._frist_open = true --第一次打开 更改一次界面位置
end

function LookPlayerFrameMediator:InitMultiPanel()
    self.super.InitMultiPanel(self)
end

function LookPlayerFrameMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Look_Player_Open,
        noticeTable.Layer_Look_Player_Close,
    }
end

function LookPlayerFrameMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Look_Player_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Look_Player_Close then
        self:CloseLayer()
    end
end

function LookPlayerFrameMediator:OpenLayer(noticeData)
    if not (self._layer) then
        local path = "player_look_layer/PlayerFrameLayer"
        if global.isWinPlayMode then
            path = "player_look_layer/PlayerFrameLayer_win32"
        end
        self._layer = requireLayerUI(path).create()

        if not self._layer then 
            return 
        end
        
        self._type = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.LookPlayerMainGUI
        
        if self._frist_open then
            self._frist_open = false
            local posx, posy = self._layer:getPosition()
            print(posx, posy)
            self._layer:setPosition(posx - 418, posy)
            self:setSavedPosition(posx - 418, posy)
        end

        LookPlayerFrameMediator.super.OpenLayer(self)
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.PLAYER_FRAME, self._layer)
        LoadLayerCUIConfig(global.CUIKeyTable.LOOKPLAYER_FRAME, self._layer)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer:GetSUIParent(),
            index = global.SUIComponentTable.PlayerMainO
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

        if noticeData and noticeData.extent and noticeData.extent ~= SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP then
            self._layer:ChangeOpenedPage(noticeData.extent)
        end
    else
        local extent = noticeData and noticeData.extent or 1
        local openedLayer = self._layer:GetOpenedLayer()
        local openedLook = self._layer:GetOpenedLookState()
        if (noticeData and openedLook ~= noticeData.lookPlayer) or extent == openedLayer then
            self:CloseLayer()
        else
            self._layer:ChangeOpenedPage(extent)
        end
    end

end

function LookPlayerFrameMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.PlayerMainO
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:OnCloseMainLayer()
    end

    LookPlayerFrameMediator.super.CloseLayer(self)
end
return LookPlayerFrameMediator
