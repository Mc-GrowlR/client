local BaseUIMediator        = requireMediator( "BaseUIMediator" )
local PrivateChatMediator = class('PrivateChatMediator', BaseUIMediator )
PrivateChatMediator.NAME  = "PrivateChatMediator"

function PrivateChatMediator:ctor()
    PrivateChatMediator.super.ctor( self )
end

function PrivateChatMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
      noticeTable.Layer_Private_Chat_Open,
      noticeTable.Layer_Private_Chat_Close,
      noticeTable.Layer_Private_Chat_AddItem,
      noticeTable.Layer_Private_Chat_RemoveItem,
    }
end

function PrivateChatMediator:handleNotification(notification)
   local noticeName    = notification:getName()
   local noticeTable   = global.NoticeTable
   local noticeData    = notification:getBody()

    if noticeTable.Layer_Private_Chat_Open == noticeName then
        self:OpenLayer()
    elseif noticeTable.Layer_Private_Chat_Close == noticeName then
        self:CloseLayer()
    elseif noticeTable.Layer_Private_Chat_AddItem == noticeName then
        self:AddItem(noticeData)
    elseif noticeTable.Layer_Private_Chat_RemoveItem == noticeName then
        self:RemoveItem(noticeData)
    end
end

function PrivateChatMediator:OpenLayer()

    if not (self._layer) then
        local path  = "private_chat/PrivateChatLayer-win32"
        self._layer = requireLayerUI(path).create()
        self._type  = global.UIZ.UI_NORMAL
        self._GUI_ID   = SLDefine.LAYERID.PrivateChatWin32GUI
        PrivateChatMediator.super.OpenLayer(self)

        self._layer:InitGUI()

        global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, { id = 14, status = false })
    end    
end

function PrivateChatMediator:CloseLayer()
    PrivateChatMediator.super.CloseLayer(self)
end

function PrivateChatMediator:AddItem(data)
    if self._layer then
        self._layer:AddItem(data)
    end
end

function PrivateChatMediator:RemoveItem(data)
    if self._layer then
        self._layer:RemoveItem(data)
    end
end

return PrivateChatMediator