local DebugMediator = requireMediator("DebugMediator")
local CustomCacheMediator = class("CustomCacheMediator", DebugMediator)
CustomCacheMediator.NAME = "CustomCacheMediator"

function CustomCacheMediator:ctor()
    CustomCacheMediator.super.ctor(self)
end

function CustomCacheMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.ReleaseMemory
    }
end

function CustomCacheMediator:handleNotification(notification)
    local noticeName = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData = notification:getBody()

    if noticeName == noticeTable.ReleaseMemory then
        global.CustomCache:Clear()
    end
end

return CustomCacheMediator
