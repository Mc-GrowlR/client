local BehaviorController = class('BehaviorController', framework.Mediator)
BehaviorController.NAME = "BehaviorController"

local BehaviorSelector      = require("bt/BehaviorSelector")

local facade                = global.Facade

function BehaviorController:ctor()
    BehaviorController.super.ctor(self, self.NAME)
end

function BehaviorController:destory()
    if BehaviorController.instance then
        facade:removeMediator( BehaviorController.NAME )
        BehaviorController.instance = nil
    end
end

function BehaviorController:Inst()
    if not BehaviorController.instance then
        BehaviorController.instance = BehaviorController.new()
        facade:registerMediator(BehaviorController.instance)
    end

    return BehaviorController.instance
end

function BehaviorController:InitOnEnterWorld()
    global.gamePlayerController:RegisterLuaInputHandler(handler(self, self.ProcessInput))
    self._selector = BehaviorSelector.new()
end

function BehaviorController:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.GameWorldInitComplete,
    }
end

function BehaviorController:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.GameWorldInitComplete == noticeID then
        self:OnGameWorldInitComplete(data)
    end
end

function BehaviorController:ProcessInput(player, actCompleted)
    if self._selector then
        self._selector:process(player, actCompleted)
    end
end

function BehaviorController:OnGameWorldInitComplete(data)
    self._selector:Init()
end

return BehaviorController
