local RemoteProxy = requireProxy("remote/RemoteProxy")
local GameSettingProxy = class("GameSettingProxy", RemoteProxy)
GameSettingProxy.NAME = global.ProxyTable.GameSettingProxy
local skillUtils = requireProxy("skillUtils")
local cjson = require("cjson")

GameSettingProxy.syncTable = {
    [16] = {key = "ZDLH", job = 3},     -- 自动烈火
    [35] = {key = "ZDZR", job = 3},     -- 自动逐日
    [53] = {key = "ZDKTZ", job = 3},    -- 自动开天斩
    [54] = {key = "ZDZR", job = 3},     -- 自动逐日
    [118] = {key = "ZDLYJF", job = 3},  -- 龙影剑法
    [119] = {key = "ZDLTJF", job = 3},  -- 雷霆剑法
    [120] = {key = "ZDZHJS", job = 3},  -- 纵横剑术
    [200] = {key = "ZDLJ"},             -- 自动连击
    
    [3011] = {key = "HERO_FOLLOW_ATTACK"},     -- 自动跟随主角攻击
    [3012] = {key = "HERO_ATTACK_DODGE"},     -- 英雄打怪躲避
    [41] = {key = "BB_FOLLOW_ATTACK"},    -- 宝宝自动跟随主角攻击
}

local discard = 
{
    [global.MMO.SETTING_IDX_FRAME_RATE_TYPE_HIGH] = 1
}

function GameSettingProxy:ctor()
    GameSettingProxy.super.ctor(self)
    
    self._data = {}
    self._config = {}

    self._pickConfig = {}--组配置
    self._pickData   = {}--拾取的设置
    self._pickHangUpData = {} -- 总开关数据

    self._itemConfig = {} --拾取相关的改为由服务器发 这个是默认选项

    self._innerChangedSize = false

    self._bossTipsData = {} --Boss提醒配置
    self._bossTipsDataKey = {}
    self._bossTypeData = {"BOSS","大BOSS","超级BOSS" } -- boss type

    self._RankData = {} --保护数据

    self._hideReportBtn = false   -- 是否隐藏举报按钮
end

function GameSettingProxy:LoadConfig()
    self._config = requireGameConfig("cfg_setup")
    self:readLocalData()

    -- pick config
    self._pickConfig = requireGameConfig("cfg_pick_set")

    local GameConfigMgrProxy = global.Facade:retrieveProxy(global.ProxyTable.GameConfigMgrProxy)
    local configKey = "cfg_serverItemCfg"
    local itemConfig = GameConfigMgrProxy:getConfigByKey(configKey)
    if not itemConfig then
        itemConfig = {}
    end
    self._itemConfig = itemConfig
end

function GameSettingProxy:OnPropertyInited()
    self:refSyncData()
    self:SyncDataToServer()
    self:readLocalPickData()
    self:readLocalGroupPickData()
    self:readLocalBossTipsData()
    self:readLocalBossTypeData()
    self:readLocalProtectData()
    self:initSomeSetting()
    global.Facade:sendNotification(global.NoticeTable.GameSettingInited)
end

function GameSettingProxy:OnReConnectInited()
    self:SyncDataToServer()
end

function GameSettingProxy:refSyncData()
    local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local configs = skillProxy:GetConfigs()
    for i,v in pairs(configs) do
        if v.MagicID > 1000 and (v.job == 0 or v.job == 3) and skillProxy:IsOnoffSkill(v.MagicID) then --自定义战士开关技能
            self.syncTable[10000+v.MagicID] = {key = "ZD"..v.MagicID, job =v.job}
        end
    end
end

function GameSettingProxy:SyncDataToServer()
    local PlayerProperty = global.Facade:retrieveProxy( global.ProxyTable.PlayerProperty )
    local roleJob = PlayerProperty:GetRoleJob()

    local jsonData = {}
    for k, v in pairs(self.syncTable) do
        if (not v.job) or (v.job == 3) or (roleJob == v.job) then
            table.insert(jsonData, {key = v.key, value = (CHECK_SETTING(k) == 1 and 1 or 0)})
        end
    end

    -- 掉落屏蔽 "1,2,3"
    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local list = ChatProxy:GetDropTypeShield()
    local dropShield = table.concat(list, ",")
    table.insert(jsonData, {key = "MSGFILTER", value = dropShield})
    SendTableToServer(global.MsgType.MSG_CS_GAME_SETTING_CHANGE, jsonData)
