local RemoteProxy = requireProxy("remote/RemoteProxy")
local RedPointProxy = class("RedPointProxy", RemoteProxy)
RedPointProxy.NAME = global.ProxyTable.RedPointProxy

local SUIHelper = require("sui/SUIHelper")
local sgsub     = string.gsub
local sformat   = string.format
local ssplit    = string.split
local sfind     = string.find
local smatch    = string.match

local cjson = require("cjson")
local values = {
    LEVEL = function(isHero)--当前等级
        local PropertyProxy
        if isHero then
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        else
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        end
        local LEVEL = PropertyProxy:GetRoleLevel()

        return LEVEL
    end,
    HP = function(isHero)--当前hp
        local PropertyProxy
        if isHero then
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        else
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        end
        local HP = PropertyProxy:GetRoleCurrHP()
        return HP
    end,
    MP = function(isHero)--当前mp
        local PropertyProxy
        if isHero then
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        else
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        end
        local MP = PropertyProxy:GetRoleCurrMP()
        return MP
    end,
    MAXAC = function(isHero)--最高物防
        local PropertyProxy
        if isHero then
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        else
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        end
        local MAXAC = PropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_DEF)
        return MAXAC
    end,
    MAXMAC = function(isHero)--最高魔防
        local PropertyProxy
        if isHero then
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        else
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        end
        local MAXMAC = PropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_MDF)
        return MAXMAC
    end,
    MAXDC = function(isHero)--最高物攻
        local PropertyProxy
        if isHero then
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        else
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        end
        local MAXDC = PropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_ATK)
        return MAXDC
    end,
    MAXMC = function(isHero)--最高魔攻
        local PropertyProxy
        if isHero then
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        else
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        end
        local MAXMC = PropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_MAT)
        return MAXMC
    end,
    MAXSC = function(isHero)--最高道术
        local PropertyProxy
        if isHero then
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        else
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        end
        local MAXMC = PropertyProxy:GetRoleAttByAttType(GUIFunction:PShowAttType().Max_Daoshu)
        return MAXMC
    end,
    MAXHP = function(isHero)--最大hp
        local PropertyProxy
        if isHero then
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        else
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        end
        local MAXHP = PropertyProxy:GetRoleMaxHP()
        return MAXHP
    end,
    MAXMP = function(isHero)--最大mp
        local PropertyProxy
        if isHero then
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        else
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        end
        local MAXMP = PropertyProxy:GetRoleMaxMP()
        return MAXMP
    end,
    EXP = function(isHero)--经验
        local PropertyProxy
        if isHero then
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        else
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        end
        local EXP = PropertyProxy:GetCurrExp()
        return EXP
    end,
    RELEVEL = function(isHero)--转生
        local PropertyProxy
        if isHero then
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        else
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        end
        local RELEVEL = PropertyProxy:GetRoleReinLv()
        return RELEVEL
    end,
    STARCOUNTALL = function(isHero)--获取全身所有装备星星数量总和
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        local equipData = EquipProxy:GetEquipData()
        local sum = 0
        for _, equip in pairs(equipData) do
            if equip.Star then
                sum = sum + equip.Star
            end
        end
        return sum
    end,
    JOB = function(isHero)--人物职业
        local PropertyProxy
        if isHero then
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        else
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        end
        local JOB = PropertyProxy:GetRoleJob()
        return JOB
    end,
    GENDER = function(isHero)--人物性别
        local PropertyProxy
        if isHero then
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        else
            PropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        end
        local SEX = PropertyProxy:GetRoleSex()
        return SEX
    end,
    USEITEMNAME = function(isHero, pos)--装备名字
        if not pos then
            return ""
        end
        local EquipProxy
        if isHero then
            EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
        else
            EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        end
        pos = tonumber(pos)
        local equipData = EquipProxy:GetEquipDataByPos(pos)
        if not equipData then
            return ""
        end
        return equipData.Name
    end,
    USEITEMID = function(isHero, pos)--装备index
        if not pos then
            return 0
        end
        local EquipProxy
        if isHero then
            EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
        else
            EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        end
        pos = tonumber(pos)
        local equipData = EquipProxy:GetEquipDataByPos(pos)
        if not equipData then
            return 0
        end
        return equipData.Index
    end,
    ITEMINDEX = function(isHero, currencyId, BindCurrency)--道具id
        local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
        local binds = ssplit(BindCurrency or "", "#")
        local bind = false
        for i, v in ipairs(binds) do
            if currencyId == (tonumber(v) or 0) then
                bind = true
                break
            end
        end
        local count = PayProxy:GetItemCount(currencyId, bind)
        return count
    end,
    MONEY = function(isHero, name)
        local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
        local MoneyProxy = global.Facade:retrieveProxy(global.ProxyTable.MoneyProxy)
        local currencyId = MoneyProxy:GetMoneyIdByName(name)
        local count = PayProxy:GetItemCount(currencyId)
        return count
    end,

}

