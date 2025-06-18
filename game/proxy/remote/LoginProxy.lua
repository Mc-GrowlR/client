local RemoteProxy = requireProxy("remote/RemoteProxy")
local LoginProxy = class("LoginProxy", RemoteProxy)
LoginProxy.NAME = global.ProxyTable.Login
local cjson = require("cjson")
local connectTimeOut = 5

-- 网络消息水印头
function GET_NET_MSG_STAMP_HEAD_RECOG()
    return 900000
end
function GET_NET_MSG_STAMP_HEAD_PARAM1()
    return math.random(1,1000000000)
end

LoginProxy.param1Ex = nil
function GET_NET_MSG_STAMP_HEAD_PARAM1_NEW(func)
    if LoginProxy.param1Ex then 
        func(LoginProxy.param1Ex)
        return 
    end
    local currentModule = global.L_ModuleManager:GetCurrentModule()
    local moduleGameEnv = currentModule:GetGameEnv()
    local NetStampHost  = moduleGameEnv:GetCustomDataByKey("NetStampHost")
    local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local serverID = tonumber(LoginProxy:GetMainSelectedServerId() or LoginProxy:GetSelectedServerId()) or 0
    local netUrl = string.format("%s%s.txt", NetStampHost, get_str_MD5(tostring(serverID))) 
    local fileUtil = cc.FileUtils:getInstance()
    local filePath = fileUtil:getWritablePath() .. "_temp_net_"
    if fileUtil:isFileExist(filePath) then
        fileUtil:removeFile(filePath)
    end
    HTTPRequest(netUrl,function (success, response)
        local param1 = bit._and(math.random(100000000,2100000000),0xFFFF00FF)  
        if success then 
            fileUtil:writeStringToFile(response, filePath)
            local netInfoStr = fileUtil:getDataFromFileEx(filePath)
            local netInfo = cjson.decode(netInfoStr)
            local index = L8Bit(netInfo.UnixTime) + 1
            param1 = netInfo.Sequence[index]
            param1 = tonumber(param1) or 0
            LoginProxy.param1Ex = param1
        end
        func(param1)
    end)
end

function LoginProxy:ctor()
    LoginProxy.super.ctor(self)

    self._data = {}

    -- 角色
    self._data.roles = {}
    self._data.selectRole = {}
    self._data.restoreRoleDatas ={}
    self._restoreTag = nil

    -- util
    self._netMsgSpecialData = nil

    self._tipsContent = ""
    self._serviceVer  = ""

    self._forbidName    = false -- 服务器控制开关，是否禁止取名字
    self._forbidChat    = false -- 服务器控制开关，是否禁止聊天等

    self._loginKey      = ""   -- 529号消息返回的key
    self._newLogin      = false -- 新的登录方式
end

function LoginProxy:IsForbidName()
    return self._forbidName
end

function LoginProxy:SetForbidChat(v)
    self._forbidChat = v
end
function LoginProxy:IsForbidChat()
    return self._forbidChat
end

function LoginProxy:SetTipsContent(content)
    self._tipsContent = content
end

function LoginProxy:GetTipsContent()
    return self._tipsContent
end

function LoginProxy:SetServiceVer(ver)
    self._serviceVer = ver
end

function LoginProxy:GetServiceVer()
    return self._serviceVer
end

function LoginProxy:GetSelectedServer()
    local currentModule = global.L_ModuleManager:GetCurrentModule()
    local moduleGameEnv = currentModule:GetGameEnv()
    return moduleGameEnv:GetSelectedServer()
end

function LoginProxy:GetSelectedServerDomain() -- 当前选择的服务器 域名
    local server = self:GetSelectedServer()
    if server then
        return server.ip
    end

    return nil
end

function LoginProxy:GetMainSelectedServerId() -- 当前选择的服务器 主服id
    local server = self:GetSelectedServer()
    if server then
        return server.mainServerId
    end

    return nil
end

function LoginProxy:GetSelectedServerId() -- 当前选择的服务器 id
    local server = self:GetSelectedServer()
    if server then
        return server.serverId
    end

    return nil
end

function LoginProxy:GetSelectedServerName() -- 当前选择的服务器 name
    local server = self:GetSelectedServer()
    if server then
        return server.serverName
    end

    return nil
end

function LoginProxy:GetSelectedServerUrlSuffix() -- 当前选择的服务器 资源URL 后缀
    local server = self:GetSelectedServer()
    if server then
        return server.urlSuffix
    end

    return nil
end

function LoginProxy:GetSelectedServerIp() -- 当前选择的服务器 ip 地址
    local server = self:GetSelectedServer()
    if server then
        return server.ip
    end

    return nil
end

function LoginProxy:GetSelectedServerPort() -- 当前选择的服务器 端口
    local server = self:GetSelectedServer()
    if server then
        return tonumber(server.port)
    end

    return nil
end

function LoginProxy:GetSelectedServerProxyPort() -- 当前选择的服务器 代理端口
    local server = self:GetSelectedServer()
    if server then
        return tonumber(server.proxyport)
    end

    return nil
end

function LoginProxy:SetGameServerPort(port)
    self._data.gameServerPort = port
end

function LoginProxy:GetGameServerPort()
    return self._data.gameServerPort
end

function LoginProxy:SetRolePort(port)
    self._data.rolePort = port
end

function LoginProxy:GetRolePort()
    return self._data.rolePort
end

-- roles
function LoginProxy:SetSelectedRole(role)
    self._data.selectRole = role
end

function LoginProxy:GetSelectedRole()
    return self._data.selectRole
end

function LoginProxy:SetSelectedRoleByIndex(index)
    local role = self._data.roles[index]
    if role then
        self._data.selectRole = role
    end
end

function LoginProxy:GetSelectedRoleName() -- 当前选择的角色 name
    if self._data.selectRole then
        return self._data.selectRole.name
    end
    return nil
end

function LoginProxy:GetSelectedRoleID() --当前选择的角色ID
    if self._data.selectRole then
        return self._data.selectRole.roleid
    end
    return nil
end

function LoginProxy:GetSelectedRoleCTime() --当前选择的角色创建时间
    if self._data.selectRole and self._data.selectRole.ctime then
        return self._data.selectRole.ctime
    end
    return 0
end

function LoginProxy:GetRoles()
    return self._data.roles
end

function LoginProxy:AddRole(role)
    table.insert(self._data.roles, role)

    for i, v in ipairs(self._data.roles) do
        v.index = i
    end
