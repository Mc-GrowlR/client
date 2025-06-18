local AutoFindMonsterCommand = class('AutoFindMonsterCommand', framework.SimpleCommand)
local proxyUtils = requireProxy("proxyUtils")

local function squLen(x, y)
    return x * x + y * y
end

function AutoFindMonsterCommand:ctor()
end

function AutoFindMonsterCommand:execute(notification)
    local player = global.gamePlayerController:GetMainPlayer()
    if not player then
        return nil
    end

    local getMonsterVec = function (monsters, ncount)
        local monsterVec = {}
        local num = 0

        for i = 1, ncount do
            local monster = monsters[i]
            if proxyUtils.checkAutoTargetEnableByID(monster:GetID()) then
                num = num + 1
                monsterVec[num] = monster
            end
        end

        return monsterVec, num
    end
    
    local facade = global.Facade
    local autoProxy = facade:retrieveProxy(global.ProxyTable.Auto)
    local inputProxy = facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local targetIndex = autoProxy:GetTargetIndex()
    local targetType = autoProxy:GetTargetType()

    local monsterVec  = {}
    local monsterVecNum = 0
    
    if targetType ~= global.MMO.ACTOR_MONSTER or not targetIndex or global.MMO.AUTO_FIND_TARGET_NONE == targetIndex or 0 == targetIndex then -- not target index,find nearst monster
        local monsters, ncount = global.monsterManager:FindMonsterInCurrViewField(true, true)
        monsterVec, monsterVecNum = getMonsterVec(monsters, ncount)
    else
        local monsters = {}
        local ncount = 0

        if type(targetIndex) == "number" then
            monsters, ncount = global.monsterManager:FindMonsterInCurrViewFieldByTypeIndex(targetIndex, true, true)
        elseif type(targetIndex) == "table" then
            monsters, ncount = global.monsterManager:FindMonsterInCurrViewFieldByTypeIndexTable(targetIndex, true, true)
        end
        
        monsterVec, monsterVecNum = getMonsterVec(monsters, ncount)
        
        if monsterVecNum < 1 then
            local monsters, ncount = global.monsterManager:FindMonsterInCurrViewField()
            monsterVec, monsterVecNum = getMonsterVec(monsters, ncount)
        end
    end

    if monsterVecNum < 1 then
        return false
    end
    
    -- find nearest monster
    local target = self:FindNearestMonster(monsterVec, monsterVecNum)
    
    if target then
        inputProxy:SetTargetID(target:GetID(), global.MMO.SELETE_TARGET_TYPE_FIND)
    end
end


function AutoFindMonsterCommand:FindNearestMonster(monsterVec, monsterVecNum)
    -- 不自动选: 守卫/石化状态下祖玛卫士 
    local target     = nil
    local cost       = global.MMO.MAX_CONST
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    local pMapX      = mainPlayer:GetMapX()
    local pMapY      = mainPlayer:GetMapY()
    local mX         = 0
    local mY         = 0

    for i = 1, monsterVecNum do
        local monster = monsterVec[i]
        if monster then
            local mX = monster:GetMapX()
            local mY = monster:GetMapY()
            if not (mX == pMapX and mY == pMapY) and proxyUtils.checkAutoTargetEnableByID(monster:GetID()) then
                local len = squLen(mX - pMapX, mY - pMapY)
                if len < cost then
                    target = monster
                    cost = len
                end
            end
        end
    end
    
    return target
end

return AutoFindMonsterCommand
