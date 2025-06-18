local AutoFindDropItemCommand = class('AutoFindDropItemCommand', framework.SimpleCommand)
local proxyUtils              = requireProxy( "proxyUtils" )


local function diffLen( x, y )
    return math.max( math.abs( x ), math.abs( y ) )
end


function AutoFindDropItemCommand:ctor()
end

function AutoFindDropItemCommand:execute(notification)
    local player     = global.gamePlayerController:GetMainPlayer()
    if not player then
        return nil
    end

    local facade     = global.Facade
    local autoProxy  = facade:retrieveProxy( global.ProxyTable.Auto )
    local target     = nil
    local pMapX      = player:GetMapX()
    local pMapY      = player:GetMapY()


    -- only tips
    local bagProxy  = facade:retrieveProxy( global.ProxyTable.Bag )
    local bagfull   = bagProxy:isToBeFull()


    -- find target
    local itemVec      = global.dropItemManager:FindDropItemInCurrViewField( SL:GetMetaValue("GAME_DATA","FindDropItemRange"), true )
    local mainPlayerID = player:GetID()
    local pickLen      = nil
    local currPickLen  = nil
    local targets      = {}
    local targetCount  = 0
    for _, dropItem in ipairs( itemVec ) do
        if self:isPickable( dropItem, mainPlayerID, bagfull ) then
            -- for random pick nearest item
            currPickLen = diffLen( dropItem:GetMapX() - pMapX, dropItem:GetMapY() - pMapY )
            if pickLen then
                if currPickLen > pickLen then
                    break
                end
            end

            pickLen              = currPickLen
            targetCount          = targetCount + 1
            targets[targetCount] = dropItem
        end
    end

    -- random drop item
    if targetCount > 0 then
        local targetIndex = Random( targetCount )
        target = targets[targetIndex]
    end

    if target then
        local targetID = target:GetID()
        local targetX  = target:GetMapX()
        local targetY  = target:GetMapY()

        -- record pick item ID
        autoProxy:SetPickItemID( targetID )

        if not (targetX == pMapX and targetY == pMapY) then
            -- move to range pos
            local movePos   = {}
            movePos.x       = targetX
            movePos.y       = targetY
            movePos.type    = global.MMO.INPUT_MOVE_TYPE_FINDITEM
            facade:sendNotification( global.NoticeTable.InputMove, movePos )
        end
    else
        -- oh, can't find drop
        autoProxy:ClearAutoPick()
    end
end

function AutoFindDropItemCommand:isPickable( dropItem, mainPlayerID, bagfull )
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
    if not proxyUtils:AutoPickItemEnable( dropItem, mainPlayerID ) then
        return false
    end


    return true
end

return AutoFindDropItemCommand
