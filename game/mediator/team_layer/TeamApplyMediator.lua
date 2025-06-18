local BaseUIMediator = requireMediator("BaseUIMediator")
local TeamApplyMediator = class("TeamApplyMediator", BaseUIMediator)
TeamApplyMediator.NAME = "TeamApplyMediator"

function TeamApplyMediator:ctor()
    TeamApplyMediator.super.ctor(self)
end

function TeamApplyMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TeamApply_Open,
        noticeTable.Layer_TeamApply_Close,
    }
end

function TeamApplyMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local id = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_TeamApply_Open == id then
        self:OnOpen(data)

    elseif noticeTable.Layer_TeamApply_Close == id then
        self:OnClose()
    end
end

function TeamApplyMediator:OnOpen(data)
    if not (self._layer) then
        self._layer = requireLayerUI("team_layer/TeamApplyLayer").create()
        self._type = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.TeamApplyGUI

        TeamApplyMediator.super.OpenLayer(self)

        self._layer:InitGUI()
    end
end

function TeamApplyMediator:OnClose()
    TeamApplyMediator.super.CloseLayer(self)
end

return TeamApplyMediator
