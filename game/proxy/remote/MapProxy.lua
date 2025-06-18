local RemoteProxy = requireProxy("remote/RemoteProxy")
local MapProxy = class("MapProxy", RemoteProxy)
MapProxy.NAME = global.ProxyTable.Map

local ssplit  = string.split

local Forbids = {
    GUILD = false,      -- 禁止显示行会名
    JOBLV = false,      -- 禁止显示等级和职业
    SAY   = false,      -- 禁止说话
    CHECK = false,      -- 禁止查看
    HPPER = false,      -- 血量显示百分比
    NAME  = false,      -- 统一名字
} 

local function get_bit(num, pos)
    if pos > 0 then
        pos = 32 - pos
    end
    return bit.band(bit.rshift(num, pos), 0x1)
end

-- 点到线段的距离  
local function getDistancePointToLine(lineA, lineB, point)
    local Ap = cc.p(0, 0)
    local Ab = cc.p(0, 0)
    local Bp = cc.p(0, 0)

    Ap.x = point.x - lineA.x
    Ap.y = point.y - lineA.y

    Ab.x = lineB.x - lineA.x
    Ab.y = lineB.y - lineA.y

    Bp.x = point.x - lineB.x
    Bp.y = point.y - lineB.y

    local r = (Ap.x * Ab.x + Ap.y * Ab.y) / (Ab.x * Ab.x + Ab.y * Ab.y)

    if r <= 0 then
        return math.floor(math.sqrt(Ap.x * Ap.x + Ap.y * Ap.y))
    end

    if r >= 1 then
        return math.floor(math.sqrt(Bp.x * Bp.x + Bp.y * Bp.y))
    end

    local px = lineA.x + Ab.x * r
    local py = lineA.y + Ab.y * r
    return math.floor(math.sqrt((point.x - px) * (point.x - px) + (point.y - py) * (point.y - py)))
end

function MapProxy:ctor()
    MapProxy.super.ctor(self)
    
    self._lastMapID = nil
    self._property = {}
    self._inSafeArea = false
    self._shakeGlobalHandle = nil       -- 屏幕震动的全局延时回调
    self._openDoorAble = true           -- 是否允许请求开门
    self._safeAreaID = nil              -- 安全区id  脚本进出安全区操作
    self._mainPlaySafeAreaOwn = false   -- 主玩家是否远离安全区

    self._shabakeOpen = false           -- 沙巴克开启状态
    self._isCheckShaBaKeZone = false    -- 是否检测沙巴克区域
    self._shabakeZone = {}              -- 沙巴克区域
end

function MapProxy:GetMapID()
    return self._property.MapId
end

function MapProxy:GetMapName()
    return self._property.MapName
end

function MapProxy:GetLastMapID()
    return self._lastMapID
end

function MapProxy:GetMiniMapID()
    return self._property.Minimap
end

function MapProxy:SetShaBaKeOpen(state)
    self._shabakeOpen = state
end

function MapProxy:IsShaBaKeOpen()
    return self._shabakeOpen == true
end

function MapProxy:IsCheckShaBaKeZone()
    return self._isCheckShaBaKeZone
end

function MapProxy:GetMiniMapFile()
    local miniMapID = self:GetMiniMapID()
    if not miniMapID or miniMapID == 0 then
        if SL:GetMetaValue("GAME_DATA","CancelDefaultMiniMap") == 1 then
            return nil
        end
        return getResFullPath("scene/uiminimap/default.png")
    end
    return getResFullPath(string.format("scene/uiminimap/%06d.png", miniMapID - 1))
end

function MapProxy:CheckMiniMapAble()
    local minimapFile = self:GetMiniMapFile()
    if not minimapFile then
        return false
    end
    return global.FileUtilCtl:isFileExist(minimapFile)
end

function MapProxy:GetMapDataID()
    if self._property and self._property.sourid then
        return self._property.sourid
    end
    
    return self:GetMapID()
end

function MapProxy:IsMainPlayerSafeAreaOwn()
    return self._mainPlaySafeAreaOwn
end

function MapProxy:HasSafeArea()
    if not self._property then
        return false
    end
    if (not self._property.SafePoint) or (not self._property.SafePoint[1]) then
        return false
    end

    return true
end

