local RemoteProxy   = requireProxy( "remote/RemoteProxy" )
local ItemUseProxy = class( "ItemUseProxy", RemoteProxy )
ItemUseProxy.NAME   = global.ProxyTable.ItemUseProxy

local socket = require("socket")

function ItemUseProxy:ctor()
    self.itemCD = {}
    self.itemCD_Hero = {}

    self.itemUseCountdown = 0
    self.itemUseCountdown_Hero = 0
    ItemUseProxy.super.ctor(self)
end

function ItemUseProxy:UseItem(item, autoUse)
    if not item or next(item) == nil then
        return
    end
    if not CheckCanDoSomething() then
        return
    end
    
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    if item.from ~= ItemMoveProxy.ItemFrom.BAG then
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        if BagProxy:GetBagCollimator() then --判断背包准星操作
            return
        end
    end

    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local canUse, strList, notCheckUse = CheckItemUseNeed(item)
    if not canUse and not notCheckUse then
        for i,v in ipairs(strList) do
            if not v.can and not notCheckUse then
                local color = GUIFunction:ItemUseConditionColor(v.can)
                local conditionStr = string.format(GET_STRING(80049997), color, v.str)
                global.Facade:sendNotification(global.NoticeTable.SystemTips, conditionStr)
                break
            end
        end
        return
    end

    local isUseCd = self:CheckIsCD(item.Index)
    if isUseCd then
        return
    end

    if not self:CheckSpecialUseCondition(item) then
        return
    end

    local BuffProxy = global.Facade:retrieveProxy( global.ProxyTable.Buff )
    local ret,buffid = BuffProxy:CheckUseItemEnable( item.Index )
    if not ret then
        if buffid then
            local config = BuffProxy:GetConfigByID( buffid ) or {}
            if config.bufftitle then
                ShowSystemTips( config.bufftitle )
            end
        end
        return
    end

    if item.StdMode == 2 or item.StdMode == 3 then
        local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        local itemUseCd =  MapProxy:GetEatItemSpeed() or 500
        self:IntoCD(item.Index, itemUseCd)
    end

    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    
    local Item_Type = ItemManagerProxy:GetItemSettingType()
    local itemType = ItemManagerProxy:GetItemType(item)

    if item.StdMode == 96 then
        itemType = Item_Type.WishBox
    end
    if itemType == Item_Type.DruaAndSomething
        or itemType == Item_Type.Bundle
        or itemType == Item_Type.Box
        or itemType == Item_Type.TreasureMap
        or itemType == Item_Type.FashionItem
        or itemType == Item_Type.MonsterCard
        or itemType == Item_Type.SomethingCanUse
        or itemType == Item_Type.WishBox 
        or itemType == Item_Type.Collimator 
        or itemType == Item_Type.NewPet then
        self:handleItem(item)

        local Name      = item.Name or ""
        local MakeIndex = item.MakeIndex
        if item.StdMode == 200 and item.Shape == 0 and (ItemConfigProxy:CheckItemOverLap(item) or ItemConfigProxy:CheckItemBatch(item)) then
            if item.StdMode == 200 and item.Shape == 0 then
                autoUse = true
            end
            if autoUse then -- 自动使用 用全部
                local autoUseNumber = item.OverLap > 1 and item.OverLap or 1
                LuaSendMsg( global.MsgType.MSG_CS_USE_BAG_ITEM, MakeIndex, autoUseNumber , 0, 0, Name , string.len(Name) )
            else
                -- 叠加道具批量使用
                local function callback(btnType, data)
                    if data.editStr and data.editStr ~= "" then
                        if type(data.editStr) == "string" then
                            local num  = tonumber(data.editStr)
                            if not num or num > item.OverLap or num <= 0 then
                                global.Facade:sendNotification( global.NoticeTable.SystemTips, GET_STRING( 90020007 ) )
                                return
                            end
                            LuaSendMsg( global.MsgType.MSG_CS_USE_BAG_ITEM, MakeIndex, num , 0, 0, Name , string.len(Name) )
                        end
                    end
                end
                local data = {}
                data.str = GET_STRING(90020006)
                data.callback = callback
                data.btnType = 2
                data.showEdit = true
                data.editParams = {
                    inputMode = 2,
                    str = item.OverLap
                }
                global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
            end
        else
            if itemType == Item_Type.Bundle and ItemConfigProxy:CheckItemTreasureBox(item) then
                if not CheckGoldBoxCanUse() then
                    ShowSystemTips("该系统正在使用中..")
                    return
                end
                local data = {
                    storage = {
                        MakeIndex = MakeIndex,
                        state = 0
                    }
                }
                global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
                global.Facade:sendNotification(global.NoticeTable.Layer_Treasure_Box_Open,item)
                return
            end
            
            LuaSendMsg( global.MsgType.MSG_CS_USE_BAG_ITEM, MakeIndex, 1 , 0, 0, Name , string.len(Name) )
        end
    elseif itemType == Item_Type.SkillBook then
        local function callback(atype,aData)
            if atype == 1 then
                local Name       = item.Name
                local MakeIndex = item.MakeIndex
                LuaSendMsg( global.MsgType.MSG_CS_USE_BAG_ITEM, MakeIndex, 0 , 0, 0, Name , string.len(Name) )
            end
        end
        local data = {}
        data.str = string.format(GET_STRING(90020001), item.Name)
        data.callback = callback
        data.btnType = 2
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
    elseif itemType == Item_Type.Equip then
        local Name      = item.Name
        local MakeIndex = item.MakeIndex

        local targetPos = nil
        -- 是否有找到合适的位置 战力对比
        local comparison = ItemConfigProxy:GetItemComparison(item.Index) 
        local myPower, powerSortIndex = GUIFunction:GetEquipPower(item, {jobPower = true})
        local param = {jobPower = true, power = myPower, comparison = comparison, powerSortIndex = powerSortIndex}
        local excludePos = GUIFunction:CheckEquipExcludePos(item)
        local minPowerPos, onEquipMinPower, hasEquip = GUIFunction:GetMinPowerPosByStdMode(item.StdMode, param, nil, false, excludePos)
        if minPowerPos >= 0 and (not hasEquip or onEquipMinPower < myPower) then
            targetPos = minPowerPos
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_Auto_Use_UnAttach, {id = MakeIndex})

        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local canUseBuJuk, pos = EquipProxy:CheckBujukUse(item, targetPos)
        if pos then
            targetPos = pos
        else
            if not canUseBuJuk then 
                return false
            end
        end

        local noticeName = global.NoticeTable.TakeOnRequest
        global.Facade:sendNotification(noticeName,
            {
                itemData = item,
                pos = targetPos
            }
        )
    end

    global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_USE_ITEM, param = item})
