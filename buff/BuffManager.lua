local DebugMediator = requireMediator("DebugMediator")
local BuffManager = class("BuffManager", DebugMediator)
BuffManager.NAME = "BuffManager"

local cjson = require("cjson")

local BuffEntityIce = require("buff/BuffEntityIce")
local BuffEntityAnim = require("buff/BuffEntityAnim")
local BuffEntityColor = require("buff/BuffEntityColor")
local BuffEntityColors = require("buff/BuffEntityColors")
local BuffEntityFreezed = require("buff/BuffEntityFreezed")
local BuffEntityCloaking = require("buff/BuffEntityCloaking")
local BuffEntityPoisonTransparent = require("buff/BuffEntityPoisonTransparent")
local BuffEntityStoneMode = require("buff/BuffEntityStoneMode")
local BuffEntityAvatar = require("buff/BuffEntityAvatar")
local BuffEntitySneak  = require("buff/BuffEntitySneak")
local BuffEntityHorse  = require("buff/BuffEntityHorse")

local mmo = global.MMO
local facade = global.Facade
local noticeTable = global.NoticeTable

function BuffManager:ctor()
    BuffManager.super.ctor(self, self.NAME)

    self._buffItems = {}
    self._handleOnMainActBegin = {}     --潜行buff 需监听主玩家位置
end

function BuffManager:destory()
    if BuffManager.instance then
        global.Facade:removeMediator(BuffManager.NAME)
        BuffManager.instance = nil
    end
end

function BuffManager:Inst()
    if not BuffManager.instance then
        BuffManager.instance = BuffManager.new()
        global.Facade:registerMediator(BuffManager.instance)
    end

    return BuffManager.instance
end

function BuffManager:listNotificationInterests()
    return {
        noticeTable.AddBuffEntity,
        noticeTable.ActorBuffPresentUpdate,
        noticeTable.DropItemOutOfView,
        noticeTable.ActorOutOfView,
        noticeTable.RefreshActorHP,
        noticeTable.RefreshBuffVisible,
        noticeTable.MainPlayerActionBegan,
    }
end

function BuffManager:handleNotification(notification)
    local id = notification:getName()
    local data = notification:getBody()

    if noticeTable.AddBuffEntity == id then
        self:AddBuff(data)

    elseif noticeTable.ActorBuffPresentUpdate == id then
        self:OnActorBuffPresentUpdate(data)

    elseif noticeTable.DropItemOutOfView == id then
        self:OnDropItemOutOfView(data)

    elseif noticeTable.ActorOutOfView == id then
        self:OnActorOutOfView(data)

    elseif noticeTable.RefreshActorHP == id then
        self:OnRefreshActorHP(data)

    elseif noticeTable.RefreshBuffVisible == id then
        self:OnRefreshBuffVisible(data)

    elseif noticeTable.MainPlayerActionBegan == id then
        self:OnMainActBeginHanlder(data)

    end
end

function BuffManager:Tick(dt)
    local removed = {}
    for actorID, items in pairs(self._buffItems) do
        for buffID, item in pairs(items) do
            if item:IsInvalid() then
                table.insert(removed, { actorID = actorID, buffID = buffID })
            else
                item:Tick(dt)
            end
        end
    end
    for _, v in pairs(removed) do
        self:RmvBuff({ actorID = v.actorID, buffID = v.buffID })
    end
end

