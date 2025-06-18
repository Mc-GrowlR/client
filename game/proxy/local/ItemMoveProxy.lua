local RemoteProxy = requireProxy("remote/RemoteProxy")
local ItemMoveProxy = class("ItemMoveProxy", RemoteProxy)
ItemMoveProxy.NAME = global.ProxyTable.ItemMoveProxy

ItemMoveProxy.ItemFrom = {
    BAG = 1,                -- 背包
    PALYER_EQUIP = 2,       -- 玩家身上
    QUICK_USE = 3,          -- 快捷栏
    STORAGE = 4,            -- 仓库
    BAG_GOLD = 5,           -- 背包金币
    SELL = 6,               -- 摆摊
    REPAIRE = 7,            -- npc商店
    TRADE = 8,              -- 面对面交易
    TRADE_GOLD = 10,        -- 交易
    BEST_RINGS = 11,        -- 极品首饰
    AUTO_TRADE = 12,        -- 摆摊
    ITEMBOX    = 13,        -- 自定义UI ITEMBOX
    NPC_DO_SOMETHING = 14,  -- NPC自定义放入框
    NEWTYPE = 15,
    HERO_BAG = 66,          --英雄背包
    HERO_EQUIP = 67,        -- 英雄装备
    HERO_BEST_RINGS = 68,   -- 英雄极品首饰
    SSR_ITEM_BOX    = 77,   -- ssr 自定义ItemBox
    PETS_EQUIP    = 78,     -- 宠物装备
    SKILL_WIN    = 79,      -- PC 技能
    OTHER = 99              -- 其他
}

ItemMoveProxy.ItemGoTo = {
    BAG = 1,
    PALYER_EQUIP = 2,
    QUICK_USE = 3,
    STORAGE = 4,
    SELL = 5,
    DROP = 6,
    REPAIRE = 7,
    TRADE = 8,
    TRADE_GOLD = 10,
    BAG_GOLD = 11, --背包金币
    BEST_RINGS = 12, -- 极品首饰
    AUTO_TRADE = 13, -- 摆摊
    ITEMBOX    = 14, -- 自定义UI ITEMBOX
    NPC_DO_SOMETHING = 15, -- NPC自定义放入框
    TreasureBox = 16,
    NEWTYPE    = 17,
    HERO_BAG    = 66, --英雄背包
    HERO_EQUIP = 67, -- 英雄装备
    HERO_BEST_RINGS = 68, -- 英雄极品首饰
    SSR_ITEM_BOX    = 77, -- ssr 自定义ItemBox
    TOPUI        = 78,    
}

function ItemMoveProxy:ctor()
    ItemMoveProxy.super.ctor(self)
    self.onMovingItem = nil
    self.onMoving = false
    self.movingItemFrom = nil
    self.linkFunc = nil
    self.onMovingSkill = nil
    self._guiTypeNum = 0
end

function ItemMoveProxy:DropItem(data)
    local item = data.itemData
    --   背包 -> 地面
    if not item or next(item) == nil then
        return true
    end
    global.Facade:sendNotification(global.NoticeTable.IntoDropItem, item)
    return false
end
function ItemMoveProxy:DropItem_Hero(data)
    local item = data.itemData
    --   英雄背包 -> 地面
    if not item or next(item) == nil then
        return true
    end
    global.Facade:sendNotification(global.NoticeTable.IntoDropItem_Hero, item)
    return false
end

function ItemMoveProxy:DropGold(data)
    -- 丢弃金币 背包金币 -> 地面
    local function callback(btnType, data)
        local bagState = {
            goldState = 1
        }
        global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, bagState)
        if data.editStr and data.editStr ~= "" then
            if type(data.editStr) == "string" then
                local num = tonumber(data.editStr)
                LuaSendMsg(global.MsgType.MSG_CS_MAP_GOOD_DISCARD, num, 0, 0, 0, 0, 0)
            end
        end
    end
    local data = {}
    data.str = GET_STRING(90020002)
    data.callback = callback
    data.btnType = 1
    data.showEdit = true
    data.editParams = {
        inputMode = 2
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

function ItemMoveProxy:ChangeItemPos(data)
    -- 道具换位 背包 -> 背包
    local itemData = data.itemData
    local pos = data.pos
    local targetPosInBag = data.itemPosInbag --点击到的位置
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local posMakeIndexInbag = BagProxy:GetMakeIndexByBagPos(targetPosInBag)
    local beginPos = BagProxy:GetBagPosByMakeIndex(itemData.MakeIndex)
    local posDataInBag = BagProxy:GetItemDataByMakeIndex(posMakeIndexInbag)
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    if posMakeIndexInbag then
        if posMakeIndexInbag == itemData.MakeIndex then --不变
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        elseif posDataInBag and posDataInBag.Index == itemData.Index and ItemConfigProxy:CheckItemOverLapById(itemData.Index) then
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
            BagProxy:RequestItemTwoToOne(posMakeIndexInbag, itemData.MakeIndex)
            return true
        else --换位
            -- 先结束事件
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
            BagProxy:ExchangePos(itemData.MakeIndex, targetPosInBag, posMakeIndexInbag, beginPos)

            if global.isWinPlayMode then
                global.Facade:sendNotification(global.NoticeTable.Item_Move_begin_On_BagPosChang,
                {
                    MakeIndex = posMakeIndexInbag,
                    pos = pos
                }
                )
                return true
            end
        end
    else --移动
        -- 先结束事件
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
        -- 再发刷新
        BagProxy:SetItemPosData(itemData.MakeIndex, targetPosInBag)
        return true
    end
end
function ItemMoveProxy:ChangeItemPos_Hero(data)
    -- 道具换位 背包 -> 背包
    local itemData = data.itemData
    local pos = data.pos
    local targetPosInBag = data.itemPosInbag --点击到的位置
    local HeroBagProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
    local posMakeIndexInbag = HeroBagProxy:GetMakeIndexByBagPos(targetPosInBag)
    local beginPos = HeroBagProxy:GetBagPosByMakeIndex(itemData.MakeIndex)
    local posDataInBag = HeroBagProxy:GetItemDataByMakeIndex(posMakeIndexInbag)
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    if posMakeIndexInbag then
        if posMakeIndexInbag == itemData.MakeIndex then --不变
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        elseif posDataInBag and posDataInBag.Index == itemData.Index and ItemConfigProxy:CheckItemOverLapById(itemData.Index) then
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
            HeroBagProxy:RequestItemTwoToOne(posMakeIndexInbag, itemData.MakeIndex)
            return true
        else --换位
            -- 先结束事件
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
            HeroBagProxy:ExchangePos(itemData.MakeIndex, targetPosInBag, posMakeIndexInbag, beginPos)

            if global.isWinPlayMode then
                global.Facade:sendNotification(global.NoticeTable.Item_Move_begin_On_HeroBagPosChang,
                {
                    MakeIndex = posMakeIndexInbag,
                    pos = pos
                }
                )
                return true
            end
        end
    else --移动
        -- 先结束事件
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
        -- 再发刷新
        HeroBagProxy:SetItemPosData(itemData.MakeIndex, targetPosInBag)
        return true
    end
end
function ItemMoveProxy:PutItemInTreasureBox(data)
    -- 道具换位 背包 -> 宝箱
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)

    local layer = data.boxLayer
    local itemData = data.itemData
    local boxData = data.boxData
    local MakeIndex = itemData.MakeIndex
    local boxMakeIndex = boxData.MakeIndex
    if ItemConfigProxy:CheckItemTreasureBoxKey(itemData) then
        if MakeIndex and boxMakeIndex and itemData.Shape == boxData.Shape then
            LuaSendMsg(global.MsgType.MSG_SC_OPEN_TREASUREBOX, boxMakeIndex, MakeIndex)
            layer:setTouchEnabled(false)
        end
    end
