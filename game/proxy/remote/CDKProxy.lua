--[[    author:yzy
    time:2021-12-31 16:21:52
]]
local RemoteProxy = requireProxy("remote/RemoteProxy")
local CDKProxy = class("CDKProxy", RemoteProxy)
CDKProxy.NAME = global.ProxyTable.CDKProxy

function CDKProxy:ctor()
    CDKProxy.super.ctor(self)

    self._haveGainedReward = false
end

function CDKProxy:SendHTTPRequestPost(conver_id)
    local loginProxy    = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local envProxy      = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)

    local userid        = loginProxy:GetSelectedRoleID()
    local rolename      = loginProxy:GetSelectedRoleName()
    local code          = conver_id
    local serverid      = loginProxy:GetSelectedServerId()
    local operid        = global.L_ModuleManager:GetCurrentModule():GetOperID()
    local platformid    = envProxy:GetChannelID()

    local serverip      = loginProxy:GetSelectedServerIp()
    local serverdomain  = loginProxy:GetSelectedServerDomain()
    local cdkURL        = envProxy:GetCustomDataByKey("checkCodeUrl")

    if not cdkURL or string.len(cdkURL) <= 0 then
        return
    end

    local cjson = require("cjson")
    -- http数据请求回调
    local function callback(success, response)
        if success then
            local jsonData = cjson.decode(response)
            if not jsonData then
                release_print("request Convert error: step 2, convert code http callback！ json decode error")
                return false
            end
            --[[                Scodearr=array（
                    0=>’激活码可用”，
                    2=>’激活码不可用”，
                    2=>’激活码不存在’，
                    3=>’激活到已失效’，
                    4=>’使用过同类礼包’，
                    5=>’激活码已使用’，
                    6=>’激活码繁忙，请稍后重试”，
            ]]
            dump(jsonData, "jsonData::::")

            local titleStr = jsonData.msg or GET_STRING(300000900)
            global.Facade:sendNotification(global.NoticeTable.SystemTips, titleStr)
        else
            release_print("request Convert error: step 1, convert code http callback！ failed")
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(300000990))
        end
    end
    local suffix = string.format("userid=%s&name=%s&code=%s&serverid=%s&operid=%s&platformId=%s&serverDomain=%s", userid, rolename, code, serverid, operid, platformid, serverdomain)
    HTTPRequestPost(cdkURL, callback, suffix)
end

function CDKProxy:handle_MSG_SC_CONVERT_RESPONSE(msg)
    local msgLen = msg:GetDataLength()
    if msgLen > 0 then
        local dataString = msg:GetData():ReadString(msgLen)
        local convertID = dataString
        if convertID then
            self:SendHTTPRequestPost(convertID)
        end
    else
        release_print("Convert string len is 0")
    end
end

function CDKProxy:RegisterMsgHandler()
    CDKProxy.super.RegisterMsgHandler(self)

    local msgType = global.MsgType
    LuaRegisterMsgHandler(msgType.MSG_SC_CONVERT_RESPONSE, handler(self, self.handle_MSG_SC_CONVERT_RESPONSE))
end

return CDKProxy