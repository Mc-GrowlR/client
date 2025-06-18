local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankBuyRoleLayer = class("TradingBankBuyRoleLayer", BaseLayer)
local cjson = require("cjson")
local QuickCell = requireUtil("QuickCell")

function TradingBankBuyRoleLayer:ctor()
    TradingBankBuyRoleLayer.super.ctor(self)
    self.TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    self.TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
end

function TradingBankBuyRoleLayer.create(...)
    local ui = TradingBankBuyRoleLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end
function TradingBankBuyRoleLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_buy_role")
    self._root = ui_delegate(self)
    self:InitUI(data)
    self.m_page = 1
    self.m_maxpage = 1
    self.m_pagenum = 10
    self.m_data = {}
    self.m_reqState = true
    self.m_selType = 1 -- 1 全部 -2-4 战法道
    self.m_order_price = nil
    self.m_order_level = nil
    self.m_searchName = nil
    local val = {
        type = 1, --角色
        page = self.m_page,
        pagenum = self.m_pagenum,
    }
    self:ReqgetGoodsInfo(val, handler(self, self.refListView))
    return true
end
function TradingBankBuyRoleLayer:InitUI(data)
    ------------
    self._root.Panel_item:setVisible(false)
    self._root.ListView_2:addScrollViewEventListener(function(sender, event)
        local itemnum = #sender:getItems()
        local Bottomitem = sender:getBottommostItemInCurrentView()
        local lastitem = sender:getItem(itemnum - 1)
        if (event == 1 or (event == 10 and lastitem == Bottomitem)) and self.m_page < self.m_maxpage and not self.m_reqState then
            local seltype = {[1] = nil, [2] = 0, [3] = 1, [4] = 2 }
            local val = {
                type = 1, --角色
                page = self.m_page + 1,
                pagenum = self.m_pagenum,
                role_type = seltype[self.m_selType],
                order_price = self.m_order_price,
                order_level = self.m_order_level

            }
            self:ReqgetGoodsInfo(val, handler(self, self.refListView))
        end
    end)
    self._root.Panel_job1:addTouchEventListener(function(sender, type)--筛选
        if type ~= 2 then
            return
        end
        local size = self._root.Panel_job1:getContentSize()
        local txt = { GET_STRING(600000110), GET_STRING(600000111), GET_STRING(600000112), GET_STRING(600000113) }
        local worldpos = cc.p(self._root.Panel_job1:getWorldPosition())
        worldpos.y = worldpos.y - size.height
        local callback = function(index)--筛选
            dump(index, "seltype___")
            if self.m_selType ~= index then
                dump(txt[index], "text___")
                self._root.Text_job1:setString(txt[index])
                self.m_selType = index
                local seltype = {[1] = nil, [2] = 0, [3] = 1, [4] = 2 }
                self.m_page = 1
                self.m_maxpage = 1
                self.m_order_price = nil
                self.m_order_level = nil
                self._root.ListView_2:removeAllChildren()
                local val2 = {
                    type = 1, --角色
                    page = self.m_page,
                    pagenum = self.m_pagenum,
                    role_type = seltype[self.m_selType],
                }

                self:ReqgetGoodsInfo(val2, handler(self, self.refListView))
                local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
                TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingBuyLayerRoleJobFilter, {Filter_Button_name = txt[index]})
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

    self._root.Panel_level1:addTouchEventListener(function(sender, type)--等级排序
        if type ~= 2 then
            return
        end
        if self.m_order_price == "desc" then
            self.m_order_price = "asc"
        else
            self.m_order_price = "desc"
        end
        self.m_order_price = nil
        local seltype = {[1] = nil, [2] = 0, [3] = 1, [4] = 2 }
        self.m_page = 1
        self.m_maxpage = 1
        self._root.ListView_2:removeAllChildren()
        local val2 = {
            type = 1, --角色
            page = self.m_page,
            pagenum = self.m_pagenum,
            role_type = seltype[self.m_selType],
            -- order_price = self.m_order_price,
            order_level = self.m_order_level
        }
        self:ReqgetGoodsInfo(val2, handler(self, self.refListView))

    end)
    self._root.Panel_price1:addTouchEventListener(function(sender, type)--价格排序
        if type ~= 2 then
            return
        end
        if self.m_order_price == "desc" then
            self.m_order_price = "asc"
        else
            self.m_order_price = "desc"
        end
        self.m_order_level = nil
        local seltype = {[1] = nil, [2] = 0, [3] = 1, [4] = 2 }
        self.m_page = 1
        self.m_maxpage = 1
        self._root.ListView_2:removeAllChildren()
        local val2 = {
            type = 1, --角色
            page = self.m_page,
            pagenum = self.m_pagenum,
            role_type = seltype[self.m_selType],
            order_price = self.m_order_price,
        --  order_level = self.m_order_level
        }
        self:ReqgetGoodsInfo(val2, handler(self, self.refListView))
    end)

