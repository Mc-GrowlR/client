local gameMapController = class("gameMapController")
gameMapController.NAME  = "gameMapController"

local optionsUtils = requireProxy("optionsUtils")
local cjson = require("cjson")

local fireSet = {
    [4]  = 27,      -- 困魔咒
    [5]  = 36,      -- 正常火墙
}

-- 转换race， 这些是守卫
local convertDefenderRace = 
{
    [11] = 1,
    [55] = 1,
    [110] = 1,
    [111] = 1,
    [112] = 1,
}

local function converActorData(msgHdr, jsonData)
    -- 为了服务器下发的数据包更小，同时为了客户端的逻辑改动更小，将受到的数据转化一下

    ---------------------------------------------------------------------------
    -- json数组 -> json对象
    jsonData.RaceServer         = jsonData.rs
    if jsonData.info then
        jsonData.UserID         = jsonData.info[1]
        jsonData.Name           = jsonData.info[2]
        jsonData.sex            = jsonData.info[3]
        jsonData.Hair           = jsonData.info[4]
        jsonData.Job            = jsonData.info[5]
    end
    if jsonData.sp then
        jsonData.WalkCurrSpeed  = jsonData.sp[1]
        jsonData.RunCurrSpeed   = jsonData.sp[2]
        jsonData.AttackCurrSpeed = jsonData.sp[3]
        jsonData.MagicCurrSpeed = jsonData.sp[4]
    end
    if jsonData.id then
        jsonData.clothID        = jsonData.id[1]
        jsonData.weaponID       = jsonData.id[2]
        jsonData.Cap            = jsonData.id[3]
        jsonData.clothEff       = jsonData.id[4]
        jsonData.weaponEff      = jsonData.id[5]
        jsonData.shieldID       = jsonData.id[6]
        jsonData.shieldEffect   = jsonData.id[7]
    end
    if jsonData.wex then --左武器外观ID
        jsonData.leftWeaponID = jsonData.wex
    end
    if jsonData.wfex then --左武器外观特效
        jsonData.leftWeaponEff = jsonData.wfex
    end
    if jsonData.horse then
        jsonData.mountID        = jsonData.horse[1]
        jsonData.mountEff       = jsonData.horse[2]
        jsonData.mountCloth     = jsonData.horse[3]
        jsonData.doubleTag      = jsonData.horse[4]
        jsonData.doubleUserId   = jsonData.horse[5]
    end
    if jsonData.cg then
        jsonData.ShenMiRen      = bit.band(bit.rshift(jsonData.cg, 0), 1)
        jsonData.RangeCanFindMe = bit.band(bit.rshift(jsonData.cg, 1), 1)
        jsonData.OffLine        = bit.band(bit.rshift(jsonData.cg, 2), 1)
    end
    if jsonData.state then
        jsonData.Group          = jsonData.state[1]
        jsonData.stallname      = jsonData.state[2]
        jsonData.castlename     = jsonData.state[3]
        jsonData.Candle         = tonumber(jsonData.state[4])
    end
    if jsonData.guild then
        jsonData.GuildID        = jsonData.guild[1]
        jsonData.GuildName      = jsonData.guild[2]
        jsonData.Rank           = jsonData.guild[3]
        jsonData.RankName       = jsonData.guild[4]
    end
    if jsonData.ms then
        jsonData.MasterId       = jsonData.ms[1]
    end
    if jsonData.ow then
        jsonData.OwnerID        = jsonData.ow[1]
        jsonData.OwnerName      = jsonData.ow[2]
    end
    if jsonData.data then
        jsonData.nLevel         = jsonData.data[1]
        jsonData.Hp             = jsonData.data[2]
        jsonData.MaxHp          = jsonData.data[3]
        jsonData.Color          = jsonData.data[4]
        jsonData.StoneMode      = jsonData.data[5]
        jsonData.pklv           = jsonData.data[6]
        jsonData.Through        = jsonData.data[7]
        jsonData.ActionType     = jsonData.data[8]
    end
    if jsonData.NoShow and jsonData.NoShow ~= "" then
        local paramArray        = string.split(jsonData.NoShow,"#")
        jsonData.noShowName     = tonumber(paramArray[1])
        jsonData.noShowHPBar    = tonumber(paramArray[2])
    end
    if jsonData.csd then
        jsonData.gmData         = jsonData.csd
    end
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- 消息头数据 
    -- race & raceImg
    local recog = msgHdr.recog
    jsonData.race = L16Bit(recog)
    jsonData.raceImg = H16Bit(recog)

    -- nActorId
    local param1 = msgHdr.param1
    jsonData.nActorId = param1

    -- x y
    local param2 = msgHdr.param2
    jsonData.X = L16Bit(param2)
    jsonData.Y = H16Bit(param2)
    
    -- dir & type
    local param3 = msgHdr.param3
    jsonData.type = L16Bit(param3)
    jsonData.Dir = H16Bit(param3)
    ---------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------
    -- 守卫，客户端通过RaceServer动态改变race
    if jsonData.RaceServer and convertDefenderRace[jsonData.RaceServer] then
        jsonData.race = global.MMO.ACTOR_RACE_DEFENDER
    end
    ---------------------------------------------------------------------------
    
    
    ---------------------------------------------------------------------------
    local cs = jsonData.cs or 0
    local caved         = bit.band(bit.rshift(cs, 0), 1) == 1   -- 洞穴，被隐藏
    local skeleton      = bit.band(bit.rshift(cs, 1), 1) == 1   -- 死亡，骨头
    local die           = bit.band(bit.rshift(cs, 2), 1) == 1   -- 死亡，躺下
    jsonData.caved      = caved
    jsonData.skeleton   = skeleton
    jsonData.die        = die
    ---------------------------------------------------------------------------

    return jsonData
end

function gameMapController:ctor()
    self.mNetActorMap = {}

    self.mBoundaryL  = nil
    self.mBoundaryR  = nil
    self.mBoundaryT  = nil
    self.mBoundaryB  = nil
    self.mViewCentOffset = cc.p( 0.0, 0.0 )

    self.mCamera = nil
    self.mViewSize = nil

    self.mFollowActorPos = cc.p( 0.0, 0.0 )

    self.mNetMsgHandle = {}

    self:Init()

    self:RegisterMsgHandler()
end

function gameMapController:destory()
    if gameMapController.instance then
        gameMapController.instance = nil
    end
end

function gameMapController:Inst()
    if not gameMapController.instance then
        gameMapController.instance = gameMapController.new()
    end

    return gameMapController.instance
end

-----------------------------------------------------------------------------
function gameMapController:Init()
    self:initMapScrollFollow()
end
-----------------------------------------------------------------------------
function gameMapController:initMapScrollFollow()
    local  winSize   = global.Director:getWinSize()
    self.mFullScreenSize = cc.p( winSize.width, winSize.height )
    self.mHalfScreenSize = cc.pMul( self.mFullScreenSize, 0.5 )

    local pcOffset = cc.p(-22, -80)
    if global.isWinPlayMode and SL:GetMetaValue("GAME_DATA", "PCMapCenterOffset") then
        local valueList = string.split(SL:GetMetaValue("GAME_DATA", "PCMapCenterOffset"), "|")
        if tonumber(valueList[1]) and tonumber(valueList[2]) then
            pcOffset = cc.p(tonumber(valueList[1]), tonumber(valueList[2]))
        end
    end

    local offset = global.isWinPlayMode and pcOffset or cc.p(0.0, 0.0)
    self:SetViewCenterOffset( offset.x, offset.y )
end
-----------------------------------------------------------------------------
function gameMapController:SetViewCamera( camera )
    self.mCamera = camera

    if self.mCamera then
        self.mCamera:retain()
    end
end
-----------------------------------------------------------------------------
function gameMapController:GetViewCamera()
    return self.mCamera
end
-----------------------------------------------------------------------------
function gameMapController:SetViewSize( size )
    self.mViewSize = size
end
-----------------------------------------------------------------------------
function gameMapController:GetViewSize() 
    if self.mViewSize then
        return self.mViewSize
    end

    local size = global.Director:getWinSize()
    if self.mCamera then
        local scaleX, scaleY = CalcCameraZoom(self.mCamera)
        size.width  = math.ceil(size.width  * scaleX)
        size.height = math.ceil(size.height * scaleY)
    end
    self.mViewSize = size
    
    return self.mViewSize
end
-----------------------------------------------------------------------------
function gameMapController:SetViewCenterOffset( x, y )
    self.mViewCentOffset.x = x
    self.mViewCentOffset.y = y

    global.sceneManager:SetViewCenterOffset( self.mViewCentOffset.x, self.mViewCentOffset.y )
end

function gameMapController:GetViewCenterOffset()
    return self.mViewCentOffset
end
-----------------------------------------------------------------------------
function gameMapController:followMainPlayer()
    if not global.gamePlayerController:GetMainPlayer() then return end

    if not self.mBoundaryB then return end

    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    local playerPos  = mainPlayer:getPosition()
    if self.mFollowActorPos.x == playerPos.x and self.mFollowActorPos.y == playerPos.y then
        return
    end
    self.mFollowActorPos.x = playerPos.x
    self.mFollowActorPos.y = playerPos.y

    if self.mCamera then
        local tempPos = cc.pAdd( playerPos, self.mViewCentOffset )
        self.mCamera:setPosition( tempPos )
    end
end
-----------------------------------------------------------------------------
function gameMapController:calcMapFollowParam( width, height )
    self.mBoundaryL = self.mHalfScreenSize.x
    self.mBoundaryR = math.max(width - self.mHalfScreenSize.x, 0)
    self.mBoundaryT = -self.mHalfScreenSize.y
    self.mBoundaryB = math.min(-(height - self.mHalfScreenSize.y), 0)
end
-----------------------------------------------------------------------------
function gameMapController:Cleanup()
    self:CleanupActor(true)
    self.mNetActorMap = {}

    if self.mCamera then
        self.mCamera:autorelease()
        self.mCamera = nil
    end
