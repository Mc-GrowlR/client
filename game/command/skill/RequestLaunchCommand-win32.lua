local RequestLaunchCommand = class('RequestLaunchCommand', framework.SimpleCommand)

local cjson      = require("cjson")
local proxyUtils = requireProxy("proxyUtils")
local skillUtils = requireProxy("skillUtils")

local function squLen( x, y )
    local maxv = math.max(math.abs(x), math.abs(y))
    return maxv * maxv
end

function RequestLaunchCommand:ctor()
    self._checkParamFunc    = {}
    self._checkParamFunc[1] = handler(self, self.checkParam1)
    self._checkParamFunc[2] = handler(self, self.checkParam2)
    self._checkParamFunc[3] = handler(self, self.checkParam3)
    self._checkParamFunc[4] = handler(self, self.checkParam4)
    self._checkParamFunc[5] = handler(self, self.checkParam5)
end

function RequestLaunchCommand:getActorIDByMapPosition(mapPos)
    local worldPos  = global.sceneManager:MapPos2WorldPos(mapPos.x, mapPos.y, true)
    local actor     = global.actorManager:Pick(worldPos)
    if not actor then
        return nil
    end
    return actor:GetID()
end

function RequestLaunchCommand:checkParam1(param)
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return false
    end
    param.vecSrc    = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    param.vecDst    = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    param.dir       = mainPlayer:GetDirection()
    return true
end

function RequestLaunchCommand:checkParam2(param)
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return false
    end

    param.vecSrc        = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    param.vecDst        = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    param.dir           = mainPlayer:GetDirection()
    
    return true
end

function RequestLaunchCommand:checkParam3(param)
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return false
    end
    local inputProxy    = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)

    param.vecSrc        = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    param.vecDst        = inputProxy:GetLaunchTargetPos()
    param.targetID      = inputProxy:GetLaunchTargetID()
    param.dir           = skillUtils.calcLaunchDirection(param.vecDst, param.vecSrc)
    
    -- 增益型, 在自动释放或锁定释放时
    local SkillProxy    = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local launchType    = inputProxy:GetLaunchType()
    if SkillProxy:IsAdditionSkill(param.skillID) and (launchType == global.MMO.LAUNCH_TYPE_AUTO or launchType == global.MMO.LAUNCH_TYPE_LOCK) then
        param.vecDst    = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
        param.targetID  = mainPlayer:GetID()
        param.dir       = mainPlayer:GetDirection()
    end

    -- 选择目标点下目标
    if not param.targetID and inputProxy:GetLaunchTargetPos() then
        param.targetID  = self:getActorIDByMapPosition(inputProxy:GetLaunchTargetPos())
    end
    
    return true
end

function RequestLaunchCommand:checkParam4(param)
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return false
    end
    local inputProxy    = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)

    -- 强攻
    local launchType    = inputProxy:GetLaunchType()
    if launchType == global.MMO.LAUNCH_TYPE_ATTACK then
        param.vecSrc    = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
        param.vecDst    = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
        param.dir       = inputProxy:getCursorWorldDirection()
        return true
    end

    -- 默认传入方向和传入坐标
    param.vecSrc        = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    param.vecDst        = inputProxy:GetLaunchTargetPos()
    param.targetID      = inputProxy:GetLaunchTargetID()
    param.dir           = skillUtils.calcLaunchDirection(param.vecDst, param.vecSrc)

    -- 
    if not param.targetID and inputProxy:GetLaunchTargetPos() then
        param.targetID  = self:getActorIDByMapPosition(inputProxy:GetLaunchTargetPos())
    end

    -- 锁定攻击目标
    local attackTargetID    = inputProxy:GetAttackTargetID()
    if attackTargetID then
        local targetActor   = global.actorManager:GetActor(attackTargetID)
        if targetActor then
            param.vecDst    = cc.p(targetActor:GetMapX(), targetActor:GetMapY())
            param.dir       = skillUtils.calcLaunchDirection(param.vecDst, param.vecSrc)
            param.targetID  = attackTargetID
        end
    end

    local isAttack = false
    if param.targetID then
        local targetActor   = global.actorManager:GetActor(param.targetID)
        if targetActor then
            param.vecDst    = cc.p(targetActor:GetMapX(), targetActor:GetMapY())
            param.dir       = skillUtils.calcLaunchDirection(param.vecDst, param.vecSrc)
            isAttack        = not targetActor:IsDeath() and not targetActor:IsDie() and true or false
        end        
    end

    if param.skillID == 0 and not isAttack then
        return false
    end

    return true
end

