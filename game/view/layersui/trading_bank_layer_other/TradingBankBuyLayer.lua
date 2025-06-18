local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankBuyLayer = class("TradingBankBuyLayer", BaseLayer)
local RichTextHelp = requireUtil("RichTextHelp")
local LayerNodeOpen = {
    "Layer_TradingBankBuyRoleLayer_Open_other", --
    "Layer_TradingBankBuyMoneyLayer_Open_other", --
    "Layer_TradingBankBuyRequestLayer_Open_other",--
    "Layer_TradingBankBuyMeLayer_Open_other", --
}
local LayerNodeClose = {
    "Layer_TradingBankBuyRoleLayer_Close_other",
    "Layer_TradingBankBuyMoneyLayer_Close_other",
    "Layer_TradingBankBuyRequestLayer_Close_other",--
    "Layer_TradingBankBuyMeLayer_Close_other",
}
TradingBankBuyLayer.BtnMax = 3
function TradingBankBuyLayer:ctor()
    TradingBankBuyLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankBuyLayer.create(...)
    local ui = TradingBankBuyLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankBuyLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_buy")
    self._root = ui_delegate(self)
    self:InitUI(data)
    return true
end

function TradingBankBuyLayer:InitUI(data)
    self.ListView_1 = self._root.ListView_1
    self.Button_1 = self._root.Button_1
    self.Button_1:setVisible(false)
    self.m_btns = {}
    local panel, btn
    local btnDescIndex = {600000001,600000002,600000805}
    for i = 1, TradingBankBuyLayer.BtnMax do
        btn = self.Button_1:cloneEx()
        self.ListView_1:pushBackCustomItem(btn)
        btn:setVisible(true)
        btn:setPositionX(0)
        btn:setTag(i)
        btn:setTitleText(GET_STRING(btnDescIndex[i]))
        btn:addTouchEventListener(handler(self, self.onButtonClick))
        table.insert(self.m_btns, btn)
    end
    -- self._root.TextField_1 = (self._root.TextField_1)
    -- self.OtherTradingBankProxy:cancelEmpty(self._root.TextField_1)
    self._root.Button_search:addTouchEventListener(handler(self, self.onSearchClick))
    self:setSelButton(1)
    self:setTip(1)
    self:setSelPanel(1)
    self:addScrollLabel()-- 跑马灯
    self._root.Panel_1:setVisible(true)
    -----求购
    self:InitRequestBuyUI()
    
end

