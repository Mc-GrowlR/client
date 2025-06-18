local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankBuyMeLayer = class("TradingBankBuyMeLayer", BaseLayer)
local QuickCell = requireUtil("QuickCell")
local cjson = require("cjson")
--废弃
function TradingBankBuyMeLayer:ctor()
    TradingBankBuyMeLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    self.TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
end

function TradingBankBuyMeLayer.create(...)
    local ui = TradingBankBuyMeLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end
function TradingBankBuyMeLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_buy_me")
    self._root = ui_delegate(self)
    self.m_page = 1
    self.m_maxpage = 1
    self.m_pagenum = 10
    self.m_data = {}
    self.m_selType = 1 -- 1全部 2 角色 3货币
    self.m_order_price = nil
    self:InitUI(data)
    local val = {
        page = self.m_page,
        pagenum = self.m_pagenum
    }
    self:ReqgetTargetGoodsInfo(val, handler(self, self.refListView))

    self.m_buyType = 1 --1角色 2 货币
    return true
end
function TradingBankBuyMeLayer:InitUI(data)
    self._root.Panel_item:setVisible(false)
    self._root.ListView_2:addScrollViewEventListener(function(sender, event)
        local itemnum = #sender:getItems()
        local Bottomitem = sender:getBottommostItemInCurrentView()
        local lastitem = sender:getItem(itemnum - 1)
        if (event == 1 or (event == 10 and lastitem == Bottomitem)) and self.m_page < self.m_maxpage and not self.m_reqState then
            self.m_reqState = true
            local seltype = {[1] = nil, [2] = 1, [3] = 2 }
            local val = {
                type = seltype[self.m_selType],
                page = self.m_page + 1,
                pagenum = self.m_pagenum,
                order_price = self.m_order_price
            }
            self:ReqgetTargetGoodsInfo(val, handler(self, self.refListView))
        end
    end)


    self._root.Panel_type3:addTouchEventListener(function(sender, type)
        if type ~= 2 then
            return
        end
        local size = self._root.Panel_type3:getContentSize()
        local txt = { GET_STRING(600000110), GET_STRING(600000001), GET_STRING(600000002) }
        local worldpos = cc.p(self._root.Panel_type3:getWorldPosition())
        worldpos.y = worldpos.y - size.height
        local callback = function(index)
            if self.m_selType ~= index then
                self._root.Text_type3:setString(txt[index])
                self.m_selType = index
                local seltype = {[1] = nil, [2] = 1, [3] = 2 }
                self.m_page = 1
                self.m_maxpage = 1
                self.m_order_price = nil
                self._root.ListView_2:removeAllChildren()
                local val = {
                    type = seltype[self.m_selType],
                    page = self.m_page,
                    pagenum = self.m_pagenum,
                    order_price = self.m_order_price
                }
                self:ReqgetTargetGoodsInfo(val, handler(self, self.refListView))
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
    self._root.Panel_price3:addTouchEventListener(function(sender, type)--等级价格
        if type ~= 2 then
            return
        end
        if self.m_order_price == "asc" then
            self.m_order_price = "desc"
        else
            self.m_order_price = "asc"
        end
        local seltype = {[1] = nil, [2] = 1, [3] = 2 }
        self.m_page = 1
        self.m_maxpage = 1
        self._root.ListView_2:removeAllChildren()
        local val2 = {
            type = seltype[self.m_selType],
            page = self.m_page,
            pagenum = self.m_pagenum,
            order_price = self.m_order_price,
        }
        self:ReqgetTargetGoodsInfo(val2, handler(self, self.refListView))
    end)
end
function TradingBankBuyMeLayer:ReqgetTargetGoodsInfo(val, func)
    self.m_reqState = true
    self.OtherTradingBankProxy:getTargetGoodsInfo(self, val, func)
end
function TradingBankBuyMeLayer:refListView(code, data, msg)
    dump({ code, data, msg }, "refListView__")
    self.m_reqState = false
    if code == 200 then
        self.m_page = data.current
        self.m_maxpage = data.pages
        local listdata = data.records
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

    end

end
function TradingBankBuyMeLayer:createItem(data)
    local item = self._root.Panel_item:clone()
    item:setVisible(true)

    local Image_item = item:getChildByName("Image_item")
    local Text_goodname = item:getChildByName("Text_goodname")
    local Text_name = item:getChildByName("Text_name")
    -- local Text_num = item:getChildByName("Text_num")
    local Text_pirce = item:getChildByName("Text_pirce")
    local Button_buy = item:getChildByName("Button_buy")
    local Image_head = Image_item:getChildByName("Image_head")
    Text_name:setString(data.role or "")
    Text_pirce:setString(data.price or "0")
    local goodname = ""
    if data.type == 2 then
        goodname = string.format(GET_STRING(600000120), data.coinConfigTypeName, data.coinNum)
        --Image_head:loadTexture(global.MMO.PATH_RES_PRIVATE.."trading_bank/img_cost.png")
        Image_item:setVisible(false)
        Text_goodname:setPositionX(Text_goodname:getPositionX() - 30)
        Text_goodname:setFontSize(20)
    else
        Text_goodname:setFontSize(16)
        local jobid = "0"
        if data.roleConfigId and string.len(data.roleConfigId) > 0 then
            jobid = data.roleConfigId
        end
        local sex = data.sex or 0 -- 0-1 男女
        jobid = tonumber(jobid)
        local jobName = GET_STRING(600000111 + jobid)
        Image_head:loadTexture(global.MMO.PATH_RES_PRIVATE .. "trading_bank/img_0" .. (sex + 1) .. (jobid + 1) .. ".png")
        item:setTouchEnabled(true)
        item:addTouchEventListener(function(sender, type)
            if type ~= 2 then
                return
            end

            self.TradingBankLookPlayerProxy:RequestPlayerData(data.roleId, function()
                local TradingBankBuyMeLayerMediator_other = global.Facade:retrieveMediator("TradingBankBuyMeLayerMediator_other")
                if not TradingBankBuyMeLayerMediator_other._layer then
                    return
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerInfo_Open_other, { position = cc.p(150, 60) })
            end)

        end)
        goodname = string.format(GET_STRING(600000120), GET_STRING(600000121), jobName)
    end
    Text_goodname:setString(goodname)
    Button_buy:addTouchEventListener(function(sender, type)
        if type ~= 2 then
            return
        end
        local val = {}
        val.callback = function(res)
        end
        val.showPayTips = true
        val.notcancel = true
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, val)
        self.OtherTradingBankProxy:reqOrderPlace(self, { commodity_id = data.id }, handler(self, self.resOrderPlace2))--下单
        self.m_buyType = data.type
    end)
    item.Data = data
    return item
