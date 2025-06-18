SL = {}

require("GUI/SLReqMessage")

local tconcat = table.concat
local tinsert = table.insert
local tkeys = table.keys
local tsort = table.sort
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next
local sfind = string.find
local ssub = string.sub
local slen = string.len
local sbyte = string.byte
local sgsub = string.gsub
local sformat = string.format
local supper = string.upper
local cjson = require("cjson")
local skillUtils = requireProxy("skillUtils")
local proxyUtils = requireProxy("proxyUtils")
local invalidStr = { "%", "(", ")", "_", "lib", "function", "then", "end", "_G", "return", "index", "set" }

SL._DEBUG = global.isWindows and (global.isDebugMode or global.isGMMode)

SL.FormParam = {}
SL.LocalStringCache = {}        -- 将要存储的数据缓存
SL.LocalStringTimerID = nil     -- 存储数据定时器

SL.DigitChangeTimerID = nil     -- 数字滚动定时器

SL.Triggers = {}                -- 触发

SL.CustomMapEffects = {}        --添加地图特效数据

SL.OpenGUITXTEditor = false

---------------------------------------------------------------------------
local function deprecatedTip(old_name, new_name)
    SL:Print("\n********** \n"..old_name.." was deprecated please use ".. new_name .. " instead.\n**********")
end


---------------------------------------------------------------------------
-- 基础函数
function SL:release_print(...)
    release_print(...)
end

function SL:Print(...)
    if not SL._DEBUG then
        return nil
    end
    SL:release_print(...)
end

function SL:PrintEx(...)
    if not SL._DEBUG then
        return nil
    end
    SL:release_print(...)
    SL:release_print(debug.traceback())
end

local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

