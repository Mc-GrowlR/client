local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankMeLayer = class("TradingBankMeLayer", BaseLayer)
local cjson = require("cjson")
local QuickCell = requireUtil("QuickCell")
local utf8 = require("util/utf8")
local OptState = {
    WaitPay = 1,
    PaySuccess = 3,
    PayOutTime = -1,
    Cancel = -2,--取消
    Back = -21, --退回
    AlReady = 31, --成功并已到账
    Wait = 32,--成功未到账
}

local CommodityType = {
    Role = 1,
    Money = 2,
}

function TradingBankMeLayer:ctor()
    TradingBankMeLayer.super.ctor(self)
    self._otherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankMeLayer.create(...)
    local ui = TradingBankMeLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end
function TradingBankMeLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_me")
    self._root = ui_delegate(self)
    self._ui = self._root
    self._root.Panel_1:setVisible(false)
    self:InitUI()
    ------------------------
    self:ShowBase()
    return true
end

--请求玩家余额
function TradingBankMeLayer:ReqUserMoneyBalance()
    self._otherTradingBankProxy:getUserMoneyBalance(self, {}, function(code, val, msg)
        local tradeCoin = val.tradeCoin or 0
        self._panelShowRoot.Text_me:setString(tradeCoin) --我的交易币
        self._panelShowRoot.Text_wait:setString(val.frozenMoney or 0) --待入账交易币
        self._panelShowRoot.Button_getMoney:setEnabled(tradeCoin > 0)
        if tradeCoin > 0 then 
            Shader_Normal(self._panelShowRoot.Button_getMoney)
        else
            Shader_Grey(self._panelShowRoot.Button_getMoney)
        end
    end)
end

function TradingBankMeLayer:InitUI(data)
    self._ui.Panel_show:setVisible(false)
    self._ui.Panel_getMomey:setVisible(false)
    self._ui.Panel_info:setVisible(false)
    self._ui.Panel_getMoney_record:setVisible(false)
    self._ui.Panel_opt_record:setVisible(false)
    self._ui.Panel_help_center:setVisible(false)
    ----------------------------base show 
    self:InitBaseUI()
    ----------------------------提现
    self:InitGetMoneyUI()
    ----------------------------实名
    self:InitInfoUI()
    ----------------------------购买记录
    self:InitOptRecordUI()
    ----------------------------提现记录
    self:InitGetMoneyRecordUI()
    ----------------------------帮助中心
    self:InitHelpCenterUI()
    ----------------------------求购记录
    self:InitReqBuyRecordUI()
end

function TradingBankMeLayer:HideAllUI()
    self._ui.Panel_show:setVisible(false)
    self._ui.Panel_getMomey:setVisible(false)
    self._ui.Panel_info:setVisible(false)
    self._ui.Panel_getMoney_record:setVisible(false)
    self._ui.Panel_opt_record:setVisible(false)
    self._ui.Panel_help_center:setVisible(false)
    self._ui.Panel_reqBuy_record:setVisible(false)
end

