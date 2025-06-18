local BaseUIMediator = requireMediator("BaseUIMediator")
local GUIVarManagerMediator = class('GUIVarManagerMediator', BaseUIMediator)
GUIVarManagerMediator.NAME = "GUIVarManagerMediator"

function GUIVarManagerMediator:ctor()
    GUIVarManagerMediator.super.ctor(self)
end

function GUIVarManagerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_GUIVarManager_Open,
        noticeTable.Layer_GUIVarManager_Close
    }
end

function GUIVarManagerMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_GUIVarManager_Open == name then
        self:OpenLayer(data)
    elseif noticeTable.Layer_GUIVarManager_Close == name then
        self:CloseLayer()
    end
end

function GUIVarManagerMediator:OpenLayer(data)
    if self._layer and not tolua.isnull(self._layer) then
        self:CloseLayer()
    else
        self._layer = nil
    end

    if not (self._layer) then
        self._layer = requireLayerGUI("GUIVarManager").create(data)
        self._type = global.UIZ.UI_MASK
        GUIVarManagerMediator.super.OpenLayer(self)
    end
end

function GUIVarManagerMediator:CloseLayer()
    if not self._layer then
        return false
    end
    GUIVarManagerMediator.super.CloseLayer(self)
end

return GUIVarManagerMediator