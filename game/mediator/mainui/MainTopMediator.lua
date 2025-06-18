local MainTopMediator = class("MainTopMediator", framework.Mediator)
MainTopMediator.NAME = "MainTopMediator"

function MainTopMediator:ctor()
    MainTopMediator.super.ctor(self, self.NAME)
end

function MainTopMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Main_Init,
    }
end

function MainTopMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Main_Init == noticeID then
        self:OnMainInit()
    end
end

function MainTopMediator:OnMainInit()
    if not self._layer then
        self._layer = requireMainUI("MainTopLayout").create()

        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_EXTRA_MT
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)

        LoadLayerCUIConfig(global.CUIKeyTable.MAINTOP, self._layer)
    end
end

return MainTopMediator