local RemoteProxy = requireProxy("remote/RemoteProxy")
local HeroSkillProxy = class("HeroSkillProxy", RemoteProxy)
HeroSkillProxy.NAME = global.ProxyTable.HeroSkillProxy
local cjson     = require("cjson")


local function parseOneSkillData(data)
    data.id = data.MagicID
    data.DelayTime = data.DelayTime or 0
    
    -- extension
    data.isCD = false
    data.curTime = 0
    return data
end


function HeroSkillProxy:ctor()
    HeroSkillProxy.super.ctor(self)
    
    self._data = {}
    self._configs = {}
    self._heroSkillID = nil
    self:Init()
end

function HeroSkillProxy:Init()
    self._data.skills           = {}          -- 所有拥有技能
    self._data.ngSkills         = {}          -- 所有拥有内功技能
    self._data.setComboSkill    = {}          -- 设置加入连击的连击技能
    self._data.comboSkills      = {}          -- 所有拥有的连击技能
    self._data.openComboNum     = 3           -- 默认开启连击设置格子数
end

function HeroSkillProxy:LoadConfig()
    self._configs = requireGameConfig("cfg_magicinfo")
end

-- 技能配置
function HeroSkillProxy:GetConfigs()
    return self._configs
end

function HeroSkillProxy:FindConfigBySkillID(skillID)
    return self._configs[skillID]
end

function HeroSkillProxy:FindAllSkillsByJob(job)
    if not job then
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        job = PlayerProperty:GetRoleJob()
    end

    local configs = self:GetConfigs()
    local items   = {}
    for _, v in pairs(configs) do
        if v.job == job or v.job == 3 then
            table.insert(items, v)
        end
    end
    return items
end

-- 获取技能名字
function HeroSkillProxy:GetSkillNameByID(skillID)
    local config = self:FindConfigBySkillID(skillID)
    if not config then
        return "ERROR SKILL NAME"
    end
    return config.HeroMagicName
end

-- 获取技能Icon 圆形
function HeroSkillProxy:GetIconPathByID(skillID, isCombo)
    if skillID == 0 then
        local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        if PlayerInputProxy:CheckMiningAble() then
            skillID = 999
        end
    end

    local config = self:FindConfigBySkillID(skillID)
    if not config then
        local path = string.format("%s%s.jpg", global.MMO.PATH_RES_SKILL_ICON_C, "default")
        if global.FileUtilCtl:isFileExist(path) then
            return path
        end
        return string.format("%s%s.png", global.MMO.PATH_RES_SKILL_ICON_C, "default")
    end

    local data = isCombo and self:GetComboSkillByID(skillID) or self:GetSkillByID(skillID)
    if not data or not data.LevelUpIcon or data.LevelUpIcon <= 0 then
        local path = string.format("%s%s.jpg", global.MMO.PATH_RES_SKILL_ICON_C, config.icon)
        if global.FileUtilCtl:isFileExist(path) then
            return path
        end
        return string.format("%s%s.png", global.MMO.PATH_RES_SKILL_ICON_C, config.icon)
    end

    local path = string.format("%s%s_%s.jpg", global.MMO.PATH_RES_SKILL_ICON_C, config.icon, data.LevelUpIcon)
    if global.FileUtilCtl:isFileExist(path) then
        return path
    end

    return string.format("%s%s_%s.png", global.MMO.PATH_RES_SKILL_ICON_C, config.icon, data.LevelUpIcon)
end

-- 获取技能Icon 矩形
function HeroSkillProxy:GetIconRectPathByID(skillID, isCombo)
    local config = self:FindConfigBySkillID(skillID)
    if not config then
        local path = string.format("%s%s.png", global.MMO.PATH_RES_SKILL_ICON, "default")
        if global.FileUtilCtl:isFileExist(path) then
            return path
        end
        return string.format("%s%s.jpg", global.MMO.PATH_RES_SKILL_ICON, "default")
    end

    local data = isCombo and self:GetComboSkillByID(skillID) or self:GetSkillByID(skillID)
    if not data or not data.LevelUpIcon or data.LevelUpIcon <= 0 then
        local path = string.format("%s%s.png", global.MMO.PATH_RES_SKILL_ICON, config.icon)
        if global.FileUtilCtl:isFileExist(path) then
            return path
        end
        return string.format("%s%s.jpg", global.MMO.PATH_RES_SKILL_ICON, config.icon)
    end

    local path = string.format("%s%s_%s.png", global.MMO.PATH_RES_SKILL_ICON, config.icon, data.LevelUpIcon)
    if global.FileUtilCtl:isFileExist(path) then
        return path
    end

    return string.format("%s%s_%s.jpg", global.MMO.PATH_RES_SKILL_ICON, config.icon, data.LevelUpIcon)
