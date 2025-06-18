local BagData = class("BagData")

--[[   README:
   后端不存储背包位置信息 所以需要前端自己储存位置信息
   位置信息保存:
      存本地及内存 增删改变位置信息
      新加入默认存第一空位 若大于40则存入缓存
      服务器实际背包大小为52  40背包 12缓存和快捷栏（缓存数为0-12快捷栏上限为6
      背包显示40 如果背包删后小于40 并且缓存中有存在 则补充至背包至上限
      快捷栏保存道具类型，由于没有类型 存名字 快捷栏拖入时存 脱出或者背包没有同类型道具可以补充时删
]]
function BagData:ctor()
    self.bagVo = {}   --背包数据
    self.posData = {} --背包位置相关数据
    self.quickUseVo = {}  --快捷栏数据
    self.noPosVo = {}  --缓存数据
    self.isInit = false
    self.posMark = {}    --背包位置信息标记
    self.quickUsePosMark = {}  --快捷栏位置信息
    self.bagMax = global.MMO.MAX_ITEM_NUMBER
    self.itemCount = 0
    self.itemCountByIndex = {}

    self.lastPosMark = {}  -- 记录分批背包数据上次存储位置

    self:InitBagPosMark()

end

function BagData:InitBagPosMark()
    local bagPosData = self:GetPosMarkData()
    if bagPosData then
        self.posMark = bagPosData
    else
        for i = 1, self.bagMax do
            self.posMark[i] = 0
        end
    end
end

function BagData:SetMaxBag(maxBag)
    self.bagMax = maxBag
end

function BagData:GetMaxBag()
    return self.bagMax or 0
end

function BagData:SetNewPosMark()
    local newPosMark = {}
    for i = 1, self.bagMax do
        if not self.posMark[i] or self.posMark[i] == 0 then
            newPosMark[i] = 0
        else
            newPosMark[i] = self.posMark[i]
        end
    end
    self.posMark = newPosMark
end

function BagData:AmendHistoryPos(data, sort, startIndex, endIndex)
    if not data then
        return
    end

    local newPosMark = {}
    local newItems = {}

    startIndex = startIndex or 1
    endIndex = endIndex or self.bagMax
    for i = 1, self.bagMax do
        if not self.posMark[i] or self.posMark[i] == 0 then
            newPosMark[i] = 0
        else
            if i >= startIndex and i <= endIndex then
                if not sort and self.lastPosMark[i] then
                    newPosMark[i] = self.posMark[i]
                else
                    newPosMark[i] = 0
                end
            else
                newPosMark[i] = self.posMark[i]
            end
        end
    end

    if next(data) == nil then
        self.posMark = newPosMark
        self:SetPosMarkData()
        return
    end

    for k, item in pairs(data) do
        local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
        local quickUsePos = QuickUseProxy:CheckIsInQucikUseList(item)
        if not quickUsePos then
            local historyPos = self:GetHistoryPos(item.MakeIndex)
            if historyPos then
                newPosMark[historyPos] = item.MakeIndex
                self.posData[item.MakeIndex] = historyPos
                self.lastPosMark[historyPos] = item.MakeIndex
            else
                table.insert(newItems, item)
            end
        else
            local bagPos = self.posData and self.posData[item.MakeIndex]
            if bagPos then
                print("=====bag and quickuse have same makeindex:  quickUsePos:  bagPos:  ", item.MakeIndex, quickUsePos, bagPos)
            end
        end
    end

    local function GetNewPos()
        for i = 1, self.bagMax do
            if not newPosMark[i] or newPosMark[i] == 0 then
                return i
            end
        end
        return nil
    end

    if sort then
        if newItems and next(newItems) and #newItems > 1 then
            table.sort(newItems, function(a, b)
                if a.Index ~= b.Index then
                    return a.Index < b.Index
                else
                    return a.MakeIndex < b.MakeIndex
                end
            end)
        end

        for k, v in pairs(newItems) do
            local newPos = GetNewPos()
            if newPos then
                newPosMark[newPos] = v.MakeIndex
                self.posData[v.MakeIndex] = newPos
            else
                self.noPosVo[v.MakeIndex] = v
            end
        end
    else
        for k, v in pairs(newItems) do
            local newPos = GetNewPos()
            if newPos then
                newPosMark[newPos] = v.MakeIndex
                self.posData[v.MakeIndex] = newPos
                self.lastPosMark[newPos] = v.MakeIndex
            else
                self.noPosVo[v.MakeIndex] = v
            end
        end
    end

    self.posMark = newPosMark

    self:SetPosMarkData()
end

function BagData:IsInited()
    return self.isInit
end

function BagData:Inited(bool)
    self.isInit = bool
end

function BagData:GetBagData()
    return self.bagVo
end

function BagData:isFull()
    --没有新位置即为背包满了
    local pos = self:NewItemPos()
    return not pos
end

function BagData:GetItemByMakeIndex(MakeIndex)
    local data = nil
    if self.bagVo[MakeIndex] then
        data = self.bagVo[MakeIndex]
    elseif self.noPosVo[MakeIndex] then
        data = self.noPosVo[MakeIndex]
    end
    return data
end

