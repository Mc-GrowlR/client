local BaseUIMediator = requireMediator("BaseUIMediator")
local ChatExtendMediator = class("ChatExtendMediator", BaseUIMediator)
ChatExtendMediator.NAME = "ChatExtendMediator"

function ChatExtendMediator:ctor()
    ChatExtendMediator.super.ctor(self)
end

function ChatExtendMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_ChatExtend_Open,
        noticeTable.Layer_ChatExtend_Close,
        noticeTable.Layer_ChatExtend_Exit,
    }
end

function ChatExtendMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_ChatExtend_Open == noticeID then
        self:OpenLayer(data)
        
    elseif noticeTable.Layer_ChatExtend_Close == noticeID then
        self:CloseLayer()

    elseif noticeTable.Layer_ChatExtend_Exit == noticeID then
        self:OnExitWithAction()
    end
end

function ChatExtendMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer = requireLayerUI("chat_layer/ChatExtendLayer").create()

        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_CHAT_MINI
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()
    else
        if global.isWinPlayMode then
            self:CloseLayer()
        end
    end
    
    self:OnSelectGroup(data)
end

function ChatExtendMediator:CloseLayer()
    if not self._layer then
        return nil
    end
    self._layer:removeFromParent()
    self._layer = nil
end

function ChatExtendMediator:OnExitWithAction()
    if not self._layer then
        return nil
    end
    if ChatExtend and ChatExtend.ExitAction then
        ChatExtend.ExitAction()
    end
end

function ChatExtendMediator:OnSelectGroup(data)
    if not self._layer then
        return nil
    end

    self._layer:OnSelectGroup(data)
end

return ChatExtendMediator
