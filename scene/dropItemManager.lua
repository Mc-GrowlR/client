local dropItemManager = class('dropItemManager')

local tSort = table.sort
local mAbs  = math.abs

local KEY_MAP_XY = KEY_MAP_XY

function dropItemManager:ctor()
    self.mDropItemMapXYInCurrViewField = {}
    self.mDropItemInCurrViewFieldMap = {}
    self.mDropItemInCurrViewField = {}
    self.mDropItemIndexMap = {}
    self.mDropItemCount = 0
end

function dropItemManager:destory()
    if dropItemManager.instance then
        dropItemManager.instance = nil
    end
end

function dropItemManager:Inst()
    if not dropItemManager.instance then
        dropItemManager.instance = dropItemManager.new()
    end

    return dropItemManager.instance
end

function dropItemManager:Cleanup()
    self.mDropItemMapXYInCurrViewField = {}
    self.mDropItemInCurrViewFieldMap = {}
    self.mDropItemInCurrViewField = {}
    self.mDropItemIndexMap = {}
    self.mDropItemCount = 0
end

function dropItemManager:FindDropItem(id)
    return self.mDropItemInCurrViewFieldMap[id]
end

function dropItemManager:AddDropItem(item)
    if not item then
        return false
    end

    local itemID = item:GetID()

    if self.mDropItemInCurrViewFieldMap[itemID] then
        return false
    end

    self.mDropItemCount = self.mDropItemCount + 1

    local n = self.mDropItemCount

    self.mDropItemIndexMap[itemID] = n

    self.mDropItemInCurrViewField[n] = item

    self.mDropItemInCurrViewFieldMap[itemID] = item

    local point = KEY_MAP_XY(item:GetMapX(), item:GetMapY())
    if not self.mDropItemMapXYInCurrViewField[point] then
        self.mDropItemMapXYInCurrViewField[point] = {}
    end
    self.mDropItemMapXYInCurrViewField[point][itemID] = item
end

function dropItemManager:RmvDropItem(itemID)
    local item = self.mDropItemInCurrViewFieldMap[itemID]

    if not item then
        return false
    end

    self.mDropItemInCurrViewFieldMap[itemID] = nil

    local index = self.mDropItemIndexMap[itemID]
    if index == self.mDropItemCount then
        self.mDropItemInCurrViewField[index] = nil
    else
        -- last index --> index
        local lastActor = self.mDropItemInCurrViewField[self.mDropItemCount]
        self.mDropItemInCurrViewField[index] = lastActor
        self.mDropItemIndexMap[lastActor:GetID()] = index

        -- reset last value
        self.mDropItemInCurrViewField[self.mDropItemCount] = nil
    end

    self.mDropItemIndexMap[itemID] = nil
    self.mDropItemCount = self.mDropItemCount - 1

    local point = KEY_MAP_XY(item:GetMapX(), item:GetMapY())
    local itemMapXY = self.mDropItemMapXYInCurrViewField[point][itemID]
    if not itemMapXY then
        return false
    end
    self.mDropItemMapXYInCurrViewField[point][itemID] = nil
end

function dropItemManager:FindDropItemInCurrViewField(range, sortNearToFarFromPlayer, ownerID)
    if range then
        return self:FindDropItemInCurrViewFieldByRange(range, sortNearToFarFromPlayer, ownerID)
    end
    return self:FindDropItemInCurrViewFieldAll()
end

function dropItemManager:FindDropIDInCurrViewField(range, sortNearToFarFromPlayer, ownerID)
    if range then
        local itemRecvVec, num = self:FindDropItemInCurrViewFieldByRange(range, sortNearToFarFromPlayer, ownerID)
        local recvVec = {}
        for i, v in ipairs(itemRecvVec) do
            recvVec[i] = v:GetID()
        end
        return recvVec, num
    end
    local recvVec = {}
    local num = 0

    for i = 1, self.mDropItemCount do
        local m = self.mDropItemInCurrViewField[i]
        if m then
            num = num + 1
            recvVec[num] = m:GetID()
        end
    end

    return recvVec, num
end

function dropItemManager:FindDropItemInCurrViewFieldAll()
    return self.mDropItemInCurrViewField, self.mDropItemCount
end

function dropItemManager:FindDropItemInCurrViewFieldByRange(range, sortNearToFarFromPlayer, ownerID)
    if nil == sortNearToFarFromPlayer then 
        sortNearToFarFromPlayer = false 
    end

    if nil == ownerID then 
        ownerID = global.MMO.ACTOR_ID_INVALID 
    end

    local recvVec = {}
    local num = 0

    -- Find any items in range
    local function inRange(a, range)
        if -1 == range then return true end 

        local p  = global.gamePlayerController:GetMainPlayer()
        local mX = p:GetMapX()
        local mY = p:GetMapY()
        local dX = a:GetMapX() - mX
        local dY = a:GetMapY() - mY
        local diffA = (mAbs(dX) > mAbs(dY)) and mAbs(dX) or mAbs(dY)    

        return diffA <= range 
    end 

    for i = 1, self.mDropItemCount do
        local m = self.mDropItemInCurrViewField[i]
        if m and (global.MMO.ACTOR_ID_INVALID == ownerID or m:CheckOwnerID(ownerID)) and inRange(m, range) then
            num = num + 1
            recvVec[num] = m
        end
    end

    -- Need to sort ?
    if sortNearToFarFromPlayer and num > 1 then
        local  p  = global.gamePlayerController:GetMainPlayer()
        local  mX = p:GetMapX()
        local  mY = p:GetMapY()
        local function distCmp(a, b)   
            local dX = a:GetMapX() - mX
            local dY = a:GetMapY() - mY
            local diffA = (mAbs(dX) > mAbs(dY)) and mAbs(dX) or mAbs(dY)

            dX = b:GetMapX() - mX
            dY = b:GetMapY() - mY
            local diffB = (mAbs(dX) > mAbs(dY)) and mAbs(dX) or mAbs(dY)

            return diffA < diffB 
        end 
        tSort(recvVec, distCmp)
    end

    return recvVec, num
end

function dropItemManager:FindDropItemAllInMapXY(X, Y)
    local point = KEY_MAP_XY(X, Y)
    local itemMapXY = self.mDropItemMapXYInCurrViewField[point]

    return itemMapXY
end

return dropItemManager
