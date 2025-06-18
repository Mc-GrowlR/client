local TakeOnEquipResponseCommand = class('TakeOnEquipResponseCommand', framework.SimpleCommand)

function TakeOnEquipResponseCommand:ctor()
end

function TakeOnEquipResponseCommand:execute(notification)
    local data = notification:getBody()
    SLBridge:onLUAEvent(LUA_EVENT_TAKE_ON_EQUIP, {isSuccess = data.isSuccess, pos = data.pos})
    if not data.isSuccess then
        -- 穿戴失败
        global.Facade:sendNotification(global.NoticeTable.Bag_Item_Pos_Change)
        global.Facade:sendNotification(global.NoticeTable.HeroBag_Item_Pos_Change)
    end
end

return TakeOnEquipResponseCommand