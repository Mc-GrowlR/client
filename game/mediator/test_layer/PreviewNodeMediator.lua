local BaseUIMediator = requireMediator("BaseUIMediator")
local PreviewNodeMediator = class('PreviewNodeMediator', BaseUIMediator)
PreviewNodeMediator.NAME = "PreviewNodeMediator"

function PreviewNodeMediator:ctor()
    PreviewNodeMediator.super.ctor(self)
end

function PreviewNodeMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_PreviewNode_Open,
        noticeTable.Layer_PreviewNode_Close,
    }
end

function PreviewNodeMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_PreviewNode_Open == name then
        self:OpenLayer(data)
        
    elseif noticeTable.Layer_PreviewNode_Close == name then
        self:CloseLayer()
    end
end

function PreviewNodeMediator:OpenLayer(data)
    
    if not (self._layer) then
        self._layer = requireLayerUI("test_layer/PreviewNodeLayer"):Create(data)
        self._type  = global.UIZ.UI_MASK
        
        PreviewNodeMediator.super.OpenLayer(self)
    else
        self._layer = nil
        self:OpenLayer()
    end
end

function PreviewNodeMediator:CloseLayer()
    if not self._layer then
        return nil
    end
    PreviewNodeMediator.super.CloseLayer(self)
end

return PreviewNodeMediator
