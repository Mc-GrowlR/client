local Behavior = require("bt/Behavior")
local BehaviorSelector  = class("BehaviorSelector", Behavior)

local BehaviorTurn      = require("bt/BehaviorTurn")
local BehaviorMove      = require("bt/BehaviorMove")
local BehaviorDig       = require("bt/BehaviorDig")
local BehaviorCorpse    = require("bt/BehaviorCorpse")
local BehaviorMining    = require("bt/BehaviorMining")
local BehaviorLaunch    = require("bt/BehaviorLaunch")
local BehaviorKLaunch   = require("bt/BehaviorKLaunch")

local proxyUtils        = requireProxy("proxyUtils")
local skillUtils        = requireProxy("skillUtils")

local facade            = global.Facade
local BehaviorConfig    = global.BehaviorConfig

local AutoCtlName       = "AutoController"

function BehaviorSelector:ctor(data)
    BehaviorSelector.super.ctor(self, data)
    self._behaviors = {}
end

function BehaviorSelector:Init()
    table.insert(self._behaviors, BehaviorKLaunch.new())
    table.insert(self._behaviors, BehaviorTurn.new())
    table.insert(self._behaviors, BehaviorMove.new())
    table.insert(self._behaviors, BehaviorDig.new())
    table.insert(self._behaviors, BehaviorCorpse.new())
    table.insert(self._behaviors, BehaviorMining.new())
    table.insert(self._behaviors, BehaviorLaunch.new())

    self._autoCtl = facade:retrieveMediator(AutoCtlName)
end

function BehaviorSelector:process(player, actCompleted)
    -- 摆摊
    if false == CheckCanDoSomething(true) then
        if actCompleted ~= global.MMO.ACTION_IDLE then
            facade:sendNotification(global.NoticeTable.ActorEnterIdleAction, {actor = player})
        end
        return nil
    end

    -- 野蛮等待
    if actCompleted == global.MMO.ACTION_DASH_WAITING then
        facade:sendNotification(global.NoticeTable.ActorEnterIdleAction, {actor = player})
        return nil
    end

    -- 野蛮失败
    if actCompleted == global.MMO.ACTION_DASH_FAIL then
        facade:sendNotification(global.NoticeTable.ActorEnterIdleAction, {actor = player})
        return nil
    end
    
    -- behavior
    local status        = BehaviorConfig.BTSTATUS_Failure
    local currBehavior  = nil
    for _, behavior in ipairs(self._behaviors) do
        status = behavior:update(player, actCompleted)

        if status == BehaviorConfig.BTSTATUS_Success or status == BehaviorConfig.BTSTATUS_Running then
            currBehavior = behavior
            break
        end
    end

    -- 这儿做个处理，释放技能可能需要走位，不等下一帧，当前帧生效
    if currBehavior and currBehavior:getType() == BehaviorConfig.BehaviorType.BehaviorLaunch then
        local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        local pathPoints = inputProxy:GetCurrPathPoint()
        if pathPoints > 0 and inputProxy:GetLaunchSkillID() ~= nil then
            local behavior = self._behaviors[3]
            status = behavior:update(player, actCompleted)

            if status == BehaviorConfig.BTSTATUS_Success or status == BehaviorConfig.BTSTATUS_Running then
                currBehavior = behavior
            end
        end
    end

    -- auto
    if status == BehaviorConfig.BTSTATUS_Failure then
        if self._autoCtl then
            self._autoCtl:stateBegin(player, actCompleted)
        end
    end

    -- 自动战斗选择后，会产生新的行为，再遍历一次
    if status == BehaviorConfig.BTSTATUS_Failure then
        for _, behavior in ipairs(self._behaviors) do
            status      = behavior:update(player, actCompleted)

            if status == BehaviorConfig.BTSTATUS_Success or status == BehaviorConfig.BTSTATUS_Running then
                currBehavior = behavior
                break
            end
        end
    end

    -- 这儿做个处理，释放技能可能需要走位，不等下一帧，当前帧生效
    if currBehavior and currBehavior:getType() == BehaviorConfig.BehaviorType.BehaviorLaunch then
        local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        local pathPoints = inputProxy:GetCurrPathPoint()
        if pathPoints > 0 and inputProxy:GetLaunchSkillID() ~= nil then
            local behavior = self._behaviors[3]
            status = behavior:update(player, actCompleted)

            if status == BehaviorConfig.BTSTATUS_Success or status == BehaviorConfig.BTSTATUS_Running then
                currBehavior = behavior
            end
        end
    end

    -- idle
    if status == BehaviorConfig.BTSTATUS_Failure then
        if actCompleted ~= global.MMO.ACTION_IDLE then
            facade:sendNotification(global.NoticeTable.ActorEnterIdleAction, {actor = player})
        end
    end
end

return BehaviorSelector
