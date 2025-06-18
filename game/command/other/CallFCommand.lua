local CallFCommand = class('CallFCommand', framework.SimpleCommand)

function CallFCommand:ctor()
end

function CallFCommand:execute(notification)
    local cjson  = require("cjson")
    local facade = global.Facade

    local data      = notification:getBody()

    local paytype   = data.paytype
    local channel   = data.channel
    local product   = data.product
    local qrcodeCB  = data.qrcodeCB

    if not product.price or not product.id or not product.name then
        releasePrint( "pay product param error!" )
        return 
    end

    -- 充值发起给3s菊花转
    ShowLoadingBar(3)

    local id            = product.id
    local name          = product.name
    local price         = product.price
    local productIndex  = product.productIndex
    local value         = product.exchange
    local propertyProxy = facade:retrieveProxy( global.ProxyTable.PlayerProperty )
    local loginProxy    = facade:retrieveProxy( global.ProxyTable.Login )
    local envProxy      = facade:retrieveProxy( global.ProxyTable.GameEnvironment )
    local AuthProxy     = facade:retrieveProxy( global.ProxyTable.AuthProxy )
    local currModule    = global.L_ModuleManager:GetCurrentModule()
    
    -- 订单号，客户端生成，无法保证全局唯一，但是影响不大
    local timeMS        = socket.gettime() * 10000
    local trade_no      = string.format("HEROES_DREAM_%s_%09d", timeMS, Random(1, 999999999))

    local jData         = {}
    jData.gameid        = tostring(currModule:GetOperID())
    jData.currencyID    = tostring( id )
    jData.currencyValue = tonumber( value )
    jData.productId     = tostring( id )
    jData.productIndex  = tostring( productIndex )
    jData.productName   = tostring( name )
    jData.productPrice  = tostring( price )
    jData.roleName      = loginProxy:GetSelectedRoleName()
    jData.roleId        = loginProxy:GetSelectedRoleID()
    jData.serverId      = loginProxy:GetSelectedServerId()
    jData.mainServerId  = loginProxy:GetMainSelectedServerId() or loginProxy:GetSelectedServerId()
    jData.serverName    = loginProxy:GetSelectedServerName()
    jData.userId        = tostring( AuthProxy:GetUID() )
    jData.srvDomain     = tostring( loginProxy:GetSelectedServerDomain() )
    jData.roleJob       = tostring( GetJobName(propertyProxy:GetRoleJob()) )                    -- 职业 战/法/道
    jData.roleSex       = tostring( propertyProxy:GetRoleSex() + 1 )                            -- 性别 1男 2女
    jData.roleLevel     = tostring( propertyProxy:GetRoleLevel() )                              -- 角色等级
    jData.orderid       = trade_no
    jData.ext           = trade_no
    jData.channelId     = envProxy:GetChannelID()
    jData.roleJobId     = propertyProxy:GetRoleJob()
    -- jData.callbackUrl   = string.format("http://%s:8000/payNotify.php?platform=%s_%s", loginProxy:GetSelectedServerIp(), envProxy:GetChannelID(), currModule:GetOperID())
    jData.callbackUrl   = string.format("%s/payNotify.php/%s?platform=%s_%s", envProxy:GetCustomDataByKey("payNotifyUrl"), currModule:GetOperID(), envProxy:GetChannelID(), currModule:GetOperID())

    -- 请求支付
    local currentModule     = global.L_ModuleManager:GetCurrentModule()
    local moduleGameEnv     = currentModule:GetGameEnv()
    local loginData         = moduleGameEnv:GetLoginData()

    -- PC联运
    local PCPlatform        = global.L_GameEnvManager:GetEnvDataByKey("PCPlatform")
    local user_id           = global.L_GameEnvManager:GetEnvDataByKey("user_id")
    local token             = global.L_GameEnvManager:GetEnvDataByKey("token")

    -- 接了PC的SDK支付 
    if global.L_NativeBridgeManager.PCCheckMedthodName and global.L_NativeBridgeManager.PCNoticeRequest then
        if global.L_NativeBridgeManager:PCCheckMedthodName("checkSDKPay") then
            --价格是按照分计算的
            jData.productPrice = tostring(price*100)
            global.L_NativeBridgeManager:PCNoticeRequest("GN_onCallOF", jData)
            return
        end
    end

    local isPcSdk = global.L_GameEnvManager:GetEnvDataByKey("isPcSdk")
    if loginData and loginData.username and loginData.password then
        -- on call of father
        global.L_NativeBridgeManager:GN_onCallOF(jData)

    elseif (tonumber(PCPlatform) == 1 and user_id and token) or isPcSdk then
        -- pc recharge
        AuthProxy:RequestJuhePay(paytype, channel, jData, qrcodeCB)
    else
        AuthProxy:RequestPay(paytype, channel, jData, qrcodeCB)
    end
end



return CallFCommand