local function getChildInSubNodes(nodeTable, key)
    if not key or key == "" then 
        return nil
    end
    if #nodeTable == 0 then
        return nil
    end
    local child = nil
    local subNodeTable = {}
    for _, v in ipairs(nodeTable) do
        if tolua.isnull(v) then
            return nil
        end
        child = v:getChildByName(key)
        if (child) then
            return child
        end
        if GUI:getRedID(child) == key then
            return child
        end
    end
    for _, v in ipairs(nodeTable) do
        local subNodes = v:getChildren()
        if #subNodes ~= 0 then
            for _, v1 in ipairs(subNodes) do
                table.insert(subNodeTable, v1)
            end
        end
    end
    return getChildInSubNodes(subNodeTable, key)
end

local function getChildByKey(parent, key)
    return getChildInSubNodes({ parent }, key)
end

local getVarNames
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

function RedPointProxy:ctor()
    RedPointProxy.super.ctor(self)
    self:Init()
end

function RedPointProxy:onRegister()
    RedPointProxy.super.onRegister(self)
end

-- 获取支持的常量
function RedPointProxy:getValues()
    return values
end

function RedPointProxy:Init()
    self._configs           = {}
    self._groups            = {}    -- 按组分config
    self._needCheckItems    = {}    -- 要检测的项目  {levelConditionVar = {config}}
    self._idsWithVarItems   = {}    -- id里面带有变量的项目

    self._GuideWidgetConfig = requireConfig("GuideWidgetConfig.lua")
    self._conditionsCache   = {}
    self._idsCache          = {}
    self._ServerVars        = {}    -- 服务器数据解析之后
    self._valList           = {}    -- 触发表
    self._TXTServerVars     = {}

    self._needCheckIDs      = {}
    self._needCheckIDsVec   = {}
    self._scheduleId = nil

    self._showIDTable       = { showIDs = {}, mainIDs = {}, npcLayerIDs = {} }
    self._ConstDict         = {}    -- 常量映射

    self:LoadConfig()
    self:InitItems()
end

function RedPointProxy:StartSchedule()
    if self._scheduleId then
        UnSchedule(self._scheduleId)
        self._scheduleId = nil
    end
    self._scheduleId = Schedule(function()
        for i = 1, 5 do
            if #self._needCheckIDsVec > 0 then
                local id = table.remove(self._needCheckIDsVec, 1)
                local config = self._configs[id]
                if self:CheckStrConditions(config.levelCondition)
                and self:CheckStrConditions(config.VarCondition, { BindCurrency = config.BindCurrency })
                and self:CheckStrConditions(config.currencyCondition, { BindCurrency = config.BindCurrency }) then --满足条件
                    self:addShowIds(config.id)
                else
                    self:rmvShowIds(config.id)
                end
                self._needCheckIDs[id] = false
            else 
                break
            end
        end
    end, 1 / 60)
end

function RedPointProxy:InitItems()
    self._needCheckItems["_ALL_"] = {}
    for k, v in pairs(self._groups) do
        local firstItem = v[1]
        if firstItem.levelCondition then
            local lConditions = self:stringtoCondition(firstItem.levelCondition)
            local namevec = {}
            getVarNames(lConditions, namevec)
            for i, varname in ipairs(namevec) do
                self._needCheckItems[varname] = self._needCheckItems[varname] or {}
                table.insert(self._needCheckItems[varname], firstItem)
            end
        else
            for i, v2 in ipairs(v) do
                table.insert(self._needCheckItems["_ALL_"], v2)
            end
        end
    end

    for k, configs in pairs(self._needCheckItems) do
        for i, config in ipairs(configs) do
            self:addVarList(config.id)
            self:addIdsList(config.id)
        end

    end
    -- dump(self._valList, "self._valList__")
end
---------------------------------------varlist
function RedPointProxy:rmVarList(id)
    for varname, idList in pairs(self._valList) do
        idList[id] = nil
    end
end

-- 增加触发变量
function RedPointProxy:addVarList(id)
    local config = self._configs[id]
    local lConditions = self:getConditions(config.levelCondition)
    local vConditions = self:getConditions(config.VarCondition, { BindCurrency = config.BindCurrency })
    local cConditions = self:getConditions(config.currencyCondition, { BindCurrency = config.BindCurrency })
    local namevec = {}
    getVarNames(lConditions, namevec)
    getVarNames(vConditions, namevec)
    getVarNames(cConditions, namevec)
    for i, varname in ipairs(namevec) do
        self._valList[varname] = self._valList[varname] or {}
        self._valList[varname][id] = config
    end
end

----------------------------------------------id  {type = 1,value= "101"}  {type = 2,var = STR(哈哈),property = haha}
-- str -> ids
function RedPointProxy:getIdsByStr(str)
    if not str then
        SL:Print("ERROR:红点配置 ids 为空")
        return {}
    end
    if not self._idsCache[str] then
        self._idsCache[str] = self:ParseIdsWithStr(str)
    end
    return self._idsCache[str]
end

--ids -> {101,1,2,3,4}
function RedPointProxy:getIDVecByIds(ids)
    local vec = {}
    for i, v in ipairs(ids) do
        if v.type == 1 then
            table.insert(vec, v.value)
        else
            local key = v.property or "value"
            if self._ServerVars[v.var] then
                local value = self._ServerVars[v.var][key]
                if value then
                    local idVec = ssplit(value, "#")
                    for i, v in ipairs(idVec) do
                        table.insert(vec, v)
                    end
                end
            end
        end
    end
    return vec
