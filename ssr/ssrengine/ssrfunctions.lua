ssr = ssr or {}

local tconcat = table.concat
local tinsert = table.insert
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
local cjson = require("cjson")

_SSR_DEBUG = false
if global.isGMMode or global.isDebugMode then
    _SSR_DEBUG = true
end

------------------------------------------------------------
ssr.ssrBridge  = require("ssr/ssrengine/ssrBridge").new()
ssr.GuideTask  = requireGuide("SGuideTask")
ssr.ssrBridge.LUAEvent = {}

-------------------------------------------------------------
-- mapping
ssr.Layer       = cc.Layer
ssr.Text        = ccui.Text
ssr.TextInput   = ccui.EditBox
ssr.TextAtlas   = ccui.TextAtlas
ssr.Button      = ccui.Button
ssr.Slider      = ccui.Slider
ssr.ImageView   = ccui.ImageView
ssr.LoadingBar  = ccui.LoadingBar
ssr.Widget      = ccui.Widget
ssr.Layout      = ccui.Layout
ssr.ListView    = ccui.ListView
ssr.CheckBox    = ccui.CheckBox
ssr.PageView    = ccui.PageView
ssr.Animation   = cc.Animation
ssr.Animate     = cc.Animate
ssr.Sprite      = cc.Sprite

ssr.UserData    = UserData
ssr.ItemShow    = GoodsItem
ssr.RichText    = require("util/RichTextHelp")
ssr.ItemBox     = SItemBox
-------------------------------------------------------------

-------------------------------------------------------------
ssr.isWindows   = global.isWindows
ssr.isAndroid   = global.isAndroid
ssr.isIOS       = global.isIOS
ssr.isMobile    = global.isMobile
-------------------------------------------------------------

-------------------------------------------------------------
ssr.schedule = schedule
ssr.performWithDelay = performWithDelay
ssr.random = Random
-------------------------------------------------------------

-------------------------------------------------------------
function ssr._registerObj(obj)
    ssr.ssrBridge:_registerObj(obj)
end
-------------------------------------------------------------

-------------------------------------------------------------
-- 处理加密问题，开发模式下不可以获取加密的字符
if _SSR_DEBUG then
    local fileUtils = cc.FileUtils:getInstance()
    function fileUtils:getDataFromFile(filePath)
        local bpos, epos = string.find(filePath, "scripts/ssr/ssrgame/")
        if bpos and epos then
            return fileUtils:getDataFromFileOrigin(filePath)
        end
        return getmetatable(self).getDataFromFile(self, filePath)
    end
    function fileUtils:getDataFromFileEx(filePath)
        return fileUtils:getDataFromFile(filePath)
    end
end

-------------------------------------------------------------

-- print info
function ssr.print(...)
    if _SSR_DEBUG then
        release_print(...)
    end
end