end

function LoginProxy:DelRoleByID(roleid)
    for k, v in pairs(self._data.roles) do
        if v.roleid == roleid then
            table.remove(self._data.roles, k)
            break
        end
    end
    for i, v in ipairs(self._data.roles) do
        v.index = i
    end
end

function LoginProxy:ClearRoles()
    self._data.roles = {}
    self._data.selectRole = nil
end
--- 


-- 服务器Special data
function LoginProxy:SetNetMsgSpecialData(value)
    self._netMsgSpecialData = value
end

function LoginProxy:GetNetMsgSpecialData()
    return self._netMsgSpecialData
end
--

-- step 0.
function LoginProxy:RequestLoginServer()
    HideLoadingBar()

    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local uid       = AuthProxy:GetUID()
    local token     = AuthProxy:GetToken()
    
    -- for debug mode, login whitelist
    if global.isDebugMode then
        token = "sJAsOn001"
    end
    self:RequestServerList(uid, token, function (ret)
        if 1 ~= ret then
            local function callback(bType, custom)
                if bType == 1 then
                    if global.isWindows then
                        global.Director:endToLua()
                    else
                        global.L_NativeBridgeManager:GN_accountLogout()
                        global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
                    end
                end
            end
            local data = {}
            data.str = GET_STRING(600003002)
            data.btnDesc = { GET_STRING(600003001)}
            data.callback = callback
            global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        end
    end)
end

-- step 1. 2001->
function LoginProxy:RequestServerList(account, password, connectResfunc) 
    releasePrint("step 1. function LoginProxy:RequestServerList(account, password)")

    local ret = -1
    local netClient = global.gameEnvironment:GetNetClient()
    local selectServer = self:GetSelectedServer()

    releasePrint(cjson.encode(selectServer))

    -- 没有选择服务器
    if not selectServer or not selectServer.ip or not selectServer.port then
        local function callback(bType, custom)
            if global.isWindows then
                global.Director:endToLua()
            else
                global.L_NativeBridgeManager:GN_accountLogout()
                global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
            end
        end
        local data = {}
        data.str = GET_STRING(30009001)
        data.btnDesc = {GET_STRING(1002)}
        data.callback = callback
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        return ret
    end

    -- 服务器未开启
    local currentModule = global.L_ModuleManager:GetCurrentModule()
    local moduleGameEnv = currentModule:GetGameEnv()
    if selectServer.state == 4 and (moduleGameEnv:IsWhitelist() == false) then
        local function callback(bType, custom)
            if global.isWindows then
                global.Director:endToLua()
            else
                global.L_NativeBridgeManager:GN_accountLogout()
                global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
            end
        end
        local data = {}
        data.str = GET_STRING(30009002)
        data.btnDesc = {GET_STRING(1002)}
        data.callback = callback
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        return ret
    end

    local ip          = self:GetSelectedServerIp()
    local port        = self:GetSelectedServerPort()
    local proxyport   = self:GetSelectedServerProxyPort()
    local connectIP   = tostring(ip)
    local connectPort = tonumber(proxyport or port)
    self:SetRolePort(connectPort)

    -- // connect server
    netClient:Disconnect()
    local Connect = function (param1Ex)
        ret = netClient:Connect(connectIP, connectPort)
        releasePrint("2001, connect:", connectIP, connectPort, ret)
        if 1 == ret then
            -- // 1. message 2001 - request server lis
            -- login
            local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
            local pwdSession = Encode6BitBuf(password, string.len(password))
            local channelID = envProxy:GetChannelID()  
            local encodechannelID = Encode6BitBuf(channelID, string.len(channelID))
            local sendStr = string.format("%s/%s/%s", account, pwdSession, encodechannelID)
            local sendLen = string.len(sendStr)

            print("sendStr", sendStr, sendLen)

            netClient:SetNetMessageTypeSData(0)

            local recog = GET_NET_MSG_STAMP_HEAD_RECOG()
            local param1 = param1Ex or GET_NET_MSG_STAMP_HEAD_PARAM1()
            local param2 = tonumber(self:GetMainSelectedServerId() or self:GetSelectedServerId()) or 0
            local param3 = tonumber(self:GetSelectedServerPort()) or 0

            LuaSendMsg(global.MsgType.MSG_CS_REQUEST_SERVER_LIST, recog, param1, param2, param3, sendStr, sendLen)
            releasePrint("step 1. global.MsgType.MSG_CS_REQUEST_SERVER_LIST 2001", account, password, sendStr)

            self.reqServerListScheduleID =  PerformWithDelayGlobal(function() 
                self:connectTimeOutTips()
                self.reqServerListScheduleID = nil
            end, connectTimeOut)
        end
        connectResfunc(ret)
    end
    if proxyport then 
        GET_NET_MSG_STAMP_HEAD_PARAM1_NEW(function (param1Ex)
            Connect(param1Ex)
        end)
    else
        Connect()
    end
end

function LoginProxy:handle_MSG_SC_RESPOINSE_CHECK_TOKEN_FAIL(msg)
    releasePrint("step 1. local function handle_MSG_SC_RESPOINSE_CHECK_TOKEN_FAIL(msg)")
    self:unScheduleServerList()

    -- recog  -99 = 信息不全  -6 = 认证失败！
    local header = msg:GetHeader()
    if header.recog == -99 then
        local function callback(bType, custom)
            if global.isWindows then
                global.Director:endToLua()
            else
                global.L_NativeBridgeManager:GN_accountLogout()
                global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
            end
        end
        local data = {}
        data.str    = GET_STRING(30009104)
        data.btnDesc = { GET_STRING(800802)}
        data.callback = callback
        data.hideCloseBtn = true
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        
    elseif header.recog == -6 then
        local function callback(bType, custom)
            if global.isWindows then
                global.Director:endToLua()
            else
                global.L_NativeBridgeManager:GN_accountLogout()
                global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
            end
        end
        local data = {}
        data.str    = GET_STRING(30009105)
        data.btnDesc = { GET_STRING(800802)}
        data.callback = callback
        data.hideCloseBtn = true
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
    end
end

