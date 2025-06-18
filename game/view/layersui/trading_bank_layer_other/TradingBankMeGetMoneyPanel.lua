local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankMeGetMoneyPanel = class("TradingBankMeGetMoneyPanel", BaseLayer)

function TradingBankMeGetMoneyPanel:ctor()
    TradingBankMeGetMoneyPanel.super.ctor(self)
    self._otherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankMeGetMoneyPanel.create(...)
    local layer = TradingBankMeGetMoneyPanel.new()
    if layer:Init(...) then
        return layer
    end
    return nil
end

function TradingBankMeGetMoneyPanel:Init(data)
    GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_getmoney_panel")
    self._root = ui_delegate(self)
    self._data = data
    self:InitAdapt()
    self:InitUI()
    return true
end

function TradingBankMeGetMoneyPanel:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")

    GUI:setPosition(self._root.Panel_2, winSizeW / 2, winSizeH / 2)
end

function TradingBankMeGetMoneyPanel:InitUI()
    if self._data.isGetMoney then --提现
        self._root.Panel_apply:setVisible(true)
        self._root.Panel_record:setVisible(false)
        local Panel_apply_root = ui_delegate(self._root.Panel_apply)
        Panel_apply_root.TextField_money:setTouchEnabled(false)
        Panel_apply_root.TextField_money:setString("￥" .. (self._data.money or 0))
        Panel_apply_root.Text_jyb_count:setString(-self._data.money or 0)
        Panel_apply_root.Text_sxf_count:setString(self._data.charge or 0)
        Panel_apply_root.Text_dz_count:setString(self._data.getMoney or 0)
        Panel_apply_root.Text_sxf:setString(string.format(GET_STRING(600000189), self._data.Ratio or 0))
        Panel_apply_root.Text_record:setTouchEnabled(true)
        Panel_apply_root.Text_record:getVirtualRenderer():enableUnderline()
        Panel_apply_root.Text_record:addClickEventListener(function()
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankMeLayer_ShowGetMoneyRecord_other)
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankMeGetMoneyPanelLayer_Close_other)
        end)
    else--提现记录
        self._root.Panel_apply:setVisible(false)
        self._root.Panel_record:setVisible(true)
        local Panel_record_root = ui_delegate(self._root.Panel_record)
        local totalExtractMoney = self._data.totalExtractMoney or ""
        local extractChargeMoney = self._data.extractChargeMoney or ""
        local dzcount = self._data.extractMoney or ""
        local orderId = self._data.orderId or ""
        local paymentTime = os.date("%Y-%m-%d %H:%M:%S",self._data.paymentTime or os.time() ) 
        local createTime = os.date("%Y-%m-%d %H:%M:%S",self._data.createTime or os.time() )  
        local remark = self._data.remark or ""
        Panel_record_root.Text_money:setString((-totalExtractMoney) .. GET_STRING(600000459))
        --0审核中  1提现成功  2 提现失败  3 撤回提现
        local stateTxts = {
            GET_STRING(600000420),
            GET_STRING(600000421),
            GET_STRING(600000422),
            GET_STRING(600000449),
        }
        local stateIndex = self._data.status and self._data.status + 1 or 2
        Panel_record_root.Text_state:setString(stateTxts[stateIndex] or "")
        if self._data.status == 1 then
            self._root.Button_1:setVisible(false)
            Panel_record_root.Text_desc:setVisible(false)
            Panel_record_root.Text_desc_1:setVisible(false)
            Panel_record_root.Text_time_2:setPositionY(Panel_record_root.Text_desc:getPositionY())
        elseif self._data.status == 0 then
            GUI:Text_setTextColor(Panel_record_root.Text_state, "#FF0000")
            Panel_record_root.Text_desc:setVisible(false)
            Panel_record_root.Text_desc_1:setVisible(false)
            Panel_record_root.Text_time_2:setVisible(false)
            self._root.Button_1:setTitleText(GET_STRING(600000428))--撤销提现
        elseif self._data.status == 2 or self._data.status == 3 then
            GUI:Text_setTextColor(Panel_record_root.Text_state, "#FF0000")
            Panel_record_root.Text_time_2:setVisible(false)
            self._root.Button_1:setTitleText(GET_STRING(600000430))--重新提现
        end
        Panel_record_root.Text_sxf:setString(string.format(GET_STRING(600000423), extractChargeMoney))
        Panel_record_root.Text_dz:setString(string.format(GET_STRING(600000424), dzcount))
        Panel_record_root.Text_time:setString(string.format(GET_STRING(600000426), createTime))
        Panel_record_root.Text_time_2:setString(string.format(GET_STRING(600000431), paymentTime))
        GUI:Text_setMaxLineWidth(Panel_record_root.Text_desc_1, 285)
        Panel_record_root.Text_desc_1:setString(remark)
        Panel_record_root.Text_jydh_count:setString(orderId)
        GUI:Text_setMaxLineWidth(Panel_record_root.Text_jydh_count, 250)
    end

    self._root.Button_1:addClickEventListener(function()
        if self._data.isGetMoney then
            self._otherTradingBankProxy:doTrack(self._otherTradingBankProxy.UpLoadData.TraingGetMoneyLayerApplyBtnClick)
            self._otherTradingBankProxy:getExtractConfig(self, {}, function(code, data, msg)
                if code == 200 then
                    if data.placeType == 1 then --placeType 1游戏外  2游戏内
                         --弹出复制交易行官网链接 让玩家浏览器去交易
                         local params = {}
                         params.type = 1
                         params.btntext = {GET_STRING(10000962),GET_STRING(700000131)}
                         local url = self._otherTradingBankProxy:getAndroidWeb()
                         local platformText = string.gsub(GET_STRING(700000133), "jyh", url)
                         if SL:GetMetaValue("PLATFORM_IOS") then
                             url = self._otherTradingBankProxy:getIosWeb()
                             platformText = string.gsub(GET_STRING(700000132), "jyh", url)
                         end
                         params.text = platformText
                         params.titleImg = global.MMO.PATH_RES_PRIVATE .. "trading_bank_other/img_tips.png"
                         params.callback = function(res)
                             if res == 1 or res == 2 or res == 3 then
                                 if res == 2 then 
                                     SL:SetMetaValue("CLIPBOARD_TEXT", url)
                                     ShowSystemTips(GET_STRING(600000419))
                                     self._otherTradingBankProxy:doTrack(self._otherTradingBankProxy.UpLoadData.TraingCobyUrlBtnClick)
                                 end
                                 global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Close_other)
                             end
                         end
                         global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open_other, params)
                    else
                        local val = { account = self._data.account, money = self._data.money }
                        self._otherTradingBankProxy:reqExtractApplyFor(self, val, function(code2, data2, msg2)
                            if code2 == 200 then
                                if data2 then
                                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code3)
                                        if code3 == 3 or code3 == 1 or code3 == 0 then
                                        end
                                    end, title = "", notcancel = true, canmove = true, txt = GET_STRING(600000417), btntext = { GET_STRING(600000139) } })
                                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankMeGetMoneyPanelLayer_Close_other)
                                end
                            else
                                ShowSystemTips(msg2)
                            end
                        end)
                    end
                else
                    ShowSystemTips(msg)
                end
            end)
        else -- 提现记录
            --撤销提现
            if self._data.status == 0 then--0审核中
                local data = {}
                data.txt = GET_STRING(600000429)--是否撤销提现
                data.callback = function(res)
                    if res == 2 then
                        local val = { id = self._data.id }
                        self._otherTradingBankProxy:cancelExtractApplyFor(self, val, function(code, data, msg)

                            if code == 200 then
                                if data then--撤销成功
                                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankMeLayer_ShowGetMoneyRecord_other)
                                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankMeGetMoneyPanelLayer_Close_other)
                                end
                                ShowSystemTips(msg)
                            elseif code == 21005 then --提现已进入打款阶段，暂不支持撤销提现
                                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code)
                                    if code == 3 or code == 1 or code == 0 then

                                    end
                                end, title = "", notcancel = true, canmove = true, txt = msg or "", btntext = { GET_STRING(600000139) } })
                            else
                                ShowSystemTips(msg)
                            end
                        end)
                    end
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, data)
            elseif self._data.status == 2 or self._data.status == 3 then--2提现失败  3撤回提现
                self._otherTradingBankProxy:getExtractConfig(self, {}, function(code, data, msg)
                    if code == 200 then
                        if data.placeType == 1 then --placeType 1游戏外  2游戏内
                             --弹出复制交易行官网链接 让玩家浏览器去交易
                             local params = {}
                             params.type = 1
                             params.btntext = {GET_STRING(10000962),GET_STRING(700000131)}
                             local url = self._otherTradingBankProxy:getAndroidWeb()
                             local platformText = string.gsub(GET_STRING(700000133), "jyh", url)
                             if SL:GetMetaValue("PLATFORM_IOS") then
                                 url = self._otherTradingBankProxy:getIosWeb()
                                 platformText = string.gsub(GET_STRING(700000132), "jyh", url)
                             end
                             params.text = platformText
                             params.titleImg = global.MMO.PATH_RES_PRIVATE .. "trading_bank_other/img_tips.png"
                             params.callback = function(res)
                                 if res == 1 or res == 2 or res == 3 then
                                     if res == 2 then 
                                         SL:SetMetaValue("CLIPBOARD_TEXT", url)
                                         ShowSystemTips(GET_STRING(600000419))
                                         self._otherTradingBankProxy:doTrack(self._otherTradingBankProxy.UpLoadData.TraingCobyUrlBtnClick)
                                     end
                                     global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Close_other)
                                 end
                             end
                             global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open_other, params)
                        else
                            local val = { account = self._data.alipayAccount, money = self._data.totalExtractMoney }--重新提现
                            self._otherTradingBankProxy:reqExtractApplyFor(self, val, function(code2, data2, msg2)
                                if code2 == 200 then
                                    if data2 then
                                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code3)
                                            if code3 == 3 or code3 == 1 or code3 == 0 then
                                            end
                                        end, title = "", notcancel = true, canmove = true, txt = GET_STRING(600000417), btntext = { GET_STRING(600000139) } })
                                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankMeLayer_ShowGetMoneyRecord_other)
                                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankMeGetMoneyPanelLayer_Close_other)
                                    end
                                else
                                    ShowSystemTips(msg2)
                                end
                            end)
                        end
                    else
                        ShowSystemTips(msg)
                    end
                end)
            end
        end
    end)
    self._root.ButtonClose:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankMeGetMoneyPanelLayer_Close_other)
    end)
    self._root.Panel_cancel:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankMeGetMoneyPanelLayer_Close_other)
    end)

end

function TradingBankMeGetMoneyPanel:exitLayer()

    self._otherTradingBankProxy:removeLayer(self)
end

return TradingBankMeGetMoneyPanel