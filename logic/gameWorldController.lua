local GameWorldController = class("GameWorldController", function ()
    return cc.Layer:create()
end)

local SCENE_GRAPH_FILE  = "scene/GameWorld.csb" 

function GameWorldController:ctor()

    self.mSpeedCheatCount = 0
    self.mElapsedT = 0
    self.mLastElapsedT = 0
    self.mLoopCount  = 0
    self.mHeartBeatT = os.time()

    self._restart = false

    self._leaveWorld = false

    self:RegisterMsgHandler()
end

function GameWorldController:destory()
end

function GameWorldController.create()
    local layer = GameWorldController.new()
    if layer:Init() then
        return layer
    else
        return nil
    end
end

-----------------------------------------------------------------------------
function GameWorldController:Init()
    --********* Mis
    self:scheduleUpdateWithPriorityLua(handler(self, self.update), 0)

    return true
end
-----------------------------------------------------------------------------
function GameWorldController:handleMessage(msg)
    -- Message 885, anti SPEED cheat
    local hdr = msg:GetHeader()
    local dataSourceSize = msg:GetDataLength()
    local dataSource = msg:GetData()

    local sliceStr = dataSource:ReadString( dataSourceSize )
    local jsonData = string.split(sliceStr , "/")

    local     localElapsedSinceLastMsg  = self.mElapsedT - self.mLastElapsedT
    local     serverElapsedSinceLastMsg = tonumber( jsonData[3] )
    local     serverCurrTime            = tonumber( jsonData[2] )
    
    local     timeDiff                  = localElapsedSinceLastMsg - serverElapsedSinceLastMsg;
    
    --云真机启动
    if global.L_GameEnvManager:GetEnvDataByKey("isCloudLogin") then
        return
    end

    if self.mElapsedT == self.mLastElapsedT and self.mLastElapsedT > 0 then  -- 885 message may be accumulated ( e.g. app process be suspend by onStop/onResume ) -- Make sure it is not initial state.
                    
        self.mSpeedCheatCount = 0
        return 1
    end

    if self.s_isRoot and timeDiff >= hdr.param2 and 0 < self.mElapsedT and 1 == hdr.param1 and self.mLoopCount < 200 then
        self.mSpeedCheatCount = self.mSpeedCheatCount + 1

        if  hdr.param3 <= self.mSpeedCheatCount then

            if not global.isDebugMode then
                -- issue, can not restart in handle msg
                self._restart = true
            else
                print( "Speed cheat has detected" )
            end
        end
    else
        -- cold down
        self.mSpeedCheatCount = ( 0 >= self.mSpeedCheatCount ) and 0 or (self.mSpeedCheatCount - 1)
    end
  

    -- Sync time line
    self.mElapsedT         = serverCurrTime
    self.mLastElapsedT     = self.mElapsedT
    self.mLoopCount        = 0

    return 1
end

function GameWorldController:RespGameWorldInfoInit(msg)
    global.Facade:sendNotification(global.NoticeTable.GameWorldInfoInitBegin)

    -- 开始初始化
    local jsonData = ParseRawMsgToJson( msg )
    local header = msg:GetHeader()
    local data = {
        jsonData = jsonData,
        header = header
    }
    global.Facade:sendNotification(global.NoticeTable.GameWorldInfoInit, data)

    local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    LoginProxy:SyncVersion()
    
    if LoginProxy and LoginProxy.SendDeviceInfo then
        LoginProxy:SendDeviceInfo()
    end

    if LoginProxy and LoginProxy.SendSDKInfo then
        LoginProxy:SendSDKInfo()
    end
end

function GameWorldController:RegisterMsgHandler()
    LuaRegisterMsgHandler(885, handler( self, self.handleMessage) )
    -----------------------------------------------------------------------------

    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GAME_WORLD_INFO_INIT, handler(self, self.RespGameWorldInfoInit))
end
-----------------------------------------------------------------------------

function GameWorldController:CheckHeartBeat()
    local dValue = math.abs(os.time() - self.mHeartBeatT)
    if dValue >= 60 then
        self.mHeartBeatT = os.time()
    end
    if os.time() - self.mHeartBeatT < 10 then
        return
    end
    self.mHeartBeatT = os.time()

    -- 发心跳
    LuaSendMsg( global.MsgType.MSG_CS_HEART_BEAT_KEEP, self.mHeartBeatT )
end

function GameWorldController:OnGameSuspend()
    -- 暂停前发心跳 发心跳
    -- 重置时间戳
    self.mHeartBeatT = os.time()

    -- 发心跳
    LuaSendMsg( global.MsgType.MSG_CS_HEART_BEAT_KEEP, self.mHeartBeatT )
end

function GameWorldController:OnGameLeaveWorld()
    -- issue, can not leaveWorld in handle msg
    self._leaveWorld = true
end

function GameWorldController:update(delta)
    local dI = math.floor( delta * 1000.0 )
    self.mElapsedT = self.mElapsedT + dI
    self.mLoopCount = self.mLoopCount + 1

    if self._restart then
        self._restart = false
        global.L_NativeBridgeManager:GN_accountLogout()
        global.Facade:sendNotification(global.NoticeTable.RestartGame)
        return
    end

    if self._leaveWorld then
        self._leaveWorld = false
        global.Facade:sendNotification(global.NoticeTable.LeaveWorld)
        return
    end

    -----------------------------------------------------------------------------
    -- 网络收发消息包
    global.gameEnvironment:GetNetClient():Tick()


    -----------------------------------------------------------------------------
    -- drop item
    global.dropItemController:Tick( delta )


    -----------------------------------------------------------------------------
    -- 技能CD
    global.CalcSkillCDMediator:Tick( delta )
    -- 连击技能CD
    global.CalcComboSkillCDMediator:Tick(delta)

    -- 角色 
    global.actorManager:Tick( delta )

    -- 场景 
    global.sceneManager:Tick(delta)
    
    -- 
    global.gameMapController:Tick( delta )

    -- actor refresh
    global.actorRefreshController:Tick(delta)

    -----------------------------------------------------------------------------
    -- 技能 
    global.skillManager:Tick( delta )

    -- buff
    global.BuffManager:Tick(delta)

    -- effect
    global.ActorEffectManager:Tick(delta)
    
    -----------------------------------------------------------------------------
    -- sequence animation manager 
    global.FrameAnimManager:Tick( delta )

    -- downloader
    global.ResDownloader:Tick( delta )

    -- heartBeat
    self:CheckHeartBeat()
end

return GameWorldController