end
-----------------------------------------------------------------------------
function gameMapController:CleanupActor(cleanMainPlayer)
    global.npcManager:Cleanup()
    global.playerManager:Cleanup()
    global.monsterManager:Cleanup( false )
    global.dropItemManager:Cleanup()
    global.sceneEffectManager:Cleanup()
    global.netMonsterController:Cleanup( false )
    global.netPlayerController:Cleanup( false )

    -- clean up
    if global.gamePlayerController:GetMainPlayer() then
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        if not cleanMainPlayer then
            self.mNetActorMap[mainPlayer:GetID()] = nil
        end

        -- remove actors trace
        local noticeData = {
            actorID = nil,
        }

        local mapData = global.sceneManager:GetMapData2DPtr()
        for k,v in pairs(self.mNetActorMap) do
            noticeData.actor   = v
            noticeData.actorID = v:GetID()
            global.Facade:sendNotification(global.NoticeTable.ActorOutOfView, noticeData )
        end

        self.mNetActorMap = {}

        -- release all actor
        global.actorManager:RemoveAllActor( (not cleanMainPlayer) and mainPlayer:GetID() or 0 )

        -- keep trace main player
        if not cleanMainPlayer then
            global.playerManager:SetMainPlayerID( mainPlayer:GetID() )
            global.playerManager:AddPlayer( mainPlayer )
            self.mNetActorMap[mainPlayer:GetID()] = mainPlayer
        else
            global.gamePlayerController:CleanupMainPlayer()
            global.playerManager:CleanupMainPlayer()
        end
    end
end
-----------------------------------------------------------------------------
function gameMapController:handle_MSG_SC_MAP_ACTOR_CLEANUP( msg )
    self:CleanupActor( false )
    return 1
end
-----------------------------------------------------------------------------
function gameMapController:handleMessage(msg)
    local msgHdr  = msg:GetHeader()
    local msgLen  = msg:GetDataLength()
    local msgData = (msgLen > 0 and msg:GetData():ReadString(msgLen) or "")

    if self.mNetMsgHandle[msgHdr.msgId] then
        self.mNetMsgHandle[msgHdr.msgId](msgHdr, msgData)
    end
end

-----------------------------------------------------------------------------
function gameMapController:Tick( dt )
    self:followMainPlayer()
end
-----------------------------------------------------------------------------
function gameMapController:handle_MSG_SC_CREATE_MAIN_PLAYER( msg )
    -- 创建主玩家
    local msgHdr  = msg:GetHeader()
    local msgLen  = msg:GetDataLength()
    local msgData = (msgLen > 0 and msg:GetData():ReadString(msgLen) or "")
    
    self:handle_InOfView(msgHdr, msgData)
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    AuthProxy:RequestIsCloudLogin() --进入游戏上报云手机信息
end
-----------------------------------------------------------------------------
function gameMapController:refreshActor( actor, msgHdr, jsonData, action, stopAnimFrame )
    -- set actor property
    SetActorProperty( actor, jsonData )

    actor:SetAction( action, true )
    actor:stopAnimToFrame( stopAnimFrame )
    actor:dirtyAnimFlag()

    -- refresh pos
    local actorPos = cc.p(0,0)
    local mapX = jsonData.X
    local mapY = jsonData.Y
    actorPos = global.sceneManager:MapPos2WorldPos( mapX, mapY, true )
    actor:setPosition( actorPos.x, actorPos.y )
    global.actorManager:SetActorMapXY( actor, mapX, mapY )

    -- 非主玩家，强刷坐标时清理动作队列
    if actor:IsMonster() then
        global.netMonsterController:cleanupCacheByActorID(actor:GetID())
    elseif actor:IsPlayer() and not actor:IsMainPlayer() then
        global.netPlayerController:cleanupCacheByActorID(actor:GetID())
    end
end
-----------------------------------------------------------------------------
function gameMapController:handle_InOfView(msgHdr, msgData)
    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end

    converActorData(msgHdr, jsonData)

    local actorID = jsonData.UserID
    if not actorID then
        return nil
    end

    -- 初始action
    local action        = global.MMO.ACTION_IDLE
    local stopAnimFrame = nil

    if jsonData.StoneMode == 1 then
        -- 1:祖玛雕像的石化状态
        action = global.MMO.ACTION_BORN
        stopAnimFrame = 1

    elseif jsonData.caved == true then
        -- 触龙神/食人花在地下隐藏状态
        action = global.MMO.ACTION_CAVE
        stopAnimFrame = 1

    elseif jsonData.skeleton == true then
        -- 死亡, 骨头
        action = global.MMO.ACTION_DEATH

    elseif jsonData.die == true then
        action = global.MMO.ACTION_DIE
        stopAnimFrame = -1
    end

    local actor = global.actorManager:GetActor( actorID )
    if actor then
        print("--------------- IN OF VIEW, ACTOR IS EXIST, 联系SFY", actorID, actor:GetName(), msgHdr.msgId)
        -- if msgHdr.msgId == global.MsgType.MSG_SC_CREATE_MAIN_PLAYER and actor:IsPlayer() then
        --     global.playerManager:SetMainPlayerID( actorID )
        --     global.gamePlayerController:BindMainActor( actor )
        --     global.actorManager:UpdateLockFrameT()
        -- end

        -- if actor:IsWall() and jsonData.Dir then
        --     stopAnimFrame = jsonData.Dir + 1
        -- end
        -- -- 城墙怪特殊，服务器先发死亡后发出生，导致状态不对，但是又要显示站立的模型，这儿要特殊处理
        -- if actor:IsWall() and (actor:IsDeath() or actor:IsDie()) then
        --     action = global.MMO.ACTION_DEATH
        -- end
        
        -- self:refreshActor( actor, msgHdr, jsonData, action, stopAnimFrame )
        -- SetActorName(actor, jsonData)
        -- global.Facade:sendNotification( global.NoticeTable.DelayRefreshHUDLabel, { actor = actor, actorID = actorID, hudParam = jsonData } )
        -- global.Facade:sendNotification( global.NoticeTable.DelayRefreshHUDTitle, { actor = actor, actorID = actorID, hudParam = jsonData } )
        -- if actor:IsWall() then
        --     -- 城墙怪，如果是死亡状态，模型使用站立
        --     if (actor:IsDeath() or actor:IsDie()) then
        --         actor:SetAnimAct(global.MMO.ANIM_IDLE)
        --     end
        --     actor:updateAnimation()

        --     actor:SetKeyValue(global.MMO.Is_Wall, true)
        -- end

        return actor
    end
    
    local race      = jsonData.race
    local isPlayer  = false
    local isNpc     = false
    local isMonster = false
    -- 0:player;1:hero;150:humanoid
    if race == 0 or race == 1 or race == 150 then
        isPlayer    = true
    elseif race == 50 then
        isNpc       = true
    else
        isMonster   = true
    end

    local initParam = {
        actorID = actorID,
        mapX    = jsonData.X or 0,
        mapY    = jsonData.Y or 0,
        action  = action,
        dir     = jsonData.Dir or 0,
        clothID = jsonData.clothID,
    }

    local actor   = nil
    local race    = jsonData.race
    -- 0:player;1:hero;150:humanoid
    if isPlayer then
        actor = global.netPlayerController:AddNetPlayerToWorld( initParam )
    elseif isNpc then
        actor = global.netNpcController:AddNetNpcToWorld( initParam )
    else
        actor = global.netMonsterController:AddNetMonsterToWorld( initParam )
    end

    if nil == actor then
        return nil
    end

    -- 主玩家，绑定创建
    if msgHdr.msgId == global.MsgType.MSG_SC_CREATE_MAIN_PLAYER and actor:IsPlayer() then
        global.playerManager:SetMainPlayerID( actorID )
        global.gamePlayerController:BindMainActor( actor )
        global.actorManager:UpdateLockFrameT()
    end

    ------------------------------------------------------------
    -- 是城墙
    if actor:IsWall() then
        if jsonData.Dir then
            stopAnimFrame = jsonData.Dir + 1
        end
        actor:SetKeyValue(global.MMO.Is_Wall, true)
    end

    -- restore actor data
    self:refreshActor( actor, msgHdr, jsonData, action, stopAnimFrame )

    -- 是沙巴克大门
    if actor:IsGate() then
        if jsonData.Dir then
            local isOpen = jsonData.Dir >= 3
            actor:setGateOpenState(isOpen)
        end
        actor:SetKeyValue(global.MMO.Is_Gate, true)
    end

    if actor:IsMonster() then
        -- Add to monster manager
        global.monsterManager:AddMonster( actor )

    elseif actor:IsPlayer() then
        -- Add to player manager
        global.playerManager:AddPlayer( actor )

    elseif actor:IsNPC() then
        -- Add to npc manager
        global.npcManager:AddNpc( actor )

    end

    -- Track Npc, NetPlayer, monster....
    self.mNetActorMap[actorID] = actor


    local noticeData = {
        actorID  = actorID,
        actor    = actor,
        hudParam = jsonData,
    }
    global.Facade:sendNotification(global.NoticeTable.ActorInOfView, noticeData)

    if jsonData.Effect then
        global.ActorEffectManager:ActorEffectRefresh({action = 1, items = jsonData.Effect})
    end

    self:refreshHorse(actor, jsonData)

    SLBridge:onLUAEvent(LUA_EVENT_ACTOR_IN_OF_VIEW, {id = actorID})
    return actor
end

function gameMapController:handle_DeathFallDown(msgHdr, msgData)
    if msgData == "" then
        return nil
    end
    local actorID = msgData
    local actor = global.actorManager:GetActor(actorID)
    if nil == actor then
        return nil
    end

    if actor:IsPlayer() then
        if actor:IsMainPlayer() then
            global.gamePlayerController:handle_Die(actor, msgHdr)  
            global.Facade:sendNotification(global.NoticeTable.Audio_Play_BGM, {type = global.MMO.SND_TYPE_BGM_DIE})
            local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
            PlayerPropertyProxy:setAlive(false)
        else
            global.netPlayerController:handle_Die(actor, msgHdr)
            SLBridge:onLUAEvent(LUA_EVENT_NET_PLAYER_DIE, {id = actorID})
        end
        global.Facade:sendNotification(global.NoticeTable.ActorPlayerDie, {actorID = actorID, actor = actor})
        global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_PLAYER_DIE, index=actor:GetSexID()})

    elseif actor:IsMonster() then
        global.netMonsterController:handle_Die(actor, msgHdr) 
        global.Facade:sendNotification(global.NoticeTable.ActorMonsterDie, {actorID = actorID, actor = actor})
        local clothID = actor:GetAnimationID()
        global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_MON_DIE, index = clothID})
        SLBridge:onLUAEvent(LUA_EVENT_MONSTER_DIE, {id = actorID})
    end

    global.Facade:sendNotification(global.NoticeTable.ActorDie, {actorID = actorID, actor = actor})
end

