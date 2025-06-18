local BaseLayer = requireLayerUI("BaseLayer")
local RechargeQRCodeLayer = class("RechargeQRCodeLayer", BaseLayer)

local RichTextHelp = requireUtil("RichTextHelp")

function RechargeQRCodeLayer:ctor()
    RechargeQRCodeLayer.super.ctor(self)
end

function RechargeQRCodeLayer.create(...)
    local ui = RechargeQRCodeLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function RechargeQRCodeLayer:Init(data)
    self.ui = ui_delegate(self)

    return true
end

function RechargeQRCodeLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_RECHARGE_QRCODE)
    RechargeQRCode.main()

    -- 关闭
    self.ui.Button_close:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_Recharge_QRCode_Close)
    end)
end

function RechargeQRCodeLayer:ShowQRCode(data)
    local imageQRCode = nil
    -- qrcode
    local filename = data.filename
    local fullPath = global.FileUtilCtl:fullPathForFilename(filename)
    if global.FileUtilCtl:isFileExist(fullPath) then
        imageQRCode = ccui.ImageView:create()
        imageQRCode:loadTexture(filename)
        local imgSize = imageQRCode:getContentSize()
        if imgSize.width > 350 or imgSize.height > 350 then
            imageQRCode:ignoreContentAdaptWithSize(false)
            imageQRCode:setContentSize(200,200)
        end
        self.ui.Node_qrcode:removeAllChildren()
        self.ui.Node_qrcode:addChild(imageQRCode)
    end

    -- qrcode tips
    local AuthProxy     = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local PAY_CHANNEL   = AuthProxy.PAY_CHANNEL
    local channel       = data.channel
    local setTip        = global.L_GameEnvManager:GetEnvDataByKey("recharge_tip")
    local tips = 
    {
        [PAY_CHANNEL.WEIXIN] = setTip or GET_STRING(30103200),
        [PAY_CHANNEL.ALIPAY] = setTip or GET_STRING(30103201),
        [PAY_CHANNEL.HUABEI] = setTip or GET_STRING(30103201),
    }

    local richText = RichTextHelp:CreateRichTextWithXML(tips[channel], 500, SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE") or 16, "#ffffff")
    self.ui.Node_qrcode_tips:removeAllChildren()
    self.ui.Node_qrcode_tips:addChild(richText)


    local leftTime = 40 -- 倒计时40秒
    local function showLeftTime()
        self.ui.Text_time:setString(string.format( GET_STRING(30103213), leftTime))
        if leftTime <= 0 then 
            self.ui.Text_time:stopAllActions()
            global.Facade:sendNotification(global.NoticeTable.HighLightNodeShader, imageQRCode, global.MMO.SHADER_TYPE_SHADOW)
            self.ui.Text_time:setString(GET_STRING(30103214))
            ShowSystemTips(GET_STRING(30103214))
        end 
        leftTime = math.max(0, leftTime - 1)
    end
    showLeftTime()
    schedule(self.ui.Text_time, showLeftTime, 1)
end

return RechargeQRCodeLayer