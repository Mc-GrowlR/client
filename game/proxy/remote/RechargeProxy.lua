local RemoteProxy = requireProxy("remote/RemoteProxy")
local RechargeProxy = class("RechargeProxy", RemoteProxy)
RechargeProxy.NAME = global.ProxyTable.RechargeProxy

function RechargeProxy:ctor()
    RechargeProxy.super.ctor(self)
    
    self._products = {}
end

function RechargeProxy:GetProducts()
    return self._products
end

function RechargeProxy:GetProductByID(id)
    for _, v in pairs(self._products) do
        if tostring(id) == tostring(v.currency_itemid) then
            return v
        end
    end
    return nil
end

function RechargeProxy:RespProductInfo(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return false
    end
    -- dump(jsonData)
    self._products = jsonData
end

function RechargeProxy:RespRechargeComplete(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return false
    end

    -- -- 友盟 充值完成上报
    -- if global.L_NativeBridgeManager.GN_umengFinishPay then
    --     local AuthProxy = global.Facade:retrieveProxy( global.ProxyTable.AuthProxy )
    --     local uploadData = {
    --         userId = tostring( AuthProxy:GetUID() ),
    --         orderId = tostring( AuthProxy:getOrderID() ),
    --         productId = tostring( jsonData.currencyID ),
    --         productName = tostring( jsonData.productName ),
    --         productPrice = tostring( jsonData.productPrice ),
    --     }
    --     global.L_NativeBridgeManager:GN_umengFinishPay(uploadData)
    -- end
end

function RechargeProxy:RespRechargeReceived(msg)
    global.Facade:sendNotification(global.NoticeTable.RechargeReceivedResp)
end

function RechargeProxy:RespJumpRecharge(msg)
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local channels  = 
    {
        AuthProxy.PAY_CHANNEL.ALIPAY,
        AuthProxy.PAY_CHANNEL.HUABEI,
        AuthProxy.PAY_CHANNEL.WEIXIN,
    }

    local header  = msg:GetHeader()
    local price         = header.recog
    local payChannel    = channels[header.param1]
    local currencyID    = header.param2
    local productIndex  = header.param3

    -- 
    if not payChannel then
        return nil
    end

    -- 二维码回调
    local product = self:GetProductByID(currencyID)
    if not product then
        ShowSystemTips( "未找到商品: " .. (currencyID or "") )
        return nil
    end

    -- 二维码充值回调
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
    
    -- 开始充值, 手机端使用原生 PC端使用二维码
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

function RechargeProxy:RespJumpRechargeEx(msg)
    local json = ParseRawMsgToJson(msg)
    if not json then
        return
    end

    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local channels  = 
    {
        AuthProxy.PAY_CHANNEL.ALIPAY,
        AuthProxy.PAY_CHANNEL.HUABEI,
        AuthProxy.PAY_CHANNEL.WEIXIN,
    }

    local price         = tonumber(json.Param1)
    local payChannel    = tonumber(json.Param2) and channels[tonumber(json.Param2)]
    local currencyID    = tonumber(json.Param3)
    local productIndex  = tonumber(json.Param4)
    -- 
    if not payChannel or not price then
        return nil
    end

    -- 二维码回调
    local product = self:GetProductByID(currencyID)
    if not product then
        ShowSystemTips( "未找到商品: " .. (currencyID or "") )
        return nil
    end

    -- 二维码充值回调
    local function qrcodeCB(isOK, filename)
        if isOK then
            -- 二维码拉取成功
            local qrcode_data = {
                filename    = filename,
                channel     = payChannel,
            }
            global.Facade:sendNotification( global.NoticeTable.Layer_Recharge_QRCode_Open, qrcode_data)
        end
    end
    
    -- 开始充值, 手机端使用原生 PC端使用二维码
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

function RechargeProxy:RegisterMsgHandler()
    RechargeProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType
    
    LuaRegisterMsgHandler(msgType.MSG_SC_PRODUCT_INFO, handler(self, self.RespProductInfo))
    LuaRegisterMsgHandler(msgType.MSG_SC_RECHARGE_RECEIVED, handler(self, self.RespRechargeReceived))
    LuaRegisterMsgHandler(msgType.MSG_SC_RECHARGE_COMPLETE, handler(self, self.RespRechargeComplete))
    LuaRegisterMsgHandler(msgType.MSG_SC_JUMP_CHARGE, handler(self, self.RespJumpRecharge))
    LuaRegisterMsgHandler(msgType.MSG_SC_JUMP_CHARGE_EX, handler(self, self.RespJumpRechargeEx))
end

return RechargeProxy
