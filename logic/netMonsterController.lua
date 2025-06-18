local netActorController = require("logic/netActorController")
local netMonsterController = class("netMonsterController",netActorController)
netMonsterController.NAME = "netMonsterController"

function netMonsterController:ctor()
    netMonsterController.super.ctor(self)
    
    self:RegisterMsgHandler()
end

function netMonsterController:destory()
    netMonsterController.super.destory(self)

    if netMonsterController.instance then
        netMonsterController.instance = nil
    end
end

function netMonsterController:Inst()
    if not netMonsterController.instance then
        netMonsterController.instance = netMonsterController.new()
    end

    return netMonsterController.instance
end

function netMonsterController:RegisterMsgHandler()
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_MONSTER_OWNER, handler( self, self.handle_MSG_SC_MONSTER_OWNER))
end

function netMonsterController:handle_MSG_SC_MONSTER_OWNER(msg)
    local msgLen = msg:GetDataLength()
    if msgLen == 0 then
        return -1
    end
    local dataString = msg:GetData():ReadString(msgLen)
    local slices = string.split(dataString, ",")

    local actorID   = slices[1]
    local ownerID   = slices[2] or ""
    local ownerName = slices[3] or ""
    local actor     = global.actorManager:GetActor( actorID )

    if not actor or not actor:IsMonster() then
        return -1
    end

    actor:SetOwnerID( ownerID )
    actor:SetOwnerName( ownerName )

    global.Facade:sendNotification(global.NoticeTable.ActorOwnerChange, {actorID = actorID, actor = actor})
    SLBridge:onLUAEvent(LUA_EVENT_ACTOR_OWNER_CHANGE, {actorID = actorID})
    return 1
end

function netMonsterController:AddNetMonsterToWorld( param )
    local id         = param.actorID
    local netMonster = global.actorManager:CreateActor( id, global.MMO.ACTOR_MONSTER, param )
    if nil == netMonster then
        return nil
    end

    -- bind handler
    netMonster:SetGameActorActionHandler( self )


    -- HUD for actor
    local clothID = param.clothID or 0
    netMonster:SetDirection( param.dir or global.MMO.ORIENT_U )
    netMonster:SetTypeIdex( clothID )
    netMonster:SetAction( param.action or global.MMO.ACTION_IDLE )
    netMonster:SetClothID( clothID )

    -- 
    local refreshData = {}
    refreshData.actor = netMonster
    refreshData.actorID = param.actorID
    global.Facade:sendNotification(global.NoticeTable.DelayCreateHUDBar, refreshData)

    -- feature
    global.Facade:sendNotification( global.NoticeTable.DelayDirtyFeature, {actorID = id, actor = netMonster})

    return netMonster
end

function netMonsterController:Cleanup( cleanHandler )
    netMonsterController.super.Cleanup(self, cleanHandler)
end

function netMonsterController:handleActionBegin( actor, act )
    netMonsterController.super.handleActionBegin(self, actor, act)

    -- monster audio
    local clothID = actor:GetAnimationID()
    if act == global.MMO.ACTION_DIE then
        -- global.Facade:sendNotification( global.NoticeTable.Audio_Play, {type=global.MMO.SND_TYPE_MON_DIE, index=clothID} )
    elseif act == global.MMO.ACTION_ATTACK then
        global.Facade:sendNotification( global.NoticeTable.Audio_Play, {type=global.MMO.SND_TYPE_MON_ATTACK, index=clothID} )
    elseif act == global.MMO.ACTION_WALK or act == global.MMO.ACTION_RUN then
        global.Facade:sendNotification( global.NoticeTable.Audio_Play, {type=global.MMO.SND_TYPE_MON_MOVE, index=clothID} )
    elseif act == global.MMO.ACTION_BORN then
        global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type=global.MMO.SND_TYPE_MON_BORN, index=clothID})
    end
end

function netMonsterController:handleActionCompleted(actor, act)
    netMonsterController.super.handleActionCompleted(self, actor, act)

    -- 大刀坐标恢复
    if actor:GetRaceServer() == global.MMO.ACTOR_SERVER_RACE_KNIEF then
        local wPos = global.sceneManager:MapPos2WorldPos( actor:GetMapX(), actor:GetMapY(), true )
        local dir = GetActorAttrByID(actor:GetID(), global.MMO.ACTOR_ATTR_DIR)
        actor:setPosition( wPos.x, wPos.y )
        actor:SetDirection(dir)
    end

    -- 出生完成，广播
    if act == global.MMO.ACTION_BORN then
        global.Facade:sendNotification(global.NoticeTable.ActorMonsterBirth, {actorID = actor:GetID(), actor = actor})
    elseif act == global.MMO.ACTION_CAVE then
        if not actor:IsSleepInCave() then
            actor:SetSleepInCave(true)
            actor:SetKeyValue(global.MMO.Is_Cave, true)
            global.Facade:sendNotification(global.NoticeTable.ActorMonsterCaved, {actorID = actor:GetID(), actor = actor})
        end
    end
