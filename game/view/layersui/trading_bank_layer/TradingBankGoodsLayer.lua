local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankGoodsLayer = class("TradingBankGoodsLayer", BaseLayer)
local QuickCell = requireUtil("QuickCell")
local cjson = require("cjson")

local STATE = {
    -- up_fail = -3,--上架失败
    -- invalid = -2,--已失效
    up_already = 1, --已上架
    down_already = 2, --已下架
    selling = 3, --出售中
-- uping = 6, --上架中
-- geting = 7,--取回中
}

function TradingBankGoodsLayer:ctor()
    TradingBankGoodsLayer.super.ctor(self)
    self._tradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    self._equipOptState = self._tradingBankProxy:GetEquipOptState()
    self._commodityType = self._tradingBankProxy:GetCommodityType()

end

function TradingBankGoodsLayer.create(...)
    local ui = TradingBankGoodsLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankGoodsLayer:Init(data)
    GUI:LoadInternalExport(self, "trading_bank/trading_bank_goods")
    self._root = ui_delegate(self)
    self.m_page = 1
    self.m_maxpage = 1
    self.m_pagenum = 10
    self.m_data = {}
    self.m_selType = 1
    self:InitUI(data)
    local val = {
        page = self.m_page,
        pagenum = self.m_pagenum,

    }
    self:ReqgetMyGoodsInfo(val, handler(self, self.refListView))

    local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingShelfTabClick)
    return true
end
function TradingBankGoodsLayer:InitUI(data)
    -- self._root.Text_tips:getVirtualRenderer():enableUnderline()
    -- self._root.Text_tips:setTouchEnabled(true)
    self._root.Text_tips:setVisible(false)
    self._root.Button_tips:setVisible(false)
    self._root.Button_tips:addTouchEventListener(function(sender, type)
        if type ~= 2 then
            return
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open, { noclose = true, callback = function(code)
            if code == 1 then
                local val = {
                    page = self.m_page,
                    pagenum = self.m_pagenum,

                }
                self:ReqgetMyGoodsInfo(val, handler(self, self.refListView))
            else
            end
        end })
    end)
    self._root.Panel_item:setVisible(false)
    self._root.ListView_2:addScrollViewEventListener(function(sender, event)
        local itemnum = #sender:getItems()
        local Bottomitem = sender:getBottommostItemInCurrentView()
        local lastitem = sender:getItem(itemnum - 1)
        if (event == 1 or (event == 10 and lastitem == Bottomitem)) and self.m_page < self.m_maxpage and not self.m_reqState and not self.m_modfiy then
            local val = {
                page = self.m_page + 1,
                pagenum = self.m_pagenum,
            }
            self:ReqgetMyGoodsInfo(val, handler(self, self.refListView))
        end
    end)

end
function TradingBankGoodsLayer:ReqgetMyGoodsInfo(val, func)
    self.m_reqState = true
    self._tradingBankProxy:getMyGoodsInfo(self, val, func)
end

function TradingBankGoodsLayer:refListView(success, response, code)
    dump({ success, response, code }, "refListView__")
    local TradingBankGoodsLayerMediator = global.Facade:retrieveMediator("TradingBankGoodsLayerMediator")
    if not TradingBankGoodsLayerMediator._layer then
        return
    end
    self.m_reqState = false
    if success then
        local data = cjson.decode(response)
        if data.code == 200 then
            data = data.data
            self._root.Text_tips:setVisible(false)
            self._root.Button_tips:setVisible(false)
            if self.m_modfiy then
                self.m_modfiy = false
                local items = self._root.ListView_2:getItems()
                for i, v in ipairs(items) do
                    if v.page == self.m_page then
                        local idx = self._root.ListView_2:getIndex(v)
                        self._root.ListView_2:removeItem(idx)
                    end
                end
            end


            self.m_page = data.current_page
            self.m_maxpage = data.last_page
            local listdata = data.data
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
                item.page = self.m_page
                self._root.ListView_2:pushBackCustomItem(item)
            end
            self._root.ListView_2:jumpToItem(lastIndex, cc.p(0, 0), cc.p(0, 0))
        elseif data.code >= 50000 and data.code <= 50020 then--token失效
            self._root.Text_tips:setVisible(true)
            self._root.Button_tips:setVisible(true)
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open, { noclose = true, callback = function(code)
                if code == 1 then
                    local val = {
                        page = self.m_page,
                        pagenum = self.m_pagenum,

                    }
                    self._root.Text_tips:setVisible(false)
                    self._root.Button_tips:setVisible(false)
                    self:ReqgetMyGoodsInfo(val, handler(self, self.refListView))
                else
                    -- global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankGoodsLayer_Close)
                end
            end })
        else
        end
    end