function TradingBankMeLayer:InitBaseUI()
    self._panelShowRoot = ui_delegate(self._ui.Panel_show)
    self._panelShowRoot.Text_me:setString(0) --我的交易币
    self._panelShowRoot.Text_wait:setString(0) --待入账交易币
    self._panelShowRoot.Button_getMoney:setEnabled(false)
    Shader_Grey(self._panelShowRoot.Button_getMoney)
    --提现
    self._panelShowRoot.Button_getMoney:addClickEventListener(function(sender, type)
        self._otherTradingBankProxy:doTrack(self._otherTradingBankProxy.UpLoadData.TraingMeLayerGetMoneyBtnClick)
        self._otherTradingBankProxy:checkAuthentication(self,function(code, data, msg)
            dump({code, data, msg}, "实名认证")
            if code == 200 then
                if data then
                    self._otherTradingBankProxy:getExtractConfig(self, {}, function(code2, data2, msg2)
                        if code2 == 200 then
                            dump(data2, "配置信息")
                            if data2.placeType == 1 then --placeType 1游戏外  2游戏内
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
                                self._otherTradingBankProxy:getExtractAccountInfo(self, {}, function(code3, AccountInfo, msg3)
                                    if code3 == 200 then
                                        if AccountInfo.lastRecord then --有提现单子
                                            -- extractApplyId
                                            local tipsData = {
                                                title = "",
                                                notcancel = true,
                                                canmove = true,
                                                txt = GET_STRING(600000450),
                                                btntext = { GET_STRING(600000451), GET_STRING(600000170) },
                                                callback = function(res)
                                                    if res == 1 then
                                                        self._otherTradingBankProxy:reqExtractRecordDetails(self, { id = AccountInfo.extractApplyId or 1 }, function(code4, Details, msg4)
                                                            if code4 == 200 then
                                                                Details.account = "AUTO_FILL"
                                                                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankMeGetMoneyPanelLayer_Open_other, Details)
                                                            else
                                                                ShowSystemTips(msg4)
                                                            end
                                                        end)
                                                    end
                                                end
                                            }
                                            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, tipsData)
                                        else
                                            self:ShowGetMoney()
                                        end
                                    else
                                        ShowSystemTips(msg3)
                                    end
                        
                                end)
                            end
                        else
                            ShowSystemTips(msg2)
                        end
                    end)
                else
                    local params = {}
                    params.type = 1
                    params.btntext = {GET_STRING(600000653),GET_STRING(600000654)}
                    params.text = GET_STRING(600000655)
                    params.titleImg = global.MMO.PATH_RES_PRIVATE .. "trading_bank_other/img_tips.png"
                    params.callback = function(res)
                        if res == 1 or res == 2 or res == 3 then
                            if res == 2 then 
                                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBindIdentityLayer_Open_other)
                            end
                            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Close_other)
                        end
                    end
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open_other, params)

                    
                    
                end
            end
        end)
    end)
    --复制唯一码
    self._panelShowRoot.Button_copy:addClickEventListener(function(sender, type)
        local OnlyOneID = self._otherTradingBankProxy:getOnlyOneID()
        if OnlyOneID then
            SL:SetMetaValue("CLIPBOARD_TEXT", tostring(OnlyOneID))
            ShowSystemTips(GET_STRING(600000419))
        else
            self._otherTradingBankProxy:getTradeId(self, {}, function(code, data, msg)
                if code == 200 then
                    self._otherTradingBankProxy:setOnlyOneID(data or 0)
                    SL:SetMetaValue("CLIPBOARD_TEXT", tostring(data or 0))
                    ShowSystemTips(GET_STRING(600000419))
                else
                    ShowSystemTips(msg)
                end
            end)
        end
    end)
    --实名
    self._panelShowRoot.Button_identity:addClickEventListener(function(sender, type)
        --检测绑定手机
        self._otherTradingBankProxy:checkBindPhone(self,{}, function (code, data, msg)
            if code  == 200 then 
                if data then
                    --检测实名
                    self._otherTradingBankProxy:checkAuthentication(self,function(code, data, msg)
                        dump({code, data, msg}, "实名认证")
                        if code == 200 then
                            if data then 
                                self:ShowInfo()
                            else
                                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBindIdentityLayer_Open_other)
                            end
                        else 
                            ShowSystemTips(msg or "")
                        end
                    end)
                else 
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open_other)
                end
            else 
                ShowSystemTips(msg or "")
            end
        end) 
        
        
    end)

    --提现记录
    self._panelShowRoot.Button_extract_record:addClickEventListener(function(sender, type)
        self:ShowGetMoneyRecord()
    end)

    --购买记录
    self._panelShowRoot.Button_buy_record:addClickEventListener(function(sender, type)
        self:ShowOptRecord()
    end)
    --待入账交易币说明
    self._panelShowRoot.Text_desc:setTouchEnabled(true)
    self._panelShowRoot.Text_desc:getVirtualRenderer():enableUnderline()
    self._panelShowRoot.Text_desc:addClickEventListener(function(sender, type)
        self._otherTradingBankProxy:getExtractConfig(self, {}, function(code, data, msg)
            if code == 200 then
                dump(data, "配置信息")
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code)
                    if code == 3 or code == 1 or code == 0 then
                        dump("提示退出")
                    end
                end, title = "", notcancel = true, canmove = true, txt = data.explain or "", btntext = { GET_STRING(600000139) } })
            else
                ShowSystemTips(msg)
            end
        end)
    end)
    --唯一码说明
    self._panelShowRoot.Text_desc_1:setTouchEnabled(true)
    self._panelShowRoot.Text_desc_1:getVirtualRenderer():enableUnderline()
    self._panelShowRoot.Text_desc_1:addClickEventListener(function(sender, type)
        self._otherTradingBankProxy:reqHelpText(self, { type = 3 }, function(help)
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code)
                if code == 3 or code == 1 or code == 0 then
                    dump("提示退出")
                end
            end, title = help.title, notcancel = true, canmove = true, txt = help.data, btntext = { GET_STRING(600000139) } })
        end)
    end)
    --意见反馈
    self._panelShowRoot.Button_suggest:addClickEventListener(function(sender, type)
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankSuggestPanelLayer_Open_other)
    end)
    --帮助
    self._panelShowRoot.Button_help:addClickEventListener(function(sender, type)
        self:ShowHelpCenter()
    end)
    --绑定手机
    self._panelShowRoot.Button_bindPhone:addClickEventListener(function(sender, type)
        --检测绑定手机
        self._otherTradingBankProxy:checkBindPhone(self,{}, function (code, data, msg)
            if code  == 200 then 
                if data then
                    local phone = self._otherTradingBankProxy:getMobile() or ""
                    local params = {}
                    params.type = 1
                    params.btntext = GET_STRING(600000139)
                    params.text =  string.format(GET_STRING(600000656), phone) 
                    params.titleImg = global.MMO.PATH_RES_PRIVATE .. "trading_bank_other/img_tips.png"
                    params.callback = function(res)
                        if res == 1 then
                            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Close_other)
                        end
                    end
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open_other, params)
                else 
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open_other)
                end
            end
        end) 
    end)
    --求购记录
    self._panelShowRoot.Button_reqBuy_record:addClickEventListener(function(sender, type)
        self._otherTradingBankProxy:doTrack(self._otherTradingBankProxy.UpLoadData.TraingMeLayerReqBuyRecordBtnClick)
        self:ShowReqBuyRecord()
    end)
    ---id
    local userData = self._otherTradingBankProxy:getUserData()
    if userData then
        local jid = userData.jid or ""
        self._panelShowRoot.Text_ID:setString("ID: ".. jid)
        self._panelShowRoot.Text_ID._jid = jid
    else
        self._otherTradingBankProxy:reqUserData(self, function(code, data, msg)
            if code == 200 then
                self._otherTradingBankProxy:setUserData(data)
                local jid = data.jid or ""
                self._panelShowRoot.Text_ID:setString("ID: ".. jid)
                self._panelShowRoot.Text_ID._jid = jid
            else
                ShowSystemTips(msg)
            end
        end)
    end
    --复制id
    self._panelShowRoot.Button_copy_ID:addClickEventListener(function(sender, type)
        local jid = self._panelShowRoot.Text_ID._jid
        if jid then
            SL:SetMetaValue("CLIPBOARD_TEXT", tostring(jid))
            ShowSystemTips(GET_STRING(600000419))
        else
            ShowSystemTips(GET_STRING(600000852))
        end
    end)
    --交易行客服
    self._panelShowRoot.Button_KeFu:addClickEventListener(function(sender, type)
        local kefuUrl = self._otherTradingBankProxy:getKeFuWxUrl()
        cc.Application:getInstance():openURL(kefuUrl)
    end)
