local HeroTakeOnEquipResponseCommand = class('HeroTakeOnEquipResponseCommand', framework.SimpleCommand)

function HeroTakeOnEquipResponseCommand:ctor()
end

function HeroTakeOnEquipResponseCommand:execute(notification)
    local data = notification:getBody()
    SLBridge:onLUAEvent(LUA_EVENT_HERO_TAKE_ON_EQUIP, {isSuccess = data.isSuccess})
    if data.isSuccess then      -- 穿戴成功
    else                        -- 穿戴失败
        global.Facade:sendNotification(global.NoticeTable.HeroBag_Item_Pos_Change)
        global.Facade:sendNotification(global.NoticeTable.Bag_Item_Pos_Change)
    end
end

return HeroTakeOnEquipResponseCommand