function gameMapController:handle_DeathSkeleton(msgHdr, msgData)
    if msgData == "" then
        return nil
    end
    local actorID = msgData
    local actor = global.actorManager:GetActor(actorID)
    if nil == actor then
        return nil
    end
    
    -- monster only.
    if actor:IsMonster() then
        global.netMonsterController:handle_DeathSkeleton(actor, msgHdr) 
        global.Facade:sendNotification(global.NoticeTable.ActorMonsterDeath, {actorID = actorID, actor = actor})
    end
end

function gameMapController:handle_Revive(msgHdr, msgData)
    if msgData == "" then
        return nil
    end

    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end

    local actor = global.actorManager:GetActor( jsonData.UserID )
    if nil == actor then
        return nil
    end

    if actor:IsPlayer() then
        if actor:IsMainPlayer() then
            global.gamePlayerController:handle_Revive(actor, jsonData)
        else
            global.netPlayerController:handle_Revive(actor, jsonData)
            SLBridge:onLUAEvent(LUA_EVENT_NET_PLAYER_REVIVE, {id = actor:GetID()})
        end
    elseif actor:IsMonster() then
        global.netMonsterController:handle_Revive(actor, jsonData)
        SLBridge:onLUAEvent(LUA_EVENT_MONSTER_REVIVE, {id = actor:GetID()})
    end
end

function gameMapController:handle_OutOfView(msgHdr, msgData)
    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end

    local actorID = jsonData.UserID
    local actor = global.actorManager:GetActor( actorID )
    if nil == actor then
        return nil
    end
    
    if nil == self.mNetActorMap[actorID] then
        return nil
    end
    self.mNetActorMap[actorID] = nil

    -- Remove from monster manager
    if actor:IsMonster() then  
        global.monsterManager:RmvMonster( actorID )
        global.netMonsterController:handleActorOutOfView( actor )
    elseif actor:IsPlayer() then
        if actor:IsMainPlayer() then
            -- effect
            local mainPlayer = global.gamePlayerController:GetMainPlayer()
            if mainPlayer and msgHdr.recog ~= 1 then
                global.Facade:sendNotification(global.NoticeTable.ActorFlyOut, mainPlayer, 0)
            end
            return 1
        end

        -- 恢复攻击状态和护身
        actor:SetDamage()
        actor:SetHuShen()

        global.playerManager:RmvPlayer( actorID )
        global.netPlayerController:handleActorOutOfView( actor )
    elseif actor:IsNPC() then
        global.npcManager:RmvNpc( actorID )
    end

    local noticeData = {
        actor   = actor,
        actorID = actorID,
        msgID   = msgHdr.msgId,
        recog   = msgHdr.recog
    }
    global.Facade:sendNotification(global.NoticeTable.ActorOutOfView, noticeData)

    SLBridge:onLUAEvent(LUA_EVENT_ACTOR_OUT_OF_VIEW, {id = actorID})

    return global.actorManager:RemoveActor( actorID )
end

function gameMapController:handle_FlyIn(msgHdr, msgData)
    local mapX = msgHdr.param1
    local mapY = msgHdr.param2
    local dir  = msgHdr.param3
    local effectType = msgHdr.recog
    local noShow = effectType == 1

    -- dump(msgHdr, "___handle_FlyIn")
    -- dump(msgData)

    -- audio
    global.Facade:sendNotification( global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_FLY_IN} )

    -- effect
    if not noShow then
        local effectId = effectType > 1 and effectType
        global.Facade:sendNotification( global.NoticeTable.ActorFlyIn, {x = mapX, y = mapY}, effectId or 0)
    end

    -- 如果有actor，强行刷坐标
    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end

    local actor = global.actorManager:GetActor(jsonData.UserID)
    if not actor then
        return nil
    end

    -- 主玩家不需要强拉坐标，切地图时已经带了坐标
    if actor:IsPlayer() and actor:IsMainPlayer() then
        return nil
    end

    if actor:IsMonster() then
        global.netMonsterController:handle_FlyIn(actor, msgHdr )
        
    elseif actor:IsPlayer() then
        global.netPlayerController:handle_FlyIn(actor, msgHdr )
    end

    global.Facade:sendNotification(global.NoticeTable.ActorMoveForce, {actorID = jsonData.UserID, actor = actor})
end

function gameMapController:handle_FlyIn2(msgHdr, msgData)
    local mapX = msgHdr.param1
    local mapY = msgHdr.param2
    local dir  = msgHdr.param3
    local effectType = msgHdr.recog
    local noShow = effectType == 1

    -- audio
    global.Facade:sendNotification( global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_FLY_IN} )

    -- effect
    if not noShow then
        local effectId = effectType > 1 and effectType
        global.Facade:sendNotification( global.NoticeTable.ActorFlyIn, {x = mapX, y = mapY}, effectId or 1)
    end

    -- 如果有actor，强行刷坐标
    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end

    local actor = global.actorManager:GetActor(jsonData.UserID)
    if not actor then
        return nil
    end

    -- 主玩家不需要强拉坐标，切地图时已经带了坐标
    if actor:IsPlayer() and actor:IsMainPlayer() then
        return nil
    end

    if actor:IsMonster() then
        global.netMonsterController:handle_FlyIn2(actor, msgHdr )
        
    elseif actor:IsPlayer() then
        global.netPlayerController:handle_FlyIn2(actor, msgHdr )
    end

    global.Facade:sendNotification(global.NoticeTable.ActorMoveForce, {actorID = jsonData.UserID, actor = actor})
end

function gameMapController:handle_FlyOut(msgHdr, msgData)
    local effectType = msgHdr.recog
    local noShow = effectType == 1

    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end

    local actor = global.actorManager:GetActor(jsonData.UserID)
    if not actor then
        return nil
    end

    -- audio
    global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_FLY_OUT})
    
    -- effect
    if not noShow then
        local effectId = effectType > 1 and effectType
        global.Facade:sendNotification(global.NoticeTable.ActorFlyOut, actor, effectId or 0)
    end
end

function gameMapController:handle_FlyOut2(msgHdr, msgData)
    local effectType = msgHdr.recog
    local noShow = effectType == 1

    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end

    local actor = global.actorManager:GetActor(jsonData.UserID)
    if not actor then
        return nil
    end

    -- audio
    global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_FLY_OUT})
    
    -- effect
    if not noShow then
        local effectId = effectType > 1 and effectType
        global.Facade:sendNotification(global.NoticeTable.ActorFlyOut, actor, effectId or 1)
    end
end

function gameMapController:handle_FeatureChanged(header, msgData)
    if msgData == "" then
        return nil
    end
    local actor = global.actorManager:GetActor( msgData )
    if nil == actor then
        print( "illegal actorID in handle_MSG_SC_ACTOR_FEATURE_CHANGED", msgData )
        return nil
    end

    local ftype = header.recog
    local value = header.param1
    local value1 = header.param2

    if ftype == global.MMO.ACTOR_FTCHANGE_CLOTH then
        if actor:IsMonster() then
            actor:SetClothID(value)
            global.Facade:sendNotification(global.NoticeTable.DelayDirtyFeature, {actorID = actor:GetID(), actor = actor})
            return
        end
        -- 衣服
        local actorAttr = GetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE) or {}
        actorAttr.clothID = value
        SetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE, actorAttr)
        global.Facade:sendNotification( global.NoticeTable.DelayActorFeatureChange, actorAttr )

    elseif ftype == global.MMO.ACTOR_FTCHANGE_CLOTH_EFF then
        -- 衣服特效/翅膀 ???
        local actorAttr = GetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE) or {}
        actorAttr.clothEff = value
        SetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE, actorAttr)
        global.Facade:sendNotification( global.NoticeTable.DelayActorFeatureChange, actorAttr )

    elseif ftype == global.MMO.ACTOR_FTCHANGE_WEAPON then
        -- 武器
        local actorAttr = GetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE) or {}
        actorAttr.weaponID = value
        if value1 then --左手武器
            actorAttr.leftWeaponID = value1
        end
        SetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE, actorAttr)
        global.Facade:sendNotification( global.NoticeTable.DelayActorFeatureChange, actorAttr )

    elseif ftype == global.MMO.ACTOR_FTCHANGE_WEAPON_EFF then
        -- 武器特效
        local actorAttr = GetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE) or {}
        actorAttr.weaponEff = value
        if value1 then --左手武器
            actorAttr.leftWeaponEff = value1
        end
        SetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE, actorAttr)
        global.Facade:sendNotification( global.NoticeTable.DelayActorFeatureChange, actorAttr )

    elseif ftype == global.MMO.ACTOR_FTCHANGE_HAIR then
        -- 发型
        local actorAttr = GetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE) or {}
        actorAttr.Hair = value
        SetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE, actorAttr)
        global.Facade:sendNotification( global.NoticeTable.DelayActorFeatureChange, actorAttr )

    elseif ftype == global.MMO.ACTOR_FTCHANGE_CAP then
        -- 斗笠
        local actorAttr = GetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE) or {}
        actorAttr.Cap = value
        SetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE, actorAttr)
        global.Facade:sendNotification( global.NoticeTable.DelayActorFeatureChange, actorAttr )

    elseif ftype == global.MMO.ACTOR_FTCHANGE_TEAMSTATE then
        -- 组队状态
        local lastGroup = actor:GetTeamState()
        actor:SetTeamState(value)
        if actor:IsPlayer() and actor:IsMainPlayer() and actor:GetTeamState() == 0 then
            local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
            TeamProxy:ClearTeamMember()
            SLBridge:onLUAEvent(LUA_EVENT_TEAM_MEMBER_UPDATE)
            SLBridge:onLUAEvent(LUA_EVENT_LEAVETEAM, actor:GetName())
        end
        -- 
        if actor:IsPlayer() then
            if lastGroup ~= value then
                if global.gamePlayerController:GetMainPlayerID() == actor:GetID() then
                    SL:onLUAEvent(LUA_EVENT_PLAYER_TEAM_STATUS_CHANGE)
                else
                    SL:onLUAEvent(LUA_EVENT_NET_PLAYER_TEAM_STATUS_CHANGE, {id = actor:GetID()})
                end
            end
        end

    elseif ftype == global.MMO.ACTOR_FTCHANGE_SEX then
        -- sex
        actor:SetSexID(value)
        actor:dirtyHair()
        actor:dirtyCloth()
        local actorAttr = GetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE) or {}
        global.Facade:sendNotification( global.NoticeTable.DelayActorFeatureChange, actorAttr )
        
    elseif ftype == global.MMO.ACTOR_FTCHANGE_SHIELD then
        --盾牌  盾牌特效
        local actorAttr = GetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE) or {}
        actorAttr.shieldID = value
        actorAttr.shieldEffect = value1
        SetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_FEATURE, actorAttr)
        global.Facade:sendNotification( global.NoticeTable.DelayActorFeatureChange, actorAttr )
    end

    return 1