function SL:dump(value, desciption, nesting)
    if not SL._DEBUG then
        return nil
    end

    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    local traceback = string.split(debug.traceback("", 2), "\n")
    SL:Print("dump from: " .. string.trim(traceback[3]))

    local function dump_(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
        end
        if type(value) ~= "table" then
            result[#result + 1] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result + 1] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result + 1] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
            else
                result[#result + 1] = string.format("%s%s = {", indent, dump_value_(desciption))
                local indent2 = indent .. "    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                tsort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result + 1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, desciption, "- ", 1)

    for i, line in ipairs(result) do
        SL:Print(line)
    end
end

function SL:PrintTraceback()
    local traceback = string.split(debug.traceback("", 2), "\n")
    SL:PrintTable(traceback)
end

SL.print = SL.Print
SL.printEx = SL.PrintEx
SL.Dump = SL.dump
SL.PrintTable = SL.dump


local function CheckJsonInvalid(jsonStr)
    for i, v in ipairs(invalidStr) do
        local v2 = i < 4 and "%" .. v or v
        if string.find(jsonStr, v2) then
            SL:release_print(string.format("Jeson Error: Invalid character '%s'", v))
            return false
        end
    end
    return true
end

-- json字符串解密
-- params: json string
-- return: json table
function SL:JsonDecode(jsonStr, ischeck)
    if ischeck then
        if CheckJsonInvalid(jsonStr) then
            return cjson.decode(jsonStr)
        end
    else
        return cjson.decode(jsonStr)
    end
end

-- json字符串加密
-- params: json table
-- return: json string
function SL:JsonEncode(jsonData, ischeck)
    if ischeck then
        local jData = cjson.encode(jsonData)
        if CheckJsonInvalid(jData) then
            return jData
        end
    else
        return cjson.encode(jsonData)
    end
end

-- 文件路径是否存在
function SL:IsFileExist(path)
    return global.FileUtilCtl:isFileExist(path)
end

-- 深拷贝
function SL:CopyData(data)
    return clone(data)
end

function SL:Split(input, delimiter)
    return string.split(input, delimiter)
end

-- 注册游戏事件回调
-- params: string, string, function
-- return: nil
function SL:RegisterLUAEvent(eventID, eventTag, eventCB, widget)
    if not eventID then
        SL:Print("[GUI ERROR] SL:RegisterLUAEvent, eventID is null", eventID, eventTag, eventCB)
        return
    end
    if not eventTag then
        SL:Print("[GUI ERROR] SL:RegisterLUAEvent, eventTag is null", eventID, eventTag, eventCB)
        return
    end
    if not eventCB then
        SL:Print("[GUI ERROR] SL:RegisterLUAEvent, eventCB is null", eventID, eventTag, eventCB)
        return
    end
    SLBridge.LUAEvent[eventID] = SLBridge.LUAEvent[eventID] or {}
    SLBridge.LUAEvent[eventID][eventTag] = eventCB

    if widget then
        GUI:Win_BindLuaEvent(widget, eventID, eventTag)
    end
end

-- 注销游戏事件回调
-- params: string, string, function
-- return: nil
function SL:UnRegisterLUAEvent(eventID, eventTag)
    if not eventID then
        SL:Print("[GUI ERROR] SL:UnRegisterLUAEvent, eventID is null", eventID, eventTag)
        return
    end
    if not eventTag then
        SL:Print("[GUI ERROR] SL:UnRegisterLUAEvent, eventTag is null", eventID, eventTag)
        return
    end
    if not SLBridge.LUAEvent[eventID] then
        SL:Print("[GUI ERROR] SL:UnRegisterLUAEvent, can't registered", eventID)
        return
    end
    SLBridge.LUAEvent[eventID][eventTag] = nil
end

function SL:onLUAEvent(name, data)
    SLBridge:onLUAEvent(name, data)
end

function SL:SendNetMsg(msgID, p1, p2, p3, sendData)
    SL.NetworkUtil:SendMsg(msgID, sendData, p1, p2, p3)
end

function SL:RegisterNetMsg(msgID, netCB, widget)
    SL.NetworkUtil:RegisterNetworkHandler(msgID, netCB)
    if widget then
        GUI:Win_BindNetMsgEvent(widget, msgID)
    end
end

function SL:UnRegisterNetMsg(msgID)
    SL.NetworkUtil:UnRegisterNetworkHandler(msgID)
end

function SL:SendLuaNetMsg(msgID, p1, p2, p3, sendData)
    SL.NetworkUtil:SendLuaMsg(msgID, p1, p2, p3, sendData)
end

function SL:RegisterLuaNetMsg(msgID, netCB, widget)
    SL.NetworkUtil:RegisterLuaNetworkHandler(msgID, netCB)
    if widget then
        GUI:Win_BindLuaNetMsgEvent(widget, msgID)
    end
end

function SL:UnRegisterLuaNetMsg(msgID)
    SL.NetworkUtil:UnRegisterLuaNetworkHandler(msgID)
end

-- 注册触发
function SL:RegisterTrigger(eventName, eventCB)
    SL.Triggers[eventName] = eventCB
end

-- 注销
function SL:UnRegisterTrigger(eventName)
    SL.Triggers[eventName] = nil
end

-- 转换颜色，从16进制字符转为{r, g, b}
function SL:ConvertColorFromHexString(hexString)
    return GetColorFromHexString(hexString)
end

-- 提示
function SL:ShowSystemTips(str)
    ShowSystemTips(str)
end

-- 开启一个定时器
-- params: function, number
-- return: int
function SL:Schedule(callback, interval)
    return cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, interval, false)
end

-- 开启一个定时器  时间戳  时间戳不支持毫秒级的定时器
function SL:ScheduleTimeSec(callback, interval)
    local oldTime = GetServerTime()
    return cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        if GetServerTime() - oldTime >= interval then
            oldTime = GetServerTime()
            if callback then
                callback()
            end
        end
    end, 1/60, false)
end

-- 开启一个单次定时器
-- params: function, number
-- return: int
function SL:ScheduleOnce(listener, time)
    return PerformWithDelayGlobal(listener, time)
end

-- 停止一个定时器
-- params: int
function SL:UnSchedule(scheduleID)
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
end

-- 开启一个定时器, 绑定node
-- params: function, number
-- return: int
function SL:schedule(node, callback, delay)
    return schedule(node, callback, delay)
end

-- 开启一个单次定时器
-- params: int
function SL:scheduleOnce(node, callback, delay)
    return performWithDelay(node, callback, delay)
end

--哈希表转成按数组
function SL:HashToSortArray(hashTab, sortFunc)
    return HashToSortArray(hashTab, sortFunc)
end

--显示提示文本
function SL:SHOW_DESCTIP(str, width, worldPos, anchorPoint, swallowType)
    SHOW_DESCTIP(str, width, worldPos, anchorPoint, swallowType)
end

-- 加载文件
function SL:Require(file, reload)
    if reload then
        package.loaded[file] = nil
    end
    return require(file)
end

-- 加载文件
function SL:RequireFile(file)
    if SL._DEBUG then
        package.loaded[file] = nil
    end
    return require(file)
end

-- 指定分隔符拆解一个文件
function SL:LoadTxtFile(path, delimiter, callBack)
    if nil == path or nil == callBack then
        print("LoadText error")
        return
    end

    if not global.FileUtilCtl:isFileExist(path) then
        release_print("LoadTxtFile path is not exist !!!")
        return 
    end

    local strBuffer = global.FileUtilCtl:getDataFromFileEx(path)
    strBuffer = sgsub(strBuffer, "\r", "")
    local lineBreak = "\n"

    local lines = string.split(strBuffer, lineBreak)
    local len = 0
    local pos1 = nil
    for k, v in pairs(lines) do
        len = slen(v)
        if len > 0 then
            pos1, _ = sfind(v, "//")
            if not pos1 then -- skip //
                local dataTable
                if delimiter == nil or delimiter == "" or delimiter == "\n" then -- ignore "" \n
                    dataTable = {}
                    dataTable[1] = v
                else
                    dataTable = string.split(v, delimiter)
                end

                callBack(dataTable)
            end
        end
    end
end


-- 基础函数
---------------------------------------------------------------------------
-- 数字转换成万、亿单位
function SL:GetSimpleNumber(n, places)
    local places = places and "%."..places.."f" or "%.2f"
    if n >= 100000000 then
        return string.format(places.."%s", n / 100000000, GET_STRING(1045))
    end
    if n >= 100000 then
        return string.format("%d%s", n / 10000, GET_STRING(1005))
    end
    if n >= 10000 then
        return string.format(places.."%s", n / 10000, GET_STRING(1005))
    end
    return tostring(n)
end

-- 血量单位 过十亿(单位：E)   10w-99999w(单位：W）
function SL:HPUnit(hp, pointBit, notCheckSet)
    local hpNum = tonumber(hp) or 0
    if hpNum < 0 then
        return hpNum
    end

    if notCheckSet then
        return hpNum
    elseif CHECK_SETTING(global.MMO.SETTING_IDX_HP_UNIT) ~= 1 then
        return hpNum
    end

    -- 小数点后几位  默认保留后两位
    pointBit = pointBit or 2

    local unitFunc = function(num)
        if pointBit == 0 then
            return math.floor(num)
        end
        local iNum, fNum = math.modf(num)
        local fDecimal = math.pow(10, tostring(pointBit))
        local newFNum = math.floor(tostring(fNum * fDecimal))
        local newINum = iNum + (newFNum / fDecimal)
        return newINum
    end

    if hpNum >= 1000000000 then
        hp = unitFunc(hpNum / 100000000) .. GET_STRING(310000600)
    elseif hpNum >= 100000 and hpNum <= 999999999 then
        hp = unitFunc(hpNum / 10000) .. GET_STRING(310000601)
    end

    return hp
end

-- 中文转换成竖着显示
function SL:ChineseToVertical(str)
    return ChineseToVertical(str)
end

-- 获取字符串的byte长度
function SL:GetUTF8ByteLen(str)
    local function chsize(char)
        if not char then
            print("not char")
            return 0
        elseif char > 240 then
            return 4
        elseif char > 225 then
            return 3
        elseif char > 192 then
            return 2
        else
            return 1
        end
    end
    local len = 0
    local chineseLen = 0
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        local charS = chsize(char)
        currentIndex = currentIndex + charS
        len = len + charS
        if charS >= 3 then
            chineseLen = chineseLen + 1
        end
    end
    return len, chineseLen
end

-- 时间格式化成字符串显示
function SL:TimeFormatToStr(time)
    return TimeFormatToString(time)
end

function SL:SecondToHMS(sec, isToStr, isSimple)
    local d = math.floor(sec / 86400)
    local h = math.fmod(math.floor(sec / 3600), 24)
    local m = math.fmod(math.floor(sec / 60), 60)
    local s = math.fmod(sec, 60)
    local time = {}
    time.d = d
    time.h = h
    time.m = m
    time.s = s
    if type(isToStr) == "boolean" and isToStr == true then
        if time.d > 0 then
            if isSimple then
                return sformat("%d天%d时", time.d, time.h)
            else
                return sformat("%d天%d时%d分%d秒", time.d, time.h, time.m, time.s)
            end
        else
            if time.h > 0 then
                if isSimple then
                    return sformat("%d时%d分", time.h, time.m)
                else
                    return sformat("%d时%d分%d秒", time.h, time.m, time.s)
                end
            else
                if time.m > 0 then
                    return sformat("%d分%d秒", time.m, time.s)
                else
                    return sformat("%d秒", time.s)
                end
            end
        end
    else
        return time
    end
end

-- 数字转化为千分位字符串
function SL:GetThousandSepString(num)
    local formatted = ""
    if tonumber(num) then
        formatted = tostring(num)
    end
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- 阿拉伯数字转中文大写
function SL:NumberToChinese(szNum)
    return NumberToChinese(szNum)
end

local function writefile(str, filePath)
    local path = global.FileUtilCtl:getSuitableFOpen(filePath) -- io.open 读写不能是UTF-8
    local file = io.open(path, "w+")
    if file then 
        print("open file success...", path)
        local tbl = string.split(str, "\n")
        for i = 1, #tbl do
            tbl[i] = sgsub(tbl[i], "!@2@!", "\\n")
            file:write(tbl[i] .. "\n")
        end
        print("write file complete...", string.len(str))
        file:close()
    else 
        print("open file error...", path)
    end 
end

local function dealSpecialStr(str)
    str = sgsub(str, '\\', '\\\\')
    str = sgsub(str, '"([^"]*)"', '!@1@!%1!@1@!')
    str = sgsub(str, '"([^"]*)"', '%1')
    str = sgsub(str, '!@1@!', '\\\"')
    return str
end

-- serialize table to str
local function serialize(t, sortfunc, quotKey)
    if next(t) == nil then
        local serStr =  "{" .. "\n" .. "}"
        return "local config = " .. serStr .. "\nreturn config"
    end

    local function ser_table(tbl, deep)
        local tmp = {}
        local sortList = tkeys(tbl)
        for _, k in ipairs(sortList) do
            local v = tbl[k]

            if type(v) == "table" then     
                deep = deep + 1

                local key = type(k) == "number" and "[" .. k .. "]" or (quotKey and '["' .. k .. '"]' or k)
                local space = srep(" ", deep * 4)
                tinsert(tmp, "\n" .. space .. key .. " = " .. ser_table(v, deep))
                
                deep = deep - 1
            else
                local key2 = type(k) == "number" and "[" .. k .. "]" or k
                local space = "\n" .. srep(" ", (deep + 1) * 4)
                if type(v) == "string" then
                    if sfind(v, "\n") then
                        v = sgsub(v, "\n", "!@2@!")
                    end
                    v = dealSpecialStr(v)
                    tinsert(tmp, space .. key2 .. '="' .. v .. '"')
                else
                    tinsert(tmp, space .. key2 .. "=" .. tostring(v))
                end
            end                
        end

        local concatStr = ""
        for index, value in ipairs(tmp) do
            concatStr = concatStr .. value .. ","
        end

        return "{" .. concatStr .. "\n" .. srep(" ", deep * 4) .. "}"
    end

    local sortT = tkeys(t)
    tsort(sortT)

    local finalStr = "local config = {\n"
    local cnt = #sortT

    for index, k in ipairs(sortT) do
        local oneStr = ser_table(t[k], 1)
        local key = type(k) == "number" and "[" .. k .. "]" or (quotKey and '["' .. k .. '"]' or k)
        local oneStr = sformat("    %s = %s,%s", key, oneStr, index == cnt and "" or "\n")
        finalStr = finalStr .. oneStr
    end

    finalStr = finalStr .. "\n}\n" .. "return config"

    return finalStr
end

-- lua table转成config配置表
-- tab lua表, name 要保存的config名字, destPath 保存的路径(默认dev/scripts/game_config/),
-- sortFunc 外层排序函数, quotKey ["key"]这种带引号的key,默认不带引号
function SL:SaveTableToConfig(tab, name, destPath, sortFunc, quotKey)
    if not tab or type(tab) ~= "table" or not name or string.len(name) == 0 then
        return
    end

    print("++++++Save begin++++++", name)
    local startMS = GetTimeInMS()

    local serializeStr = serialize(tab, sortFunc, quotKey)

    local serMS = GetTimeInMS()
    print("serialize cost:" .. (serMS - startMS))

    local path = (destPath or "dev/scripts/game_config/") .. name .. ".lua"
    writefile(serializeStr, path)

    print("io cost:" .. (GetTimeInMS() - serMS))
    print("------Save end------")
end

-- 同步官方配置表
function SL:UpdateConfig(file)
    local fileList = file and {file} or SLDefine.ConfigSettingFile
    local configPath = "scripts/game_config/"
    local module = global.L_ModuleManager:GetCurrentModule()

    -- 母包路径
    local motherPath = global.FileUtilCtl:getDefaultResourceRootPath() .. tostring(module:GetID()) .. "/" .. module:GetVersion() .. "/" .. configPath
    -- 热更路径
    local hotUpdatePath = module:GetStabPath() .. configPath

    local officalPath = {}
    for i, name in pairs(fileList) do 
        local filePath = nil
        if global.FileUtilCtl:isFileExist(motherPath..name) then 
            filePath = motherPath..name
        end 
        if global.FileUtilCtl:isFileExist(hotUpdatePath..name) then 
            filePath = hotUpdatePath..name
        end 
        if global.FileUtilCtl:isFileExist(filePath) then -- 官方路径 先找母包 再找热更 以热更为主
            officalPath[name] = filePath
        end 
    end 

    local customPath = {}
    for i, name in pairs(fileList) do 
        local filePath = nil 
        local devPath = global.FileUtilCtl:getDefaultResourceRootPath() .. "dev" .. "/" .. configPath .. fileList[i]
        if global.FileUtilCtl:isFileExist(devPath) then 
            filePath = devPath
        end 
        if global.FileUtilCtl:isFileExist(filePath) then -- 本地路径 dev目录下
            customPath[name] = filePath
        end 
    end 

    local function getAddFile(path)
        local config = require(path)
        if config and next(config) then 
            return config
        end 
    end 

    local function getUpdateFile(pathOffcial, pathCustom)
        local offcialCfg = require(pathOffcial)
        local customCfg = require(pathCustom)

        if offcialCfg and next(offcialCfg) and customCfg and next(customCfg) then 
            for key, cfg in pairs(offcialCfg) do 
                if not customCfg[key] then 
                    customCfg[key] = cfg
                end 
            end 
        end 

        return customCfg
    end 

    -- 对比 有无新增
    for i, name in pairs(fileList) do 
        local newCfg = nil
        if not officalPath[name] and customPath[name] then -- 官方无 本地有 用本地
            -- do nothing 
        end 
        
        if officalPath[name] and not customPath[name] then -- 官方有 本地无 新增官方表
            newCfg = getAddFile(officalPath[name])
        end  

        if officalPath[name] and customPath[name] then -- 官方有 本地有 对比 1.本地已有key不操作 2.本地无的key补全
            newCfg = getUpdateFile(officalPath[name], customPath[name])
        end 

        if newCfg and next(newCfg) then 
            local cfgName = string.gsub(name, ".lua", "")
            SL:SaveTableToConfig(newCfg, cfgName, nil, nil, true)
            global.FileUtilCtl:purgeCachedEntries()
        end 
    end 
end 

-- 同步服务下发配置表
function SL:UpdateServerConfig(file)
    local fileList = file and {file} or SLDefine.ConfigServerFile
    local GameConfigMgrProxy = global.Facade:retrieveProxy(global.ProxyTable.GameConfigMgrProxy)
    for i, name in pairs(fileList) do 
        local clientCfg = {}
        local severCfg = GameConfigMgrProxy:getServerConfingByKey(name) or {}
        if not severCfg or next(severCfg) == nil then 
            print("未找到服务配置"..name)
        end 

        local configPath = "scripts/game_server_config/"
        local devPath = global.FileUtilCtl:getDefaultResourceRootPath() .. "dev/" .. configPath .. name .. ".lua"
        local isFile = global.FileUtilCtl:isFileExist(devPath)
        if isFile then 
            clientCfg  = require(devPath)
        end 

        -- 对比 同步客户端修改的配置
        if severCfg and next(severCfg) then 
            if clientCfg and next(clientCfg) then 
                for key, cfg in pairs(clientCfg) do 
                    if severCfg[key] then 
                        local keys = {}
                        keys = table.keys(cfg)
                        for _, key2 in pairs(keys) do 
                            severCfg[key][key2] = cfg[key2] -- 服务删除字段：a.客户端有 补全, b.客户端没有不管。 服务新增字段：新增。服务修改字段：以客户端为准
                        end 
                    else 
                        severCfg[key] = cfg -- 客户端新增key
                    end  
                end 
            end 

            local newCfg = {}
            newCfg = severCfg
            SL:SaveTableToConfig(newCfg, name)
            global.FileUtilCtl:purgeCachedEntries()
        end 
    end
end 

-- 十六进制转十进制
function SL:HexToInt(hexStr)
    return tonumber(hexStr, 16)
end

function SL:GetStrMD5(str)
    return get_str_MD5(str)
end

function SL:GetPointDistanceSQ(pt1, pt2)
    return cc.pDistanceSQ(pt1, pt2)
end

function SL:GetPointDistance(pt1, pt2)
    return cc.pGetDistance(pt1, pt2)
end

function SL:GetPointLength(pt)
    return cc.pGetLength(pt)
end

function SL:GetPointLengthSQ(pt)
    return cc.pLengthSQ(pt)
end

function SL:GetMidPoint(pt1, pt2)
    return cc.pMidpoint(pt1, pt2)
end

function SL:GetAddPoint(pt1, pt2)
    return cc.pAdd(pt1, pt2)
end

function SL:GetSubPoint(pt1, pt2)
    return cc.pSub(pt1, pt2)
end

function SL:GetNormalizePoint(pt)
    return cc.pNormalize(pt)
end

function SL:GetPointAngle(pt1, pt2)
    return cc.pGetAngle(pt1, pt2)
end

function SL:GetPointRotate(pt1, pt2)
    local angle = cc.pGetAngle(pt1, pt2)
    return angle * 180 / math.pi
end

function SL:GetPointAngleSelf(pt)
    return cc.pToAngleSelf(pt)
end

function SL:GetPointRotateSelf(pt)
    local angle = cc.pToAngleSelf(pt)
    return angle * 180 / math.pi
end

------------------------------游戏相关--------------------------------------
-- 跳转到某个超链
-- id: int  param: 附加参数
function SL:JumpTo(id, param)
    JUMPTO(id, param)
end

function SL:SubmitAct(data)
    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
    SUIComponentProxy:SubmitAct(data)  
end

-- 退出到选角界面
function SL:ExitToRoleUI()
    local data = {}
    data.str = GET_STRING(30003056)
    data.btnDesc = { GET_STRING(1001), GET_STRING(1000) }
    data.callback = function(bType)
        if bType == 1 then
            global.userInputController:RequestLeaveWorld()
        end
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
    global.Facade:sendNotification(global.NoticeTable.Audio_Play, { type = global.MMO.SND_TYPE_LAYER_CLICK })
end

function SL:ForceExitToRoleUI()
    global.gameWorldController:OnGameLeaveWorld()
end

-- 退出到登录界面
function SL:ExitToLoginUI(isJudgePC)
    global.L_NativeBridgeManager:GN_accountLogout()
    global.Facade:sendNotification(global.NoticeTable.RestartGame)
    if isJudgePC then
        local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
        if envProxy:IsNeedExitGame() then
            global.Director:endToLua()
        end
    end
end

-- 退出游戏
function SL:ExitGame()
    global.userInputController:RequestToOutGame()
end

-- 退出游戏
function SL:ShutdownGame()
    global.Director:endToLua()
end

-- 发送GM命令到聊天
function SL:SendGMMsgToChat(msg)
    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local MSG_TYPE  = ChatProxy.MSG_TYPE
    local CHANNEL   = ChatProxy.CHANNEL
    local input     = string.format("@%s", msg)
    local sendData  = { mt = MSG_TYPE.Normal, msg = input, channel = CHANNEL.Shout }
    global.Facade:sendNotification(global.NoticeTable.SendChatMsg, sendData)
end

-- 创建一个红点到节点
function SL:CreateRedPoint(targetNode, offset)
    return CreateRedPoint(targetNode, offset)
end

function SL:GetMetaValue(key, ...)
    local metaValueProxy = global.Facade:retrieveProxy(global.ProxyTable.MetaValueProxy)
    return metaValueProxy:GetValueByKey(key, ...)
end

function SL:SetMetaValue(key, ...)
    local metaValueProxy = global.Facade:retrieveProxy(global.ProxyTable.MetaValueProxy)
    return metaValueProxy:SetValueByKey(key, ...)
end

function SL:PrintMetaKey()
    local metaValueProxy = global.Facade:retrieveProxy(global.ProxyTable.MetaValueProxy)
    metaValueProxy:PrintMetaKey()
end

function SL:PrintAllMetaValue()
    local metaValueProxy = global.Facade:retrieveProxy(global.ProxyTable.MetaValueProxy)
    metaValueProxy:PrintAllMetaValue()
end

-- 设置文本样式(按钮、文本)
function SL:SetColorStyle(widget, colorID)
    SET_COLOR_STYLE(widget, colorID)
end

function SL:GetColorCfg(id)
    return GET_COLOR_CONFIG(id)
end

-- condition
function SL:CheckCondition(conditionStr)
    local ConditionProxy = global.Facade:retrieveProxy(global.ProxyTable.ConditionProxy)
    return ConditionProxy:CheckCondition(conditionStr)
end

-- 显示气泡提醒
function SL:AddBubbleTips(id, path, callback)
    global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, { id = id, status = true, path = path, callback = callback })
end

-- 删除气泡提醒
function SL:DelBubbleTips(id)
    global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, { id = id, status = false })
