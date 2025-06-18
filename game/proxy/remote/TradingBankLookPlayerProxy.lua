local RemoteProxy = requireProxy("remote/RemoteProxy")
local TradingBankLookPlayerProxy = class("TradingBankLookPlayerProxy", RemoteProxy)
TradingBankLookPlayerProxy.NAME = global.ProxyTable.TradingBankLookPlayerProxy
function TradingBankLookPlayerProxy:ctor()
    TradingBankLookPlayerProxy.super.ctor(self)

    self:initData()
    self.SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
end
function TradingBankLookPlayerProxy:initData()
    self.lookPlayerData = {}
    self.lookPlayerItems = {}
    self.fashionData = {}
    self.fashionId = {
        dress = 4,
        weapon = 5
    }
    self.titleData = {} --称号数据
    self._titleActive = nil --激活的称号
    self.m_BagItems = {}
    self.m_storeItems = {}
    self.m_skills = {}
    self.m_baseAtr = {}


    self.lookPlayerData_Hero = {}
    self.lookPlayerItems_Hero = {}
    self.fashionData_Hero = {}
    self.titleData_Hero = {} --称号数据
    self._titleActive_Hero = nil --激活的称号
    self.m_BagItems_Hero = {}
    self.m_storeItems_Hero = {}
    self.m_skills_Hero = {}
    self.m_baseAtr_Hero = {}
    self.m_hasHeroData = false



    self._func = nil
end
function TradingBankLookPlayerProxy:onRegister()
    TradingBankLookPlayerProxy.super.onRegister(self)
end
function TradingBankLookPlayerProxy:getBagItems()
    return self.m_BagItems
end
function TradingBankLookPlayerProxy:getBagItems_Hero()
    return self.m_BagItems_Hero
end
function TradingBankLookPlayerProxy:getStoreItems()
    return self.m_storeItems
end
function TradingBankLookPlayerProxy:handle_MSG_SC_ROLE_INFO_RESPONSE(msg)
    local header = msg:GetHeader()
    local recog = header.recog
    -- self:SetEmbattle(recog)
    -- self:SetEmbattle_Hero(recog)
    local data = ParseRawMsgToJson(msg)
    if recog == 1 then--bag
        local bagitems = {}
        data = data or {}
        for i, v in ipairs(data) do
            local vv = ChangeItemServersSendDatas(v)
            table.insert(bagitems, vv)
        end
        self.m_BagItems = bagitems
        return
    elseif recog == 2 then --storeitems
        local storeitems = {}
        data = data or {}
        for i, v in ipairs(data) do
            local vv = ChangeItemServersSendDatas(v)
            table.insert(storeitems, vv)
        end
        self.m_storeItems = storeitems
        return
    end

    if not data then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000057))
        return
    end



    self._titleActive = data.active
    self.m_skills = {}
    if data.Magic then
        for _, v in ipairs(data.Magic) do
            local skill = self:parseOneSkillData(v)
            self:AddSkill(skill)
        end
    end

    self:SetLookPlayerItemData(data.Items)

    self:SetLookPlayerFashion(data.t_dress, data.t_weapon)

    self:SetLookPlayerData(data)

    self:SetLookPlayerTitle(data.Titles)
    if data.UserState then
        self:setBaseAtr(data.UserState)
    end

    -------------------------------
    if data.HeroData then
        self.m_hasHeroData = true
        local HeroData = data.HeroData
        local herobagitems = {}
        local herostoreitems = {}
        HeroData.BagItems = HeroData.BagItems or {}
        for i, v in ipairs(HeroData.BagItems) do
            local vv = ChangeItemServersSendDatas(v)
            table.insert(herobagitems, vv)
        end
        HeroData.StoreItems = HeroData.StoreItems or {}
        for i, v in ipairs(HeroData.StoreItems) do
            local vv = ChangeItemServersSendDatas(v)
            table.insert(herostoreitems, vv)
        end
        self.m_BagItems_Hero = herobagitems
        self.m_storeItems_Hero = herostoreitems
        self._titleActive_Hero = HeroData.active
        self.m_skills_Hero = {}
        if HeroData.Magic then
            for _, v in ipairs(HeroData.Magic) do
                local skill = self:parseOneSkillData(v)
                self:AddSkill_Hero(skill)
            end
        end

        self:SetLookPlayerItemData_Hero(HeroData.Items)

        self:SetLookPlayerFashion_Hero(HeroData.t_dress, HeroData.t_weapon)

        self:SetLookPlayerData_Hero(HeroData)

        self:SetLookPlayerTitle_Hero(HeroData.Titles)
        if HeroData.UserState then
            self:setBaseAtr(HeroData.UserState, true)
        end
    end

    -------------------------------


    -- print("=====查看玩家")

    self._isget = true
    if self._func then
        self._func()
    end
