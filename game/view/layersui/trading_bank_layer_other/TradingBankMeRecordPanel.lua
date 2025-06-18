local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankMeRecordPanel = class("TradingBankMeRecordPanel", BaseLayer)
local OptState = {
    WaitPay = 1,
    PaySuccess = 3,
    PayOutTime = -1,
    Cancel = -2,--取消
    Back = -21, --退回
    AlReady = 31, --成功并已到账
    Wait = 32,--成功未到账
}

function TradingBankMeRecordPanel:ctor()
    TradingBankMeRecordPanel.super.ctor(self)
    self._otherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankMeRecordPanel.create(...)
    local layer = TradingBankMeRecordPanel.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function TradingBankMeRecordPanel:Init(data)
    dump(data, "TradingBankMeRecordPanel___")
    GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_tradingrecord_panel")
    self._root = ui_delegate(self)
    self._data = data
    self:InitAdapt()
    self:InitUI()
    return true
end

function TradingBankMeRecordPanel:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")

    GUI:setPosition(self._root.Panel_2, winSizeW / 2, winSizeH / 2)
end

function TradingBankMeRecordPanel:InitUI()
    if self._data.optRecord_type == 0 then --买的
        if self._data.status == OptState.WaitPay then --待支付
            self._root.Text_state:setString(GET_STRING(600000434))
        elseif self._data.status == OptState.PaySuccess then  --交易成功
            self._root.Text_state:setString(GET_STRING(600000435))
        elseif self._data.status == OptState.PayOutTime then --支付超时
            self._root.Text_state:setString(GET_STRING(600000436))
        elseif self._data.status == OptState.Back then --退回
            self._root.Text_state:setString(GET_STRING(600000479))
        elseif self._data.status == OptState.Cancel then --取消
            self._root.Text_state:setString(GET_STRING(600000480))
        end
        self._root.Text_desc:setVisible(false)

        self._root.Text_getmoney_text:setVisible(false)
        self._root.Text_will_getmoney_text:setVisible(false)
        self._root.Text_getmoney:setVisible(false)
        self._root.Text_will_getmoney:setVisible(false)

    else--卖的
        if self._data.status == OptState.Wait then --待入账
            self._root.Text_state:setString(GET_STRING(600000437))
        elseif self._data.status == OptState.AlReady then  --已入账
            self._root.Text_state:setString(GET_STRING(600000438))
        elseif self._data.status == OptState.Back then  --退回
            self._root.Text_getmoney_text:setVisible(false)
            self._root.Text_will_getmoney_text:setVisible(false)
            self._root.Text_getmoney:setVisible(false)
            self._root.Text_will_getmoney:setVisible(false)
            self._root.Text_state:setString(GET_STRING(600000479))
        end
        self._root.Text_getmoney:setString(self._data.commodityAmount or "")
        local showTime = string.format(GET_STRING(600000452), self._data.commodityAmount or "", os.date("%Y-%m-%d", tonumber(self._data.thawTime) or 0))
        self._root.Text_will_getmoney:setString(showTime)
    end
    local path = ""
    if self._data.commodityType == 1 then --角色
        local sex = self._data.sex or 0
        local jobid = self._data.roleConfigId or 0
        path = global.MMO.PATH_RES_PRIVATE .. "trading_bank/img_0" .. (sex + 1) .. (jobid + 1) .. ".png"
        self._root.Text_goodsname:setString(self._data.role or "(" .. GET_STRING(1067 + jobid) .. ")")
        self._root.Text_count:setString(self._data.roleLevel or "")
        self._root.Text_count_text:setString(GET_STRING(600000455))
        self._root.Text_goods_type:setString(GET_STRING(600000001))
    else
        path = global.MMO.PATH_RES_PRIVATE .. "trading_bank/img_cost.png"
        self._root.Text_goodsname:setString(self._data.coinConfigTypeName or "")
        self._root.Text_count:setString(self._data.commodityQty or "")
        self._root.Text_goods_type:setString(GET_STRING(600000002))
    end
    self._root.Image_head:loadTexture(path)
    self._root.Text_money:setString("￥" .. (self._data.totalAmount or ""))
    self._root.Text_server:setString(self._data.serverName or "")
    self._root.Text_goods_num:setString(self._data.commodityId or "")
    self._root.Text_goods_price:setString(self._data.totalAmount or "")
    self._root.Text_goods_count:setString("x1")
    self._root.Text_real_money:setString(self._data.totalAmount or "")


    self._root.Text_order:setString(self._data.orderNum or "")--订单
    self._root.Text_time:setString(os.date("%Y-%m-%d %H:%M:%S", self._data.createTime or os.time()))--订单时间
    self._root.Button_1:addClickEventListener(function()
        SL:SetMetaValue("CLIPBOARD_TEXT", tostring(self._data.orderNum or ""))
        ShowSystemTips(GET_STRING(600000419))
    end)
    self._root.ButtonClose:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankMeRecordPanelLayer_Close_other)
    end)

    self._root.Panel_cancel:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankMeRecordPanelLayer_Close_other)
    end)

end

function TradingBankMeRecordPanel:exitLayer()

    self._otherTradingBankProxy:removeLayer(self)
end

return TradingBankMeRecordPanel