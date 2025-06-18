local AutoFindBehavior = require("auto_behavior/AutoFindBehavior")
local AutoFindSkillBehavior = class("AutoFindSkillBehavior", AutoFindBehavior)

local skillUtils = requireProxy("skillUtils")
local proxyUtils = requireProxy("proxyUtils")

function AutoFindSkillBehavior:ctor()
    AutoFindSkillBehavior.super.ctor(self)
end

function AutoFindSkillBehavior:update(player, actCompleted)

    if self:checkLaunchFirstSkill() then
        return true
    end

    if self:checkLaunchComboSkill() then
        return true
    end

    if self:checkLaunchAutoSkill() then
        return true
    end

    if self:checkLaunchSimpleSkill() then
        return true
    end

    if self:checkLaunchLockSkill() then
        return true
    end

    if self:checkAutoMining(player) then
        return true
    end

    return false
end

function AutoFindSkillBehavior:checkLaunchFirstSkill()
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    if not inputProxy:GetTargetID() then
        return false
    end

    if inputProxy:GetLaunchSkillID() then
        return false
    end

    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    if not inputProxy:IsAttackState() and not autoProxy:IsAutoLockState() and not autoProxy:IsAFKState() and
        not autoProxy:IsAutoFightState() then
        return false
    end

    local skillID, destPos = skillUtils.findFirstLaunchSkill()
    if not skillID then
        return false
    end

    local actorPickerProxy      = global.Facade:retrieveProxy(global.ProxyTable.ActorPicker)
    local lastMouseInsideActor  = actorPickerProxy:GetLastMouseInsideActor()
    local launchData = {
        skillID = skillID,
        destPos = destPos,
        priority = inputProxy:GetLaunchPriority(),
        launchType = inputProxy:GetLaunchType(),
        targetID = lastMouseInsideActor or inputProxy:GetTargetID()
    }
    global.Facade:sendNotification(global.NoticeTable.InputLaunch, launchData)
    return true
end

function AutoFindSkillBehavior:checkLaunchAutoSkill()
    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    if not autoProxy:IsAFKState() and not autoProxy:IsAutoFightState() then
        return false
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    if inputProxy:GetLaunchSkillID() then
        return false
    end

    local targetID = inputProxy:GetTargetID()
    if not targetID then
        return false
    end

    if not proxyUtils.checkLaunchTargetByID(targetID) then
        inputProxy:ClearTarget()
        return false
    end

    -- 挂机目标死亡，原地等待一段时间
    if autoProxy:GetAFKTargetDeath() then
        return true
    end

    local targetActor = global.actorManager:GetActor(targetID)
    if not targetActor then
        inputProxy:ClearTarget()
        return true
    end

    -- 闪避技能
    local skillID, destPos = skillUtils.findAvoidDangerSkill(targetActor, targetID)

    if skillID then
        autoProxy:ResetLaunchAvoidStamp()
    else
        -- 自动释放技能
        skillID, destPos = skillUtils.findAutoLaunchSkill(targetActor, targetID)
    end

    if skillID then
        local launchData = {
            skillID = skillID,
            destPos = destPos,
            priority = global.MMO.LAUNCH_PRIORITY_SYSTEM,
            launchType = global.MMO.LAUNCH_TYPE_AUTO,
            targetID = targetID
        }
        global.Facade:sendNotification(global.NoticeTable.InputLaunch, launchData)
        return true
    end

    -- 闪避走位
    destPos = skillUtils.findAvoidDangerPos()
    if destPos then
        local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
        local mapID = mapProxy:GetMapID()
        local movePos = {
            mapID = mapID,
            x = destPos.x,
            y = destPos.y,
            type = global.MMO.INPUT_MOVE_TYPE_AUTOMOVE
        }
        global.Facade:sendNotification(global.NoticeTable.InputMove, movePos)
        return true
    end
    return false
end

