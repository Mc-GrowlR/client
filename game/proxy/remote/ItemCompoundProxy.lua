local RemoteProxy = requireProxy("remote/RemoteProxy")
local ItemCompoundProxy = class("ItemCompoundProxy", RemoteProxy)
ItemCompoundProxy.NAME = global.ProxyTable.ItemCompoundProxy

--[[
    README:
    self.compoundNeedList = {
        [10000] = {
            12,123
        }
    }
    Index 为10000的材料能合成 12 123号合成ID
    self.compoundState = {
        [12] = true,
        [123] = false
    }
    当前是否满足合成条件 用于红点等
    self.compoundList = {
        
    }
]]
function ItemCompoundProxy:ctor()
    ItemCompoundProxy.super.ctor(self)
    self.config = {}
    self.configByIndex = {}

    self.redPoint = false
    self.onCompoundIndex = 0
    self.lastCheckMoneyTime = 0
    self.changeMoneyList = {}
    self.lastCheckMoneyCount = {}

    self.compoundNeedList = {} -- 原材料
    self.moneyNeedList = {}
    self.equipPosList = {}
    self.compoundState = {} -- 
    self.compoundList = {}

    self.pageRedPoint = {}

    self.showItemList = {}

    self.pageName = {}

    self.effectList = {}

    self:LoadConfig()
end

function ItemCompoundProxy:onRegister()
    ItemCompoundProxy.super.onRegister(self)
end

function ItemCompoundProxy:LoadConfig()
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    self.config = {}
    local fileName = global.isIOS and "cfg_makeitems.luac" or "cfg_makeitems.lua"
    if global.isIOS and not global.FileUtilCtl:isFileExist("scripts/game_config/" .. fileName) then -- ios的文件gm不是luac
        fileName = "cfg_makeitems.lua"
    end

    if global.FileUtilCtl:isFileExist("scripts/game_config/" .. fileName) then
        self.config = requireGameConfig("cfg_makeitems")
    end

    for k, item in pairs(self.config) do
        self.configByIndex[item.id] = item
        local pageIndex = item.page1 * 1000 + item.page2
        if not self.showItemList[pageIndex] then
            self.showItemList[pageIndex] = {}
        end
        self.pageName[item.page1] = item.page1name
        self.pageName[pageIndex] = item.page2name
        local moneyCost = {}
        local materialCost = {}
        local material = item.material
        local itemList = string.split(material or "", "&")
        for _, cost in pairs(itemList) do
            if cost and cost ~= "" then
                local costData = string.split(cost, "#")
                local costID = tonumber(costData[1])
                local costCount = tonumber(costData[2])
                table.insert(materialCost, {
                    id = costID,
                    count = costCount
                })
                if not self.compoundNeedList[costID] then
                    self.compoundNeedList[costID] = {}
                end
                self.compoundNeedList[costID][item.id] = costCount
                local isBind, bindIndex = ItemConfigProxy:CheckItemBind(costID)
                if isBind and bindIndex and bindIndex ~= costID then
                    if not self.compoundNeedList[bindIndex] then
                        self.compoundNeedList[bindIndex] = {}
                    end
                    self.compoundNeedList[bindIndex][item.id] = costCount
                end
            end
        end

        local moneyList = string.split(item.CYquantity or "", "&")
        for _, cost in pairs(moneyList) do
            if cost and cost ~= "" then
                local costData = string.split(cost, "#")
                local costID = tonumber(costData[1])
                local costCount = tonumber(costData[2])
                if not self.moneyNeedList[costID] then
                    self.moneyNeedList[costID] = {}
                end
                table.insert(moneyCost, {
                    id = costID,
                    count = costCount
                })

                self.moneyNeedList[costID][item.id] = costCount
                local isBind, bindIndex = ItemConfigProxy:CheckItemBind(costID)
                if isBind and bindIndex and bindIndex ~= costID then
                    if not self.moneyNeedList[bindIndex] then
                        self.moneyNeedList[bindIndex] = {}
                    end
                    self.moneyNeedList[bindIndex][item.id] = costCount
                end
            end
        end

        local equipPosCheck = item.isstamode
        if equipPosCheck and equipPosCheck ~= "" then
            local posListStr = string.split(equipPosCheck, "#")
            local posList = {}
            for i, v in ipairs(posListStr) do
                local pos = tonumber(v)
                if not self.equipPosList[pos] then
                    self.equipPosList[pos] = {}
                end
                self.equipPosList[pos][item.id] = item.id
                table.insert(posList, pos)
            end
            item.posList = posList
        end

        local itemGet = item.product
        if itemGet then
            local itemGetData = string.split(itemGet, "#")
            local itemID = tonumber(itemGetData[1])
            local itemCount = tonumber(itemGetData[2])
            item.production = {
                id = itemID,
                count = itemCount
            }
        end

        item.moneycost = moneyCost
        item.materialcost = materialCost
        table.insert(self.showItemList[pageIndex], item)
    end

    local showConfig = SL:GetMetaValue("GAME_DATA","itemiconeffect")
    if showConfig and showConfig ~= "" then
        local effectType = string.split(showConfig, "|")
        for k, v in ipairs(effectType) do
            local effctAndList = string.split(v, "&")
            local listStr = effctAndList[1]
            local effectId = tonumber(effctAndList[2])
            local indexList = string.split(listStr, "#")
            for _, index in ipairs(indexList) do
                local comIndex = tonumber(index)
                self.effectList[comIndex] = effectId
            end
        end
    end