function BuffManager:CreateBuffItem(data)
    local actorID = data.actorID
    local buffID = data.buffID

    local item = nil

    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    if buffID == mmo.BUFF_ID_FREEZED_GRAY then
        item = BuffEntityFreezed.new(data)

    elseif buffID == mmo.BUFF_ID_CLOAKING then
        item = BuffEntityCloaking.new(data)

    elseif buffID == mmo.BUFF_ID_POISONING_RED then
        item = BuffEntityColor.new(data)

    elseif buffID == mmo.BUFF_ID_POISONING_GREEN then
        item = BuffEntityColor.new(data)

    elseif buffID == mmo.BUFF_ID_COLOR then
        item = BuffEntityColor.new(data)

    elseif buffID == mmo.BUFF_ID_ICE then
        item = BuffEntityIce.new(data)

    elseif buffID == mmo.BUFF_ID_COLORS then
        item = BuffEntityColors.new(data)

    elseif buffID == mmo.BUFF_ID_POISON_TRANSPARENT then
        item = BuffEntityPoisonTransparent.new(data)

    elseif buffID == mmo.BUFF_ID_STONE_MODE then
        item = BuffEntityStoneMode.new(data)

    elseif buffID == mmo.BUFF_ID_THUNDER_SWORD then
        item = BuffEntityColor.new(data)

    elseif buffID == mmo.BUFF_ID_SNEAK then
        item = BuffEntitySneak.new(data)
    
    elseif buffID == mmo.BUFF_ID_HORSE then
        item = BuffEntityHorse.new(data)

    elseif BuffProxy:IsAvatarBuff(buffID) then
        item = BuffEntityAvatar.new(data)

    else
        item = BuffEntityAnim.new(data)
    end

    return item
end

--------------------------------------------------------
function BuffManager:GetDataByUID(uid)
    local data = {}
    if self:IsEmpty(uid) then
        return data
    end
    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    local config = BuffProxy:GetConfig()
    local items = self:GetItemsByActorID(uid)
    for k, v in pairs(config) do
        if items[v.ID] and v.buffshow ~= 1 then
            local bdata     = items[v.ID]:GetData()
            local endTime   = items[v.ID]:GetEndTime()
            local ol        = items[v.ID]:GetOl()
            table.insert(data, {id = v.ID, param = bdata.param, endTime = endTime, ol = ol})
        end
    end
    return data
end

function BuffManager:GetCountByUID(uid)
    local items = self:GetDataByUID(uid)
    return #items
end
--------------------------------------------------------

--------------------------------------------------------
function BuffManager:GetItemsByActorID(actorID)
    if not self._buffItems[actorID] then
        self._buffItems[actorID] = {}
    end
    return self._buffItems[actorID]
end

function BuffManager:GetItem(actorID, buffID)
    local items = self:GetItemsByActorID(actorID)
    return items[buffID]
end

function BuffManager:IsEmpty(actorID)
    return (not self._buffItems[actorID]) or (not next(self._buffItems[actorID]))
end
--------------------------------------------------------

--------------------------------------------------------
function BuffManager:CleanupByActorID(actorID)
    if (self:IsEmpty(actorID)) then
        return
    end

    local items = self:GetItemsByActorID(actorID)
    local removed = {}
    for _, item in pairs(items) do
        table.insert(removed, { actorID = item:GetActorID(), buffID = item:GetBuffID() })
    end
    for _, v in pairs(removed) do
        self:RmvBuff(v)
    end
end

function BuffManager:Cleanup()
    local removed = {}
    for _, items in pairs(self._buffItems) do
        for _, item in pairs(items) do
            table.insert(removed, item:GetActorID())
        end
    end
    for _, actorID in pairs(removed) do
        self:CleanupByActorID(actorID)
    end
    self._buffItems = {}
    self._handleOnMainActBegin = {}
end
--------------------------------------------------------

--------------------------------------------------------
function BuffManager:AddBuff(data)
    -- print("buff began, actorID: " .. data.actorID .. "  buffID:" .. data.buffID)

    local actorID = data.actorID
    local buffID = data.buffID
    local param = data.param
    local ol    = data.ol

    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return nil
    end

    -- empty
    if self:IsEmpty(actorID) then
        self._buffItems[actorID] = {}
    end

    -- exist, update it
    if self:GetItem(actorID, buffID) then
        self:UpdateBuff(data)
        return
    end

    local items = self:GetItemsByActorID(actorID)
    local item    = self:CreateBuffItem(data)
    items[buffID] = item
    item:OnEnter()

    -- 主玩家Buff同步
    if actorID == global.gamePlayerController:GetMainPlayerID() then
        local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
        BuffProxy:AddBuffItem({ id = buffID, param = param, ol = ol })

        ssr.ssrBridge:OnMainPlayerBuffChange()
        SLBridge:onLUAEvent(LUA_EVENT_MAINBUFFUPDATE, { actorID = actorID, buffID = buffID, type = 1 })
    end

    -- 主玩家英雄buff提示
    if actor:IsHero() and actor:GetMasterID() == global.gamePlayerController:GetMainPlayerID() then
        local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
        BuffProxy:AddBuffItem({ id = buffID, param = param, ol = ol }, true)
    end

    -- notice
    global.Facade:sendNotification(global.NoticeTable.BuffEntitiesChange, { actorID = actorID })
    SLBridge:onLUAEvent(LUA_EVENT_BUFFUPDATE, { actorID = actorID, buffID = buffID, type = 1 })

    return true