end
function TradingBankGoodsLayer:createItem(data)
    local item = self._root.Panel_item:cloneEx()
    item:setVisible(true)

    local Image_item = item:getChildByName("Image_item")
    local Text_goodname = item:getChildByName("Text_goodname")
    -- local Text_name = item:getChildByName("Text_name")
    local Text_num = item:getChildByName("Text_num")
    local Text_pirce = item:getChildByName("Text_pirce")
    local Text_state = item:getChildByName("Text_state")
    local Image_head = Image_item:getChildByName("Image_head")
    local itemData


    -- Text_name:setString(data.role or "")
    Text_pirce:setString(data.price or "0")

    Text_num:setString(data.coin_num or "1")
    -- local stateTxt = {

    --     [-3] = GET_STRING(600000122),
    --     [-2] = GET_STRING(600000123),
    --     [1] = GET_STRING(600000124),
    --     [2] = GET_STRING(600000125),
    --     [3] = GET_STRING(600000184),
    --     [6] = GET_STRING(600000126),
    --     [7] = GET_STRING(600000127),
    -- }
    Text_state:setString(data.status_ch)
    if data.type == self._commodityType.Money then
        Text_goodname:setString(data.coin_config_type_name or "")
        -- Image_head:loadTexture(global.MMO.PATH_RES_PRIVATE.."trading_bank/img_cost.png")
        Image_item:setVisible(false)
        Text_goodname:setPositionX(Text_goodname:getPositionX() - 30)
        Text_goodname:setFontSize(20)
    elseif data.type == self._commodityType.Role then
        Text_goodname:setFontSize(16)
        local jobid = data.role_config_id or 0
        jobid = tonumber(jobid)
        local jobName = GET_STRING(600000111 + jobid)
        local sex = data.sex or 0 -- 0-1 男女
        Text_goodname:setString(GET_STRING(600000121) .. ":" .. jobName)
        Image_head:loadTexture(global.MMO.PATH_RES_PRIVATE .. "trading_bank/img_0" .. (sex + 1) .. (jobid + 1) .. ".png")
    elseif data.type == self._commodityType.Equip then
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        itemData = ItemConfigProxy:GetItemDataByIndex(data.equip_id)
        local goodparam = {index = data.equip_id}
        if data.equip_num and data.equip_num > 1 then 
            goodparam.count = data.equip_num
        end
        local goodsItem = GoodsItem:create(goodparam)
        Image_head:setVisible(false)
        Image_item:addChild(goodsItem)
        local size = Image_item:getContentSize()
        goodsItem:setPosition(size.width / 2, size.height / 2)
        local color = (itemData.Color and itemData.Color > 0) and itemData.Color or 255
        local name = itemData.Name or ""
        -- 道具名字
        Text_goodname:setString(name)
        Text_goodname:setTextColor(SL:GetColorByStyleId(color))
        goodsItem:addTouchEventListener(function()--点击tips
            self._tipsIndex = self._tradingBankProxy:GetTipsIndex() 
            self._tipsPos = Image_item:getWorldPosition()
            self._tradingBankProxy:ReqQueryItemData(data.id, self._tipsIndex)
        end, 2)
        Text_num:setString("1")--数量写死1  现在只支持寄售一个
    end
    local state = data.status
    for i = 1, 3 do
        local btn = item:getChildByName("Button_" .. i)
        btn.val = data
        btn.itemData = itemData
        btn:addTouchEventListener(handler(self, self.onBtnClick))

        if state == STATE.up_fail then -- 上架失败
        elseif state == STATE.invalid then --已失效
        elseif state == STATE.up_already then --已上架--都显示
            if i == 1 then
                btn:setTitleText(GET_STRING(600000136))
            end
        elseif state == STATE.down_already then--已下架
        elseif state == STATE.selling then --出售中
        else --67上架中  取回中
            btn:setVisible(false)
        end
    end

    return item
end

function TradingBankGoodsLayer:OnTips(data)
    local itemData = data.itemData
    local tipsIndex = data.tipsIndex
    if self._tipsIndex == tipsIndex then 
        local param = {itemData = itemData, isHideFrom = true, pos = self._tipsPos}
        global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, param)
    end
end

