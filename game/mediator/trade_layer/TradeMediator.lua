local BaseUIMediator = requireMediator("BaseUIMediator")
local TradeMediator = class("TradeMediator", BaseUIMediator)
TradeMediator.NAME = "TradeMediator"

function TradeMediator:ctor()
    TradeMediator.super.ctor(self)
end

function TradeMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Trade_Open,
        noticeTable.Layer_Trade_Close,
        noticeTable.Layer_Trade_TraderItemChange,
        noticeTable.Layer_Trade_MyselfItemChange,
        noticeTable.Layer_Trade_MoneyChange,              
        noticeTable.Layer_Trade_MyMoneyChange,           
        noticeTable.Layer_Trade_StatusChange,             
        noticeTable.Layer_Trade_MyStatusChange,            
    }
end

function TradeMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local id = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Trade_Open == id then
        self:OpenLayer(data)
    elseif noticeTable.Layer_Trade_Close == id then
        self:CloseLayer()
    elseif noticeTable.Layer_Trade_TraderItemChange == id then
        self:OnTraderItemChange(data)
    elseif noticeTable.Layer_Trade_MyselfItemChange == id then
        self:OnMyselfItemChange(data)

    elseif noticeTable.Layer_Trade_MoneyChange == id then
        self:RefreshTradeMoney(data)
    elseif noticeTable.Layer_Trade_MyMoneyChange == id then
        self:RefreshMyMoney(data)
    elseif noticeTable.Layer_Trade_StatusChange == id then
        self:RefreshTradeStatus()
    elseif noticeTable.Layer_Trade_MyStatusChange == id then
        self:RefreshMyStatus()
    end
end

function TradeMediator:OpenLayer(data)
    if not (self._layer) then
        local path = "trade_layer/TradeLayer"
        if global.isWinPlayMode then
            path = "trade_layer/TradeLayer_win32"
        end
        self._layer = requireLayerUI(path).create()
        self._type  = global.UIZ.UI_NORMAL
        self._hideLast = false
        self._GUI_ID   = SLDefine.LAYERID.TradeGUI

        TradeMediator.super.OpenLayer(self)

        self._layer:InitGUI()
    end
end

function TradeMediator:CloseLayer()
    TradeMediator.super.CloseLayer(self)

    local proxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
    if proxy:IsTrading() then
        proxy:RequestCancle()
    end

    -- 异常处理
    if not global.isWinPlayMode then
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel, {from = ItemMoveProxy.ItemFrom.TRADE})
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel, {from = ItemMoveProxy.ItemFrom.TRADE_GOLD})
    end
end

function TradeMediator:OnTraderItemChange(data)
    if not self._layer then
        return false
    end
    self._layer:UpdateItemList(data)
end

function TradeMediator:OnMyselfItemChange(data)
    if not self._layer then
        return false
    end
    self._layer:UpdateItemList(data)
end

function TradeMediator:RefreshTradeMoney(data)
    if not self._layer then
        return false
    end
    SLBridge:onLUAEvent(LUA_EVENT_TRADE_MONEY_CHANGE, data)
end

function TradeMediator:RefreshMyMoney(data)
    if not self._layer then
        return false
    end
    SL:onLUAEvent(LUA_EVENT_TRADE_MY_MONEY_CHANGE, data)
end

function TradeMediator:RefreshTradeStatus()
    if not self._layer then
        return false
    end
    SL:onLUAEvent(LUA_EVENT_TRADE_STATUS_CHANGE)
end

function TradeMediator:RefreshMyStatus()
    if not self._layer then
        return false
    end
    SL:onLUAEvent(LUA_EVENT_TRADE_MY_STATUS_CHANGE)
end

return TradeMediator