end

function TradingBankMeLayer:ShowBase()
    self:HideAllUI()
    self._ui.Panel_1:setVisible(true)
    self._ui.Panel_show:setVisible(true)

    --红点
    self._panelShowRoot.Image_redPoint:setVisible(false)
    self._otherTradingBankProxy:getExtractRedPoint(self, {}, function(code, data, msg)
        if code == 200 then
            if data then
                self._panelShowRoot.Image_redPoint:setVisible(true)
            end
        else
            ShowSystemTips(msg)
        end
    end)

    self:ReqUserMoneyBalance()
end
---------------------------------------------------------------提现
function TradingBankMeLayer:InitGetMoneyUI()
    self._panelGetMomeyRoot = ui_delegate(self._ui.Panel_getMomey)
    self._otherTradingBankProxy:cancelEmpty(self._panelGetMomeyRoot.Input_getMoney)
    GUI:TextInput_setInputMode(self._panelGetMomeyRoot.Input_getMoney, 2)
    self._panelGetMomeyRoot.Button_extract_record:addClickEventListener(function(sender, type)--提现记录
        self._isGetMoneyViewInToRecord = true
        self:ShowGetMoneyRecord()
    end)

    self._panelGetMomeyRoot.Button_back:addClickEventListener(function(sender, type)--返回
        self:ShowBase()
    end)
    self._panelGetMomeyRoot.Text_getAll:setTouchEnabled(true)
    self._panelGetMomeyRoot.Text_getAll:addClickEventListener(function(sender, type)--全部提现
        self._panelGetMomeyRoot.Input_getMoney:setString(self._panelGetMomeyRoot.Text_money._money or 0)
    end)

    self._panelGetMomeyRoot.Button_help:addClickEventListener(function(sender, type)--? 待入账说明
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code)
            if code == 3 or code == 1 or code == 0 then
                dump("提示退出")
            end
        end, title = "", notcancel = true, canmove = true, txt = self._panelGetMomeyRoot.Button_help.explain or "", btntext = { GET_STRING(600000139) } })
    end)
    self._panelGetMomeyRoot.Input_getMoney:onEditHandler(function(event)
        if event.name == "changed" then
            local s = event.target:getString()
            s = string.gsub(s, "%s", "")
            s = string.gsub(s, "[^%.%d]", "")
            if not self:IsGoodNumber(s) then
                return
            end
            local snum = s
            local dotIndex = string.find(s, "%.")
            if dotIndex then
                local sLen = #s
                if dotIndex == sLen then
                    snum = s .. "0"
                elseif dotIndex + 2 < sLen then --只有两位小数
                    snum = string.sub(s, 1, dotIndex + 2)
                    s = snum
                end
            end
            snum = tonumber(snum)
            local money = tonumber(self._panelGetMomeyRoot.Text_money._money) or 0
            if snum >= money then
                s = money
            end
            event.target:setString(s or "")
        end
    end)
    self._panelGetMomeyRoot.Text_account:onEditHandler(function(event)
        if event.name == "changed" then
            self._panelGetMomeyRoot.Text_account._isBind = false
        end
    end)
    self._panelGetMomeyRoot.Button_getMoney:addClickEventListener(function(sender, type)--提现
        local money = self._panelGetMomeyRoot.Input_getMoney:getString()
        local moneyNum = tonumber(money)
        if not money or string.len(money) <= 0 or not moneyNum or moneyNum <= 0 then
            ShowSystemTips(GET_STRING(600000443))
            return
        end
        local account = self._panelGetMomeyRoot.Text_account:getString()
        if self._panelGetMomeyRoot.Text_account._isBind then 
            account = "AUTO_FILL"
        else
            if not account or string.len(account) <= 0 then
                ShowSystemTips(GET_STRING(600000444))
                return
            end
        end
        local minRatio = self._panelGetMomeyRoot.Text_tips_sxf.minRatio
        local minCharge = self._panelGetMomeyRoot.Text_tips_sxf.minCharge
        local realcharge = tonumber(string.format("%.2f", minRatio * money / 100)) or 0
        local charge = math.max(realcharge, minCharge)

        local params = {
            isGetMoney = true,
            money = money,
            Ratio = minRatio,
            charge = charge,
            getMoney = money - charge,
            account = account
        }
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankMeGetMoneyPanelLayer_Open_other, params)
    end)

    self._panelGetMomeyRoot.Panel_agreement:setVisible(false)--合作协议 先不要
    -- self._panelGetMomeyRoot.CheckBox:setSelected(self:getAgreement())
    -- self._panelGetMomeyRoot.Panel_agreement:addClickEventListener(function(sender, type)--协议
    --     self._panelGetMomeyRoot.CheckBox:setSelected(not self._panelGetMomeyRoot.CheckBox:isSelected())
    --     self:SaveAgreement()
    -- end)
    -- self._panelGetMomeyRoot.Text_agreement:addClickEventListener(function(sender, type)--合作协议
    -- self._otherTradingBankProxy:reqHelpText(self, {type = 4}, function(help)
    --     global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code)
    --         if code == 3 or code == 1 or code == 0 then
    --             dump("提示退出")
    --         end
    --     end, title = help.title, notcancel = true, canmove = true, txt = help.data, btntext = { GET_STRING(600000139) } })
    -- end)
    --end)
end

function TradingBankMeLayer:SaveAgreement()
    local loginProxy    = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local mainPlayerID = loginProxy:GetSelectedRoleID()
    local path    = "TradingBank" .. mainPlayerID
    local key    = "GetMoneyAgreement"
    local userData = UserData:new(path)

    local writeData = { agree = self._panelGetMomeyRoot.CheckBox:isSelected() and 1 or 0 }
    local jsonStr = cjson.encode(writeData)
    userData:setStringForKey(key, jsonStr)