function LoginProxy:recordLoginUserData2Bugly()
    -- record login user data
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local envProxy  = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    local account   = AuthProxy:GetUID()
    local serverID  = self:GetSelectedServerId()
    local channelID = envProxy:GetChannelID()
    local etc2_enable = global.LuaBridgeCtl:GetModulesSwitch( global.MMO.Modules_Index_Enable_ETC2)

    local userValue = string.format("%s|%s|%s|%s", tostring(account), tostring(serverID), tostring(channelID), tostring(etc2_enable))

    -- account|serverID|channel
    if cc.PLATFORM_OS_ANDROID == global.Platform then
        buglyAddUserValue("LoginUserAccountData", userValue)
    else
        releasePrint("LoginUserAccountData:" .. userValue)
    end
end

-- step 2. ->529
function LoginProxy:handle_MSG_SC_RESPONSE_SERVER_LIST(msg)
    releasePrint("step 2. local function handle_MSG_SC_RESPONSE_SERVER_LIST(msg)")
    local msgHdr = msg:GetHeader()
    self:unScheduleServerList()

    local data = msg:GetData()
    local dataStr = data:ReadString(msg:GetDataLength())
    local slices = string.split(dataStr, "/")
    local userID = slices[2]
    self._userID = userID
    self._loginKey = slices[1] or ""
    self._newLogin = msgHdr.recog == 1

    releasePrint("userID", userID)
    releasePrint("======529: ", string.format("数据: %s    key: %s  recog: %s", dataStr, self._loginKey, msgHdr.recog) )

    -- Data recording
    if cc.PLATFORM_OS_WINDOWS ~= global.Platform then
        local jData  = {}
        jData.userID = userID
        jData.srvID  = self:GetSelectedServerId()
        global.L_NativeBridgeManager:GN_onUserIDUpdated(jData)
    end

    -- record to bugly
    self:recordLoginUserData2Bugly()

    self:RequestServerInfo()
end

-- step 3. 104->
function LoginProxy:RequestServerInfo()
    print("step 3. function LoginProxy:RequestServerInfo()")
    local serverId = self:GetSelectedServerId()
    local mainServerId = self:GetMainSelectedServerId()

    if not serverId or "" == serverId then
        local function callback(bType, custom)
            if bType == 1 then
                self:RequestLoginServer()
            elseif bType == 2 then
                if global.isWindows then
                    global.Director:endToLua()
                else
                    global.L_NativeBridgeManager:GN_accountLogout()
                    global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
                end
            end
        end
        local data = {}
        data.str = GET_STRING(30009003)
        data.btnDesc = {"重 试", "返 回"}
        data.callback = callback
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        -- print("error, RequestServerInfo, serverId:" .. tostring(serverId))
        return
    end

    local sendServerId = mainServerId or serverId
    if self._newLogin then
        sendServerId = Encode6BitBuf(self._loginKey, string.len(self._loginKey))
    end
    releasePrint("serverId", serverId)
    releasePrint("mainServerId", mainServerId)
    releasePrint("sendServerId", sendServerId)
    LuaSendMsg(global.MsgType.MSG_CS_REQUEST_SERVER_INFO, 0, 0, 0, 0, sendServerId, string.len(sendServerId))
end

-- step 4. ->530
function LoginProxy:handle_MSG_SC_RESPONSE_SERVER_INFO(msg)
    print("step 4. local function handle_MSG_SC_RESPONSE_SERVER_INFO(msg)")

    if self._newLogin then
        ShowLoadingBar()
        local header = msg:GetHeader()
        local specialData = header.recog
        local netClient = global.gameEnvironment:GetNetClient()
        print("SetNetMessageTypeSData:", specialData)
        netClient:SetNetMessageTypeSData(specialData)
        self:SetNetMsgSpecialData(specialData)
        releasePrint("530: ", string.format("SessionId: %s", specialData) )
        self:RequestRoleInfo(specialData)
        return false
    end
    
    local data = msg:GetData()
    local dataStr = data:ReadString(msg:GetDataLength())

    local slices = string.split(dataStr, "/")
    local ip = tostring(slices[1])
    local port = tonumber(slices[2])
    local specialData = tonumber(slices[3])

    self:SetRolePort(port)

    ShowLoadingBar()
    -- // Disconnect current server and connect new server
    local netClient = global.gameEnvironment:GetNetClient()
    netClient:Disconnect()
    netClient:SetNetMessageTypeSData(specialData)
    self:SetNetMsgSpecialData(specialData)
    print("SetNetMessageTypeSData:", specialData)

    local ip          = self:GetSelectedServerIp()
    local proxyport   = self:GetSelectedServerProxyPort()
    local connectIP   = tostring(ip)
    local connectPort = tonumber(proxyport or port)

    local errorTips = (connectPort == nil and 0) or (connectPort == 0 and 1) or nil
    if errorTips then
        ShowSystemTips(string.format(GET_STRING(30009300), errorTips))
    end

    local Connect = function (param1Ex)
        local ret = netClient:Connect(connectIP, connectPort)
        releasePrint("530, connect", connectIP, connectPort, ret)

        if 1 ~= ret then
            local function callback(bType, custom)
                if bType == 1 then
                    self:RequestLoginServer()
                elseif bType == 2 then
                    if global.isWindows then
                        global.Director:endToLua()
                    else
                        global.L_NativeBridgeManager:GN_accountLogout()
                        global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
                    end
                end
            end
            local data = {}
            data.str = GET_STRING(30009003)
            data.btnDesc = {"重 试", "返 回"}
            data.callback = callback
            global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
            -- print("error, handle_MSG_SC_RESPONSE_SERVER_INFO:" .. tostring(ip) .. ":" .. tostring(port))
            return
        end

        -- // request role data of current account
        self:RequestRoleInfo(specialData, param1Ex)
    end
    
    if proxyport then
        GET_NET_MSG_STAMP_HEAD_PARAM1_NEW(function (param1Ex)
            Connect(param1Ex)
        end)
    else
        Connect()
    end
end

-- step 5. 100->
function LoginProxy:RequestRoleInfo(specialData, param1Ex)
    print("step 5. function LoginProxy:RequestRoleInfo(specialData)")

    local envProxy  = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local account   = AuthProxy:GetUID()
    local currModule= global.L_ModuleManager:GetCurrentModule()
    local gameid    = currModule:GetOperID() or "0"
    -- login
    -- 100 （查询角色）  格式：帐号/SessionId/服务器名/主SdkId/子SdkId
    -- TODO, sdk id
    local sendStr = string.format("%s/%d/%s/%s/%s",
        account,
        specialData,
        self:GetSelectedServerId(),
        envProxy:GetChannelID(),
        gameid
    )

    local param3 = tonumber(self:GetRolePort()) or 0
    if self._newLogin then
        sendStr = string.format("%s/%s", sendStr, self._loginKey)
        param3 = tonumber(self:GetSelectedServerPort()) or 0
    end

    print("request role info")
    local recog = GET_NET_MSG_STAMP_HEAD_RECOG()
    local param1 = param1Ex or GET_NET_MSG_STAMP_HEAD_PARAM1()
    local param2 = tonumber(self:GetMainSelectedServerId() or self:GetSelectedServerId()) or 0
    LuaSendMsg(global.MsgType.MSG_CS_REQUEST_ROLE_INFO, recog, param1, param2, param3, sendStr, string.len(sendStr))
    
