
-- 服务器道具属性变更，在这里变更服务器属性为前端需要的属性
function ChangeItemServersSendDatas(item)
    
    if not item or not next(item) then
        print("=======================================")
        print("item data error")
        print("=======================================")
    end
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local itemconfigO = ItemConfigProxy:GetItemDataByIndex(item.Index)
    if not itemconfigO or next(itemconfigO) == nil then
        print("=======================================")
        print("no this item: my index is " .. item.Index)
        print("=======================================")
    end

    local itemconfig = {}
    setmetatable(itemconfig,{
        __index = function( t,key )
            local Index = t.Index
            if not Index then
                return
            end
            local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
            local config = ItemConfigProxy:GetItemDataByIndex(Index) or {}
            rawset( t, key, config[key])
            return config[key]
        end
    })

    local itemCount = item.overlap and item.overlap or 1
    itemconfig.Index = item.Index
    itemconfig.MakeIndex = item.makeindex or 0
    itemconfig.Dura = item.dura or 0
    itemconfig.DuraMax = item.duramax or 0
    itemconfig.Values = item.values or {}
    itemconfig.Where = item.where
    itemconfig.OverLap = itemCount > 0 and itemCount or 1
    itemconfig.Price = item.price
    itemconfig.Type = item.Type
    itemconfig.BindInfo = item.BindInfo or nil
    itemconfig.Star = nil
    itemconfig.Bind = nil

    itemconfig.ExtendInfo = {}
    local cjson = require("cjson")
    if item.ExtendInfo and string.len(item.ExtendInfo) > 0 then
        itemconfig.ExtendInfo = cjson.decode(item.ExtendInfo)
    end
    itemconfig.AddValues = item.AddValues or {}

    if next(itemconfig.AddValues) then
        for k, v in pairs(itemconfig.AddValues) do
            if v.Id == 0 then
                itemconfig.getServerTime = GetServerTime() --记录获取时的时间戳
                v.Value = v.Value + GetServerTime()
            elseif v.Id == 1 then
                itemconfig.Bind = v.Value
            elseif v.Id == 2 and v.Value and v.Value > 0 then
                itemconfig.Color = v.Value
            elseif v.Id == 3 then
                itemconfig.Star = v.Value
            end
        end
    end

    if item.ExAbil and string.len(item.ExAbil) > 0 then
        local exAbilJsonData = cjson.decode(item.ExAbil)
        itemconfig.ExAbil = exAbilJsonData
        if exAbilJsonData.name and string.len(exAbilJsonData.name) > 0 then
            if not itemconfig.originName then
                itemconfig.originName = itemconfig.Name
            end
            itemconfig.Name = exAbilJsonData.name
        end
    end

    local newLooks, newEffect, newSEffect = ItemConfigProxy:GetChangeItemLook(itemconfig.MakeIndex)
    local newEffectZ = nil
    local newSEffectZ = nil
    if next(itemconfig.Values) then
        --Value[48] 低位是Looks 高位是Effect
        --Value[47] 低位是内观Effect
        for k, v in pairs(itemconfig.Values) do
            if (v.Id == 48 or v.Id == 47) and v.Value then
                local looks = L16Bit(v.Value)
                local effect = H16Bit(v.Value)
                if v.Id == 47 then
                    newSEffect = looks > 0 and looks or newSEffect
                elseif v.Id == 48 then
                    newLooks = looks > 0 and looks or newLooks
                    newEffect = effect > 0 and effect or newEffect
                end
            elseif v.Id == 45 then --物品投保次数
                itemconfig.touBaoTimes = v.Value
            elseif v.Id == 33 then --特定的装备是否显示属性
                itemconfig.TipsShowAttr = v.Value
            elseif v.Id == 39 then --特效层级
                newEffectZ = L16Bit(v.Value)
                newSEffectZ = H16Bit(v.Value)
            end
        end
    end

    if newLooks and newLooks > 0 then
        itemconfig.Looks = newLooks
    end

    local bEffect = nil
    local sEffect = nil
    if newEffect and newEffect > 0 then
        bEffect = newEffect
    end

    if newSEffect and newSEffect > 0 then
        sEffect = newSEffect
    end

    if bEffect then
        local iBEffect = global.ConstantConfig.showOrinalEffec == 1 and (itemconfig.bEffect or "") .. "|" or "0"
        itemconfig.bEffect = string.format("%s%s", iBEffect, bEffect)
    end

    if sEffect then
        local iSEffect = global.ConstantConfig.showOrinalEffec == 1 and (itemconfig.sEffect or "") .. "|" or "0"
        itemconfig.sEffect = string.format("%s%s", iSEffect, sEffect)
    end

    if newEffectZ and newEffectZ >= 0 then
        itemconfig.bEffect = (itemconfig.bEffect or "0") .. "#" .. newEffectZ
    end

    if newSEffectZ and newSEffectZ >= 0 then
        itemconfig.sEffect = (itemconfig.sEffect or "0") .. "#" .. newSEffectZ
    end

    return itemconfig
