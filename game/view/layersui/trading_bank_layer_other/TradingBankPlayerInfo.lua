local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankPlayerInfo = class("TradingBankPlayerInfo", BaseLayer)
local cjson = require("cjson")

function TradingBankPlayerInfo:ctor()
    TradingBankPlayerInfo.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankPlayerInfo.create(...)
    local ui = TradingBankPlayerInfo.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankPlayerInfo:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_player_info")
    self._ui = ui_delegate(self)
    self._root = self._ui
    self:InitAdapt()
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerPanel_Open_other, { parent = self._ui.Node_1 })
    self._ui.Panel_cancel:addTouchEventListener(handler(self, self.onButtonClick))

    return true
end

function TradingBankPlayerInfo:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_cancel, winSizeW, winSizeH)
    GUI:setPositionY(self._root.Panel_1, winSizeH / 2)
end

function TradingBankPlayerInfo:onButtonClick(sender, type)
    if type ~= 2 then
        return
    end
    local name = sender:getName()
    if name == "Panel_cancel" then -- 取消
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerPanel_Close_other)
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerInfo_Close_other)
    end

end

return TradingBankPlayerInfo