end

function LoginProxy:handle_MSG_SC_RESPOINSE_ROLE_INFO_FAIL(msg)
    print("step 6. local function handle_MSG_SC_RESPOINSE_ROLE_INFO_FAIL(msg)")
    HideLoadingBar(true)

    local header = msg:GetHeader()
    dump(header)
    local errorcode = header.param1
    if errorcode == 1 then
        -- 会话错误
        ShowSystemTips(GET_STRING(30009080))
    elseif errorcode == 2 then
        -- serverID为空
        ShowSystemTips(GET_STRING(30009081))
        
    elseif errorcode == 3 then
        -- serverID异常
        ShowSystemTips(GET_STRING(30009082))

    end

    local function callback(bType, custom)
        if bType == 1 then
            self:RequestLoginServer()
        elseif bType == 2 then
            if global.isWindows then
                global.Director:endToLua()
            else
                global.L_NativeBridgeManager:GN_accountLogout()
                global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
            end
        end
    end
    local data = {}
    data.str = GET_STRING(30009004)
    data.btnDesc = {GET_STRING(30009045), GET_STRING(30009046)}
    data.callback = callback
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

-- step 6. ->520
function LoginProxy:handle_MSG_SC_RESPOINSE_ROLE_INFO(msg)
    print( "step 6. local function handle_MSG_SC_RESPOINSE_ROLE_INFO(msg)" )
    HideLoadingBar(true)

    -- 清除角色信息
    self:ClearRoles()

    -- headr 第一个：封第一个角色 第二个：封第二个角色
    local header = msg:GetHeader()
    local banned = {}
    banned[1] = (header.recog == 2)
    banned[2] = (header.param1 == 2)

    -- 禁止自定义取名编辑
    self._forbidName = header.param3 == 1

    local data = msg:GetData()
    local dataLen = msg:GetDataLength()
    local cjson = require("cjson")
    local jsonStr = data:ReadString(dataLen)
    print( jsonStr )
    local jsonData = cjson.decode(jsonStr)
    
    -- 无角色
    if not jsonData.list or not next(jsonData.list) then
        -- global.Facade:sendNotification(global.NoticeTable.Layer_Login_Role_Open)
    else
        local lastIndex = 0
        for i, v in ipairs(jsonData.list) do
            if i > 2 then
                break
            end
    
            v.name   = v.chr
            v.renew  = v.relevel
            v.ctime  = v.create_time or GetServerTime()
            v.roleid = v.UserID
            v.banned = (v.deny_ip == 1 or v.deny_account == 1 or v.deny_uid == 1)
            v.newChar = v.newChar
            v.LockChar = v.LockChar
            v.deny_msg = v.deny_msg
            v.deny_time = v.deny_time
            self:AddRole(v)
    
            if v.last == 1 then
                lastIndex = i
            end
        end
        if lastIndex > 0 then
            self:SetSelectedRoleByIndex(lastIndex)
        elseif #jsonData.list >= 1 then
            self:SetSelectedRoleByIndex(1)
        end

        if self._restoreTag then
            if #jsonData.list >= 1 then
                self:SetSelectedRoleByIndex(2)
            else
                self:SetSelectedRoleByIndex(1)
            end
            self._restoreTag = nil
        end
    end

    ---刷新角色数量
    local module            = global.L_ModuleManager:GetCurrentModule()
    local moduleGameEnv     = module:GetGameEnv()
    local roleData = self._data.roles or {}
    if moduleGameEnv.SetRoleCountByServerID then 
        moduleGameEnv:SetRoleCountByServerID(self:GetSelectedServerId(), #roleData)
    end

    -- 登录成功
    global.Facade:sendNotification(global.NoticeTable.LoginServerSuccess)


    -- 数据上报
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local account   = AuthProxy:GetUID()
    local jData     = {}
    jData.zoneId    = self:GetSelectedServerId()
    jData.zoneName  = self:GetSelectedServerName()
    jData.userId    = account
    jData.promoteId = tostring(global.L_GameEnvManager:GetGMName())
    local DataTrackProxy = global.Facade:retrieveProxy(global.ProxyTable.DataTrackProxy)
    DataTrackProxy:OnRoleInfo(jData)
end

--sdk设备信息
function LoginProxy:SendDeviceInfo() 
    local cjson = require("cjson")
    local strData = ""
    local boxID = nil
    if global.L_GameEnvManager:GetEnvDataByKey("isBoxLogin") == 1 then
        local boxBoxGameID  = global.L_ModuleManager:GetCurrentModule():GetOperID() or ""
        local boxChannelID  = global.L_GameEnvManager:GetChannelID() or ""
        boxID               = boxBoxGameID .. ":" .. boxChannelID
    end

    if SL:GetMetaValue("WINPLAYMODE") then
        local DataRePortProxy = global.Facade:retrieveProxy( global.ProxyTable.DataRePortProxy )
        local infoData        = DataRePortProxy:GetDeviceInfo()
        local PCStrData = infoData.device or {}
        PCStrData.boxid = boxID
        strData = cjson.encode(PCStrData)

    else
        local deviceInfo = global.L_NativeBridgeManager.GetLoginDataByKey and global.L_NativeBridgeManager:GetLoginDataByKey("deviceInfo") or ""
        if deviceInfo and string.len(deviceInfo) > 0 then
            local deviceData = cjson.decode(deviceInfo)
            if deviceData and next(deviceData) then
                deviceData.boxid = boxID
                strData = cjson.encode(deviceData)
            end
        end
    end

    local jsonString = strData
    releasePrint("SendDeviceInfo = "..jsonString)
    LuaSendMsg(global.MsgType.MSG_SC_MOBILE_DEVICE_INFO, 0, 0, 0, 0, jsonString, string.len(jsonString))
end

--sdk参数渠道号 appid appkey等
function LoginProxy:SendSDKInfo() 
    local cjson = require("cjson")

    local strData = ""

    if SL:GetMetaValue("WINPLAYMODE") then
        local DataRePortProxy = global.Facade:retrieveProxy( global.ProxyTable.DataRePortProxy )
        local infoData        = DataRePortProxy:GetDeviceInfo()
        local PCStrData = {
            sdkver  = "1.0.0",
            channel = infoData.channel or "",
            appid   = infoData.appid or "",
            appver  = global.L_GameEnvManager:GetAPKVersionName() or "",
            pservname = self:GetSelectedServerName(),
            pservid = self:GetSelectedServerId(),
        }
        strData = cjson.encode(PCStrData)
    else
        strData = global.L_NativeBridgeManager.GetLoginDataByKey and global.L_NativeBridgeManager:GetLoginDataByKey("sdkInfo") or ""
        if strData and strData ~= "" then
            -- 新增字段
            local jsonData = cjson.decode(strData)
            jsonData.pservname = self:GetSelectedServerName()
            jsonData.pservid = self:GetSelectedServerId()
            strData = cjson.encode(jsonData)
        end
    end
    
    local jsonString = strData
    releasePrint("SendSDKInfo = "..jsonString)
    LuaSendMsg(global.MsgType.MSG_SC_MOBILE_SDK_INFO, 0, 0, 0, 0, jsonString, string.len(jsonString))
end

function LoginProxy:CheckBnannedRole(role)
    if role and role.banned then
        self:ShowBannedRole(role)

        return true
    end

    return false
end

function LoginProxy:ShowBannedRole(role)
    local function callback()
    end
    HideLoadingBar()

    -- 封禁客户端自行拼接时间轴，封禁时间 > 15天时不提醒时间
    local str = GET_STRING(30009034)
    if role.deny_msg and role.deny_msg ~= "" then
        str = role.deny_msg
        if role.deny_time and role.deny_time > os.time() and role.deny_time - os.time() < 15*24*60*60 then
            local date = os.date("*t", role.deny_time)
            local timeStr = string.format("%d-%02d-%02d %02d:%02d:%02d", date.year, date.month, date.day, date.hour, date.min, date.sec)
            str = str .. "<br>" .. string.format(GET_STRING(30009079), timeStr)
        end
    end

    local data = {}
    data.str = str
    data.btnDesc = {GET_STRING(1002)}
    data.callback = callback
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

function LoginProxy:RequestCreateRole(name, job, sex)
    ShowLoadingBar()

    local envProxy  = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local account   = AuthProxy:GetUID()
    -- login
    -- 101 （创建角色）  格式：帐号/角色名/职业/性别/服务器名/主SdkId/子SdkId
    -- TODO, sdk id
    local cjson = require("cjson")
    local jsonData = {}
    jsonData.account = account
    jsonData.chr = name
    jsonData.job = job
    jsonData.sex = sex
    jsonData.server_name = self:GetSelectedServerId()
    jsonData.sdkid = envProxy:GetChannelID()
    jsonData.secsdk = "0"
    local jsonString = cjson.encode(jsonData)
    LuaSendMsg(global.MsgType.MSG_CS_CREATE_ROLE, 0, 0, 0, 0, jsonString, string.len(jsonString))

    -- record create info
    self._createName = name
    self._createJob = job
    self._createSex = sex
end

function LoginProxy:handle_MSG_SC_CREATE_ROLE_SUCCESS(msg)
    HideLoadingBar()

    local data      = msg:GetData()
    local dataLen   = msg:GetDataLength()
    local dataStr   = data:ReadString(dataLen)
    local slices    = string.split(dataStr, "/")
    local roleName  = slices[1]

    local role  = {}
    role.roleid = slices[2]
    role.name   = roleName
    role.level  = 1
    role.job    = self._createJob
    role.sex    = self._createSex
    role.ctime  = GetServerTime()

    self:AddRole(role)
    self:SetSelectedRole(role)

    -- clear create info
    self._createName = nil
    self._createJob = nil
    self._createSex = nil

    -- go
    self:RequestEnterGame()

    -- Data recording
    local AuthProxy     = global.Facade:retrieveProxy( global.ProxyTable.AuthProxy )
    local jData = {}
    jData.zoneId        = self:GetSelectedServerId()
    jData.zoneName      = self:GetSelectedServerName()
    jData.roleId        = self:GetSelectedRoleID()
    jData.roleName      = self:GetSelectedRoleName()
    jData.roleCTime     = role.ctime
    jData.roleLevel     = "1"
    jData.roleVIPLev    = "0"
    jData.roleBalance   = "0"
    jData.roleGuild     = ""
    jData.userId        = tostring( AuthProxy:GetUID() )
    jData.reinLevel     = "0"
    jData.promoteId     = tostring(global.L_GameEnvManager:GetGMName())
    jData.roleJobName   = GetJobName(role.job)
    jData.roleJobId     = role.job
    jData.roleAtt       = 0
    local DataTrackProxy = global.Facade:retrieveProxy( global.ProxyTable.DataTrackProxy )
    DataTrackProxy:OnCreateRole(jData)

    ---刷新角色数量
    local module            = global.L_ModuleManager:GetCurrentModule()
    local moduleGameEnv     = module:GetGameEnv()
    local roleData = self._data.roles or {}
    if moduleGameEnv.SetRoleCountByServerID then 
        moduleGameEnv:SetRoleCountByServerID(self:GetSelectedServerId(), #roleData)
    end
end

function LoginProxy:handle_MSG_SC_CREATE_ROLE_FAIL(msg)
    HideLoadingBar(true)
    local head = msg:GetHeader()

    if head.recog == -10 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009035))
    elseif head.recog == -11 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009036))
    elseif head.recog == 5 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009070))
    elseif head.recog == 6 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009071))
    elseif head.recog == 7 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009072))
    elseif head.recog == 100 or head.recog == 101 or head.recog == 102 or head.recog == 103 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009000+head.recog))
    else
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009016 + head.recog))
    end
