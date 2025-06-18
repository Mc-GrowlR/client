local BaseUIMediator = requireMediator("BaseUIMediator")
local RichTextTestMediator = class('RichTextTestMediator', BaseUIMediator)
RichTextTestMediator.NAME = "RichTextTestMediator"

function RichTextTestMediator:ctor()
    RichTextTestMediator.super.ctor(self)
end

function RichTextTestMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_RichTextTest_Open,
        noticeTable.Layer_RichTextTest_Close,
    }
end

function RichTextTestMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_RichTextTest_Open == name then
        self:OpenLayer(data)
        
    elseif noticeTable.Layer_RichTextTest_Close == name then
        self:CloseLayer()
    end
end

function RichTextTestMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer = requireLayerUI("test_layer/RichTextTestLayer"):Create(data)
        self._type  = global.UIZ.UI_NOTICE
        
        RichTextTestMediator.super.OpenLayer(self)
    end
end

function RichTextTestMediator:CloseLayer()
    if not self._layer then
        return nil
    end
    RichTextTestMediator.super.CloseLayer(self)
end

return RichTextTestMediator
