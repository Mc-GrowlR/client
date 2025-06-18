local BaseUIMediator = requireMediator("BaseUIMediator")
local MagicInfoConfigMediator = class('MagicInfoConfigMediator', BaseUIMediator)
MagicInfoConfigMediator.NAME = "MagicInfoConfigMediator"

function MagicInfoConfigMediator:ctor()
    MagicInfoConfigMediator.super.ctor(self)
end

function MagicInfoConfigMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
    {
        noticeTable.MagicInfoOpen,
        noticeTable.MagicInfoClose,
    }
end

function MagicInfoConfigMediator:handleNotification(notification)
    local noticeName  = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData  = notification:getBody()
    
    if noticeTable.MagicInfoOpen == noticeName then
        self:Open()

    elseif noticeTable.MagicInfoClose == noticeName then
        self:Close()

    end
end

function MagicInfoConfigMediator:Open()
    if not self._layer then
        self._layer = requireLayerUI("test_layer/MagicInfoConfigLayer").create()
        self._type = global.UIZ.UI_TOBOX
        MagicInfoConfigMediator.super.OpenLayer(self)
    end
end

function MagicInfoConfigMediator:Close()
    if self._layer then
        self._layer:OnClose()
    end
    MagicInfoConfigMediator.super.CloseLayer(self)
end

return MagicInfoConfigMediator