function ssr.PrintTable(root)
    if not _SSR_DEBUG then
        return nil
    end

    if nil == root then
        ssr.print("nil")
        return nil
    end

    local cache = {[root] = "."}
    local function _dump(t, space, name)
        local temp = {}
        local value = ""
        local tempStr = ""
        local endPos = nil
        for k, v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                tinsert(temp, "+" .. key .. " {" .. cache[v] .. "}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                tinsert(temp, "+" .. key .. _dump(v, space .. (next(t, k) and "|" or " ") .. srep(" ", #key), new_key))
            else
                value = tostring(v)
                if nil == value then
                    tempStr = "nil"
                else
                    endPos = sfind(value, "\0")
                    if endPos == nil then
                        tempStr = value
                    elseif endPos == 1 then
                        tempStr = ""
                    else
                        tempStr = ssub(value, 1, endPos)
                    end
                end

                tinsert(temp, "+" .. key .. " : " .. tempStr)
            end
        end
        return tconcat(temp, "\n" .. space)
    end
    ssr.print("Table:" .. tostring(root) .. "\n" .. _dump(root, "", ""))
end

function ssr.PrintTraceback()
    local traceback = string.split(debug.traceback("", 2), "\n")
    ssr.PrintTable(traceback)
end

function ssr.LoadTxt(path, delimiter, callback)
    if nil == path or nil == callback then
        print("LoadText error")
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

                callback(dataTable)
            end
        end
    end
end

function ssr.Schedule(callback, interval)
    return global.Scheduler:scheduleScriptFunc(callback, interval, false)
end

function ssr.UnSchedule(scheduleID)
    global.Scheduler:unscheduleScriptEntry(scheduleID)
end

function ssr.PerformWithDelayGlobal(callback, time)
    local handle = nil
    handle = 
    global.Scheduler:scheduleScriptFunc(
        function()
            global.Scheduler:unscheduleScriptEntry(handle)
            callback()
        end,
        time,
        false
    )
    return handle
end

function ssr.UIQuickChild(nativeUI)
    if (nativeUI == nil) then
        return nil
    end
    local function getChildInSubNodes(nodeTable, key)
        if #nodeTable == 0 then
            return nil
        end
        local child = nil
        local subNodeTable = {}
        for _, v in ipairs(nodeTable) do
            child = v:getChildByName(key)
            if (child) then
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
        return getChildInSubNodes({parent}, key)
    end

    local tt = {
        __index = function(t, k)
            local u = getChildByKey(t.nativeUI, k)
            rawset(t, k, u)
            return u
        end
    }
    local r = {["nativeUI"] = nativeUI}
    setmetatable(r, tt)
    return r
end

function ssr.getVisibleSize()
    return cc.Director:getInstance():getVisibleSize()
end

function ssr.getWinWidth()
    return cc.Director:getInstance():getVisibleSize().width
end

function ssr.getWinHeight()
    return cc.Director:getInstance():getVisibleSize().height
end

function ssr.encodeJson( table )
    if not table then
        return nil
    end
    local jsonStr = cjson.encode(table)
    return jsonStr
end

function ssr.decodeJson( jsonStr )
    if not jsonStr then
        return nil
    end
    local tableData = cjson.decode(jsonStr)
    return tableData
end

function ssr.requireSSRGame(path)
    return require("ssr/ssrgame/" .. path)
end

function ssr.tonumber(e, base)
    return tonumber(e, base)
end

function ssr.SecondToHMS(sec, isToStr, isSimple)
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

function ssr.TimeFormatToStr( time )
    return TimeFormatToString(time)
end

function ssr.GetColorFromHexString( hexString )
    return GetColorFromHexString(hexString)
end

function ssr.GetColorHexFromRGB( rgb )
    return GetColorHexFromRBG(rgb)
end

function ssr.GetColorByStyleId( id )
    return GET_COLOR_BYID_C3B(id)
end

function ssr.SetColorStyle(widget, colorID)
    SET_COLOR_STYLE(widget, colorID)
end

function ssr.GetColorHexByStyleId( id )
    return GET_COLOR_BYID(id)
end

function ssr.GetSizeByStyleId(id)
    return GET_SIZE_BYID(id)
end

function ssr.GetSimpleNumber(n)
    if n >= 100000000 then
        return string.format("%.2f%s", n/100000000, GET_STRING(1045))
    end
    if n >= 100000 then
        return string.format("%d%s", n/10000, GET_STRING(1005))
    end
    if n >= 10000 then
        return string.format("%.2f%s", n/10000, GET_STRING(1005))
    end
    return tostring(n)
end

function ssr.GetThousandSepString( num )
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

function ssr.SplitStr(inputStr,  delimiter)
    inputStr = tostring(inputStr)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(inputStr, delimiter, pos, true) end do
        table.insert(arr, string.sub(inputStr, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(inputStr, pos))
    return arr
end

function ssr.SplitStrFirst( inputStr, delimiter )
    inputStr = tostring(inputStr)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    local st, sp = string.find(inputStr, delimiter, pos, true)
    if st and sp then
        table.insert(arr, string.sub(inputStr, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(inputStr, pos))
    return arr
end

function ssr.max(value1, value2)
    return math.max( value1, value2 )
end

function ssr.min(value1, value2)
    return math.min( value1, value2 )
end

function ssr.ceil(value)
    return math.ceil( value )
end

function ssr.floor(value)
    return math.floor( value )
end

function ssr.abs( value )
    return math.abs( value )
end

function ssr.encodeBase64(source_str)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((source_str:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#source_str%3+1])
end

function ssr.decodeBase64(source_str)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    source_str = string.gsub(source_str, '[^'..b..'=]', '')
    return (source_str:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

function ssr.urlencode(input)
    local function urlencodechar(char)
        return "%" .. string.format("%02X", string.byte(char))
    end
    -- convert line endings
    input = string.gsub(tostring(input), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
    -- convert spaces to "+" symbols
    return string.gsub(input, " ", "+")
end

function ssr.urldecode(input)
    input = string.gsub (input, "+", " ")
    input = string.gsub (input, "%%(%x%x)", function(h) return string.char(tonumber(h, 16) or 0) end)
    input = string.gsub (input, "\r\n", "\n")
    return input
end

function ssr.getFileMD5( filePath )
    if not global.FileUtilCtl:isFileExist(filePath) then
        return nil
    end
    filePath = global.FileUtilCtl:isFileExist(filePath) and global.FileUtilCtl:fullPathForFilename(filePath)
    local cmd = "certutil -hashfile "..filePath.." MD5"
	local t = io.popen(cmd)

    local i = 0
    local str_md5
    for line in t:lines() do
        i = i + 1 
        if i == 2 then 
            str_md5 = line
        end
    end
    
    return str_md5
end

function ssr.getStrMD5( str )
    return get_str_MD5(str)
end

function ssr.IsWinMode( ... )
    return global.isWinPlayMode
end

function ssr.HTTPRequestPost(url, callback, data, header)
    local httpRequest = cc.XMLHttpRequest:new()
    httpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    httpRequest.timeout = 100000 -- 10 s
    httpRequest:open("POST", url)
    if header then
        for k, v in pairs(header) do
            httpRequest:setRequestHeader(k, v)
        end
    end

    if callback then
        local function HttpResponseCB()
            local code = httpRequest.status
            local success = code >= 200 and code < 300
            local response = httpRequest.response

            release_print("ssr.HTTPRequestPost Code:" .. tostring(code))
            callback(success, response, code)
        end
        httpRequest:registerScriptHandler(HttpResponseCB)
    end

    httpRequest:send(data)
end

function ssr.HTTPRequest(url, callback)
    local httpRequest = cc.XMLHttpRequest:new()
    httpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    httpRequest.timeout = 100000 -- 10 s
    httpRequest:open("GET", url)

    if callback then
        local function HttpResponseCB()
            local code = httpRequest.status
            local success = code >= 200 and code < 300
            local response = httpRequest.response

            release_print("ssr.HTTPRequest Code:" .. tostring(code))
            callback(success, response)
        end

        httpRequest:registerScriptHandler(HttpResponseCB)
    end

    httpRequest:send()
end

function ssr.HPUnit( hp, pointBit )
    return SL:HPUnit( hp, pointBit )
end

-------------------------------------------------------------
--- game functions
function ssr.getBagData()
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local bagData = BagProxy:GetBagData()
    return clone(bagData)
end

function ssr.getCurBagData()
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local bagData = BagProxy:GetBagData()
    return bagData
end

function ssr.GetMaxBag()
    local BagProxy = global.Facade:retrieveProxy( global.ProxyTable.Bag )
    return BagProxy:GetMaxBag()
end

function ssr.getQuickUseData()
    local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
    local quickData = QuickUseProxy:GetQuickUseData()
    return clone(quickData)
end

function ssr.getEquipData()
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local quipData = EquipProxy:GetEquipData()
    return clone(quipData)
end

function ssr.getEquipDataByPos(pos)
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    return EquipProxy:GetEquipDataByPos(pos)
end

function ssr.createSFXAnim(id)
    return global.FrameAnimManager:CreateSFXAnim(id)
end

function ssr.createSkillAnim(id, dir)
    return global.FrameAnimManager:CreateSkillEffAnim(id, dir)
end

function ssr.createNpcAnim(id)
    return global.FrameAnimManager:CreateActorNpcAnim(id)
end

function ssr.createMonsterAnim(id, act)
    act = act or 0
    return global.FrameAnimManager:CreateActorMonsterAnim(id, act)
end

function ssr.createPlayerAnim(id, sex, act)
    act = act or 0
    sex = sex or 0
    return global.FrameAnimManager:CreateActorPlayerAnim(id, sex, act)
end

function ssr.createWeaponAnim(id, sex, act)
    act = act or 0
    sex = sex or 0
    return global.FrameAnimManager:CreateActorPlayerWeaponAnim(id, sex, act)
end

function ssr.createWingsAnim(id, sex, act)
    act = act or 0
    sex = sex or 0
    return global.FrameAnimManager:CreateActorPlayerWingsAnim(id, sex, act)
end

function ssr.createHairAnim(id, sex, act)
    act = act or 0
    sex = sex or 0
    return global.FrameAnimManager:CreateActorPlayerHairAnim(id, sex, act)
end

function ssr.getSelectedRoleID()
    local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    return LoginProxy:GetSelectedRoleID()
end

function ssr.getMainPlayerID()
    return global.gamePlayerController:GetMainPlayerID()
end

function ssr.getBuffByActorID(actorID)
    return global.BuffManager:GetDataByUID(actorID)
end

function ssr.checkHaveOnBuff(actorID, buffID)
    return global.BuffManager:IsHaveOneBuff(actorID, buffID)
end

function ssr.findBuffConfigByID(buffID)
    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    return BuffProxy:GetConfigByID(buffID)
end

function ssr.getPlayerSkills(noBasicSkill, activeOnly)
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    return SkillProxy:GetSkills(noBasicSkill, activeOnly)
        -- 已有技能数据 param1:是否排除普攻  param2:是否只获取主动技能
end

function ssr.CreateStaticUIModel(sex, feature,scale)
    return CreateStaticUIModel(sex, feature,scale, {ignoreStaticScale = true})
end

function ssr.GetOpenServerDay()
    local ServerTimeProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerTimeProxy)
    local openDay = ServerTimeProxy:GetOpenDay() or 0
    return openDay
end

function ssr.GetOpenServerTime()
    local ServerTimeProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerTimeProxy)
    local openTime = ServerTimeProxy:GetOpenTime() or 0
    return openTime
end

function ssr.GetServerTime()
    return GetServerTime()
end

function ssr.IsInMapSafeArea()
    local MapProxy = global.Facade:retrieveProxy( global.ProxyTable.Map )
    return MapProxy:IsInSafeArea()
end

function ssr.IsRoleAlive()
    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    return PlayerProperty:IsAlive()
end

function ssr.GetRoleLevel()
    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    return PlayerProperty:GetRoleLevel()
end

function ssr.GetRoleReinLv()
    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    return PlayerProperty:GetRoleReinLv() or 0
end

function ssr.ShowSystemTips(str)
    global.Facade:sendNotification(global.NoticeTable.SystemTips, str)
end

function ssr.UseItemByIndex(Index)
    return UseItemByIndex(Index)
end

function ssr.UseItemByItemData(item)
    local ItemUseProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemUseProxy)
    ItemUseProxy:UseItem(item)
end

function ssr.RequestChangePKState(modeType)
    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    PlayerProperty:RequestChangePKMode(modeType)
end

function ssr.JumpToLayer(hyperlinkID, param)
    JUMPTO(hyperlinkID, param)
end

function ssr.CloseLayer(hyperlinkID, isOpen, param)
    local JumpProxy = global.Facade:retrieveProxy(global.ProxyTable.JumpProxy)
    local param1 = 2
    if isOpen then
        param1 = 1
    end
    JumpProxy:JumpTo(hyperlinkID, param, param1)
end

function ssr.OpenTargetFuncDockLayer(targetID, pos)
    if not targetID  or not pos then
        return
    end
    local target = global.actorManager:GetActor(targetID)
    if not target then
        return
    end

    if target:IsPlayer() then
        local FuncDockProxy = global.Facade:retrieveProxy(global.ProxyTable.FuncDockProxy)
        local data = {}
        data.type        = FuncDockProxy.FuncDockType.Func_Player_Head
        data.anchorPoint = cc.p(0, 1)
        data.pos         = cc.p(pos.x or 200, pos.y or 200)
        data.targetName  = target:GetName()
        data.targetId    = target:GetID()

        if target:IsHumanoid() then
            data.type = FuncDockProxy.FuncDockType.Func_Monster_Head
            global.Facade:sendNotification(global.NoticeTable.Layer_Func_Dock_Open, data)
        else
            global.Facade:sendNotification(global.NoticeTable.Layer_Func_Dock_RequsetInfo, data)
        end
        
    end
end

function ssr.TakeOnEquipRequest(itemData, pos)
    global.Facade:sendNotification(global.NoticeTable.TakeOnRequest,
                {
                    itemData = itemData,
                    pos = pos
                }
    )
end

function ssr.TakeOffEquipRequest( itemData)
    global.Facade:sendNotification(global.NoticeTable.TakeOffRequest, itemData)
end

function ssr.SendJsonMsg(action, method, data)
    if not action then
        ssr.print("SendJsonMsg ERROR, invalid action")
        return nil
    end
    if not method then
        ssr.print("SendJsonMsg ERROR, invalid method")
        return nil
    end
    global.JsonProtoHelper:SendMsg(action, method, data)
end

function ssr.RegisterJsonMsgHandler(action, handler)
    global.JsonProtoHelper:RegisterJsonHandler(action, handler)
end

function ssr.ShowLoadingBar(time)
    ShowLoadingBar(time)
end

function ssr.HideLoadingBar()
    HideLoadingBar()
end

function ssr.AddToSkillActivePanel( widget )
    global.Facade:sendNotification(global.NoticeTable.Skill_PanelActive_AddChild, widget)
end

function ssr.AddToSkillPanel( widget )
    global.Facade:sendNotification(global.NoticeTable.Skill_PanelSkill_AddChild, widget)
end

function ssr.ShowLocalNoticeByType(jsonData)
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
            -- Label       = jsonData.Label
            X           = jsonData.X,
            isDelete    = jsonData.isDelete,
        }
        global.Facade:sendNotification(global.NoticeTable.ShowTimerNoticeXY, data)
    end
end

function ssr.OpenCommonTipLayer( str, btnDesc, callback , extend)
    if not str then
        return
    end
    local data = {}
    data.str = str

    if btnDesc then
        data.btnDesc = btnDesc
    end
    if callback then
        data.callback = callback
    end
    if extend and next(extend) then
        for key, value in pairs(extend) do
            data[key] = value
        end
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)

end

function ssr.StoreBuyTipsOpen( idx , limitStr)
    StoreBuyTipsOpen(idx, limitStr)
end

function ssr.BuyStoreItemsById( storeIndex, count)
    if not storeIndex or not count then
        return
    end
    local PageStoreProxy = global.Facade:retrieveProxy(global.ProxyTable.PageStoreProxy)
    local storeData = PageStoreProxy:GetItemDataByStoreIndex(storeIndex)
    if not storeData or next(storeData) == nil then
        return
    end
    local canBy = PageStoreProxy:CheckStoreLimitStatus(storeIndex)
    if not canBy then
        return
    end
    local ConditionProxy = global.Facade:retrieveProxy(global.ProxyTable.ConditionProxy)
    if not ConditionProxy:CheckCondition(storeData.Condition) then
        return
    end

    PageStoreProxy:RequestBuy(storeData.Index, count )
end


function ssr.OnQuickSelectTarget( type )
    if not type then
        return
    end

    local data = {}
    data.type = tonumber(type) == 1 and global.MMO.ACTOR_PLAYER or global.MMO.ACTOR_MONSTER 
    data.systemTips = false
    data.imgNotice = true
    global.Facade:sendNotification(global.NoticeTable.QuickSelectTarget, data)
end

function ssr.SetMainPropertyPanelVisible(state)
end

function ssr.GetBatteryPercent()
    local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    local battery  = envProxy:GetBatteryLevel()
    return tonumber(battery)
end

function ssr.GetCurExpAndMaxValue()
    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local data = {}
    data.curExp  = PlayerProperty:GetCurrExp()
    data.maxExp  = PlayerProperty:GetNeedExp()
    return data
end

function ssr.GetItemDataByMakeIndex(MakeIndex)
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local itemData = BagProxy:GetItemDataByMakeIndex(MakeIndex)
    if not itemData then
        local EquipProxy    = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        itemData            = EquipProxy:GetEquipDataByMakeIndex(MakeIndex)
    end
    return itemData
end

function ssr.AddExtraWidgetToTips(widget, Index )
    local ItemTipsProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemTipsProxy)
    if not Index or not tonumber(Index) then
        return
    else
        ItemTipsProxy:AddExtraWidgetByIndex(widget, Index)
    end
    
end

function ssr.GetMoneyCountById(id)
    local MoneyProxy = global.Facade:retrieveProxy(global.ProxyTable.MoneyProxy)
    local goldCount = MoneyProxy:GetMoneyCountById(id)
    return goldCount
end

function ssr.GetItemConfigData()
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local itemConfig  = ItemConfigProxy:GetItemConfigData()
    return itemConfig
end

function ssr.RefreshBagPos( ... )
    ResetBagPos()
end

function ssr.SendGMMsgToChat( msg )
    local input     = string.format("@%s", msg)
    local sendData  = {mt = 1, msg = input, channel = 2}
    global.Facade:sendNotification(global.NoticeTable.SendChatMsg, sendData)
end

function ssr.SendMsgToChat( mt, msg, channel, isEquip)
    -- 后台控制不可聊天
    if IsForbidSay(true) then
        return
    end
    
    local sendData = {mt = mt, msg = msg, channel = channel}
    if mt and mt == 3 then
        if msg and msg.chatshow == 1 then
            print("此物品在聊天不可见！！")
            return
        end
        local item = clone(msg)
        if isEquip then
            item.wore  = true
        end
        sendData.msg = item
    end
    global.Facade:sendNotification(global.NoticeTable.SendChatMsg, sendData)
end

function ssr.CreateExport( filename )
    local ui = require(filename).create()
    if ui.root then
        local new_widget = ccui.Widget:create()
        new_widget:setAnchorPoint(cc.p(0, 0))

        local children = ui.root:getChildren()
        for _, child in pairs(children) do
            child:removeFromParent()
        end
        for _, child in pairs(children) do
            new_widget:addChild(child)
        end

        local name = ui.root:getName()
        -- 自适应代码
        if name ~= "Layer" and name ~= "Node" then
            local visible = cc.Director:getInstance():getVisibleSize()
            new_widget:setContentSize(visible)
            ccui.Helper:doLayout(new_widget)
        else
            new_widget:setContentSize(ui.root:getContentSize())
        end

        rawset(ui, "root", new_widget)
        return new_widget, ui
    end
    return nil
end

function ssr.ReturnLogin(isForce)
    if not isForce then
        local function callback(bType, custom)
            if bType == 1 then
                global.L_NativeBridgeManager:GN_accountLogout()
                global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
            end
        end
        local data = {}
        data.str = GET_STRING(700000110)
        data.btnDesc = {GET_STRING(1001), GET_STRING(1000)}
        data.callback = callback
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
    else
        global.L_NativeBridgeManager:GN_accountLogout()
        global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
    end
end

function ssr.SetBagItemChoose( data )
    global.Facade:sendNotification(global.NoticeTable.Bag_Item_Choose_State, data)
end

function ssr.DoLayout(widget)
    ccui.Helper:doLayout(widget)
end

function ssr.GetPlayerSkillDataById(skillID)
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    return SkillProxy:GetSkillByID(skillID)
end

function ssr.PrivateChatWithTarget( targetId, targetName )
    if not targetId or not targetName then
        return 
    end
    global.Facade:sendNotification(global.NoticeTable.PrivateChatWithTarget, {name = targetName, uid = targetId})
end

function ssr.InviteAddTeam( targetId )
    if not targetId then
        return 
    end
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    TeamProxy:RequestInvite(targetId)
end

function ssr.ApplyInTeam( targetId )
    if not targetId then
        return 
    end
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    TeamProxy:RequestApply(targetId)
end

function ssr.InviteAddGuild( targetId )
    if not targetId then
        return 
    end
    local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    GuildProxy:RequestGuildInviteOther(targetId)
end

function ssr.AddFriend( targetId, targetName)
    if not targetId or not targetName then
        return 
    end
    local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
    FriendProxy:requestAddFriend( targetId, targetName)
end

function ssr.DeleteFriend( targetId, targetName, tips)
    if not targetId or not targetName then
        return 
    end
    local function RequestDelete( ... )
        local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
        FriendProxy:requestDelFriend( targetId, targetName )
    end
    if tips then
        local data    = {}
        data.btnType  = 2
        data.str      = string.format(GET_STRING( 300000015 ), targetName)
        data.callback = function(type)
            if 1 == type then
                RequestDelete()
            end
        end
        global.Facade:sendNotification( global.NoticeTable.Layer_CommonTips_Open, data )
    else
        RequestDelete()
    end
end

function ssr.AddToBlackList( targetId, targetName)
    if not targetId or not targetName then
        return 
    end
    local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
    FriendProxy:requestAddBlackList( targetId, targetName )
end

function ssr.OutFromBlackList( targetId, targetName)
    if not targetId or not targetName then
        return 
    end
    local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
    FriendProxy:requestOutBlackList( targetId, targetName )
end

function ssr.SendTradeRequest( targetId, targetName )
    if not targetId or not targetName then
        return 
    end
    local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
    TradeProxy:SendTradeRequest(targetId, targetName)
end

function ssr.LookPlayerInfo( targetId )
    local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    if mapProxy:IsForbidVisitPlayer() then
        ShowSystemChat(GET_STRING(30001071), 255, 249)
        return
    end
    
    local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
    LookPlayerProxy:RequestPlayerData(targetId)
end

function ssr.GetTeamMembers( ... )
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    return TeamProxy:GetTeamMember()
end

function ssr.RequestGuildMembersList( ... )
    local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    GuildProxy:RequestMemberList()
end

function ssr.GetGuildMembers( ... )
    local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    return GuildProxy:GetMemberList()
end

function ssr.IsFileExist( filePath )
    return global.FileUtilCtl:isFileExist(filePath)
end

function ssr.AFKBegin( ... )
    local AutoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    if AutoProxy:IsAFKState() then
        LuaSendMsg(global.MsgType.MSG_CS_AUTOPLAYGAME_REQUEST,2)
        global.Facade:sendNotification(global.NoticeTable.AFKEnd)
    else
        LuaSendMsg(global.MsgType.MSG_CS_AUTOPLAYGAME_REQUEST,1)
        global.Facade:sendNotification(global.NoticeTable.AFKBegin)
    end
end

function ssr.AFKEnd( ... )
    LuaSendMsg(global.MsgType.MSG_CS_AUTOPLAYGAME_REQUEST,2)
    global.Facade:sendNotification(global.NoticeTable.AFKEnd)
end

function ssr.AttachOrUnAttachSUI( data )
    global.Facade:sendNotification(global.NoticeTable.SUIComponentAttachBySSR, data)
end

function ssr.CheckSettingValue( id, allValue )
    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    return GameSettingProxy:GetValue(id, allValue)
end

function ssr.ChangeSettingValue( id, value )
    CHANGE_SETTING(id, value)
end

function ssr.SetSkillKey(skillID, key)
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    SkillProxy:SetSkillKey(skillID, key)
end

function ssr.DeleteSkillKey(skillID)
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    SkillProxy:DelSkillKey(skillID)
end

function ssr.GetSkillKey(skillID)
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    return SkillProxy:GetSkillKey(skillID)
end

function ssr.GetActorStallStatus( actorID )
    local playerActor = global.actorManager:GetActor(actorID)
    return playerActor and playerActor:IsStallStatus() 
end

function ssr.GetSkillConfig()
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local config = SkillProxy:GetConfigs()
    return clone(config)
end

function ssr.OnLaunchSkill(skillID)

    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    local destPos = inputProxy:getCursorMapPosition()
    if global.isWinPlayMode then
        global.Facade:sendNotification(global.NoticeTable.UserInputLaunch, {skillID = skillID, destPos = destPos})
    else
        global.Facade:sendNotification(global.NoticeTable.UserInputLaunch, {skillID = skillID, priority = global.MMO.LAUNCH_PRIORITY_USER})
    end
end

function ssr.GetTitleList()
    local PlayerTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerTitleProxy)
    local titleListData = PlayerTitleProxy:getTitleList()
    return clone(titleListData)