end

function ItemMoveProxy:AddToQuickUse(data)
    -- 道具换位 背包 -> 快捷使用栏
    -- PC端将来自背包道具加入快捷栏 如果目标位置有道具则将该道具加入移动 该道具归属改变为来自背包
    -- 移动端 将道具加入快捷栏 如果快捷栏有道具 则将该道具移动到背包 不加入移动
    local itemData = data.itemData
    local pos = data.pos
    local posInQuickUse = data.posInQuickUse
    local AttrConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.AttrConfigProxy)
    local canPutInList = AttrConfigProxy:GetItemsConfigQuickUsable()

    if not posInQuickUse
    or posInQuickUse <= 0
    or posInQuickUse > global.MMO.QUICK_USE_SIZE
    or not canPutInList[itemData.StdMode] then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return true
    end

    -- 先结束事件
    global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)

    local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local posData = QuickUseProxy:GetQucikUseDataByPos(posInQuickUse)
    -- 从背包移出
    BagProxy:DelItemData(itemData)

    if posData then --替换
        -- 置空
        QuickUseProxy:SetQuickUsePosData(posInQuickUse, posData, true)
        -- 加入背包
        BagProxy:AddItemDataAndNotice(posData)
        -- PC 将背包的该道具加入移动
        if global.isWinPlayMode then
            global.Facade:sendNotification(global.NoticeTable.Item_Move_begin_On_BagPosChang,
            {
                MakeIndex = posData.MakeIndex,
                pos = pos
            }
            )
        end
    end
    -- 加入快捷栏
    QuickUseProxy:SetQuickUsePosData(posInQuickUse, itemData)
    return true
end
function ItemMoveProxy:AddToQuickUse_FromHeroBag(data)
    -- 道具换位 背包 -> 快捷使用栏
    -- PC端将来自背包道具加入快捷栏 如果目标位置有道具则将该道具加入移动 该道具归属改变为来自背包
    -- 移动端 将道具加入快捷栏 如果快捷栏有道具 则将该道具移动到背包 不加入移动
    local itemData = data.itemData
    local pos = data.pos
    local posInQuickUse = data.posInQuickUse
    local AttrConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.AttrConfigProxy)
    local canPutInList = AttrConfigProxy:GetItemsConfigQuickUsable()

    if not posInQuickUse
    or posInQuickUse <= 0
    or posInQuickUse > global.MMO.QUICK_USE_SIZE
    or not canPutInList[itemData.StdMode] then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return true
    end

    -- 先结束事件
    global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)

    local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
    local posData = QuickUseProxy:GetQucikUseDataByPos(posInQuickUse)
    -- 从背包移出
    BagProxy:DelItemData(itemData)

    if posData then --替换
        -- 置空
        QuickUseProxy:SetQuickUsePosData(posInQuickUse, posData, true)
        -- 加入背包
        BagProxy:AddItemDataAndNotice(posData)
        -- PC 将背包的该道具加入移动
        if global.isWinPlayMode then
            global.Facade:sendNotification(global.NoticeTable.Item_Move_begin_On_BagPosChang,
            {
                MakeIndex = posData.MakeIndex,
                pos = pos
            }
            )
        end
    end
    -- 加入快捷栏
    QuickUseProxy:SetQuickUsePosData(posInQuickUse, itemData)
    return true
end
function ItemMoveProxy:ChangeItemPosQuickUse(data)
    -- 道具换位 快捷栏 -> 快捷栏
    -- 换位  移动端直接换位
    -- PC端将目标位置的道具加入移动 来源位置为原移动道具位置
    local itemData = data.itemData
    local pos = data.pos
    local MakeIndex = itemData.MakeIndex
    local targetPos = data.posInQuickUse
    local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
    local myOldPos = QuickUseProxy:GetQucikUsePosByMakeIndex(MakeIndex)
    local targetItemData = QuickUseProxy:GetQucikUseDataByPos(targetPos)
    -- 清空原位置数据
    QuickUseProxy:SetQuickUsePosData(myOldPos, itemData, true)
    -- 清空目标位置数据
    if targetItemData then
        QuickUseProxy:SetQuickUsePosData(targetPos, targetItemData, true)
    end
    -- 目标位置数据加入
    QuickUseProxy:SetQuickUsePosData(targetPos, itemData)
    -- 原位置数据加入
    if targetItemData then
        QuickUseProxy:SetQuickUsePosData(myOldPos, targetItemData)
    end
    -- TODO: PC 端 将新创建节点的信息加入移动
    if global.isWinPlayMode then

    end
end

function ItemMoveProxy:DeleteQuickUse(data)
    -- 道具换位 快捷栏 -> 背包
    -- 如果背包格子满了 取消
    local itemData = data.itemData
    local MakeIndex = itemData.MakeIndex
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
    local isFull = BagProxy:isToBeFull()
    if isFull then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return true
    else
        -- 先结束事件
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
        -- 从快捷栏移出
        local pos = QuickUseProxy:GetQucikUsePosByMakeIndex(MakeIndex)
        QuickUseProxy:SetQuickUsePosData(pos, itemData, true)
        -- 加入背包
        BagProxy:AddItemDataAndNotice(itemData)
        return true
    end
end
function ItemMoveProxy:DeleteQuickUse_ToHeroBag(data)
    -- 道具换位 快捷栏 -> 英雄背包
    -- 如果背包格子满了 取消
    local itemData = data.itemData
    local MakeIndex = itemData.MakeIndex
    local HeroBagProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
    local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
    local isFull = HeroBagProxy:isToBeFull()
    if isFull then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return true
    else
        -- 先结束事件
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
        -- 从快捷栏移出
        local pos = QuickUseProxy:GetQucikUsePosByMakeIndex(MakeIndex)
        QuickUseProxy:SetQuickUsePosData(pos, itemData, true)
        -- 加入背包
        HeroBagProxy:RequestHumBagToHeroBag(data.itemData.MakeIndex, data.itemData.Name)
        return true
    end
end

function ItemMoveProxy:TakeOnBestRing(data)
    -- 装备 背包 -> 主角装备
    local itemData = data.itemData
    local pos = data.pos
    local equipPos = data.equipPos
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local list = EquipProxy:GetEquipPosByStdModeList(itemData.StdMode)
    if not list or not next(list) then
        if not global.isWinPlayMode then
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        end
        return true
    end
    global.Facade:sendNotification(global.NoticeTable.TakeOnRequest,
    {
        itemData = itemData,
        pos = equipPos
    }
    )
    return false

