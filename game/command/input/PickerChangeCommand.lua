local PickerChangeCommand = class('PickerChangeCommand', framework.SimpleCommand)

local proxyUtils = requireProxy("proxyUtils")

local function squLen(x, y)
    return x * x + y * y
end

function PickerChangeCommand:ctor()
end

function PickerChangeCommand:execute(note)
    local pick = note:getBody()
    if nil == pick then
        return
    end
    
    if pick.pickType ~= global.MMO.PICK_ACTOR_NPC then
        -- 有选中范围技能
        local inptuProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        local mainPlayer = global.gamePlayerController:GetMainPlayer()
        if SkillProxy:GetSelectSkill() then
            local skillID = SkillProxy:GetSelectSkill()
            local destPos = {x = pick.xGridPicked, y = pick.yGridPicked}
            global.Facade:sendNotification(global.NoticeTable.UserInputLaunch, {skillID = skillID, destPos = destPos})
            return nil
        end
    else
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        if SkillProxy:GetSelectSkill() then
            SkillProxy:ClearSelectSkill()
        end
    end
    
    
    if pick.pickType == global.MMO.PICK_MAP_GRID then
        self:onPickGrid(pick)
    
    elseif pick.pickType == global.MMO.PICK_ACTOR_PLAYER then
        self:onPickPlayer(pick)
    
    elseif pick.pickType == global.MMO.PICK_ACTOR_MONSTER then
        self:onPickMosnter(pick)
    
    elseif pick.pickType == global.MMO.PICK_ACTOR_NPC then
        self:onPickNpc(pick)
    
    elseif pick.pickType == global.MMO.PICK_ACTOR_COLLECTION then
        self:onPickCollection(pick)
    
    elseif pick.pickType == global.MMO.PICK_ACTOR_CORPSE then
        self:onPickCorpse(pick)
    end
end

function PickerChangeCommand:onPickGrid(pick)
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return
    end

    if pick.touchWay == global.MMO.MOVE_EVENT_TOUCH_AND_MOUSE_L and pick.eventType == cc.Handler.EVENT_TOUCH_BEGAN then
        -- scene effect
        global.Facade:sendNotification(global.NoticeTable.MapPickCursorPosChange, pick)
    end

    -- attack target id
    if pick.touchWay == global.MMO.MOVE_EVENT_TOUCH_AND_MOUSE_L then
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        PlayerInputProxy:SetAttackState(false)
        PlayerInputProxy:ClearAttackTargetID()

        --minming
        if PlayerInputProxy:CheckMiningAble() then
            local sX = mainPlayer:GetMapX()
            local sY = mainPlayer:GetMapY()
            local dX = pick.xGridPicked
            local dY = pick.yGridPicked
            -- local len = squLen(sX - dX, sY - dY)

            local dir = PlayerInputProxy:Vec2ToDir(cc.pSub(cc.p(dX, dY), cc.p(sX, sY)))
            if dir < global.MMO.ORIENT_U or dir > global.MMO.ORIENT_LU then
                dir = nil
            end
            local dest = cc.p(sX, sY)
            if dir then
                local vec2 = PlayerInputProxy:DirToNormalizeVec2(dir)
                if vec2 and next(vec2) then
                    dest = cc.pAdd(dest, vec2)
                end
            end

            local state = false
            if global.sceneManager:GetMapData2DPtr():isObstacle(dest.x, dest.y) ~= 0 or global.userInputController:IsPressedShift() then
                global.Facade:sendNotification(global.NoticeTable.UserInputMining, {dir=dir, dest=dest})
                return
            end
        end

        -- force attack
        if global.userInputController:IsPressedShift() then
            global.Facade:sendNotification(global.NoticeTable.LaunchAttackSkill)
            return nil
        else
            if global.dropItemController:PickMainPlayerPosItem( {mapX = pick.xGridPicked, mapY = pick.yGridPicked} ) then
                return
            end
        end
    end

    -- clear auto data
    local autoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    local allowInput = autoProxy:TryExitAutoFight()
    if allowInput then
        local isInputTurnDir = false

        if pick.touchWay == global.MMO.MOVE_EVENT_MOUSE_R and pick.eventType == cc.Handler.EVENT_TOUCH_BEGAN then
            -- input turn
            local sX = mainPlayer:GetMapX()
            local sY = mainPlayer:GetMapY()
            local dX = pick.xGridPicked
            local dY = pick.yGridPicked
            local len = squLen(sX - dX, sY - dY)
            local range = 2
            if (len <= range) then
                isInputTurnDir = true
            end
        end

        if isInputTurnDir then
            -- input turn
            local PlayerInputProxy  = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
            local direction         = PlayerInputProxy:getCursorWorldDirection()
            PlayerInputProxy:SetMouseTurnDir(direction)
        else
            -- input move
            local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
            PlayerInputProxy:SetMouseTouchPos(cc.p(pick.xGridPicked, pick.yGridPicked))
            PlayerInputProxy:SetMouseTouchWay(pick.touchWay)
        end
    else
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(800001))
    end