end

function ssr.GetMetaValueByKey(key, param)
    local MetaValueProxy = global.Facade:retrieveProxy(global.ProxyTable.MetaValueProxy)
    return MetaValueProxy:GetValueByKey(key, param)
end

function ssr.PrintMetaKey( ... )
    local MetaValueProxy = global.Facade:retrieveProxy(global.ProxyTable.MetaValueProxy)
    MetaValueProxy:PrintMetaKey()
end

function ssr.GetNetType( ... )
    local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    return envProxy:GetNetType()
end

function ssr.GetBatteryLevel( ... )
    local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    return envProxy:GetBatteryLevel()
end

function ssr.Screen2World( srcPos )
    return Screen2World(srcPos)
end

function ssr.World2Screen( srcPos )
    return World2Screen(srcPos)
end

function ssr.WorldPos2MapPos( worldPos )
    local mapPos = {}
    mapPos.x = math.floor(worldPos.x / global.MMO.MapGridWidth)
    mapPos.y = math.floor(-worldPos.y / global.MMO.MapGridHeight)
    return mapPos
end

function ssr.MapPos2WorldPos(  mapPos, centerOfGrid  )
    if not mapPos or not next(mapPos) then
        return nil
    end
    
    local worldPos = cc.p( mapPos.x * global.MMO.MapGridWidth, -mapPos.y * global.MMO.MapGridHeight )

    if centerOfGrid then
        worldPos.x = worldPos.x + global.MMO.MapGridWidth * 0.5
        worldPos.y = worldPos.y - global.MMO.MapGridHeight * 0.5
    end

    return worldPos
