local BaseUIMediator        = requireMediator("BaseUIMediator")
local HeroStateSelectLayerMediator = class('HeroStateSelectLayerMediator', BaseUIMediator)
HeroStateSelectLayerMediator.NAME = "HeroStateSelectLayerMediator"

function HeroStateSelectLayerMediator:ctor()
    HeroStateSelectLayerMediator.super.ctor(self)
end

function HeroStateSelectLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Hero_StateSelect_Open,
        noticeTable.Layer_Hero_StateSelect_Close,
        noticeTable.PlayerPropertyChange_Hero,
        noticeTable.PlayerExpChange_Hero,
        noticeTable.HeroState_change,
    }
end

function HeroStateSelectLayerMediator:handleNotification(notification)
    local notices    = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()
    if noticeName == notices.Layer_Hero_StateSelect_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Hero_StateSelect_Close then
        self:CloseLayer()
    elseif noticeName == notices.HeroState_change then
        self:refState()
    end
end

function HeroStateSelectLayerMediator:refState(noticeData)
    if not self._layer then
        return
    end
    self._layer:refState()
end

function HeroStateSelectLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        if not HeroPropertyProxy:HeroIsLogin() then
            return
        end
        local set = HeroPropertyProxy:getStatesSysSet()
        local path
        if #set == 4 then
            path = "hero_layer/HeroStateSelectLayer"
        else
            path = "hero_layer/HeroStateThreeSelectLayer"
        end
        self._layer = requireLayerUI(path).create(noticeData)
        self._GUI_ID = SLDefine.LAYERID.HeroStateSelectGUI
        self._type = global.UIZ.UI_NORMAL
        HeroStateSelectLayerMediator.super.OpenLayer(self)
        
        self._layer:InitGUI(noticeData)
        if noticeData.pos then
            self._layer._root.Panel_3:setPosition(noticeData.pos)
        end
    end
end

function HeroStateSelectLayerMediator:CloseLayer()
    if not self._layer then
        return
    end
    HeroStateSelectLayerMediator.super.CloseLayer(self)
end

return HeroStateSelectLayerMediator