end

function LoginProxy:RequestDeleteRole(uid)
    dump(uid)
    ShowLoadingBar()
    local sendStr = uid
    LuaSendMsg(global.MsgType.MSG_CS_DELETE_ROLE, 0, 0, 0, 0, sendStr, string.len(sendStr))
end

function LoginProxy:handle_MSG_SC_DELETE_ROLE_SUCCESS(msg)
    HideLoadingBar(true)
    -- del
    self:DelRoleByID(self:GetSelectedRoleID())
    
    -- select
    local roles = self:GetRoles()
    if #roles == 0 then
        self:SetSelectedRole(nil)
    else
        self:SetSelectedRoleByIndex(1)
    end

    global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009014))
    global.Facade:sendNotification(global.NoticeTable.Layer_Login_Role_Update)

    ---刷新角色数量
    local module            = global.L_ModuleManager:GetCurrentModule()
    local moduleGameEnv     = module:GetGameEnv()
    local roleData = self._data.roles or {}
    if moduleGameEnv.SetRoleCountByServerID then 
        moduleGameEnv:SetRoleCountByServerID(self:GetSelectedServerId(), #roleData)
    end
end

function LoginProxy:handle_MSG_SC_DELETE_ROLE_FAIL(msg)
    HideLoadingBar(true)

    global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009015))