end

function ItemCompoundProxy:CheckStrConditions(condition)
    if not condition or condition == "" then
        return true
    end

    local RedPointProxy = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)
    return RedPointProxy:CheckStrConditions(condition)
end

function ItemCompoundProxy:IsStrengIgnore(Index)
    if not Index then
        return false
    end

    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local cfg = ItemConfigProxy:GetItemDataByIndex(Index)
    local StdMode = cfg.StdMode
    if not StdMode then
        return false
    end

    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    local Item_Type = ItemManagerProxy:GetItemSettingType()
    local itemType = ItemManagerProxy:GetItemType(cfg)
    if itemType == Item_Type.Equip then -- 装备类型的强化都要忽略合成材料
        return true
    end

    return false
end

function ItemCompoundProxy:CheckListIsShow(page1, page2)
    for pageIndex, itemList in pairs(self.showItemList) do
        if math.floor(pageIndex / 1000) == page1 and ((not page2) or page2 == pageIndex) then
            for k, v in pairs(itemList) do
                local isShow = self:CheckStrConditions(v.showcondition)
                if isShow then
                    return isShow
                end
            end
        end
    end
    return false
end

function ItemCompoundProxy:CheckCompoudListState(page1, page2)
    for pageIndex, itemList in pairs(self.showItemList) do
        if math.floor(pageIndex / 1000) == page1 and ((not page2) or page2 == pageIndex) then
            for k, v in pairs(itemList) do
                local isShow = self:GetCompoundStateByIndex(v.id)
                if isShow then
                    return isShow
                end
            end
        end
    end
    return false
end

function ItemCompoundProxy:GetPageIndexByID(id)
    if not id then
        return
    end
    for pageIndex, itemList in pairs(self.showItemList) do
        for k, v in pairs(itemList) do
            if v.id == id then
                return pageIndex
            end
        end
    end
    return nil
end

function ItemCompoundProxy:GetPageName(pageIndex)
    return self.pageName[pageIndex]
end

function ItemCompoundProxy:OnItemChange(Index, isAdd)
    local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
    local needThisMaterialList = self.compoundNeedList[Index]
    if needThisMaterialList and next(needThisMaterialList) then -- 材料对应的列表
        for id, count in pairs(needThisMaterialList) do
            local state = clone(self.compoundState[id]) -- 根据增删，对应检测 增 检测原来不满足 删 检测原来满足
            if (not state and isAdd) or (state and not isAdd) then
                local compoundData = self:GetCompoundConfigByIndex(id)
                local materialCost = compoundData.materialcost or {}
                local isCanCompound = true

                local hongdian = compoundData.hongdian
                if isCanCompound and hongdian then
                    if hongdian == -1 then
                        isCanCompound = false
                    else
                        isCanCompound = self:CheckStrConditions(hongdian)
                    end
                end

                local showcondition = compoundData.showcondition
                if isCanCompound and showcondition then
                    isCanCompound = self:CheckStrConditions(showcondition)
                end

                local posList = compoundData.posList

                if isCanCompound and next(materialCost) then
                    for _, costItem in pairs(materialCost) do
                        isCanCompound = PayProxy:CheckItemCount(costItem.id, costItem.count, true, true)
                        if not isCanCompound then
                            break
                        end
                    end
                end

                local moneyCost = compoundData.moneycost or {}
                if isCanCompound and next(moneyCost) then
                    for _, costItem in pairs(moneyCost) do
                        local moneyID = costItem.id
                        isCanCompound = PayProxy:CheckItemCount(moneyID, costItem.count, true, true)
                        if not isCanCompound then
                            break
                        end
                    end
                end
                local compCondition = compoundData.condition
                if isCanCompound and compCondition then
                    isCanCompound = self:CheckStrConditions(compCondition)
                end
                if isCanCompound then
                    self.redPoint = true
                end
                self.compoundState[id] = isCanCompound
            end
            local nowState = clone(self.compoundState[id])
            local upData = {
                stateChange = nowState,
                id = id,
                isAdd = isAdd
            }
            global.Facade:sendNotification(global.NoticeTable.Layer_CompoundItemLayer_Update, upData)
        end
    end
