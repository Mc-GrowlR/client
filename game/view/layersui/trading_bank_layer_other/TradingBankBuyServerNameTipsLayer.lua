local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankBuyServerNameTipsLayer = class("TradingBankBuyServerNameTipsLayer", BaseLayer)
local cjson = require("cjson")

function TradingBankBuyServerNameTipsLayer:ctor()
    TradingBankBuyServerNameTipsLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankBuyServerNameTipsLayer.create(...)
    local ui = TradingBankBuyServerNameTipsLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankBuyServerNameTipsLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_buy_server_name_tip")
    self._root = ui_delegate(self)
    self:InitAdapt()
    self._root.Panel_cancel:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyServerNameTipsLayer_Close_other)
    end)
    dump(data,"TradingBankBuyServerNameTipsLayer data___")
    self._pos = data.pos 
    self._selectServerID = data.serverID
    self._callback = data.callback
    self._maxTextWidth = 56
    self._listViewHeight = 270
    self._listItemHeight = 30
    self:initView()
    
    self._page = 1
    self._maxpage = 1
    self._pagenum = 10
    self:getServerNames({pageNum = self._page, pageSize = self._pagenum}, handler(self,self.resGetServerNames))
    return true
end

function TradingBankBuyServerNameTipsLayer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_cancel, winSizeW, winSizeH)
end

function TradingBankBuyServerNameTipsLayer:getServerNames(val, callback)
    self._reqState = true
    self.OtherTradingBankProxy:getServerNames(self, val, callback)
end

function TradingBankBuyServerNameTipsLayer:resGetServerNames(code, data, msg)
    dump({code, data, msg},"resGetServerNames___")
    self._reqState = false
    if code == 200 then 
        self._page = data.pageNum or 1
        self._maxpage =  data.pageTotal or  1
        self._pagenum =  data.pageSize or  10
        local serverList =  data.records or {}
        self:refListView(serverList)
    else
        ShowSystemTips(msg or "接口异常")
    end
end

function TradingBankBuyServerNameTipsLayer:initView()
    self._root.Panel_1:setVisible(false)
    self._root.Panel_show:setPosition(self._pos)
    local it1 = self._root.Panel_1:cloneEx()
    it1:setVisible(true)
    local Text_1 = it1:getChildByName("Text_1")
    local Image_1 = it1:getChildByName("Image_1")
    Image_1:setVisible(false)
    Text_1:setString("搜索")
    self._root.ListView_1:pushBackCustomItem(it1)
    it1:addClickEventListener(function ()
        if self._callback then
            self._callback({serverId = -2})
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyServerNameTipsLayer_Close_other)
    end)

    local it = self._root.Panel_1:cloneEx()
    it:setVisible(true)
    local Text_1 = it:getChildByName("Text_1")
    local Image_1 = it:getChildByName("Image_1")
    Image_1:setVisible(self._selectServerID == -1)
    Text_1:setString(GET_STRING(600000706))
    local contentSize = Text_1:getContentSize()
    local width = contentSize.width + 26
    self._maxTextWidth = math.max(self._maxTextWidth, width)
    

    it:addClickEventListener(function ()
        if self._callback then
            self._callback({serverId = -1})
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyServerNameTipsLayer_Close_other)
    end)

    self._root.ListView_1:pushBackCustomItem(it)
    self._root.ListView_1:addScrollViewEventListener(function(sender, event)
        local itemnum = #sender:getItems()
        local Bottomitem = sender:getBottommostItemInCurrentView()
        local lastitem = sender:getItem(itemnum - 1)
        if (event == 1 or (event == 10 and lastitem == Bottomitem)) and self._page < self._maxpage and not self._reqState then
            self:getServerNames({pageNum = self._page + 1, pageSize = self._pagenum}, handler(self,self.resGetServerNames))
        end
    end)

    
    self._root.Panel_show:setContentSize(self._maxTextWidth,  self._listItemHeight)
    self._root.ListView_1:setContentSize(self._maxTextWidth,  self._listItemHeight)
    self._root.Image_2:setContentSize(self._maxTextWidth + 2,  self._listItemHeight + 2)

    self._root.ListView_1:setPositionY(self._listItemHeight)
    self._root.Image_2:setPositionY(self._listItemHeight )

end

function TradingBankBuyServerNameTipsLayer:refListView(data)
    local lastIndex = #self._root.ListView_1:getItems() - 1
    for i, v in ipairs(data) do
        local it = self._root.Panel_1:cloneEx()
        it:setVisible(true)
        local Text_1 = it:getChildByName("Text_1")
        local Image_1 = it:getChildByName("Image_1")
        if self._selectServerID then 
            Image_1:setVisible(tonumber(v.serverId) == tonumber(self._selectServerID))
        else
            Image_1:setVisible(false)
        end
        Text_1:setString(v.serverName or "")
        local width = Text_1:getContentSize().width + 26
        self._maxTextWidth = math.max(self._maxTextWidth, width)
        it:setVisible(true)
        it:addTouchEventListener(handler(self, self.onItemClick))
        
        it.data = v
        self._root.ListView_1:pushBackCustomItem(it)
    end
    local items = self._root.ListView_1:getItems()
    local sumItemHeight = #items * self._listItemHeight
    local listH = math.min(sumItemHeight, self._listViewHeight)
    self._root.ListView_1:setContentSize(self._maxTextWidth, listH)
    self._root.Panel_show:setContentSize(self._maxTextWidth, listH)
    self._root.Image_2:setContentSize(self._maxTextWidth + 2, listH + 2)

    self._root.ListView_1:setPositionY(listH)
    self._root.Image_2:setPositionY(listH)
    for i, item in ipairs(items) do
        item:setContentSize(self._maxTextWidth , self._listItemHeight)
        local Image_1 = item:getChildByName("Image_1")
        Image_1:setContentSize(self._maxTextWidth, self._listItemHeight)
    end
    self._root.ListView_1:jumpToItem(lastIndex, cc.p(0, 0), cc.p(0, 0))
    
end

function TradingBankBuyServerNameTipsLayer:onItemClick(sender, type)
    if type ~= 2 then
        return
    end
    
    if self._callback then
        self._callback(sender.data)
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyServerNameTipsLayer_Close_other)
end

function TradingBankBuyServerNameTipsLayer:exitLayer()
    self.OtherTradingBankProxy:removeLayer(self)
end

return TradingBankBuyServerNameTipsLayer