end

function LoginProxy:RequestRestoreRoleInfo()
    self._data.restoreRoleDatas = {}

    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local account   = tostring(AuthProxy:GetUID())

    LuaSendMsg(global.MsgType.MSG_CS_RESTORE_ROLE_LIST, 0, 0, 0, 0, account, string.len(account))
end

function LoginProxy:handle_MSG_SC_RESTORE_ROLE_LIST(msg)
    -- 558[{uid,uname,ulevel},{uid,uname,ulevel},]
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return nil
    end

    for _,v in pairs(jsonData) do
        table.insert(self._data.restoreRoleDatas, v)
    end

    if #self._data.restoreRoleDatas == 0 then
        SL:ShowSystemTips("你没有可以恢复的角色！")
        return false
    end
    global.Facade:sendNotification(global.NoticeTable.Refresh_RestoreRole_UI)
end

function LoginProxy:getRestoreRoleDatas()
    return self._data.restoreRoleDatas
end

function LoginProxy:RequestRestoreRole(data)
    local sendStr = data.uid .. "/" .. data.uname
    LuaSendMsg(global.MsgType.MSG_CS_RESTORE_ROLE, 0, 0, 0, 0, sendStr, string.len(sendStr))

    releasePrint("request restore role", sendStr)
end

function LoginProxy:handle_MSG_SC_RESTORE_ROLE(msg)
    -- 559 Recog
    -- -1禁止恢复
    -- 0恢复失败
    -- >0恢复成功

    local header = msg:GetHeader()
    if header.recog == -1 then
        ShowSystemTips(GET_STRING(30009090))
        
    elseif header.recog == 0 then
        ShowSystemTips(GET_STRING(30009091))
        
    elseif header.recog > 0 then
        ShowSystemTips(GET_STRING(30009092))
        self._restoreTag = 1

        local specialData  = self:GetNetMsgSpecialData()
        self:RequestRoleInfo(specialData)

        
        global.Facade:sendNotification(global.NoticeTable.Layer_Login_Role_RestoreSuccess)
    end

    releasePrint("restore role resp", header.recog)
end

-- step 7. 103->
function LoginProxy:RequestEnterGame()
    -- debug
    releasePrint("step 7")
    ShowLoadingBar()

    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local account   = AuthProxy:GetUID()
    local roleName  = self:GetSelectedRoleName()

    local sendStr = string.format("%s/%s", account, roleName)
    LuaSendMsg(global.MsgType.MSG_CS_SELECT_ROLE, 0, 0, 0, 0, sendStr, string.len(sendStr))
end

-- step 8. ->525
function LoginProxy:handle_MSG_SC_GAMESERVER_INFO(msg)
    -- debug
    releasePrint("step 8. 525 handle_MSG_SC_GAMESERVER_INFO")
    HideLoadingBar()

    local data = msg:GetData()
    local dataStr = data:ReadString(msg:GetDataLength())
    local slices = string.split(dataStr, "/")
    local ip = tostring(slices[1])
    local port = tonumber(slices[2])

    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local account   = AuthProxy:GetUID()

    self:SetGameServerPort(port)

    local ip          = self:GetSelectedServerIp()
    local proxyport   = self:GetSelectedServerProxyPort()
    local connectIP   = tostring(ip)
    local connectPort = tonumber(proxyport or port)
    -- // Disconnect current server and connect new server

    local errorTips = (connectPort == nil and 0) or (connectPort == 0 and 1) or nil
    if errorTips then
        ShowSystemTips(string.format(GET_STRING(30009300), errorTips))
    end

    local netClient = global.gameEnvironment:GetNetClient()
    netClient:Disconnect()
    local Connect = function (param1Ex)
        local ret = netClient:Connect(connectIP, connectPort)
        releasePrint("525, connect", connectIP, connectPort, ret)
        if 1 ~= ret then
            -- TODO, tips 游戏世界
            return
        end

        -- 20消息
        -- // *#账号/角色名字/角色ID/parma4/920080512/channelid/whitelist
        -- channelid 渠道号 string
        -- whitelist 白名单 1/0  1.白名单 0.非白名单
        local currentModule = global.L_ModuleManager:GetCurrentModule()
        local moduleGameEnv = currentModule:GetGameEnv()
        local whitelist     = (moduleGameEnv:IsWhitelist() == true and 1 or 0)
        local envProxy      = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
        local cert          = global.L_NativeBridgeManager.GetCertification and global.L_NativeBridgeManager:GetCertification()
        local adult         = global.L_NativeBridgeManager.GetAdult and global.L_NativeBridgeManager:GetAdult()
        cert                = (cert == true) and 1 or 0
        adult               = (adult == true) and 1 or 0
        local isboxlogin    = global.L_GameEnvManager:GetEnvDataByKey("isBoxLogin") or 0
        local isBatchMsg    = (global.LuaBridgeCtl:GetModulesSwitch(global.MMO.Modules_Index_Net_BatchMsg) == 1) and 1 or 0
        -- android:0, ios:1  except:2
        local platform = 2
        if cc.PLATFORM_OS_ANDROID == global.Platform or global.isOHOS then
            platform = 0
        elseif cc.PLATFORM_OS_IPAD == global.Platform or cc.PLATFORM_OS_IPHONE == global.Platform then
            platform = 1
        end
        local sendStr = string.format("*#%s/%s/%s/%d/%s/0/%s/%s/%s/%s/%s/%s",
            account,
            self:GetSelectedRoleName(),
            self:GetSelectedRoleID(),
            netClient:GetNetMessageTypeSData(),
            platform,                            --920080512 改 platform参数
            envProxy:GetChannelID(),
            whitelist,
            cert,
            adult,
            isboxlogin,
            isBatchMsg
        )
        
        print("+++++++++++++++++MSG_CS_LOGIN_SERVER:", sendStr )
        local recog = GET_NET_MSG_STAMP_HEAD_RECOG()
        local param1 = param1Ex or GET_NET_MSG_STAMP_HEAD_PARAM1()
        local param2 = tonumber(self:GetMainSelectedServerId() or self:GetSelectedServerId()) or 0
        local param3 = tonumber(self:GetGameServerPort()) or 0

        LuaSendMsg(global.MsgType.MSG_CS_LOGIN_SERVER, recog, param1, param2, param3, sendStr, string.len(sendStr))
    
        local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
        AuthProxy:RequestDecodeJWTToServer()
        -- 小退后 后端需要间隔处理连接 （200ms
        PerformWithDelayGlobal(function()
            AuthProxy:RequestQQDawankaInfo()
        end, 0.20)
    
        AuthProxy:RequestRenewalQQOpenKey(true)

        --公告超时
        global.Facade:sendNotification(global.NoticeTable.GameWorldLoadinTipsTimeout)
    end
    if proxyport then 
        GET_NET_MSG_STAMP_HEAD_PARAM1_NEW(function (param1Ex)
            Connect(param1Ex)
            LoginProxy.param1Ex = nil
        end)
    else
        Connect()
    end