end

function gameMapController:handle_Walk(msgHdr, msgData)
    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end

    local actorID = jsonData.UserID
    local actor = global.actorManager:GetActor( actorID )

    if nil == actor then
        return nil
    end

    if actor:IsMonster() then
        local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
        if actor:GetMasterID() == mainPlayerID then --宝宝触发
            ssr.ssrBridge:OnPetActionBegin(actorID, 1, actor:GetMapX(), actor:GetMapY(), actor:GetName())
        end

        return global.netMonsterController:handle_MSG_SC_ACTOR_WALK(actor, msgHdr )
    elseif actor:IsPlayer() then
        return global.netPlayerController:handle_MSG_SC_ACTOR_WALK(actor, msgHdr )
    end
end

function gameMapController:handle_Run(msgHdr, msgData, isRunOne)
    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end

    local actorID = jsonData.UserID
    local actor = global.actorManager:GetActor( actorID )
    if nil == actor then
        return nil
    end

    actor:SetKeyValue(global.MMO.IS_RUN_ONE, isRunOne)
    if actor:IsMonster() then
        local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
        if actor:GetMasterID() == mainPlayerID then --宝宝触发
            ssr.ssrBridge:OnPetActionBegin(actorID, 2, actor:GetMapX(), actor:GetMapY(), actor:GetName())
        end

        return global.netMonsterController:handle_MSG_SC_ACTOR_RUN(actor, msgHdr )
    elseif actor:IsPlayer() then
        return global.netPlayerController:handle_MSG_SC_ACTOR_RUN(actor, msgHdr )
    end
end

function gameMapController:handle_RideRun(msgHdr, msgData)
    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end

    local actorID = jsonData.UserID
    local actor = global.actorManager:GetActor( actorID )
    if nil == actor then
        return nil
    end

    if actor:IsPlayer() then
        return global.netPlayerController:handle_MSG_SC_ACTOR_RIDE_RUN(actor, msgHdr )
    end
end

function gameMapController:handle_Turn(msgHdr, msgData)
    if msgData == "" then
        return nil
    end

    local actorID = msgData
    local actor = global.actorManager:GetActor( actorID )
    if nil == actor then
        return nil
    end

    local dir = msgHdr.recog
    local mapX = msgHdr.param1
    local mapY = msgHdr.param2
    
    if actor:GetMapX() ~= mapX or actor:GetMapY() ~= mapY then
        local pos = global.sceneManager:MapPos2WorldPos( mapX, mapY, true )
        if actor.GetRaceServer and actor:GetRaceServer() ~= global.MMO.ACTOR_SERVER_RACE_KNIEF then
            actor:setPosition( pos.x, pos.y )
            actor:SetDirection( dir )
        else
            SetActorAttrByID(actorID, global.MMO.ACTOR_ATTR_DIR, dir)
        end
    else
        actor:SetDirection(dir)
    end

    global.actorManager:SetActorMapXY( actor, mapX, mapY )
    
    actor:dirtyAnimFlag()
end

function gameMapController:handle_PickCorpse( msgHdr, msgData )
    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end

    local actorID = jsonData.UserID
    local actor = global.actorManager:GetActor( actorID )
    if nil == actor then
        return nil
    end

    local ret = -3
    if actor:IsPlayer() then
        if not actor:IsMainPlayer() then
            if msgHdr.param1 == 1 then
                --挖矿
                ret = global.netPlayerController:handleActorMining( actor, jsonData )

            else
                --挖尸体
                ret = global.netPlayerController:handleActorSitdown( actor, jsonData )
            end 
        end

        if msgHdr.param2 >= 1 then
            if actor:IsMainPlayer() then
                --挖矿 起灰特效
                local present =
                {
                    skillID = 999,
                    launchX = actor:GetMapX(),
                    launchY = actor:GetMapY(),
                    hitX    = actor:GetMapX(),
                    hitY    = actor:GetMapY(),
                    dir     = actor:GetDirection(),
                    skillStage = 3,
                    launcherID = actor:GetID()
                }
                global.Facade:sendNotification(global.NoticeTable.RequestSkillPresent, present)

                -- 挖矿 起灰音效
                global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type=global.MMO.SND_TYPE_MINING_DROP})
            end
            
            --挖矿 广播土堆
            local item  = 
            {
                id      = msgHdr.param3,
                type    = global.MMO.EFFECT_TYPE_MINING_HIT,
                x       = actor:GetMapX(),
                y       = actor:GetMapY(),
                param   = msgHdr.param2,
            }
            self:addSpecialEffect( item )
        end
    end
end

function gameMapController:handle_RefreshHP( msgHdr, msgData )
    if msgData == "" then
        return false
    end

    local newArray = string.split( msgData,"|" )
    local dataStrArray = string.split(newArray[1] or "","&")
    local actorID = dataStrArray[1]
    local HP      = tonumber(dataStrArray[2]) or 0
    local maxHP   = tonumber(dataStrArray[3]) or 0
    local MP      = tonumber(dataStrArray[4]) or 0
    local maxMP   = tonumber(dataStrArray[5]) or 0

    local actor = global.actorManager:GetActor( actorID )
    if not actor then
        --自己的英雄不在视野内也要刷新血量
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        local HeroID = HeroPropertyProxy:GetRoleUID()
        if HeroID and HeroID == actorID then 
            HeroPropertyProxy:SetRoleMana(HP, maxHP, MP, maxMP)
        end
        return false
    end

    local power = newArray[2]

    -- 1 受击
    local unAattack = L16Bit(msgHdr.recog) == 1

    -- 飘字类型
    local throwType = msgHdr.param2

    -- 飘字的值
    local throwPower = tonumber(power) or msgHdr.param3

    local nData = {
        actorID   = actorID,
        HP        = HP,
        maxHP     = maxHP,
        MP        = MP,
        maxMP     = maxMP,
        isDamage  = false,
        unAattack = unAattack,
        level     = msgHdr.param1,  -- 等级
    }

    if unAattack then
        nData.huShen = H16Bit(msgHdr.recog)
    end

    local oldHP = actor:GetHP() or 0
    local oldMP = actor:GetMP() or 0

    global.Facade:sendNotification(global.NoticeTable.RefreshActorHP, nData)

    JudgeIsRefreshTargetHP(nData)

    -- 飘字
    if throwType > 0 then
        if throwType == 110 then
            local changeHp = HP - oldHP
            local hpTypeID = changeHp > 0 and 4 or (changeHp < 0 and 1 or 0)
            if hpTypeID > 0 then
                global.Facade:sendNotification(global.NoticeTable.ShowThrowDamage, {Id = hpTypeID, UserID = actorID, Power = math.abs(changeHp)})
            end

            local changeMp = MP - oldMP
            local mpTypeID = changeMp > 0 and 12 or (changeMp < 0 and 11 or 0)
            if mpTypeID > 0 then
                global.Facade:sendNotification(global.NoticeTable.ShowThrowDamage, {Id = mpTypeID, UserID = actorID, Power = math.abs(changeMp)})
            end
        else
            global.Facade:sendNotification(global.NoticeTable.ShowThrowDamage, {Id = throwType, UserID = actorID, Power = throwPower})
        end
    end
end

function gameMapController:handle_Damage(msgHdr, msgData)
    if msgData == "" then
        return false
    end

    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return false
    end

    local actorID = jsonData.UserID
    local actor   = global.actorManager:GetActor(actorID)
    if not actor then
        return false
    end

    local HP      = jsonData.Hp or 0
    local maxHP   = jsonData.MaxHp or 0
    local MP      = jsonData.Mp or 0
    local maxMP   = jsonData.MaxMp or 0

    local nData = {
        actorID   = actorID,
        HP        = HP,
        maxHP     = maxHP,
        MP        = MP,
        maxMP     = maxMP,
        isDamage  = true,
        unAattack = true,
        huShen    = H16Bit(msgHdr.recog)
    }

    -- 飘字类型
    local throwType = L16Bit(msgHdr.recog)
    
    -- 飘字的值
    local throwPower = tonumber(jsonData.Damage) or msgHdr.param1
    
    -- 后仰
    local struck = 1 -- 默认后仰
    local struchRules = jsonData.Struck or 0
    local isMain = (actor:IsPlayer() and actor:IsMainPlayer()) or false

    -- 以前是后端判断,  改成前端自行判断
    if (isMain and CheckBit(struchRules, 0)) or ((actor:IsPlayer() or actor:IsHero()) and CheckBit(struchRules, 1)) or (actor:IsMonster() and CheckBit(struchRules, 2)) then
        struck = 0
    end

    if struck == 1 then -- 后仰状态
        self:handle_Stuck(msgHdr, msgData)
    end

    -- 音效 ？？？？
    global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_SCREAM, index = jsonData.Weapon, param = actorID})
    if jsonData.Magic ~= 1 then
        global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_STUCK, index = jsonData.Weapon, param = actorID})
    end

    global.Facade:sendNotification(global.NoticeTable.RefreshActorHP, nData)

    JudgeIsRefreshTargetHP(nData)

    -- 飘字
    if throwType > 0 then
        global.Facade:sendNotification(global.NoticeTable.ShowThrowDamage, {Id = throwType, UserID = actorID, Power = throwPower, TargetID = jsonData.AttackUserID})
    end

    -- 刷新内力值
    local data = {
        curInternalForce = jsonData.InternalForce,
        maxInternalForce = jsonData.MaxInternalForce
    }
    if next(data) then
        data.actorID  = actorID
        global.Facade:sendNotification(global.NoticeTable.RefreshActorIForce, data)
    end

    global.Facade:sendNotification(global.NoticeTable.AutoFightBack, {attackActorID = jsonData.AttackUserID, actorID = actorID})
end

-- 护身状态掉蓝由服务端直接通知反击
function gameMapController:handle_MSG_SC_FIGHT_BACK_ID(msg)
    local header = msg:GetHeader()
    local msgLen = msg:GetDataLength()
    if msgLen <= 0 then
        return
    end
    
    local attackActorID = msg:GetData():ReadString(msgLen)
    local actor = global.actorManager:GetActor(attackActorID)
    if not actor then
        return
    end

    if not actor:IsPlayer() then
        return
    end

    global.Facade:sendNotification(global.NoticeTable.AutoFightBack, {attackActorID = attackActorID})
