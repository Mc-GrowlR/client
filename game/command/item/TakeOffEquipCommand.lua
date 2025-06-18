local TakeOffEquipCommand = class('TakeOffEquipCommand', framework.SimpleCommand)

function TakeOffEquipCommand:ctor()
end

function TakeOffEquipCommand:execute(notification) ---脱装备
    local equipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local data    = notification:getBody()

    local bagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)

    if bagProxy:GetBagCollimator() then --有准星操作
        return
    end
    -- is bag full?
    if bagProxy:isToBeFull() then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(800050))
        local data = {
            MakeIndex = data.MakeIndex,
            state = 1
        }
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Equip_State_Change, data)
        return false
    end


    local name    = data.Name
    local pos        = data.Where
    local MakeIndex = data.MakeIndex

    local AutoUseItemProxy = global.Facade:retrieveProxy(global.ProxyTable.AutoUseItemProxy)
    AutoUseItemProxy:AddEquipOffMakeIndex(MakeIndex)
    LuaSendMsg(global.MsgType.MSG_CS_PLAYER_EQUIP_OFF_REQUEST, MakeIndex, pos, 0, 0, name, string.len(name))

end


return TakeOffEquipCommand