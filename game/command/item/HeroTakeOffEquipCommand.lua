local HeroTakeOffEquipCommand = class('HeroTakeOffEquipCommand', framework.SimpleCommand)

function HeroTakeOffEquipCommand:ctor()
end

function HeroTakeOffEquipCommand:execute(notification) ---脱装备
    local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
    local data    = notification:getBody()

    local HeroBagProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)

    -- if HeroBagProxy:GetBagCollimator() then --有准星操作
    -- 	return
    -- end
    -- is bag full?
    if HeroBagProxy:isToBeFull() then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(800050))
        local data = {
            MakeIndex = data.MakeIndex,
            state = 1
        }
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Equip_State_Change_Hero, data)
        return false
    end


    local name    = data.Name
    local pos        = data.Where
    local MakeIndex = data.MakeIndex

    local AutoUseItemProxy = global.Facade:retrieveProxy(global.ProxyTable.AutoUseItemProxy)
    AutoUseItemProxy:AddEquipOffMakeIndex(MakeIndex)
    LuaSendMsg(global.MsgType.MSG_CS_PLAYER_EQUIP_OFF_REQUEST_HERO, MakeIndex, pos, 0, 0, name, string.len(name))

end


return HeroTakeOffEquipCommand