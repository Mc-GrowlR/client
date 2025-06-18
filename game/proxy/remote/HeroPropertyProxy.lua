local RemoteProxy        = requireProxy("remote/RemoteProxy")
local HeroPropertyProxy = class("HeroPropertyProxy", RemoteProxy)
HeroPropertyProxy.NAME = global.ProxyTable.HeroPropertyProxy
local cjson            = require("cjson")

local AttFun = require("util/AttributeFunction")

function HeroPropertyProxy:ctor()
    HeroPropertyProxy.super.ctor(self)

    local HeroPropertyVO = requireVO("remote/HeroPropertyVO")
    self.VOdata = HeroPropertyVO.new()
    self._herologin         = false -- 英雄是否出生
    self._guardState        = false
    self.isInited           = false
    self.alive              = true
    self.heroNameColor      = 255
    self._feature =  
    {
        clothID           = 0,
        weaponID          = 0,
        shieldID          = 0,
        wingsID           = 0,
        hairID            = 0,
        leftWeaponID      = 0,
    }
    self._internalData  = {}          -- 内功数据

    self._godMgicShowSetting = true --设置显示神魔
    self._superEquipShowSetting = false --设置时装显示
    --主角切页开关
    self._mainPlayerPageSwitch = {
    -- [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP] = false --nil/true为开启；false为关闭   神装默认为关闭
    }
    self._mainLookPlayerPageSwitch = {
        [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP] = true,
        [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_TITLE] = true,
        [SLDefine.PlayerPage.MAIN_PLAYER_LAYER_SUPER_EQUIP] = true,
    }

    self._attribute        = {}
    self._lockTargetID = nil


    ---怒气
    self._angerMax = 0 --最大怒气
    self._angerCur = 0--当前怒气
    self._shan = false --是否要闪
    self._speed = 10
    self._delayTime = 1
    -----
    self.m_heroid = nil

    self._LoginCD = 30

    self._LoginCDTime = 0

    self._attr_not_hint = {} --不弹出属性飘字提示

    self._lastJob = -1

    self:initLoadConfig()
end

function HeroPropertyProxy:initLoadConfig()
    local attrNotHintArray = string.split(SL:GetMetaValue("GAME_DATA","attr_not_hint") or "", "#")
    for i, v in ipairs(attrNotHintArray) do
        local attid = tonumber(v)
        if attid then
            self._attr_not_hint[attid] = attid
        end
    end
end

function HeroPropertyProxy:initConfig()
    self.m_states = self:getStatesSysSet()--手机版点击快捷切换状态 战斗 跟随 休息 守护 0-3
    local localdata = self:readLocalData()
    if localdata then
        self.m_states = localdata
    end
end
function HeroPropertyProxy:getStatesSysSet()--Heroqiehuan 三个或四个
    if self._Statesysset then
        return self._Statesysset
    end
    self._Statesysset = {}
    if global.ConstantConfig and SL:GetMetaValue("GAME_DATA","Heroqiehuan") then
        local strs = string.split(SL:GetMetaValue("GAME_DATA","Heroqiehuan"), "#")
        for i, v in ipairs(strs) do
            local num = tonumber(v)
            table.insert(self._Statesysset, num and num - 1 or nil)
        end
    else
        self._Statesysset = { 0, 1, 2, 3 }
    end
    return clone(self._Statesysset)
end
function HeroPropertyProxy:setCD(cd)
    self._LoginCD = cd
end
function HeroPropertyProxy:getCD(cd)
    return self._LoginCDTime
end

function HeroPropertyProxy:readLocalData()
    local LoginProxy    = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local mainPlayerID = LoginProxy:GetSelectedRoleID()
    local path    = "hero_state_" .. mainPlayerID
    local key    = "setting"
    local userData = UserData:new(path)
    local jsonStr = userData:getStringForKey(key, "")

    if not jsonStr or string.len(jsonStr) == 0 then
        return false
    end

    local jsonData = cjson.decode(jsonStr)
    if not jsonData then
        return false
    end
    local set = self:getStatesSysSet()
    for i = #jsonData, 1, -1 do
        if not table.indexof(set, jsonData[i]) then
            table.remove(jsonData, i)
        end
    end
    return jsonData
end

function HeroPropertyProxy:saveLocalData(data)
    if not data then
        return false
    end
    local LoginProxy    = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local mainPlayerID = LoginProxy:GetSelectedRoleID()
    local path    = "hero_state_" .. mainPlayerID
    local key    = "setting"
    local userData = UserData:new(path)
    pcall(function()
        local jsonStr = cjson.encode(data)
        userData:setStringForKey(key, jsonStr)
    end)
    return true
end

function HeroPropertyProxy:GetHeroActor()
    local actor = global.actorManager:GetActor(self:GetRoleUID())
    return actor
end
function HeroPropertyProxy:getIsMergePanelMode()
    local res = false
    if global.ConstantConfig and tonumber(SL:GetMetaValue("GAME_DATA","playerInfoMode")) == 1 and not global.isWinPlayMode and tonumber(SL:GetMetaValue("GAME_DATA","syshero")) == 1 then--heromode 单面板模式
        res = true
    end
    return res
end

function HeroPropertyProxy:IsInited()
    return self.isInited
end

function HeroPropertyProxy:Inited()
    self.isInited = true
end

function HeroPropertyProxy:GetSample()
    return self.VOdata:GetSampleData()
end
-- 等级
function HeroPropertyProxy:GetRoleLevel()
    return self.VOdata:GetLevel()
end
-- 主角名字
function HeroPropertyProxy:GetName()
    return self.VOdata:GetName()
end
-- 行会名字
function HeroPropertyProxy:GetGuildName()
    return self.VOdata:GetGuildName()
end
-- 职业
function HeroPropertyProxy:GetRoleJob()
    local job = self.VOdata:GetRoleJob()
    return job
