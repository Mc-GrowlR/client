local gamePlayerController = class("gamePlayerController")
local Queue = requireUtil( "queue" )
gamePlayerController.NAME = "gamePlayerController"

local actorUtils = requireProxy( "actorUtils" )

local moveMsgType = 
{
    [global.MMO.ACTION_WALK] = global.MsgType.MSG_CS_MAIN_PLAYER_WALK,
    [global.MMO.ACTION_RUN] = global.MsgType.MSG_CS_MAIN_PLAYER_RUN,
    [global.MMO.ACTION_RIDE_RUN] = global.MsgType.MSG_CS_MAIN_PLAYER_RIDE_RUN,
    [global.MMO.ACTION_ASSASSIN_SNEAK] = global.MsgType.MSG_CS_MAIN_PLAYER_WALK,
}

local moveStep = 
{
    [global.MMO.ACTION_WALK] = 1,
    [global.MMO.ACTION_RUN] = 2,
    [global.MMO.ACTION_RIDE_RUN] = 3,
    [global.MMO.ACTION_ASSASSIN_SNEAK] = 1,
}

function gamePlayerController:ctor()
    self.mMainPlayerID = global.MMO.ACTOR_ID_INVALID
    self.mMainPlayerActor = nil
    self.mLuaTouchHandler = -1
    self.mLuaInputHandler = -1

    self.mHandleOnActCompleted = {}
    self.mHandleOnActBegin = {}
    self.mActQueue = Queue.new()
    self.mInputEnable = true

    self:Init()

    self:RegisterMsgHandler()
end

function gamePlayerController:destory()
    if gamePlayerController.instance then
        gamePlayerController.instance = nil
    end
end

function gamePlayerController:Inst()
    if not gamePlayerController.instance then
        gamePlayerController.instance = gamePlayerController.new()
    end

    return gamePlayerController.instance
end

function gamePlayerController:Init()
end
-----------------------------------------------------------------------------
function gamePlayerController:RegisterMsgHandler()
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_PLAYER_CHANGE_ID, handler( self, self.handle_MSG_SC_PLAYER_CHANGE_ID ) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_NET_PLAYER_MOVE_FAIL, handler( self, self.handle_MSG_SC_NET_PLAYER_MOVE_FAIL ) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_ACTION_CONFIREM_SUCCESS , handler( self, self.handle_MSG_SC_ACTION_CONFIRM ) )
    LuaRegisterMsgHandler( global.MsgType.MSG_SC_SKILL_ACTION_CONFIRM_SUCCESS , handler( self, self.handle_MSG_SC_SKILL_ACTION_CONFIRM ) )
end
-----------------------------------------------------------------------------
function gamePlayerController:HandleTouchEndEvent(touchPos, touchWay, eventType)
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    local state = ItemMoveProxy:GetMovingItemState()
    if state then
        return
    end
    self:NotifyLuaTouchEvent( touchPos, touchWay, eventType)
end
-----------------------------------------------------------------------------
function gamePlayerController:handleActionBegin(actor, actBegin)
    if nil == self.mMainPlayerActor then
        return -1
    end

    if actBegin == global.MMO.ACTION_WALK or actBegin == global.MMO.ACTION_ASSASSIN_SNEAK or actBegin == global.MMO.ACTION_RUN or actBegin == global.MMO.ACTION_RIDE_RUN then
        -- Store last point for moving confirmation
        local MapProxy  = global.Facade:retrieveProxy(global.ProxyTable.Map)
        local mapID     = MapProxy:GetMapID()
        local msgType   = moveMsgType[actBegin]

        -- 检测服务器开关
        if actBegin == global.MMO.ACTION_RUN and CHECK_SERVER_OPTION(global.MMO.SERVER_RUN_ONE) then
            msgType = global.MsgType.MSG_CS_WALKEX
        end

        local dir       = self.mMainPlayerActor:GetDirection()
        local player    = self.mMainPlayerActor
        local point     = player:GetMapY() * 65536 + player:GetMapX()
        local lastPoint = player:GetLastMapY() * 65536 + player:GetLastMapX()

        LuaSendMsg( msgType, point, 0, dir, lastPoint, mapID, string.len(mapID) )
    end

    self:OnActionBegin(actor, actBegin)

    -- Action begin handle.
    for k,v in pairs(self.mHandleOnActBegin) do
        v(actor, actBegin)
    end