end
function ItemMoveProxy:TakeOnBestRing_Hero( data )
    -- 装备 背包 -> 主角装备
    local itemData = data.itemData
    local pos = data.pos
    local equipPos = data.equipPos
    local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
    local list = HeroEquipProxy:GetEquipPosByStdModeList(itemData.StdMode)
    if not list or not next(list) then
        if not global.isWinPlayMode then
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        end
        return true
    end
    global.Facade:sendNotification(global.NoticeTable.HeroTakeOnRequest,
    {
        itemData = itemData,
        pos = equipPos
    }
    )
    return false

end
function ItemMoveProxy:TakeOnItem_Hero( data )
    -- 装备 背包 -> 主角装备
    local itemData = data.itemData
    local pos = data.pos
    local equipPos = data.equipPos
    local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)

    if equipPos == HeroEquipProxy:GetEquipTypeConfig().Equip_Type_Bujuk then
        local posItemData = HeroEquipProxy:GetEquipDataByPos(equipPos)
        if posItemData and posItemData.StdMode == 96 then
            local targetShape = posItemData.Shape
            local myAniCount = itemData.AniCount
            if itemData and itemData.StdMode == 3 and itemData.Shape == 4 and targetShape and myAniCount and targetShape == myAniCount then
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)

                LuaSendMsg(global.MsgType.MSG_CS_ITEM_FIX_ITEMS, itemData.MakeIndex, posItemData.MakeIndex, 0, 0)
                return true
            end
        end
    end

    local list = HeroEquipProxy:GetEquipPosByStdModeList(itemData.StdMode)
    if not list or not next(list) then
        if not global.isWinPlayMode then
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        end
        return true
    end
    local equipPosList = HeroEquipProxy:GetEquipMappingConfig(equipPos)
    equipPosList = equipPosList or { equipPos }
    for k, v in pairs(list) do
        for _, equipPosition in ipairs(equipPosList) do -- 头部位置 显示上只有头 实际穿了头和斗笠两个位置
            if v == equipPosition then
                global.Facade:sendNotification(global.NoticeTable.HeroTakeOnRequest,
                {
                    itemData = itemData,
                    pos = equipPosition
                }
                )
                return false
            end
        end
    end
    if not global.isWinPlayMode then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
    end
    return true
end
function ItemMoveProxy:TakeOnItem_Hero_FromHumBag(data)
    -- 人物背包 -> 英雄装备
    dump(data,"TakeOnItem_Hero_FromHumBag_____")
    local itemData = data.itemData
    local pos = data.pos
    local equipPos = data.equipPos
    local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)

    if equipPos == HeroEquipProxy:GetEquipTypeConfig().Equip_Type_Bujuk then
        local posItemData = HeroEquipProxy:GetEquipDataByPos(equipPos)
        if posItemData and posItemData.StdMode == 96 then
            local targetShape = posItemData.Shape
            local myAniCount = itemData.AniCount
            if itemData and itemData.StdMode == 3 and itemData.Shape == 4 and targetShape and myAniCount and targetShape == myAniCount then
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)

                LuaSendMsg(global.MsgType.MSG_CS_ITEM_FIX_ITEMS, itemData.MakeIndex, posItemData.MakeIndex, 0, 0)
                return true
            end
        end
    end

    local list = HeroEquipProxy:GetEquipPosByStdModeList(itemData.StdMode)
    if not list or not next(list) then
        if not global.isWinPlayMode then
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        end
        return true
    end
    local equipPosList = HeroEquipProxy:GetEquipMappingConfig(equipPos)
    equipPosList = equipPosList or { equipPos }
    for k, v in pairs(list) do
        for _, equipPosition in ipairs(equipPosList) do -- 头部位置 显示上只有头 实际穿了头和斗笠两个位置
            if v == equipPosition then
                global.Facade:sendNotification(global.NoticeTable.HeroTakeOnRequestFromHumBag,
                {
                    itemData = itemData,
                    pos = equipPosition
                }
                )
                return false
            end
        end
    end
    if not global.isWinPlayMode then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
    end
    return true
end


function ItemMoveProxy:TakeOnItem_FromHeroBag(data)
    --  英雄背包 -> 主角装备
    local itemData = data.itemData
    local pos = data.pos
    local equipPos = data.equipPos
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)

    if equipPos == EquipProxy:GetEquipTypeConfig().Equip_Type_Bujuk then
        local posItemData = EquipProxy:GetEquipDataByPos(equipPos)
        if posItemData and posItemData.StdMode == 96 then
            local targetShape = posItemData.Shape
            local myAniCount = itemData.AniCount
            if itemData and itemData.StdMode == 3 and itemData.Shape == 4 and targetShape and myAniCount and targetShape == myAniCount then
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)

                LuaSendMsg(global.MsgType.MSG_CS_ITEM_FIX_ITEMS, itemData.MakeIndex, posItemData.MakeIndex, 0, 0)
                return true
            end
        end
    end

    local list = EquipProxy:GetEquipPosByStdModeList(itemData.StdMode)
    if not list or not next(list) then
        if not global.isWinPlayMode then
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        end
        return true
    end
    local equipPosList = EquipProxy:GetEquipMappingConfig(equipPos)
    equipPosList = equipPosList or { equipPos }
    for k, v in pairs(list) do
        for _, equipPosition in ipairs(equipPosList) do -- 头部位置 显示上只有头 实际穿了头和斗笠两个位置
            if v == equipPosition then
                global.Facade:sendNotification(global.NoticeTable.TakeOnRequestFromHeroBag,
                {
                    itemData = itemData,
                    pos = equipPosition
                }
                )
                return false
            end
        end
    end
    if not global.isWinPlayMode then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
    end
    return true
end
function ItemMoveProxy:TakeOnItem(data)
    -- 装备 背包 -> 主角装备
    local itemData = data.itemData
    local pos = data.pos
    local equipPos = data.equipPos
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)

    if equipPos == EquipProxy:GetEquipTypeConfig().Equip_Type_Bujuk then
        local posItemData = EquipProxy:GetEquipDataByPos(equipPos)
        if posItemData and posItemData.StdMode == 96 then
            local targetShape = posItemData.Shape
            local myAniCount = itemData.AniCount
            if itemData and itemData.StdMode == 3 and itemData.Shape == 4 and targetShape and myAniCount and targetShape == myAniCount then
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)

                LuaSendMsg(global.MsgType.MSG_CS_ITEM_FIX_ITEMS, itemData.MakeIndex, posItemData.MakeIndex, 0, 0)
                return true
            end
        end
    end

    local list = EquipProxy:GetEquipPosByStdModeList(itemData.StdMode)
    if not list or not next(list) then
        if not global.isWinPlayMode then
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        end
        return true
    end
    local equipPosList = EquipProxy:GetEquipMappingConfig(equipPos)
    equipPosList = equipPosList or { equipPos }
    for k, v in pairs(list) do
        for _, equipPosition in ipairs(equipPosList) do -- 头部位置 显示上只有头 实际穿了头和斗笠两个位置
            if v == equipPosition then
                global.Facade:sendNotification(global.NoticeTable.TakeOnRequest,
                {
                    itemData = itemData,
                    pos = equipPosition
                }
                )
                return false
            end
        end
    end
    if not global.isWinPlayMode then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
    end
    return true