end
-- 职业
function HeroPropertyProxy:GetRoleJobName()
    local job = self:GetRoleJob()
    local name = GET_STRING(1067 + job)
    return name
end
-- 性别
function HeroPropertyProxy:SetRoleSex(sex)
    self.VOdata:SetRoleSex(sex)
end
function HeroPropertyProxy:GetRoleSex()
    return self.VOdata:GetRoleSex()
end
-- uid
function HeroPropertyProxy:GetRoleUID()
    return self.m_heroid
end
-- 转生
function HeroPropertyProxy:GetRoleReinLv()
    return self.VOdata:GetReinLv()
end
function HeroPropertyProxy:SetRoleReinLv(relevel)
    self.VOdata:SetReinLv(relevel)
    -- rein level
end

--获取玩家状态的脚本的变量
function HeroPropertyProxy:GetVariableInfo()
    return self.VOdata:GetVariableInfo()
end

--设置玩家状态的脚本的变量
function HeroPropertyProxy:SetVariableInfo(variable_info)
    self.VOdata:SetVariableInfo(variable_info)
end

function HeroPropertyProxy:GetRoleCurrHP()
    return self.VOdata:GetRoleCurrHP()
end

function HeroPropertyProxy:GetRoleCurrMP()
    return self.VOdata:GetRoleCurrMP()
end

function HeroPropertyProxy:GetRoleMaxHP()
    return self.VOdata:GetRoleMaxHP()
end

function HeroPropertyProxy:GetRoleMaxMP()
    return self.VOdata:GetRoleMaxMP()
end

-- 当前经验值
function HeroPropertyProxy:GetCurrExp()
    return self.VOdata:GetCurrExp()
end
-- 升级所需经验值
function HeroPropertyProxy:GetNeedExp()
    return self.VOdata:GetNeedExp()
end

function HeroPropertyProxy:GetRoleHPPercent()
    return self:GetRoleCurrHP() / self:GetRoleMaxHP() * 100
end

function HeroPropertyProxy:GetRoleMPPercent()
    return self:GetRoleCurrMP() / self:GetRoleMaxMP() * 100
end
function HeroPropertyProxy:GetRoleEXPPercent()
    return self:GetCurrExp() / self:GetNeedExp() * 100
end

function HeroPropertyProxy:GetLastLevel()
    return self.VOdata:GetLastLevel()
end

function HeroPropertyProxy:GetRoleAttByAttType(attId)
    return self.VOdata:GetAttByAttType(attId)
end

--获取外观
function HeroPropertyProxy:GetFeature()
    return self._feature
end

function HeroPropertyProxy:setAlive( alive )
    self.alive = alive
    if alive then
        self:getFacade():sendNotification( global.NoticeTable.SelfHeroRevive )
    else
        self:getFacade():sendNotification( global.NoticeTable.SelfHeroDie )
    end
end

function HeroPropertyProxy:getAlive()
    return self.alive 
end

function HeroPropertyProxy:SetRoleMana(curHP, maxHP, curMP, maxMP)
    local nData = {}
    if self.maxHP ~= maxHP then
        nData.maxHPChange = true
        self.maxHP = maxHP
    end
    if self.maxMP ~= maxMP then
        nData.maxMPChange = true
        self.maxMP = maxMP
    end
    nData.curHP = curHP
    nData.curMP = curMP
    nData.maxHP = maxHP
    nData.maxMP = maxMP

    self.VOdata:SetRoleManaData(curHP, maxHP, curMP, maxMP)
    global.Facade:sendNotification(global.NoticeTable.PlayerManaChange_Hero, nData)
end

function HeroPropertyProxy:SetCurrExp(value, changed)
    self.VOdata:SetRoleCurrExp(value)
    -- exp change notice
    global.Facade:sendNotification(global.NoticeTable.PlayerExpChange_Hero, { changed = changed })
end

function HeroPropertyProxy:SetLastLevel(level)
    self.VOdata:SetLastLevel(level)
end

function HeroPropertyProxy:SetNeedExp(exp)
    self.VOdata:SetNeedExp(exp)
end

function HeroPropertyProxy:SetFeature(feature)
    self._feature.clothID = feature.clothID
    self._feature.weaponID = feature.weaponID
    self._feature.shieldID = feature.shieldID
    self._feature.wingsID = feature.wingsID
    self._feature.hairID = feature.hairID
    self._feature.leftWeaponID = feature.leftWeaponID
end

function HeroPropertyProxy:SetName(name)
    self.VOdata:SetName(name)
end

function HeroPropertyProxy:SetGuildName(guildname)
    self.VOdata:SetGuildName(guildname)
end

function HeroPropertyProxy:GetPKMode()
    return self.VOdata:GetPKMode()
end

function HeroPropertyProxy:SetPKMode(curse)
    self.VOdata:SetPKMode(curse)
end

function HeroPropertyProxy:SetHeroNameColor(color)
    self.heroNameColor = color and color or 255
    SL:onLUAEvent(LUA_EVENT_HERO_FRAME_NAME_RRFRESH)
end

function HeroPropertyProxy:GetHeroNameColor()
    return self.heroNameColor
end

function HeroPropertyProxy:SetWeight(weight, wearWeight, handWeight)
    self.VOdata:SetWeight(weight, wearWeight, handWeight)
end
--0-2来回切换
function HeroPropertyProxy:RequestChangeHeroMode(idx)
    local state = self:getHeroState()
    state = state + 1
    if state > 2 then--win32
        state = 0
    end
    if idx then--
        state = idx
    end
    self:setHeroState(state)
    LuaSendMsg(global.MsgType.MSG_CS_HERO_ATTACK_MODE, state)
end

function HeroPropertyProxy:setStates(states)
    self.m_states = states
    self:saveLocalData(self.m_states)
end
--当前开启的状态
function HeroPropertyProxy:getStates()
    return self.m_states or {}