end

function TradingBankMeLayer:getAgreement()
    local loginProxy    = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local mainPlayerID = loginProxy:GetSelectedRoleID()
    local path    = "TradingBank" .. mainPlayerID
    local key    = "GetMoneyAgreement"
    local userData = UserData:new(path)
    local jsonStr = userData:getStringForKey(key, "")
    if not jsonStr or string.len(jsonStr) == 0 then
        return false
    end

    local jsonData = cjson.decode(jsonStr)
    if not jsonData then
        return false
    end
    return jsonData.agree == 1
end

function TradingBankMeLayer:ShowGetMoney(isback)
    self:HideAllUI()
    self._ui.Panel_getMomey:setVisible(true)
    -----------------
    if not isback then
        self._panelGetMomeyRoot.Text_name:setString("")
        self._panelGetMomeyRoot.Text_account:setString("") --支付宝账号
        self._panelGetMomeyRoot.Text_mindesc:setString("")--
        self._panelGetMomeyRoot.Text_tips_sxf:setString("")--string.format(GET_STRING(600000413),10)
        self._panelGetMomeyRoot.Text_money._money = 0
        self._panelGetMomeyRoot.Text_money:setString(0)
        self._panelGetMomeyRoot.img_red:setVisible(false)
        self._panelGetMomeyRoot.Input_getMoney:setString("")
        -- self._panelGetMomeyRoot.Button_getMoney:setEnabled(false)
    end
    --账号信息
    self._otherTradingBankProxy:getExtractAccountInfo(self, {}, function(code, data, msg)
        if code == 200 then
            self._panelGetMomeyRoot.Text_name:setString(data.realName or "")
            if data.alipayAccount and string.len(data.alipayAccount) > 0 then
                self._panelGetMomeyRoot.Text_account:setString(data.alipayAccount) --支付宝账号
                -- self._panelGetMomeyRoot.Text_account:setTouchEnabled(false)
                self._panelGetMomeyRoot.Text_account._isBind = true
            end
            self._panelGetMomeyRoot.Text_money:setString(data.money or 0) --
            self._panelGetMomeyRoot.Text_money._money = data.money or 0
        else
            ShowSystemTips(msg)
        end
    end)
    --配置信息
    self._otherTradingBankProxy:getExtractConfig(self, {}, function(code, data, msg)
        if code == 200 then
            dump(data, "配置信息")
            self._panelGetMomeyRoot.Text_mindesc:setString(string.format(GET_STRING(600000413), data.minMoney or 0))
            self._panelGetMomeyRoot.Text_tips_sxf:setString(string.format(GET_STRING(600000415), data.minRatio or 0, data.minCharge or 0))
            self._panelGetMomeyRoot.Text_tips_sxf.minRatio = data.minRatio
            self._panelGetMomeyRoot.Text_tips_sxf.minCharge = data.minCharge
            self._panelGetMomeyRoot.Button_help.explain = data.explain
            
        else
            ShowSystemTips(msg)
        end
    end)
    --红点
    self._otherTradingBankProxy:getExtractRedPoint(self, {}, function(code, data, msg)
        if code == 200 then
            if data then
                self._panelGetMomeyRoot.img_red:setVisible(true)
            end
        else
            ShowSystemTips(msg)
        end
    end)

end
-----------------------------------------------------实名
function TradingBankMeLayer:InitInfoUI()
    self._panelInfoRoot = ui_delegate(self._ui.Panel_info)
    self._panelInfoRoot.Text_name:setString("")
    self._panelInfoRoot.Text_code:setString("")
    self._panelInfoRoot.Button_back:addClickEventListener(function(sender, type)--返回
        self:ShowBase()
    end)
end
function TradingBankMeLayer:ShowInfo()
    self:HideAllUI()
    self._ui.Panel_info:setVisible(true)
    local userData = self._otherTradingBankProxy:getUserData()
    if userData then
        local realName = userData.realName or ""
        local idcard = userData.idcard or ""
        --后台脱敏
        GUI:Text_setString(self._panelInfoRoot.Text_name, realName)
        GUI:Text_setString(self._panelInfoRoot.Text_code, idcard)
    else
        self._otherTradingBankProxy:reqUserData(self, function(code, data, msg)
            if code == 200 then
                self._otherTradingBankProxy:setUserData(data)

                local realName = data.realName or ""
                local idcard = data.idcard or ""
                --后台脱敏
                GUI:Text_setString(self._panelInfoRoot.Text_name, realName)
                GUI:Text_setString(self._panelInfoRoot.Text_code, idcard)
            else
                ShowSystemTips(msg)
            end

        end)
    end
end

----------------------------------------------------------------购买记录
function TradingBankMeLayer:InitOptRecordUI()
    self._panelOptRecordRoot = ui_delegate(self._ui.Panel_opt_record)
    self._panelOptRecordRoot.Button_back:addClickEventListener(function(sender, type)--返回
        self:ShowBase()
    end)
    self._panelOptRecordRoot.Panel_item:setVisible(false)
    self._panelOptRecordRoot.Button_buy_record:addClickEventListener(function(sender, type)--买的记录
        self._optRecordType = 0 --0已购买 1已卖出
        self:InitOptRecord()
    end)
    self._panelOptRecordRoot.Button_sell_record:addClickEventListener(function(sender, type)--卖的记录
        self._optRecordType = 1 --0已购买 1已卖出
        self:InitOptRecord()
    end)
    self._panelOptRecordRoot.ListView:addScrollViewEventListener(function(sender, event)
        local itemnum = #sender:getItems()
        local Bottomitem = sender:getBottommostItemInCurrentView()
        local lastitem = sender:getItem(itemnum - 1)
        if (event == 1 or (event == 10 and lastitem == Bottomitem)) and self._optRecordPage < self._optRecordAllpage and not self._optRecordReqState then
            local params = {
                page = self._optRecordPage + 1,
                pagenum = self._optRecordNum,
                type = self._optRecordType
            }
            self:ReqOptRecord(params)
        end
    end)
