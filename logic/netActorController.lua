local netActorController = class("netActorController")
netActorController.NAME = "netActorController"

local actorUtils = requireProxy( "actorUtils" )

-- 状态队列
local ACTION_CACHE = 
{
    WALK                = 1,    -- 走
    RUN                 = 2,    -- 跑
    RIDE_RUN            = 3,    -- 坐骑 跑
    STUCK               = 4,    -- 受击
    SKILL_ACTION        = 5,    -- 魔法 纯动作
    SKILL_MAGIC         = 6,    -- 魔法 纯魔法 -- 无用
    SKILL_ACTION_MAGIC  = 7,    -- 魔法 动作 + 魔法
    DASH                = 8,    -- 野蛮
    ONDASH              = 9,    -- 被野蛮，被推开
    SBYS                = 10,   -- 十步一杀
    QLS                 = 11,   -- 擒龙手 
    SNEAK               = 12,   -- 潜行
    ZXC                 = 27,   -- 追心刺 
}

function netActorController:ctor()
    self.mHandleOnActCompleted = {}
    self.mHandleOnActBegin = {}

    self.mNextActionCache = {}
end

function netActorController:destory()
end

function netActorController:Init()
end

function netActorController:Cleanup(cleanHandler)
    if cleanHandler == nil then
        cleanHandler = true
    end

    if cleanHandler then
        self.mHandleOnActCompleted = {}
        self.mHandleOnActBegin = {}
    end

    self.mNextActionCache = {}
end

-----------------------------------------------------------------------------
function netActorController:AddHandleOnActCompleted(func)
    table.insert(self.mHandleOnActCompleted, func)
end

function netActorController:AddHandleOnActBegin(func)
    table.insert(self.mHandleOnActBegin, func)
end

-----------------------------------------------------------------------------
function netActorController:handleActionBegin(actor, act)
    -- Action begin handle.
    for k, v in pairs(self.mHandleOnActBegin) do
        v(actor, act)
    end
end

