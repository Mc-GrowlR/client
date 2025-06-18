local DebugProxy = requireProxy("DebugProxy")
local PlayerInputProxy = class("PlayerInputProxy", DebugProxy)
PlayerInputProxy.NAME = global.ProxyTable.PlayerInputProxy
local cjson = require("cjson")

local DirMaps =
{
    {x = 0, y = -1, },
    {x = 1, y = -1, },
    {x = 1, y = 0, },
    {x = 1, y = 1, },
    {x = 0, y = 1, },
    {x = -1, y = 1, },
    {x = -1, y = 0, },
    {x = -1, y = -1, },
}

function PlayerInputProxy:ctor()
    PlayerInputProxy.super.ctor(self)
    
    self._movePermission = true
    
    ----------- target -------------
    self._targetID          = nil
    self._lastTargetID      = nil
    self._attackState       = false     -- 持续攻击状态 shift锁定
    self._attackTargetID    = nil       -- 持续攻击目标
    self._ownerPlayerID     = nil       -- 目标怪物归属的玩家id
    self._isTraceOwnerPlayer= false     -- 自动追踪归属玩家
    ------------------------------
    
    ----------- move -------------
    self._moveDestPos       = nil
    self._moveDirty         = false
    self._moveType          = global.MMO.INPUT_MOVE_TYPE_OTHER
    self._currMovePos       = nil -- current move to pos
    self._pathFindPoints    = nil
    self._currPathPoint     = 0
    self._isMoveBlocked     = false     -- 寻路被
    self._launchNoWalkPos   = nil       -- 攻击时  走路不可通行的位置(强制刷新阻挡)
    ------------------------------

    ----------- skill -------------
    self._launchDirty       = false
    self._skillID           = nil
    self._launchPos         = nil
    self._launchTargetID    = nil
    self._launchType        = global.MMO.LAUNCH_TYPE_USER
    self._launchPriority    = global.MMO.LAUNCH_PRIORITY_SYSTEM
    ------------------------------

    ----------- collection -------------
    self._collectCount      = 0
    ------------------------------

    ----------- dig coprse -------------
    self._coprseID          = nil
    self._digDest           = nil
    ------------------------------------

    ----------- mining -----------------
    self._miningDir         = nil
    self._miningDest        = nil
    ------------------------------------
    
    ----------- mouse touch ------------
    self._mouseTouchPos     = nil
    self._mouseTouchWay     = nil
    ------------------------------------
    
    ----------- mouse turn -------------
    self._mouseTurnDir      = global.MMO.ORIENT_INVAILD
    ------------------------------------

    ----------- mouse target ID --------
    self._mouseOverTargetID = nil
    ------------------------------------
end


--------------- util -----------------
function PlayerInputProxy:calcWorldDirection(dst, src)
    local angle = math.deg(cc.pToAngleSelf(cc.pSub(dst, src)))
    local ret   = global.MMO.ORIENT_INVAILD
    
    if (angle > -22.5 and angle <= 22.5) then -- right
        ret = global.MMO.ORIENT_R
    
    elseif (angle > 22.5 and angle <= 67.5) then -- right up
        ret = global.MMO.ORIENT_RU
    
    elseif (angle > 67.5 and angle <= 112.5) then -- up
        ret = global.MMO.ORIENT_U
    
    elseif (angle > 112.5 and angle <= 157.5) then -- left up
        ret = global.MMO.ORIENT_LU
    
    elseif ((angle > 157.5 and angle <= 180) or (angle <= -157.5 and angle > -180)) then -- left
        ret = global.MMO.ORIENT_L
    
    elseif (angle <= -112.5 and angle > -157.5) then -- left down
        ret = global.MMO.ORIENT_LB
    
    elseif (angle <= -67.5 and angle > -112.5) then -- down
        ret = global.MMO.ORIENT_B
    
    elseif (angle <= -22.5 and angle > -67.5) then --right down
        ret = global.MMO.ORIENT_RB
    end
    return ret
end

