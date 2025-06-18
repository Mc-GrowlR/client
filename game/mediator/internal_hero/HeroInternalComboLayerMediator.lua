local BaseUIMediator = requireMediator("BaseUIMediator")
local HeroInternalComboLayerMediator = class("HeroInternalComboLayerMediator", BaseUIMediator)
HeroInternalComboLayerMediator.NAME = "HeroInternalComboLayerMediator"

function HeroInternalComboLayerMediator:ctor()
    HeroInternalComboLayerMediator.super.ctor(self)
    self._layer = nil
end

function HeroInternalComboLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Hero_Internal_Combo_Open,
        noticeTable.Layer_Hero_Internal_Child_Del,
    }
end

function HeroInternalComboLayerMediator:handleNotification(notification)
    local notices = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Hero_Internal_Combo_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Hero_Internal_Child_Del then
        if SLDefine.InternalPage.Combo == noticeData then
            self:CloseLayer()
        end
    end
end

function HeroInternalComboLayerMediator:OpenLayer(noticeData)
    if not self._layer then
        local path = "internal_hero/HeroInternalComboLayer"
        self._layer = requireLayerUI(path).create(noticeData)

        local data = {}
        data.child = self._layer
        data.index = SLDefine.InternalPage.Combo
        data.init = noticeData and noticeData.init
        data.isInternal = true

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(noticeData)

        SL:onLUAEvent(LUA_EVENT_HERO_FRAME_PAGE_ADD, data)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._root,
            index = global.SUIComponentTable.HeroInternalCombo
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        
    else
        self:CloseLayer()
        self:OpenLayer(noticeData)
    end

end

function HeroInternalComboLayerMediator:CloseLayer()
    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.HeroInternalCombo
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer then
        if HeroInternalCombo.OnClose then
            HeroInternalCombo.OnClose()
        end
        self._layer:removeFromParent()
        self._layer = nil
    end
end


return HeroInternalComboLayerMediator