end

function SL:ReloadMap()
    global.Facade:sendNotification(global.NoticeTable.ReloadMap)
end

function SL:HTTPRequestGet(url, callback)
    HTTPRequest(url, callback)
end

function SL:HTTPRequestPost(url, callback, data, header)
    HTTPRequestPost(url, callback, data, header)
end

------------------------------打开、关闭相关功能界面------------------------------------------------
-- 打开设置界面
function SL:OpenSettingUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_SettingFrame_Open,data)
end
-- 关闭设置界面
function SL:CloseSettingUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_SettingFrame_Close)
end

-- 打开行会指定页签界面
function SL:OpenGuildMainUI(page)
    global.Facade:sendNotification(global.NoticeTable.Layer_GuildFrame_Open, page)
end
-- 关闭行会界面
function SL:CloseGuildMainUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_GuildFrame_Close)
end

-- 打开行会申请界面
function SL:OpenGuildApplyListUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Guild_ApplyList_Open)
end
-- 关闭行会申请界面
function SL:CloseGuildApplyListUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Guild_ApplyList_Close)
end

-- 打开行会创建界面
function SL:OpenGuildCreateUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Guild_Create_Open)
end
-- 关闭行会创建界面
function SL:CloseGuildCreateUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Guild_Create_Close)
end

-- 打开行会结盟申请界面
function SL:OpenGuildAllyApplyUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Guild_Ally_Apply_Open)
end
-- 关闭行会结盟申请界面
function SL:CloseGuildAllyApplyUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Guild_Ally_Apply_Close)
end

-- 关闭行会宣战/结盟界面
function SL:CloseGuildWarSponsorUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Guild_WarSponsor_Close)
end

--[[    
    data = {
        pos = {x = 0, y = 0}, bag_page = 1
    }
]]
function SL:OpenBagUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Open, data)
end
function SL:CloseBagUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Close)
end

function SL:OpenHeroBagUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_HeroBag_Open, data)
end
function SL:CloseHeroBagUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_HeroBag_Close)
end

-- 打开拍卖行
function SL:OpenAuctionUI()
    local mediator = global.Facade:retrieveMediator("TradingBankFrameMediator")--拍卖行和交易行不能同时使用
    if  mediator._layer then
        ShowSystemTips(GET_STRING(600000702))
        return
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionMain_Open)
end
function SL:CloseAuctionUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionMain_Close)
end

-- 打开摆摊界面
function SL:OpenStallLayerUI(data)
    local mediator = global.Facade:retrieveMediator("TradingBankFrameMediator")--摆摊和交易行不能同时使用
    if  mediator._layer then
        ShowSystemTips(GET_STRING(600000701))
        return
    end
    local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
    if TradeProxy:IsTrading() then
        TradeProxy:RequestCancle()
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_StallLayer_Open, data)
end
function SL:CloseStallLayerUI()
    local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
    if not StallProxy:GetMyTradingStatus() then
        StallProxy:CleanMySellData()
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_StallLayer_Close)
end

-- 打开玩家交易界面
function SL:OpenTradeUI()
    local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
    local targetId = SL:GetMetaValue("TARGET_ID")
    local targetName = SL:GetMetaValue("TARGET_NAME")
    TradeProxy:SendTradeRequest(targetId, targetName)
end
function SL:CloseTradeUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Trade_Close)
end

-- 打开排行榜
function SL:OpenRankUI(type)
    global.Facade:sendNotification(global.NoticeTable.Layer_Rank_Open, type)
end
function SL:CloseRankUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Rank_Close)
end

-- 打开聊天
function SL:OpenChatUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Chat_Open)
end
function SL:CloseChatUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Chat_Close)
end

-- 聊天拓展
function SL:OpenChatExtendUI(index)
    global.Facade:sendNotification(global.NoticeTable.Layer_ChatExtend_Open, {group = index})
end
function SL:CloseChatExtendUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_ChatExtend_Close)
end

--社区帖子
function SL:OpenCommunityUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_CommunityLayer_Open)
end

function SL:CloseCommunityUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_CommunityLayer_Close)
end

-- 打开交易行
function SL:OpenTradingBankUI(page)
    local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    if OtherTradingBankProxy:getPublishOpen() == 1 then
        return
    end

    if global.OtherTradingBank then -- 三方 交易行
        local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
        OtherTradingBankProxy:getTradingBankStatus({}, function(code, data, msg)
            local isOpen = false
            if code == 200 then 
                if data and data.openExchange == 1 then
                    isOpen = true
                else 
                    ShowSystemTips(GET_STRING(600000179))
                end
            else 
                ShowSystemTips(msg or GET_STRING(600000660))
            end
            if isOpen then 
                local gameToken = OtherTradingBankProxy:getGameToken()
                if not gameToken or gameToken == "" or gameToken == "noToken" then 
                    ShowSystemTips(GET_STRING(600000631))
                    return 
                end 
                if global.OtherTradingBankH5 then 
                    OtherTradingBankProxy:showTradingView()
                else 
                    --是否登录
                    if OtherTradingBankProxy:getToken() == "" then 
                        OtherTradingBankProxy:Login1_2(function(code, msg)
                            if code == 200 then 
                                if OtherTradingBankProxy:getToken() ~= "" then 
                                    SL:OpenTradingBankUI(page)
                                end
                            else
                                ShowSystemTips(msg or "")
                            end
                        end)
                        return 
                    end
                    OtherTradingBankProxy:doTrack(OtherTradingBankProxy.UpLoadData.TraingIconBtnClick)--没有请求成功没有appid 和 secret 上报不成功
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankFrame_Open_other,  {id = page} ) 
                end
                
            end
            if OtherTradingBankProxy then 
                OtherTradingBankProxy:setOpenStatus(isOpen)
            end
        end, true) 
    else
        local Box996Proxy = global.Facade:retrieveProxy( global.ProxyTable.Box996Proxy )
        Box996Proxy:requestLogUp(Box996Proxy.OTHER_UP_EVEIT[1])
        
        local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)

        TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingIconBtnClick, {first_entry_time = ""})

        local mainPlayerID = SL:GetMetaValue("MAIN_ACTOR_ID")
        if mainPlayerID then 
            if SL:GetMetaValue("ACTOR_IS_IN_STALL",mainPlayerID) then --摆摊状态不能打开
                ShowSystemTips(GET_STRING(600000700))
                return 
            end
        end

        local mediator = global.Facade:retrieveMediator("StallLayerMediator")--摆摊和交易行不能同时使用
        if  mediator._layer then
            ShowSystemTips(GET_STRING(600000701))
            return 
        end

        local mediator = global.Facade:retrieveMediator("AuctionMainMediator")--拍卖行和交易行不能同时使用
        if  mediator._layer then
            ShowSystemTips(GET_STRING(600000702))
            return
        end

        TradingBankProxy:getTradingBankStatus({},function(success, response, code)
            local isOpen = false
            if success then
                local data = cjson.decode(response)
                if data and data.code == 200 and data.data and data.data.status == 0 then
                    isOpen = true
                end
            end
            if isOpen then
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankFrame_Open, {id = page})
                TradingBankProxy:SetBeginTime(os.time()) --访问开始时间
            else
                ShowSystemTips(GET_STRING(600000179))
            end
            if TradingBankProxy then 
                TradingBankProxy:setOpenStatus(isOpen)
            end
        end)
    end
    
