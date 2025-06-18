local HeroTakeOffEquipResponseCommand = class('HeroTakeOffEquipResponseCommand', framework.SimpleCommand)

function HeroTakeOffEquipResponseCommand:ctor()
end

function HeroTakeOffEquipResponseCommand:execute(notification)
    local data = notification:getBody()
    SLBridge:onLUAEvent(LUA_EVENT_HERO_TAKE_OFF_EQUIP, {isSuccess = data.isSuccess})
    if not data.isSuccess then      -- 脱装备失败
        if data.header and data.header.recog ~= 0 then
            local data = {
                MakeIndex = data.header.recog,
                state = 1
            }
            global.Facade:sendNotification( global.NoticeTable.Layer_Player_Equip_State_Change_Hero, data )
        end
        if data.header and data.header.param1 ~= 0 then 
            local errorCode = data.header.param1
            local stringCode = 600000325
            if errorCode == -1 then --位置错误
                stringCode = 600000320
            elseif errorCode == -2 then -- 未穿戴该位置物品
                stringCode = 600000321
            elseif errorCode == -4 then -- 无法取下
                stringCode = 600000322
            elseif errorCode == -5 then -- 背包已满
                stringCode = 600000323
            elseif errorCode == -6 then --未开启人物英雄背包互通
                stringCode = 600000324
            end
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(stringCode))
        end
    end
end

return HeroTakeOffEquipResponseCommand
