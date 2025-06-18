local BaseUIMediator = requireMediator("BaseUIMediator")
local GuideTaskMediator = class("GuideTaskMediator", BaseUIMediator)
GuideTaskMediator.NAME = "GuideTaskMediator"

local ssplit = string.split

local GuideTask = requireMediator("guide_layer/GuideTask")

function GuideTaskMediator:ctor()
    GuideTaskMediator.super.ctor(self)

    self._task = nil

    self:Init()
end

function GuideTaskMediator:Init()
end

function GuideTaskMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.MainPlayerDie,
        noticeTable.DRotationChanged,
        noticeTable.GuideStart,
        noticeTable.GuideStop,
        noticeTable.GuideEventBegan,
        noticeTable.GuideEventEnded,
    }
end

function GuideTaskMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local id = notification:getName()
    local data = notification:getBody()

    if noticeTable.MainPlayerDie == id then
        self:OnMainPlayerDie(data)

    elseif noticeTable.GuideStart == id then
        self:OnGuideStart(data)

    elseif noticeTable.GuideStop == id then
        self:OnGuideStop(data)

    elseif noticeTable.DRotationChanged == id then
        self:OnGuideStop(data)

    elseif noticeTable.GuideEventBegan == id then
        self:OnGuideEventBegan(data)

    elseif noticeTable.GuideEventEnded == id then
        self:OnGuideEventEnded(data)
    end
    
end

function GuideTaskMediator:OnMainInit()
end

function GuideTaskMediator:OnMainPlayerDie()
    self:OnGuideStop()
end

function GuideTaskMediator:OnGuideStart(data)
    -- dump("OnGuideStart___")
    -- 审核服屏蔽
    local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    if envProxy:IsReviewServer() then
        return false
    end
    -- dump("OnGuideStart___1")
    -- 主玩家死亡
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return false
    end
        -- dump("OnGuideStart___2")
    if mainPlayer:IsDie() then
        return false
    end

    -- new task
    if self._task then
        self._task:Exit()
        self._task = nil    
    end
    self._task = GuideTask.new(data)--GuideTask.new(data, config)
    -- dump(self._task,"self._task____")
    self._task:Enter()
end

function GuideTaskMediator:OnGuideStop()
    if not self._task then
        return nil
    end
    
    -- 
    -- self._delayNode:stopAllActions()
    -- self._startCallback = nil

    -- -- exit & end
    -- self._task:ExitTransition()
    self._task:Exit()
    -- self._task:OnStop()
    self._task = nil

    -- local proxy = global.Facade:retrieveProxy(global.ProxyTable.GuideProxy)
    -- proxy:SetTask(self._task)
end

function GuideTaskMediator:OnGuideEventBegan(data)
    if not self._task then
        return nil
    end
    self._task:onEventBegan(data)
end

function GuideTaskMediator:OnGuideEventEnded(data)
    if not self._task then
        return nil
    end
    self._task:OnGuideEventEnded(data)
end

return GuideTaskMediator
