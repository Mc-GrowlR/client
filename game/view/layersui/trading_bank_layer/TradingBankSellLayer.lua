local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankSellLayer = class("TradingBankSellLayer", BaseLayer)
local cjson = require("cjson")
local QuickCell = requireUtil("QuickCell")
local RichTextHelp = require("util/RichTextHelp")

local equipDescName = "equipDesc"
function TradingBankSellLayer:ctor()
    TradingBankSellLayer.super.ctor(self)
    self._tradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    self._playerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    self._moneyProxy = global.Facade:retrieveProxy(global.ProxyTable.MoneyProxy)
    self._moneyType = self._moneyProxy.MoneyType
    self._equipOptState = self._tradingBankProxy:GetEquipOptState()
    self._commodityType = self._tradingBankProxy:GetCommodityType()
end

function TradingBankSellLayer.create(...)
    local ui = TradingBankSellLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankSellLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_sell")
    self._root = ui_delegate(self)

    self._root.Panel_common:setVisible(false)
    self._root.Panel_role:setVisible(false)
    self._root.Panel_money:setVisible(false)
    self._root.Panel_equip:setVisible(false)
    self._root.Text_min_price_role:setVisible(false)
    self:InitUI()
    self:SetShowCheckPhone(false)
    self:CheckSafeArea()
    
    local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingSellTabClick)

    return true
end

function TradingBankSellLayer:InitUI()

    self._root.Button_next:addClickEventListener(function()
        self:OnNext()
    end)

    self._root.Button_help:addClickEventListener(function()
        self._tradingBankProxy:reqHelpText(self, {}, function(help)
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, { callback = function(code)
                if code == 3 or code == 1 or code == 0 then
                    dump("提示退出")
                end
            end, title = help.title, notcancel = true, canmove = true, txt = help.data, btntext = { GET_STRING(600000139) } })
        end)

        local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
        TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingSellRuleClick)
        
    end)

    self._root.CheckBox_role:addEventListener(function()
        self:SetSellType(self._commodityType.Role)
        self._sellType = self._commodityType.Role
    end)

    self._root.CheckBox_money:addEventListener(function()
        -- local moneyData = self._tradingBankProxy:getMoneyData(self)
        -- if  #moneyData == 0 then
        --     ShowSystemTips(GET_STRING(600000015))
        --     self._root.CheckBox_money:setSelected(false)
        --     return
        -- end
        self:SetSellType(self._commodityType.Money)
        self._sellType = self._commodityType.Money
    end)

    self._root.CheckBox_equip:addEventListener(function()
        self:SetSellType(self._commodityType.Equip)
        self._sellType = self._commodityType.Equip
    end)

    self._root.Money_CheckBox:setVisible(false)

    self._root.TextField_role_price:onEditHandler(function(event)
        if event.name == "changed" then
            local s = event.target:getString()
            s = string.gsub(s, "%s", "")
            s = string.gsub(s, "[^%d]", "")
            event.target:setString(s)
        end
    end)

    self._root.TextField_money_count:onEditHandler(function(event)
        dump(self._sellType)
        dump(self._moneyItem, "self._moneyItem____")
        if self._sellType ~= self._commodityType.Money or #self._moneyItem == 0 then
            return
        end
        local count = self._moneyProxy:GetMoneyCountById(self._moneyItem[self._selMoneyIndex].val.coin_type_id)
        if event.name == "changed" then
            local s = event.target:getString()
            s = string.gsub(s, "%s", "")
            s = string.gsub(s, "[^%d]", "")
            event.target:setString(s)
            if not self:IsGoodNumber(s) then--数量
                s = 1
            end
            s = tonumber(s)
            if s > count then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, string.format(GET_STRING(600000168), count))
                s = count
                event.target:setString(s)
            end
            local strs2 = string.format(GET_STRING(600000190), self._min_price * s)
            self._root.Text_min_price_money:setString(strs2)
        end

    end)

    self._root.TextField_money_price:onEditHandler(function(event)
        if self._sellType ~= 2 or #self._moneyItem == 0 then
            return
        end
        local count = self._moneyProxy:GetMoneyCountById(self._moneyItem[self._selMoneyIndex].val.coin_type_id)
        if event.name == "changed" then
            local s = event.target:getString()
            s = string.gsub(s, "%s", "")
            s = string.gsub(s, "[^%d%.]", "")
            event.target:setString(s)
            if not self:IsGoodNumber(s) then--价格
                s = 1
            end
            s = tonumber(s)
            if s > 10000000 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000165))
                s = 10000000
                event.target:setString(s)
            end
        end
    end)

    self._tradingBankProxy:cancelEmpty(self._root.TextField_target_money)
    -----加mask 
    self:AddMask(self._root.TextField_money_count, self._root.money_count_mask)
    self:AddMask(self._root.TextField_money_price, self._root.money_price_mask)
    self:AddMask(self._root.TextField_target_money, self._root.target_money_mask)
    self:AddMask(self._root.TextField_target_role, self._root.target_role_mask)

    -------买家是否可以还价
    self:InitBargain(self._root.Panel_bargain_role)
    self:InitBargain(self._root.Panel_bargain_money)
    -------
    ---最低售价
    self._root.Text_min_price_role:setVisible(false)
    self._root.Button_tips:addTouchEventListener(function(sender, type)
        if type ~= 2 then
            return
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open, { noclose = 1,
        callback = function(code)
            if code == 1 then
                self._root.Panel_role:setVisible(true)
                self._root.Panel_common:setVisible(true)
                self._root.Text_tips:setVisible(false)
                self._root.Button_tips:setVisible(false)
                self:ReqSellConfig()
            end
        end
        })
    end)
    self._root.Text_sxf1:setVisible(false)
    self._root.Text_sxf2:setVisible(false)
    self._root.Text_roleName:setString(string.format(GET_STRING(600000191), self._playerProperty:GetName()))

    --装备
    self._root.good_item:setVisible(false)
    self._root.bag_item:setVisible(false)
    local bagDesc = RichTextHelp:CreateRichTextWithXML(GET_STRING(600000607), 250)
    bagDesc:formatText()
    local title2Size = self._root.Image_title2:getContentSize()
    self._root.Image_title2:addChild(bagDesc)
    bagDesc:setPosition(title2Size.width / 2, title2Size.height / 2)
    self:RefEquipNumLabel(0)
