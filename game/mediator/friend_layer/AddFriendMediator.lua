
local BaseUIMediator = requireMediator("BaseUIMediator")
local AddFriendMediator = class("AddFriendMediator", BaseUIMediator)
AddFriendMediator.NAME = "AddFriendMediator"

function AddFriendMediator:ctor()
    AddFriendMediator.super.ctor(self)
end

function AddFriendMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_AddFriend_Open,
        noticeTable.Layer_AddFriend_Close
    }
end

function AddFriendMediator:handleNotification( notification )
    local noticeName = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData = notification:getBody()

    if noticeTable.Layer_AddFriend_Open == noticeName then
        self:OnOpen()

    elseif noticeTable.Layer_AddFriend_Close == noticeName then
        self:OnClose()
    end
end

function AddFriendMediator:OnOpen( data )
    if not self._layer then
        self._layer = requireLayerUI("friend_layer/AddFriendLayer").create( data )
        self._type = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.FriendAdd

        AddFriendMediator.super.OpenLayer(self)

        self._layer:InitGUI()
    end
end

function AddFriendMediator:OnClose()
    AddFriendMediator.super.CloseLayer(self)
end

return AddFriendMediator