end
--CancelMove_Hero
function ItemMoveProxy:CancelHeroEquipMove_Hero(data)
    -- local itemData = data.itemData
    -- local pos = data.pos
    -- local HeroEquipProxy = global.Facade:retrieveProxy( global.ProxyTable.HeroEquipProxy )
    -- local MakeIndex = itemData.MakeIndex
    -- local equipItemData = HeroEquipProxy:GetEquipDataByMakeIndex(MakeIndex)
    -- -- 在拖动或者其他延时操作时，被自动穿戴替换道具，此时的异常处理
    -- if  equipItemData then
    global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
    -- end
    return true
end

function ItemMoveProxy:TakeOffEquip_Hero(data)
    -- 脱下装备  英雄装备栏 -> 英雄背包
    dump(data,"TakeOffEquip_Hero___")
    local itemData = data.itemData
    local pos = data.pos
    local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
    local MakeIndex = itemData.MakeIndex
    local equipItemData = HeroEquipProxy:GetEquipDataByMakeIndex(MakeIndex)
    -- 在拖动或者其他延时操作时，被自动穿戴替换道具，此时的异常处理
    if not equipItemData then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return
    end

    global.Facade:sendNotification(global.NoticeTable.HeroTakeOffRequest, itemData)
end

function ItemMoveProxy:TakeOffEquip_Hero_To_HumBag(data)
    -- 脱下装备  英雄装备栏 -> 人物背包
    dump(data, "TakeOffEquip_Hero__to_HumBag")
    local itemData = data.itemData
    local pos = data.pos
    local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
    local MakeIndex = itemData.MakeIndex
    local equipItemData = HeroEquipProxy:GetEquipDataByMakeIndex(MakeIndex)
    -- 在拖动或者其他延时操作时，被自动穿戴替换道具，此时的异常处理
    if not equipItemData then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return
    end
    global.Facade:sendNotification(global.NoticeTable.HeroTakeOffRequestToHumBag, itemData)
end
function ItemMoveProxy:TakeOffEquip(data)
    -- 脱下装备  装备栏 -> 背包
    local itemData = data.itemData
    local pos = data.pos
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local MakeIndex = itemData.MakeIndex
    local equipItemData = EquipProxy:GetEquipDataByMakeIndex(MakeIndex)
    -- 在拖动或者其他延时操作时，被自动穿戴替换道具，此时的异常处理
    if not equipItemData then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return
    end

    global.Facade:sendNotification(global.NoticeTable.TakeOffRequest, itemData)
end
function ItemMoveProxy:TakeOffEquip_To_HeroBag(data)
    dump(data, "TakeOffEquip_To_HeroBag")
    -- 脱下装备  人物装备栏 -> 英雄背包
    local itemData = data.itemData
    local pos = data.pos
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local MakeIndex = itemData.MakeIndex
    local equipItemData = EquipProxy:GetEquipDataByMakeIndex(MakeIndex)
    -- 在拖动或者其他延时操作时，被自动穿戴替换道具，此时的异常处理
    if not equipItemData then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return
    end

    global.Facade:sendNotification(global.NoticeTable.TakeOffToHeroBagRequest, itemData)
end


--TODO:
function ItemMoveProxy:QuickUseIntoSellRequire(data)
    -- 预出售 预修理   快捷栏 -> 预览界面
    local itemData = data.itemData
    local pos = data.pos
    local target = data.target
end

function ItemMoveProxy:AddItemIntoSellRepaire(data)
    -- 预出售 预修理   背包 -> 预览界面
    local itemData = data.itemData
    local pos = data.pos
    local target = data.target
    if not itemData then
        return true
    end
    local data = {
        Name = itemData.Name,
        MakeIndex = itemData.MakeIndex
    }

    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    if target == ItemMoveProxy.ItemGoTo.SELL then
        local NPCSellProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCSellProxy)
        NPCSellProxy:SetOnSellingData(itemData)
        NPCSellProxy:RequestNpcStoreSellPre(data)
    elseif target == ItemMoveProxy.ItemGoTo.REPAIRE then
        local NPCRepaireProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCRepaireProxy)
        NPCRepaireProxy:SetOnRepairingData(itemData)
        NPCRepaireProxy:RequestNpcStoreRepairePre(data)
    elseif target == ItemMoveProxy.ItemGoTo.NPC_DO_SOMETHING then
        local NPCDoSomethingProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCDoSomethingProxy)
        NPCDoSomethingProxy:SetonDoThingsData(itemData)
    elseif target == ItemMoveProxy.ItemGoTo.NEWTYPE then
        local NPCNewTypeOkProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCNewTypeOkProxy)
        NPCNewTypeOkProxy:SetonDoThingsData(itemData)
    end
    local data = {
        itemData = itemData
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_UpDate, data)
end
--和背包丢弃同一接口， 快捷栏数据全部来自于背包
function ItemMoveProxy:DropItemFromQuickUse(data)
    -- 丢弃  快捷栏 -> 地面
    local itemData = data.itemData
    if not itemData or not next(itemData) then
        return true
    end
    global.Facade:sendNotification(global.NoticeTable.IntoDropItem, itemData)
    return true
end

function ItemMoveProxy:PlayerEquipToPlayerEquip(data)
    -- 取消  装备栏 -> 装备栏
    global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
    return true
end

function ItemMoveProxy:CancelSellIntoBag(data)
    -- 取消 预出售 预修理  预览界面 -> 背包
    --移动端 直接取消
    --PC端 原位置 == 取消 新位置 移动到新位置 有物品的位置 交换位置并且添加该物品到移动
    local itemData = data.itemData
    local pos = data.pos
    local targetPosInBag = data.itemPosInbag
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local posDataInbag = BagProxy:GetMakeIndexByBagPos(targetPosInBag)
    local beginPos = BagProxy:GetBagPosByMakeIndex(itemData.MakeIndex)
    local NPCSellProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCSellProxy)
    NPCSellProxy:ResetSellingState()
    if posDataInbag then
        if posDataInbag == itemData.MakeIndex then --不变
            -- 背包中的重新刷出来
            local data = {
                storage = {
                    MakeIndex = itemData.MakeIndex,
                    state = 1
                }
            }
            global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
        else --换位
            if global.isWinPlayMode then
                BagProxy:SetItemPosData(itemData.MakeIndex, targetPosInBag)
                BagProxy:SetItemPosData(posDataInbag, beginPos)
                global.Facade:sendNotification(global.NoticeTable.Item_Move_begin_On_BagPosChang,
                {
                    MakeIndex = posDataInbag,
                    pos = pos
                }
                )
            else
                local newPos = BagProxy:NewItemPos()
                newPos = newPos < beginPos and newPos or beginPos
                -- 先结束事件
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
                -- 再发刷新
                BagProxy:SetItemPosData(itemData.MakeIndex, newPos)
            end
            return true
        end
    else --移动
        -- 先结束事件
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
        -- 再发刷新
        BagProxy:SetItemPosData(itemData.MakeIndex, targetPosInBag)
        return true
    end
end