end

function TradingBankSellLayer:CheckSafeArea()
    local MapProxy = global.Facade:retrieveProxy( global.ProxyTable.Map )
    if not MapProxy:IsInSafeArea() then--安全区才能打开
        local text = GET_STRING(600000171)
        self._tradingBankProxy:getTxtConf(self, {}, function(success, response, code)
            dump({ success, response, code }, "getTxtConf__")
            if success then
                local resData = cjson.decode(response)
                if resData.code == 200 then
                    text = (resData.data and resData.data.sale) or ""
                end
            end
            ShowSystemTips(text)
        end)
    else 
        self:ReqSellConfig()
    end
end

function TradingBankSellLayer:InitBargain(node)
    node._isSelect = true
    local CheckBox_true = node:getChildByName("CheckBox_true")
    local CheckBox_false = node:getChildByName("CheckBox_false")
    CheckBox_true:setSelected(true)
    CheckBox_true:addEventListener(function()
        node._isSelect = true
        local select = CheckBox_true:isSelected()
        if select then
            CheckBox_false:setSelected(false)
        end
    end)
    CheckBox_false:addEventListener(function()
        node._isSelect = false
        local select = CheckBox_false:isSelected()
        if select then
            CheckBox_true:setSelected(false)
        end
    end)
end

function TradingBankSellLayer:AddMask(node, mask)
    local x = node:getPositionX()
    node.xxx = x
    node:setPositionX(-1000000)
    mask:addTouchEventListener(function(sender, state)
        if state == 2 then
            local caninput = true
            if self._sellType == self._commodityType.Money and #self._moneyItem > 0 then
                local count = self._moneyProxy:GetMoneyCountById(self._moneyItem[self._selMoneyIndex].val.coin_type_id)
                if count == 0 then
                    global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000164))
                    caninput = false
                end
            end
            if caninput then
                node:setPositionX(x)
                node:touchDownAction(node, 2)
            end
        end
    end)
    if not self._maskEdit then
        self._maskEdit = {}
    end
    table.insert(self._maskEdit, node)