end
function TradingBankLookPlayerProxy:haveData()
    return self._isget
end
function TradingBankLookPlayerProxy:haveData_Hero()
    return self.m_hasHeroData
end
function TradingBankLookPlayerProxy:GetRoleJobName_Hero()
    if not self.m_HerobaseAtr then
        return GET_STRING(1067 + 0)
    end
    local job = self.m_HerobaseAtr.job
    local name = GET_STRING(1067 + job)
    return name
end
function TradingBankLookPlayerProxy:GetRoleReinLv_Hero()
    if not self.m_HerobaseAtr then
        return 0
    end
    return self.m_HerobaseAtr.relevel
end
function TradingBankLookPlayerProxy:GetRoleLevel_Hero()
    if not self.m_HerobaseAtr then
        return 0
    end
    return self.m_HerobaseAtr.level
end

function TradingBankLookPlayerProxy:GetCurrExp_Hero()
    if not self.m_HerobaseAtr then
        return 0
    end
    return self.m_HerobaseAtr.curExp
end
function TradingBankLookPlayerProxy:GetNeedExp_Hero()
    if not self.m_HerobaseAtr then
        return 0
    end
    return self.m_HerobaseAtr.needExp
end
function TradingBankLookPlayerProxy:GetSuperExp_Hero()
    if not self.m_HerobaseAtr then
        return 0
    end
    return self.m_HerobaseAtr.SuperExp
end
function TradingBankLookPlayerProxy:GetRoleCurrHP_Hero()
    return self:GetRoleAttByAttType_Hero(GUIFunction:PShowAttType().HP)
end
function TradingBankLookPlayerProxy:GetRoleMaxHP_Hero()
    if not self.m_HerobaseAtr then
        return 0
    end
    return self.m_HerobaseAtr.maxHP or 1
end
function TradingBankLookPlayerProxy:GetRoleCurrMP_Hero()
    return self:GetRoleAttByAttType_Hero(GUIFunction:PShowAttType().MP)
end
function TradingBankLookPlayerProxy:GetRoleMaxMP_Hero()
    if not self.m_HerobaseAtr then
        return 0
    end
    return self.m_HerobaseAtr.maxHP or 1
end

function TradingBankLookPlayerProxy:GetVariableInfo_Hero()
    if not self.m_HerobaseAtr then
        return 0
    end
    return self.m_HerobaseAtr.variableInfo
end
function TradingBankLookPlayerProxy:GetRoleAttByAttType_Hero(attid)
    if not self.m_HerobaseAtr then
        return 0
    end
    local data = self.m_HerobaseAtr.attdata or {}
    if data[attid] then
        return data[attid]
    end
    return 0
end



function TradingBankLookPlayerProxy:GetRoleJobName()
    local job = self.m_baseAtr.job or 0
    local name = GetJobName(job)
    return name
end
function TradingBankLookPlayerProxy:GetRoleReinLv()
    return self.m_baseAtr.relevel
end
function TradingBankLookPlayerProxy:GetRoleLevel()
    return self.m_baseAtr.level
end

function TradingBankLookPlayerProxy:GetCurrExp()
    return self.m_baseAtr.curExp
end
function TradingBankLookPlayerProxy:GetNeedExp()
    return self.m_baseAtr.needExp
end
function TradingBankLookPlayerProxy:GetRoleCurrHP()
    return self:GetRoleAttByAttType(GUIFunction:PShowAttType().HP)
end
function TradingBankLookPlayerProxy:GetRoleMaxHP()
    return self.m_baseAtr.maxHP or 1
end
function TradingBankLookPlayerProxy:GetRoleCurrMP()
    return self:GetRoleAttByAttType(GUIFunction:PShowAttType().MP)
end
function TradingBankLookPlayerProxy:GetRoleMaxMP()
    return self.m_baseAtr.maxHP or 1
end

function TradingBankLookPlayerProxy:GetVariableInfo()
    return self.m_baseAtr.variableInfo
