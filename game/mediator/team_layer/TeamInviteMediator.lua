local BaseUIMediator = requireMediator( "BaseUIMediator" )
local TeamInviteMediator = class("TeamInviteMediator", BaseUIMediator)
TeamInviteMediator.NAME = "TeamInviteMediator"

function TeamInviteMediator:ctor()
    TeamInviteMediator.super.ctor( self )
end

function TeamInviteMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TeamInvite_Open,
        noticeTable.Layer_TeamInvite_Close,
    }
end

function TeamInviteMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    
    if noticeTable.Layer_TeamInvite_Open == noticeName then
        self:OpenLayer(noticeData)

    elseif noticeTable.Layer_TeamInvite_Close == noticeName then
        self:CloseLayer()
    end
end

function TeamInviteMediator:OpenLayer(data)
    if not self._layer then
        local layer = requireLayerUI("team_layer/TeamInviteLayer").create()
        self._layer = layer
        self._type = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.TeamInviteGUI

        TeamInviteMediator.super.OpenLayer( self )

        self._layer:InitGUI()
    end
end

function TeamInviteMediator:CloseLayer()
    TeamInviteMediator.super.CloseLayer( self )
end

return TeamInviteMediator