end

function GameSettingProxy:readLocalData()
    local LoginProxy    = global.Facade:retrieveProxy( global.ProxyTable.Login )
    local mainPlayerID  = LoginProxy:GetSelectedRoleID()
    local path     = "setting_UserData" .. mainPlayerID
    local key      = "setting"
    local userData = UserData:new(path)
    local jsonStr  = userData:getStringForKey(key, "")
    
    if not jsonStr or string.len(jsonStr) == 0 then
        return false
    end

    local jsonData = cjson.decode(jsonStr)
    if not jsonData then
        return false
    end

    -- 
    self._data = jsonData

    return true
end

function GameSettingProxy:saveLocalData()
    if not self._data then
        return false
    end
    local LoginProxy    = global.Facade:retrieveProxy( global.ProxyTable.Login )
    local mainPlayerID  = LoginProxy:GetSelectedRoleID()
    local path      = "setting_UserData" .. mainPlayerID
    local key       = "setting"
    local userData  = UserData:new(path)

    local writeData = {}
    for key, value in pairs(self._data) do
        if discard[tonumber(key)] ~= 1 then
            writeData[key] = value
        end
    end
    local jsonStr  = cjson.encode(writeData)
    userData:setStringForKey(key, jsonStr)
    return true
end

function GameSettingProxy:GetValue(id)
    id = tostring(id)

    local config = self:GetConfigByID(id)
    if not config then
        return {}
    end

    local platform = config and config.platform or nil
    if platform ~= 0 and platform ~= 99 and platform ~= global.OperatingMode then  --判断平台
        return {}
    end
    --挂机忽略怪物列表不走default
    if not self._data[id] and id ~= global.MMO.SETTING_IDX_IGNORE_MONSTER then
        return {config.default, config.default1, config.default2, config.default3} 
    end
    local data = self._data[id]
    return data 
end

function GameSettingProxy:SetValue(id, value)
    id = tostring(id)

    self._data[id] = self._data[id] or {}
    
    if type(value) == "table" then
        self._data[id] = value
    else
        local data = self._data[id]
        data[1]    = value
    end

    local numID = tonumber(id)
    if self.syncTable[numID] or self.syncTable[numID+10000] then
        self:SyncDataToServer()
    end

    self:saveLocalData()
end

function GameSettingProxy:GetConfigByID(id)
    id = tonumber(id)
    return self._config[id]
end

function GameSettingProxy:GetConfigByGroup(group)
    local config = {}
    for i, v in pairs(self._config) do
        if v.group == group and (v.platform == 0 or v.platform == global.OperatingMode) then
            table.insert(config, v)
        end
    end
    table.sort(config, function(a, b)
        return a.order and b.order and a.order < b.order
    end)
    return config
end


