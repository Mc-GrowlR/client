local gameActor = require("actor/gameActor")
local gameActorDropItem = class('gameActorDropItem', gameActor)

function gameActorDropItem:ctor()
    gameActorDropItem.super.ctor(self)
end

function gameActorDropItem:init()
    gameActorDropItem.super.init(self)


    self.mFeatureDirty      = false
    self.mCurrActorSprite   = nil 
    self.mOwnerID           = global.MMO.ACTOR_ID_INVALID
    self.mOwnerName         = ""

    self.mPickState         = 0
    self.mPickTimeout       = false
    self.mPickBornStamp     = nil
    self.mMakeIndex         = 0
    self.mClothID           = nil
    self.mDropShake         = nil
end

function gameActorDropItem:destory()
    gameActorDropItem.super.destory(self)

    -- remove hud
    global.HUDManager:RemoveActorAllHUD(self.mID)
end

function gameActorDropItem:Tick(dt)
    gameActorDropItem.super.Tick(self, dt)

    if self.mFeatureDirty then
        self.mFeatureDirty = false
        self:checkFeature()
    end
end

function gameActorDropItem:setPosition(x, y)
    gameActorDropItem.super.setPosition(self, x, y)

    -- update hud pos
    global.HUDManager:setPosition(self.mID, x, y + global.MMO.HUD_DROPITEM_OFFSET_Y)

    -- update buff pos
    global.BuffManager:setPosition(self:GetID(), x, y)
    global.ActorEffectManager:setPosition(self:GetID(), x, y)
end

function gameActorDropItem:InitParam(param)
    self.mCurrActorNode = cc.Node:create()
    self.mClothID = tonumber(param.cloth) or 1

    -- set zOrder by clothID
    self:GetNode():setLocalZOrder(self.mClothID)

    self.mCurrMountNode = cc.Node:create()
    self.mCurrActorNode:addChild(self.mCurrMountNode)
    self.mCurrMountNode:setTag(global.MMO.DROP_MOUNT_TAG)

    -- Store owner id
    self.mOwnerID = param.ownerID

    return 1
end

function gameActorDropItem:dirtyFeature()
    self.mFeatureDirty = true
end

function gameActorDropItem:checkFeature()
    self:updateActorSprite()
end

function gameActorDropItem:updateActorSprite()
    if self.mCurrActorSprite then 
        self.mCurrActorSprite:removeFromParent()
        self.mCurrActorSprite = nil
    end

    local groundFile    = global.dropItemController:GetItemGroundFile(self.mClothID)
    local dropItemTexc  = ccui.ImageView:create(groundFile)
    local itemScale     = SL:GetMetaValue("GAME_DATA","itemGroundSacle") or (global.isWinPlayMode and 0.5 or 0.8)

    if nil == dropItemTexc then
        groundFile      = "res/item/un_define.pvr.ccz"
        dropItemTexc    = ccui.ImageView:create(groundFile)

        print("Failed to load drop item avatar:" .. groundFile .. "\n")
    end
    
    self.mCurrActorSprite = dropItemTexc
    self.mCurrActorSprite:setScale(itemScale)
    self.mCurrActorSprite.GetBoundingBox = self.mCurrActorSprite.getBoundingBox
    self.mCurrActorNode:addChild(self.mCurrActorSprite)

    -- 掉落动画
    if (self:GetDropShake() == 1 and (tonumber(SL:GetMetaValue("GAME_DATA", "NoShowItemDropEff"))) ~= 1) then
        local actorPos = self:getPosition()
        local interval = 1 / 30
        local max      = 50
        local distance = max
        local count    = 2
        local action   = nil
        local speed    = 1
        local flag     = 1
        self:setPosition(actorPos.x, actorPos.y + distance)
        action = schedule(self.mCurrActorNode, function()
            speed = speed + 1
            distance = distance - flag * max * interval * (3 + speed * interval)
            self:setPosition(actorPos.x, actorPos.y + distance)
            if count == 2 then
                if distance <= 0 then
                    count    = count - 1
                    max      = max / 2
                    distance = 0
                    flag     = -1
                    speed    = 60
                end
            elseif count == 1 then
                if distance >= max then
                    count    = count - 1
                    distance = max
                    speed    = 30
                    flag     = 1
                end
            else
                if distance <= 0 then
                    self:setPosition(actorPos.x, actorPos.y)
                    self.mCurrActorNode:stopActionByTag(689)
                end
            end
        end, interval)

        action:setTag(689)
    end
end

--获取animation，其实是Sprite，用于检测鼠标经过
function gameActorDropItem:GetAnimation()
    return self.mCurrActorSprite
end

function gameActorDropItem:GetType()
    return global.MMO.ACTOR_DROPITEM
end

function gameActorDropItem:SetMakeIndex(MakeIndex)
    self.mMakeIndex = MakeIndex
end

function gameActorDropItem:GetMakeIndex()
    return self.mMakeIndex
end

function gameActorDropItem:SetName(name)
    self.mName = name or ""
end

function gameActorDropItem:SetOwnerName(name)
    self.mOwnerName = name or ""
end
function gameActorDropItem:GetOwnerName()
    return self.mOwnerName
end

function gameActorDropItem:GetOwnerID()
    return self.mOwnerID
end
function gameActorDropItem:CheckOwnerID(id)
    return "0" == self.mOwnerID or nil == self.mOwnerID or id == self.mOwnerID
end

function gameActorDropItem:ResetPickState()
    self.mPickState = 0
end
function gameActorDropItem:GetPickState()
    return self.mPickState
end
function gameActorDropItem:PickStateMark()
    self.mPickState = self.mPickState + 1
end

function gameActorDropItem:ResetPickTimeout()
    self.mPickTimeout = false
end
function gameActorDropItem:IsPickTimeout()
    return self.mPickTimeout
end
function gameActorDropItem:SetPickTimeout()
    self.mPickTimeout = true
end

function gameActorDropItem:SetBornStamp(time)
    self.mPickBornStamp = time
end
function gameActorDropItem:GetBornStamp()
    return self.mPickBornStamp
end

function gameActorDropItem:IsPickEnable()
    if nil == self.mPickBornStamp then
        return true
    end

    -- 2sec pick CD
    if GetServerTime() - self.mPickBornStamp >= 2 then
        return true
    end

    return false
end

function gameActorDropItem:SetDropShake(v)
    self.mDropShake = v
end
function gameActorDropItem:GetDropShake()
    return self.mDropShake
end


return gameActorDropItem