-- 是否是安全地图
function MapProxy:IsSafeMap()
    return bit.band(bit.rshift(self:GetFlag(), 1), 1) == 1
end

function MapProxy:GetInSafeArea(playerMapX, playerMapY, isCheckDistance)
    if not playerMapX or not playerMapY then
        return false
    end

    if self:IsSafeMap() then
        return true
    end

    if not self:HasSafeArea() then
        return false
    end

    local playerPoint = cc.p(playerMapX, playerMapY)
    local safePoint = self._property.SafePoint
    local distance  = nil
    for i,point in ipairs(safePoint) do
        if  ((playerMapY - point[2]) * (point[3] - point[1]) - (playerMapX - point[1]) * (point[4] - point[2]) <= 0) and
            ((playerMapY - point[4]) * (point[5] - point[3]) - (playerMapX - point[3]) * (point[6] - point[4]) <= 0) and
            ((playerMapY - point[6]) * (point[7] - point[5]) - (playerMapX - point[5]) * (point[8] - point[6]) <= 0) and
            ((playerMapY - point[8]) * (point[1] - point[7]) - (playerMapX - point[7]) * (point[2] - point[8]) <= 0) then
            self._safeAreaID = point[9]
            return true
        end
        if isCheckDistance then
            if not distance then
                distance = getDistancePointToLine(cc.p(point[1], point[2]), cc.p(point[3], point[4]), playerPoint)
            else
                distance = math.min(getDistancePointToLine(cc.p(point[1], point[2]), cc.p(point[3], point[4]), playerPoint), distance)
            end
            distance = math.min(getDistancePointToLine(cc.p(point[3], point[4]), cc.p(point[5], point[6]), playerPoint), distance)
            distance = math.min(getDistancePointToLine(cc.p(point[5], point[6]), cc.p(point[7], point[8]), playerPoint), distance)
            distance = math.min(getDistancePointToLine(cc.p(point[7], point[8]), cc.p(point[1], point[2]), playerPoint), distance)
        end
    end

    return false, distance
end

function MapProxy:UpdateInSafeAreaState()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return false
    end

    local mapX = mainPlayer:GetMapX()
    local mapY = mainPlayer:GetMapY()
    local inSafeArea, distance = self:GetInSafeArea(mapX, mapY, true) 
    inSafeArea = inSafeArea or (bit.band(bit.rshift(self:GetFlag(), 1), 1) == 1)--地图标记(安全区域)
    local maxDistance = 16
    distance = distance or maxDistance
    self._mainPlaySafeAreaOwn = distance > maxDistance
    if inSafeArea ~= self._inSafeArea then
        self._inSafeArea = inSafeArea
        global.Facade:sendNotification(global.NoticeTable.MapStateChange, self:IsInSafeArea())
        SLBridge:onLUAEvent(LUA_EVENT_MAP_STATE_CHANGE, self._inSafeArea)

        if self._safeAreaID then
            local safeAreaID = self._safeAreaID
            if not inSafeArea then
                self._safeAreaID = nil
            end
            if safeAreaID > 0 then
                LuaSendMsg(global.MsgType.MSG_CS_CHANGESAFEAREA, inSafeArea and 1 or 0, safeAreaID)
            end
        end
    end
end

-- 是否在安全区域
function MapProxy:IsInSafeArea()
    return self._inSafeArea 
end

-- 是否可以穿人
function MapProxy:IsCrossPlayerEnable()
    -- 攻城战 禁止穿所有
    if self._isSiegeWar and self._property.WarDisAll == 1 then
        return false
    end
    return self._property.througHHum == 1 or self._property.througHHum == 3 or self._property.RunHuman == 1
end

-- 是否可以穿怪
function MapProxy:IsCrossMonsterEnable()
    -- 攻城战 禁止穿所有
    if self._isSiegeWar and self._property.WarDisAll == 1 then
        return false
    end
    return self._property.througHHum == 2 or self._property.througHHum == 3 or self._property.RunMon == 1
end

-- 是否可以穿NPC
function MapProxy:IsCrossNpcEnable()
    -- 攻城战 禁止穿所有
    if self._isSiegeWar and self._property.WarDisAll == 1 then
        return false
    end
    return self._property.RunNpc == 1
end