end

function ssr.OpenItemTips(data)
    global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, data)
end

function ssr.GetCurLookPlayerEquipData(pos)
    local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
    if pos and tonumber(pos) then 
        local equipItem = LookPlayerProxy:GetLookPlayerItemDataByPos(pos) 
        return clone(equipItem)
    end
    local data =  LookPlayerProxy:GetLookPlayerItemPosData()
    return clone(data)
end

function ssr.GetMainPlayerBaseData( ... )
    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local data = {}
    data.roleJob    = PlayerProperty:GetRoleJob()
    data.sex        = PlayerProperty:GetRoleSex()
    data.level      = PlayerProperty:GetRoleLevel()
    data.reinLv     = PlayerProperty:GetRoleReinLv() or 0
    data.name       = PlayerProperty:GetName()
    data.pkMode     = PlayerProperty:GetPKMode()
    data.curHP      = PlayerProperty:GetRoleCurrHP()
    data.maxHP      = PlayerProperty:GetRoleMaxHP()
    data.curMP      = PlayerProperty:GetRoleCurrMP()
    data.maxMP      = PlayerProperty:GetRoleMaxMP()
    data.curExp     = PlayerProperty:GetCurrExp()
    data.maxExp     = PlayerProperty:GetNeedExp()


    return data
end

