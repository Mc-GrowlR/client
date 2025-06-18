local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankLookOtherServerPlayerLayer = class("TradingBankLookOtherServerPlayerLayer", BaseLayer)

local cjson = require("cjson")

function TradingBankLookOtherServerPlayerLayer:ctor()
    TradingBankLookOtherServerPlayerLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    self.LoginProxy    = global.Facade:retrieveProxy(global.ProxyTable.Login)
end

function TradingBankLookOtherServerPlayerLayer.create(...)
    local ui = TradingBankLookOtherServerPlayerLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankLookOtherServerPlayerLayer:Init(data)
    GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_look_other_server_player")
    self._root = ui_delegate(self)
    self.m_data = data
    self.m_isPay = data.isPay
    self.m_callback = data.callback
    self:InitAdapt()
    self:InitUI(self.m_data.goodsInfo)
    return true
end

function TradingBankLookOtherServerPlayerLayer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_2, winSizeW, winSizeH)
    GUI:setPosition(self._root.Panel_2, winSizeW / 2, winSizeH / 2)
    if  self.m_isPay then 
        -- 568-407
        --933 -568
        GUI:setPosition(self._root.Image_bg,winSizeW / 2 - 161,  winSizeH / 2)
        GUI:setPosition(self._root.pay_Node,winSizeW / 2 + 365,  winSizeH / 2)
    else
        GUI:setPosition(self._root.Image_bg, winSizeW / 2, winSizeH / 2)
        self._root.pay_Node:setVisible(false)
    end
end

function TradingBankLookOtherServerPlayerLayer:InitUI(data)
    dump(data,"TradingBankLookOtherServerPlayerLayer_InitUI")
    self._root.Button_close:addClickEventListener(function ()
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankLookOtherServerPlayerLayer_Close_other)
    end)
    --购买
    self._root.Button_buy:addClickEventListener(function ()
        self.OtherTradingBankProxy:doTrack(self.OtherTradingBankProxy.UpLoadData.TraingBuyLayerBuyBtnClick)
        local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
        local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
        self.m_isPay = true 
        GUI:setPosition(self._root.Image_bg,winSizeW / 2 - 161,  winSizeH / 2)
        GUI:setPosition(self._root.pay_Node,winSizeW / 2 + 365,  winSizeH / 2)
        self._root.Button_close:setVisible(false)
        self._root.Button_buy:setVisible(false)
        self._root.pay_Node:setVisible(true)
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPanel_Open_other, { parent = self._root.pay_Node, goodsData = self.m_data.goodsData, isrole = true, callback = self.m_data.callback })
    end)
    self._root.Text_Name:setString(data.title or "")
    self._root.Text_Job:setString(data.roleConfigTypeName or "")
    self._root.Text_Server:setString(data.serverName or "")
    self._root.Text_Price:setString(data.price or "")
    
    self._root.Image_cp:setVisible(false)
    if  self.m_isPay then 
        self._root.Button_close:setVisible(false)
        self._root.Button_buy:setVisible(false)
        
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPanel_Open_other, { parent = self._root.pay_Node, goodsData = self.m_data.goodsData, isrole = true, callback = self.m_data.callback })
    end
    self:showImgs()
end


function TradingBankLookOtherServerPlayerLayer:onImageClic(sender, type)
    if type ~= 2 then
        return
    end
    if sender.path then 
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankLookTexture_Open_other, sender)
    end
end
-------------------
--显示图片
function TradingBankLookOtherServerPlayerLayer:showImgs()
    local detailData = self.m_data.goodsInfo.detail or {}
    local paths = {}
    local imageCount = 0
    for i, v in ipairs(detailData) do
        local imgPaths = cjson.decode(v.slotValue or "{}")
        for i2, path in ipairs(imgPaths) do
            imageCount = imageCount + 1
            table.insert(paths, path)
        end
    end
    local ImageViews = {}
    local size = self._root.Image_cp:getContentSize()
    local yy = math.ceil(imageCount / 5)
    local H = (yy + 1) * 18.7 + yy * size.height
    self._root.Panel_p:setInnerContainerSize(cc.size(680, H))
    for i, v in ipairs(paths) do
        local Image_cp = self._root.Image_cp:cloneEx()
        Image_cp:addTo(self._root.Panel_p)
        local x = (i - 1) % 5 + 1
        local y = math.ceil(i / 5)
        Image_cp:setPosition(18.7 * x + (x - 0.5) * size.width, H - (18.7 * y + (y - 0.5) * size.height))
        Image_cp:addTouchEventListener(handler(self, self.onImageClic))
        self:loadImg(Image_cp, v, i)
    end
end

function TradingBankLookOtherServerPlayerLayer:loadImg(sender , url, index)
    local host = "https://oss.ptjyh.aml52.com/"
    url = host .. url
    self.OtherTradingBankProxy:addLayer(self)
    local mainPlayerID = self.LoginProxy:GetSelectedRoleID()
    local fileUtils = cc.FileUtils:getInstance()
    local writablePath = fileUtils:getWritablePath()
    local filePath = string.format("%s%s_%s_%s", writablePath, mainPlayerID, self.m_data.goodsInfo.id ,index)
    if fileUtils:isFileExist(filePath) then 
        sender.path = filePath
        sender:loadTexture(filePath)
        sender:setVisible(true)
        return 
    end
    local httpRequest = cc.XMLHttpRequest:new()
    httpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    httpRequest.timeout = 100000 -- 10 s
    httpRequest:open("GET", url)
    ------------------------------
    local function HttpResponseCB()
        local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
        if not OtherTradingBankProxy:findLayer(self) then 
            return 
        end
        local code = httpRequest.status
        local response = httpRequest.response
        ------------------
        releasePrint("Http Request Code:" .. tostring(code))
        if code >= 200 and code < 300 then 
            local res = global.FileUtilCtl:writeStringToFile(response, filePath)
            if res  then 
                sender.path = filePath
                sender:loadTexture(filePath)
                sender:setVisible(true)
            end
        end
    end
    httpRequest:registerScriptHandler(HttpResponseCB)
    httpRequest:send()
end

function TradingBankLookOtherServerPlayerLayer:exitLayer()
    self.OtherTradingBankProxy:removeLayer(self)
end

return TradingBankLookOtherServerPlayerLayer