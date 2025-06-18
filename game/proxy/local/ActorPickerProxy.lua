local DebugProxy = requireProxy("DebugProxy")
local ActorPickerProxy = class("ActorPickerProxy", DebugProxy)
ActorPickerProxy.NAME = global.ProxyTable.ActorPicker


function ActorPickerProxy:ctor()
    ActorPickerProxy.super.ctor(self)
    
    self.pickable               = {}
    self.pickable.pickType      = global.MMO.PICK_NONE
    self.pickable.actorPicked   = 0
    self.pickable.xGridPicked   = 0
    self.pickable.yGridPicked   = 0
    self.pickable.touchWay      = 0

    self.lastMouseInsideActor   = nil
    self._lastMouseActorIsDropItem = false

    self.mouseMovePos           = nil
    self.mouseMoveAble          = true
    self._touchActorID          = nil
    self._lastTouchActID        = nil
end

function ActorPickerProxy:Cleanup()
    self.pickable.pickType      = global.MMO.PICK_NONE
    self.pickable.actorPicked   = 0
    self.pickable.xGridPicked   = 0
    self.pickable.yGridPicked   = 0
    self.pickable.touchWay      = 0
end

function ActorPickerProxy:Assign(pickable)
    if pickable then
        self.pickable = pickable
        global.Facade:sendNotification(global.NoticeTable.PickerChange, self.pickable)
    end
end

function ActorPickerProxy:GetPickable()
    return self.pickable
end

function ActorPickerProxy:TouchWorldEvent(touchPos, touchWay, eventType)
    -- convert touch to world
    local touchPosInWorld = Screen2World(touchPos)

    -- pick
    local pickable     = {}
    pickable.touchWay  = touchWay
    pickable.eventType = eventType


    --按了守护按钮 英雄去守护
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    if touchWay == global.MMO.MOVE_EVENT_TOUCH_AND_MOUSE_L and eventType == cc.Handler.EVENT_TOUCH_BEGAN and HeroPropertyProxy:HeroIsLogin() and HeroPropertyProxy:getGuardBtnState() then
        local MapPos = cc.p(global.sceneManager:WorldPos2MapPos(touchPosInWorld))
        HeroPropertyProxy:RequestTargetXY(MapPos.x, MapPos.y)
        HeroPropertyProxy:setGuardBtnState(false)
        return
    end
    -- ctrl + 右键 查看
    if touchWay == global.MMO.MOVE_EVENT_MOUSE_R and eventType == cc.Handler.EVENT_TOUCH_BEGAN and global.userInputController:IsPressedCtrl() then
        local actor = global.actorManager:Pick(touchPosInWorld)
        local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
        if actor and not actor:IsDie() and (actor:IsPlayer() or actor:IsHumanoid()) and actor:GetID() ~= mainPlayerID then
            -- 当前禁止查看
            local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
            if mapProxy:IsForbidVisitPlayer() then
                ShowSystemChat(GET_STRING(30001071), 255, 249)
                return
            end

            if actor:IsHumanoid() then --人形怪
                local disHeadLookHumanoid = tonumber(global.ConstantConfig.disHeadLookHumanoid) == 1
                if disHeadLookHumanoid then
                    ShowSystemTips(GET_STRING(50000269))
                    return
                end
            end

            local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
            LookPlayerProxy:RequestPlayerData(actor:GetID())
            return
        end
    end

    -- alt + 右键 快速私聊
    if touchWay == global.MMO.MOVE_EVENT_MOUSE_R and eventType == cc.Handler.EVENT_TOUCH_BEGAN and global.userInputController:IsPressedAlt() then
        local actor = global.actorManager:Pick(touchPosInWorld)
        local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
        if actor and not actor:IsDie() and actor:IsPlayer() and actor:GetID() ~= mainPlayerID then
            global.Facade:sendNotification(global.NoticeTable.PrivateChatWithTarget, { name = actor:GetName(), uid = actor:GetID() })
            return
        end
    end

    -- alt + 鼠标左右键挖肉
    if global.userInputController:IsPressedAlt() then
        -- touchPosInWorld
        local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        inputProxy:SetDigDest(touchPosInWorld)
        return
    end


    -- find pickable
    local actor = nil
    self._touchActorID = nil
    if touchWay == global.MMO.MOVE_EVENT_TOUCH_AND_MOUSE_L and eventType == cc.Handler.EVENT_TOUCH_BEGAN then
        if global.HUDManager.Pick then
            actor = global.HUDManager:Pick(touchPosInWorld)
        end

        if not actor then
            actor = global.actorManager:Pick(touchPosInWorld)
        end

        local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
        local mainPlayer = global.gamePlayerController:GetMainPlayer()

        if actor then
            -- dead
            if actor:IsDie() then
                actor = nil

            elseif actor:IsDeath() then
                if self._lastTouchActID then
                    global.HUDManager:setVisible(self._lastTouchActID, global.MMO.HUD_TYPE_BATCH_LABEL, global.MMO.HUD_LABEL_NAME, false)
                end
                if actor and actor:GetID() then
                    global.HUDManager:setVisible(actor:GetID(), global.MMO.HUD_TYPE_BATCH_LABEL, global.MMO.HUD_LABEL_NAME, true)
                    self._lastTouchActID = actor:GetID()
                    self._touchActorID = actor:GetID()
                end
                actor = nil

            elseif actor:IsCave() then
                actor = nil
            end
        end

        -- ignore main player
        if actor and (actor:GetID() == mainPlayerID) then
            actor = nil
        end
        -- ignore pickup sprite
        if actor and actor:IsPickUpSprite() then
            actor = nil
        end

        if actor and not actor:IsAttackType() then
            actor = nil
        end

        if actor and not actor:IsPlayerAttacked() then
            actor = nil
        end
        -- ignore master is main player
        -- if actor and (actor:GetMasterID() == mainPlayerID) then
        --     actor = nil
        -- end
    end

    local dirtyFlag = false
    if actor then
        local actorType = actor:GetType()
        if actorType == global.MMO.ACTOR_MONSTER then -- monster
            dirtyFlag = true
            pickable.pickType = global.MMO.PICK_ACTOR_MONSTER
            pickable.actorPicked = actor:GetID()
            pickable.xGridPicked = actor:GetMapX()
            pickable.yGridPicked = actor:GetMapY()
            if actor:IsCollection() then
                pickable.pickType = global.MMO.PICK_ACTOR_COLLECTION

            elseif actor:IsDie() then
                if not global.isWinPlayMode or global.userInputController:IsPressedCtrl() then
                    pickable.pickType = global.MMO.PICK_ACTOR_CORPSE
                end
            else
                pickable.pickType = global.MMO.PICK_ACTOR_MONSTER
            end

        elseif actorType == global.MMO.ACTOR_PLAYER then -- player
            dirtyFlag = true
            pickable.pickType = global.MMO.PICK_ACTOR_PLAYER
            pickable.actorPicked = actor:GetID()
            pickable.xGridPicked = actor:GetMapX()
            pickable.yGridPicked = actor:GetMapY()

        elseif actorType == global.MMO.ACTOR_NPC then -- NPC
            dirtyFlag = true
            pickable.pickType = global.MMO.PICK_ACTOR_NPC
            pickable.actorPicked = actor:GetID()
            pickable.xGridPicked = actor:GetMapX()
            pickable.yGridPicked = actor:GetMapY()

        elseif actorType == global.MMO.ACTOR_DROPITEM then -- NPC
            actor = nil
        end
    end


    if nil == actor then --Nothing was picked.
        local mapX, mapY = global.sceneManager:WorldPos2MapPos(touchPosInWorld)

        dirtyFlag = true
        pickable.pickType = global.MMO.PICK_MAP_GRID
        pickable.actorPicked = 0
        pickable.xGridPicked = mapX
        pickable.yGridPicked = mapY
    end


    if global.MMO.PICK_ACTOR_NPC == pickable.pickType or
        global.MMO.PICK_ACTOR_COLLECTION == pickable.pickType or -- always dirty NPC
        global.MMO.PICK_MAP_GRID == pickable.pickType then -- always dirty grid
        dirtyFlag = true
    end

    if dirtyFlag then
        self:Assign(pickable)
    end

    if not self._touchActorID then
        if self._lastTouchActID then
            global.HUDManager:setVisible(self._lastTouchActID, global.MMO.HUD_TYPE_BATCH_LABEL, global.MMO.HUD_LABEL_NAME, false)
        end
    end