end

function BuffManager:UpdateBuff(data)
    local actorID = data.actorID
    local buffID = data.buffID
    local param = data.param
    local ol    = data.ol  -- buff 层级

    if (self:IsEmpty(actorID)) then
        return false
    end

    local item = self:GetItem(actorID, buffID)
    if item then
        item:UpdateParam(param)
        item:UpdateOl(ol)
        item:UpdatePresent()
    end

    -- 主玩家Buff同步
    if actorID == global.gamePlayerController:GetMainPlayerID() then
        local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
        BuffProxy:UpdateBuffItem({ id = buffID, param = param, ol = ol })

        ssr.ssrBridge:OnMainPlayerBuffChange()
        SLBridge:onLUAEvent(LUA_EVENT_MAINBUFFUPDATE, { actorID = actorID, buffID = buffID, type = 2 })
    end

    -- notice
    global.Facade:sendNotification(global.NoticeTable.BuffEntitiesChange, { actorID = actorID })
    SLBridge:onLUAEvent(LUA_EVENT_BUFFUPDATE, { actorID = actorID, buffID = buffID, type = 2 })
end

function BuffManager:RmvBuff(data)
    -- print("buff ended, actorID: " .. data.actorID .. "  buffID:" .. data.buffID)
    local actorID = data.actorID
    local buffID = data.buffID

    -- not exist
    if (self:IsEmpty(actorID)) then
        return false
    end

    -- do exist & delete it
    local items = self:GetItemsByActorID(actorID)
    local item = items[buffID]
    if item then
        items[buffID] = nil
        item:OnExit()
    end

    if self:IsEmpty(actorID) then
        self._buffItems[actorID] = nil
    end

    -- 主玩家Buff同步
    if actorID == global.gamePlayerController:GetMainPlayerID() then
        local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
        BuffProxy:RmvBuffItem({ id = buffID })

        ssr.ssrBridge:OnMainPlayerBuffChange()
        SLBridge:onLUAEvent(LUA_EVENT_MAINBUFFUPDATE, { actorID = actorID, buffID = buffID, type = 0 })
    end

    -- notice
    global.Facade:sendNotification(global.NoticeTable.BuffEntitiesChange, { actorID = actorID })
    SLBridge:onLUAEvent(LUA_EVENT_BUFFUPDATE, { actorID = actorID, buffID = buffID, type = 0 })

    return true
end
--------------------------------------------------------

--------------------------------------------------------
function BuffManager:handleBuffInit(msgHdr, msgData)
    if msgData == "" then
        return nil
    end
    fixNetMsgHeader(msgHdr)

    local jsonData = cjson.decode(msgData)
    if not jsonData or not jsonData.UserID or not jsonData.buff then
        return nil
    end

    local actorID = jsonData.UserID
    local items = {}
    if not self:IsEmpty(actorID) then
        items = self:GetItemsByActorID(actorID)
    end

    if #jsonData.buff == 0 and not next(items) then
        return nil
    end

    local buffData = jsonData.buff

    local added = {}
    local removed = {}
    local changed = {}

    -- check added & changed
    for _, v in pairs(buffData) do
        if v.param and tonumber(v.param) then
            v.param = fixMinusNumber(tonumber(v.param))
        end
        if (not items[v.id]) then
            added[v.id] = v
        else
            changed[v.id] = v
        end
    end

    -- custom buff
    local customBuff = {
        [mmo.BUFF_ID_HORSE] = mmo.BUFF_ID_HORSE
    }

    -- check removed
    local tmp = {}
    for _, v in pairs(buffData) do
        tmp[v.id] = 1
    end
    for _, v in pairs(items) do
        if not tmp[v:GetBuffID()] and not customBuff[v:GetBuffID()] then
            table.insert(removed, v:GetBuffID())
        end
    end

    for _, v in pairs(changed) do
        self:AddBuff({ actorID = actorID, buffID = v.id, param = v.param, ol = v.ol, replaceId = v.p1 })
    end
    for _, v in pairs(added) do
        self:AddBuff({ actorID = actorID, buffID = v.id, param = v.param, ol = v.ol, replaceId = v.p1 })
    end
    for _, v in pairs(removed) do
        self:RmvBuff({ actorID = actorID, buffID = v })
    end