end
--锁定对象
function HeroPropertyProxy:RequestLockTarget(id, x, y, isPlayer)
    local isp = isPlayer and 1 or 0
    self._tempID = id
    LuaSendMsg(global.MsgType.MSG_CS_LOCKTARGET_HERO, x, y, isp, 0, id, string.len(id))
end
--守护位置 -- mappos
function HeroPropertyProxy:RequestTargetXY(x, y)
    LuaSendMsg(global.MsgType.MSG_CS_LOCKTARGET_HERO, x, y)
end
function HeroPropertyProxy:CancelLock()
    LuaSendMsg(global.MsgType.MSG_CS_LOCKTARGET_CANCEL_HERO)
end

--守护按钮点击
function HeroPropertyProxy:setGuardBtnState(guard)
    if guard then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000266))
    end
    self._guardState = guard
end
function HeroPropertyProxy:getGuardBtnState()
    return self._guardState
end
function HeroPropertyProxy:CompareAttribute(property)
    if not SL:GetMetaValue("GAME_DATA","isShowAttributeTips") or tonumber(SL:GetMetaValue("GAME_DATA","isShowAttributeTips")) == 0 then
        return nil
    end

    -- 五秒内不播放
    if (not self._attribute_effect_enable) then
        PerformWithDelayGlobal(function()
            self._attribute_effect_enable = true
        end, 5)
    end

    local AttrConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.AttrConfigProxy)
    local AttrType = GUIFunction:PShowAttType()
    -- 
    local isInvalid = true
    local attrItems = {}
    for k, v in pairs(AttrType) do
        local config = AttrConfigProxy:GetAttConfigByAttId(v)
        if config and not self._attr_not_hint[v] then
            local attrValue = 0
            if v == 1 then
                attrValue = self:GetRoleMaxHP()
            elseif v == 2 then
                attrValue = self:GetRoleMaxMP()
            else
                attrValue = self:GetRoleAttByAttType(v)
            end

            attrItems[v] = attrValue
            if attrValue > 0 then
                isInvalid = false
            end
        end
    end

    -- invalid
    if isInvalid then
        return nil
    end

    -- init
    if not next(self._attribute) then
        self._attribute = attrItems
        return nil
    end

    local mfloor = math.floor
    local diffAttr = {}
    for i, v in pairs(AttrType) do
        if attrItems[v] then
            local diff = mfloor(attrItems[v] - (self._attribute[v] or 0))
            if diff >= 1 then
                local data = {}
                data.id = v
                data.value = diff
                table.insert(diffAttr, data)
            end
        end
    end

    if next(diffAttr) and self._attribute_effect_enable then
        local attribute_data = {}
        attribute_data.attributes = diffAttr
        attribute_data.attr_type = 0

        if SL:GetMetaValue("GAME_DATA","isShowAttributeTips") and tonumber(SL:GetMetaValue("GAME_DATA","isShowAttributeTips")) ~= 0 then
            global.Facade:sendNotification(global.NoticeTable.Layer_Notice_Attribute, attribute_data)
        end
        global.Facade:sendNotification(global.NoticeTable.PlayerAttribute_Change_Hero, diffAttr)
    end

    self._attribute = attrItems
end

function HeroPropertyProxy:SyncProperties()
    local Sample = self:GetSample()

    -- 属性对比
    -- 因为脚本属性刷新是一段一段的，需要做个处理，一定时间内没有属性变化时才对比刷新
    if self._attributeScheduleID then
        UnSchedule(self._attributeScheduleID)
        self._attributeScheduleID = nil
    end
    self._attributeScheduleID = PerformWithDelayGlobal(function()
        self:CompareAttribute(Sample)
    end, 1)


    -- level change
    local lastLevel = self:GetLastLevel()
    if lastLevel and lastLevel ~= Sample.level then

        -- notifi
        local nData = {}
        nData.last = lastLevel
        nData.level = Sample.level
        global.Facade:sendNotification(global.NoticeTable.PlayerLevelChange_Hero, nData)
    end
    self:SetLastLevel(Sample.level)
    global.Facade:sendNotification(global.NoticeTable.PlayerPropertyChange_Hero)

    ---------------
    if Sample.job ~= self._lastJob then
        self._lastJob = Sample.job
        global.Facade:sendNotification(global.NoticeTable.PlayerJobChange_Hero, Sample.job)
    end
    if Sample.sex ~= self._lastSex then
        self._lastSex = Sample.sex
        global.Facade:sendNotification(global.NoticeTable.PlayerSexChange_Hero, Sample.sex)
        SLBridge:onLUAEvent(LUA_EVENT_HERO_SEX_CHANGE)
    end

    if Sample.relevel ~= self._lastRelevel then
        self._lastRelevel = Sample.relevel
        global.Facade:sendNotification(global.NoticeTable.PlayerReinLevelChange_Hero, Sample.relevel)
    end
    ----------------

    SLBridge:onLUAEvent(LUA_EVENT_HERO_PROPERTY_CHANGE)

    --
    local actor = self:GetHeroActor()
    if actor then
        actor:SetLevel(Sample.level)
        actor:SetJobID(Sample.job)
        local curHP = self:GetRoleAttByAttType(GUIFunction:PShowAttType().HP)
        local maxHP = self:GetRoleMaxHP()
        actor:SetHPHUD(curHP, maxHP)
        actor:SetNGHUD(self._internalData.force, self._internalData.maxForce)
    end

    if not self:IsInited() then
        self:Inited()
    end

end