end

-- step 8. ->526
function LoginProxy:handle_MSG_SC_GAMESERVER_INFO_ERROR(msg)
    -- debug
    releasePrint("step 8. 526 handle_MSG_SC_GAMESERVER_INFO_ERROR")
    HideLoadingBar()

    -- nRecog = 99 标识服务器隐藏 或者 维护 不在名单内不能进
    local descStr = GET_STRING(30009003)
    local header = msg:GetHeader()
    if header.recog == 99 then
        descStr = GET_STRING(30009106)
    end

    -- 
    local function callback(bType, custom)
        if global.isWindows then
            global.Director:endToLua()
		else
			global.L_NativeBridgeManager:GN_accountLogout()
			global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
        end
    end
    local data = {}
    data.str    = descStr .. "[526]"
    data.btnDesc = { GET_STRING(30009046)}
    data.callback = callback
    data.hideCloseBtn = true
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

-- step 9. 1018->
function LoginProxy:EnterWorld(isReconnect)
    local envProxy          = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    local currModule        = global.L_ModuleManager:GetCurrentModule()
    local GameConfigMgrProxy = global.Facade:retrieveProxy(global.ProxyTable.GameConfigMgrProxy)

    local contentFix        = GameConfigMgrProxy:getContentFix()
    local jsonData          = contentFix
    jsonData.gameid         = currModule:GetOperID() 
    jsonData.channelId      = envProxy:GetChannelID()
    jsonData.packageName    = envProxy:GetAPKPackageName()
    jsonData.tripartite     = global.OtherTradingBank and 1 or 0
    local sendJson          = cjson.encode( jsonData )

    local visibleSize       = global.Director:getVisibleSize()
    local screenwidth       = visibleSize.width
    local screenheight      = visibleSize.height
    local devicecode        = self:GetDeviceCode()
    local platform          = global.OperatingMode
    local connectV          = isReconnect and 1 or 0
    local isEMU             = global.L_GameEnvManager:IsEmulator() and 1 or 0
    local param2            = Merge16Bit(connectV, isEMU)
    local param3            = Merge16Bit(screenwidth, screenheight)
    LuaSendMsg(global.MsgType.MSG_CS_ENTER_GAME_DUMMY, platform, param2, param3, devicecode, sendJson, string.len(sendJson))

    -- debug
    releasePrint("step 9", os.date(), platform, param2, param3, devicecode, sendJson)
end

function LoginProxy:SaveDeviceCode(code) --本地储存devicecode
    local userData = UserData:new("ContentFix")
    userData:setStringForKey("devicecode", code)
end

function LoginProxy:GetDeviceCode() --获取devicecode
    local userData = UserData:new("ContentFix")
    local code = userData:getStringForKey("devicecode", "")
    if code == "" or code == nil then
        code = 0
    end
    print(code,"devicecode")
    return code
end

function LoginProxy:RequestRoleName(job, sex)
    ShowLoadingBar(3)
    LuaSendMsg(global.MsgType.MSG_CS_ROLE_NAME, job, sex)
end

function LoginProxy:handle_MSG_SC_ROLE_NAME(msg)
    HideLoadingBar()
    local len = msg:GetDataLength()
    if len <= 0 then
        return nil
    end

    local msgData = msg:GetData()
    local sliceStr = msgData:ReadString(len)

    global.Facade:sendNotification(global.NoticeTable.Layer_Login_Role_RandNameResp, sliceStr)
end

function LoginProxy:RequestLeaveWorldNotify()
    -- 小退要发送一个消息给服务器
    LuaSendMsg(global.MsgType.MSG_CS_REBACK_TO_ROLE)
end

function LoginProxy:RequestSoftClose()
    -- 请求小退  服务器返回可以小退才能小退
    LuaSendMsg(global.MsgType.MSG_CS_QURYSOFTCLOSE)
end

function LoginProxy:handle_MSG_SC_SERVER_FORBIDDEN(msg)
    releasePrint("step 10 handle_MSG_SC_SERVER_FORBIDDEN")
    local function callback(bType, custom)
        if global.isWindows then
            global.Director:endToLua()
		else
			global.L_NativeBridgeManager:GN_accountLogout()
			global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
        end
    end
    local data = {}
    data.str    = GET_STRING(30009053)
    data.btnDesc = { GET_STRING(30009046)}
    data.callback = callback
    data.hideCloseBtn = true
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)

    -- 重连禁用
    global.Facade:sendNotification(global.NoticeTable.ReconnectForbidden)
end

function LoginProxy:handle_MSG_SC_SERVER_FORBIDDEN_NET_ERROR(msg)
    releasePrint("step 10 handle_MSG_SC_SERVER_FORBIDDEN_NET_ERROR")

    -- 重连禁用
    global.Facade:sendNotification(global.NoticeTable.ReconnectForbidden)

    -- 不弹提醒
    local header = msg:GetHeader()
    if header.recog == 1 then
        return
    end

    local function callback(bType, custom)
        -- PC上默认退出，方便获取新的登录信息以及更新exe
        if global.isWindows then
            global.Director:endToLua()
		else
			global.L_NativeBridgeManager:GN_accountLogout()
			global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
        end
    end
    local data = {}
    data.str    = GET_STRING(30009061)
    data.btnDesc = { GET_STRING(30009046)}
    data.callback = callback
    data.hideCloseBtn = true
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