end

function BuffManager:handleBuffAdd(msgHdr, msgData)
    if "" == msgData then
        return nil
    end
    fixNetMsgHeader(msgHdr)

    local buffID = msgHdr.recog
    local param  = msgHdr.param1
    local userId = msgData
    local ol     = msgHdr.param2
    local replaceId = msgHdr.param3 --替换buffid特效  魔法盾需要显示其它的特效

    -- 新增/更新
    self:AddBuff({actorID = userId, buffID = buffID, param = param, ol = ol, replaceId = replaceId})


    -- 
    -- print("----------------------BUFF add", buffID, param, userId)
end

function BuffManager:handleBuffRmv(msgHdr, msgData)
    if "" == msgData then
        return nil
    end

    local buffID = msgHdr.recog
    local userId = msgData

    -- 
    self:RmvBuff({ actorID = userId, buffID = buffID })

    -- 
    -- print("----------------------BUFF rmv", buffID, userId)
end
--------------------------------------------------------

--------------------------------------------------------
function BuffManager:OnActorBuffPresentUpdate(actorID)
    -- 更新buff表现，外观改变需要更新buff表现....
    if self:IsEmpty(actorID) then
        return
    end

    local items = self:GetItemsByActorID(actorID)
    for _, v in pairs(items) do
        v:UpdatePresent()
    end
end

function BuffManager:setPosition(actorID, x, y)
    -- 更新buff表现，外观改变需要更新buff表现....
    if self:IsEmpty(actorID) then
        return
    end

    local items = self:GetItemsByActorID(actorID)
    for _, v in pairs(items) do
        v:setPosition(x, y)
    end
end

function BuffManager:OnRefreshActorHP(data)
    if not data.isDamage then
        return
    end
    if self:IsEmpty(data.actorID) then
        return
    end
    local items = self:GetItemsByActorID(data.actorID)
    for _, v in pairs(items) do
        v:OnActorStuck()
    end
end

function BuffManager:OnDropItemOutOfView(data)
    self:CleanupByActorID(data.actorID)
end

function BuffManager:OnActorOutOfView(data)
    self:CleanupByActorID(data.actorID)
end

function BuffManager:OnRefreshBuffVisible(data)
    if data and (data:IsDeath() or data:IsDie()) then
        local isHide = tonumber(SL:GetMetaValue("GAME_DATA", "MonsterDieHideAnim")) == 1
        if isHide then
            self:UpdateBuffItemVisible(data:GetID(), not isHide)
        end
    end
end

--------------------------------------------------------
function BuffManager:IsAllowAnimUpdate(actorID)
    if self:IsEmpty(actorID) then
        return true
    end

    local items = self:GetItemsByActorID(actorID)
    for _, v in pairs(items) do
        if not v:IsAllowAnimUpdate() then
            return false
        end
    end
    return true
end

-- 是否中毒
function BuffManager:IsPoisoning(actorID)
    if self:IsEmpty(actorID) then
        return false
    end

    local items = self:GetItemsByActorID(actorID)
    for _, v in pairs(items) do
        if v:GetBuffID() == mmo.BUFF_ID_POISONING_RED or v:GetBuffID() == mmo.BUFF_ID_POISONING_GREEN then
            return true
        end
    end
    return false
end

-- 是否中红毒
function BuffManager:IsPoisoningRed(actorID)
    return self:IsHaveOneBuff(actorID, mmo.BUFF_ID_POISONING_RED)