end
function TradingBankSellLayer:ResetEditPosx()
    if self._maskEdit then
        for i, v in ipairs(self._maskEdit) do
            v:setPositionX(-1000000)
        end
    end
end
function TradingBankSellLayer:ReqSellConfig()
    self._tradingBankProxy:reqSellConfig(self, {}, function(success, response, code)
        dump({ success, response, code }, "ReqSellRoleConfig___")
        if success then
            local resData = cjson.decode(response)
            if resData.code == 200 then
                resData = resData.data
                self._role_sell_switch = resData.role_sell_switch and resData.role_sell_switch == 1
                self._coin_sell_switch = resData.coin_sell_switch and resData.coin_sell_switch == 1
                self._equip_sell_switch = resData.equip_sell_switch and resData.equip_sell_switch == 1

                if self._role_sell_switch or self._coin_sell_switch or self._equip_sell_switch then
                    self._role_minprice = resData.role_min_price
                    self._service_percent = resData.service_percent --手续费
                    self._equip_max_sell_num = resData.equip_sell_num --装备最大寄售数量
                    local timeDesc = resData.buy_desc or GET_STRING(600000630)
                    self._root.Text_time_desc:setString(timeDesc)

                    self:InitChargeAndMinPrice()
                    self:InitCheckItem()
                    if self._role_sell_switch then
                        self:SetSellType(self._commodityType.Role)
                        self._sellType = self._commodityType.Role
                    elseif self._coin_sell_switch then
                        self:SetSellType(self._commodityType.Money)
                        self._sellType = self._commodityType.Money
                    elseif self._equip_sell_switch then
                        self:SetSellType(self._commodityType.Equip)
                        self._sellType = self._commodityType.Equip
                    end
                else
                    ShowSystemTips(GET_STRING(600000609))
                end
            elseif resData.code >= 50000 and resData.code <= 50020 then--token失效
                self:SetShowCheckPhone(true)
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open, { noclose = 1,
                callback = function(code)
                    if code == 1 then
                        self:SetShowCheckPhone(false)
                        self:ReqSellConfig()
                    end
                end
                })
            else
                global.Facade:sendNotification(global.NoticeTable.SystemTips, resData.msg or "")
            end
        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000137))
        end
    end)
end

function TradingBankSellLayer:InitCheckItem()
    local x1 = self._root.CheckBox_role:getPositionX()
    local x2 = self._root.CheckBox_money:getPositionX()
    local x3 = self._root.CheckBox_equip:getPositionX()
    local x = { x1, x2, x3 }
    local showCheck = {}
    if self._role_sell_switch then
        table.insert(showCheck, self._root.CheckBox_role)
    else
        self._root.CheckBox_role:setVisible(false)
    end

    if self._coin_sell_switch then
        table.insert(showCheck, self._root.CheckBox_money)
    else
        self._root.CheckBox_money:setVisible(false)
    end

    if self._equip_sell_switch then
        table.insert(showCheck, self._root.CheckBox_equip)
    else
        self._root.CheckBox_equip:setVisible(false)
    end
    for i, v in ipairs(showCheck) do
        v:setPositionX(x[i])
    end
end

function TradingBankSellLayer:GetAccountfo(name, func)
    self._tradingBankProxy:reqAccountInfo(self, { account = name }, function(success, response, code)
        dump({ success, response, code }, "GetAccountfo")
        if success then
            local resData = cjson.decode(response)
            if resData.code == 200 then
                func()
            else

                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, { callback = function(code)
                end, notcancel = true, txt = GET_STRING(600000176), btntext = { GET_STRING(600000139) } })
            end
        end
    end)
end

function TradingBankSellLayer:GetRoleInfo(name, func)
    self._tradingBankProxy:reqRoleInfo(self, { role_name = name }, function(success, response, code)
        dump({ success, response, code }, "getRoleInfo___")
        if success then
            local resData = cjson.decode(response)
            if resData.code == 200 then
                func()
            else
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, { callback = function(code)
                end, notcancel = true, txt = GET_STRING(600000175), btntext = { GET_STRING(600000139) } })
            end
        end
    end)