function PlayerInputProxy:calcMapDirection(dst, src)
    local angle = math.deg(cc.pToAngleSelf(cc.pSub(dst, src)))
    local ret   = global.MMO.ORIENT_INVAILD
    if (angle > -22.5 and angle <= 22.5) then -- right
        ret = global.MMO.ORIENT_R
    
    elseif (angle > 22.5 and angle <= 67.5) then -- right up
        ret = global.MMO.ORIENT_RB
    
    elseif (angle > 67.5 and angle <= 112.5) then -- up
        ret = global.MMO.ORIENT_B
    
    elseif (angle > 112.5 and angle <= 157.5) then -- left up
        ret = global.MMO.ORIENT_LB
    
    elseif ((angle > 157.5 and angle <= 180) or (angle <= -157.5 and angle > -180)) then -- left
        ret = global.MMO.ORIENT_L
    
    elseif (angle <= -112.5 and angle > -157.5) then -- left down
        ret = global.MMO.ORIENT_LU
    
    elseif (angle <= -67.5 and angle > -112.5) then -- down
        ret = global.MMO.ORIENT_U
    
    elseif (angle <= -22.5 and angle > -67.5) then --right down
        ret = global.MMO.ORIENT_RU
    end
    return ret
end

function PlayerInputProxy:calcMapDistance(dst, src)
    return math.max(math.abs(dst.x - src.x), math.abs(dst.y - src.y))
end

function PlayerInputProxy:getCursorWorldPosition()
    local cursorPos = global.userInputController:GetCursorPos()
    local worldPos  = Screen2World(cursorPos)
    return worldPos
end

function PlayerInputProxy:getCursorWorldDirection()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return global.MMO.ORIENT_INVAILD
    end
    local src = mainPlayer:getPosition()
    local dst = self:getCursorWorldPosition()
    return self:calcWorldDirection(dst, src)
end

function PlayerInputProxy:getCursorMapPosition()
    local cursorPos = global.userInputController:GetCursorPos()
    local worldPos  = Screen2World(cursorPos)
    local mapX,mapY = global.sceneManager:WorldPos2MapPos(worldPos)
    return cc.p(mapX, mapY)
end

function PlayerInputProxy:DirToNormalizeVec2(dir)
    if dir <= 7 and dir >= 0 then
        return DirMaps[dir + 1]
    end
    
    return global.MMO.ORIENT_INVAILD
end

function PlayerInputProxy:getMainPlayerFaceDest()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return cc.p(0, 0)
    end

    local normalize = self:DirToNormalizeVec2(mainPlayer:GetDirection())
    return cc.pAdd(cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY()), normalize)
end

function PlayerInputProxy:Vec2ToDir(vec)
    -- convert y
    if vec.y ~= 0 then
        vec.y = -vec.y
    end
    
    local constant = global.MMO
    if vec.x == 0 then
        if vec.y == 0 then
            return constant.ORIENT_INVAILD
        elseif vec.y > 0 then
            return constant.ORIENT_U
        else
            return constant.ORIENT_B
        end
    
    elseif vec.x > 0 then
        if vec.y == 0 then
            return constant.ORIENT_R
        elseif vec.y > 0 then
            return constant.ORIENT_RU
        else
            return constant.ORIENT_RB
        end
    
    else
        if vec.y == 0 then
            return constant.ORIENT_L
        elseif vec.y > 0 then
            return constant.ORIENT_LU
        else
            return constant.ORIENT_LB
        end
    
    end
    
    return global.MMO.ORIENT_INVAILD
end

function PlayerInputProxy:MergeVec2(vec)
    local ret = bit.lshift(vec.y, 16)
    ret = bit.bor(ret, vec.x)
    
    return ret
end


local function squLen(x, y)
    return x * x + y * y
end

local function findBestPos(sX, sY, dX, dY, range, enableFunc, minrange)
    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData then
        return dX, dY
    end

    minrange = minrange or 0
    if not range or 0 >= range then
        return dX, dY
    end
    
    local result = {}
    local index = 1
    local x = nil
    local y = nil
    local bestIndex = nil
    local cost  = global.MMO.MAX_CONST
    local seqR  = range*range
    local seqMR = minrange*minrange

    -- 1.check origin
    local len = squLen(sX - dX, sY - dY)
    if (len <= seqR) and (len >= seqMR) and enableFunc(sX, sY, dX, dY) then
        return sX, sY
    end
    
    -- 2.check other
    for offY = -range, range do
        for offX = -range, range do
            x = dX + offX
            y = dY + offY

            if enableFunc(x, y, dX, dY) and mapData:isObstacle(x, y) == 0 then
                result[index] = cc.p(x, y)
                local len = squLen(sX - x, sY - y)
                if len < cost and squLen(x - dX, y - dY) >= seqMR then
                    bestIndex = index
                    cost = len
                end
                index = index + 1
            end
        end
    end
    
    if bestIndex and result[bestIndex] then
        return result[bestIndex].x, result[bestIndex].y
    end
    return dX, dY