end
function TradingBankLookPlayerProxy:GetRoleAttByAttType(attid)
    local data = self.m_baseAtr.attdata or {}
    if data[attid] then
        return data[attid]
    end
    return 0
end

function TradingBankLookPlayerProxy:setBaseAtr(data, isHero)
    local maxHP                                    = data.maxhp
    local maxMP                                    = data.maxmp
    local curExp                                    = data.exp
    local curHP                                    = data.hp
    local curMP                                    = data.mp
    local sex                                        = data.sex
    local variableInfo                            = data.InfoEx
    --  Sample.yb                                        = head.param2
    local Sample = {}
    if isHero then
        self.m_HerobaseAtr = {}
        Sample = self.m_HerobaseAtr
    else

        self.m_baseAtr = {}
        Sample = self.m_baseAtr
    end

    Sample.maxMP                            = maxMP
    Sample.curMP                            = curMP
    Sample.maxHP                            = maxHP
    Sample.curHP                            = curHP
    Sample.curExp                            = curExp
    Sample.MaxSuperExp                            = data.MaxSuperExp
    Sample.SuperExp                                = data.SuperExp
    Sample.variableInfo                            = variableInfo
    Sample.job                                    = data.job
    Sample.sex                                    = data.sex
    Sample.level                                    = data.level
    Sample.needExp                                = data.maxexp
    Sample.relevel                                = data.relevel

    local PShowAttType = GUIFunction:PShowAttType()

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
    Sample.attdata[PShowAttType.Anti_Posion]    = data.AntiPosion
    Sample.attdata[PShowAttType.Posion_Recover]    = data.PosionRecover
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


    -- body
end
-- 技能数据
function TradingBankLookPlayerProxy:GetSkills_Hero(noBasicSkill, activeOnly)
    -- 已有技能数据 param1:是否排除普攻  param2:是否只获取主动技能
    local skills = {}
    for _, v in pairs(self.m_skills_Hero) do
        local config = self.SkillProxy:FindConfigBySkillID(v.MagicID)
        if (noBasicSkill and v.MagicID == global.MMO.SKILL_INDEX_BASIC) then
        elseif activeOnly and false == self:IsActiveSkill_Hero(v.MagicID) then
        else
            skills[v.MagicID] = v
        end
    end
    return skills
end
-- 主动技能
function TradingBankLookPlayerProxy:IsActiveSkill_Hero(skillID)
    local config = self.SkillProxy:FindConfigBySkillID(skillID)
    if not config then
        return false
    end
    return config.type == 1
end

function TradingBankLookPlayerProxy:GetSkillByID_Hero(skillID)
    -- 获取技能数据
    return self.m_skills_Hero[skillID]
end
function TradingBankLookPlayerProxy:GetSkillTrainData_Hero(skillID)
    -- 技能等级>3的全部特殊处理下
    local maxStr = "-"
    if not skillID or not self.m_skills_Hero[skillID] then
        return maxStr
    end
    if skillID == global.MMO.SKILL_INDEX_BASIC then
        return maxStr
    end
    local skillData    = self.m_skills_Hero[skillID]
    local isBaseSkill = skillData.Level <= 3
    local skillLevel    = skillData.Level
    local maxSkillLevel = skillData.TrainLv
    if isBaseSkill and skillLevel >= maxSkillLevel then
        return maxStr
    end
    local skillMaxTrain = {
        [0] = skillData.MaxTrain1,
        [1] = skillData.MaxTrain2,
        [2] = skillData.MaxTrain3,
        [3] = skillData.MaxTrain4
    }
    local curTrain = skillData.CurTrain or 0
    local maxTrain = (isBaseSkill and skillMaxTrain[skillLevel] or skillData.MaxTrain1) or 0
    local str = curTrain >= maxTrain and maxStr or string.format(GET_STRING(1053), curTrain, maxTrain)
    return str
end
-- 获取技能Icon 矩形
function TradingBankLookPlayerProxy:GetIconRectPathByID_Hero(skillID)
    local config = self.SkillProxy:FindConfigBySkillID(skillID)
    if not config then
        return string.format("%s%s.jpg", global.MMO.PATH_RES_SKILL_ICON, "default")
    end

    local data = self:GetSkillByID_Hero(skillID)
    if not data or not data.LevelUpIcon or data.LevelUpIcon <= 0 then
        return string.format("%s%s.jpg", global.MMO.PATH_RES_SKILL_ICON, config.icon)
    end

    return string.format("%s%s_%s.jpg", global.MMO.PATH_RES_SKILL_ICON, config.icon, data.LevelUpIcon)
