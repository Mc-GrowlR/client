local RequestLaunchCommand = class('RequestLaunchCommand', framework.SimpleCommand)

local cjson      = require("cjson")
local proxyUtils = requireProxy("proxyUtils")
local skillUtils = requireProxy("skillUtils")

local function squLen( x, y )
    local maxv = math.max(math.abs(x), math.abs(y))
    return maxv * maxv
end

function RequestLaunchCommand:ctor()
    self._checkParamFunc = {}
    
    self._checkParamFunc[1] = handler(self, self.checkParam1)
    self._checkParamFunc[2] = handler(self, self.checkParam2)
    self._checkParamFunc[3] = handler(self, self.checkParam3)
    self._checkParamFunc[4] = handler(self, self.checkParam4)
    self._checkParamFunc[5] = handler(self, self.checkParam5)
end

function RequestLaunchCommand:calcDir(dest, src)
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    return inputProxy:Vec2ToDir(cc.pSub(dest, src))
end

function RequestLaunchCommand:findTargetByWorldPos(worldPos, launchID, findAll)
    -- find pickable
    local target = nil
    if global.HUDManager.Pick then
        target = global.HUDManager:Pick( worldPos )
    end

    if not target then
        target = global.actorManager:Pick( worldPos )
    end

    -- can't find target
    if not target then
        return nil, nil
    end

    -- error type
    if not findAll and not proxyUtils.checkLaunchTarget(target) then
        if launchID == 28 and target:IsBorn() then
        else
            return nil, nil
        end
    end

    return target:GetID(), target
end

function RequestLaunchCommand:findTargetByMapPos(mapPos, launchID, findAll)
    local worldPos = global.sceneManager:MapPos2WorldPos(mapPos.x, mapPos.y, true)
    return self:findTargetByWorldPos(worldPos, launchID, findAll)
end

function RequestLaunchCommand:checkParam1(param)
    local player = global.gamePlayerController:GetMainPlayer()
    if not player then
        return false
    end

    -- cehck target
    local targetID, targetActor = skillUtils.checkTarget(param.launchID)

    -- if target, find best pos & dir
    if targetID and targetActor then
        param.vecSrc    = cc.p(player:GetMapX(), player:GetMapY())
        param.vecDst    = cc.p(targetActor:GetMapX(), targetActor:GetMapY())
        param.dir       = self:calcDir(param.vecDst, param.vecSrc)
        param.targetID  = targetID
    else
        -- default
        param.vecSrc    = cc.p(player:GetMapX(), player:GetMapY())
        param.vecDst    = cc.p(player:GetMapX(), player:GetMapY())
        param.dir       = player:GetDirection()
    end
    
    return true
end

function RequestLaunchCommand:checkParam2(param)
    local player = global.gamePlayerController:GetMainPlayer()
    if not player then
        return false
    end

    -- src & dir, only
    param.vecSrc    = cc.p(player:GetMapX(), player:GetMapY())
    param.vecDst    = cc.p(player:GetMapX(), player:GetMapY())
    param.dir       = player:GetDirection()
    
    return true
end

function RequestLaunchCommand:checkParam3(param)
    local player = global.gamePlayerController:GetMainPlayer()
    if not player then
        return false
    end

    -- cehck target
    local targetID, targetActor = skillUtils.checkTarget()

    -- if target, find best pos & dir
    if targetID and targetActor then
        param.vecSrc    = cc.p(player:GetMapX(), player:GetMapY())
        param.vecDst    = cc.p(targetActor:GetMapX(), targetActor:GetMapY())
        param.dir       = self:calcDir(param.vecDst, param.vecSrc)
        param.targetID  = targetID
    else
        -- default
        param.vecSrc    = cc.p(player:GetMapX(), player:GetMapY())
        param.vecDst    = cc.p(player:GetMapX(), player:GetMapY())
        param.dir       = player:GetDirection()
    end
    
    return true
end