end
-- 关闭交易行
function SL:CloseTradingBankUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankFrame_Close)
end

-- 打开商城
function SL:OpenStoreUI(page)
    global.Facade:sendNotification(global.NoticeTable.Layer_StoreFrame_Open, page)
end
function SL:CloseStoreUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_StoreFrame_Close)
end

function SL:OpenStoreDetailUI(storeIndex, limitStr)
    if not storeIndex then
        return
    end
    local PageStoreProxy = global.Facade:retrieveProxy(global.ProxyTable.PageStoreProxy)
    local storeData = PageStoreProxy:GetItemDataByStoreIndex(storeIndex)
    if not storeData or next(storeData) == nil then
        return
    end
    local canBy = PageStoreProxy:CheckStoreLimitStatus(storeIndex)
    if not canBy then
        if limitStr and string.len(limitStr) > 0 then
            ShowSystemTips(limitStr)
        end
        return
    end
    local buyData = {
        data = storeData,
    }
    global.Facade:sendNotification(global.NoticeTable.Layer_StoreBuy_Open, buyData)
end
function SL:CloseStoreDetailUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_StoreBuy_Close)
end

-- 技能配置界面
function SL:OpenSkillSettingUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_SkillSetting_Open, data)
end
function SL:CloseSkillSettingUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_SkillSetting_Close)
end

-- 社交（1附近玩家、2组队、3好友、4邮件）
function SL:OpenSocialUI(page)
    global.Facade:sendNotification(global.NoticeTable.Layer_Social_Open, page)
end
function SL:CloseSocialUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Social_Close)
end

-- 打开 PC 分辨率修改界面
function SL:OpenResolutionSetUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_setResolutionSize_Open)
end
function SL:CloseResolutionSetUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_setResolutionSize_Close)
end

-- 打开菊花转
function SL:ShowLoadingBar(time)
    ShowLoadingBar(time)
end

-- 关闭菊花转
function SL:HideLoadingBar()
    HideLoadingBar()
end

-- 摇骰子界面
--[[
    {
        arr = table 投掷值 {xx, xx}
        count = 数量
        callback = @xxx 脚本触发
    }
]]
function SL:OpenPlayDice(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_PlayDice_Open, data)
end

function SL:ClosePlayDice()
    global.Facade:sendNotification(global.NoticeTable.Layer_PlayDice_Close)
end

--------------------------------------------------------------------------------------------------------------
---
--[[    
    data 
    {
        extent = 子页id
        isFast 是否pc快捷键打开
        type = 类型 1基础 2内功
    }
]]
-- 打开个人人物界面
function SL:OpenMyPlayerUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open, data)
end
function SL:CloseMyPlayerUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Player_Close)
end
--关闭人物 子页签
function SL:CloseMyPlayerPageUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_Player_Child_Del,data)
end

-- 打开个人英雄界面
function SL:OpenMyPlayerHeroUI(page)
    global.Facade:sendNotification(global.NoticeTable.Layer_Player_Open_Hero, page)
end
function SL:CloseMyPlayerHeroUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Player_Close_Hero)
end
--关闭英雄 子页签
function SL:CloseMyPlayerHeroPageUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_Player_Child_Del_Hero,data)
end

-- 打开他人人物界面
function SL:OpenOtherPlayerUI(page)
    global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Open, page)
end
function SL:CloseOtherPlayerUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Close)
end
--关闭他人 子页签
function SL:CloseOtherPlayerPageUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Child_Del,data)
end

-- 打开他人英雄界面
function SL:OpenOtherPlayerHeroUI(page)
    global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Open_Hero, page)
end
function SL:CloseOtherPlayerHeroUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Close_Hero)
end
--关闭他人英雄 子页签
function SL:CloseOtherPlayerHeroPageUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Child_Del_Hero,data)
end

--关闭他人人物 子页签
function SL:CloseTradingBankPlayerPageUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Player_Child_Del,data)
end

--关闭他人英雄 子页签
function SL:CloseTradingBankHeroPageUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Player_Child_Del_Hero,data)
end
-------
---
-- 打开玩家首饰盒
-- param: 1: 自己人物、2：自己英雄、11：其他玩家人物、12：其他玩家英雄、21：交易行人物、22：交易行英雄
function SL:OpenBestRingBoxUI(param, data)
    if param == 1 then
        global.Facade:sendNotification(global.NoticeTable.Layer_PlayerBestRing_Open, data)
    elseif param == 2 then
        global.Facade:sendNotification(global.NoticeTable.Layer_PlayerBestRing_Open_Hero, data)
    elseif param == 11 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_PlayerBestRing_Open, data)
    elseif param == 12 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_PlayerBestRing_Open_Hero, data)
    elseif param == 21 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_PlayerBestRing_Open, data)
    elseif param == 22 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_PlayerBestRing_Open_Hero, data)
    end
end
-- 同上
function SL:CloseBestRingBoxUI(param)
    if param == 1 then
        global.Facade:sendNotification(global.NoticeTable.Layer_PlayerBestRing_Close)
    elseif param == 2 then
        global.Facade:sendNotification(global.NoticeTable.Layer_PlayerBestRing_Close_Hero)
    elseif param == 11 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_PlayerBestRing_Close)
    elseif param == 12 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_PlayerBestRing_Close_Hero)
    elseif param == 21 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_PlayerBestRing_Close)
    elseif param == 22 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_PlayerBestRing_Close_Hero)
    end
end

---打开人物装备面板
-- param: 1: 自己人物、2：自己英雄、11：其他玩家人物、12：其他玩家英雄、21：交易行人物、22：交易行英雄
function SL:OpenPlayerEquipUI(param, data)
    if param == 1 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Equip_Open, data)
    elseif param == 2 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Equip_Open_Hero, data)
    elseif param == 11 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Equip_Open, data)
    elseif param == 12 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Equip_Open_Hero, data)
    elseif param == 21 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Player_Equip_Open, data)
    elseif param == 22 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Player_Equip_Open_Hero, data)
    end
end
---打开人物状态面板
-- param: 1: 自己人物、2：自己英雄、11：其他玩家人物、12：其他玩家英雄、21：交易行人物、22：交易行英雄
function SL:OpenPlayerBaseAttrUI(param, data)
    if param == 1 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Base_Att_Open,data)
    elseif param == 2 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Base_Att_Open_Hero, data)
    elseif param == 11 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Base_Att_Open, data)
    elseif param == 12 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Base_Att_Open_Hero, data)
    elseif param == 21 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Player_Base_Att_Open, data)
    elseif param == 22 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Player_Base_Att_Open_Hero, data)
    end
end
---打开人物属性面板
-- param: 1: 自己人物、2：自己英雄、11：其他玩家人物、12：其他玩家英雄、21：交易行人物、22：交易行英雄
function SL:OpenPlayerExtraAttrUI(param, data)
    if param == 1 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Extra_Att_Open,data)
    elseif param == 2 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Extra_Att_Open_Hero, data)
    elseif param == 11 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Extra_Att_Open, data)
    elseif param == 12 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Extra_Att_Open_Hero, data)
    elseif param == 21 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Player_Extra_Att_Open, data)
    elseif param == 22 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Player_Extra_Att_Open_Hero, data)
    end
end
---打开人物技能面板
-- param: 1: 自己人物、2：自己英雄、11：其他玩家人物、12：其他玩家英雄、21：交易行人物、22：交易行英雄
function SL:OpenPlayerSkillUI(param, data)
    if param == 1 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Skill_Open,data)
    elseif param == 2 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Skill_Open_Hero, data)
    elseif param == 11 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Skill_Open, data)
    elseif param == 12 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Skill_Open_Hero, data)
    elseif param == 21 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Player_Skill_Open, data)
    elseif param == 22 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Player_Skill_Open_Hero, data)
    end
end
---打开人物称号面板
-- param: 1: 自己人物、2：自己英雄、11：其他玩家人物、12：其他玩家英雄、21：交易行人物、22：交易行英雄
function SL:OpenPlayerTitleUI(param, data)
    if param == 1 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Title_Attach, data)
    elseif param == 2 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Title_Attach_Hero, data)
    elseif param == 11 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Title_Attach, data)
    elseif param == 12 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Title_Attach_Hero, data)
    elseif param == 21 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Title_Attach, data)
    elseif param == 22 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Title_Attach_Hero, data)
    end
end
---打开人物时装面板
-- param: 1: 自己人物、2：自己英雄、11：其他玩家人物、12：其他玩家英雄、21：交易行人物、22：交易行英雄
function SL:OpenPlayerSuperEquipUI(param, data)
    if param == 1 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Super_Equip_Open, data)
    elseif param == 2 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Super_Equip_Open_Hero, data)
    elseif param == 11 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Super_Equip_Open, data)
    elseif param == 12 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Super_Equip_Open_Hero, data)
    elseif param == 21 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Player_Super_Equip_Open, data)
    elseif param == 22 then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBank_Look_Player_Super_Equip_Open_Hero, data)
    end
end

-- 打开人物BUFF面板 1: 自己人物、2：自己英雄、11：其他玩家人物、12：其他玩家英雄
function SL:OpenPlayerBuffUI(param, data)
    if param == 1 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Buff_Open, data)
    elseif param == 2 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Buff_Open_Hero, data)
    elseif param == 11 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Buff_Open, data)
    elseif param == 12 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Buff_Attach_Hero, data)
    end
