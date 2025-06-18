local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankRefuseLayer = class("TradingBankRefuseLayer", BaseLayer)
local cjson = require("cjson")
local UTF8 = require("util/utf8")

function TradingBankRefuseLayer:ctor()
    TradingBankRefuseLayer.super.ctor(self)
    self.TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)

end
--  1 第一个按钮(ok)  2第二个按钮(x) 
function TradingBankRefuseLayer.create(...)
    local ui = TradingBankRefuseLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankRefuseLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_refuse")
    self._root = ui_delegate(self)
    self:InitAdapt()

    self.m_callback = data and data.callback
    self.m_reasons = data and data.reasons or {}
    self._root.Button_1:addTouchEventListener(handler(self, self.onButtonClick))
    self._root.ButtonClose:addTouchEventListener(handler(self, self.onButtonClick))

    self.selReason = 1
    local Reason
    local txt
    for i = 1, 3 do
        Reason = self._root["Panel_sel" .. i]
        if i ~= self.selReason then
            Reason:getChildByName("Image_2"):getChildByName("Image_1"):setVisible(false)
        end
        Reason:addTouchEventListener(function(sender, type)
            if type ~= 2 then
                return
            end
            self:refSelReason(i)
        end)
        txt = Reason:getChildByName("Text_1"):setString(self.m_reasons[i] or "")
    end
    self._root.TextField_2 = (self._root.TextField_2)
    local x = self._root.TextField_2:getPositionX()
    self._root.TextField_2:setPositionX(-100000)
    self._root.Panel_mask:addTouchEventListener(function(sender, state)
        if state == 2 and self.selReason == 3 then
            self._root.TextField_2:setPositionX(x)
            self._root.TextField_2:touchDownAction(self._root.TextField_2, 2)
        end
    end)

    return true
end

function TradingBankRefuseLayer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_1, winSizeW, winSizeH)
    GUI:setPosition(self._root.Image_bg, winSizeW / 2, winSizeH / 2)
end

function TradingBankRefuseLayer:refSelReason(index)
    local selitem = self._root["Panel_sel" .. index]:getChildByName("Image_2"):getChildByName("Image_1")
    selitem:setVisible(true)
    local selitem = self._root["Panel_sel" .. self.selReason]:getChildByName("Image_2"):getChildByName("Image_1")
    selitem:setVisible(false)
    self.selReason = index
    if index ~= 3 then
        self._root.TextField_2:setPositionX(-100000)
    end
end

function TradingBankRefuseLayer:onButtonClick(sender, type)
    if type ~= 2 then
        return
    end
    local name = sender:getName()
    if name == "Button_1" then
        local ReasonStr = ""
        if self.selReason == 1 then
            ReasonStr = GET_STRING(600000058)
        elseif self.selReason == 2 then
            ReasonStr = GET_STRING(600000059)
        else
            local str = self._root.TextField_2:getString()
            local str2 = string.gsub(str, "%s", "")
            local num = UTF8:length(str2)
            if num < 10 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000064)) --600000060
                return
            end
            ReasonStr = str
        end


        if self.m_callback then
            if not self.m_callback(1, ReasonStr) then
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankRefuseLayer_Close)
            end
        end
    else
        if self.m_callback then
            if not self.m_callback(2) then
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankRefuseLayer_Close)
            end
        end
    end

end

return TradingBankRefuseLayer