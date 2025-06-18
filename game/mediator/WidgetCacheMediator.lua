local DebugMediator = requireMediator("DebugMediator")
local WidgetCacheMediator = class("WidgetCacheMediator", DebugMediator)
WidgetCacheMediator.NAME = "WidgetCacheMediator"

function WidgetCacheMediator:ctor()
    WidgetCacheMediator.super.ctor(self)

    global.WidgetCacheManager:WidgetPoolCapacity("item/item", 50)
    global.WidgetCacheManager:WidgetPoolCapacity("bag_item/bag_item", 40)
    global.WidgetCacheManager:WidgetPoolCapacity("bag_item/bag_item_effect", 40)
    global.WidgetCacheManager:WidgetPoolCapacity("bag_item/bag_item_num", 40)
end

function WidgetCacheMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.ReleaseMemory
    }
end

function WidgetCacheMediator:handleNotification(notification)
    local noticeName = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData = notification:getBody()

    if noticeName == noticeTable.ReleaseMemory then
        global.WidgetCacheManager:Clear()
    end
end

return WidgetCacheMediator
