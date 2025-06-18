
local BaseUIMediator = requireMediator("BaseUIMediator")
local AddBlackListMediator = class("AddBlackListMediator", BaseUIMediator)
AddBlackListMediator.NAME = "AddBlackListMediator"

function AddBlackListMediator:ctor()
    AddBlackListMediator.super.ctor(self)
end

function AddBlackListMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_AddBlackList_Open,
        noticeTable.Layer_AddBlackList_Close
    }
end

function AddBlackListMediator:handleNotification( notification )
    local noticeName = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData = notification:getBody()

    if noticeTable.Layer_AddBlackList_Open == noticeName then
        self:OnOpen()

    elseif noticeTable.Layer_AddBlackList_Close == noticeName then
        self:OnClose()
    end
end

function AddBlackListMediator:OnOpen( data )
    if not self._layer then
        self._layer = requireLayerUI("friend_layer/AddBlackListLayer").create( data )
        self._type = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.FriendAddBlacklist

        AddBlackListMediator.super.OpenLayer(self)

        self._layer:InitGUI()
    end
end

function AddBlackListMediator:OnClose()
    AddBlackListMediator.super.CloseLayer(self)
end

return AddBlackListMediator