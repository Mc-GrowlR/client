local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankCostZFLayer = class("TradingBankCostZFLayer", BaseLayer)

function TradingBankCostZFLayer:ctor()
    TradingBankCostZFLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankCostZFLayer.create(...)
    local ui = TradingBankCostZFLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankCostZFLayer:Init(val)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_cost_zf")
    self._root = ui_delegate(self)
    self:InitAdapt()
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFPanel_Open_other, { parent = self._root.Node_1, goodsData = val.data,  callback = val.callback })
    return true
end

function TradingBankCostZFLayer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_1, winSizeW, winSizeH)
    GUI:setPosition(self._root.Panel_1,winSizeW / 2, winSizeH / 2)
    GUI:setPositionY(self._root.Node_1, winSizeH / 2)
    GUI:setPositionY(self._root.Node_2, winSizeH / 2)
    GUI:setPositionY(self._root.Node_3, winSizeH / 2)
end

-------------------------------------
return TradingBankCostZFLayer