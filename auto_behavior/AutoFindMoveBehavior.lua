local AutoFindBehavior = require("auto_behavior/AutoFindBehavior")
local AutoFindMoveBehavior = class("AutoFindMoveBehavior", AutoFindBehavior)

local proxyUtils = requireProxy("proxyUtils")

function AutoFindMoveBehavior:ctor()
    AutoFindMoveBehavior.super.ctor(self)
end

function AutoFindMoveBehavior:update(player, actCompleted)
    -- body
    -- offline auto 
    if self:checkAimlessMove(player, actCompleted) then
        return true
    end

    return false
end

function AutoFindMoveBehavior:checkAimlessMove(player, actCompleted)
    if actCompleted ~= global.MMO.ACTION_IDLE then
        return false
    end

    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    -- 挂机目标死亡，原地等待
    if autoProxy:GetAFKTargetDeath() then
        return true
    end

    local assistProxy = global.Facade:retrieveProxy(global.ProxyTable.AssistProxy)
    if assistProxy:checkAimlessMove() then
        return true
    end

    return false
end

return AutoFindMoveBehavior
