local actorHUDHPManager = class("actorHUDHPManager")
local optionsUtils = requireProxy("optionsUtils")
local Queue = requireUtil("queue")

function actorHUDHPManager:ctor()
    self._Queue = Queue.new()
    self._Cache = {}
end

function actorHUDHPManager:destory()
    if actorHUDHPManager.instance then
        actorHUDHPManager.instance = nil
    end
end

function actorHUDHPManager:Inst()
    if not actorHUDHPManager.instance then
        actorHUDHPManager.instance = actorHUDHPManager.new()
    end
    return actorHUDHPManager.instance
end

function actorHUDHPManager:Update(actor)
    if not actor then
        return false
    end
    local actorID = actor:GetID()

    if self._Cache[actorID] then
        return false
    end

    self._Cache[actorID] = actor

    self._Queue:push(actorID)


    if self._timerID then
        return false
    end

    local function callback()
        self:Tick()
    end
    self._timerID = Schedule(callback, 0.01)
    callback()
end

function actorHUDHPManager:UpdateNow(actor)
    if not actor then
        return false
    end
    
    self._Cache[actor:GetID()] = nil
    global.Facade:sendNotification(global.NoticeTable.RefreshHUDHP, actor)
    optionsUtils:refreshHUDHMpLabelVisible(actor)
end

function actorHUDHPManager:Tick()
    if self._Queue:size() > 0 then
        self:UpdateNow(self._Cache[self._Queue:pop()])
    else
        self:Cleanup()
    end
end

function actorHUDHPManager:DelActor(actor, isUpdate)
    if isUpdate then
        self:UpdateNow(actor)
    else
        self._Cache[actor:GetID()] = nil
    end
end

function actorHUDHPManager:Cleanup()
    if self._timerID then
        UnSchedule(self._timerID)
        self._timerID = nil
    end
    self._Cache = {}
    self._Queue:clear()
end

return actorHUDHPManager