function ssr.GetRoleAttrByType(type)
    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    return PlayerProperty:GetRoleAttrByType(type)
end

function ssr.GetItemBoxDataByIndex( boxindex )
    local SSRUIManager = global.Facade:retrieveMediator("SSRUIManager")
    return SSRUIManager:GetItemDataByboxIndex(boxindex)
end

function ssr.RemoveItemBoxDataByIndex( boxindex )
    global.Facade:sendNotification(global.NoticeTable.SSR_ITEMBOXWidget_Remove, {boxindex = boxindex})
end

function ssr.ClearTarget( ... )
    local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    inputProxy:ClearTarget()
end

function ssr.AddBubbleTips( data )
    global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, data)
end

function ssr.IsMainSkillPanelShow( ... )
    return false
end

function ssr.IsInBlackList( uid )
    if not uid then return false end
    local friendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
    if friendProxy:getBlacklistDataByUid(uid) then
        return true
    end
    return false
end

function ssr.IsMyFriend( uid )
    if not uid then return false end
    local friendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
    if friendProxy:getFriendDataByUid(uid) then
        return true
    end
    return false
end

function ssr.IsMyTeamMember( uid )
    if not uid then return false end
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    if TeamProxy:IsTeamMember(uid) then
        return true
    end
    return false
end