function netActorController:handleActionCompleted(actor, act)
    -- Action completion handle.
    for k, v in pairs(self.mHandleOnActCompleted) do
        v(actor, act)
    end

    --重置加速
    if actor:GetIsSpeedup() then
        actor:SetIsSpeedup(false)
        actor:dirtyAnimFlag()
    end
    if actor:GetIsFullSpeedup() then
        actor:SetIsFullSpeedup(false)
        actor:dirtyAnimFlag()
    end

    --确认
    actor:SetConfirmed(true)

    local isIdleAction = false
    local nextActionCache = self.mNextActionCache[actor:GetID()]
    if nextActionCache and nextActionCache[1] then
        local nextAction = table.remove(nextActionCache, 1)
        if nextActionCache[1] ~= nil and nextActionCache[1].act ~= ACTION_CACHE.STUCK then
            actor:SetIsSpeedup(true)

            -- 堆积的太多，更快的加速
            if nextActionCache[2] ~= nil and nextActionCache[3] ~= nil then
                actor:SetIsFullSpeedup(true)
            end
        end

        if nextAction.act == ACTION_CACHE.STUCK then
            actor:SetAction(global.MMO.ACTION_STUCK)

        elseif nextAction.act == ACTION_CACHE.WALK then
            actor:SetMoveTo(nextAction.pos)
            actor:SetAction(global.MMO.ACTION_WALK)
            actor:SetConfirmed(true)

        elseif nextAction.act == ACTION_CACHE.SNEAK then
            actor:SetMoveTo(nextAction.pos)
            actor:SetAction(global.MMO.ACTION_ASSASSIN_SNEAK)
            actor:SetConfirmed(true)

        elseif nextAction.act == ACTION_CACHE.RUN then
            actor:SetMoveTo(nextAction.pos)
            actor:SetAction(global.MMO.ACTION_RUN)
            actor:SetConfirmed(true)

        elseif nextAction.act == ACTION_CACHE.RIDE_RUN then
            actor:SetMoveTo(nextAction.pos)
            actor:SetAction(global.MMO.ACTION_RIDE_RUN)
            actor:SetConfirmed(true)

        elseif nextAction.act == ACTION_CACHE.SKILL_ACTION then
            local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
            SkillProxy:actorEnterAction(nextAction.jsonData, nextAction.isMagic)

            local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
            SkillProxy:requestSkillPresent(nextAction.jsonData, 1)

            if nextAction.skillStage == 2 then
                local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
                SkillProxy:requestSkillPresent(nextAction.jsonData, 2)
            end
            actor.skillStage = nextAction.skillStage
            actor.skillID = nextAction.jsonData.MagicID

        elseif nextAction.act == ACTION_CACHE.SKILL_ACTION_MAGIC then
            local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
            SkillProxy:actorEnterAction(nextAction.jsonData, nextAction.isMagic)
            SkillProxy:requestSkillPresent(nextAction.jsonData, 3)
        
        elseif nextAction.act == ACTION_CACHE.DASH then
            local msgHdr    = nextAction.msgHdr
            local mapX      = msgHdr.param1
            local mapY      = msgHdr.param2
            local dir       = msgHdr.param3
            local time      = msgHdr.recog * 0.001
            if ((mapX ~= actor:GetMapX() or mapY ~= actor:GetMapY())) and time > 0 then
                actorUtils.actorDash(actor, mapX, mapY, dir, time)
            else
                isIdleAction = true
            end

        elseif nextAction.act == ACTION_CACHE.ONDASH then
            local msgHdr    = nextAction.msgHdr
            local mapX      = msgHdr.param1
            local mapY      = msgHdr.param2
            local dir       = msgHdr.param3
            local time      = msgHdr.recog
            local moveTime  = L16Bit(time) * 0.001
            local idleTime  = math.min(H16Bit(time) * 0.001, 5)
            if ((mapX ~= actor:GetMapX() or mapY ~= actor:GetMapY())) and moveTime > 0 then
                actorUtils.actorOnDash(actor, mapX, mapY, dir, moveTime, idleTime)
            else
                isIdleAction = true
            end
        
        elseif nextAction.act == ACTION_CACHE.SBYS then
            local msgHdr    = nextAction.msgHdr
            local mapX      = msgHdr.param1
            local mapY      = msgHdr.param2
            local dir       = msgHdr.param3
            if (mapX ~= actor:GetMapX() or mapY ~= actor:GetMapY()) then
                actorUtils.actorSBYS(actor, mapX, mapY, dir)
            else
                isIdleAction = true
            end

        elseif nextAction.act == ACTION_CACHE.QLS then
            local msgHdr    = nextAction.msgHdr
            local mapX      = msgHdr.param1
            local mapY      = msgHdr.param2
            local dir       = msgHdr.param3
            if (mapX ~= actor:GetMapX() or mapY ~= actor:GetMapY()) then
                actorUtils.actorQLS(actor, mapX, mapY, dir)
            else
                isIdleAction = true
            end
        elseif nextAction.act == ACTION_CACHE.ZXC then 
            local msgHdr    = nextAction.msgHdr
            local mapX      = msgHdr.param1
            local mapY      = msgHdr.param2
            local dir       = H16Bit(msgHdr.param3) == 0 and L16Bit(msgHdr.param3) or L16Bit(msgHdr.param3)
            local time      = msgHdr.recog * 0.001
            if ((mapX ~= actor:GetMapX() or mapY ~= actor:GetMapY())) and time > 0 then
                actorUtils.actorZhuiXinCi(actor, mapX, mapY, dir, time)
            else
                isIdleAction = true
            end
        
        else
            isIdleAction = true
        end

    elseif act == global.MMO.ACTION_DIE or act == global.MMO.ACTION_DEATH then
    elseif act == global.MMO.ACTION_CAVE then
    else
        isIdleAction = true
    end

    if isIdleAction then
        --移动优化
        if act == global.MMO.ACTION_WALK or act == global.MMO.ACTION_RUN or act == global.MMO.ACTION_RIDE_RUN or act == global.MMO.ACTION_ASSASSIN_SNEAK then
            actor:setPosition(actor.mTargePos.x, actor.mTargePos.y)
        end
        actor:SetAction(global.MMO.ACTION_IDLE)
    end