end

function TradingBankSellLayer:RefEquipUI()
    self:RefBagEquip()
    self:ReqgetEquipGoodsInfo()
end

function TradingBankSellLayer:RefBagEquip()
    self._bagCells = {}
    self._bagData = {}
    self:RefreshBagData()
    local bagProxy        = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    self._root.ScrollView_bagList:removeAllChildren()
    local itemSize = self._root.bag_item:getContentSize()
    local wid = itemSize.width
    local hei = itemSize.height
    local total = bagProxy:GetMaxBag()
    for i = 1, total do
        local cell_data = {}
        cell_data.wid = wid
        cell_data.hei = hei
        cell_data.createCell = function()
            local cell = self:CreateBagCell(i)
            return cell.nativeUI
        end
        local cell = QuickCell:Create(cell_data)
        table.insert(self._bagCells, cell)
        self._root.ScrollView_bagList:addChild(cell)
    end
    local col = 4
    local row = math.ceil(total / col)
    local marginX = 4
    local marginY = 3
    local innerWid = self._root.ScrollView_bagList:getContentSize().width
    local innerHei = hei * row + marginY * (row - 1)
    self._root.ScrollView_bagList:setInnerContainerSize(cc.size(innerWid, innerHei))
    for index, v in ipairs(self._bagCells) do
        local iRow = math.ceil(index / col)
        local iCol = (index - 1) % col
        local posX = (wid + marginX) * iCol
        local posY = innerHei - hei * iRow - (iRow - 1) * marginY
        v:setPosition(cc.p(posX, posY))
    end
end

function TradingBankSellLayer:CheckConditions(itemData)
    local res = true
    --30天内寄售过的不能寄售
    if itemData.AddValues then
        for k, v in pairs(itemData.AddValues) do
            if v.Id == 15 then
                if GetServerTime() < v.Value then
                    res = false
                end
                break
            end
        end
    end
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local bindArticleType    = ItemConfigProxy:GetBindArticleType()
    local isBind, isSelf, isMeetType = CheckItemisBind(itemData, bindArticleType.TYPE_NOSTALL)
    if  isMeetType then 
        res = false
    end
    return res
end

function TradingBankSellLayer:CreateBagCell(i)
    local item = self._root.bag_item:cloneEx()
    item:setVisible(true)
    local ui = ui_delegate(item)
    local itemData = self._bagData[i]
    if itemData then
        local goodsItem = GoodsItem:create({ index = itemData.Index, itemData = itemData })
        item:addChild(goodsItem)
        local size = item:getContentSize()
        goodsItem:setPosition(size.width / 2, size.height / 2)

        goodsItem:addTouchEventListener(function()--长按
            local param = { typeID = itemData.typeId, itemData = itemData, isHideFrom = true }
            global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, param)
        end, 1)

        goodsItem:addTouchEventListener(function()--点击上架
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankUpModifyEquipPanel_Open, { type = self._equipOptState.Sell, itemData = itemData })

            local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
            TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingSellEquipGoodsClickUp)
        end, 2)
    end
    return ui
end

function TradingBankSellLayer:RefreshBagData()
    local bagProxy        = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local quickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
    local bagData        = bagProxy:GetBagData()
    local quickData    = quickUseProxy:GetQuickUseData()

    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local articleType    = ItemConfigProxy:GetArticleType()
    local checkArticleType = {[articleType.TYPE_TRADE_AUCTIONA] = true }

    for _, vItem in pairs(quickData) do
        if not ItemConfigProxy:GetItemArticle(vItem.Index, checkArticleType)
        and self:CheckConditions(vItem) then
            table.insert(self._bagData, vItem)
        end
    end
    for _, vItem in pairs(bagData) do
        if not ItemConfigProxy:GetItemArticle(vItem.Index, checkArticleType)
        and self:CheckConditions(vItem) then
            table.insert(self._bagData, vItem)
        end
    end
end

