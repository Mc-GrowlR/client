local InputMoveCommand = class('InputMoveCommand', framework.SimpleCommand)

function InputMoveCommand:ctor()
end

function InputMoveCommand:execute(note)
    local data = note:getBody()

    local facade        = global.Facade
    local inputProxy    = facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local mapProxy      = facade:retrieveProxy(global.ProxyTable.Map)
    local autoProxy     = facade:retrieveProxy(global.ProxyTable.Auto)


    local mainPlayer    = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return nil
    end

    if mainPlayer:IsHoreseCopilot() then
        return nil
    end

    -- 
    inputProxy:ClearMove()
    
    -- clear mouse input move
    inputProxy:ClearMouseTouch()

    -- 
    local moveType      = data.type and data.type or global.MMO.INPUT_MOVE_TYPE_OTHER
    local destPos       = cc.p(data.x, data.y)

    -- 摇杆/点地板
    if moveType == global.MMO.INPUT_MOVE_TYPE_JOYSTICK or moveType == global.MMO.INPUT_MOVE_TYPE_GRID then
        -- find pos
        local moveDir       = data.moveDir
        local moveStep      = data.moveStep

        ----------------------------------------
        -- open door
        local openDoorPos   = cc.p(destPos.x, destPos.y)
        if moveType == global.MMO.INPUT_MOVE_TYPE_JOYSTICK then
            local normal    = inputProxy:DirToNormalizeVec2(data.moveDir)
            local move      = cc.pMul(normal, 1)
            openDoorPos.x   = mainPlayer:GetMapX() + move.x * moveStep
            openDoorPos.y   = mainPlayer:GetMapY() + move.y * moveStep
        end
        if global.sceneManager:canOpenDoor(openDoorPos.x, openDoorPos.y) then
            local mapProxy  = facade:retrieveProxy(global.ProxyTable.Map)
            mapProxy:RequestOpenDoor(openDoorPos.x, openDoorPos.y)
            return nil
        end

        ----------------------------------------
        -- calc dest pos
        local srcPos        = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
        destPos             = global.PathFindController:FindDestPosJoystick(srcPos, moveDir, moveStep)
    end
    
    -- 
    if nil == destPos then
        return nil
    end

    -- fix move pos by range
    local posX = destPos.x
    local posY = destPos.y
    if data.range and data.range > 0 then
        posX, posY = inputProxy:FindBestMovePos(mainPlayer:GetMapX(), mainPlayer:GetMapY(), data.x, data.y,data.range)
    end

    -- check move pos enable
    if mainPlayer:GetMapX() == posX and mainPlayer:GetMapY() == posY then
        if autoProxy:IsAutoMoveState() then
            facade:sendNotification(global.NoticeTable.AutoMoveEnd)
        end
        return nil
    end
    
    -- check mapID
    local mapID = data.mapID
    if not mapID then
        local mapProxy = facade:retrieveProxy(global.ProxyTable.Map)
        mapID = mapProxy:GetMapID()
    end
    
    -- push last move pos
    local targetID = data.targetID
    local skillID  = data.skillID
    inputProxy:SetCurrMoveType(moveType)
    inputProxy:SetCurrMovePos({mapID = mapID, x = posX, y = posY, targetID = targetID, skillID = skillID})
    
    -- path find
    local moveTo            = inputProxy:GetCurrMovePos()
    if moveType == global.MMO.INPUT_MOVE_TYPE_LAUNCH then
        local findPoints    = global.PathFindController:FindPathAStarLimits(cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY()), cc.p(moveTo.x, moveTo.y))
        inputProxy:SetPathFindPoints(findPoints)
    else
        local findPoints    = global.PathFindController:FindPathAStar(cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY()), cc.p(moveTo.x, moveTo.y))
        inputProxy:SetPathFindPoints(findPoints)
    end

    -- can't find path 
    local pathPoints = inputProxy:GetCurrPathPoint()
    if pathPoints == 0 then
        -- record move blocked
        inputProxy:SetIsMoveBlocked(true)

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
                -- 忽略当前目标
                local targetID = inputProxy:GetTargetID()
                local target = nil
                if targetID then
                    target = global.actorManager:GetActor(targetID)
                    if target then
                        if not target:IsPauseIgnored() and not target:IsIngored() then
                            if autoProxy:IsAutoFightState() and global.PathFindController:checkActorLimitObstacle(cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY()), cc.p(target:GetMapX(), target:GetMapY())) then
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

        -- auto move end
        if autoProxy:IsAutoMoveState() then
            facade:sendNotification(global.NoticeTable.AutoMoveEnd)
        end
        return nil
    end

    local targetID = inputProxy:GetTargetID()
    if targetID then
        local target = global.actorManager:GetActor(targetID)
        if target and target:IsPauseIgnored() then
            target:PauseIgnoredActor()
        end
    end
end

return InputMoveCommand
