local AutoFindBehavior = require("auto_behavior/AutoFindBehavior")
local AutoFindActorBehavior = class("AutoFindActorBehavior", AutoFindBehavior)

local proxyUtils = requireProxy("proxyUtils")

function AutoFindActorBehavior:ctor()
    AutoFindActorBehavior.super.ctor(self)
end

function AutoFindActorBehavior:update(player, actCompleted)
    -- body
    if self:checkAutoPick() then
        return true
    end

    if self:checkAutoFindDropItem() then
        return true
    end

    if self:checkAutoFindTarget(player, actCompleted) then
        return true
    end

    return false
end

-- 检测拾取
function AutoFindActorBehavior:isCanPick()
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    if not inputProxy:IsMoving() then
        if autoProxy:GetPickItemID() then
            autoProxy:CheckPickTimeout()
            return true
        end
    end

    if nil == autoProxy:GetPickItemID() then
        global.Facade:sendNotification(global.NoticeTable.AutoFindDropItem)
    end

    if -1 == global.PathFindController:CheckNextMovePosAble() then
        autoProxy:SetPickItemID(nil)
        return false
    end

    if autoProxy:GetPickItemID() then
        return true
    end
    return false
end

-- 是否在自动拾取ing
function AutoFindActorBehavior:checkAutoPick()
    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    if not autoProxy:IsPickState() then
        return false
    end
    return self:isCanPick()
end

-- 查找掉落物
function AutoFindActorBehavior:checkAutoFindDropItem()
    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    if not autoProxy:IsAFKState() and not autoProxy:IsAutoFightState() then
        return false
    end

    if not autoProxy:IsCanAutoPick() then
        return false
    end

    -- 内挂 范围内是否有足够怪物
    if proxyUtils:checkIsEnoughMonster() then
        return false
    end

    -- 小精灵 如果是一个个拾取模式  需要放弃去拾取
    if proxyUtils:checkIsPlayerAbandonPickup() then
        return false
    end

    return self:isCanPick()
end

function AutoFindActorBehavior:checkAutoFindTarget(player, actCompleted)
    if actCompleted ~= global.MMO.ACTION_IDLE then
        return false
    end

    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    if not autoProxy:IsAFKState() and not autoProxy:IsAutoFightState() then
        return false
    end

    if autoProxy:GetAutoTargetInterruptFlag() then
        return false
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    if inputProxy:GetTargetID() then
        return false
    end

    -- 1.find current target
    local needTerminate = false
    local targetType = autoProxy:GetTargetType()
    if global.MMO.ACTOR_NPC == targetType then
        global.Facade:sendNotification(global.NoticeTable.AutoFindNPC)
        if inputProxy:GetTargetID() then
            needTerminate = true
        end

    elseif global.MMO.ACTOR_MONSTER == targetType or global.MMO.ACTOR_PLAYER == targetType or attackF1 then
        global.Facade:sendNotification(global.NoticeTable.AutoFindPlayer)

    elseif global.MMO.ACTOR_COLLECTION == targetType then
        global.Facade:sendNotification(global.NoticeTable.AutoFindCollection)
        if inputProxy:GetTargetID() then
            needTerminate = true
        end

    end

    return needTerminate
end

return AutoFindActorBehavior