function TradingBankSellLayer:UpdateBag()
    if self._sellType ~= self._commodityType.Equip then 
        return 
    end
    if not self._bagCells then 
        return 
    end
    self._bagData = {}
    for k, v in ipairs(self._bagCells) do
        v:Exit()
        v:Refresh()
    end
    self:RefreshBagData()
    for k, v in ipairs(self._bagData) do
        if self._bagCells[k] then
            local cell = self._bagCells[k]
            cell:Exit()
            cell:Refresh()
        end
    end
end

function TradingBankSellLayer:ReqgetEquipGoodsInfo()
    if self._sellType ~= self._commodityType.Equip then 
        return 
    end
    local val = {
        page = 1,
        pagenum = self._equip_max_sell_num,
        commodity_type = self._commodityType.Equip
    }
    self._tradingBankProxy:getMyGoodsInfo(self, val, handler(self, self.ResMyGoodsInfo))
end

function TradingBankSellLayer:ResMyGoodsInfo(success, response, code)
    dump({ success, response, code }, "ResMyGoodsInfo_")
    if success then
        local data = cjson.decode(response)
        if data.code == 200 then
            data = data.data
            self._goodListData = data.data or {}
            dump(self._goodListData, "listdata__")
            self:RefGoodListEquip()
            self:RefEquipNumLabel(#self._goodListData)
        elseif data.code >= 50000 and data.code <= 50020 then--token失效
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open)
        else
        end
    end
end

function TradingBankSellLayer:RefGoodListEquip()
    self._goodCells = {}
    self._root.ScrollView_goodList:removeAllChildren()
    local itemSize = self._root.good_item:getContentSize()
    local wid = itemSize.width
    local hei = itemSize.height
    local total = self._equip_max_sell_num
    for i = 1, total do
        local cell_data = {}
        cell_data.wid = wid
        cell_data.hei = hei
        cell_data.createCell = function()
            local cell = self:CreateGoodCell(i)
            return cell.nativeUI
        end
        local cell = QuickCell:Create(cell_data)
        table.insert(self._goodCells, cell)
        self._root.ScrollView_goodList:addChild(cell)
    end
    local col = 2
    local row = math.ceil(total / col)
    local marginX = 4
    local marginY = 3
    local contentSize = self._root.ScrollView_goodList:getContentSize()
    local innerWid = contentSize.width
    local innerHei = math.max(hei * row + marginY * (row - 1), contentSize.height)
    self._root.ScrollView_goodList:setInnerContainerSize(cc.size(innerWid, innerHei))
    for index, v in ipairs(self._goodCells) do
        local iRow = math.ceil(index / col)
        local iCol = (index - 1) % col
        local posX = (wid + marginX) * iCol
        local posY = innerHei - hei * iRow - (iRow - 1) * marginY
        v:setPosition(cc.p(posX, posY))
    end
end

function TradingBankSellLayer:CreateGoodCell(i)
    local item = self._root.good_item:cloneEx()
    item:setVisible(true)
    local ui = ui_delegate(item)
    local goodData = self._goodListData[i]
    if goodData then
        ui.Image_add:setVisible(false)
        ui.Text_empty:setVisible(false)
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        local itemData = ItemConfigProxy:GetItemDataByIndex(goodData.equip_id)
        local goodparam = {index = goodData.equip_id}
        if goodData.equip_num and goodData.equip_num > 1 then 
            goodparam.count = goodData.equip_num
        end
        local goodsItem = GoodsItem:create(goodparam)
        ui.Image_goodBg:addChild(goodsItem)
        local size = ui.Image_goodBg:getContentSize()
        goodsItem:setPosition(size.width / 2, size.height / 2)

        local color = (itemData.Color and itemData.Color > 0) and itemData.Color or 255
        local name = itemData.Name or ""
        -- 道具名字
        ui.Text_name:setString(name)
        ui.Text_name:setTextColor(SL:GetColorByStyleId(color))
        ui.Text_state:setString(goodData.status_ch)
        goodsItem:addTouchEventListener(function()--点击tips
            self._tipsIndex = self._tradingBankProxy:GetTipsIndex() 
            self._tipsPos = ui.Image_goodBg:getWorldPosition()
            self._tradingBankProxy:ReqQueryItemData(goodData.id, self._tipsIndex)
        end, 2)

        ui.Text_price:setString(goodData.price .. GET_STRING(600000628))
    else
        ui.Text_name:setVisible(false)
        ui.Text_price_desc:setVisible(false)
        ui.Text_state:setVisible(false)
        ui.Text_price:setVisible(false)

    end
    return ui
