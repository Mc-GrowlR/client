local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankSellLayer = class("TradingBankSellLayer", BaseLayer)
local cjson = require("cjson")
function TradingBankSellLayer:ctor()
    TradingBankSellLayer.super.ctor(self)
    self._otherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    self._playerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    self._moneyProxy = global.Facade:retrieveProxy(global.ProxyTable.MoneyProxy)
    self._moneyType = self._moneyProxy.MoneyType
    self._tipsImgPath = global.MMO.PATH_RES_PRIVATE .. "trading_bank_other/img_tips.png"
end

function TradingBankSellLayer.create(...)
    local ui = TradingBankSellLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankSellLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_sell")
    self._root = ui_delegate(self)

    self._root.Panel_2:setVisible(false)
    self._root.Panel_common:setVisible(false)
    self._root.Text_most1:setVisible(false)
    self._root.Panel_3:setVisible(false)
    self._root.Panel_1:setVisible(false)
    self._root.Text_mostdi:setString("")
    -------买家是否可以还价
    self._root.Panel_sel._isSelect = true
    ------------------------
    self._servicePercent = 0 --手续费

    self:ReqMoneyData()
    return true
end

function TradingBankSellLayer:IsGoodNumber(str)
    if not (string.len(str) > 0) then
        return false
    end
    if not self:IsNumber(str) then
        return false
    end
    if not tonumber(str) then
        return false
    end
    if tonumber(str) <= 0 then
        return false
    end
    return true
end
--是否纯数字
function TradingBankSellLayer:IsNumber(str)
    if string.find(str, "[^%d%%.]") then
        return false
    end
    return true
end

--验证手机之后获取货币信息
function TradingBankSellLayer:ReqMoneyData()
    self._otherTradingBankProxy:reqMoneyData(self, function(code, value, msg)--请求货币信息
        if code == 200 then
            self._root.Panel_1:setVisible(true)
            self:InitUI()
        else
            ShowSystemTips(msg)
        end
    end)
end
function TradingBankSellLayer:InitUI()
    --输入框
    for i = 1, 4 do
        self._root["TextField_" .. i] = (self._root["TextField_" .. i])
        if i == 1 then
            self._otherTradingBankProxy:cancelEmpty(self._root["TextField_" .. i])
        end
    end
    self:OnCheck(1)
    for i = 1, 2 do
        self._root["Button_" .. i]:addTouchEventListener(handler(self, self.OnButtonClick))
    end

    for i = 1, 2 do
        self._root["CheckBox_" .. i]:addEventListener(function()
            --设置上架类型
            self:OnCheck(i)
        end)
    end
    --查无此人
    self._root.Text_7:setVisible(false)
    --tips
    --货币
    self._root.Panel_CheckBox:setVisible(false)
    self:RefMoneyUI()
    --角色售卖信息
    self._root.TextField_1:onEditHandler(function(event)
        if event.name == "changed" then
            local s = event.target:getString()
            s = string.gsub(s, "%s", "")
            s = string.gsub(s, "[^%d]", "")
            s = tonumber(s)
            if s and s > 10000000 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000165))
                s = 10000000
            end
            event.target:setString(s)

        end
    end)
    self._root.TextField_2:onEditHandler(function(event)
        if self.m_selIndex ~= 2 or #self.m_moneyItem == 0 then
            return
        end
        local coinTypeId = tonumber(self.m_moneyItem[self.m_selMoneyIndex].val.coinTypeId)
        local count = self._moneyProxy:GetMoneyCountById(coinTypeId)
        if event.name == "changed" then
            local s = event.target:getString()
            s = string.gsub(s, "%s", "")
            s = string.gsub(s, "[^%d]", "")
            event.target:setString(s)
            if not self:IsGoodNumber(s) then--数量
                s = 1
            end
            if string.len(s) > 14 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000453))
                s = 99999999999999
            end
            s = tonumber(s)
            if s > count then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, string.format(GET_STRING(600000168), count))
                s = count
                event.target:setString(s)
            end
            -- local strs2 = string.format(GET_STRING(600000190), self:GetRealNum(self.m_min_price * s))
            -- self._root.Text_mostdi:setString(strs2)
        end

    end)
    self._root.TextField_3:onEditHandler(function(event)
        if self.m_selIndex ~= 2 or #self.m_moneyItem == 0 then
            return
        end
        local coinTypeId = tonumber(self.m_moneyItem[self.m_selMoneyIndex].val.coinTypeId)
        local count = self._moneyProxy:GetMoneyCountById(coinTypeId)
        if event.name == "changed" then
            local s = event.target:getString()
            s = string.gsub(s, "%s", "")
            s = string.gsub(s, "[^%d%.]", "")
            event.target:setString(s)
            if not self:IsGoodNumber(s) then--价格
                s = 1
            end
            s = tonumber(s)
            if s > 100000 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000454))
                s = 100000
                event.target:setString(s)
            end
        end
    end)
    --指定购买人
    self._root.TextField_4:onEditHandler(function(event)

        if event.name == "changed" then
            local s = event.target:getString()
            s = string.gsub(s, "%s", "")
            event.target:setString(s)
        end
        if event.name == "return" then

        end

    end)
    -----加mask 
    self:AddMask(self._root.TextField_2, self._root.Panel_mask1)
    self:AddMask(self._root.TextField_3, self._root.Panel_mask2)
    self:AddMask(self._root.TextField_4, self._root.Panel_mask3)




    --验证token
    self._root.Panel_2:setVisible(false)
    self._root.Panel_common:setVisible(false)
    -------买家是否可以还价
    self._root.Panel_sel_1:setVisible(false)
    self._root.Panel_sel:addClickEventListener(function()
        self._root.Panel_sel._isSelect = not self._root.Panel_sel._isSelect
        self._root.Panel_sel_1:setVisible(not self._root.Panel_sel._isSelect)
        self._root.Panel_sel_2:setVisible(self._root.Panel_sel._isSelect)
    end)
    -------
    ---最低售价
    self._root.Text_most1:setVisible(false)
    self._root.Panel_2:getChildByName("Text_2"):setString(string.format(GET_STRING(600000191), self._playerProperty:GetName()))
    self:ReqSellRoleInfo()

