local skillUtils = requireProxy("skillUtils")
local RemoteProxy = requireProxy("remote/RemoteProxy")
local SummonsProxy = class("SummonsProxy", RemoteProxy)
SummonsProxy.NAME = global.ProxyTable.SummonsProxy

function SummonsProxy:ctor()
    SummonsProxy.super.ctor(self)

    self._data = {}
    self._config = {}
    self._summonsConfigByLv = {} --{组={技能配置 技能按优先级排序}}
    self._skillGroup = {}--{技能=组}
    self._groups = {}-- {{Group},{Group}  按组排序}  

    self:clear()
end

function SummonsProxy:clear()
    self._data.mode = 2
    self._data.summonsAlived = false
    self._data.heroSummonsAlived = false--英雄是否有召唤物
    self._summonsData = {} --每种可能有多只 {技能id ={当前数目,最大数目}}
    self._isMerge = false  --召唤骷髅和召唤神兽  是否公用一个数目
    self._lockTargetID = nil

    self._canUseSkillID = {}--直接根据 服务端下发的技能id来判断能不能召唤

    self._summonsNum = 0--召唤物 总量 精灵和宠物不算
    self._summonNumByGroup = {}--{组={id,数量}
end

function SummonsProxy:LoadConfig()
    local GameConfigMgrProxy = global.Facade:retrieveProxy(global.ProxyTable.GameConfigMgrProxy)
    local config = GameConfigMgrProxy:getConfigByKey("cfg_callmobset") or {}

    self._config = config
    dump(self._config,"self._config__")
    self._summonsConfigByLv = {}
    for i, v in ipairs(self._config) do
        if not self._summonsConfigByLv[v.Group] then 
            self._summonsConfigByLv[v.Group] = {}
            table.insert(self._groups, v)
        end
        table.insert(self._summonsConfigByLv[v.Group], v)
        self._skillGroup[v.ID] = v.Group
    end

    for k, group in pairs(self._summonsConfigByLv) do
        table.sort(group,function (a,b) 
            return a.Lv > b.Lv
        end)
    end
    table.sort(self._groups,function (a,b) 
        return a.Group > b.Group
    end)
end
--先招组别Group大的 同组别中先招优先级Lv大的  每组只招一种
function SummonsProxy:autoSummon()
    local summunMax = tonumber(SL:GetMetaValue("SERVER_OPTION", "CallMobSetCnt"))
    local useLvNext = SL:GetMetaValue("SERVER_OPTION", "UseLvNext")--是否顺延
    if self._summonsNum >= summunMax then 
        return -1
    end
    if self._canUseSkillID["-1"] == 1 then 
        return -1
    end

    local configByLv
    local skillID
    local curCount 
    local summonData 
    local group
    local curSummonData
    local isNextGroup = false
    local curSkillID
    for i, v in ipairs(self._groups) do
        group = v.Group
        configByLv = self._summonsConfigByLv[group]
        for _, config in ipairs(configByLv) do
            repeat
                skillID = config.ID  
                curSummonData = self._summonNumByGroup[group] or {}
                curSkillID = curSummonData[1] 
                if curSkillID then--当前组存在召唤物
                    if curSkillID == skillID then 
                        curCount = curSummonData[2] --当前数目
                        if curCount < config.Cnt then--还能招
                            if self:canSummons(skillID) and skillUtils.checkAbleToAutoLaunch(skillID) then 
                                return skillID
                            else
                                isNextGroup = true
                                break
                            end
                        else 
                            isNextGroup = true
                            break
                        end
                    else
                        break
                    end
                else--当前组不存在召唤物 
                    if self:canSummons(skillID) and skillUtils.checkAbleToAutoLaunch(skillID) then
                        return skillID
                    else 
                        if useLvNext then 
                            break
                        else 
                            isNextGroup = true
                            break
                        end
                    end
                end
            until true

            if isNextGroup then 
                isNextGroup = false
                break
            end
        end
    end
    return -1
end


function SummonsProxy:GetMode()
    return self._data.mode
end

function SummonsProxy:SetMode(mode)
    self._data.mode = mode
end

function SummonsProxy:IsAlived()
    return self:IsSummonsAlived()
end

function SummonsProxy:IsSummonsAlived()
    return self._data.summonsAlived == true
end

function SummonsProxy:IsHeroSummonsAlived()
    return self._data.heroSummonsAlived == true
end

function SummonsProxy:RequestModeChange(mode)
    local targetID = ""
    if mode == 3 then
        -- 锁定
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        targetID = PlayerInputProxy:GetTargetID() or ""
    end
    LuaSendMsg(global.MsgType.MSG_CS_SUMMONS_MODE_CHANGE, mode, 0, 0, 0, targetID, string.len(targetID))

    self:SetMode(mode)

    -- SL
    SLBridge:onLUAEvent(LUA_EVENT_SUMMON_MODE_CHANGE, { mode = mode })
end

function SummonsProxy:RespSummonAliveUpdate(msg)
    local header = msg:GetHeader()
    local status = header.recog > 0
    local isHero = header.param1 == 1
    if isHero then
        self._data.heroSummonsAlived = status
    else
        global.monsterManager:SetPetOfMainAlive(status)
        self._data.summonsAlived = status
    end
    global.Facade:sendNotification(global.NoticeTable.SummonsAliveStatusChange, { status = self:IsAlived() })

    -- SL 
    SLBridge:onLUAEvent(LUA_EVENT_SUMMON_ALIVE_CHANGE, { status = self:IsAlived() })
end

function SummonsProxy:RespModeUpdate(msg)
    local header = msg:GetHeader()
    local mode = header.recog

    self:SetMode(mode)

    -- SL
    SLBridge:onLUAEvent(LUA_EVENT_SUMMON_MODE_CHANGE, { mode = mode })
end

function SummonsProxy:canSummons(skillID)
    if not skillID then
        return false
    end
    -- 分身术不走 服务端的统计。。。。
    if skillID ~= 74 then 
        if next(self._canUseSkillID) then 
            return self._canUseSkillID[skillID] == 1
        end
    end
    
    local newAutoSummon = SL:GetMetaValue("SERVER_OPTION", "CallMobSet")
    if not newAutoSummon then 
        if self._isMerge and skillID == global.MMO.SKILL_INDEX_ZHKL then--召唤骷髅和 召唤神兽公用一个数目
            skillID = global.MMO.SKILL_INDEX_ZHSS
        end
    end
    
    local SummonsData = self._summonsData[skillID]
    if SummonsData then
        return SummonsData[1] < SummonsData[2]
    end
    return true
end

function SummonsProxy:RespPetDeath(msg)--召唤物最大数量   和 数目变化
    local header = msg:GetHeader()
    local status = header.recog == 1
    -- dump(header, "header__")
    local maxNum = header.param1
    local skillID = header.param2
    self._isMerge = header.param3 == 0

    local msgLen = msg:GetDataLength()
    if msgLen > 0 then 
        local str = msg:GetData():ReadString(msgLen)
        self._canUseSkillID = {}
        if str == "-1" then
            self._canUseSkillID["-1"] = 1
        else 
            local t = string.split(str, ",")
            for i, v in ipairs(t) do
                self._canUseSkillID[tonumber(v)] = 1
            end
        end
        -- dump(str,"str____")
    end

    if skillID > 0 then-- 技能召唤的 
        local newAutoSummon = SL:GetMetaValue("SERVER_OPTION", "CallMobSet")
        if not newAutoSummon then 
            if self._isMerge and skillID == 17 then--召唤骷髅和 召唤神兽公用一个数目
                skillID = 30
            end
        end
        self._summonsData[skillID] = self._summonsData[skillID] or { 0, 1 } -- 当前个数,最大数目
        if status then--出生
            self._summonsData[skillID][1] = self._summonsData[skillID][1] + 1
            self._summonsData[skillID][2] = maxNum

            self._summonsNum = self._summonsNum + 1
            local group = self._skillGroup[skillID]
            if group then 
                self._summonNumByGroup[group] = self._summonNumByGroup[group] or {skillID, 0}
                self._summonNumByGroup[group][2] = self._summonNumByGroup[group][2] + 1
            end
        else--死亡
            self._summonsData[skillID][1] = self._summonsData[skillID][1] - 1

            self._summonsNum = self._summonsNum - 1 
            local group = self._skillGroup[skillID]
            if group then 
                if self._summonNumByGroup[group] then 
                    self._summonNumByGroup[group][2] = self._summonNumByGroup[group][2] - 1
                    if self._summonNumByGroup[group][2] == 0 then 
                        self._summonNumByGroup[group] = nil
                    end
                end
            end
        end
    end

    global.Facade:sendNotification(global.NoticeTable.SummonsAliveStatusChange, { status = self:IsAlived() })

    -- SL 
    SLBridge:onLUAEvent(LUA_EVENT_SUMMON_ALIVE_CHANGE, { status = self:IsAlived() })
end

----------锁定
function SummonsProxy:SetLockTargetID(actorID)
    self._lockTargetID = actorID
end

function SummonsProxy:GetLockTargetID()
    return self._lockTargetID
end

function SummonsProxy:ReqLockActorByID(actorID)
    self:SetLockTargetID(actorID)
    LuaSendMsg(global.MsgType.MSG_CS_MOBLOCKTARGET, 0, 0, 0, 0, actorID, string.len(actorID))
end

function SummonsProxy:ReqUnLockActorByID(actorID)
    self:SetLockTargetID(nil)
    if not actorID then
        return
    end
    LuaSendMsg(global.MsgType.MSG_CS_MOBUNLOCKTARGET, 0, 0, 0, 0, actorID, string.len(actorID))
end

function SummonsProxy:RegisterMsgHandler()
    SummonsProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler(msgType.MSG_SC_SUMMONS_MODE_UPDATE, handler(self, self.RespModeUpdate))           -- 召唤物攻击模式改变
    LuaRegisterMsgHandler(msgType.MSG_SC_SUMMON_ALIVE_UPDATE, handler(self, self.RespSummonAliveUpdate))    -- 召唤物存活状态(是否有召唤物)
    LuaRegisterMsgHandler(msgType.MSG_SC_PET_STATE,            handler(self, self.RespPetDeath))             -- 召唤物存活状态(出生死亡数量变化)
end

return SummonsProxy