end

function netActorController:handleActionProcess(actor)
end

-----------------------------------------------------------------------------
function netActorController:handleActorOutOfView(actor)
    self.mNextActionCache[actor:GetID()] = nil
end

function netActorController:handle_Die(actor, msgHdr, msgData)
    self:SyncLatestPosition(actor, false)
    self.mNextActionCache[actor:GetID()] = nil

    -- 死亡时不拉坐标了，会闪现
    global.actorManager:SetActorMapXY(actor, msgHdr.param1, msgHdr.param2)
    actor:stopAnimToFrame(nil)
    actor:SetAction(global.MMO.ACTION_DIE, true)
end

function netActorController:handle_DeathSkeleton(actor, msgHdr, msgData)
    self:SyncLatestPosition(actor, false)
    self.mNextActionCache[actor:GetID()] = nil

    -- 死亡时不拉坐标了，会闪现
    global.actorManager:SetActorMapXY(actor, msgHdr.param1, msgHdr.param2)
    actor:stopAnimToFrame(nil)
    actor:SetAction(global.MMO.ACTION_DEATH, true)
end

function netActorController:handle_Revive(actor, jsonData)
    self.mNextActionCache[actor:GetID()] = nil

    -- feature
    if jsonData.Hp and jsonData.MaxHp then
        actor:SetHPHUD(jsonData.Hp, jsonData.MaxHp)
    end

    -- To map grid position
    local actorPos = global.sceneManager:MapPos2WorldPos(jsonData.X, jsonData.Y, true)
    local action = actor:IsMonster() and global.MMO.ACTION_BORN or global.MMO.ACTION_IDLE

    actor:SetConfirmed(true)
    actor:SetIsArrived(true)
    actor:stopAnimToFrame(nil)
    actor:setPosition(actorPos.x, actorPos.y)
    actor:SetDirection(jsonData.Dir)
    actor:SetAction(action, true)
    actor:dirtyAnimFlag()
    global.actorManager:SetActorMapXY(actor, jsonData.X, jsonData.Y)

    local noticeData = {}
    noticeData.actor   = actor
    noticeData.actorID = jsonData.UserID
    global.Facade:sendNotification(global.NoticeTable.ActorRevive, noticeData)
end

function netActorController:handleActorSitdown(actor, jsonData)
    -- 死亡状态无法切换
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    if global.MMO.ACTION_IDLE == actor:GetAction() then
        actor:SetDirection(jsonData.Dir)
        actor:SetAction(global.MMO.ACTION_SITDOWN)
    else
        -- Another action is running
        local netAct    = {}
        netAct.act      = ACTION_CACHE.SITDOWN
        netAct.Dir      = jsonData.Dir
        if self.mNextActionCache[actor:GetID()] == nil then
            self.mNextActionCache[actor:GetID()] = {}
        end
        table.insert(self.mNextActionCache[actor:GetID()], netAct)
    end

    self:CheckFastCurrentAction(actor)
end

function netActorController:handleActorMining(actor, jsonData)
    -- 死亡状态无法切换
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    if global.MMO.ACTION_IDLE == actor:GetAction() then
        actor:SetDirection(jsonData.Dir)
        actor:SetAction(global.MMO.ACTION_MINING)
    else
        -- Another action is running
        local netAct    = {}
        netAct.act      = ACTION_CACHE.MINING
        netAct.Dir      = jsonData.Dir
        if self.mNextActionCache[actor:GetID()] == nil then
            self.mNextActionCache[actor:GetID()] = {}
        end
        table.insert(self.mNextActionCache[actor:GetID()], netAct)
    end

    self:CheckFastCurrentAction(actor)
end