end

function PlayerInputProxy:findBestSkillPos(sX, sY, dX, dY, range, enableFunc, minrange)
    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData then
        return dX, dY
    end

    minrange = minrange or 0
    if not range or 0 >= range then
        return dX, dY
    end
    
    local seqR  = range*range
    local seqMR = minrange*minrange
    
    local len   = squLen(sX - dX, sY - dY)
    if (len <= seqR) and (len >= seqMR) and enableFunc(sX, sY, dX, dY) then
        return sX, sY
    end

    local items = {}
    local index = 1
    local bestI = nil
    local cost  = global.MMO.MAX_CONST

    local x     = nil
    local y     = nil
    local lenA  = nil

    local function isLine(p1, p2)
        if p1.x == p2.x or p1.y == p2.y then
            return true
        end
        return false
    end

    -- 
    local function calcDistance(dst, src)
        local dis = self:calcMapDistance(dst, src)
        dis = dis + (isLine(dst, src) and 0 or 0.1)
        return dis
    end
    
    -- 2.check other
    local lenS  = nil
    local lenD  = nil
    for offY = -range, range do
        for offX = -range, range do
            x = dX + offX
            y = dY + offY

            if enableFunc(x, y, dX, dY) and (mapData:isObstacle(x, y) == 0 or (x == sX and y == sY)) then
                lenS = calcDistance(cc.p(sX, sY), cc.p(x, y))
                lenD = calcDistance(cc.p(dX, dY), cc.p(x, y))
                lenA = (lenS*1.1) + lenD
                if lenA < cost and squLen(x - dX, y - dY) >= seqMR then
                    bestI = index
                    cost  = lenA
                end

                items[index] = cc.p(x, y)
                index = index + 1
            end
        end
    end
    
    if bestI and items[bestI] then
        return items[bestI].x, items[bestI].y
    end
    return dX, dY
end

local function attackEnable(sX, sY, dX, dY)
    if sX == dX and sY == dY then
        return false
    end
    
    if sX == dX or sY == dY then
        return true
    end
    
    local slope = (dX - sX) / (dY - sY)
    return 1 == math.abs(slope)
end

local function skillEnable(sX, sY, dX, dY)
    return true
end

local function moveEnable(sX, sY, dX, dY)
    return true
end

function PlayerInputProxy:FindBestAttackPos(sX, sY, dX, dY, range, minRange)
    return self:findBestSkillPos(sX, sY, dX, dY, range, attackEnable, minRange)
end

function PlayerInputProxy:FindBestSkillPos(sX, sY, dX, dY, range, minRange)
    return findBestPos(sX, sY, dX, dY, range, skillEnable, minRange)
end

function PlayerInputProxy:FindBestMovePos(sX, sY, dX, dY, range)
    return findBestPos(sX, sY, dX, dY, range, moveEnable)
end

function PlayerInputProxy:IsMovePermission()
    return self._movePermission
end

function PlayerInputProxy:SetMovePermission(permission)
    self._movePermission = permission
end

--------------------- target ------------------------------
function PlayerInputProxy:SetTargetID(targetID)
    self._lastTargetID  = self._targetID
    self._targetID      = targetID

    self:SetTraceOwnerPlayerState( false )

    global.Facade:sendNotification(global.NoticeTable.TargetChange, {targetID = targetID})
    SLBridge:onLUAEvent(LUA_EVENT_TARGET_CAHNGE, targetID)
    global.Facade:sendNotification(global.NoticeTable.TargetChange_After, {targetID = targetID})

    -- 记录上次目标
    if (nil == self._targetID) then
        if self._targetScheduleID then
            UnSchedule(self._targetScheduleID)
            self._targetScheduleID = nil
        end
        self._targetScheduleID = PerformWithDelayGlobal(function()
            self._lastTargetID = nil
            self._targetScheduleID = nil
        end, 5)
    end

    -- clear auto lock
    if nil == self._targetID then
        local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
        autoProxy:ClearAutoLock()
        autoProxy:ClearDu()
    end

    local actor    = global.actorManager:GetActor(targetID)
    if not targetID or not actor then
        ssr.ssrBridge:OnTargetChange(nil)
        return
    end

    if actor:IsPlayer() or actor:IsMonster() then
        local type = actor:IsPlayer() and 1 or 2
        ssr.ssrBridge:OnTargetChange(targetID, actor:GetName(), actor:GetHP(), actor:GetMaxHP(), actor:GetLevel(), type, actor:GetMasterID(), actor:GetTypeIndex(), actor:GetMapX(), actor:GetMapY())
    else
        ssr.ssrBridge:OnTargetChange(nil)
    end
