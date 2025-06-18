local AutoController = class('AutoController', framework.Mediator)
AutoController.NAME = "AutoController"

local proxyUtils        = requireProxy("proxyUtils")
local skillUtils        = requireProxy("skillUtils")

local AutoFindActorBehavior      = require("auto_behavior/AutoFindActorBehavior")
local AutoFindSkillBehavior      = require("auto_behavior/AutoFindSkillBehavior")
local AutoFindMoveBehavior       = require("auto_behavior/AutoFindMoveBehavior")

local facade            = global.Facade

function AutoController:ctor()
    AutoController.super.ctor(self, self.NAME)

    self._autoFindBehavior = {}
end

function AutoController:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.GameWorldInitComplete,
        noticeTable.ClearAllAutoState,
        noticeTable.ChangeScene,
        noticeTable.AFKBegin,
        noticeTable.AFKEnd,
        noticeTable.AutoPickBegin,
        noticeTable.AutoPickEnd,
        noticeTable.ActorInOfView,
        noticeTable.ActorRevive,
    }
end


function AutoController:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.GameWorldInitComplete == noticeID then
        self:onInit()

    elseif noticeTable.ClearAllAutoState == noticeID then
        self:onClearAllAutoState(data)

    elseif noticeTable.ChangeScene == noticeID then
        local mapID = data
        local lastMapID = notification:getType()
        self:onChangeScene(mapID, lastMapID)
    
    elseif noticeTable.AFKBegin == noticeID then
        self:onAFKBegin()
    
    elseif noticeTable.AFKEnd == noticeID then
        self:onAFKEnd()
    
    elseif noticeTable.AutoPickBegin == noticeID then
        self:onAutoPickBegin()
    
    elseif noticeTable.AutoPickEnd == noticeID then
        self:onAutoPickEnd()
            
    elseif noticeTable.ActorInOfView == noticeID then
        self:onActorInOfView(data)

    elseif noticeTable.ActorRevive == noticeID then
        self:onActorRevive(data)

    end
end

function AutoController:onInit()
    self._assistProxy       = facade:retrieveProxy(global.ProxyTable.AssistProxy)
    self._inputProxy        = facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    self._skillProxy        = facade:retrieveProxy(global.ProxyTable.Skill)
    self._autoProxy         = facade:retrieveProxy(global.ProxyTable.Auto)

    table.insert(self._autoFindBehavior, AutoFindActorBehavior.new())
    table.insert(self._autoFindBehavior, AutoFindSkillBehavior.new())
    table.insert(self._autoFindBehavior, AutoFindMoveBehavior.new())
    
    self._isInited = true
end

function AutoController:onClearAllAutoState(ignore)
    if not self._isInited then
        return
    end

    if self._autoProxy:GetPickItemID() then
        self._autoProxy:SetPickItemID(nil)
    end

    if ignore and ignore.ignoreAutoMining == 1 then
    else
        self._autoProxy:ClearAutoMining()
    end
end

function AutoController:onChangeScene(mapID, lastMapID)
    if not mapID then
        return nil
    end

    -- clear auto state
    facade:sendNotification(global.NoticeTable.ClearAllAutoState)

    -- slove change scene
    if mapID == lastMapID then
        self:onChangeSameScene(mapID, lastMapID)
    else
        self:onChangeOtherScene(mapID, lastMapID)
    end
end

function AutoController:onChangeSameScene(mapID, lastMapID)
    if not self._isInited then
        return
    end

    if CHECK_SERVER_OPTION(global.MMO.SERVER_CHECK_AUTO_FIGHT) then
        return
    end
    
    -- 随机石切换地图
    if self._autoProxy:GetRandStoneAFKFlag() then
        self._autoProxy:SetRandStoneAFKFlag(false)
    else
        self._autoProxy:ClearAFKState()
        self._autoProxy:ClearAllState()
        self._autoProxy:ClearPickState()
    end
end

function AutoController:onChangeOtherScene(mapID, lastMapID)
    if not self._isInited then
        return
    end
    
    local movePos = self._autoProxy:PopMove()
    if movePos and movePos.mapID == mapID then
        -- move to next pos at next action
        facade:sendNotification(global.NoticeTable.InputMove, movePos)
    else
        -- exception
        self._autoProxy:ClearAllState()
        self._autoProxy:ClearAFKState()
        self._autoProxy:ClearPickState()
    end
end

