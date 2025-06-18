
local BaseUIMediator = requireMediator("BaseUIMediator")
local FriendApplyMediator = class("FriendApplyMediator", BaseUIMediator)
FriendApplyMediator.NAME = "FriendApplyMediator"

function FriendApplyMediator:ctor()
    FriendApplyMediator.super.ctor(self)
end

function FriendApplyMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_FriendApply_Open,
        noticeTable.Layer_FriendApply_Close,
        noticeTable.Layer_FriendApply_Refresh
    } 
end

function FriendApplyMediator:handleNotification( notification )
    local noticeName = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData =  notification:getBody()

    if noticeTable.Layer_FriendApply_Open == noticeName then
        self:OpenLayer( noticeData )

    elseif noticeTable.Layer_FriendApply_Close == noticeName then
        self:CloseLayer()

    elseif noticeTable.Layer_FriendApply_Refresh == noticeName then
        self:RefreshFriendApply()
    end
end

function FriendApplyMediator:OpenLayer( data )
    if not self._layer then
        self._layer = requireLayerUI("friend_layer/FriendApplyLayer").create()
        self._type = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.FriendApplyGUI
        
        FriendApplyMediator.super.OpenLayer(self)

        self._layer:InitGUI()
    end
end

function FriendApplyMediator:CloseLayer()
    FriendApplyMediator.super.CloseLayer(self)
end

function FriendApplyMediator:RefreshFriendApply()
    if self._layer then
        SL:onLUAEvent(LUA_EVENT_FRIEND_APPLY)
    end
end

return FriendApplyMediator