end

function TradingBankMeLayer:ShowOptRecord()
    self:HideAllUI()
    self._ui.Panel_opt_record:setVisible(true)
    self._optRecordType = 0 --0已购买 1已卖出
    self:InitOptRecord()
end
function TradingBankMeLayer:InitOptRecord()--
    self._optRecordPage = 1
    self._optRecordNum = 10
    self._optRecordAllpage = 1
    self._panelOptRecordRoot.Button_buy_record:setEnabled(self._optRecordType ~= 0)
    self._panelOptRecordRoot.Button_sell_record:setEnabled(self._optRecordType ~= 1)
    self._panelOptRecordRoot.ListView:removeAllChildren()
    local params = {
        page = self._optRecordPage,
        pagenum = self._optRecordNum,
        type = self._optRecordType,
    }
    self:ReqOptRecord(params)
end
--type  0已购买 1已卖出
function TradingBankMeLayer:ReqOptRecord(params)--
    self._optRecordReqState = true
    self._otherTradingBankProxy:getFinishOrderList(self, params, function(code, data, msg)
        self._optRecordReqState = false
        if code == 200 then
            self._optRecordPage = tonumber(data.current or 1)
            self._optRecordNum = tonumber(data.size or 10)
            self._optRecordAllpage = tonumber(data.total or 1)
            self:CreateOptRecords(data.records or {})
        else
            ShowSystemTips(msg)
        end

    end)
end

function TradingBankMeLayer:CreateOptRecords(data)
    dump(data, "createOptRecords___")
    local lastIndex = #self._panelOptRecordRoot.ListView:getItems() - 1
    for i, v in ipairs(data) do
        local itemSize = self._panelOptRecordRoot.Panel_item:getContentSize()
        local cell_data = {}
        cell_data.wid = itemSize.width
        cell_data.hei = itemSize.height
        -- cell_data.anchor = cc.p(0.5, 1)
        cell_data.tick_interval = 0.05
        cell_data.createCell = function()
            local cell = self:CreateOptRecordItem(v)
            return cell
        end
        local item = QuickCell:Create(cell_data)
        item.page = self._optRecordPage
        self._panelOptRecordRoot.ListView:pushBackCustomItem(item)
    end
    self._panelOptRecordRoot.ListView:jumpToItem(lastIndex, cc.p(0, 0), cc.p(0, 0))
end

