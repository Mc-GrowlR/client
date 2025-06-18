local GameActorSkillController = class("GameActorSkillController")
GameActorSkillController.NAME = "GameActorSkillController"

function GameActorSkillController:ctor()
    self._jointCache = {}

    self:RegisterMsgHandler()
    self._klaunchQueue = {}
    self._mainPlayerAddDashTime = 0
end

function GameActorSkillController:destory()
    if GameActorSkillController.instance then
        GameActorSkillController.instance = nil
    end
end

function GameActorSkillController:Inst()
    if not GameActorSkillController.instance then
        GameActorSkillController.instance = GameActorSkillController.new()
    end

    return GameActorSkillController.instance
end

function GameActorSkillController:GetMainPlayerAddDashTime()
    return self._mainPlayerAddDashTime
end

function GameActorSkillController:SetMainPlayerAddDashTime(t)
    self._mainPlayerAddDashTime = t
end

local function handle_MSG_SC_PLAYER_SKILL_27_SUCCESS(msg)
    local msgHdr  = msg:GetHeader()
    local msgLen  = msg:GetDataLength()
    local actorID = msgLen > 0 and msg:GetData():ReadString(msgLen) or ""
    if not actorID then
        return nil
    end
    local mapX    = msgHdr.param1
    local mapY    = msgHdr.param2
    local dir     = msgHdr.param3
    local time    = msgHdr.recog

    local actor  = global.actorManager:GetActor(actorID)
    if not actor then
        return -1
    end
    if actor:GetMapX() == mapX and actor:GetMapY() == mapY and not actor:IsPlayer() then
        return -1
    end

    if actor:IsMonster() then
        global.netMonsterController:handle_MSG_SC_PLAYER_SKILL_27_SUCCESS(actor, msgHdr)
    elseif actor:IsPlayer() then
        if actor:IsMainPlayer() then
            global.gamePlayerController:handle_MSG_SC_PLAYER_SKILL_27_SUCCESS(actor, msgHdr)
        else
            global.netPlayerController:handle_MSG_SC_PLAYER_SKILL_27_SUCCESS(actor, msgHdr)
        end
    end

    return 1
end

local function handle_MSG_SC_PLAYER_SKILL_27_BACKSTEP(msg)
    local msgHdr  = msg:GetHeader()
    local msgLen  = msg:GetDataLength()
    local actorID = msgLen > 0 and msg:GetData():ReadString(msgLen) or ""
    if not actorID then
        return nil
    end
    local mapX      = msgHdr.param1
    local mapY      = msgHdr.param2
    local dir       = msgHdr.param3
    local time      = msgHdr.recog

    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return -1
    end
    if actor:GetMapX() == mapX and actor:GetMapY() == mapY then
        return -1
    end

    if actor:IsMonster() then
        global.netMonsterController:handle_MSG_SC_PLAYER_SKILL_27_BACKSTEP(actor, msgHdr)
    elseif actor:IsPlayer() then
        if actor:IsMainPlayer() then
            global.gamePlayerController:handle_MSG_SC_PLAYER_SKILL_27_BACKSTEP(actor, msgHdr)
        else
            global.netPlayerController:handle_MSG_SC_PLAYER_SKILL_27_BACKSTEP(actor, msgHdr)
        end
    end

    return 1
end

function GameActorSkillController:handle_MSG_SC_SKILL_HIT_MISS(msg)
    local msgLen = msg:GetDataLength()
    local dataString = msg:GetData():ReadString(msgLen)
    self._hitMissUserID = dataString
end

function GameActorSkillController:getHitMissUserID()
    return self._hitMissUserID
end

function GameActorSkillController:resetHitMissUserID()
    self._hitMissUserID = nil
end