end

function PickerChangeCommand:onPickNpc(pick)
    -- attack target id
    if pick.touchWay == global.MMO.MOVE_EVENT_TOUCH_AND_MOUSE_L then
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        PlayerInputProxy:SetAttackState(false)
        PlayerInputProxy:ClearAttackTargetID()
        
        -- force attack
        if global.userInputController:IsPressedShift() then
            global.Facade:sendNotification(global.NoticeTable.LaunchAttackSkill)
            return nil
        end
    end

    -- change target
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    inputProxy:SetTargetID(pick.actorPicked, global.MMO.SELETE_TARGET_TYPE_PICK)
    
    -- click npc
    local npcProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    if npcProxy then
        npcProxy:CheckTalk(pick.actorPicked, false)
    end
end

function PickerChangeCommand:onPickMosnter(pick)
    -- attack target id
    if pick.touchWay == global.MMO.MOVE_EVENT_TOUCH_AND_MOUSE_L and pick.eventType == cc.Handler.EVENT_TOUCH_BEGAN then
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        PlayerInputProxy:SetAttackState(true)
        PlayerInputProxy:SetAttackTargetID(pick.actorPicked)

        -- force attack
        if global.userInputController:IsPressedShift() then
            global.Facade:sendNotification(global.NoticeTable.LaunchAttackSkill)
            return nil
        end
    end
    
    -- change target
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local isChangTarget = pick.actorPicked ~= inputProxy:GetTargetID()
    inputProxy:SetTargetID(pick.actorPicked, global.MMO.SELETE_TARGET_TYPE_PICK)

    if isChangTarget and inputProxy:GetCurrMoveType() == global.MMO.INPUT_MOVE_TYPE_LAUNCH and inputProxy:GetCurrPathPoint() > 0 then
        inputProxy:ClearMove()
    end
end

function PickerChangeCommand:onPickCollection(pick)
    -- attack target id
    if pick.touchWay == global.MMO.MOVE_EVENT_TOUCH_AND_MOUSE_L then
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        PlayerInputProxy:SetAttackState(false)
        
        -- force attack
        if global.userInputController:IsPressedShift() then
            global.Facade:sendNotification(global.NoticeTable.LaunchAttackSkill)
            return nil
        end
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    if pick.actorPicked ~= inputProxy:GetTargetID() then
        -- change target
        inputProxy:SetTargetID(pick.actorPicked, global.MMO.SELETE_TARGET_TYPE_PICK)
    end
    
    global.Facade:sendNotification(global.NoticeTable.AutoFindCollection)
end


function PickerChangeCommand:onPickPlayer(pick)
    -- baitan
    local playerId = pick.actorPicked
    local palyerActor = global.actorManager:GetActor(playerId)
    if palyerActor and palyerActor:IsStallStatus() then
        local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
        StallProxy:RequestItemList(playerId)
        return
    end
    -- attack target id
    if pick.touchWay == global.MMO.MOVE_EVENT_TOUCH_AND_MOUSE_L and pick.eventType == cc.Handler.EVENT_TOUCH_BEGAN then
        -- attack state
        local attackState = true
        local attackTargetID = pick.actorPicked
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        PlayerInputProxy:SetAttackState(attackState)
        PlayerInputProxy:SetAttackTargetID(attackTargetID)
    
        -- force attack
        if global.userInputController:IsPressedShift() then
            global.Facade:sendNotification(global.NoticeTable.LaunchAttackSkill)
            return nil
        end
    end
    
    -- change target
    if palyerActor and not palyerActor:GetValueByKey(global.MMO.HUD_SNEAK) then
        local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        local isChangTarget = pick.actorPicked ~= inputProxy:GetTargetID()
        inputProxy:SetTargetID(pick.actorPicked, global.MMO.SELETE_TARGET_TYPE_PICK)
        
        if isChangTarget and inputProxy:GetCurrMoveType() == global.MMO.INPUT_MOVE_TYPE_LAUNCH and inputProxy:GetCurrPathPoint() > 0 then
            inputProxy:ClearMove()
        end
    end
end

function PickerChangeCommand:onPickCorpse(pick)
    global.Facade:sendNotification(global.NoticeTable.UserInputCorpse, {corpseID = pick.actorPicked})
end

return PickerChangeCommand
