local RemoteProxy = requireProxy("remote/RemoteProxy")
local ItemManagerProxy = class("ItemManagerProxy", RemoteProxy)
ItemManagerProxy.NAME = global.ProxyTable.ItemManagerProxy

--README: 储存下道具来源，道具归属等信息

ItemManagerProxy.ItemType = {
    DruaAndSomething = 1, 		-- 道具表 StdMode 0~3 的道具
    SkillBook 		 = 2, 		-- 技能书
    Equip 			 = 3, 		-- 装备
    Bundle 			 = 4, 		-- 困束
    Box 			 = 5, 		-- 盒子
    TreasureMap 	 = 6, 		-- StdMode 为 101 的道具
    FashionItem 	 = 7, 		-- 时装道具
    MonsterCard 	 = 8, 		-- 怪物卡片
    SomethingCanUse  = 9, 		-- StdMode 为 49 的道具
    BoxKey 			 = 10, 		-- 箱子钥匙
    Collimator       = 11, 		-- 准星道具
    WishBox 		 = 12, 		-- StdMode 为 96 的道具
    NewPet 			 = 13, 		-- 宠物系统，道具使用
    Other 			 = 99 		-- 其他
}

function ItemManagerProxy:ctor()
    ItemManagerProxy.super.ctor(self)
    self.itemDataFrom = {}
end

function ItemManagerProxy:GetItemSettingType()
    return clone(self.ItemType)
end

function ItemManagerProxy:SetItemBelong(MakeIndex, from)
    self.itemDataFrom[MakeIndex] = from
end

function ItemManagerProxy:GetItemBelong(MakeIndex)
    return self.itemDataFrom[MakeIndex]
end

function ItemManagerProxy:CleanItemBelongs()
    self.itemDataFrom = {}
end

function ItemManagerProxy:GetItemTypeByStdMode(stdMode)
    local AttrConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.AttrConfigProxy)
    local equipMap = AttrConfigProxy:GetItemsConfigEquipMapByStdMode()
    local stdMode = stdMode or 0
    local type = self.ItemType.Other
    if stdMode >= 0 and stdMode <= 3 then
        type = self.ItemType.DruaAndSomething
    elseif stdMode == 4 then
        type = self.ItemType.SkillBook
    elseif equipMap[stdMode] or stdMode == 25 then --特殊 护身符
        type = self.ItemType.Equip
    elseif stdMode == 31 then -- 困 束
        type = self.ItemType.Bundle
    elseif stdMode == 200 then -- 盒子
        type = self.ItemType.Box
    elseif stdMode == 101 then
        type = self.ItemType.TreasureMap
    elseif stdMode == 102 then
        type = self.ItemType.FashionItem
    elseif stdMode == 103 then
        type = self.ItemType.MonsterCard
    elseif stdMode == 49 then
        type = self.ItemType.SomethingCanUse
    elseif stdMode == 40 then
        type = self.ItemType.BoxKey
    elseif stdMode == 47 then --准星道具
        type = self.ItemType.Collimator
    elseif stdMode == 201 then --新宠物系统
        type = self.ItemType.NewPet
    end
    return type
end

function ItemManagerProxy:IsBestRings(item)
    return item.StdMode > 99 and item.StdMode < 112
end

function ItemManagerProxy:IsCityStoneByIndex(Index)
    for k, v in pairs(SL:GetMetaValue("GAME_DATA","cityStone")) do
        if v == Index then
            return true
        end
    end
    return false
end

function ItemManagerProxy:IsRandStoneByIndex(Index)
    for k, v in pairs(SL:GetMetaValue("GAME_DATA","randStone")) do
        if v == Index then
            return true
        end
    end
    return false
end

function ItemManagerProxy:IsCityStone(item)
    if item and next(item) then
        for k, v in pairs(SL:GetMetaValue("GAME_DATA","cityStone")) do
            if v == item.Index then
                return true
            end
        end
    end
    return false
end