function AutoFindSkillBehavior:checkLaunchComboSkill()
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    if not inputProxy:GetTargetID() then
        return false
    end

    if inputProxy:GetLaunchSkillID() then
        return false
    end

    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    local isAttackState = global.isWinPlayMode and inputProxy:IsAttackState() or false
    if not isAttackState and not autoProxy:IsAutoLockState() and not autoProxy:IsAFKState() and
        not autoProxy:IsAutoFightState() then
        return false
    end

    local skillID, destPos, isAuto = skillUtils.findComboLaunchSkill()
    if not skillID then
        return false
    end

    local launchData = {
        skillID = skillID,
        destPos = destPos,
        priority = global.MMO.LAUNCH_PRIORITY_SYSTEM,
        launchType = isAuto and global.MMO.LAUNCH_TYPE_AUTO or global.MMO.LAUNCH_TYPE_USER,
        targetID = inputProxy:GetTargetID()
    }
    global.Facade:sendNotification(global.NoticeTable.InputLaunch, launchData)
    return true
end

function AutoFindSkillBehavior:checkLaunchSimpleSkill()
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    if inputProxy:GetLaunchSkillID() then
        return false
    end

    local targetID = inputProxy:GetTargetID()
    if not targetID then
        return false
    end

    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    if not autoProxy:IsAutoLockState() then
        return false
    end

    if not proxyUtils.checkLaunchTargetByID(targetID) then
        inputProxy:ClearTarget()
        return false
    end

    local targetActor = global.actorManager:GetActor(targetID)
    if not targetActor then
        inputProxy:ClearTarget()
        return false
    end

    if CHECK_SETTING(global.MMO.SETTING_IDX_ALWAYS_ATTACK) ~= 1 then
        return false
    end

    local skillID, destPos = skillUtils.findSimpleLaunchSkill()
    if skillID then
        local launchData = {
            skillID = skillID,
            destPos = destPos,
            priority = global.MMO.LAUNCH_PRIORITY_SYSTEM,
            launchType = global.MMO.LAUNCH_TYPE_LOCK,
            targetID = targetID
        }
        global.Facade:sendNotification(global.NoticeTable.InputLaunch, launchData)
        return true
    end

    return false
end

function AutoFindSkillBehavior:checkLaunchLockSkill()
    -- shift锁定
    if not global.isWinPlayMode then
        return false
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    -- 不在锁定攻击状态
    if not inputProxy:IsAttackState() then
        return false
    end

    local targetID = inputProxy:GetAttackTargetID()
    if not targetID then
        return false
    end

    local targetActor = global.actorManager:GetActor(targetID)
    if not targetActor then
        inputProxy:ClearAttackTargetID()
        return false
    end

    local optionAble = CHECK_SETTING(global.MMO.SETTING_IDX_NOT_NEED_SHIFT) == 1
    local shiftAble = global.userInputController:IsPressedShift()

    if (targetActor:IsPlayer() and (optionAble or shiftAble)) or targetActor:IsMonster() then
        -- 骑马检测
        local HorseProxy = global.Facade:retrieveProxy(global.ProxyTable.HorseProxy)
        if not HorseProxy:IsLaunch(global.MMO.SKILL_INDEX_BASIC) then
            if not HorseProxy:RequestHorseDown() then
                inputProxy:SetAttackState(false)
            end
            return false
        end

        local skillID, destPos = skillUtils.findLockLaunchSkill()
        if skillID then
            local launchData = {
                skillID = skillID,
                destPos = destPos,
                priority = global.MMO.LAUNCH_PRIORITY_SYSTEM,
                launchType = global.MMO.LAUNCH_TYPE_LOCK,
                targetID = targetID
            }
            global.Facade:sendNotification(global.NoticeTable.InputLaunch, launchData)
        end
        return true
    end
    return false
end

function AutoFindSkillBehavior:checkAutoMining()
    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    if autoProxy:IsAutoFightState() then
        return false
    end

    local autoMiningDir, autoMiningDst = autoProxy:GetAutoMining()
    if not autoMiningDir or not autoMiningDst then
        return false
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    if not inputProxy:CheckMiningAble() then
        autoProxy:ClearAutoMining()
        return false
    end

    local miningData = {
        dir = autoMiningDir,
        dest = autoMiningDst
    }
    global.Facade:sendNotification(global.NoticeTable.InputMining, miningData)

    return true
end

return AutoFindSkillBehavior