end
function TradingBankLookPlayerProxy:parseOneSkillData_Hero(data)
    data.id = data.MagicID
    data.DelayTime = data.DelayTime or 0

    -- extension
    data.isCD = false
    data.curTime = 0
    return data
end

function TradingBankLookPlayerProxy:AddSkill_Hero(data)
    --增加技能
    -- dump(data)
    if not data then
        return false
    end
    if self.m_skills_Hero[data.MagicID] then
        return false
    end
    if not self.SkillProxy:FindConfigBySkillID(data.MagicID) then
        print("add skill error, skill config is nil " .. data.MagicID)
        return false
    end

    -- 增加技能  
    self.m_skills_Hero[data.MagicID] = data
end

-- 技能数据
function TradingBankLookPlayerProxy:GetSkills(noBasicSkill, activeOnly)
    -- 已有技能数据 param1:是否排除普攻  param2:是否只获取主动技能
    local skills = {}
    for _, v in pairs(self.m_skills) do
        local config = self.SkillProxy:FindConfigBySkillID(v.MagicID)
        if (noBasicSkill and v.MagicID == global.MMO.SKILL_INDEX_BASIC) then
        elseif activeOnly and false == self:IsActiveSkill(v.MagicID) then
        else
            skills[v.MagicID] = v
        end
    end
    return skills
end
-- 主动技能
function TradingBankLookPlayerProxy:IsActiveSkill(skillID)
    local config = self.SkillProxy:FindConfigBySkillID(skillID)
    if not config then
        return false
    end
    return config.type == 1
end
function TradingBankLookPlayerProxy:GetSkillByID(skillID)
    -- 获取技能数据
    return self.m_skills[skillID]
end
function TradingBankLookPlayerProxy:GetSkillTrainData(skillID)
    -- 技能等级>3的全部特殊处理下
    local maxStr = "-"
    if not skillID or not self.m_skills[skillID] then
        return maxStr
    end
    if skillID == global.MMO.SKILL_INDEX_BASIC then
        return maxStr
    end
    local skillData    = self.m_skills[skillID]
    local isBaseSkill = skillData.Level <= 3
    local skillLevel    = skillData.Level
    local maxSkillLevel = skillData.TrainLv
    if isBaseSkill and skillLevel >= maxSkillLevel then
        return maxStr
    end
    local skillMaxTrain = {
        [0] = skillData.MaxTrain1,
        [1] = skillData.MaxTrain2,
        [2] = skillData.MaxTrain3,
        [3] = skillData.MaxTrain4
    }
    local curTrain = skillData.CurTrain or 0
    local maxTrain = (isBaseSkill and skillMaxTrain[skillLevel] or skillData.MaxTrain1) or 0
    local str = curTrain >= maxTrain and maxStr or string.format(GET_STRING(1053), curTrain, maxTrain)
    return str
end
-- 获取技能Icon 矩形
function TradingBankLookPlayerProxy:GetIconRectPathByID(skillID)
    local config = self.SkillProxy:FindConfigBySkillID(skillID)
    if not config then
        return string.format("%s%s.jpg", global.MMO.PATH_RES_SKILL_ICON, "default")
    end

    local data = self:GetSkillByID(skillID)
    if not data or not data.LevelUpIcon or data.LevelUpIcon <= 0 then
        return string.format("%s%s.jpg", global.MMO.PATH_RES_SKILL_ICON, config.icon)
    end

    return string.format("%s%s_%s.jpg", global.MMO.PATH_RES_SKILL_ICON, config.icon, data.LevelUpIcon)
end
function TradingBankLookPlayerProxy:parseOneSkillData(data)
    data.id = data.MagicID
    data.DelayTime = data.DelayTime or 0

    -- extension
    data.isCD = false
    data.curTime = 0
    return data
end

function TradingBankLookPlayerProxy:AddSkill(data)
    --增加技能
    -- dump(data)
    if not data then
        return false
    end
    if self.m_skills[data.MagicID] then
        return false
    end
    if not self.SkillProxy:FindConfigBySkillID(data.MagicID) then
        print("add skill error, skill config is nil " .. data.MagicID)
        return false
    end

    -- 增加技能  
    self.m_skills[data.MagicID] = data