function netActorController:handle_MSG_SC_ACTOR_WALK(actor, msgHdr)
    -- 死亡状态无法切换
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    local p = { x = msgHdr.param1, y = msgHdr.param2 }

    if global.MMO.ACTION_IDLE == actor:GetAction() then
        local act = global.MMO.ACTION_WALK
        if actor:GetValueByKey(global.MMO.ACT_SNEAK) then
            act = global.MMO.ACTION_ASSASSIN_SNEAK
        end

        actor:SetMoveTo(p)
        actor:SetAction(act)
        actor:SetConfirmed(true)
    else
        -- Another action is running
        local act = ACTION_CACHE.WALK
        if actor:GetValueByKey(global.MMO.ACT_SNEAK) then
            act = ACTION_CACHE.SNEAK
        end

        local netAct    = {}
        netAct.act      = act
        netAct.pos      = p
        if self.mNextActionCache[actor:GetID()] == nil then
            self.mNextActionCache[actor:GetID()] = {}
        end
        table.insert(self.mNextActionCache[actor:GetID()], netAct)
    end

    self:CheckFastCurrentAction(actor)
end

function netActorController:handle_MSG_SC_ACTOR_RUN(actor, msgHdr)
    -- 死亡状态无法切换
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    local p = { x = msgHdr.param1, y = msgHdr.param2 }

    if global.MMO.ACTION_IDLE == actor:GetAction() then
        actor:SetMoveTo(p)
        actor:SetAction(global.MMO.ACTION_RUN)
        actor:SetConfirmed(true)
    else
        -- Another action is running
        local netAct    = {}
        netAct.act      = ACTION_CACHE.RUN
        netAct.pos      = p
        if self.mNextActionCache[actor:GetID()] == nil then
            self.mNextActionCache[actor:GetID()] = {}
        end
        table.insert(self.mNextActionCache[actor:GetID()], netAct)
    end

    self:CheckFastCurrentAction(actor)
end

function netActorController:handle_MSG_SC_ACTOR_RIDE_RUN(actor, msgHdr)
    -- 死亡状态无法切换
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    local p = { x = msgHdr.param1, y = msgHdr.param2 }

    if global.MMO.ACTION_IDLE == actor:GetAction() then
        actor:SetMoveTo(p)
        actor:SetAction(global.MMO.ACTION_RIDE_RUN)
        actor:SetConfirmed(true)
    else
        -- Another action is running
        local netAct    = {}
        netAct.act      = ACTION_CACHE.RIDE_RUN
        netAct.pos      = p
        if self.mNextActionCache[actor:GetID()] == nil then
            self.mNextActionCache[actor:GetID()] = {}
        end
        table.insert(self.mNextActionCache[actor:GetID()], netAct)
    end

    self:CheckFastCurrentAction(actor)
end

function netActorController:handle_MSG_SC_ACTOR_STUCK(actor)
    -- 死亡状态无法切换
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    -- 受击弯腰，只保留一个
    if global.MMO.ACTION_IDLE == actor:GetAction() then
        actor:SetAction(global.MMO.ACTION_STUCK)
    else
        if self.mNextActionCache[actor:GetID()] == nil then
            self.mNextActionCache[actor:GetID()] = {}
        end
        local found = false
        for i, v in ipairs(self.mNextActionCache[actor:GetID()]) do
            if v.act == ACTION_CACHE.STUCK then
                found = true
                break
            end
        end
        if not found then
            local netAct = {}
            netAct.act = ACTION_CACHE.STUCK
            table.insert(self.mNextActionCache[actor:GetID()], netAct)
        end
    end

    self:CheckFastCurrentAction(actor)
end

function netActorController:handle_MSG_SC_NET_PLAYER_ATTACK(actor, msgHdr, jsonData)
    -- 死亡状态无法切换
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    if actor:IsMonster() and msgHdr.param3 > 0 then
        return nil
    end

    if global.MMO.ACTION_IDLE == actor:GetAction() then
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        SkillProxy:actorEnterAction(jsonData, false)
        SkillProxy:requestSkillPresent(jsonData, 3)
    else
        -- Another action is running
        local netAct = {}
        netAct.act      = ACTION_CACHE.SKILL_ACTION_MAGIC   
        netAct.msgHdr   = msgHdr
        netAct.jsonData = jsonData
        netAct.isMagic  = false
        if self.mNextActionCache[actor:GetID()] == nil then
            self.mNextActionCache[actor:GetID()] = {}
        end
        table.insert(self.mNextActionCache[actor:GetID()], netAct)
    end

    self:CheckFastCurrentAction(actor)
