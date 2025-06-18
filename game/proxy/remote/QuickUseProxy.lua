local RemoteProxy    = requireProxy("remote/RemoteProxy")

local QuickUseProxy = class("QuickUseProxy", RemoteProxy)
QuickUseProxy.NAME = global.ProxyTable.QuickUseProxy

--数据全部来自背包
function QuickUseProxy:ctor()
    QuickUseProxy.super.ctor(self)
    self.ItemBelongType = global.MMO.ITEM_FROM_BELONG_QUICKUSE
    self.quickUseData = {}  --具体数据 key:pos v:itemData
    self.quickUseList = {}  --初始化的时候读取本地列表用
    self.quickUseSize = global.MMO.QUICK_USE_SIZE
    self.quickUsableList = nil
    self:InitQuickUseHistoryData()
end

function QuickUseProxy:InitQuickUseHistoryData()
    local historyData = self:GetQuickUsePosMarkData()
    if historyData and next(historyData) then
        for k, v in ipairs(historyData) do
            self.quickUseList[k] = v
        end
    end
    for i = 1, self.quickUseSize do -- 自动补全
        if not self.quickUseList[i] then
            self.quickUseList[i] = 0
        end
    end
    local AttrConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.AttrConfigProxy)
    local QuickUsable = AttrConfigProxy:GetItemsConfigQuickUsable()
    self.quickUsableList = QuickUsable
end

--历史数据修正
function QuickUseProxy:RequireHistoryQuickyUseList()
    local newList = {}
    for i = 1, self.quickUseSize do
        newList[i] = 0
    end

    for k, v in pairs(self.quickUseList) do
        local data = self:GetQucikUseDataByMakeIndex(v)
        if data and k <= self.quickUseSize then -- 因为多平台原因 不同平台格子数变化
            newList[k] = v
        end
    end
    self.quickUseList = newList
    self:SetQuickPosMarkData()
end

function QuickUseProxy:CheckIsInQucikUseList(item)
    if item and item.MakeIndex then
        for k, v in pairs(self.quickUseList) do
            if v == item.MakeIndex then
                return k
            end
        end
    end
    return false
end

function QuickUseProxy:AutoAddBagItemToQuick(item, pos)
    if not item or next(item) == nil or not pos then
        return
    end
    local posData = self:GetQucikUseDataByPos(pos)
    if posData then
        return
    end
    local autoAddItemMakeIndex = nil
    local itemIndex = item.Index
    local itemData = nil
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local sameItems = BagProxy:GetItemDataByItemIndex(itemIndex)
    if sameItems and next(sameItems) then
        itemData = sameItems[1]
        autoAddItemMakeIndex = itemData.MakeIndex
    end
    if itemData and autoAddItemMakeIndex and autoAddItemMakeIndex ~= 0 then
        local Bag = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        Bag:DelItemData(itemData) -- 从背包中移除

        self:SetQuickUsePosData(pos, itemData)
    end
end

function QuickUseProxy:CheckQuickUseHasEmpty()
    local size = self.quickUseSize or 6
    for i = 1, size do
        if not self.quickUseList[i] or self.quickUseList[i] <= 0 then
            return i
        end
    end
    return false
end

function QuickUseProxy:CheckItemCanAddToQuickUse(itemData)
    if not itemData or not next(itemData) then
        return false
    end
    local itemStdMode = itemData.StdMode
    if itemStdMode and self.quickUsableList[itemStdMode] then
        return true
    end
    return false
end

function QuickUseProxy:GetQucikUsePosByMakeIndex(MakeIndex)
    if not MakeIndex then
        return false
    end
    local size = self.quickUseSize or 6
    for i = 1, size do
        if self.quickUseList[i] and self.quickUseList[i] == MakeIndex then
            return i
        end
    end
    return false
end

function QuickUseProxy:GetItemCountByIndex(Index)
    local itemList = 0
    if not Index then
        return itemList
    end
    for k, v in pairs(self.quickUseData) do
        if v.Index == Index then
            local count = v.OverLap and v.OverLap or 1
            itemList = itemList + count
        end
    end
    return itemList
end

function QuickUseProxy:GetQucikUseDataByMakeIndex(MakeIndex)
    if not MakeIndex then
        return false
    end
    for k, v in pairs(self.quickUseData) do
        if v.MakeIndex == MakeIndex then
            return v
        end
    end
    return false
end

function QuickUseProxy:GetQucikUseDataByPos(position)
    if not position then
        return false
    end
    return self.quickUseData[position]
end

function QuickUseProxy:GetQuickUseData()
    return self.quickUseData
end

function QuickUseProxy:GetQuickUseLocalList()
    return self.quickUseList
end

function QuickUseProxy:GetQucikUseDataByIndex(Index)
    local itemList = {}
    if not Index then
        return itemList
    end
    for k, v in pairs(self.quickUseData) do
        if v.Index == Index then
            table.insert(itemList, v)
        end
    end
    return itemList