end

function ItemCompoundProxy:OnEquipChange(pos)
    local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
    local equipPosList = self.equipPosList[pos]
    if equipPosList and next(equipPosList) then -- 位置对应
        for id, count in pairs(equipPosList) do
            local state = clone(self.compoundState[id])
            local compoundData = self:GetCompoundConfigByIndex(id)
            local materialCost = compoundData.materialcost or {}
            local isCanCompound = true

            local showcondition = compoundData.showcondition
            if isCanCompound and showcondition then
                isCanCompound = self:CheckStrConditions(showcondition)
            end

            local hongdian = compoundData.hongdian
            if isCanCompound and hongdian then
                if hongdian == -1 then
                    isCanCompound = false
                else
                    isCanCompound = self:CheckStrConditions(hongdian)
                end
            end

            if isCanCompound and next(materialCost) then
                for _, costItem in pairs(materialCost) do
                    local checkEquipCount = (compoundData.posList and next(compoundData.posList))
                    isCanCompound = PayProxy:CheckItemCount(costItem.id, costItem.count, true, true)
                    if not isCanCompound then
                        break
                    end
                end
            end

            local moneyCost = compoundData.moneycost or {}
            if isCanCompound and next(moneyCost) then
                for _, costItem in pairs(moneyCost) do
                    local moneyID = costItem.id
                    isCanCompound = PayProxy:CheckItemCount(moneyID, costItem.count, true, true, false)
                    if not isCanCompound then
                        break
                    end
                end
            end
            local compCondition = compoundData.condition
            if isCanCompound and compCondition then
                isCanCompound = self:CheckStrConditions(compCondition)
            end
            if isCanCompound then
                self.redPoint = true
            end
            self.compoundState[id] = isCanCompound
            local nowState = clone(self.compoundState[id])
            local upData = {
                stateChange = state ~= nowState,
                id = id
            }
            global.Facade:sendNotification(global.NoticeTable.Layer_CompoundItemLayer_Update, upData)
        end
    end
end

function ItemCompoundProxy:OnMoneyChange(Index, isAdd)
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
    local needThisMoneyList = self.moneyNeedList[Index]
    if needThisMoneyList and next(needThisMoneyList) then -- 材料对应的列表
        for id, count in pairs(needThisMoneyList) do
            local state = clone(self.compoundState[id]) -- 根据增删，对应检测 增 检测原来不满足 删 检测原来满足
            if (not state and isAdd) or (state and not isAdd) then
                local compoundData = self:GetCompoundConfigByIndex(id)
                local materialCost = compoundData.materialcost or {}
                local isCanCompound = true

                local showcondition = compoundData.showcondition
                if isCanCompound and showcondition then
                    isCanCompound = self:CheckStrConditions(showcondition)
                end

                local hongdian = compoundData.hongdian
                if isCanCompound and hongdian then
                    if hongdian == -1 then
                        isCanCompound = false
                    else
                        isCanCompound = self:CheckStrConditions(hongdian)
                    end
                end

                if isCanCompound and next(materialCost) then
                    for _, costItem in pairs(materialCost) do
                        local checkEquipCount = (compoundData.posList and next(compoundData.posList))
                        isCanCompound = PayProxy:CheckItemCount(costItem.id, costItem.count, true, true)
                        if not isCanCompound then
                            break
                        end
                    end
                end

                local moneyCost = compoundData.moneycost or {}
                if isCanCompound and next(moneyCost) then
                    for _, costItem in pairs(moneyCost) do
                        local moneyID = costItem.id
                        isCanCompound = PayProxy:CheckItemCount(moneyID, costItem.count, true, true, true)
                        if not isCanCompound then
                            break
                        end
                    end
                end

                local compCondition = compoundData.condition
                if isCanCompound and compCondition then
                    isCanCompound = self:CheckStrConditions(compCondition)
                end

                if isCanCompound then
                    self.redPoint = true
                end
                self.compoundState[id] = isCanCompound
            end
            local nowState = clone(self.compoundState[id])
            local upData = {
                stateChange = state ~= nowState,
                id = id
            }
            global.Facade:sendNotification(global.NoticeTable.Layer_CompoundItemLayer_Update, upData)
        end
    end
