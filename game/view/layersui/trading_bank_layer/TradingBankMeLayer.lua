local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankMeLayer = class("TradingBankMeLayer", BaseLayer)
local cjson = require("cjson")
function TradingBankMeLayer:ctor()
    TradingBankMeLayer.super.ctor(self)
    self.TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
end

function TradingBankMeLayer.create(...)
    local ui = TradingBankMeLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end
function TradingBankMeLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_me")
    self._root = ui_delegate(self)
    self._ui = self._root
    self:InitUI()

    local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingMyTabClick)
    return true
end
function TradingBankMeLayer:InitUI(data)
    self._ui.Button_tips:setVisible(false)
    self._ui.Text_tips:setVisible(false)
    self._ui.Panel_show:setVisible(false)

    if global.isWinPlayMode then
        self._ui.Text_2:setString(GET_STRING(600000010))
    else
        self._ui.Text_2:setString(GET_STRING(600000011))
    end

    --跳转盒子
    self._ui.Button_3:addTouchEventListener(function(sender, type)
        if type ~= 2 then
            return
        end
        -- local hzurl = ""
        -- if  global.isWinPlayMode then
        --     hzurl = "http://www.996box.com/downloads"
        -- else
        --     hzurl = "http://land.996box.com/mobilepage/index.html"
        -- end
        -- cc.Application:getInstance():openURL(hzurl)

        local Box996Proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
        Box996Proxy:getBox996DownloadURL(5)
        Box996Proxy:requestLogUp(Box996Proxy.OTHER_UP_EVEIT[105])

        local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
        TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingGetMoneyClick)

    end)
    --help
    self._ui.Button_4:addTouchEventListener(function(sender, type)
        if type ~= 2 then
            return
        end
        self.TradingBankProxy:reqTradeCoinHelpText(self, {}, function(help)
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, { callback = function(code)
                if code == 3 or code == 1 or code == 0 then
                    dump("提示退出")
                end
            end, title = help.title, notcancel = true, canmove = true, txt = help.data, btntext = { GET_STRING(600000139) } })
        end)
    end)
    self._ui.Button_tips:addTouchEventListener(function(sender, type)
        if type ~= 2 then
            return
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open, {
            callback = function(code)
                if code == 1 then
                    self:reqUserMoney()
                end
            end
        })
    end)
    self:reqUserMoney()
end
function TradingBankMeLayer:reqUserMoney()
    dump("TradingBankMeLayer:reqUserMoney_____")
    self.TradingBankProxy:reqUserMoney(self, {}, function(success, response, code)
        dump({ success, response, code }, "reqUserMoney___")
        if success then
            local data = cjson.decode(response)
            if data.code == 200 then
                data = data.data
                local trade_coin = data.trade_coin
                local frozen_money = data.frozen_money
                -- local balance1 = data.balance
                -- local gold = self._root.Panel_pay4:getChildByName("Text_1")
                self._ui.Text_me:setString(tonumber(trade_coin) / 100)
                self._ui.Text_wait:setString(tonumber(frozen_money) / 100)
                self._ui.Button_tips:setVisible(false)
                self._ui.Text_tips:setVisible(false)
                self._ui.Panel_show:setVisible(true)
            elseif data.code >= 50000 and data.code <= 50020 then--token失效
                self._ui.Button_tips:setVisible(true)
                self._ui.Text_tips:setVisible(true)
                self._ui.Panel_show:setVisible(false)
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open, { callback = function(code)
                    if code == 1 then
                        self:reqUserMoney()
                    else
                        -- global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankGoodsLayer_Close)
                    end
                end })
            else
                global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg or "")
            end

        else
            -- global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING())
        end
    end)
end
function TradingBankMeLayer:exitLayer()
    self.TradingBankProxy:removeLayer(self)
end

return TradingBankMeLayer