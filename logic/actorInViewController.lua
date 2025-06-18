local actorInViewController = class('actorInViewController', framework.Mediator)
actorInViewController.NAME  = "actorInViewController"

local Max = 3
local Min = 0
local ShowMaxNumInView = 200

function actorInViewController:ctor()
    actorInViewController.super.ctor(self, self.NAME)
    
    self._actorCounts = {}        -- 位置ID 计数
    self._actorPosIDs = {}        -- actorID = 位置ID
    self._posIDActors = {}        -- 位置ID  = actorIDs
    self._indexs      = {}        -- 
end

function actorInViewController:destory()
    if actorInViewController.instance then
        global.Facade:removeMediator(actorInViewController.NAME)
        actorInViewController.instance = nil
    end
end

function actorInViewController:Inst()
    if not actorInViewController.instance then
        actorInViewController.instance = actorInViewController.new()
        global.Facade:registerMediator(actorInViewController.instance)
    end
    return actorInViewController.instance
end

function actorInViewController:onRegister()
    actorInViewController.super.onRegister(self)

    local function dealAct(actor, act)
        -- 移动中视野处理
        if actor and IsMoveAction(act) then
            global.actorInViewController:AddActor(actor)
            global.Facade:sendNotification(global.NoticeTable.RefreshMoveInView, actor)
        end
    end

    global.netPlayerController:AddHandleOnActBegin(dealAct)
    global.netPlayerController:AddHandleOnActCompleted(dealAct)

    global.netMonsterController:AddHandleOnActBegin(dealAct)
    global.netMonsterController:AddHandleOnActCompleted(dealAct)
end

function actorInViewController:GetActorCount()
    return global.playerManager:PlayerCountInView() + global.monsterManager:MonsterCountInView()
end

function actorInViewController:GetActorPosSign(actor)
    return actor:GetMapX() * 65536 + actor:GetMapY()
end

function actorInViewController:UpdateActor(actor)
    -- 移除上个位置
    self:DelActor(actor)

    -- 处理新位置
    local posID = self:GetActorPosSign(actor)
    local actorID = actor:GetID()

    local count = (self._actorCounts[posID] or 0) + 1
    self._actorCounts[posID] = count
    self._actorPosIDs[actorID] = posID

    self._posIDActors[posID] = self._posIDActors[posID] or {}
    self._posIDActors[posID][actorID] = count

    self._indexs[posID] = self._indexs[posID] or {}
    self._indexs[posID][count] = actor

    actor:SetKeyValue("InView", self:IsVisible(actor))
end

function actorInViewController:AddActor(actor)
    if not actor then
        return false
    end

    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    if not mainPlayerID then
        return false
    end

    if actor:GetID() == mainPlayerID then
        actor:SetKeyValue("InView", true)
        return false
    end

    -- 自己的宝宝
    if actor:GetMasterID() == mainPlayerID then
        actor:SetKeyValue("InView", true)
        return false
    end

    if not (actor:IsMonster() or actor:IsPlayer()) then
        actor:SetKeyValue("InView", true)
        return false
    end

    if actor:IsDie() or actor:IsDeath() then
        actor:SetKeyValue("InView", true)
        return false
    end

    self:UpdateActor(actor)
end

function actorInViewController:IsVisible(actor)
    if not actor then
        return false
    end

    if self:GetActorCount() < ShowMaxNumInView then
        return true
    end

    if not (actor:IsMonster() or actor:IsPlayer()) then
        return true
    end

    local posID = self:GetActorPosSign(actor)
    if not self._posIDActors[posID] then
        return false
    end

    local count = self._posIDActors[posID][actor:GetID()]
    if not count then
        return false
    end

    if count > Min and count < Max then
        return true
    end

    return false
end

function actorInViewController:DelActor(actor)
    if not actor then
        return false
    end

    local actorID = actor:GetID()

    local posID = self._actorPosIDs[actorID]
    if not posID then
        return false
    end
    self._actorPosIDs[actorID] = nil

    if self._posIDActors[posID] and self._posIDActors[posID][actorID] then
        self._posIDActors[posID][actorID] = nil
    end

    local count = self._actorCounts[posID] or 0
    if count < 2 then
        self._actorCounts[posID] = nil
        self._posIDActors[posID] = nil
        self._indexs[posID] = nil
        return false
    end

    count = count - 1
    self._actorCounts[posID] = count
    local actor = self._indexs[posID] and self._indexs[posID][count]
    if actor and not tolua.isnull(actor) then
        global.Facade:sendNotification(global.NoticeTable.RefreshMoveInView, actor)
    end
end

function actorInViewController:Cleanup()
    self._actorCounts = {}
    self._posIDActors = {}
    self._actorPosIDs = {}
    self._indexs      = {}
end

return actorInViewController