end
--[[
    避免货币频繁变动导致检测过于频繁
    10秒内不重复检测
    CD内的变动在delay中检测
]]
function ItemCompoundProxy:OnMoneyChangeCount(Index, count)
    local serverTime = GetServerTime()
    if Index == 2 then -- 元宝类型改成绑定元宝类型检测（消耗货币只检测绑定元宝， 但是元宝又可以和绑定元宝一起消耗）
        Index = 4
    end
    self.changeMoneyList[Index] = count
    if not self.onMoneyChangeUpdate then
        PerformWithDelayGlobal(function()
            local nowServerTime = GetServerTime()
            for k, v in pairs(self.changeMoneyList) do
                local oldCount = self.lastCheckMoneyCount[k] or 0
                local newCount = v
                if v ~= oldCount then
                    self:OnMoneyChange(k, v > oldCount)
                end
                self.lastCheckMoneyCount[k] = newCount
            end

            self.changeMoneyList = {}
            self.lastCheckMoneyTime = nowServerTime
            self.onMoneyChangeUpdate = nil
        end, 5)
        self.onMoneyChangeUpdate = true
    end
    if serverTime > (self.lastCheckMoneyTime + 5) or serverTime < self.lastCheckMoneyTime then
        for k, v in pairs(self.changeMoneyList) do
            local oldCount = self.lastCheckMoneyCount[k] or 0
            local newCount = v
            if v ~= oldCount then
                self:OnMoneyChange(k, v > oldCount)
            end
            self.lastCheckMoneyCount[k] = newCount
        end

        self.changeMoneyList = {}
        self.lastCheckMoneyTime = serverTime
    end
end

function ItemCompoundProxy:SetOnCompoundIndex(Index)
    self.onCompoundIndex = Index
end

function ItemCompoundProxy:GetOnCompoundIndex()
    return self.onCompoundIndex
end

function ItemCompoundProxy:GetOnCompoundData()
    local onCompoundIndex = self:GetOnCompoundIndex()
    local data = self:GetCompoundConfigByIndex(onCompoundIndex)
    return data
end

function ItemCompoundProxy:CheckCompoudState()
    return self.redPoint
end

function ItemCompoundProxy:GetCompoundStateByIndex(Index)
    return self.compoundState[Index]
end
function ItemCompoundProxy:GetCompoundConfig()
    return self.config
end

function ItemCompoundProxy:GetShowItemList(menulayertype)
    local typeList = {}
    menulayertype = menulayertype or 0
    for k, list in pairs(self.showItemList) do
        for i, item in ipairs(list) do
            local itemMenulayertype = item.menulayertype or 0
            if itemMenulayertype == menulayertype then
                if not typeList[k] then
                    typeList[k] = {}
                end
                table.insert(typeList[k], item)
            end
        end
    end

    local sortTypeList = {}
    if typeList and next(typeList) then
        for k, v in pairs(typeList) do
            if #v > 1 then
                table.sort(v, function(item1, item2)
                    return item1.page3 < item2.page3
                end)
            end
            sortTypeList[k] = v
        end
    else
        sortTypeList = typeList
    end

    return sortTypeList
end

function ItemCompoundProxy:GetShowItemListByIndex(PageIndex, menulayertype)
    local pageData = self:GetShowItemList(menulayertype)
    return pageData[PageIndex]
end

function ItemCompoundProxy:GetCompoundConfigByIndex(Index)
    return self.configByIndex[Index]
end

function ItemCompoundProxy:GetCompoundEffect(Index)
    return self.effectList[Index]
end