function ssr.GetMainPlayerMapPos()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return false
    end
    return  cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())
end

function ssr.SendCodeToExchange(convertID)
    if not convertID then
        return
    end
    local CDKProxy = global.Facade:retrieveProxy(global.ProxyTable.CDKProxy)
    CDKProxy:SendHTTPRequestPost(convertID)
end

function ssr.GetPlayerFeature()
    local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    return PlayerPropertyProxy:GetFeature()
end

function ssr.CheckEquipPowerThanSelf(itemInfo, from)
    return CheckEquipPowerThanSelf(itemInfo, from)
end

function ssr.CreateTextInputByTextField( textField )
    if not textField  or tolua.isnull(textField) then
        return
    end
    return CreateEditBoxByTextField(textField)
end

function ssr.IsBagToFull(isTips)
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    return BagProxy:isToBeFull(isTips)
end

function ssr.OpenSplit(itemData)
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

function ssr.IntoDropItem(itemData)
    if not itemData or not next(itemData) then
        return 
    end
    global.Facade:sendNotification(global.NoticeTable.IntoDropItem, itemData)
end

function ssr.putOutStorageItem(itemData)
    if not itemData or not next(itemData) then return end
    local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
    NPCStorageProxy:RequestPutOutStorageData(itemData.MakeIndex, itemData.Name)
end

function ssr.putInStorageItem( itemData )
    if not itemData or not next(itemData) then return end
    local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
    NPCStorageProxy:RequestSaveToStorageAllPage(itemData.MakeIndex, itemData.Name)
end

function ssr.CheckConditionInfo(condition)
    local ConditionProxy = global.Facade:retrieveProxy(global.ProxyTable.ConditionProxy)
    return ConditionProxy:CheckCondition(condition) 
end

function ssr.GetNeedReinLvOrLevel( Need, needLevel, isLevel)
    if not Need or not needLevel then
        return
    end
    if not isLevel then -- 转生等级
        if Need == 45 or Need >= 40 then
            local reinLv = Need >= 40 and L16Bit(needLevel) or H16Bit(needLevel)
            return reinLv
        end
    elseif isLevel == 1 then -- 等级
        if Need == 10 then
            return H16Bit(needLevel)
        elseif Need == 14 then
            return needLevel
        end
    end
end

function ssr.GetHaveTitleDataById( id )
    if not id then return end
    local PlayerTitleProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerTitleProxy)
    local titleData = PlayerTitleProxy:getTitleData()[id]
    return titleData
end

function ssr.CloseLookPlayerLayer( isHero )
    if isHero then
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Close_Hero)
    else
        global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Close)
    end
end

function ssr.CloseItemTips( ... )
    global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)
end

function ssr.OpenAutoUseTip( itemData, equipPos, isBook, isBestRing , isHero)
    global.Facade:sendNotification( global.NoticeTable.Layer_Auto_Use_Attach, 
    {
        id = itemData.MakeIndex,
        item = itemData,
        targetPos = equipPos,
        skillBook = isBook,
        isHero = isHero
    })
end

function ssr.ShakeScene(time, distance)
    local data = {
        time = time,
        distance = distance
    }
    global.Facade:sendNotification( global.NoticeTable.ShakeScene, data)
end

function ssr.GetCurMapData()
    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    local data = {
        mapID = MapProxy:GetMapID(),
        mapName = MapProxy:GetMapName()
    }
    return data
end

function ssr.AutoMoveBegin(x, y, mapID)
    local movePos = 
    {
        mapID   = mapID,
        x       = tonumber(x),
        y       = tonumber(y),
        autoMoveType = global.MMO.AUTO_MOVE_TYPE_TARGET
    }
    global.Facade:sendNotification(global.NoticeTable.AutoMoveBegin, movePos)
end

function ssr.GetAutoMoveState( ... )
    local AutoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
    return AutoProxy:IsAutoMoveState()
end

function ssr.PayProductRequest(currencyID, price, productIndex, payWay)
    local RechargeProxy = global.Facade:retrieveProxy(global.ProxyTable.RechargeProxy)
    local product = RechargeProxy:GetProductByID(currencyID)
    if not product then
        ShowSystemTips( "未找到商品: " .. (currencyID or "") )
        return nil
    end

    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local channels  = 
    {
        AuthProxy.PAY_CHANNEL.ALIPAY,
        AuthProxy.PAY_CHANNEL.HUABEI,
        AuthProxy.PAY_CHANNEL.WEIXIN,
    }

    local payChannel = payWay and channels[payWay] or AuthProxy.PAY_CHANNEL.ALIPAY
    local function qrcodeCB(isOK, filename)
        if isOK then
            -- 二维码拉取成功
            local qrcode_data = {
                filename    = filename,
                channel     = payChannel,
            }
            global.Facade:sendNotification( global.NoticeTable.Layer_Recharge_QRCode_Open, qrcode_data )
        end
    end

    local info = 
    {
        id           = product.currency_itemid,
        name         = product.currency_name,
        price        = price,
        productIndex = productIndex,
    }
    local paytype   = global.isWindows and AuthProxy.PAY_TYPE.QRCODE or AuthProxy.PAY_TYPE.NATIVE
    local payData   = {paytype = paytype, channel = payChannel, product = info, qrcodeCB = qrcodeCB}
    global.Facade:sendNotification(global.NoticeTable.PayProductRequest, payData)
