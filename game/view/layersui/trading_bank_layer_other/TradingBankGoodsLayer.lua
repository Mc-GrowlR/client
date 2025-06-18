local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankGoodsLayer = class("TradingBankGoodsLayer", BaseLayer)
local QuickCell = requireUtil("QuickCell")
local cjson = require("cjson")

local STATE = {
    retrieve_fail = -4, --取回失败
    up_fail = -3, --上架失败
    -- invalid = -2,--已失效
    --no_pass = -1，-- 未通过
    up_already = 1, --已上架
    down_already = 2, --已下架
    selling = 3, --出售中
    --buyer_declined = 5,--买家拒绝购买
    uping = 6, --上架中
    geting = 7, --取回中



}
function TradingBankGoodsLayer:ctor()
    TradingBankGoodsLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankGoodsLayer.create(...)
    local ui = TradingBankGoodsLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankGoodsLayer:Init(data)
    GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_goods")
    self._root = ui_delegate(self)
    self.m_page = 1
    self.m_maxpage = 1
    self.m_pagenum = 10
    self.m_data = {}
    self.m_selType = 1

    self._root.Panel_1:setVisible(false)
    ------------------------
    local function checkConsignmentSwitch ()
        self.OtherTradingBankProxy:checkConsignmentSwitch(self, {}, function(code, val, msg)
            if code == 200 then
                if val then
                    self._root.Panel_1:setVisible(true)
                    self:RefMyGoodsList()
                else --还未验证手机
                    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open_other, { callback = function(code)
                        if code == 1 then--手机验证成功
                            self._root.Panel_1:setVisible(true)
                            self:RefMyGoodsList()
    
                        end
                    end,  openLock = true })
                end
            else
                ShowSystemTips(msg)
            end
        end)
    end
    
    self:InitUI(data)

    --检测绑定手机
    self.OtherTradingBankProxy:checkBindPhone(self,{}, function (code, data, msg)
        if code  == 200 then 
            if data then 
                checkConsignmentSwitch()
            else
                global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankPhoneLayer_Open_other, { callback = function(code)
                    if code == 1 then--手机绑定成功 --自动开启寄售锁
                        self._root.Panel_1:setVisible(true)
                        self:RefMyGoodsList()
                    end
                end})
            end
        else
            ShowSystemTips(msg)
        end
    end)
    return true
end

function TradingBankGoodsLayer:RefMyGoodsList()
    local val = {
        page = self.m_page,
        pagenum = self.m_pagenum,
    }
    self:ReqgetMyGoodsInfo(val, handler(self, self.refListView))
end
function TradingBankGoodsLayer:InitUI(data)
    self._root.Panel_item:setVisible(false)
    self._root.ListView_2:addScrollViewEventListener(function(sender, event)
        local itemnum = #sender:getItems()
        local Bottomitem = sender:getBottommostItemInCurrentView()
        local lastitem = sender:getItem(itemnum - 1)
        if (event == 1 or (event == 10 and lastitem == Bottomitem)) and self.m_page < self.m_maxpage and not self.m_reqState and not self.m_modfiy then
            self.m_page = self.m_page + 1
            self:RefMyGoodsList()
        end
    end)
end
function TradingBankGoodsLayer:ReqgetMyGoodsInfo(val, func)
    self.m_reqState = true
    self.OtherTradingBankProxy:getMyGoodsInfo(self, val, func)
end

function TradingBankGoodsLayer:refListView(code, data, msg)
    self.m_reqState = false
    if code == 200 then
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
        self.m_page = data.current
        self.m_maxpage = data.pages
        local listdata = data.records
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

    else
        ShowSystemTips(msg)
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



    -- Text_name:setString(data.role or "")
    Text_pirce:setString(data.price or "0")

    Text_num:setString(data.coinNum or "0")
    local stateTxt = {

        [-3] = GET_STRING(600000122),
        [-2] = GET_STRING(600000123),
        [1] = GET_STRING(600000124),
        [2] = GET_STRING(600000125),
        [3] = GET_STRING(600000184),
        [6] = GET_STRING(600000126),
        [7] = GET_STRING(600000127),
    }
    Text_state:setString(stateTxt[data.status or -2])
    if data.type == 2 then
        Text_goodname:setString(data.coinConfigTypeName or "")
        -- Image_head:loadTexture(global.MMO.PATH_RES_PRIVATE.."trading_bank/img_cost.png")
        Image_item:setVisible(false)
        Text_goodname:setPositionX(Text_goodname:getPositionX() - 30)
        Text_goodname:setFontSize(20)
    else
        Text_goodname:setFontSize(16)
        local jobid = data.roleConfigId or 0
        jobid = tonumber(jobid)
        local jobName = GET_STRING(600000111 + jobid)
        local sex = data.sex or 0 -- 0-1 男女
        Text_goodname:setString(GET_STRING(600000121) .. ":" .. jobName)
        Image_head:loadTexture(global.MMO.PATH_RES_PRIVATE .. "trading_bank/img_0" .. (sex + 1) .. (jobid + 1) .. ".png")
    end
    local state = data.status
    for i = 1, 3 do
        local btn = item:getChildByName("Button_" .. i)
        btn.val = data
        btn:addTouchEventListener(handler(self, self.onBtnClick))

        if state == STATE.up_fail then -- 上架失败
            --重新上架/取回
            if i == 1 then
                btn:setTitleText(GET_STRING(600000412))
            elseif i == 3 then
                btn:setVisible(false)
            end
        elseif state == STATE.up_already then --已上架--都显示
            --下架/取回/修改
            if i == 1 then
                btn:setTitleText(GET_STRING(600000136))
            end
        elseif state == STATE.down_already then--已下架
        elseif state == STATE.retrieve_fail then --取回失败
        elseif state == STATE.selling then --出售中 
        else --上架中  取回中  
            btn:setVisible(false)
        end
    end

    return item