function GameSettingProxy:GetMainOptions()
    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local roleJob = PlayerProperty:GetRoleJob()

    local items = {}
    for i, v in pairs(self._config) do
        if v.mainpos and v.mainpos ~= "" and (v.platform == 0 or v.platform == global.OperatingMode) then
            local normalAndPress = string.split(v.mainpos, "&")
            local item = {}
            local has = false
            local filterJob = true
            if normalAndPress and normalAndPress[3] and normalAndPress[3] ~= "" then 
                local job  = tonumber(normalAndPress[3])
                if job and roleJob ~= job then 
                    filterJob = false
                end
            end
            --normal
            if normalAndPress and normalAndPress[1] and normalAndPress[1] ~= "" then 
                local slicesPos         = string.split(normalAndPress[1], "|")
                -- 移动1
                if not global.isWinPlayMode and slicesPos[1] and slicesPos[1] ~= "" then
                    local slicesPosM    = string.split(slicesPos[1], "#")
                    has             = true
                    item.id         = v.id
                    item.lid        = tonumber(slicesPosM[2]) or 0
                    item.x          = tonumber(slicesPosM[3]) or 0
                    item.y          = tonumber(slicesPosM[4]) or 0
                    item.brightPath = string.format("%s%s","private/new_setting/icon/",slicesPosM[1])
                end

                -- PC
                if global.isWinPlayMode and slicesPos[2] and slicesPos[2] ~= "" then
                    local slicesPosP    = string.split(slicesPos[2], "#")
                    has             = true
                    item.id         = v.id
                    item.lid        = tonumber(slicesPosP[2]) or 0
                    item.x          = tonumber(slicesPosP[3]) or 0
                    item.y          = tonumber(slicesPosP[4]) or 0
                    item.brightPath = string.format("%s%s","private/new_setting/icon/",slicesPosP[1])
                end
            end
            --press
            if normalAndPress and  normalAndPress[2] and normalAndPress[2] ~= "" then 
                local slicesPos         = string.split(normalAndPress[2], "|")
                -- 移动1
                if not global.isWinPlayMode and slicesPos[1] and slicesPos[1] ~= "" then
                    local slicesPosM    = string.split(slicesPos[1], "#")
                    has                 = true
                    item.id             = v.id
                    item.off_lid        = tonumber(slicesPosM[2]) or 0
                    item.off_x          = tonumber(slicesPosM[3]) or 0
                    item.off_y          = tonumber(slicesPosM[4]) or 0
                    item.normalPath = string.format("%s%s","private/new_setting/icon/",slicesPosM[1])
                end

                -- PC
                if global.isWinPlayMode and slicesPos[2] and slicesPos[2] ~= "" then
                    local slicesPosP    = string.split(slicesPos[2], "#")
                    has                 = true
                    item.id             = v.id
                    item.off_lid        = tonumber(slicesPosP[2]) or 0
                    item.off_x          = tonumber(slicesPosP[3]) or 0
                    item.off_y          = tonumber(slicesPosP[4]) or 0
                    item.normalPath = string.format("%s%s","private/new_setting/icon/",slicesPosP[1])
                end
            end
            if has and filterJob then 
                table.insert(items,item)
            end
        end
    end
    return items
end

--------------------------------------------------------
--boss提醒
function GameSettingProxy:readLocalBossTipsData()
    local mainPlayerID  = global.gamePlayerController:GetMainPlayerID()
    local path          = "setting_UserData" .. mainPlayerID
    local key           = "bossTips_setting"
    local userData      = UserData:new(path)
    local jsonStr       = userData:getStringForKey(key, "")
    
    if not jsonStr or string.len(jsonStr) == 0 then
        return false
    end

    local jsonData = cjson.decode(jsonStr)
    if not jsonData then
        return false
    end
    self._bossTipsSetting = true
    self._bossTipsData = jsonData
    for i,v in ipairs(self._bossTipsData) do
        self._bossTipsDataKey[v[1]] = v
    end
    return true
end
function GameSettingProxy:saveLocalBossTipsData()
    -- 延迟存储,防卡顿
    if self._bossTipStorageTimer then
        UnSchedule(self._bossTipStorageTimer)
        self._bossTipStorageTimer = nil
    end
    self._bossTipStorageTimer = PerformWithDelayGlobal(function()
        self._bossTipStorageTimer = nil

        local mainPlayerID  = global.gamePlayerController:GetMainPlayerID()
        local path          = "setting_UserData" .. mainPlayerID
        local key           = "bossTips_setting"
        local userData      = UserData:new(path)
        local jsonStr       = cjson.encode(self._bossTipsData)
        userData:setStringForKey(key, jsonStr)
    end, 0.01)

    return true
end
function GameSettingProxy:readLocalBossTypeData()
    local mainPlayerID  = global.gamePlayerController:GetMainPlayerID()
    local path          = "setting_UserData" .. mainPlayerID
    local key           = "bossType_setting"
    local userData      = UserData:new(path)
    local jsonStr       = userData:getStringForKey(key, "")
    
    if not jsonStr or string.len(jsonStr) == 0 then
        return false
    end

    local jsonData = cjson.decode(jsonStr)
    if not jsonData then
        return false
    end

    self._bossTypeData = jsonData

    return true
