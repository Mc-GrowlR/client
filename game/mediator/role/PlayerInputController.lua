local PlayerInputController = class('PlayerInputController', framework.Mediator)
PlayerInputController.NAME  = "PlayerInputController"

local proxyUtils        = requireProxy("proxyUtils")
local skillUtils        = requireProxy("skillUtils")
local actorUtils        = requireProxy( "actorUtils" )

local facade                = global.Facade

function PlayerInputController:ctor()
    PlayerInputController.super.ctor(self, self.NAME)
end

function PlayerInputController:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.GameWorldInitComplete,
        noticeTable.ClearAllInputState,
        noticeTable.MainPlayerDie,
        noticeTable.ChangeScene,
        noticeTable.ForbiddenMoveBuffBegan,
        noticeTable.ForbiddenMoveBuffEnd,
        noticeTable.CollectCompleted,
        noticeTable.UserInputMove,
        noticeTable.UserInputLaunch,
        noticeTable.UserInputCorpse,
        noticeTable.UserInputMining,
        noticeTable.UserPressedShift,
        noticeTable.UserReleaseShift,
        noticeTable.LaunchAttackSkill,
    }
end

function PlayerInputController:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.GameWorldInitComplete == noticeID then
        self:onInit()
    
    elseif noticeTable.ClearAllInputState == noticeID then
        self:onClearAllInputState()
    
    elseif noticeTable.MainPlayerDie == noticeID then
        self:onMainPlayerDie()

    elseif noticeTable.ChangeScene == noticeID then
        local mapID = data
        local lastMapID = notification:getType()
        self:onChangeScene(mapID, lastMapID)

    elseif noticeTable.ForbiddenMoveBuffBegan == noticeID then
        self:onForbiddenMoveBuffBegan()
    
    elseif noticeTable.ForbiddenMoveBuffEnd == noticeID then
        self:onForbiddenMoveBuffEnd()
    
    elseif noticeTable.CollectCompleted == noticeID then
        self:onCollectCompleted()

    elseif noticeTable.UserInputMove == noticeID then
        self:onUserInputMove(data)

    elseif noticeTable.UserInputLaunch == noticeID then
        self:onUserInputLaunch(data)

    elseif noticeTable.UserInputCorpse == noticeID then
        self:onUserInputCorpse(data)

    elseif noticeTable.UserInputMining == noticeID then
        self:onUserInputMining(data)
    
    elseif noticeTable.UserPressedShift == noticeID then
        self:onUserPressedShift()

    elseif noticeTable.UserReleaseShift == noticeID then
        self:onUserReleaseShift()

    elseif noticeTable.LaunchAttackSkill == noticeID then
        self:onLaunchAttackSkill()
    end
end

function PlayerInputController:onInit()
    self._inputProxy        = facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    self._skillProxy        = facade:retrieveProxy(global.ProxyTable.Skill)
    self._autoProxy         = facade:retrieveProxy(global.ProxyTable.Auto)

    self._isInited = true
end

function PlayerInputController:onClearAllInputState()
    if not self._isInited then
        return
    end

    self._inputProxy:ClearMouseTouch()
    self._inputProxy:ClearLaunch()
    self._inputProxy:ClearMining()
    self._inputProxy:ClearCorpse()
    self._inputProxy:ClearDigDest()
end

function PlayerInputController:onMainPlayerDie()
    if not self._isInited then
        return
    end

    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    facade:sendNotification(global.NoticeTable.ClearAllAutoState)
    facade:sendNotification(global.NoticeTable.InputIdle)
    self._autoProxy:ClearAutoLock()
    self._autoProxy:ClearAllState()
    self._autoProxy:ClearAFKState()
    self._autoProxy:ClearPickState()
end

function PlayerInputController:onChangeScene(mapID, lastMapID)
    if not self._isInited then
        return
    end

    if not mapID then
        return nil
    end

    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    facade:sendNotification(global.NoticeTable.InputIdle)
end

function PlayerInputController:onCollectCompleted()
    if not self._isInited then
        return
    end

    self._inputProxy:CompletedCollect()