end

function TradingBankSellLayer:OnTips(data)
    local itemData = data.itemData
    local tipsIndex = data.tipsIndex
    if self._tipsIndex == tipsIndex then 
        local param = {itemData = itemData, isHideFrom = true, pos = self._tipsPos}
        global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, param)
    end
end

function TradingBankSellLayer:RefEquipNumLabel(num)
    local equipDesc = self._root.Image_title1:getChildByName(equipDescName)
    if equipDesc then
        equipDesc:removeFromParent()
    end
    equipDesc = RichTextHelp:CreateRichTextWithXML(string.format(GET_STRING(600000608), num, self._equip_max_sell_num or 0), 250)
    equipDesc:formatText()
    equipDesc:setName(equipDescName)
    local title1Size = self._root.Image_title1:getContentSize()
    self._root.Image_title1:addChild(equipDesc)
    equipDesc:setPosition(title1Size.width / 2, title1Size.height / 2)
end

function TradingBankSellLayer:InitMoneyUI()
    local moneyData = self._tradingBankProxy:getMoneyData(self) or {}
    local refMoneyList = function()
        moneyData = self._tradingBankProxy:getMoneyData(self) or {}
        self._moneyItem = {}
        self._selMoneyIndex = 1
        local size = self._root.Money_CheckBox:getContentSize()
        local itemnum = #moneyData
        local size2 = self._root.ScrollView_money:getContentSize()
        local yy = math.ceil(itemnum / 2)
        local contentH = math.max(yy * size.height, 60)
        self._root.ScrollView_money:setInnerContainerSize(cc.size(size2.width, contentH))
        for i, v in ipairs(moneyData) do
            local count = self._moneyProxy:GetMoneyCountById(v.coin_type_id)
            local name = v.coin_type_name
            local item = self._root.Money_CheckBox:cloneEx()
            local Text_money = item:getChildByName("Text_money")
            local CheckBox = item:getChildByName("CheckBox")
            CheckBox:setSelected(i == 1)
            Text_money:setString(string.format(GET_STRING(600000100), name, count))
            item:setVisible(true)
            item:setTag(i)
            item:addTouchEventListener(handler(self, self.OnCheckMoney))
            item:addTo(self._root.ScrollView_money)
            local yy = math.ceil(i / 2)
            local xx = (i - 1) % 2
            local x = xx * (size.width + 5)
            local y = contentH - (yy - 1) * size.height
            dump({ x, y }, "pos___")
            item:setPosition(x, y)
            item.val = v
            table.insert(self._moneyItem, item)
        end
        local price = self._moneyItem[self._selMoneyIndex] and tonumber(self._moneyItem[self._selMoneyIndex].val.coin_min_price) or 0
        self._min_price = price
        local str = string.format(GET_STRING(600000172), self:GetRealNum(price))
        self._root.Text_most2:setString(str)
        -- --最低出售数量
        local count = self._moneyItem[self._selMoneyIndex] and tonumber(self._moneyItem[self._selMoneyIndex].val.coin_min_sell_count) or 0
        self._root.Text_min_count_money:setString(string.format(GET_STRING(600000174), count))
    end

    if #moneyData == 0 then
        self._tradingBankProxy:reqMoneyData(self, function()
            refMoneyList()
        end)
    else
        refMoneyList()
    end
end

--初始化手续费 和 最低价格
function TradingBankSellLayer:InitChargeAndMinPrice()
    self._root.Text_min_price_role:setVisible(true)
    local str = string.format(GET_STRING(600000117), self._role_minprice)
    self._root.Text_min_price_role:setString(str)
    local sxf = string.format(GET_STRING(600000189), self._service_percent)
    self._root.Text_sxf1:setString(sxf)
    self._root.Text_sxf2:setString(sxf)
    self._root.Text_sxf1:setVisible(true)
    self._root.Text_sxf2:setVisible(true)
    self:OnRefreshSVIPTitle()--请求svip