-- 是否可以穿守卫
function MapProxy:IsCrossDefenderEnable()
    -- 攻城战 禁止穿所有
    if self._isSiegeWar and self._property.WarDisAll == 1 then
        return false
    end
    return CHECK_SERVER_OPTION("RunGuard") == 1
end

function MapProxy:IsCrossAllSafeArea()
    return CHECK_SERVER_OPTION("SafeZoneRunAll")
end

-- 安全区禁止穿NPC
function MapProxy:IsFirbidCrossNpcSafeArea()
    return CHECK_SERVER_OPTION("DisRunSafeZoneNpc")
end

-- 安全区禁止穿摆摊玩家
function MapProxy:IsFirbidCrossStallSafeArea()
    return CHECK_SERVER_OPTION("DisRunSafeZoneStall")
end

-- 安全区禁止穿离线玩家
function MapProxy:IsFirbidCrossOfflineSafeArea()
    return CHECK_SERVER_OPTION("DisRunSafeZoneOffline")
end

-- 管理员穿所有
function MapProxy:IsGMRunAll()
    return CHECK_SERVER_OPTION("GMRunAll")
end

-- 是否是管理员
function MapProxy:IsAdmin()
    return self._property.isAdmin or CHECK_SERVER_OPTION("isAdmin")
end

-- 是否允许走路穿人
function MapProxy:IsAbleWalkCrossPlayer()
    return self._property.WALKHuman == 1
end

-- 是否允许走路穿怪
function MapProxy:IsAbleWalkCrossMonster()
    return self._property.WALKMON == 1
end

-- 能否改变攻击模式
function MapProxy:IsChangePKStateEnable()
    return self._property.ChangeAttMode == 0
end

-- 地图标记
function MapProxy:GetFlag()
    return self._property.MapFlag or 0
end

-- 行会战地图标识 取值16  按位取值5
function MapProxy:IsMapWar()
    local mapFlag = self:GetFlag()
    return bit.band(bit.rshift(mapFlag, 4), 1) == 1
end

-- 吃物品速度
function MapProxy:GetEatItemSpeed()
    return CHECK_SERVER_OPTION("EatItemSpeed")
end

-- 击NPC间隔
function MapProxy:GetClickNpcSpeed()
    return CHECK_SERVER_OPTION("ClickNpcSpeed") or 100
end

-- 转向间隔
function MapProxy:GetTurnIntervalTime()
    return (CHECK_SERVER_OPTION("TurnIntervalTime") or 200) + (global.MMO.NETWORK_DELAY * 1000)
end

-- 使用毒符方式（0：穿戴，1:背包，2：无）
function MapProxy:GetUseAmuletType()
    return CHECK_SERVER_OPTION("UseAmuletType")
end

-- 背景音乐
function MapProxy:GetMapBGM()
    return self._property.MusicID
end

-- 浑水摸鱼 禁止显示行会名
function MapProxy:IsForbidGuild()
    return Forbids.GUILD
end

-- 浑水摸鱼 禁止显示等级和职业
function MapProxy:IsForbidLvJob()
    return Forbids.JOBLV
end

-- 浑水摸鱼 禁止说话
function MapProxy:IsForbidSay()
    return Forbids.SAY
end

-- 浑水摸鱼 禁止查看
function MapProxy:IsForbidVisitPlayer()
    return Forbids.CHECK
end

-- 浑水摸鱼 血量显示百分比
function MapProxy:IsHPPercent()
    return Forbids.HPPER
end

-- 是否统一名字
function MapProxy:IsUnitiveName()
    return Forbids.NAME
end

-- 获取统一名字
function MapProxy:GetUnitiveName()
    -- 后端统一改
    if not self:IsUnitiveName() then
        return "ERROR UNITIVE NAME"
    end
    if not self._property.SecretConfig or "" == self._property.SecretConfig then
        return "ERROR UNITIVE NAME"
    end
    local slices = ssplit(self._property.SecretConfig, "|")
    return tostring(slices[2])
end