end

function PlayerInputProxy:SetOwnerPlayerID( ID )
    if ID == "" or ID == -1 then
        ID = nil
    end

    self._ownerPlayerID = ID

    global.Facade:sendNotification( global.NoticeTable.Layer_Monster_Belong_TargetChange,{targetID=ID or self._targetID} )
end

function PlayerInputProxy:GetOwnerPlayerID()
    return self._ownerPlayerID
end

function PlayerInputProxy:IsTraceOwnerPlayer()
    return self._isTraceOwnerPlayer == true
end

function PlayerInputProxy:SetTraceOwnerPlayerState( state )
    self._isTraceOwnerPlayer = state

    if self._ownerPlayerID then --是否有归属
        local mainPlayer        = global.gamePlayerController:GetMainPlayer()
        if not mainPlayer then
            return
        end

        local AutoProxy         = global.Facade:retrieveProxy( global.ProxyTable.Auto )
        local AutoController    = global.Facade:retrieveMediator( "AutoController" )
        
        AutoProxy:SetIsAutoLockState( true )
        AutoController:checkLaunchSimpleSkill( mainPlayer )

    end

    global.Facade:sendNotification( global.NoticeTable.Layer_Monster_Belong_Select )
end

function PlayerInputProxy:GetTargetID()
    if self._isTraceOwnerPlayer then
        return self._ownerPlayerID or self._targetID
    end

    return self._targetID
end

function PlayerInputProxy:ClearTarget()
    self:SetTargetID(nil)
end

function PlayerInputProxy:GetLastTargetID()
    return self._lastTargetID
end

function PlayerInputProxy:SetAttackTargetID(targetID)
    self._attackTargetID = targetID
    
    global.Facade:sendNotification(global.NoticeTable.AttackTargetChange, {targetID = targetID})
end

function PlayerInputProxy:GetAttackTargetID()
    return self._attackTargetID
end

function PlayerInputProxy:ClearAttackTargetID()
    self:SetAttackTargetID(nil)
end

function PlayerInputProxy:SetAttackState(state)
    self._attackState = state
end

function PlayerInputProxy:IsAttackState()
    return self._attackState
end
--------------------- target end ------------------------------


--------------------- move ------------------------------
function PlayerInputProxy:SetCurrMovePos(pos)
    self._moveDirty = true
    self._currMovePos = pos
end

function PlayerInputProxy:GetCurrMovePos()
    return self._currMovePos
end

function PlayerInputProxy:IsMoveDirty()
    return self._moveDirty
end

function PlayerInputProxy:IsMoving()
    return self:IsMoveDirty() or self:GetCurrPathPoint() > 0
end

function PlayerInputProxy:GetMoveInterruptFlag()
    if not self._currMovePos then
        return false
    end
    
    return self._currMovePos.isInterrupt
end

function PlayerInputProxy:SetMoveInterruptFlag(flag)
    if self._currMovePos then
        self._currMovePos.isInterrupt = flag
    end
end

function PlayerInputProxy:SetCurrMoveType(type)
    self._moveType = type
end

function PlayerInputProxy:GetCurrMoveType()
    return self._moveType
end

function PlayerInputProxy:SetPathFindPoints(points)
    self._pathFindPoints = points
    self._moveDirty = nil
    
    local size = self:GetPathPointSize()
    self:SetCurrPathPoint(size)
    
    if size > 1 then
        -- move begin
        global.Facade:sendNotification(global.NoticeTable.FindPathPointsBegin)
    else
        -- move end
        global.Facade:sendNotification(global.NoticeTable.FindPathPointsEnd)
    end
end

function PlayerInputProxy:GetPathFindPoints()
    return self._pathFindPoints or {}
end

function PlayerInputProxy:GetPathPointSize()
    if self._pathFindPoints then
        return #self._pathFindPoints
    end
    return 0
end

function PlayerInputProxy:SetCurrPathPoint(curr)
    self._currPathPoint = curr
end