end

function ItemUseProxy:HeroUseItem(item, autoUse)
    if not item or next(item) == nil then
        return
    end

    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local canUse, strList, notCheckUse = CheckItemUseNeed_Hero(item)
    if not canUse and not notCheckUse then
        for i,v in ipairs(strList) do
            if not v.can and not notCheckUse then
                local color = GUIFunction:ItemUseConditionColor(v.can)
                local conditionStr = string.format(GET_STRING(80049997), color, v.str)
                global.Facade:sendNotification(global.NoticeTable.SystemTips, conditionStr)
                break
            end
        end
        return
    end

    local isUseCd = self:CheckIsCD_Hero(item.Index)
    if isUseCd then
        return
    end

    if not self:CheckSpecialUseCondition(item) then
        return
    end

    if item.StdMode == 2 or item.StdMode == 3 then
        local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        local itemUseCd =  MapProxy:GetEatItemSpeed() or 500
        self:IntoCD_Hero(item.Index, itemUseCd)
    end

    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    
    local Item_Type = ItemManagerProxy:GetItemSettingType()
    local itemType = ItemManagerProxy:GetItemType(item)

    if item.StdMode == 96 then
        itemType = Item_Type.WishBox
    end
    if itemType == Item_Type.DruaAndSomething
        or itemType == Item_Type.Bundle
        or itemType == Item_Type.Box
        or itemType == Item_Type.TreasureMap
        or itemType == Item_Type.FashionItem
        or itemType == Item_Type.MonsterCard
        or itemType == Item_Type.SomethingCanUse
        or itemType == Item_Type.WishBox 
        or itemType == Item_Type.Collimator then
        -- self:handleItem(item)

        local Name       = item.Name
        local MakeIndex = item.MakeIndex
        if item.StdMode == 200 and item.Shape == 0 and (ItemConfigProxy:CheckItemOverLap(item) or ItemConfigProxy:CheckItemBatch(item)) then
            if item.StdMode == 200 and item.Shape == 0 then
                autoUse = true
            end
            if autoUse then -- 自动使用 用全部
                local autoUseNumber = item.OverLap > 1 and item.OverLap or 1
                LuaSendMsg( global.MsgType.MSG_CS_USE_BAG_ITEM_HERO, MakeIndex, autoUseNumber , 0, 0, Name , string.len(Name) )
            else
                -- 叠加道具批量使用
                local function callback(btnType, data)
                    if data.editStr and data.editStr ~= "" then
                        if type(data.editStr) == "string" then
                            local num  = tonumber(data.editStr)
                            if not num or num > item.OverLap or num <= 0 then
                                global.Facade:sendNotification( global.NoticeTable.SystemTips, GET_STRING( 90020007 ) )
                                return
                            end
                            LuaSendMsg( global.MsgType.MSG_CS_USE_BAG_ITEM_HERO, MakeIndex, num , 0, 0, Name , string.len(Name) )
                        end
                    end
                end
                local data = {}
                data.str = GET_STRING(90020006)
                data.callback = callback
                data.btnType = 2
                data.showEdit = true
                data.editParams = {
                    inputMode = 2,
                    str = item.OverLap
                }
                global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
            end
        else
            if itemType == Item_Type.Bundle and ItemConfigProxy:CheckItemTreasureBox(item) then
                local data = {
                    storage = {
                        MakeIndex = MakeIndex,
                        state = 0
                    }
                }
                global.Facade:sendNotification(global.NoticeTable.HeroBag_State_Change, data)
                global.Facade:sendNotification(global.NoticeTable.Layer_Treasure_Box_Open,item)
                return
            end
            
            LuaSendMsg( global.MsgType.MSG_CS_USE_BAG_ITEM_HERO, MakeIndex, 1 , 0, 0, Name , string.len(Name) )
        end
    elseif itemType == Item_Type.SkillBook then
        local function callback(atype,aData)
            if atype == 1 then
                local Name       = item.Name
                local MakeIndex = item.MakeIndex
                LuaSendMsg( global.MsgType.MSG_CS_USE_BAG_ITEM_HERO, MakeIndex, 0 , 0, 0, Name , string.len(Name) )
            end
        end
        local data = {}
        data.str = string.format(GET_STRING(90020001), item.Name)
        data.callback = callback
        data.btnType = 2
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
    elseif itemType == Item_Type.Equip then
        local Name       = item.Name
        local MakeIndex = item.MakeIndex

        local targetPos = nil
        -- 是否有找到合适的位置 战力对比
        local comparison = ItemConfigProxy:GetItemComparison(item.Index) 
        local myPower,powerSortIndex = GUIFunction:GetEquipPower(item, {jobPower = true}, true)
        local param = {jobPower = true, power = myPower, comparison = comparison, powerSortIndex = powerSortIndex}
        local excludePos = GUIFunction:CheckEquipExcludePos(item)
        local minPowerPos, onEquipMinPower, hasEquip = GUIFunction:GetMinPowerPosByStdMode(item.StdMode, param, nil, true, excludePos)

        if minPowerPos >= 0 and (not hasEquip or onEquipMinPower < myPower) then
            targetPos = minPowerPos
        end

        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy) 
        local canUseBuJuk, pos = EquipProxy:CheckBujukUse(item, targetPos)
        if pos then
            targetPos = pos
        else
            if not canUseBuJuk then 
                return false
            end
        end

        local noticeName = global.NoticeTable.HeroTakeOnRequest 
        global.Facade:sendNotification(noticeName,
            {
                itemData = item,
                pos = targetPos
            }
        )
    end

    global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_USE_ITEM, param = item})