end

-- 技能数据
function HeroSkillProxy:GetSkills(noBasicSkill, activeOnly)
    -- 已有技能数据 param1:是否排除普攻  param2:是否只获取主动技能
    local skills = {}
    for _, v in pairs(self._data.skills) do
        local config = self:FindConfigBySkillID(v.MagicID)
        if (noBasicSkill and v.MagicID == global.MMO.SKILL_INDEX_BASIC) then
        elseif activeOnly and false == self:IsActiveSkill(v.MagicID) then
        else
            skills[v.MagicID] = v
        end
    end
    return skills
end
function HeroSkillProxy:IsActiveSkill(skillID)
    local config = self:FindConfigBySkillID(skillID)
    if not config then
        return false
    end
    return config.type == 1
end
function HeroSkillProxy:GetSkillByID(skillID)
    -- 获取技能数据
    return self._data.skills[skillID]
end

function HeroSkillProxy:DelAllSkill()
    self._data.skills = {}
    self._heroSkillID = nil
    self._data.ngSkills         = {}          
    self._data.setComboSkill    = {}
    self._data.comboSkills      = {}
end

function HeroSkillProxy:GetLevel(skillID)
    -- 技能等级
    local data = self:GetSkillByID(skillID)
    if data then
        return data.Level
    end
    return -1
end

function HeroSkillProxy:AddSkill(data, bIsInit)
    --增加技能
    -- dump(data)
    if not data then
        return false
    end
    if self._data.skills[data.MagicID] then
        return false
    end
    if not self:FindConfigBySkillID(data.MagicID) then
        print("add skill error, skill config is nil " .. data.MagicID)
        return false
    end

    if self:isHeroSkill(data.MagicID) then
        self._heroSkillID = data.MagicID
    end

    -- 增加技能  
    self._data.skills[data.MagicID] = data

    -- 广播新增技能
    global.Facade:sendNotification(global.NoticeTable.SkillAdd_Hero, data)
    SLBridge:onLUAEvent(LUA_EVENT_HERO_SKILL_ADD, data)

    -- 判断一遍合击技能是否是可以是否状态
    SLBridge:onLUAEvent(LUA_EVENT_HERO_ANGER_CAHNGE, {forceRefresh=true})
end

function HeroSkillProxy:DelSkill(skillID, bIsInit)
    --删除技能
    if not skillID then
        return false
    end
    if not self._data.skills[skillID] then
        return false
    end

    -- 删除技能
    local data = self._data.skills[skillID]
    self._data.skills[skillID] = nil
    if self:isHeroSkill(skillID) then
        self._heroSkillID = nil
    end
    -- 广播
    global.Facade:sendNotification(global.NoticeTable.SkillDel_Hero, data)
    SLBridge:onLUAEvent(LUA_EVENT_HERO_SKILL_DEL, data)
end

function HeroSkillProxy:UpdateSkillData(data)
    -- 更新技能数据
    if not data then
        return
    end
    if not data.skillID then
        return nil
    end
    local skill = self:GetSkillByID(data.skillID)
    if not skill then
        return nil
    end

    -- 更新技能属性
    for k, v in pairs(data) do
        skill[k] = v
    end
    global.Facade:sendNotification(global.NoticeTable.SkillUpdate_Hero, skill)
end

function HeroSkillProxy:GetSkillTrainData(skillID)
    -- 技能等级>3的全部特殊处理下
    local maxStr = "-"
    if not skillID or not self._data.skills[skillID] then
        return maxStr
    end
    if skillID == global.MMO.SKILL_INDEX_BASIC then
        return maxStr
    end
    local skillData     = self._data.skills[skillID]
    local isBaseSkill   = skillData.Level <= 3
    local skillLevel    = skillData.Level
    local maxSkillLevel = skillData.TrainLv
    if skillLevel >= maxSkillLevel then
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
-- 

--是否使用技能书 通过书名
function HeroSkillProxy:CheckAbleToUseBookByName(bookname)
    local allSkills = self:FindAllSkillsByJob()
    local tskillID  = nil
    for _, v in pairs(allSkills) do
        if v.magName == bookname or v.HeroMagicName == bookname then
            tskillID = v.MagicID
            break
        end
    end
    if not tskillID then
        return false
    end

    -- 已学习
    if self:IsLearned(tskillID) then
        return false
    end

    return true
end