end

-- 是否中绿毒
function BuffManager:IsPoisoningGreen(actorID)
    return self:IsHaveOneBuff(actorID, mmo.BUFF_ID_POISONING_GREEN)
end

-- 是否有护盾
function BuffManager:IsHaveShield(actorID)
    return self:IsHaveOneBuff(actorID, mmo.BUFF_ID_MAGIC_SHIELD)
end

-- 是否麻痹
function BuffManager:IsFreezed(actorID)
    return self:IsHaveOneBuff(actorID, mmo.BUFF_ID_FREEZED_GRAY)
end

-- 神圣战甲术
function BuffManager:IsHaveAngelShield(actorID)
    return self:IsHaveOneBuff(actorID, mmo.BUFF_ID_ANGEL_SHIELD)
end

-- 是否有幽灵盾
function BuffManager:IsHaveGhostShield(actorID)
    return self:IsHaveOneBuff(actorID, mmo.BUFF_ID_GHOST_SHIELD)
end

-- 是否某个buff
function BuffManager:IsHaveOneBuff(actorID, buffID)
    if self:IsEmpty(actorID) then
        return false
    end

    local items = self:GetItemsByActorID(actorID)
    for _, v in pairs(items) do
        if v:GetBuffID() == buffID then
            return true
        end
    end
    return false
end

-- 自动释放该技能是否有该buff
function BuffManager:CheckAutoBuffBySkillID(actorID, skillID)
    if self:IsEmpty(actorID) then
        return false
    end

    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    local skillBuff = BuffProxy:GetNoSkillAuto( skillID )
    if not skillBuff then
        return false
    end

    local items = self:GetItemsByActorID(actorID)
    for _, v in pairs(items) do
        local buffID = v:GetBuffID()
        if skillBuff[buffID] then
            return buffID
        end
    end

    return false
end

-- 释放该技能是否有该buff
function BuffManager:CheckLaunchBuffBySkillID(actorID, skillID)
    if self:IsEmpty(actorID) then
        return false
    end

    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    local skillBuff = BuffProxy:GetNoSkillLaunch( skillID )
    if not skillBuff then
        return false
    end

    local items = self:GetItemsByActorID(actorID)
    for _, v in pairs(items) do
        local buffID = v:GetBuffID()
        if skillBuff[buffID] then
            return buffID
        end
    end

    return false
end

function BuffManager:IsInColorBuff(actorID)
    -- 是否在变色buff
    if self:IsEmpty(actorID) then
        return false
    end

    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    local items = self:GetItemsByActorID(actorID)
    for _, v in pairs(items) do
        if v:GetBuffID() == mmo.BUFF_ID_FREEZED_GRAY then
            -- 麻痹
            return true

        elseif v:GetBuffID() == mmo.BUFF_ID_POISONING_RED then
            -- 红毒
            return true

        elseif v:GetBuffID() == mmo.BUFF_ID_POISONING_GREEN then
            -- 绿毒
            return true

        elseif v:GetBuffID() == mmo.BUFF_ID_COLORS then
            -- 换色
            return true

        elseif v:GetBuffID() == mmo.BUFF_ID_COLOR then
            -- 变色
            return true

        elseif v:GetBuffID() == mmo.BUFF_ID_THUNDER_SWORD then
            -- 雷霆
            return true

        elseif v:GetBuffID() == mmo.BUFF_ID_ICE then
            -- 冰冻
            return true

        elseif BuffProxy:GetBuffColorByID(v:GetBuffID()) then
            -- buff表配置了颜色    
            return true

        end
    end
    return false
end