--小退
function LoginProxy:handle_MSG_SC_REBACK_TO_ROLE(msg)
    -- body
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return
    end
    
    if jsonData.SoftCloseSuccess == 1 then
        if self:GetSelectedRoleID() == jsonData.UserID then --小退处理
            global.gameWorldController:OnGameLeaveWorld()
        end
    else
        global.Facade:sendNotification( global.NoticeTable.SystemTips, GET_STRING(310000100) )
    end
end

-- 2020->
function LoginProxy:SyncVersion()
    local AuthProxy     = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local currModule    = global.L_ModuleManager:GetCurrentModule()
    local account       = AuthProxy:GetUID()
    local resOriginVer  = currModule:GetOriginVersion()
    local resRemoteVer  = currModule:GetRemoteVersion()
    local sdkuid        = global.L_NativeBridgeManager:GetSdkuid() or global.L_NativeBridgeManager:GetUsername() or account
    
    local isBoxLogin    = global.L_GameEnvManager:GetEnvDataByKey("isBoxLogin") == 1 --盒子登录
    local hasBuf        = global.L_NativeBridgeManager:GetHasBuff() or "0"
    local versionCode   = global.L_GameEnvManager:GetAPKVersionCode()
    versionCode         = isBoxLogin and tonumber(versionCode) + 1000 or versionCode
    local channelID     = global.L_GameEnvManager:GetChannelID()
    local hasNp         = tostring(SL:GetMetaValue("PC_NP_STATUS") and 1 or 0)
    local is996cloudDevice         = tostring(SL:GetMetaValue("996_CLOUD_DEVICE") and 1 or 0)

    local sendStr = string.format("%s/%s/%s/%s/%s/%s/%s/%s/%s", account, resOriginVer, resRemoteVer, tostring(sdkuid), hasBuf, versionCode, channelID, hasNp,
        is996cloudDevice)
    local sendLen = string.len(sendStr)
    releasePrint("sync version:" .. sendStr)
    LuaSendMsg(global.MsgType.MSG_CS_SYNC_VERSION, 0, 0, 0, 0, sendStr, sendLen)
end

function LoginProxy:unScheduleServerList()
    if self.reqServerListScheduleID then 
        UnSchedule(self.reqServerListScheduleID)
        self.reqServerListScheduleID = nil
    end
end

function LoginProxy:connectTimeOutTips()
    local function callback(bType)
        if bType == 1 then
            -- PC上默认退出，方便获取新的登录信息以及更新exe
            if global.isWindows then
                global.Director:endToLua()
            else
                global.L_NativeBridgeManager:GN_accountLogout()
                global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
            end
        end
    end
    local data = {}
    data.str = GET_STRING(600003000)
    data.btnDesc = {GET_STRING(600003001)}
    data.callback = callback
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

function LoginProxy:RegisterMsgHandler()
    LoginProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler(msgType.MSG_SC_RESPONSE_SERVER_LIST,          handler(self, self.handle_MSG_SC_RESPONSE_SERVER_LIST))
    LuaRegisterMsgHandler(msgType.MSG_SC_RESPONSE_SERVER_INFO,          handler(self, self.handle_MSG_SC_RESPONSE_SERVER_INFO))
    LuaRegisterMsgHandler(msgType.MSG_SC_CREATE_ROLE_SUCCESS,           handler(self, self.handle_MSG_SC_CREATE_ROLE_SUCCESS))
    LuaRegisterMsgHandler(msgType.MSG_SC_CREATE_ROLE_FAIL,              handler(self, self.handle_MSG_SC_CREATE_ROLE_FAIL))
    LuaRegisterMsgHandler(msgType.MSG_SC_DELETE_ROLE_SUCCESS,           handler(self, self.handle_MSG_SC_DELETE_ROLE_SUCCESS))
    LuaRegisterMsgHandler(msgType.MSG_SC_DELETE_ROLE_FAIL,              handler(self, self.handle_MSG_SC_DELETE_ROLE_FAIL))
    LuaRegisterMsgHandler(msgType.MSG_SC_RESTORE_ROLE_LIST,             handler(self, self.handle_MSG_SC_RESTORE_ROLE_LIST))
    LuaRegisterMsgHandler(msgType.MSG_SC_RESTORE_ROLE,                  handler(self, self.handle_MSG_SC_RESTORE_ROLE))
    LuaRegisterMsgHandler(msgType.MSG_SC_RESPOINSE_ROLE_INFO,           handler(self, self.handle_MSG_SC_RESPOINSE_ROLE_INFO))
    LuaRegisterMsgHandler(msgType.MSG_SC_RESPOINSE_ROLE_INFO_FAIL,      handler(self, self.handle_MSG_SC_RESPOINSE_ROLE_INFO_FAIL))
    LuaRegisterMsgHandler(msgType.MSG_SC_GAMESERVER_INFO,               handler(self, self.handle_MSG_SC_GAMESERVER_INFO))
    LuaRegisterMsgHandler(msgType.MSG_SC_GAMESERVER_INFO_ERROR,         handler(self, self.handle_MSG_SC_GAMESERVER_INFO_ERROR))
    LuaRegisterMsgHandler(msgType.MSG_SC_ROLE_NAME,                     handler(self, self.handle_MSG_SC_ROLE_NAME))
    LuaRegisterMsgHandler(msgType.MSG_SC_SERVER_FORBIDDEN,              handler(self, self.handle_MSG_SC_SERVER_FORBIDDEN))
    LuaRegisterMsgHandler(msgType.MSG_SC_SERVER_FORBIDDEN_NET_ERROR,    handler(self, self.handle_MSG_SC_SERVER_FORBIDDEN_NET_ERROR))
    LuaRegisterMsgHandler(msgType.MSG_SC_RESPOINSE_CHECK_TOKEN_FAIL,    handler(self, self.handle_MSG_SC_RESPOINSE_CHECK_TOKEN_FAIL))
    LuaRegisterMsgHandler(msgType.MSG_SC_REBACK_TO_ROLE,                handler(self,self.handle_MSG_SC_REBACK_TO_ROLE))                --小退是否成功数据
end

return LoginProxy