end

function TradingBankSellLayer:AddMask(node, mask)
    local x = node:getPositionX()
    node.xxx = x
    node:setPositionX(-1000000)
    mask:addClickEventListener(function(sender, state)
        local caninput = true
        if self.m_selIndex == 2 and #self.m_moneyItem > 0 then
            local coinTypeId = tonumber(self.m_moneyItem[self.m_selMoneyIndex].val.coinTypeId)
            local count = self._moneyProxy:GetMoneyCountById(coinTypeId)
            if count == 0 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000164))
                caninput = false
            end
        end
        if caninput then
            node:setPositionX(x)
            node:touchDownAction(node, 2)
        end
    end)
    if not self.m_maskEdit then
        self.m_maskEdit = {}
    end
    table.insert(self.m_maskEdit, node)
end
function TradingBankSellLayer:ResetEditPosx()
    if self.m_maskEdit then
        for i, v in ipairs(self.m_maskEdit) do
            v:setPositionX(-1000000)
        end
    end
end
function TradingBankSellLayer:ReqSellRoleInfo()
    self._otherTradingBankProxy:reqSellRoleInfo(self, {}, function(code, data, msg)
        dump({ code, data, msg }, "reqSellRoleInfo__")
        --commodityExpireHour
        if code == 200 then
            self._root.Panel_2:setVisible(true)
            self._root.Panel_common:setVisible(true)
            self._root.Text_most1:setVisible(true)

            self._servicePercent = tonumber(data.servicePercent)
            self._roleMinPrice = data.roleMinPrice or 0
            self._roleMaxServiceCharge = data.maxServiceCharge
            local str = string.format(GET_STRING(600000803), self._roleMinPrice, self._servicePercent)   
            self._root.Text_most1:setString(str)
            
            local commodityExpireHour = data.commodityExpireHour or 0
            self._otherTradingBankProxy:setOutTime(commodityExpireHour)
            local price = 0
            if self.m_selMoneyIndex then 
                price = self.m_moneyItem[self.m_selMoneyIndex] and tonumber(self.m_moneyItem[self.m_selMoneyIndex].val.coinMinPrice) or 0
            end
            str = string.format(GET_STRING(600000803), self:GetRealNum(price), self._servicePercent)
            self._root.Text_most2:setString(str)
        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, msg or "")
        end
    end)
