local HeroTakeOnEquipCommand = class('HeroTakeOnEquipCommand', framework.SimpleCommand)

function HeroTakeOnEquipCommand:ctor()
end

function HeroTakeOnEquipCommand:execute(notification)--穿装备
    local playerProxy    = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    local data    = notification:getBody()
    if not data then
        return
    end

    local itemData = data.itemData
    local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
    local pos = HeroEquipProxy:GetEquipPosByStdMode(itemData.StdMode)

    if data.pos then
        pos = data.pos
    else
        local minPowerPos, onEquipMinPower, hasEquip = HeroEquipProxy:GetEquipTakeOnPosByStdMode(itemData.StdMode)
        if minPowerPos >= 0 then
            pos = minPowerPos
        end
    end

    if not pos then
        return
    end

    local canUse, strList, notCheckUse = CheckItemUseNeed_Hero(itemData)
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

    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    if not EquipProxy:CheckEquipCondition(pos) then
        return
    end

    local MakeIndex = itemData.MakeIndex
    local Name = itemData.Name
    LuaSendMsg(global.MsgType.MSG_CS_HERO_TAKEON_FROMHUMBAG, MakeIndex, pos, 0, 0, Name, string.len(Name))
end


return HeroTakeOnEquipCommand