function TradingBankBuyLayer:InitRequestBuyUI(data)
    --获取求购次数
    self.OtherTradingBankProxy:getRequestBuyCount(self, {}, function (code, data, msg)
        dump({code, data, msg},"求购次数")
        if code == 200 then 
            self:refRequestBuyCount(data.count or 0)
        else
            ShowSystemTips(msg)
        end
    end)

    self._root.Panel_requestBug:setVisible(false)
    self._root.Button_request:addClickEventListener(function ()
        if not self._requestBuyCount or self._requestBuyCount == 0 then 
            ShowSystemTips(GET_STRING(600000809))
            return 
        end
        self._root.Panel_1:setVisible(false)
        self._root.Panel_requestBug:setVisible(true)
    end)
    --职业
    self._jobDesc = { GET_STRING(600000111), GET_STRING(600000112), GET_STRING(600000113) }
    self._selType = 1
    self._root.Text_job_b:setString(self._jobDesc[self._selType])
    self._root.ImageView_job_b:setTouchEnabled(true)
    self._root.ImageView_job_b:addClickEventListener(function ()
        local size = self._root.ImageView_job_b:getContentSize()
        local worldpos = cc.p(self._root.ImageView_job_b:getWorldPosition())
        worldpos.y = worldpos.y - size.height * 0.5
        local callback = function(index)--筛选
            dump(index, "seltype___")
            if self._selType ~= index then
                self._root.Text_job_b:setString(self._jobDesc[index])
                self._selType = index
            end
        end
        local val = {
            width = size.width,
            txt = self._jobDesc,
            index = self._selType,
            pos = worldpos,
            callback = callback
        }
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyTipsLayer_Open_other, val)
    end)
    --等级 限制输入 10000
    self._root.Input_level1:onEditHandler(function(event)
        if event.name == "changed" then
            local minLevel = self._root.Input_level1:getString()
            minLevel = string.gsub(minLevel, "%s", "")
            minLevel = string.gsub(minLevel, "[^%d]", "")
            self._root.Input_level1:setString(minLevel)
            minLevel = tonumber(minLevel) or 0
            if minLevel > 10000 then 
                self._root.Input_level1:setString(10000)
            end
        end
    end)
    self._root.Input_level2:onEditHandler(function(event)
        if event.name == "changed" then
            local maxLevel = self._root.Input_level2:getString()
            maxLevel = string.gsub(maxLevel, "%s", "")
            maxLevel = string.gsub(maxLevel, "[^%d]", "")
            self._root.Input_level2:setString(maxLevel)
            maxLevel = tonumber(maxLevel) or 0
            if maxLevel > 10000 then 
                self._root.Input_level2:setString(10000)
            end
        end
    end)
    --求购金额
    self._priceMin = {0, 200, 500, 1000}
    self._priceMax = {200, 500, 1000, 9999}
    self._priceIndex = 1

    self._root.Text_price_b:setString(self:getPriceStr(self._priceIndex))
    local showPriceStr = {}
    for i, v in ipairs(self._priceMin) do
        table.insert(showPriceStr, self:getPriceStr(i))
    end
    self._root.ImageView_price_b:setTouchEnabled(true)
    self._root.ImageView_price_b:addClickEventListener(function ()
        local size = self._root.ImageView_price_b:getContentSize()
        local worldpos = cc.p(self._root.ImageView_price_b:getWorldPosition())
        worldpos.y = worldpos.y - size.height * 0.5
        local callback = function(index)--筛选
            dump(index, "_priceIndex")
            if self._priceIndex ~= index then
                self._priceIndex = index
                self._root.Text_price_b:setString(self:getPriceStr(self._priceIndex))
            end
        end
        local val = {
            width = size.width,
            txt = showPriceStr,
            index = self._priceIndex,
            pos = worldpos,
            callback = callback
        }
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyTipsLayer_Open_other, val)
    end)
    --求购发布 
    self._root.Button_request_b:addClickEventListener(function ()
        self.OtherTradingBankProxy:doTrack(self.OtherTradingBankProxy.UpLoadData.TraingReqBuyLayerPutClick)
        --等级
        local minLevel =  self._root.Input_level1:getString()
        local maxLevel =  self._root.Input_level2:getString()
        minLevel = tonumber(minLevel)
        maxLevel = tonumber(maxLevel)
        if not minLevel or not maxLevel then 
            ShowSystemTips(GET_STRING(600000806))
            return 
        end
        if minLevel > maxLevel then 
            ShowSystemTips(GET_STRING(600000807))
            return 
        end
        local val =  {
            roleType = self._selType - 1,
            minRoleLevel = minLevel,
            maxRoleLevel = maxLevel,
            minPrice = self._priceMin[self._priceIndex],
            maxPrice = self._priceMax[self._priceIndex]
        }
        self:addRequestBuyData(val)
    end)
end

--刷新求购次数
function TradingBankBuyLayer:refRequestBuyCount(count)
    self._requestBuyCount = count
    self._root.Button_request_b:setTitleText(string.format(GET_STRING(600000808), count or 0))
    self._root.Button_request:setTitleText(string.format(GET_STRING(600000808), count or 0))
end

function TradingBankBuyLayer:addRequestBuyData(val)
    self.OtherTradingBankProxy:addRequestBuyData(self, val, function (code, data, msg)
        dump({code, data, msg},"添加收购返回")
        if code == 200 then 
            ShowSystemTips(string.format(GET_STRING(600000810), data or 0))
            self:refRequestBuyCount(data or 0)
            self._root.Panel_1:setVisible(true)
            self._root.Panel_requestBug:setVisible(false)
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyRequestLayer_RefList_other)
        else
            ShowSystemTips(msg)
        end
    end)