end
function GameSettingProxy:saveLocalBossTypeData()
    -- 延迟存储,防卡顿
    if self._bossTypeStorageTimer then
        UnSchedule(self._bossTypeStorageTimer)
        self._bossTypeStorageTimer = nil
    end
    self._bossTypeStorageTimer = PerformWithDelayGlobal(function()
        self._bossTypeStorageTimer = nil

        local mainPlayerID  = global.gamePlayerController:GetMainPlayerID()
        local path          = "setting_UserData" .. mainPlayerID
        local key           = "bossType_setting"
        local userData      = UserData:new(path)
        local jsonStr       = cjson.encode(self._bossTypeData)
        userData:setStringForKey(key, jsonStr)
    end, 0.01)

    return true
end

function GameSettingProxy:GetBossTipsValues()
    return self._bossTipsData
end
function GameSettingProxy:SetBossTipsValues(values)
    self._bossTipsData = values
    for i,v in ipairs(self._bossTipsData) do
        self._bossTipsDataKey[v[1]] = v
    end
    self:saveLocalBossTipsData()
end
function GameSettingProxy:GetBossType()
    return self._bossTypeData
end
function GameSettingProxy:SetBossType(values)
    self._bossTypeData = values
    self:saveLocalBossTypeData()
end
function GameSettingProxy:getNeedTipsMonsterData(name)
    return self._bossTipsDataKey[name]
end
function CHECK_SETTING_BOSSTIPS(name)
    if not name then 
        return 
    end
    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    return GameSettingProxy:getNeedTipsMonsterData(name)
end
--------------------------------------------------------
--- 手动拾取
--------------------------------------------------------
function GameSettingProxy:readLocalPickData()
    local mainPlayerID  = global.gamePlayerController:GetMainPlayerID()
    local path          = "setting_UserData" .. mainPlayerID
    local key           = "pick_setting"
    local userData      = UserData:new(path)
    local jsonStr       = userData:getStringForKey(key, "")
    
    if not jsonStr or string.len(jsonStr) == 0 then
        return false
    end

    local jsonData = cjson.decode(jsonStr)
    if not jsonData then
        return false
    end

    -- 
    self._pickData = jsonData

    return true
end

function GameSettingProxy:saveLocalPickData()
    -- 延迟存储,防卡顿
    if self._pickStorageTimer then
        UnSchedule(self._pickStorageTimer)
        self._pickStorageTimer = nil
    end
    self._pickStorageTimer = PerformWithDelayGlobal(function()
        self._pickStorageTimer = nil

        local mainPlayerID  = global.gamePlayerController:GetMainPlayerID()
        local path          = "setting_UserData" .. mainPlayerID
        local key           = "pick_setting"
        local userData      = UserData:new(path)
        local jsonStr       = cjson.encode(self._pickData)
        userData:setStringForKey(key, jsonStr)
    end, 0.01)

    return true
end
function GameSettingProxy:readLocalGroupPickData()
    local mainPlayerID  = global.gamePlayerController:GetMainPlayerID()
    local path          = "setting_UserData" .. mainPlayerID
    local key           = "grouppick_setting"
    local userData      = UserData:new(path)
    local jsonStr       = userData:getStringForKey(key, "")
    
    if not jsonStr or string.len(jsonStr) == 0 then
        return false
    end

    local jsonData = cjson.decode(jsonStr)
    if not jsonData then
        return false
    end

    -- 
    self._pickHangUpData = jsonData

    return true
end

function GameSettingProxy:saveLocalGroupPickData()
    -- 延迟存储,防卡顿
    if self._pickGroupStorageTimer then
        UnSchedule(self._pickGroupStorageTimer)
        self._pickGroupStorageTimer = nil
    end
    self._pickGroupStorageTimer = PerformWithDelayGlobal(function()
        self._pickGroupStorageTimer = nil

        local mainPlayerID  = global.gamePlayerController:GetMainPlayerID()
        local path          = "setting_UserData" .. mainPlayerID
        local key           = "grouppick_setting"
        local userData      = UserData:new(path)
        local jsonStr       = cjson.encode(self._pickHangUpData)
        userData:setStringForKey(key, jsonStr)
    end, 0.01)

    return true
end
------------------
function GameSettingProxy:GetPickConfig()
    return self._pickConfig
end
function GameSettingProxy:GetPickGroupValue(id)--拾取组设置
    id = tostring(id)
    --掉落显示#手动拾取#挂机捡取
    local set = self._pickHangUpData[id] or {1,1,1}
    return set
