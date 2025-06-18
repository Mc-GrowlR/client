local PathFindController = class("PathFindController")
local PathFindAStar = require("logic/PathFindAStar")

local function squLen(x, y)
    return x * x + y * y
end

local function convertDir(dir)
    if dir > global.MMO.ORIENT_LU then
        dir = dir - (global.MMO.ORIENT_LU+1)

    elseif dir < global.MMO.ORIENT_U then
        dir = dir + (global.MMO.ORIENT_LU+1)
    end
    return dir
end

local function checkMoveAbleOneStep(mapData, srcPos, moveStep, moveDir)
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local normalize = nil
    local dstPos = cc.p(0, 0)
    for i = 1, moveStep do
        normalize = inputProxy:DirToNormalizeVec2(moveDir)
        normalize = cc.pMul(normalize, i)
        dstPos.x  = srcPos.x + normalize.x
        dstPos.y  = srcPos.y + normalize.y
        if mapData:isObstacle(dstPos.x, dstPos.y) ~= 0 then
            return false
        end
    end
    return true, dstPos
end

function PathFindController:ctor()
    self.pathFindAStar = PathFindAStar.new()
end

function PathFindController:destory()
    if PathFindController.instance then
        PathFindController.instance = nil
    end
end

function PathFindController:Inst()
    if not PathFindController.instance then
        PathFindController.instance = PathFindController.new()
    end
    return PathFindController.instance
end

function PathFindController:IsOutBounds(movePos)
    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData then
        return true
    end

    local mapRows = mapData:getMapDataRows()
    local mapCols = mapData:getMapDataCols()
    return (movePos.x < 0 or movePos.x >= mapCols or movePos.y < 0 or movePos.y >= mapRows)
end

function PathFindController:CheckMoveAble(movePos)
    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData then
        return false
    end

    if self:IsOutBounds(movePos) then
        return false
    end
    if mapData:isObstacle(movePos.x, movePos.y) == 0 then
        return true
    end
    return false
end

function PathFindController:IsImpass(pos)
    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData then
        return true
    end

    local around = 
    {
        { pos.x + 1, pos.y     }, -- right
        { pos.x,     pos.y + 1 }, -- bottom
        { pos.x - 1, pos.y     }, -- left
        { pos.x,     pos.y - 1 }, -- top
        { pos.x + 1, pos.y - 1 }, -- right up    
        { pos.x + 1, pos.y + 1 }, -- right bottom
        { pos.x - 1, pos.y + 1 }, -- left bottom
        { pos.x - 1, pos.y - 1 }, -- left top    
    }
    for i = 1, 8 do
        local aroundX = around[i][1]
        local aroundY = around[i][2]
        if self:CheckMoveAble(cc.p(aroundX, aroundY)) then
            return false
        end
    end

    return true
end

function PathFindController:FindPathAStar(srcPos, dstPos)
    local findPoints = {}

    if not srcPos or not dstPos then
        return findPoints
    end
  
    if srcPos.x == dstPos.x and srcPos.y == dstPos.y then   -- it's current pos,nothing to do
        return findPoints
    end

    -- 死路
    if true == self:IsImpass(srcPos) or true == self:IsImpass(dstPos) then
        return findPoints
    end

    -- 
    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData then
        return findPoints
    end

    -- find
    aiManager:Inst():FindPath(srcPos.x, srcPos.y, dstPos.x, dstPos.y, mapData)
    findPoints = aiManager:Inst():GetPathFind():GetPathPoints()

    return findPoints
end

function PathFindController:FindPathAStarLimits(srcPos, dstPos)
    local points = self.pathFindAStar:find_path(srcPos.x, srcPos.y, dstPos.x, dstPos.y)
    return points
end