function TradingBankMeLayer:CreateOptRecordItem(data)
    local item = self._panelOptRecordRoot.Panel_item:clone()
    item:setVisible(true)
    item._data = data
    local item_root = ui_delegate(item)
    item_root.Text_time:setString(os.date("%Y-%m-%d %H:%M:%S", data.createTime or os.time()))
    local path = ""
    if data.commodityType == CommodityType.Role then --角色
        local sex = data.sex or 0
        local jobid = data.roleConfigId or 0
        path = global.MMO.PATH_RES_PRIVATE .. "trading_bank/img_0" .. (sex + 1) .. (jobid + 1) .. ".png"
        item_root.Text_name:setString(data.role or "")
        item_root.Text_job:setString("(" .. GET_STRING(1067 + jobid) .. ")")
        item_root.Text_countOrlevel:setString(string.format(GET_STRING(600000433)))
        item_root.Text_countOrlevel_num:setString(data.roleLevel or "")
        local nameX = item_root.Text_name:getPositionX()
        local nameSize = item_root.Text_name:getContentSize()
        item_root.Text_job:setPositionX(nameX + nameSize.width + 5)
        local jobX = item_root.Text_job:getPositionX()
        local jobSize = item_root.Text_job:getContentSize()
        item_root.Text_countOrlevel:setPositionX(jobX + jobSize.width + 10)
        local countX = item_root.Text_countOrlevel:getPositionX()
        local countSize = item_root.Text_countOrlevel:getContentSize()
        item_root.Text_countOrlevel_num:setPositionX(countX + countSize.width)

    else
        path = global.MMO.PATH_RES_PRIVATE .. "trading_bank/img_cost.png"
        item_root.Text_name:setString(data.coinConfigTypeName or "")
        item_root.Text_countOrlevel:setString(string.format(GET_STRING(600000432)))
        item_root.Text_job:setVisible(false)
        item_root.Text_countOrlevel_num:setString(data.commodityQty or "")
        local nameX = item_root.Text_name:getPositionX()
        local nameSize = item_root.Text_name:getContentSize()
        item_root.Text_countOrlevel:setPositionX(nameX + nameSize.width + 10)
        local countX = item_root.Text_countOrlevel:getPositionX()
        local countSize = item_root.Text_countOrlevel:getContentSize()
        item_root.Text_countOrlevel_num:setPositionX(countX + countSize.width)
    end
    item_root.Image_head:loadTexture(path)
    item_root.Text_server:setString(data.serverName or "")
    item_root.Button_1:setVisible(false)
    local asyTable = {}
    if self._optRecordType == 0 then -- 买的 
        if data.status == OptState.WaitPay then --待支付
            item_root.Button_1:setVisible(true)
            local expireTime = tonumber(data.expireTime) or GetServerTime()
            local time = math.max(expireTime - GetServerTime(), 0)
            local getTimeStr = function (s)
                return string.format("%.2d:%.2d", s/60, s%60)
            end
            item_root.Text_state:stopAllActions()
            local refTimeLabel = function ()
                time = math.max(expireTime - GetServerTime(), 0)
                item_root.Text_state:setString(string.format(GET_STRING(600000664),getTimeStr(time)))
                GUI:Text_setTextColor(item_root.Text_state, "#00FF00") 
                if time <= 0 then
                    item_root.Text_state:setString(GET_STRING(600000436))
                    item_root.Text_state:setString(GET_STRING(600000436))
                    item_root.Text_count:setFontSize(30)
                    item_root.Text_count:setPositionY(50)
                    item_root.Text_count:setPosition(685, 60)
                    item_root.Text_state:stopAllActions()
                    item_root.Button_1:setVisible(false)
                    data.status = OptState.PayOutTime
                    GUI:Text_setTextColor(item_root.Text_state, "#FF0000")
                end
            end
            
            schedule(item_root.Text_state, function(sender)
                refTimeLabel()
                if asyTable.schedule then
                    asyTable.schedule() 
                    asyTable.schedule = nil
                end
            end, 1)

            item_root.Text_count:setPosition(599, 47)
            item_root.Text_count:setFontSize(20)

            refTimeLabel()
            item_root.Button_1:addClickEventListener(function()
                --支付
                local platform = global.isAndroid and "game_ad" or "game_ios"
                if global.isWindows then
                    platform = "game_pc"
                end
                local params = {
                    type = 2,
                    payinfo = {
                        order_id = data.id,
                        channel = "ALIPAY",
                        client_type = platform,
                        price = data.totalAmount
                    }
                }
                
                params.callback = function()
                    if data.commodityType == CommodityType.Role then --角色
                        local val = {}
                        val.txt = GET_STRING(600000192)--
                        val.btntext = { GET_STRING(600000139), GET_STRING(600000193) }
                        val.callback = function(res)
                            if res == 1 then
                                self:InitOptRecord()
                            elseif res == 2 then
                                global.gameWorldController:OnGameLeaveWorld()
                            end
                        end
                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, val)
                    else 
                        self:InitOptRecord()
                    end
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPowerfulLayer_Open_other, params)

            end)
        elseif data.status == OptState.PaySuccess then  --交易成功
            item_root.Text_state:setString(GET_STRING(600000435))
            item_root.Text_count:setFontSize(30)
            item_root.Text_count:setPositionY(50)
        elseif data.status == OptState.PayOutTime then --支付超时
            item_root.Text_state:setString(GET_STRING(600000436))
            item_root.Text_count:setFontSize(30)
            item_root.Text_count:setPositionY(50)
        elseif data.status == OptState.Cancel then --取消
            item_root.Text_state:setString(GET_STRING(600000480))
            item_root.Text_count:setFontSize(30)
            item_root.Text_count:setPositionY(50)
        elseif data.status == OptState.Back then --退回
            item_root.Text_state:setString(GET_STRING(600000479))
            item_root.Text_count:setFontSize(30)
            item_root.Text_count:setPositionY(50)
        end
        item_root.Text_dz:setVisible(false)
        item_root.Text_dz2:setVisible(false)
        item_root.Text_dz_time:setVisible(false)
        item_root.Text_count:setString("￥" .. (data.totalAmount or ""))

    else--卖的
        if data.status == OptState.Wait then --待入账
            item_root.Text_state:setString(GET_STRING(600000437))
            item_root.Text_dz_time:setString(os.date("%Y.%m.%d %H:%M", tonumber(data.thawTime) or 0))
        elseif data.status == OptState.AlReady then  --已入账
            item_root.Text_state:setString(GET_STRING(600000438))
            item_root.Text_dz:setString(GET_STRING(600000442))
            item_root.Text_dz2:setVisible(false)
            item_root.Text_dz_time:setVisible(false)
        elseif data.status == OptState.Back then  --退回
            item_root.Text_state:setString(GET_STRING(600000479))
            item_root.Text_dz2:setVisible(false)
            item_root.Text_dz_time:setVisible(false)
            item_root.Text_dz:setVisible(false)
            item_root.Text_count:setFontSize(30)
            item_root.Text_count:setPositionY(50)
        end
        item_root.Text_count:setString("￥" .. (data.commodityAmount or ""))
    end

    item:addClickEventListener(function()
        local params = clone(data)
        if data.status == OptState.WaitPay then
            params.asyTable = asyTable
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankWaitPayPanelLayer_Open_other, {
                data = params,
                callback = function()
                    self:InitOptRecord()
                end
            })
        else
            params.optRecord_type = self._optRecordType
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankMeRecordPanelLayer_Open_other, params)
        end
    end)
    return item
end
-----------------------------------------------------提现记录
function TradingBankMeLayer:InitGetMoneyRecordUI()
    self._panelGetMoneyRecordRoot = ui_delegate(self._ui.Panel_getMoney_record)
    self._panelGetMoneyRecordRoot.Panel_item:setVisible(false)
    self._panelGetMoneyRecordRoot.Button_back:addClickEventListener(function(sender, type)--返回
        if self._isGetMoneyViewInToRecord then
            self._isGetMoneyViewInToRecord = false
            self:ShowGetMoney(true)
        else
            self:ShowBase()
        end
    end)
    self._panelGetMoneyRecordRoot.ListView:addScrollViewEventListener(function(sender, event)
        local itemnum = #sender:getItems()
        local Bottomitem = sender:getBottommostItemInCurrentView()
        local lastitem = sender:getItem(itemnum - 1)
        if (event == 1 or (event == 10 and lastitem == Bottomitem)) and self._getMoneyPage < self._getMoneyAllPage and not self._getMoneyReqState then
            local params = {
                page = self._getMoneyPage + 1,
                pagenum = self._getMoneyNum
            }
            self:ReqExtractRecordList(params)
        end
    end)
