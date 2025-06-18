local MainAssistMediator = class("MainAssistMediator", framework.Mediator)
MainAssistMediator.NAME = "MainAssistMediator"

function MainAssistMediator:ctor()
    MainAssistMediator.super.ctor(self, self.NAME)
end

function MainAssistMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Main_Init,
        noticeTable.Layer_Assist_Show,
        noticeTable.Layer_Assist_Hide,
        noticeTable.Layer_Assist_ChangeHide,
    }
end

function MainAssistMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Main_Init == noticeID then
        self:OnMainInit()

    elseif noticeTable.Layer_Assist_Show == noticeID then
        self:OnShow(data)

    elseif noticeTable.Layer_Assist_Hide == noticeID then
        self:OnHide(data)

    elseif noticeTable.Layer_Assist_ChangeHide == noticeID then
        self:ChangeHideStatus(data)

    end
end

function MainAssistMediator:OnMainInit()
    if not self._layer then
        self._layer = requireMainUIWIN32("MainAssistLayout-win32").create()

        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_LT
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()

        LoadLayerCUIConfig(global.CUIKeyTable.ASSIST, self._layer)
        -- 特殊刷新数值
        self._layer:ReloadCUISetWidget()

        -- 自定义组件挂接
        local componentData = 
        {
            root  = self._layer._ui.Panel_mission,
            index = global.SUIComponentTable.MainRootMission
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

        local componentData = 
        {
            root  = self._layer._ui.Panel_assist,
            index = global.SUIComponentTable.MainRootAssist
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

        ssr.ssrBridge:setGUIParent(110, self._layer._ui.Panel_mission)
        ssr.ssrBridge:setGUIParent(111, self._layer._ui.Panel_assist)
    end

    -- 开关
    if CHECK_SERVER_OPTION(global.MMO.SERVER_OPTION_MISSTION) ~= 1 then
        self._layer:setVisible(false)
    end
end

function MainAssistMediator:OnShow(data)
    if not self._layer then
        return
    end
    self._layer:setVisible(true)
end

function MainAssistMediator:OnHide(data)
    if not self._layer then
        return
    end
    self._layer:setVisible(false)
end

function MainAssistMediator:ChangeHideStatus(data)
    if not self._layer then
        return
    end
    self._layer:ChangeHideStatus(not data)
end

return MainAssistMediator