local HeroProperty = class( "HeroProperty" )

function HeroProperty:ctor()
   self._sample   = {}           -- 基本属性
   self.lastlevel = nil          -- 上一次等级
   self.namestr       = ""       -- 名字
   self.guildname     = ""       -- 公会
   self.curPkState    = 0       -- 当前攻击模式
   self.Sex          = nil      -- 性别
   self.variableInfo = ""       -- 玩家状态的脚本变量
   self.HeroLuck     = nil     -- 英雄忠诚度
end
function HeroProperty:GetHeroLuck()
   return self.HeroLuck or 1000
end
function HeroProperty:SetHeroLuck(HeroLuck)
   self.HeroLuck = HeroLuck or 1000
end
function HeroProperty:GetSampleData()
   return self._sample
end

function HeroProperty:GetLevel()
   return self._sample.level or 0
end

function HeroProperty:GetLastLevel()
   return self.lastlevel
end

function HeroProperty:GetRoleCurrHP()
   return self:GetAttByAttType(GUIFunction:PShowAttType().HP)
end

function HeroProperty:GetRoleCurrMP()
   return self:GetAttByAttType(GUIFunction:PShowAttType().MP)
end

function HeroProperty:GetRoleMaxHP()
   return self._sample.maxHP or 1
end

function HeroProperty:GetRoleMaxMP()
  return self._sample.maxMP or 1
end

function HeroProperty:GetCurrExp()
   return self._sample.curExp or 0
end

function HeroProperty:GetNeedExp()
  return self._sample.needExp or 1
end

function HeroProperty:GetForceAgainst()
   return self._sample.nForceAgainst or 0
end

function HeroProperty:GetForceRecovery() 
   return self._sample.nForceRecovery or 0
end

function HeroProperty:GetName()
   return self.namestr or ""
end

function HeroProperty:GetGuildName()
   return self.guildname or ""
end

function HeroProperty:GetPKMode()
   return self.curPkState
end

function HeroProperty:GetRoleSex()
   return self.Sex
end

function HeroProperty:GetVariableInfo()
   return self.variableInfo or ""
end

function HeroProperty:SetVariableInfo(variable_info)
   self.variableInfo = variable_info
end

function HeroProperty:GetAttByAttType(attid)
   local data = self._sample.attdata or {}
   if data[attid] then
      return data[attid]
   end
   return 0
end

function HeroProperty:SetRoleManaData(curHP, maxHP, curMP, maxMP)
   local PShowAttType = GUIFunction:PShowAttType()
   self:SetAttDataByAttId(PShowAttType.HP,curHP)
   self._sample.maxHP = maxHP
   self:SetAttDataByAttId(PShowAttType.MP,curMP)
   self._sample.maxMP = maxMP
end

function HeroProperty:SetRoleCurrExp(curExp)
   self._sample.curExp = curExp
end

function HeroProperty:SetLastLevel( level )
   self.lastlevel = level
end

function HeroProperty:SetPKMode( state )
   self.curPkState = state
end

function HeroProperty:SetRoleSex(sex)
   self.Sex = sex
end

function HeroProperty:SetNeedExp( exp )
   self._sample.needExp = exp
end

function HeroProperty:SetName(name)
   self.namestr = name
end

function HeroProperty:SetGuildName(guildname)
   self.guildname = guildname
end

function HeroProperty:SetWeight(weight, wearWeight, handWeight)
   local PShowAttType = GUIFunction:PShowAttType()
   self:SetAttDataByAttId(PShowAttType.Weight, weight)
   self:SetAttDataByAttId(PShowAttType.Wear_Weight, wearWeight)
   self:SetAttDataByAttId(PShowAttType.Hand_Weight, handWeight)
end

function HeroProperty:SetAttDataByAttId(attid,val)
   if not self._sample.attdata then
      self._sample.attdata = {}
   end
   self._sample.attdata[attid] = val
end

function HeroProperty:SetDZValue(value)
   self:SetAttDataByAttId(GUIFunction:PShowAttType().Internal_DZValue, value)
end

function HeroProperty:GetReinLv()
    return self._sample.relevel or 0
end

function HeroProperty:SetReinLv(relevel)
    self._sample.relevel = relevel
end

function HeroProperty:GetRoleJob()
   return self._sample.job or -1
end

return HeroProperty 