end

function PlayerInputController:onForbiddenMoveBuffBegan()
    if not self._isInited then
        return
    end

    self._inputProxy:SetMovePermission(false)
end

function PlayerInputController:onForbiddenMoveBuffEnd()
    if not self._isInited then
        return
    end

    self._inputProxy:SetMovePermission(true)
end

----------------------------------------------------
--- user input
function PlayerInputController:onUserInputMove(data)
    if not self._isInited then
        return
    end


    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    facade:sendNotification(global.NoticeTable.ClearAllAutoState)
    facade:sendNotification(global.NoticeTable.InputIdle)
    self._autoProxy:ClearAllState()
    self._autoProxy:ClearAFKState()
    self._autoProxy:ClearPickState()

    -- 移动取消攻击锁定
    if CHECK_SETTING(60) == 1 then
        self._autoProxy:ClearAutoLock()
    end

    -- 
    facade:sendNotification(global.NoticeTable.InputMove, data)
end

function PlayerInputController:onUserInputLaunch(data)
    if not self._isInited then
        return
    end

    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    
    
    -- tips
    local UnableLaunchTips  = {}
    -- UnableLaunchTips[-2] = 800200
    UnableLaunchTips[-3]    = 800201
    UnableLaunchTips[-4]    = 800203
    UnableLaunchTips[-5]    = 800204
    UnableLaunchTips[-6]    = 50312
    UnableLaunchTips[-12]   = 800205
    UnableLaunchTips[-15]   = 800206
    

    local skillID       = data.skillID
    local destPos       = data.destPos
    local priority      = global.MMO.LAUNCH_PRIORITY_USER
    
    -- 普攻
    if skillID == 0 then
        skillID         = skillUtils.findLockLaunchSkill()
        skillID         = skillID or 0
    end

    -- auto find target
    if self._skillProxy:IsNeedTarget(skillID) then
        if self._inputProxy:GetTargetID() then
            if not proxyUtils.checkLaunchTargetByID(self._inputProxy:GetTargetID()) then
                self._inputProxy:ClearTarget()
                -- ShowSystemTips(GET_STRING(800402))
                return nil
            end
        else
            if not global.isWinPlayMode then --fix PC出现锁定光圈，施法还是打在其他地方； PC是根据鼠标位置进行施法
                skillUtils.findTarget()
            end
        end
    end

    -- unable tips
    local ret, param = self._skillProxy:CheckAbleToLaunch(skillID, true)
    if UnableLaunchTips[ret] then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(UnableLaunchTips[ret]))
        print("CheckAbleToLaunch:" .. ret)
    end
    
    -- 1.check launch
    if 1 == ret then 
        -- 打断动作, 立即施法
        local skillProxy = facade:retrieveProxy(global.ProxyTable.Skill)
        if skillProxy:IsNotNeedEnterAction(skillID) then
            local mainPlayer = global.gamePlayerController:GetMainPlayer()
            if mainPlayer and actorUtils.CheckActionDashAble(mainPlayer:GetAction()) then
                if IsMoveAction(mainPlayer:GetAction()) then
                    local subActTime = mainPlayer:GetCurrActTime() or 0
                    global.GameActorSkillController:SetMainPlayerAddDashTime(subActTime)
                end
                skillProxy:RequestLaunchImmediate( skillID )
            end
            return
        end

        -- launch
        local skillID           = skillID
        local destPos           = destPos
        local priority          = global.MMO.LAUNCH_PRIORITY_USER
        local launchType        = global.MMO.LAUNCH_TYPE_USER
        local launchData        = {skillID = skillID, destPos = destPos, priority = priority, launchType = launchType}
        facade:sendNotification(global.NoticeTable.InputLaunch, launchData)
        
    else
        if ret == -10 then
            local HorseProxy = global.Facade:retrieveProxy(global.ProxyTable.HorseProxy)
            HorseProxy:RequestHorseDown()
        elseif ret == -13 then
            if param then
                local buffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
                local buffTitle = buffProxy:GetNoSkillBuffTitle(param)
                if buffTitle then
                    ShowSystemTips(buffTitle)
                end
            end
        end
        
        local PlayerProperty = facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        if PlayerProperty:GetRoleJob() == global.MMO.ACTOR_PLAYER_JOB_FIGHTER and skillID == 0 then
        else
            -- record
            self._autoProxy:SetLaunchFirstSkill(skillID, destPos)
        end
    end
    
    -- 2.check lock state
    skillID = data.skillID
    if not self._autoProxy:IsAutoLockState() and not self._autoProxy:IsAFKState() and self._skillProxy:IsLockTargetSkill(skillID) and CHECK_SETTING(14) == 1 then
        self._autoProxy:SetIsAutoLockState(true)
        local skillProxy = facade:retrieveProxy(global.ProxyTable.Skill)
        if skillProxy:IsComboSkill(skillID) then
            self._autoProxy:SetAutoLockSkillID(0)
        else
            self._autoProxy:SetAutoLockSkillID(skillID)
        end
    end
