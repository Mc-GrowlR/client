local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankBuyRoleLayer = class("TradingBankBuyRoleLayer", BaseLayer)
local cjson = require("cjson")
local QuickCell = requireUtil("QuickCell")

function TradingBankBuyRoleLayer:ctor()
    TradingBankBuyRoleLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    self.TradingBankLookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankLookPlayerProxy)
    self.LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
end

function TradingBankBuyRoleLayer.create(...)
    local ui = TradingBankBuyRoleLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankBuyRoleLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_buy_role")
    self._root = ui_delegate(self)
    --展示跨区商品
    self.m_isShowCrossServerCommodity = self.OtherTradingBankProxy:getisShowCrossServerCommodity() or 1
    dump(self.m_isShowCrossServerCommodity,"self.m_isShowCrossServerCommodity____")
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
    self.m_serverID = tonumber(self.LoginProxy:GetSelectedServerId())
    
    local val = {
        type = 1, --角色
        page = self.m_page,
        pagenum = self.m_pagenum,
        server_id = self.m_serverID 
    }
    self:ReqgetGoodsInfo(val, handler(self, self.firstReq))
    if self.m_isShowCrossServerCommodity == 0 then 
        local serverName = self.LoginProxy:GetSelectedServerName()
        self:setScrollLabel(self._root.Text_serverName1, serverName)
    end
    return true
end
--第一次请求  先看本服没数据请求全部
function TradingBankBuyRoleLayer:firstReq(code, data, msg)
    self.m_reqState = false
    if code == 200 then
        local listdata = data.records or {}
        dump(listdata, "firstReq____")
        if #listdata == 0 then
            if self.m_isShowCrossServerCommodity == 1 then 
                self.m_serverID = -1
                self:setScrollLabel(self._root.Text_serverName1, GET_STRING(600000706))
                local val = {
                    type = 1, --角色
                    page = self.m_page,
                    pagenum = self.m_pagenum,
                    server_id = self.m_serverID 
                }
                self:ReqgetGoodsInfo(val, handler(self, self.refListView))
            else 
                local serverName = self.LoginProxy:GetSelectedServerName()
                self:setScrollLabel(self._root.Text_serverName1, serverName)
            end
            
        else 
            local serverName = self.LoginProxy:GetSelectedServerName()
            self:setScrollLabel(self._root.Text_serverName1, serverName)
            self:refListView(code, data, msg)
        end
    else
        ShowSystemTips(msg or "")
    end
end