end
function TradingBankSellLayer:GetAccountInfo(name, func)
    self._otherTradingBankProxy:reqAccountInfo(self, { account = name }, function(code, data, msg)
        if code == 200 then
            func()
        else
            ShowSystemTips(msg)
            -- global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code)
            -- end, notcancel = true, txt = GET_STRING(600000176), btntext = { GET_STRING(600000139) } })
        end
    end)
end
function TradingBankSellLayer:GetRoleInfo(name, func)
    self._otherTradingBankProxy:reqRoleInfo(self, { role_name = name }, function(code, data, msg)
        dump({ code, data, msg }, "getRoleInfo___")
        if code == 200 then
            func()
        else
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code)
            end, notcancel = true, txt = GET_STRING(600000175), btntext = { GET_STRING(600000139) } })
        end
    end)
end
function TradingBankSellLayer:RefMoneyUI()
    self.m_moneyItem = {}
    self.m_selMoneyIndex = 1
    local moneyData = self._otherTradingBankProxy:getMoneyData(self)
    local size = self._root.Panel_CheckBox:getContentSize()
    local itemnum = #moneyData
    local size2 = self._root.ScrollView_money:getContentSize()
    local yy = math.ceil(itemnum / 2)
    local contentH = math.max(yy * size.height, 94)
    self._root.ScrollView_money:setInnerContainerSize(cc.size(size2.width, contentH))
    dump(moneyData, "moneyData____")
    -- --最低出售数量
    local index = nil
    for i, v in ipairs(moneyData) do
        local min_count = tonumber(v.coinMinSellCount) or 0
        local count = self._moneyProxy:GetMoneyCountById(tonumber(v.coinTypeId))
        local name = v.coinTypeName
        local item = self._root.Panel_CheckBox:cloneEx()
        local Text_money = item:getChildByName("Text_money")
        local CheckBox = item:getChildByName("CheckBox")
        CheckBox:setSelected(false)
        Text_money:setString(string.format(GET_STRING(600000100), name, count))
        item:setVisible(true)
        item:setTag(i)
        item:addTouchEventListener(function(sender, type)
            if type ~= 2 then
                return
            end
            if self.m_selMoneyIndex == i then 
                return
            end
            if count < min_count then
                ShowSystemTips(GET_STRING(600000456))
            else
                self:OnCheckMoney(sender, type)
            end
        end)
        if count < min_count then --
            Shader_Grey(CheckBox)
        end
        if not index and count >= min_count then
            index = i
        end
        item:addTo(self._root.ScrollView_money)
        local yy = math.ceil(i / 2)
        local xx = (i - 1) % 2
        local x = xx * (size.width + 5)
        local y = contentH - (yy - 1) * size.height
        item:setPosition(x, y)
        item:setAnchorPoint(0, 1)
        item.val = v
        table.insert(self.m_moneyItem, item)
    end
    -- GUI:ScrollView_scrollToTop(self._root.ScrollView_money,0,true)
    self.m_selMoneyIndex = index
    if index then
        local price = self.m_moneyItem[self.m_selMoneyIndex] and tonumber(self.m_moneyItem[self.m_selMoneyIndex].val.coinMinPrice) or 0
        self.m_min_price = price
        
        local str = string.format(GET_STRING(600000632), self:GetRealNum(price), self._servicePercent)
        self._root.Text_most2:setString(str)

        local MinCount = self.m_moneyItem[self.m_selMoneyIndex] and tonumber(self.m_moneyItem[self.m_selMoneyIndex].val.coinMinSellCount) or 0
        self._root.Text_most3:setString(string.format(GET_STRING(600000174), MinCount))

        local CheckBox = self.m_moneyItem[self.m_selMoneyIndex]:getChildByName("CheckBox")
        CheckBox:setSelected(true)
    end