function HeroPropertyProxy:handle_MSG_SC_PLAYER_PROPERTIES_HERO(msg)

    local Sample = self:GetSample()
    local data = ParseRawMsgToJson(msg)
    local PShowAttType = GUIFunction:PShowAttType()

    local maxHP                                    = data.maxhp
    local maxMP                                    = data.maxmp
    local curExp                                    = data.exp
    local curHP                                    = data.hp
    local curMP                                    = data.mp
    local sex                                        = data.sex
    local variableInfo                            = data.InfoEx
    --  Sample.yb                                        = head.param2
    Sample.job                                    = data.job
    Sample.sex                                    = data.sex
    Sample.level                                    = data.level
    Sample.needExp                                = data.maxexp
    Sample.relevel                                = data.relevel
    Sample.HeroLuck                                    = data.HeroLuck
    Sample.attdata = {}
    Sample.attdata[PShowAttType.Min_DEF]        = data.ac1   --物防
    Sample.attdata[PShowAttType.Max_DEF]        = data.ac2   --
    Sample.attdata[PShowAttType.Min_MDF]        = data.mac1  --魔防
    Sample.attdata[PShowAttType.Max_MDF]        = data.mac2
    Sample.attdata[PShowAttType.Min_ATK]        = data.dc1   --物理
    Sample.attdata[PShowAttType.Max_ATK]        = data.dc2
    Sample.attdata[PShowAttType.Min_MAT]        = data.mc1   --魔法
    Sample.attdata[PShowAttType.Max_MAT]        = data.mc2
    Sample.attdata[PShowAttType.Min_Daoshu]        = data.sc1   --道术
    Sample.attdata[PShowAttType.Max_Daoshu]        = data.sc2
    Sample.attdata[PShowAttType.HP]                = curHP         --生命
    Sample.attdata[PShowAttType.MP]                = curMP         --魔法
    Sample.attdata[PShowAttType.Weight]            = data.weight--当前重量
    Sample.attdata[PShowAttType.Max_Weight]        = data.maxweight--玩家最大负重
    Sample.attdata[PShowAttType.Wear_Weight]    = data.wearweight--穿戴负重
    Sample.attdata[PShowAttType.Max_Wear_Weight] = data.maxwearweight--最大穿戴负重
    Sample.attdata[PShowAttType.Hand_Weight]    = data.handweight--腕力
    Sample.attdata[PShowAttType.Max_Hand_Weight] = data.maxhandweight--当前最大可穿戴腕力
    Sample.attdata[PShowAttType.Anti_Magic]        = data.antimagic
    Sample.attdata[PShowAttType.Hit_Point]        = data.hitPoint
    Sample.attdata[PShowAttType.Speed_Point]    = data.SpeedPoint
    Sample.attdata[PShowAttType.Anti_Posion]    = data.AntiPoison
    Sample.attdata[PShowAttType.Posion_Recover]    = data.PoisonRecover
    Sample.attdata[PShowAttType.Health_Recover]    = data.HealthRecover
    Sample.attdata[PShowAttType.Spell_Recover]    = data.SpellRecover
    Sample.attdata[PShowAttType.Hit_Speed]        = data.HitSpeed
    Sample.attdata[PShowAttType.Block_Rate]        = data.GedangRate
    Sample.attdata[PShowAttType.Block_Value]    = data.GedangPower
    Sample.attdata[PShowAttType.Double_Rate]    = data.BjRate
    Sample.attdata[PShowAttType.Double_Damage]    = data.BjPoint
    Sample.attdata[PShowAttType.Defence]        = data.Abil23
    Sample.attdata[PShowAttType.Double_Defence]    = data.Abil24
    Sample.attdata[PShowAttType.More_Damage]    = data.Abil25
    Sample.attdata[PShowAttType.ATK_Defence]    = data.Abil26
    Sample.attdata[PShowAttType.MAT_Defence]    = data.Abil27
    Sample.attdata[PShowAttType.Ignore_Defence]    = data.Abil28
    Sample.attdata[PShowAttType.Bounce_Damage]    = data.Abil29
    Sample.attdata[PShowAttType.Health_Add]        = data.Abil30
    Sample.attdata[PShowAttType.Magice_Add]        = data.Abil31
    Sample.attdata[PShowAttType.More_Item]        = data.Abil32
    Sample.attdata[PShowAttType.Less_Item]        = data.Abil33
    Sample.attdata[PShowAttType.Vampire]        = data.Abil34
    Sample.attdata[PShowAttType.A_M_D_Add]        = data.Abil35
    Sample.attdata[PShowAttType.Defence_Add]    = data.Abil36
    Sample.attdata[PShowAttType.MDefence_Add]    = data.Abil37
    Sample.attdata[PShowAttType.God_Damage]        = data.Abil38
    Sample.attdata[PShowAttType.Lucky]            = data.Abil39
    Sample.attdata[PShowAttType.Monster_Damage_Value] = data.Abil40
    Sample.attdata[PShowAttType.Monster_Damage_Per]    = data.Abil41
    Sample.attdata[PShowAttType.Anger_Recover]        = data.Abil42
    Sample.attdata[PShowAttType.Combine_Skill_Damage] = data.Abil43
    Sample.attdata[PShowAttType.Monster_DropItem]    = data.Abil44
    Sample.attdata[PShowAttType.No_Palsy]            = data.Abil45
    Sample.attdata[PShowAttType.No_Protect]            = data.Abil46
    Sample.attdata[PShowAttType.No_Rebirth]            = data.Abil47
    Sample.attdata[PShowAttType.No_ALL]                = data.Abil48
    Sample.attdata[PShowAttType.No_Charm]            = data.Abil49
    Sample.attdata[PShowAttType.No_Fire]            = data.Abil50
    Sample.attdata[PShowAttType.No_Ice]                = data.Abil51
    Sample.attdata[PShowAttType.No_Web]                = data.Abil52
    Sample.attdata[PShowAttType.Att_UnKonw]            = data.Abil53
    Sample.attdata[PShowAttType.More_A_Damage]        = data.Abil54
    Sample.attdata[PShowAttType.Less_A_Damage]        = data.Abil55
    Sample.attdata[PShowAttType.More_M_Damage]        = data.Abil56
    Sample.attdata[PShowAttType.Less_M_Damage]        = data.Abil57
    Sample.attdata[PShowAttType.More_D_Damage]        = data.Abil58
    Sample.attdata[PShowAttType.Less_D_Damage]        = data.Abil59
    Sample.attdata[PShowAttType.More_Health_Per]    = data.Abil60
    Sample.attdata[PShowAttType.HP_Recover]            = data.Abil61
    Sample.attdata[PShowAttType.MP_Recover]            = data.Abil62
    --  Sample.attdata[PShowAttType.Block_Rate]            = data.Abil63
    --  Sample.attdata[PShowAttType.Block_Value]           = data.Abil64
    Sample.attdata[PShowAttType.Drop_Rate]            = data.Abil65
    Sample.attdata[PShowAttType.Exp_Add_Rate]        = data.Abil66
    Sample.attdata[PShowAttType.Damage_Rate_Add]    = data.Abil67
    Sample.attdata[PShowAttType.Damage_Human]        = data.Abil68
    Sample.attdata[PShowAttType.Ice_Rate]            = data.Abil69
    Sample.attdata[PShowAttType.Defen_Ice]            = data.Abil70

    Sample.attdata[PShowAttType.Sec_Recovery_HP]    = data.Abil71
    Sample.attdata[PShowAttType.Mon_Bj_Power_Rate]    = data.Abil72
    Sample.attdata[PShowAttType.DC_Add_Rate]        = data.Abil73
    local monPKV = data.FaMeMonPK or 0
    local abil74 = data.Abil74 or 0
    Sample.attdata[PShowAttType.Monster_Damage]        = abil74 + monPKV
    Sample.attdata[PShowAttType.Monster_Damage_Percent] = data.Abil75
    Sample.attdata[PShowAttType.PK_Damage_Add_Percent] = data.Abil76
    local pk = data.FaMePK or 0
    local abil77 = data.Abil77 or 0
    Sample.attdata[PShowAttType.PK_Damage_Dec_Percent] = abil77 + pk
    Sample.attdata[PShowAttType.Penetrate]            = data.Abil78
    Sample.attdata[PShowAttType.Death_Hit_Percent]    = data.Abil79
    Sample.attdata[PShowAttType.Death_Hit_Value]    = data.Abil80
    Sample.attdata[PShowAttType.Monster_Suck_HP_Rate] = data.Abil81
    Sample.attdata[PShowAttType.Monster_Vampire]    = data.Abil82
    Sample.attdata[PShowAttType.Less_Monster_Damage] = data.Abil83
    Sample.attdata[PShowAttType.Drug_Recover]        = data.Abil84
    Sample.attdata[PShowAttType.Ignore_Def_Dec]        = data.Abil85
    Sample.attdata[PShowAttType.Fire_Hit_Dec_Rate]    = data.Abil86
    Sample.attdata[PShowAttType.Ergum_Hit_Dec_Rate]    = data.Abil87
    Sample.attdata[PShowAttType.Hit_Plus_Dec_Rate]    = data.Abil88
    Sample.attdata[PShowAttType.Health_Add_WPer]       = data.Abil89
    Sample.attdata[PShowAttType.Death_Hit_Dec_Percent] = data.Abil90
    Sample.attdata[PShowAttType.Sec_Recovery_MP]    = data.Abil91

    Sample.attdata[PShowAttType.Internal_AddPower]        = data.Abil101
    Sample.attdata[PShowAttType.Internal_DecPower]        = data.Abil102
    Sample.attdata[PShowAttType.HJ_DecPower]              = data.Abil103
    Sample.attdata[PShowAttType.Internal_ForceRate]       = data.Abil104
    Sample.attdata[PShowAttType.Internal_DZValue]         = data.Abil105
    Sample[PShowAttType.All_Du_ADD]                       = data.Abil130
    Sample[PShowAttType.All_Du_Less]                      = data.Abil131

    if data.CustAbil then
        for i, v in ipairs(data.CustAbil) do
            Sample.attdata[v[1]]    = v[2]
        end
    end

    self:SetRoleSex(sex)
    self:SetRoleMana(curHP, maxHP, curMP, maxMP)
    self:SetCurrExp(curExp)
    self:SetVariableInfo(variableInfo)
    self:SetHeroLuck(Sample.HeroLuck)

    -- 内功
    self:SetInternalData(data)

    -- print("-----------------------property change", curExp, data.maxexp, Sample.level)
    local bagnum = data.HeroBagCount
    local HeroBagProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
    if HeroBagProxy:getBagMaxNum() ~= bagnum then
        HeroBagProxy:setBagMaxNum(bagnum)
        global.Facade:sendNotification(global.NoticeTable.HeroBagCountChnage, bagnum)
        SLBridge:onLUAEvent(LUA_EVENT_REF_HERO_ITEM_LIST)
    end


    local SndaItemBoxOpened = data.SndaItemBoxOpened or false
    local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
    HeroEquipProxy:SetBestRingsOpenState(SndaItemBoxOpened == 1)

    self:SyncProperties()