end
function TradingBankLookPlayerProxy:DelSkill_Hero(skillID)
    --删除技能
    if not skillID then
        return false
    end
    if not self.m_skills_Hero[skillID] then
        return false
    end

    -- 删除技能
    local data = self.m_skills_Hero[skillID]
    self.m_skills_Hero[skillID] = nil
end

function TradingBankLookPlayerProxy:DelSkill(skillID)
    --删除技能
    if not skillID then
        return false
    end
    if not self.m_skills[skillID] then
        return false
    end

    -- 删除技能
    local data = self.m_skills[skillID]
    self.m_skills[skillID] = nil
end

function TradingBankLookPlayerProxy:SetLookPlayerTitle_Hero(data)
    self._titleData_Hero = {}
    if data and next(data) then
        for i, v in pairs(data) do
            local id = v[1]
            local time = v[2]

            local data = { id = id, time = time, index = i }
            self._titleData_Hero[i] = data
        end
    end
end

function TradingBankLookPlayerProxy:GetLookPlayerTitle_Hero()
    return self._titleData_Hero
end

function TradingBankLookPlayerProxy:GetLookPlayerTitleActive_Hero()
    return self._titleActive_Hero
end

function TradingBankLookPlayerProxy:SetLookPlayerTitle(data)
    self._titleData = {}
    if data and next(data) then
        for i, v in pairs(data) do
            local id = v[1]
            local time = v[2]

            local data = { id = id, time = time, index = i }
            self._titleData[i] = data
        end
    end
end

function TradingBankLookPlayerProxy:GetLookPlayerTitle()
    return self._titleData
end

function TradingBankLookPlayerProxy:GetLookPlayerTitleActive()
    return self._titleActive
end
function TradingBankLookPlayerProxy:SetLookPlayerFashion_Hero(dress, weapon)
    self.fashionData_Hero[self.fashionId.dress + 10000] = dress
    self.fashionData_Hero[self.fashionId.weapon + 10000] = weapon
end

function TradingBankLookPlayerProxy:GetLookPlayerFashionLooks_Hero(fashionId)
    local itemId = self.fashionData_Hero[fashionId]
    local show = {
        look = nil,
        effect = nil
    }
    if not itemId then
        return show
    end
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local itemData = ItemConfigProxy:GetItemDataByIndex(itemId)
    if not itemData then
        return show
    end
    if itemData and itemData.Looks then
        show.look = itemData.Looks
    end
    if itemData and itemData.sEffect then
        show.effect = itemData.sEffect
    end
    return show
end
function TradingBankLookPlayerProxy:SetLookPlayerFashion(dress, weapon)
    self.fashionData[self.fashionId.dress + 10000] = dress
    self.fashionData[self.fashionId.weapon + 10000] = weapon
end

function TradingBankLookPlayerProxy:GetLookPlayerFashionLooks(fashionId)
    local itemId = self.fashionData[fashionId]
    local show = {
        look = nil,
        effect = nil
    }
    if not itemId then
        return show
    end
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local itemData = ItemConfigProxy:GetItemDataByIndex(itemId)
    if not itemData then
        return show
    end
    if itemData and itemData.Looks then
        show.look = itemData.Looks
    end
    if itemData and itemData.sEffect then
        show.effect = itemData.sEffect
    end
    return show
end

function TradingBankLookPlayerProxy:SetLookPlayerItemData_Hero(Items)
    if not Items or not next(Items) then
        return
    end
    for k, v in pairs(Items) do
        local itemData = ChangeItemServersSendDatas(v)
        self.lookPlayerItems_Hero[itemData.Where] = itemData
    end
end
function TradingBankLookPlayerProxy:GetLookPlayerItemDataByPos_Hero(pos, beginOnMoving)
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local data = self.lookPlayerItems_Hero[pos]
    local list = EquipProxy:GetEquipMappingConfig(pos) -- 单显示位置 多个装备位置共享
    if beginOnMoving and list then
        data = nil
        for _, v in ipairs(list) do
            data = self.lookPlayerItems_Hero[v]
            if data then
                break
            end
        end
    end
    return data
end
function TradingBankLookPlayerProxy:GetEquipDataByName_Hero(Name)
    local list = {}
    local data = self:GetLookPlayerItemPosData_Hero()
    if not Name or Name == "" or not data or next(data) == nil then
        return list
    end
    for k, v in pairs(data) do
        if v.Name == Name then
            table.insert(list, v)
        end
    end
    return list
