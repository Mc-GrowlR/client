local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankBuyEquipLayer = class("TradingBankBuyEquipLayer", BaseLayer)
local cjson = require("cjson")
local QuickCell = requireUtil("QuickCell")

function TradingBankBuyEquipLayer:ctor()
    TradingBankBuyEquipLayer.super.ctor(self)
    self._tradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    self._tradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
end

function TradingBankBuyEquipLayer.create(...)
    local ui = TradingBankBuyEquipLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankBuyEquipLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_buy_equip")
    self._root = ui_delegate(self)
    self:InitUI(data)
    self._page = 1
    self._max_page = 1
    self._page_num = 10
    self._data = {}
    self._req_state = true
    self._order_price = nil
    self._search_name = nil
    self._equip_type = nil
    local val = {
        type = 3, --装备
        page = self._page,
        pagenum = self._page_num,
    }
    self:ReqgetGoodsInfo(val, handler(self, self.RefListView))
    return true
end

function TradingBankBuyEquipLayer:InitUI(data)
    self._root.Panel_item:setVisible(false)
    self._root.ListView_2:addScrollViewEventListener(function(sender, event)
        local itemnum = #sender:getItems()
        local Bottomitem = sender:getBottommostItemInCurrentView()
        local lastitem = sender:getItem(itemnum - 1)
        if (event == 1 or (event == 10 and lastitem == Bottomitem)) and self._page < self._max_page and not self._req_state then
            local val = {
                type = 3, --装备
                page = self._page + 1,
                pagenum = self._page_num,
                order_price = self._order_price,
                equip_type_id = self._equip_type
            }
            self:ReqgetGoodsInfo(val, handler(self, self.RefListView))
        end
    end)

    self._root.Panel_price:addClickEventListener(function()--价格排序
        if self._order_price == "desc" then
            self._order_price = "asc"
        else
            self._order_price = "desc"
        end
        self._page = 1
        self._max_page = 1
        self._root.ListView_2:removeAllItems()
        local val2 = {
            type = 3, --装备
            page = self._page,
            pagenum = self._page_num,
            order_price = self._order_price,
            equip_type_id = self._equip_type
        }
        self:ReqgetGoodsInfo(val2, handler(self, self.RefListView))
    end)
end

function TradingBankBuyEquipLayer:TypeChange(data)

    local equipType = data.type
    if equipType == "0" then 
        equipType = nil
    end
    self._equip_type = equipType
    self._page = 1
    self._max_page = 1
    self._root.ListView_2:removeAllItems()
    local val2 = {
        type = 3, --装备
        page = self._page,
        pagenum = self._page_num,
        order_price = self._order_price,
        equip_type_id = self._equip_type
    }
    self:ReqgetGoodsInfo(val2, handler(self, self.RefListView))
end

function TradingBankBuyEquipLayer:Search(equip_name)
    self._order_price = nil
    self._page = 1
    self._max_page = 1
    self._root.ListView_2:removeAllItems()
    local val = {
        type = 3, --装备
        page = self._page,
        pagenum = self._page_num,
        title = equip_name,
        equip_type_id = self._equip_type
    }
    self._search_name = equip_name
    if equip_name and string.len(equip_name) == 0 then
        val.title = nil
        self._search_name = nil
    end

    self:ReqgetGoodsInfo(val, handler(self, self.RefListView))
end

function TradingBankBuyEquipLayer:ReqgetGoodsInfo(val, func)
    self._req_state = true
    self._tradingBankProxy:getGoodsInfo(self, val, func)
end

function TradingBankBuyEquipLayer:RefListView(success, response, code)
    self._req_state = false
    if success then
        local data = cjson.decode(response)
        if data.code == 200 then
            data = data.data
            self._page = data.current_page
            self._max_page = data.last_page
            local listdata = data.data or {}
            dump(listdata, "listdata___")
            if self._search_name then
                if #listdata == 0 then
                    global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000625))
                end
                self._search_name = nil
            end
            local lastIndex = #self._root.ListView_2:getItems() - 1
            for i, v in ipairs(listdata) do
                local itemSize = self._root.Panel_item:getContentSize()
                local cell_data = {}
                cell_data.wid = itemSize.width
                cell_data.hei = itemSize.height
                cell_data.anchor = cc.p(0.5, 1)
                cell_data.tick_interval = 0.05
                cell_data.createCell = function()
                    local cell = self:CreateItem(v)
                    return cell
                end
                local item = QuickCell:Create(cell_data)
                self._root.ListView_2:pushBackCustomItem(item)
            end
            self._root.ListView_2:jumpToItem(lastIndex, cc.p(0, 0), cc.p(0, 0))
        end
    end
end