end

function netActorController:handle_MSG_SC_PLAYER_SKILL_LAUNCH_SUCCESS(actor, msgHdr, jsonData)
    -- 死亡状态无法切换
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    if global.MMO.ACTION_IDLE == actor:GetAction() then
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        SkillProxy:actorEnterAction(jsonData, true)
        SkillProxy:requestSkillPresent(jsonData, 1)
        actor.skillStage = 1
        actor.skillID = jsonData.MagicID
    else
        -- Another action is running
        local netAct = {}
        netAct.act          = ACTION_CACHE.SKILL_ACTION
        netAct.jsonData     = jsonData
        netAct.msgHdr       = msgHdr
        netAct.isMagic      = true
        netAct.skillStage   = 1
        if self.mNextActionCache[actor:GetID()] == nil then
            self.mNextActionCache[actor:GetID()] = {}
        end
        table.insert(self.mNextActionCache[actor:GetID()], netAct)
    end

    self:CheckFastCurrentAction(actor)
end

function netActorController:handle_MSG_SC_PLAYER_SKILL_MAGIC_SUCCESS(actor, msgHdr, jsonData)
    -- 死亡状态无法切换
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    if global.MMO.ACTION_IDLE == actor:GetAction() then
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        SkillProxy:requestSkillPresent(jsonData, 2)

    elseif (global.MMO.ACTION_ATTACK == actor:GetAction() or global.MMO.ACTION_SKILL == actor:GetAction() or CheckInSkillAction(actor:GetAction())) and actor.skillStage == 1 and actor.skillID == jsonData.MagicID then
        actor.skillStage = 2
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        SkillProxy:requestSkillPresent(jsonData, 2)
    else
        -- Another action is running
        if self.mNextActionCache[actor:GetID()] == nil then
            self.mNextActionCache[actor:GetID()] = {}
        end

        if jsonData.showSkillMaigc then
            local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
            SkillProxy:requestSkillPresent(jsonData, 3)
        else
            for i, v in ipairs(self.mNextActionCache[actor:GetID()]) do
                if v.act == ACTION_CACHE.SKILL_ACTION and v.skillStage == 1 then
                    v.msgHdr = msgHdr
                    v.jsonData = jsonData
                    v.skillStage = 2
                    break
                end
            end
        end
    end
end

function netActorController:handle_MSG_SC_PLAYER_SKILL_27_SUCCESS(actor, msgHdr)
    -- 野蛮
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    local mapX    = msgHdr.param1
    local mapY    = msgHdr.param2
    local dir     = H16Bit(msgHdr.param3) == 0 and L16Bit(msgHdr.param3) or L16Bit(msgHdr.param3)
    local time    = msgHdr.recog * 0.001
    local skillId = H16Bit(msgHdr.param3) > 0 and H16Bit(msgHdr.param3) or 0

    if skillId == 0 then 
        if global.MMO.ACTION_IDLE == actor:GetAction() then
            if (mapX ~= actor:GetMapX() or mapY ~= actor:GetMapY()) and time > 0 then
                actorUtils.actorDash(actor, mapX, mapY, dir, time)
            else
                --执行野蛮失败撞墙动作
                actor:SetAction(global.MMO.ACTION_DASH_FAIL)
            end        
        else
            if (mapX ~= actor:GetMapX() or mapY ~= actor:GetMapY()) and time > 0 then
                -- Another action is running
                local netAct = {}
                netAct.act      = ACTION_CACHE.DASH
                netAct.msgHdr   = msgHdr
                if self.mNextActionCache[actor:GetID()] == nil then
                    self.mNextActionCache[actor:GetID()] = {}
                end
                table.insert(self.mNextActionCache[actor:GetID()], netAct)
            end
        end
    else 
        if global.MMO.ACTION_IDLE == actor:GetAction() then
            if (mapX ~= actor:GetMapX() or mapY ~= actor:GetMapY()) and time > 0 then
                actorUtils.actorZhuiXinCi(actor, mapX, mapY, dir)
            end
        else
            -- Another action is running
            local netAct = {}
            netAct.act      = ACTION_CACHE.ZXC
            netAct.msgHdr   = msgHdr
            if self.mNextActionCache[actor:GetID()] == nil then
                self.mNextActionCache[actor:GetID()] = {}
            end
            table.insert(self.mNextActionCache[actor:GetID()], netAct)
        end
    end 

    self:CheckFastCurrentAction(actor)
