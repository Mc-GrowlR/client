local BaseLayer = requireLayerUI("BaseLayer")
local AutoUseTipsLayer = class("AutoUseTipsLayer", BaseLayer)

function AutoUseTipsLayer:ctor()
    AutoUseTipsLayer.super.ctor(self)
    self._tipsList = {}
    self._ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    self._HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
    self._EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    self._HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
end

function AutoUseTipsLayer.create(...)
    local layout = AutoUseTipsLayer.new()
    if layout:Init(...) then
        return layout
    end
    return nil
end

function AutoUseTipsLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function AutoUseTipsLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_AUTO_USE_POP)
    AutoUsePop.main(data)

    self:InitUI(data)
end

function AutoUseTipsLayer:RemoveTips(data)
    if not data or not data.id then
        return
    end

    if self._tipsList[data.id] then
        self._tipsList[data.id]:removeFromParent()
        self._tipsList[data.id] = nil
    end
end

function AutoUseTipsLayer:InitUI(data)
    local tag = data.id
    self._Node = self:getChildByTag(tag)
    if not self._Node then
        return
    end
    
    self._tipsList[tag] = self._Node
    local pView = self._Node:getChildByName("PPopUI")
    IterAllChild(pView, pView)

    local item       = data.item
    local MakeIndex  = data.item.MakeIndex
    local targetPos  = data.targetPos
    local skillBook  = data.skillBook
    local itemBelong = self._ItemManagerProxy:GetItemBelong(MakeIndex)
    local isFromHero = itemBelong == global.MMO.ITEM_FROM_BELONG_HEROBAG 
    local isHero     = data.isHero
    local proxy = isHero and self._HeroEquipProxy or self._EquipProxy

    local dt = {
        data = data,
        item = item,
        MakeIndex = MakeIndex,
        targetPos = targetPos,
        skillBook = skillBook,
        isHero = isHero,
        isFromHero = isFromHero,
        EquipProxy = proxy
    }

    pView.BtnClose:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_Auto_Use_UnAttach, {id = MakeIndex, pos = targetPos, isHero = isHero})
    end)

    pView.BtnUse:addClickEventListener(function()
        self:OnExit(dt, true)
    end)

    -- 剩余时间
    local strF = AutoUsePop and AutoUsePop._remainTimeStr or GET_STRING(1074)
    local remaining = tonumber(SL:GetMetaValue("GAME_DATA", "autousetimes")) or 5
    pView.TextTime:setString(string.format(strF, remaining))

    local isAutoEquip = true
    local limitQuality = tonumber(SL:GetMetaValue("GAME_DATA", "auto_equip_quality")) or 1
    if CHECK_SETTING(global.MMO.SETTING_IDX_AUTO_PUT_IN_EQUIP) == 0 then
        isAutoEquip = false
    end
    pView.TextTime:setVisible(isAutoEquip)

    local function callback()
        remaining = remaining - 1
        remaining = math.max(remaining, 0)
        pView.TextTime:setString(string.format(strF, remaining))

        if remaining == 0 then
            self:OnExit(dt, isAutoEquip)
        end
    end
    if isAutoEquip then
        schedule(pView, callback, 1)
    end

end

function AutoUseTipsLayer:OnExit(t, usable)
    if not usable then
        return false
    end

    if t.isHero and not self._HeroPropertyProxy:HeroIsLogin() then
        global.Facade:sendNotification(global.NoticeTable.Layer_Auto_Use_UnAttach, {id = t.MakeIndex, pos = t.targetPos, isHero = t.isHero})
        return
    end

    local ItemUseProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemUseProxy)
    -- 技能书
    if t.skillBook then
        if t.isHero then
            if t.isFromHero then
                ItemUseProxy:HeroUseItem(t.item)
            end
        else
            ItemUseProxy:UseItem(t.item)
        end

    -- 极品首饰
    -- 装备        
    elseif t.targetPos then
        local canEquip, strList
        if t.isHero then
            canEquip, strList = CheckItemUseNeed_Hero(t.item)
        else
            canEquip, strList = CheckItemUseNeed(t.item)
        end
        if canEquip then
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            local movingData = ItemMoveProxy:GetMovingItemData()
            if movingData and t.MakeIndex == movingData.MakeIndex then
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
            end

            -- 因为穿戴有延时，在结束时重新选择最优位置
            local equipIntoPos = -1
            -- 是否有找到合适的位置 战力对比
            local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
            local comparison = ItemConfigProxy:GetItemComparison(t.item.Index)
            local myPower = 0
            local powerSortIndex = nil
            myPower, powerSortIndex = GUIFunction:GetEquipPower(t.item, {jobPower = true}, t.isHero)
            local param = {jobPower = true, power = myPower, comparison = comparison, powerSortIndex = powerSortIndex}
            local excludePos = GUIFunction:CheckEquipExcludePos(t.item)
            local minPowerPos, onEquipMinPower, hasEquip = GUIFunction:GetMinPowerPosByStdMode(t.item.StdMode, param, nil, t.isHero, excludePos)

            if minPowerPos >= 0 and (not hasEquip or onEquipMinPower < myPower) then
                equipIntoPos = minPowerPos
            end
            if equipIntoPos < 0 then
                global.Facade:sendNotification(global.NoticeTable.Layer_Auto_Use_UnAttach, {id = t.MakeIndex, pos = t.targetPos, isHero = t.isHero})
                return
            else
                if not t.EquipProxy:CheckEquipWeight(t.item, minPowerPos) then
                    global.Facade:sendNotification(global.NoticeTable.Layer_Auto_Use_UnAttach, {id = t.MakeIndex, pos = t.targetPos, isHero = t.isHero})
                    return
                end
                t.targetPos = equipIntoPos
            end

            local eventName = global.NoticeTable.TakeOnRequest
            if t.isHero then
                eventName = t.isFromHero and global.NoticeTable.HeroTakeOnRequest or global.NoticeTable.HeroTakeOnRequestFromHumBag
            end
            global.Facade:sendNotification(eventName, {itemData = t.item, pos = t.targetPos})
        end
    else
        if t.isHero then
            ItemUseProxy:HeroUseItem(t.item, true)
        else
            ItemUseProxy:UseItem(t.item, true)
        end
    end

    global.Facade:sendNotification(global.NoticeTable.Layer_Auto_Use_UnAttach, {id = t.MakeIndex, pos = t.targetPos, isHero = t.isHero})
end

return AutoUseTipsLayer