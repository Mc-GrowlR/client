local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankZFPlayerLayer = class("TradingBankZFPlayerLayer", BaseLayer)
function TradingBankZFPlayerLayer.create(...)
    local ui = TradingBankZFPlayerLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankZFPlayerLayer:Init(data)
    self.TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_zf_player")
    self._root = ui_delegate(self)
    self:InitAdapt()
    
    local prodData = data.data
    dump(data,"data____")
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerPanel_Close)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerInfo_Close)

    self.TradingBankLookPlayerProxy:RequestPlayerData(data.role_id, function()
        local TradingBankZFPlayerLayerMediator = global.Facade:retrieveMediator("TradingBankZFPlayerLayerMediator")
        if not TradingBankZFPlayerLayerMediator._layer then
            return
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerPanel_Open, { parent = self._root.Node_1, role_id = data.role_id, noClose = true ,prodData = prodData})
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPanel_Open, { parent = self._root.Node_2, data = data.data, isrole = true, callback = data.callback })
    end)

    return true
end

function TradingBankZFPlayerLayer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_cancel, winSizeW, winSizeH)
    GUI:setPositionY(self._root.Node_1, winSizeH / 2)
    GUI:setPositionY(self._root.Node_2, winSizeH / 2)
end

-------------------------------------
return TradingBankZFPlayerLayer