function MapProxy:SetForbidData()
    if not self._property.SecretConfig or "" == self._property.SecretConfig then
        Forbids.GUILD = false
        Forbids.JOBLV = false
        Forbids.SAY   = false
        Forbids.CHECK = false
        Forbids.HPPER = false
        Forbids.NAME  = false
    else
        local slices = ssplit(self._property.SecretConfig, "|")
        local option = tonumber(slices[1])
        local value1 = bit.band(bit.rshift(option, 0), 1)
        local value2 = bit.band(bit.rshift(option, 2), 1)
        local value3 = bit.band(bit.rshift(option, 3), 1)
        local value5 = bit.band(bit.rshift(option, 5), 1)
        Forbids.GUILD = option > 32
        Forbids.JOBLV = option > 32
        Forbids.SAY   = value1 == 1
        Forbids.CHECK = value2 == 1
        Forbids.NAME  = value3 == 1
        Forbids.HPPER = value5 == 1
    end
end

-- 后仰 时间
function MapProxy:GetStuckActionTime()
    return self._property.StruckTime
end

--是否可以放某个技能
function MapProxy:IsForbidLaunchSkill(skillID)
    if not self._property.NotAllowUseMagic or self._property.NotAllowUseMagic == "" then
        return false
    end
    
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local slices = ssplit(self._property.NotAllowUseMagic, "|")
    for _, v in pairs(slices) do
        local tid = SkillProxy:GetSkillIDByName(v)
        if tid == skillID then
            return true
        end
    end

    return false
end

--是否在沙巴克区域
function MapProxy:CheckShaBeKeZone(mapX, mapY)
    if not mapX or not mapY then
        return false
    end

    if self._shabakeZone.isMapGloabl then
        return true
    end

    if not self._shabakeZone.finish then
        self._shabakeZone.finish = true
        local cPointX = tonumber(SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_HOME_X))
        local cPointY = tonumber(SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_HOME_Y))
        local rangeX  = tonumber(SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_RANGE_X))
        local rangeY  = tonumber(SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_RANGE_Y))
        if cPointX or cPointY then
            self._shabakeZone.cPoint = cc.p(cPointX or 0, cPointY or 0)
        end
        if rangeX or rangeY then
            self._shabakeZone.range     = cc.p(rangeX or 0, rangeY or 0)
        end
    end

    if self._shabakeZone.cPoint and self._shabakeZone.range then
        if math.abs(self._shabakeZone.cPoint.x-mapX) < self._shabakeZone.range.x 
            and math.abs(self._shabakeZone.cPoint.y-mapY) < self._shabakeZone.range.y then
            return true
        end
    end
    return false
end

-- 是否在攻城区域
function MapProxy:IsInSiegeArea()
    return self._isSiegeWar
end
-----------------------------------------------------------------------------
function MapProxy:RequestOpenDoor(px, py)
    if not self._openDoorAble then
        return false
    end
    self._openDoorAble = false

    PerformWithDelayGlobal(function()
        self._openDoorAble = true
    end, 0.5)

    if global.sceneManager:canOpenDoor(px, py) then
		LuaSendMsg(global.MsgType.MSG_CS_OPEN_DOOR_REQUEST, 0, px, py)
	end
end