end
function TradingBankMeLayer:ShowGetMoneyRecord()
    self:HideAllUI()
    self._ui.Panel_getMoney_record:setVisible(true)
    self._getMoneyPage = 1
    self._getMoneyNum = 10
    self._getMoneyAllPage = 1
    self._panelGetMoneyRecordRoot.ListView:removeAllChildren()
    local params = {
        page = self._getMoneyPage,
        pagenum = self._getMoneyNum
    }
    self:ReqExtractRecordList(params)
end
function TradingBankMeLayer:ReqExtractRecordList(params)
    self._getMoneyReqState = true
    self._otherTradingBankProxy:reqExtractRecordList(self, params, function(code, data, msg)
        self._getMoneyReqState = false
        if code == 200 then
            self._getMoneyPage = data.pageNum or 1
            self._getMoneyNum = data.pageSize or 10
            self._getMoneyAllPage = data.pageTotal or 1
            self:CreateGetMoneyRecords(data.records or {})
        else
            ShowSystemTips(msg)
        end

    end)
end
function TradingBankMeLayer:CreateGetMoneyRecords(data)
    local lastIndex = #self._panelGetMoneyRecordRoot.ListView:getItems() - 1
    for i, v in ipairs(data) do
        local itemSize = self._panelGetMoneyRecordRoot.Panel_item:getContentSize()
        local cell_data = {}
        cell_data.wid = itemSize.width
        cell_data.hei = itemSize.height
        -- cell_data.anchor = cc.p(0.5, 1)
        cell_data.tick_interval = 0.05
        cell_data.createCell = function()
            local cell = self:CreateGetMoneyRecordItem(v)
            return cell
        end
        local item = QuickCell:Create(cell_data)
        item.page = self._getMoneyPage
        self._panelGetMoneyRecordRoot.ListView:pushBackCustomItem(item)
    end
    self._panelGetMoneyRecordRoot.ListView:jumpToItem(lastIndex, cc.p(0, 0), cc.p(0, 0))
end

function TradingBankMeLayer:CreateGetMoneyRecordItem(data)
    dump(data, "CreateGetMoneyRecordItem")
    local item = self._panelGetMoneyRecordRoot.Panel_item:clone()
    item:setVisible(true)
    item._data = data
    local item_root = ui_delegate(item)
    item_root.Text_time:setString(os.date("%Y-%m-%d %H:%M:%S", data.createTime or os.time()))
    item_root.Text_sxf:setString(data.extractChargeMoney or "")--手续费
    --0审核中  1提现成功  2 提现失败  3撤回提现
    local stateTxts = {
        GET_STRING(600000420),
        GET_STRING(600000421),
        GET_STRING(600000422),
        GET_STRING(600000449),
    }
    local stateIndex = data.status and data.status + 1 or 2
    item_root.Text_state:setString(stateTxts[stateIndex] or "")
    if data.status == 1 then
        GUI:Text_setTextColor(item_root.Text_state, "#00FF00")
    end
    item_root.Text_count:setString(-(data.totalExtractMoney or 0) .. GET_STRING(600000459))
    item_root.Image_redPoint:setVisible(not data.read)
    local detailData = clone(data)
    detailData.account = "AUTO_FILL"
    item:addClickEventListener(function()
        self._otherTradingBankProxy:reqExtractRecordDetails(self, { id = data.id }, function(code, data, msg)
            if code == 200 then
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankMeGetMoneyPanelLayer_Open_other, data)
            else
                ShowSystemTips(msg)
            end
        end)
        item_root.Image_redPoint:setVisible(false)
    end)
    return item
end
----------------------------------------------------帮助中心
function TradingBankMeLayer:InitHelpCenterUI()
    self._panelHelpCenterRoot = ui_delegate(self._ui.Panel_help_center)
    self._panelHelpCenterRoot.help_item:setVisible(false)
    self._helpList = {}
    self._panelHelpCenterRoot.Button_back:addClickEventListener(function(sender, type)--返回
        self._panelHelpCenterRoot.Input_search:setString("")
        self:ShowBase()
    end)
    self._panelHelpCenterRoot.Button_search:addClickEventListener(function(sender, type)--搜索
        local searchStr = self._panelHelpCenterRoot.Input_search:getString()
        self:ReqHelpList(searchStr)
    end)
end

function TradingBankMeLayer:ShowHelpCenter()
    self:HideAllUI()
    self._ui.Panel_help_center:setVisible(true)
    self:ReqHelpList("")
end

function TradingBankMeLayer:ReqHelpList(keyword)
    self._otherTradingBankProxy:HelpList(self, { keyword = keyword }, function(code, data, msg)
        if code == 200 then
            self._helpList = data
            self:RefHelpCenter()
        else
            ShowSystemTips(msg or "")
        end
    end)
end

function TradingBankMeLayer:RefHelpCenter()
    self._panelHelpCenterRoot.ListView_help:removeAllItems()
    self:CreateHelpDesc(self._helpList)
end

function TradingBankMeLayer:CreateHelpDesc(data)
    dump(data, "CreateHelpDesc")
    for i, v in ipairs(data) do
        local itemSize = self._panelHelpCenterRoot.help_item:getContentSize()
        local cell_data = {}
        cell_data.wid = itemSize.width
        cell_data.hei = itemSize.height
        -- cell_data.anchor = cc.p(0.5, 1)
        cell_data.tick_interval = 0.05
        cell_data.createCell = function()
            local cell = self:CreateHelpDescItem(v, i)
            return cell
        end
        local item = QuickCell:Create(cell_data)
        self._panelHelpCenterRoot.ListView_help:pushBackCustomItem(item)
    end
end

function TradingBankMeLayer:CreateHelpDescItem(data, i)
    local item = self._panelHelpCenterRoot.help_item:cloneEx()
    item:setVisible(true)
    item._data = data
    local item_root = ui_delegate(item)
    item_root.Text_title:setString(data.title or "")
    item_root.ImageBG:setVisible(i % 2 == 1)
    item:addClickEventListener(function(sender, type)
        local params = {}
        params.type = 1
        params.btntext = GET_STRING(600000476)
        params.text = data.text or ""
        params.titleImg = global.MMO.PATH_RES_PRIVATE .. "trading_bank_other/img_tips.png"
        params.callback = function(res)
            if res == 1 then
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Close_other)
            end
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open_other, params)
    end)
    return item