end
--下单返回
function TradingBankBuyMeLayer:resOrderPlace2(code, data, msg)
    dump({ code, data, msg }, "resOrderPlace___")
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Close_other)
    if code == 200 then
        ----下单成功
        if self.m_buyType == 1 then
            local callback = function()
                local val = {}
                val.txt = GET_STRING(600000192)--
                val.btntext = { GET_STRING(600000139), GET_STRING(600000193) }
                val.callback = function(res)
                    if res == 1 then
                        self._root.ListView_2:removeAllChildren()
                        self.m_page = 1
                        local val = {
                            page = self.m_page,
                            pagenum = self.m_pagenum,
                            order_price = self.m_order_price,
                        }

                        self:ReqgetTargetGoodsInfo(val, handler(self, self.refListView))
                    elseif res == 2 then
                        global.gameWorldController:OnGameLeaveWorld()
                    end
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, val)
            end
            data.callback = callback
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPlayerLayer_Open_other, data)
        else
            local callback = function()
                local val = {}
                val.txt = GET_STRING(600000447)--
                val.btntext = { GET_STRING(600000139) }
                val.callback = function(res)
                    if res == 1 then

                    end
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, val)
            end
            data.callback = callback
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFLayer_Open_other, data)
        end
    elseif code == 40050 then --锁定中
        local data = {}
        data.txt = GET_STRING(600000405)--
        data.callback = function()
        end
        data.btntext = {}
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, data)
    elseif code == 40002 then --不买自己的商品
        local data = {}
        data.txt = GET_STRING(600000404)--
        data.callback = function()
        end
        data.btntext = {}
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, data)
    elseif code == 30060 then --角色位满了
        local data = {}
        data.txt = GET_STRING(600000406)--
        data.callback = function(res)
            if res == 2 then --切换角色
                global.userInputController:RequestLeaveWorld()
            end
        end
        data.btntext = { GET_STRING(600000407), GET_STRING(600000408) }
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, data)
    else
        ShowSystemTips(msg)
    end


end
function TradingBankBuyMeLayer:sortList(func)
    local items = self._root.ListView_2:getItems()
    for i, v in ipairs(items) do
        v:retain()
    end
    self._root.ListView_2:removeAllChildren()
    table.sort(items, func)
    for i, v in ipairs(items) do
        self._root.ListView_2:pushBackCustomItem(v)
    end

end

function TradingBankBuyMeLayer:exitLayer()
    self.OtherTradingBankProxy:removeLayer(self)
end

return TradingBankBuyMeLayer