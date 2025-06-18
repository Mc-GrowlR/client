local BaseUIMediator   = requireMediator( "BaseUIMediator" )
local PlayDiceMediator = class('PlayDiceMediator', BaseUIMediator )
PlayDiceMediator.NAME  = "PlayDiceMediator"

function PlayDiceMediator:ctor()
    PlayDiceMediator.super.ctor( self )
end

function PlayDiceMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
    {
        noticeTable.Layer_PlayDice_Open,
        noticeTable.Layer_PlayDice_Close,
    }
end

function PlayDiceMediator:handleNotification(notification)
    local noticeTable  = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeID == noticeTable.Layer_PlayDice_Open then
        self:OpenLayer(data)

    elseif noticeID == noticeTable.Layer_PlayDice_Close then
        self:CloseLayer()
    end
end

function PlayDiceMediator:OpenLayer(data)
    if not self._layer then
        self._layer = requireLayerUI("script_layer/PlayDiceLayer").create(data)
        self._type  = global.UIZ.UI_NORMAL

        PlayDiceMediator.super.OpenLayer(self)

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)
    end
end

function PlayDiceMediator:CloseLayer()
    if not self._layer then
        return
    end
    self._layer:OnClose()
    PlayDiceMediator.super.CloseLayer(self)
end

return PlayDiceMediator