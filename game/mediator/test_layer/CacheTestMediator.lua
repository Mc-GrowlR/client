local BaseUIMediator = requireMediator("BaseUIMediator")
local CacheTestMediator = class('CacheTestMediator', BaseUIMediator)
CacheTestMediator.NAME = "CacheTestMediator"

function CacheTestMediator:ctor()
    CacheTestMediator.super.ctor(self)
end

function CacheTestMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_CacheTest_Open,
        noticeTable.Layer_CacheTest_Close,
    }
end

function CacheTestMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_CacheTest_Open == name then
        self:OpenLayer(data)
        
    elseif noticeTable.Layer_CacheTest_Close == name then
        self:CloseLayer()
    end
end

function CacheTestMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer = requireLayerUI("test_layer/CacheTestLayer"):Create(data)
        self._type  = global.UIZ.UI_NOTICE
        
        CacheTestMediator.super.OpenLayer(self)
    end
end

function CacheTestMediator:CloseLayer()
    if not self._layer then
        return nil
    end
    CacheTestMediator.super.CloseLayer(self)
end

return CacheTestMediator