end

-- 打开称号提示界面
function SL:OpenTitleTipsUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_TitleTips_Open, data)
end
-- 关闭称号提示界面
function SL:CloseTitleTipsUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_TitleTips_Close)
end
-- 打开查看他人称号提示界面
function SL:OpenOtherTitleTipsUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_Look_TitleTips_Open, data)
end
-- 关闭查看他人称号提示界面
function SL:CloseOtherTitleTipsUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Look_TitleTips_Close)
end
-- 交易行查看他人容器
function SL:CloseTradingBankLookPanelUI()
    if global.OtherTradingBank then 
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerPanel_Close_other)
    else
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerPanel_Close)
    end
end
-- 交易行查看他人界面
function SL:CloseTradingBankLookInfoUI()
    if global.OtherTradingBank then 
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerInfo_Close_other)
    else
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerInfo_Close)
    end
end

-- 打开内功状态 1:人物 2:英雄
function SL:OpenInternalStateUI(param, data)
    if param == 1 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Internal_State_Open, data)
    elseif param == 2 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Hero_Internal_State_Open, data)
    end
end

-- 打开内功技能 1:人物 2:英雄
function SL:OpenInternalSkillUI(param, data)
    if param == 1 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Internal_Skill_Open, data)
    elseif param == 2 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Hero_Internal_Skill_Open, data)
    end
end

-- 打开内功经络 1:人物 2:英雄
function SL:OpenInternalMerdianUI(param, data)
    if param == 1 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Internal_Meridian_Open, data)
    elseif param == 2 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Hero_Internal_Meridian_Open, data)
    end
end

-- 打开内功连击 1:人物 2:英雄
function SL:OpenInternalComboUI(param, data)
    if param == 1 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Player_Internal_Combo_Open, data)
    elseif param == 2 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Hero_Internal_Combo_Open, data)
    end
end
-- 关闭人物内功 子页签
function SL:CloseMyPlayerInternalPageUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_Player_Internal_Child_Del, data)
end
-- 关闭英雄内功 子页签
function SL:CloseMyHeroInternalPageUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_Hero_Internal_Child_Del, data)
end
--------------------------------------------------------------------------------------------------------------------------------
-- 打开邀请组队界面
function SL:OpenTeamInvite()
    global.Facade:sendNotification(global.NoticeTable.Layer_TeamInvite_Open)
end
function SL:CloseTeamInvite()
    global.Facade:sendNotification(global.NoticeTable.Layer_TeamInvite_Close)
end

-- 打开入队申请列表
function SL:OpenTeamApply()
    global.Facade:sendNotification(global.NoticeTable.Layer_TeamApply_Open)
end
function SL:CloseTeamApply()
    global.Facade:sendNotification(global.NoticeTable.Layer_TeamApply_Close)
end

-- 打开被邀请组队界面
function SL:OpenTeamBeInvite(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_Team_BeInvite_Open, data)
end
function SL:CloseTeamBeInvite()
    global.Facade:sendNotification(global.NoticeTable.Layer_Team_BeInvite_Close)
end

-- 打开小地图
function SL:OpenMiniMap()
    global.Facade:sendNotification(global.NoticeTable.Layer_MiniMap_Open)
end
function SL:CloseMiniMap()
    global.Facade:sendNotification(global.NoticeTable.Layer_MiniMap_Close)
end

-- 
function SL:OpenGuideEnter(param)
    global.Facade:sendNotification(global.NoticeTable.GuideEnterTransition, { name = "GUIDE_BEGIN_SKILL_BUTTON", extent = param })
end
function SL:CloseGuideEnter()
    global.Facade:sendNotification(global.NoticeTable.GuideEnterTransition, { name = "GUIDE_BEGIN_SKILL_CHANGE_BUTTON" })
end

-- 转生点
function SL:OpenReinAttrUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Rein_Attr_Open)
end
function SL:CloseReinAttrUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Rein_Attr_Close)
end

-- 任务栏打开
function SL:OpenAssistUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Assist_ChangeHide, true)
end
function SL:CloseAssistUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Assist_ChangeHide, false)
end

-- 小地图伸缩
function SL:OpenMiniMapChangeUI()
    global.Facade:sendNotification(global.NoticeTable.MainMiniMapChange, true)
end
function SL:CloseMiniMapChangeUI()
    global.Facade:sendNotification(global.NoticeTable.MainMiniMapChange, false)
end

-- 附近展示页
function SL:OpenMainNearUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_MainNear_Open)
end
function SL:CloseMainNearUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_MainNear_Close)
end

-- 直接调用支付
function SL:OpenCallPayUI()
    local NativeBridgeProxy = global.Facade:retrieveProxy(global.ProxyTable.NativeBridgeProxy)
    if NativeBridgeProxy then
        NativeBridgeProxy:GN_PC_CallOF()
    end
end

-- 打开客服UI
function SL:OpenKefuUI()
    if global.modBridgeController then
        global.modBridgeController:GN_kefu()
    end
end

-- 打开PC私聊
function SL:OpenPCPrivateUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Private_Chat_Open)
end
function SL:ClosePCPrivateUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Private_Chat_Close)
end

-- PC 小地图变换
function SL:OpenPCMiniMapUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_MainMiniMapWin32_Tab)
end

-- 打开添加好友界面
function SL:OpenAddFriendUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_AddFriend_Open)
end
function SL:CloseAddFriendUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_AddFriend_Close)
end

-- 打开添加黑名单界面
function SL:OpenAddBlackListUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_AddBlackList_Open)
end
function SL:CloseAddBlackListUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_AddBlackList_Close)
end

-- 打开好友添加申请界面
function SL:OpenFriendApplyUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_FriendApply_Open)
end
function SL:CloseFriendApplyUI()
    SL:RequestClearFriendApplyList()
    global.Facade:sendNotification(global.NoticeTable.Layer_FriendApply_Close)
end

-- 打开拍卖行世界拍卖/行会拍卖 source 0世界拍卖 1行会拍卖
function SL:OpenAuctionWorldUI(parent, source)
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionWorld_Open, { parent = parent, source = source })
end
function SL:CloseAuctionWorldUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionWorld_Close)
end

-- 打开拍卖行我的竞拍
function SL:OpenAuctionBiddingUI(parent)
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionBidding_Open, { parent = parent })
end
function SL:CloseAuctionBiddingUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionBidding_Close)
end

-- 打开拍卖行我的上架
function SL:OpenAuctionPutListUI(parent)
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionPutList_Open, { parent = parent })
end
function SL:CloseAuctionPutListUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionPutList_Close)
end

-- 打开拍卖行上架界面
function SL:OpenAuctionPutinUI(itemData)
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionPutin_Open, itemData)
end
function SL:CloseAuctionPutinUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionPutin_Close)
end

-- 打开拍卖行下架界面
function SL:OpenAuctionPutoutUI(itemData)
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionPutout_Open, itemData)
end
function SL:CloseAuctionPutoutUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionPutout_Close)
end

-- 打开拍卖行竞拍界面
function SL:OpenAuctionBidUI(itemData)
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionBid_Open, itemData)
end
function SL:CloseAuctionBidUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionBid_Close)
end

-- 打开拍卖行一口价界面
function SL:OpenAuctionBuyUI(itemData)
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionBuy_Open, itemData)
end
function SL:CloseAuctionBuyUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionBuy_Close)
end

-- 打开拍卖行超时界面
function SL:OpenAuctionTimeoutUI(itemData)
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionTimeout_Open, itemData)
end
function SL:CloseAuctionTimeoutUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_AuctionTimeout_Close)
end

-- 打开合成界面
function SL:OpenCompoundItemsUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_CompoundItemLayer_Open, data)
end
function SL:CloseCompoundItemsUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_CompoundItemLayer_Close)
end

--打开 boss提醒 设置界面
function SL:OpenBossTipsUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_BossTipsLayer_Open)
end

--关闭 boss提醒 设置界面
function SL:CloseBossTipsUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_BossTipsLayer_Close)
end

--打开 拾取 设置界面
function SL:OpenPickSettingUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_pickSettingLayer_Open)
end

--关闭 拾取 设置界面
function SL:ClosePickSettingUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_pickSettingLayer_Close)
end

--打开 保护 设置界面
function SL:OpenProtectSettingUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_ProtectSettingLayer_Open, data)
end

--关闭 保护 设置界面
function SL:CloseProtectSettingUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_ProtectSettingLayer_Close)
end

--打开 增加名字 设置界面
function SL:OpenAddNameUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_addMonsterNameLayer_Open, data)
end

--关闭 增加名字 设置界面
function SL:CloseAddNameUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_addMonsterNameLayer_Close)
end

--打开 增加boss类型 设置界面
function SL:OpenAddBossTypeUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_addMonsterTypeLayer_Open)
end

--关闭 增加boss类型 设置界面
function SL:CloseAddBossTypeUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_addMonsterTypeLayer_Close)
end

--打开 技能排行 设置界面
function SL:OpenSkillRankPanelUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_SkillRankPanel_Open, data)
end

--关闭 技能排行 设置界面
function SL:CloseSkillRankPanelUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_SkillRankPanel_Close)
end

--打开 技能 设置界面
function SL:OpenSkillPanelUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_SkillPanel_Open)
end

--关闭 技能 设置界面
function SL:CloseSkillPanelUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_SkillPanel_Close)
end

--打开 选择下拉框
--[[    list = list --下拉要显示的内容
    func --回调  选中的编号 0是关闭1~n
    position --初始位置
    cellwidth --item 宽
    cellheight--item 高
]]
function SL:OpenSelectListUI(list, position, cellwidth, cellheight, func, extraData)
    local data = {}
    data.values = list
    data.position = position
    data.cellwidth = cellwidth
    data.cellheight = cellheight
    data.func = func
    if extraData then
        for k, v in pairs(extraData) do
            data[k] = v
        end
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_Common_SelectList_Open, data)
end

-- 关闭 选择下拉框
function SL:CloseSelectListUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Common_SelectList_Close)
end

-- 打开996盒子界面 index: 1: 特权称号 2: 每日礼包 3: 超级礼包 4: 会员礼包 5: SVIP
function SL:OpenBox996UI(index)
    local Box996Proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
    Box996Proxy:requestLogUp(Box996Proxy.BOX_UP_BTN[0])
    global.Facade:sendNotification(global.NoticeTable.Layer_Box996Main_Open, {index = index})
end
-- 关闭996盒子界面
function SL:CloseBox996UI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Box996Main_Close)
end

--hero相关
-- 打开英雄状态选择界面
function SL:OpenHeroStateSelectUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_Hero_StateSelect_Open, data)
end
-- 关闭英雄状态选择界面
function SL:CloseHeroStateSelectUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_Hero_StateSelect_Close, data)
end

