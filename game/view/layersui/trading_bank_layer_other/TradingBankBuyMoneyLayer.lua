local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankBuyMoneyLayer = class("TradingBankBuyMoneyLayer", BaseLayer)
local QuickCell = requireUtil("QuickCell")
local cjson = require("cjson")
local moneyData
function TradingBankBuyMoneyLayer:ctor()
    TradingBankBuyMoneyLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankBuyMoneyLayer.create(...)
    local ui = TradingBankBuyMoneyLayer.new()
    if ui and ui:Init(...) then
        return ui
    end

    return nil
end
function TradingBankBuyMoneyLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_buy_money")
    self._root = ui_delegate(self)
    self.m_page = 1
    self.m_maxpage = 1
    self.m_pagenum = 10
    self.m_data = {}
    self.m_selType = 1
    self.m_order_price = nil
    self.m_order_level = nil
    self._root.Panel_item:setVisible(false)
    self.OtherTradingBankProxy:reqMoneyData(self, function(code, data, msg)
        if code == 200 then
            moneyData = data
            self:InitUI(data)
            local val = {
                type = 2, --货币
                page = self.m_page,
                pagenum = self.m_pagenum,
            }
            self:ReqgetGoodsInfo(val, handler(self, self.refListView))
        else
            ShowSystemTips(msg)
        end
    end)


    return true
end
function TradingBankBuyMoneyLayer:InitUI(data)
    self._root.ListView_2:addScrollViewEventListener(function(sender, event)
        local itemnum = #sender:getItems()
        local Bottomitem = sender:getBottommostItemInCurrentView()
        local lastitem = sender:getItem(itemnum - 1)
        if (event == 1 or (event == 10 and lastitem == Bottomitem)) and self.m_page < self.m_maxpage and not self.m_reqState then
            local coin_id
            if self.m_selType ~= 1 then
                coin_id = moneyData[self.m_selType - 1].id
            end
            local val = {
                type = 2,
                page = self.m_page + 1,
                pagenum = self.m_pagenum,
                order_price = self.m_order_price,
                order_coin_num = self.m_order_num,
                coin_config_id = coin_id

            }
            self:ReqgetGoodsInfo(val, handler(self, self.refListView))
        end
    end)
    self._root.Panel_type2:addTouchEventListener(function(sender, type)
        if type ~= 2 then
            return
        end
        local size = self._root.Panel_type2:getContentSize()
        local txt = { GET_STRING(600000110) }
        for i, v in ipairs(moneyData) do
            table.insert(txt, v.coinTypeName)
        end
        -- local txt = {GET_STRING(600000110),GET_STRING(600000111),GET_STRING(600000112),GET_STRING(600000113)}
        local worldpos = cc.p(self._root.Panel_type2:getWorldPosition())
        worldpos.y = worldpos.y - size.height

        local callback = function(index)
            dump(index, "seltype___")
            if self.m_selType ~= index then
                self._root.Text_type2:setString(txt[index])
                self.m_selType = index
                self.m_page = 1
                self.m_maxpage = 1
                self.m_order_price = nil
                self.m_order_num = nil
                self._root.ListView_2:removeAllChildren()
                local coin_id
                if self.m_selType ~= 1 then
                    coin_id = moneyData[self.m_selType - 1].id
                end
                local val2 = {
                    type = 2, --角色
                    page = self.m_page,
                    pagenum = self.m_pagenum,
                    coin_config_id = coin_id,
                }

                self:ReqgetGoodsInfo(val2, handler(self, self.refListView))
            end
        end
        local val = {
            width = size.width,
            txt = txt,
            index = self.m_selType,
            pos = worldpos,
            callback = callback
        }
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyTipsLayer_Open_other, val)
    end)
    self._root.Panel_num2:addTouchEventListener(function(sender, type)--num排序
        if type ~= 2 then
            return
        end
        if self.m_order_num == "asc" then
            self.m_order_num = "desc"
        else
            self.m_order_num = "asc"
        end
        self.m_order_price = nil
        self.m_page = 1
        self.m_maxpage = 1
        self._root.ListView_2:removeAllChildren()
        local coin_id
        if self.m_selType ~= 1 then
            coin_id = moneyData[self.m_selType - 1].id
        end
        local val2 = {
            type = 2, --角色
            page = self.m_page,
            pagenum = self.m_pagenum,
            coin_config_id = coin_id,
            -- order_price = self.m_order_price,
            order_coin_num = self.m_order_num
        }
        self:ReqgetGoodsInfo(val2, handler(self, self.refListView))

    end)
    self._root.Panel_price2:addTouchEventListener(function(sender, type)--等级价格
        if type ~= 2 then
            return
        end
        if self.m_order_price == "asc" then
            self.m_order_price = "desc"
        else
            self.m_order_price = "asc"
        end
        self.m_order_num = nil
        self.m_page = 1
        self.m_maxpage = 1
        self._root.ListView_2:removeAllChildren()
        local coin_id
        if self.m_selType ~= 1 then
            coin_id = moneyData[self.m_selType - 1].id
        end
        local val2 = {
            type = 2, --角色
            page = self.m_page,
            pagenum = self.m_pagenum,
            coin_config_id = coin_id,
            order_price = self.m_order_price,
        -- order_coin_num = self.m_order_num
        }
        self:ReqgetGoodsInfo(val2, handler(self, self.refListView))
    end)

