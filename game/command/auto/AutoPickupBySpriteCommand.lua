local AutoPickupBySpriteCommand = class('AutoPickupBySpriteCommand', framework.SimpleCommand)
local proxyUtils            = requireProxy("proxyUtils")

local tSort = table.sort
local mAbs  = math.abs

local function diffLen(x, y)
    return math.max(math.abs(x), math.abs(y))
end

function AutoPickupBySpriteCommand:ctor()
end

function AutoPickupBySpriteCommand:execute(notification)
    local player    = global.gamePlayerController:GetMainPlayer()
    if not player then
        return nil
    end
    local PickupSpriteProxy        = global.Facade:retrieveProxy(global.ProxyTable.PickupSpriteProxy)
    if not PickupSpriteProxy:getPickupSpriteState() then
        return
    end

    local facade    = global.Facade
    local autoProxy = facade:retrieveProxy(global.ProxyTable.Auto)
    -- local target     = nil
    local pMapX    = player:GetMapX()
    local pMapY    = player:GetMapY()

    -- local Range = 
    -- only tips
    local bagProxy = facade:retrieveProxy(global.ProxyTable.Bag)
    local bagfull = bagProxy:isToBeFull()
    local range = PickupSpriteProxy:getPickupRange()
    -- find target
    local mode = PickupSpriteProxy:getPickSpriteMode()
    local spriteID = PickupSpriteProxy:getPickSpriteID()

    local itemVec = nil
    local nItemVec = 0

    if spriteID and (mode == 1 or mode == 3) then--小精灵附近
        itemVec, nItemVec = self:monsterMode(range, true, spriteID)
    else
        itemVec, nItemVec = global.dropItemManager:FindDropItemInCurrViewField(range, true)
    end

    local mainPlayerID = player:GetID()
    local pickLen    = nil
    local currPickLen = nil
    local targetCount = 0
    local nums = 0
    local strs = {}
    local dropItemMakeindex
    
    for i = 1, nItemVec do
        local dropItem = itemVec[i]
        if dropItem and self:isPickable(dropItem, mainPlayerID, bagfull) then
            dropItemMakeindex = dropItem:GetMakeIndex()
            if not dropItemMakeindex or dropItemMakeindex == 0 then --金币没有唯一id
                dropItemMakeindex = dropItem:GetName()
            end
            local temps = string.format("%s,%s,%s", dropItemMakeindex, dropItem:GetMapX(), dropItem:GetMapY())
            table.insert(strs, temps)
            nums = nums + 1
            if nums == 35 then
                break
            end
        end
    end
    
    if #strs > 0 then
        PickupSpriteProxy:ReqPickUpSomething(table.concat(strs, ";"))
    end
end

function AutoPickupBySpriteCommand:monsterMode(range, sortNearToFarFromPlayer, actorID)
    local sprite = global.actorManager:GetActor(actorID)
    if not sprite then
        return {}, 0
    end

    if nil == sortNearToFarFromPlayer then 
        sortNearToFarFromPlayer = false 
    end

    local function inRange(a, range)
        if -1 == range then return true end 

        local p  = sprite
        local mX = p:GetMapX()
        local mY = p:GetMapY()
        local dX = a:GetMapX() - mX
        local dY = a:GetMapY() - mY
        local diffA = (mAbs(dX) > mAbs(dY)) and mAbs(dX) or mAbs(dY)    

        return diffA <= range 
    end

    local allitem, ncount = global.dropItemManager:FindDropItemInCurrViewFieldAll()
    local ownerID = global.MMO.ACTOR_ID_INVALID 
    local recvVec = {}
    local num     = 0

    for i = 1, ncount do
        local m = allitem[i]
        if m and (global.MMO.ACTOR_ID_INVALID == ownerID or m:CheckOwnerID(ownerID)) and inRange(m, range) then
            num = num + 1
            recvVec[num] = m
        end
    end

    -- Need to sort ?
    if sortNearToFarFromPlayer and num > 1 then
        local p  = sprite
        local mX = p:GetMapX()
        local mY = p:GetMapY()
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
function AutoPickupBySpriteCommand:isPickable(dropItem, mainPlayerID, bagfull)
    if not dropItem then
        return false
    end

    if dropItem:IsIngored() then
        return false
    end

    if bagfull and dropItem:GetTypeIndex() ~= 0 then -- 背包满可以捡金币
        return false
    end

    -- check pick state
    if dropItem:GetPickState() >= 1 or dropItem:IsPickTimeout() then
        return false
    end

    -- check owner
    if not proxyUtils:AutoPickItemEnable(dropItem, mainPlayerID, true) then
        return false
    end


    return true
end

return AutoPickupBySpriteCommand