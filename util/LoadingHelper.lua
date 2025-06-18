local LoadingHelper = class("LoadingHelper")
local Queue            = requireUtil( "queue" )

function LoadingHelper:ctor( interval )
    self._timerID       = nil
    self._timerInterval = interval or 0
    self._checkFinish   = true
    self._taskQueue     = Queue.new()
    self._taskCount     = 0

    self._firstRun      = true
    self._forEnterWorld = false
    self._isCompleted   = false
    self._extraRef      = 0

    self._lastParam     = nil     -- for skip load failed
end

function LoadingHelper:CheckFinishEnable( enable )
    self._checkFinish = enable
end

function LoadingHelper:setForEnterWorldLoading( value )
    self._forEnterWorld = value
end

function LoadingHelper:AddLoadingTask( loadingVec, callback, loadingUnit, step )
    local task       = {}
    task.loadingVec  = loadingVec
    task.callback    = callback
    task.loadingUnit = loadingUnit
    task.size        = #loadingVec
    task.index       = 1
    task.step        = step or 5

    self._taskQueue:push( task )
    self._taskCount = self._taskCount + task.size

    if not self._timerID then
        self:TimerBegan()
    end
end

function LoadingHelper:Tick()
    if self._taskQueue:empty() then   -- loading finish
        if self._checkFinish then
        self:Finish()
        end

        return nil
    end

    local task = self._taskQueue:front()
    local step = task.step or 3
    if self._firstRun then        -- avoid black
        step = 1
        self._firstRun = false
    end


    for i = 1, step do
        if not self:run( task ) then
        break
        end
    end
end


function LoadingHelper:run( task )
    if task.index > task.size then
        return false
    end


    local value     = task.loadingVec[task.index]
    self._taskCount = self._taskCount - 1
    task.index      = task.index + 1
    if task.callback and value ~= self._lastParam then
        -- loading
        task.callback( value )
    end
    
    self._lastParam = value


    -- loading progress
    if self._forEnterWorld then
        EnterWorldLoadingProgress( task.loadingUnit )
    end

    if task.index > task.size then  -- loading next
        self._taskQueue:pop()

        return false
    end

    return true 
end

function LoadingHelper:TimerBegan()
    if not self._timerID then
        local interval = self._timerInterval or 0
        self._timerID = Schedule( handler( self, self.Tick ), interval )
    end
end

function LoadingHelper:TimerEnded()
    if self._timerID then
        UnSchedule( self._timerID )

        self._timerID = nil
        self._taskQueue:clear()
    end
end

function LoadingHelper:Finish()
    self:TimerEnded()

    self._isCompleted = true


    if self._extraRef <= 0 then    -- extra task is completed
        self:Completed()
    end
end

function LoadingHelper:Completed()
    if self._forEnterWorld then
        global.LoadingHelper = nil      -- clear self

        global.Facade:sendNotification( global.NoticeTable.LoadingCompleted )
    end
end

function LoadingHelper:AddExtraRef()
    self._extraRef = self._extraRef + 1
end

function LoadingHelper:ReleaseExtraRef()
    self._extraRef = self._extraRef - 1

    if 0 == self._extraRef and self._isCompleted then
        self:Completed()
    end
end

return LoadingHelper