end

--设置上架类型
function TradingBankSellLayer:SetSellType(type)
    self:ResetEditPosx()

    self._root.Panel_common:setVisible(true)
    self._root.Panel_role:setVisible(type == self._commodityType.Role)
    self._root.Panel_money:setVisible(type == self._commodityType.Money)
    self._root.Panel_equip:setVisible(type == self._commodityType.Equip)

    self._root.CheckBox_role:setSelected(type == self._commodityType.Role)
    self._root.CheckBox_money:setSelected(type == self._commodityType.Money)
    self._root.CheckBox_equip:setSelected(type == self._commodityType.Equip)

    self._root.Button_next:setVisible(type ~= self._commodityType.Equip)

    local Box996Proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
    if type == self._commodityType.Role then
        self._root.Button_next:setTitleText(GET_STRING(600000160))
        self._root.TextField_target_role:setString("")
        Box996Proxy:requestLogUp(Box996Proxy.OTHER_UP_EVEIT[106])
    elseif type == self._commodityType.Money then
        if not self._selMoneyIndex then
            self:InitMoneyUI()
        end
        self._root.Button_next:setTitleText(GET_STRING(600000161))
        self._root.TextField_target_money:setString("")
        Box996Proxy:requestLogUp(Box996Proxy.OTHER_UP_EVEIT[107])
    elseif type == self._commodityType.Equip then
        self:RefEquipUI()
    end
end
--设置是否显示检测手机
function TradingBankSellLayer:SetShowCheckPhone(show)
    self._root.Text_tips:setVisible(show)
    self._root.Button_tips:setVisible(show)
end
--设置货币类型
function TradingBankSellLayer:OnCheckMoney(sender, type)
    if type ~= 2 then
        return
    end
    local tag = sender:getTag()
    for i, v in ipairs(self._moneyItem) do
        local CheckBox = v:getChildByName("CheckBox")
        CheckBox:setSelected(i == tag)
    end
    self._selMoneyIndex = tag
    local count = self._moneyProxy:GetMoneyCountById(self._moneyItem[self._selMoneyIndex].val.coin_type_id)
    if count == 0 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000164))
    end
    self._root.TextField_money_count:setString("")
    self._root.Text_min_price_money:setString(string.format(GET_STRING(600000190), ""))
    self:ResetEditPosx()
    local num = self._root.TextField_money_count:getString()

    if not self:IsGoodNumber(num) then--数量
        num = 1
    end

    local price = tonumber(self._moneyItem[self._selMoneyIndex].val.coin_min_price)
    self._min_price = price
    local str = string.format(GET_STRING(600000172), self:GetRealNum(price))
    self._root.Text_most2:setString(str)


    local count = self._moneyItem[self._selMoneyIndex] and tonumber(self._moneyItem[self._selMoneyIndex].val.coin_min_sell_count) or 0
    self._root.Text_min_count_money:setString(string.format(GET_STRING(600000174), count))
end

--
function TradingBankSellLayer:OnNext()
    if self._sellType == self._commodityType.Role then
        local account = self._root.TextField_target_role:getString()
        if string.len(account) == 0 then
            self:OnRole()
        else
            self:GetAccountfo(account, handler(self, self.OnRole))
        end

        local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
        TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingSellRoleNextClick)
    elseif self._sellType == self._commodityType.Money then
        local name = self._root.TextField_target_money:getString()
        if string.len(name) == 0 then
            self:OnMoney()
        else
            self:GetRoleInfo(name, handler(self, self.OnMoney))
        end

        local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
        TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingSellMoneyUpClick)
    end
end