end
function GameSettingProxy:GetPickValue(id)--拾取设置
    id = tostring(id)
    --组类别#掉落显示#手动拾取#挂机捡取
    local set = {}
    if not self._pickData[id] then
        local find = false
        for i,v in ipairs(self._itemConfig) do--服务器的为默认配置 道具表控制是否可以 设置
            if v.Index == tonumber(id) then
                find = true
                set =  {v.ShowName or 1,v.AutoPick or 1 ,v.HideMode or 1}
                break
            end
        end
        if not find then
            set =  {1,1,1}
        end
    else
        set = clone(self._pickData[id])
    end
    
    set[1] = set[1]  or 1
    set[2] = set[2]  or 1
    set[3] = set[3]  or 1
    local config  = self:GetPickCanSet(id)--不能勾选的当不能拾取
    for i,v in ipairs(config) do
        if v == 0 then
            set[i] = 0
        end
    end
    
    return set
end
function GameSettingProxy:GetPickCanSet(id)--道具表 配置能否勾选
    id = tostring(id)
    --组类别#掉落显示#手动拾取#挂机捡取
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local itemConfig = ItemConfigProxy:GetItemDataByIndex(tonumber(id))
    if itemConfig.pickset and string.len(itemConfig.pickset) > 0 then--先读道具表
        local slices = string.split(tostring(itemConfig.pickset), "#")
        local value  = {tonumber(slices[2]) or 0, tonumber(slices[3]) or 0, tonumber(slices[4]) or 0}
        return value
    end
    return {1,1,1}
end
function GameSettingProxy:GetGroupIdByIndex(Index)
    local id = tonumber(Index)
    --组类别#掉落显示#手动拾取#挂机捡取
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local itemConfig = ItemConfigProxy:GetItemDataByIndex(id)
    if itemConfig and itemConfig.pickset and string.len(itemConfig.pickset) > 0 then--先读道具表
        local slices = string.split(tostring(itemConfig.pickset), "#")
        return slices[1]
    end
    return nil
end
function GameSettingProxy:SetPickValue(id, value)
    id = tostring(id)

    self._pickData[id] = value

    self:saveLocalPickData()
end
function GameSettingProxy:SetPickGroupValue(id, value)
    id = tostring(id)

    self._pickHangUpData[id] = value

    self:saveLocalGroupPickData()
end
function GameSettingProxy:readLocalProtectData()
    local mainPlayerID  = global.gamePlayerController:GetMainPlayerID()
    local path          = "setting_UserData" .. mainPlayerID
    local key           = "RankData_setting"
    local userData      = UserData:new(path)
    local jsonStr       = userData:getStringForKey(key, "")
    
    if not jsonStr or string.len(jsonStr) == 0 then
        return false
    end

    local jsonData = cjson.decode(jsonStr)
    if not jsonData then
        return false
    end

    self._RankData = jsonData
    return true
end

function GameSettingProxy:saveLocalProtectData()
    -- 延迟存储,防卡顿
    if self._protectDataStorageTimer then
        UnSchedule(self._protectDataStorageTimer)
        self._protectDataStorageTimer = nil
    end
    self._protectDataStorageTimer = PerformWithDelayGlobal(function()
        self._protectDataStorageTimer = nil

        local mainPlayerID  = global.gamePlayerController:GetMainPlayerID()
        local path          = "setting_UserData" .. mainPlayerID
        local key           = "RankData_setting"
        local userData      = UserData:new(path)
        local jsonStr       = cjson.encode(self._RankData)
        userData:setStringForKey(key, jsonStr)
    end, 0.01)

    return true
end

