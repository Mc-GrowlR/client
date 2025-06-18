local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankCaptureMaskLayer = class("TradingBankCaptureMaskLayer", BaseLayer)


function TradingBankCaptureMaskLayer:ctor()
    TradingBankCaptureMaskLayer.super.ctor(self)
end

function TradingBankCaptureMaskLayer.create(...)
    local ui = TradingBankCaptureMaskLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankCaptureMaskLayer:Init(data)
    GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_capture_mask")
    self._ui = ui_delegate(self)

    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._ui.Panel_1, winSizeW, winSizeH)
    GUI:setPosition(self._ui.Panel_1, winSizeW / 2, winSizeH / 2)
    return true
end

return TradingBankCaptureMaskLayer