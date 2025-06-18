local BaseUIMediator = requireMediator("BaseUIMediator")
local HeroStateLayerMediator = class("HeroStateLayerMediator", BaseUIMediator)
HeroStateLayerMediator.NAME = "HeroStateLayerMediator"

function HeroStateLayerMediator:ctor()
    HeroStateLayerMediator.super.ctor(self)
end

function HeroStateLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.PlayerPropertyChange_Hero,
        noticeTable.PlayerExpChange_Hero,
        noticeTable.HeroState_change,
        noticeTable.PlayerPropertyInited,
        noticeTable.Layer_Hero_Logout,
        noticeTable.Layer_Hero_Login,
        noticeTable.Layer_Hero_Button_Show,
        noticeTable.PlayerLevelChange_Hero,
        noticeTable.SelfHeroDie,
        noticeTable.DRotationChanged,
        noticeTable.PlayerManaChange_Hero,
        noticeTable.SelfHeroRevive
    }
end

function HeroStateLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.PlayerPropertyChange_Hero or noticeName == notices.PlayerExpChange_Hero or notices.PlayerManaChange_Hero == noticeName then
        self:refProperty(noticeData)
    elseif noticeName == notices.PlayerLevelChange_Hero then
        self:refLevel(noticeData)
    elseif noticeName == notices.HeroState_change then
        self:refState(noticeData)
    elseif noticeName == notices.PlayerPropertyInited then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Hero_Login then
        self:HeroLogin(noticeData)
    elseif noticeName == notices.Layer_Hero_Logout then
        self:HeroLogOut(noticeData)
    elseif noticeName == notices.Layer_Hero_Button_Show then
        self:HeroBtnShowOrHide(noticeData)
    elseif notices.SelfHeroDie == noticeName then
        self:onSelfHeroDie()
    elseif notices.DRotationChanged == noticeName then
        self:InitAdapet()
    elseif notices.SelfHeroRevive == noticeName then
        self:onSelfHeroRevive(noticeData)
    end
end

function HeroStateLayerMediator:onSelfHeroDie(noticeData)
    if not self._layer then
        return
    end
    self._layer:Hero_Die(true)
end

function HeroStateLayerMediator:onSelfHeroRevive(noticeData)
    if not self._layer then
        return
    end
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    if not HeroPropertyProxy:HeroIsLogin() then
        return
    end
    self._layer:Hero_Die(false)
    
end
function HeroStateLayerMediator:refLevel(noticeData)
    if not self._layer then
        return
    end
    self._layer:refLevel(noticeData)
end

function HeroStateLayerMediator:HeroBtnShowOrHide(noticeData)
    if not self._layer then
        return
    end
    self._layer:HeroBtnShowOrHide(noticeData)
end

function HeroStateLayerMediator:HeroLogin(noticeData)
    if not self._layer then
        return
    end
    self._layer:HeroLogin(noticeData)
end

function HeroStateLayerMediator:HeroLogOut(noticeData)
    if not self._layer then
        return
    end
    self._layer:HeroLogOut(noticeData)
end

function HeroStateLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        if not HeroPropertyProxy:IsHeroOpen() then
            return
        end

        local path = "hero_layer/HeroStateLayer"
        self._layer = requireLayerUI(path).create()
        self._type = global.UIZ.UI_MAIN
        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_TOP_LB
        
        GUI.ATTACH_PARENT = self._layer 
        self._layer:InitGUI(noticeData)

        LoadLayerCUIConfig(global.CUIKeyTable.HERO_STATE, self._layer)

        self._layer:refOriginalPos()
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)
    end
end

function HeroStateLayerMediator:refProperty(noticeData)
    if not self._layer then
        return
    end
    self._layer:refProperty()
end

function HeroStateLayerMediator:refState(noticeData)
    if not self._layer then
        return
    end
    self._layer:refState()
end

function HeroStateLayerMediator:InitAdapet(noticeData)
    if not self._layer then
        return
    end
    -- self._layer:InitAdapet()
end

function HeroStateLayerMediator:CloseLayer()
    if not self._layer then
        return
    end
    self._layer:removeFromParent()
    self._layer = nil
end

return HeroStateLayerMediator