function TradingBankSellLayer:OnMoney()
    local num = self._root.TextField_money_count:getString()
    local price = self._root.TextField_money_price:getString()
    local target_rolename = self._root.TextField_target_money:getString()
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
    if #self._moneyItem == 0 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000186))
        return
    end
    local name = self._moneyItem[self._selMoneyIndex].val.coin_type_name or ""
    local coin_id = self._moneyItem[self._selMoneyIndex].val.coin_type_id
    if not self:IsGoodNumber(price) then--价格
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000116))
        return
    end
    if string.find(price, "%.") then--价格必须为整数
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000196))
        return
    end
    -- price 
    -- target_rolename
    -- coin_num
    -- coin_id
    -- bargain_switch 是否能还价
    local data2 = {
        price = tonumber(price),
        target_rolename = target_rolename,
        coin_num = tonumber(num),
        coin_id = coin_id,
        bargain_switch = self._root.Panel_bargain_money._isSelect and 1 or 0
    }
    self:SellMoney(data2, function()
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankFrame_Open, { id = global.LayerTable.TradingBankGoodsLayer })

    end)

end
function TradingBankSellLayer:UserCoinSell(func)
    self._tradingBankProxy:userCoinSell(self, {}, function(success, response, code)
        if success then
            local resData = cjson.decode(response)
            if resData.code == 200 then
                func()
            elseif resData.code >= 50000 and resData.code <= 50020 then--token失效
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open,{ callback = function(code)
                    if code == 1 then
                        self:UserCoinSell(func)
                    end
                end})
            else
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, {
                    callback = function(code)
                        if code == 1 then
                            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankFrame_Open, { id = global.LayerTable.TradingBankGoodsLayer })
                        end
                    end,
                    notcancel = true, txt = resData.msg or "", btntext = { GET_STRING(600000182), GET_STRING(600000139) }
                })
            end
        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000181))
        end

    end)
end
function TradingBankSellLayer:OnRole()
    self:UserCoinSell(function()
        local pirce = self._root.TextField_role_price:getString()
        local target_rolename = self._root.TextField_target_role:getString()
        target_rolename = string.len(target_rolename) > 0 and target_rolename or nil
        dump(self._role_minprice)
        self._role_minprice = self._role_minprice or 0
        if self:IsGoodNumber(pirce) then--价格
            if tonumber(pirce) < tonumber(self._role_minprice) then

                global.Facade:sendNotification(global.NoticeTable.SystemTips, string.format(GET_STRING(600000117), self._role_minprice))
                return
            end
        else--
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000116))
            return
        end
        --bargain_switch 是否能还价
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCaptureLayer_Open, { price = tonumber(pirce), target_account = target_rolename, bargain_switch = self._root.Panel_bargain_role._isSelect and 1 or 0 })--卖角色是输入对方账号
    end)

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

--卖金币
function TradingBankSellLayer:SellMoney(val, func)
    local coin_name = self._moneyItem[self._selMoneyIndex].val.coin_type_name or ""
    local txt = string.format(GET_STRING(600000169), val.price, val.coin_num, coin_name)
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, { callback = function(code)
        if code == 2 then
            self._tradingBankProxy:sellMoney(self, val, function(success, response, code)
                if success then
                    local resData = cjson.decode(response)
                    if resData.code == 200 then
                        --global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000118))
                        if func then
                            func()
                        end
                        global.Facade:sendNotification(global.NoticeTable.SystemTips, resData.msg or "")
                    elseif resData.code >= 50000 and resData.code <= 50020 then--token失效
                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open)
                    else
                        global.Facade:sendNotification(global.NoticeTable.SystemTips, resData.msg or "")
                    end
                else
                    global.Facade:sendNotification(GET_STRING(600000119))
                end
            end)
        end
    end, txt = txt, btntext = { GET_STRING(600000170), GET_STRING(600000161) } })
end

function TradingBankSellLayer:ExitLayer()
    self._tradingBankProxy:removeLayer(self)
end

function TradingBankSellLayer:OnRefreshSVIPTitle(data)
    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
    if not data then
        if proxy:IsShowSVIP() then
            proxy:requestSVIPLevel()
        end
        return
    end

    if data.isSvipLevel then
        local svipData = data.data
        local svipLevel = tonumber(svipData.svipLevel) or 0
        if svipLevel >= 1 and svipData.state == 1 then
            local desc = string.format(GET_STRING(600000326), self._service_percent, svipLevel)
            self._root.Text_sxf1:setString(desc)
            self._root.Text_sxf2:setString(desc)
        end
    end
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
return TradingBankSellLayer