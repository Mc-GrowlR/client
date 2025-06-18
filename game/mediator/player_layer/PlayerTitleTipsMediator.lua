local BaseUIMediator = requireMediator("BaseUIMediator")
local PlayerTitleTipsMediator = class("PlayerTitleTipsMediator", BaseUIMediator)
PlayerTitleTipsMediator.NAME = "PlayerTitleTipsMediator"

function PlayerTitleTipsMediator:ctor()
    PlayerTitleTipsMediator.super.ctor(self)
end

function PlayerTitleTipsMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_TitleTips_Open,
        noticeTable.Layer_TitleTips_Close,
        noticeTable.UserInputEventNotice,
    }
end

function PlayerTitleTipsMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData    = notification:getBody()
    if noticeTable.Layer_TitleTips_Open == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_TitleTips_Close == noticeName then
        self:CloseLayer()
    elseif noticeTable.UserInputEventNotice == noticeName then
        self:OnUserInputEventNotice()
    end
end

function PlayerTitleTipsMediator:OpenLayer(noticeData)
    if not (self._layer) then
        local Layer = requireLayerUI("player_layer/PlayerTitleTipsLayer")
        local layer = Layer.create(noticeData)
        self._layer        = layer
        self._type        = global.UIZ.UI_TOBOX
        PlayerTitleTipsMediator.super.OpenLayer(self)
        GUI.ATTACH_PARENT = self._layer 
        self._layer:InitGUI(noticeData)
    else
        self._layer:InitLayer(noticeData)
    end
end

function PlayerTitleTipsMediator:CloseLayer()
    PlayerTitleTipsMediator.super.CloseLayer(self)
end

function PlayerTitleTipsMediator:OnUserInputEventNotice()
    if self._layer then
        self:CloseLayer()
    end
end

return PlayerTitleTipsMediator