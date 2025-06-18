local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankBuyRequestLayer = class("TradingBankBuyRequestLayer", BaseLayer)
local QuickCell = requireUtil("QuickCell")
local cjson = require("cjson")
local seltype = {[1] = nil, [2] = 0, [3] = 1, [4] = 2 }
function TradingBankBuyRequestLayer:ctor()
    TradingBankBuyRequestLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankBuyRequestLayer.create(...)
    local ui = TradingBankBuyRequestLayer.new()
    if ui and ui:Init(...) then
        return ui
    end

    return nil
end
function TradingBankBuyRequestLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_buy_request")
    self._root = ui_delegate(self)
    
    self.m_page = 1
    self.m_maxpage = 1
    self.m_pagenum = 10
    self.m_data = {}
    self.m_selType = 1
    self.m_order_price = nil
    self._root.Panel_item:setVisible(false)
    self._jobDesc = { GET_STRING(600000110), GET_STRING(600000111), GET_STRING(600000112), GET_STRING(600000113) }
    self:InitUI(data)
    self:RefList()
    return true
end

function TradingBankBuyRequestLayer:RefList()
    self._root.ListView_2:removeAllChildren()
    self.m_page = 1
    self.m_pagenum = 10
    self.m_selType = 1
    local val = {
        roleType = seltype[self.m_selType],
        pageNum = self.m_page,
        pageSize = self.m_pagenum,
    }
    self:ReqRequestData(val, handler(self, self.refListView))
end

function TradingBankBuyRequestLayer:InitUI(data)
    self._root.Text_jobLabel:setString(self._jobDesc[self.m_selType])
    self._root.ListView_2:addScrollViewEventListener(function(sender, event)
        local itemnum = #sender:getItems()
        local Bottomitem = sender:getBottommostItemInCurrentView()
        local lastitem = sender:getItem(itemnum - 1)
        if (event == 1 or (event == 10 and lastitem == Bottomitem)) and self.m_page < self.m_maxpage and not self.m_reqState then
            local val = {
                roleType = seltype[self.m_selType],
                pageNum = self.m_page + 1,
                pageSize = self.m_pagenum,
                orderPrice = self.m_order_price,
            }
            self:ReqRequestData(val, handler(self, self.refListView))
        end
    end)

    self._root.Panel_job:addTouchEventListener(function(sender, type)--筛选
        if type ~= 2 then
            return
        end
        local size = self._root.Panel_job:getContentSize()
        local worldpos = cc.p(self._root.Panel_job:getWorldPosition())
        worldpos.y = worldpos.y - size.height
        local callback = function(index)--筛选
            dump(index, "seltype___")
            if self.m_selType ~= index then
                self._root.Text_jobLabel:setString(self._jobDesc[index])
                self.m_selType = index
                self.m_page = 1
                self.m_maxpage = 1
                self.m_order_price = nil
                self._root.ListView_2:removeAllChildren()
                local val2 = {
                    pageNum = self.m_page,
                    pageSize = self.m_pagenum,
                    roleType = seltype[self.m_selType],
                }

                self:ReqRequestData(val2, handler(self, self.refListView))
            end
        end
        local val = {
            width = size.width,
            txt = self._jobDesc,
            index = self.m_selType,
            pos = worldpos,
            callback = callback
        }
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyTipsLayer_Open_other, val)
    end)
    
    self._root.Panel_price:addTouchEventListener(function(sender, type)--等级价格
        if type ~= 2 then
            return
        end
        if self.m_order_price == "asc" then
            self.m_order_price = "desc"
        else
            self.m_order_price = "asc"
        end
        self.m_page = 1
        self.m_maxpage = 1
        self._root.ListView_2:removeAllChildren()
        local val2 = {
            roleType = seltype[self.m_selType],
            pageNum = self.m_page,
            pageSize = self.m_pagenum,
            orderPrice = self.m_order_price,
        }
        self:ReqRequestData(val2, handler(self, self.refListView))
    end)

end

function TradingBankBuyRequestLayer:ReqRequestData(val, func)
    self.m_reqState = true
    
    self.OtherTradingBankProxy:getRequestBuyData(self, val, func)
end

function TradingBankBuyRequestLayer:refListView(code, data, msg)
    dump({ code, data, code }, "refListView__")
    self.m_reqState = false
    if code == 200 then
        self.m_page = data.pageNum
        self.m_maxpage = data.pageTotal
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
function TradingBankBuyRequestLayer:createItem(data)
    dump(data,"createItem____")
    local item = self._root.Panel_item:cloneEx()
    item:setVisible(true)

    local Image_item = item:getChildByName("Image_item")
    local Text_job = item:getChildByName("Text_job")
    local Text_level = item:getChildByName("Text_level")
    local Text_price = item:getChildByName("Text_price")
    local Text_sell = item:getChildByName("Text_sell")
    --local Image_head = Image_item:getChildByName("Image_head")
    Text_job:setString(self._jobDesc[data.roleType + 2])
    if data.minPrice == 1000 then 
        Text_price:setString(data.minPrice .. "以上" )
    else
        Text_price:setString(data.minPrice .. "-" .. data.maxPrice)
    end
    Text_level:setString(data.minRoleLevel .. "-" .. data.maxRoleLevel)

    Text_sell:getVirtualRenderer():enableUnderline()
    Text_sell:addClickEventListener(function(sender, type)
        self.OtherTradingBankProxy:doTrack(self.OtherTradingBankProxy.UpLoadData.TraingReqBuyShowGoSellClick)
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankFrame_Open_other, { id = global.LayerTable.TradingBankSellLayer })
    end)
    return item
end

function TradingBankBuyRequestLayer:exitLayer()
    self.OtherTradingBankProxy:removeLayer(self)
end

return TradingBankBuyRequestLayer