function GameActorSkillController:handle_MSG_SC_JOINT_SKILL_PRESENT(msg)
    -- local jsonData = ParseRawMsgToJson( msg )
    -- if not jsonData then
    --     return -1
    -- end
     local header = msg:GetHeader()
    local msgLen = msg:GetDataLength()
    local userid  = ""
    local target = ""
    if msgLen>0 then
        local strs = msg:GetData():ReadString(msgLen)
        dump(strs,"strs____")
        local ss = string.split(strs,"#")
        userid = ss[1]
        if #ss>1 then
            table.remove(ss,1)
            target = table.concat(ss,"#")
        end
    end

    dump(header,"msgHdr____") 
    dump(userid,"userid")
    dump(target,"target___")
    local  magicid = header.recog
    local jsonData = {}
    jsonData.magicid =magicid
    jsonData.userid =userid
    jsonData.x = header.param1
    jsonData.y = header.param2
    jsonData.dir = header.param3
    jsonData.target = target
    local actorID   = jsonData.userid
    local actor     = global.actorManager:GetActor(actorID)
    if not actor then
        print("joint skill launcher is Miss!!!!!!!")
        return -1
    end
    if not actor:IsPlayer() then
        return -1
    end

    if actorID == global.gamePlayerController:GetMainPlayerID() then


        if actor:GetAction() == global.MMO.ACTION_WALK or actor:GetAction() == global.MMO.ACTION_RUN then
            table.insert(self._jointCache, jsonData)
            return -1
        end
    end

    self:launchJointSkill(jsonData)
    return 1
end

function GameActorSkillController:handle_MSG_SC_JOINT_SKILL_PRESENT_HIT(msg)
    local header = msg:GetHeader()
    local msgLen = msg:GetDataLength()
    local userid  = ""
    if msgLen>0 then
        userid = msg:GetData():ReadString(msgLen)
    end
    dump(header,"handle_MSG_SC_JOINT_SKILL_PRESENT_HIT__")
    local actorID   = userid
    
    local actor     = global.actorManager:GetActor(actorID)
    if not actor then
        return -1
    end
    local skillID  = header.param1

    local root = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_SKILL)
    local skillData  = global.skillManager:getSkillDataByID(skillID)
    local animID 
    local func = function(sender, eventType)
                sender:removeFromParent()
            end
    local anim
    repeat 
        animID = skillData and skillData.hitID
        anim = global.FrameAnimManager:CreateSkillEffAnim(animID)
        root:addChild(anim)
        anim:setPosition(cc.pAdd(actor:getPosition(), global.MMO.PLAYER_AVATAR_OFFSET))
        anim:setLocalZOrder(animID)
        anim:Play(0, 0, true)
        anim:SetAnimEventCallback(func) 
        if skillData.linkSkill and skillData.linkSkill >= 1 then
            skillData = global.skillManager:getSkillDataByID(skillData.linkSkill)
        else
            skillData = nil
        end
    until not skillData
    return 1
end
function GameActorSkillController:handle_MSG_SC_HERO_EFFECT(msg)
    local header = msg:GetHeader()
    local msgLen = msg:GetDataLength()
    local userid  = ""
    if msgLen>0 then
        userid = msg:GetData():ReadString(msgLen)
    end
    local animID  = header.param1
    -- dump(header,"header____")
    -- dump(userid,"userid__")
    local anim = global.FrameAnimManager:CreateSFXAnim( animID  )
    local actor     = global.actorManager:GetActor(userid)
    -- dump(actor,"actor__")
    local func = function(sender, eventType)
                    sender:removeFromParent()
                end
    if actor then
        actor:GetNode():addChild( anim )
        anim:setLocalZOrder(animID)
        anim:Play(0, 0, true)
        anim:SetAnimEventCallback(func) 
    end
end