function ItemMoveProxy:CancelRequireIntoBag(data)
    -- 取消 预出售 预修理  预览界面 -> 背包
    -- 移动端 直接取消
    -- PC端 原位置 == 取消 新位置 移动到新位置 有物品的位置 交换位置并且添加该物品到移动
    local itemData = data.itemData
    local pos = data.pos
    local targetPosInBag = data.itemPosInbag
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local posDataInbag = BagProxy:GetMakeIndexByBagPos(targetPosInBag)
    local beginPos = BagProxy:GetBagPosByMakeIndex(itemData.MakeIndex)
    local NPCRepaireProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCRepaireProxy)
    NPCRepaireProxy:ResetRepairingState()
    if posDataInbag then
        if posDataInbag == itemData.MakeIndex then --不变
            -- 背包中的重新刷出来
            local data = {
                storage = {
                    MakeIndex = itemData.MakeIndex,
                    state = 1
                }
            }
            global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
        else --换位
            if global.isWinPlayMode then
                BagProxy:SetItemPosData(itemData.MakeIndex, targetPosInBag)
                BagProxy:SetItemPosData(posDataInbag, beginPos)
                global.Facade:sendNotification(global.NoticeTable.Item_Move_begin_On_BagPosChang,
                {
                    MakeIndex = posDataInbag,
                    pos = pos
                }
                )
            else
                local newPos = BagProxy:NewItemPos()
                newPos = newPos < beginPos and newPos or beginPos
                -- 先结束事件
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
                -- 再发刷新
                BagProxy:SetItemPosData(itemData.MakeIndex, newPos)
            end
            return true
        end
    else --移动
        -- 先结束事件
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
        -- 再发刷新
        BagProxy:SetItemPosData(itemData.MakeIndex, targetPosInBag)
        return true
    end
end

function ItemMoveProxy:CancelDoSomethingIntoBag(data)
    -- 取消 请求 -> 背包
    -- 移动端 直接取消
    -- PC端 原位置 == 取消 新位置 移动到新位置 有物品的位置 交换位置并且添加该物品到移动
    local itemData = data.itemData
    local pos = data.pos
    local targetPosInBag = data.itemPosInbag
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local posDataInbag = BagProxy:GetMakeIndexByBagPos(targetPosInBag)
    local beginPos = BagProxy:GetBagPosByMakeIndex(itemData.MakeIndex)
    local NPCDoSomethingProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCDoSomethingProxy)
    NPCDoSomethingProxy:CleanOnDoData()
    if posDataInbag then
        if posDataInbag == itemData.MakeIndex then --不变
            -- 背包中的重新刷出来
            local data = {
                storage = {
                    MakeIndex = itemData.MakeIndex,
                    state = 1
                }
            }
            global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
        else --换位
            if global.isWinPlayMode then
                BagProxy:SetItemPosData(itemData.MakeIndex, targetPosInBag)
                BagProxy:SetItemPosData(posDataInbag, beginPos)
                global.Facade:sendNotification(global.NoticeTable.Item_Move_begin_On_BagPosChang,
                {
                    MakeIndex = posDataInbag,
                    pos = pos
                }
                )
            else
                local newPos = BagProxy:NewItemPos()
                newPos = newPos < beginPos and newPos or beginPos
                -- 先结束事件
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
                -- 再发刷新
                BagProxy:SetItemPosData(itemData.MakeIndex, newPos)
            end
            return true
        end
    else --移动
        -- 先结束事件
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
        -- 再发刷新
        BagProxy:SetItemPosData(itemData.MakeIndex, targetPosInBag)
        return true
    end
end

function ItemMoveProxy:CancelNewTypeIntoBag(data)
    -- 取消 请求 -> 背包
    -- 移动端 直接取消
    -- PC端 原位置 == 取消 新位置 移动到新位置 有物品的位置 交换位置并且添加该物品到移动
    local itemData = data.itemData
    local pos = data.pos
    local targetPosInBag = data.itemPosInbag
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local posDataInbag = BagProxy:GetMakeIndexByBagPos(targetPosInBag)
    local beginPos = BagProxy:GetBagPosByMakeIndex(itemData.MakeIndex)
    local NPCNewTypeOkProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCNewTypeOkProxy)
    NPCNewTypeOkProxy:CleanOnDoData()
    if posDataInbag then
        if posDataInbag == itemData.MakeIndex then --不变
            -- 背包中的重新刷出来
            local data = {
                storage = {
                    MakeIndex = itemData.MakeIndex,
                    state = 1
                }
            }
            global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
        else --换位
            if global.isWinPlayMode then
                BagProxy:SetItemPosData(itemData.MakeIndex, targetPosInBag)
                BagProxy:SetItemPosData(posDataInbag, beginPos)
                global.Facade:sendNotification(global.NoticeTable.Item_Move_begin_On_BagPosChang,
                {
                    MakeIndex = posDataInbag,
                    pos = pos
                }
                )
            else
                local newPos = BagProxy:NewItemPos()
                newPos = newPos < beginPos and newPos or beginPos
                -- 先结束事件
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
                -- 再发刷新
                BagProxy:SetItemPosData(itemData.MakeIndex, newPos)
            end
            return true
        end
    else --移动
        -- 先结束事件
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
        -- 再发刷新
        BagProxy:SetItemPosData(itemData.MakeIndex, targetPosInBag)
        return true
    end
end

function ItemMoveProxy:SellOrRequiredCancel(data)
    -- if global.isWinPlayMode then
    global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
    -- end
end

function ItemMoveProxy:AddItemIntoTrade(data)
    local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
    local state = TradeProxy:GetLockState()
    if state then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return true
    end
    local itemData = data.itemData
    local pos = data.pos
    local targetPosInTrade = data.itemPosInTrade
    if not itemData then
        return true
    end

    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local MakeIndex = itemData.MakeIndex
    local Name = itemData.Name
    local isBind,isSelf,isMeetType = CheckItemisBind(itemData, ItemConfigProxy:GetBindArticleType().TYPE_NOTRADE)
    if isMeetType then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        local data = {}
        data.str = string.format(GET_STRING(90020014), Name)
        data.btnType = 1
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        return true
    else
        TradeProxy:RequestPutInItem(MakeIndex, Name)
    end
end

function ItemMoveProxy:DeleteItemIntoTrade(data)
    local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
    local state = TradeProxy:GetLockState()
    if state then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return true
    end
    local itemData = data.itemData
    local pos = data.pos
    local targetPosInTrade = data.itemPosInTrade
    if not itemData then
        return true
    end
    local MakeIndex = itemData.MakeIndex
    local Name = itemData.Name
    TradeProxy:RequestPutOutItem(MakeIndex, Name)
end