end
--设置上架类型1-2角色货币
function TradingBankSellLayer:OnCheck(index)
    -- dump(index,"onCheck___")
    local moneyData = self._otherTradingBankProxy:getMoneyData(self)
    if index == 2 and #moneyData == 0 then
        ShowSystemTips(GET_STRING(600000015))
        self._root.CheckBox_2:setSelected(false)
        return
    end
    for i = 1, 2 do
        self._root["Panel_" .. (i + 1)]:setVisible(index == i)
        self._root["CheckBox_" .. i]:setSelected(index == i)
    end
    self.m_selIndex = index

    local desc = {
        GET_STRING(600000445),
        GET_STRING(600000151)
    }
    self._root.Text_8:setString(desc[self.m_selIndex])
    self._root.Text_7:setVisible(false)
    self._root.TextField_4:setString("")
    self._root.Button_2:setTitleText(GET_STRING(600000159 + self.m_selIndex))
    self:ResetEditPosx()
end
--设置货币类型
function TradingBankSellLayer:OnCheckMoney(sender, type)
    local tag = sender:getTag()
    for i, v in ipairs(self.m_moneyItem) do
        local CheckBox = v:getChildByName("CheckBox")
        CheckBox:setSelected(i == tag)
    end
    self.m_selMoneyIndex = tag
    local coinTypeId = tonumber(self.m_moneyItem[self.m_selMoneyIndex].val.coinTypeId)
    local count = self._moneyProxy:GetMoneyCountById(coinTypeId)
    if count == 0 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000164))
        --  self._root.TextField_2:setString("")
        -- self._root.TextField_2:setPositionX(-100000)
    end
    self._root.TextField_2:setString("")
    -- self._root.Text_mostdi:setString(string.format(GET_STRING(600000190), ""))
    self:ResetEditPosx()
    local num = self._root.TextField_2:getString()

    if not self:IsGoodNumber(num) then--数量
        num = 1
    end

    local price = tonumber(self.m_moneyItem[self.m_selMoneyIndex].val.coinMinPrice) or 0
    self.m_min_price = price
    local str = string.format(GET_STRING(600000632), self:GetRealNum(price), self._servicePercent)
    self._root.Text_most2:setString(str)


    local count = self.m_moneyItem[self.m_selMoneyIndex] and tonumber(self.m_moneyItem[self.m_selMoneyIndex].val.coinMinSellCount) or 0
    self._root.Text_most3:setString(string.format(GET_STRING(600000174), count))
end

function TradingBankSellLayer:sellFunc()
    local name = self._root.TextField_4:getString()
    if string.len(name) == 0 then
        if self.m_selIndex == 1 then
            self:OnRole()
        else-- 货币
            self:OnMoney()
        end
    else
        if self.m_selIndex == 2 then--货币查询角色
            local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
            if name == PlayerProperty:GetName() then
                ShowSystemTips(GET_STRING(600000446))
                return
            end
            self:GetRoleInfo(name, handler(self, self.OnMoney))
        else--角色查询账号
            if self:IsGoodNumber(name) then --唯一码是数字
                local checkIsSelf = function(OnlyOneID)--检测是不是自己
                    if tonumber(OnlyOneID) == tonumber(name) then
                        ShowSystemTips(GET_STRING(600000446))
                    else
                        self:GetAccountInfo(name, handler(self, self.OnRole))
                    end
                end
                local OnlyOneID = self._otherTradingBankProxy:getOnlyOneID()
                if OnlyOneID then
                    checkIsSelf(OnlyOneID)
                else
                    self._otherTradingBankProxy:getTradeId(self, {}, function(code, data, msg)
                        if code == 200 then
                            self._otherTradingBankProxy:setOnlyOneID(data or 0)
                            checkIsSelf(data)
                        else
                            ShowSystemTips(msg)
                        end
                    end)
                end
            else
                ShowSystemTips(GET_STRING(600000409))
            end
        end
    end
