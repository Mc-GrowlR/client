local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankTips2Layer = class("TradingBankTips2Layer", BaseLayer)
local cjson = require("cjson")
function TradingBankTips2Layer:ctor()
    TradingBankTips2Layer.super.ctor(self)
    self.TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)

end
--  1 第一个按钮(ok)  2第二个按钮(cancel) 
function TradingBankTips2Layer.create(...)
    local ui = TradingBankTips2Layer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankTips2Layer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_tips2")
    self._root = ui_delegate(self)
    self:InitAdapt()

    local type = data.type or 1 -- 1 按钮  2滑块 
    local text = data.text or ""
    local btntext = data.btntext
    self.m_callback = data.callback
    if type == 1 then
        self._root.Panel_8:setVisible(false)
    else
        self._root.Button_1:setVisible(false)
        --237-266
        self._root.Slider_3:setPercent(0)
        local contentSize = self._root.Panel_mask:getContentSize()
        self._root.Panel_mask:setContentSize(14.5, contentSize.height)
        self._root.Slider_3:addEventListener(function(sender, eventType)
            if eventType == 0 then
                local p = sender:getPercent()
                local contentSize = self._root.Panel_mask:getContentSize()
                self._root.Panel_mask:setContentSize(14.5 + p / 100 * 237, contentSize.height)
                if p == 100 then
                    PerformWithDelayGlobal(function()
                        if self.m_callback then
                            self.m_callback(1)
                            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Close)
                        end
                    end, 0.1)
                end
            end
        end)
    end

    if text then
        self._root.Text_desc:setString(text)
    end
    if btntext then
        self._root.Button_1:setTitleText(btntext)
    end

    self._root.Button_1:addTouchEventListener(handler(self, self.onButtonClick))
    self._root.Button_2:addTouchEventListener(handler(self, self.onButtonClick))
    return true
end

function TradingBankTips2Layer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_cancel, winSizeW, winSizeH)
    GUI:setPosition(self._root.Image_1, winSizeW / 2, winSizeH / 2)
end

function TradingBankTips2Layer:onButtonClick(sender, type)
    if type ~= 2 then
        return
    end
    local name = sender:getName()
    if name == "Button_1" then
        if self.m_callback then
            if not self.m_callback(1) then
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Close)
            end
        end
    else
        if self.m_callback then
            if not self.m_callback(2) then
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Close)
            end
        end
    end

end

return TradingBankTips2Layer