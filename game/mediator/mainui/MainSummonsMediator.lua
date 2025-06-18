local MainSummonsMediator = class("MainSummonsMediator", framework.Mediator)
MainSummonsMediator.NAME = "MainSummonsMediator"

function MainSummonsMediator:ctor()
    MainSummonsMediator.super.ctor(self, self.NAME)
end

function MainSummonsMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.Layer_Main_Init,
    }
end

function MainSummonsMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Main_Init == noticeID then
        self:OnOpen()
    end
end

function MainSummonsMediator:OnOpen()
    if not (self._layer) then
        self._layer = requireMainUI("MainSummonsLayout").create()

        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_RB
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()

        LoadLayerCUIConfig(global.CUIKeyTable.MOBILE_SUMMONS, self._layer)
    end
end

return MainSummonsMediator
