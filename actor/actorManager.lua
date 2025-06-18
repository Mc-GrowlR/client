local actorManager = class("actorManager")
local gameActorPlayer = require("actor/gameActorPlayer")
local gameActorMonster = require("actor/gameActorMonster")
local gameActorNpc = require("actor/gameActorNpc")
local gameActorDropItem = require("actor/gameActorDropItem")
local gameActorEffect = require("actor/gameActorEffect")
local gameActorMonsterGate = require("actor/gameActorMonsterGate")
local gameActorMonsterWall = require("actor/gameActorMonsterWall")

local mAbs = math.abs
local filterDis = 150

local tsort = table.sort

local INVALID_MAP_POS = 0xFFFF

local function pickAble(actor)
    if actor:IsSEffect() then
        return false
    end
    return true
end

local function pickCmpFun(a1, a2)
    local dw1 = a1:IsDie() and 1 or 0
    local dw2 = a2:IsDie() and 1 or 0
    if dw1 ~= dw2 then
        return dw1 < dw2
    end

    local y1 = a1:GetMapY()
    local y2 = a2:GetMapY()
    return y1 > y2
end

local function filterActors(actors, ncount, pickPos)
    local newActors = {}
    local num = 0

    for i = 1, ncount do
        local actor = actors[i]
        if actor and pickAble(actor) and mAbs(actor:getPosition().x - pickPos.x) <= filterDis or mAbs(actor:getPosition().y - pickPos.y) <= filterDis then
            num = num + 1
            newActors[num] = actor
        end
    end

    tsort(newActors, pickCmpFun)
    
    return newActors, num
end

local function pickActors(actors, ncount, pickPos)
    local newActors, nums = filterActors(actors, ncount, pickPos)
    local boundBox  = nil
    local pos       = nil
    local actor     = nil
    local mAnimate  = nil
    local mIsAttack = false

    for i = 1, nums do
        actor     = newActors[i]
        mAnimate  = actor:GetAnimation()
        mIsAttack = actor:IsAttackType()

        if mIsAttack and mAnimate and actor:IsPlayerAttacked() then
            pos = actor:getPosition()
            if actor:IsMonster() and not actor:GetValueByKey(global.MMO.MONSTER_VISIBLE) then
                boundBox       = cc.rect(0,0,0,0)
                boundBox.width = global.MMO.MapGridWidth  -- 使用格子宽度
                boundBox.x     = pos.x - boundBox.width * 0.5
                boundBox.height= global.MMO.HUD_OFFSET_1.y + global.MMO.MapGridHeight -- 血条位置高度
                boundBox.y     = pos.y
            else
                boundBox   = mAnimate:GetBoundingBox()
                boundBox.x = boundBox.x + pos.x
                boundBox.y = boundBox.y + pos.y
            end

            if cc.rectContainsPoint(boundBox, pickPos) then
                return actor
            end
        end
    end

    return nil
end

local function addMapXYActorID( mapTab,actorID,mapX,mapY )
    if mapX == INVALID_MAP_POS and mapY == INVALID_MAP_POS then
        return
    end

    local XYKey = KEY_MAP_XY( mapX,mapY )
    if not mapTab[XYKey] then
        mapTab[XYKey] = {}
    end
    mapTab[XYKey][actorID] = true
end

local function rmvMapXYActorID( mapTab,actorID,mapX,mapY )
    if mapX == INVALID_MAP_POS and mapY == INVALID_MAP_POS then
        return
    end
    local XYKey = KEY_MAP_XY( mapX,mapY )
    if not mapTab[XYKey] then
        return
    end
    mapTab[XYKey][actorID]=nil
    if not next( mapTab[XYKey] ) then
        mapTab[XYKey] = nil
    end
end