end

function ssr.GetRolesData()
    local loginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    return loginProxy:GetRoles()
end

function ssr.GetItemCount(index, isBind)
    local PayProxy      = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
    return PayProxy:GetItemCount(index, isBind)
end

function ssr.PlaySound( id, isLoop )
    global.Facade:sendNotification( global.NoticeTable.Audio_Play, {type=global.MMO.SND_TYPE_SSR_UI, index = id, isLoop = isLoop} )
end

function ssr.AddRedDot( data )
    global.Facade:sendNotification(global.NoticeTable.Layer_RedDot_refData,data)
    local RedDotProxy = global.Facade:retrieveProxy(global.ProxyTable.RedDotProxy)
    RedDotProxy:SetBagRedDotByData(data)
end

function ssr.IsCanRevive()
    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    if PlayerProperty:IsCanRevive() == nil then
        return false
    end
    return PlayerProperty:IsCanRevive()
end

function ssr.RequestCreateGuild( guildName )
    if guildName and string.len(guildName) > 0 then
        local proxySensitive = global.Facade:retrieveProxy(global.ProxyTable.SensitiveWordProxy)
        local function handle_Func(state)
            if not state then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(1006))
                return
            end
            
            local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
            GuildProxy:RequestCreateGuild(guildName)
        end
        proxySensitive:IsHaveSensitiveAddFilter(guildName, handle_Func)
    else
        global.Facade:sendNotification(global.NoticeTable.Layer_CreatGuild_ToCreate)
    end
end

-- 注册游戏事件回调
-- params: string, string, function
-- return: nil
function ssr.RegisterLUAEvent(eventID, eventTag, eventCB)
    if not eventID then
        ssr.print("[GUI ERROR] ssr.RegisterLUAEvent, eventID is null", eventID, eventTag, eventCB)
        return
    end
    if not eventTag then
        ssr.print("[GUI ERROR] ssr.RegisterLUAEvent, eventTag is null", eventID, eventTag, eventCB)
        return
    end
    if not eventCB then
        ssr.print("[GUI ERROR] ssr.RegisterLUAEvent, eventCB is null", eventID, eventTag, eventCB)
        return
    end
    ssr.ssrBridge.LUAEvent[eventID] = ssr.ssrBridge.LUAEvent[eventID] or {}
    ssr.ssrBridge.LUAEvent[eventID][eventTag] = eventCB
end

-- 注销游戏事件回调
-- params: string, string, function
-- return: nil
function ssr.UnRegisterLUAEvent(eventID, eventTag)
    if not eventID then
        ssr.print("[GUI ERROR] ssr.UnRegisterLUAEvent, eventID is null", eventID, eventTag)
        return
    end
    if not eventTag then
        ssr.print("[GUI ERROR] ssr.UnRegisterLUAEvent, eventTag is null", eventID, eventTag)
        return
    end
    ssr.ssrBridge.LUAEvent[eventID][eventTag] = nil
end

-- 检测是否显示当前pk模式
function ssr.IsShowCurPkMode(mode)
    local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    return PlayerPropertyProxy:IsShowCurMode(mode)
end

function ssr.IsKfState()
    local ServerTimeProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerTimeProxy)
    return ServerTimeProxy:IsKfState()
end

function ssr.RequestStoreDataByPage(page)
    if not page then
        return
    end
    local PageStoreProxy = global.Facade:retrieveProxy(global.ProxyTable.PageStoreProxy)
    PageStoreProxy:RequestPageData(page)
end

function ssr.SetClipboardText( str )
    str = str or ""
    if global.isWindows then
        if Win32BridgeCtl then
            Win32BridgeCtl:Inst():copyToClipboard(str)
        end
    else
        global.L_NativeBridgeManager:GN_setClipboardText(str)
    end
end

function ssr.OpenBagByPos( pos )
    global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Open,{pos = pos})
end

function ssr.CheckSensitiveWordsCB( str, type, callback, ex_param )
    if not tonumber(type) then
        return
    end
    local SensitiveWordProxy = global.Facade:retrieveProxy(global.ProxyTable.SensitiveWordProxy)
    if type == 1 then   -- 昵称类
        SensitiveWordProxy:IsHaveSensitiveAddFilter(str, callback)
    elseif type == 2 then   -- 聊天
        local data = {}
        data.channel_id = ex_param and ex_param.channelId
        data.to_role_level  = nil
        data.to_role_id     = ex_param and ex_param.uid
        data.to_role_name   = ex_param and ex_param.name

        local function handle_Func(state, str, risk_param)
            if risk_param and risk_param ~= 0 then
                callback(false, false)
            else
                callback(state, str, risk_param)
            end
        end

        SensitiveWordProxy:fixSensitiveTalkAddFilter(str, handle_Func, nil, data)
    elseif type == 3 then   -- 行会公告
        SensitiveWordProxy:fixSensitiveTalkAddFilter(str, callback, 1)
    end
    
end

function ssr.GetGameDataCfg()
    return clone(global.ConstantConfig)
end

-- 通过唯一ID获取装备数据 isHero:是否英雄
function ssr.GetEquipDataByMakeIndex(MakeIndex, isHero)
    return SL:GetMetaValue("EQUIP_DATA_BY_MAKEINDEX", MakeIndex, isHero)
end

-- 通过唯一ID获取背包数据 isHero:是否英雄
function ssr.GetBagDataByMakeIndex(MakeIndex, isHero)
    return SL:GetMetaValue("ITEM_DATA_BY_MAKEINDEX", MakeIndex, isHero)
end

