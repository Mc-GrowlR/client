local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankWaitPayPanel = class("TradingBankWaitPayPanel", BaseLayer)
local CommodityType = {
    Role = 1,
    Money = 2,
}
function TradingBankWaitPayPanel:ctor()
    TradingBankWaitPayPanel.super.ctor(self)
    self._otherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankWaitPayPanel.create(...)
    local layer = TradingBankWaitPayPanel.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function TradingBankWaitPayPanel:Init(data)
    dump(data, "TradingBankWaitPayPanel___")
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_wait_pay_panel")
    self._root = ui_delegate(self)
    self._data = data.data
    self._callback = data.callback
    self:InitAdapt()
    self:InitUI()
    return true
end

function TradingBankWaitPayPanel:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")

    GUI:setPosition(self._root.Panel_2, winSizeW / 2, winSizeH / 2)
end

function TradingBankWaitPayPanel:InitUI()
    local path = ""
    if self._data.commodityType == CommodityType.Role then --角色
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
    ------------- 订单支付时间
    local expireTime = tonumber(self._data.expireTime) or GetServerTime()
    local time = math.max(expireTime - GetServerTime(), 0)
    local getTimeStr = function (s)
        return string.format("%.2d:%.2d", s/60, s%60)
    end
    self._root.Text_state:stopAllActions()
    local refTimeLabel = function ()
        time = math.max(expireTime - GetServerTime(), 0)
        self._root.Text_state:setString(string.format(GET_STRING(600000664),getTimeStr(time)) )
        if time <= 0 then
            self._root.Text_state:setString(GET_STRING(600000436))
            self._root.Text_state:stopAllActions()
            GUI:Text_setTextColor(self._root.Text_state, "#FF0000")
        end
    end
    --为了跟交易记录定时器同步。。。。
    self._data.asyTable.schedule = function ()
        refTimeLabel()
        schedule(self._root.Text_state, function(sender)
            refTimeLabel()
        end, 1)
    end
    
    refTimeLabel()
    -------------
    self._root.Text_order:setString(self._data.orderNum or "")--订单
    self._root.Text_time:setString(os.date("%Y-%m-%d %H:%M:%S", self._data.createTime or os.time()))--订单时间
    self._root.Button_1:addClickEventListener(function()
        SL:SetMetaValue("CLIPBOARD_TEXT", tostring(self._data.orderNum or ""))
        ShowSystemTips(GET_STRING(600000419))
    end)
    self._root.ButtonClose:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankWaitPayPanelLayer_Close_other)
    end)

    self._root.Panel_cancel:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankWaitPayPanelLayer_Close_other)
    end)
    --取消订单
    self._root.Button_cancelOrder:addClickEventListener(function()
        self._otherTradingBankProxy:reqCancelorder(self, { order_id = self._data.id }, handler(self, self.ResCancelorder))
    end)
    --去支付
    self._root.Button_Pay:addClickEventListener(function()
        local platform = global.isAndroid and "game_ad" or "game_ios"
        if global.isWindows then
            platform = "game_pc"
        end
        local params = {
            type = 2,
            payinfo = {
                order_id = self._data.id,
                channel = "ALIPAY",
                client_type = platform,
                price = self._data.totalAmount
            }
        }
        
        params.callback = function()
            if self._data.commodityType == CommodityType.Role then --角色
                local val = {}
                val.txt = GET_STRING(600000192)--
                val.btntext = { GET_STRING(600000139), GET_STRING(600000193) }
                val.callback = function(res)
                    if res == 1 then
                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankWaitPayPanelLayer_Close_other)
                    elseif res == 2 then
                        global.gameWorldController:OnGameLeaveWorld()
                    end
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, val)
            else
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankWaitPayPanelLayer_Close_other)
            end
        end
        
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPowerfulLayer_Open_other, params)
    end)

end

function TradingBankWaitPayPanel:ResCancelorder(code, data, msg)
    dump({ code, data, msg }, "resCancelorder___")
    ShowSystemTips(msg)
    if code == 200 then
        if self._callback then
            self._callback()
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankWaitPayPanelLayer_Close_other)
    end
end

function TradingBankWaitPayPanel:ExitLayer()
    self._otherTradingBankProxy:removeLayer(self)
end

return TradingBankWaitPayPanel