function TradingBankGoodsLayer:onBtnClick(sender, type)
    if type ~= 2 then
        return
    end
    --下架  修改   取回  。。。  上架 修改 取回    。。。  下架  修改   取回 
    local name = sender:getName()
    local val = sender.val
    local state = val.status
    local itemData = sender.itemData
    local id = val.id
    if name == "Button_1" then -- 上架/下架
        if state == STATE.invalid or state == STATE.down_already then
            -- if val.type == self._commodityType.Equip then 
            --     local params = {itemData = itemData, opt = self._equipOptState.Up}
            --     global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankUpModifyEquipPanel_Open, params)
            -- else
            local data = {}
            data.txt = GET_STRING(600000140)--重新上架
            data.callback = function(res)
                if res == 2 then
                    self:up(id)
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, data)
            -- end
        elseif state == STATE.up_already then
            -- if val.type == self._commodityType.Equip then
            --     local params = { itemData = itemData, opt = self._equipOptState.Down, price = val.price }
            --     global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankDownGetEquipPanel_Open, params)
            -- else
                local data = {}
                data.txt = GET_STRING(600000142)--是否下架该商品
                data.callback = function(res)
                    if res == 2 then
                        self:down(id)
                    end
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, data)
            -- end
        elseif state == STATE.selling then --售卖中        
            self:invalidDoing()
        end

    elseif name == "Button_2" then --取回 -- (上架失败)删除
        if state == STATE.up_fail then --上架失败
            self._tradingBankProxy:reqDelete(self, { commodity_id = id }, handler(self, self.resGet))
        elseif state == STATE.invalid or state == STATE.down_already then
            -- if val.type == self._commodityType.Equip then 
            --     local params = {itemData = itemData, opt = self._equipOptState.Get, price = val.price}
            --     global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankDownGetEquipPanel_Open, params)
            -- else
            local data = {}
            data.txt = GET_STRING(600000141)--回到背包里
            if val.type == self._commodityType.Equip then 
                data.txt = GET_STRING(600000629)--邮件下发
            end
            data.callback = function(res)
                if res == 2 then
                    self:get(id)
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, data)
            -- end
        elseif state == STATE.up_already then
            local data = {}
            data.txt = GET_STRING(600000143)--请先下架商品再尝试取回
            data.btntext = { GET_STRING(600000139), GET_STRING(600000138) }
            data.callback = function(res)
                if res == 2 then
                    self:down(id)
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, data)
        elseif state == STATE.selling then
            self:invalidDoing()
        end
    else--Button_3 -- 修改
        if state == STATE.up_already then
            local data = {}
            data.txt = GET_STRING(600000144)--请先下架商品再尝试修改
            data.btntext = { GET_STRING(600000139), GET_STRING(600000138) }
            data.callback = function(res)
                if res == 2 then
                    self:down(id)
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, data)
        elseif state == STATE.down_already then
            -- if val.type == self._commodityType.Equip then 
            --     local params = {itemData = itemData, opt = self._equipOptState.Up, price = val.price}
            --     global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankUpModifyEquipPanel_Open, params)
            -- else
            local data = {}
            data.txt = ""
            data.price = val.price
            data.callback = function(res, newprice)
                if res == 2 then
                    if not self:isGoodNumber(newprice) then
                        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000116))
                        return true
                    end
                    local nprice = tonumber(newprice)
                    self:modify(id, nprice)
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, data)
            -- end
        elseif state == STATE.selling then
            self:invalidDoing()
        end
    end
end

function TradingBankGoodsLayer:invalidDoing()
    local data = {}
    data.txt = GET_STRING(600000183)--无法进行操作
    data.callback = function(res)
        -- if res == 2 then
        --     self:down(id)
        -- end
    end
    data.btntext = { GET_STRING(600000139) }
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open, data)
    -- body
end
function TradingBankGoodsLayer:isGoodNumber(str)
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
function TradingBankGoodsLayer:IsNumber(str)
    if string.find(str, "[^%d]") then
        return false
    end
    return true
end
function TradingBankGoodsLayer:resGet(success, response, code)
    local TradingBankGoodsLayerMediator = global.Facade:retrieveMediator("TradingBankGoodsLayerMediator")
    if not TradingBankGoodsLayerMediator._layer then
        return
    end
    if success then
        local data = cjson.decode(response)
        if data.code == 200 then
            self.m_modfiy = true

            local val = {
                page = self.m_page,
                pagenum = self.m_pagenum,

            }

            self:ReqgetMyGoodsInfo(val, handler(self, self.refListView))
            -- else
            -- global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg or "")
        end
        global.Facade:sendNotification(global.NoticeTable.SystemTips, data.msg or "")
    else
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000137))

    end
end
--下架
function TradingBankGoodsLayer:down(id)
    self._tradingBankProxy:reqDownShelf(self, { commodity_id = id }, handler(self, self.resGet))
end
--上架
function TradingBankGoodsLayer:up(id)
    self._tradingBankProxy:reqOnShelf(self, { commodity_id = id }, handler(self, self.resGet))
end
--取回
function TradingBankGoodsLayer:get(id)
    self._tradingBankProxy:reqTakeBack(self, { commodity_id = id }, handler(self, self.resGet))
end
--修改
function TradingBankGoodsLayer:modify(id, price)
    self._tradingBankProxy:reqModifyPrice(self, { commodity_id = id, price = price }, handler(self, self.resGet))
end
function TradingBankGoodsLayer:exitLayer()
    self._tradingBankProxy:removeLayer(self)
end
-------------------------------------
return TradingBankGoodsLayer