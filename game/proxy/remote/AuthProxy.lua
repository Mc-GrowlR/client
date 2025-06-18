local RemoteProxy = requireProxy("remote/RemoteProxy")
local AuthProxy = class("AuthProxy", RemoteProxy)
AuthProxy.NAME = global.ProxyTable.AuthProxy

local sha1 = require( "sha1/init" )
local cjson = require("cjson")
local socket = require "socket"


local sformat   = string.format

local appid     = "10001"
local gameid    = "1"
local signkey   = "634eff98723b31da43ed35f0dd4edf36"                   --key"dc772af6372cea474ceb38ea5acc9104"
local doamin    = "http://sdk.dhsf.xqhuyu.com/"
local url_visitor           = "user/yk_register"              -- 地址： 游客登录
local url_forgetpwd         = "user/forgetPassword"           -- 地址： 忘记密码
-- local url_bindPhone         = "user/bindPhone"                -- 地址： 绑定手机
local url_alipay            = "pay/alipay"                    -- 地址:  支付宝支付
local url_weixin            = "pay/wap_wx"                    -- 地址:  微信支付
local url_alipay_sdk        = "PayQuyou/wap_alipay"           -- 地址:  三方支付宝
local url_weixin_sdk        = "PayQuyou/wap_wx"               -- 地址:  三方微信
local url_qrcode_alipay_sdk = "PayQuyou/qrcode_alipay"        -- 地址:  三方支付宝 二维码
local url_qrcode_weixin_sdk = "PayQuyou/qrcode_wx"            -- 地址:  三方微信   二维码
-- local url_decode_jwt        = "XlNotify.php"                  -- 地址： 解密jwt HS256
-- 现在支付 
local xz_url_pay            = "PayX/xzH5Pay"  
local xz_qrcode_pay         = "PayX/xzCodePay"
local xz_get_qrcode         = "PayX/getUserQrcode"

local newDoamin2= "http://pay-sdkv2.dhsf.xqhuyu.com/api/"
local url_qrcode_weixin     = "pay/orderPlace"            -- 地址:  二维码支付 微信   以前的doamin .. "pay/qrcode_wx"
local url_qrcode_alipay     = "pay/orderPlace"            -- 地址:  二维码支付 支付宝 以前的doamin .. "pay/qrcode_alipay"
local url_get_qrcode        = "pay/getUserQrcode"         -- 地址:  下载二维码  以前的doamin .. "pay/get_user_qrcode"

-- 聚合
local juhe_secret_key       = "ptONCD6UxNbQRxYrvdVpFACgL1Ir53rjfUO0lOM2Did0ZxGEg2WB0WfhtsqTT2ee"
local juhe_domain           = "http://pcjuhe.dhsf.xqhuyu.com"
local juhe_url_pay          = "/v1/recharge"
local juhe_url_upload       = "/v1/yylog"

local domain_qqGame         = "https://xdwqq.dhsf.xqhuyu.com"
local juhe_url_qqPay        = "/v1/qq_buy"
local juhe_url_qqUpload     = "/v1/qq_yylog"
local juhe_url_qqFilter     = "/v1/uic_filter"


local doamin2               = "http://sdkv2.dhsf.xqhuyu.com/api/"        -- 测试："http://sdk-dev.dhsf.xqhuyu.com/api/"
local url_authCode          = "user/sendsms"                  -- 地址： 发送手机验证码
local url_register          = "user/reg"                      -- 地址： 普通注册
local url_login             = "user/login"                    -- 地址： 登录  
local url_bindPhoneByMb     = "user/bindPhoneByMb"            -- 地址： 绑定手机 密保绑定
local url_changePhone       = "user/changePhone"              -- 地址： 修改手机
local url_changepwdByPhone  = "user/changePwdByPhone"         -- 地址： 修改密码 验证码修改
local url_changepwdByMb     = "user/changePwdByMb"            -- 地址： 修改密码 密保修改
local url_changeMb          = "user/changemb"                 -- 地址： 修改密保
local url_checkToken        = "user/checkToken"               -- 地址： 检测token有效性
local url_identify          = "user/identification"           -- 地址： 实名认证
local url_loginByPhone      = "user/phoneLogin"               -- 地址： 手机验证码登录

-- 盒子创角上报
local domain_box            = "https://user-api.996box.com"              -- 测试："boxuser-dev.dhsf.xqhuyu.com"
local url_roleAD            = "/v1/AdData/pcGameRole"
local signBoxKey            = "zg1zn559tgh4enh25mz2hn2"                  -- 盒子秘钥

-- 新游推荐上报创角
local domain_boxN           = "http://footprint.996box.com"                     -- 测试: "http://anvj.dhsftest.xqhuyu.com"
local url_roleNewRecom      = "/api/GameRecommend/pcGameRole"   
-- PC盒子支付拉取场景
local url_getSceneInfo      = "/api/GameRole/getSceneInfo"
local boxSceneSignKey       = "7PZJImoeAE5Dnjb6pCYu8Ja5Buhb2urL"

-- 腾讯域名
local host_tencent          = "https://openapi.minigame.qq.com" --"http://openapi.tencentyun.com"  -- test  "http://openapi.sparta.html5.qq.com/"     

--云手机上报
local cloud_box_url         = "https://api.996box.com"
local cloud_record_url      =  "/user/v1/cloud/device/recordGameUser"

AuthProxy.PAY_CHANNEL = 
{
    ALIPAY  = "ALIPAY",         -- 支付宝
    HUABEI  = "HUABEI",         -- 花呗
    WEIXIN  = "WEIXIN",         -- 微信
}

AuthProxy.PAY_TYPE = 
{
    NATIVE  = "NATIVE",         -- 原生
    QRCODE  = "QRCODE",         -- 二维码
}

local function urlencodechar(char)
    return "%" .. string.format("%02X", string.byte(char))
end

local function urlencodeT(input)
    -- convert line endings
    input = string.gsub(tostring(input), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%-%_%~ ])", urlencodechar)
    -- convert spaces to "+" symbols
    return string.gsub(input, " ", "+")
end