function TradingBankBuyRoleLayer:setScrollLabel(label, str)
    local oriX = label._oriX
    if not oriX then 
        oriX = label:getPositionX()
        label._oriX = oriX
    end
    label:stopAllActions()
    label:setPositionX(oriX)
    label:setString(str)
    local parent = label:getParent()
    local parentContenSize = parent:getContentSize()
    local labelContentSzie = label:getContentSize()
    if labelContentSzie.width > parentContenSize.width then
        local speed = 15
        local needWidth = labelContentSzie.width - parentContenSize.width + oriX * 2
        label:runAction(cc.RepeatForever:create(
                            cc.Sequence:create(
                                cc.MoveBy:create(needWidth / speed, cc.p(-needWidth, 0)),
                                cc.DelayTime:create(0.5),
                                cc.MoveBy:create(needWidth / speed, cc.p(needWidth, 0)),
                                cc.DelayTime:create(0.5)
                                )))
    else 
        label:setPositionX((parentContenSize.width - labelContentSzie.width) / 2)
    end
    
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
                order_level = self.m_order_level,
                server_id = self.m_serverID 
            }
            self:ReqgetGoodsInfo(val, handler(self, self.refListView))
        end
    end)
    self:setScrollLabel(self._root.Text_serverName1, "")
    self._root.Panel_serverName:addTouchEventListener(function(sender, type)--筛选
        if type ~= 2 then
            return
        end
        if self.m_isShowCrossServerCommodity == 0 then
            -- ShowSystemTips(GET_STRING(600002002))
            return 
        end
        local size = self._root.Panel_serverName:getContentSize()
        -- local txt = { GET_STRING(600000110), GET_STRING(600000111), GET_STRING(600000112), GET_STRING(600000113) }
        local worldpos = cc.p(self._root.Panel_serverName:getWorldPosition())
        worldpos.y = worldpos.y - size.height
        local callback = function(server)--筛选
            dump(server, "selserver__")

            if not server or (server and self.m_serverID == server.serverId) then
                return 
            end
            local  getGoods = function ()
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
                    server_id = self.m_serverID 
                }
                self:ReqgetGoodsInfo(val2, handler(self, self.refListView))
            end
            if server.serverId == -1 then --全部
                self.m_serverID = -1
                self:setScrollLabel(self._root.Text_serverName1, GET_STRING(600000706))
                getGoods()
            elseif server.serverId == -2 then --搜索
                local val = {}
                val.callback = function(server2)
                    dump(server2,"server2____")
                    if not server2 or (server2 and self.m_serverID == server2.serverId) then
                        return 
                    end
                    self.m_serverID = tonumber(server2.serverId) 
                    self:setScrollLabel(self._root.Text_serverName1, server2.serverName)
                    getGoods()
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankSearchServerLayer_Open_other, val)
            else 
                self.m_serverID = tonumber(server.serverId) 
                self:setScrollLabel(self._root.Text_serverName1, server.serverName)
                getGoods()
            end
            
            
        end
        local val = {
            serverID = self.m_serverID,
            pos = worldpos,
            callback = callback
        }
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyServerNameTipsLayer_Open_other, val)
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
                    server_id = self.m_serverID 
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

    self._root.Panel_level1:addTouchEventListener(function(sender, type)--等级排序
        if type ~= 2 then
            return
        end
        if self.m_order_level == "asc" then
            self.m_order_level = "desc"
        else
            self.m_order_level = "asc"
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
            order_level = self.m_order_level,
            server_id = self.m_serverID 
        }
        self:ReqgetGoodsInfo(val2, handler(self, self.refListView))

    end)
    self._root.Panel_price1:addTouchEventListener(function(sender, type)--价格排序
        if type ~= 2 then
            return
        end
        if self.m_order_price == "asc" then
            self.m_order_price = "desc"
        else
            self.m_order_price = "asc"
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
            server_id = self.m_serverID 
        --  order_level = self.m_order_level
        }
        self:ReqgetGoodsInfo(val2, handler(self, self.refListView))
    end)

end