end

-- str -> ids {id,id}
function RedPointProxy:ParseIdsWithStr(idstrs)
    local idVec = ssplit(idstrs, "#")
    local res = {}
    for i, v in ipairs(idVec) do
        local id = {}
        if sfind(v, "%b<>") then
            id.type = 2
            local value = smatch(v, "<(.-)>")
            local var, property = self:ParseVar(value)
            id.var = var
            id.property = property
        else
            id.type = 1
            id.value = v
        end
        table.insert(res, id)
    end
    return res
end

function RedPointProxy:addIdsList(id)
    local config = self._configs[id]
    if config.ids then
        local ids = self:getIdsByStr(config.ids)
        for i, v in ipairs(ids) do
            if v.type == 2 then
                local key2 = v.var
                self._idsWithVarItems[key2] = self._idsWithVarItems[key2] or {}
                table.insert(self._idsWithVarItems[key2], id)
            end
        end
    end
end

function RedPointProxy:rmIdsList(id)
    for k, idvec in pairs(self._idsWithVarItems) do
        for i = #idvec, 1, -1 do
            local id2 = idvec[i]
            if id2 == id then
                table.remove(idvec, i)
                break
            end
        end
    end
end

function RedPointProxy:addRedByIdKey(Idkey)
    local vec = self._idsWithVarItems[Idkey]
    for i = 1, #vec do
        self:addShowIds(vec[i])
    end
end

function RedPointProxy:rmvRedByIdKey(Idkey)
    local vec = self._idsWithVarItems[Idkey]
    for i = 1, #vec do
        self:rmvShowIds(vec[i])
    end
end

function RedPointProxy:UpdateItems(varkey)
    local vec = self._needCheckItems[varkey]
    for i, v in ipairs(vec) do
        local conf = nil
        local group = v.group
        local configs = self._groups[group]
        for i2, config in ipairs(configs) do
            if config.levelCondition and self:CheckStrConditions(config.levelCondition) then
                conf = config
                break
            end    
        end
        if conf then
            if vec[i].levelCondition ~= conf.levelCondition then
                self:rmVarList(vec[i].id)
                self:addVarList(conf.id)

                self:rmvShowIds(vec[i].id)
                self:rmIdsList(vec[i].id)
                self:addIdsList(conf.id)

                vec[i] = conf
            end
        end
    end
end

function RedPointProxy:rmvRedDot(widget)
    if not widget then
        return
    end
    local reddot = widget:getChildByName("_RedDot_2")
    if reddot then
        reddot:removeFromParent()
    end
end

function RedPointProxy:addRedDot(widget, offset)
    if not widget then
        return
    end
    local reddot = widget:getChildByName("_RedDot_2")
    if reddot then
        reddot:removeFromParent()
    end
    local offset2, strs, id, x, y,tblr
    if offset then
        strs = ssplit(offset, "|")
        offset2 = strs[global.isWinPlayMode and 2 or 1]
    end
    if offset2 then --0#-5#5#0
        strs = ssplit(offset2, "#")
        id = strs[1] or 0
        x = strs[2] or 0
        y = strs[3] or 0
        tblr = strs[4] or 0
    end
    if not id then
        return
    end
    local redid = tonumber(id)
    x = tonumber(x)
    y = tonumber(y)
    tblr = tonumber(tblr)
    local content = widget:getContentSize()
    local wid = content.width 
    local hei = content.height
    y = hei - y
    --默认左上
    if tblr == 1 then--右
        x = x + wid
    elseif tblr == 2 then--左下 
        y = y - hei
    elseif tblr == 3 then --右下
        x = x + wid
        y = y - hei
    elseif tblr == 4 then--中间
        x = x + wid/2
        y = y - hei/2
    end
    if not redid then -- 自定义路径
        local path = SUIHelper.fixImageFileName(id)
        reddot = cc.Sprite:create(path)
        if reddot then
            reddot:setName("_RedDot_2")
            widget:addChild(reddot)
            reddot:setPosition(x, y)
        end
    elseif redid == 0 then
        strs = ssplit(SL:GetMetaValue("GAME_DATA","Redtips") or "", "|")
        local path = strs[global.isWinPlayMode and 1 or 2]
        path = SUIHelper.fixImageFileName(path)
        reddot = cc.Sprite:create(path)
        if reddot then
            reddot:setName("_RedDot_2")
            widget:addChild(reddot)
            reddot:setPosition(x, y)
        end
    else
        local sfxID = id
        if sfxID then
            reddot = global.FrameAnimManager:CreateSFXAnim(sfxID)
            if reddot then
                reddot:Play(0, 0, true)
                reddot:setName("_RedDot_2")
                widget:addChild(reddot)
                reddot:setPosition(x, y)
            end
        end
    end
end