-- 打开快捷使用框
--[[
    itemData    -- table 物品数据
    equipPos    -- int 穿戴位置
    isBook      -- boolean 是否是技能书
    isHero      -- boolean 是否为英雄
]]
function SL:OpenAutoUseTip(itemData, equipPos, isBook, isHero)
    global.Facade:sendNotification(global.NoticeTable.Layer_Auto_Use_Attach, 
    {
        id = itemData.MakeIndex,
        item = itemData,
        targetPos = equipPos,
        skillBook = isBook,
        isHero = isHero
    })
end

-- 关闭快捷使用框
function SL:CloseAutoUseTip(makeIndex, isHero)
    if not makeIndex then
        return
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_Auto_Use_UnAttach, {id = makeIndex, isHero = isHero})
end

-- 好评有礼
function SL:ReviewGift()
    local NativeBridgeProxy = global.Facade:retrieveProxy(global.ProxyTable.NativeBridgeProxy)
    NativeBridgeProxy:GN_ReviewGift()
end

-- 开宝箱动画页 itemData: 宝箱物品数据
function SL:OpenTreasureBoxShow(itemData)
    global.Facade:sendNotification(global.NoticeTable.Layer_Treasure_Box_Open, itemData)
end

function SL:CloseTreasureBoxShow()
    global.Facade:sendNotification(global.NoticeTable.Layer_Treasure_Box_Close)
end

-- 开宝箱奖励 itemData: 宝箱物品数据
function SL:OpenGoldBoxUI(itemData)
    global.Facade:sendNotification(global.NoticeTable.Layer_Gold_Box_Open, itemData)
end

function SL:CloseGoldBoxUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_Gold_Box_Close)
end

------ 求购
function SL:OpenPurchaseUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_PurchaseMain_Open)
end
function SL:ClosePurchaseUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_PurchaseMain_Close)
    local PurchaseProxy = global.Facade:retrieveProxy(global.ProxyTable.PurchaseProxy)
    PurchaseProxy:NotifyClosePurchase()
end

-- 世界求购
function SL:OpenPurchaseWorldUI(parent)
    global.Facade:sendNotification(global.NoticeTable.Layer_PurchaseWorld_Open, {parent = parent})
end
function SL:ClosePurchaseWorldUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_PurchaseWorld_Close)
end

-- 我的求购
function SL:OpenPurchaseMyUI(parent)
    global.Facade:sendNotification(global.NoticeTable.Layer_PurchaseMy_Open, {parent = parent})
end
function SL:ClosePurchaseMyUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_PurchaseMy_Close)
end

-- 求购- 出售
function SL:OpenPurchaseSellUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_PurchaseSell_Open, data)
end
function SL:ClosePurchaseSellUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_PurchaseSell_Close)
end

-- 求购- 上架
function SL:OpenPurchasePutInUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_PurchasePutIn_Open, data)
end
function SL:ClosePurchasePutInUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_PurchasePutIn_Close)
end

-- 仓库 - 关闭
function SL:CloseStorageUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Storage_Close)
end
------------------------------打开、关闭相关功能界面------------------------------------------------

---------------------------------------------------------------------------
-- 通用弹窗
-- 通用 Desc 弹窗
function SL:OpenCommonDescTipsPop(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_Common_Desc_Open, data)
end
function SL:CloseCommonDescTipsPop()
    global.Facade:sendNotification(global.NoticeTable.Layer_Common_Desc_Close)
end

-- 通用弹窗
function SL:OpenCommonTipsPop(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end
function SL:CloseCommonTipsPop()
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Close)
end

-- 道具装备tips
function SL:OpenItemTips(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, data)
end
function SL:CloseItemTips()
    global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)
end

-- 道具拆分弹窗
function SL:OpenItemSplitPop(itemData)
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    if not BagProxy:isToBeFull(true) then
        local bagItemData = BagProxy:GetItemDataByMakeIndex(itemData.MakeIndex)
        local data = {
            itemData = bagItemData,
            closeCB = function()
                global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)
            end
        }
        global.Facade:sendNotification(global.NoticeTable.Layer_Split_Open, data)
    end
end
function SL:CloseItemSplitPop()
    global.Facade:sendNotification(global.NoticeTable.Layer_Split_Close)
end

-- FuncDock 通用界面
function SL:OpenFuncDockTips(data)
    local FuncDockProxy = global.Facade:retrieveProxy(global.ProxyTable.FuncDockProxy)
    if data.type == FuncDockProxy.FuncDockType.Func_Player_Head then
        global.Facade:sendNotification(global.NoticeTable.Layer_Func_Dock_RequsetInfo, data)
    else
        global.Facade:sendNotification(global.NoticeTable.Layer_Func_Dock_Open, data)
    end
end
function SL:CloseFuncDockTips()
    global.Facade:sendNotification(global.NoticeTable.Layer_Func_Dock_Close)
end

-- 进度条
function SL:OpenProgressBarUI(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_ProgressBar_Open, data)
end
function SL:CloseProgressBarUI()
    global.Facade:sendNotification(global.NoticeTable.Layer_ProgressBar_Close)
end

-- 多条选择项弹窗提示 [组队邀请/交易请求使用]
--[[
    {
        pos     = 位置,
        list    = {
            {str = 文本, agreeCall = 同意按钮回调, disAgreeCall = 拒绝回调},
            ...
        }
    }
]]
function SL:OpenCommonBubbleInfo(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonBubbleInfo_Open, data)
end
function SL:CloseCommonBubbleInfo()
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonBubbleInfo_Close)
end


-- 打开网址/链接
function SL:OpenURL(url)
    if not url or string.len(url) == 0 then
        return
    end
    cc.Application:getInstance():openURL(url)
end

-- 通用弹窗
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- 引导
-- 打开引导
function SL:StartGuide(data)
    local guide = requireGuide("SGuideTask").new(data)
    guide:Start()
    return guide
end
-- 关闭引导
function SL:CloseGuide(guide)
    guide:Destory()
end
-- 引导

-- 战斗相关
---------------------------------------------------------------------------
-- 取消目标actor
function SL:ClearTarget()
    deprecatedTip("SL:ClearTarget", "SL:SetMetaValue(\"SELECT_TARGET_ID\", nil)")

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    inputProxy:ClearTarget()
end

--获取视野内的玩家
function SL:FindPlayerInCurrViewField(noMainPlayer)
    deprecatedTip("SL:FindPlayerInCurrViewField", "SL:GetMetaValue(\"FIND_IN_VIEW_PLAYER_LIST\")")

    return global.playerManager:FindPlayerInCurrViewField(noMainPlayer)
end

--获取视野内的怪物
function SL:FindMonsterInCurrViewField(noPetOfMainPlayer, noPetOfNetPlayer)
    deprecatedTip("SL:FindMonsterInCurrViewField", "SL:GetMetaValue(\"FIND_IN_VIEW_MONSTER_LIST\")")

    return global.monsterManager:FindMonsterInCurrViewField(noPetOfMainPlayer, noPetOfNetPlayer)
end

--检测是否可以攻击
function SL:checkLaunchTargetByID(targetID)
    deprecatedTip("SL:checkLaunchTargetByID", "SL:GetMetaValue(\"TARGET_ATTACK_ENABLE\", param)")

    return proxyUtils.checkLaunchTargetByID(targetID)
end

-- 快速选择目标
function SL:QuickSelectTarget(data)
    global.Facade:sendNotification(global.NoticeTable.QuickSelectTarget, data)
end
-- 战斗相关
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- 本地存储
-- 存储字符到本地
function SL:SetLocalString(key, value)
    SL.LocalStringCache[key] = value

    if SL.LocalStringTimerID then
        SL:UnSchedule(SL.LocalStringTimerID)
        SL.LocalStringTimerID = nil
    end
    SL.LocalStringTimerID = SL:ScheduleOnce(function()
        SL.LocalStringTimerID = nil
        local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
        local playerID = LoginProxy:GetSelectedRoleID()
        local userData = UserData:new("GUIStorage" .. playerID)
        for k, v in pairs(SL.LocalStringCache) do
            userData:setStringForKey(k, v)
        end
        userData:writeMapDataToFile()
    end, 0.5)
end

-- 从本地读取字符
function SL:GetLocalString(key)
    local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local playerID = LoginProxy:GetSelectedRoleID()
    local userData = UserData:new("GUIStorage" .. playerID)
    return userData:getStringForKey(key, "")
end
-- 本地存储
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- ITEM ITEMTIPS
-- 检测人物是否可穿戴
function SL:CheckItemUseNeed_Hero(itemData)
    local canUse, conditionStr, notCheckUse = CheckItemUseNeed_Hero(itemData)
    return {
        canUse = canUse, conditionStr = conditionStr, notCheckUse = notCheckUse
    }
end
function SL:CheckItemUseNeed(itemData)
    local canUse, conditionStr, notCheckUse = CheckItemUseNeed(itemData)
    return {
        canUse = canUse, conditionStr = conditionStr, notCheckUse = notCheckUse
    }
end

function SL:GetDiffEquip(itemData, isHero)
    return GUIFunction:GetDiffEquip(itemData, isHero)
end

-- 对比传入装备和自身穿戴装备
function SL:CheckEquipPowerThanSelf(itemInfo, from)
    return CheckEquipPowerThanSelf(itemInfo, from)
end
---------------------------------------------------------------------------

-- menulayer
function SL:CheckMenuLayerConditionByID(layerid)
    local JumpLayerProxy = global.Facade:retrieveProxy(global.ProxyTable.JumpLayerProxy)
    local config = JumpLayerProxy:GetConfigByID(layerid)
    if not config then
        return true
    end
    return SL:CheckCondition(config.condition)
end

-- open menulayer
function SL:OpenMenuLayerByID(id, parent, extent)
    local JumpLayerProxy = global.Facade:retrieveProxy(global.ProxyTable.JumpLayerProxy)
    return JumpLayerProxy:OpenPanelById(id, parent, extent)
end

-- close menulayer
function SL:CloseMenuLayerByID(id)
    local JumpLayerProxy = global.Facade:retrieveProxy(global.ProxyTable.JumpLayerProxy)
    return JumpLayerProxy:ClosePanelById(id)
end

-- 注册控件事件
function SL:RegisterWndEvent(widget, desc, msgtype, callback)
    SLHandlerEvent:RegisterWndEvent(widget, desc, msgtype, callback)
end
-- 取消控件事件
function SL:UnRegisterWndEvent(widget, desc, msgtype)
    SLHandlerEvent:UnRegisterWndEvent(widget, desc, msgtype)
end

-- 添加窗体控件自定义属性
function SL:AddWndProperty(widget, desc, key, value)
    SLHandlerEvent:AddWndProperty(widget, desc, key, value)
end

-- 删除窗体控件自定义属性
function SL:DelWndProperty(widget, desc, key)
    SLHandlerEvent:DelWndProperty(widget, desc, key)
end