function AutoController:onAFKBegin()
    if not self._isInited then
        return
    end
    
    self._autoProxy:ClearAutoTarget()
    
    if self._autoProxy:IsAFKState() then
        return nil
    end

    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    facade:sendNotification(global.NoticeTable.ClearAllAutoState)
    facade:sendNotification(global.NoticeTable.InputIdle)
    self._autoProxy:ClearAutoLock()
    self._autoProxy:ClearAllState()

    self._autoProxy:SetIsAFKState(true)
    facade:sendNotification(global.NoticeTable.AutoFightBegin, global.MMO.INPUT_PRIORITY_SYSTEM)
    ssr.ssrBridge:OnAutoFightBegin()

    SLBridge:onLUAEvent(LUA_EVENT_AFKBEGIN)
end

function AutoController:onAFKEnd()
    if not self._isInited then
        return
    end
    
    if not self._autoProxy:IsAFKState() then
        return nil
    end

    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    facade:sendNotification(global.NoticeTable.ClearAllAutoState)
    facade:sendNotification(global.NoticeTable.InputIdle)
    self._autoProxy:ClearAutoLock()
    self._autoProxy:ClearAllState()
    self._autoProxy:ClearAFKState()
    self._autoProxy:ClearPickState()
end

function AutoController:onAutoPickBegin()
    if self._autoProxy:IsPickState() then
        return nil
    end

    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    facade:sendNotification(global.NoticeTable.ClearAllAutoState)
    facade:sendNotification(global.NoticeTable.InputIdle)
    self._autoProxy:ClearAutoLock()
    self._autoProxy:ClearAllState()
    self._autoProxy:ClearAFKState()

    print("----------------------- pick state begin")
    self._autoProxy:SetIsPickState(true)
end

function AutoController:onAutoPickEnd()
    if not self._autoProxy:IsPickState() then
        return nil
    end

    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    facade:sendNotification(global.NoticeTable.ClearAllAutoState)
    facade:sendNotification(global.NoticeTable.InputIdle)
    self._autoProxy:ClearAutoLock()
    self._autoProxy:ClearAllState()
    self._autoProxy:ClearAFKState()
    self._autoProxy:ClearPickState()

    print("----------------------- pick state end")
end


------------------------------------------------------------

-------------------------------------------------------------
function AutoController:stateBegin(player, actCompleted)
    if not self._isInited then
        return false
    end
    local mapData = global.sceneManager:GetMapData2DPtr()
    if not mapData then
        return false
    end
    
    local ret = false
    for k, v in pairs(self._autoFindBehavior) do
        if v:update(player, actCompleted) then
            ret = true
            break
        end
    end

    return ret
end
-------------------------------------------------------------

-------------------------------------------------------------
function AutoController:onCollectCompleted()
    if not self._isInited then
        return
    end
    
    if self._autoProxy:IsAutoFightState() and global.MMO.ACTOR_COLLECTION == self._autoProxy:GetTargetType() then
        facade:sendNotification(global.NoticeTable.AutoFightEnd)
        ssr.ssrBridge:OnAutoFightEnd()
    end
end

function AutoController:onActorInOfView(data)
    local actorID = data.actorID
    local actor   = data.actor
    if self._inputProxy and actor and false == actor:IsDie() and (actor:IsPlayer() or actor:IsMonster()) then
        -- 进视野选择
        if (nil == self._inputProxy:GetTargetID()) and (self._inputProxy:GetLastTargetID() and self._inputProxy:GetLastTargetID() == actorID) then
            self._inputProxy:SetTargetID(actorID)
        end
    end
end

function AutoController:onActorRevive(data)
    local actorID = data.actorID
    local actor   = data.actor
    if self._inputProxy and actor and false == actor:IsDie() and (actor:IsPlayer() or actor:IsMonster()) then
        -- 复活选择
        if (nil == self._inputProxy:GetTargetID()) and (self._inputProxy:GetLastTargetID() and self._inputProxy:GetLastTargetID() == actorID) then
            self._inputProxy:SetTargetID(actorID)

            if not global.isWinPlayMode and self._inputProxy:IsAttackState() and CHECK_SETTING(global.MMO.SETTING_IDX_ALWAYS_ATTACK) == 1 then
                self._autoProxy:SetIsAutoLockState(true)
                if not self._autoProxy:GetAutoLockSkillID() then
                    local skillID = skillUtils.findLockLaunchSkill()
                    self._autoProxy:SetAutoLockSkillID(skillID or 0)
                end
            end
        end
    end
end

return AutoController