function RedPointProxy:addShowIds(id)
    if self._showIDTable.showIDs[id] then
        return false
    end

    self._showIDTable.showIDs[id] = true

    SLBridge:onLUAEvent(LUA_EVENT_RED_POINT_ADD, {id = id})

    local config = self._configs[id]
    local idvec  = self:getIDVecByIds(self:getIdsByStr(config.ids))

    --mainIDs = {101 = {count = 1 , btnIDs = {10 = {count = 1}}}}
    --npcLayerIDs = {101 = {count = 1 , btnIDs = {10 = {count = 1}}}}

    local mainID
    local npcLayerID

    local activeMainButtonID = 0
    local activeNpcLayerID = {}

    for i, v in ipairs(idvec) do
        if i == 1 then
            mainID = v
            self._showIDTable.mainIDs[mainID] = self._showIDTable.mainIDs[mainID] or { count = 0, btnIDs = {} }
            self._showIDTable.mainIDs[mainID].count = self._showIDTable.mainIDs[mainID].count + 1
        elseif i == 2 then
            self._showIDTable.mainIDs[mainID].btnIDs[v] = self._showIDTable.mainIDs[mainID].btnIDs[v] or { count = 0, offset = 0 }
            if self._showIDTable.mainIDs[mainID].btnIDs[v].count == 0 or self._showIDTable.mainIDs[mainID].btnIDs[v].offset ~= config.offset then--主面板激活红点 
                activeMainButtonID = v
                self._showIDTable.mainIDs[mainID].btnIDs[v].offset = config.offset
            end
            self._showIDTable.mainIDs[mainID].btnIDs[v].count = self._showIDTable.mainIDs[mainID].btnIDs[v].count + 1
        elseif i == 3 then
            npcLayerID = v
            self._showIDTable.npcLayerIDs[npcLayerID] = self._showIDTable.npcLayerIDs[npcLayerID] or { count = 0, btnIDs = {} }
            self._showIDTable.npcLayerIDs[npcLayerID].count = self._showIDTable.npcLayerIDs[npcLayerID].count + 1
        else
            self._showIDTable.npcLayerIDs[npcLayerID].btnIDs[v] = self._showIDTable.npcLayerIDs[npcLayerID].btnIDs[v] or { count = 0, offset = 0 }
            if self._showIDTable.npcLayerIDs[npcLayerID].btnIDs[v].count == 0 or self._showIDTable.npcLayerIDs[npcLayerID].btnIDs[v].offset ~= config.offset then
                table.insert(activeNpcLayerID, v)
                self._showIDTable.npcLayerIDs[npcLayerID].btnIDs[v].offset = config.offset
            end
            self._showIDTable.npcLayerIDs[npcLayerID].btnIDs[v].count = self._showIDTable.npcLayerIDs[npcLayerID].btnIDs[v].count + 1
        end
    end

    if activeMainButtonID ~= 0 then
        local widgets = self:FindWidget({ { id = mainID, offset = config.offset }, { id = activeMainButtonID, offset = config.offset } }, true)
        for i, widget in ipairs(widgets) do
            self:addRedDot(widget, config.offset)
        end
    end
    
    if #activeNpcLayerID > 0 then --npcLayer 在npcLayer打开也要激活红点
        local NPCLayerMediator = global.Facade:retrieveMediator("NPCLayerMediator")
        if NPCLayerMediator._layer and NPCLayerMediator._layer.background then
            local npclayerid = NPCLayerMediator._layer.background.element.attr.layerid
            if npclayerid and npclayerid == npcLayerID then
                local idVec = { { id = npclayerid, offset = config.offset } }
                for i, v in ipairs(activeNpcLayerID) do
                    table.insert(idVec, { id = v, offset = config.offset })
                end
                local widgets = self:FindWidget(idVec)
                for i, widget in ipairs(widgets) do
                    self:addRedDot(widget, config.offset)
                end
            end
        end
    end
