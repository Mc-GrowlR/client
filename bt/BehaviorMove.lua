local Behavior = require("bt/Behavior")
local BehaviorMove = class("BehaviorMove", Behavior)

local facade            = global.Facade
local BehaviorConfig    = global.BehaviorConfig

local function checkAbleToWalk(nextPoint)
    return global.PathFindController:checkAbleToWalk(nextPoint)
end

local function checkOverTarget(nextPoint)
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    
    -- launch only
    local moveType = inputProxy:GetCurrMoveType()
    if moveType ~= global.MMO.INPUT_MOVE_TYPE_LAUNCH then
        return false
    end

    -- can't find target
    local targetID = inputProxy:GetTargetID()
    local target = global.actorManager:GetActor(targetID)
    if not target then
        return false
    end

    if nextPoint.x == target:GetMapX() and nextPoint.y == target:GetMapY() then
        return true
    end

    return false
end

function BehaviorMove:ctor(data)
    BehaviorMove.super.ctor(self, data)
end

function BehaviorMove:getType()
    return BehaviorConfig.BehaviorType.BehaviorMove
end

function BehaviorMove:update(player, actCompleted)
    local player                = global.gamePlayerController:GetMainPlayer()
    local inputProxy            = facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local autoProxy             = facade:retrieveProxy(global.ProxyTable.Auto)

    if inputProxy:IsLaunchDirty() then
        return BehaviorConfig.BTSTATUS_Failure
    end

    if not inputProxy:IsMovePermission() then
        return BehaviorConfig.BTSTATUS_Failure
    end

    if player:IsHoreseCopilot() then
        return BehaviorConfig.BTSTATUS_Failure
    end

    if inputProxy:GetLaunchNoWalkPos() then
        inputProxy:SetLaunchNoWalkPos(nil)
    end

    local isHandMove    = false
    local isRunOne      = false
    -- 点地板
    local touchPos              = inputProxy:GetMouseTouchPos()
    local touchWay              = inputProxy:GetMouseTouchWay()
    if touchPos and touchPos.x ~= 0 and touchPos.y ~= 0 and touchWay and (touchPos.x ~= player:GetMapX() or touchPos.y ~= player:GetMapY()) then
        GUIFunction:ClickMapGroundMoveFunc(touchPos, touchWay)
        if CHECK_SERVER_OPTION(global.MMO.SERVER_RUN_ONE) then
            isRunOne = touchWay == -1
        end
        isHandMove = true
    end

    -- 摇杆
    if not global.isWinPlayMode and not isHandMove then
        GUIFunction:OnGamePadMoveFunc()
        local moveDir, moveStep = SL:GetMetaValue("GAMEPAD_MOVE_PARAM")
        isHandMove = isHandMove or moveDir ~= 0xff
        if CHECK_SERVER_OPTION(global.MMO.SERVER_RUN_ONE) then
            isRunOne = isRunOne or moveStep == 2
        end
    end


    -- move to next point
    local currPathPoint         = inputProxy:GetCurrPathPoint()
    if currPathPoint == 0 then
        if actCompleted == global.MMO.ACTION_WALK or actCompleted == global.MMO.ACTION_RUN or actCompleted == global.MMO.ACTION_RIDE_RUN then
            global.Facade:sendNotification(global.NoticeTable.ActorEnterIdleAction, {actor = player})

            self:onMoveFinished(player, actCompleted)
        end
        return BehaviorConfig.BTSTATUS_Failure
    end

    local pathPoints            = inputProxy:GetPathFindPoints()
    local nextPoint, moveStep   = global.PathFindController:checkNextMovePos(player, pathPoints, currPathPoint)
    if nextPoint then
        -- can launch
        if checkOverTarget(nextPoint) then
            inputProxy:ClearMove()
            global.Facade:sendNotification(global.NoticeTable.ActorEnterIdleAction, {actor = player})
            return BehaviorConfig.BTSTATUS_Failure
        end

        --判断是否在禁锢区
        local sceneImprisonEffectProxy = global.Facade:retrieveProxy(global.ProxyTable.SceneImprisonEffectProxy)
        if sceneImprisonEffectProxy:CheckImprison(nextPoint.x, nextPoint.y) then
            global.Facade:sendNotification(global.NoticeTable.ActorEnterIdleAction, {actor = player})
            return BehaviorConfig.BTSTATUS_Failure
        end 

        if not isHandMove and moveStep == 1 and CHECK_SERVER_OPTION(global.MMO.SERVER_RUN_ONE) then
            isRunOne = true
        end

        -- walk, check next point has player/monster/npc
        if not isRunOne and moveStep == 1 then
            if not checkAbleToWalk(nextPoint) then
                -- record move blocked
                inputProxy:SetIsMoveBlocked(true)


                local moveType  = inputProxy:GetCurrMoveType()
                -- move crowded
                if autoProxy:IsAFKState() then
                    if moveType == global.MMO.INPUT_MOVE_TYPE_FINDITEM then
                        -- 忽略当前拾取物
                        local autoPickItemID = autoProxy:GetPickItemID()
                        if autoPickItemID then
                            local target = global.actorManager:GetActor(autoPickItemID)
                            if target then
                                target:IgnoreActor(true)
                            end
                        end
                        autoProxy:ClearAutoPick()
                        autoProxy:SetPickItemFlag(true) 

                    elseif moveType == global.MMO.INPUT_MOVE_TYPE_LAUNCH then
                        -- 忽略
                        if actCompleted == global.MMO.ACTION_WALK or actCompleted == global.MMO.ACTION_RUN or actCompleted == global.MMO.ACTION_RIDE_RUN then
                        else
                            local targetID = inputProxy:GetTargetID()
                            local target   = nil
                            if targetID then
                                target = global.actorManager:GetActor(targetID)
                                if target then
                                    if not target:IsPauseIgnored() and not target:IsIngored() then
                                        if autoProxy:IsAutoFightState() and global.PathFindController:checkActorLimitObstacle(cc.p(player:GetMapX(), player:GetMapY()), cc.p(target:GetMapX(), target:GetMapY())) then
                                            target:PauseIgnoredActor(true)
                                        else
                                            target:IgnoreActor(true)
                                        end
                                    end
                                end
                            end
                            -- clear launch data
                            if not target or (not target:IsPauseIgnored() and target:IsIngored()) then
                                autoProxy:ClearAutoLock()
                                inputProxy:ClearLaunch()
                                inputProxy:ClearTarget()
                            end
                        end
                    end
                    
                    inputProxy:ClearMove()
                    global.Facade:sendNotification(global.NoticeTable.ActorEnterIdleAction, {actor = player})
                else
                    inputProxy:ClearMove()
                    global.Facade:sendNotification(global.NoticeTable.ActorEnterIdleAction, {actor = player})
                    global.Facade:sendNotification(global.NoticeTable.ClearAllAutoState)
                end

                inputProxy:SetLaunchNoWalkPos(nextPoint)

                return BehaviorConfig.BTSTATUS_Failure
            end
        end

        local targetID = inputProxy:GetTargetID()
        if targetID then
            local target = global.actorManager:GetActor(targetID)
            if target and target:IsPauseIgnored() then
                target:PauseIgnoredActor()
            end
        end

        -- move
        player:SetKeyValue(global.MMO.IS_RUN_ONE, false)
        player:SetMoveTo(nextPoint)
        if moveStep == 3 then
            player:SetAction( global.MMO.ACTION_RIDE_RUN )
        elseif moveStep == 2 then
            player:SetAction( global.MMO.ACTION_RUN )
        else
            local act = global.MMO.ACTION_WALK
            if player:GetValueByKey(global.MMO.ACT_SNEAK) then
                act = global.MMO.ACTION_ASSASSIN_SNEAK
            elseif isRunOne then
                act = global.MMO.ACTION_RUN
                player:SetKeyValue(global.MMO.IS_RUN_ONE, true)
            end
            player:SetAction( act )
        end

        if currPathPoint - moveStep == 0 and not autoProxy:IsAFKState() then
            inputProxy:ClearMove()
        end

        inputProxy:SetCurrPathPoint(currPathPoint - moveStep)
        inputProxy:SetIsMoveBlocked(false)

        return BehaviorConfig.BTSTATUS_Running
    else
        -- move failed
        inputProxy:ClearMove()
        global.Facade:sendNotification(global.NoticeTable.ActorEnterIdleAction, {actor = player})

        -- 
        if not autoProxy:GetAutoTargetInterruptFlag() then
            if autoProxy:IsAutoFightState() or autoProxy:IsAutoMoveState() then
                autoProxy:PauseAutoTarget()
                autoProxy:ResumeAutoTarget()
            end
        end

        return BehaviorConfig.BTSTATUS_Failure
    end
    
    return BehaviorConfig.BTSTATUS_Failure
end

function BehaviorMove:onMoveFinished()
    local autoProxy     = global.Facade:retrieveProxy(global.ProxyTable.Auto)

    -- auto move end
    if autoProxy:IsMoveCompleted() and autoProxy:IsAutoMoveState() then
        facade:sendNotification(global.NoticeTable.AutoMoveEnd)
    end
end

return BehaviorMove