end
function TradingBankBuyMoneyLayer:ReqgetGoodsInfo(val, func)
    self.m_reqState = true
    self.OtherTradingBankProxy:getGoodsInfo(self, val, func)
end
function TradingBankBuyMoneyLayer:refListView(code, data, msg)
    dump({ code, data, code }, "refListView__")
    self.m_reqState = false
    if code == 200 then
        self.m_page = data.current
        self.m_maxpage = data.pages
        local listdata = data.records or {}
        dump(listdata, "listdata__")
        local lastIndex = #self._root.ListView_2:getItems() - 1
        for i, v in ipairs(listdata) do
            local itemSize = self._root.Panel_item:getContentSize()
            local cell_data = {}
            cell_data.wid = itemSize.width
            cell_data.hei = itemSize.height
            cell_data.anchor = cc.p(0.5, 1)
            cell_data.tick_interval = 0.05
            cell_data.createCell = function()
                local cell = self:createItem(v)
                return cell
            end
            local item = QuickCell:Create(cell_data)


            -- local item = self:createItem(v)
            self._root.ListView_2:pushBackCustomItem(item)
        end
        self._root.ListView_2:jumpToItem(lastIndex, cc.p(0, 0), cc.p(0, 0))
    else
        ShowSystemTips(msg)
    end
end
function TradingBankBuyMoneyLayer:createItem(data)
    dump(data,"createItem____")
    local item = self._root.Panel_item:cloneEx()
    item:setVisible(true)

    local Image_item = item:getChildByName("Image_item")
    local Text_goodname = item:getChildByName("Text_goodname")
    local Text_name = item:getChildByName("Text_name")
    local Text_num = item:getChildByName("Text_num")
    local Text_pirce = item:getChildByName("Text_pirce")
    local Button_buy = item:getChildByName("Button_buy")
    --local Image_head = Image_item:getChildByName("Image_head")
    Text_goodname:setString(data.coinConfigTypeName or "")
    Text_name:setString(data.role or "")
    Text_pirce:setString(data.price or "0")
    Text_num:setString(data.coinNum or "0")
    --Image_head:loadTexture(global.MMO.PATH_RES_PRIVATE.."trading_bank/img_cost.png")
    local call = function(...)
        self._root.ListView_2:removeAllChildren()
        self.m_page = 1
        local coin_id
        if self.m_selType ~= 1 then
            coin_id = moneyData[self.m_selType - 1].id
        end
        local val = {
            type = 2, --货币
            page = self.m_page,
            pagenum = self.m_pagenum,
            coin_config_id = coin_id,
            order_price = self.m_order_price,
            order_coin_num = self.m_order_num,
        }
        self:ReqgetGoodsInfo(val, handler(self, self.refListView))
    end

    local callback = function()
        local val = {}
        val.txt = GET_STRING(600000447)--
        val.btntext = { GET_STRING(600000139) }
        val.callback = function(res)
            if res == 1 then
                call()
            end
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, val)
    end
    Button_buy:addClickEventListener(function(sender, type)
        self.OtherTradingBankProxy:doTrack(self.OtherTradingBankProxy.UpLoadData.TraingBuyLayerBuyBtnClick)
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFLayer_Open_other, {data = data ,callback = callback})
    end)
    return item
end

function TradingBankBuyMoneyLayer:exitLayer()
    self.OtherTradingBankProxy:removeLayer(self)
end

return TradingBankBuyMoneyLayer