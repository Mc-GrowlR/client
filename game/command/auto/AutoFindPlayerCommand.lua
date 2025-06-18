local AutoFindPlayerCommand = class('AutoFindPlayerCommand', framework.SimpleCommand)
local proxyUtils = requireProxy("proxyUtils")

local function squLen(x, y)
    return x * x + y * y
end

function AutoFindPlayerCommand:ctor()
end

function AutoFindPlayerCommand:execute(notification)
    local facade = global.Facade
    local inputProxy = facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    
    if not mainPlayer then
        return nil
    end
    
    
    -- 暂时用来 自动战斗锁定人形怪
    local target = nil
    local cost = global.MMO.MAX_CONST
    local pMapX = mainPlayer:GetMapX()
    local pMapY = mainPlayer:GetMapY()
    local playerVec, nPlayer = global.playerManager:GetPlayersInCurrViewField()
    for i = 1, nPlayer do
        local player = playerVec[i]
        if player and player:IsHumanoid() and not (player:GetMapX() == pMapX and player:GetMapY() == pMapY) then
            if true == proxyUtils.checkAutoTargetEnableByID(player:GetID()) then
                local len = squLen(player:GetMapX() - pMapX, player:GetMapY() - pMapY)
                if len < cost then
                    target = player
                    cost = len
                end
            end
        end
    end
    
    
    if target then
        inputProxy:SetTargetID(target:GetID(), global.MMO.SELETE_TARGET_TYPE_FIND)
    else
        -- oh, can't find monster, find special player
        facade:sendNotification(global.NoticeTable.AutoFindMonster)
    end
end


return AutoFindPlayerCommand