end
function TradingBankBuyRoleLayer:Search(role_name)
    self.m_selType = 1 -- 1 全部 -2-4 战法道
    self.m_order_price = nil
    self.m_order_level = nil
    self._root.ListView_2:removeAllChildren()
    local val = {
        type = 1, --角色
        page = self.m_page,
        pagenum = self.m_pagenum,
        role_name = role_name
    }
    -- self._root.Text_roleName:setString(role_name)
    self.m_searchName = role_name
    if role_name and string.len(role_name) == 0 then
        -- self._root.Text_roleName:setString(GET_STRING(600000177))
        val.role_name = nil
        self.m_searchName = nil
    end

    self:ReqgetGoodsInfo(val, handler(self, self.refListView))
end
function TradingBankBuyRoleLayer:ReqgetGoodsInfo(val, func)
    self.m_reqState = true
    self.TradingBankProxy:getGoodsInfo(self, val, func)
end
function TradingBankBuyRoleLayer:refListView(success, response, code)
    -- local TradingBankBuyRoleLayerMediator = global.Facade:retrieveMediator("TradingBankBuyRoleLayerMediator")
    -- if not TradingBankBuyRoleLayerMediator._layer then
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
            dump(listdata, "listdata___")
            if self.m_searchName then
                if #listdata == 0 then
                    global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000175))
                end
                self.m_searchName = nil
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
function TradingBankBuyRoleLayer:createItem(data)
    local item = self._root.Panel_item:cloneEx()
    item:setVisible(true)
    local jobid = data.role_config_id or 0 -- 0-2 战法道
    jobid = tonumber(jobid)
    local sex = data.sex or 0 -- 0-1 男女
    local jobName = GET_STRING(600000111 + jobid)
    local ui = ui_delegate(item)
    local Image_item = item:getChildByName("Image_item")
    local Text_name = item:getChildByName("Text_name")
    local Text_job = item:getChildByName("Text_job")
    local Text_level = item:getChildByName("Text_level")
    local Text_pirce = item:getChildByName("Text_pirce")
    local Button_buy = item:getChildByName("Button_buy")
    local Image_head = Image_item:getChildByName("Image_head")
    Image_head:loadTexture(global.MMO.PATH_RES_PRIVATE .. "trading_bank/img_0" .. (sex + 1) .. (jobid + 1) .. ".png")
    Text_name:setString(data.role or "")
    Text_job:setString(jobName)
    Text_level:setString(data.role_level or "0")
    Text_pirce:setString(data.price or "0")
    item.roleData = data
    item:setTouchEnabled(true)
    item:addTouchEventListener(function(sender, type)
        if type ~= 2 then
            return
        end

        self.TradingBankLookPlayerProxy:RequestPlayerData(data.role_id, function()
            local TradingBankBuyRoleLayerMediator = global.Facade:retrieveMediator("TradingBankBuyRoleLayerMediator")
            if not TradingBankBuyRoleLayerMediator._layer then
                return
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerInfo_Open, { position = cc.p(150, 60),data = data })
        end)

    end)
    Button_buy:addTouchEventListener(function(sender, type)
        if type ~= 2 then
            return
        end
        local callback = function()
            local data = {}
            data.txt = GET_STRING(600000192)--
            data.btntext = { GET_STRING(600000139), GET_STRING(600000193) }
            data.callback = function(res)
                if res == 1 then
                    self._root.ListView_2:removeAllChildren()
                    local seltype = {[1] = nil, [2] = 0, [3] = 1, [4] = 2 }
                    self.m_page = 1
                    local val = {
                        type = 1,
                        page = self.m_page,
                        pagenum = self.m_pagenum,
                        order_price = self.m_order_price,
                        role_type = seltype[self.m_selType],
                    }
                    self:ReqgetGoodsInfo(val, handler(self, self.refListView))
                elseif res == 2 then
                    global.gameWorldController:OnGameLeaveWorld()
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, data)
        end

        self:reqcommodityInfo({ data = data, callback = callback, role_id = data.role_id })

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
function TradingBankBuyRoleLayer:reqcommodityInfo(val)
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
                    data.btntext = { GET_STRING(600000139) }
                    data.callback = function()
                    end
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, data)
                else
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPlayerLayer_Open, { data = data, callback = val.callback, role_id = val.role_id })
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

function TradingBankBuyRoleLayer:exitLayer()
    self.TradingBankProxy:removeLayer(self)
end

return TradingBankBuyRoleLayer