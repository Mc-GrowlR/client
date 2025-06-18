local DebugMediator     = requireMediator( "DebugMediator" )
local FrameRateMediator = class('FrameRateMediator', DebugMediator)
FrameRateMediator.NAME  = "FrameRateMediator"

local TIMER_INTERVAL    = 1      -- timer 回调间隔 in second
local SAMPLE_COUNT      = 12     -- 采样次数
local LOW_FRAME_RATE    = 25     -- 低帧率
local SKIP_TIME         = 10

function FrameRateMediator:ctor()
    self._enable               = true

    self._step                 = nil
    self._frames               = nil

    self._lastLowFrameTipsTime = nil

    self._viewComponent        = false

    self._skipElapsed          = 0

    self._skipFrameRate        = false

    FrameRateMediator.super.ctor( self, self.NAME )
end

function FrameRateMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.PlayerPropertyInited,
        noticeTable.Layer_FrameRateClose,
    }
end

function FrameRateMediator:handleNotification(notification)
    local noticeID = notification:getName()
    local notices  = global.NoticeTable
    local data     = notification:getBody()


    if notices.PlayerPropertyInited == noticeID then
        self:CheckOut()
    elseif notices.Layer_FrameRateClose == noticeID then
        self:closeLayer( data )

    end
end

function FrameRateMediator:Tick( delta )
    self._skipElapsed = self._skipElapsed + delta
    if global.Director and self._skipElapsed > SKIP_TIME then
        local frame = 1 / global.Director:getSecondsPerFrame()
        if frame <= 1 then
            releasePrint( "!!!!!!! frame rate <= 1")
        end
        if frame > 1 then
            self._frames = self._frames + frame
            self._step   = self._step + 1

            if self._step >= SAMPLE_COUNT then
                local aveRate = self._frames / SAMPLE_COUNT
                local rateModel = aveRate < LOW_FRAME_RATE and global.MMO.FRAME_RATE_TYPE_LOW or global.MMO.FRAME_RATE_TYPE_HIGH
                self:setRateModel( rateModel )

                self:resetSample()
            end
        end
    end
end

function FrameRateMediator:TimerBegan()
    self:TimerEnded()

    if not self._timerID then
        local function callback( delta )
            self:Tick( delta )
        end

        self:resetSample()
        self._timerID = Schedule( callback, TIMER_INTERVAL )
    end
end

function FrameRateMediator:TimerEnded()
    if self._timerID then
        UnSchedule( self._timerID )
        self._timerID = nil
    end
end

function FrameRateMediator:CheckOut()
	-- 审核服屏蔽低帧率
	local envProxy = global.Facade:retrieveProxy( global.ProxyTable.GameEnvironment )
    self._enable = not envProxy:IsReviewServer()

    --云手机不检测
    if global.L_GameEnvManager:GetEnvDataByKey("isCloudLogin") then
        return
    end

    local isClose = SL:GetMetaValue("GAME_DATA","closeHighRateTips") and SL:GetMetaValue("GAME_DATA","closeHighRateTips") == 1
    if self._enable and not isClose then
        self:TimerBegan()
    end
end

function FrameRateMediator:resetSample()
    self._step        = 0
    self._frames      = 0
    self._skipElapsed = 0
end

function FrameRateMediator:setEnable( enable )
    self._enable = enable
end

function FrameRateMediator:setRateModel( model )
    if self._rateModel ~= model then
        if model == global.MMO.FRAME_RATE_TYPE_LOW then
            local currTime = GetServerTime()
            if not self._lastLowFrameTipsTime or currTime - self._lastLowFrameTipsTime >= SL:GetMetaValue("GAME_DATA","FrameRateInterval") then
                self:openLayer()
            end
        end
    end
end

function FrameRateMediator:openLayer()
    if global.isDebugMode or global.isGMMode then
        return false
    end

    if self._skipFrameRate then
        return false
    end

    if not self._viewComponent and CHECK_SETTING(global.MMO.SETTING_IDX_FRAME_RATE_TYPE_HIGH) == 1 then
        -- stop timer
        self:TimerEnded()

        local function endCallback(event, data)
            if event == 1 then
                self._skipFrameRate = data and data.checkBoxState
                global.Facade:sendNotification( global.NoticeTable.Layer_FrameRateClose, true ) 
            else
                global.Facade:sendNotification( global.NoticeTable.Layer_FrameRateClose, false ) 
            end
            self._viewComponent = false
        end

        local data = {}
        data.str = GET_STRING(30103300)
        data.callback = endCallback
        data.btnDesc = {GET_STRING(30103301), GET_STRING(30103302)}
        data.btnType = 2
        data.hideCloseBtn = true
        data.checkBoxState = false
        data.checkBoxStr = GET_STRING(30103303)
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        self._viewComponent = true
    end
end

function FrameRateMediator:closeLayer( value )
    -- clear timer
    self:TimerEnded()

    self._viewComponent = false

    -- record last tips time
    self._lastLowFrameTipsTime = GetServerTime()

    if value then
        self:setLowModel()
    else
        self:CheckOut()
    end
end

function FrameRateMediator:setLowModel()
    self._rateModel = global.MMO.FRAME_RATE_TYPE_LOW
    self:setEnable( false )

    CHANGE_SETTING( global.MMO.SETTING_IDX_FRAME_RATE_TYPE_HIGH, {0} )
end

function FrameRateMediator.OnUnloaded()
  global.Facade:sendNotification( global.NoticeTable.Layer_FrameRateClose, true )
  global.Facade:removeMediator( FrameRateMediator.NAME )

  FrameRateMediator.super.OnUnloaded()
end

function FrameRateMediator.Onloaded()
  local mediator = FrameRateMediator.new()
  global.Facade:registerMediator( mediator )

  FrameRateMediator.super.Onloaded()
end

return FrameRateMediator