end
function TradingBankLookPlayerProxy:GetLookPlayerItemDataList_Hero(pos)
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local data = {}
    local list = EquipProxy:GetEquipMappingConfig(pos) -- 单显示位置 多个装备位置共享
    if list then
        for _, v in ipairs(list) do
            local equipData = self.lookPlayerItems_Hero[v]
            if equipData then
                table.insert(data, equipData)
            end
        end
    else
        if self.lookPlayerItems_Hero[pos] then
            table.insert(data, self.lookPlayerItems_Hero[pos])
        end
    end
    if next(data) == nil then
        data = nil
    end
    return data
end

function TradingBankLookPlayerProxy:GetLookPlayerItemDataByMakeIndex_Hero(MakeIndex)
    for k, v in pairs(self.lookPlayerItems_Hero) do
        if v.MakeIndex and v.MakeIndex == MakeIndex then
            return v
        end
    end
    return nil
end

function TradingBankLookPlayerProxy:GetLookPlayerItemPosData_Hero()
    return self.lookPlayerItems_Hero
end

function TradingBankLookPlayerProxy:SetLookPlayerData_Hero(data)
    self.lookPlayerData_Hero.Job = data.Job
    self.lookPlayerData_Hero.Name = data.Name
    self.lookPlayerData_Hero.Sex = data.Sex
    self.lookPlayerData_Hero.Hair = data.Hair
    self.lookPlayerData_Hero.Color = data.Color
    self.lookPlayerData_Hero.GuildName = data.GuildName or ""
    self.lookPlayerData_Hero.RankName = data.RankName or ""
    self.lookPlayerData_Hero.SndaItemBoxOpened = data.SndaItemBoxOpened
end






function TradingBankLookPlayerProxy:SetLookPlayerItemData(Items)
    if not Items or not next(Items) then
        return
    end
    for k, v in pairs(Items) do
        local itemData = ChangeItemServersSendDatas(v)
        self.lookPlayerItems[itemData.Where] = itemData
    end
end

function TradingBankLookPlayerProxy:GetLookPlayerItemDataByPos(pos, beginOnMoving)
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local data = self.lookPlayerItems[pos]
    local list = EquipProxy:GetEquipMappingConfig(pos) -- 单显示位置 多个装备位置共享
    if beginOnMoving and list then
        data = nil
        for _, v in ipairs(list) do
            data = self.lookPlayerItems[v]
            if data then
                break
            end
        end
    end
    return data
end

function TradingBankLookPlayerProxy:GetEquipDataByName(Name)
    local list = {}
    local data = self:GetLookPlayerItemPosData()
    if not Name or Name == "" or not data or next(data) == nil then
        return list
    end
    for k, v in pairs(data) do
        if v.Name == Name then
            table.insert(list, v)
        end
    end
    return list
end

function TradingBankLookPlayerProxy:GetLookPlayerItemDataList(pos)
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local data = {}
    local list = EquipProxy:GetEquipMappingConfig(pos) -- 单显示位置 多个装备位置共享
    if list then
        for _, v in ipairs(list) do
            local equipData = self.lookPlayerItems[v]
            if equipData then
                table.insert(data, equipData)
            end
        end
    else
        if self.lookPlayerItems[pos] then
            table.insert(data, self.lookPlayerItems[pos])
        end
    end
    if next(data) == nil then
        data = nil
    end
    return data
end

function TradingBankLookPlayerProxy:GetLookPlayerItemDataByMakeIndex(MakeIndex)
    for k, v in pairs(self.lookPlayerItems) do
        if v.MakeIndex and v.MakeIndex == MakeIndex then
            return v
        end
    end
    return nil
end

function TradingBankLookPlayerProxy:GetLookPlayerItemPosData()
    return self.lookPlayerItems
end

function TradingBankLookPlayerProxy:SetLookPlayerData(data)
    self.lookPlayerData.Job = data.Job
    self.lookPlayerData.Name = data.Name
    self.lookPlayerData.Sex = data.Sex
    self.lookPlayerData.Hair = data.Hair
    self.lookPlayerData.Color = data.Color
    self.lookPlayerData.GuildName = data.GuildName or ""
    self.lookPlayerData.RankName = data.RankName or ""
    self.lookPlayerData.SndaItemBoxOpened = data.SndaItemBoxOpened
