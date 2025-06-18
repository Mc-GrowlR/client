local TakeOnEquipCommand = class('TakeOnEquipCommand', framework.SimpleCommand)

function TakeOnEquipCommand:ctor()
end

function TakeOnEquipCommand:execute(notification)--穿装备
    local playerProxy    = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local data    = notification:getBody()

    if not data then
        return
    end
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    if BagProxy:GetBagCollimator() then --有准星操作
        return
    end

    local itemData = data.itemData
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local pos = EquipProxy:GetEquipPosByStdMode(itemData.StdMode)

    if data.pos then
        pos = data.pos
    else
        local minPowerPos, onEquipMinPower, hasEquip = EquipProxy:GetEquipTakeOnPosByStdMode(itemData.StdMode)
        if minPowerPos >= 0 then
            pos = minPowerPos
        end
    end

    if not pos then
        return
    end

    local canUse, strList, notCheckUse = CheckItemUseNeed(itemData)
    if not canUse and not notCheckUse then
        for i, v in ipairs(strList) do
            if not v.can and not notCheckUse then
                local color = GUIFunction:ItemUseConditionColor(v.can)
                local conditionStr = string.format(GET_STRING(80049997), color, v.str)
                global.Facade:sendNotification(global.NoticeTable.SystemTips, conditionStr)
                break
            end
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return
    end

    if not EquipProxy:CheckEquipCondition(pos) then
        return
    end

    local MakeIndex = itemData.MakeIndex
    local Name = itemData.Name
    LuaSendMsg(global.MsgType.MSG_CS_PLAYER_EQUIP_ON_REQUEST, MakeIndex, pos, 0, 0, Name, string.len(Name))
end


return TakeOnEquipCommand