local DynamicObstacleController = class('DynamicObstacleController', framework.Mediator)
DynamicObstacleController.NAME = "DynamicObstacleController"

local INVALID_MAP_POS = 0xFFFF

function DynamicObstacleController:ctor()
    DynamicObstacleController.super.ctor(self, self.NAME)

    self._obstacles = {}
end

function DynamicObstacleController:destory()
    if DynamicObstacleController.instance then
        global.Facade:removeMediator( DynamicObstacleController.NAME )
        DynamicObstacleController.instance = nil
    end
end

function DynamicObstacleController:Inst()
    if not DynamicObstacleController.instance then
        DynamicObstacleController.instance = DynamicObstacleController.new()
        global.Facade:registerMediator(DynamicObstacleController.instance)
    end

    return DynamicObstacleController.instance
end

function DynamicObstacleController:onRegister()
    DynamicObstacleController.super.onRegister(self)

    local function actCallback(actor, act)
        -- 非移动类action
        if not IsMoveAction(act) then
            return
        end

        self:dynamicPathPoints()
    end
    global.gamePlayerController:AddHandleOnActCompleted(actCallback)
end

function DynamicObstacleController:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.ActorInOfView,
        noticeTable.ActorOutOfView,
        noticeTable.ActorPlayerDie,
        noticeTable.ActorMonsterDie,
        noticeTable.ActorMonsterDeath,
        noticeTable.ActorRevive,
        noticeTable.ActorEffectInOfView,
        noticeTable.ActorEffectOutOfView,
        noticeTable.PlayerStallStatucChange,
        noticeTable.ActorSafeZoneChange,
        noticeTable.ActorMapXYChange,
        noticeTable.MapData_Load_Success,
        noticeTable.Map_Refresh_Throug_HHum,
    }
end

function DynamicObstacleController:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeID == noticeTable.ActorInOfView then
        self:onActorInOfView(data)

    elseif noticeID == noticeTable.ActorOutOfView then
        self:onActorOutOfView(data)

    elseif noticeID == noticeTable.ActorPlayerDie then
        self:onActorPlayerDie(data)

    elseif noticeID == noticeTable.ActorMonsterDie then
        self:onActorMonsterDie(data)

    elseif noticeID == noticeTable.ActorMonsterDeath then
        self:onActorMonsterDeath(data)
        
    elseif noticeID == noticeTable.ActorRevive then
        self:onActorRevive(data)

    elseif noticeID == noticeTable.ActorEffectInOfView then
        self:onActorEffectInOfView(data)

    elseif noticeID == noticeTable.ActorEffectOutOfView then
        self:onActorEffectOutOfView(data)

    elseif noticeID == noticeTable.PlayerStallStatucChange then
        self:onPlayerStallStatucChange(data)

    elseif noticeID == noticeTable.ActorSafeZoneChange then
        self:onActorSafeZoneChange(data)
        
    elseif noticeID == noticeTable.ActorMapXYChange then
        self:onActorMapXYChange(data)

    elseif noticeID == noticeTable.MapData_Load_Success then
        self:onMapDataLoadSuccess()

    elseif noticeID == noticeTable.Map_Refresh_Throug_HHum then
        self:onUpdateAllObstacles()

    end
end

function DynamicObstacleController:checkActorIsObstacle(actor)
    -- main player
    if actor:IsPlayer() and actor:IsMainPlayer() then
        return false
    end

    -- 管理员不受控制
    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    if MapProxy:IsAdmin() and MapProxy:IsGMRunAll() then
        return false
    end

    -- dead
    if actor:IsDie() or actor:IsDeath() then
        return false
    end

    -- 该actor服务器控制可穿
    if (actor:IsNPC() or actor:IsPlayer() or actor:IsMonster()) and actor:IsThroughAble() then
        return false
    end

    local MapProxy                      = global.Facade:retrieveProxy(global.ProxyTable.Map)
    local isCrossAllSafeArea            = MapProxy:IsCrossAllSafeArea()             -- 安全区 不受控制
    local isForbidCrossNPCSafeArea      = MapProxy:IsFirbidCrossNpcSafeArea()       -- 安全区 禁止穿 NPC
    local isFirbidCrossStallSafeArea    = MapProxy:IsFirbidCrossStallSafeArea()     -- 安全区 禁止穿 摆摊玩家
    local isFirbidCrossOfflineSafeArea  = MapProxy:IsFirbidCrossOfflineSafeArea()   -- 安全区 禁止穿 离线玩家

    -- new obstacle data
    local isObstacle            = 0
    if actor:IsNPC() then
        isObstacle              = MapProxy:IsCrossNpcEnable() and 0 or 1
        if actor:GetInSafeZone() then
            isObstacle          = isCrossAllSafeArea and 0 or isObstacle
            isObstacle          = isFirbidCrossStallSafeArea and 1 or isObstacle
        end

    elseif actor:IsPlayer() then
        isObstacle              = (MapProxy:IsCrossPlayerEnable() and 0 or 1)
        if actor:GetInSafeZone() then
            isObstacle          = isCrossAllSafeArea and 0 or isObstacle
            if actor:IsStallStatus() then
                isObstacle      = isFirbidCrossStallSafeArea and 1 or isObstacle
            end
            if actor:GetIsOffLine() then
                isObstacle      = isFirbidCrossOfflineSafeArea and 1 or isObstacle
            end
        end

    elseif actor:IsDefender() then
        isObstacle              = (MapProxy:IsCrossDefenderEnable() and 0 or 1)
        if actor:GetInSafeZone() then
            isObstacle          = isCrossAllSafeArea and 0 or isObstacle
        end

    elseif actor:IsMonster() then
        isObstacle              = (MapProxy:IsCrossMonsterEnable() and 0 or 1)
        if actor:GetInSafeZone() then
            isObstacle          = isCrossAllSafeArea and 0 or isObstacle
        end

    elseif actor:IsSEffect() then
        local mainPlayerID      = global.gamePlayerController:GetMainPlayerID()
        isObstacle              = (actor:GetEffectType() == global.MMO.EFFECT_TYPE_EMPTY and actor:GetDuranceID() == mainPlayerID) and 1 or 0
    end

    return isObstacle == 1
