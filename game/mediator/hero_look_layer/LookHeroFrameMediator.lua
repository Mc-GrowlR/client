local BaseUIMediator        = requireMediator( "BaseUIMediator" )
local LookHeroFrameMediator = class('LookHeroFrameMediator', BaseUIMediator )
LookHeroFrameMediator.NAME  = "LookHeroFrameMediator"


function LookHeroFrameMediator:ctor()
    LookHeroFrameMediator.super.ctor( self )
    self._frist_open = true --第一次打开 更改一次界面位置
end

function LookHeroFrameMediator:InitMultiPanel()
    self.super.InitMultiPanel(self)
end

function LookHeroFrameMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
            noticeTable.Layer_Look_Player_Open_Hero,
            noticeTable.Layer_Look_Player_Close_Hero,
        }
end

function LookHeroFrameMediator:handleNotification(notification)
    local notices  = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Look_Player_Open_Hero then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Look_Player_Close_Hero then
        self:CloseLayer()
    end
end

function LookHeroFrameMediator:OpenLayer(noticeData)
    if not (self._layer) then
        local path = "hero_look_layer/HeroFrameLayer"
        if global.isWinPlayMode then
            path = "hero_look_layer/HeroFrameLayer_win32"
        end
        self._layer = requireLayerUI( path ).create()

        if not self._layer then 
            return 
        end
        
        self._type = global.UIZ.UI_NORMAL

        self._GUI_ID = SLDefine.LAYERID.LookHeroMainGUI

        LookHeroFrameMediator.super.OpenLayer(self)

        self._layer:InitGUI(noticeData)

        if self._frist_open then
            self._frist_open = false
            local posx,posy = self._layer:getPosition()
            print(posx,posy)
            self._layer:setPosition(posx - 418, posy)
            self:setSavedPosition(posx - 418, posy)
        end

        LoadLayerCUIConfig(global.CUIKeyTable.HERO_FRAME, self._layer)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer:GetSUIParent(),
            index = global.SUIComponentTable.PlayerMain_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        -- 自定义组件挂接

        if noticeData and noticeData.extent and noticeData.extent ~= SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP then
            self._layer:ChangeOpenedPage(noticeData.extent)
        end
    else
        local extent = noticeData and noticeData.extent or 1
        local openedLayer = self._layer:GetOpenedLayer()
        local openedLook =  self._layer:GetOpenedLookState()
        if (noticeData and openedLook ~= noticeData.lookPlayer) or extent == openedLayer then
            self:CloseLayer()
        else
            self._layer:ChangeOpenedPage(extent)
        end
    end

end

function LookHeroFrameMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = {
        index = global.SUIComponentTable.PlayerMain_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    -- 自定义组件挂接

    if self._layer then
        self._layer:OnCloseMainLayer()
    end

    LookHeroFrameMediator.super.CloseLayer( self )
end

return LookHeroFrameMediator