function ItemMoveProxy:AddGoldToTrade(data)
    local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
    local state = TradeProxy:GetLockState()
    local moneyId = TradeProxy:GetTradeMoneyID()
    local MoneyProxy = global.Facade:retrieveProxy(global.ProxyTable.MoneyProxy)
    if state then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return true
    end
    -- 交易金币 背包金币 -> 交易栏
    local function callback(btnType, data)
        local bagState = {
            goldState = 1
        }
        global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, bagState)
        if data.editStr and data.editStr ~= "" then
            if type(data.editStr) == "string" then
                local num = tonumber(data.editStr)
                local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
                TradeProxy:RequestChangeMoney(num)
            end
        end
    end
    local data = {}
    local moneyName = moneyId and MoneyProxy:GetMoneyNameById(moneyId) or "金币"
    data.str = string.format(GET_STRING(90020016), moneyName)
    data.callback = callback
    data.btnType = 1
    data.showEdit = true
    data.editParams = {
        inputMode = 2
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

function ItemMoveProxy:PutOutTradingGold(data)
    local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
    local state = TradeProxy:GetLockState()
    if state then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return true
    end
    local tradingCount = 0
    local tradingCount = TradeProxy:GetSelfGoldNum() or 0
    if tradingCount > 0 then
        TradeProxy:RequestChangeMoney(0)
    end
end
--取出
function ItemMoveProxy:GetOutStorageItemsToBag(data)

    local data = data.itemData
    local StorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
    StorageProxy:RequestPutOutStorageData(data.MakeIndex, data.Name)

end
--放入
function ItemMoveProxy:AddItemIntoStorage(data)

    local data = data.itemData
    local StorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
    StorageProxy:RequestSaveToStorage(data.MakeIndex, data.Name)

end

function ItemMoveProxy:CancelPutOutStorage(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
end
-- 摆摊取出
function ItemMoveProxy:PutStallItemInBag(data)
    local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
    local itemData = data.itemData
    local pos = data.pos
    local targetPosInTrade = data.itemPosInTrade
    if not CheckCanDoSomething() then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return true
    end
    if not itemData then
        -- 先结束事件
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return true
    end
    -- 先结束事件
    global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
    local MakeIndex = itemData.MakeIndex
    local Name = itemData.Name
    StallProxy:PutOutItem(MakeIndex)

end
-- 摆摊放入
function ItemMoveProxy:PutItemInStall(data)
    local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
    local itemData = data.itemData
    local pos = data.pos
    local targetPosInTrade = data.itemPosInTrade
    if not CheckCanDoSomething() then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return true
    end
    if not itemData then
        return true
    end

    local MakeIndex = itemData.MakeIndex
    local Name = itemData.Name
    local isBind = CheckItemisBind(itemData)
    local noTrade = false --禁止摆摊
    if not isBind and itemData.Article and itemData.Article ~= "" then
        local parseArticle = string.split(itemData.Article, "|")
        for k, v in pairs(parseArticle) do
            if v == "9" then --物品禁止摆摊规则
                noTrade = true
                break
            end
        end
    end

    if isBind or noTrade then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        local data = {}
        data.str = string.format(isBind and GET_STRING(90020005) or GET_STRING(90170005), Name)
        data.btnType = 1
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        return true    
    end
    StallProxy:RequestPutInItem(MakeIndex)
end
-- itembox 取出
function ItemMoveProxy:PutITEMBOXItemInBag(data)
    local boxindex = global.SUIManager:GetITEMBOXIndexByMakeIndex(data.itemData.MakeIndex)
    if boxindex then
        local npcProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
        local submitData =         {
            index    = boxindex,
            npcid    = npcProxy:GetCurrentNPCID()
        }
        global.SUIManager:RequestITEMBOXPutout(submitData)
    end
end
-- itembox 放入
function ItemMoveProxy:PutItemInTEMBOX(data)
    local function checkAble()
        if data.stdmode == "*" then
            return true
        end
        local slices = string.split(data.stdmode, ",")
        for i, v in ipairs(slices) do
            if tonumber(v) == data.itemData.StdMode then
                return true
            end
        end
        return false
    end
    if false == checkAble() then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return nil
    end

    -- send msg
    local npcProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local submitData = {
        makeindex = data.itemData.MakeIndex,
        index    = data.boxindex,
        npcid    = npcProxy:GetCurrentNPCID()
    }
    global.SUIManager:RequestITEMBOXPutin(submitData)
end

-- SSR itemBox 
-- 取出
function ItemMoveProxy:PutSSRITEMBOXItemInBag(data)
    local SSRUIManager = global.Facade:retrieveMediator("SSRUIManager")
    local boxindex = SSRUIManager:GetITEMBOXIndexByMakeIndex(data.itemData.MakeIndex)
    if boxindex then

        global.Facade:sendNotification(global.NoticeTable.SSR_ITEMBOXWidget_Remove, { boxindex = boxindex })

        if ssrGlobal_PutItemBoxItemToBag and type(ssrGlobal_PutItemBoxItemToBag) == "function" then
            ssrGlobal_PutItemBoxItemToBag(boxindex, data.itemData)
        end

        local itemData = data.itemData
        local pos = data.pos
        local targetPosInBag = data.itemPosInbag
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        local posDataInbag = BagProxy:GetMakeIndexByBagPos(targetPosInBag)
        local beginPos = BagProxy:GetBagPosByMakeIndex(itemData.MakeIndex)
        if posDataInbag then
            if posDataInbag == itemData.MakeIndex then --不变
                -- 背包中的重新刷出来
                local data = {
                    storage = {
                        MakeIndex = itemData.MakeIndex,
                        state = 1
                    }
                }
                global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
            else --换位
                if global.isWinPlayMode then
                    BagProxy:SetItemPosData(itemData.MakeIndex, targetPosInBag)
                    BagProxy:SetItemPosData(posDataInbag, beginPos)
                    global.Facade:sendNotification(global.NoticeTable.Item_Move_begin_On_BagPosChang,
                    {
                        MakeIndex = posDataInbag,
                        pos = pos
                    }
                    )
                else
                    local newPos = BagProxy:NewItemPos()
                    newPos = newPos < beginPos and newPos or beginPos
                    -- 先结束事件
                    global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
                    -- 再发刷新
                    BagProxy:SetItemPosData(itemData.MakeIndex, newPos)
                end
                return true
            end
        else --移动
            -- 先结束事件
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
            -- 再发刷新
            BagProxy:SetItemPosData(itemData.MakeIndex, targetPosInBag)
            return true
        end

    end
end

-- 放入
function ItemMoveProxy:PutItemInSSRITEMBOX(data)
    local function checkAble()
        if data.stdmode == "*" then
            return true
        end

        local stdmodeList = {}
        if type(data.stdmode) == "table" then
            stdmodeList = data.stdmode
        elseif type(data.stdmode) == "number" then
            table.insert(stdmodeList, data.stdmode)
        end
        for i, v in ipairs(stdmodeList) do
            if tonumber(v) == data.itemData.StdMode then
                return true
            end
        end
        return false
    end
    if false == checkAble() then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        return nil
    end

    global.Facade:sendNotification(global.NoticeTable.SSR_ITEMBOXWidget_Update, data)

    if ssrGlobal_PutInItemBox and type(ssrGlobal_PutInItemBox) == "function" then
        ssrGlobal_PutInItemBox(data.boxindex, data.itemData)
    end

end

function ItemMoveProxy:TakeOffPetEquipLink(data)
    -- 宠物装备栏 -> 背包 （ 不限制宠物
    local itemData = data.itemData
    local pos = data.pos
    local PetsEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.PetsEquipProxy)
    local MakeIndex = itemData.MakeIndex
    local equipItemData = PetsEquipProxy:GetEquipDataByMakeIndex(MakeIndex)
    -- if not equipItemData then
    global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
    --     return
    -- end

    if type(data.linkFunc) == "function" then
        data.linkFunc()
    end
end
-----

function ItemMoveProxy:PutItemIntoSomeEquip(data)
    -- 快捷栏 快捷栏 -> 主角装备
    global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
    local itemData = data.itemData
    local pos = data.pos
    local equipPos = data.equipPos
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    if equipPos == EquipProxy:GetEquipTypeConfig().Equip_Type_Bujuk then
        local posItemData = EquipProxy:GetEquipDataByPos(equipPos)
        if posItemData and posItemData.StdMode == 96 then
            local targetShape = posItemData.Shape
            local myAniCount = itemData.AniCount
            if itemData and itemData.StdMode == 3 and itemData.Shape == 4 and targetShape and myAniCount and targetShape == myAniCount then

                LuaSendMsg(global.MsgType.MSG_CS_ITEM_FIX_ITEMS, itemData.MakeIndex, posItemData.MakeIndex, 0, 0)
            end
        end
    end
    return true
end
function ItemMoveProxy:HumBagToHeroBag(data)
    -- 人物背包 -> 英雄背包
    local itemData = data.itemData
    local HeroBagProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
    if not HeroBagProxy:isToBeFull(true) then
        HeroBagProxy:RequestHumBagToHeroBag(data.itemData.MakeIndex, data.itemData.Name)
    end
end
function ItemMoveProxy:HeroBagToHumBag(data)
    -- 人物背包 -> 英雄背包
    local itemData = data.itemData
    local HeroBagProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
    HeroBagProxy:RequestHeroBagToHumBag(data.itemData.MakeIndex, data.itemData.Name)
end

-----
function ItemMoveProxy:SkillShowToTopUI(data)
    if not data.skillId then
        return
    end

    global.Facade:sendNotification(global.NoticeTable.TopTouch_Add_Child, { skill = data.skillId, pos = data.pos })
    SLBridge:onLUAEvent(LUA_EVENT_SKILL_ADD_TO_UI_WIN32, { skill = data.skillId, pos = data.pos })
end
----------------------------
function ItemMoveProxy:ExchangeItemMoveItem(param)
    local resetOldCallBack = param.resetOld
    local newItemData = param.goMovingData
    --step1:RESET Old ITEM STATE
    resetOldCallBack()
    --step2:CHANGE MOVING DATA ON newItemData
    --TODO:将当前移动的节点用新的替换
end

function ItemMoveProxy:GetItemMoveFrome()
    return self.movingItemFrom
end

function ItemMoveProxy:SetMoveItemData(data, from, skillId)
    --有来源即可  可能移动的节点 不一定是道具
    if from then
        self.onMovingItem = data
        self.onMoving = true
        self.onMovingSkill = skillId
        if skillId then
            global.Facade:sendNotification(global.NoticeTable.TopTouch_Remove_Child, { skill = skillId })
            SLBridge:onLUAEvent(LUA_EVENT_SKILL_REMOVE_TO_UI_WIN32, { skill = skillId })
        end
    else
        self.onMovingItem = nil
        self.onMoving = false
        self.onMovingSkill = nil
    end
    self.movingItemFrom = from
end

function ItemMoveProxy:SetLinkFunc(func)
    if type(func) == "function" then
        self.linkFunc = func
    else
        self.linkFunc = nil
    end
end

function ItemMoveProxy:GetItemCanGoTargetFunc(target)
    if not self.movingItemFrom or not target then
        return false
    end
    local itemTargetMap = ItemMoveProxy.ItemFromAndGoToMap[self.movingItemFrom]

    if not itemTargetMap or not next(itemTargetMap) then
        return false
    end

    local callBackFun = itemTargetMap[target]

    return callBackFun
end
-- 如果不需要结束移动，或者在自己的逻辑中已经结束 则方法返回bool true
function ItemMoveProxy:CheckAndCallBack(data)
    local target = data.target
    local callBackFunc = self:GetItemCanGoTargetFunc(target)
    if not callBackFunc then
        if not global.isWinPlayMode then
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
        end
        return
    end
    data.itemData = self.onMovingItem
    data.linkFunc = self.linkFunc
    data.skillId = self.onMovingSkill
    if not callBackFunc(self, data) then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End)
    end