local function calcSuffix(originData)
    -- ascii排序
    table.sort(originData, function(a, b)
        return a.key < b.key
    end)

    -- 计算sign
    local origin = ""
    local realOrigin = ""
    for i, v in ipairs(originData) do
        local send_value = v.value
        if send_value then
            if string.find(send_value, "%%") then
                local strList = string.split(send_value, "%")
                local t = urlencodeT("%")
                send_value = table.concat(strList, t)
            end

            if string.find(send_value, "%+") then
                local strList = string.split(send_value, "+")
                local t = urlencodeT("+")
                send_value = table.concat(strList, t)
            end

            if string.find(send_value, "%&") then
                local strList = string.split(send_value, "&")
                local t = urlencodeT("&")
                send_value = table.concat(strList, t)
            end
        end
        origin = origin .. sformat("%s=%s", v.key, v.value)
        origin = origin .. (i < #originData and "&" or "")

        realOrigin = realOrigin .. sformat("%s=%s", v.key, send_value)
        realOrigin = realOrigin .. (i < #originData and "&" or "")
    end
    local sign = sha1.hmac(signkey, origin)

    -- 拼接sign
    local suffix = realOrigin .. "&" .. sformat("sign=%s", sign)
    return suffix
end

local function getHeader()
    local header    = {
        imei        = "",
        imei2       = "",
        meid        = "",
        deviceid    = "",
    }
    return header
end

local function calcBoxSignSuffix(originData, secret_key, unlencode)
    
    table.sort(originData, function(a, b)
        return a.key < b.key
    end)

    -- 拼接
    local origin = ""
    local valueStr = ""
    for i, v in ipairs(originData) do
        if v and v.key and v.value and string.len(v.key) > 0 and string.len(v.value) > 0 then
            if unlencode then
                origin = origin .. string.format("%s=%s", v.key, urlencodeT(v.value)) 
            else
                origin = origin .. string.format("%s=%s", v.key, v.value)
            end
            origin = origin ..  "&"
            valueStr = valueStr .. v.value
        end
    end

    origin = string.sub(origin, 1, string.len(origin)-1)

    local rqtime = os.time()	
    local rqrandom = randDataID("Box")
    valueStr = valueStr .. secret_key .. rqtime .. rqrandom

    origin = origin.."&rqtime="..rqtime.."&rqrandom="..rqrandom
    print("calcBoxSignSuffix", origin)
    -- 
    local signMD5 = get_str_MD5(valueStr)
    local suffix  = origin .. "&" .. string.format("sign=%s", signMD5)
    
    return suffix
end

function AuthProxy:ctor()
    AuthProxy.super.ctor(self)
    ---------------------域名切换---------------------
    local BaseDoamin =  self:GetCustomDataByKey("BaseDoamin")
    if BaseDoamin and string.len(BaseDoamin) > 0 then 
        doamin = BaseDoamin .. "/"
    end

    local QRCodePayDoamin =  self:GetCustomDataByKey("QRCodePayDoamin")
    if QRCodePayDoamin and string.len(QRCodePayDoamin) > 0 then 
        newDoamin2 = QRCodePayDoamin .. "/api/"
    end

    local PCJuHeDoamin =  self:GetCustomDataByKey("PCJuHeDoamin")
    if PCJuHeDoamin and string.len(PCJuHeDoamin) > 0 then 
        juhe_domain = PCJuHeDoamin
    end

    local QQPayAndSensitiveWordDoamin =  self:GetCustomDataByKey("QQPayAndSensitiveWordDoamin")
    if QQPayAndSensitiveWordDoamin and string.len(QQPayAndSensitiveWordDoamin) > 0 then 
        domain_qqGame = QQPayAndSensitiveWordDoamin
    end

    local NewBaseDoamin =  self:GetCustomDataByKey("NewBaseDoamin")
    if NewBaseDoamin and string.len(NewBaseDoamin) > 0 then 
        doamin2 = NewBaseDoamin .. "/api/"
    end

    local BoxNDoamin =  self:GetCustomDataByKey("BoxNDoamin")
    if BoxNDoamin and string.len(BoxNDoamin) > 0 then 
        domain_boxN = BoxNDoamin
    end

    local TencentDoamin =  self:GetCustomDataByKey("TencentDoamin")
    if TencentDoamin and string.len(TencentDoamin) > 0 then 
        host_tencent = TencentDoamin
    end

    local BoxCloudDoamin =  self:GetCustomDataByKey("BoxCloudDoamin")
    if BoxCloudDoamin and string.len(BoxCloudDoamin) > 0 then 
        cloud_box_url = BoxCloudDoamin
    end

    local BoxDoamin =  self:GetCustomDataByKey("996BoxDoamin")
    if BoxDoamin and string.len(BoxDoamin) > 0 then 
        domain_box = BoxDoamin
    end
    -----------------------------------------------
    self._authCode  = ""    -- 手机短信授权码
    self._username  = ""
    self._password  = ""
    self._mobile    = ""
    self._token     = ""
    self._uid       = ""

    local envProxy  = global.Facade:retrieveProxy( global.ProxyTable.GameEnvironment )
    self._isSDKPay  = tonumber(envProxy:GetCustomDataByKey("sdkPay")) == 1
    self._isXZPay   = tonumber(envProxy:GetCustomDataByKey("XZPay")) == 1

    -- 临时处理，初始化一些必要参数
    local tmp           = global.L_GameEnvManager:GetChannelID()
    if tmp and string.len(tmp) > 0 then
        appid           = tmp
    end

    local currModule    = global.L_ModuleManager:GetCurrentModule()
    local tmp           = currModule:GetOperID()
    if tmp and string.len(tmp) > 0 then
        gameid          = tmp
    end

    local tmp           = global.L_GameEnvManager:GetSignkey()
    if tmp and string.len(tmp) > 0 then
        signkey         = tmp
    else
        releasePrint("can't find signkey by env.json, use default")
        -- 测试用
        if global.isWindows and global.isDebugMode then
            global.L_GameEnvManager:SetChannelID("1")
        end
    end

    --
    self._orderId   = ""


    -- 聚合SDK支付参数
    self._juhe_param_subject    = global.L_GameEnvManager:GetEnvDataByKey("juhe_subject")   
    self._juhe_param_game_id    = global.L_GameEnvManager:GetEnvDataByKey("juhe_game_id") 
    self._juhe_param_game_name  = global.L_GameEnvManager:GetEnvDataByKey("juhe_game_name") 
    self._juhe_param_agent_id   = global.L_GameEnvManager:GetEnvDataByKey("juhe_agent_id") --渠道id [仅千贝]
    self._juhe_small_id         = global.L_GameEnvManager:GetEnvDataByKey("juhe_small_id") --小号id [顺玩]
    self._juhe_origin_id        = global.L_GameEnvManager:GetEnvDataByKey("original_user_id")  --神游原始玩家id

    self.downloader         = httpDownloader:new()

    self._canRenewal        = false   -- 可续期状态
    self:OnRegisterNativeFunc()
end

function AuthProxy:GetCustomDataByKey(key)
    local currentModule = global.L_ModuleManager:GetCurrentModule()
    local moduleGameEnv = currentModule:GetGameEnv()
    local customData    = moduleGameEnv:GetCustomData()

    if not customData then
        return nil
    end
    return customData[key]
end

function AuthProxy:releaseDownloader()
    if httpDownloader.Destory and self.downloader then
        httpDownloader:Destory(self.downloader)
        self.downloader = nil
    end
end

function AuthProxy:resetDownloader()
    self:releaseDownloader()
    self.downloader = httpDownloader:new()
end

function AuthProxy:Cleanup()
    self._authCode  = ""
    self._username  = ""
    self._password  = ""
    self._mobile    = ""
    self._token     = ""
    self._uid       = ""
end
function AuthProxy:getGameId()
    return gameid
end
function AuthProxy:RequestLoginAdmin(data)
    self._username  = data.username
    self._password  = data.password
    self._uid       = data.username
    self._token     = data.password

    global.Facade:sendNotification(global.NoticeTable.AuthLoginSuccess, data)
end

function AuthProxy:SetData(data)
    self._username  = data.uid
    self._password  = data.token
    self._uid       = data.uid
    self._token     = data.token
end

function AuthProxy:OnRegisterNativeFunc() 
    local function OnPcSdkLoginSuccess(sender, jsonString)
        local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
        local jsonData = jsonString and cjson.decode(jsonString)
        if jsonData and next(jsonData) then
            AuthProxy:SetData(jsonData)
            global.Facade:sendNotification(global.NoticeTable.AuthLoginSuccess, jsonData)
        end
    end
    -- register native status changing callback
    global.NativeBridgeCtl:removeSelectorsInGroup("PCLoginSuccess")
    global.NativeBridgeCtl:addNativeSelector("PCLoginSuccess", "NG_PcSdkLoginSuccess", OnPcSdkLoginSuccess, nil)
    
end

function AuthProxy:ReadLocalData()
    local userData  = UserData:new("auth")
    self._username  = userData:getStringForKey("username", "")
    self._password  = userData:getStringForKey("password", "")
    self._token     = userData:getStringForKey("token", "")
    self._uid       = userData:getStringForKey("uid", "")

    self:ReadLocalCache()
    self:CleanLocalCache()
end

function AuthProxy:SaveLocalData()
    local savePassword = (global.isDebugMode or global.isGMMode) and self._password or ""
    local userData = UserData:new("auth")
    userData:setStringForKey("username", self._username)
    userData:setStringForKey("password", savePassword)
    userData:setStringForKey("token", self._token)
    userData:setStringForKey("uid", self._uid)
    userData:writeMapDataToFile()
end

function AuthProxy:ReadLocalCache()
    if global.isDebugMode then
        local userData = UserData:new("auth")
        local usernameCache = userData:getStringForKey("username_cache", "")
        local passwordCache = userData:getStringForKey("password_cache", "")
        if usernameCache ~= "" and passwordCache ~= "" then
            self._username = usernameCache
            self._password = passwordCache
        end
    end
end

function AuthProxy:SaveLocalCache()
    if global.isDebugMode then
        local savePassword = (global.isDebugMode or global.isGMMode) and self._password or ""
        local userData = UserData:new("auth")
        userData:setStringForKey("username_cache", self._username)
        userData:setStringForKey("password_cache", savePassword)
        userData:writeMapDataToFile()
    end
end

function AuthProxy:CleanLocalCache()
    local userData = UserData:new("auth")
    userData:setStringForKey("username_cache", "")
    userData:setStringForKey("password_cache", "")
    userData:writeMapDataToFile()
end

function AuthProxy:GetUsername()
    return self._username
end

function AuthProxy:GetPassword()
    return self._password
end

function AuthProxy:GetToken()
    return self._token
end

function AuthProxy:IsValidToken()
    return self._token and string.len(self._token) > 0
end

function AuthProxy:GetMobile()
    return self._mobile
end

function AuthProxy:GetUID()
    return self._uid
end

function AuthProxy:IsSDKPay()
    return self._isSDKPay
end

function AuthProxy:getOrderID()
    return self._orderId
end


--
function AuthProxy:RequestAuthCode(phonenumber)
    -- 1、发送手机验证码
    local url = doamin2 .. url_authCode
    if not (url and string.len(url) > 0) then
        return false
    end
    
    -- http数据请求回调
    local function httpCB(success, response)
        if not success then
            ShowSystemTips("[-1] 获取验证码失败, 请求失败")
            return false
        end
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("[-2] 获取验证码失败, 解析失败")
            return false
        end
        if not (jsonData.code == 200) then
            ShowSystemTips("[-3] 获取验证码失败, 状态异常 "  .. jsonData.msg)
            return false
        end
        dump(jsonData)
    end
    -- local suffix = sformat("phone=%s", phonenumber)
    local originData = {
        {key="phone",       value=phonenumber},
        {key="game_id",     value=gameid},
        {key="appid",       value=appid},
        {key="type",        value="login"},
    }
    local suffix = calcSuffix(originData)
    local header = getHeader()
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestAuthCode url: " .. url .. "   postData: " .. suffix)
end

function AuthProxy:RequestRegister(data)
    -- 2、普通注册
    local url = doamin2 .. url_register
    if not (url and string.len(url) > 0) then
        return nil
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if not success then
            ShowSystemTips("[-1] 注册失败, 请求失败")
            return false
        end
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("[-2] 注册失败, 解析失败")
            return false
        end
        if not (jsonData.code == 200) then
            ShowSystemTips("[-3] 注册失败, 状态异常 " .. jsonData.msg)
            global.Facade:sendNotification(global.NoticeTable.AuthRegisterFailure, jsonData)
            return false
        end

        dump(jsonData)
        self._uid = jsonData.data.uid
        self._token = jsonData.data.token
        self._username = jsonData.data.username
        self._password = jsonData.data.password

        if global.L_NativeBridgeManager.SetCertification and global.L_NativeBridgeManager.SetAdult then
            if jsonData.data.age_status and tonumber(jsonData.data.age_status) == 0 then
                global.L_NativeBridgeManager:SetCertification(false)
                global.L_NativeBridgeManager:SetAdult(false)
            else
                global.L_NativeBridgeManager:SetCertification(true)
                local isAdult = jsonData.data.age_status and tonumber(jsonData.data.age_status) == 2 
                global.L_NativeBridgeManager:SetAdult(isAdult)
            end
        end

        local jData = {}
        jData.userId = self._uid
        global.L_NativeBridgeManager:GN_umengUploadRegister(jData)

        -- notice
        global.Facade:sendNotification(global.NoticeTable.AuthRegisterSuccess, jsonData)
    end

    local originData = {
        {key="username",    value=data.username},
        {key="password",    value=data.password},
        {key="question",    value=data.question},
        {key="answer",      value=data.answer},
        {key="type",        value=data.type},
        {key="game_id",     value=gameid},
        {key="appid",       value=appid},
        {key="promote_id",  value=global.L_GameEnvManager:GetGMName()},
    }

    local DataRePortProxy       = global.Facade:retrieveProxy( global.ProxyTable.DataRePortProxy )
    local registerDataRePort    = DataRePortProxy:UserRegister()
    if registerDataRePort then
        table.insert(originData,{
            key="_device_info",
            value=registerDataRePort
        })
    end

    local suffix = calcSuffix(originData)
    local header = getHeader()
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestRegister url: " .. url .. "  postData: " .. suffix)
end

function AuthProxy:RequestLogin(data)
    -- 3、登陆接口
    local url = doamin2 .. url_login
    if not (url and string.len(url) > 0) then
        return nil
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if not success then
            ShowSystemTips("[-1] 登录失败, 请求失败")
            return false
        end
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("[-2] 登录失败, 解析失败")
            return false
        end
        if not (jsonData.code == 200) then
            ShowSystemTips(jsonData.msg)
            return false
        end

        dump(jsonData)
        self._uid = jsonData.data.uid
        self._token = jsonData.data.token
        self._mobile = jsonData.data.mobile
        self._username = jsonData.data.username

        -- 0 未实名，2成年，3未成年
        if global.L_NativeBridgeManager.SetCertification and global.L_NativeBridgeManager.SetAdult then
            if jsonData.data.age_status and tonumber(jsonData.data.age_status) == 0 then
                global.L_NativeBridgeManager:SetCertification(false)
                global.L_NativeBridgeManager:SetAdult(false)

                global.Facade:sendNotification(global.NoticeTable.Layer_IdentifyID_Open, true)
                return
            else
                global.L_NativeBridgeManager:SetCertification(true)
                local isAdult = jsonData.data.age_status and tonumber(jsonData.data.age_status) == 2 
                global.L_NativeBridgeManager:SetAdult(isAdult)
            end
        end

        local isBind = jsonData.data.mobile
        local isOpenTips = tonumber(jsonData.data.bind_phone) == 1
        if ( not isBind or string.len(isBind) == 0) and isOpenTips then
            --未绑定手机号
            local function callback(bType, custom)
                if bType == 1 then
                    global.Facade:sendNotification(global.NoticeTable.AuthLoginSuccess, jsonData)
                elseif bType == 2 then
                    local LoginAccountMediator = global.Facade:retrieveMediator( "LoginAccountMediator" )
                    if LoginAccountMediator and LoginAccountMediator._layer then
                        if not LoginAccountMediator._layer._isFetchAssets then
                            return false
                        end
                        LoginAccountMediator._layer:ShowBindPhone()
                    end
                end
            end
            local data = {}
            data.str = GET_STRING(700000101)
            data.btnDesc = {  GET_STRING(700000102), GET_STRING(700000103)}
            data.callback = callback
            global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        else
            -- notice
            ShowSystemTips("登录成功")
            global.Facade:sendNotification(global.NoticeTable.AuthLoginSuccess, jsonData)
        end

    end

    if data.type == 1 then
        self._username = data.username
        self._password = data.password
    end

    local platform = -1 
    if global.isWindows then
        platform = 0
    elseif global.isAndroid or global.isOHOS then
        platform = 1
    elseif global.isIOS then
        platform = 2
    end

    local deviceid = nil
    if global.isWindows and getMac then
        deviceid = getMac()
    end
    local originData = {
        {key="username",    value=data.username},
        {key="password",    value=data.password},
        {key="type",        value=data.type},
        {key="platform",    value=platform},
        {key="game_id",     value=gameid},
        {key="appid",       value=appid},
        {key="device_id",   value=deviceid},
        {key="promote_id",  value=global.L_GameEnvManager:GetGMName()}
    }

    local DataRePortProxy   = global.Facade:retrieveProxy( global.ProxyTable.DataRePortProxy )
    local loginDataRePort   = DataRePortProxy:UserLogin()
    if loginDataRePort then
        table.insert(originData,{
            key="_device_info" ,
            value=loginDataRePort
        })
    end

    local suffix = calcSuffix(originData)
    local header = getHeader()
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestLogin url: " .. url .. "  postData: " .. suffix)
end

function AuthProxy:RequestLoginByPhone(data)
    -- 3、登陆接口  手机登录
    local url = doamin2 .. url_loginByPhone
    if not (url and string.len(url) > 0) then
        return nil
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if not success then
            ShowSystemTips("[-1] 登录失败, 请求失败")
            return false
        end
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("[-2] 登录失败, 解析失败")
            return false
        end
        if not (jsonData.code == 200) then
            ShowSystemTips("[-3] 登录失败, 状态异常 " .. jsonData.msg)
            return false
        end

        dump(jsonData)
        self._uid = jsonData.data.uid
        self._token = jsonData.data.token
        self._mobile = jsonData.data.mobile
        self._username = jsonData.data.username

        -- 0 未实名，2成年，3未成年
        if global.L_NativeBridgeManager.SetCertification and global.L_NativeBridgeManager.SetAdult then
            if jsonData.data.age_status and tonumber(jsonData.data.age_status) == 0 then
                global.L_NativeBridgeManager:SetCertification(false)
                global.L_NativeBridgeManager:SetAdult(false)
            else
                global.L_NativeBridgeManager:SetCertification(true)
                local isAdult = jsonData.data.age_status and tonumber(jsonData.data.age_status) == 2 
                global.L_NativeBridgeManager:SetAdult(isAdult)
            end
        end

        -- notice
        global.Facade:sendNotification(global.NoticeTable.AuthLoginSuccess, jsonData)
    end

    self._mobile   = data.phoneId

    local originData = {
        {key="phone",       value=data.phoneId},
        {key="code",        value=data.authCode},
        {key="game_id",     value=gameid},
        {key="appid",       value=appid},
        {key="promote_id",  value=global.L_GameEnvManager:GetGMName()}
    }
    local suffix = calcSuffix(originData)
    local header = getHeader()
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestLogin url: " .. url .. "  postData: " .. suffix)
end

function AuthProxy:RequestVisitor(data)
    -- 4、游客登陆接口
    local url = doamin .. url_visitor
    if not (url and string.len(url) > 0) then
        return nil
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if not success then
            ShowSystemTips("[-1] 游客登录失败, 请求失败")
            return false
        end
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("[-2] 游客登录失败, 解析失败")
            return false
        end
        if not (jsonData.status == 1) then
            ShowSystemTips("[-3] 游客登录失败, 状态异常 " .. jsonData.status .. jsonData.msg)
            return false
        end

        dump(jsonData)
        self._uid = jsonData.data.uid
        self._token = jsonData.data.token
        self._mobile = jsonData.data.mobile
        self._username = jsonData.data.username
        self._password = jsonData.data.password

        -- notice
        global.Facade:sendNotification(global.NoticeTable.AuthVisitorSuccess, jsonData)
    end

    local originData = {
        {key="game_id",     value=gameid},
        {key="appid",       value=appid},
        {key="promote_id",  value=global.L_GameEnvManager:GetGMName()},
    }
    local suffix = calcSuffix(originData)
    local header = getHeader()
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestVisitor url: " .. url .. "  postData: " .. suffix)
end

function AuthProxy:RequestForgetPassword(data)
    -- 5、用户忘记密码
    local url = doamin .. url_forgetpwd
    if not (url and string.len(url) > 0) then
        return nil
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if not success then
            ShowSystemTips("[-1] 修改密码失败, 请求失败")
            return false
        end
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("[-2] 修改密码失败, 解析失败")
            return false
        end
        if not (jsonData.status == 1) then
            ShowSystemTips("[-3] 修改密码失败, 状态异常 " .. jsonData.status .. jsonData.msg)
            return false
        end

        dump(jsonData)
    end

    local originData = {
        {key="phone",       value=data.phonenumber},
        {key="code",        value=data.code},
        {key="newpassword", value=data.newpassword},
        {key="appid",       value=appid},
    }
    local suffix = calcSuffix(originData)
    local header = getHeader()
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestForgetPassword url: " .. url .. "  postData: " .. suffix)
end

function AuthProxy:RequestBindPhoneByMb(data)
    -- 6、绑定手机
    local url = doamin2 .. url_bindPhoneByMb
    if not (url and string.len(url) > 0) then
        return nil
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if not success then
            ShowSystemTips("[-1] 密保绑定手机失败, 请求失败")
            return false
        end
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("[-2] 密保绑定手机失败, 解析失败")
            return false
        end
        if not (jsonData.code == 200) then
            ShowSystemTips("[-3] 密保绑定手机失败, 状态异常 " .. jsonData.msg)
            return false
        end
        dump(jsonData)
        ShowSystemTips("手机号绑定成功")

        global.Facade:sendNotification(global.NoticeTable.AuthBindPhoneResp, jsonData)
    end

    local originData = {
        {key="username",    value=data.username},
        {key="answer",      value=data.answer},
        {key="phone",       value=data.phone},
        {key="code",        value=data.code},
        {key="appid",       value=appid},
        {key="game_id",     value=gameid}
    }
    local suffix = calcSuffix(originData)
    local header = getHeader()
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestBindPhoneByMb url: " .. url .. "  postData: " .. suffix)
end

function AuthProxy:RequestChangePhone(data)
    -- 6、 换绑手机
    local url = doamin2 .. url_changePhone
    if not (url and string.len(url) > 0) then
        return nil
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if not success then
            ShowSystemTips("[-1] 绑定手机失败, 请求失败")
            return false
        end
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("[-2] 密保绑定手机失败, 解析失败")
            return false
        end
        if not (jsonData.code == 200) then
            ShowSystemTips("[-3] 密保绑定手机失败, 状态异常 " .. jsonData.msg)
            return false
        end
        dump(jsonData)
        ShowSystemTips("手机号修改成功")

        global.Facade:sendNotification(global.NoticeTable.AuthBindPhoneResp, jsonData)
    end

    local originData = {
        {key="username",    value=data.username},
        {key="phone",       value=data.phone},
        {key="code",        value=data.code},
        {key="phone_new",   value=data.phone_new},
        {key="code_new",    value=data.code_new},
        {key="appid",       value=appid},
        {key="game_id",     value=gameid},
    }
    local suffix = calcSuffix(originData)
    local header = getHeader()
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestChangePhone url: " .. url .. "  postData: " .. suffix)
end

function AuthProxy:RequestChangePwdByPhone(data)
    -- 7、修改密码
    local url = doamin2 .. url_changepwdByPhone
    if not (url and string.len(url) > 0) then
        return nil
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if not success then
            ShowSystemTips("[-1] 手机修改密码失败, 请求失败")
            return false
        end
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("[-2] 手机修改密码失败, 解析失败")
            return false
        end
        if not (jsonData.code == 200) then
            ShowSystemTips("[-3] 手机修改密码失败, 状态异常 " .. jsonData.msg)
            return false
        end
        dump(jsonData)
        ShowSystemTips("修改成功，请牢记您的新密码")
        self._username = data.username
        self._password = data.newpassword

        global.Facade:sendNotification(global.NoticeTable.AuthChangePwdByPhoneResp, jsonData)
    end

    local originData = {
        {key="username",    value=data.username},
        {key="phone",       value=data.phone},
        {key="code",        value=data.code},
        {key="newpassword", value=data.newpassword},
        {key="appid",       value=appid},
        {key="game_id",     value=gameid},
    }
    local suffix = calcSuffix(originData)
    local header = getHeader()
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestChangePassword url: " .. url .. "  postData: " .. suffix)
end

function AuthProxy:RequestChangePwdByMb(data)
    -- 7、修改密码
    local url = doamin2 .. url_changepwdByMb
    if not (url and string.len(url) > 0) then
        return nil
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if not success then
            ShowSystemTips("[-1] 密保修改密码失败, 请求失败")
            return false
        end
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("[-2] 密保修改密码失败, 解析失败")
            return false
        end
        if not (jsonData.code == 200) then
            ShowSystemTips("[-3] 密保修改密码失败, 状态异常 " .. jsonData.msg)
            return false
        end
        dump(jsonData)
        ShowSystemTips("修改成功，请牢记您的新密码")

        self._username = data.username
        self._password = data.newpassword

        global.Facade:sendNotification(global.NoticeTable.AuthChangePwdResp, jsonData)
    end

    local originData = {
        {key="username",    value=data.username},
        {key="answer",      value=data.answer},
        {key="newpassword", value=data.newpassword},
        {key="appid",       value=appid},
        {key="game_id",     value=gameid},
    }
    local suffix = calcSuffix(originData)
    local header = getHeader()
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestChangePwdByMb url: " .. url .. "  postData: " .. suffix)
end

function AuthProxy:RequestChangeMb(data)
    -- 修改密保
    local url = doamin2 .. url_changeMb
    if not (url and string.len(url) > 0) then
        return nil
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if not success then
            ShowSystemTips("[-1] 修改密保失败, 请求失败")
            return false
        end
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("[-2] 修改密保失败, 解析失败")
            return false
        end
        if not (jsonData.code == 200) then
            ShowSystemTips("[-3] 修改密保失败, 状态异常 " .. jsonData.msg)
            return false
        end
        dump(jsonData)
        ShowSystemTips("修改成功，请牢记您的新密保")

        self._username = data.username
        self._password = data.password
        global.Facade:sendNotification(global.NoticeTable.AuthChangeMbResp, jsonData)
    end

    local originData = {
        {key="username",    value=data.username},
        {key="password",    value=data.password},
        {key="question",    value=data.question},
        {key="answer",      value=data.answer},
        {key="question_new",value=data.question_new},
        {key="answer_new",  value=data.answer_new},
        {key="appid",       value=appid},
        {key="game_id",     value=gameid},
    }
    local suffix = calcSuffix(originData)
    local header = getHeader()
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestChangeMb url: " .. url .. "  postData: " .. suffix)
end

function AuthProxy:RequestCheckToken(uid, token)
    -- 8、验证token有效性 成功后刷新token
    local url = doamin2 .. url_checkToken
    if not (url and string.len(url) > 0) then
        return nil
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if not success then
            ShowSystemTips("[-1] 快速登录失败, 请求失败")
            return false
        end
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("[-2] 快速登录失败, 解析失败")
            return false
        end
        if not (jsonData.code == 200) then
            ShowSystemTips("[-3] 快速登录失败, 状态异常 " .. jsonData.msg)
            -- token验证失败，清空已存储token
            self._token = ""

            -- notice
            global.Facade:sendNotification(global.NoticeTable.AuthCheckTokenFailure, jsonData)
            return false
        end
        dump(jsonData)

        self._uid = jsonData.data.uid
        self._token = jsonData.data.token
        self._mobile = jsonData.data.mobile
        self._username = jsonData.data.username

        if global.L_NativeBridgeManager.SetCertification and global.L_NativeBridgeManager.SetAdult then
            if jsonData.data.age_status and tonumber(jsonData.data.age_status) == 0 then
                global.L_NativeBridgeManager:SetCertification(false)
                global.L_NativeBridgeManager:SetAdult(false)
            else
                global.L_NativeBridgeManager:SetCertification(true)
                local isAdult = jsonData.data.age_status and tonumber(jsonData.data.age_status) == 2 
                global.L_NativeBridgeManager:SetAdult(isAdult)
            end
        end
        -- notice
        global.Facade:sendNotification(global.NoticeTable.AuthCheckTokenSuccess, jsonData)
    end

    local originData = {
        {key="uid",      value=uid},
        {key="token",    value=token},
        {key="game_id",  value=gameid},
        {key="appid",    value=appid},
        {key="promote_id",  value=global.L_GameEnvManager:GetGMName()}
    }
    local suffix = calcSuffix(originData)
    local header = getHeader()
    header["X-Token"] = token
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestCheckToken url: " .. url .. "  postData: " .. suffix)
end

function AuthProxy:RequestAlipay(payData, orderCB)
    -- 支付宝支付
    local url = doamin .. (self._isSDKPay and url_alipay_sdk or url_alipay)

    if self._isXZPay then
        url = doamin .. xz_url_pay
    end
    
    if not (url and string.len(url) > 0) then
        if orderCB then
            orderCB()
        end
        return nil
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if orderCB then
            orderCB()
        end

        if not success then
            ShowSystemTips("[-1] ALIPAY ERROR")
            return false
        end
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("[-2] ALIPAY ERROR")
            return false
        end
        if not (jsonData.status == 1) then
            ShowSystemTips("[-3] ALIPAY ERROR, code: " .. jsonData.status .. jsonData.msg)
            return false
        end
        if not (jsonData.data and jsonData.data.order) then
            ShowSystemTips("[-4] ALIPAY ERROR")
            return false
        end

        releasePrint(cjson.encode(jsonData))
        dump(jsonData)

        -- notify native and do something
        if self._isSDKPay or self._isXZPay then
            cc.Application:getInstance():openURL(jsonData.data.order)
        else
            global.L_NativeBridgeManager:GN_onCallOF({orderInfo = jsonData.data.order})
        end
    end

    local originData    = clone(payData)

    local DataRePortProxy   = global.Facade:retrieveProxy( global.ProxyTable.DataRePortProxy )
    local prePayDataRePort  = DataRePortProxy:PrePay()
    if prePayDataRePort then
        table.insert(originData,{
            key="_device_info" ,
            value=prePayDataRePort,
        })
    end

    local suffix        = calcSuffix(originData)
    local header        = getHeader()
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestAlipay url: " .. url .. "  postData: " .. suffix)
end

function AuthProxy:RequestWXpay(payData, orderCB)
    local function openWebView(url, referer)
        if false == global.isMobile then
            print("++++++++++++++++++++++++++mobile only")
            return
        end

        if self._webView and not tolua.isnull(self._webView) then
            self._webView:removeFromParent()
            self._webView = nil
        end
        local viewURL = url
        local winSize = cc.Director:getInstance():getVisibleSize()
    
        self._webView = ccexp.CustomView and ccexp.CustomView:create() or ccexp.WebView:create()
        if referer then
            if global.isIOS then
                referer = string.gsub(referer, "http://", "")
                referer = string.sub(referer, 1, string.len(referer) - 1)
                referer = referer .. "://"
                self._webView:setReferer(referer)
            else
                self._webView:setReferer(referer)
            end
        end
        self._webView:setPosition(winSize.width / 2, winSize.height / 2)
        self._webView:setContentSize(winSize.width / 2,  winSize.height / 2)
    
        self._webView:setOnShouldStartLoading(function(sender, url)
            releasePrint("onWebViewShouldStartLoading, url is ", url)
            return true
        end)
        self._webView:setOnDidFinishLoading(function(sender, a_url)
            releasePrint("onWebViewDidFinishLoading, url is ", url)
        end)
        self._webView:setOnDidFailLoading(function(sender, url)
            releasePrint("setOnDidFailLoading, url is ", url)
        end)
    
        local ui_root = global.Director:getRunningScene()
        self._webView:setVisible(false)
        ui_root:addChild(self._webView, 999)

        self._webView:loadURL(viewURL)
    end

    -- 微信支付
    local url =  doamin .. (self._isSDKPay and url_weixin_sdk or url_weixin)
    if self._isXZPay then
        url = doamin .. xz_url_pay 
    end
    if not (url and string.len(url) > 0) then
        if orderCB then
            orderCB(false)
        end
        return nil
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if orderCB then
            orderCB()
        end
        if not success then
            ShowSystemTips("[-1] WXPAY ERROR")
            releasePrint("request wxpay failed, code: -1 [request failed]")
            return false
        end
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("[-2] WXPAY ERROR")
            releasePrint("request wxpay failed, code: -2 [parse failed]")
            return false
        end
        if not (jsonData.status == 1) then
            ShowSystemTips("[-3] WXPAY ERROR, code: " .. jsonData.status .. jsonData.msg)
            releasePrint("request wxpay failed, code: " .. jsonData.status .. jsonData.msg)
            return false
        end
        if not (jsonData.data and jsonData.data.url and jsonData.data.referer) then
            ShowSystemTips("[-4] WXPAY ERROR")
            releasePrint("request wxpay failed, code: -3 [url or referer failed]")
            return false
        end

        releasePrint(cjson.encode(jsonData))
        dump(jsonData)

        if self._isSDKPay then
            cc.Application:getInstance():openURL(jsonData.data.order)
        else
            releasePrint(jsonData.data.url .. "referer: " .. jsonData.data.referer)
            openWebView(jsonData.data.url, jsonData.data.referer)
        end
    end

    local originData    = clone(payData)

    local DataRePortProxy   = global.Facade:retrieveProxy( global.ProxyTable.DataRePortProxy )
    local prePayDataRePort  = DataRePortProxy:PrePay()
    if prePayDataRePort then
        table.insert(originData,{
            key="_device_info",
            value=prePayDataRePort
        })
    end

    local suffix        = calcSuffix(originData)
    local header        = getHeader()
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestWXpay url: " .. url .. "  postData: " .. suffix)
end

function AuthProxy:RequestIdentifyID(data)
    --实名认证接口
    local url = doamin2 .. url_identify
    if not (url and string.len(url) > 0) then
        return nil
    end

    if not self:IsValidToken() then
        ShowSystemTips("请登录后操作")
        return
    end
    
    -- http数据请求回调
    local function httpCB(success, response)
        if not success then
            ShowSystemTips("[-1] 实名认证失败, 请求失败")
            return false
        end
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("[-2] 实名认证失败, 解析失败")
            return false
        end
        if not (jsonData.code == 200)  then
            ShowSystemTips("[-3] 实名认证失败, 状态异常 " .. jsonData.msg)
            return false
        end

        dump(jsonData)
        if global.L_NativeBridgeManager.SetCertification and global.L_NativeBridgeManager.SetAdult then
            if jsonData.data.age_status and tonumber(jsonData.data.age_status) == 0 then
                global.L_NativeBridgeManager:SetCertification(false)
                global.L_NativeBridgeManager:SetAdult(false)
            else
                ShowSystemTips("实名认证成功")
                global.L_NativeBridgeManager:SetCertification(true)
                local isAdult = jsonData.data.age_status and tonumber(jsonData.data.age_status) == 2 
                global.L_NativeBridgeManager:SetAdult(isAdult)

                global.Facade:sendNotification(global.NoticeTable.AuthChangePwdResp)
            end
        end
        
    end

    local originData = {
        {key="name",        value=data.name},
        {key="idcard",      value=data.IDNumber},
        {key="game_id",     value=gameid},
        {key="appid",       value=appid},
    }
    local suffix = calcSuffix(originData)
    local header = getHeader()
    header["X-Token"]  = self:GetToken()
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestIdentify url: " .. url .. "  postData: " .. suffix)

end

----------------------------------------------------------
-- 二维码支付
function AuthProxy:RequestQRCodePay(payChannel, payData, orderCB)
    local url = nil
    if self.PAY_CHANNEL.WEIXIN == payChannel then
        url = self._isSDKPay and (doamin .. url_qrcode_weixin_sdk) or (newDoamin2 .. url_qrcode_weixin)

    elseif self.PAY_CHANNEL.ALIPAY == payChannel or self.PAY_CHANNEL.HUABEI == payChannel then
        url = self._isSDKPay and (doamin .. url_qrcode_alipay_sdk) or  (newDoamin2 .. url_qrcode_alipay)
    end

    if self._isXZPay then
        url = doamin .. xz_qrcode_pay
    end
    
    if not (url and string.len(url) > 0) then
        if orderCB then
            orderCB(false)
        end
        return nil
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if not success then
            ShowSystemTips("QRCODEPAY ERROR [-1]")
            
            if orderCB then
                orderCB(false)
            end
            return false
        end
        print(response)
        local jsonData = cjson.decode(response)
        if not jsonData then
            ShowSystemTips("QRCODEPAY ERROR [-2]")

            if orderCB then
                orderCB(false)
            end
            return false
        end
        jsonData.status = jsonData.status or jsonData.data.status or 0
        if not (jsonData.status == 1) then
            ShowSystemTips("QRCODEPAY ERROR [-3] " .. jsonData.status .. jsonData.msg)

            if orderCB then
                orderCB(false)
            end
            return false
        end
        if not (jsonData.data and jsonData.data.order_no) then
            ShowSystemTips("QRCODEPAY ERROR [-4]")

            if orderCB then
                orderCB(false)
            end
            return false
        end

        dump(jsonData)

        -- 请求支付二维码
        local originData = {
            {key="order_no",    value=jsonData.data.order_no},
        }
        local suffix = calcSuffix(originData)
        local get_qrcode_url = self._isXZPay and (doamin .. xz_get_qrcode) or (newDoamin2 .. url_get_qrcode)
        local url    = string.format("%s?%s", get_qrcode_url, suffix)
        
        orderCB(true, url)
    end

    local originData    = clone(payData)

    local DataRePortProxy   = global.Facade:retrieveProxy( global.ProxyTable.DataRePortProxy )
    local prePayDataRePort  = DataRePortProxy:PrePay()
    if prePayDataRePort then
        table.insert(originData,{
            key="_device_info",
            value=prePayDataRePort
        })
    end

    local suffix        = calcSuffix(originData)
    local header        = getHeader()
    HTTPRequestPost(url, httpCB, suffix, header)
    releasePrint("RequestQRCodePay url: " .. url .. "  postData: " .. suffix)
end

function AuthProxy:RequestPay(payType, payChannel, productData, qrcodeCB)
    local timeMS        = socket.gettime() * 10000
    local trade_no      = sformat("HEROES_DREAM_%s_%09d", timeMS, Random(1, 999999999))
    self._orderId       = trade_no

    local GMSdkPay      = self._isXZPay

    local pay_way       = nil
    if GMSdkPay and self.PAY_TYPE.QRCODE == payType then
        pay_way = 7
    elseif GMSdkPay and self.PAY_TYPE.NATIVE == payType then
        if self.PAY_CHANNEL.ALIPAY == payChannel or self.PAY_CHANNEL.HUABEI == payChannel then
            pay_way = 5
        elseif self.PAY_CHANNEL.WEIXIN == payChannel then
            pay_way = 6
        end
    else
        if self.PAY_CHANNEL.ALIPAY == payChannel then
            pay_way = 3
        elseif self.PAY_CHANNEL.HUABEI == payChannel then
            pay_way = 20
        elseif self.PAY_CHANNEL.WEIXIN == payChannel then
            pay_way = 4
        end
    end
    
    -- 新增 主服id和主服name
    local LoginProxy    = global.Facade:retrieveProxy( global.ProxyTable.Login )
    local selSerInfo    = LoginProxy:GetSelectedServer()
    local mainServerId  = selSerInfo and selSerInfo.mainServerId or productData.serverId
    local mainServerName= selSerInfo and selSerInfo.mainServerName or productData.serverName
    local server_id     = string.format("%s:%s", productData.serverId or "", mainServerId or "")
    local server_name   = string.format("%s$$%s", productData.serverName or "", mainServerName or "")

    -- 请求支付
    local payData       = {
        {key="uid",             value=self._uid},
        {key="appid",           value=appid},
        {key="game_id",         value=gameid},
        {key="promote_id",      value=global.L_GameEnvManager:GetGMName()},
        {key="role_id",         value=productData.roleId},
        {key="server_id",       value=server_id},
        {key="role_name",       value=productData.roleName},
        {key="server_name",     value=server_name},
        {key="trade_no",        value=trade_no},
        {key="payplatform2cp",  value=productData.currencyID},
        {key="props_name",      value=productData.productName},
        {key="price",           value=productData.productPrice},
        {key="is_huabei",       value=(self.PAY_CHANNEL.HUABEI == payChannel and 1 or 0)},
        {key="pay_way",         value=pay_way},
    }

    local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    table.insert(payData,{key="job_id",  value=PlayerPropertyProxy:GetRoleJob()})
    table.insert(payData,{key="job_name",        value=PlayerPropertyProxy:GetRoleJobName() or ""})
    table.insert(payData,{key="role_level",      value=PlayerPropertyProxy:GetRoleLevel()})
    table.insert(payData,{key="prod_name",       value=productData.productName or ""})

    local pc_version = nil
    local roomid = nil
    local isBoxLogin    =  global.L_GameEnvManager:GetEnvDataByKey("isBoxLogin") and global.L_GameEnvManager:GetEnvDataByKey("isBoxLogin") == 1
    if isBoxLogin and global.isWindows then
        local pc_version = 3 
        local roomid = global.L_GameEnvManager:GetEnvDataByKey("roomid") or 0   --进入游戏的直播房号
        table.insert( payData, {key="sdk_version",     value=pc_version})
        table.insert( payData, {key="live_no",         value=roomid} )
    end

    -- 支付
    ShowLoadingBar(3)
    if self.PAY_TYPE.QRCODE == payType then
        -- 二维码
        -- 下单成功自动下载二维码
        local function orderCB(isOk, qrcodeURL)
            HideLoadingBar()

            if isOk then
                self:DownloadQRCode(qrcodeURL, qrcodeCB)
            else
                qrcodeCB(false)
            end
        end

        if isBoxLogin then
            local function getSceneCB(isOk)
                self:RequestQRCodePay(payChannel, payData, orderCB)
            end

            local function httpCB(success, response)
                if not success then
                    getSceneCB()
                    return false
                end
                print(response)
                local jsonData = cjson.decode(response)
                if not jsonData then
                    getSceneCB()
                    return false
                end
                if not (jsonData.code == 200) then
                    releasePrint("PCBOX GETSCENEINFO ERROR [-3] ".. jsonData.code .. jsonData.msg)
                    getSceneCB()
                    return false
                end
                if jsonData.data then
                    table.insert( payData, {key="scene",        value=jsonData.data.scene})

                    for _, v in pairs(payData) do
                        if v.key and v.key == "live_no" then
                            local live_no = v.value 
                            v.value = jsonData.data.live_no or live_no
                            break
                        end
                    end
                end
        
                dump(jsonData)
                self:RequestQRCodePay(payChannel, payData, orderCB)
            end
        
            local originData    = {
                {key="game_id",         value=gameid}, 
                {key="user_id",         value=self:GetUID()}
            }
            local suffix        = calcBoxSignSuffix(originData, boxSceneSignKey)
            local header        = getHeader()
            header["token"]     = self:GetToken()
            HTTPRequestPost(domain_boxN .. url_getSceneInfo, httpCB, suffix, header)
            releasePrint("RequestGetSceneInfo url: " .. domain_boxN .. url_getSceneInfo .. "  postData: " .. suffix)

        else
            self:RequestQRCodePay(payChannel, payData, orderCB)
        end

    elseif self.PAY_TYPE.NATIVE == payType then
        local function orderCB(isOk)
            HideLoadingBar()
        end

        -- 原生 支付
        if self.PAY_CHANNEL.ALIPAY == payChannel or self.PAY_CHANNEL.HUABEI == payChannel then
            -- 支付宝
            self:RequestAlipay(payData, orderCB)
    
        elseif self.PAY_CHANNEL.WEIXIN == payChannel then
            -- 微信
            self:RequestWXpay(payData, orderCB)
        end
    end

    -- 友盟 发起充值上报
    if global.L_NativeBridgeManager.GN_umengSubmitPay then
        local uploadData = {
            userId = tostring( self:GetUID() ),
            orderId = tostring( trade_no ),
            productId = tostring( productData.currencyID ),
            productName = tostring( productData.productName ),
            productPrice = tostring( productData.productPrice ),
        }
        global.L_NativeBridgeManager:GN_umengSubmitPay(uploadData)
    end
end

function AuthProxy:DownloadQRCode(url, qrcodeCB)
    local directoryPath = global.FileUtilCtl:getWritablePath() .. global.L_ModuleManager:GetCurrentModulePath()
    local filename      = "qrcode.png"
    local filePath      = directoryPath .. filename
    local qrcodeURL     = url

    -- remove texture cache
    local textureCache  = global.Director:getTextureCache()
    if textureCache:getTextureForKey(filePath) then
        textureCache:removeTextureForKey(filePath)
    end

    -- check directory & create directory
    if not global.FileUtilCtl:isDirectoryExist(directoryPath) then
        global.FileUtilCtl:createDirectory(directoryPath)
    end

    -- check file & remove file
    if global.FileUtilCtl:isFileExist(filePath) then
        global.FileUtilCtl:removeFile(filePath)
        global.FileUtilCtl:purgeCachedEntries()
    end

    -- download qrcode
    global.HttpDownloader:AsyncDownloadEasy(
        qrcodeURL,
        filePath,
        function(isOK)
            print("download qrcode isOK", isOK)
            HideLoadingBar()
            if false == isOK  then
                ShowSystemTips(GET_STRING(30103202))
            end

            if qrcodeCB then
                qrcodeCB(isOK, filename)
            end
        end,
        0
    )
    ShowLoadingBar(3)

    -- for debug
    releasePrint("---------------------------------------------- download qrcode")
    releasePrint("url: " .. qrcodeURL)
end

----------------------------------------------------------------
--- 聚合
---

local function calcJuheSuffix(originData, secret_key, unlencode, pc_sign)
    -- ascii排序
    table.sort(originData, function(a, b)
        return a.key < b.key
    end)

    -- 拼接
    local origin = ""
    for i, v in ipairs(originData) do
        if v and v.key and v.value and string.len(v.key) > 0 and string.len(v.value) > 0 then
            if unlencode then
                origin = origin .. string.format("%s=%s", v.key, urlencodeT(v.value)) 
            else
                origin = origin .. string.format("%s=%s", v.key, v.value)
            end
            origin = origin ..  "&"
        end
    end

    origin = string.sub(origin, 1, string.len(origin)-1)
    
    print("calcSuffix", origin .. secret_key)
    -- 
    local signMD5 = get_str_MD5(origin .. secret_key)
    local suffix  = origin .. "&" .. string.format("sign=%s", signMD5)
    if pc_sign then
        suffix  = origin .. "&" .. string.format("pc_sign=%s", signMD5)
    end
    return suffix
end

local function encodeBase64(source_str)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local s64 = ''
    local str = source_str

    while #str > 0 do
        local bytes_num = 0
        local buf = 0

        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end

        for group_cnt=1,(bytes_num+1) do
            local b64char = math.fmod(math.floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end

        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. '='
        end
    end

    return s64
end

function AuthProxy:DownloadJuheQRCode(url, qrcodeCB)
    local directoryPath = global.FileUtilCtl:getWritablePath() .. global.L_ModuleManager:GetCurrentModulePath()
    local filename      = "qrcode.png"
    local filePath      = directoryPath .. filename
    local qrcodeURL     = url

    -- remove texture cache
    local textureCache = global.Director:getTextureCache()
    if textureCache:getTextureForKey(filePath) then
        textureCache:removeTextureForKey(filePath)
    end
 
    -- check directory & create directory
    if not global.FileUtilCtl:isDirectoryExist(directoryPath) then
        global.FileUtilCtl:createDirectory(directoryPath)
    end

    -- check file & remove file
    if global.FileUtilCtl:isFileExist(filePath) then
        global.FileUtilCtl:removeFile(filePath)
        global.FileUtilCtl:purgeCachedEntries()
    end

    -- check file & remove file
    if global.FileUtilCtl:isFileExist(filePath .. ".tmp") then
        global.FileUtilCtl:removeFile(filePath .. ".tmp")
        global.FileUtilCtl:purgeCachedEntries()
    end

    -- download qrcode
    self.downloader:AsyncDownloadEasy(
        qrcodeURL,
        filePath,
        function(isOK)
            print("download qrcode isOK", isOK)
            HideLoadingBar()
            if false == isOK  then
                ShowSystemTips("拉取支付二维码异常 [QRCODE 01]")
            end

            if qrcodeCB then
                qrcodeCB(isOK, filename)
            end
        end,
        0
    )
    ShowLoadingBar(3)

    -- for debug
    releasePrint("---------------------------------------------- download qrcode")
    releasePrint("url: " .. qrcodeURL)
end

function AuthProxy:HTTPRequestPost(url, callback, data, header)
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

            releasePrint("Http Request Code:" .. tostring(code))
            callback(success, response, code)
        end
        httpRequest:registerScriptHandler(HttpResponseCB)
    end

    httpRequest:send(data)
end

function AuthProxy:RequestJuhePay(payType, payChannel, productData, qrcodeCB)
    local timeMS        = socket.gettime() * 10000
    local trade_no      = sformat("HEROES_DREAM_%s_%09d", timeMS, Random(1, 999999999))
    self._orderId       = trade_no
    local currencyID    = tostring( productData.currencyID )
    local productName   = tostring( productData.productName )
    local productPrice  = tostring( productData.productPrice )
    local currencyValue = tostring( productData.currencyValue )

    local PlayerProperty    = global.Facade:retrieveProxy( global.ProxyTable.PlayerProperty )
    local LoginProxy        = global.Facade:retrieveProxy( global.ProxyTable.Login )
    local envProxy          = global.Facade:retrieveProxy( global.ProxyTable.GameEnvironment )
    local user_name         = global.L_GameEnvManager:GetEnvDataByKey("user_name")
    local extUid            = global.L_GameEnvManager:GetEnvDataByKey("ext_uid")    --未md5加密uid  --有小号登录时ext_uid始终传大号id
    local small_user_name   = global.L_GameEnvManager:GetEnvDataByKey("small_user_name")    --小号name （羽瞬
    local promote_id        = global.L_GameEnvManager:GetEnvDataByKey("promote_id")
    local tgt               = global.L_GameEnvManager:GetEnvDataByKey("tgt")    -- 联想SDK 用户登录返回的 TGT (用户唯一标识)

    local IsSteam      = global.L_GameEnvManager:GetEnvDataByKey("IsSteam")
    if IsSteam then
        self._orderId       = ""
        trade_no            = nil
    end

    -- 下单回调
    -- 下单成功自动下载二维码
    local function orderCB(isOk, qrcodeURL)
        HideLoadingBar()

        if isOk then
            self:DownloadJuheQRCode(qrcodeURL, qrcodeCB)
        else
            qrcodeCB(false)
        end
    end

    -- http数据请求回调
    local function httpCB(success, response)
        releasePrint(response)

        -- request failed
        if not success then
            ShowSystemTips("[-1] 网络异常，请检查网络后重试")
            
            if orderCB then
                orderCB(false)
            end
            return false
        end

        -- json decode error
        local jsonData = cjson.decode(response)
        dump(jsonData)

        if not jsonData then
            ShowSystemTips("[-2] 拉取支付数据异常")

            if orderCB then
                orderCB(false)
            end
            return false
        end

        -- code error
        if jsonData.status ~= 0 then
            ShowSystemTips(jsonData.status .. " " .. jsonData.msg)

            if orderCB then
                orderCB(false)
            end
            return false
        end

        -- 订单号
        local isPcSdk = global.L_GameEnvManager:GetEnvDataByKey("isPcSdk")
        if jsonData.data and jsonData.data.order_number and isPcSdk then
            productData.PcSdk_orderid = jsonData.data.order_number
            local jsonString = (productData and cjson.encode(productData))
            local methodName = "GN_onCallOF"
            global.NativeBridgeCtl:sendMessage2Native(methodName, jsonString)
            return
        end 
        
        -- 团团SDK
        local base_url = global.L_GameEnvManager:GetEnvDataByKey("baseUrl")
        if jsonData.data and jsonData.data.order_sn and base_url then
            local url = base_url .. "/pay"
            local function httpCB_(success, response)
                releasePrint(response)
        
                -- request failed
                if not success then
                    return false
                end
            end
            local data = {
                {key = "vorderid",      value = jsonData.data.order_sn},
                {key = "zone_id",       value = LoginProxy:GetSelectedServerId()},
                {key = "zone_name",     value = LoginProxy:GetSelectedServerName()},
                {key = "role_id",       value = LoginProxy:GetSelectedRoleID()},
                {key = "role_name",     value = LoginProxy:GetSelectedRoleName()},
                {key = "role_level",    value = PlayerProperty:GetRoleLevel()},
                {key = "fee",           value = tonumber(productPrice)},
                {key = "subject",       value = productName},
                {key = "body",          value = productName},
                
            }
            local paramData = {}
            for i, v in ipairs(data) do
                paramData[v.key] = v.value
            end
            local suffix = cjson.encode(paramData)
            local header = {}
            header["Content-Type"] = "application/json"
            self:HTTPRequestPost(url, httpCB_, suffix, header)
            releasePrint("POST TT_Url============".. url .. "  suffix: ".. suffix) 
            return
        end

        -- 直接打开支付界面 
        if jsonData.data and jsonData.data.pay_url then
            releasePrint("Pay_Url============", jsonData.data.pay_url )
            cc.Application:getInstance():openURL(jsonData.data.pay_url)
            return 
        end

        -- 二维码
        if not jsonData.data.code_img_url then
            ShowSystemTips("[-3] 拉取支付数据异常")

            if orderCB then
                orderCB(false)
            end
            return false
        end

        local IsSteam      = global.L_GameEnvManager:GetEnvDataByKey("IsSteam")
        if IsSteam then
            self._orderId  = jsonData.data.orderid or ""
            return 
        end
        -- 请求支付二维码
        orderCB(true, jsonData.data.code_img_url)
    end
    local doitems       = 
    {
        [self.PAY_CHANNEL.ALIPAY] = "alipay",
        [self.PAY_CHANNEL.HUABEI] = "alipay",
        [self.PAY_CHANNEL.WEIXIN] = "weixin",
    }


    local ext = {
        ["token"]       = self:GetToken(),                      -- 小号登录时是小号token
        ["game_name"]   = self._juhe_param_game_name,
        ["username"]    = user_name,
        ["product"]     = currencyID,
        ["product_desc"]= productName,
        ["server_name"] = LoginProxy:GetSelectedServerName(),
        ["role_name"]   = LoginProxy:GetSelectedRoleName(),
        ["role_level"]  = PlayerProperty:GetRoleLevel(),
        ["order"]       = trade_no,
        -- ["attach"]      = 1,
        ["agent_id"]    = self._juhe_param_agent_id,             --渠道id
        ["coin_id"]     = currencyID,                            --货币id
        ["coins"]       = currencyValue,                         --货币值
        ["small_id"]    = self._juhe_small_id,
        ["small_user_name"] = small_user_name,
        ["promote_id"]  = promote_id,
    }

    local extStr = cjson.encode(ext)
    -- dump(extStr)

    local originData = {
        {key="platform",        value=envProxy:GetChannelID()}, 
        {key="cpgameid",        value=global.L_ModuleManager:GetCurrentModule():GetOperID()},  
        {key="subject",         value=self._juhe_param_subject or "dhsf" },
        {key="game_id",         value=self._juhe_param_game_id},

        {key="do",              value=doitems[payChannel]},
        {key="userid",          value= extUid or self:GetUID()},                --Steam平台 user_id直接传的steamID
        {key="server_id",       value=LoginProxy:GetSelectedServerId()},
        {key="paymoney",        value=productPrice},
        {key="role_id",         value=LoginProxy:GetSelectedRoleID()},
        {key="tgt",             value=tgt},
        {key = "ext",           value= encodeBase64(extStr)},
        {key="original_user_id",value= self._juhe_origin_id},
    }   
     --[[ 龙城决
        platform：638
        cpgameid：206
        game_id:26
    ]] 

    --[[ 梓轩
        platform：607
        cpgameid：212
    ]]

    --[[ 9377
        platform：561
        cpgameid：194
        game_id : 5431
        subject：dhsf]]

    --[[千贝
        platform：634
        cpgameid：217
    ]]

    --[[顺玩
        platform：1186
        cpgameid：352
    ]]
    
    --测试数据
    -- local ext = {
    --     ["token"]       = "a4e0b47abdeb5768cacfaf5b58fe624b",--global.L_GameEnvManager:GetEnvDataByKey("token"),
    --     ["game_name"]   = "顺玩神器",--self._juhe_param_game_name and urlencodeT(self._juhe_param_game_name),
    --     ["username"]    = "shtest001",--loginData.username and urlencodeT(loginData.username),
    --     ["product"]     = urlencodeT("灵符"),--currencyID,
    --     ["product_desc"]=  urlencodeT("灵符"),
    --     ["server_name"] = urlencodeT("区服1"), --LoginProxy:GetSelectedServerName()
    --     ["role_name"]   = urlencodeT("角色名称1"), --LoginProxy:GetSelectedRoleName()
    --     ["role_level"]  = PlayerProperty:GetRoleLevel(),
    --     ["order"]       = "11111",--trade_no,
    --     -- ["attach"]      = "1",
    --     ["agent_id"]    = 111,             --渠道id
    --     ["coin_id"]     = currencyID,                            --货币id
    --     ["coins"]       = currencyValue,                         --货币值
    --     ["small_id"]    = "8131",
    -- }

    -- local extStr = cjson.encode(ext)
    -- dump(extStr)

    -- local originData = {        --测试数据 
    --     {key="platform",        value=1928},  --!
    --     {key="cpgameid",        value=435},  --!
    --     {key="subject",         value="dhsf"}, --!
    --     -- {key="uname",           value=urlencodeT("n12345689")}, --!
    --     {key="game_id",         value=1},
    --     -- {key="password",        value=123456},

    --     {key="do",              value= doitems[payChannel]},
    --     {key="userid",          value= "juhe_e73387855bebd50"}, --!
    --     {key="server_id",       value= 1001}, --!
    --     {key="paymoney",        value="1"},
    --     {key="role_id",         value="1"},   --!
    --     {key = "ext",           value= encodeBase64(extStr)}
    -- }

    -- dump(originData)
    local isQQChannel = global.L_GameEnvManager:GetEnvDataByKey("IsQQ")
    if isQQChannel then
        table.insert(originData, {key="openid",         value= global.L_GameEnvManager:GetEnvDataByKey("user_id") }) --
        table.insert(originData, {key="openkey",        value= global.L_GameEnvManager:GetEnvDataByKey("token")})  --
        table.insert(originData, {key="pfkey",          value= global.L_GameEnvManager:GetEnvDataByKey("pfkey")})  --
        table.insert(originData, {key="appid",          value= global.L_GameEnvManager:GetEnvDataByKey("appid")}) --
        table.insert(originData, {key="server_url",     value= LoginProxy:GetSelectedServerUrlSuffix()})
        table.insert(originData, {key="role_name",      value= LoginProxy:GetSelectedRoleName()})
        table.insert(originData, {key="product",        value=currencyID})
        table.insert(originData, {key="product_desc",   value=productName})
     
        -- appid : 1111951543

        local url = domain_qqGame .. juhe_url_qqPay 
        local suffix = calcJuheSuffix(originData, juhe_secret_key)
        -- print("pay suffix = ", suffix)

        local function qqPayCallback(success, response)
            -- request failed
            print("qqPayCallback = ", success)
            print("response = ", response)
            if not success then
                ShowSystemTips("网络异常，请检查网络后重试")
                
                if orderCB then
                    orderCB(false)
                end
                return false
            end

            -- json decode error
            local jsonData = cjson.decode(response)
            dump(jsonData)
            if not jsonData then
                ShowSystemTips("拉取支付数据异常")

                if orderCB then
                    orderCB(false)
                end
                return false
            end

            if jsonData.ret ~= 0 then
                ShowSystemTips(jsonData.msg or "")

                if orderCB then
                    orderCB(false)
                end
                return false
            end

            HideLoadingBar()

            local data = {}
            if jsonData.sandbox then
                data.sandbox = jsonData.sandbox
            end
            
            if jsonData.url_params then
                data.goodstokenurl = jsonData.url_params
            end
            data.action = "buy"
            data.appid =  global.L_GameEnvManager:GetEnvDataByKey("appid") 
            data.openid = global.L_GameEnvManager:GetEnvDataByKey("user_id")
            data.openkey = global.L_GameEnvManager:GetEnvDataByKey("token")

            print(cjson.encode(data))

            -- if self:IsQQLauncher() then
            --     if QQBridge then
            --         local param = urlencodeT(cjson.encode(data))
            --         QQBridge:Inst():RequestRecharge(param)
            --     end

            -- else
                local url = "qqgameprotocol:///openembedwebdialog Caption=支付 Width=800 Height=500 New=1 Url=https://qqgame.qq.com/midaspay/?param="
                local param = urlencodeT(cjson.encode(data))
                releasePrint("buyUrl============", url .. param)
                cc.Application:getInstance():openURL(url .. param)
            -- end
            
        end
        HTTPRequestPost(url, qqPayCallback, suffix)

         -- for debug
        releasePrint("url: " .. url .. "  post: " .. suffix)

    else
        local url = juhe_domain..juhe_url_pay
        local suffix = calcJuheSuffix(originData, juhe_secret_key)
        HTTPRequestPost(url, httpCB, suffix)

        -- for debug
        releasePrint("url: " .. url .. "  post: " .. suffix)

    end
    ShowLoadingBar(3)

end

function AuthProxy:uploadData(data_type, data)
    -- 数据上报
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local loginProxy  = global.Facade:retrieveProxy( global.ProxyTable.Login )
    local selectRole  = loginProxy:GetSelectedRole()

    local extUid                = global.L_GameEnvManager:GetEnvDataByKey("ext_uid")
    local additional_parameters = data.additional_parameters
    local event_type            = data.event_type               -- 1.选服 2.创角 3.进游戏 4.升级
    local user_id               = extUid or AuthProxy:GetUID()
    local server_id             = data.server_id
    local server_name           = data.server_name
    local role_id               = data.role_id
    local role_name             = data.role_name
    local role_level            = data.role_level
    local role_create_time      = data.role_create_time
    local fight                 = data.fight 
    local role_career           = data.role_career
    local role_sex              = data.role_sex
    local vip_level             = data.vip_level
    local money_num             = data.money_num
    local rein_level            = data.rein_level

    local PCNeedUpLoad = tonumber(global.ConstantConfig and global.ConstantConfig.PCNeedUpLoadLevel) == 1
    -- 选服不上报
    if data_type == 1 or (not PCNeedUpLoad and data_type == 4) then
        return nil
    end

    -- 团团SDK
    local base_url = global.L_GameEnvManager:GetEnvDataByKey("baseUrl")
    if base_url and string.len(base_url) > 0 then
        local CloseGameID = global.L_GameEnvManager:GetEnvDataByKey("CloseGameID")
        -- 关闭通知
        if data_type == 5 and CloseGameID then
            local url = base_url .. "/close"
            local function httpCB_close(success, response)
                releasePrint(response)
        
                -- request failed
                if not success then
                    return false
                end
            end
            local suffix = cjson.encode({})
            local header = {}
            header["Content-Type"] = "application/json"
            self:HTTPRequestPost(url, httpCB_close, suffix, header)
            releasePrint("POST TT_Url==Close==========".. url .. "  suffix: ".. suffix) 

            if data and data.gameInitFinish then
                global.userInputController:RequestToOutGame()
            else
                local glview = global.Director:getOpenGLView()
                glview:endToLua()
            end
            return
        end

        local url = base_url .. "/roleReport"
        local function httpCB_(success, response)
            releasePrint(response)
    
            -- request failed
            if not success then
                return false
            end
        end
        local data = {
            {key = "zone_id",       value = server_id},
            {key = "zone_name",     value = server_name},
            {key = "role_id",       value = role_id},
            {key = "role_name",     value = role_name},
            {key = "role_level",    value = role_level},
            {key = "shift_level",   value = tonumber(rein_level)},
        }
        local paramData = {}
        for i, v in ipairs(data) do
            paramData[v.key] = v.value
        end
        local suffix = cjson.encode(paramData)
        local header = {}
        header["Content-Type"] = "application/json"
        self:HTTPRequestPost(url, httpCB_, suffix, header)
        releasePrint("POST TT_Url==Upload==========".. url .. "  suffix: ".. suffix) 
        return
    end

    -- http数据请求回调
    local function httpCB(success, response)
        releasePrint(response)

        -- request failed
        if not success then
            return false
        end

        -- json decode error
        local jsonData = cjson.decode(response)
        dump(jsonData)

        if jsonData and jsonData.data and jsonData.data.open_url then
            cc.Application:getInstance():openURL(jsonData.data.open_url)
            releasePrint("UPLOAD_DATA  open_url: " .. jsonData.data.open_url)
            local CloseGameID = global.L_GameEnvManager:GetEnvDataByKey("CloseGameID")
            if CloseGameID and data_type == 5 then -- 关闭
                if data and data.gameInitFinish then
                    global.userInputController:RequestToOutGame()
                else
                    local glview = global.Director:getOpenGLView()
                    glview:endToLua()
                end
            end
        end

    end
    local PlayerProperty    = global.Facade:retrieveProxy( global.ProxyTable.PlayerProperty )
    local LoginProxy        = global.Facade:retrieveProxy( global.ProxyTable.Login )
    local envProxy          = global.Facade:retrieveProxy( global.ProxyTable.GameEnvironment )
    local user_name         = global.L_GameEnvManager:GetEnvDataByKey("user_name")
    local promote_id        = global.L_GameEnvManager:GetEnvDataByKey("promote_id")         -- 推广员ID
    local ext_token         = global.L_GameEnvManager:GetEnvDataByKey("ext_token")          -- 首次登录token 不是小号登录token
    local small_user_name   = global.L_GameEnvManager:GetEnvDataByKey("small_user_name")    --小号name （羽瞬

    local originData = 
    {
        {key="platform",        value=envProxy:GetChannelID()}, 
        {key="cpgameid",        value=global.L_ModuleManager:GetCurrentModule():GetOperID()},
        {key="subject",         value=self._juhe_param_subject},
        {key="game_id",         value=self._juhe_param_game_id},
        {key="timestamp",       value=os.time()},

        {key="data_type",       value=data_type},
        {key="additional_parameters", value=additional_parameters},
        {key="event_type",      value=event_type},
        {key="user_id",         value=user_id},
        {key="user_name",       value=user_name},
        {key="server_id",       value=server_id},
        {key="server_name",     value=server_name},
        {key="role_id",         value=role_id},
        {key="role_name",       value=role_name},
        {key="role_level",      value=role_level},
        {key="role_create_time",value=role_create_time},
        {key="fight",           value=fight},
        {key="role_career",     value=role_career},
        {key="role_sex",        value=role_sex},
        {key="vip_level",       value=vip_level},
        {key="money_num",       value=money_num},
        {key="log_time",        value=os.time()},
        {key="type",            value=data_type-1},
        {key="small_id",        value=self._juhe_small_id},
        {key="promote_id",      value=promote_id},
        {key="token",           value=ext_token},
        {key="small_user_name", value=small_user_name},
        {key="agent_id",        value=self._juhe_param_agent_id},
        {key="original_user_id", value= self._juhe_origin_id},
    }
    local url = juhe_domain..juhe_url_upload
    -- dump(originData)
    -- local originData = 
    -- {
    --     {key="platform",        value=1186},  --!
    --     {key="cpgameid",        value=352},  
    --     {key="subject",         value="dhsf"},
    --     {key="game_id",         value=13},
    --     {key="timestamp",       value=os.time()},

    --     {key="data_type",       value=data_type},
    --     {key="additional_parameters", value=additional_parameters},
    --     {key="event_type",      value=event_type},
    --     {key="user_id",         value=8130},
    --     {key="user_name",       value="shtest207"},
    --     {key="server_id",       value=server_id},
    --     {key="server_name",     value=urlencodeT(server_name)},
    --     {key="role_id",         value=role_id},
    --     {key="role_name",       value=urlencodeT(role_name)},
    --     {key="role_level",      value=role_level},
    --     {key="role_create_time",value=role_create_time},
    --     {key="fight",           value=fight},
    --     {key="role_career",     value=urlencodeT(role_career)},
    --     {key="role_sex",        value=role_sex},
    --     {key="vip_level",       value=vip_level},
    --     {key="money_num",       value=money_num},
    --     {key="log_time",        value=os.time()},
    --     {key="type",            value=data_type-1},
    --     {key="small_id",        value=8131},--self._juhe_small_id},
    -- }
    local suffix = calcJuheSuffix(originData, juhe_secret_key ,true)
    HTTPRequestPost(url, httpCB, suffix)

    -- for debug
    releasePrint("---------------------------------------------- upload")
    releasePrint("url: " .. url .. "  post: " .. suffix)
end

-- QQ大厅数据上报
function AuthProxy:uploadDataQQGame(data_type,data)

    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local loginProxy  = global.Facade:retrieveProxy( global.ProxyTable.Login )
    local selectRole  = loginProxy:GetSelectedRole()

    local data_type             = data_type            -- 1.选服 2.创角 3.进游戏 4.升级 5.QQ登录时机 6.QQ注册时机（伪）
    local user_id               = data.user_id or AuthProxy:GetUID()
    local server_id             = data.server_id
    -- local server_name           = data.server_name
    local role_id               = data.role_id
    local role_name             = data.role_name
    local role_level            = data.role_level
    -- local role_create_time      = data.role_create_time
    local role_career           = data.role_career
    local role_sex              = data.role_sex

    -- 选服不上报
    if data_type == 1 or data_type == 4 then
        return nil
    end

    -- http数据请求回调
    local function httpCB(success, response)
        releasePrint(response)
        -- request failed
        if not success then
            print("[-1] 网络异常，请求上报QQ数据失败.")
            return false
        end

        -- json decode error
        local jsonData = cjson.decode(response)
        dump(jsonData)
    end
    local PlayerProperty    = global.Facade:retrieveProxy( global.ProxyTable.PlayerProperty )
    local LoginProxy        = global.Facade:retrieveProxy( global.ProxyTable.Login )
    local envProxy          = global.Facade:retrieveProxy( global.ProxyTable.GameEnvironment )
    local user_name         = global.L_GameEnvManager:GetEnvDataByKey("user_name")
    local originData = 
    {
        {key="platform",        value=envProxy:GetChannelID()}, 
        {key="cpgameid",        value=global.L_ModuleManager:GetCurrentModule():GetOperID()},
        {key="subject",         value=self._juhe_param_subject},
        {key="game_id",         value=self._juhe_param_game_id},
        {key="timestamp",       value=os.time()},

        {key="data_type",       value=data_type},
        {key="user_id",         value=user_id},
        -- {key="user_name",       value=user_name},
        {key="server_id",       value=server_id},
        -- {key="server_name",     value=server_name},
        {key="role_id",         value=role_id},
        -- {key="role_name",       value=role_name},
        {key="role_level",      value=role_level},
        -- {key="role_create_time",value=role_create_time},
        {key="role_career",     value=role_career},
        {key="role_sex",        value=role_sex},
        {key="log_time",        value=os.time()},
    }
    
    local url = domain_qqGame .. juhe_url_qqUpload
    local suffix = calcJuheSuffix(originData, "webgame@2019J5v6ByRT" ,true)  --无签名验证
    HTTPRequestPost(url, httpCB, suffix)

    -- for debug
    releasePrint("---------------------------------------------- QQ upload")
    releasePrint("url: " .. url .. "  post: " .. suffix)
end

function AuthProxy:uploadBoxData(data_type, data)
    if not data_type or data_type ~= 2 then -- 创角
        return 
    end
    local isBoxAD       = global.L_GameEnvManager:GetEnvDataByKey("isBoxAD")
    local roomid        = global.L_GameEnvManager:GetEnvDataByKey("roomid") 
    local url           = nil
    if isBoxAD and tonumber(isBoxAD) == 1 then  -- 广告
        url = domain_box .. url_roleAD
    elseif roomid and tonumber(roomid) == 3 then    -- 新游推荐
        url = domain_boxN .. url_roleNewRecom
    else
        return 
    end

    if not url then return end

    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local loginProxy  = global.Facade:retrieveProxy( global.ProxyTable.Login )
    local selectRole  = loginProxy:GetSelectedRole()
    local user_id     = AuthProxy:GetUID()
    local server_id   = data.server_id
    local role_id     = data.role_id
    local role_name   = data.role_name

    local function httpCB(success, response)
        releasePrint(response)
        -- request failed
        if not success then
            print("[-1] 网络异常，请求上报盒子创角数据失败.")
            return false
        end

        -- json decode error
        local jsonData = cjson.decode(response)
        dump(jsonData)
    end
    local PlayerProperty    = global.Facade:retrieveProxy( global.ProxyTable.PlayerProperty )
    local envProxy          = global.Facade:retrieveProxy( global.ProxyTable.GameEnvironment )
    local listId            = global.L_GameEnvManager:GetEnvDataByKey("open_game_list_id") or 0 -- 盒子 开服列表ID

    local originData = 
    {
        {key="user_id",             value=user_id},
        {key="game_id",             value=global.L_ModuleManager:GetCurrentModule():GetOperID()},
        {key="open_game_list_id",   value=listId},
        {key="server_id",           value=server_id},
        {key="roleid",              value=role_id},
        {key="rolename",            value=role_name},
    }
    
    local suffix = calcJuheSuffix(originData, signBoxKey , nil, true)  
    HTTPRequestPost(url, httpCB, suffix)

    -- for debug
    releasePrint("---------------------------------------------- Box upload")
    releasePrint("url: " .. url .. "  post: " .. suffix)
end

function AuthProxy:IsQQChannel()
    local isQQChannel = global.L_GameEnvManager:GetEnvDataByKey("IsQQ")
    return isQQChannel
end

function AuthProxy:RequestWordFilteringQQ(contentType, content, callbackCB, ex_param)
    local isback = false

    local function scheduleCB()
        if not isback then 
            isback = true
            if callbackCB then
                callbackCB(true, content)
            end
        end
    end

    -- 团团SDK特殊自己审核
    local base_url = global.L_GameEnvManager:GetEnvDataByKey("baseUrl")
    local isTTReview = tonumber(global.L_GameEnvManager:GetEnvDataByKey("isTTReview")) == 1
    if base_url and string.len(base_url) > 0 and isTTReview then
        local url = base_url .. "/message"
        local function httpCB(success, response)
            if isback then return end
            releasePrint(response)
            isback = true
    
            -- request failed
            if not success then  --默认合法
                if callbackCB then
                    callbackCB(true, content)
                end
                return false
            end

            local jsonData = cjson.decode(response)
            dump(jsonData)

            if not jsonData or type(jsonData) ~= "table" then
                if callbackCB then
                    callbackCB(true, content)
                end
                return false
            end

            if jsonData.data then
                local data = jsonData.data
                local result = data.result
                local text = data.text
                if result and text then -- 安锋
                    -- result 1合法 2部分合法 3完全不合法
                    if tonumber(result) ~= 1 and (tonumber(contentType) == 1 or tonumber(contentType) == 3) then -- 昵称/公告拒绝
                        if callbackCB then
                            callbackCB(false, false)
                        end
                        return true
                    else
                        if callbackCB then
                            callbackCB(true, text, result - 1)
                        end
                        return true
                    end
    
                end
            end
            
            --无结果默认通过
            if callbackCB then
                callbackCB(true, content)
            end

        end
        local suffix = cjson.encode({
            text = content,
            scene = contentType, --
        })
        local header = {}
        header["Content-Type"] = "application/json"
        self:HTTPRequestPost(url, httpCB, suffix, header)
        releasePrint("POST TT_Url==Review==========".. url .. "  suffix: ".. suffix)
        return
    end

    -- http数据请求回调
    local function httpCB(success, response)
        if isback then return end
        releasePrint(response)
        isback = true
        
        if not success then  --默认合法
            if callbackCB then
                callbackCB(true, content)
            end
            return false
        end

        -- json decode error
        local jsonData = cjson.decode(response)
        dump(jsonData)

        if not jsonData or type(jsonData) ~= "table" then
            if callbackCB then
                callbackCB(true, content)
            end
            return false
        end

        -- code error
        if jsonData.status ~= 0 then
            releasePrint("--word_Filter_error:  "..jsonData.status .. " " .. jsonData.msg)

            if callbackCB then
                callbackCB(true, content)
            end
            return false
        end

        if jsonData.data then
            local qqData = jsonData.data
            if qqData.text_result_list_ then
                local result = qqData.text_result_list_[1]
                if result.check_ret_ == 0 then  --合法
                    if callbackCB then
                        callbackCB(true, content)
                    end
                    return true
                elseif result.check_ret_ == 1 then  --恶意
                    if result.punish_type_ == 1 then  --禁止
                        if callbackCB then
                            callbackCB(false, false)
                        end
                        return true
                    elseif result.punish_type_ == 2 then --可过滤
                        if callbackCB then
                            callbackCB(false, result.result_text_) 
                        end
                        return true
                    end
                end
            elseif jsonData.data.suggestion then   -- AI
                if jsonData.data.suggestion == "pass" then
                    if callbackCB then
                        callbackCB(true, content)
                    end
                    return true
                elseif jsonData.data.suggestion == "review" or jsonData.data.suggestion == "block" then
                    if callbackCB then
                        callbackCB(false, false)
                    end
                    return true
                end
            elseif jsonData.data.level then -- 小7/易盾 检查结果
                if tonumber(jsonData.data.level) == 1 then
                    if callbackCB then
                        callbackCB(true, content)
                    end
                    return true
                elseif tonumber(jsonData.data.level) == -1 then
                    if callbackCB then
                        callbackCB(false, false)
                    end
                    return true
                end
            elseif jsonData.data.yd996_status and jsonData.data.str then -- 网易/易盾 
                -- yd996_status 0通过 1疑问 2拒绝
                if tonumber(jsonData.data.yd996_status) ~= 0 and ( tonumber(contentType) == 1 or tonumber(contentType) == 3 ) then -- 昵称/公告拒绝
                    if callbackCB then
                        callbackCB(false, false)
                    end
                    return true
                else
                    if callbackCB then
                        callbackCB(true, jsonData.data.str, tonumber(jsonData.data.yd996_status))
                    end
                    return true
                end

            end
        end
        
        --无结果默认通过
        if callbackCB then
            callbackCB(true, content)
        end
    end

    local envProxy          = global.Facade:retrieveProxy( global.ProxyTable.GameEnvironment )
    local isQQChannel = global.L_GameEnvManager:GetEnvDataByKey("IsQQ")

    local loginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local role_id    = loginProxy:GetSelectedRoleID() 
    local role_name  = loginProxy:GetSelectedRoleName()
    local server_id  = loginProxy:GetSelectedServerId()
    local AuthProxy = global.Facade:retrieveProxy( global.ProxyTable.AuthProxy )
    local user_id   = AuthProxy:GetUID()
    local serverName = loginProxy:GetSelectedServerName()
    local currentModule     = global.L_ModuleManager:GetCurrentModule()
    local gameName = currentModule:GetName()
    local area = nil
    if gameName and serverName then
        area = string.format( "%s_%s", gameName, serverName )
    end

    local CONTENT_TYPE = {  --支持“chat”(聊天消息)，“nick”(昵称),"post"(帖 子)，"notice"(公告), "signature"(签名)5种
        "nick","chat","notice","post","signature"
    }

    local ServerTimeProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerTimeProxy)
    local openDay = 0
    if ServerTimeProxy and ServerTimeProxy.GetOpenDay then
        openDay = ServerTimeProxy:GetOpenDay()
    end

    local platform = 0
    if cc.PLATFORM_OS_ANDROID == global.Platform or global.isOHOS then
        platform = 1
    elseif cc.PLATFORM_OS_IPAD == global.Platform or cc.PLATFORM_OS_IPHONE == global.Platform then
        platform = 2
    end

    local player       = global.gamePlayerController and global.gamePlayerController:GetMainPlayer()
    local role_level   = nil
    if player then
        role_level      = player:GetLevel()
    end

    local ext = {
        ["user_id"]     = user_id,      --角色所属小号id （小7的就是uid）
        ["device_type"] = platform,     --设备类型：1=安卓 2=ios
    }
    local extStr = cjson.encode(ext)

    local originData = {
        {key = "str",           value = content},
        {key = "type",          value = contentType},
        {key ="platform",       value = envProxy:GetChannelID()}, 
        {key ="cpgameid",       value = global.L_ModuleManager:GetCurrentModule():GetOperID()},  
        {key ="subject",        value = self._juhe_param_subject or "dhsf"},
        {key ="context_type",   value= CONTENT_TYPE[tonumber(contentType)]},
        {key ="user_id",        value= user_id},
        {key ="username",       value= self._username},
        {key ="role_id",        value= role_id},
        {key ="role_name",      value= role_name},
        {key ="role_level",     value= role_level},
        {key ="server_id",      value= server_id},
        {key ="area",           value= area},
        {key ="open_day",       value= openDay},
        {key ="ext",            value= encodeBase64(extStr)}
    }
    if isQQChannel then
        table.insert(originData, {key="openid",         value= global.L_GameEnvManager:GetEnvDataByKey("user_id") }) --
        table.insert(originData, {key="openkey",        value= global.L_GameEnvManager:GetEnvDataByKey("token")})  --
        table.insert(originData, {key="pfkey",          value= global.L_GameEnvManager:GetEnvDataByKey("pfkey")})  --
        table.insert(originData, {key="appid",          value= global.L_GameEnvManager:GetEnvDataByKey("appid")}) --
    end  

    if ex_param and next(ex_param) then
        for k, val in pairs(ex_param) do
            table.insert(originData, {key = k, value = val})
        end
    end

    local url = domain_qqGame .. juhe_url_qqFilter
    local suffix = calcJuheSuffix(originData, juhe_secret_key)
    HTTPRequestPost(url, httpCB, suffix)

    PerformWithDelayGlobal(scheduleCB, 3)
    -- for debug
    releasePrint("------------------------------------------WordFiltering++")
    releasePrint("url: " .. url .. "  post: " .. suffix)
    
end

function AuthProxy:RequestQQDawankaInfo( ... )
    local isQQChannel = global.L_GameEnvManager:GetEnvDataByKey("IsTTQQ") or global.L_GameEnvManager:GetEnvDataByKey("IsQQ")
    if isQQChannel then
        local requestData = {}
        requestData["openid"]   = global.L_GameEnvManager:GetEnvDataByKey("qqgame_openid") or global.L_GameEnvManager:GetEnvDataByKey("user_id") 
        requestData["openkey"]  = global.L_GameEnvManager:GetEnvDataByKey("qqgame_openkey") or global.L_GameEnvManager:GetEnvDataByKey("token")
        requestData["appkey"]   = global.L_GameEnvManager:GetEnvDataByKey("qqgame_appkey") or global.L_GameEnvManager:GetEnvDataByKey("appkey") or "9GMF2HknSZeJZgzb"
        requestData["appid"]    = global.L_GameEnvManager:GetEnvDataByKey("qqgame_appid") or global.L_GameEnvManager:GetEnvDataByKey("appid")
        local userData          = UserData:new("QQDAWAKA_data")
        local dawakaData        = userData:getStringForKey("data", nil)
        if dawakaData and string.len(dawakaData) > 0 then
            requestData["dawakaData"] = dawakaData
        end
        local sendStr = cjson.encode( requestData )
        LuaSendMsg(global.MsgType.MSG_CS_GET_DAWANKA_INFO, 0, 0, 0, 0, sendStr, string.len(sendStr))
    end
    
end

function AuthProxy:RequestDecodeJWTToServer( ... )
    local xlData = global.L_GameEnvManager:GetEnvDataByKey("xlData")
    local decodeJwt = nil
    if xlData and string.len(xlData) > 0 then
        LuaSendMsg(global.MsgType.MSG_CS_SEND_XULEI_VIP, 0, 0, 0, 0, xlData, string.len(xlData))
    end
    
end

function AuthProxy:calcCloudSignSuffix(originData, secret_key, unlencode)
    table.sort(originData, function(a, b)
        return a.key < b.key
    end)

    -- 拼接
    local origin = ""
    local valueStr = ""
    for i, v in ipairs(originData) do
        if v and v.key and v.value and string.len(v.key) > 0 and string.len(v.value) > 0 then
            if unlencode then
                origin = origin .. string.format("%s=%s", v.key, urlencodeT(v.value)) 
            else
                origin = origin .. string.format("%s=%s", v.key, v.value)
            end
            origin = origin ..  "&"
            valueStr = valueStr .. v.value
        end
    end

    origin = string.sub(origin, 1, string.len(origin)-1)
    local rqtime = os.time()	
    local rqrandom = randDataID("Box")
    valueStr = valueStr .. secret_key .. rqtime .. rqrandom
    origin = origin.."&rqtime="..rqtime.."&rqrandom="..rqrandom
    releasePrint("isCloudLogin : RequestIsCloudLogin "..valueStr)
    local signMD5 = get_str_MD5(valueStr)
    -- local suffix  = origin .. "&" .. string.format("sign=%s", signMD5)
    local oTab = {}
    for k,v in pairs(originData) do
        oTab[v.key] = urlencodeT(v.value)
    end
    oTab.rqtime = rqtime
    oTab.rqrandom = rqrandom
    oTab.sign = signMD5
    return oTab
end

--直播红包+飘屏群 上报需求  
function AuthProxy:RequestUpLoadCreateRole(jsonData)
    local action = "/trilateral/v1/create/role/task"
    -- cloud_box_url = "https://test-api.996box.com"
    local url = cloud_box_url .. action
    local currModule   = global.L_ModuleManager:GetCurrentModule()
    local loginProxy   = global.Facade:retrieveProxy( global.ProxyTable.Login )
    local mainServerId = loginProxy:GetMainSelectedServerId()

    local envProxy     = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    local platformid   = envProxy:GetChannelID()
    local roles = loginProxy:GetRoles() or {}
    local roleNum = math.max(1, #roles)
    local originData = {
        {key="exp",          value = 0},
        {key="gameId",       value = tonumber(currModule:GetOperID())},
        {key="job",          value = tonumber(jsonData.roleJobId)},
        {key="mainServerId", value = tonumber(mainServerId)},
        {key="occurredTime", value = tonumber(jsonData.roleCTime)},
        {key="onlineTime",   value = 0},
        {key="platformId",   value = tostring(platformid)},
        {key="reLevel",      value = 0},
        {key="roleId",       value = jsonData.roleId},
        {key="roleLevel",    value = tonumber(jsonData.roleLevel)},
        {key="roleName",     value = jsonData.roleName},
        {key="serverId",     value = tonumber(jsonData.zoneId)},
        {key="serverName",   value = jsonData.zoneName},
        {key="userId",       value = jsonData.userId},
        {key="roleNum",      value = roleNum},
    }
    -- dump(url,"url___")
    local suffix = self:calcCloudSignSuffix(originData, boxSceneSignKey)
    -- dump(suffix,"suffix___")
    local header = {} 
    header["Content-Type"] = "application/json"
    function MyHTTPRequestPost(url, callback, data, header)
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
    
                release_print("Http Request Code:" .. tostring(code))
                callback(success, response, code)
            end
            httpRequest:registerScriptHandler(HttpResponseCB)
        end
        httpRequest:send(data)
    end

    MyHTTPRequestPost(url, function (success, response)
        dump({success, response},"RequestUpLoadCreateRole_______")
        if success then
        end
    end, cjson.encode(suffix), header)
end

function AuthProxy:RequestIsCloudLogin()
    --云真机启动 上报服务器
    if global.L_GameEnvManager:GetEnvDataByKey("isCloudLogin") then
        local loginProxy  = global.Facade:retrieveProxy( global.ProxyTable.Login )
        local user_id     = self:GetUID()
        local server_id  = loginProxy:GetSelectedServerId()
        local role_id     = loginProxy:GetSelectedRoleID() 
        local userPhoneId = global.L_GameEnvManager:GetEnvDataByKey("userPhoneId") or ""
        local packName = global.L_GameEnvManager:GetAPKPackageName() or ""
        local originData =
        {
            {key="extUserDeviceNo", value=userPhoneId},
            {key="gameRegionId", value=server_id},
            {key="gameRoleId", value=role_id},
            {key="uid", value=user_id},
        }
        local suffixTab = self:calcCloudSignSuffix(originData, boxSceneSignKey)
        local data = {}
        data.url = cloud_box_url .. cloud_record_url
        data.ojson = cjson.encode(suffixTab)
        global.L_NativeBridgeManager:GN_sendCloudLoginMes(data)

        local sendStr = packName.. "#" ..userPhoneId
        releasePrint("PackageName:"..sendStr)
        if packName ~= "" then
            LuaSendMsg(global.MsgType.MSG_CS_YWPACKINFO_REQUEST, 0, 0, 0, 0, sendStr, string.len(sendStr))
        end
    end
end

local function calcTecentSuffix(originData, secret_key, uri)
    -- ascii排序
    table.sort(originData, function(a, b)
        return a.key < b.key
    end)

    -- 拼接
    local origin = ""
    for i, v in ipairs(originData) do
        if v and v.key and v.value and string.len(v.key) > 0 and string.len(v.value) > 0 then
            origin = origin .. string.format("%s=%s", v.key, v.value)
            origin = origin ..  "&"
        end
    end
    origin = string.sub(origin, 1, string.len(origin)-1)

    -- URL编码
    local urlUri = urlencodeT(uri)
    local urlStr = "POST&" .. urlUri .. "&"..urlencodeT(origin)
    -- HMAC-SHA1
    local sign = sha1.hmac_binary(secret_key, urlStr)
    -- Base64
    sign = encodeBase64(sign)

    -- 
    local suffix  = origin .. "&" .. string.format("sig=%s", urlencodeT(sign))
    return suffix
end

-- QQ大厅续期openKey
function AuthProxy:RequestRenewalQQOpenKey(islogin)
    local QQ_renewal_uri = "/v3/user/is_login"

    local isQQChannel = global.L_GameEnvManager:GetEnvDataByKey("IsQQ")
    if isQQChannel then
        local date = os.date("*t", GetServerTime())
        local nextHourMin = 60 -  date.min
        local delayTime = nextHourMin == 0 and 0.1 or nextHourMin*60
        PerformWithDelayGlobal(function ( ... )
            local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
            if AuthProxy then
                self._canRenewal = true
                AuthProxy:RequestRenewalQQOpenKey()
            end
        end, delayTime)
    end
    
    if isQQChannel and (self._canRenewal or islogin) then
        local function httpCB(success, response)
            releasePrint(response)
            
            if success then
                local jsonData = cjson.decode(response)
                if islogin and jsonData and jsonData.ret and jsonData.ret ~= 0 then
                    local errorcode = jsonData.ret
                    local errorMsg = jsonData.msg
                    ShowSystemTips("登录态校验失败! "..errorcode .. "  ".. errorMsg)
                end
                dump(jsonData)
            end
        end

        local originData = {
            {key="openid",         value= global.L_GameEnvManager:GetEnvDataByKey("user_id")},
            {key="openkey",        value= global.L_GameEnvManager:GetEnvDataByKey("token")},
            {key="appid",          value= global.L_GameEnvManager:GetEnvDataByKey("appid")},
            {key="pf",             value= "qqgame"},
            {key="format",         value= "json"}
        }

        local appkey = global.L_GameEnvManager:GetEnvDataByKey("appkey")
        
        local url = host_tencent..QQ_renewal_uri
        local suffix = calcTecentSuffix(originData, appkey.."&", QQ_renewal_uri)
        HTTPRequestPost(url, httpCB, suffix)
        releasePrint("RenewalQQOpenKey url: " .. url .. "  post: " .. suffix)
    end  
end

return AuthProxy
