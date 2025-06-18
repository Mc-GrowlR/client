
local BaseUIMediator        = requireMediator("BaseUIMediator")
local HeroFrameMediator = class('HeroFrameMediator', BaseUIMediator)
HeroFrameMediator.NAME = "HeroFrameMediator"

function HeroFrameMediator:ctor()
    HeroFrameMediator.super.ctor(self)
end

function HeroFrameMediator:InitMultiPanel()
    self.GROUP_ID = 101
    self.super.InitMultiPanel(self)
end

function HeroFrameMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Player_Open_Hero,
        noticeTable.Layer_Player_Close_Hero,
        noticeTable.Layer_Hero_Logout,
    }
end

function HeroFrameMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Player_Open_Hero then
        if IsForbidOpenBagOrEquip() then
            return
        end
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Player_Close_Hero or noticeName == notices.Layer_Hero_Logout then
        self:CloseLayer()
    end
end

function HeroFrameMediator:OpenLayer(noticeData)

    if not (self._layer) then
        local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)--没英雄
        if not PlayerPropertyProxy:getIsMakeHero() then
            ShowSystemTips(GET_STRING(600000208))
            return
        end
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)--没召唤
        if not HeroPropertyProxy:HeroIsLogin() then
            ShowSystemTips(GET_STRING(600000209))
            return
        end
        
        local path = "hero_layer/HeroFrameLayer"

        if global.isWinPlayMode then
            path = "hero_layer/HeroFrameLayer_win32"
        end
        self._layer = requireLayerUI(path).create()
        self._type = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.PlayerHeroMainGUI

        HeroFrameMediator.super.OpenLayer(self)

        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.HERO_FRAME, self._layer)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.PlayerMain_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        global.Facade:sendNotification(global.NoticeTable.Layer_HeroFrame_Load_Success)
    else
        local extent = noticeData and noticeData.extent or 1
        local type = noticeData and noticeData.type or 1
        local openedLayer = self._layer:GetOpenedLayer()
        local openedType = self._layer:GetOpenedType()      -- 内功/基础
        if openedType == type then
            if extent == openedLayer then
                self:CloseLayer()
            else
                self._layer:ChangeOpenedPage(extent)
            end
        else                            -- 基础/内功切换
            self._layer:ChangeType(type)
            self._layer:ChangeOpenedPage(extent)
        end
    end

end

function HeroFrameMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.PlayerMain_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        self._layer:OnCloseMainLayer()
    end
    HeroFrameMediator.super.CloseLayer(self)
end

return HeroFrameMediator