end
-----------------------------------------------------------------------------
function gamePlayerController:OnActionBegin(actor, actBegin)
    if actBegin == global.MMO.ACTION_WALK or actBegin == global.MMO.ACTION_RUN or actBegin == global.MMO.ACTION_RIDE_RUN then
        global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type=global.MMO.SND_TYPE_ACT_MOVE, index=actBegin, isRide=actor:GetHorseMasterID()})
        ssr.ssrBridge:OnActionBegin(actBegin)
    end

    if actBegin ~= global.MMO.ACTION_IDLE then
        global.Facade:sendNotification( global.NoticeTable.MainPlayerActionBegan, actBegin )
    end
end
-----------------------------------------------------------------------------
function gamePlayerController:OnActionCompleted(actor, actCompleted)
    local nextAct = nil
    local actData = nil
    if not self.mActQueue:empty() then
        local act = self.mActQueue:pop()
        nextAct   = act.act
        actData   = act.data

        self.mInputEnable = false
    else
        self.mInputEnable = true
    end


    if nextAct then
        self:executeAction(nextAct, actData)
    end


    if actCompleted ~= global.MMO.ACTION_IDLE then
        global.Facade:sendNotification( global.NoticeTable.MainPlayerActionEnded, actCompleted )
    end
end
-----------------------------------------------------------------------------
function gamePlayerController:handleActionCompleted(actor, actCompleted)  
    self:OnActionCompleted( actor, actCompleted )

    -- Action completion handle.
    for k,v in pairs(self.mHandleOnActCompleted) do
        v(actor, actCompleted)
    end

    if actCompleted == 27 then 
        print("真正释放特效.................")
    end 
    self:ProcessLuaInput( actor, actCompleted )

    if actCompleted == global.MMO.ACTION_WALK or actCompleted == global.MMO.ACTION_RUN or actCompleted == global.MMO.ACTION_RIDE_RUN then
        local currAct = actor:GetAction()
        if currAct ~= global.MMO.ACTION_ASSASSIN_SNEAK and currAct ~= global.MMO.ACTION_WALK and currAct ~= global.MMO.ACTION_RUN and currAct ~= global.MMO.ACTION_RIDE_RUN then
            actor:setPosition( actor.mTargePos.x, actor.mTargePos.y )
        end

        if actor:IsMoveEff() and SL:GetMetaValue("GAME_DATA", "disable_footprint_effect") ~= 1 then
            local lastMapX = actor:GetLastMapX()
            local lastMapY = actor:GetLastMapY()
            local skipWalk = actor:GetMoveEffSkipWalk()
            local skipSwitch = actor:GetEffSkipWalkSwitch() or 0
            actor:SetMoveEffSkipWalk(not skipWalk and skipSwitch == 0)
            if lastMapX == 0xFFFF or lastMapY == 0xFFFF or (actCompleted == global.MMO.ACTION_WALK and skipWalk) then
                return
            end
            global.gameMapController:addEffectToMap(actor:GetMoveEff(), lastMapX, lastMapY)
        end        
    elseif actCompleted == global.MMO.ACTION_ASSASSIN_SNEAK then
        local currAct = actor:GetAction()
        if currAct ~= global.MMO.ACTION_ASSASSIN_SNEAK and currAct ~= global.MMO.ACTION_WALK and currAct ~= global.MMO.ACTION_RUN and currAct ~= global.MMO.ACTION_RIDE_RUN then
            actor:setPosition( actor.mTargePos.x, actor.mTargePos.y )
        end
    end
end
-----------------------------------------------------------------------------
function gamePlayerController:handleActionProcess(actor, act, dt)
    if act ~= global.MMO.ACTION_IDLE then
        global.Facade:sendNotification( global.NoticeTable.MainPlayerActionProcess, act )
    end