end

function PlayerInputController:onUserInputCorpse(data)
    if not self._isInited then
        return
    end

    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    facade:sendNotification(global.NoticeTable.ClearAllAutoState)
    facade:sendNotification(global.NoticeTable.InputIdle)
    self._autoProxy:ClearAutoLock()
    self._autoProxy:ClearAllState()
    self._autoProxy:ClearAFKState()
    self._autoProxy:ClearPickState()

    -- 
    facade:sendNotification(global.NoticeTable.InputCorpse, data)
end

function PlayerInputController:onUserInputMining(data)
    if not self._isInited then
        return
    end

    if not self._inputProxy:IsLaunchMining( data.dest ) then
        return
    end

    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    facade:sendNotification(global.NoticeTable.ClearAllAutoState)
    facade:sendNotification(global.NoticeTable.InputIdle)
    self._autoProxy:ClearAutoLock()
    self._autoProxy:ClearAllState()
    self._autoProxy:ClearAFKState()
    self._autoProxy:ClearPickState()
    
    -- 
    self._autoProxy:SetAutoMining(data.dir, data.dest)
    facade:sendNotification(global.NoticeTable.InputMining, data)
end
----------------------------------------------------


----------------------------------------------------
function PlayerInputController:onUserPressedShift()
    if not self._isInited then
        return
    end

    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    facade:sendNotification(global.NoticeTable.ClearAllAutoState)
    self._autoProxy:ClearAutoLock()
    self._autoProxy:ClearAllState()
    self._autoProxy:ClearAFKState()
    self._autoProxy:ClearPickState()

    if self._inputProxy:GetTargetID() then
        self._inputProxy:SetAttackState(true)
    end
end

function PlayerInputController:onUserReleaseShift()
    if not self._isInited then
        return
    end

    facade:sendNotification(global.NoticeTable.ClearAllInputState)
    facade:sendNotification(global.NoticeTable.ClearAllAutoState, {ignoreAutoMining = 1})
    self._autoProxy:ClearAutoLock()
    self._autoProxy:ClearAllState()
    self._autoProxy:ClearAFKState()
    self._autoProxy:ClearPickState()

    self._inputProxy:ClearLaunch()

    if self._inputProxy:GetTargetID() then
        self._inputProxy:SetAttackState(true)
    end
end

function PlayerInputController:onLaunchAttackSkill()
    if not self._isInited then
        return
    end
    
    local skillID, destPos  = skillUtils.findAttackLaunchSkill()

    if not skillID then
        return
    end

    self._inputProxy:ClearTarget()

    local skillID           = skillID
    local destPos           = destPos
    local priority          = global.MMO.LAUNCH_PRIORITY_USER
    local launchType        = global.MMO.LAUNCH_TYPE_ATTACK
    local launchData        = {skillID = skillID, destPos = destPos, priority = priority, launchType = launchType}
    facade:sendNotification(global.NoticeTable.InputLaunch, launchData)
end

return PlayerInputController