--某些排序的设置 
function GameSettingProxy:getRankData(id)
    if not id then 
        return {}
    end
    id = tostring(id)
    local config = self:GetConfigByID(id)
    if not config then
        return {indexs = {} ,time = 1000,oriStr = ""}
    end
    if self._RankData[id] then
        local oriStr = self._RankData[id].oriStr
        local indexs = config.indexs
        if indexs and indexs ~= ""  and  oriStr ~= indexs then --发现之前的配置跟现在不一样  清除之前的排序数据
            self:setRankData(id,{indexs = {} ,time = 1000,oriStr = config.indexs})
        else
            return self._RankData[id]
        end
    end
    
    if not config.indexs then 
        config.indexs = ""
    end 
    if not config.time then 
        config.time = 1000
    end
    self._RankData[id] = {indexs = {} ,time = 1000,oriStr = config.indexs}
    self._RankData[id].time = config.default2 or config.time
    if id == tostring(global.MMO.SETTING_IDX_AUTO_GROUPSKILL) or id == tostring(global.MMO.SETTING_IDX_AUTO_SIMPSKILL) then  
    else
        local indexs =  string.split(config.indexs,"#")
        for i,index in ipairs(indexs) do
            table.insert(self._RankData[id].indexs, tonumber(index))
        end
    end
    return self._RankData[id]

end
function GameSettingProxy:setRankData(id,value)
    id = tostring(id)

    self._RankData[id] = value

    self:saveLocalProtectData()
end