end
function RedPointProxy:rmvShowIds(id)
    if not self._showIDTable.showIDs[id] then
        return false
    end
    self._showIDTable.showIDs[id] = nil

    SLBridge:onLUAEvent(LUA_EVENT_RED_POINT_DEL, {id = id})

    local config = self._configs[id]
    local idvec  = self:getIDVecByIds(self:getIdsByStr(config.ids))
    local otherID = {}
    --mainIDs = {101 = {count = 1 , btnIDs = {10 = {count = 1}}}}
    --npcLayerIDs = {101 = {count = 1 , btnIDs = {10 = {count = 1}}}}
    local mainID
    local npcLayerID
    local rmvMainButtonID = 0
    local rmvNpcLayerID = {}
    for i, v in ipairs(idvec) do
        if i == 1 then
            mainID = v
            if self._showIDTable.mainIDs[mainID] and self._showIDTable.mainIDs[mainID].count then
                self._showIDTable.mainIDs[mainID].count = math.max(self._showIDTable.mainIDs[mainID].count - 1, 0)
            end
        elseif i == 2 then
            if self._showIDTable.mainIDs[mainID]
            and self._showIDTable.mainIDs[mainID].btnIDs
            and self._showIDTable.mainIDs[mainID].btnIDs[v]
            and self._showIDTable.mainIDs[mainID].btnIDs[v].count then
                self._showIDTable.mainIDs[mainID].btnIDs[v].count = math.max(self._showIDTable.mainIDs[mainID].btnIDs[v].count - 1, 0)
                if self._showIDTable.mainIDs[mainID].btnIDs[v].count == 0 then
                    rmvMainButtonID = v
                end
            end
        elseif i == 3 then
            npcLayerID = v
            if self._showIDTable.npcLayerIDs[npcLayerID] and self._showIDTable.npcLayerIDs[npcLayerID].count then
                self._showIDTable.npcLayerIDs[npcLayerID].count = math.max(self._showIDTable.npcLayerIDs[npcLayerID].count - 1, 0)
            end
        else
            if self._showIDTable.npcLayerIDs[npcLayerID]
            and self._showIDTable.npcLayerIDs[npcLayerID].btnIDs
            and self._showIDTable.npcLayerIDs[npcLayerID].btnIDs[v]
            and self._showIDTable.npcLayerIDs[npcLayerID].btnIDs[v].count then
                self._showIDTable.npcLayerIDs[npcLayerID].btnIDs[v].count = math.max(self._showIDTable.npcLayerIDs[npcLayerID].btnIDs[v].count - 1, 0)
                if self._showIDTable.npcLayerIDs[npcLayerID].btnIDs[v].count == 0 or self._showIDTable.npcLayerIDs[npcLayerID].btnIDs[v].offset ~= config.offset then
                    table.insert(rmvNpcLayerID, v)
                end
            end
        end
    end

    if rmvMainButtonID ~= 0 then
        local widgets = self:FindWidget({ { id = mainID, offset = config.offset }, { id = rmvMainButtonID, offset = config.offset } }, true)
        for i, widget in ipairs(widgets) do
            self:rmvRedDot(widget)
        end
    end
    
    if #rmvNpcLayerID > 0 then --npcLayer 在npcLayer打开也要激活红点
        local NPCLayerMediator = global.Facade:retrieveMediator("NPCLayerMediator")
        if NPCLayerMediator._layer and NPCLayerMediator._layer.background then
            local npclayerid = NPCLayerMediator._layer.background.element.attr.layerid
            if npclayerid and npclayerid == npcLayerID then
                local idVec = { { id = npcLayerID, offset = config.offset } }
                for i, v in ipairs(rmvNpcLayerID) do
                    table.insert(idVec, { id = v, offset = config.offset })
                end
                local widgets = self:FindWidget(idVec)
                for i, widget in ipairs(widgets) do
                    self:rmvRedDot(widget)
                end
            end
        end
    end
end

