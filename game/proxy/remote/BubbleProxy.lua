local RemoteProxy = requireProxy("remote/RemoteProxy")
local BubbleProxy = class("BubbleProxy", RemoteProxy)
BubbleProxy.NAME = global.ProxyTable.BubbleProxy

--前端条件 气泡表
local cjson = require("cjson")
local getVarNames = nil
getVarNames = function(conditions, vec)
    if not conditions then
        return
    end
    if conditions.dType == 2 then
        for i, condition in ipairs(conditions.conditions) do
            if condition.dType == 2 then
                getVarNames(condition, vec)
            else
                local name = ""
                if condition.var.Hero then
                    name = "H_" .. name
                end
                name = name .. condition.var.key
                if condition.var.value then
                    name = name .. "_" .. condition.var.value
                end
                table.insert(vec, name)
            end
        end
    else
        local name = ""
        if conditions.var.Hero then
            name = "H_" .. name
        end
        name = name .. conditions.var.key
        if conditions.var.value then
            name = name .. "_" .. conditions.var.value
        end
        table.insert(vec, name)
    end
end

function BubbleProxy:ctor()
    BubbleProxy.super.ctor(self)
    self:Init()
end

function BubbleProxy:onRegister()
    BubbleProxy.super.onRegister(self)
end

function BubbleProxy:Init()
    self._configs = {}
    self._valList = {} --触发表
    self._scheduleId = nil

    self._needCheckIDs = {}
    self._needCheckIDsVec = {}

    self._activeIDs = {}--激活列表
    self:LoadConfig()
    self:InitItems()
end

function BubbleProxy:LoadConfig()
    local configs = requireGameConfig("cfg_bubble")
    for k, v in pairs(configs) do
        self._configs[v.id] = v
    end
end

function BubbleProxy:InitItems()
    for id, config in pairs(self._configs) do
        self:addVarList(id)
    end
end

function BubbleProxy:StartSchedule()
    if self._scheduleId then
        UnSchedule(self._scheduleId)
        self._scheduleId = nil
    end
    self._scheduleId = Schedule(function()
        for i = 1, 5 do
            if #self._needCheckIDsVec > 0 then
                local id = table.remove(self._needCheckIDsVec, 1)
                local config = self._configs[id]
                if self:CheckStrConditions(config.VarCondition1,{ BindCurrency = config.BindCurrency })
                and self:CheckStrConditions(config.VarCondition2,{ BindCurrency = config.BindCurrency })
                and self:CheckStrConditions(config.currencyCondition, { BindCurrency = config.BindCurrency }) then --满足条件
                    self:addActiveID(config.id)
                else
                    self:rmvActiveID(config.id)
                end
                self._needCheckIDs[id] = false
            else 
                break
            end
        end
    end, 1 / 60)
end

function BubbleProxy:addActiveID(id)
    if not self._activeIDs[id] then  
        self._activeIDs[id] = true
        local config = self._configs[id]
        local RemindUpgradeProxy = global.Facade:retrieveProxy(global.ProxyTable.RemindUpgradeProxy)   
        RemindUpgradeProxy:refData(id,true,{id = id,name = config.ShowText,link = config.Link})
    end
end

function BubbleProxy:rmvActiveID(id)
    if not self._activeIDs[id] then
        return 
    end  
    self._activeIDs[id] = false 
    local RemindUpgradeProxy = global.Facade:retrieveProxy(global.ProxyTable.RemindUpgradeProxy)   
    RemindUpgradeProxy:refData(id,false)
end

function BubbleProxy:addVarList(id)--增加触发变量
    local config = self._configs[id]
    local RedPointProxy = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)  
    local vConditions = RedPointProxy:getConditions(config.VarCondition1,{ BindCurrency = config.BindCurrency })
    local vConditions2 = RedPointProxy:getConditions(config.VarCondition2,{ BindCurrency = config.BindCurrency })
    local cConditions = RedPointProxy:getConditions(config.currencyCondition, { BindCurrency = config.BindCurrency })
    local namevec = {}
    getVarNames(vConditions, namevec)
    getVarNames(vConditions2, namevec)
    getVarNames(cConditions, namevec)
    for i, varname in ipairs(namevec) do
        self._valList[varname] = self._valList[varname] or {}
        self._valList[varname][id] = config
    end
end

-------------------------------------------------------------
function BubbleProxy:CheckStrConditions(str, exData)
    if not str or str == "" then
        return true
    end
    local RedPointProxy = global.Facade:retrieveProxy(global.ProxyTable.RedPointProxy)  
    return RedPointProxy:CheckStrConditions(str, exData)
end

function BubbleProxy:InstertCheckQue(Var)
    local List = self._valList[Var]
    if List then
        for id, val in pairs(List) do
            if not self._needCheckIDs[id] then
                self._needCheckIDs[id] = true
                table.insert(self._needCheckIDsVec, id)
            end
        end
    end
end

return BubbleProxy