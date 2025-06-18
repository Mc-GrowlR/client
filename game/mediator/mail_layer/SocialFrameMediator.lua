local BaseUIMediator = requireMediator("BaseUIMediator")
local SocialFrameMediator = class("SocialFrameMediator", BaseUIMediator)
SocialFrameMediator.NAME = "SocialFrameMediator"

function SocialFrameMediator:ctor()
    SocialFrameMediator.super.ctor( self )
end

function SocialFrameMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Social_Open,
        noticeTable.Layer_Social_Close,
    }
end

function SocialFrameMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local id = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Social_Open == id then
        self:OpenLayer(data)

    elseif noticeTable.Layer_Social_Close == id then
        self:CloseLayer()
    end
end

function SocialFrameMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer    = requireLayerUI("mail_layer/SocialFrameLayer").create()
        self._type     = global.UIZ.UI_NORMAL
        self._escClose = true
        self._GUI_ID   = SLDefine.LAYERID.SocialGUI

        SocialFrameMediator.super.OpenLayer(self)

        self._layer:InitGUI(data)

        LoadLayerCUIConfig(global.CUIKeyTable.SOCIAL_FRAME, self._layer)
    else
        self._layer:PageTo(data)
    end
end

function SocialFrameMediator:CloseLayer()
    if self._layer then
        self._layer:OnClose()
    end
    SocialFrameMediator.super.CloseLayer(self)
end

return SocialFrameMediator