function ssr.GetStorageDataByMakeIndex(MakeIndex)
    return SL:GetMetaValue("STORAGE_DATA_BY_MAKEINDEX", MakeIndex)
end

-- 获取正在查看玩家的某一装备位数据
function ssr.GetLookPlayerItemDataByPos(pos, param)
    return SL:GetMetaValue("L.M.EQUIP_DATA", pos, param)
end

function ssr.GetLookPlayerData()
    return SL:GetMetaValue("L.M.PLAYER_DATA")
end

function ssr.GetLookPlayerEquipDataByName(name)
    return SL:GetMetaValue("L.M.EQUIP_DATA", name)
end

-- 
function ssr.GetEquipDataByName(name, isHero)
    local proxy
    if isHero then
        return SL:GetMetaValue("H.EQUIP_DATA", name)
    else
        return SL:GetMetaValue("EQUIP_DATA", name)
    end
end

-- 游戏设置相关
function ssr.CheckSetById(id)
    return CHECK_SETTING(id)
end

function ssr.SetSettingValue(id, values)
    CHANGE_SETTING(id, values)
end

function ssr.TransToMiniMapPos( value1, value2 )
    local MiniMapMediator = global.Facade:retrieveMediator("MiniMapMediator")
    if MiniMapMediator and MiniMapMediator._layer then
        local mapPos = value1
        if value1 and value2 then
            mapPos = cc.p(value1, value2)
        end
        return MiniMapMediator._layer:CalcMiniMapPos(mapPos)
    end 
    return nil
end

------------------------------Tips相关-------------------------
function ssr.GetItemFromList()
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    return clone(ItemMoveProxy.ItemFrom)
end

function ssr.GetItemType()
    return SL:GetMetaValue("ITEMFROMUI_ENUM")
end

-- 获取道具类型
function ssr.GetItemTypeByData(itemData)
    return SL:GetMetaValue("ITEMTYPE", itemData)
end

function ssr.GetItemDataByIndex(index)
    return SL:GetMetaValue("ITEM_DATA", index)
end

function ssr.GetDiffEquip(itemData, isHero)
    return GUIFunction:GetDiffEquip(itemData, isHero)
end

function ssr.CheckSeverOptions(id)
    return SL:GetMetaValue("SERVER_OPTIONS", id)
end

-- 根据道具 index 获取道具名字
function ssr.GetItemNameByIndex(index)
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    return ItemConfigProxy:GetItemNameByIndex(index)
end

function ssr.CheckItemisBind(itemData, articleType)
    return SL:GetMetaValue("ITEM_IS_BIND", itemData, articleType)
end

-- 有对应装备位的stdMode列表
function ssr.GetEquipMapByStdModeList()
    return SL:GetMetaValue("EQUIPMAP_BY_STDMODE")
end

-- 额外显示持久的stdMode列表
function ssr.GetExtraShowLastingByStdMode()
    return SL:GetMetaValue("EX_SHOWLAST_MAP")
end

-- 通过stdMode获取对应装备位
function ssr.GetEquipPosByStdMode(stdMode)
    return SL:GetMetaValue("EQUIP_POS_BY_STDMODE", stdMode)
end

-- 获取额外属性对应id列表
function ssr.GetExAttType()
    return GUIFunction:GetExAttType()
end

-- 服务段下发的额外id对应的属性id列表
function ssr.GetExAttMap(id)
    return GUIDefine.ExAttrList and GUIDefine.ExAttrList[id]
end

-- 获取cfg_att_score表对应id的数据
function ssr.GetAttConfigByAttId(id)
    return SL:GetMetaValue("ATTR_CONFIG", id)
end

-- 检查道具是否满足条件可使用 isHero：boolean 是否英雄
function ssr.CheckItemUseNeed(itemData, isHero)
    if isHero then
        return CheckItemUseNeed_Hero(itemData)
    else
        return CheckItemUseNeed(itemData)
    end
end

-- 获取所有属性类型
function ssr.GetAttrTypeList()
    local list = GUIFunction:PShowAttType()
    return list
end

-- 获取cfg_custpro_caption 对应id的描述
function ssr.GetCustomDescById(id)
    return SL:GetMetaValue("CUSTOM_DESC", id)
end

-- 获取cfg_custpro_caption 对应id的图标显示
function ssr.GetCustomIconShowById(id)
    return SL:GetMetaValue("CUSTOM_ICON", id)
end

-- 获取id在cfg_att_score表内的配置
function ssr.GetAttrConfigById(id)
    return SL:GetMetaValue("ATTR_CONFIG", id)
end

-- 通过名字获取cfg_suit配置
function ssr.GetSuitConfigByName(name)
    return SL:GetMetaValue("SUIT_CONFIG", name)
end

-- 通过id获取cfg_suit配置
function ssr.GetSuitConfigById(id)
    return SL:GetMetaValue("SUIT_CONFIG", id)
end

-- 通过id获取cfg_suitex配置
function ssr.GetNewSuitConfigById(id)
    return SL:GetMetaValue("SUITEX_CONFIG", id)
end

---------------------------------------------------------------

-------- 英雄
function ssr.GetHeroBaseData( ... )
    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    local data = {}
    data.roleJob    = PlayerProperty:GetRoleJob()
    data.sex        = PlayerProperty:GetRoleSex()
    data.level      = PlayerProperty:GetRoleLevel()
    data.reinLv     = PlayerProperty:GetRoleReinLv() or 0
    data.name       = PlayerProperty:GetName()
    data.pkMode     = PlayerProperty:GetPKMode()
    data.curHP      = PlayerProperty:GetRoleCurrHP()
    data.maxHP      = PlayerProperty:GetRoleMaxHP()
    data.curMP      = PlayerProperty:GetRoleCurrMP()
    data.maxMP      = PlayerProperty:GetRoleMaxMP()
    data.curExp     = PlayerProperty:GetCurrExp()
    data.maxExp     = PlayerProperty:GetNeedExp()
    return data
end

function ssr.GetHeroState( ... )
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    return HeroPropertyProxy:getHeroState()
end

function ssr.RequestHeroInOrOut( ... )
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    HeroPropertyProxy:RequestHeroInOrOut()
end

function ssr.RequestHeroJointAttack( ... )
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    if HeroPropertyProxy:getShan()  then
        HeroPropertyProxy:ReqJointAttack()
    end
end