end

function DynamicObstacleController:addRef(x, y)
    local key = KEY_MAP_XY(x, y)

    self._obstacles[key] = self._obstacles[key] or 0
    self._obstacles[key] = self._obstacles[key] + 1

    -- 第一次增加引用计数，将地图置为阻挡状态
    if self._obstacles[key] == 1 then
        local mapData = global.sceneManager:GetMapData2DPtr()
        if not mapData then
            return nil
        end
        mapData:setObstacle(x, y, 1)
    end
end

function DynamicObstacleController:decRef(x, y)
    local key = KEY_MAP_XY(x, y)

    self._obstacles[key] = self._obstacles[key] or 0
    self._obstacles[key] = self._obstacles[key] - 1

    -- 警告
    if self._obstacles[key] < 0 then
        print("WARNING, dynamic obstacle less than 0!!!", self._obstacles[key], x, y)
        PrintTraceback()
    end

    -- 计数 < 0, 当前位置已无动态阻挡
    if self._obstacles[key] <= 0 then
        self._obstacles[key] = nil
        local mapData = global.sceneManager:GetMapData2DPtr()
        if not mapData then
            return nil
        end
        mapData:setObstacle(x, y, 0)
    end
end

function DynamicObstacleController:onActorMapXYChange(data)
    if not data or not data.actor then
        return
    end
    local actor = data.actor
    local lastMapX = actor:GetLastMapX()
    local lastMapY = actor:GetLastMapY()
    local currMapX = actor:GetMapX()
    local currMapY = actor:GetMapY()
    
    -- 该Actor无阻挡标记，不进行阻挡引用计数 +-
    if not actor:IsObstacleFlag() then
        return
    end

    -- 当前坐标点无效，可能是未执行进视野先执行了刷新
    if currMapX == INVALID_MAP_POS and currMapY == INVALID_MAP_POS then
        return
    end

    if lastMapX ~= INVALID_MAP_POS and lastMapY ~= INVALID_MAP_POS then
        self:decRef(lastMapX, lastMapY)
    end

    self:addRef(currMapX, currMapY)
end

function DynamicObstacleController:checkAddObstacle(data)
    if not data or not data.actor then
        return
    end
    local actor = data.actor

    -- 检测是否给阻挡标记
    local isObstacle = self:checkActorIsObstacle(actor)
    actor:SetObstacleFlag(isObstacle)

    -- 不存在阻挡标记
    if not actor:IsObstacleFlag() then
        return
    end

    -- 增加该位置引用计数
    local currMapX = actor:GetMapX()
    local currMapY = actor:GetMapY()
    self:addRef(currMapX, currMapY)
end

function DynamicObstacleController:checkRemoveObstacle(data)
    if not data or not data.actor then
        return
    end
    local actor = data.actor

    -- 不存在阻挡标记
    if not actor:IsObstacleFlag() then
        return
    end

    -- ???? 是否应该置为 false
    actor:SetObstacleFlag(false)

    -- 减少该位置引用计数
    local currMapX = actor:GetMapX()
    local currMapY = actor:GetMapY()
    self:decRef(currMapX, currMapY)
end

function DynamicObstacleController:checkUpdateObstacle(data)
    -- 注意这里刷新，坐标无改变，应认为 同位置刷新
    if not data or not data.actor then
        return
    end
    local actor = data.actor
    local currMapX = actor:GetMapX()
    local currMapY = actor:GetMapY()

    -- 当前坐标点无效，可能是未执行进视野先执行了刷新
    if currMapX == INVALID_MAP_POS and currMapY == INVALID_MAP_POS then
        return
    end

    -- 否是阻挡
    local lastObstacleFlag = actor:IsObstacleFlag()

    -- 检测是否给阻挡标记
    local isObstacle = self:checkActorIsObstacle(actor)
    actor:SetObstacleFlag(isObstacle)

    -- 阻挡数据无变化
    if lastObstacleFlag == actor:IsObstacleFlag() then
        return
    end

    -- 上次是阻挡，减引用计数
    if lastObstacleFlag then
        self:decRef(currMapX, currMapY)
    end
    
    -- 当前是阻挡，加引用计数
    if actor:IsObstacleFlag() then
        self:addRef(currMapX, currMapY)
    end