function MapProxy:handle_MSG_SC_MAP_CHANGE(msg)
    local msgHdr = msg:GetHeader()
    local param3 = msgHdr.param3
    local througHHum = self._property.througHHum
    self._lastMapID = self:GetMapID()
    local jsonData = ParseRawMsgToJson(msg)

    jsonData.RunHuman   = jsonData.RunHuman or bit.band(bit.rshift(param3, 0), 0x1)
    jsonData.RunMon     = jsonData.RunMon or bit.band(bit.rshift(param3, 1), 0x1)
    jsonData.RunNpc     = jsonData.RunNpc or bit.band(bit.rshift(param3, 2), 0x1)
    jsonData.WarDisAll  = jsonData.WarDisAll or bit.band(bit.rshift(param3, 3), 0x1)
    jsonData.WALKMON    = jsonData.WALKMON or bit.band(bit.rshift(param3, 4), 0x1)
    jsonData.WALKHuman  = jsonData.WALKHuman or bit.band(bit.rshift(param3, 5), 0x1)
    jsonData.isAdmin    = jsonData.isAdmin or bit.band(bit.rshift(param3, 6), 0x1) == 1

    -- 表头那个值包含128, 对应mapflag+4
    if bit.band(bit.rshift(param3, 7), 0x1) == 1 then
        local mapFlag = tonumber(jsonData.MapFlag) or 0 
        jsonData.MapFlag = mapFlag + 4
    end

    -- 黑夜
    local DarkLayerProxy = global.Facade:retrieveProxy(global.ProxyTable.DarkLayerProxy)
    if bit.band(bit.rshift(param3, 8), 0x1) == 1 then
        jsonData.DayLight = jsonData.DayLight or DarkLayerProxy.STATE.night
    elseif bit.band(bit.rshift(param3, 9), 0x1) == 1 then
        jsonData.DayLight = jsonData.DayLight or DarkLayerProxy.STATE.sunrise
    elseif bit.band(bit.rshift(param3, 10), 0x1) == 1 then
        jsonData.DayLight = jsonData.DayLight or DarkLayerProxy.STATE.evening
    end

    if bit.band(bit.rshift(param3, 11), 0x1) == 1 then
        jsonData.EnableDayLight = jsonData.EnableDayLight or DarkLayerProxy.MODE.dark
    end

    self._safeAreaID = nil
    self._property.SafePoint = nil
    self._property = jsonData
    self._property.througHHum = througHHum

    self:SetForbidData()
    
    local date = os.date("*t")
    print("--------------------------", string.format("%s/%s/%s %s:%s:%s", date.year, date.month, date.day, date.hour, date.min, date.sec))
    dump(jsonData, "_________handle_MSG_SC_MAP_CHANGE")
    local msgHdr = msg:GetHeader()
    local mapX = msgHdr.param1
    local mapY = msgHdr.param2
    global.gamePlayerController:OnChangeScene(mapX, mapY)
    
    -- print("切换地图")
    local mediator = global.Facade:retrieveMediator("NoticeMediator")
    local proxy    = global.Facade:retrieveProxy("NoticeProxy")
    if mediator:GetEffectsData()[2] then
        for _,v in ipairs(mediator:GetEffectsData()[2]) do
            global.Facade:sendNotification(global.NoticeTable.Layer_Notice_RemoveChild, tostring(v))
        end
        mediator:GetEffectsData()[2] = {}
    end

    --light state 
    if DarkLayerProxy then
        if jsonData.EnableDayLight then
            DarkLayerProxy:setMode(jsonData.EnableDayLight)
        end
        if jsonData.DayLight then
            DarkLayerProxy:setState(jsonData.DayLight)
        end
    end

    local root   = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_DAMAGE)
    local sfxParent = root:getChildByName("MAP_SFX_PARENT")
    if sfxParent then
        sfxParent:removeFromParent()
        sfxParent = nil
    end

    self._shabakeZone.isMapGloabl = false
    self._isCheckShaBaKeZone = jsonData.MapId == SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_MAP_NAME)
    if not self._isCheckShaBaKeZone then
        self._isCheckShaBaKeZone = jsonData.MapId == SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_MAP_PALACE)
        self._shabakeZone.isMapGloabl = self._isCheckShaBaKeZone
    end

    if not self._isCheckShaBaKeZone then
        self._isCheckShaBaKeZone = jsonData.MapId == SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_MAP_SECRET)
        self._shabakeZone.isMapGloabl = self._isCheckShaBaKeZone
    end

    global.actorInViewController:Cleanup()

    global.HUDHPManager:Cleanup()
    
    self:UpdateInSafeAreaState()

    global.Facade:sendNotification(global.NoticeTable.ChangeScene, self:GetMapID(), self._lastMapID)

    -- 告诉服务器游戏帧率
    local fps   = global.Director:getFrameRate()
    local mapID = self:GetMapID()
    LuaSendMsg(global.MsgType.MSG_CS_NOTICE_FPS, fps, 0, 0, 0, mapID, string.len(mapID))
end

function MapProxy:handle_MSG_SC_ENTER_SAFE_AREA(msg)
    -- TODO
    local header = msg:GetHeader()
    local state = header.recog
    
    self._inSafeArea = (state == 0)
    global.Facade:sendNotification(global.NoticeTable.MapStateChange, self:IsInSafeArea())

end