end

function netActorController:handle_MSG_SC_PLAYER_SKILL_27_BACKSTEP(actor, msgHdr)
    -- 被野蛮，被推开
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    local mapX      = msgHdr.param1
    local mapY      = msgHdr.param2
    local dir       = msgHdr.param3
    local time      = msgHdr.recog
    local moveTime  = L16Bit(time) * 0.001
    local idleTime  = math.min(H16Bit(time) * 0.001, 5)

    if global.MMO.ACTION_IDLE == actor:GetAction() then
        if (mapX ~= actor:GetMapX() or mapY ~= actor:GetMapY()) and  moveTime > 0 then
            actorUtils.actorOnDash(actor, mapX, mapY, dir, moveTime, idleTime)
        end
    else
        -- Another action is running
        local netAct = {}
        netAct.act      = ACTION_CACHE.ONDASH
        netAct.msgHdr   = msgHdr
        if self.mNextActionCache[actor:GetID()] == nil then
            self.mNextActionCache[actor:GetID()] = {}
        end
        table.insert(self.mNextActionCache[actor:GetID()], netAct)
    end

    self:CheckFastCurrentAction(actor)
end

function netActorController:handle_MSG_SC_PLAYER_SKILL_82_SUCCESS(actor, msgHdr)
    -- 十步一杀 瞬移
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    local mapX = msgHdr.param1
    local mapY = msgHdr.param2
    local dir = msgHdr.param3

    if global.MMO.ACTION_IDLE == actor:GetAction() then
        if( mapX ~= actor:GetMapX() or mapY ~= actor:GetMapY()) then
            actorUtils.actorSBYS(actor, mapX, mapY, dir)
        end
    else
        -- Another action is running
        local netAct = {}
        netAct.act      = ACTION_CACHE.SBYS
        netAct.msgHdr   = msgHdr
        if self.mNextActionCache[actor:GetID()] == nil then
            self.mNextActionCache[actor:GetID()] = {}
        end
        table.insert(self.mNextActionCache[actor:GetID()], netAct)
    end

    self:CheckFastCurrentAction(actor)
end

function netActorController:handle_MSG_SC_PLAYER_SKILL_71_SUCCESS(actor, msgHdr)
    -- 擒龙手 瞬移
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    local mapX = msgHdr.param1
    local mapY = msgHdr.param2
    local dir = msgHdr.param3

    if global.MMO.ACTION_IDLE == actor:GetAction() then
        if (mapX ~= actor:GetMapX() or mapY ~= actor:GetMapY()) then
            actorUtils.actorQLS(actor, mapX, mapY, dir)
        end
    else
        -- Another action is running
        local netAct = {}
        netAct.act      = ACTION_CACHE.QLS
        netAct.msgHdr   = msgHdr
        if self.mNextActionCache[actor:GetID()] == nil then
            self.mNextActionCache[actor:GetID()] = {}
        end
        table.insert(self.mNextActionCache[actor:GetID()], netAct)
    end

    self:CheckFastCurrentAction(actor)
end

