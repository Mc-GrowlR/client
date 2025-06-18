local BaseUIMediator = requireMediator( "BaseUIMediator" )
local TeamBeInviteMediator = class("TeamBeInviteMediator", BaseUIMediator)
TeamBeInviteMediator.NAME = "TeamBeInviteMediator"

function TeamBeInviteMediator:ctor()
    TeamBeInviteMediator.super.ctor( self )
end

function TeamBeInviteMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Team_BeInvite_Open,
        noticeTable.Layer_Team_BeInvite_Close,
    }
end

function TeamBeInviteMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    
    if noticeTable.Layer_Team_BeInvite_Open == noticeName then
        self:OpenLayer(noticeData)

    elseif noticeTable.Layer_Team_BeInvite_Close == noticeName then
        self:CloseLayer()
    end
end

function TeamBeInviteMediator:OpenLayer(data)
    if not self._layer then
        local layer = requireLayerUI("team_layer/TeamBeInvitedLayer").create(data)
        self._layer = layer
        self._type = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.TeamBeInvitedPopGUI

        TeamBeInviteMediator.super.OpenLayer( self )

        self._layer:InitGUI(data)
    end
end

function TeamBeInviteMediator:CloseLayer()
    TeamBeInviteMediator.super.CloseLayer( self )
end

return TeamBeInviteMediator