end

function ItemMoveProxy:GetMovingItemState()
    return self.onMoving
end

function ItemMoveProxy:GetMovingItemData()
    return self.onMovingItem
end

function ItemMoveProxy:GetMovingSkill()
    return self.onMovingSkill
end

function ItemMoveProxy:onRegister()
    ItemMoveProxy.super.onRegister(self)
    --放在最后 先注册方法
    ItemMoveProxy.ItemFromAndGoToMap = {
        [ItemMoveProxy.ItemFrom.BAG] = {
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.ChangeItemPos,
            [ItemMoveProxy.ItemGoTo.PALYER_EQUIP] = ItemMoveProxy.TakeOnItem,
            [ItemMoveProxy.ItemGoTo.QUICK_USE] = ItemMoveProxy.AddToQuickUse,
            [ItemMoveProxy.ItemGoTo.STORAGE] = ItemMoveProxy.AddItemIntoStorage,
            [ItemMoveProxy.ItemGoTo.SELL] = ItemMoveProxy.AddItemIntoSellRepaire,
            [ItemMoveProxy.ItemGoTo.DROP] = ItemMoveProxy.DropItem,
            [ItemMoveProxy.ItemGoTo.REPAIRE] = ItemMoveProxy.AddItemIntoSellRepaire,
            [ItemMoveProxy.ItemGoTo.TRADE] = ItemMoveProxy.AddItemIntoTrade,
            [ItemMoveProxy.ItemGoTo.BEST_RINGS] = ItemMoveProxy.TakeOnBestRing,
            [ItemMoveProxy.ItemGoTo.AUTO_TRADE] = ItemMoveProxy.PutItemInStall,
            [ItemMoveProxy.ItemGoTo.ITEMBOX]    = ItemMoveProxy.PutItemInTEMBOX,
            [ItemMoveProxy.ItemGoTo.NPC_DO_SOMETHING] = ItemMoveProxy.AddItemIntoSellRepaire,
            [ItemMoveProxy.ItemGoTo.TreasureBox] = ItemMoveProxy.PutItemInTreasureBox,
            [ItemMoveProxy.ItemGoTo.HERO_BAG] = ItemMoveProxy.HumBagToHeroBag,
            [ItemMoveProxy.ItemGoTo.NEWTYPE] = ItemMoveProxy.AddItemIntoSellRepaire,
            [ItemMoveProxy.ItemGoTo.HERO_EQUIP] = ItemMoveProxy.TakeOnItem_Hero_FromHumBag,
            [ItemMoveProxy.ItemGoTo.SSR_ITEM_BOX] = ItemMoveProxy.PutItemInSSRITEMBOX,

        },
        [ItemMoveProxy.ItemFrom.PALYER_EQUIP] = {
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.TakeOffEquip,
            [ItemMoveProxy.ItemGoTo.PALYER_EQUIP] = ItemMoveProxy.PlayerEquipToPlayerEquip,
            [ItemMoveProxy.ItemGoTo.HERO_BAG] = ItemMoveProxy.TakeOffEquip_To_HeroBag,
        },
        [ItemMoveProxy.ItemFrom.QUICK_USE] = {
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.DeleteQuickUse,
            [ItemMoveProxy.ItemGoTo.QUICK_USE] = ItemMoveProxy.ChangeItemPosQuickUse,
            -- [ItemMoveProxy.ItemGoTo.STORAGE] = ItemMoveProxy.AddItemIntoStorage,
            -- [ItemMoveProxy.ItemGoTo.SELL] = ItemMoveProxy.QuickUseIntoSellRequire,
            [ItemMoveProxy.ItemGoTo.DROP] = ItemMoveProxy.DropItemFromQuickUse,
            -- [ItemMoveProxy.ItemGoTo.REPAIRE] = ItemMoveProxy.QuickUseIntoSellRequire,
            [ItemMoveProxy.ItemGoTo.PALYER_EQUIP] = ItemMoveProxy.PutItemIntoSomeEquip,
            [ItemMoveProxy.ItemGoTo.HERO_BAG] = ItemMoveProxy.DeleteQuickUse_ToHeroBag,
        },
        [ItemMoveProxy.ItemFrom.STORAGE] = {
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.GetOutStorageItemsToBag,
            [ItemMoveProxy.ItemGoTo.STORAGE] = ItemMoveProxy.CancelPutOutStorage,
        },
        [ItemMoveProxy.ItemFrom.BAG_GOLD] = {
            [ItemMoveProxy.ItemGoTo.DROP] = ItemMoveProxy.DropGold,
            [ItemMoveProxy.ItemGoTo.TRADE] = ItemMoveProxy.AddGoldToTrade,
            [ItemMoveProxy.ItemGoTo.TRADE_GOLD] = ItemMoveProxy.AddGoldToTrade,
        },
        [ItemMoveProxy.ItemFrom.SELL] = {
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.CancelSellIntoBag,
            [ItemMoveProxy.ItemGoTo.QUICK_USE] = ItemMoveProxy.ChangeItemPos,
            [ItemMoveProxy.ItemGoTo.SELL] = ItemMoveProxy.SellOrRequiredCancel
        },
        [ItemMoveProxy.ItemFrom.REPAIRE] = {
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.CancelRequireIntoBag,
            [ItemMoveProxy.ItemGoTo.QUICK_USE] = ItemMoveProxy.ChangeItemPos,
            [ItemMoveProxy.ItemGoTo.REPAIRE] = ItemMoveProxy.SellOrRequiredCancel
        },
        [ItemMoveProxy.ItemFrom.TRADE] = {
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.DeleteItemIntoTrade,
        },
        [ItemMoveProxy.ItemFrom.TRADE_GOLD] = {
            [ItemMoveProxy.ItemGoTo.BAG_GOLD] = ItemMoveProxy.PutOutTradingGold,
        },
        [ItemMoveProxy.ItemFrom.BEST_RINGS] = {
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.TakeOffEquip,
        },
        [ItemMoveProxy.ItemFrom.AUTO_TRADE] = {
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.PutStallItemInBag,
        },
        [ItemMoveProxy.ItemFrom.ITEMBOX] = {
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.PutITEMBOXItemInBag,
        },
        [ItemMoveProxy.ItemFrom.NPC_DO_SOMETHING] = {
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.CancelDoSomethingIntoBag,
            [ItemMoveProxy.ItemGoTo.QUICK_USE] = ItemMoveProxy.ChangeItemPos,
            [ItemMoveProxy.ItemGoTo.NPC_DO_SOMETHING] = ItemMoveProxy.SellOrRequiredCancel
        },
        [ItemMoveProxy.ItemFrom.HERO_BAG] = {
            [ItemMoveProxy.ItemGoTo.HERO_BAG] = ItemMoveProxy.ChangeItemPos_Hero,
            [ItemMoveProxy.ItemGoTo.HERO_EQUIP] = ItemMoveProxy.TakeOnItem_Hero,
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.HeroBagToHumBag,
            [ItemMoveProxy.ItemGoTo.DROP] = ItemMoveProxy.DropItem_Hero,
            [ItemMoveProxy.ItemGoTo.HERO_BEST_RINGS] = ItemMoveProxy.TakeOnBestRing_Hero,
            [ItemMoveProxy.ItemGoTo.PALYER_EQUIP] = ItemMoveProxy.TakeOnItem_FromHeroBag,
        },
        [ItemMoveProxy.ItemFrom.HERO_EQUIP] = {
            [ItemMoveProxy.ItemGoTo.HERO_BAG] = ItemMoveProxy.TakeOffEquip_Hero,
            [ItemMoveProxy.ItemGoTo.HERO_EQUIP] = ItemMoveProxy.CancelHeroEquipMove_Hero,
            [ItemMoveProxy.ItemGoTo.DROP] = ItemMoveProxy.CancelHeroEquipMove_Hero,
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.TakeOffEquip_Hero_To_HumBag,
        },
        [ItemMoveProxy.ItemFrom.HERO_BEST_RINGS] = {
            [ItemMoveProxy.ItemGoTo.HERO_BAG] = ItemMoveProxy.TakeOffEquip_Hero,
        },
        [ItemMoveProxy.ItemFrom.NEWTYPE] = {
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.CancelNewTypeIntoBag,
            [ItemMoveProxy.ItemGoTo.QUICK_USE] = ItemMoveProxy.ChangeItemPos,
            [ItemMoveProxy.ItemGoTo.NEWTYPE] = ItemMoveProxy.SellOrRequiredCancel
        },
        [ItemMoveProxy.ItemFrom.SSR_ITEM_BOX] = {
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.PutSSRITEMBOXItemInBag,
        },
        [ItemMoveProxy.ItemFrom.PETS_EQUIP] = {
            [ItemMoveProxy.ItemGoTo.BAG] = ItemMoveProxy.TakeOffPetEquipLink,
        },
        [ItemMoveProxy.ItemFrom.SKILL_WIN] = {
            [ItemMoveProxy.ItemGoTo.TOPUI] = ItemMoveProxy.SkillShowToTopUI,
        }
    }