local function getAllMapXYActor( mapTab,mapX,mapY )
    local actors = {}
    if mapX == INVALID_MAP_POS and mapY == INVALID_MAP_POS then
        return actors
    end
    local XYKey = KEY_MAP_XY( mapX,mapY )
    if not mapTab[XYKey] then
        return actors
    end

    for k,v in pairs(mapTab[XYKey]) do
        local actor = global.actorManager:GetActor( k )
        if actor then
            table.insert( actors, actor )
        end
    end

    return actors
end

function actorManager:ctor()
    self.mGameActorsMap = {}
    self.mActorIndexMap = {}
    self.mGameActors = {}
    self.mActorsCount = 0

    self.mTicking = false

    self.mAddingActorsMap = {}
    self.mAddingActors = {}
    self.mAddingActorsCount = 0
    self.mAddingDirty = false

    self.mRmvingActors = {}
    self.mRmvingActorsCount = 0
    self.mRmvingDirty = false

    self.mNodeOfActorSprite = nil
    self.mNodeOfActorSpriteBehind = nil

    self.mMonsterAllocator = {}
    self.mPlayerAllocator = {}
    self.mMonsterMapXYActorID   = {}
    self.mPlayerMapXYActorID    = {}
    self.mNPCMapXYActorID       = {}

    self.effect_root_node = {}
    self.effect_root_node_zorder = { 0, 4, 1, 2, 3, -1, 5 }

    self.mCurrLockT = 0
    self.mLockFrameT = 0  -- 非平滑模式锁帧时间，根据玩家的跑速度计算出来
end

function actorManager:destory()
    if actorManager.instance then
        actorManager.instance = nil
    end
end

function actorManager:Inst()
    if not actorManager.instance then
        local inst = actorManager.new()
        actorManager.instance = inst
    end

    return actorManager.instance
end

function actorManager:GetActors()
    return self.mGameActors, self.mActorsCount
end

function actorManager:IsMoveTime()
    return self.mCurrLockT <= 0
end

function actorManager:UpdateLockFrameT()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return
    end
    self.mLockFrameT = mainPlayer:GetRunStepTime() / mainPlayer:GetRunSpeed() / 6 / 2
end

function actorManager:Tick(dt)
    self.mCurrLockT = self.mCurrLockT - dt

    if self.mAddingDirty then
        for i = 1, self.mAddingActorsCount do
            local d = self.mAddingActors[i]
            self:addActor(d.actorID, d.actor)
        end

        self.mAddingDirty = false
        self.mAddingActorsMap = {}
        self.mAddingActors = {}
        self.mAddingActorsCount = 0
    end

    if self.mRmvingDirty then
        for i = 1, self.mRmvingActorsCount do
            self:RemoveActor(self.mRmvingActors[i])
        end

        self.mRmvingDirty = false
        self.mRmvingActors = {}
        self.mRmvingActorsCount = 0
    end

    self.mTicking = true

    for i = 1, self.mActorsCount do
        local actor = self.mGameActors[i]
        if actor then
            actor:Tick(dt)
        end
    end

    self.mTicking = false

    -- 锁帧时间
    if self.mCurrLockT <= 0 then
        self.mCurrLockT = self.mLockFrameT
    end
end

function actorManager:Pick(pickPos, mainPlayer)
    local actors = nil
    local target = nil
    local ncount = 0

    -- npc
    if not target then
        actors, ncount = global.npcManager:GetNpcInCurrViewField()
        target = pickActors(actors, ncount, pickPos)
    end

    -- player
    if not target then
        local noMainPlayer = (not mainPlayer)
        actors, ncount = global.playerManager:FindPlayerInCurrViewField(noMainPlayer)
        target = pickActors(actors, ncount, pickPos)
    end

    -- monster
    if not target then
        actors, ncount = global.monsterManager:FindMonsterInCurrViewField(false, false)
        target = pickActors(actors, ncount, pickPos)
    end

    -- drop item
    if not target then
        actors, ncount = global.dropItemManager:FindDropItemInCurrViewField()
        target = pickActors(actors, ncount, pickPos)
    end
    
    return target
end