--[[   if not item or not next(item) then
      print("=======================================")
      print("item data error")
      print("=======================================")
      return {}
   end
   local itemCount = item.overlap and item.overlap or 1
   item.MakeIndex = item.makeindex or 0
   item.Dura = item.dura or 0
   item.DuraMax = item.duramax or 0
   item.Values = item.values or {}
   item.Where = item.where
   item.OverLap = itemCount > 0 and itemCount or 1
   item.Source = item.source and item.source or 0
   item.Luck = item.luck and item.luck or 0
   item.Need = item.need and item.need or 0
   item.NeedLevel = item.needlevel and item.needlevel or 0
   item.StdMode = item.stdmode or 0
   item.Shape = item.shape or 0
   item.Looks = item.looks or 0
   item.nBindIdx = item.bind or 0
   item.Name = item.name or 0
   item.Weight = item.weight or 0
   item.Price = item.price or 0
   item.Reserved = item.reserved or 0
   item.sEffect = item.effectparam or ""

   item.makeindex = nil
   item.dura = nil
   item.duramax = nil
   item.values = nil
   item.where = nil
   item.overlap = nil
   item.price = nil
   item.source = nil
   item.luck = nil
   item.need = nil
   item.needlevel = nil
   item.stdmode = nil
   item.shape = nil
   item.looks = nil
   item.bind = nil
   item.name = nil
   item.weight = nil
   item.reserved = nil
   item.effectparam = nil

   return item
   ]]
end

function GetItemPowerValue(item, param)
    if not item or not next(item) then
        return 0
    end

    param = param or {}
    -- 基础属性
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local attributeCfg = ItemConfigProxy:GetItemDataByIndex(item.Index)
    local attList = {}
    local attrArray = string.split(attributeCfg.attribute or "", "|")
    for i, v in ipairs(attrArray) do
        if v and v ~= "" and string.len(v) > 0 then
            local vArray = string.split(v or "", "#")
            table.insert(attList, {
                id = tonumber(vArray[2]) or 3,
                value = tonumber(vArray[3]) or 0
            })
        end
    end

    local powerValue, powerSortIndex = CalculateAttPowerValue(attList, param.jobPower, param.powerSortIndex)
    local comparison1, job1 = ItemConfigProxy:GetItemComparison(item.Index)
    local contrast = param.contrastV or 0 -- 选中装备 战力属性值
    local comparison = param.comparisonV or comparison1 -- 选中装备 优先级
    if comparison1 > comparison or (param.powerSortIndex and powerSortIndex > param.powerSortIndex) then --优先级
        powerValue = math.abs(powerValue) + contrast + 1 -- 比选中装备战力高 
    elseif comparison1 < comparison then
        powerValue = math.min(math.abs(powerValue), contrast - 1) -- 比选中装备战力低 
    end

    return powerValue, powerSortIndex
end

function GetItemPowerValue_Hero(item, param)
    if not item or next(item) == nil then
        return 0
    end

    param = param or {}
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    local myJob = HeroPropertyProxy:GetRoleJob() or 3
    
    -- 基础属性
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local attributeCfg = ItemConfigProxy:GetItemDataByIndex(item.Index)
    local attList = {}
    local attrArray = string.split(attributeCfg.attribute or "", "|")
    for i, v in ipairs(attrArray) do
        if v and v ~= "" and string.len(v) > 0 then
            local vArray = string.split(v or "", "#")
            table.insert(attList, {
                id = tonumber(vArray[2]) or 3,
                value = tonumber(vArray[3]) or 0
            })
        end
    end

    local powerValue, powerSortIndex = CalculateAttPowerValue_Hero(attList, param.jobPower, param.powerSortIndex)
    local comparison1, job1 = ItemConfigProxy:GetItemComparison(item.Index)
    local contrast = param.contrastV or 0 --比对装备的属性值
    local comparison = param.comparisonV or comparison1 --比对装备的优先级
    if comparison1 > comparison or (param.powerSortIndex and powerSortIndex > param.powerSortIndex) then --优先级
        powerValue = math.abs(powerValue) + contrast + 1 --自身战力 + 对比装备的战力（ > 对比装备的战力 ） 1(避免等于0的情况)
    elseif comparison1 < comparison then
        powerValue = math.min(math.abs(powerValue), contrast - 1) --对比装备的战力 +  > 自身战力（ < 对比装备的战力 ）1(避免等于0的情况)
    end

    return powerValue, powerSortIndex
end

-- attList: 属性   isJobPower： 是否是只要对比     sortIndex：对比的属性下标(按照职业 按照属性 先比较匹配的属性  再比较物防  最后比较魔防  都是上限属性)
function CalculateAttPowerValue(attList, isJobPower, sortIndex)
    local PShowAttType = GUIFunction:PShowAttType()

    local power = -1
    local AttrConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.AttrConfigProxy)
    local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local myJob = PlayerPropertyProxy:GetRoleJob() or 0
    local jobPowerAttIds = {
        [PShowAttType.Max_DEF] = 2,
        [PShowAttType.Max_MDF] = 1
    }
    --[[      按照职业 按照属性 先比较匹配的属性  再比较物防  最后比较魔防  都是上限属性
      战士=攻击
      法师=魔法
      道士=道术
   ]]
    if isJobPower then
        if myJob == 0 then --战士
            jobPowerAttIds[PShowAttType.Max_ATK] = 3
        elseif myJob == 1 then --法师
            jobPowerAttIds[PShowAttType.Max_MAT] = 3
        elseif myJob == 2 then --道士
            jobPowerAttIds[PShowAttType.Max_Daoshu] = 3
        end
    end

    local powers = {}
    local powerSortIndex = 0

    for k, v in pairs(attList) do
        if jobPowerAttIds[v.id] then
            local score = v.value
            powers[jobPowerAttIds[v.id]] = score
            if jobPowerAttIds[v.id] > powerSortIndex and score > 0 then        
                powerSortIndex = jobPowerAttIds[v.id]
            end
        end
    end

    if sortIndex and powerSortIndex <= sortIndex then
        powerSortIndex = sortIndex
    end
    power = powers[powerSortIndex] or -1
    return power, powerSortIndex