end

function ItemUseProxy:handleItem(item)

    ---随机卷轴
    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    local autoProxy = global.Facade:retrieveProxy( global.ProxyTable.Auto )
    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    if ItemManagerProxy:IsRandStone(item) then
        autoProxy:SetRandStoneAFKFlag(true)
    end
end

function ItemUseProxy:CheckSpecialUseCondition(item)
    if not item or not next(item) then
        return
    end

    return true
end

function ItemUseProxy:IntoCD( index ,times)
    local cdtimes = times or 500 

    if next(self.itemCD) and self.itemUseCountdown > 0 then
        cdtimes = math.max(cdtimes - (math.floor(socket.gettime() * 1000) - self.itemUseCountdown), 0)
    end

    self.itemUseCountdown = math.floor(socket.gettime() * 1000)

    self.itemCD[index] = true
    PerformWithDelayGlobal(function()
        self.itemUseCountdown = 0
        self.itemCD[index] = false
    end, cdtimes/1000)
end

function ItemUseProxy:CheckIsCD( index )
    return self.itemCD[index]
end

function ItemUseProxy:IntoCD_Hero( index ,times)
    local cdtimes = times or 500 

    if next(self.itemCD_Hero) and self.itemUseCountdown_Hero > 0 then
        cdtimes = math.max(cdtimes - (math.floor(socket.gettime() * 1000) - self.itemUseCountdown_Hero), 0)
    end

    self.itemUseCountdown_Hero = math.floor(socket.gettime() * 1000)

    self.itemCD_Hero[index] = true
    PerformWithDelayGlobal(function()
        self.itemUseCountdown_Hero = 0
        self.itemCD_Hero[index] = false
    end, cdtimes/1000)
end

function ItemUseProxy:CheckIsCD_Hero( index )
    return self.itemCD_Hero[index]
end
function ItemUseProxy:onRegister()
    ItemUseProxy.super.onRegister(self)
end

return ItemUseProxy