end
-----------------------------------------------------------------------------
function gamePlayerController:BindMainActor(player)  
    self.mMainPlayerActor = player
    -- 
    local mainPlayerID = player:GetID()
    print( "main player ID", mainPlayerID )
    self:SetMainPlayerID( mainPlayerID )
    global.playerManager:SetMainPlayerID( mainPlayerID )

    -- set is mainPlayer
    self.mMainPlayerActor:SetIsMainPlayer(true)

    -- To map grid position.
    local mapX = player:GetMapX()
    local mapY = player:GetMapY()
    local worldPos = global.sceneManager:MapPos2WorldPos( mapX, mapY, true )
    player:setPosition( worldPos.x, worldPos.y )

    -- Action listener
    self.mMainPlayerActor:SetGameActorActionHandler ( self )

    global.Facade:sendNotification( global.NoticeTable.BindMainPlayer, player )
    SLBridge:onLUAEvent(LUA_EVENT_BIND_MAINPLAYER)
    if global.Platform == cc.PLATFORM_OS_WINDOWS then
        print( "bind main player:"..player:GetID() )
    end
end
-----------------------------------------------------------------------------
function gamePlayerController:Cleanup()  
    self.mMainPlayerID     = global.MMO.ACTOR_ID_INVALID
    self.mMainPlayerActor  = nil

    self.mHandleOnActCompleted = {}
    self.mHandleOnActBegin = {}

    self.mLuaTouchHandler = -1
    self.mLuaInputHandler = -1

    self.mInputEnable       = true
end

function gamePlayerController:CleanupMainPlayer()  
    self.mMainPlayerID    = global.MMO.ACTOR_ID_INVALID
    self.mMainPlayerActor = nil
end
-----------------------------------------------------------------------------
function gamePlayerController:handle_MSG_SC_ACTION_CONFIRM(msg) 
    if nil == self.mMainPlayerActor then
        return -1
    end

    self.mMainPlayerActor:SetConfirmed(true)
    -- self.mMainPlayerActor:SetDashWaiting(false)

    return 1
end

function gamePlayerController:handle_MSG_SC_SKILL_ACTION_CONFIRM( msg )
    if nil == self.mMainPlayerActor then
        return -1
    end

    local isConfirmed = true
    local msgLen = msg:GetDataLength()
    if msgLen > 0 then
        local msgHdr = msg:GetHeader()
        local dataString = msg:GetData():ReadString(msgLen)
        isConfirmed = dataString == self.mMainPlayerActor:GetID()
    end

    if isConfirmed then
        self.mMainPlayerActor:SetConfirmed(true)
        self.mMainPlayerActor:SetDashWaiting(false)
    end

    return 1
end
-----------------------------------------------------------------------------
function gamePlayerController:OnChangeScene( mapX, mapY )  
    if not self.mMainPlayerActor then
        return
    end
    
    if self.mMainPlayerActor:IsDie() or self.mMainPlayerActor:IsDeath() then
        return
    end

    -- Set player to new map position.
    local actorPos = global.sceneManager:MapPos2WorldPos( mapX, mapY, true )
    self.mMainPlayerActor:SetAction(global.MMO.ACTION_IDLE)
    self.mMainPlayerActor:setPosition(actorPos.x, actorPos.y)
    global.actorManager:SetActorMapXY( self.mMainPlayerActor, mapX, mapY )

    -- stop player
    self.mMainPlayerActor:SetIsArrived(true)
    self.mMainPlayerActor:SetConfirmed(true)     
    self.mMainPlayerActor:SetDashWaiting(false)  

    --
    global.Facade:sendNotification(global.NoticeTable.PlayerMapPosChange)
    SLBridge:onLUAEvent("LUA_EVENT_PLAYER_MAPPOS_CHANGE")

    return 1
end
-----------------------------------------------------------------------------
function gamePlayerController:handle_Die( mainPlayerActor, msgHdr )  

    -- Force stop player
    mainPlayerActor.mIsArrived   = true
    mainPlayerActor:SetConfirmed(true)
    mainPlayerActor:SetDashWaiting(false)
    mainPlayerActor.mOrient      = msgHdr.param3
    local targetPos              = global.sceneManager:MapPos2WorldPos( mainPlayerActor.mCurrMapX,
                                                                        mainPlayerActor.mCurrMapY,
                                                                        true )
    mainPlayerActor:setPosition( targetPos.x, targetPos.y )
    mainPlayerActor:SetAction( global.MMO.ACTION_DIE )

    global.actorManager:SetActorMapXY( mainPlayerActor, msgHdr.param1,msgHdr.param2 )

    return 1