end

function TradingBankLookPlayerProxy:GetLookPlayerName()
    return self.lookPlayerData.Name
end

function TradingBankLookPlayerProxy:GetLookPlayerSex()
    return self.lookPlayerData.Sex
end

function TradingBankLookPlayerProxy:GetLookPlayerHair()
    return self.lookPlayerData.Hair
end

function TradingBankLookPlayerProxy:GetLookPlayerNameColor()
    return self.lookPlayerData.Color
end

function TradingBankLookPlayerProxy:GetLookPlayerGuildName()
    return self.lookPlayerData.GuildName or ""
end

function TradingBankLookPlayerProxy:GetLookPlayerGuildRankName()
    return self.lookPlayerData.RankName or ""
end

function TradingBankLookPlayerProxy:GetBestRingsOpenState()
    return self.lookPlayerData.SndaItemBoxOpened
end

function TradingBankLookPlayerProxy:GetLookPlayerUid()
    return self.playerUid
end

function TradingBankLookPlayerProxy:SetEmbattle_Hero(data)
    self.embattle_Hero = {}
    if data and data ~= 0 then
        self.embattle_Hero[1] = H16Bit(data)
        self.embattle_Hero[2] = L16Bit(data)
    end
end
function TradingBankLookPlayerProxy:GetEmbattle_Hero()
    return self.embattle_Hero
end

function TradingBankLookPlayerProxy:GetLookPlayerName_Hero()
    return self.lookPlayerData_Hero.Name
end

function TradingBankLookPlayerProxy:GetLookPlayerSex_Hero()
    return self.lookPlayerData_Hero.Sex
end

function TradingBankLookPlayerProxy:GetLookPlayerHair_Hero()
    return self.lookPlayerData_Hero.Hair
end

function TradingBankLookPlayerProxy:GetLookPlayerNameColor_Hero()
    return self.lookPlayerData_Hero.Color
end

function TradingBankLookPlayerProxy:GetLookPlayerGuildName_Hero()
    return self.lookPlayerData_Hero.GuildName or ""
end

function TradingBankLookPlayerProxy:GetLookPlayerGuildRankName_Hero()
    return self.lookPlayerData_Hero.RankName or ""
end

function TradingBankLookPlayerProxy:GetBestRingsOpenState_Hero()
    return self.lookPlayerData_Hero.SndaItemBoxOpened
end

function TradingBankLookPlayerProxy:GetLookPlayerUid_Hero()
    return self.playerUid
end


--请求通知脚本查看uid的珍宝
function TradingBankLookPlayerProxy:RequestLookZhenBao_Hero(uid)
    if uid then
        LuaSendMsg(global.MsgType.MSG_CS_SCRIPT_ZHENBAO, 0, 0, 0, 0, uid, string.len(uid))
    end
end
--请求通知脚本查看uid的珍宝
function TradingBankLookPlayerProxy:RequestLookZhenBao(uid)
    if uid then
        LuaSendMsg(global.MsgType.MSG_CS_SCRIPT_ZHENBAO, 0, 0, 0, 0, uid, string.len(uid))
    end
end

function TradingBankLookPlayerProxy:RequestPlayerData(Uid, func)
    dump(Uid, "uid____")
    self:initData()
    self._func = func
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Player_Close, { id = global.LayerTable.PlayerLayer })
    self.lookPlayerData = {}
    self.lookPlayerItems = {}
    self.fashionData = {}
    self.playerUid = Uid
    self.isget = false
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    if HeroPropertyProxy:IsHeroOpen() then
        LuaSendMsg(global.MsgType.MSG_CM_GETPLAYERINFO, 1, 0, 0, 0, Uid, string.len(Uid))
    else
        LuaSendMsg(global.MsgType.MSG_CM_GETPLAYERINFO, 0, 0, 0, 0, Uid, string.len(Uid))
    end

end

function TradingBankLookPlayerProxy:RegisterMsgHandler()
    TradingBankLookPlayerProxy.super.RegisterMsgHandler(self)

    local msgType    = global.MsgType

    --预请求查看数据
    LuaRegisterMsgHandler(msgType.MSG_SC_GETPLAYERINFO, handler(self, self.handle_MSG_SC_ROLE_INFO_RESPONSE))
end

return TradingBankLookPlayerProxy