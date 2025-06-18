local RemoteProxy = requireProxy("remote/RemoteProxy")
local ServerTimeProxy = class("ServerTimeProxy", RemoteProxy)
ServerTimeProxy.NAME = global.ProxyTable.ServerTimeProxy

local cjson = require("cjson")

function ServerTimeProxy:ctor()
    ServerTimeProxy.super.ctor(self)

    self._openDay = 1 --开服天数
    self._openTime = 0 --开服时间戳
    self._mergeCount = 0 --合服次数
    self._mergeTime = 0 --合服时间戳
    self._mergeDay = 0 --合区天数
    self._isKfState = nil
    self:StartTimer()
end

function ServerTimeProxy:GetOpenDay()
    return self._openDay
end

function ServerTimeProxy:GetOpenTime()
    return self._openTime
end

function ServerTimeProxy:GetMergeCount()
    return self._mergeCount or 0
end

function ServerTimeProxy:GetMergeTime()
    return self._mergeTime or 0
end

function ServerTimeProxy:GetMergeDay()
    return self._mergeDay or 0
end

function ServerTimeProxy:SetServerTime(unixtime)
    unixtime = unixtime or os.time()
    global.MMO.ServerTime_Sub = unixtime - os.time()
end

function ServerTimeProxy:IsKfState()
    return self._isKfState == 1
end

function ServerTimeProxy:SetKFState(state)
    self._isKfState = state
end

--kfday  开服天数
--unixtime 当前时间戳
--kfunixtime 开服时间戳
function ServerTimeProxy:SaveTimeData(data)
    if not data then return end
    self:SetServerTime(data.unixtime)
    self._openDay = data.kfday
    self._openTime = data.kfunixtime
    self._mergeCount = data.hfcount
    self._mergeTime = data.hfunixtime
    self._mergeDay = data.hfday
end

function ServerTimeProxy:handle_MSG_SC_SERVER_TIME_RESPONSE(msg)
    local header = msg:GetHeader()
    local len = msg:GetDataLength()
    self:SetServerTime(header.recog)
end

function ServerTimeProxy:handle_MSG_SC_ACROSS_DAY_RESPONSE(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then return end
    dump(jsonData)
    self:SaveTimeData(jsonData)

    ssr.ssrBridge:OnAcrossDay()
end

function ServerTimeProxy:StartTimer()
    local function upload()
        self._timer = nil
        local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
        local serverIp    = LoginProxy:GetSelectedServerIp()
        if not string.match(serverIp, "^s") then
            self.RequestUploadServerInfo()
        end
    end
    self._timer = PerformWithDelayGlobal(upload, 5 * 60)
end

function ServerTimeProxy:RequestUploadServerInfo(onlineNum)
    if global.isDebugMode or global.isGMMode then
        return
    end

    local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    local uploadUrl = "https://996engine.cn-hangzhou.log.aliyuncs.com/logstores/client_log/track?APIVersion=0.6.0"

    local UploadServerInfoDoamin = envProxy:GetCustomDataByKey("UploadServerInfoDoamin")
    if UploadServerInfoDoamin and string.len(UploadServerInfoDoamin) > 0 then 
        uploadUrl = UploadServerInfoDoamin .. "/logstores/client_log/track?APIVersion=0.6.0"
    end
    local device = ""
    if global.isWindows then
        device = "pc"
    elseif global.isAndroid or global.isOHOS then
        device = "android"
    elseif global.isIOS then
        device = "ios"
    end

    local data = {}
    data.operateType    = 1        --类型
    data.onlineNum      = onlineNum
    data.resRemoteVer   = global.L_ModuleManager:GetCurrentModule():GetRemoteVersion()
    data.gameid         = global.L_ModuleManager:GetCurrentModule():GetOperID()
    data.channelid      = envProxy:GetChannelID()
    data.promote_id     = global.L_GameEnvManager:GetEnvDataByKey("promote_id") 
    data.serverId       = LoginProxy:GetSelectedServerId()
    data.serverName     = LoginProxy:GetSelectedServerName()
    data.serverIp       = LoginProxy:GetSelectedServerIp()
    data.serverPort     = LoginProxy:GetGameServerPort()
    data.serverVer      = LoginProxy:GetServiceVer()
    data.roleName       = LoginProxy:GetSelectedRoleName()
    data.roleId         = LoginProxy:GetSelectedRoleID()
    data.roleLevel      = PlayerProperty:GetRoleLevel()
    data.device_type    = device

    local suffix = ""
    for key, value in pairs(data) do
        if value then
            suffix = suffix .. string.format("&%s=%s", key, value)
        end
    end

    local function httpCB(success, response)
        if not success then
            return false
        end
        print(response)
    end
    local url = uploadUrl .. suffix
    HTTPRequest(url, httpCB)
    releasePrint("RequestServer_Upload url: " .. url)
end

function ServerTimeProxy:handle_MSG_SC_SERVER_INFO_UPLOAD(msg)
    local header = msg:GetHeader()
    if header and header.recog > 0 then -- 实际人数  
        self:RequestUploadServerInfo(header.recog)
    end
end

function ServerTimeProxy:RegisterMsgHandler()
    ServerTimeProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler(msgType.MSG_SC_SERVER_TIME_RESPONSE, handler(self, self.handle_MSG_SC_SERVER_TIME_RESPONSE)) -- 返回服务器时间
    LuaRegisterMsgHandler(msgType.MSG_SC_ACROSS_DAY_RESPONSE, handler(self, self.handle_MSG_SC_ACROSS_DAY_RESPONSE))
    LuaRegisterMsgHandler(msgType.MSG_SC_SERVER_INFO_UPLOAD, handler(self, self.handle_MSG_SC_SERVER_INFO_UPLOAD))
end

return ServerTimeProxy