end
-----------------------------------------------------------------------------
function gamePlayerController:handle_MSG_SC_NET_PLAYER_MOVE_FAIL(msg)  
    local mainPlayer = self:GetMainPlayer()
    if nil == mainPlayer then
        return -1
    end

    if mainPlayer:IsDie() or mainPlayer:IsDeath() then
        return
    end

    
    local msgHdr = msg:GetHeader()
    -- 通知抛弃
    if msgHdr.recog >= 40 then
        return -1
    end

    print(string.format( "!!!!!!!!!!!!!!!!!!!! move fail:%d. [%d, %d] ---> [%d, %d]", msgHdr.recog, mainPlayer:GetMapX(), mainPlayer:GetMapY(), msgHdr.param1, msgHdr.param2 ))
    
    if mainPlayer:IsOnPush() and mainPlayer:GetMapX() == msgHdr.param1 and mainPlayer:GetMapY() == msgHdr.param2 then
        return -1
    end
    
    local posOfAccepted = global.sceneManager:MapPos2WorldPos(msgHdr.param1, msgHdr.param2, true)
    mainPlayer:SetDirection(msgHdr.param3)
    mainPlayer:setPosition(posOfAccepted.x, posOfAccepted.y)
    mainPlayer:SetIsArrived(true)
    mainPlayer:SetConfirmed(true)
    global.actorManager:SetActorMapXY( mainPlayer, msgHdr.param1,msgHdr.param2 )

    -- 28号消息，recog=1的时候，可以立刻走，其他等待一下
    if msgHdr.recog == 1 then
        -- 拉回时等状态时间结束
        local currentActT = mainPlayer.mCurrentActT
        mainPlayer:SetAction(global.MMO.ACTION_IDLE_LOCK)
        mainPlayer.mCurrentActT = currentActT
    else
        -- 拉回时等状态时间结束
        local currentActT = mainPlayer.mCurrentActT
        mainPlayer:SetAction(global.MMO.ACTION_IDLE_LOCK)
        mainPlayer.mCurrentActT = currentActT
    end

    return 1
end
-----------------------------------------------------------------------------
function gamePlayerController:handle_MSG_SC_PLAYER_CHANGE_ID(msg)  
    local jsonData = ParseRawMsgToJson( msg )
    if not jsonData then
        return -1
    end

    local actorID = jsonData.UserID
    if self.mMainPlayerID == actorID then
        return 1
    end

    global.actorManager:RefreshActorID( self.mMainPlayerID, actorID )
    global.playerManager:SetMainPlayerID( actorID )

    self.mMainPlayerID = actorID

    return 1
end
-----------------------------------------------------------------------------
function gamePlayerController:handle_MSG_SC_ACTOR_STUCK()
    if nil == self.mMainPlayerActor then
        return -1
    end

    local player  = self.mMainPlayerActor
    -- 死亡状态无法切换
    if player:IsDie() or player:IsDeath() then
        return
    end

    if global.MMO.ACTION_IDLE == player:GetAction() then
        player:SetAction(global.MMO.ACTION_STUCK)
    else
        self:pushAction(global.MMO.ACTION_STUCK)
    end

    return 1
end

-----------------------------------------------------------------------------
function gamePlayerController:handle_MSG_SC_NET_PLAYER_ATTACK(actor, msgHdr, jsonData)
    -- 死亡状态无法切换
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    -- local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    -- SkillProxy:actorEnterAction(jsonData, msgHdr, false)
    -- SkillProxy:requestSkillPresent(jsonData, 1)
    -- SkillProxy:requestSkillPresent(jsonData, 2)
end
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
function gamePlayerController:handle_MSG_SC_PLAYER_SKILL_LAUNCH_SUCCESS(actor, msgHdr, jsonData)
    -- 死亡状态无法切换
    if actor:IsDie() or actor:IsDeath() then
        return
    end

    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    SkillProxy:actorEnterAction(jsonData, true)