end

function HeroPropertyProxy:handle_MSG_SC_PLAYER_EXP_HERO(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return nil
    end

    local isNG = tonumber(jsonData.isNG) or 0
    if isNG == 0 then
        local currentExp = tonumber(jsonData.curr) or 0
        local changed    = tonumber(jsonData.changed) or 0
        self:SetCurrExp(currentExp, changed)

        if changed and changed > 0 then
            local value    = GET_SETTING(35, true)
            local disable = value[1] == 1
            local limit    = tonumber(value[2]) or 1
            if not disable or changed >= limit then

                if CHECK_SERVER_OPTION(global.MMO.SERVER_EXP_IN_CHAT) == 0 then
                    local str = string.format(GET_STRING(600000222), changed)
                    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
                    local mdata = {
                        Msg        = str,
                        FColor    = 255,
                        BColor    = 249,
                        ChannelId = ChatProxy.CHANNEL.System,
                    }
                    global.Facade:sendNotification(global.NoticeTable.AddChatItem, mdata)
                else

                    local pointList = SL:GetMetaValue("GAME_DATA","pointList")
                    if not pointList then
                        return
                    end

                    if changed < pointList[4] then
                        return
                    end

                    local str = string.format(GET_STRING(600000216), changed)
                    local platformIndex = global.isWinPlayMode and 1 or 2
                    local mdata = {
                        Msg        = str,
                        X        = pointList[platformIndex].X,
                        Y        = pointList[platformIndex].Y,
                        FColor    = pointList[3].X,
                        BColor    = pointList[3].Y,
                    }

                    global.Facade:sendNotification(global.NoticeTable.ShowPlayerEXPNotice, mdata)
                end
            end
        end
    elseif isNG == 1 then -- 内功经验
        local currentExp = tonumber(jsonData.curr) or 0
        local changed    = tonumber(jsonData.changed) or 0
        self:SetInternalExp(currentExp, changed)
    end
end

function HeroPropertyProxy:GetHeroLuck()
    return self.VOdata:GetHeroLuck()
end

function HeroPropertyProxy:SetHeroLuck(_HeroLuck)
    local HeroLuck = self:GetHeroLuck()
    if _HeroLuck and HeroLuck ~= _HeroLuck then --请求刷新
        self.VOdata:SetHeroLuck(_HeroLuck)
        global.Facade:sendNotification(global.NoticeTable.PlayerPropertyChange_Hero)
    end
end

function HeroPropertyProxy:GetShowSetting()
    return self._superEquipShowSetting
end

function HeroPropertyProxy:SetShowSetting(show)
    self._superEquipShowSetting = show
end

function HeroPropertyProxy:SetShowGodMgicSetting(show)
    self._godMgicShowSetting = show
end

function HeroPropertyProxy:SetInternalForce(value)
    self._internalData.force = value
end

function HeroPropertyProxy:RefreshNGHUD()
    local actor = self:GetHeroActor()
    if actor then
        actor:SetNGHUD(self._internalData.force, self._internalData.maxForce)
    end
end

function HeroPropertyProxy:SetInternalExp(value, changed)
    self._internalData.exp = value
    SL:onLUAEvent(LUA_EVENT_HERO_INTERNAL_EXP_CHANGE, {changed = changed})
end

function HeroPropertyProxy:SetInternalDZValue(curValue, maxValue)
    self.VOdata:SetDZValue(curValue)
    self._internalData.maxDZValue = maxValue
end

function HeroPropertyProxy:SetInternalData(data)
    local lastLv = self._internalData.level or 0
    self._internalData.force = data.InternalForce or 0              -- 内力值
    self._internalData.maxForce = data.MaxInternalForce or 0        -- 内力值上限
    self._internalData.exp = data.InternalEXP or 0                  -- 内功经验值
    self._internalData.maxExp = data.MaxInternalEXP or 0            -- 内功经验值上限
    self._internalData.level = data.InternalLevel or 0              -- 内功等级
    self._internalData.maxDZValue = data.MaxDZXYValue or 0          -- 最大斗转星移值
    if lastLv ~= self._internalData.level then
        global.Facade:sendNotification(global.NoticeTable.HeroInternalLevelChange)
        SLBridge:onLUAEvent(LUA_EVENT_HERO_INTERNAL_LEVEL_CHANGE, {lastLevel = lastLv, curLevel = self._internalData.level})
    end
    if lastLv == 0 and self._internalData.level > lastLv then
        SLBridge:onLUAEvent(LUA_EVENT_HERO_LEARNED_INTERNAL)
    end
end

function HeroPropertyProxy:GetInternalData()
    return self._internalData
end

function HeroPropertyProxy:SetIForceData(force, maxForce)
    if force then
        self._internalData.force = force
    end
    if maxForce then
        self._internalData.maxForce = maxForce
    end
    SL:onLUAEvent(LUA_EVENT_HERO_INTERNAL_FORCE_CHANGE)
end

function HeroPropertyProxy:SendSuperEquipSetting(stting_type)
    local state = 0
    local data = nil
    if stting_type == 1 then
        if self._superEquipShowSetting then
            state = 1
        end
        data = {
            ShowShiZhuang = state
        }
    elseif stting_type == 2 then
        if self._godMgicShowSetting then
            state = 1
        end
        data = {
            ShowShenMo = state
        }
    end

    if data then
        local cjson = require("cjson")
        local jsonStr = cjson.encode(data)
        
        LuaSendMsg(global.MsgType.MSG_CS_SUPER_EQUIP_SETTING_HERO, 0, 0, 0, 0, jsonStr, string.len(jsonStr))
    end
end

--获取主角切页开关     main_player_layer: 主角切页
function HeroPropertyProxy:GetMainPlayerPageSwitch(main_player_layer, look_player)
    if look_player then
        return self._mainLookPlayerPageSwitch[main_player_layer]
    end
    if self._mainPlayerPageSwitch[main_player_layer] ~= false then
        return true
    end
    return false
end

--设置主角切页开关     main_player_layer: 主角切页   is_turn_on: 开关是否开启
function HeroPropertyProxy:SetMainPlayerPageSwitch(main_player_layer, is_turn_on)
    self._mainPlayerPageSwitch[main_player_layer] = is_turn_on
end

--召唤英雄或收起
function HeroPropertyProxy:RequestHeroInOrOut()
    LuaSendMsg(global.MsgType.MSG_CS_HERO, 0, 0, 0, 0, 0, 0)
end
-- 角色名字  名字颜色ID
function HeroPropertyProxy:handle_MSG_SC_PLAYER_NAMEANDID_HERO(msg)
    local msgLen = msg:GetDataLength()
    local msgHdr = msg:GetHeader()
    if msgLen <= 0 then
        return
    end
    local dataString = msg:GetData():ReadString(msgLen)
    local strs = string.split(dataString, "&")
    self:SetName(strs[1])
    self:SetHeroNameColor(msgHdr.param1)

end
--请求合击
function HeroPropertyProxy:ReqJointAttack()
    if not global.isWinPlayMode then
        local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
        local skillID = HeroSkillProxy:haveHeroSkill()
        if skillID then
            global.Facade:sendNotification(global.NoticeTable.SkillEnterCD_Hero, skillID)
        end
    end
    LuaSendMsg(global.MsgType.MSG_CS_JOINTATTACK_HERO, 0, 0, 0, 0, 0, 0)
end

function HeroPropertyProxy:getShan()
    return self._shan
end
function HeroPropertyProxy:getMaxAnger()
    return self._angerMax
end
--获取当前怒气
function HeroPropertyProxy:getCurAnger()
    return self._angerCur
end

function HeroPropertyProxy:getDelayTime()
    return self._delayTime
end
function HeroPropertyProxy:getSpeed()
    return self._speed
end

--英雄怒气值
function HeroPropertyProxy:handle_MSG_SC_ANGER_HERO(msg)
    local msgLen = msg:GetDataLength()
    local msgHdr = msg:GetHeader()
    local max = msgHdr.recog or 0
    local cur = msgHdr.param1 or 0
    local s = msgHdr.param2 or 0
    self._angerMax = max
    self._angerCur = cur
    self._shan = s == 1
    self._delayTime = msgHdr.param3 or 1

    local msgLen = msg:GetDataLength()
    if msgLen > 0 then
        local dataString = msg:GetData():ReadString(msgLen)
        self._speed = tonumber(dataString) or 10

    end

    SLBridge:onLUAEvent(LUA_EVENT_HERO_ANGER_CAHNGE)

end

--获取英雄状态0 攻击  1 跟随 2 休息
function HeroPropertyProxy:getHeroState()
    return self._state or 0
end
function HeroPropertyProxy:setHeroState(state)
    self._state = state
end
--获取英雄守护状态0   1 
function HeroPropertyProxy:getHeroGuardState()
    return self._guard or 0
end




--获取英雄锁定状态0   1 
function HeroPropertyProxy:getHeroLockState()
    return self._target or 0
end
function HeroPropertyProxy:setLockID(ID)
    self._lockTargetID = ID
end
function HeroPropertyProxy:getLockID()
    return self._lockTargetID
end
--英雄状态
function HeroPropertyProxy:handle_MSG_SC_PLAYER_STATE_HERO(msg)
    local msgLen = msg:GetDataLength()
    local msgHdr = msg:GetHeader()
    local state = msgHdr.recog or 0
    local guard = msgHdr.param1 or 0
    local target = msgHdr.param2 or 0
    self._state = state -- 状态
    self._guard = guard -- 守护
    self._target = target -- 锁定
    if target == 1 and self._tempID then
        self:setLockID(self._tempID)
        self._tempID = nil
        global.Facade:sendNotification(global.NoticeTable.HeroLock_Icon)
    elseif target == 0 then
        self:setLockID(nil)
        global.Facade:sendNotification(global.NoticeTable.HeroLock_Icon)
    end
    global.Facade:sendNotification(global.NoticeTable.HeroState_change)
end

--英雄开关
function HeroPropertyProxy:IsHeroOpen()
    local res = false
    if global.ConstantConfig and tonumber(SL:GetMetaValue("GAME_DATA","syshero")) == 1 then
        res = true
    end
    return res
end
--英雄面板模式 1 单面板  2多面板
function HeroPropertyProxy:getHeroPanelMode()
    local res = "1"
    if global.ConstantConfig and tonumber(SL:GetMetaValue("GAME_DATA","playerInfoMode")) == 2 then
        res = "2"
    end
    return res
end
--英雄出生
function HeroPropertyProxy:handle_MSG_SC_HEROLOGIN(msg)

    local msgLen = msg:GetDataLength()
    local msgHdr = msg:GetHeader()
    if msgLen <= 0 then
        return
    end
    local dataString = msg:GetData():ReadString(msgLen)
    local ids = string.split(dataString, "&")
    local playerID = ids[1]
    local heroID = ids[2]
    local func = function(sender, eventType)
        sender:removeFromParent()
    end
    local animID = 98
    local anim = global.FrameAnimManager:CreateSFXAnim(animID)
    local srcX    = msgHdr.param1
    local srcY    = msgHdr.param2

    local worldPos    = global.sceneManager:MapPos2WorldPos(srcX, srcY)
    local root = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_ACTOR_SFX_FRONT)
    root:addChild(anim)
    anim:setPosition(worldPos)
    anim:setLocalZOrder(animID)
    anim:Play(0, 0, true)
    anim:SetAnimEventCallback(func)
    global.Facade:sendNotification(global.NoticeTable.Audio_Play, { type = global.MMO.SND_TYPE_FLY_IN_HERO })
    if playerID == global.playerManager:GetMainPlayerID() then
        self.m_heroid = heroID
        self._herologin = true
        global.Facade:sendNotification( global.NoticeTable.Layer_Hero_Login )
        global.Facade:sendNotification( global.NoticeTable.HeroLock_Icon)--刷新图标
        SLBridge:onLUAEvent(LUA_EVENT_HERO_LOGIN_OROUT, true)
    end