end

function gameMapController:handle_Stuck( msgHdr, msgData )
    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end

    local actorID = jsonData.UserID
    local actor = global.actorManager:GetActor( actorID )
    if nil == actor or actor:IsDie() then
        return nil
    end

    if actor:IsMonster() then
        return global.netMonsterController:handle_MSG_SC_ACTOR_STUCK( actor )

    elseif actor:IsPlayer() then
        if actor:IsMainPlayer() then
            return global.gamePlayerController:handle_MSG_SC_ACTOR_STUCK( actor )
        else
            return global.netPlayerController:handle_MSG_SC_ACTOR_STUCK( actor )
        end
    end
end

function gameMapController:handle_RefreshSpeed( msgHdr, msgData )
    if msgData == "" then
        return nil
    end
    -- recog  走
    -- param1 跑
    -- param2 攻击
    -- param3 施法
    -- Str    UserID
    local header    = msgHdr
    local actorID   = msgData
    local actor     = global.actorManager:GetActor(actorID)
    if not actor then
        return nil
    end

    print("速度改变 ", actorID, header.recog, header.param1, header.param2, header.param3)

    -- 走速度
    if header.recog > 0 then
        if actor:IsPlayer() and actor:IsMainPlayer() then
            actor:SetWalkSpeed(actor:GetWalkStepTime() / (header.recog * 0.001 + global.MMO.NETWORK_DELAY))
        else
            actor:SetWalkSpeed(actor:GetWalkStepTime() / (header.recog * 0.001))
        end
    end

    -- 跑速度
    if header.param1 > 0 then
        if actor:IsPlayer() and actor:IsMainPlayer() then
            actor:SetRunSpeed(actor:GetRunStepTime() / (header.param1 * 0.001 + global.MMO.NETWORK_DELAY))
        else
            actor:SetRunSpeed(actor:GetRunStepTime() / (header.param1 * 0.001))
        end
    end

    -- 攻击速度
    -- 飞扬ios数据流量放火墙往相反方向跑出现空气墙，增加网络延迟误差
    local delay = SL:GetMetaValue("GAME_DATA", "attack_network_delay") == 1 and global.MMO.NETWORK_DELAY or 0
    if header.param2 > 0 then
        actor:SetAttackSpeed(actor:GetAttackStepTime() / (header.param2 * 0.001 + delay))
    end

    -- 魔法速度
    if header.param3 > 0 then
        actor:SetMagicSpeed(actor:GetMagicStepTime() / (header.param3 * 0.001 + delay))
    end

    -- 同步主玩家锁帧时间
    if actor:IsPlayer() and actor:IsMainPlayer() then
        global.actorManager:UpdateLockFrameT()
    end
end

function gameMapController:handle_RefreshMonsterSpeed( msgHdr, msgData )
    if msgData == "" then
        return nil
    end

    local header    = msgHdr
    local actorID   = msgData
    local actor     = global.actorManager:GetActor(actorID)
    if not actor then
        return nil
    end

    print("怪物速度改变 ", actorID, header.recog, header.param1)
    -- 走速度
    if header.recog > 0 then
        actor:SetWalkSpeed(actor:GetWalkStepTime() / (header.recog * 0.001 + global.MMO.NETWORK_DELAY))
    end

    -- 攻击速度
    if header.param1 > 0 then
        actor:SetAttackSpeed(actor:GetAttackStepTime() / (header.recog * 0.001))
    end
end

function gameMapController:handle_RefreshName(msgHdr, msgData)
    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end
    
    local actorID = jsonData.UserID
    local actor = global.actorManager:GetActor( actorID )
    if not actor then
        return nil
    end

    local guildID = actor:IsPlayer() and actor:GetGuildID() or nil

    SetActorProperty(actor, jsonData)
    SetActorName(actor, jsonData)

    global.Facade:sendNotification( global.NoticeTable.DelayRefreshHUDLabel, { actor = actor, actorID = actorID, hudParam = jsonData } )
    global.Facade:sendNotification( global.NoticeTable.DelayRefreshHUDTitle, { actor = actor, actorID = actorID, hudParam = jsonData } )

    local newGuildID = actor:IsPlayer() and actor:GetGuildID() or nil
    if guildID ~= newGuildID then
        local guilds = {}
        if guildID and guildID ~= "" then
            guilds[guildID] = true
        end

        if newGuildID and newGuildID ~= "" then
            guilds[newGuildID] = true
        end
        
        if next(guilds) then
            global.Facade:sendNotification( global.NoticeTable.RefreshGuildActorColor, {guilds=guilds} )
        end
    end
end

function gameMapController:handle_Sell(header, msgData)
    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end

    local actorID = jsonData.userid
    local actor = global.actorManager:GetActor( actorID )
    if not actor then
        return -1
    end
    local sellStatus = jsonData.open
    
    actor:SetAction(global.MMO.ACTION_IDLE)

    if sellStatus == 1 then
        local pos = global.sceneManager:MapPos2WorldPos( jsonData.x, jsonData.y, true )
        actor:setPosition( pos.x, pos.y )
        actor:SetDirection( jsonData.dir )
        actor:dirtyAnimFlag()

        global.actorManager:SetActorMapXY( actor, jsonData.x, jsonData.y, true )
    end

    --摆摊状态 (0, 1)
    actor:SetSellStatus(sellStatus)
    --摊位名字
    actor:SetStallName(jsonData.stallname)

    if actorID == global.gamePlayerController:GetMainPlayerID() then
        local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
        StallProxy:SetMyTradingStatus(sellStatus == 1)
        if sellStatus == 0 then --取消摆摊
            StallProxy:CleanMySellData()  --返回摆摊物品
        end
    end

    global.Facade:sendNotification(global.NoticeTable.Layer_StallLayer_StatusChange, {status = sellStatus, userid = actorID})
    global.Facade:sendNotification(global.NoticeTable.PlayerStallStatucChange, {actorID = actorID, actor = actor})
    global.Facade:sendNotification(global.NoticeTable.RefreshActorBooth, {actorID = actorID, actor = actor})
    if actorID == global.gamePlayerController:GetMainPlayerID() then
        SLBridge:onLUAEvent(LUA_EVENT_PLAYER_STALL_STATUS_CHANGE)
    else
        SLBridge:onLUAEvent(LUA_EVENT_NET_PLAYER_STALL_STATUS_CHANGE, {id = actorID})
    end
end

function gameMapController:handle_MSG_SC_NET_MONSTER_BORN(msg)
    local msgLen = msg:GetDataLength()
    if msgLen <= 0 then
        return
    end
    local msgHdr = msg:GetHeader()
    local msgData = msg:GetData():ReadString(msgLen)
    local actorID = msgData
    local actor = global.actorManager:GetActor( actorID )
    if not actor then
        print("[出生 20] 没有发现ACTOR", actorID)
        return nil
    end
    if not actor:IsMonster() then
        return nil
    end

    global.netMonsterController:handle_MSG_SC_NET_MONSTER_BORN(actor, msgHdr, msgData)
end

function gameMapController:handle_MSG_SC_NET_MONSTER_CAVE(msg)
    local msgLen = msg:GetDataLength()
    if msgLen <= 0 then
        return
    end
    local msgHdr = msg:GetHeader()
    local msgData = msg:GetData():ReadString(msgLen)
    local actorID = msgData
    local actor = global.actorManager:GetActor( actorID )
    if not actor then
        print("[钻回 21] 没有发现ACTOR", actorID)
        return nil
    end
    if not actor:IsMonster() then
        return nil
    end

    global.netMonsterController:handle_MSG_SC_NET_MONSTER_CAVE(actor, msgHdr, msgData)
end

function gameMapController:handle_Icons(msgHdr, msgData)
    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end
    local actorID = jsonData.UserID
    local actor = global.actorManager:GetActor( actorID )
    if not actor then
        return nil
    end

    SetActorAttrByID( actorID, global.MMO.ACTOR_ATTR_HUDICONS, jsonData.icons or {} )
    global.Facade:sendNotification( global.NoticeTable.DelayRefreshHUDTitle, { actor = actor, actorID = actorID } )
end

function gameMapController:handle_Title(msgHdr, msgData)
    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end
    local actorID = jsonData.UserID
    local actor = global.actorManager:GetActor( actorID )
    if not actor then
        return nil
    end

    SetActorAttrByID( actorID, global.MMO.ACTOR_ATTR_HUDTITLE, jsonData.title or {} )
    global.Facade:sendNotification( global.NoticeTable.DelayRefreshHUDTitle, { actor = actor, actorID = actorID } )
end

-- 挖矿
function gameMapController:handle_AutoMining(msgHdr, msgData)
    local mainPlayer    = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return
    end
    local inputProxy    = global.Facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
    local x             = msgHdr.param1
    local y             = msgHdr.param2
    local dest          = cc.p(x, y)
    local src           = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    local dir           = inputProxy:calcMapDirection(dest, src)

    local autoProxy     = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    autoProxy:SetAutoMining(dir,dest)

    local mapProxy  = global.Facade:retrieveProxy(global.ProxyTable.Map)
    local mapID     = mapProxy:GetMapID()
    local movePos   = 
    {
        mapID   = mapID, 
        x       = dest.x, 
        y       = dest.y, 
        type    = global.MMO.INPUT_MOVE_TYPE_AUTOMOVE,
    }
    global.Facade:sendNotification(global.NoticeTable.InputMove, movePos)
end

-- actor 转生
function gameMapController:handle_ActorReLevel(msgHdr, msgData)
    
    if not msgData then
        return false
    end

    local actor = global.actorManager:GetActor(msgData)
    if not actor:IsPlayer() then
        return false
    end

    actor:SetReLevel(msgHdr.recog)
end

-----------------------------------------------------------------------------
--- 开门 关门
function gameMapController:handle_MSG_SC_OPEN_DOOR_NOTICE(msg)
    local header = msg:GetHeader()
    global.sceneManager:openDoor( header.param1, header.param2 )
end

function gameMapController:handle_MSG_SC_CLOSE_DOOR_NOTICE(msg)
    local header = msg:GetHeader()
    global.sceneManager:closeDoor( header.param1, header.param2 )