end


function TradingBankBuyLayer:getPriceStr(index)
    if not index or not self._priceMin[index] then 
        return ""
    end
    if self._priceMin[index] == 1000 then 
        return self._priceMin[index].."以上"
    else
        return self._priceMin[index].."-"..self._priceMax[index]
    end
end

function TradingBankBuyLayer:addScrollLabel()
    self.OtherTradingBankProxy:getScrollDataItem(self, function (showStr, timeStep)
        dump({showStr,timeStep},"addScrollLabel")
        if showStr then 
            local scrolllabel = ccui.Text:create()
            self._root.Layout_bg:addChild(scrolllabel)
            scrolllabel:setPosition(cc.p(4, -30))
            scrolllabel:setAnchorPoint(cc.p(0, 0))
            scrolllabel:setFontSize(14)
            scrolllabel:setTextColor(cc.c3b(0, 0, 0))
            scrolllabel:setString(showStr)
            local sequence = cc.Sequence:create(
                cc.MoveBy:create(1.5, cc.p(0, 33)),
                cc.DelayTime:create(timeStep),
                cc.CallFunc:create(function ()
                    self:addScrollLabel()
                end),
                cc.MoveBy:create(1.5, cc.p(0, 33)),
                cc.CallFunc:create(function ()
                    scrolllabel:removeFromParent()
                end)
            )
            scrolllabel:runAction(sequence)
        end
    end)
end

function TradingBankBuyLayer:setSelPanel(index)
    if self.m_panelSel == index then
        return
    end
    self:removePanel()
    global.Facade:sendNotification(global.NoticeTable[LayerNodeOpen[index]], { parent = self._root.Node_1 })
    self.m_panelSel = index
end

function TradingBankBuyLayer:removePanel()
    for i = 1, TradingBankBuyLayer.BtnMax do
        global.Facade:sendNotification(global.NoticeTable[LayerNodeClose[i]])
    end
end

function TradingBankBuyLayer:setSelButton(index)
    local btn
    for i = 1, TradingBankBuyLayer.BtnMax do
        btn = self.m_btns[i]
        btn:setBright(index == i)
        btn:setTitleFontSize(global.isWinPlayMode and 13 or 16)
        local selColor = global.isWinPlayMode and "#e6e7a7" or "#f8e6c6"
        GUI:Button_setTitleColor(btn, index == i and selColor or "#807256")
        GUI:Button_titleEnableOutline(btn, "#111111", 2)
    end
end

function TradingBankBuyLayer:setTip(index)
    -- local str = GET_STRING(600000003 + index)
    -- local idvis = self._root.Text_tip:isVisible()
    self._root.Text_tip:setVisible(index == 1)
    self._root.Image_input:setVisible(index == 1)
    self._root.Button_search:setVisible(index == 1)
    self._root.Text_tip2:setVisible(index == 2)
    self._root.Button_request:setVisible(index == 3)
end
function TradingBankBuyLayer:onSearchClick(sender, type)
    if type ~= 2 then
        return
    end
    self.OtherTradingBankProxy:doTrack(self.OtherTradingBankProxy.UpLoadData.TraingBuyLayerSearchBtnClick)
    --搜索
    local name = self._root.TextField_1:getString()
    dump(name, "name____")
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyRoleLayer_Search_other, name)
end
function TradingBankBuyLayer:onButtonClick(sender, type)
    if type ~= 2 then
        return
    end
    local tag = sender:getTag()
    if tag == 3 then 
        self.OtherTradingBankProxy:doTrack(self.OtherTradingBankProxy.UpLoadData.TraingBuyLayerReqBuyBtnClick)
    end
    self:setSelButton(tag)
    self:setTip(tag)
    self:setSelPanel(tag)
end
function TradingBankBuyLayer:exitLayer()
    self.OtherTradingBankProxy:removeLayer(self)
end

return TradingBankBuyLayer