end

-- attList: 属性   isJobPower： 是否是只要对比     sortIndex：对比的属性下标(按照职业 按照属性 先比较匹配的属性  再比较物防  最后比较魔防  都是上限属性)
function CalculateAttPowerValue_Hero(attList, isJobPower, sortIndex)
    local PShowAttType = GUIFunction:PShowAttType()
    local power = -1
    local AttrConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.AttrConfigProxy)
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    local myJob = HeroPropertyProxy:GetRoleJob() or 0
    local jobPowerAttIds = {
        [PShowAttType.Max_DEF] = 2,
        [PShowAttType.Max_MDF] = 1
    }
    --[[      按照职业 按照属性 先比较匹配的属性  再比较物防  最后比较魔防  都是上限属性
      战士=攻击
      法师=魔法
      道士=道术
   ]]
    if isJobPower then
        if myJob == 0 then --战士
            jobPowerAttIds[PShowAttType.Max_ATK] = 3
        elseif myJob == 1 then --法师
            jobPowerAttIds[PShowAttType.Max_MAT] = 3
        elseif myJob == 2 then --道士
            jobPowerAttIds[PShowAttType.Max_Daoshu] = 3
        end
    end

    local powers = {}
    local powerSortIndex = 0

    for k, v in pairs(attList) do
        if jobPowerAttIds[v.id] then
            local score = v.value
            powers[jobPowerAttIds[v.id]] = score
            if jobPowerAttIds[v.id] > powerSortIndex and score > 0 then        
                powerSortIndex = jobPowerAttIds[v.id]
            end
        end
    end

    if sortIndex and powerSortIndex <= sortIndex then
        powerSortIndex = sortIndex
    end
    power = powers[powerSortIndex] or -1
    return power, powerSortIndex
end

local GET_CEHCK_VALUE = {
    --等级
    [0] = function( isHero )
        local proxyTable    = isHero and global.ProxyTable.HeroPropertyProxy or global.ProxyTable.PlayerProperty
        local proxy         = global.Facade:retrieveProxy(proxyTable)
        return proxy:GetRoleLevel()
    end,
    --属性：攻击
    [1] = function( isHero )
        local proxyTable    = isHero and global.ProxyTable.HeroPropertyProxy or global.ProxyTable.PlayerProperty
        local proxy         = global.Facade:retrieveProxy(proxyTable)
        return proxy:GetRoleAttByAttType( GUIFunction:PShowAttType().Max_ATK )
    end,
    --属性： 魔法
    [2] = function( isHero )
        local proxyTable    = isHero and global.ProxyTable.HeroPropertyProxy or global.ProxyTable.PlayerProperty
        local proxy         = global.Facade:retrieveProxy(proxyTable)
        return proxy:GetRoleAttByAttType( GUIFunction:PShowAttType().Max_MAT )
    end,
    --属性： 道术
    [3] = function( isHero )
        local proxyTable    = isHero and global.ProxyTable.HeroPropertyProxy or global.ProxyTable.PlayerProperty
        local proxy         = global.Facade:retrieveProxy(proxyTable)
        return proxy:GetRoleAttByAttType( GUIFunction:PShowAttType().Max_Daoshu ) 
    end,
    -- 转生等级
    [4] = function(isHero)
        local proxyTable    = isHero and global.ProxyTable.HeroPropertyProxy or global.ProxyTable.PlayerProperty
        local proxy         = global.Facade:retrieveProxy(proxyTable)
        return proxy:GetRoleReinLv()
    end,
    -- 声望值
    [5] = function( isHero )
        local proxy         = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
        return proxy:GetItemCount(15,true)
    end,
    -- 是否加入行会
    [6] = function ( isHero )
        local proxy         = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
        return proxy:IsJoinGuild()
    end,
    -- 是否是沙城成员
    [7] = function( isHero )
        local proxy         = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return proxy:IsShabakeMember()
    end,
    -- 是否是行会会长
    [8] = function( isHero )
        local proxy         = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
        return proxy:IsMaster()
    end,
    -- 是否是沙城会长
    [9] = function( isHero )
        local proxy         = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        return proxy:IsShabakeAdmin()
    end,
    -- 获取职业
    [10] = function( isHero )
        local proxyTable    = isHero and global.ProxyTable.HeroPropertyProxy or global.ProxyTable.PlayerProperty
        local proxy         = global.Facade:retrieveProxy(proxyTable)
        return proxy:GetRoleJob()
    end,
    -- 获取货币
    [11] = function(costID)
        if not costID then
            return 0
        end
        local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
        return PayProxy:GetItemCount(costID)
    end,
    -- 获取属性值
    [12] = function(attrID, isHero)
        if not attrID then
            return
        end
        local proxyTable    = isHero and global.ProxyTable.HeroPropertyProxy or global.ProxyTable.PlayerProperty
        local proxy         = global.Facade:retrieveProxy(proxyTable)
        return proxy:GetRoleAttByAttType(attrID)
    end,
    -- 刺术 刺客属性
    [13] = function(isHero)
        local proxyTable    = isHero and global.ProxyTable.HeroPropertyProxy or global.ProxyTable.PlayerProperty
        local proxy         = global.Facade:retrieveProxy(proxyTable)
        return proxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_Prick) 
    end,
}

