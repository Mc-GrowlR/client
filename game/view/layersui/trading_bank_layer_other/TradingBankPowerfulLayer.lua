local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankPowerfulLayer = class("TradingBankPowerfulLayer", BaseLayer)
local cjson = require("cjson")

function TradingBankPowerfulLayer:ctor()
    TradingBankPowerfulLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankPowerfulLayer.create(...)
    local ui = TradingBankPowerfulLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankPowerfulLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_powerful")
    self._root = ui_delegate(self)
    self:InitAdapt()

    ---init
    self._payType = data.type
    self._payInfo = data.payinfo
    self.m_callback = data.callback
    self._order_id = self._payInfo.order_id
    self._commodityType = self._payInfo.commodityType
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
        local filename    = "lyjyhqrcode.png"
        local filePath    = directoryPath .. filename
        local textureCache = global.Director:getTextureCache()
        if textureCache:getTextureForKey(filePath) then
            textureCache:removeTextureForKey(filePath)
        end
        if global.FileUtilCtl:isFileExist(filePath) then
            global.FileUtilCtl:removeFile(filePath)
        end
        self.OtherTradingBankProxy:reqpayOrderEWM(self, self._payInfo, function(code, data, msg)
            if code == 200 then 
                local qrCodeImg = data.qrCodeImg
                local pngBase64Str =  string.gsub(qrCodeImg,"data:image/png;base64,","")
                local pngStr = base64dec(pngBase64Str)
                local ress = global.FileUtilCtl:writeStringToFile(pngStr, filePath)
                if ress then
                    self._root.Image_ewm:loadTexture(filePath)
                    self._root.Image_ewm:setVisible(true)
                else
                    ShowSystemTips(GET_STRING(600000851))
                end
            else
                ShowSystemTips(msg or "")
            end
        end
        )
    else
        self.OtherTradingBankProxy:reqpayOrder2(self, self._payInfo, handler(self, self.respay))
    end
end

function TradingBankPowerfulLayer:respay(code, data, msg)
    dump({ code, data, msg }, "respay___")
    if code == 200 then
        if data and type(data) == "table" and data.body then
            self:openWebViewURL(data.body)
        end
    else
        ShowSystemTips(msg)
    end


end

function TradingBankPowerfulLayer:openWebViewURL(url)
    cc.Application:getInstance():openURL(url)
end

function TradingBankPowerfulLayer:reqOrderStatus()
    self.OtherTradingBankProxy:reqOrderStatus(self, { order_id = self._order_id }, function(code, data, msg)
        dump({ code, data, msg }, "reqOrderStatus__")
        if code == 200 then
            if data and data.status == "success" then
                self:ZFSuccess()
            else--未支付
                
                ShowSystemTips(GET_STRING(600000195))
            end
        end
    end)
end

function TradingBankPowerfulLayer:ZFSuccess()
    if self.m_callback then
        self.m_callback()
    end
    ShowSystemTips(GET_STRING(600000197))
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPowerfulLayer_Close_other)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPanel_Close_other)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFLayer_Close_other)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFPanel_Close_other)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFLayer_Close_other)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPlayerLayer_Close_other)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankLookOtherServerPlayerLayer_Close_other)
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
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPowerfulLayer_Close_other)
    end

end

function TradingBankPowerfulLayer:exitLayer()
    self.OtherTradingBankProxy:removeLayer(self)
end
return TradingBankPowerfulLayer