function ItemCompoundProxy:CheckIsCanCompoud(item, isTips, isSystemTips)
    if not item then
        return
    end
    local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local materialCost = item.materialcost or {}
    local compoundCount = nil
    local takeoffPlayerEquip = {}

    if isTips ~= true then
        isTips = false
    end

    local checkEquipCount = (item.posList and next(item.posList))
    if next(materialCost) then
        for _, costItem in pairs(materialCost) do
            local costDataNotips = {
                itemID = costItem.id,
                itemNum = costItem.count,
                noTips = true
            }
            local isCanCompound = CheckItemCountEnoughEX(costDataNotips)
            local costDataWithEquip = {
                itemID = costItem.id,
                itemNum = costItem.count,
                equipCount = checkEquipCount,
                noTips = true
            }
            local itemWithEquip = CheckItemCountEnoughEX(costDataWithEquip)
            if not itemWithEquip and not isCanCompound then
                local costData = {
                    itemID = costItem.id,
                    itemNum = costItem.count,
                    equipCount = checkEquipCount,
                    noTips = not isTips,
                    errorTitle = isSystemTips and GET_STRING(90090011) or nil
                }
                CheckItemCountEnoughEX(costData)
                return false
            end
            local itemHaveNum = PayProxy:GetItemCount(costItem.id, true)
            local canCompoundCount = math.floor(itemHaveNum / costItem.count)
            compoundCount = compoundCount and math.min(compoundCount, canCompoundCount) or canCompoundCount
        end
    end

    local moneyCost = item.moneycost or {}
    if next(moneyCost) then
        for _, costItem in pairs(moneyCost) do
            local costData = {
                itemID = costItem.id,
                itemNum = costItem.count,
                noTips = not isTips,
                bOneID = true,
                errorTitle = isSystemTips and GET_STRING(90090011) or nil
            }
            local isCanCompound = CheckItemCountEnoughEX(costData)
            if not isCanCompound then
                return false
            end
            local itemHaveNum = PayProxy:GetItemCount(costData.itemID, true)
            local canCompoundCount = math.floor(itemHaveNum / costItem.count)
            compoundCount = compoundCount and math.min(compoundCount, canCompoundCount) or canCompoundCount
        end
    end

    local condition = item.condition
    if condition then
        if not self:CheckStrConditions(condition) then
            return false
        end
    end

    local itemProduct = item.product
    if not itemProduct or itemProduct == "" then
        return false
    end

    local needPos = 0
    local itemArray = string.split(itemProduct, "&")
    for i, itemGet in ipairs(itemArray) do
        if itemGet and itemGet ~= "" then
            local itemGetData = string.split(itemGet, "#")
            local itemID = tonumber(itemGetData[1])
            local itemCount = tonumber(itemGetData[2])
            local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
            local itemData = ItemConfigProxy:GetItemDataByIndex(itemID)
            local isLap = ItemConfigProxy:CheckItemOverLap(itemData)
            if itemID > 100 then -- 货币占格子
                if isLap then
                    needPos = needPos + 1 -- math.ceil(itemCount/itemData.OverLap)
                else
                    needPos = needPos + itemCount
                end
            end
        end
    end

    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local bagItemNum = BagProxy:GetTotalItemCount()
    local maxBag = BagProxy:GetMaxBag()
    if bagItemNum + needPos > maxBag then
        if isSystemTips then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(800050))
        end
        return false
    end
    return true, compoundCount, takeoffPlayerEquip
end

function ItemCompoundProxy:RequestCompound()
    local item = self:GetOnCompoundData()
    if not item then
        return
    end
    local compoundID = item.id
    local isCanCompound, compoudNum, equipList = self:CheckIsCanCompoud(item, true, true)
    if not isCanCompound then
        return
    end

    local itemGet = item.product
    local itemGetData = string.split(itemGet, "#")
    local itemID = tonumber(itemGetData[1])
    local itemCount = tonumber(itemGetData[2])
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    local itemData = ItemConfigProxy:GetItemDataByIndex(itemID)
    local isEquip = ItemManagerProxy:GetItemTypeByStdMode(itemData.StdMode) == ItemManagerProxy.ItemType.Equip

    if item.hecheng and item.hecheng > 0 and compoudNum > 1 then
        local function callback(num)
            num = tonumber(num)
            if not num or num <= 0 then
                return
            end
            if num > compoudNum then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(90020007))
            else
                self:SureCompound(item, num, equipList)
            end
        end

        local itemShwoArray = string.split(item.shwo or "", "#")
        local produceItemID = tonumber(itemShwoArray[1])
        local count = tonumber(itemShwoArray[2])

        local data = {}
        data.title = GET_STRING(90090012)
        data.maxNum = compoudNum
        data.callback = callback
        data.Index = produceItemID
        data.count = count
        data.notValidTitle = GET_STRING(90020007)
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonNumber_Open, data)
    else
        compoudNum = 1
        self:SureCompound(item, compoudNum, equipList)
    end