function MapProxy:RespSiegeWarStatus(msg)
    -- 是否进入城堡(1是进入; 0是离开)
    local header     = msg:GetHeader()
    self._isSiegeWar = (header.recog == 1)
    global.Facade:sendNotification(global.NoticeTable.SiegeAreaChange, self._isSiegeWar)
    SLBridge:onLUAEvent(LUA_EVENT_MAP_SIEGEAREA_CHANGE, self._isSiegeWar)
end

function MapProxy:handle_MSG_SC_RESPONE_SCENE_SHAKE(msg)
    local header = msg:GetHeader()
    local shakeLevel = header.recog
    local shakeTimes = header.param1 or 0

    if not shakeLevel or shakeTimes < 1 then
        return false
    end

    if self._shakeGlobalHandle then
        global.Scheduler:unscheduleScriptEntry(self._shakeGlobalHandle)
    end
    self._shakeGlobalHandle = nil


    local function shakeFunc(time, count, distance)
        if time >= count then
            return false
        end

        local delayTime = 1000
        global.Facade:sendNotification(global.NoticeTable.ShakeScene, {time = delayTime, distance = distance})

        self._shakeGlobalHandle = PerformWithDelayGlobal(function()
            self._shakeGlobalHandle = nil
            shakeFunc(time+1, count, distance)
        end, delayTime * 0.001)
    end

    local distance = (({3, 5, 7})[shakeLevel]) or 20
    shakeFunc(0, shakeTimes, distance)
end

-- 穿人穿怪
function MapProxy:handle_MSG_SM_THROUGHHUM(msg)
    local header = msg:GetHeader()
    if self._property.througHHum ~= header.param1 then
        self._property.througHHum = header.param1
        global.Facade:sendNotification(global.NoticeTable.Map_Refresh_Throug_HHum)
    end
end

-- 播放特效
function MapProxy:handle_MSG_SC_MAP_PLAY_EFFECT(msg)
    local msgHdr = msg:GetHeader()
    
    if not msgHdr.param1 or msgHdr.param1 == 0 then
        return
    end

    -- 播放特效
    local sfxAnim = global.FrameAnimManager:CreateSFXAnim(msgHdr.param1)
    if not sfxAnim then
        return
    end

    local root = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_DAMAGE)
    local sfxParent = root:getChildByName("MAP_SFX_PARENT")
    if not sfxParent then
        sfxParent = cc.Node:create()
        sfxParent:setName("MAP_SFX_PARENT")
        root:addChild(sfxParent, 999)
    end

    sfxParent:addChild(sfxAnim, msgHdr.param1)
    local sfxPos = global.sceneManager:MapPos2WorldPos(msgHdr.param2, msgHdr.param3)
    sfxAnim:setPosition(sfxPos.x, sfxPos.y)
    sfxAnim:Play(0, 0)
    local function removeEvent()
        sfxAnim:removeFromParent()
    end
    sfxAnim:SetAnimEventCallback(removeEvent)
end

--场景切换时的配置修改
function MapProxy:handle_MSG_MSG_SM_MAP_CONFIG(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if jsonData and next(jsonData) then
        if not self._property or not next(self._property) then
            self._property = {}
        end

        for k,v in pairs(jsonData) do
            self._property[k] = v
        end

        self:SetForbidData()
        global.Facade:sendNotification(global.NoticeTable.Map_Refresh_Throug_HHum)
    end
end

--服务器开关配置修改
function MapProxy:handle_MSG_SM_CASTLEMAPINFO(msg)
    local jsonData = ParseRawMsgToJson(msg) or {}
    if not next(jsonData) then
        return
    end

    -- 服务器开关
    local ServerOptionsProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerOptionsProxy)
    for k, v in pairs(jsonData) do
        ServerOptionsProxy:setOptionByKey(k,v)
    end

    if not self._shabakeZone.isMapGloabl then
        local mapID = self:GetMapID()
        self._isCheckShaBaKeZone = mapID == SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_MAP_NAME)
        if not self._isCheckShaBaKeZone then
            self._isCheckShaBaKeZone = mapID == SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_MAP_PALACE)
            self._shabakeZone.isMapGloabl = self._isCheckShaBaKeZone
        end

        if not self._isCheckShaBaKeZone then
            self._isCheckShaBaKeZone = mapID == SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_MAP_SECRET)
            self._shabakeZone.isMapGloabl = self._isCheckShaBaKeZone
        end
    end

    global.Facade:sendNotification(global.NoticeTable.RefreshGuildActorColor )