function RequestLaunchCommand:checkParam4(param)
    local player = global.gamePlayerController:GetMainPlayer()
    if not player then
        return false
    end


    local function findDestTarget(skillID)
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        local inputPos   = inputProxy:GetLaunchTargetPos()
        if SkillProxy:IsAdditionSkill(skillID) then
            if inputPos then
                local targetID = self:findTargetByMapPos(inputPos, skillID, true)
                local destPos  = inputPos
                return targetID, destPos
            else
                local targetID = player:GetID()
                local destPos  = cc.p(player:GetMapX(), player:GetMapY())
                return player:GetID(), destPos
            end
        elseif SkillProxy:IsInputDestSkill(skillID) then
            if inputPos then
                local autoProxy = global.Facade:retrieveProxy( global.ProxyTable.Auto )
                local isAutoFight = autoProxy:IsAutoFightState()
                local targetID = isAutoFight and inputProxy:GetLaunchTargetID() or self:findTargetByMapPos(inputPos,skillID)
                if isAutoFight and targetID then
                    inputPos = nil
                    local actor = global.actorManager:GetActor(targetID)
                    if actor then
                        inputPos = cc.p(actor:GetMapX(), actor:GetMapY())
                    end
                end
                return targetID, inputPos
            else
                return nil
            end
        end
    end

    -- 1.check target pos
    local targetID, targetPos = findDestTarget(param.launchID)
    if not targetPos then
        return false
    end

    param.vecSrc    = cc.p(player:GetMapX(), player:GetMapY())
    param.vecDst    = targetPos
    param.dir       = self:calcDir(param.vecDst, param.vecSrc)
    param.targetID  = targetID

    return true
end

function RequestLaunchCommand:checkParam5(param)
    local player = global.gamePlayerController:GetMainPlayer()
    if not player then
        return false
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local autoProxy  = global.Facade:retrieveProxy(global.ProxyTable.Auto)

    -- 强攻
    local launchType = inputProxy:GetLaunchType()
    if launchType == global.MMO.LAUNCH_TYPE_ATTACK then
        param.vecSrc    = cc.p(player:GetMapX(), player:GetMapY())
        param.vecDst    = cc.p(player:GetMapX(), player:GetMapY())
        param.dir       = player:GetDirection()
        return true
    end

    ---------------------------------------------------------
    -- can't find target
    if nil == inputProxy:GetTargetID() then
        autoProxy:ClearAutoLock()
        return false
    end

    -- 无目标或目标无法攻击
    if false == proxyUtils.checkLaunchTargetByID(inputProxy:GetTargetID()) then
        inputProxy:ClearTarget()
        autoProxy:ClearAutoLock()

        -- 屏蔽此行，存在怪物血量0但是没死的情况
        -- global.Facade:sendNotification( global.NoticeTable.SystemTips, GET_STRING(800402) )
        return false
    end
    ---------------------------------------------------------

    -- find target
    local targetID, targetActor = skillUtils.checkTarget()
    
    -- find best pos & dir
    param.vecSrc    = cc.p(player:GetMapX(), player:GetMapY())
    param.vecDst    = cc.p(targetActor:GetMapX(), targetActor:GetMapY())
    param.dir       = self:calcDir(param.vecDst, param.vecSrc)
    param.targetID  = targetID
    
    return true
end