end
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- 场景特效
function gameMapController:handle_MSG_SC_MAP_ADD_SPECIAL_EFFECT( msg )
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return nil
    end
    local len = #jsonData
    local data = nil
    local item = nil
    for i = 1, len do
        data = jsonData[i]
        local item  = 
        {
            id          = data.Id,
            type        = data.Type,
            x           = data.X,
            y           = data.Y,
            param       = data.Param,
            sfxId       = data.EffId,
            TopType     = data.TopType,
            DuranceID   = data.DuranceID or global.gamePlayerController:GetMainPlayerID()
        }
        if item.TopType == 2 then
            SL:AddMapSpecialEffect(item.id, SL:GetMetaValue("MAP_ID"), item.sfxId, item.x, item.y, true, item.TopType)
        else
            self:addSpecialEffect( item )
        end
    end
end

function gameMapController:handle_MSG_SC_MAP_RMV_SPECIAL_EFFECT( msg )
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return nil
    end

    local len = #jsonData
    local data = nil
    local actorID = nil
    for i = 1, len do
        data = jsonData[i]
        actorID = data.Id

        local sfxActor = self.mNetActorMap[actorID]
        if (sfxActor) then
            -- notice
            global.Facade:sendNotification(global.NoticeTable.ActorEffectOutOfView, {actorID = actorID, actor = sfxActor})
        end

        self.mNetActorMap[actorID] = nil
        global.sceneEffectManager:RmvSceneEffect( actorID )
        global.actorManager:RemoveActor( actorID )
    
        local sceneImprisonEffectProxy = global.Facade:retrieveProxy(global.ProxyTable.SceneImprisonEffectProxy) 
        sceneImprisonEffectProxy:RmImprison( actorID )
    end
end

function gameMapController:addSpecialEffect( item )
    local isInit = true       
    local actorID = item.id
    local needLight = false

    -- find it
    local sfxActor = global.actorManager:GetActor( actorID ) 
    if nil ~= sfxActor then
        sfxActor:GetNode():setVisible( true )
        isInit = false
        -----lightID 
        if not sfxActor:GetLightID() then
            needLight = true
        end
    else
        -- New special effect actor
        local paramSfx      = {}
        paramSfx.type       = global.MMO.EFFECT_TYPE_NORMAL
        local limitCount    = 200
        local actorCount    = global.actorManager:GetActorNum()

        local isBehind      = false
        local isFront       = false
        local effectRace    = item.type
        if fireSet[effectRace] then
            paramSfx.sfxId  = fireSet[effectRace]
            paramSfx.isLoop = true
            isBehind        = (actorCount>limitCount)
            paramSfx.type   = global.MMO.EFFECT_TYPE_FIRE
            -----lightID 
            needLight = true

            local sfxId     = item.sfxId and tonumber(item.sfxId)
            if sfxId and sfxId > 0 then
                paramSfx.sfxId = sfxId
            end

        elseif effectRace == 1 then -- 僵尸2 出生洞
            paramSfx.sfxId  = global.MMO.SFX_MONSTER_BORN1
            paramSfx.isLoop = false
            isBehind = true

        elseif effectRace == global.MMO.EFFECT_TYPE_MINING_HIT then
            -- 土(静态特效)(ps: 以前是挖矿 sfxid:999)
            paramSfx.type   = global.MMO.EFFECT_TYPE_MINING_HIT
            paramSfx.sfxId  = 2208
            paramSfx.isLoop = true
            paramSfx.param  = item.param
            isBehind = true

        elseif effectRace == 27 or effectRace == 50 then
            -- 传送门
            paramSfx.sfxId  = global.MMO.SFX_PORTAL
            paramSfx.isLoop = true
            isBehind        = true
            paramSfx.type   = global.MMO.EFFECT_TYPE_PORTAL
            needLight = true

        elseif effectRace == global.MMO.EFFECT_TYPE_SFX then
            -- 通用特效
            paramSfx.type   = global.MMO.EFFECT_TYPE_SFX
            paramSfx.sfxId  = item.sfxId
            paramSfx.isLoop = true
            isBehind        = item.TopType == 0
            isFront         = item.TopType == 1

        elseif effectRace == global.MMO.EFFECT_TYPE_EMPTY then
            -- 禁锢  设置动态阻挡
            paramSfx.type       = global.MMO.EFFECT_TYPE_EMPTY
            paramSfx.sfxId      = item.sfxId
            paramSfx.isLoop     = true
            paramSfx.DuranceID  = item.DuranceID
            isBehind            = false

        else
            return -1
        end

        sfxActor = global.actorManager:CreateActor( actorID, global.MMO.ACTOR_SEFFECT, paramSfx, isBehind ,isFront)
        
        if nil == sfxActor then
            return -1
        end
    end

    -- To map grid position.
    local mapX = item.x
    local mapY = item.y
    local actorPos = global.sceneManager:MapPos2WorldPos( mapX, mapY, true )
    sfxActor:setPosition( actorPos.x, actorPos.y )
    global.actorManager:SetActorMapXY( sfxActor, mapX, mapY )

    -- feature
    global.Facade:sendNotification( global.NoticeTable.DelayDirtyFeature, {actorID = actorID, actor = sfxActor})

    if isInit then
        -- Track effect.
        self.mNetActorMap[actorID] = sfxActor
        global.sceneEffectManager:AddSceneEffect( sfxActor )
    end

    global.Facade:sendNotification(global.NoticeTable.ActorEffectInOfView, {actorID = actorID, actor = sfxActor, needLight = needLight})
end

-- 场景添加特效
function gameMapController:addEffectToMap( animID, mapX, mapY )
    if not animID or not mapX or not mapY then
        return
    end

    -- 播放特效
    local sfxAnim = global.FrameAnimManager:CreateSFXAnim(animID)
    if not sfxAnim then
        return
    end

    local root = global.sceneGraphCtl:GetSceneNode( global.MMO.NODE_SKILL_BEHIND )
    local sfxParent = root:getChildByName("MAP_SFX_PARENT")
    if not sfxParent then
        sfxParent = cc.Node:create()
        sfxParent:setName("MAP_SFX_PARENT")
        root:addChild( sfxParent, 999 )
    end

    sfxParent:addChild(sfxAnim, animID)
    local sfxPos = global.sceneManager:MapPos2WorldPos( mapX, mapY )
    sfxAnim:setPosition( sfxPos.x, sfxPos.y)
    sfxAnim:Play(0, 0)
    local function removeEvent()
        sfxAnim:removeFromParent()
    end
    sfxAnim:SetAnimEventCallback( removeEvent )
end
-----------------------------------------------------------------------------

-- 掉落物
function gameMapController:addDropItem( item )
    local id = item.Id
    local Idx = item.Idx
    local code = global.dropItemController:AddDropItemToWorld( item )

    if code == 2 then       -- refresh drop item ownerID
        global.Facade:sendNotification(global.NoticeTable.RefreshDropItem, id)
        return nil
    elseif code ~= 1 then
        return nil
    end


    -- Track Npc, NetPlayer, monster....
    local dropItem = global.actorManager:GetActor( id )
    self.mNetActorMap[ id ] = dropItem

    -- type index
    dropItem:SetTypeIndex( Idx )

    local noticeData = {
        actorID = id,
        color = item.Color or 255,
        jipin = item.jipin,
        count = item.cnt,
        itemName = item.Name,
    }
    global.Facade:sendNotification(global.NoticeTable.DropItemInOfView, noticeData)
    global.Facade:sendNotification(global.NoticeTable.DelayDirtyFeature, {actorID = id, actor = dropItem})

    SLBridge:onLUAEvent(LUA_EVENT_DROPITEM_IN_OF_VIEW, {actorID = id, item = item})
end

function gameMapController:rmvDropItem( id )
    -- Drop item 
    if nil == id then
        return nil
    end
    local it = self.mNetActorMap[id]
    if nil == it then
        return nil
    end
    self.mNetActorMap[id] = nil

    global.Facade:sendNotification(global.NoticeTable.DropItemOutOfView, {actorID = id})

    global.dropItemController:RmvDroItemFromWorld( id )

    SLBridge:onLUAEvent(LUA_EVENT_DROPITEM_OUT_OF_VIEW, {actorID = id})
end

function gameMapController:handle_MSG_SC_MAP_ITEM_DROP_BATCH( msg )
    local jsonData = ParseRawMsgToJson( msg )
    if not jsonData or next(jsonData) == nil then
        return nil
    end
    local len = #jsonData
    local item = nil
    for i = 1, len do
        item = jsonData[i]
        self:addDropItem(item)
    end
end

function gameMapController:handle_MSG_SC_MAP_ITEM_REMOVE_BATCH( msg )
    local jsonData = ParseRawMsgToJson( msg )
    if not jsonData or next(jsonData) == nil then
        return nil
    end
    local len = #jsonData
    local item = nil
    local itemID = nil
    for i = 1, len do
        item = jsonData[i]
        itemID = tonumber(item.Id)
        self:rmvDropItem( itemID )
    end
end
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--移动特效、足迹
function gameMapController:handle_MSG_SC_ACTOR_MOVE_EFF(msg)
    local msgLen    = msg:GetDataLength()
    if msgLen <= 0 then
        return
    end

    local msgHdr    = msg:GetHeader()
    local userid    = msg:GetData():ReadString(msgLen)
    local effID     = msgHdr.recog
    local skipWalk  = msgHdr.param1

    local actor = global.actorManager:GetActor(userid)
    if not actor then
        return
    end

    if actor:IsPlayer() then
        actor:SetMoveEff(effID)
        actor:SetEffSkipWalkSwitch(skipWalk) 
    end
end

-----------------------------------------------------------------------------
-- 强制移动
function gameMapController:handle_MSG_SC_NET_PLAYER_MOVE_FORCE(msg)
    local msgLen = msg:GetDataLength()
    if msgLen <= 0 then
        return
    end
    local msgData = msg:GetData():ReadString(msgLen)
    if msgData == "" then
        return nil
    end
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end
    local actor = global.actorManager:GetActor(jsonData.UserID)
    if not actor then
        return nil
    end

    local msgHdr = msg:GetHeader()
    local mapX = msgHdr.param1
    local mapY = msgHdr.param2
    local dir  = msgHdr.param3

    local data = {
        mapX = msgHdr.param1,
        mapY = msgHdr.param2,
        dir  = msgHdr.param3
    }
    if actor:IsPlayer() then
        if actor:IsMainPlayer() then
            global.gamePlayerController:handle_Move_Force(actor,data)
        else
            global.netPlayerController:handle_Move_Force(actor, data)
        end
    else
        global.netMonsterController:handle_Move_Force(actor, data)
    end

    global.Facade:sendNotification(global.NoticeTable.ActorMoveForce, {actorID = jsonData.UserID, actor = actor})
end
----------------------------------------------------------------------------