function actorManager:addActor(actorID, actor)
    if not actorID then
        return false
    end

    if not actor then
        return false
    end
    
    actor:SetID(actorID)

    if self.mTicking then
        self.mAddingDirty = true

        self.mAddingActorsMap[actorID] = actor

        self.mAddingActorsCount = self.mAddingActorsCount + 1

        local n = self.mAddingActorsCount

        self.mAddingActors[n] = {actor = actor, actorID = actorID}
    else
        self.mActorsCount = self.mActorsCount + 1

        local n = self.mActorsCount

        self.mActorIndexMap[actorID] = n

        self.mGameActors[n] = actor

        self.mGameActorsMap[actorID] = actor
    end
end

local actorNews = {
    [global.MMO.ACTOR_PLAYER]   = function () return gameActorPlayer.new()   end,
    [global.MMO.ACTOR_DROPITEM] = function () return gameActorDropItem.new() end,
    [global.MMO.ACTOR_NPC]      = function () return gameActorNpc.new()      end,
    [global.MMO.ACTOR_SEFFECT]  = function () return gameActorEffect.new()   end
}

local actorMonsterNews = {
    [900] = function () return gameActorMonsterGate.new() end,

    [901] = function () return gameActorMonsterWall.new() end,
    [902] = function () return gameActorMonsterWall.new() end,
    [903] = function () return gameActorMonsterWall.new() end,
    [904] = function () return gameActorMonsterWall.new() end,
    [905] = function () return gameActorMonsterWall.new() end,
    [906] = function () return gameActorMonsterWall.new() end,

    [-1]  = function () return gameActorMonster.new() end
}

function actorManager:CreateActor(actorID, atype, params, isBehind, isFront)
    if self.mGameActorsMap[actorID] then
        return false
    end

    local actorfunc = nil
    if atype == global.MMO.ACTOR_MONSTER then
        actorfunc = actorMonsterNews[params.clothID] or actorMonsterNews[-1]
    else
        actorfunc = actorNews[atype]
    end

    local actor = actorfunc and actorfunc()

    if not actor then
        return false
    end

    actor:init()     
    actor:InitParam(params)

    self:addActor(actorID, actor)

    -- Add to Actor Sprite Node.
    if isBehind then
        self:AddActorSfxInBehind(actor, atype, params.type)
    elseif isFront then
        self:AddActorSfxInFront(actor, atype, params.sfxId or 0)
    else
        self:AddActorSfx(actor)
    end

    return actor
end

----------------------------------------------------------------------------
-- actor 后面
function actorManager:AddActorSfxInBehind(actor, type, effectType)
    if global.MMO.ACTOR_SEFFECT == type then
        if self.effect_root_node[effectType] then
            self.effect_root_node[effectType]:addChild(actor:GetNode())
        else
            self.mNodeOfActorSpriteBehind:addChild(actor:GetNode())
        end
    else
        self.mNodeOfActorSpriteBehind:addChild(actor:GetNode())
    end
end

-- actor 前面
function actorManager:AddActorSfxInFront(actor, type, order)
    local IsSfx  = global.MMO.ACTOR_SEFFECT == type 
    local zOrder = IsSfx and order or 0 
    self.mNodeOfActorSpriteFront:addChild(actor:GetNode(), zOrder)
end

function actorManager:AddActorSfx(actor)
    self.mNodeOfActorSprite:addChild(actor:GetNode())
end

function actorManager:GetActor(actorID)
    return self.mGameActorsMap[actorID] or self.mAddingActorsMap[actorID]
end

function actorManager:GetActorNum()
    return self.mActorsCount
end