end

--英雄退出
function HeroPropertyProxy:handle_MSG_SC_HEROLOGOUT(msg)

    local msgLen = msg:GetDataLength()
    local msgHdr = msg:GetHeader()
    if msgLen <= 0 then
        return
    end
    local dataString = msg:GetData():ReadString(msgLen)
    local ids = string.split(dataString, "&")
    local playerID = ids[1]
    local heroID = ids[2]
    local actor    = global.actorManager:GetActor(heroID)
    local func = function(sender, eventType)
        sender:removeFromParent()
    end
    local animID = 99
    local anim = global.FrameAnimManager:CreateSFXAnim(animID)
    local srcX    = msgHdr.param1
    local srcY    = msgHdr.param2

    local worldPos    = global.sceneManager:MapPos2WorldPos(srcX, srcY)
    local root = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_ACTOR_SFX_FRONT)
    root:addChild(anim)
    anim:setPosition(worldPos)
    anim:setLocalZOrder(animID)
    anim:Play(0, 0, true)
    anim:SetAnimEventCallback(func)
    if playerID == global.playerManager:GetMainPlayerID() then--如果是自己的英雄

        self:NoticeOut()
    end
    global.Facade:sendNotification(global.NoticeTable.Audio_Play, { type = global.MMO.SND_TYPE_FLY_OUT_HERO })