end
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
function gamePlayerController:handle_MSG_SC_PLAYER_SKILL_MAGIC_SUCCESS(actor, msgHdr, jsonData)
    -- 死亡状态无法切换
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    SkillProxy:requestSkillPresent(jsonData, 2)
end
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
function gamePlayerController:handle_MSG_SC_PLAYER_SKILL_27_SUCCESS(actor, msgHdr)
    -- 野蛮
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    local mapX    = msgHdr.param1
    local mapY    = msgHdr.param2
    local dir     = H16Bit(msgHdr.param3) == 0 and L16Bit(msgHdr.param3) or L16Bit(msgHdr.param3)
    local time    = msgHdr.recog * 0.001
    local skillId = H16Bit(msgHdr.param3) > 0 and H16Bit(msgHdr.param3) or 0
    -- 坐标不对
    if (mapX == actor:GetMapX() and mapY == actor:GetMapY()) or time == 0 then
        --执行野蛮失败撞墙动作
        actor:SetAction(global.MMO.ACTION_DASH_FAIL)
        return
    end

    -- 野蛮时间需要加上动作补间
    local addTime = global.GameActorSkillController:GetMainPlayerAddDashTime()
    time = time + addTime
    global.GameActorSkillController:SetMainPlayerAddDashTime(0)

    -- 防止野蛮后后退
    global.Facade:sendNotification(global.NoticeTable.ClearAllInputState)
    global.Facade:sendNotification(global.NoticeTable.InputIdle)
    if skillId == 0 then 
        actorUtils.actorDash(actor, mapX, mapY, dir, time)
    else 
        actorUtils.actorZhuiXinCi(actor, mapX, mapY, dir, time)
    end 
end
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
function gamePlayerController:handle_MSG_SC_PLAYER_SKILL_27_BACKSTEP(actor, msgHdr)
    -- 被野蛮，被推开
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    local mapX      = msgHdr.param1
    local mapY      = msgHdr.param2
    local dir       = msgHdr.param3
    local time      = msgHdr.recog

    -- 坐标不对
    if (mapX == actor:GetMapX() and mapY == actor:GetMapY()) or time == 0 then
        return
    end

    -- 防止野蛮后后退
    global.Facade:sendNotification(global.NoticeTable.ClearAllInputState)
    global.Facade:sendNotification(global.NoticeTable.InputIdle)

    local moveTime = L16Bit(time) * 0.001
    local idleTime = math.min(H16Bit(time) * 0.001, 5)
    actorUtils.actorOnDash(actor, mapX, mapY, dir, moveTime, idleTime)
end
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
function gamePlayerController:handle_MSG_SC_PLAYER_SKILL_82_SUCCESS(actor, msgHdr)
    -- 十步一杀 瞬移
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    local mapX = msgHdr.param1
    local mapY = msgHdr.param2
    local dir = msgHdr.param3

    -- 坐标不对
    if (mapX == actor:GetMapX() and mapY == actor:GetMapY()) then
        return
    end

    -- 清理所有输入状态
    global.Facade:sendNotification(global.NoticeTable.ClearAllInputState)
    global.Facade:sendNotification(global.NoticeTable.InputIdle)

    -- 关闭技能
    local SkillProxy = global.Facade:retrieveProxy( global.ProxyTable.Skill )
    if SkillProxy:GetSelectSkill() == global.MMO.SKILL_INDEX_SBYS then
        SkillProxy:ClearSelectSkill()
    end
    
    -- 进入十步一杀技能表现
    actorUtils.actorSBYS(actor, mapX, mapY, dir)
end
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
function gamePlayerController:handle_MSG_SC_PLAYER_SKILL_71_SUCCESS(actor, msgHdr)
    -- 擒龙手 瞬移
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    local mapX = msgHdr.param1
    local mapY = msgHdr.param2
    local dir = msgHdr.param3

    -- 坐标不对
    if (mapX == actor:GetMapX() and mapY == actor:GetMapY()) then
        return
    end
    
    actorUtils.actorQLS(actor, mapX, mapY, dir)
end
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
function gamePlayerController:NotifyLuaTouchEvent(touch, touchWay, eventType)  
    if -1 ~= self.mLuaTouchHandler then
        self.mLuaTouchHandler(touch, touchWay, eventType)
    end
end
-----------------------------------------------------------------------------
function gamePlayerController:ProcessLuaInput(actor, actCompleted)  
    if -1 ~= self.mLuaInputHandler and actCompleted ~= global.MMO.ACTION_DIE and self.mInputEnable then
        self.mLuaInputHandler(actor, actCompleted)
    end