end
--
function TradingBankSellLayer:OnButtonClick(sender, type)
    if type ~= 2 then
        return
    end
    local name = sender:getName()

    if name == "Button_2" then--下一步
        self._otherTradingBankProxy:doTrack(self._otherTradingBankProxy.UpLoadData.TraingSellLayerNextBtnClick)
        --检测寄售锁
        local function checkConsignmentSwitch()
            self._otherTradingBankProxy:checkConsignmentSwitch(self, {}, function(code, val, msg)
                if code == 200 then
                    if val then
                        self:sellFunc()
                    else --还未验证手机
                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open_other, { callback = function(code)
                            if code == 1 then--手机验证成功
                                --self:sellFunc()
                            end
                        end,  openLock = true })
                    end
                else
                    ShowSystemTips(msg)
                end
            end)
        end 
        
        --检测绑定手机
        self._otherTradingBankProxy:checkBindPhone(self,{}, function (code, data, msg)
            dump({code, data, msg},"checkBindPhone__")
            if code  == 200 then 
                if data then 
                    checkConsignmentSwitch()
                else
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open_other, { callback = function(code)
                        if code == 1 then--手机绑定成功 --自动开启寄售锁
                            --self:sellFunc()
                        end
                    end})
                end
            else
                ShowSystemTips(msg)
            end
        end)
    elseif name == "Button_1" then--提示
        self._otherTradingBankProxy:reqHelpText(self, { type = 1 }, function(help)
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code)
                if code == 3 or code == 1 or code == 0 then
                    dump("提示退出")
                end
            end, title = help.title, notcancel = true, canmove = true, txt = help.data, btntext = { GET_STRING(600000139) } })
        end)

    end
end
function TradingBankSellLayer:OnMoney()
    local num = self._root.TextField_2:getString()

    local price = self._root.TextField_3:getString()
    local target_rolename = self._root.TextField_4:getString()
    target_rolename = string.len(target_rolename) > 0 and target_rolename or nil
    if self:IsGoodNumber(num) then--数量
        local count = tonumber(num)
        -- if count<20 then
        --     global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000115))
        --     return 
        -- end
        num = string.gsub(num, "^0+", "")
        -- if not string.find(num,"%d+0") then
        --      global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000173))
        --     return 
        -- end
    else--
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000114))
        return
    end
    if #self.m_moneyItem == 0 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000186))
        return
    end
    local name = self.m_moneyItem[self.m_selMoneyIndex].val.coinTypeName or ""
    local coin_id = tonumber(self.m_moneyItem[self.m_selMoneyIndex].val.coinTypeId)
    if not self:IsGoodNumber(price) then--价格
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000116))
        return
    end
    if string.find(price, "%.") then--价格必须为整数
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000196))
        return
    end
    price = tonumber(price)

    local upMoneyFunc = function()
        -- price 
        -- target_rolename
        -- coin_num
        -- coin_id
        -- bargain_switch 是否能还价
        local data2 = {
            price = price,
            target_rolename = target_rolename,
            coin_num = tonumber(num),
            coin_id = coin_id,
            bargain_switch = self._root.Panel_sel._isSelect and 1 or 0
        }
        self:SellMoney(data2, function()
            local outtime = self._otherTradingBankProxy:getOutTime()
            local tipsStr = string.format(GET_STRING(600000458), outtime)
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code)
                if code == 3 or code == 1 or code == 0 then
                end
            end, title = "", notcancel = true, canmove = true, txt = tipsStr, btntext = { GET_STRING(600000139) } })

            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankFrame_Open_other, { id = global.LayerTable.TradingBankGoodsLayer })

        end)
    end

    local maxServiceCharge = self.m_moneyItem[self.m_selMoneyIndex].val.maxServiceCharge or 0
    maxServiceCharge = tonumber(maxServiceCharge)
    if price and maxServiceCharge and maxServiceCharge ~= 0 and self._servicePercent and self._servicePercent ~= 0 then
        if price * self._servicePercent / 100 >= maxServiceCharge then
            local params = {}
            params.type = 1
            params.btntext = GET_STRING(600000476)
            params.text = string.format(GET_STRING(600000477), maxServiceCharge)
            params.titleImg = self._tipsImgPath
            params.callback = function(res)
                if res == 1 then
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Close_other)
                    upMoneyFunc()
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open_other, params)
        else
            upMoneyFunc()
        end
    else
        upMoneyFunc()
    end
end