end

function HeroPropertyProxy:NoticeOut()--英雄退出 或尸体消失 -- 或主角死亡
    self._angerCur = 0
    self._shan = false
    self:setLockID(nil)
    self._herologin = false
    --隐藏英雄怒气
    SLBridge:onLUAEvent(LUA_EVENT_HERO_ANGER_CAHNGE)
    global.Facade:sendNotification(global.NoticeTable.HeroLock_Icon)--刷新图标


    self._LoginCDTime = self._LoginCD
    if self.ScheduleID1 then
        UnSchedule(self.ScheduleID1)
    end
    self.ScheduleID1 = Schedule(function()
        self._LoginCDTime = self._LoginCDTime - 1
        if self._LoginCDTime <= 0 then
            self._LoginCDTime = 0
            UnSchedule(self.ScheduleID1)
            self.ScheduleID1 = nil
        end
    end, 1)
    local HeroSkillProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
    HeroSkillProxy:DelAllSkill()



    local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
    HeroEquipProxy:loginOut()
    local HeroPropertyVO = requireVO("remote/HeroPropertyVO")
    self.VOdata = HeroPropertyVO.new()
    self._guardState     = false
    self.isInited        = false
    self.alive           = true
    self.heroNameColor   = 255
    self._feature        =    
    {
        clothID            = 0,
        weaponID            = 0,
        shieldID            = 0,
        wingsID            = 0,
        fireID            = 0,
        hairID            = 0,
        leftWeaponID      = 0,
    }

    self._godMgicShowSetting = true --设置显示神魔
    self._superEquipShowSetting = false --设置时装显示
    self._attribute        = {}
    self._lockTargetID = nil
    ---怒气
    self._angerMax = 0 --最大怒气
    self._angerCur = 0--当前怒气
    self._shan = false --是否要闪
    self._speed = 10
    self._delayTime = 1
    ----
    self.m_heroid = nil
    global.Facade:sendNotification(global.NoticeTable.Layer_Hero_Logout)
    SLBridge:onLUAEvent(LUA_EVENT_HERO_LOGIN_OROUT, false)