local CHECK_USE_NEED = {}
local M_CHECK_USE_NEED = {
    -- 等级   聚灵珠客户端不判断等级
    [0] = function( param, isHero )
        local level     = param.value or 0
        if param.StdMode == 49 or level <= 0 then
            return true,{}
        end

        local gValue    = GET_CEHCK_VALUE[0]( isHero )
        local canUse    =  gValue >= level

        return canUse, { {str=string.format(GET_STRING(80010000), level), can = canUse} }
    end,

    -- 攻
    [1] = function( param,isHero )
        local dc        = param.value or 0
        local gValue    = GET_CEHCK_VALUE[1]( isHero )
        local canUse    = gValue >= dc

        return canUse, { {str=string.format(GET_STRING(80010001),dc), can = canUse} }
    end,

    -- 魔
    [2] = function( param,isHero )
        local mc        = param.value or 0
        local gValue    = GET_CEHCK_VALUE[2]( isHero )
        local canUse    = gValue >= mc

        return canUse, { {str=string.format(GET_STRING(80010002),mc), can = canUse} }
    end,

    -- 道
    [3] = function( param,isHero )
        local sc        = param.value or 0
        local gValue    = GET_CEHCK_VALUE[3]( isHero )
        local canUse    = gValue >= sc

        return canUse, { {str=string.format(GET_STRING(80010003),sc), can = canUse} }
    end,

    -- 转生
    [4] = function( param,isHero )
        local value     = param.value or 0
        local gValue    = GET_CEHCK_VALUE[4]( isHero )
        local canUse    = gValue >= value

        return canUse, { {str=string.format(GET_STRING(80010004),value), can = canUse} }
    end,

    --需要指定声望点
    [5] = function( param,isHero )
        local value     = param.value or 0
        local gValue    = GET_CEHCK_VALUE[5]( isHero )
        local canUse    = gValue >= value

        return canUse, { {str=string.format(GET_STRING(80010005),value), can = canUse} }
    end,

    -- 是否加入行会
    [6] = function( param,isHero )
        local canUse    = GET_CEHCK_VALUE[6]( isHero )

        return canUse, { {str=GET_STRING(80010006), can = canUse} }
    end,

    -- 沙城成员 不做检测 默认满足
    [7] = function( param,isHero )
        return true, { {str=GET_STRING(80010007), can = true} }
    end,

    -- 指定职业和等级
    [10] = function( param,isHero )
        if param.StdMode == 49 then
            return true,{}
        end

        local value     = param.value or 0 
        local job       = L16Bit(value)
        local canUse    = job == 99
        local conditions= {}

        if not canUse then
            local combJob   = {[0] = 0, [1] = 1, [2] = 2}   -- 人物、英雄通用
            local heroJob   = {[3] = 3, [4] = 4, [5] = 5}   
            local playerJob = {[6] = 6, [7] = 7, [8] = 8}
            if combJob[job] then
                canUse      = job == GET_CEHCK_VALUE[10](isHero)
                conditions[1] = {str = string.format(GET_STRING(80010083), GET_STRING(50000324 + job)), can = canUse}
            elseif heroJob[job] then
                canUse      = job == GET_CEHCK_VALUE[10](true)
                conditions[1] = {str = string.format(GET_STRING(80010086), GET_STRING(50000324 + job - 3)), can = canUse}
            elseif playerJob[job] then
                local job   = job - 6
                canUse      = job == GET_CEHCK_VALUE[10]()
                conditions[1] = {str = string.format(GET_STRING(80010085), GET_STRING(50000324 + job)), can = canUse}
            end
        end

        local levelCanUse,condition = CHECK_USE_NEED[0]( {
            StdMode = param.StdMode,
            value   = H16Bit(value),
        }, isHero )

        conditions[2] = condition[1]
        return canUse and levelCanUse,conditions
    end,

    -- 指定职业和攻击力
    [11] = function( param,isHero )
        if param.StdMode == 49 then
            return true,{}
        end

        local value     = param.value or 0 
        local job       = L16Bit(value)
        local canUse    = job == 99
        local conditions= {}

        if not canUse then
            local combJob   = {[0] = 0, [1] = 1, [2] = 2}   -- 人物、英雄通用
            local heroJob   = {[3] = 3, [4] = 4, [5] = 5}   
            local playerJob = {[6] = 6, [7] = 7, [8] = 8}
            if combJob[job] then
                canUse      = job == GET_CEHCK_VALUE[10](isHero)
                conditions[1] = {str = string.format(GET_STRING(80010083), GET_STRING(50000324 + job)), can = canUse}
            elseif heroJob[job] then
                canUse      = job == GET_CEHCK_VALUE[10](true)
                conditions[1] = {str = string.format(GET_STRING(80010086), GET_STRING(50000324 + job - 3)), can = canUse}
            elseif playerJob[job] then
                local job   = job - 6
                canUse      = job == GET_CEHCK_VALUE[10]()
                conditions[1] = {str = string.format(GET_STRING(80010085), GET_STRING(50000324 + job)), can = canUse}
            end
        end

        local dcCanUse,condition = CHECK_USE_NEED[1]( {
            StdMode = param.StdMode,
            value   = H16Bit(value),
        }, isHero )

        conditions[2] = condition[1]
        return canUse and dcCanUse,conditions
    end,

    -- 12：指定职业和魔法力
    [12] = function( param,isHero )
        if param.StdMode == 49 then
            return true,{}
        end

        local value     = param.value or 0 
        local job       = L16Bit(value)
        local canUse    = job == 99
        local conditions= {}

        if not canUse then
            local combJob   = {[0] = 0, [1] = 1, [2] = 2}   -- 人物、英雄通用
            local heroJob   = {[3] = 3, [4] = 4, [5] = 5}   
            local playerJob = {[6] = 6, [7] = 7, [8] = 8}
            if combJob[job] then
                canUse      = job == GET_CEHCK_VALUE[10](isHero)
                conditions[1] = {str = string.format(GET_STRING(80010083), GET_STRING(50000324 + job)), can = canUse}
            elseif heroJob[job] then
                canUse      = job == GET_CEHCK_VALUE[10](true)
                conditions[1] = {str = string.format(GET_STRING(80010086), GET_STRING(50000324 + job - 3)), can = canUse}
            elseif playerJob[job] then
                local job   = job - 6
                canUse      = job == GET_CEHCK_VALUE[10]()
                conditions[1] = {str = string.format(GET_STRING(80010085), GET_STRING(50000324 + job)), can = canUse}
            end
        end

        local mcCanUse,condition = CHECK_USE_NEED[2]( {
            StdMode = param.StdMode,
            value   = H16Bit(value),
        }, isHero )

        conditions[2] = condition[1]
        return canUse and mcCanUse,conditions
    end,

    -- 13：指定职业和道术
    [13] = function( param,isHero )
        if param.StdMode == 49 then
            return true,{}
        end

        local value     = param.value or 0 
        local job       = L16Bit(value)
        local canUse    = job == 99
        local conditions= {}

        if not canUse then
            local combJob   = {[0] = 0, [1] = 1, [2] = 2}   -- 人物、英雄通用
            local heroJob   = {[3] = 3, [4] = 4, [5] = 5}   
            local playerJob = {[6] = 6, [7] = 7, [8] = 8}
            if combJob[job] then
                canUse      = job == GET_CEHCK_VALUE[10](isHero)
                conditions[1] = {str = string.format(GET_STRING(80010083), GET_STRING(50000324 + job)), can = canUse}
            elseif heroJob[job] then
                canUse      = job == GET_CEHCK_VALUE[10](true)
                conditions[1] = {str = string.format(GET_STRING(80010086), GET_STRING(50000324 + job - 3)), can = canUse}
            elseif playerJob[job] then
                local job   = job - 6
                canUse      = job == GET_CEHCK_VALUE[10]()
                conditions[1] = {str = string.format(GET_STRING(80010085), GET_STRING(50000324 + job)), can = canUse}
            end
        end

        local scCanUse,condition = CHECK_USE_NEED[3]( {
            StdMode = param.StdMode,
            value   = H16Bit(value),
        }, isHero )

        conditions[2] = condition[1]
        return canUse and scCanUse,conditions
    end,

    --指定等级
    [14] = function( param,isHero )
        local level     = param.value or 0
        local gValue    = GET_CEHCK_VALUE[0]( isHero )
        local canUse    =  gValue == level

        return canUse, { {str=string.format(GET_STRING(80010084), level), can = canUse} }
    end,

    -- 等级 及转生
    [40] = function( param,isHero )
        local value     = param.value or 0
        local checkParam = {
            StdMode = param.StdMode,
            value   = H16Bit(value)
        }
        local levelCanUse,condition1    = CHECK_USE_NEED[0]( checkParam,isHero )
        checkParam.value                = L16Bit(value)
        local reinLVCanUse,condition2   = CHECK_USE_NEED[4]( checkParam,isHero )

        return levelCanUse and reinLVCanUse, { condition1[1], condition2[1] }
    end,

    -- 攻    及转生
    [41] = function( param,isHero )
        local value     = param.value or 0
        local checkParam = {
            StdMode = param.StdMode,
            value   = H16Bit(value)
        }
        local levelCanUse,condition1    = CHECK_USE_NEED[1]( checkParam,isHero )
        checkParam.value                = L16Bit(value)
        local reinLVCanUse,condition2   = CHECK_USE_NEED[4]( checkParam,isHero )

        return levelCanUse and reinLVCanUse, { condition2[1], condition1[1] }
    end,

    -- 魔    及转生
    [42] = function( param,isHero )
        local value     = param.value or 0
        local checkParam = {
            StdMode = param.StdMode,
            value   = H16Bit(value)
        }
        local levelCanUse,condition1    = CHECK_USE_NEED[2]( checkParam,isHero )
        checkParam.value                = L16Bit(value)
        local reinLVCanUse,condition2   = CHECK_USE_NEED[4]( checkParam,isHero )

        return levelCanUse and reinLVCanUse, { condition2[1], condition1[1] }
    end,

    -- 道    及转生
    [43] = function( param,isHero )
        local value     = param.value or 0
        local checkParam = {
            StdMode = param.StdMode,
            value   = H16Bit(value)
        }
        local levelCanUse,condition1    = CHECK_USE_NEED[3]( checkParam,isHero )
        checkParam.value                = L16Bit(value)
        local reinLVCanUse,condition2   = CHECK_USE_NEED[4]( checkParam,isHero )

        return levelCanUse and reinLVCanUse, { condition2[1], condition1[1] }
    end,

    --声望等级    指定声望点
    [44] = function( param,isHero )
        local value     = param.value or 0
        local checkParam = {
            StdMode = param.StdMode,
            value   = H16Bit(value)
        }
        local levelCanUse,condition1    = CHECK_USE_NEED[5]( checkParam,isHero )
        checkParam.value                = L16Bit(value)
        local reinLVCanUse,condition2   = CHECK_USE_NEED[4]( checkParam,isHero )

        return levelCanUse and reinLVCanUse, { condition2[1], condition1[1] }
    end,

    -- 指定职业和转生等级
    [45] = function( param,isHero )
        if param.StdMode == 49 then
            return true,{}
        end
        
        local value     = param.value or 0 
        local job       = H16Bit(value)
        local canUse    = job == 99
        local conditions= {}

        if not canUse then
            local combJob   = {[0] = 0, [1] = 1, [2] = 2}   -- 人物、英雄通用
            local heroJob   = {[3] = 3, [4] = 4, [5] = 5}   
            local playerJob = {[6] = 6, [7] = 7, [8] = 8}
            if combJob[job] then
                canUse      = job == GET_CEHCK_VALUE[10](isHero)
                conditions[1] = {str = string.format(GET_STRING(80010083), GET_STRING(50000324 + job)), can = canUse}
            elseif heroJob[job] then
                canUse      = job == GET_CEHCK_VALUE[10](true)
                conditions[1] = {str = string.format(GET_STRING(80010086), GET_STRING(50000324 + job - 3)), can = canUse}
            elseif playerJob[job] then
                local job   = job - 6
                canUse      = job == GET_CEHCK_VALUE[10]()
                conditions[1] = {str = string.format(GET_STRING(80010085), GET_STRING(50000324 + job)), can = canUse}
            end
        end

        local reinLVCanUse,condition = CHECK_USE_NEED[4]( {
            StdMode = param.StdMode,
            value   = L16Bit(value),
        },isHero )
        conditions[2] = condition[1]

        return canUse and reinLVCanUse,conditions
    end,

    -- 是否是行会会长
    [60] = function( param,isHero )
        local value     = param.value or 0
        local canUse    = GET_CEHCK_VALUE[8]( isHero )

        return canUse,{ {str=GET_STRING(80010060), can = canUse} }
    end,

    -- 沙城会长 不做检测 默认满足
    [70] = function( param, isHero )
        return true,{ {str=GET_STRING(80010070), can = true} }
    end,

    -- 110 - 120 新增 [职业判断无额外设定]
    -- 指定职业和等级
    [110] = function (param, isHero)
        local job       = param.value or 99
        local value2    = param.value2 or 0
        local canUse    = job == 99
        local conditions= {}

        if not canUse then 
            canUse = job == GET_CEHCK_VALUE[10](isHero)
            conditions[1] = {str = string.format(GET_STRING(80010083), GetJobName(job)), can = canUse}
        end

        local levelCanUse, condition = CHECK_USE_NEED[0]({
            StdMode = param.StdMode,
            value   = value2,
        }, isHero)

        conditions[2] = condition[1]
        return canUse and levelCanUse, conditions
    end,

    -- 指定职业和攻击力
    [111] = function(param, isHero)
        if param.StdMode == 49 then
            return true, {}
        end

        local job       = param.value or 99 
        local value2    = param.value2 or 0
        local canUse    = job == 99
        local conditions= {}

        if not canUse then
            canUse      = job == GET_CEHCK_VALUE[10](isHero)
            conditions[1] = {str = string.format(GET_STRING(80010083), GetJobName(job)), can = canUse}
        end

        local dcCanUse, condition = CHECK_USE_NEED[1]({
            StdMode = param.StdMode,
            value   = value2,
        }, isHero)

        conditions[2] = condition[1]
        return canUse and dcCanUse, conditions
    end,

    -- 112：指定职业和魔法力
    [112] = function(param, isHero)
        if param.StdMode == 49 then
            return true, {}
        end

        local job       = param.value or 99 
        local value2    = param.value2 or 0
        local canUse    = job == 99
        local conditions= {}

        if not canUse then
            canUse      = job == GET_CEHCK_VALUE[10](isHero)
            conditions[1] = {str = string.format(GET_STRING(80010083), GetJobName(job)), can = canUse}
        end

        local mcCanUse,condition = CHECK_USE_NEED[2]({
            StdMode = param.StdMode,
            value   = value2,
        }, isHero)

        conditions[2] = condition[1]
        return canUse and mcCanUse, conditions
    end,

    -- 113：指定职业和道术
    [113] = function(param, isHero)
        if param.StdMode == 49 then
            return true,{}
        end

        local job       = param.value or 99 
        local value2    = param.value2 or 0
        local canUse    = job == 99
        local conditions= {}

        if not canUse then
            canUse      = job == GET_CEHCK_VALUE[10](isHero)
            conditions[1] = {str = string.format(GET_STRING(80010083), GetJobName(job)), can = canUse}
        end

        local scCanUse,condition = CHECK_USE_NEED[3]({
            StdMode = param.StdMode,
            value   = value2,
        }, isHero)

        conditions[2] = condition[1]
        return canUse and scCanUse, conditions
    end,

    -- 114: 指定货币
    [114] = function(param)
        local costID = param.value or 0
        if costID == 0 then
            return true, {}
        end

        -- 货币数量
        local value2 = param.value2 or 0
        if value2 <= 0 then
            return true, {}
        end

        local hasValue  = GET_CEHCK_VALUE[11](costID)
        local MoneyProxy = global.Facade:retrieveProxy(global.ProxyTable.MoneyProxy)
        local costName  = MoneyProxy:GetMoneyNameById(costID) or "无效货币"
        local canUse    = hasValue >= value2
        return canUse, {{str=string.format(GET_STRING(80010100), costName, value2), can = canUse}}
    end,

    -- 115: 指定转生等级和等级
    [115] = function(param, isHero)
        local reLevel   = param.value or 0
        local level     = param.value2 or 0
        local checkParam = {
            StdMode = param.StdMode,
            value   = reLevel
        }
        local reinLVCanUse, condition1  = CHECK_USE_NEED[4](checkParam, isHero)
        checkParam.value                = level
        local levelCanUse, condition2   = CHECK_USE_NEED[0](checkParam, isHero)

        return reinLVCanUse and levelCanUse, {condition1[1], condition2[1]}
    end,

    -- 116: 指定转生等级和攻击力
    [116] = function(param, isHero)
        local reLevel   = param.value or 0
        local value2    = param.value2 or 0
        local checkParam = {
            StdMode = param.StdMode,
            value   = reLevel
        }
        local reinLVCanUse, condition1  = CHECK_USE_NEED[4](checkParam, isHero)
        checkParam.value                = value2
        local canUse, condition2        = CHECK_USE_NEED[1](checkParam, isHero)

        return reinLVCanUse and canUse, {condition1[1], condition2[1]}
    end,

    -- 117: 指定转生等级和魔法力
    [117] = function(param, isHero)
        local reLevel   = param.value or 0
        local value2    = param.value2 or 0
        local checkParam = {
            StdMode = param.StdMode,
            value   = reLevel
        }
        local reinLVCanUse, condition1  = CHECK_USE_NEED[4](checkParam, isHero)
        checkParam.value                = value2
        local canUse, condition2        = CHECK_USE_NEED[2](checkParam, isHero)

        return reinLVCanUse and canUse, {condition1[1], condition2[1]}
    end,

    -- 118: 指定转生等级和道术
    [118] = function(param, isHero)
        local reLevel   = param.value or 0
        local value2    = param.value2 or 0
        local checkParam = {
            StdMode = param.StdMode,
            value   = reLevel
        }
        local reinLVCanUse, condition1  = CHECK_USE_NEED[4](checkParam, isHero)
        checkParam.value                = value2
        local canUse, condition2        = CHECK_USE_NEED[3](checkParam, isHero)

        return reinLVCanUse and canUse, {condition1[1], condition2[1]}
    end,

    -- 119: 指定转生等级和声望点
    [119] = function(param, isHero)
        local reLevel   = param.value or 0
        local value2    = param.value2 or 0
        local checkParam = {
            StdMode = param.StdMode,
            value   = reLevel
        }
        local reinLVCanUse, condition1  = CHECK_USE_NEED[4](checkParam, isHero)
        checkParam.value                = value2
        local canUse, condition2        = CHECK_USE_NEED[5](checkParam, isHero)

        return reinLVCanUse and canUse, {condition1[1], condition2[1]}
    end,

    -- 120: 指定转生等级和职业
    [120] = function(param, isHero)
        if param.StdMode == 49 then
            return true, {}
        end
        
        local value     = param.value or 0 
        local job       = param.value2 or 99
        local canUse    = job == 99
        local conditions= {}

        local reinLVCanUse, condition = CHECK_USE_NEED[4]({
            StdMode = param.StdMode,
            value   = value,
        }, isHero)
        conditions[1] = condition[1]

        if not canUse then
            canUse      = job == GET_CEHCK_VALUE[10](isHero)
            conditions[2] = {str = string.format(GET_STRING(80010083), GetJobName(job)), can = canUse}
        end

        return canUse and reinLVCanUse, conditions 
    end,
    -- 121: 指定职业和职业对应核心属性值以上
    [121] = function(param, isHero)
        if param.StdMode == 49 then
            return true, {}
        end

        local job       = param.value or 99 
        local value2    = param.value2 or 0
        local canUse    = job == 99
        local conditions= {}

        if not canUse then
            canUse      = job == GET_CEHCK_VALUE[10](isHero)
            conditions[1] = {str = string.format(GET_STRING(80010083), GetJobName(job)), can = canUse}
        end

        local attrCanUse = nil
        if job >= 5 and job <= 15 then
            local attId = GUIFunction:PShowAttType()["Max_CustJobAttr_" .. job]
            local attrValue = GET_CEHCK_VALUE[12](attId, isHero) or 0
            attrCanUse = attrValue >= value2
            local config = SL:GetMetaValue("ATTR_CONFIG", attId) or {}
            conditions[2] = {str = string.format(GET_STRING(80010100), config.name or string.format("职业%s核心属性", job), value2), can = attrCanUse}
        else
            local aCanUse, condition = CHECK_USE_NEED[job + 1]({
                StdMode = param.StdMode,
                value   = value2,
            }, isHero)
            attrCanUse = aCanUse
            conditions[2] = condition[1]
        end
        
        return canUse and attrCanUse, conditions
    end,
    -- 122: 指定转生等级和刺客属性上限值
    [122] = function(param, isHero)
        local reLevel   = param.value or 0
        local value2    = param.value2 or 0
        local conditions = {}
        local checkParam = {
            StdMode = param.StdMode,
            value   = reLevel
        }
        local reinLVCanUse, condition1  = CHECK_USE_NEED[4](checkParam, isHero)
        conditions[1] = condition1[1]

        local attrValue     = GET_CEHCK_VALUE[13](isHero) or 0
        local attrCanUse    = attrValue >= value2
        local config = SL:GetMetaValue("ATTR_CONFIG", GUIFunction:PShowAttType().Max_Prick) or {}
        conditions[2] = {str = string.format(GET_STRING(80010100), config.name or "刺客核心属性", value2), can = attrCanUse}

        return reinLVCanUse and attrCanUse, conditions
    end,

    -- 123: 指定转生等级和职业5属性上限值
    -- 123 - 134 ：职业5 - 15
    [123] = function(param, isHero)
        local reLevel   = param.value or 0
        local value2    = param.value2 or 0
        local jobIdx    = param.jobIdx or 0
        local conditions = {}
        local checkParam = {
            StdMode = param.StdMode,
            value   = reLevel
        }
        local reinLVCanUse, condition1  = CHECK_USE_NEED[4](checkParam, isHero)
        conditions[1] = condition1[1]

        local job = 5 + jobIdx
        local attId = GUIFunction:PShowAttType()["Max_CustJobAttr_" .. job]
        local attrValue = GET_CEHCK_VALUE[12](attId, isHero) or 0
        local attrCanUse = attrValue >= value2
        local config = SL:GetMetaValue("ATTR_CONFIG", attId) or {}
        conditions[2] = {str = string.format(GET_STRING(80010100), config.name or string.format("职业%s核心属性", job), value2), can = attrCanUse}

        return reinLVCanUse and attrCanUse, conditions
    end,
    

}
CHECK_USE_NEED = M_CHECK_USE_NEED