function RedPointProxy:FindWidget(idVec, ismain)
    -- 主界面ID#按钮ID#面板ID#按钮ID#按钮ID
    local mainId, buttonId
    local layerId
    local buttonIdVec = {}
    if ismain then
        mainId = idVec[1].id
        buttonId = idVec[2].id
        mainId = tonumber(mainId)
        local getNodesFunc = self._GuideWidgetConfig[mainId]
        if not getNodesFunc then
            return {}
        end
        local widget, parent = getNodesFunc({ typeassist = buttonId })
        if widget then
            widget._Redoffset = idVec[2].offset
            return { widget }
        end
    else
        layerId = idVec[1].id
        for i = 2, #idVec do
            buttonIdVec[#buttonIdVec + 1] = idVec[i]
        end
        if #buttonIdVec > 0 then
            local NPCLayerMediator = global.Facade:retrieveMediator("NPCLayerMediator")
            if NPCLayerMediator._layer then
                if NPCLayerMediator._layer and NPCLayerMediator._layer.background then
                    local npclayerid = NPCLayerMediator._layer.background.element.attr.layerid
                    if npclayerid and npclayerid == layerId then
                        local widgets = {}
                        for i, v in ipairs(buttonIdVec) do
                            local widget = getChildByKey(NPCLayerMediator._layer, tostring(v.id))
                            if widget then
                                widget._Redoffset = v.offset
                                table.insert(widgets, widget)
                            end
                        end
                        return widgets
                    end
                end
            end
        end
    end
    return {}
end

----------------------------------------------------------解析表

-- T10#等级>=10 ->  {T10,等级} ,>= ,10
-- T10<=10   -> {T10},<=,10
-- <T10#哈哈>>=10 -> {T10,哈哈},>=,10
function RedPointProxy:ParseExpression(expression)
    local elements = {}
    local var, element
    if sfind(expression, "%b<>") then
        elements = { smatch(expression, "<(.-)>([!><=]+)(.*)") }
        var, element = self:ParseVar(elements[1])
    else
        elements = { smatch(expression, "(.-)([!><=]+)(.*)") }
        var = self:ParseVar(elements[1])
    end
    if elements[3] == "null" then 
        elements[3] = ""
    end
    return { var, element }, elements[2], elements[3]
end

-- T10 -> T10 
-- T10#转生 -> T10,转生
-- $str(T10)#转生 -> T10,转生
-- $custom(T10)#转生 -> custom(T10),转生
-- N$哈哈->N$哈哈
function RedPointProxy:ParseVar(var)
    if not var then
        return ""
    end
    local value, attr
    if sfind(var, "#") then
        local vars = ssplit(var, "#")
        value = vars[1]
        attr = vars[2]
    else
        value = var
    end
    value = string.upper(value)
    if value then
        if sfind(value, "$STR%(.+%)") then
            value = smatch(value, "$STR%((.+)%)")
        elseif sfind(value, "%a$.+") then
            value = smatch(value, "%a$.+")
        elseif sfind(value, "$.+") then
            value = smatch(value, "$(.+)")
        end
    end
    return value, attr
end

function RedPointProxy:CheckStrConditions(str, exData)
    if not str or str == "" then
        return true
    end
    local conditions = self:getConditions(str, exData)
    return self:CheckConditions(conditions)
end

function RedPointProxy:getConditions(str, exData)
    if not str or str == "" then
        return nil
    end
    if not self._conditionsCache[str] then
        self._conditionsCache[str] = self:ParseConditionStr(str, exData)
    end
    return self._conditionsCache[str]
end

function RedPointProxy:CheckConditions(conditions)
    if not conditions then 
        return true
    end
    local ok = true
    if conditions.dType == 2 then
        local isAnd = true
        for i, condition in ipairs(conditions.conditions) do
            local conditionres = false
            if condition.dType == 2 then
                conditionres = self:CheckConditions(condition)
            else
                conditionres = self:CheckCondition(condition)
            end
            if isAnd then
                ok = (ok and conditionres)
            else
                ok = (ok or conditionres)
            end
            if condition.opType == 1 then
                isAnd = true
            else
                isAnd = false
            end
        end
    else
        ok = self:CheckCondition(conditions)
    end
    return ok
end

function RedPointProxy:CheckCondition(condition)
    local scount
    if values[condition.var.key] then -- 常量 货币道具
        scount = values[condition.var.key](condition.var.Hero, condition.var.value, condition.value2)
    else
        local key = condition.property or "value"
        scount = self._ServerVars[condition.var.key] and self._ServerVars[condition.var.key][key]
    end
    local v = tonumber(scount) or scount
    if not v then
        v = ""
    end
    local count = condition.count
    local opt = condition.opt
    --不等于  可以类型不同
    if opt ~= 5 and type(v) ~= type(count) then -- 服务端可能下发""空字符串 
        return false
    end
    if opt == 1 then
        return v >= count
    elseif opt == 2 then
        return v <= count
    elseif opt == 3 then
        return v < count
    elseif opt == 4 then
        return v > count
    elseif opt == 5 then 
        return v ~= count
    else
        return v == count
    end
end

function RedPointProxy:stringtoCondition(str, exData)
    local BindCurrency = exData and exData.BindCurrency
    local vars, operator, scount = self:ParseExpression(str)
    local condition = {}

    local opt = 0
    if operator == ">=" then
        opt = 1
    elseif operator == "<=" then
        opt = 2
    elseif operator == "<" then
        opt = 3
    elseif operator == ">" then
        opt = 4
    elseif operator == "!=" then 
        opt = 5
    end
    local count = tonumber(scount)
    if not count then
        if opt ~= 0 and opt ~= 5 then 
            opt = 0
        end
        count = scount
    end
    -- 操作符
    condition.opt = opt
    -- 值
    condition.count = count

    local function getRealVar(var)
        local varT = {}
        if tonumber(var) then --货币或道具
            varT.value = tonumber(var)
            varT.key = "ITEMINDEX"
            return varT
        end
        local key, value
        if sfind(var, "H%.") then
            if sfind(var, "%[(%d+)%]") then
                local key, value = smatch(var, "H%.(.+)%[(%d+)%]")
                varT.key = key
                varT.Hero = true
                varT.value = value
            else
                key = smatch(var, "H%.(.+)")
                varT.key = key
                varT.Hero = true
            end
        elseif sfind(var, "MONEY%((.+)%)") then--常量MONEY()特殊处理 服务端的变量 有可能是XXXX(xxx)
            value = smatch(var, "MONEY%((.+)%)")
            key = "MONEY"
            varT.key = key
            varT.value = value
        else
            if sfind(var, "%[(%d+)%]") then
                key, value = smatch(var, "(.+)%[(%d+)%]")
                varT.key = key
                varT.value = value
            else
                key = var
                varT.key = key
            end

        end
        return varT
    end
    condition.var = getRealVar(vars[1])--{key,Hero,value}
    condition.property = vars[2]--键值对
    condition.value2 = BindCurrency
    condition.dType = 1

    return condition
end

function RedPointProxy:_compareBracket(str)
    local offset = 1
    local strIdx = 2
    local len = string.len(str)
    local IDX = 1
    while 1 do
        IDX = IDX + 1
        local lIdx = sfind(str, "%[", strIdx) or len
        local rIdx = sfind(str, "%]", strIdx) or len
        if lIdx < rIdx then
            strIdx = lIdx + 1
            offset = offset + 1
        else
            strIdx = rIdx + 1
            offset = offset - 1
        end
        if offset == 0 then
            strIdx = strIdx - 1
            break
        end
        if strIdx > string.len(str) then
            print(">>>>>>>condition () not compare", str, IDX)
            return nil
        end
    end
    return strIdx
end

function RedPointProxy:ParseConditionStr(str, exData)
    if not str or str == "" then
        return nil
    end
    local conditions = {}
    local idx = 0
    while 1 do
        idx = idx + 1
        if str == "" or idx > 100 then
            break
        end
        local condition = nil
        local len = string.len(str)
        local andIdx = sfind(str, "&")
        local orIdx = sfind(str, "|")
        local splitIdx = math.min(andIdx or len + 1, orIdx or len + 1)
        local fchar = string.sub(str, 0, 1)
        if fchar == "[" then
            local rightBracketIdx = self:_compareBracket(str)
            if not rightBracketIdx then
                rightBracketIdx = string.len(str)
                print(">>Bracket compare error:", str)
                break
            end
            condition = self:ParseConditionStr(string.sub(str, 2, rightBracketIdx - 1), exData)
            conditions[idx] = condition
            local fchar = string.sub(str, rightBracketIdx + 1, rightBracketIdx + 1)
            str = string.sub(str, rightBracketIdx + 2)
            andIdx = sfind(fchar, "&")
            orIdx = sfind(fchar, "|")
        else
            local splitIdx = math.min(andIdx or len + 1, orIdx or len + 1)
            local conditionStr = string.sub(str, 1, splitIdx - 1)
            -- print("idx", andIdx, orIdx, len, str, conditionStr)
            condition = self:stringtoCondition(conditionStr, exData)
            conditions[idx] = condition
            str = string.sub(str, splitIdx + 1)
        end
        if condition then
            if andIdx and (not orIdx or orIdx > andIdx) then
                condition.opType = 1
            end
            if orIdx and (not andIdx or andIdx > orIdx) then
                condition.opType = 2
            end
        end
    end
    if #conditions == 0 then
        return nil
    end
    if #conditions == 1 then
        return conditions[1]
    end
    local data = {}
    data.dType = 2
    data.conditions = conditions
    data.originStr = str
    return data
end

function RedPointProxy:LoadConfig()
    local configs = requireGameConfig("cfg_redpoint")
    for k, v in pairs(configs) do
        self._configs[v.id] = v
        if v.group then
            self._groups[v.group] = self._groups[v.group] or {}
            table.insert(self._groups[v.group], v)
        end
    end
    for k, v in pairs(self._groups) do
        table.sort(v, function(a, b)
            return a.level < b.level
        end)
    end
end

function RedPointProxy:InstertCheckQue(Var)
    local List = self._valList[Var]
    if List then
        if self._needCheckItems[Var] then--这里需要更新需要检测的条件
            self:UpdateItems(Var)
        end
        for id, val in pairs(List) do
            if not self._needCheckIDs[id] then
                self._needCheckIDs[id] = true
                table.insert(self._needCheckIDsVec, id)
            end
        end
    end
    local BubbleProxy  = global.Facade:retrieveProxy(global.ProxyTable.BubbleProxy)
    if BubbleProxy then 
        BubbleProxy:InstertCheckQue(Var)
    end
end
-- Npc界面打开触发 添加红点
function RedPointProxy:onNpcLayerOpen()
    local add = function (npcLayerID)
        if not npcLayerID then
            return false
        end

        local idVec = {{id = npcLayerID}}
        local npcButtons = self._showIDTable.npcLayerIDs[npcLayerID]
        local btnIDs = npcButtons and npcButtons.btnIDs
        if not btnIDs then
            return false
        end

        for k, v in pairs(btnIDs) do
            if v.count and v.count > 0 then
                idVec[#idVec+1] = {id = k, offset = v.offset}
            end
        end

        local widgets = self:FindWidget(idVec)
        for i = 1, #widgets do
            local widget = widgets[i]
            self:addRedDot(widget, widget._Redoffset)
        end
    end

    local NPCLayerMediator = global.Facade:retrieveMediator("NPCLayerMediator")
    if NPCLayerMediator._layer and NPCLayerMediator._layer.background then
        add(NPCLayerMediator._layer.background.element.attr.layerid)
    end
end
-----------------官方其他界面触发 添加
function RedPointProxy:onOtherLayer(mainIDs)
    for i, mainID in ipairs(mainIDs) do
        local mainParam = self._showIDTable.mainIDs[tostring(mainID)]
        if mainParam and mainParam.count and mainParam.count > 0 then
            local mianBtns = mainParam.btnIDs
            local widgets
            for id, btn in pairs(mianBtns) do
                if btn.count and btn.count > 0 then  
                    widgets = self:FindWidget({ { id = mainID }, { id = id, offset = btn.offset } }, true)
                    if widgets[1] then 
                        self:addRedDot(widgets[1], btn.offset)
                    end
                end
            end
        end
    end
end
-- 背包界面加载成功 添加红点
function RedPointProxy:onBagLayerLoadSuccess()
    local mainIDs = {1,7} 
    self:onOtherLayer(mainIDs)
end
-----------------
----- 玩家界面加载成功 添加红点
function RedPointProxy:onPlayerFrameLoadSuccess()
    local mainIDs = {202} 
    self:onOtherLayer(mainIDs)
end
----- 玩家装备界面加载成功 添加红点
function RedPointProxy:onPlayerEquipLoadSuccess()
    local mainIDs = {2} 
    self:onOtherLayer(mainIDs)
end
-- 英雄背包界面加载成功 添加红点
function RedPointProxy:onHeroBagLayerLoadSuccess()
    local mainIDs = {3} 
    self:onOtherLayer(mainIDs)
end
-----------------
----- 英雄界面加载成功 添加红点
function RedPointProxy:onHeroFrameLoadSuccess()
    local mainIDs = {203} 
    self:onOtherLayer(mainIDs)
end
----- 英雄装备界面加载成功 添加红点
function RedPointProxy:onHeroEquipLoadSuccess()
    local mainIDs = {41} 
    self:onOtherLayer(mainIDs)
end
function RedPointProxy:onSUIComponentUpdate(data)
    local mainID = data.index
    if mainID >= 101 and mainID <= 110 then --暂时只支持101~110
        mainID = tostring(mainID)
        if self._showIDTable.mainIDs[mainID] and self._showIDTable.mainIDs[mainID].count and self._showIDTable.mainIDs[mainID].count > 0 then
            local MainButtons = self._showIDTable.mainIDs[mainID]
            if MainButtons and MainButtons.btnIDs then
                for k, v in pairs(MainButtons.btnIDs) do
                    if v.count and v.count > 0 then
                        local widgets = self:FindWidget({ { id = mainID, offset = v.offset }, { id = k, offset = v.offset } }, true)
                        for i, widget in ipairs(widgets) do
                            self:addRedDot(widget, widget._Redoffset)
                        end
                    end
                end

            end
        end
    end
end


-- 触发检测
function RedPointProxy:doSomeThing(Var)
    self:InstertCheckQue(Var)
end

function RedPointProxy:handle_MSG_SC_REDPOINTVARCHANGE(msg)
    local msgHdr = msg:GetHeader()
    local jsonData = ParseRawMsgToJson(msg)

    for i, v in ipairs(jsonData) do
        local key = string.upper(v.Var)
        
        local txtKey   = key
        local txtValue = v.Value

        local IsTable  = false

        sgsub(txtValue, "^{(.+)}$", function (s)
            local Tabs = {}
            sgsub(sgsub(s .. ",", ",,", ","), "(.-),", function ( s )
                Tabs[#Tabs+1] = string.trim(s)
            end)

            txtKey = sformat("<V_%s>", sgsub(txtKey, "%$", ""))
            txtValue = Tabs

            IsTable = true
        end)

        if not IsTable then
            sgsub(txtValue, "^%^(.+)%^$", function (s)
                local Tabs = {}
                sgsub(sgsub(s .. ",", ",,", ","), "(.-),", function ( s )
                    Tabs[#Tabs+1] = string.trim(s)
                end)

                txtKey = sformat("<T_%s>", sgsub(txtKey, "%$", ""))
                txtValue = Tabs
            end)
        end

        self._TXTServerVars[txtKey] = txtValue
        
        -- red point
        local var = {
            var = key, _originValue_ = v.Value
        }
        local value = v.Value

        if sfind(value, ",") then
            local exp = ssplit(value, ",")
            for i, v in ipairs(exp) do
                local property, res = smatch(v, "(.+)%s-=%s-(.+)")
                if property and res then
                    var[property] = tonumber(res) or res
                end
            end
        else
            var.value = tonumber(value) or value
            if sfind(value, "=") then
                local property, res = smatch(value, "(.+)%s-=%s-(.+)")
                if property and res then
                    var[property] = tonumber(res) or res
                end
            end
        end

        -- 解析后的值
        self._ServerVars[key] = var

        if self._idsWithVarItems[key] then
            -- ids更新删除老红点
            self:rmvRedByIdKey(key)

            -- ids更新+新红点
            self:addRedByIdKey(key)
        end

        if self._needCheckItems[key] then
            self:UpdateItems(key)
        end

        SL:onLUAEvent(LUA_EVENT_SERVER_VALUE_CHANGE,{key = key,value = v.Value})

        -- 插入检测队列
        self:InstertCheckQue(key)
    end
    global.Facade:sendNotification(global.NoticeTable.Server_Var_Change)
end

function RedPointProxy:TransValueByKey(key)
    local k1, v1 = self:ParseVar(key)
    if self._ServerVars[k1] and v1 and self._ServerVars[k1][v1] then
        return self._ServerVars[k1][v1]
    end
    return self._ServerVars[k1] and self._ServerVars[k1].value or ""
end

function RedPointProxy:getOriginValueByKey(key)
    key = string.upper(key)
    return self._ServerVars[key] and self._ServerVars[key]._originValue_ or ""
end

function RedPointProxy:getTXTValueByKey(key)
    return self._TXTServerVars[string.upper(key)]
end

function RedPointProxy:CheckRedPointID(id)
    if self._showIDTable and self._showIDTable.showIDs and self._showIDTable.showIDs[id] then 
        return true
    end
    return false
end

function RedPointProxy:RegisterMsgHandler()
    local msgType = global.MsgType
    LuaRegisterMsgHandler(msgType.MSG_SC_REDPOINTVARCHANGE, handler(self, self.handle_MSG_SC_REDPOINTVARCHANGE))    -- 变量变动
end

return RedPointProxy