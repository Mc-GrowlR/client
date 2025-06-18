local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankBuyMoneyLayer = class("TradingBankBuyMoneyLayer", BaseLayer)
local QuickCell = requireUtil("QuickCell")
local cjson = require("cjson")
local moneyData
function TradingBankBuyMoneyLayer:ctor()
    TradingBankBuyMoneyLayer.super.ctor(self)
    self.TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
end

function TradingBankBuyMoneyLayer.create(...)
    local ui = TradingBankBuyMoneyLayer.new()
    if ui and ui:Init(...) then
        return ui
    end

    return nil
end
function TradingBankBuyMoneyLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_buy_money")
    self._root = ui_delegate(self)
    self.m_page = 1
    self.m_maxpage = 1
    self.m_pagenum = 10
    self.m_data = {}
    self.m_selType = 1
    self.m_order_price = nil
    self.m_order_level = nil
    self._root.Panel_item:setVisible(false)
    self.TradingBankProxy:reqMoneyData(self, function(data)
        moneyData = data
        self:InitUI(data)
        local val = {
            type = 2, --货币
            page = self.m_page,
            pagenum = self.m_pagenum,
        }
        self:ReqgetGoodsInfo(val, handler(self, self.refListView))
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
            table.insert(txt, v.coin_type_name)
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
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyTipsLayer_Open, val)
    end)
    self._root.Panel_num2:addTouchEventListener(function(sender, type)--num排序
        if type ~= 2 then
            return
        end
        if self.m_order_price == "desc" then
            self.m_order_price = "asc"
        else
            self.m_order_price = "desc"
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
        if self.m_order_price == "desc" then
            self.m_order_price = "asc"
        else
            self.m_order_price = "desc"
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
    self.TradingBankProxy:getGoodsInfo(self, val, func)
end
function TradingBankBuyMoneyLayer:refListView(success, response, code)
    dump({ success, response, code }, "refListView__")
    -- local TradingBankBuyMoneyLayerMediator = global.Facade:retrieveMediator("TradingBankBuyMoneyLayerMediator")
    -- if not TradingBankBuyMoneyLayerMediator._layer then
    --     return 
    -- end
    self.m_reqState = false
    if success then
        local data = cjson.decode(response)
        if data.code == 200 then
            data = data.data
            self.m_page = data.current_page
            self.m_maxpage = data.last_page
            local listdata = data.data or {}
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
end

function TradingBankBuyMoneyLayer:createItem(data)
    local item = self._root.Panel_item:cloneEx()
    item:setVisible(true)
    -- local jobid = data.role_config_id or 0
    -- jobid = tonumber(jobid)
    -- local jobName =  GET_STRING(600000111+jobid)
    local ui = ui_delegate(item)
    local Image_item = item:getChildByName("Image_item")
    local Text_goodname = item:getChildByName("Text_goodname")
    local Text_name = item:getChildByName("Text_name")
    local Text_num = item:getChildByName("Text_num")
    local Text_pirce = item:getChildByName("Text_pirce")
    local Button_buy = item:getChildByName("Button_buy")
    --local Image_head = Image_item:getChildByName("Image_head")
    Text_goodname:setString(data.coin_config_type_name or "")
    Text_name:setString(data.role or "")
    Text_pirce:setString(data.price or "0")
    local count = self.TradingBankProxy:addNewLine(data.commodity_detail or data.coin_num or "0")
    
    Text_num:setString(count)

    -- GUI:Text_setMaxLineWidth(Text_num, 80)
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
    Button_buy:addTouchEventListener(function(sender, type)
        if type ~= 2 then
            return
        end
        --global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankCostZFLayer_Open,{data = data,callback = call})
        self:reqcommodityInfo({ data = data, callback = call })

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
function TradingBankBuyMoneyLayer:reqcommodityInfo(val)
    dump(val, "val___")
    self.TradingBankProxy:reqcommodityInfo(self, { commodity_id = val.data.id }, function(success, response, code)
        if success then
            local data = cjson.decode(response)
            if data.code == 200 then
                data = data.data
                -- local order_id = data.order_id
                -- self._order_id = order_id
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
                        self:reqcommodityInfo(val)
                    else
                        -- global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankGoodsLayer_Close)
                    end
                end })
            else
                global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg or "")
            end
        else
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000137))
        end
    end)
end
function TradingBankBuyMoneyLayer:exitLayer()
    self.TradingBankProxy:removeLayer(self)
end

return TradingBankBuyMoneyLayer