local BaseUIMediator = requireMediator( "BaseUIMediator" )
local RedDotMediator = class("RedDotMediator", BaseUIMediator)
RedDotMediator.NAME = "RedDotMediator"

function RedDotMediator:ctor()
    RedDotMediator.super.ctor( self )
end

function RedDotMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
            noticeTable.Layer_RedDot_refData,
            }
end

function RedDotMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    if noticeTable.Layer_RedDot_refData == noticeName then
        self:refData(noticeData)
    end
end



function RedDotMediator:refData(data)
    local Layer = requireLayerUI( "common_tips_layer/RedDotLayer" )
    Layer.create(data)
end


return RedDotMediator