local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankZFPlayerLayer = class("TradingBankZFPlayerLayer", BaseLayer)
function TradingBankZFPlayerLayer.create(...)
    local ui = TradingBankZFPlayerLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankZFPlayerLayer:Init(val)
    dump(val, "TradingBankZFPlayerLayer   val______")
    self.TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_zf_player")
    self._root = ui_delegate(self)
    self:InitAdapt()
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerPanel_Close_other)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerInfo_Close_other)
    local goodsData = val.data
    --查询商品信息
    -- self.OtherTradingBankProxy:reqcommodityInfo(self, { commodity_id = val.commodityId }, function(code, data, msg)
    --     if code == 200 then
            self.TradingBankLookPlayerProxy:RequestPlayerData(goodsData.roleId, function()
                local TradingBankZFPlayerLayerMediator_other = global.Facade:retrieveMediator("TradingBankZFPlayerLayerMediator_other")
                if not TradingBankZFPlayerLayerMediator_other._layer then
                    return
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerPanel_Open_other, { parent = self._root.Node_1, roleId = goodsData.roleId, noClose = true })
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPanel_Open_other, { parent = self._root.Node_2, goodsData = goodsData, isrole = true, callback = val.callback })
            end)
    --     else
    --         ShowSystemTips(msg or "")
    --         global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerPanel_Close_other)
    --         global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerInfo_Close_other)
    --         global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPlayerLayer_Close_other)
    --     end
    -- end)
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