function actorManager:RemoveActor(actorID)
    if not actorID then
        return false
    end

    local actor = self.mGameActorsMap[actorID] 
    
    if not actor then
        return false
    end

    if self.mTicking then
        self.mRmvingDirty = true

        self.mRmvingActorsCount = self.mRmvingActorsCount + 1

        local n = self.mRmvingActorsCount

        self.mRmvingActors[n] = actorID
    else
        self:deleteActor(actor)

        self.mGameActorsMap[actorID] = nil

        -- remove index
        local index = self.mActorIndexMap[actorID]

        if index == self.mActorsCount then
            self.mGameActors[index] = nil
        else
            -- last index --> index
            local lastActor = self.mGameActors[self.mActorsCount]
            self.mGameActors[index] = lastActor
            self.mActorIndexMap[lastActor:GetID()] = index

            -- reset last value
            self.mGameActors[self.mActorsCount] = nil
        end

        self.mActorIndexMap[actorID] = nil
        self.mActorsCount = self.mActorsCount - 1
    end
end

function actorManager:RemoveAllActor(excludeID)
    local excludeActor = nil
    if excludeID and excludeID ~= 0 then
        excludeActor = self.mGameActorsMap[excludeID]
    end

    for i = 1, self.mActorsCount do
        local actor = self.mGameActors[i]
        if actor and actor:GetID() ~= excludeID then
            self:deleteActor(actor)
        end
    end

    if excludeActor then
        local actorID = excludeActor:GetID()
        self.mGameActorsMap = {[actorID] = excludeActor}
        self.mActorIndexMap = {[actorID] = 1}
        self.mGameActors    = {excludeActor}
        self.mActorsCount   = 1
    else
        self.mGameActorsMap = {}
        self.mActorIndexMap = {}
        self.mGameActors    = {}
        self.mActorsCount   = 0
    end
end

function actorManager:Cleanup()
    self:RemoveAllActor()
    self:cleanupActorRootNode()
end

function actorManager:RefreshActorID(actorID, newActorID)
    local actor = self.mGameActorsMap[actorID]
    if not actor then
        return false
    end

    if actor:IsPlayer() then
        actor:SetID(newActorID)
    end

    local n = self.mActorIndexMap[actorID]

    self.mActorIndexMap[newActorID] = n

    self.mGameActors[n] = actor

    self.mGameActorsMap[newActorID] = actor

    self.mGameActorsMap[actorID] = nil

    self.mActorIndexMap[actorID] = nil
end

function actorManager:deleteActor(actor)
    local actorNode = actor:GetNode()
    if actorNode and not tolua.isnull(actorNode) then
        actorNode:removeFromParent()
    end
    self:RmvMapXYActor( actor,actor:GetMapX(),actor:GetMapY() )
    actor:destory()
end

function actorManager:cleanupActorRootNode()
    if self.mNodeOfActorSpriteFront then
        self.mNodeOfActorSpriteFront:autorelease()
        self.mNodeOfActorSpriteFront = nil
    end

    if self.mNodeOfActorSprite then
        self.mNodeOfActorSprite:autorelease()
        self.mNodeOfActorSprite = nil
    end

    if self.mNodeOfActorSpriteBehind then
        self.mNodeOfActorSpriteBehind:autorelease()
        self.mNodeOfActorSpriteBehind = nil
    end

    for i = 1, global.MMO.EFFECT_TYPE_MAX do
        if self.effect_root_node[i] then
            self.effect_root_node[i]:removeFromParent()
            self.effect_root_node[i] = nil
        end
    end
    self.effect_root_node = {}
end

function actorManager:InitOnEnterWorld()
    self.mNodeOfActorSprite = global.sceneGraphCtl:GetActorSpriteNode()
    self.mNodeOfActorSprite:retain()
    GUI._actorRootNode = self.mNodeOfActorSprite

    self.mNodeOfActorSpriteBehind = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_ACTOR_SFX_BEHIND)
    self.mNodeOfActorSpriteBehind:retain()

    if #self.effect_root_node == 0 then
        for i = 1, global.MMO.EFFECT_TYPE_MAX do
            self.effect_root_node[i] = cc.Node:create()
            if self.mNodeOfActorSpriteBehind then
                self.mNodeOfActorSpriteBehind:addChild(self.effect_root_node[i], self.effect_root_node_zorder[i])
            end
        end
    end
    if not self.mNodeOfActorSpriteFront then
        self.mNodeOfActorSpriteFront = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_ACTOR_SFX_FRONT)
        self.mNodeOfActorSpriteFront:retain()
    end