function GameSettingProxy:initSomeSetting()
    --global.MMO.SETTING_IDX_IGNORE_MONSTER --忽略怪物 
    local value   = GET_SETTING(global.MMO.SETTING_IDX_IGNORE_MONSTER)
    if not (value and (type(value) == "table")) then 
        local config = self:GetConfigByID(global.MMO.SETTING_IDX_IGNORE_MONSTER) 
        if config and config.names then 
            local names = string.split(config.names,"#")
            local t = {}
            for i,name in ipairs(names) do
                t[name] = 1
            end
            CHANGE_SETTING(global.MMO.SETTING_IDX_IGNORE_MONSTER, {t})
        end
    end

    --global.MMO.SETTING_IDX_BOSS_TIPS --boss提醒 
    local values   = self:GetBossTipsValues()
    if not (values and #values>0 ) and not self._bossTipsSetting then 
        local config = self:GetConfigByID(global.MMO.SETTING_IDX_BOSS_TIPS) 
        if config and config.names then 
            local names = string.split(config.names,"#")
            local t = {}
            for i,name in ipairs(names) do
                table.insert(t,{name,1,"BOSS"})
            end
            self:SetBossTipsValues(t)
        end
    end
    local protect = 
    {    
        --人物   
        global.MMO.SETTING_IDX_HP_PROTECT1          , -- hp保护1
        global.MMO.SETTING_IDX_HP_PROTECT2          , -- hp保护2
        global.MMO.SETTING_IDX_HP_PROTECT3          , -- hp保护3
        global.MMO.SETTING_IDX_HP_PROTECT4          , -- hp保护4
        global.MMO.SETTING_IDX_MP_PROTECT1          , -- mp保护1
        global.MMO.SETTING_IDX_MP_PROTECT2          , -- mp保护2
        global.MMO.SETTING_IDX_MP_PROTECT3          , -- mp保护3
        global.MMO.SETTING_IDX_MP_PROTECT4          , -- mp保护4
        --hero
        global.MMO.SETTING_IDX_HERO_HP_PROTECT1     , -- hp保护1
        global.MMO.SETTING_IDX_HERO_HP_PROTECT2     , -- hp保护2
        global.MMO.SETTING_IDX_HERO_HP_PROTECT3     , -- hp保护3
        global.MMO.SETTING_IDX_HERO_HP_PROTECT4     , -- hp保护4
        global.MMO.SETTING_IDX_HERO_MP_PROTECT1     , -- mp保护1
        global.MMO.SETTING_IDX_HERO_MP_PROTECT2     , -- mp保护2
        global.MMO.SETTING_IDX_HERO_MP_PROTECT3     , -- mp保护3
        global.MMO.SETTING_IDX_HERO_MP_PROTECT4     , -- mp保护4
        --红名保护
        global.MMO.SETTING_IDX_PK_PROTECT           , --红名保护
    }
    for i,id in ipairs(protect) do
        local values = self:getRankData(id)
        local config =  self:GetConfigByID(id)
        local minTime = config and config.time or 1000
        if values and values.time and values.time < minTime then 
            values.time = minTime
        end
        self:setRankData(id,values)
    end
end

-- 判断是否可挂机拾取
-- function GameSettingProxy:IsAutoPick(id)
--     id = tostring(id)
--     local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
--     local itemConfig = ItemConfigProxy:GetItemDataByIndex(tonumber(id))
--      local slices = string.split(tostring(itemConfig.pickset), "#")
--      if slices[1] and  self._pickHangUpData[slices[1]] and self._pickHangUpData[ slices[1]][3] == 1 then --外面的总开关要开着才能设置有效
--         return CHECK_ITEM_AUTO_PICK(id)
--      end
--     return false
-- end

function CHECK_GROUPSETTING_PICK(id)
    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    return GameSettingProxy:GetPickGroupValue(id)
end

function CHANGE_GROUPSETTING_PICK(id, value)
    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    GameSettingProxy:SetPickGroupValue(id, value)
end
function CHECK_SETTING_PICK(id)
    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    return GameSettingProxy:GetPickValue(id)
end

function CHANGE_SETTING_PICK(id, value)
    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    GameSettingProxy:SetPickValue(id, value)

    global.Facade:sendNotification(global.NoticeTable.GamePickSettingChange)
end
--检测掉落物显示
function CHECK_ITEM_DROP_SHOW(id)
    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    local value = GameSettingProxy:GetPickValue(id)
    local groupid = GameSettingProxy:GetGroupIdByIndex(id)
    local groupOK = true
    if groupid then
        local groupvalue = GameSettingProxy:GetPickGroupValue(groupid)
        groupOK =  groupvalue[1] == 1
    end 
    return value[1] == 1 and groupOK
end

-- 检测手动拾取
function CHECK_ITEM_PICK(id)
    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    local value = GameSettingProxy:GetPickValue(id)
    local groupid = GameSettingProxy:GetGroupIdByIndex(id)
    local groupOK = true
    if groupid then
        local groupvalue = GameSettingProxy:GetPickGroupValue(groupid)
        groupOK =  groupvalue[2] == 1
    end 
    return value[2] == 1 and groupOK
end
-- 检测自动拾取
function CHECK_ITEM_AUTO_PICK(id)
    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    local value = GameSettingProxy:GetPickValue(id)
    local groupid = GameSettingProxy:GetGroupIdByIndex(id)
    local groupOK = true
    if groupid then
        local groupvalue = GameSettingProxy:GetPickGroupValue(groupid)
        groupOK =  groupvalue[3] == 1
    end 
    return value[3] == 1 and  groupOK
end
function CHECK_ITEM_PICK_CANSET(id)
    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    local value = GameSettingProxy:GetPickCanSet(id)
    return value
end
--------------------------------------------------------
--- 手动拾取
--------------------------------------------------------

function GameSettingProxy:ResponseSettingChange(msg)
end

function GameSettingProxy:RegisterMsgHandler()
    GameSettingProxy.super.RegisterMsgHandler(self)
    
    local msgType = global.MsgType
end

function CHECK_SETTING(id)
    local data   = GET_SETTING(id)
    local enable = data[1]
    return enable
end

function GET_SETTING(id)
    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    return GameSettingProxy:GetValue(id)
end
function CHANGE_SETTING(id, values)
    local data = GET_SETTING(id)
    for i=1,4 do
        if data and data[i] then
            values[i] = values[i] or data[i]
        end
    end
    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    GameSettingProxy:SetValue(id, values)

    global.Facade:sendNotification(global.NoticeTable.GameSettingChange, {id = id, value = values})

    SLBridge:onLUAEvent(LUA_EVENT_SETTING_CAHNGE, {id = id, values = values})
end

------------------------------------------------------
--- 内部改动尺寸标识
function GameSettingProxy:IsInnerChangedSize()
    return self._innerChangedSize
end

function GameSettingProxy:SetInnerChangedSize(boolean)
    self._innerChangedSize = boolean
end

function GameSettingProxy:RequestNotifySizeChange(width, height)
    if not width or not height then
        return
    end
    LuaSendMsg(global.MsgType.MSG_CS_MODIFY_RESOLUTION, width, height)
end

------------------------------------------------------
--- 举报
function GameSettingProxy:IsHideReportBtn( ... )
    return self._hideReportBtn
end

function GameSettingProxy:SetHideReportBtn(state)
    self._hideReportBtn = state
end

return GameSettingProxy