-- 是否已经学习
function HeroSkillProxy:IsLearned(skillID)
    local skillData = self:GetSkillByID(skillID)
    return skillData and true or false
end

-- MP 是否满足
function HeroSkillProxy:IsEnoughMana(skillID)
    local skill = self:GetSkillByID(skillID)
    if not skill then
        return false
    end
    if not skill.Spell or not skill.DefSpell then
        -- 没有告诉我是否耗蓝
        return true
    end

    local propertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local currMP = propertyProxy:GetRoleCurrMP()
    return currMP and currMP >= (skill.Spell + skill.DefSpell)
end

-- skill key
function HeroSkillProxy:GetSkillKey(skillID)
    if not skillID then
        return nil
    end
    local skill = self:GetSkillByID(skillID)
    if not skill then
        return nil
    end
    return skill.Key
end

function HeroSkillProxy:SetSkillKey(skillID, key)
    if not skillID then
        return nil
    end
    local skill = self:GetSkillByID(skillID)
    if not skill then
        return nil
    end
    skill.Key  = key
    self:sendMCMessage(skillID, key, 0)
end

-- skill 开关
function HeroSkillProxy:GetNGSkillOnOff(skillID, skillType)
    if not skillID then
        return nil
    end
    local skill = self:GetNGSkillData(skillID, skillType)
    if not skill then
        return nil
    end
    return skill.Key
end

function HeroSkillProxy:SetNGSkillOnOff(skillID, skillType, key)
    if not skillID then
        return nil
    end
    local skill = self:GetNGSkillData(skillID, skillType)
    if not skill then
        return nil
    end
    skill.Key  = key
    self:sendMCMessage(skillID, key, 1, skillType)
end

--key 0 开启 1关闭
--type 0英雄 1内功 2连击
--skillType 0=人物技能, 1=英雄技能 2=人物怒内功技能  3=英雄怒内功技能  4=人物静内功技能  5=英雄静内功技能   6=人物连击技能 7=英雄连击技能
function HeroSkillProxy:sendMCMessage(skillID, key, type, ngType)
    local skillType = 0
    if type == 0 then
        skillType = 1
    elseif type == 1 and ngType then
        skillType = ngType
    end
    LuaSendMsg(global.MsgType.MSG_CS_PLAYER_ONOFF_SKILL_HERO, skillID, key, skillType, 0)
end