function PathFindController:FindDestPosJoystick(srcPos, moveDir, moveStep)
    -- 绝路
    if true == self:IsImpass(srcPos) then
        return nil
    end

    -- 
    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData then
        return nil
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local moveDirty = false
    local dstPos = cc.p(srcPos.x, srcPos.y)

    -- 先根据方向找格子
    if not moveDirty then
        for i = moveStep, 1, -1 do
            moveDirty, dstPos = checkMoveAbleOneStep(mapData, srcPos, i, moveDir)
            if moveDirty then
                break
            end
        end
    end
    
    -- 找邻近2个方向
    if not moveDirty then
        local dirs = {moveDir+1, moveDir-1}
        for _, dir in ipairs(dirs) do
            dir = convertDir(dir)

            for i = moveStep, 1, -1 do
                moveDirty, dstPos = checkMoveAbleOneStep(mapData, srcPos, i, dir)
                if moveDirty then
                    break
                end
            end

            if moveDirty then
                break
            end
        end
    end

    -- 找更远2个方向
    if not moveDirty then
        local dirs = {moveDir+2, moveDir-2}
        for _, dir in ipairs(dirs) do
            dir = convertDir(dir)

            moveDirty, dstPos = checkMoveAbleOneStep(mapData, srcPos, 1, dir)
            if moveDirty then
                break
            end
        end
    end

    -- 
    if not moveDirty then
        local normalize  = inputProxy:DirToNormalizeVec2(moveDir)
        local normalizeT = nil
        dstPos           = cc.p(0, 0)
        for i = moveStep, SL:GetMetaValue("GAME_DATA","Joystick_Check_Range") or 0 do
            normalizeT = cc.pMul(normalize, i)
            dstPos.x   = srcPos.x + normalize.x
            dstPos.y   = srcPos.y + normalize.y
            if mapData:isObstacle(dstPos.x, dstPos.y) == 0 then
                moveDirty = true
                break
            end
        end
    end

    if not moveDirty then
        return nil
    end

    local findPoints = self:FindPathAStarLimits(srcPos, dstPos)
    if not findPoints then
        return nil
    end
    local pathLen = #findPoints
    if pathLen <= 0 then
        return nil
    end

    -- 第一步
    dstPos = findPoints[pathLen]

    -- 是否能走多步
    if pathLen > 1 and pathLen >= moveStep then
        local moveDir = CalcActorDirByPos(srcPos, findPoints[pathLen])
        for i = pathLen-1, 1, -1 do
            -- 步数超出
            if pathLen - i >= moveStep then
                break
            end
            -- 不同方向
            if moveDir ~= CalcActorDirByPos(findPoints[i+1], findPoints[i]) then
                break
            end
            dstPos = findPoints[i]
        end
    end

    return dstPos
end


--------------------------------------------------------------------------------------------
function PathFindController:checkMovePosEnable(mapPos)
    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData then
        return false
    end

    return mapData:isObstacle(mapPos.x, mapPos.y) == 0
end

function PathFindController:checkNextMovePos(player, pathPoints, currPathPoint)
    if currPathPoint <= 0 then
        return nil, nil
    end
    
    -- check first point
    local moveStep = 1
    local currPos = cc.p(player:GetMapX(), player:GetMapY())
    local nextPos = pathPoints[currPathPoint]
    local nextEnable = self:checkMovePosEnable(nextPos)
    if not nextEnable then
        return nil, nil
    end

    -- 寻路只有一格
    if currPathPoint <= 1 then
        return nextPos, moveStep
    end
    
    -- 只能走路buff
    if not CheckRunAble() or CheckRunStep() <= 1 then
        return nextPos, moveStep
    end

    local nextDir = CalcActorDirByPos(currPos, nextPos)

    -- check second point
    local next2Pos = pathPoints[currPathPoint - 1]
    if nextDir ~= CalcActorDirByPos(nextPos, next2Pos) or not self:checkMovePosEnable(next2Pos) then
        return nextPos, moveStep
    end

    -- 2 step only.
    moveStep = 2
    if CheckRunStep() <= 2 or currPathPoint <= 2 then
        return next2Pos, moveStep
    end
    
    -- check third point
    local next3Pos = pathPoints[currPathPoint - 2]
    if nextDir ~= CalcActorDirByPos(next2Pos, next3Pos) or not self:checkMovePosEnable(next3Pos) then
        return next2Pos, moveStep
    end
    
    moveStep = 3
    return next3Pos, moveStep
end

function PathFindController:CheckNextMovePosAble()
    local player                = global.gamePlayerController:GetMainPlayer()
    if not player then
        return -1
    end

    local inputProxy            = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local pathPoints            = inputProxy:GetPathFindPoints()
    local currPathPoint         = inputProxy:GetCurrPathPoint()
    if currPathPoint <= 0 then
        return 0
    end

    local nextPoint, moveStep   = self:checkNextMovePos(player, pathPoints, currPathPoint)
    if nextPoint then
        -- walk, check next point has player/monster/npc
        if moveStep == 1 and not self:checkAbleToWalk(nextPoint) then
            return -1
        end
        
        return 1
    end

    return -1
