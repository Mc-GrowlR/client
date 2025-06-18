local DebugMediator = requireMediator("DebugMediator")
local ActorEffectManager = class("ActorEffectManager", DebugMediator)
ActorEffectManager.NAME = "ActorEffectManager"

local cjson = require("cjson")
local optionsUtils = requireProxy( "optionsUtils" )

function ActorEffectManager:ctor()
    ActorEffectManager.super.ctor(self, self.NAME)

    self._effects   = {}
    self._rootNodeB = nil
    self._rootNodeF = nil

    self._npcEffects= {}

end

function ActorEffectManager:destory()
    if ActorEffectManager.instance then
        global.Facade:removeMediator( ActorEffectManager.NAME )
        ActorEffectManager.instance = nil
    end
end

function ActorEffectManager:Inst()
    if not ActorEffectManager.instance then
        ActorEffectManager.instance = ActorEffectManager.new()
        global.Facade:registerMediator(ActorEffectManager.instance)
    end

    return ActorEffectManager.instance
end

function ActorEffectManager:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
    {
        noticeTable.ActorOutOfView,
        noticeTable.ActorInOfView,
        noticeTable.DropItemOutOfView,
    }
end

function ActorEffectManager:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.ActorOutOfView == noticeID then
        self:OnActorOutOfView(data)

    elseif noticeTable.ActorInOfView == noticeID then
        self:OnActorInOfView(data)

    elseif noticeTable.DropItemOutOfView == noticeID then
        self:OnDropItemOutOfView(data)
    end
end

function ActorEffectManager:getRoots()
    if not self._rootNodeB then
        self._rootNodeB = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_SKILL_BEHIND)
    end
    if not self._rootNodeF then
        self._rootNodeF = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_SKILL)
    end
end

function ActorEffectManager:Tick(dt)
    local removed = {}
    for actorID, items in pairs(self._effects) do
        for sfxID, item in pairs(items) do
            if self:CheckInvalid(item) then
                table.insert(removed, {actorID = actorID, sfxID = sfxID})
            end
        end
    end
    for _, v in pairs(removed) do
        self:RmvEffect({actorID = v.actorID, sfxID = v.sfxID})
    end
end

function ActorEffectManager:CheckInvalid(item)
    -- forever
    if item.count == 0 then
        return false
    end

    -- count compare
    if item.counting >= item.count then
        return true
    end
    return false
end

function ActorEffectManager:IsEmpty(actorID)
    local items = self._effects[actorID]
    if not items or not next(items) then
        return true
    end
    return false
end

function ActorEffectManager:Cleanup()
    local removed = {}
    for _, items in pairs(self._effects) do
        for _, item in pairs(items) do
            table.insert(removed, item.actorID)
        end
    end
    for _, v in pairs(removed) do
        self:CleanupByActorID(v)
    end
    self._effects = {}
end

function ActorEffectManager:CleanupByActorID(actorID)
    if (self:IsEmpty(actorID)) then
        return
    end

    local items = self:GetItemsByActorID(actorID)
    local removed = {}
    for _, item in pairs(items) do
        table.insert(removed, {actorID = item.actorID, sfxID = item.sfxID})
    end
    for _, v in pairs(removed) do
        self:RmvEffect(v)
    end
end

function ActorEffectManager:OnActorOutOfView(data)
    self:CleanupByActorID(data.actorID)
end

function ActorEffectManager:OnActorInOfView(data)
    self:CheckAddNPCEffect(data.actorID)
end

function ActorEffectManager:OnDropItemOutOfView(data)
    self:CleanupByActorID(data.actorID)
end

function ActorEffectManager:GetItemsByActorID(actorID)
    if not self._effects[actorID] then
        self._effects[actorID] = {}
    end
    return self._effects[actorID]
end

function ActorEffectManager:setPosition(actorID, x, y)
    if self:IsEmpty(actorID) then
        return nil
    end
    local items = self._effects[actorID]
    if not items then
        return nil
    end
    local offset    = cc.p(0,0)
    local position  = cc.p(0,0)
    for _, item in pairs(items) do
        offset      = cc.p(item.offsetX or 0, item.offsetY or 0)
        position    = cc.pAdd(cc.p(x, y), global.MMO.PLAYER_AVATAR_OFFSET)
        position    = cc.pAdd(position, offset)
        item.anim:setPosition(position)
    end
end

function ActorEffectManager:AddEffect(item)
    self:getRoots()

    -- error param
    local actorID       = item.actorID
    local sfxID         = item.sfxID
    if not actorID or not sfxID then
        return false
    end

    -- can't find actor
    local actor         = global.actorManager:GetActor(actorID)
    if not actor then
        print("+++++++++++++++++++ AddEffect can't find actor")
        return false
    end

    self._effects[actorID]  = self._effects[actorID] or {}
    local items             = self._effects[actorID]

    local visible = type(item.visible) ~= "boolean" and true or item.visible
    visible      = visible and  CHECK_SETTING(global.MMO.SETTING_IDX_EFFECT_SHOW) ~= 1
    if actor:IsPlayer() and actor:IsDoubleHorse() then
        visible = false
    end
    -- exist
    if items[sfxID] then
        items[sfxID].anim:setVisible(visible)
        return false
    end

    -- add sfx
    local root          = (item.front == true and self._rootNodeF or self._rootNodeB)
    local anim          = global.FrameAnimManager:CreateSFXAnim(sfxID)
    anim:SetGlobalElapseEnable(item.count == 0)
    root:addChild(anim, sfxID)
    anim:Play(0, 0, true, item.speed)
    anim:SetAnimEventCallback(function()
        item.counting   = item.counting + 1
    end)

    anim:setVisible(visible)
    
    -- fix param
    item.counting       = 0
    item.anim           = anim
    items[sfxID]        = item
    
    -- 
    local position      = actor:getPosition()
    self:setPosition(actorID, position.x, position.y)

    return true