function TradingBankSellLayer:OnRole()
    local price = self._root.TextField_1:getString()
    local target_rolename = self._root.TextField_4:getString()
    target_rolename = string.len(target_rolename) > 0 and target_rolename or nil
    -- dump(self._roleMinPrice)
    self._roleMinPrice = self._roleMinPrice or 0
    local minPriceTips
    if self:IsGoodNumber(price) then--价格
        if tonumber(price) < tonumber(self._roleMinPrice) then
            -- global.Facade:sendNotification(global.NoticeTable.SystemTips, string.format(GET_STRING(600000117), self._roleMinPrice))
            -- return
            minPriceTips = string.format(GET_STRING(600000117), self._roleMinPrice)
        end
    else--
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000116))
        return
    end

    price = tonumber(price)
    dump(price, "price____")
    local upRoleFunc = function()
        --bargain_switch 是否能还价
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureLayer_Open_other, { 
            price = price,
            target_account = target_rolename, 
            bargain_switch = self._root.Panel_sel._isSelect and 1 or 0 ,
            minPriceTips = minPriceTips
        })
    end


    local maxServiceCharge = self._roleMaxServiceCharge or 0
    maxServiceCharge = tonumber(maxServiceCharge)
    if price and maxServiceCharge and maxServiceCharge ~= 0 and self._servicePercent and self._servicePercent ~= 0 then
        if price * self._servicePercent / 100 >= maxServiceCharge then
            local params = {}
            params.type = 1
            params.btntext = GET_STRING(600000476)
            params.text = string.format(GET_STRING(600000477), maxServiceCharge)
            params.titleImg = self._tipsImgPath
            params.callback = function(res)
                if res == 1 then
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Close_other)
                    upRoleFunc()
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open_other, params)
        else
            upRoleFunc()
        end
    else
        upRoleFunc()
    end
end

--卖金币
function TradingBankSellLayer:SellMoney(val, func)
    local coin_name = self.m_moneyItem[self.m_selMoneyIndex].val.coinTypeName or ""
    local txt = string.format(GET_STRING(600000169), val.price, val.coin_num, coin_name)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, { callback = function(code)
        if code == 2 then
            self._otherTradingBankProxy:sellMoney(self, val, function(code, data, msg)
                if code == 200 then 
                    self._otherTradingBankProxy:doTrack(self._otherTradingBankProxy.UpLoadData.TraingMoneySell,
                    {
                        properities = {
                            goods_price = val.price,
                            result = "成功",
                            num = val.coin_num
                        }
                    })
                else
                    self._otherTradingBankProxy:doTrack(self._otherTradingBankProxy.UpLoadData.TraingMoneySell,
                    {
                        properities = {
                            goods_price = val.price,
                            result = "失败",
                            num = val.coin_num
                        }
                    })
                end
                if code == 200 then
                    if func then
                        func()
                    end
                    global.Facade:sendNotification(global.NoticeTable.SystemTips, msg or "")
                elseif code == 30315 then --寄售锁失效重新验证phone
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open_other, { callback = function(code)
                        if code == 1 then--
                            self:SellMoney(val, func)
                        end
                    end, checkPhone = true, openLock = true })
                elseif code == 30307 then --等级 充值 不满足条件
                    local params = {}
                    params.type = 1
                    params.btntext = GET_STRING(600000476)
                    params.text = msg or ""
                    params.titleImg = self._tipsImgPath
                    params.callback = function(res)
                        if res == 1 then
                            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Close_other)
                        end
                    end
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTips2Layer_Open_other, params)
                else
                    global.Facade:sendNotification(global.NoticeTable.SystemTips, msg or "")
                end
            end)
        end
    end, txt = txt, btntext = { GET_STRING(600000170), GET_STRING(600000161) } })
end

function TradingBankSellLayer:GetRealNum(numStr)
    if numStr >= 0.0001 then
        return tostring(numStr)
    end
    local rStr, sPos = string.reverse(string.format("%.16f", numStr)), 0
    for s in string.gmatch(rStr, ".") do
        sPos = sPos + 1
        if  tonumber(s) and tonumber(s) > 0 then
            break
        end
    end
    local fStr = string.reverse(string.sub(rStr, sPos))
    return fStr
end
function TradingBankSellLayer:ExitLayer()
    self._otherTradingBankProxy:removeLayer(self)
end
return TradingBankSellLayer