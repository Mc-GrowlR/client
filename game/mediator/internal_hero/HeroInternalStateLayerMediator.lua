local BaseUIMediator = requireMediator("BaseUIMediator")
local HeroInternalStateLayerMediator = class("HeroInternalStateLayerMediator", BaseUIMediator)
HeroInternalStateLayerMediator.NAME = "HeroInternalStateLayerMediator"

function HeroInternalStateLayerMediator:ctor()
    HeroInternalStateLayerMediator.super.ctor(self)
    self._layer = nil
end

function HeroInternalStateLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Hero_Internal_State_Open,
        noticeTable.Layer_Hero_Internal_Child_Del,
    }
end

function HeroInternalStateLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Hero_Internal_State_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Hero_Internal_Child_Del then
        if SLDefine.InternalPage.State == noticeData then
            self:CloseLayer()
        end
    end
end

function HeroInternalStateLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "internal_hero/HeroInternalStateLayer"
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.InternalPage.State
        data.init = noticeData and noticeData.init
        data.isInternal = true

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_HERO_FRAME_PAGE_ADD, data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.HeroInternalState
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end

end

function HeroInternalStateLayerMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.HeroInternalState
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    
    if self._layer then
        if HeroInternalState.OnClose then
            HeroInternalState.OnClose()
        end
        self._layer:removeFromParent()
        self._layer = nil
    end
end


return HeroInternalStateLayerMediator