function TradingBankBuyEquipLayer:CreateItem(data)
    local item = self._root.Panel_item:cloneEx()
    item:setVisible(true)
    local ui = ui_delegate(item)
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local itemData =  ItemConfigProxy:GetItemDataByIndex(data.equip_id)
    local goodparam = {index = data.equip_id}
    if data.equip_num and data.equip_num > 1 then 
        goodparam.count = data.equip_num
    end
    local goodsItem = GoodsItem:create(goodparam)
    ui.Image_item:addChild(goodsItem)
    local size = ui.Image_item:getContentSize()
    goodsItem:setPosition(size.width/2, size.height/2)
    goodsItem:addTouchEventListener(function()--点击tips
        self._tipsIndex = self._tradingBankProxy:GetTipsIndex() 
        self._tipsPos = ui.Image_item:getWorldPosition()
        self._tradingBankProxy:ReqQueryItemData(data.id, self._tipsIndex)
    end, 2)
    local color = (itemData.Color and itemData.Color > 0) and itemData.Color or 255
    local name = itemData.Name or ""
    -- 道具名字
    ui.Text_name:setString(name)
    ui.Text_name:setTextColor(SL:GetColorByStyleId(color))

    ui.Text_price:setString(data.price or 0)

    ui.Button_buy:addClickEventListener(function()
        local callback = function(...)
            self._order_price = nil
            self._page = 1
            self._max_page = 1
            self._root.ListView_2:removeAllItems()
            local val = {
                type = 3, --装备
                page = self._page,
                pagenum = self._page_num,
                equip_type_id = self._equip_type
            }

            self:ReqgetGoodsInfo(val, handler(self, self.RefListView))
        end

        self:ReqcommodityInfo({ data = data, callback = callback, role_id = data.role_id })

        local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
        TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingBuyClick)
    end)

    if not global.isWindows and data.bargain_switch == 1 then 
        local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
        ui.Button_bargain:addClickEventListener(function()
            local isBoxLogin = global.L_GameEnvManager:GetEnvDataByKey("isBoxLogin") == 1
            local isBoxOpen  = isBoxLogin and not global.BoxLaunchExternal
            local tipsData = {}
            tipsData.title =  GET_STRING(600000904)
            tipsData.btntext = { GET_STRING(600000901) }
            tipsData.notcancel = true
            if isBoxOpen then
                if compareBoxVersion("3.8.0") < 0 then 
                    ShowSystemTips(GET_STRING(600001016))
                    return 
                end

                tipsData.txt = GET_STRING(600000905)
                tipsData.btntext[2] = GET_STRING(600000902)
                tipsData.btnFontSize = {16, 16}
            else
                tipsData.txt = GET_STRING(600000906)
                tipsData.btntext[2] = GET_STRING(600000903)
                tipsData.btnFontSize = {16, 16}
            end
            
            tipsData.callback = function(res)
                if res == 2 then
                    if isBoxOpen then 
                        TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingBuyBargainToBoxClick)
                        
                        local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
                        local server_id   = tonumber(LoginProxy:GetSelectedServerId())
                        local server_name = LoginProxy:GetSelectedServerName()
                        local NativeBridgeProxy = global.Facade:retrieveProxy( global.ProxyTable.NativeBridgeProxy )
                        NativeBridgeProxy:GN_GoToCommondity({
                            id = data.id,
                            server_id = server_id,
                            server_name = server_name
                        })
                    else
                        local Box996Proxy = global.Facade:retrieveProxy(global.ProxyTable.Box996Proxy)
                        Box996Proxy:getBox996DownloadURL(5)

                        TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingBuyBargainToDownClick)
                    end 
                elseif res == 1 then --取消
                    TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingBuyBargainCancelClick)
                end
            end
            
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, tipsData)

            TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingBuyBargainClick)
            
        end)
    else 
        ui.Button_bargain:setVisible(false)
        ui.Button_buy:setPositionX(ui.Button_buy:getPositionX() + 30)
    end
    
    return item
end

function TradingBankBuyEquipLayer:OnTips(data)
    local itemData = data.itemData
    local tipsIndex = data.tipsIndex
    if self._tipsIndex == tipsIndex then 
        local param = {itemData = itemData, isHideFrom = true, pos = self._tipsPos}
        global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, param)
    end
end

function TradingBankBuyEquipLayer:ReqcommodityInfo(val)
    dump(val, "val___")
    self._tradingBankProxy:reqcommodityInfo(self, { commodity_id = val.data.id }, function(success, response, code)
        if success then
            local data = cjson.decode(response)
            if data.code == 200 then
                data = data.data
                if data.status and data.status == 3 then--已出售
                    local data = {}
                    data.txt = GET_STRING(600000185)--
                    data.callback = function()
                    end
                    data.btntext = { GET_STRING(600000139) }
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, data)
                else
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFLayer_Open, { data = data, callback = val.callback })
                end
            elseif data.code >= 50000 and data.code <= 50020 then--token失效
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open, { callback = function(code)
                    if code == 1 then
                        self:ReqcommodityInfo(val)
                    else
                
                    end
                end })
            else
                ShowSystemTips(data.msg or "")
            end
        else
            ShowSystemTips(GET_STRING(600000137))
        end
    end)
end

function TradingBankBuyEquipLayer:ExitLayer()
    self._tradingBankProxy:removeLayer(self)
end

return TradingBankBuyEquipLayer