function gameMapController:handle_MSG_SC_OPENHEALTH( msg )
    local msgLen  = msg:GetDataLength()
    local msgData = (msgLen > 0 and msg:GetData():ReadString(msgLen) or "")
    local actorID = msgData
    dump(msgData,"handle_MSG_SC_OPENHEALTH")
    if not actorID then 
        return 
    end
    local actor = global.actorManager:GetActor( actorID )
    if nil == actor or 0 == actor then
        return 
    end
    actor:setVisibleServerHpLabel(true)

    optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_HMPLabel_VISIBLE)
    optionsUtils:refreshHUDHMpLabelVisible(actor)
end

function gameMapController:handle_MSG_SC_CLOSEHEALTH( msg )
    local msgLen  = msg:GetDataLength()
    local msgData = (msgLen > 0 and msg:GetData():ReadString(msgLen) or "")
    local actorID = msgData
    dump(msgData,"handle_MSG_SC_CLOSEHEALTH")
    if not actorID then 
        return 
    end
    local actor = global.actorManager:GetActor( actorID )
    if nil == actor or 0 == actor then
        return 
    end
    actor:setVisibleServerHpLabel(false)
    
    optionsUtils:InitHUDVisibleValue(actor, global.MMO.HUD_HMPLabel_VISIBLE)
    optionsUtils:refreshHUDHMpLabelVisible(actor)
end

-----------------------------------------------------------------------------
-- 技能
function gameMapController:handle_MSG_SC_PLAYER_SKILL_LAUNCH_SUCCESS(msg)
    local msgHdr = msg:GetHeader()
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end

    local actorID = jsonData.UserID
    -- can't find actor
    local actor = global.actorManager:GetActor( actorID )
    if nil == actor then
        return
    end

    -- ignore main player
    if actor:IsPlayer() and actor:IsMainPlayer() then
        return
    end

    if actor:IsMonster() then
        global.netMonsterController:handle_MSG_SC_PLAYER_SKILL_LAUNCH_SUCCESS(actor, msgHdr, jsonData)
    elseif actor:IsPlayer() then
        global.netPlayerController:handle_MSG_SC_PLAYER_SKILL_LAUNCH_SUCCESS(actor, msgHdr, jsonData)
    end
end

function gameMapController:handle_MSG_SC_NET_PLAYER_ATTACK(msg)
    local msgHdr = msg:GetHeader()
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end

    local actorID = jsonData.UserID
    -- can't find actor
    local actor = global.actorManager:GetActor( actorID )
    if nil == actor then
        return
    end

    -- ignore main player
    if actor:IsPlayer() and actor:IsMainPlayer() then
        return
    end

    if actor:IsMonster() then
        global.netMonsterController:handle_MSG_SC_NET_PLAYER_ATTACK(actor, msgHdr, jsonData)
    elseif actor:IsPlayer() then
        global.netPlayerController:handle_MSG_SC_NET_PLAYER_ATTACK(actor, msgHdr, jsonData)
    end
end

function gameMapController:handle_MSG_SC_PLAYER_SKILL_MAGIC_SUCCESS(msg)
    local msgHdr = msg:GetHeader()
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end

    local actorID = jsonData.UserID

    -- can't find actor
    local actor = global.actorManager:GetActor( actorID )
    if nil == actor then
        return
    end

    jsonData.showSkillMaigc = msgHdr.recog == 1
    if actor:IsMonster() then
        global.netMonsterController:handle_MSG_SC_PLAYER_SKILL_MAGIC_SUCCESS(actor, msgHdr, jsonData)
    elseif actor:IsPlayer() then
        if actor:IsMainPlayer() then
            global.gamePlayerController:handle_MSG_SC_PLAYER_SKILL_MAGIC_SUCCESS(actor, msgHdr, jsonData)
        else
            global.netPlayerController:handle_MSG_SC_PLAYER_SKILL_MAGIC_SUCCESS(actor, msgHdr, jsonData)
        end
    end
end

function gameMapController:handle_MSG_SC_MAINPLAYER_MAGIC(msg)
    local header        = msg:GetHeader()
    local x             = header.param1
    local y             = header.param2
    local sfxID         = header.param3

    local offset = global.MMO.PLAYER_AVATAR_OFFSET
    local dest   = global.sceneManager:MapPos2WorldPos(x, y, true)
    local root   = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_SKILL)
    local sfx    = global.FrameAnimManager:CreateSkillEffAnim(sfxID, 0)
    root:addChild(sfx)
    sfx:setLocalZOrder(sfxID)
    sfx:Play(0, 0, true)
    sfx:setPosition(cc.pAdd(dest, offset))
    sfx:SetAnimEventCallback(
        function(_, eventType)
            sfx:removeFromParent()
            sfx = nil
        end
    )
end
-----------------------------------------------------------------------------

----------------------------------刷新骑马  BEGIN----------------------------------
function gameMapController:refreshHorse( actor,jsonData )
    if not actor or not actor:IsPlayer() then
        return
    end

    local isMainHorse = jsonData.mountID and jsonData.mountID > 0
    local actorid = {
        [1] = isMainHorse and jsonData.UserID or jsonData.doubleUserId,
        [2] = not isMainHorse and jsonData.UserID or jsonData.doubleUserId 
    }

    for i,v in ipairs(actorid) do
        local actor = v and global.actorManager:GetActor(v) or nil
        if actor then
            actor:SetKeyValue(global.MMO.HORSE_MAIN, actorid[1])
            actor:SetKeyValue(global.MMO.HORSE_COPILOT, actorid[2])
            actor:SetDoubleHorse( jsonData.doubleTag )

            local data = {
                mountID     = jsonData.mountID,
                mountEff    = jsonData.mountEff,
                mountCloth  = jsonData.mountCloth,
                hairID      = actor:GetAnimationHairID()
            }

            local buffData = 
            {
                actorID = actor:GetID(),
                buffID  = global.MMO.BUFF_ID_HORSE,
                param   = {
                    feature = data,
                }
            }

            global.Facade:sendNotification(global.NoticeTable.AddBuffEntity, buffData)
        end
    end
end
----------------------------------刷新骑马  END----------------------------------

--------------------------------------------------------------------------------
--- gm数据更新 
function gameMapController:MSG_SC_ACTOR_GMDATA_UPDATE(msg)
    local msgLen = msg:GetDataLength()
    if msgLen <= 0 then
        return
    end
    local msgData = msg:GetData():ReadString(msgLen)
    local slices  = string.split(msgData, "|")
    local actorID = slices[1]
    local actor = global.actorManager:GetActor(actorID)
    if not actor or not (actor:IsPlayer() or actor:IsMonster()) then
        return
    end

    local items = {}
    for i = 2, 6 do
        items[i-1] = tonumber(slices[i])
    end
    actor:SetGMData(items)

    -- SL 广播
    SLBridge:onLUAEvent(LUA_EVENT_ACTOR_GMDATA_UPDATE, {id = actorID, data = actor:GetGMData()})
end

-- 玩家内力值更新
function gameMapController:handle_MSG_SC_ACTOR_INTERNAL_FORCE_UPDATE(msg)
    local header = msg:GetHeader()
    local msgLen = msg:GetDataLength()
    if msgLen <= 0 then
        return
    end
    local actorID = msg:GetData():ReadString(msgLen)
    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return
    end

    if not (actor:IsPlayer() or actor:IsHero()) then
        return
    end

    local maxForce = header.recog
    local curForce = header.param1
    actor:SetNGHUD(curForce, maxForce)