function PlayerInputProxy:GetCurrPathPoint()
    return self._currPathPoint
end

function PlayerInputProxy:ClearMove()
    self:SetCurrMoveType(global.MMO.INPUT_MOVE_TYPE_OTHER)
    self:SetPathFindPoints(nil)
    
    self._currMovePos = nil
    self._moveDirty = nil
end

function PlayerInputProxy:SetIsMoveBlocked(v)
    self._isMoveBlocked = v
end

function PlayerInputProxy:IsMoveBlocked()
    return self._isMoveBlocked
end

function PlayerInputProxy:SetLaunchNoWalkPos( pos )
    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData then
        return nil
    end

    if self._launchNoWalkPos then
        mapData:setObstacle(self._launchNoWalkPos.x, self._launchNoWalkPos.y, 0)
        self._launchNoWalkPos = nil
    end

    if pos and self._moveType == global.MMO.INPUT_MOVE_TYPE_LAUNCH then
        if mapData:isObstacle(pos.x, pos.y) == 0 then
            self._launchNoWalkPos = pos
            mapData:setObstacle(self._launchNoWalkPos.x, self._launchNoWalkPos.y, 1)
        end
    end

end

function PlayerInputProxy:GetLaunchNoWalkPos()
    return self._launchNoWalkPos
end
--------------------- move end------------------------------


--------------------- trun --------------------------------
function PlayerInputProxy:SetMouseTurnDir(dir)
    self._mouseTurnDir = dir
end

function PlayerInputProxy:GetMouseTurnDir()
    return self._mouseTurnDir
end

function PlayerInputProxy:ClearMouseTurnDir()
    self._mouseTurnDir = global.MMO.ORIENT_INVAILD
end

function PlayerInputProxy:RequestActorTurn(dir)
	local mainPlayer = global.gamePlayerController:GetMainPlayer()
	if mainPlayer and dir and dir >= global.MMO.ORIENT_U and dir <= global.MMO.ORIENT_LU then
		local x = mainPlayer:GetMapX()
		local y = mainPlayer:GetMapY()
		local point = y * 65536 + x
		LuaSendMsg( global.MsgType.MSG_CS_MAIN_PLAYER_TURN, point, 0, dir)
	end
end
--------------------- trun --------------------------------


--------------------- skill --------------------------------
function PlayerInputProxy:IsLaunchDirty()
    return self._launchDirty
end

function PlayerInputProxy:ResetLaunchDirty()
    self._launchDirty = false
end

function PlayerInputProxy:GetLaunchPriority()
    return self._launchPriority
end

function PlayerInputProxy:ClearLaunch()
    self._launchDirty       = false
    self._skillID           = nil
    self._launchPos         = nil
    self._launchTargetID    = nil
    self._launchPriority    = global.MMO.LAUNCH_PRIORITY_SYSTEM
    self._launchType        = global.MMO.LAUNCH_TYPE_USER
end

function PlayerInputProxy:SetLaunchSkillID(skillID, priority, launchType)
    self._launchDirty       = nil ~= skillID
    self._skillID           = skillID
    self._launchPriority    = priority or global.MMO.LAUNCH_PRIORITY_SYSTEM
    self._launchType        = launchType or global.MMO.LAUNCH_TYPE_USER
end

function PlayerInputProxy:GetLaunchSkillID()
    return self._skillID
end

function PlayerInputProxy:SetLaunchTargetPos(pos)
    self._launchPos = pos
end

function PlayerInputProxy:GetLaunchTargetPos()
    return self._launchPos
end

function PlayerInputProxy:SetLaunchTargetID(id)
    self._launchTargetID = id
end

function PlayerInputProxy:GetLaunchTargetID()
    return self._launchTargetID
end

function PlayerInputProxy:GetLaunchType()
    return self._launchType
end

--------------------- skill end ------------------------------


--------------------- collect ------------------------------
function PlayerInputProxy:GetCollectCount()
    return self._collectCount
end

function PlayerInputProxy:AddCollectCount()
    self._collectCount = self._collectCount + 1
end

function PlayerInputProxy:SubCollectCount()
    self._collectCount = self._collectCount - 1
end
--------------------- collect ------------------------------

--------------------- dig corpse --------------------
function PlayerInputProxy:GetCorpseID()
    return self._coprseID
end

function PlayerInputProxy:SetCorpseID(id)
    self._coprseID = id
end

function PlayerInputProxy:ClearCorpse()
    self._coprseID = nil