function TradingBankBuyRoleLayer:Search(role_name)
    self.m_selType = 1 -- 1 全部 -2-4 战法道
    self._root.Text_job1:setString(GET_STRING(600000110))
    self.m_order_price = nil
    self.m_order_level = nil
    self.m_page = 1
    self.m_pagenum = 10
    self._root.ListView_2:removeAllChildren()
    local val = {
        type = 1, --角色
        page = self.m_page,
        pagenum = self.m_pagenum,
        role_name = role_name,
        server_id = self.m_serverID 
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
    self.OtherTradingBankProxy:getGoodsInfo(self, val, func)
end

function TradingBankBuyRoleLayer:refListView(code, data, msg)
    self.m_reqState = false
    if code == 200 then
        self.m_page = data.current
        self.m_maxpage = data.pages
        local listdata = data.records or {}
        dump(listdata, "listdata______")
        if self.m_searchName then
            if #listdata == 0 then
                ShowSystemTips(GET_STRING(600000175))
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
    else
        ShowSystemTips(msg)
    end
end

function TradingBankBuyRoleLayer:createItem(data)
    dump(data,"data____")
    local item = self._root.Panel_item:cloneEx()
    item:setVisible(true)
    local ui = ui_delegate(item)
    local jobid = data.roleConfigId or 0 -- 0-2 战法道
    jobid = tonumber(jobid)
    local sex = data.sex or 0 -- 0-1 男女
    local jobName = GET_STRING(600000111 + jobid)
    ui.Image_head:loadTexture(global.MMO.PATH_RES_PRIVATE .. "trading_bank/img_0" .. (sex + 1) .. (jobid + 1) .. ".png")
    ui.Text_job:setString(jobName)
    ui.Text_level:setString(data.roleLevel or "0")
    ui.Text_pirce:setString(data.price or "0")
    self:setScrollLabel(ui.Text_serverName, data.serverName)
    self:setScrollLabel(ui.Text_name, data.role or "")
    item.roleData = data
    item:setTouchEnabled(true)
    item:addClickEventListener(function(sender, type)
        self.OtherTradingBankProxy:reqcommodityInfo(self, { commodity_id = data.id }, function(code, goodsInfo, msg)
            if code == 200 then 
                local mainServerId = tonumber(self.LoginProxy:GetMainSelectedServerId())
                local goodMainServerId =  tonumber(goodsInfo.mainServerId)
                local sameServer = false
                if mainServerId and goodMainServerId  then 
                    if  mainServerId == goodMainServerId then 
                        sameServer = true 
                    end
                else
                    if tonumber(self.LoginProxy:GetSelectedServerId()) == tonumber(goodsInfo.serverId) then 
                        sameServer = true 
                    end
                end
                local callback = function()
                    local val = {}
                    val.txt = GET_STRING(600000192)--
                    val.btntext = { GET_STRING(600000139), GET_STRING(600000193) }
                    val.callback = function(res)
                        if res == 1 then
                            self._root.ListView_2:removeAllChildren()
                            local seltype = {[1] = nil, [2] = 0, [3] = 1, [4] = 2 }
                            self.m_page = 1
                            local val2 = {
                                type = 1,
                                page = self.m_page,
                                pagenum = self.m_pagenum,
                                order_price = self.m_order_price,
                                role_type = seltype[self.m_selType],
                                server_id = self.m_serverID 
                            }
                            self:ReqgetGoodsInfo(val2, handler(self, self.refListView))
                        elseif res == 2 then
                            if sameServer then 
                                global.gameWorldController:OnGameLeaveWorld()
                            else
                                global.L_NativeBridgeManager:GN_accountLogout()
                                global.Facade:sendNotification(global.NoticeTable.RestartGame)
                            end
                        end
                    end
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, val)
                end

                if sameServer then 
                    self.TradingBankLookPlayerProxy:RequestPlayerData(data.roleId, function()
                        local TradingBankBuyRoleLayerMediator_other = global.Facade:retrieveMediator("TradingBankBuyRoleLayerMediator_other")
                        if not TradingBankBuyRoleLayerMediator_other._layer then
                            return
                        end
                        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPlayerInfo_Open_other, { position = cc.p(150, 60) })
                    end)
                else
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankLookOtherServerPlayerLayer_Open_other, {goodsInfo = goodsInfo, goodsData = data, callback = callback})
                end
            else
                ShowSystemTips(msg or "")
            end
            
        end)
    end)

    ui.Button_buy:addClickEventListener(function(sender, type)
        self.OtherTradingBankProxy:doTrack(self.OtherTradingBankProxy.UpLoadData.TraingBuyLayerBuyBtnClick)
        self.OtherTradingBankProxy:reqcommodityInfo(self, { commodity_id = data.id }, function(code, goodsInfo, msg)
            if code == 200 then 
                local mainServerId = tonumber(self.LoginProxy:GetMainSelectedServerId())
                local goodMainServerId =  tonumber(goodsInfo.mainServerId)
                local sameServer = false
                if mainServerId and goodMainServerId  then 
                    if  mainServerId == goodMainServerId then 
                        sameServer = true 
                    end
                else
                    if tonumber(self.LoginProxy:GetSelectedServerId()) == tonumber(goodsInfo.serverId) then 
                        sameServer = true 
                    end
                end
                local callback = function()
                    local val = {}
                    val.txt = GET_STRING(600000192)--
                    val.btntext = { GET_STRING(600000139), GET_STRING(600000193) }
                    val.callback = function(res)
                        if res == 1 then
                            self._root.ListView_2:removeAllChildren()
                            local seltype = {[1] = nil, [2] = 0, [3] = 1, [4] = 2 }
                            self.m_page = 1
                            local val2 = {
                                type = 1,
                                page = self.m_page,
                                pagenum = self.m_pagenum,
                                order_price = self.m_order_price,
                                role_type = seltype[self.m_selType],
                                server_id = self.m_serverID 
                            }
                            self:ReqgetGoodsInfo(val2, handler(self, self.refListView))
                        elseif res == 2 then
                            if sameServer then 
                                global.gameWorldController:OnGameLeaveWorld()
                            else
                                global.L_NativeBridgeManager:GN_accountLogout()
                                global.Facade:sendNotification(global.NoticeTable.RestartGame)
                            end
                        end
                    end
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, val)
                end
                if sameServer then 
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankZFPlayerLayer_Open_other, {data = data ,callback = callback})
                else
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankLookOtherServerPlayerLayer_Open_other, {goodsInfo = goodsInfo, goodsData = data ,callback = callback, isPay = true})
                    
                end
            else
                ShowSystemTips(msg or "")
            end
        end)
        
    end)

    return item
end

function TradingBankBuyRoleLayer:exitLayer()
    self.OtherTradingBankProxy:removeLayer(self)
end

return TradingBankBuyRoleLayer