function ItemManagerProxy:IsRandStone(item)
    if item and next(item) then
        for k, v in pairs(SL:GetMetaValue("GAME_DATA","randStone")) do
            if v == item.Index then
                return true
            end
        end
    end
    return false
end

--是否是时装道具
function ItemManagerProxy:IsFashionEquip(item)
    if item and item.StdMode then
        local fashionStdMode = {[66] = true, [67] = true, [68] = true, [69] = true}
        if fashionStdMode[item.StdMode] then
            return true
        end
    end
    return false
end

function ItemManagerProxy:GetItemType(item)
    if not item or not next(item) then
        return self.ItemType.Other
    end
    local type = self:GetItemTypeByStdMode(item.StdMode)
    return type
end

function ItemManagerProxy:RemoveItems(itemList)
    if not itemList or next(itemList) == nil then
        return
    end
    for _, MakeIndex in pairs(itemList) do
        local itemBelong = self:GetItemBelong(MakeIndex)
        if not itemBelong then
            return
        end

        if itemBelong == global.MMO.ITEM_FROM_BELONG_BAG then
            local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
            local itemData = BagProxy:GetItemDataByMakeIndex(MakeIndex)
            if itemData then
                BagProxy:DelItemData(itemData, true)
            end
        elseif itemBelong == global.MMO.ITEM_FROM_BELONG_EQUIP then
            local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
            local itemData = EquipProxy:GetEquipDataByMakeIndex(MakeIndex)
            if itemData then
                EquipProxy:DelEquipData(itemData)
            end
        elseif itemBelong == global.MMO.ITEM_FROM_BELONG_QUICKUSE then
            local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
            local pos = QuickUseProxy:GetQucikUsePosByMakeIndex(MakeIndex)
            local itemData = QuickUseProxy:GetQucikUseDataByMakeIndex(MakeIndex)
            if pos and itemData then
                local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
                BagProxy:ShowGetOrCostItems(-(itemData.OverLap or 1), itemData.Name)
                QuickUseProxy:SetQuickUsePosData(pos, itemData, true)
            end
        elseif itemBelong == global.MMO.ITEM_FROM_BELONG_HEROBAG then
            local HeroBagProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
            local itemData = HeroBagProxy:GetItemDataByMakeIndex(MakeIndex)
            if itemData then
                HeroBagProxy:DelItemData(itemData, true)
            end
        elseif itemBelong == global.MMO.ITEM_FROM_BELONG_HEROEQUIP then
            local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
            local itemData = HeroEquipProxy:GetEquipDataByMakeIndex(MakeIndex)
            if itemData then
                HeroEquipProxy:DelEquipData(itemData)
            end
        end
    end
end

function ItemManagerProxy:GetItemDataByMakeIndex(MakeIndex)
    local itemData = nil
    if MakeIndex then
        local itemBelong = self:GetItemBelong(MakeIndex)
        if itemBelong then
            if itemBelong == global.MMO.ITEM_FROM_BELONG_BAG then
                local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
                itemData = BagProxy:GetItemDataByMakeIndex(MakeIndex)
            elseif itemBelong == global.MMO.ITEM_FROM_BELONG_EQUIP then
                local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
                itemData = EquipProxy:GetEquipDataByMakeIndex(MakeIndex)
            elseif itemBelong == global.MMO.ITEM_FROM_BELONG_QUICKUSE then
                local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
                itemData = QuickUseProxy:GetQucikUseDataByMakeIndex(MakeIndex)
            elseif itemBelong == global.MMO.ITEM_FROM_BELONG_HEROBAG then
                local HeroBagProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
                itemData = HeroBagProxy:GetItemDataByMakeIndex(MakeIndex)
            elseif itemBelong == global.MMO.ITEM_FROM_BELONG_HEROEQUIP then
                local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
                itemData = HeroEquipProxy:GetEquipDataByMakeIndex(MakeIndex)
            end
        end
    end
    return itemData
end

function ItemManagerProxy:onRegister()
    ItemManagerProxy.super.onRegister(self)
end

return ItemManagerProxy