end

function DynamicObstacleController:onActorInOfView(data)
    self:checkAddObstacle(data)
end

function DynamicObstacleController:onActorEffectInOfView(data)
    self:checkAddObstacle(data)
end

function DynamicObstacleController:onActorOutOfView(data)
    self:checkRemoveObstacle(data)
end

function DynamicObstacleController:onActorPlayerDie(data)
    self:checkRemoveObstacle(data)
end

function DynamicObstacleController:onActorMonsterDie(data)
    self:checkRemoveObstacle(data)
end

function DynamicObstacleController:onActorMonsterDeath(data)
    self:checkRemoveObstacle(data)
end

function DynamicObstacleController:onActorRevive(data)
    self:checkUpdateObstacle(data)
end

function DynamicObstacleController:onActorEffectOutOfView(data)
    self:checkRemoveObstacle(data)
end

function DynamicObstacleController:onPlayerStallStatucChange(data)
    self:checkUpdateObstacle(data)
end

function DynamicObstacleController:onActorSafeZoneChange(data)
    self:checkUpdateObstacle(data)
end

function DynamicObstacleController:onMapDataLoadSuccess(data)
    self._obstacles = {}

    -- npc
    local actors, ncount = global.npcManager:GetNpcInCurrViewField()
    for i = 1, ncount do
        local actor = actors[i]
        if actor then
            self:checkAddObstacle({actor = actor, actorID = actor:GetID()})
        end
    end

    -- player
    local actors, ncount = global.playerManager:GetPlayersInCurrViewField()
    for i = 1, ncount do
        local actor = actors[i]
        if actor then
            self:checkAddObstacle({actor = actor, actorID = actor:GetID()})
        end
    end

    -- monsters
    local actors, ncount = global.monsterManager:GetMonstersInCurrViewField()
    for i = 1, ncount do
        local actor = actors[i]
        if actor then
            self:checkAddObstacle({actor = actor, actorID = actor:GetID()})
        end
    end
end

function DynamicObstacleController:onUpdateAllObstacles()
    -- npc
    local actors, ncount = global.npcManager:GetNpcInCurrViewField()
    for i = 1, ncount do
        local actor = actors[i]
        if actor then
            self:checkUpdateObstacle({actor = actor, actorID = actor:GetID()})
        end
    end

    -- player
    local actors, ncount = global.playerManager:GetPlayersInCurrViewField()
    for i = 1, ncount do
        local actor = actors[i]
        if actor then
            self:checkUpdateObstacle({actor = actor, actorID = actor:GetID()})
        end
    end

    -- monsters
    local actors, ncount = global.monsterManager:GetMonstersInCurrViewField()
    for i = 1, ncount do
        local actor = actors[i]
        if actor then
            self:checkUpdateObstacle({actor = actor, actorID = actor:GetID()})
        end
    end
end

function DynamicObstacleController:dynamicPathPoints()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return nil
    end

    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData then
        return nil
    end

    local PlayerInputProxy  = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local currPathPoint     = PlayerInputProxy:GetCurrPathPoint()
    local pathPoints        = PlayerInputProxy:GetPathFindPoints()
    if currPathPoint <= 0 or #pathPoints <= 0 then
        return nil
    end

    local startPos  = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    local destPos   = nil
    local destIndex = nil

    -- find dest pos
    if pathPoints[currPathPoint] then
        local path = pathPoints[currPathPoint]
        if mapData:isObstacle(path.x, path.y) == 1 then
            for i = currPathPoint, 1, -1 do
                path = pathPoints[i]
                if mapData:isObstacle(path.x, path.y) == 0 then
                    destPos = path
                    destIndex = i
                    break
                end
            end
        end
    end

    -- can't find obstacle
    if not destPos then
        return nil
    end

    print("--------------------- modify path")
    dump(destPos)

    -- it's current pos,nothing to do
    if startPos.x == destPos.x and startPos.y == destPos.y then
        return nil
    end

    -- find path
    local findPoints = global.PathFindController:FindPathAStarLimits(startPos, destPos)

    -- can't find dest
    if #findPoints <= 0 then
        return nil
    end

    -- new path points
    local newPathPoints = {}
    for i, v in ipairs(pathPoints) do
        if i == destIndex then
            break
        end
        table.insert(newPathPoints, v)
    end
    for i, v in ipairs(findPoints) do
        table.insert(newPathPoints, v)
    end
    PlayerInputProxy:SetPathFindPoints( newPathPoints )
end

return DynamicObstacleController