end
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
function gameMapController:RegisterMsgHandler()
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_CREATE_MAIN_PLAYER,         handler( self, self.handle_MSG_SC_CREATE_MAIN_PLAYER) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_PLAYER_IN_OF_VIEW,      handler( self, self.handleMessage) )

    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_PLAYER_FLY_IN,          handler( self, self.handleMessage) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_PLAYER_FLY_IN_2,        handler( self, self.handleMessage) )

    LuaRegisterMsgHandler( global.MsgType.MSG_SC_ACTOR_BUFF_INIT,            handler( self, self.handleMessage) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_ACTOR_BUFF_ADD,             handler( self, self.handleMessage) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_ACTOR_BUFF_RMV,             handler( self, self.handleMessage) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_ACTOR_EFFECT_UPDATE,        handler( self, self.handleMessage) )

    LuaRegisterMsgHandler( global.MsgType.MSG_SC_PLAYER_FEATURE_CHANGED,     handler( self, self.handleMessage) )

    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_PLAYER_WALK,            handler( self, self.handleMessage) ) 
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_PLAYER_RUN,             handler( self, self.handleMessage) ) 
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_PLAYER_RIDE_RUN,        handler( self, self.handleMessage) ) 
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_ACTOR_TURN,             handler( self, self.handleMessage) ) 
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_WALKEX,                     handler( self, self.handleMessage) )
    
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_PLAYER_HP_MP,               handler( self, self.handleMessage) ) 
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_DAMAGE_HP,                  handler( self, self.handleMessage) ) 
    
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_ACTOR_REFRESH_ACTOR_SPEED,  handler( self, self.handleMessage) ) 
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_REFRESH_MONSTER_SPEED,      handler( self, self.handleMessage) ) 

    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_MONSTER_BORN,           handler( self, self.handle_MSG_SC_NET_MONSTER_BORN) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_MONSTER_CAVE,           handler( self, self.handle_MSG_SC_NET_MONSTER_CAVE) )

    LuaRegisterMsgHandler( global.MsgType.MSG_SC_ACTOR_NAME,                 handler( self, self.handleMessage) )            -- 角色头顶数据(名子、称号等)

    LuaRegisterMsgHandler( global.MsgType.MSG_SC_SELL_NOTICE,                handler( self, self.handleMessage) )

    LuaRegisterMsgHandler( global.MsgType.MSG_SC_ACTION_PICK_CORPSE,         handler( self, self.handleMessage) )

    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_ACTOR_DEATH_FALL_DOWN,  handler( self, self.handleMessage) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_ACTOR_DEATH_SKELETON,   handler( self, self.handleMessage) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_PLAYER_REVIVE,          handler( self, self.handleMessage) )

    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_PLAYER_OUT_OF_VIEW,     handler( self, self.handleMessage) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_PLAYER_FLY_OUT,         handler( self, self.handleMessage) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_PLAYER_FLY_OUT_2,       handler( self, self.handleMessage) )
    
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_ACTOR_ICONS_UPDATE,         handler( self, self.handleMessage) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_ACTOR_TITLE_UPDATE,         handler( self, self.handleMessage) )

    LuaRegisterMsgHandler( global.MsgType.MSG_SM_ACTOR_AUTO_MINING,          handler( self, self.handleMessage) )
    
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_ACTOR_RELEVEL,              handler( self, self.handleMessage) )
    -----------------------------------------------------------------------------
    -- main player
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_MAP_ACTOR_CLEANUP,          handler( self, self.handle_MSG_SC_MAP_ACTOR_CLEANUP) )
    -----------------------------------------------------------------------------

    -----------------------------------------------------------------------------
    -- scene effect
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_MAP_ADD_SPECIAL_EFFECT,     handler( self, self.handle_MSG_SC_MAP_ADD_SPECIAL_EFFECT) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_MAP_RMV_SPECIAL_EFFECT,     handler( self, self.handle_MSG_SC_MAP_RMV_SPECIAL_EFFECT) )
    -----------------------------------------------------------------------------

    -----------------------------------------------------------------------------
    -- drop item
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_MAP_ITEM_DROP_BATCH,        handler( self, self.handle_MSG_SC_MAP_ITEM_DROP_BATCH) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_MAP_ITEM_REMOVE_BATCH,      handler( self, self.handle_MSG_SC_MAP_ITEM_REMOVE_BATCH) )
    -----------------------------------------------------------------------------

    -----------------------------------------------------------------------------
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_OPEN_DOOR_NOTICE,           handler( self, self.handle_MSG_SC_OPEN_DOOR_NOTICE) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_CLOSE_DOOR_NOTICE,          handler( self, self.handle_MSG_SC_CLOSE_DOOR_NOTICE) )
    -----------------------------------------------------------------------------
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_OPENHEALTH,                 handler( self, self.handle_MSG_SC_OPENHEALTH) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_CLOSEHEALTH,                handler( self, self.handle_MSG_SC_CLOSEHEALTH) )
    -----------------------------------------------------------------------------

    -----------------------------------------------------------------------------
    -- 技能释放成功，进入释放动作
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_PLAYER_SKILL_LAUNCH_SUCCESS,handler(self, self.handle_MSG_SC_PLAYER_SKILL_LAUNCH_SUCCESS))
    -- 攻击成功，进入攻击动作+播放攻击特效
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_PLAYER_ATTACK,          handler(self, self.handle_MSG_SC_NET_PLAYER_ATTACK))
    -- 技能释放成功，播放释放特效
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_PLAYER_SKILL_MAGIC_SUCCESS, handler(self, self.handle_MSG_SC_PLAYER_SKILL_MAGIC_SUCCESS))
    -- 地图某个位置播放一个特效
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_MAINPLAYER_MAGIC,           handler(self, self.handle_MSG_SC_MAINPLAYER_MAGIC))
    -----------------------------------------------------------------------------
    
    -----------------------------------------------------------------------------
    -- 移动特效、足迹
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_ACTOR_MOVE_EFF,             handler(self, self.handle_MSG_SC_ACTOR_MOVE_EFF))
    -----------------------------------------------------------------------------
    
    -----------------------------------------------------------------------------
    -- 强制移动
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_PLAYER_MOVE_FORCE,      handler(self, self.handle_MSG_SC_NET_PLAYER_MOVE_FORCE))
    ------------------------------------------------------------------------------

    -----------------------------------------------------------------------------
    -- gmdata 更新
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_ACTOR_GMDATA_UPDATE,       handler(self, self.MSG_SC_ACTOR_GMDATA_UPDATE))
    -- 内力值 更新
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_ACTOR_INTERNAL_FORCE_UPDATE, handler(self, self.handle_MSG_SC_ACTOR_INTERNAL_FORCE_UPDATE))

    -- 通知反击 特殊
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_FIGHT_BACK_ID,              handler(self, self.handle_MSG_SC_FIGHT_BACK_ID))
    ------------------------------------------------------------------------------

    -- in of view
    self.mNetMsgHandle[global.MsgType.MSG_SC_NET_PLAYER_IN_OF_VIEW] = function(msgHdr, msgData)
        self:handle_InOfView(msgHdr, msgData)
    end

    -- fly in effect
    self.mNetMsgHandle[global.MsgType.MSG_SC_NET_PLAYER_FLY_IN] = function(msgHdr, msgData)
        self:handle_FlyIn(msgHdr, msgData)
    end
    self.mNetMsgHandle[global.MsgType.MSG_SC_NET_PLAYER_FLY_IN_2] = function(msgHdr, msgData)
        self:handle_FlyIn2(msgHdr, msgData)
    end
    
    -- feature changed
    self.mNetMsgHandle[global.MsgType.MSG_SC_PLAYER_FEATURE_CHANGED] = function(msgHdr, msgData)
        self:handle_FeatureChanged(msgHdr, msgData)
    end

    -- walk
    self.mNetMsgHandle[global.MsgType.MSG_SC_NET_PLAYER_WALK] = function(msgHdr, msgData)
        self:handle_Walk(msgHdr, msgData)
    end

    -- run
    self.mNetMsgHandle[global.MsgType.MSG_SC_NET_PLAYER_RUN] = function(msgHdr, msgData)
        self:handle_Run(msgHdr, msgData)
    end

    -- 跑一格
    self.mNetMsgHandle[global.MsgType.MSG_SC_WALKEX] = function(msgHdr, msgData)
        self:handle_Run(msgHdr, msgData, true)
    end

    -- rile run
    self.mNetMsgHandle[global.MsgType.MSG_SC_NET_PLAYER_RIDE_RUN] = function(msgHdr, msgData)
        self:handle_RideRun(msgHdr, msgData)
    end

    -- turn
    self.mNetMsgHandle[global.MsgType.MSG_SC_NET_ACTOR_TURN] = function(msgHdr, msgData)
        self:handle_Turn(msgHdr, msgData)
    end

    -- refresh hp
    self.mNetMsgHandle[global.MsgType.MSG_SC_PLAYER_HP_MP] = function(msgHdr, msgData)
        self:handle_RefreshHP(msgHdr, msgData)
    end

    -- damage hp
    self.mNetMsgHandle[global.MsgType.MSG_SC_DAMAGE_HP] = function(msgHdr, msgData)
        self:handle_Damage(msgHdr, msgData)
    end

    -- refresh speed
    self.mNetMsgHandle[global.MsgType.MSG_SC_ACTOR_REFRESH_ACTOR_SPEED] = function(msgHdr, msgData)
        self:handle_RefreshSpeed(msgHdr, msgData)
    end

    -- refresh monster speed
    self.mNetMsgHandle[global.MsgType.MSG_SC_REFRESH_MONSTER_SPEED] = function(msgHdr, msgData)
        self:handle_RefreshMonsterSpeed(msgHdr, msgData)
    end


    -- refresh name
    self.mNetMsgHandle[global.MsgType.MSG_SC_ACTOR_NAME] = function(msgHdr, msgData)
        self:handle_RefreshName(msgHdr, msgData)
    end

    -- sell
    self.mNetMsgHandle[global.MsgType.MSG_SC_SELL_NOTICE] = function(msgHdr, msgData)
        self:handle_Sell(msgHdr, msgData)
    end

    -- pick corpse
    self.mNetMsgHandle[global.MsgType.MSG_SC_ACTION_PICK_CORPSE] = function(msgHdr, msgData)
        self:handle_PickCorpse(msgHdr, msgData)
    end

    -- death fall down
    self.mNetMsgHandle[global.MsgType.MSG_SC_NET_ACTOR_DEATH_FALL_DOWN] = function(msgHdr, msgData)
        self:handle_DeathFallDown(msgHdr, msgData)
    end
    self.mNetMsgHandle[global.MsgType.MSG_SC_NET_ACTOR_DEATH_SKELETON] = function(msgHdr, msgData)
        self:handle_DeathSkeleton(msgHdr, msgData)
    end

    -- death fall down
    self.mNetMsgHandle[global.MsgType.MSG_SC_NET_PLAYER_REVIVE] = function(msgHdr, msgData)
        self:handle_Revive(msgHdr, msgData)
    end

    -- out of view
    self.mNetMsgHandle[global.MsgType.MSG_SC_NET_PLAYER_OUT_OF_VIEW] = function(msgHdr, msgData)
        self:handle_OutOfView(msgHdr, msgData)
    end

    -- fly out effect
    self.mNetMsgHandle[global.MsgType.MSG_SC_NET_PLAYER_FLY_OUT] = function(msgHdr, msgData)
        self:handle_FlyOut(msgHdr, msgData)
    end
    self.mNetMsgHandle[global.MsgType.MSG_SC_NET_PLAYER_FLY_OUT_2] = function(msgHdr, msgData)
        self:handle_FlyOut2(msgHdr, msgData)
    end


    -- buff update
    self.mNetMsgHandle[global.MsgType.MSG_SC_ACTOR_BUFF_INIT] = function(msgHdr, msgData)
        global.BuffManager:handleBuffInit(msgHdr, msgData)
    end
    self.mNetMsgHandle[global.MsgType.MSG_SC_ACTOR_BUFF_ADD] = function(msgHdr, msgData)
        global.BuffManager:handleBuffAdd(msgHdr, msgData)
    end
    self.mNetMsgHandle[global.MsgType.MSG_SC_ACTOR_BUFF_RMV] = function(msgHdr, msgData)
        global.BuffManager:handleBuffRmv(msgHdr, msgData)
    end

    -- actor icons
    self.mNetMsgHandle[global.MsgType.MSG_SC_ACTOR_ICONS_UPDATE] = function(msgHdr, msgData)
        self:handle_Icons(msgHdr, msgData)
    end

    -- actor title
    self.mNetMsgHandle[global.MsgType.MSG_SC_ACTOR_TITLE_UPDATE] = function(msgHdr, msgData)
        self:handle_Title(msgHdr, msgData)
    end

    -- actor effect
    self.mNetMsgHandle[global.MsgType.MSG_SC_ACTOR_EFFECT_UPDATE] = function(msgHdr, msgData)
        global.ActorEffectManager:handle_ActorEffectUpdate(msgHdr, msgData)
    end

    -- actor auto mining
    self.mNetMsgHandle[global.MsgType.MSG_SM_ACTOR_AUTO_MINING] = function(msgHdr, msgData)
        self:handle_AutoMining(msgHdr, msgData)
    end

    -- actor relevel 
    self.mNetMsgHandle[global.MsgType.MSG_SC_ACTOR_RELEVEL] = function(msgHdr, msgData)
        self:handle_ActorReLevel(msgHdr, msgData)
    end
end

return gameMapController