end

function ItemMoveProxy:AddMoveTypeAndFunc(from, to, fromToEvent, toFromEvent)
    local type = 100 + self._guiTypeNum
    if not ItemMoveProxy.ItemFrom[from] then
        ItemMoveProxy.ItemFrom[from] = type
    end

    if not ItemMoveProxy.ItemGoTo[from] then
        ItemMoveProxy.ItemGoTo[from] = type
    end
    self._guiTypeNum = self._guiTypeNum + 1

    local toType = 100 + self._guiTypeNum
    if not ItemMoveProxy.ItemFrom[to] then
        ItemMoveProxy.ItemFrom[to] = toType
    end

    if not ItemMoveProxy.ItemGoTo[to] then
        ItemMoveProxy.ItemGoTo[to] = toType
    end

    local fromType = ItemMoveProxy.ItemFrom[from]
    local toType = ItemMoveProxy.ItemGoTo[to]

    if fromToEvent then
        if not ItemMoveProxy.ItemFromAndGoToMap[fromType] then
            ItemMoveProxy.ItemFromAndGoToMap[fromType] = {
                [toType] = fromToEvent
            }
        else
            ItemMoveProxy.ItemFromAndGoToMap[fromType][toType] = fromToEvent
        end
    end

    if toFromEvent then
        if not ItemMoveProxy.ItemFromAndGoToMap[toType] then
            ItemMoveProxy.ItemFromAndGoToMap[toType] = {
                [fromType] = toFromEvent
            }
        else
            ItemMoveProxy.ItemFromAndGoToMap[toType][fromType] = toFromEvent
        end
    end
end

return ItemMoveProxy