function GameActorSkillController:launchJointSkill(jsonData)
    local actorID   = jsonData.userid
    local targetID  = jsonData.target or ""
    local srcX      = jsonData.x or 0
    local srcY      = jsonData.y or 0
    local hitX      = jsonData.tx or 0
    local hitY      = jsonData.ty or 0
    local dir       = jsonData.dir or 0
    local skillID   = jsonData.magicid

    local actor     = global.actorManager:GetActor(actorID)
    if not actor then
        return -1
    end

    if not actor:IsPlayer() then
        return -1
    end
    
    -- 防止后退
    if actorID == global.gamePlayerController:GetMainPlayerID() then
        global.Facade:sendNotification(global.NoticeTable.InputIdle)
       -- local InputControllerClass = requireMediator( "role/PlayerInputController" )
       -- local inputController      = global.Facade:retrieveMediator( InputControllerClass.NAME )
        --inputController:SetInputState( global.MMO.INPUT_STATE_LAUNCH )
        if CHECK_SETTING(global.MMO.SETTING_IDX_HERO_JOINT_SHAKE) == 1 then
            global.Facade:sendNotification( global.NoticeTable.ShakeScene)--震动
        end
    else
        -- some property
        local worldPos      = global.sceneManager:MapPos2WorldPos(srcX, srcY, true)
        actor:SetDirection(dir)
        actor:setPosition(worldPos.x, worldPos.y)
        global.actorManager:SetActorMapXY( actor, srcX, srcY )
    end

    actor:StopAllAnimation()

    local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local skillConfig = skillProxy:FindConfigBySkillID(skillID)
    -- action
    local actorJob = actor:GetJobID()
    local action =
    {
        skillID = skillID,
        actor = actor,
        dir = dir,
    }
    if actorJob == global.MMO.ACTOR_PLAYER_JOB_FIGHTER then
        global.Facade:sendNotification(global.NoticeTable.ActorEnterAttackAction, action)
    else
        global.Facade:sendNotification(global.NoticeTable.ActorEnterSkillAction, action)
    end
    actor:SetConfirmed(true)

    -- skill present
   -- local presentID     = string.format("%s%s", skillID, actorJob)
   -- presentID           = tonumber(presentID)
    local present       = 
    {
        skillID     = skillID,--presentID,
        launchX     = actor:GetMapX(),
        launchY     = actor:GetMapY(),
        hitX        = hitX,
        hitY        = hitY,
        dir         = dir,
        param       = targetID,
        --launchOnly  = (not actor:IsHero()),
        skillStage  = (not actor:IsHero() and 1 or nil),
        needFly     = true,
        
        launcherID  = actorID,
    }
    global.Facade:sendNotification(global.NoticeTable.RequestSkillPresent, present)
end
function GameActorSkillController:CheckKLaunchAble()
    return #self._klaunchQueue > 0
end