end

function PathFindController:checkAbleToWalkByActor(actor)
    if not actor then
        return true
    end

    -- 死亡状态 可穿
    if actor:IsDie() or actor:IsDeath() or actor:IsCave() then
        return true
    end

    -- 该actor 可穿
    if actor:IsPlayer() or actor:IsMonster() or actor:IsNPC() then
        if actor:IsThroughAble() then
            return true
        end
    end

    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)

    -- 地图设置 可穿
    if actor:IsPlayer() then
        if MapProxy:IsAbleWalkCrossPlayer() then
            return true
        end

        if MapProxy:IsCrossAllSafeArea() and actor:GetInSafeZone() then
            return true
        end
    end

    -- 地图设置 可穿
    if actor:IsMonster() then
        if actor:GetInSafeZone() then
            if MapProxy:IsCrossAllSafeArea() and not MapProxy:IsFirbidCrossNpcSafeArea() then
                return true
            end
        end
        
        if MapProxy:IsAbleWalkCrossMonster() then
            return true
        end
    end

    -- 地图设置 可穿
    if actor:IsNPC() then
        if MapProxy:IsCrossNpcEnable() then
            return true
        end

        if MapProxy:IsCrossAllSafeArea() and actor:GetInSafeZone() then
            return true
        end
    end

    return false
end

function PathFindController:checkAbleToWalk(nextPoint)
    -- 管理员不受控制
    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    if MapProxy:IsAdmin() and MapProxy:IsGMRunAll() then
        return true
    end

    local actors = global.actorManager:GetMonsterActorByMapXY(nextPoint.x, nextPoint.y, true)
    for i, actor in ipairs(actors) do
        if actor and false == self:checkAbleToWalkByActor(actor) then
            return false
        end
    end
    
    actors = global.actorManager:GetPlayerActorByMapXY(nextPoint.x, nextPoint.y, true)
    for i, actor in ipairs(actors) do
        if actor and false == self:checkAbleToWalkByActor(actor) then
            return false
        end
    end

    actors = global.actorManager:GetNPCActorByMapXY(nextPoint.x, nextPoint.y, true)
    for i, actor in ipairs(actors) do
        if actor and false == self:checkAbleToWalkByActor(actor) then
            return false
        end
    end 

    return true
end

-- 检测直线阻挡是否存在npc player monster
function PathFindController:checkActorLimitObstacle(srcPos,dstPos)
    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData then
        return false
    end

    local inputProxy    = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local moveDir       = inputProxy:calcMapDirection(dstPos,srcPos)
    local distance      = inputProxy:calcMapDistance(dstPos,srcPos)

    local around = 
    {
        { 0,        -1 }, -- ORIENT_U
        { 1,        -1 }, -- ORIENT_RU
        { 1,         0 }, -- ORIENT_R
        { 1,         1 }, -- ORIENT_RB
        { 0,         1 }, -- ORIENT_B    
        {-1,         1 }, -- ORIENT_LB
        {-1,         0 }, -- ORIENT_L
        {-1,        -1 }, -- ORIENT_LU  
    }

    local function checkActors(actors, ncount, pos)
        for i = 1, ncount do
            local actor = actors[i]
            if actor and actor:GetMapX() == pos.x and actor:GetMapY() == pos.y then
                return actor
            end
        end
        return nil
    end

    local ret = false
    local target = nil
    local actors = {}
    local ncount = 0

    for i=1,distance do
        srcPos.x = srcPos.x + around[moveDir+1][1]
        srcPos.y = srcPos.y + around[moveDir+1][2]

        if mapData:isObstacle(srcPos.x, srcPos.y) == 1 then
            -- npc
            if not target then
                actors, ncount = global.npcManager:GetNpcInCurrViewField()
                target = checkActors(actors, ncount, srcPos)
            end

            -- player
            if not target then
                actors, ncount = global.playerManager:FindPlayerInCurrViewField()
                target = checkActors(actors, ncount, srcPos)
            end

            -- monster
            if not target then
                actors, ncount = global.monsterManager:FindMonsterInCurrViewField(false, false)
                target = checkActors(actors, ncount, srcPos)
            end

            if target then
                ret = true
                break
            end
        end
    end

    return ret
end
--------------------------------------------------------------------------------------------


return PathFindController
