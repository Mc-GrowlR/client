local BaseUIMediator = requireMediator("BaseUIMediator")
local AnimSetMediator = class('AnimSetMediator', BaseUIMediator)
AnimSetMediator.NAME = "AnimSetMediator"

function AnimSetMediator:ctor()
    AnimSetMediator.super.ctor(self)
end

function AnimSetMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
    {
        noticeTable.AnimSetOpen,
        noticeTable.AnimSetClose
    }
end

function AnimSetMediator:handleNotification(notification)
    local noticeName  = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData  = notification:getBody()
    
    if noticeTable.AnimSetOpen == noticeName then
        self:Open(noticeData)
    elseif noticeTable.AnimSetClose == noticeName then
        self:Close()
    end
end

function AnimSetMediator:Open(data)
    if self._layer and not tolua.isnull(self._layer) then
        self:CloseLayer()
    else
        self._layer = nil
    end

    if not self._layer then
        self._layer = requireLayerUI("test_layer/AnimSetLayout").create(data)
        self._type = global.UIZ.UI_TOBOX
        AnimSetMediator.super.OpenLayer(self)
    end
end

function AnimSetMediator:Close()
    global.userInputController:rmvKeyboardListener(cc.KeyCode.KEY_ESCAPE)
    AnimSetMediator.super.CloseLayer(self)
end

return AnimSetMediator
