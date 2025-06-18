local MainDigMediator = class("MainDigMediator", framework.Mediator)
MainDigMediator.NAME  = "MainDigMediator"

local proxyUtils      = requireProxy( "proxyUtils" )
local actorUtils      = requireProxy( "actorUtils" )
local CHECK_DELAY     = 0.5

local function squLen( x, y )
    return x * x + y * y
end

function MainDigMediator:ctor()
    MainDigMediator.super.ctor(self, self.NAME)

    self._targets = {}
end

function MainDigMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Main_Init,
        noticeTable.ActorDie,
        noticeTable.ActorOutOfView,
        noticeTable.ActorInOfView,
        noticeTable.ActorRevive,
        noticeTable.ActorMonsterDeath,
    }
end

function MainDigMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Main_Init == noticeID then
        self:OnOpen(data)

    elseif noticeTable.ActorDie == noticeID then
        self:CheckAddTarget(data)

    elseif noticeTable.ActorInOfView == noticeID then
        self:CheckAddTarget(data)

    elseif noticeTable.ActorOutOfView == noticeID then
        self:CheckRmvTarget(data)
        
    elseif noticeTable.ActorRevive == noticeID then
        self:CheckRmvTarget(data)
        
    elseif noticeTable.ActorMonsterDeath == noticeID then
        self:CheckRmvTarget(data)

    end
end

function MainDigMediator:OnOpen()
    if not (self._layer) then
        self._layer = requireMainUI("MainDigLayout").create()
        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_MB
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()

        LoadLayerCUIConfig(global.CUIKeyTable.MOBILE_DIG, self._layer)
    end
end

function MainDigMediator:ShowDig(targetID)
    if not (self._layer) then
        return
    end
    self._layer:ShowDig(targetID)
end

function MainDigMediator:HideDig()
    if not (self._layer) then
        return
    end
    self._layer:HideDig()
end

function MainDigMediator:checkDigAble()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return nil
    end

    local enemyVec      = {}
    local pMapX         = mainPlayer:GetMapX()
    local pMapY         = mainPlayer:GetMapY()
    local len           = 0

    for _, monster in pairs( self._targets ) do
        local fMapX     = monster:GetMapX()
        local fMapY     = monster:GetMapY()
        len             = actorUtils.calcMapDistance(pMapX, pMapY, fMapX, fMapY)
        if proxyUtils:checkDigEnable( monster ) and len <= 3 then
            local enemy       = {}
            enemy.actor       = monster
            enemy.len         = len

            table.insert(enemyVec, enemy)
        end
    end

    if #enemyVec > 0 then
        local function sort_monster( e1, e2 )
            return e1.len < e2.len
        end
        table.sort( enemyVec, sort_monster )
        
        local targetID = enemyVec[1].actor:GetID()
        self:ShowDig(targetID)
    else
        self:HideDig()
    end
end

function MainDigMediator:CheckAddTarget(data)
    if not data.actor or not data.actorID then
        return nil
    end

    if not data.actor:IsMonster() and not data.actor:IsHumanoid() then
        return nil
    end

    if proxyUtils:checkDigEnable(data.actor) then
        self._targets[data.actorID] = data.actor
    end

    self:checkDigAble()
end

function MainDigMediator:CheckRmvTarget(data)
    if not data.actor or not data.actorID then
        return nil
    end

    self._targets[data.actorID] = nil

    self:checkDigAble()
end

function MainDigMediator:onRegister()
    MainDigMediator.super.onRegister(self)

    global.gamePlayerController:AddHandleOnActBegin(function(actor, act)
        if act == global.MMO.ACTION_IDLE then
            return
        end
        self:checkDigAble()
    end)
end


return MainDigMediator