end

-----------------------------------------------------------------------------
function gamePlayerController:clearActQueue()
    self.mActQueue:clear()
end
function gamePlayerController:pushAction(act, data)
    if nil == self.mMainPlayerActor then
        return -1
    end
    if nil == act then
        return -2
    end
    if false == (act >= global.MMO.ACTION_IDLE and act <= global.MMO.ACTION_MAX) then
        return -3
    end

    if global.MMO.ACTION_IDLE == self.mMainPlayerActor:GetAction() then
        self:executeAction(act, data)
    else
        self.mActQueue:push({act = act, data = data})
    end

    return 1
end
function gamePlayerController:executeAction(act, data)
    if nil == self.mMainPlayerActor then
        return -1
    end

    self.mMainPlayerActor:SetAction(act)

    if data then
        -- on callback
        if data.callback then
            data.callback()
        end
    end
end

function gamePlayerController:GetMainPlayer()  
    return self.mMainPlayerActor
end
function gamePlayerController:SetMainPlayerID( id )  
    self.mMainPlayerID = id
end

function gamePlayerController:GetMainPlayerID()  
    return self.mMainPlayerID
end

function gamePlayerController:AddHandleOnActCompleted(func)  
    table.insert(self.mHandleOnActCompleted, func)
end

function gamePlayerController:AddHandleOnActBegin(func)  
    table.insert(self.mHandleOnActBegin, func)
end

function gamePlayerController:RegisterLuaTouchHandler(appHandler)  
    self.mLuaTouchHandler   = appHandler
end

function gamePlayerController:RegisterLuaInputHandler(inputHandler)  
    self.mLuaInputHandler   = inputHandler
end

function gamePlayerController:SetBindHorseActor( actor )
    self.mHorseActor = actor
end

function gamePlayerController:GetBindHorseActor()
    if not self.mHorseActor or tolua.isnull(self.mHorseActor:GetNode()) then
        self.mHorseActor = nil
    end
    return self.mHorseActor
end

function gamePlayerController:handle_Revive(actor, jsonData)
    -- feature
    if jsonData.Hp and jsonData.MaxHp then
        actor:SetHPHUD(jsonData.Hp, jsonData.MaxHp)
    end

    -- To map grid position
    local worldPos = global.sceneManager:MapPos2WorldPos(jsonData.X, jsonData.Y, true)

    actor:SetConfirmed(true)
    actor:SetIsArrived(true)
    actor:stopAnimToFrame(nil)
    actor:setPosition(worldPos.x, worldPos.y)
    actor:SetDirection(jsonData.Dir)
    actor:SetAction(global.MMO.ACTION_IDLE, true)
    actor:dirtyAnimFlag()
    global.actorManager:SetActorMapXY(actor, jsonData.X, jsonData.Y)

    -- 刷新主玩家安全区
    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    MapProxy:UpdateInSafeAreaState()

    local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    PlayerPropertyProxy:setAlive(true)

    global.Facade:sendNotification(global.NoticeTable.Audio_Stop_BGM)

    local noticeData = {}
    noticeData.actor   = actor
    noticeData.actorID = jsonData.UserID
    global.Facade:sendNotification(global.NoticeTable.ActorRevive, noticeData)

    global.Facade:sendNotification(global.NoticeTable.SceneFollowMainPlayer)
end

function gamePlayerController:handle_Move_Force( actor,jsonData )
    self:clearActQueue()

    if actor:IsDie() or actor:IsDeath() then
        return
    end

    local posOfAccepted = global.sceneManager:MapPos2WorldPos(jsonData.mapX, jsonData.mapY, true)
    actor:SetAction(global.MMO.ACTION_IDLE, true)
    actor.mIsArrived = true
    actor.mIsConfirmed = true     
    actor:SetDirection(jsonData.dir)
    actor:setPosition(posOfAccepted.x, posOfAccepted.y)
    global.actorManager:SetActorMapXY( actor, jsonData.mapX, jsonData.mapY )

    global.Facade:sendNotification(global.NoticeTable.SceneFollowMainPlayer)
end

return gamePlayerController