function GameActorSkillController:handle_MSG_SC_SERVER_SKILL_RESP(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return nil
    end
    dump(jsonData)

    table.insert(self._klaunchQueue, jsonData)
end

function GameActorSkillController:RequestLaunchServerSkill()
    -- 特殊处理的服务器触发技能，真神奇
    if #self._klaunchQueue == 0 then
        return nil
    end
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return nil
    end
    local sendData = table.remove(self._klaunchQueue, 1)
    SendTableToServer(global.MsgType.MSG_CS_SERVER_SKILL_LAUNCH, sendData)

    if sendData.MagId then
        local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        local skillConfig = skillProxy:FindConfigBySkillID(sendData.MagId)
        if skillConfig then
            -- present
            local present =
            {
                skillID = skillProxy:GetSkillPresentReplaceID(sendData.MagId),
                launchX = mainPlayer:GetMapX(),
                launchY = mainPlayer:GetMapY(),
                dir     = mainPlayer:GetDirection(),
                skillStage = 1,
                launcherID = mainPlayer:GetID()
            }
            global.Facade:sendNotification(global.NoticeTable.RequestSkillPresent, present)

            -- action
            if sendData.Act == 1 then
                local action =
                {
                    skillID = sendData.MagId,
                    actor = mainPlayer,
                    dir = mainPlayer:GetDirection(),
                    ActionId = sendData.ActionId or skillProxy:GetActionID(sendData.MagId),
                }

                if skillConfig.action == 0 then
                    -- 攻击
                    global.Facade:sendNotification(global.NoticeTable.ActorEnterAttackAction, action)
                    mainPlayer:SetConfirmed(true)
                    
                elseif skillConfig.action == 1 then
                    -- 施法
                    global.Facade:sendNotification(global.NoticeTable.ActorEnterSkillAction, action)
                    mainPlayer:SetConfirmed(true)
                end
            end

            -- 特殊 连击技能进CD
            local skillID = sendData.MagId
            if sendData.CD == 1 and skillProxy:IsComboSkill(skillID) then
                global.Facade:sendNotification(global.NoticeTable.ComboSkillEnterCD, skillID)
            end
        end
    end
end

--十步一杀瞬移成功
function GameActorSkillController:handle_MSG_SC_PLAYER_SKILL_82_SUCCESS(msg)
    local msgHdr    = msg:GetHeader()
    local msgLen    = msg:GetDataLength()
    if msgLen <= 0 then
        return -1
    end

    local data      = msg:GetData()
    local userID    = msg:GetData():ReadString(msgLen)
    local actor     = global.actorManager:GetActor( userID )
    if not actor then
        return -1
    end
    if not actor:IsPlayer() then
        return -1
    end

    local mapX = msgHdr.param1
    local mapY = msgHdr.param2
    if mapX == actor:GetMapX() and mapY == actor:GetMapY() then
        return -1
    end

    if actor:IsMainPlayer() then
        global.gamePlayerController:handle_MSG_SC_PLAYER_SKILL_82_SUCCESS(actor, msgHdr)
    else
        global.netPlayerController:handle_MSG_SC_PLAYER_SKILL_82_SUCCESS(actor, msgHdr)
    end

    return 1
end

-- 擒龙手瞬移
function GameActorSkillController:handle_MSG_SC_PLAYER_SKILL_71_SUCCESS (msg)

    local msgHdr    = msg:GetHeader()
    local msgLen    = msg:GetDataLength()
    if msgLen <= 0 then
        return -1
    end

    local data      = msg:GetData()
    local dataStr   = msg:GetData():ReadString(msgLen)
    local dataArray = string.split(dataStr or "","#")       -- 受击者#施法者
    local userID    = dataArray[1]
    local actor     = global.actorManager:GetActor( userID )
    if not actor then
        return -1
    end

    local mapX = msgHdr.param1
    local mapY = msgHdr.param2
    if mapX == actor:GetMapX() and mapY == actor:GetMapY() then
        return -1
    end

    if actor:IsMonster() then
        global.netMonsterController:handle_MSG_SC_PLAYER_SKILL_71_SUCCESS(actor,msgHdr)
    elseif actor:IsPlayer() then
        if actor:IsMainPlayer() then
            global.gamePlayerController:handle_MSG_SC_PLAYER_SKILL_71_SUCCESS(actor, msgHdr)
        else
            global.netPlayerController:handle_MSG_SC_PLAYER_SKILL_71_SUCCESS(actor, msgHdr)
        end
    end

    if global.gamePlayerController:GetMainPlayerID() == dataArray[2] then
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        PlayerInputProxy:ClearMove()
    end
    
    return 1
end

function GameActorSkillController:RegisterMsgHandler()
    
    local msgType = global.MsgType

    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_SKILL_27_SUCCESS, handle_MSG_SC_PLAYER_SKILL_27_SUCCESS)
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_SKILL_27_BACKSTEP, handle_MSG_SC_PLAYER_SKILL_27_BACKSTEP)
    LuaRegisterMsgHandler(msgType.MSG_SC_SKILL_HIT_MISS, handler(self, self.handle_MSG_SC_SKILL_HIT_MISS))-- 飞行技能命中失败
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_SKILL_82_SUCCESS, handler(self, self.handle_MSG_SC_PLAYER_SKILL_82_SUCCESS)) --十步一杀瞬移成功 
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_SKILL_71_SUCCESS, handler(self, self.handle_MSG_SC_PLAYER_SKILL_71_SUCCESS)) --擒龙手
    
    LuaRegisterMsgHandler(msgType.MSG_SC_JOINTATTACK_HERO, handler(self, self.handle_MSG_SC_JOINT_SKILL_PRESENT)) -- 合击
    LuaRegisterMsgHandler(msgType.MSG_SC_EXTRA_EFFECT, handler(self, self.handle_MSG_SC_JOINT_SKILL_PRESENT_HIT)) -- 合击击中特效
    LuaRegisterMsgHandler( msgType.MSG_SC_HERO_EFFECT,           handler( self, self.handle_MSG_SC_HERO_EFFECT) )             -- 英雄专属特效


    local function ActCompleted(actor, act)
        if actor and (act == global.MMO.ACTION_WALK or act == global.MMO.ACTION_RUN) then
            for i, v in ipairs(self._jointCache) do
                if v.userid == actor:GetID() then
                    self:launchJointSkill(v)
                    table.remove(self._jointCache, i)
                    global.gamePlayerController.mInputEnable = false
                    break
                end
            end
        end
    end
    global.gamePlayerController:AddHandleOnActCompleted(ActCompleted)
    LuaRegisterMsgHandler(msgType.MSG_SC_SERVER_SKILL_RESP, handler(self, self.handle_MSG_SC_SERVER_SKILL_RESP))-- 服务器触发的技能，牛逼
end

function GameActorSkillController:Cleanup()
end

return GameActorSkillController 