function HeroSkillProxy:RespPlayerSkillDataHero(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if jsonData then
        for _, v in ipairs(jsonData) do
            local skill = parseOneSkillData(v)
            if skill.SkillType == 7 then    --  英雄连击技能
                self._data.comboSkills[skill.MagicID] = skill
                SLBridge:onLUAEvent(LUA_EVENT_HERO_COMBO_SKILL_ADD, skill)
            else
                self:AddSkill(skill, true)
            end
        end
    end
end

function HeroSkillProxy:RespPlayerAddSkillHero(msg)
    local jsonData = ParseRawMsgToJson(msg)
    local skill = parseOneSkillData(jsonData)
    if skill.SkillType == 7 then    -- 英雄连击技能
        self._data.comboSkills[skill.MagicID] = skill
        SLBridge:onLUAEvent(LUA_EVENT_HERO_COMBO_SKILL_ADD, skill)
    else
        self:AddSkill(skill, false)
    end
end

--删除技能
function HeroSkillProxy:RespPlayerDelSkillHero(msg)
    local header  = msg:GetHeader()
    local skillID = header.recog
    local skillType = header.param1
    if skillType == 7 then  -- 英雄连击技能
        local data = self._data.comboSkills[skillID]
        if data then
            self._data.comboSkills[skillID] = nil
            SLBridge:onLUAEvent(LUA_EVENT_HERO_COMBO_SKILL_DEL, data)
        end
    else
        self:DelSkill(skillID)
    end
end

function HeroSkillProxy:RespPlayerUpdateSkillHero(msg)
    local jsonData  = ParseRawMsgToJson(msg)
    -- dump(jsonData)
    if not jsonData then
        return
    end
    -- dump(msg,"RespPlayerUpdateSkillHero___")
    -- dump(header)
    local data      = {
        skillID     = jsonData.MagicId,
        Level       = jsonData.Level,
        CurTrain    = jsonData.TranPoint,
        LevelUp     = jsonData.LevelUp,
        LevelUpIcon = jsonData.LevelUpIcon,
    }
    if jsonData.SkillType == 7 then     -- 英雄连击
        data.LJBJRate = jsonData.LJBJRate
        self:UpdateComboSkillData(data)
    elseif jsonData.SkillType == 3 or jsonData.SkillType == 5 then  -- 英雄内功
        self:UpdateNGSkillData(data, jsonData.SkillType)
    else
        self:UpdateSkillData(data)
    end
end

--是否拥有英雄技能 返回技能id
function HeroSkillProxy:haveHeroSkill()
    return self._heroSkillID
end

--是否是英雄技能 返回技能id  60-65
function HeroSkillProxy:isHeroSkill(skillID)
    local skillbegin = 60
    local res = false
    for i = 0,5 do
        if skillbegin + i == skillID then
            res = skillID
            break
        end
    end
    return res
end

--------------------------- 内功技能 ----------------------------------
function HeroSkillProxy:GetNGSkills()
    return self._data.ngSkills
end

function HeroSkillProxy:GetNGSkillsList()
    local list = {}
    for _, data in pairs(self._data.ngSkills) do
        for i, skill in pairs(data) do
            table.insert(list, skill)
        end
    end
    table.sort(list, function(a, b)
        if a.MagicID ~= b.MagicID then
            return a.MagicID < b.MagicID
        end
        return a.SkillType < b.SkillType
    end)
    return list
end

function HeroSkillProxy:GetNGSkillData(skillID, skillType)
    return self._data.ngSkills[skillType] and self._data.ngSkills[skillType][skillID]
end

--skillType 3=英雄怒内功技能 5=英雄静内功技能
function HeroSkillProxy:GetNGSkillName(skillID, skillType)
    local config = self:FindConfigBySkillID(skillID)
    if not config then
        return "ERROR SKILL NAME"
    end
    if skillType == 3 then
        return config.nMagicName
    elseif skillType == 5 then
        return config.jMagicName
    end
end

function HeroSkillProxy:GetNGSkillDesc(skillID, skillType)
    local config = self:FindConfigBySkillID(skillID)
    if not config then
        return "ERROR SKILL DESC"
    end
    if skillType == 3 then
        return config.nDesc
    elseif skillType == 5 then
        return config.jDesc
    end
end

-- 获取内功技能Icon 矩形
function HeroSkillProxy:GetNGIconRectPath(skillID, skillType)
    local config = self:FindConfigBySkillID(skillID)
    if not config then
        local path = string.format("%s%s.png", global.MMO.PATH_RES_SKILL_ICON, "default")
        if global.FileUtilCtl:isFileExist(path) then
            return path
        end
        return string.format("%s%s.jpg", global.MMO.PATH_RES_SKILL_ICON, "default")
    end

    local data = self:GetNGSkillData(skillID, skillType)
    local icon = nil 
    if skillType == 3 then  -- 怒
        icon = config.nIcon
    elseif skillType == 5 then  -- 静
        icon = config.jIcon
    end
    icon = icon or config.icon
    if not data or not data.LevelUpIcon or data.LevelUpIcon <= 0 then
        
        local path = string.format("%s%s.png", global.MMO.PATH_RES_SKILL_ICON, icon)
        if global.FileUtilCtl:isFileExist(path) then
            return path
        end
        return string.format("%s%s.jpg", global.MMO.PATH_RES_SKILL_ICON, icon)
    end

    local path = string.format("%s%s_%s.png", global.MMO.PATH_RES_SKILL_ICON, icon, data.LevelUpIcon)
    if global.FileUtilCtl:isFileExist(path) then
        return path
    end

    return string.format("%s%s_%s.jpg", global.MMO.PATH_RES_SKILL_ICON, icon, data.LevelUpIcon)
end

function HeroSkillProxy:GetNGSkillTrainData(skillID, skillType)
    -- 技能等级>3的全部特殊处理下
    local maxStr = "-"
    if not skillID or not self._data.ngSkills[skillType] or not self._data.ngSkills[skillType][skillID] then
        return maxStr
    end
    if skillID == global.MMO.SKILL_INDEX_BASIC then
        return maxStr
    end
    local skillData     = self._data.ngSkills[skillType][skillID]
    local isBaseSkill   = skillData.Level <= 3
    local skillLevel    = skillData.Level
    local maxSkillLevel = skillData.TrainLv
    if skillLevel >= maxSkillLevel then
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
    return curTrain >= maxTrain and maxStr or string.format(GET_STRING(1053), curTrain, maxTrain)
end

function HeroSkillProxy:UpdateNGSkillData(data, skillType)
    -- 更新技能数据
    if not data then
        return
    end
    if not data.skillID then
        return nil
    end
    local skill = self:GetNGSkillData(data.skillID, skillType)
    if not skill then
        return nil
    end

    -- 更新技能属性
    for k, v in pairs(data) do
        skill[k] = v
    end
    SLBridge:onLUAEvent(LUA_EVENT_HERO_INTERNAL_SKILL_UPDATE, skill)
end

function HeroSkillProxy:RespHeroNGSkillData(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if jsonData then
        for _, v in ipairs(jsonData) do
            local skill = parseOneSkillData(v)
            if not self._data.ngSkills[skill.SkillType] then
                self._data.ngSkills[skill.SkillType] = {}
            end
            self._data.ngSkills[skill.SkillType][skill.MagicID] = skill
        end
    end

end

function HeroSkillProxy:RespHeroAddNGSkill(msg)
    local jsonData = ParseRawMsgToJson(msg)
    local skill = parseOneSkillData(jsonData)
    if not self._data.ngSkills[skill.SkillType] then
        self._data.ngSkills[skill.SkillType] = {}
    end
    self._data.ngSkills[skill.SkillType][skill.MagicID] = skill
    SLBridge:onLUAEvent(LUA_EVENT_HERO_INTERNAL_SKILL_ADD, skill)
end

--删除技能
function HeroSkillProxy:RespHeroDelNGSkill(msg)
    local header  = msg:GetHeader()
    local skillID = header.recog
    local skillType = header.param1
    local data = self._data.ngSkills[skillType] and self._data.ngSkills[skillType][skillID]
    if data then
        self._data.ngSkills[skillType][skillID] = nil
        SLBridge:onLUAEvent(LUA_EVENT_HERO_INTERNAL_SKILL_DEL, data)
    end
end

--------------------------- 连击技能 ----------------------------------
function HeroSkillProxy:haveSetComboSkill()
    return self._data.setComboSkill
end

function HeroSkillProxy:SetComboSkill(idx, skillID)
    self._data.setComboSkill[idx] = skillID
end

function HeroSkillProxy:GetComboSkills()
    return self._data.comboSkills
end

function HeroSkillProxy:GetComboSkillByID(skillID)
    -- 获取技能数据
    return self._data.comboSkills[skillID]
end

function HeroSkillProxy:GetComboSkillTrainData(skillID)
    -- 技能等级>3的全部特殊处理下
    local maxStr = "-"
    if not skillID or not self._data.comboSkills[skillID] then
        return maxStr
    end
    local skillData     = self._data.comboSkills[skillID]
    local isBaseSkill   = skillData.Level <= 3
    local skillLevel    = skillData.Level
    local maxSkillLevel = skillData.TrainLv
    if skillLevel >= maxSkillLevel then
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
    return curTrain >= maxTrain and maxStr or string.format(GET_STRING(1053), curTrain, maxTrain)
end

function HeroSkillProxy:SetComboOpenNum(openNum)
    self._data.openComboNum = openNum
end

function HeroSkillProxy:GetComboOpenNum()
    return self._data.openComboNum
end

function HeroSkillProxy:UpdateComboSkillData(data)
    -- 更新技能数据
    if not data then
        return
    end
    if not data.skillID then
        return nil
    end
    local skill = self:GetComboSkillByID(data.skillID)
    if not skill then
        return nil
    end

    -- 更新技能属性
    for k, v in pairs(data) do
        skill[k] = v
    end
    SLBridge:onLUAEvent(LUA_EVENT_HERO_COMBO_SKILL_UPDATE, skill)
end

--------------------------------------------------------------------------

function HeroSkillProxy:RegisterMsgHandler()
    HeroSkillProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType
    
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_SKILL_DATA_HERO, handler(self, self.RespPlayerSkillDataHero))        -- 已学技能 信息
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_ADD_SKILL_HERO,  handler(self, self.RespPlayerAddSkillHero))         -- 新增技能
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_DEL_SKILL_HERO,  handler(self, self.RespPlayerDelSkillHero))         -- 删除技能
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_UP_SKILL_HERO,   handler(self, self.RespPlayerUpdateSkillHero))      -- 技能数据更新

    LuaRegisterMsgHandler(msgType.MSG_SC_HERO_NG_SKILL_DATA, handler(self, self.RespHeroNGSkillData))       -- 内功技能
    LuaRegisterMsgHandler(msgType.MSG_SC_HERO_ADD_NG_SKILL, handler(self, self.RespHeroAddNGSkill))
    LuaRegisterMsgHandler(msgType.MSG_SC_HERO_DEL_NG_SKILL, handler(self, self.RespHeroDelNGSkill))
end

return HeroSkillProxy