-- 获取窗体控件自定义属性
function SL:GetWndProperty(widget, desc, key)
    return SLHandlerEvent:GetWndProperty(widget, desc, key)
end

-- 通过色值id获取Color3B
function SL:GetColorByStyleId(id)
    return GET_COLOR_BYID_C3B(id)
end

-- 通过色值id获取hex
function SL:GetHexColorByStyleId(id)
    return GET_COLOR_BYID(id)
end

-- 通过色值id获取字号
function SL:GetSizeByStyleId(id)
    return GET_SIZE_BYID(id)
end

-- 通过Color3B获取hex
function SL:GetColorHexFromRGB( rgb )
    return GetColorHexFromRBG(rgb)
end

-- 播放按钮点击音效
function SL:PlayBtnClickAudio()
    global.Facade:sendNotification(global.NoticeTable.Audio_Play, { type = global.MMO.SND_TYPE_BTN_CLICK })
end

-- 播放登陆-选角音效
function SL:PlaySelectRoleAudio()
    global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_LOGIN_SELECTONE})
end

-- 播放开宝箱音效
function SL:PlayOpenBoxAudio()
    global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_OPEN_BOX})
end

-- 播放宝箱内选中音效
function SL:PlayFlashBoxAudio()
    global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_FLASH_BOX})
end

-- 播放音效
function SL:PlaySound(id, isLoop)
    global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_SSR_UI, index = id, isLoop = isLoop})
end

-- 停止音效
function SL:StopSound(id)
    global.Facade:sendNotification(global.NoticeTable.Audio_Stop_EffectId, id)
end

-- 停止所有音效
function SL:StopAllAudio()
    global.Facade:sendNotification(global.NoticeTable.Audio_Stop_All)
end

-- 下载小地图
function SL:DownloadMiniMapRes(mapId, callback)
    local miniMapPath = string.format("scene/uiminimap/%06d.png", tonumber(mapId) - 1)
    global.ResDownloader:download(miniMapPath, function(isOK)
        callback(isOK, miniMapPath)
    end)
end

-- 删除GM缓存资源 
function SL:RemoveGMResFile(filePath)
    local module            = global.L_ModuleManager:GetCurrentModule()
    local modulePath        = module:GetSubModPath()
    local gmCachePath       = cc.FileUtils:getInstance():getWritablePath() .. modulePath
    local fullPath          = gmCachePath .. filePath
    if not global.FileUtilCtl:isFileExist(fullPath) then
        return
    end
    global.FileUtilCtl:removeFile(fullPath)
    global.FileUtilCtl:purgeCachedEntries()
end

---------------------------------------------------------------------------
-- 聊天
-- 输入聊天内容
function SL:SendInputMsgToChat(str)
    global.Facade:sendNotification(global.NoticeTable.Layer_Chat_ReplaceInput, str)
end

-- 发送普通消息
function SL:SendNormalMsgToChat(msg, setChannel)
    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local MSG_TYPE  = ChatProxy.MSG_TYPE
    local channel   = setChannel or ChatProxy:getChannel()
    local sendData  = {mt = MSG_TYPE.Normal, msg = msg, channel = channel}
    global.Facade:sendNotification(global.NoticeTable.SendChatMsg, sendData)
end

-- 发送系统消息
function SL:SendSystemMsgToChat(data)
    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local mdata = {
        Msg        = data.Msg or "",
        FColor     = data.FColor or 255,
        BColor     = data.BColor or 255,
        ChannelId  = ChatProxy.CHANNEL.System,
    }
    global.Facade:sendNotification(global.NoticeTable.AddChatItem, mdata)
end

-- 发送装备
function SL:SendEquipMsgToChat(item, setChannel)
    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local MSG_TYPE  = ChatProxy.MSG_TYPE
    local msg       = item
    local channel   = setChannel or ChatProxy:getChannel()
    local sendData  = {mt = MSG_TYPE.Equip, msg = msg, channel = channel}
    global.Facade:sendNotification(global.NoticeTable.SendChatMsg, sendData)
end

-- 发送坐标
function SL:SendPosMsgToChat(setChannel)
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return nil
    end
    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    local msg = {
        mapID       = MapProxy:GetMapID(),
        mapName     = MapProxy:GetMapName(),
        mapX        = mainPlayer:GetMapX(),
        mapY        = mainPlayer:GetMapY()
    }
    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local MSG_TYPE  = ChatProxy.MSG_TYPE
    local channel   = setChannel or ChatProxy:getChannel()
    local sendData  = {mt = MSG_TYPE.Position, msg = msg, channel = channel}
    global.Facade:sendNotification(global.NoticeTable.SendChatMsg, sendData)
end

-- 发送表情
function SL:SendEmojiMsgToChat(config, setChannel)
    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local MSG_TYPE = ChatProxy.MSG_TYPE
    if config.type == 1 then -- 骰子
        local msg       = Random(1, 6)
        local channel   = setChannel or ChatProxy:getChannel()
        local sendData  = {mt = MSG_TYPE.Dice, msg = msg, channel = channel}
        global.Facade:sendNotification(global.NoticeTable.SendChatMsg, sendData)
    elseif config.type == 2 then -- 猜拳
        
    else
        global.Facade:sendNotification(global.NoticeTable.Layer_Chat_PushInput, config.replace)
    end
end

-- 私聊目标
function SL:PrivateChatWithTarget(targetId, targetName)
    if not targetId or not targetName then
        return
    end
    global.Facade:sendNotification(global.NoticeTable.PrivateChatWithTarget, {name = targetName, uid = targetId})
end

-- 物品数据转化 -聊天装备展示
function SL:TransItemDataIntoChatShow(itemData)
    if itemData and itemData.makeindex then
        itemData = ChangeItemServersSendDatas(itemData)
    end
    return clone(itemData)
end

-- 新增掉落消息
function SL:AddDropChatMsgShow(data)
    if not data or not data.dropType then
        SL:Print("[SL ERROR] SL:AddDropChatMsgShow param dropType is nil.")
        return 
    end
    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local msgParam = {
        Msg         = data.Msg or "",
        FColor      = data.FColor or 255,
        BColor      = data.BColor or 255,
        ChannelId   = ChatProxy.CHANNEL.Drop,
        mt          = ChatProxy.MSG_TYPE.SRText,
        dropType    = data.dropType
    }
    global.Facade:sendNotification(global.NoticeTable.AddChatItem, msgParam)
end

-- 聊天
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- 资源下载
function SL:DownLoadRes(path, url, downloadCB)
    if not url or string.len(url) == 0 then
        global.ResDownloader:download(path, function(isOK)
            if downloadCB then
                downloadCB(isOK)
            end
        end)
        return
    end
    global.ResDownloader:downloadEx(path, url, function(isOK)
        if isOK and downloadCB then
            downloadCB()
        end
    end)
end

-----脚本变量额外属性 添加监听更新
function SL:CustomAttrWidgetAdd(metaValue,widget)
    global.Facade:sendNotification(global.NoticeTable.CustomAttrWidgetAdd, {metaValue = metaValue , widget = widget})
end

-- 用于检测goodsitem 是否在listview 并且可视
function SL:CheckNodeCanCallBack(node, mousePos)
    return CheckNodeCanCallBack(node, mousePos)
end

---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- id 必须唯一 name 按钮名字 func 跳转函数
function SL:AddUpgradeBtn(id, name, func)
    local RemindUpgradeProxy = global.Facade:retrieveProxy(global.ProxyTable.RemindUpgradeProxy)   
    RemindUpgradeProxy:refData(id, true,{id = id, name = name, func = func})
end

function SL:RemoveUpgradeBtn(id)
    local RemindUpgradeProxy = global.Facade:retrieveProxy(global.ProxyTable.RemindUpgradeProxy)   
    RemindUpgradeProxy:refData(id, false)
end

---------------------------------------------------------------------------

---------------------------------------------------------------------------
----- 鼠标模拟事件 ---------------------------------------------------------
-- 模拟左键点击触发左键点击事件
function SL:WinClick(widget)
    if not widget or tolua.isnull(widget) then
        return false
    end
    if type(widget._clickCallBack_) == "function" then
        widget._clickCallBack_()
    elseif type(widget._touchCallBack_) == "function" then
        widget._touchCallBack_()
    end
end

---------------------------------------------------------------------------
-- 背包
function SL:RefreshBagPos()
    ResetBagPos()
end

-- 物品使用(通过Index)
function SL:UseItemByIndex(Index)
    return UseItemByIndex(Index)
end

-- 人物装备穿戴 isFromHero:是否来自英雄背包 
function SL:TakeOnPlayerEquip(itemData, pos, isFromHero)
    local noticeName = isFromHero and global.NoticeTable.TakeOnRequestFromHeroBag or global.NoticeTable.TakeOnRequest
    global.Facade:sendNotification(noticeName,
    {
        itemData = itemData,
        pos = pos
    })
end

-- 人物装备脱下 isToHero:是否脱到英雄背包 
function SL:TakeOffPlayerEquip(itemData, isToHero)
    local noticeName = isToHero and global.NoticeTable.TakeOffToHeroBagRequest or global.NoticeTable.TakeOffRequest 
    global.Facade:sendNotification(noticeName, itemData)
end

-- 英雄装备穿戴 isFromPlayer:是否来自人物背包
function SL:TakeOnHeroEquip(itemData, pos, isFromPlayer)
    local noticeName = isFromPlayer and global.NoticeTable.HeroTakeOnRequestFromHumBag or global.NoticeTable.HeroTakeOnRequest 
    global.Facade:sendNotification(noticeName,
    {
        itemData = itemData,
        pos = pos
    })
end

-- 英雄装备脱下 isToPlayer:是否脱到人物背包
function SL:TakeOffHeroEquip(itemData, isToPlayer)
    local noticeName = isToPlayer and global.NoticeTable.HeroTakeOffRequestToHumBag or global.NoticeTable.HeroTakeOffRequest 
    global.Facade:sendNotification(noticeName, itemData)
end

-- 批量勾选背包物品
function SL:SetBagItemChoose(data)
    global.Facade:sendNotification(global.NoticeTable.Bag_Item_Choose_State, data)
end

-- 丢弃物品
function SL:IntoDropBagItem(itemData)
    if not itemData or not next(itemData) then
        return 
    end
    global.Facade:sendNotification(global.NoticeTable.IntoDropItem, itemData)
end

---------------------------------------------------------------------------
-- 坐标转换
function SL:ConvertWorldPos2MapPos(worldX, worldY)
    return global.sceneManager:WorldPos2MapPos(cc.p(worldX, worldY))
end

function SL:ConvertMapPos2WorldPos(mapX, mapY, centerOfGrid)
    return global.sceneManager:MapPos2WorldPos(mapX, mapY, centerOfGrid)
end

function SL:ConvertWorldPos2Screen(worldX, worldY)
    return World2Screen(cc.p(worldX, worldY))
end