end
--------------------------------------------------- 求购记录
function TradingBankMeLayer:InitReqBuyRecordUI()
    self._panelReqBuyRecordRoot = ui_delegate(self._ui.Panel_reqBuy_record)
    self._panelReqBuyRecordRoot.Panel_item:setVisible(false)
    self._panelReqBuyRecordRoot.Button_back:addClickEventListener(function(sender, type)--返回
        self:ShowBase()
    end)
    self._panelReqBuyRecordRoot.ListView:addScrollViewEventListener(function(sender, event)
        local itemnum = #sender:getItems()
        local Bottomitem = sender:getBottommostItemInCurrentView()
        local lastitem = sender:getItem(itemnum - 1)
        if (event == 1 or (event == 10 and lastitem == Bottomitem)) and self._reqBuyPage < self._reqBuyAllPage and not self._reqBuyRecordState then
            local params = {
                page = self._reqBuyPage + 1,
                pagenum = self._reqBuyNum
            }
            self:ReqRequestBuyRecord(params)
        end
    end)
end

function TradingBankMeLayer:ShowReqBuyRecord()
    self:HideAllUI()
    self._ui.Panel_reqBuy_record:setVisible(true)
    self:RefRequestBuyRecord()
end

function TradingBankMeLayer:RefRequestBuyRecord()
    self._reqBuyPage = 1
    self._reqBuyNum = 10
    self._reqBuyAllPage = 1
    self._panelReqBuyRecordRoot.ListView:removeAllChildren()
    local params = {
        pageNum = self._reqBuyPage,
        pageSize = self._reqBuyNum
    }
    self:ReqRequestBuyRecord(params)
end
function TradingBankMeLayer:ReqRequestBuyRecord(params)--
    self._reqBuyRecordState = true
    self._otherTradingBankProxy:getRequestBuyRecord(self, params, function(code, data, msg)
        self._reqBuyRecordState = false
        if code == 200 then
            self._reqBuyPage = tonumber(data.pageNum or 1)
            self._reqBuyNum = tonumber(data.pageSize or 10)
            self._reqBuyAllPage = tonumber(data.pageTotal or 1)
            self:CreateReqBuyRecords(data.records or {})
        else
            ShowSystemTips(msg)
        end

    end)
end

function TradingBankMeLayer:CreateReqBuyRecords(data)
    dump(data, "CreateReqBuyRecords___")
    local lastIndex = #self._panelReqBuyRecordRoot.ListView:getItems() - 1
    for i, v in ipairs(data) do
        local itemSize = self._panelReqBuyRecordRoot.Panel_item:getContentSize()
        local cell_data = {}
        cell_data.wid = itemSize.width
        cell_data.hei = itemSize.height
        -- cell_data.anchor = cc.p(0.5, 1)
        cell_data.tick_interval = 0.05
        cell_data.createCell = function()
            local cell = self:CreateReqBuyRecordItem(v)
            return cell
        end
        local item = QuickCell:Create(cell_data)
        item.page = self._reqBuyPage
        self._panelReqBuyRecordRoot.ListView:pushBackCustomItem(item)
    end
    self._panelReqBuyRecordRoot.ListView:jumpToItem(lastIndex, cc.p(0, 0), cc.p(0, 0))
end

function TradingBankMeLayer:CreateReqBuyRecordItem(data)
    local item = self._panelReqBuyRecordRoot.Panel_item:clone()
    item:setVisible(true)
    item._data = data
    local item_root = ui_delegate(item)
    item_root.Text_time:setString(os.date("%Y-%m-%d %H:%M:%S", data.createTime or os.time()))
    
    local jobid = data.roleType or 0
    item_root.Text_job:setString(GET_STRING(1067 + jobid))
    item_root.Text_level:setString(data.minRoleLevel .. "-" .. data.maxRoleLevel)

    if data.minPrice == 1000  then
        item_root.Text_price:setString(data.minPrice .. "以上")
    else
        item_root.Text_price:setString(data.minPrice .. "-" .. data.maxPrice)
    end
    item_root.Text_delete:setTouchEnabled(true)
    item_root.Text_delete:getVirtualRenderer():enableUnderline()
    item_root.Text_delete:addClickEventListener(function()
        local tipsData = {
            title = "",
            txt = GET_STRING(600000811),
            btntext = { GET_STRING(600000135), GET_STRING(600000407) },
            callback = function(res)
                if res == 1 then
                    self._otherTradingBankProxy:doTrack(self._otherTradingBankProxy.UpLoadData.TraingReqBuyRecordOKBtnClick)
                    self._otherTradingBankProxy:deleteRequestBuyRecord(self, { requestId = data.requestId }, function(code, resData, msg)
                        if code == 200 then
                            self:RefRequestBuyRecord()
                        else
                            ShowSystemTips(msg)
                        end
                    end)
                end
            end
        }
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, tipsData)
    end)
    return item
end
----------------------------------------------------
function TradingBankMeLayer:IsGoodNumber(str)
    if not (string.len(str) > 0) then
        return false
    end
    -- if not self:IsNumber(str) then
    --     return false
    -- end
    if not tonumber(str) then
        return false
    end
    if tonumber(str) <= 0 then
        return false
    end
    return true
end

--是否纯数字
function TradingBankMeLayer:IsNumber(str)
    if string.find(str, "[^%d%.]") then
        return false
    end
    return true
end


function TradingBankMeLayer:ExitLayer()
    self._otherTradingBankProxy:removeLayer(self)
end

return TradingBankMeLayer