end

function TradingBankGoodsLayer:onBtnClick(sender, type)
    if type ~= 2 then
        return
    end
    --下架  修改   取回  。。。  上架 修改 取回    。。。  下架  修改   取回 
    local name = sender:getName()
    local val = sender.val
    local state = val.status
    local id = val.id
    if name == "Button_1" then -- 上架/下架
        if state == STATE.down_already or state == STATE.up_fail or state == STATE.retrieve_fail then
            local data = {}
            data.txt = GET_STRING(600000140)--重新上架
            data.callback = function(res)
                if res == 2 then
                    self:up(id)
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, data)
        elseif state == STATE.up_already then
            self.OtherTradingBankProxy:doTrack(self.OtherTradingBankProxy.UpLoadData.TraingGoodsLayerDownBtnClick)
            local data = {}
            data.txt = GET_STRING(600000142)--是否下架该商品
            data.btntext = { GET_STRING(600000170), GET_STRING(600000138) }
            data.callback = function(res)
                if res == 2 then
                    self:down(id)
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, data)
        elseif state == STATE.selling then --售卖中        
            self:invalidDoing()
        end

    elseif name == "Button_2" then --取回 
        self.OtherTradingBankProxy:doTrack(self.OtherTradingBankProxy.UpLoadData.TraingGoodsLayerGetBtnClick)
        -- if state == STATE.up_fail then --上架失败
        -- self.OtherTradingBankProxy:reqDelete(self, { commodity_id = id }, handler(self, self.resGet))
        if state == STATE.down_already
        or state == STATE.up_fail
        or state == STATE.retrieve_fail then

            local data = {}
            data.txt = GET_STRING(600000141)--回到背包里
            data.callback = function(res)
                if res == 2 then
                    self:get(id)
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, data)
        elseif state == STATE.up_already then
            local data = {}
            data.txt = GET_STRING(600000143)--请先下架商品再尝试取回
            data.btntext = { GET_STRING(600000170), GET_STRING(600000138) }
            data.callback = function(res)
                if res == 2 then
                    self:down(id)
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, data)
        elseif state == STATE.selling then
            self:invalidDoing()
        end
    else--Button_3 -- 修改
        self.OtherTradingBankProxy:doTrack(self.OtherTradingBankProxy.UpLoadData.TraingGoodsLayerModityBtnClick)
        if state == STATE.up_already then
            local data = {}
            data.txt = GET_STRING(600000144)--请先下架商品再尝试修改
            data.btntext = { GET_STRING(600000170), GET_STRING(600000138) }
            data.callback = function(res)
                if res == 2 then
                    self:down(id)
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, data)
        elseif state == STATE.down_already or state == STATE.retrieve_fail then
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
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, data)
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
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankTipsLayer_Open_other, data)
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
function TradingBankGoodsLayer:resGet(code, data, msg)
    if code == 200 then
        self.m_modfiy = true
        local val = {
            page = self.m_page,
            pagenum = self.m_pagenum,
        }
        self:ReqgetMyGoodsInfo(val, handler(self, self.refListView))
    end
    ShowSystemTips(msg or GET_STRING(600000414))
end
--下架
function TradingBankGoodsLayer:down(id)
    self.OtherTradingBankProxy:reqDownShelf(self, { commodity_id = id }, handler(self, self.resGet))
end
--上架
function TradingBankGoodsLayer:up(id)
    self.OtherTradingBankProxy:reqOnShelf(self, { commodity_id = id }, handler(self, self.resGet))
end
--取回
function TradingBankGoodsLayer:get(id)
    self.OtherTradingBankProxy:reqTakeBack(self, { commodity_id = id }, handler(self, self.resGet))
end
--修改
function TradingBankGoodsLayer:modify(id, price)
    self.OtherTradingBankProxy:reqModifyPrice(self, { commodity_id = id, price = price }, handler(self, self.resGet))
end
function TradingBankGoodsLayer:exitLayer()
    self.OtherTradingBankProxy:removeLayer(self)
end
-------------------------------------
return TradingBankGoodsLayer