function netActorController:handle_Move_Force(actor, jsonData)
    self.mNextActionCache[actor:GetID()] = nil

    local posOfAccepted = global.sceneManager:MapPos2WorldPos(jsonData.mapX, jsonData.mapY, true)
    actor:SetAction(global.MMO.ACTION_IDLE, true)
    actor.mIsArrived = true
    actor.mIsConfirmed = true
    actor:SetDirection(jsonData.dir)
    actor:setPosition(posOfAccepted.x, posOfAccepted.y)

    global.actorManager:SetActorMapXY(actor, jsonData.mapX, jsonData.mapY)
end

function netActorController:handle_FlyIn(actor, msgHdr)
    self.mNextActionCache[actor:GetID()] = nil

    local mapX = msgHdr.param1
    local mapY = msgHdr.param2
    local dir  = msgHdr.param3
    local posOfAccepted = global.sceneManager:MapPos2WorldPos(mapX, mapY, true)
    actor:SetAction(global.MMO.ACTION_IDLE, true)
    actor:SetIsArrived(true)
    actor:SetConfirmed(true)    
    actor:SetDirection(dir)
    actor:setPosition(posOfAccepted.x, posOfAccepted.y)

    global.actorManager:SetActorMapXY( actor, mapX, mapY )
end

function netActorController:handle_FlyIn2(actor, msgHdr)
    self.mNextActionCache[actor:GetID()] = nil

    local mapX = msgHdr.param1
    local mapY = msgHdr.param2
    local dir  = msgHdr.param3
    local posOfAccepted = global.sceneManager:MapPos2WorldPos(mapX, mapY, true)
    actor:SetAction(global.MMO.ACTION_IDLE, true)
    actor:SetIsArrived(true)
    actor:SetConfirmed(true)    
    actor:SetDirection(dir)
    actor:setPosition(posOfAccepted.x, posOfAccepted.y)

    global.actorManager:SetActorMapXY( actor, mapX, mapY )
end

function netActorController:cleanupCacheByActorID(actorID)
    self.mNextActionCache[actorID] = nil
end

function netActorController:SyncLatestPosition(actor, updateCurrPosition)
    local p1 = self.mNextActionCache[actor:GetID()]
    if p1 == nil then p1 = {} end
    local lastMoveAct = nil

    for k, v in pairs(p1) do
        local netAct = v
        if ACTION_CACHE.WALK == netAct.act or ACTION_CACHE.RUN == netAct.act or ACTION_CACHE.RIDE_RUN == netAct.act then
            lastMoveAct = netAct
        end
    end

    if lastMoveAct then
        local mapX = lastMoveAct.pos.x
        local mapY = lastMoveAct.pos.y
        local targetPos = global.sceneManager:MapPos2WorldPos(mapX, mapY, true)
        actor:setPosition(targetPos.x, targetPos.y)
        global.actorManager:SetActorMapXY(actor, mapX, mapY)

    elseif updateCurrPosition then
        if actor.mCurrentActT > 0.0001 then
            actor:SetCurrActTime(0)
            local mapX = actor:GetMapX()
            local mapY = actor:GetMapY()
            local targetPos = global.sceneManager:MapPos2WorldPos(mapX, mapY, true)
            actor:setPosition(targetPos.x, targetPos.y)
        end
    end

    -- reset state
    actor:SetIsArrived(true)
    actor:SetConfirmed(true)
end

function netActorController:CheckFastCurrentAction(actor)
    -- if not ((actor:IsPlayer() or actor:IsMonster())) then
    --     return
    -- end

    -- if global.MMO.ACTION_IDLE == actor:GetAction() then
    --     return
    -- end
end

function netActorController:handle_ActorMapXYChange(actor, mapX, mapY)
    global.Facade:sendNotification(global.NoticeTable.ActorMapXYChange, { actor = actor, actorID = actor:GetID() })
end

function netActorController:handle_MSG_SC_NET_MONSTER_BORN(actor, msgHdr, msgData)
end

function netActorController:handle_MSG_SC_NET_MONSTER_CAVE(actor, msgHdr, msgData)
end

return netActorController