end

----------------- MapXY   begin ---------------------
function actorManager:AddMapXYActor( actor,mapX,mapY )
    if not actor then
        return
    end
    if actor:IsMonster() then
        addMapXYActorID( self.mMonsterMapXYActorID, actor:GetID(), mapX, mapY )
    elseif actor:IsPlayer() then
        addMapXYActorID( self.mPlayerMapXYActorID, actor:GetID(), mapX, mapY )
    elseif actor:IsNPC() then
        addMapXYActorID( self.mNPCMapXYActorID, actor:GetID(), mapX, mapY )
    end
end

function actorManager:RmvMapXYActor( actor,mapX,mapY )
    if not actor then
        return
    end

    if actor:IsMonster() then
        rmvMapXYActorID( self.mMonsterMapXYActorID, actor:GetID(), mapX, mapY )
    elseif actor:IsPlayer() then
        rmvMapXYActorID( self.mPlayerMapXYActorID, actor:GetID(), mapX, mapY )
    elseif actor:IsNPC() then
        rmvMapXYActorID( self.mNPCMapXYActorID, actor:GetID(), mapX, mapY )
    end
end

function actorManager:GetMonsterActorByMapXY( mapX,mapY,isAll )
    if isAll then
        return getAllMapXYActor( self.mMonsterMapXYActorID,mapX,mapY )
    end

    local XYKey     = KEY_MAP_XY( mapX,mapY )
    local actorID = self.mMonsterMapXYActorID[XYKey] and next(self.mMonsterMapXYActorID[XYKey]) or nil
    if not actorID then
        return nil
    end
    return self:GetActor( actorID )
end

function actorManager:GetPlayerActorByMapXY( mapX,mapY,isAll )
    if isAll then
        return getAllMapXYActor( self.mPlayerMapXYActorID,mapX,mapY )
    end

    local XYKey         = KEY_MAP_XY( mapX,mapY )
    local actorID       = self.mPlayerMapXYActorID[XYKey] and next(self.mPlayerMapXYActorID[XYKey]) or nil
    if not actorID then
        return nil
    end
    return self:GetActor( actorID )
end

function actorManager:GetNPCActorByMapXY( mapX,mapY,isAll )
    if isAll then
        return getAllMapXYActor( self.mNPCMapXYActorID,mapX,mapY )
    end

    local XYKey         = KEY_MAP_XY( mapX,mapY )
    local actorID       = self.mNPCMapXYActorID[XYKey] and next(self.mNPCMapXYActorID[XYKey]) or nil
    if not actorID then
        return nil
    end
    return self:GetActor(actorID)
end
----------------- MapXY     end ---------------------

function actorManager:SetActorMapXY( actor, mapX, mapY )
    actor:SetMapX( mapX )
    actor:SetMapY( mapY )

    if actor:IsMonster() then
        self:RmvMapXYActor( actor,actor:GetLastMapX(),actor:GetLastMapY() )
        self:AddMapXYActor( actor,mapX,mapY )
        global.netMonsterController:handle_ActorMapXYChange( actor, mapX, mapY )
    elseif actor:IsPlayer() then
        if not actor:IsMainPlayer() then
            self:RmvMapXYActor( actor,actor:GetLastMapX(),actor:GetLastMapY() )
            self:AddMapXYActor( actor,mapX,mapY )
            global.netPlayerController:handle_ActorMapXYChange( actor, mapX, mapY )
        end
    elseif actor:IsNPC() then
        self:RmvMapXYActor( actor,actor:GetLastMapX(),actor:GetLastMapY() )
        self:AddMapXYActor( actor,mapX,mapY )
    end
end

return actorManager