end

function ItemCompoundProxy:SureCompound(item, num, equipList)
    if item.confirmtype and item.confirmtype > 0 then
        local function callback(btnType)
            if btnType == 1 then
                self:ChooseItemToCompound(item, num, equipList)
            end
        end
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        local produceItem = item.shwo
        local produceItemName = item.page3name
        if not produceItemName or produceItemName == "" then
            local produceItemID = tonumber(string.split(produceItem, "#")[1])
            produceItemName = ItemConfigProxy:GetItemName(produceItemID)
        end
        local data = {}
        data.str = string.format(GET_STRING(90090002), SL:GetMetaValue("GAME_DATA", "DEFAULT_FONT_SIZE"), produceItemName)
        data.callback = callback
        data.btnType = 2
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
    else
        self:ChooseItemToCompound(item, num, equipList)
    end
end

function ItemCompoundProxy:ChooseItemToCompound(item, num, equipList)
    local isShowChooseLayer = item.choice
    local compoundID = item.id
    --[[
        需要玩家选择的道具
        规则逻辑
            所需的装备材料如果多 不能合 必须材料数刚好满足
            选择了
            - > 合成
    ]]
    if isShowChooseLayer and isShowChooseLayer == 1 then
        local needItems = item.materialcost
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)

        for k, v in pairs(needItems) do
            local itemID = v.id
            local itemData = ItemConfigProxy:GetItemDataByIndex(itemID)
            local isEquip = ItemManagerProxy:GetItemTypeByStdMode(itemData.StdMode) == ItemManagerProxy.ItemType.Equip
            if isEquip then
                local hasCount = GetItemDataNumber(itemID, {
                    equip = true,
                    specialMoney = true
                })
                local needCount = v.count
                if hasCount ~= needCount then
                    ShowSystemTips(GET_STRING(90090004))
                    return
                end
            end
        end
    end

    if equipList and next(equipList) then
        for k, v in pairs(equipList) do
            global.Facade:sendNotification(global.NoticeTable.TakeOffRequest, v)
        end
    end
    self:requestCompoundJson(compoundID)
end

-- 检测红点
function ItemCompoundProxy:BadgeCheckFunc(type)
    local checkType = type or 0
    for i, v in pairs(self.compoundState) do
        local config = self:GetCompoundConfigByIndex(i) or {}
        local itemType = config.menulayertype or 0
        if v and itemType == checkType then
            return true
        end
    end
    return false
end

-- 打开不同的合成通知一下脚本
function ItemCompoundProxy:requestCompoundChangeJson(data)
    print("=========打开不同的合成Json： id, methods, data: ", global.JsonMsgType.CompoundChange,
        global.ActMessageTable.CompoundItem, data)
    global.JsonProtoHelper:SendMsg(global.JsonMsgType.CompoundChange, 1, global.ActMessageTable.CompoundItem, nil, data)
end

function ItemCompoundProxy:requestCompoundJson(data)
    print("=========请求合成Json： id, methods, data: ", global.JsonMsgType.CompoundItem,
        global.ActMessageTable.CompoundItem, data)
    global.JsonProtoHelper:SendMsg(global.JsonMsgType.CompoundItem, 1, global.ActMessageTable.CompoundItem, nil, data)
end

function ItemCompoundProxy:event(data)

    print("=========接收合成Json： id, methods, data: ", data)
    if not data then
        return
    end
    dump(data, "__SS")
    local recog = data.recog
    local id = data.param1

    if recog == 0 then
        -- success
        local cfg = id and self:GetCompoundConfigByIndex(id) or {}
        global.Facade:sendNotification(global.NoticeTable.SystemTips, cfg.CGmessage or "")
    elseif recog == -1 or recog == -2 then
        -- failed
        local cfg = id and self:GetCompoundConfigByIndex(id) or {}
        global.Facade:sendNotification(global.NoticeTable.SystemTips, cfg.SBmessage or "")
    end
end

function ItemCompoundProxy:RegisterMsgHandler()
    ItemCompoundProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    global.JsonProtoHelper:RegisterJsonHandler(global.JsonMsgType.CompoundItem, self)
end

return ItemCompoundProxy