local COMMON_FUNC_IDX = 123
local COMMON_FUNC_IDX_MAX = 134
local function checkComFunc(needType)
    if needType >= COMMON_FUNC_IDX and needType <= COMMON_FUNC_IDX_MAX then
        local index = needType - COMMON_FUNC_IDX
        return COMMON_FUNC_IDX, index
    end
end

-- 服务器翻过来 用于前端检测道具使用
function CheckItemUseNeed(item)
    local needType = item.Need
    local needLevel = item.NeedLevel
    local notCheckUse = true --不检测是否满足使用条件
    if not needType or not needLevel then
        return true,{},notCheckUse
    end

    local commonType, jobIdx = checkComFunc(needType)
    if not CHECK_USE_NEED[commonType or needType] then
        return true, {}, notCheckUse
    end

    local param = {
        StdMode = item.StdMode,
        value   = needLevel,
        value2  = item.NeedLevelParam or 0,
        jobIdx  = jobIdx
    }

    -- 聚灵珠不用判断显示
    if item.StdMode == 49 then
        return true, {}, notCheckUse
    end

    local canUse, conditionStr = CHECK_USE_NEED[commonType or needType](param)
    return canUse, conditionStr, notCheckUse
end

function CheckItemUseNeed_Hero(item)
    local needType = item.Need
    local needLevel = item.NeedLevel
    local notCheckUse = true --不检测是否满足使用条件
    if not needType or not needLevel then
        return true,{},notCheckUse
    end
    if not CHECK_USE_NEED[needType] then
        return true,{},notCheckUse
    end

    local param = {
        StdMode = item.StdMode,
        value   = needLevel,
        value2  = item.NeedLevelParam or 0,
    }
    local canUse,conditionStr = CHECK_USE_NEED[needType](param,true)
    return canUse,conditionStr,notCheckUse
end