function BagData:AddItem(item, pos)
    local MakeIndex = item.MakeIndex
    if pos then
        if not self.bagVo[MakeIndex] then
            self.itemCount = self.itemCount + 1
        end
        self.bagVo[MakeIndex] = item
        self.noPosVo[MakeIndex] = nil
    else
        self.noPosVo[MakeIndex] = item
    end

    self:ChangeItemCountByIndex(item.Index, item.OverLap)
end

function BagData:SubItem(MakeIndex)
    if self.bagVo[MakeIndex] then
        local item = self.bagVo[MakeIndex]
        self:ChangeItemCountByIndex(item.Index, -item.OverLap)
        self.bagVo[MakeIndex] = nil
        self.itemCount = self.itemCount - 1
    elseif self.noPosVo[MakeIndex] then
        local item = self.noPosVo[MakeIndex]
        self:ChangeItemCountByIndex(item.Index, -item.OverLap)
        self.noPosVo[MakeIndex] = nil
    end
end

function BagData:ChangeItem(item)
    local MakeIndex = item.MakeIndex
    local diffnum = 0
    if self.bagVo[MakeIndex] then
        local newNum = item.OverLap or 1
        local oldNum = self.bagVo[MakeIndex].OverLap or 1
        diffnum = newNum - oldNum
        self.bagVo[MakeIndex] = item
    elseif self.noPosVo[MakeIndex] then
        local newNum = item.OverLap or 1
        local oldNum = self.noPosVo[MakeIndex].OverLap or 1
        diffnum = newNum - oldNum
        self.noPosVo[MakeIndex] = item
    end
    self:ChangeItemCountByIndex(item.Index, diffnum)
    return diffnum
end

function BagData:SetItemPosData(MakeIndex, pos)
    self.posData[MakeIndex] = pos
    if pos then
        self.posMark[pos] = MakeIndex
        self:DelaySetPosMarkData()
    end
end

function BagData:CleanItemPosData(MakeIndex)
    local historyPos = self.posData[MakeIndex]
    if historyPos then
        self.posMark[historyPos] = 0
        self:DelaySetPosMarkData()
    end
    self.posData[MakeIndex] = nil
end

function BagData:DelaySetPosMarkData()
    if self._delayTimerID then
        UnSchedule(self._delayTimerID)
        self._delayTimerID = nil
    end

    self._delayTimerID = PerformWithDelayGlobal(function()
        self:SetPosMarkData()
        self._delayTimerID = nil
    end, 0.5)
end

function BagData:NewItemPos()
    for i = 1, self.bagMax do
        if self.posMark[i] and self.posMark[i] == 0 then
            return i
        end
    end
    return nil
end

function BagData:GetMakeIndexByBagPos(pos)
    for k, v in pairs(self.posData) do
        if v == pos then
            return k
        end
    end
    return nil
end

function BagData:GetBagDataByBagPos(startPos, endPos)
    local data = {}
    for MakeIndex, pos in pairs(self.posData) do
        if pos >= startPos and pos <= endPos then
            local itemData = self:GetItemByMakeIndex(MakeIndex)
            data[MakeIndex] = itemData
        end
    end
    return data
end

function BagData:GetBagNoPosData()
    return self.noPosVo
end

function BagData:GetBagNoPosDataByMakeIndex(MakeIndex)
    return self.noPosVo[MakeIndex]
end

function BagData:GetBagPosByMakeIndex(MakeIndex)
    return self.posData[MakeIndex]
end

function BagData:ChangeItemCountByIndex(Index, diff)
    if not Index then
        return
    end
    if not self.itemCountByIndex then
        self.itemCountByIndex = {}
    end
    local diffCount = diff or 0
    local oldCount = self.itemCountByIndex[Index] or 0
    local newCount = oldCount + diffCount
    self.itemCountByIndex[Index] = newCount > 0 and newCount or 0
end

function BagData:GetItemCountByIndex(Index)
    if not self.itemCountByIndex then
        self.itemCountByIndex = {}
    end
    local count = clone(self.itemCountByIndex[Index] or 0)
    return count
end

function BagData:ClearItemData()
    self.bagVo = {}
    self.noPosVo = {}
    self.itemCount = 0
    self.itemCountByIndex = {}
    self.posData = {}
    self.lastPosMark = {}
end

function BagData:GetItemCount()
    return self.itemCount
end

function BagData:GetHistoryPos(MakeIndex)
    for k, v in pairs(self.posMark) do
        if v == MakeIndex then
            return k
        end
    end
    return nil
end

function BagData:CleanBagPosData()
    self.posMark = {}
    for i = 1, self.bagMax do
        self.posMark[i] = 0
    end
    self.posData = {}
    self:SetPosMarkData()
end

--背包
function BagData:GetPosMarkData()
    local PosData = UserData:new("BagPosData")
    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local flag = proxy:GetSelectedRoleID() or "errorName"
    local clientData = PosData:getStringForKey("bag" .. flag)

    if not clientData or clientData == "" then
        return nil
    end
    local cjson = require("cjson")
    local lastJsonData = cjson.decode(clientData)
    return lastJsonData
end

function BagData:SetPosMarkData()

    local PosData = UserData:new("BagPosData")
    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local flag = proxy:GetSelectedRoleID() or "errorName"
    local cjson = require("cjson")
    local bagPosData = cjson.encode(self.posMark)
    local clientData = PosData:setStringForKey("bag" .. flag, bagPosData)

end

return BagData