local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankTipsLayer = class("TradingBankTipsLayer", BaseLayer)
local cjson = require("cjson")

function TradingBankTipsLayer:ctor()
    TradingBankTipsLayer.super.ctor(self)
    self.TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)

end

--0点空白区域  1 第一个按钮 2第二个按钮 3 超时
function TradingBankTipsLayer.create(...)
    local ui = TradingBankTipsLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankTipsLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_tips")
    self._root = ui_delegate(self)
    self:InitAdapt()

    ---init
    self._root.Panel_2:setVisible(false)
    self._root.Text_time:setVisible(false)
    self._root.Text_title:setVisible(false)
    self._root.TextField_4 = (self._root.TextField_4)
    self.TradingBankProxy:cancelEmpty(self._root.TextField_4)
    ------
    self.m_callback = data.callback
    local txt = data.txt
    local time = data.time
    local title = data.title
    local notcancel = data.notcancel
    local onlyTime = data.onlyTime
    local exitTime = data.exitTime
    self._root.Text_txt:setString(txt or "")
    -- txt = self:replaceText(txt)
    self._root.Text_txt = SetRichText(self._root.Text_txt, txt or " ")
    self._root.Text_txt:removeFromParent()
    self._root.ListView_1:pushBackCustomItem(self._root.Text_txt)
    local btnTxt = data.btntext or {}
    local btnFontSize = data.btnFontSize or {}
    local btnfontSize1 = btnFontSize[1] or 20
    local btnfontSize2 = btnFontSize[2] or 20
    if #btnTxt == 1 then
        self._root.Button_2:setVisible(false)
        self._root.Button_1:setPositionX(self._root.Button_1:getPositionX() + 110)
        self._root.Button_1:setTitleText(btnTxt[1])
        self._root.Button_1:setTitleFontSize(btnfontSize1)
    elseif #btnTxt == 2 then
        self._root.Button_1:setTitleText(btnTxt[1])
        self._root.Button_2:setTitleText(btnTxt[2])
        self._root.Button_1:setTitleFontSize(btnfontSize1)
        self._root.Button_2:setTitleFontSize(btnfontSize2)
    end
    if time and time > 0 then
        self._root.Text_time:setVisible(true)
        self._root.Text_time:setString(GET_STRING(600000155) .. time .. "s")
        schedule(self._root.Text_time, function()
            time = time - 1
            if time == -1 then
                local num = self._root.TextField_4:getString()
                if not self.m_callback(3, num) then
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Close)
                end
                return
            end
            self._root.Text_time:setString(GET_STRING(600000155) .. time .. "s")
        end, 1)
    end

    if onlyTime and onlyTime > 0 then
        local Text_time = ccui.Text:create()
        Text_time:setFontName("fonts/font2.ttf")
        Text_time:setFontSize(18)
        Text_time:setName("Text_Onlytime")
        Text_time:setTextColor({ r = 255, g = 0, b = 0 })
        Text_time:setString(onlyTime .. "s")
        Text_time:setAnchorPoint(0, 0.5)
        self._root.Text_txt:formatText()
        local size = self._root.Text_txt:getContentSize()
        Text_time:setPosition(cc.p(size.width + 10, size.height / 2))
        Text_time:addTo(self._root.Text_txt)
        schedule(Text_time, function()
            onlyTime = onlyTime - 1
            if onlyTime == 0 then
                local num = self._root.TextField_4:getString()
                if not self.m_callback(3, num) then
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Close)
                end
                return
            end
            Text_time:setString(onlyTime .. "s")
        end, 1)
    end


    local price = data.price
    if price then
        self._root.Panel_1:setVisible(false)
        self._root.Panel_2:setVisible(true)
        self._root.Text_2:setString(GET_STRING(600000145) .. price)
    end

    --title
    if title then
        self._root.Text_title:setVisible(true)
        self._root.Text_title:setString(title)
        self._root.Text_txt:setFontSize(16)
        self._root.Text_txt:setPositionY(self._root.Text_txt:getPositionY() - 12)
    end
    if not notcancel then
        self._root.Panel_cancel:addTouchEventListener(function(sender, type)
            if type ~= 2 then
                return
            end
            if self.m_callback then
                self.m_callback(0)
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Close)
        end)
    end
    self._root.Button_1:addTouchEventListener(handler(self, self.onButtonClick))
    self._root.Button_2:addTouchEventListener(handler(self, self.onButtonClick))
    ----寄售成功倒计时
    if exitTime then 
        self._root.ListView_1:removeAllItems()
        local Text_txt = ccui.Text:create()
        Text_txt:setFontName(global.MMO.PATH_FONT2)
        self._root.Panel_1:addChild(Text_txt)
        Text_txt:setPosition(cc.p(260, 161))
        Text_txt:setFontSize(18)
        local color = GetColorFromHexString( "#ffffff" )
        Text_txt:setTextColor(color)
        Text_txt:getVirtualRenderer():setMaxLineWidth(484)
        Text_txt:setAnchorPoint( 0.50, 1.00)
        local OutlineColor = GetColorFromHexString( "#000000" )
        Text_txt:enableOutline(OutlineColor, 1)
        Text_txt:setString(string.format(txt or "",exitTime))
        schedule(Text_txt,function()
            exitTime = exitTime - 1
            if exitTime < 0 then 
                self.m_callback(1)
                return 
            end
            Text_txt:setString(string.format(txt or "",exitTime))

        end,1)
    end
    return true
end

function TradingBankTipsLayer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_cancel, winSizeW, winSizeH)
    GUI:setPosition(self._root.Image_1, winSizeW / 2, winSizeH / 2)
end


function TradingBankTipsLayer:onButtonClick(sender, type)
    if type ~= 2 then
        return
    end
    local name = sender:getName()
    local num = self._root.TextField_4:getString()
    if name == "Button_1" then
        if self.m_callback then
            if not self.m_callback(1, num) then
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Close)
            end
        end
    else
        if self.m_callback then
            if not self.m_callback(2, num) then
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Close)
            end
        end
    end

end

return TradingBankTipsLayer