function SL:ConvertScreen2WorldPos(screenX, screenY)
    return Screen2World(cc.p(screenX, screenY))
end
--------------------------与移动端/PC端交互  begin-----------------------------
-- 打开qq(移动端)
function SL:OpenQQ()
    global.L_NativeBridgeManager:GN_startQQ()
end

-- 加qq(移动端)
function SL:JoinQQ(id)
    global.L_NativeBridgeManager:GN_joinQQ({qqKey=id})
end

-- 加qq群(移动端)
function SL:JoinQQGroup(id)
    global.L_NativeBridgeManager:GN_joinQQGroup({qqGroupKey=id})
end

-- 打开微信(移动端)
function SL:OpenWX()
    global.L_NativeBridgeManager:GN_startWX()
end

-- 加微信公众号(移动端)
function SL:JoinWXGroup(id)
    global.L_NativeBridgeManager:GN_joinWXGroup({wxGroupKey=id})
end
--------------------------与移动端/PC端交互    end-----------------------------

---------------------------------------------------------------------------
-- 添加控件 - 挂接方式
function SL:AttachOrUnAttachSUI(data)
    global.Facade:sendNotification(global.NoticeTable.SUIComponentAttachBySSR, data)
end

-- 有目标聊天信息的点击触发 [不必开放]
function SL:OnTriggerClickPlayerChatMsg(data, richText)
    ssr.ssrBridge:OnClickChatPlayerMsg(data.SendId, data.SendName, richText)
    if SL.Triggers[LUA_TRIGGER_CHAT_CLICK_PLAYER_NAME] and SL.Triggers[LUA_TRIGGER_CHAT_CLICK_PLAYER_NAME](data) then
        return
    end
    if type(ssrGlobal_OnClickChatPlayerMsg) == "function" then
        local sendData = clone(data)
        sendData.widget = richText
        if ssrGlobal_OnClickChatPlayerMsg(sendData) then
            return
        end
    end
end

-- 本地公告展示 [ssr]
function SL:ShowLocalNoticeByType(jsonData)
    if not jsonData or not jsonData.Type then
        return
    end

    if jsonData.Type == 12 then
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        local mdata     = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
            ChannelId   = ChatProxy.CHANNEL.System,
            mt          = ChatProxy.MSG_TYPE.SystemTips,
        }
        global.Facade:sendNotification(global.NoticeTable.AddChatItem, mdata)

    elseif jsonData.Type == 4 then
        local data      = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
        }
        global.Facade:sendNotification(global.NoticeTable.ShowServerNotice, data)

    elseif jsonData.Type == 5 then
        local data      = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
            Y           = jsonData.Y,
            Count       = jsonData.Count,
        }
        global.Facade:sendNotification(global.NoticeTable.ShowSystemNotice, data)

    elseif jsonData.Type == 6 then
        local data      = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
            Time        = jsonData.Time,
            Label       = jsonData.Label
        }
        global.Facade:sendNotification(global.NoticeTable.ShowTimerNotice, data)

    elseif jsonData.Type == 9 then
        ShowSystemTips(jsonData.Msg)

    elseif jsonData.Type == 10 then
        local data      = {
            X           = jsonData.X,
            Y           = jsonData.Y,
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
        }
        global.Facade:sendNotification(global.NoticeTable.ShowSystemNoticeXY, data)

    elseif jsonData.Type == 11 then
        local data      = {
            Type        = jsonData.Type,
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
        }
        global.Facade:sendNotification(global.NoticeTable.ServerNoticeEvent, data)
    elseif jsonData.Type == 13 then
        local data      = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
            Y           = jsonData.Y,
            Count       = jsonData.Count,
            ShowTime    = jsonData.time,
        }
        global.Facade:sendNotification(global.NoticeTable.ShowSystemNoticeScale, data)
    elseif jsonData.Type == 14 then
        local data      = {
            Msg         = jsonData.Msg,
            FColor      = jsonData.FColor,
            BColor      = jsonData.BColor,
            Time        = jsonData.Time,
            X           = jsonData.X,
            isDelete    = jsonData.isDelete,
        }
        global.Facade:sendNotification(global.NoticeTable.ShowTimerNoticeXY, data)
    end
end

-- 震屏
function SL:ShakeScene(time, distance)
    local data = {
        time = time,
        distance = distance
    }
    global.Facade:sendNotification( global.NoticeTable.ShakeScene, data)
end

-- 获取16高位
function SL:GetH16Bit(value)
    return H16Bit(value)
end

-- 获取16低位
function SL:GetL16Bit(value)
    return L16Bit(value)
end

-- 添加地图特效
function SL:AddMapSpecialEffect(ID, mapID, sfxId, x, y, loop, showType)
    if not ID or not mapID or not sfxId then
        return
    end
    SL.CustomMapEffects = SL.CustomMapEffects or {}
    SL.CustomMapEffects[mapID] = SL.CustomMapEffects[mapID] or {}

    if type(loop) ~= "boolean" then
        loop = true
    end
    local item = {
        sfxId = sfxId,
        x = x,
        y = y,
        loop = loop,
        isBehind = tonumber(showType) == 0,
        isFront = tonumber(showType) == 1,
    }
    SL.CustomMapEffects[mapID][ID] = item

    local curMapID = SL:GetMetaValue("MAP_ID")
    if curMapID == mapID then
        local isInit  = false
        local actorID = ID
        local mapX = item.x
        local mapY = item.y
        local sfxActor = global.actorManager:GetActor(actorID)
        if not sfxActor then
            isInit = true
            local paramSfx  = {}
            paramSfx.sfxId  = item.sfxId
            paramSfx.isLoop = item.loop
            paramSfx.type   = global.MMO.EFFECT_TYPE_NORMAL
            sfxActor = global.actorManager:CreateActor(actorID, global.MMO.ACTOR_SEFFECT, paramSfx, item.isBehind, item.isFront)
        end

        local actorPos = global.sceneManager:MapPos2WorldPos(mapX, mapY, true)
        sfxActor:setPosition(actorPos.x, actorPos.y)
        global.actorManager:SetActorMapXY(sfxActor, mapX, mapY)

        global.Facade:sendNotification( global.NoticeTable.DelayDirtyFeature, {actorID = actorID, actor = sfxActor})

        if isInit then
            global.sceneEffectManager:AddSceneEffect(sfxActor)
        end
    end
end

-- 删除地图特效
function SL:RmvMapSpecialEffect(ID, mapID)
    if not ID or not mapID then
        return
    end

    local curMapID = SL:GetMetaValue("MAP_ID")
    local sceneImprisonEffectProxy = global.Facade:retrieveProxy(global.ProxyTable.SceneImprisonEffectProxy)
    if curMapID == mapID then
        global.sceneEffectManager:RmvSceneEffect(ID)
        global.actorManager:RemoveActor(ID)
        sceneImprisonEffectProxy:RmImprison(ID)
    end

    if SL.CustomMapEffects and SL.CustomMapEffects[mapID] then
        SL.CustomMapEffects[mapID][ID] = nil
    end

end


--- 添加actor特效
---@param actorID string actor id
---@param sfxID integer 特效id
---@param isFront boolean 是否在模型前  默认在前面
---@param offX integer x偏移
---@param offY integer y偏移
function SL:AddActorEffect(actorID, sfxID, isFront, offX, offY)
    -- body
    if isFront == nil then
        isFront = true
    end
    local data =
    {
        actorID = actorID,
        sfxID   = tonumber(sfxID),
        frame   = 0,
        speed   = 1,
        count   = 0,
        front   = isFront,
        offsetX = offX or 0,
        offsetY = offY or 0,
    }
    global.ActorEffectManager:AddEffect(data)
end

--- 删除actor特效
---@param actorID string actor id
---@param sfxID integer 特效id
function SL:RmvActorEffect(actorID, sfxID)
    -- body
    local data  = {
        actorID = actorID,
        sfxID   = sfxID,
    }
    global.ActorEffectManager:RmvEffect(data)
end
---------------------------------------------------------------------------

-- 切页
function SL:SkipPage(data, key)
    local CodeDOMUIProxy = global.Facade:retrieveProxy(global.ProxyTable.CodeDOMUIProxy)
    CodeDOMUIProxy:SkipPage(data, key)
end

-- 强攻
function SL:ForceAttack()
    global.Facade:sendNotification(global.NoticeTable.LaunchAttackSkill)
end

-- GBK转UTF8编码
function SL:UTF8ToGBK(str)
    if UTF8ToGB2312 then
        return UTF8ToGB2312(str)
    end
end

-- UTF8转GBK编码
function SL:GBKToUTF8(str)
    if GB2312ToUTF8 then
        return GB2312ToUTF8(str)
    end
end

-- 搜索路径下所有文件(path: dev下面的文件路径; 例如："res/")
function SL:GetFilesByPath(path)
    local fileUtil      = global.FileUtilCtl
    local resourcePath  = fileUtil:getDefaultResourceRootPath()
    local mCachePath    = global.L_ModuleManager:GetCurrentModule():GetSubModPath()
    local mStabPath     = global.L_ModuleManager:GetCurrentModule():GetStabPath()

    local directory     = "dev/"  .. path
    local exportFolder  = resourcePath .. mStabPath  .. path
    local exportFolder2 = resourcePath .. mCachePath .. path
    local GMFolder      = resourcePath .. directory
    local cacheFolder   = fileUtil:getWritablePath() .. mCachePath .. path
    local cacheFolder2  = fileUtil:getWritablePath() .. mStabPath  .. path


    local GetFileName = function (str)
        local rerStr = string.reverse(str)
        local _, i   = sfind(rerStr, "/")
        local len    = slen(str)
        local st     = len - i + 2
        return ssub(str, st, len)
    end

    local files = {}
    local items = {}

    local iflag = {}
    local fflag = {}
    for _, path in ipairs({GMFolder, cacheFolder, exportFolder, cacheFolder2, exportFolder2}) do
        repeat
            if not fileUtil:isDirectoryExist(path) then --遍历不存在的目录在ios上会崩溃
                break
            end
            local listfiles = fileUtil:listFiles(path)
            for k, info in ipairs(listfiles) do
                -- 去掉末尾可能出现的 /
                info = sgsub(info, "[/]+$", "")

                local filename = GetFileName(info)
                if filename and not sfind(filename, "^%.") then
                    
                    if fileUtil:isDirectoryExist(info) then -- 是否是文件夹
                        if not fflag[filename] then
                            files[#files + 1] = filename
                            fflag[filename] = true
                        end
                    else
                        if not iflag[filename] then
                            items[#items + 1] = filename
                            iflag[filename] = true
                        end
                    end
                end
            end
        until true
    end

    tsort(files, function (a, b) return supper(a) < supper(b) end)
    tsort(items, function (a, b) return supper(a) < supper(b) end)

    for i, v in ipairs(items) do
        files[#files + 1] = v
    end

    return files
end