end

function netMonsterController:handle_Revive(actor, jsonData)
    netMonsterController.super.handle_Revive(self, actor, jsonData)

    if actor:IsWall() and jsonData.Dir then
        actor:stopAnimToFrame(jsonData.Dir+1)
        actor:updateAnimation()
    end
end

function netMonsterController:handle_MSG_SC_PLAYER_SKILL_MAGIC_SUCCESS(actor, msgHdr, jsonData)
    -- 死亡状态无法切换
    if actor:IsDie() or actor:IsDeath() then
        return nil
    end

    if global.MMO.ACTION_IDLE == actor:GetAction() then
        local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        if jsonData.Hit == 1 then
            SkillProxy:actorEnterAction(jsonData, true)
            SkillProxy:requestSkillPresent(jsonData, 1)
        end
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

        if jsonData.showSkillMaigc then -- 纯技能表现  不执行技能动作
            local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
            SkillProxy:requestSkillPresent(jsonData, 3)
        else
            local isAddAction = true
            for i, v in ipairs(self.mNextActionCache[actor:GetID()]) do
                if v.act == 5 and v.skillStage == 1 then
                    isAddAction = false
                    break
                end
            end

            if isAddAction then
                local netAct = {}
                netAct.act          = 5
                netAct.jsonData     = jsonData
                netAct.msgHdr       = msgHdr
                netAct.isMagic      = true
                netAct.skillStage   = 2
                table.insert(self.mNextActionCache[actor:GetID()], netAct)
            end
        end
    end
end

function netMonsterController:handle_Revive(actor, jsonData)
    netMonsterController.super.handle_Revive(self, actor, jsonData)

    if actor:IsGate() then
        local dir = jsonData.Dir or 0
        actor:setGateOpenState(dir >= 3)
        actor:SetKeyValue(global.MMO.Is_Gate, true)

    elseif actor:IsWall() then
        local dir = jsonData.Dir or 0
        actor:SetKeyValue(global.MMO.Is_Wall, true)
        actor:stopAnimToFrame(dir + 1)
        actor:SetAction(global.MMO.ACTION_IDLE)
        actor:updateAnimation()
    end
end

function netMonsterController:handle_MSG_SC_NET_MONSTER_BORN(actor, msgHdr, msgData)
    self.mNextActionCache[actor:GetID()] = nil

    local dir = msgHdr.recog
    local mapX = msgHdr.param1
    local mapY = msgHdr.param2

    if actor:IsGate() then
        actor:setGateOpenState(dir >= 3)
        actor:SetKeyValue(global.MMO.Is_Gate, true)

    elseif actor:IsWall() then
        actor:SetKeyValue(global.MMO.Is_Wall, true)
        actor:stopAnimToFrame(dir + 1)
        actor:SetAction(global.MMO.ACTION_IDLE)
        actor:updateAnimation()
    else
        global.actorManager:SetActorMapXY(actor, mapX, mapY)
        local worldPos = global.sceneManager:MapPos2WorldPos(mapX, mapY, true)
        actor:setPosition(worldPos.x, worldPos.y)
        actor:SetDirection(dir)
        actor:stopAnimToFrame(nil)
        actor:SetStoneMode(false)
        actor:SetSleepInCave(false)
        actor:SetAction(global.MMO.ACTION_BORN)
        actor:SetKeyValue(global.MMO.Is_Cave, false)
    
        global.Facade:sendNotification(global.NoticeTable.ActorMonsterBorn, {actorID = actor:GetID(), actor = actor})
    end
end

function netMonsterController:handle_MSG_SC_NET_MONSTER_CAVE(actor, msgHdr, msgData)
    self.mNextActionCache[actor:GetID()] = nil

    local dir = msgHdr.recog
    local mapX = msgHdr.param1
    local mapY = msgHdr.param2

    global.actorManager:SetActorMapXY(actor, mapX, mapY)
    local worldPos = global.sceneManager:MapPos2WorldPos(mapX, mapY, true)
    actor:setPosition(worldPos.x, worldPos.y)
    actor:SetDirection(dir)
    
    if actor:IsGate() then
        actor:setGateOpenState(dir >= 3)
        actor:SetAction(global.MMO.ACTION_BORN)
    elseif actor:IsFollowDog() then
        actor:SetAction(global.MMO.ACTION_CHANGESHAPE)
    else
        actor:SetAction(global.MMO.ACTION_CAVE)
        global.Facade:sendNotification(global.NoticeTable.ActorMonsterCave, {actorID = actor:GetID(), actor = actor})
    end
end


return netMonsterController
