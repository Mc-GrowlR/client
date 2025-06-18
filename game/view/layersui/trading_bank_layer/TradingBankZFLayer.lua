local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankZFLayer = class("TradingBankZFLayer", BaseLayer)

function TradingBankZFLayer.create(...)
    local ui = TradingBankZFLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankZFLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_zf")
    self._root = ui_delegate(self)
    self:InitAdapt()
    self.m_data = data.data
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPanel_Open, { parent = self._root.Node_1, data = data.data, callback = data.callback })
    return true
end

function TradingBankZFLayer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_cancel, winSizeW, winSizeH)
    GUI:setPosition(self._root.Node_1, winSizeW / 2, winSizeH / 2)
end

-------------------------------------
return TradingBankZFLayer