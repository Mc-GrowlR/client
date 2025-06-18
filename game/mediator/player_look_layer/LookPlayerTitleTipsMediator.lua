local BaseUIMediator = requireMediator("BaseUIMediator")
local LookPlayerTitleTipsMediator = class("LookPlayerTitleTipsMediator", BaseUIMediator)
LookPlayerTitleTipsMediator.NAME = "LookPlayerTitleTipsMediator"

function LookPlayerTitleTipsMediator:ctor()
    LookPlayerTitleTipsMediator.super.ctor(self)
end

function LookPlayerTitleTipsMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Look_TitleTips_Open,
        noticeTable.Layer_Look_TitleTips_Close,
        noticeTable.UserInputEventNotice,
    }
end

function LookPlayerTitleTipsMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData    = notification:getBody()
    if noticeTable.Layer_Look_TitleTips_Open == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_Look_TitleTips_Close == noticeName then
        self:CloseLayer()
    elseif noticeTable.UserInputEventNotice == noticeName then
        self:OnUserInputEventNotice()
    end
end

function LookPlayerTitleTipsMediator:OpenLayer(noticeData)
    if not (self._layer) then
        local Layer = requireLayerUI("player_look_layer/PlayerTitleTipsLayer")
        local layer = Layer.create(noticeData)
        self._layer        = layer
        self._type        = global.UIZ.UI_TOBOX
        LookPlayerTitleTipsMediator.super.OpenLayer(self)
        GUI.ATTACH_PARENT = self._layer 
        self._layer:InitGUI(noticeData)
    else
        self._layer:InitLayer(noticeData)
    end
end

function LookPlayerTitleTipsMediator:CloseLayer()
    LookPlayerTitleTipsMediator.super.CloseLayer(self)
end

function LookPlayerTitleTipsMediator:OnUserInputEventNotice()
    if self._layer then
        self:CloseLayer()
    end
end

return LookPlayerTitleTipsMediator