function RequestLaunchCommand:execute(note)
    local data = note:getBody()
    local skillID  = data.skillID
    local inputDir = data.dir
    local inputDst = data.dest

    if not skillID then
        return nil
    end

    local player = global.gamePlayerController:GetMainPlayer()
    if not player then
        return nil
    end

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local autoProxy  = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    local priority   = inputProxy:GetLaunchPriority()

    if skillProxy:IsComboSkill(skillID) then
        skillProxy:ClearComboLanunchID()
    end
    
    -- 请求释放参数
    local requestParam =
    {
        launchID = skillID,
        targetID = nil,
        dir      = nil,
        vecSrc   = nil,
        vecDst   = nil,
    }

    if GUIFunction and GUIFunction.OnCheckAllowLaunchSkillBefore then
        if not GUIFunction:OnCheckAllowLaunchSkillBefore(skillID) then
            releasePrint("GUIFunction:OnCheckAllowLaunchSkill ban skillID ", skillID)
            inputProxy:ClearLaunch()
            return nil
        end
    end

    -- 1.check base condition( mp? cd? )
    local ret = skillProxy:CheckAbleToLaunch(skillID)
    if 1 ~= ret then
        inputProxy:ClearLaunch()
        return nil
    end
    
    -- 2.find skill info
    local skillConfig = skillProxy:FindConfigBySkillID(skillID)
    if not skillConfig then
        -- debug
        inputProxy:ClearLaunch()
        print("can not find skill info, check config !" .. skillID)
        return nil
    end

    -- 3.check target( targetID targetPos dir )
    local launchMode     = skillProxy:GetLaunchMode(skillID)
    local checkParamFunc = self._checkParamFunc[launchMode]
    if not checkParamFunc or not checkParamFunc(requestParam) then
        inputProxy:ClearLaunch()
        return nil
    end

    -- 4.check attack range.
    local moveBestPos = (skillConfig.bestPos ~= 0)
    if nil == requestParam.targetID and requestParam.vecSrc.x == requestParam.vecDst.x and requestParam.vecSrc.y == requestParam.vecDst.y then
        moveBestPos = false
    end
    if moveBestPos then
        local srcX          = requestParam.vecSrc.x
        local srcY          = requestParam.vecSrc.y
        local dstX          = requestParam.vecDst.x
        local dstY          = requestParam.vecDst.y
        local targetID      = requestParam.targetID
        
        -- move best pos to launch
        local launchX, launchY, moveX, moveY = skillUtils.findBestLaunchPos(skillID, targetID, srcX, srcY, dstX, dstY)
        if srcX ~= launchX or srcY ~= launchY then
            if srcX == moveX and srcY == moveY then
                moveX = launchX
                moveY = launchY
            end
            local dest      = cc.p(moveX, moveY)
            dest.skillID    = skillID
            dest.targetID   = targetID
            dest.type       = global.MMO.INPUT_MOVE_TYPE_LAUNCH
            global.Facade:sendNotification(global.NoticeTable.InputMove, dest)
            inputProxy:ResetLaunchDirty()

            -- check path points
            local pathPoints = inputProxy:GetCurrPathPoint()
            if pathPoints == 0 then
                -- ingore target
                local target = nil
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
            
            return nil
        end
    elseif skillProxy:IsForceDis(skillID) then
        local srcX          = requestParam.vecSrc.x
        local srcY          = requestParam.vecSrc.y
        local dstX          = requestParam.vecDst.x
        local dstY          = requestParam.vecDst.y
        local minLaunchDis  = tonumber(skillProxy:GetMinDistance(skillID))
        local maxLaunchDis  = tonumber(skillProxy:GetMaxDistance(skillID))
        if minLaunchDis and maxLaunchDis then
            local len      = squLen( srcX - dstX, srcY - dstY )
            local minRange = minLaunchDis * minLaunchDis
            local maxRange = maxLaunchDis * maxLaunchDis
            if len < minRange or len > maxRange then
                inputProxy:ResetLaunchDirty()
                return nil
            end
        end
    end

    local targetID = requestParam.targetID
    if targetID then
        local target = global.actorManager:GetActor(targetID)
        if target and target:IsPauseIgnored() then
            target:PauseIgnoredActor()
        end
    end

    -- 5. check dir!
    if requestParam.dir == global.MMO.ORIENT_INVAILD then
        requestParam.dir = player:GetDirection()
    end

    -- 6. assist
    local AssistProxy = global.Facade:retrieveProxy(global.ProxyTable.AssistProxy)
    AssistProxy:autoDressEquipSkill(skillID)
    
    -- 7. request server
    -- debug
    -- print( "request server:", param1, GetTimeInMS() )
    -- dump(requestParam)
    local sendData = {
        skillID     = skillID,
        dir         = requestParam.dir,
        srcX        = requestParam.vecSrc.x,
        srcY        = requestParam.vecSrc.y,
        destX       = requestParam.vecDst.x,
        destY       = requestParam.vecDst.y,
        targetID    = requestParam.targetID,
    }
    local netMsgID = (skillConfig.action == 0 and global.MsgType.MSG_CS_PLAYER_SKILL_ATTACK or global.MsgType.MSG_CS_PLAYER_SKILL_LAUNCH)
    local jsonStr = cjson.encode(sendData)
    LuaSendMsg(netMsgID, skillID, 0, 0, 0, jsonStr, string.len(jsonStr))
    -- dump(sendData)

    -- 7.enter cd
    if skillProxy:IsComboSkill(skillID) then
        global.Facade:sendNotification(global.NoticeTable.ComboSkillEnterCD, skillID)
    else
        global.Facade:sendNotification(global.NoticeTable.SkillEnterCD, skillID)
    end
    
    -- 8.enter action, and play skill effect immediately
    local action =
    {
        skillID = skillID,
        actor = player,
        dir = requestParam.dir,
        ActionId = skillProxy:GetActionID(skillID),
    }

    if skillID == global.MMO.SKILL_INDEX_GSJS then
        -- 攻杀剑术
        player:SetAction(global.MMO.ACTION_DASH, true)

    elseif skillID == global.MMO.SKILL_INDEX_YMCZ then
        -- 野蛮
        player:SetAction(global.MMO.ACTION_DASH_WAITING, true)
    
    elseif skillID == global.MMO.SKILL_INDEX_SBYS then
        -- 十步一杀
        player:SetAction(global.MMO.ACTION_DASH_WAITING, true)

    elseif skillID == global.MMO.SKILL_INDEX_DIG then
        -- 挖矿
        player:SetDirection(inputDir)
        player:SetAction(global.MMO.ACTION_MINING)
        -- 特殊处理下，挖矿时普通攻击进入CD，处理下挖矿的CD问题
        global.Facade:sendNotification(global.NoticeTable.SkillEnterCD, global.MMO.SKILL_INDEX_BASIC)

    elseif skillConfig.action == 0 then
        -- 攻击
        global.Facade:sendNotification(global.NoticeTable.ActorEnterAttackAction, action)
        
    elseif skillConfig.action == 1 then
        -- 施法
        global.Facade:sendNotification(global.NoticeTable.ActorEnterSkillAction, action)
    end

    -- 刀刀刺杀
    -- 强攻不处理
    local presentSkillID = skillID
    if skillID == global.MMO.SKILL_INDEX_CSJS and CHECK_SETTING(global.MMO.SETTING_IDX_DAODAOCISHA) == 0 and inputProxy:GetLaunchType() ~= global.MMO.LAUNCH_TYPE_ATTACK then
        local distance = inputProxy:calcMapDistance(requestParam.vecDst, requestParam.vecSrc)
        if distance < 2 then
            presentSkillID = global.MMO.SKILL_INDEX_BASIC
        end
    end
    
    -- persent
    if skillID ~= global.MMO.SKILL_INDEX_DIG then
        local present =
        {
            skillID = skillProxy:GetSkillPresentReplaceID(presentSkillID),
            launchX = requestParam.vecSrc.x,
            launchY = requestParam.vecSrc.y,
            hitX    = requestParam.vecDst.x,
            hitY    = requestParam.vecDst.y,
            dir     = requestParam.dir,
            skillStage = 1,
            launcherID = player:GetID()
        }
        global.Facade:sendNotification(global.NoticeTable.RequestSkillPresent, present)
    end

    -- 开关技能关闭
    if skillID == global.MMO.SKILL_INDEX_GSJS 
        or skillID == global.MMO.SKILL_INDEX_LHJF 
        or skillID == global.MMO.SKILL_INDEX_LYJF
        or skillID == global.MMO.SKILL_INDEX_LTJF 
        or skillID == global.MMO.SKILL_INDEX_ZRJF 
        or skillID == global.MMO.SKILL_INDEX_KTZ
        or skillID == global.MMO.SKILL_INDEX_ZHJS
    then
        skillProxy:SkillOff(skillID)
    end

    -- 普攻音效
    if presentSkillID == global.MMO.SKILL_INDEX_BASIC then
        global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type=global.MMO.SND_TYPE_SKILL_ATTACK})

        --auto on skill  普攻
        if not skillProxy:IsOnSkill(global.MMO.SKILL_INDEX_CSJS) and CHECK_SETTING(global.MMO.SETTING_IDX_DAODAOCISHA) == 1 then
            skillProxy:RequestSkillOnoff(global.MMO.SKILL_INDEX_CSJS)
        end
    end
    
    -- 十步一杀  锁定自动释放
    if CHECK_SETTING(global.MMO.SETTING_IDX_ALWAYS_ATTACK) == 1 and skillID == global.MMO.SKILL_INDEX_SBYS then
        if not autoProxy:IsAutoLockState() and not autoProxy:IsAFKState() and skillProxy:IsLockTargetSkill(global.MMO.SKILL_INDEX_BASIC) then
            autoProxy:SetIsAutoLockState(true)
            autoProxy:SetAutoLockSkillID(global.MMO.SKILL_INDEX_BASIC)
        end
    end

    skillProxy:ResetDelaySkillLaunch( skillID )
    
    -- clear launch data
    inputProxy:ClearLaunch()
end

return RequestLaunchCommand
