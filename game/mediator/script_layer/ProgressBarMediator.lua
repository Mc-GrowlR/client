local BaseUIMediator   = requireMediator( "BaseUIMediator" )
local ProgressBarMediator = class('ProgressBarMediator', BaseUIMediator )
ProgressBarMediator.NAME  = "ProgressBarMediator"

function ProgressBarMediator:ctor()
    ProgressBarMediator.super.ctor( self )
end

function ProgressBarMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
    {
        noticeTable.Layer_ProgressBar_Open,
        noticeTable.Layer_ProgressBar_Close,
    }
end

function ProgressBarMediator:handleNotification(notification)
    local noticeTable  = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeID == noticeTable.Layer_ProgressBar_Open then
        self:OpenLayer(data)

    elseif noticeID == noticeTable.Layer_ProgressBar_Close then
        self:CloseLayer()
    end
end

function ProgressBarMediator:OpenLayer(data)
    if not self._layer then
        self._layer = requireLayerUI("script_layer/ProgressBarLayer").create(data)

        -- for GUI
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)

        global.Facade:sendNotification(global.NoticeTable.Layer_Notice_AddChild, {child = self._layer})
    end
end

function ProgressBarMediator:CloseLayer()
    if not self._layer then
        return
    end
    self._layer:removeFromParent()
    self._layer = nil
end

function ProgressBarMediator:onRegister()
    ProgressBarMediator.super.onRegister(self)

    local function ACTBEGIN(actor, act)
        if (global.MMO.ACTION_IDLE ~= act) then
            if not self._layer then
                return
            end
            self._layer:onActionBegin(actor, act)
        end
    end
    global.gamePlayerController:AddHandleOnActBegin(ACTBEGIN)
end

return ProgressBarMediator