local BaseUIMediator = requireMediator("BaseUIMediator")
local HeroInternalMeridianLayerMediator = class("HeroInternalMeridianLayerMediator", BaseUIMediator)
HeroInternalMeridianLayerMediator.NAME = "HeroInternalMeridianLayerMediator"

function HeroInternalMeridianLayerMediator:ctor()
    HeroInternalMeridianLayerMediator.super.ctor(self)
    self._layer = nil
end

function HeroInternalMeridianLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Hero_Internal_Meridian_Open,
        noticeTable.Layer_Hero_Internal_Child_Del,
    }
end

function HeroInternalMeridianLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Hero_Internal_Meridian_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Hero_Internal_Child_Del then
        if SLDefine.InternalPage.Meridian == noticeData then
            self:CloseLayer()
        end
    end
end

function HeroInternalMeridianLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "internal_hero/HeroInternalMeridianLayer"
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.InternalPage.Meridian
        data.init = noticeData and noticeData.init
        data.isInternal = true

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_HERO_FRAME_PAGE_ADD, data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.HeroInternalMeridian
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        
        for i = 1, 5 do
            local componentData = {
                root = self._layer._ui and self._layer._ui["Panel_show_" .. i],
                index = global.SUIComponentTable["HeroInternalMeridian" .. i]
            }
            global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        end
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end

end

function HeroInternalMeridianLayerMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.HeroInternalMeridian
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    for i = 1, 5 do
        local componentData = {
            index = global.SUIComponentTable["HeroInternalMeridian" .. i]
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
    end
    
    if self._layer then
        if HeroInternalMeridian.OnClose then
            HeroInternalMeridian.OnClose()
        end
        self._layer:removeFromParent()
        self._layer = nil
    end
end


return HeroInternalMeridianLayerMediator