local BaseUIMediator = requireMediator("BaseUIMediator")
local ButtonPosMediator = class("ButtonPosMediator", BaseUIMediator)
ButtonPosMediator.NAME = "ButtonPosMediator"

function ButtonPosMediator:ctor()
    ButtonPosMediator.super.ctor(self)
end

function ButtonPosMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_ButtonPos_Open,
        noticeTable.Layer_ButtonPos_Close,
    }
end

function ButtonPosMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local id = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_ButtonPos_Open == id then
        self:OpenLayer(data)
    elseif noticeTable.Layer_ButtonPos_Close == id then
        self:CloseLayer()
    end
end

function ButtonPosMediator:OpenLayer(data)
    if not self._layer then
        local layer     = requireLayerUI("button_pos_layer/MainButtonPosLayer").create(data)
        self._layer     = layer
        self._type      = global.UIZ.UI_NORMAL
        self._adapet    = true
        self._hideMain  = false
        self._hideLast  = false
        ButtonPosMediator.super.OpenLayer( self )
    end
end

function ButtonPosMediator:CloseLayer()
    ButtonPosMediator.super.CloseLayer( self )
end

return ButtonPosMediator