end

function MapProxy:RegisterMsgHandler()
    MapProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType
    
    LuaRegisterMsgHandler(msgType.MSG_SC_MAP_CHANGE, handler(self, self.handle_MSG_SC_MAP_CHANGE))                      -- 切换地图
    LuaRegisterMsgHandler(msgType.MSG_SC_MAP_INIT, handler(self, self.handle_MSG_SC_MAP_CHANGE))                        -- 初始地图
    LuaRegisterMsgHandler(msgType.MSG_SC_ENTER_SAFE_AREA, handler(self, self.handle_MSG_SC_ENTER_SAFE_AREA))            -- 安全区域相关
    LuaRegisterMsgHandler(msgType.MSG_SC_SIEGEWAR_STATUS_CHANGE, handler(self, self.RespSiegeWarStatus))                -- 攻城状态
    LuaRegisterMsgHandler(msgType.MSG_SC_RESPONE_SCENE_SHAKE, handler(self, self.handle_MSG_SC_RESPONE_SCENE_SHAKE))    -- 屏幕震动
    LuaRegisterMsgHandler(msgType.MSG_SM_THROUGHHUM, handler(self, self.handle_MSG_SM_THROUGHHUM))                      -- 穿人穿怪消息
    LuaRegisterMsgHandler(msgType.MSG_SC_MAP_PLAY_EFFECT, handler(self, self.handle_MSG_SC_MAP_PLAY_EFFECT))           -- 在场景播放特效
    LuaRegisterMsgHandler(msgType.MSG_SM_MAP_CONFIG, handler(self, self.handle_MSG_MSG_SM_MAP_CONFIG))                 -- 场景切换时的配置修改
    LuaRegisterMsgHandler(msgType.MSG_SM_CASTLEMAPINFO, handler(self, self.handle_MSG_SM_CASTLEMAPINFO))                -- 服务器开关配置修改
end

function MapProxy:onRegister()
    MapProxy.super.onRegister(self)

    -- 主玩家
    local function actCallback(actor, act)
        -- update in safe zone
        if not self:HasSafeArea() and not self:IsCheckShaBaKeZone() then
            return nil
        end
        if IsMoveAction(act) then
            global.Facade:sendNotification(global.NoticeTable.RefreshActorSafeZone, actor:GetID())
            global.Facade:sendNotification(global.NoticeTable.RefreshActorShaBaKeZone, actor:GetID())

            self:UpdateInSafeAreaState()
        end
    end
    global.gamePlayerController:AddHandleOnActBegin(actCallback)

    -- 网络玩家
    local function actBegin(actor, act)
        -- update in safe zone
        if not self:HasSafeArea() and not self:IsCheckShaBaKeZone() then
            return nil
        end
        if self:IsCrossPlayerEnable() and not self:IsCheckShaBaKeZone() then
            return nil
        end
        if self:IsMainPlayerSafeAreaOwn() and not self:IsCheckShaBaKeZone() then
            return nil
        end
        if IsMoveAction(act) then
            global.Facade:sendNotification(global.NoticeTable.RefreshActorSafeZone, actor:GetID())
            global.Facade:sendNotification(global.NoticeTable.RefreshActorShaBaKeZone, actor:GetID())
        end
    end
    global.netPlayerController:AddHandleOnActBegin(actBegin)
    
    -- 怪物
    local function actBegin(actor, act)
        -- update in safe zone
        if not self:HasSafeArea() and not self:IsCheckShaBaKeZone() then
            return nil
        end
        if self:IsCrossMonsterEnable() and not self:IsCheckShaBaKeZone() then
            return nil
        end
        if self:IsMainPlayerSafeAreaOwn() and not self:IsCheckShaBaKeZone() then
            return nil
        end
        if IsMoveAction(act) then
            global.Facade:sendNotification(global.NoticeTable.RefreshActorSafeZone, actor:GetID())
            global.Facade:sendNotification(global.NoticeTable.RefreshActorShaBaKeZone, actor:GetID())
        end
    end
    global.netMonsterController:AddHandleOnActBegin(actBegin)
end

return MapProxy