end

function HeroPropertyProxy:handle_MSG_SC_PLAYER_RELIVE_STATE(msg)
    local header = msg:GetHeader()
    self._canRevive = header.param1 == 1
end
function HeroPropertyProxy:handle_MSG_SC_HERO_DIE(msg)
    self:setAlive(false)
end

function HeroPropertyProxy:handle_MSG_SC_HERO_ITEM_REMOVE(msg)
    local len = msg:GetDataLength()
    if len <= 0 then
        return
    end
    local msgData = msg:GetData()
    local sliceStr = msgData:ReadString(len)
    local MakeIndexList = {}
    local itemList = string.split(sliceStr, "/")
    for k,v in pairs(itemList) do
        if tonumber(v) then
        table.insert(MakeIndexList, tonumber(v))
        end
    end
    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    ItemManagerProxy:RemoveItems(MakeIndexList)
end

function HeroPropertyProxy:HeroIsLogin()
    return self._herologin
end

function HeroPropertyProxy:IsCanRevive()
    return self._canRevive
end

function HeroPropertyProxy:onRegister()
    HeroPropertyProxy.super.onRegister(self)
end

function HeroPropertyProxy:RegisterMsgHandler()
    HeroPropertyProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_PROPERTIES_HERO,    handler(self, self.handle_MSG_SC_PLAYER_PROPERTIES_HERO))   -- 角色基础属性
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_NAMEANDID_HERO,    handler(self, self.handle_MSG_SC_PLAYER_NAMEANDID_HERO))   -- 角色名字  名字颜色ID
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_EXP_HERO,        handler(self, self.handle_MSG_SC_PLAYER_EXP_HERO))             -- 角色经验值

    LuaRegisterMsgHandler(msgType.MSG_SC_ANGER_HERO,        handler(self, self.handle_MSG_SC_ANGER_HERO))             -- 英雄怒气
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_STATE_HERO,    handler(self, self.handle_MSG_SC_PLAYER_STATE_HERO))
    LuaRegisterMsgHandler(msgType.MSG_SC_HEROLOGIN, handler(self, self.handle_MSG_SC_HEROLOGIN))--英雄出生
    LuaRegisterMsgHandler(msgType.MSG_SC_HEROLOGOUT, handler(self, self.handle_MSG_SC_HEROLOGOUT))--英雄退出

    LuaRegisterMsgHandler(msgType.MSG_SC_HERO_ITEM_REMOVE,    handler( self, self.handle_MSG_SC_HERO_ITEM_REMOVE) )--死亡掉落

    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_RELIVE_STATE,    handler(self, self.handle_MSG_SC_PLAYER_RELIVE_STATE))        -- 是否可复活状态(角色的地方也有监听，不是bug)
    LuaRegisterMsgHandler(msgType.MSG_SC_HERO_DIE,    handler(self, self.handle_MSG_SC_HERO_DIE))--英雄死亡
end

return HeroPropertyProxy