end

function PlayerInputProxy:GetDigDest()
    return self._digDest
end

function PlayerInputProxy:SetDigDest(dest)
    self._digDest = dest
end

function PlayerInputProxy:ClearDigDest()
    self:SetDigDest(nil)
end

--------------------- mining --------------------
function PlayerInputProxy:GetMiningDir()
    return self._miningDir
end

function PlayerInputProxy:SetMiningDir(dir)
    self._miningDir = dir
end

function PlayerInputProxy:GetMiningDest()
    return self._miningDest
end

function PlayerInputProxy:SetMiningDest(dest)
    self._miningDest = dest
end

function PlayerInputProxy:ClearMining()
    self._miningDir = nil
    self._miningDest = nil
end

function PlayerInputProxy:IsLaunchMining( dest )
    if not dest then
        return false
    end

    local actor = global.actorManager:GetNPCActorByMapXY(dest.x,dest.y)
    if actor and actor:IsNPC() then
        return false
    end

    return true
end

--------------------- mouse touch ------------------
function PlayerInputProxy:SetMouseTouchPos(pos)
    self._mouseTouchPos = pos
end

function PlayerInputProxy:GetMouseTouchPos()
    return self._mouseTouchPos
end

function PlayerInputProxy:SetMouseTouchWay(way)
    self._mouseTouchWay = way
end

function PlayerInputProxy:GetMouseTouchWay()
    return self._mouseTouchWay
end

function PlayerInputProxy:ClearMouseTouch()
    self._mouseTouchPos = nil
    self._mouseTouchWay = nil
end

--------------------- 挖矿 --------------------
function PlayerInputProxy:CheckMiningAble()
	local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
	local equipTypeConfig = EquipProxy:GetEquipTypeConfig()
	local equip = EquipProxy:GetEquipDataByPos(equipTypeConfig.Equip_Type_Weapon)
    
	if equip and equip.Shape == 19 and equip.Dura ~= nil and equip.Dura > 0 then
		return true
	end
	return false
end

function PlayerInputProxy:ClearMining()
    self._miningPos = nil
    self._miningDir = nil
end

function PlayerInputProxy:SetMiningPos(pos)
    self._miningPos = pos
end

function PlayerInputProxy:GetMiningPos()
    return self._miningPos
end

function PlayerInputProxy:GetMiningDir()
    return self._miningDir
end

function PlayerInputProxy:SetMiningDir(dir)
    self._miningDir = dir
end
--------------------- 挖矿 --------------------


--------------------- collect begin ------------------------------
function PlayerInputProxy:RequestCollect()
    local targetID  = self:GetTargetID()
    if targetID then
        LuaSendMsg(global.MsgType.MSG_CS_COLLECT_REQUEST, 0, 0, 0, 0, targetID, string.len(targetID))
    end
end

function PlayerInputProxy:CompletedCollect()
    local targetID  = self:GetTargetID()
    if targetID then
        LuaSendMsg(global.MsgType.MSG_CS_COLLECT_COMPLETED, 0, 0, 0, 0, targetID, string.len(targetID))
    end
end

function PlayerInputProxy:RequestDigCorpse(dir, id)
    local jsonData      = {}
    jsonData.Dir        = dir
    jsonData.ID         = id
    local jsonStr       = cjson.encode(jsonData)
    LuaSendMsg(global.MsgType.MSG_CS_PICK_CORPSE, 0, 0, 0, 0, jsonStr, string.len(jsonStr))
end

function PlayerInputProxy:handle_MSG_SC_COLLECT_COMPLETED(msg)
    local header = msg:GetHeader()

    if header.pram1 == 1 then --开始采集状态
        global.Facade:sendNotification(global.NoticeTable.CollectBegin)
    elseif header.param2 == 2 then --结束采集状态
        global.Facade:sendNotification(global.NoticeTable.CollectCompleted)
    end
end
--------------------- collect end ------------------------------

function PlayerInputProxy:GetMouseOverTargetID()
    return self._mouseOverTargetID
end

function PlayerInputProxy:SetMouseOverTargetID(targetID)
    self._mouseOverTargetID = targetID
end


function PlayerInputProxy:onRegister()
    PlayerInputProxy.super.onRegister(self)
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_COLLECT_COMPLETED, handler(self, self.handle_MSG_SC_COLLECT_COMPLETED))
end

return PlayerInputProxy