function BuffManager:CheckBuffColor(actorID, buffID)
    -- 是否某个buff
    if self:IsEmpty(actorID) then
        return cc.c3b(255, 255, 255)
    end

    local ignoreBuffID = {
        [mmo.BUFF_ID_POISON_TRANSPARENT] = true,
        [mmo.BUFF_ID_STONE_MODE] = true,
        [mmo.BUFF_ID_SNEAK] = true,
    }

    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    local color = cc.c3b(255, 255, 255)
    local items = self:GetItemsByActorID(actorID)
    for _, v in pairs(items) do
        if v:GetBuffID() == mmo.BUFF_ID_COLOR then
            if color.r == 255 and color.g == 255 and color.b == 255 then
                color = GET_COLOR_BYID_C3B(v:GetParam())
            end
        elseif not ignoreBuffID[v:GetBuffID()] then
            local buffColor = BuffProxy:GetBuffColorByID(v:GetBuffID())
            if buffColor then
                color = buffColor
            end
        end

        if v:GetBuffID() == buffID and (color.r ~= 255 or color.g ~= 255 or color.b ~= 255) then
            break
        end
    end

    return color
end

function BuffManager:CheckBuffAvatar(actorID, buffID)
    -- 是否某个buff
    if self:IsEmpty(actorID) then
        return nil
    end

    -- 骑马
    local actor = global.actorManager:GetActor(actorID)
    if actor and actor:IsPlayer() and (actor:GetHorseMasterID() or actor:IsHoreseCopilot()) then
        return {
            avatarType = 1,
            avatarID = actor:GetMonsterFeatureID()
        }
    end

    local ret = nil
    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    local items = self:GetItemsByActorID(actorID)
    for _, v in pairs(items) do
        local avatar = BuffProxy:GetBuffAvatarByID(v:GetBuffID())
        if avatar then
            ret = avatar
        end
        if v:GetBuffID() == buffID then
            break
        end
    end
    return ret
end

function BuffManager:CheckBuffScale(actorID, buffID)
    -- 是否没有buff
    if self:IsEmpty(actorID) then
        return 1
    end

    local ret = 1
    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    local items = self:GetItemsByActorID(actorID)
    for _, v in pairs(items) do
        local scale = BuffProxy:GetBuffScaleByID(v:GetBuffID())
        if scale then
            ret = scale
        end
        if v:GetBuffID() == buffID then
            break
        end
    end
    return ret
end

-- 检测变形类型是否要删除，人物 -> 怪物 / 怪物 -> 人物是时需要
function BuffManager:CheckRmvBuffAvatar(actorID, avatar)
    if not actorID then
        return false
    end

    local actor = global.actorManager:GetActor(actorID)
    if not actor then
        return false
    end

    if not avatar then
        avatar = {}
    end

    local sex = nil
    if avatar.avatarType == 0 then
        sex = avatar.avatarSex or actor:GetSexID()
    end
    local oldSex = actor:GetValueByKey(global.MMO.BUFF_PLAYER_AVATAR_SEX)
    actor:SetKeyValue( global.MMO.BUFF_PLAYER_AVATAR_SEX,sex )
    if (not oldSex and sex) or (not sex and oldSex) then
        return true
    end
    return false
end

function BuffManager:AddHandleOnMainActBegin(actorid,func)
    if not actorid then
        return
    end
    self._handleOnMainActBegin[actorid] = func
end

function BuffManager:RemoveHandleOnMainActBegin(actorid,func)
    if not actorid then
        return
    end
    self._handleOnMainActBegin[actorid] = nil
end

function BuffManager:OnMainActBeginHanlder(act)
    for k,v in pairs(self._handleOnMainActBegin) do
        v(act)
    end
end

function BuffManager:UpdateBuffItemVisible(actorID, allVisible)
    if allVisible == nil then
        -- 检测是不是副驾的玩家   副驾玩家的buff特效都不显示出来
        allVisible = true
        local actor = global.actorManager:GetActor(actorID)
        if actor and actor:IsPlayer() and actor:IsHoreseCopilot() then
            allVisible = false
        end
    end
    local visible = allVisible == true
    local items = self:GetItemsByActorID(actorID)
    for _, _item in pairs(items) do
        _item:setVisible(visible)
        _item:updatePosition()
    end
end

function BuffManager.OnUnloaded()
    BuffManager.super.OnUnloaded()
    global.BuffManager = nil
    global.Facade:removeMediator(BuffManager.NAME)
end

function BuffManager.Onloaded()
    BuffManager.super.Onloaded()
    local mediator = BuffManager.new()
    global.Facade:registerMediator(mediator)
    global.BuffManager = mediator
end

return BuffManager