end

function ActorEffectManager:RmvEffect(data)
    -- error param
    local actorID       = data.actorID
    local sfxID         = data.sfxID

    if not actorID or not sfxID then
        return false
    end

    if self:IsEmpty(actorID) then
        return false
    end

    local items         = self._effects[actorID]

    -- can'd find item
    if nil == items[sfxID] then
        return false
    end

    items[sfxID].anim:removeFromParent()
    items[sfxID]        = nil

    -- cleanup, when empty
    if self:IsEmpty(actorID) then
        self._effects[actorID] = nil
    end
end

function ActorEffectManager:ActorEffectRefresh(data)
    --
    -- dump(data)
    
    if not data or not data.action or not data.items then
        return false
    end

    -- 
    local action    = data.action
    local items     = data.items

    for _, v in ipairs(items) do
        local data  =
        {
            actorID = v.iUserId,
            sfxID   = tonumber(v.sEffSrc),
            frame   = v.iFrame or 0,
            speed   = v.iSpeed or 1,
            count   = v.iCount or 0,
            front   = not (v.iBehind == 1),
            offsetX = v.offsetX or 0,
            offsetY = v.offsetY or 0,
            visible = v.visible,
        }

        if action == 1 then
            self:AddEffect(data)

        elseif action == 0 then
            self:RmvEffect(data)
        end
    end
end

function ActorEffectManager:handle_ActorEffectUpdate(msgHdr, msgData)
    if msgData == "" then
        return nil
    end
    local action = msgHdr.recog      -- 1.增加 0.删除
    local jsonData = cjson.decode(msgData)
    if not jsonData then
        return nil
    end

    --
    -- print("+++++++++++++++++++++++++++++++++action", action)
    -- dump(jsonData)

    self:ActorEffectRefresh({action = action, items = jsonData})
end
-------------------------------------------------------------------

-------------------------------------------------------------------
function ActorEffectManager:CheckAddNPCEffect(actorID)
    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return nil
    end
    local effect = self._npcEffects[actorID]
    if not effect then
        return nil
    end

    local data =
    {
        actorID = actorID,
        sfxID   = effect.sfxID,
        frame   = 0,
        speed   = 1,
        count   = 0,
        front   = true,
        offsetX = effect.offsetX,
        offsetY = effect.offsetY,
    }
    self:AddEffect(data)
end

function ActorEffectManager:CheckRmvNPCEffect(actorID)
    local effect = self._npcEffects[actorID]
    if not effect then
        return nil
    end
    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return nil
    end

    local data =
    {
        actorID = actorID,
        sfxID   = effect.sfxID,
        frame   = 0,
        speed   = 1,
        count   = 0,
        front   = true,
        offsetX = effect.offsetX,
        offsetY = effect.offsetY,
    }
    self:RmvEffect(data)
end

function ActorEffectManager:RespAddNPCEffect(msg)
    local header = msg:GetHeader()
    local msgLen = msg:GetDataLength()
    if msgLen <= 0 then
        return nil
    end
    local npcID = msg:GetData():ReadString(msgLen)

    self._npcEffects[npcID] = 
    {
        sfxID   = header.param1,
        offsetX = header.param2,
        offsetY = header.param3,
    }

    self:CheckAddNPCEffect(npcID)
end
    
function ActorEffectManager:RespRmvNPCEffect(msg)
    local header = msg:GetHeader()
    local msgLen = msg:GetDataLength()
    if msgLen <= 0 then
        return nil
    end
    local npcID = msg:GetData():ReadString(msgLen)

    self:CheckRmvNPCEffect(npcID)

    self._npcEffects[npcID] = nil
end

function ActorEffectManager:RefreshActorEffectVisible( actorID,visible )
    if not actorID then
        return
    end

    local effects = self._effects[actorID]
    if not effects or not next(effects) then
        return
    end

    local actor = global.actorManager:GetActor(actorID)
    if actor and actor:IsPlayer() and actor:IsDoubleHorse() then
        visible = false
    end

    if visible and actor:GetValueByKey(global.MMO.HUD_SNEAK) then
        visible = false
    end

    for sfxid,item in pairs(effects) do
        local itemVisible = visible
        if visible then
            itemVisible = item.visible or visible
        end
        item.anim:setVisible(itemVisible==true)
    end
end

function ActorEffectManager:onRegister()
    
    local msgType = global.MsgType

    LuaRegisterMsgHandler(msgType.MSG_SC_ADD_NPC_EFFECT, handler(self, self.RespAddNPCEffect))
    LuaRegisterMsgHandler(msgType.MSG_SC_RMV_NPC_EFFECT, handler(self, self.RespRmvNPCEffect))
end


return ActorEffectManager