end

function QuickUseProxy:GetQuickUseItemNum(Index, famlilar)
    Index = Index or 0
    local count = 0
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local isBind, bindIndex = ItemConfigProxy:CheckItemBind(Index)

    local function GetQucikUseNumByIndex(ItemIndex)
        local itemCount = 0
        local itemList = self:GetQucikUseDataByIndex(ItemIndex)
        if itemList and next(itemList) then
            for k, v in pairs(itemList) do
                local itemNum = v.OverLap > 0 and v.OverLap or 1
                itemCount = itemCount + itemNum
            end
        end
        return itemCount
    end

    local myCount = GetQucikUseNumByIndex(Index)
    local famlilarCount = 0
    if isBind and bindIndex ~= Index and famlilar then
        famlilarCount = GetQucikUseNumByIndex(bindIndex)
    end
    local totalCount = myCount + famlilarCount
    return totalCount
end

function QuickUseProxy:UpDateQuickUseItemData(item)
    if not item then
        return
    end
    local MakeIndex = item.MakeIndex
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local pos = self:GetQucikUsePosByMakeIndex(MakeIndex)
    if pos and self.quickUseData[pos] then
        local oldNum = self.quickUseData[pos].OverLap or 1
        local newNum = item.OverLap or 1
        local changeNum = newNum - oldNum
        if changeNum ~= 0 then
            BagProxy:ShowGetOrCostItems(changeNum, item.Name)
        end
        self.quickUseData[pos] = item
        local msgData = {
            index = pos,
            itemData = item,
            isAdd = changeNum and changeNum > 0 
        }
        global.Facade:sendNotification(global.NoticeTable.QuickUseItemChange, msgData)
        ssr.ssrBridge:OnQuickUseOperData({ opera = 3, param = msgData })
        SLBridge:onLUAEvent(LUA_EVENT_QUICKUSE_DATA_OPER, {opera = 3, param = msgData})
    end
end

function QuickUseProxy:SetQuickUsePosData(pos, data, isDelete)
    self.quickUseData[pos] = (not isDelete) and data or nil

    self.quickUseList[pos] = (not isDelete) and data.MakeIndex or 0

    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    ItemManagerProxy:SetItemBelong(data.MakeIndex, (not isDelete) and self.ItemBelongType or nil)

    self:SetQuickPosMarkData()

    local msgData = {
        index = pos,
        itemData = data
    }
    local notice = isDelete and global.NoticeTable.QuickUseItemRmv or global.NoticeTable.QuickUseItemAdd
    global.Facade:sendNotification(notice, msgData)
    ssr.ssrBridge:OnQuickUseOperData({opera = isDelete and 2 or 1, param = msgData})
    SLBridge:onLUAEvent(LUA_EVENT_QUICKUSE_DATA_OPER, {opera = isDelete and 2 or 1, param = msgData})
end

--快捷栏
function QuickUseProxy:GetQuickUsePosMarkData()
    local PosData = UserData:new("BagPosData")
    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local flag = proxy:GetSelectedRoleID() or "errorName"
    local clientData = PosData:getStringForKey("quickUse" .. flag)

    if not clientData or clientData == "" then
        return nil
    end
    local cjson = require("cjson")
    local lastJsonData = cjson.decode(clientData)
    return lastJsonData
end

function QuickUseProxy:SetQuickPosMarkData()
    local PosData = UserData:new("BagPosData")
    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local flag = proxy:GetSelectedRoleID() or "errorName"
    local cjson = require("cjson")
    local bagPosData = cjson.encode(self.quickUseList)
    local clientData = PosData:setStringForKey("quickUse" .. flag, bagPosData)
end

function QuickUseProxy:GetQuickUseItemTotalCount()
    local size = self.quickUseSize or 6
    local count = 0
    for i = 1, size do
        if self.quickUseList[i] and self.quickUseList[i] > 0 then
            count = count + 1
        end
    end
    return count
end

function QuickUseProxy:GetQuickUseItemLeftNum()
    local size = self.quickUseSize or 6
    local count = self:GetQuickUseItemTotalCount()
    return size - count
end

function QuickUseProxy:SetQuickUseSize(num)
    if num and tonumber(num) then
        num = math.max(math.min(num, 6), 0)
        self.quickUseSize = tonumber(num)
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        if BagProxy:GetServerBagNum() ~= 0 then
            local maxBag = BagProxy:GetServerBagNum() + global.MMO.QUICK_USE_SIZE - self.quickUseSize
            BagProxy:SetMaxBag(maxBag)
        end
    end
end

function QuickUseProxy:GetQuickUseSize(num)
    return self.quickUseSize
end

function QuickUseProxy:onRegister()
    QuickUseProxy.super.onRegister(self)
end

return QuickUseProxy