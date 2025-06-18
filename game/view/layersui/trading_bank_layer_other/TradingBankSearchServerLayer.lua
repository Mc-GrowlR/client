local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankSearchServerLayer = class("TradingBankSearchServerLayer", BaseLayer)
local cjson = require("cjson")

function TradingBankSearchServerLayer:ctor()
    TradingBankSearchServerLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)

end

--  1 第一个按钮 2第二个按钮 
function TradingBankSearchServerLayer.create(...)
    local ui = TradingBankSearchServerLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end


function TradingBankSearchServerLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_search_server")
    self._root = ui_delegate(self)
    self:InitAdapt()

    ---init
    self._callback = data.callback

    self._page = 1
    self._maxpage = 1
    self._pagenum = 10
    self._serverName = nil
    self._root.Panel_show:setVisible(false)
    self._root.Panel_1:setVisible(false)
    self._root.Button_search:addClickEventListener(function ()
        local serverName = self._root.TextField_4:getString()
        serverName = string.trim(serverName)
        self._serverName = serverName
        if string.len(serverName) > 0 then 
            self._page = 1
            self._maxpage = 1
            self._pagenum = 10
            self._root.ListView_1:removeAllItems()
            self:getServerNames({pageNum = self._page, pageSize = self._pagenum ,serverName = self._serverName}, handler(self,self.resGetServerNames))
            
        end
    end)

    self._root.Panel_cancel:addClickEventListener(function()
        if self._root.Panel_show:isVisible() then 
            self._root.Panel_show:setVisible(false)
        end
    end)

    self._root.Button_close:addClickEventListener(function ()
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankSearchServerLayer_Close_other)
    end)
    
    self._root.ListView_1:addScrollViewEventListener(function(sender, event)
        local itemnum = #sender:getItems()
        local Bottomitem = sender:getBottommostItemInCurrentView()
        local lastitem = sender:getItem(itemnum - 1)
        if (event == 1 or (event == 10 and lastitem == Bottomitem)) and self._page < self._maxpage and not self._reqState then
            self:getServerNames({pageNum = self._page + 1, pageSize = self._pagenum,serverName = self._serverName}, handler(self,self.resGetServerNames))
        end
    end)

    return true
end

function TradingBankSearchServerLayer:getServerNames(val, callback)
    self._reqState = true
    self.OtherTradingBankProxy:getServerNames(self, val, callback)
end

function TradingBankSearchServerLayer:resGetServerNames(code, data, msg)
    dump({code, data, msg},"resGetServerNames___")
    self._reqState = false
    if code == 200 then 
        self._page = data.pageNum or 1
        self._maxpage =  data.pageTotal or  1
        self._pagenum =  data.pageSize or  10
        local serverList =  data.records or {}
        if self._page == 1  and  #serverList == 0 then 
            ShowSystemTips(GET_STRING(600002001))
            self._root.Panel_show:setVisible(false)
        else 
            self._root.Panel_show:setVisible(true)
        end
        self:refListView(serverList)
    else
        ShowSystemTips(msg or "接口异常")
    end
end

function TradingBankSearchServerLayer:refListView(data)
    local lastIndex = #self._root.ListView_1:getItems() - 1
    for i, v in ipairs(data) do
        local it = self._root.Panel_1:cloneEx()
        it:setVisible(true)
        local Text_1 = it:getChildByName("Text_1")
        local Image_1 = it:getChildByName("Image_1")
        Image_1:setVisible(false)
        Text_1:setString(v.serverName or "")
        it:addTouchEventListener(handler(self, self.onItemClick))
        it.data = v
        self._root.ListView_1:pushBackCustomItem(it)
    end
    self._root.ListView_1:jumpToItem(lastIndex, cc.p(0, 0), cc.p(0, 0))
end

function TradingBankSearchServerLayer:onItemClick(sender, type)
    if type ~= 2 then
        return
    end
    
    if self._callback then
        self._callback(sender.data)
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankSearchServerLayer_Close_other)
end

function TradingBankSearchServerLayer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_cancel, winSizeW, winSizeH)
    GUI:setPosition(self._root.Image_1, winSizeW / 2, winSizeH / 2)
end



return TradingBankSearchServerLayer