end

function ActorPickerProxy:MouseMoveWorldEvent(touchPos)
    self.mouseMovePos = touchPos
    self:checkMouseMoveEvent()
end

function ActorPickerProxy:checkMouseMoveEvent()
    if not self.mouseMovePos or not self.mouseMoveAble then
        return false
    end

    -- convert touch to world
    local touchPosInWorld = Screen2World(self.mouseMovePos)

    -- find pickable
    -- actor manager only
    local actor = global.actorManager:Pick(touchPosInWorld, true)

    if nil == actor or actor:IsBorn() or actor:IsCave() or actor:GetValueByKey(global.MMO.HUD_SNEAK) then --Nothing was picked.
        if self.lastMouseInsideActor then
            -- 移出
            global.Facade:sendNotification(global.NoticeTable.MouseMoveOutActorSide, self.lastMouseInsideActor)
            self.lastMouseInsideActor = nil
            self._lastMouseActorIsDropItem = false
        end
    else
        if self.lastMouseInsideActor and self.lastMouseInsideActor ~= actor:GetID() then
            -- 移出
            global.Facade:sendNotification(global.NoticeTable.MouseMoveOutActorSide, self.lastMouseInsideActor)
            -- 移入
            self.lastMouseInsideActor = actor:GetID()
            self._lastMouseActorIsDropItem = actor:IsDropItem()
            global.Facade:sendNotification(global.NoticeTable.MouseMoveInActorSide, self.lastMouseInsideActor)
            if actor:IsDeath() then
                global.HUDManager:setVisible(self.lastMouseInsideActor, global.MMO.HUD_TYPE_BATCH_LABEL, global.MMO.HUD_LABEL_NAME, true)
            end
        elseif not self.lastMouseInsideActor then
            -- 移入
            self.lastMouseInsideActor = actor:GetID()
            self._lastMouseActorIsDropItem = actor:IsDropItem()
            global.Facade:sendNotification(global.NoticeTable.MouseMoveInActorSide, self.lastMouseInsideActor)
            if actor:IsDeath() then
                global.HUDManager:setVisible(self.lastMouseInsideActor, global.MMO.HUD_TYPE_BATCH_LABEL, global.MMO.HUD_LABEL_NAME, true)
            end
        end
    end

    self.mouseMoveAble = false
    PerformWithDelayGlobal(function()
        self.mouseMoveAble = true
        self:checkMouseMoveEvent()
    end, 0.1)
end

function ActorPickerProxy:GetLastMouseInsideActor()
    return self.lastMouseInsideActor
end

function ActorPickerProxy:GetLastMouseInsideActorIsDropItem()
    return self._lastMouseActorIsDropItem
end

function ActorPickerProxy:onRegister()
    global.gamePlayerController:RegisterLuaTouchHandler(handler(self, self.TouchWorldEvent))

    ActorPickerProxy.super.onRegister(self)
end

return ActorPickerProxy