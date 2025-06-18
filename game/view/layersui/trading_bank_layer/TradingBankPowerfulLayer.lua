local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankPowerfulLayer = class("TradingBankPowerfulLayer", BaseLayer)
local cjson = require("cjson")

function TradingBankPowerfulLayer:ctor()
    TradingBankPowerfulLayer.super.ctor(self)
    self.TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
end

function TradingBankPowerfulLayer.create(...)
    local ui = TradingBankPowerfulLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankPowerfulLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_powerful")
    self._root = ui_delegate(self)
    self:InitAdapt()

    ---init
    self._payType = data.type
    self._payInfo = data.payinfo
    self.m_callback = data.callback
    self._order_id = self._payInfo.order_id
    self._root.Text_1:setVisible(false)
    self._root.Text_2:setVisible(false)
    self._root.Image_ewm:setVisible(false)
    if self._payType == 1 then -- 二维码 
        self._root.Image_2:setVisible(false)
    else
        self._root.Text_2:setVisible(true)
        self._root.Text_2:setString(GET_STRING(600000198))
        self._root.Image_1:setVisible(false)
        self._root.Button_1:setPositionY(self._root.Button_1:getPositionY() + 30)
        self._root.Button_2:setPositionY(self._root.Button_2:getPositionY() + 30)
        self._root.Button_3:setPositionY(self._root.Button_3:getPositionY() - 30)
    end

    for i = 1, 3 do
        local btn = self._root["Button_" .. i]
        btn:addTouchEventListener(handler(self, self.onButtonClick))
    end
    self:pay()
    return true
end

function TradingBankPowerfulLayer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_cancel, winSizeW, winSizeH)
    GUI:setPosition(self._root.Panel_1, winSizeW / 2, winSizeH / 2)
end

function TradingBankPowerfulLayer:pay()
    if self._payType == 1 then -- 二维码 
        local directoryPath = global.FileUtilCtl:getWritablePath() .. global.L_ModuleManager:GetCurrentModulePath()
        local filename    = "jyhqrcode.png"
        local filePath    = directoryPath .. filename
        local textureCache = global.Director:getTextureCache()
        if textureCache:getTextureForKey(filePath) then
            textureCache:removeTextureForKey(filePath)
        end
        if global.FileUtilCtl:isFileExist(filePath) then
            global.FileUtilCtl:removeFile(filePath)
        end
        self.TradingBankProxy:reqpayOrderEWM(self, self._payInfo,
        function(success, response, code)
            dump(pcall(cjson.decode, response), "res____")

            local funcjx = function(data)
                local dd = cjson.decode(data)
                local code = dd.code
            end
            if not pcall(funcjx, response) then
                local ress = global.FileUtilCtl:writeStringToFile(response, filePath)
                if ress then
                    self._root.Image_ewm:loadTexture(filePath)
                    self._root.Image_ewm:setVisible(true)
                else
                    ShowSystemTips(GET_STRING(30103202))
                end
                -- global.Facade:sendNotification( global.NoticeTable.Layer_Recharge_QRCode_Open, qrcode_data )
            else
                local data = cjson.decode(response)
                ----- 支付已完成
                if data and data.code == 40058 then
                    self:ZFSuccess()
                elseif data and data.msg then
                    ShowSystemTips(data.msg)
                else
                    ShowSystemTips(GET_STRING(30103202))
                end
            end
        end
        )
    else
        self.TradingBankProxy:reqpayOrder(self, self._payInfo, handler(self, self.respay))
    end
end

function TradingBankPowerfulLayer:respay(success, response, code)
    dump({ success, response, code }, "respay___")
    if success then
        local data = cjson.decode(response)
        if data.code == 200 then
            data = data.data
            if data and type(data) == "table" and data.pay_info then
                self:openWebViewURL(data.pay_info)
            end
        elseif data.code >= 50000 and data.code <= 50020 then--token失效
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open, { callback = function(code)
                if code == 1 then
                    self:pay()
                else

                end
            end })
        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg or "")
        end

    else
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000158))
    end
end

function TradingBankPowerfulLayer:openWebViewURL(url)
    cc.Application:getInstance():openURL(url)
end

function TradingBankPowerfulLayer:reqOrderStatus()
    self.TradingBankProxy:reqOrderStatus(self, { order_id = self._order_id }, function(success, response, code)
        dump({ success, response, code }, "reqOrderStatus__")
        if success then
            local data = cjson.decode(response)
            if data.code == 200 then
                data = data.data

                if data.status == "success" then

                    self:ZFSuccess()


                else--未支付
                    ShowSystemTips(GET_STRING(600000195))

                end
            else
                global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg or "")
            end
            -- global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000137))
        end
    end)
end

function TradingBankPowerfulLayer:ZFSuccess()
    if self.m_callback then
        self.m_callback()
    end
    ShowSystemTips(GET_STRING(600000197))
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPowerfulLayer_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPanel_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFLayer_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFPanel_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFLayer_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPlayerLayer_Close)
end

function TradingBankPowerfulLayer:onButtonClick(sender, type)
    if type ~= 2 then
        return
    end
    local name = sender:getName()
    if name == "Button_1" then
        self:reqOrderStatus()
    elseif name == "Button_2" then
        self:pay()
    elseif name == "Button_3" then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPowerfulLayer_Close)
    end

end

function TradingBankPowerfulLayer:exitLayer()
    self.TradingBankProxy:removeLayer(self)
end
return TradingBankPowerfulLayer