function RequestLaunchCommand:checkParam5(param)
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return false
    end
    local inputProxy    = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)

    param.vecSrc        = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
    param.vecDst        = inputProxy:GetLaunchTargetPos()
    param.targetID      = inputProxy:GetLaunchTargetID()
    param.dir           = skillUtils.calcLaunchDirection(param.vecDst, param.vecSrc)

    -- 没有传入目标，使用目标点
    if not param.targetID then
        param.targetID  = self:getActorIDByMapPosition(inputProxy:GetLaunchTargetPos())
    end

    -- 判断目标是否是掉落物
    if param.targetID then
        local targetActor = global.actorManager:GetActor(param.targetID)
        if (targetActor and targetActor:IsDropItem()) or not proxyUtils.checkLaunchTargetByID(param.targetID) then
            param.targetID = nil
        end
    end

    -- 魔法锁定
    if not param.targetID then
        local magicTargetID = inputProxy:GetTargetID()
        if magicTargetID and CHECK_SETTING(37) == 1 then
            if proxyUtils.checkLaunchTargetByID(magicTargetID) then
                local targetActor   = global.actorManager:GetActor(magicTargetID)
                if targetActor then
                    param.targetID  = magicTargetID
                    param.vecDst    = cc.p(targetActor:GetMapX(), targetActor:GetMapY())
                    param.dir       = skillUtils.calcLaunchDirection(param.vecDst, param.vecSrc)
                end
            end
        end
    end

    if param.targetID then
        local targetActor   = global.actorManager:GetActor(param.targetID)
        if targetActor then
            param.vecDst    = cc.p(targetActor:GetMapX(), targetActor:GetMapY())
            param.dir       = skillUtils.calcLaunchDirection(param.vecDst, param.vecSrc)
        end
    end

    -- 魔法锁定
    local skillProxy    = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local skillID       = param.skillID
    local targetID      = param.targetID
    if skillProxy:IsMagicLockSkill(skillID) and targetID and proxyUtils.checkLaunchTargetByID(targetID) and CHECK_SETTING(37) == 1 then
        inputProxy:SetTargetID(targetID)
    end

    return true
end

function RequestLaunchCommand:execute(note)
    local data     = note:getBody()
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
        skillID  = skillID,
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
        print("can not find skill info, check config !" .. skillID)
        inputProxy:ClearLaunch()
        return nil
    end

    -- 3.check target( targetID targetPos dir )
    local launchMode     = skillProxy:GetLaunchMode(skillID)
    local checkParamFunc = self._checkParamFunc[launchMode]
    if not checkParamFunc or not checkParamFunc(requestParam) then
        inputProxy:ClearLaunch()
        return nil
    end

    if requestParam.targetID then
        local target = global.actorManager:GetActor(requestParam.targetID)
        if not target or target:IsDie() or target:IsDeath() then
            print("")
        end
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
            local points    = inputProxy:GetPathFindPoints()
            if #points == 0 then
                -- ingore target
                if targetID then
                    local target = global.actorManager:GetActor(targetID)
                    if target then
                        target:IgnoreActor(true)
                    end
                end
                
                -- clear launch data
                autoProxy:ClearAutoLock()
                inputProxy:ClearLaunch()
                inputProxy:ClearTarget()
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

    if skillID == global.MMO.SKILL_INDEX_YMCZ then
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
        global.Facade:sendNotification(global.NoticeTable.ActorEnterAttackAction, action)
        
    elseif skillConfig.action == 1 then
        global.Facade:sendNotification(global.NoticeTable.ActorEnterSkillAction, action)
    
    end

    -- 刀刀刺杀
    -- 强攻不处理
    local presentSkillID = skillID
    if skillID == global.MMO.SKILL_INDEX_CSJS and CHECK_SETTING(global.MMO.SETTING_IDX_DAODAOCISHA) == 0 then
        local distance = inputProxy:calcMapDistance(requestParam.vecDst, requestParam.vecSrc)
        if distance < 2 then
            presentSkillID = global.MMO.SKILL_INDEX_BASIC
        end
    end

    -- 技能特效
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

    -- 更改选中目标
    local actorPickerProxy      = global.Facade:retrieveProxy(global.ProxyTable.ActorPicker)
    local lastMouseInsideActor  = actorPickerProxy:GetLastMouseInsideActor()
    if inputProxy:GetLaunchSkillID() == skillID and inputProxy:GetLaunchType() == global.MMO.LAUNCH_TYPE_USER and skillProxy:IsMagicLockSkill(skillID) and lastMouseInsideActor and lastMouseInsideActor ~= inputProxy:GetTargetID() then
        local actor = global.actorManager:GetActor(lastMouseInsideActor)
        local isChangeTarge = true
        if not actor then
            isChangeTarge = false
        elseif actor:IsNPC() then
            isChangeTarge = false
        elseif actor:IsDeath() or actor:IsDie() then
            isChangeTarge = false
        elseif lastMouseInsideActor == global.gamePlayerController:GetMainPlayerID() then
            isChangeTarge = false
        end
        if isChangeTarge then
            inputProxy:SetTargetID( lastMouseInsideActor )
        end
    end
    
    skillProxy:ResetDelaySkillLaunch( skillID )
    
    -- clear launch data
    inputProxy:ClearLaunch()
end

return RequestLaunchCommand
