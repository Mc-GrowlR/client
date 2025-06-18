local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankBuyTipsLayer = class("TradingBankBuyTipsLayer", BaseLayer)
local cjson = require("cjson")

function TradingBankBuyTipsLayer:ctor()
    TradingBankBuyTipsLayer.super.ctor(self)
    self.OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
end

function TradingBankBuyTipsLayer.create(...)
    local ui = TradingBankBuyTipsLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankBuyTipsLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank_other/trading_bank_buy_tip")
    self._root = ui_delegate(self)
    self:InitAdapt()
    self._root.Panel_cancel:addTouchEventListener(function(sender, type)
        if type ~= 2 then
            return
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyTipsLayer_Close_other)
    end)
    self:RefUI(data)
    return true
end

function TradingBankBuyTipsLayer:InitAdapt()
    local winSizeW = SL:GetMetaValue("SCREEN_WIDTH")
    local winSizeH = SL:GetMetaValue("SCREEN_HEIGHT")
    GUI:setContentSize(self._root.Panel_cancel, winSizeW, winSizeH)
end

function TradingBankBuyTipsLayer:RefUI(data)
    local width = data.width
    local txt = data.txt
    local index = data.index
    local pos = data.pos
    self.m_callback = data.callback
    local item = self._root.Panel_1
    item:setVisible(false)
    local Image_1 = item:getChildByName("Image_1")
    Image_1:setVisible(false)
    local size = item:getContentSize()
    item:setContentSize(width - 2, size.height)
    Image_1:setContentSize(width - 2, size.height)
    local num = #txt
    local ContentH = size.height * num
    self._root.ListView_1:setContentSize(width, ContentH)
    self._root.Panel_show:setContentSize(width, ContentH)
    self._root.Image_2:setContentSize(width, ContentH + 2)
    for i, v in ipairs(txt) do
        local it = item:cloneEx()
        local Text_1 = it:getChildByName("Text_1")
        local Image_1 = it:getChildByName("Image_1")
        Image_1:setVisible(index == i)
        Text_1:setString(v)
        Text_1:setPositionX(width / 2)
        it:setTag(i)
        it:setVisible(true)
        it:addTouchEventListener(handler(self, self.onItemClick))
        self._root.ListView_1:pushBackCustomItem(it)
    end
    self._root.Panel_show:setPosition(pos)
    self._root.ListView_1:setPosition(0, ContentH)
    self._root.Image_2:setPosition(0, ContentH)
end

function TradingBankBuyTipsLayer:onItemClick(sender, type)
    if type ~= 2 then
        return
    end
    local items = self._root.ListView_1:getItems()
    for i, v in ipairs(items) do
        local Image_1 = v:getChildByName("Image_1")
        Image_1:setVisible(sender == v)
    end
    local tag = sender:getTag()
    if self.m_callback then
        self.m_callback(tag)
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyTipsLayer_Close_other)
end

function TradingBankBuyTipsLayer:exitLayer()
    self.OtherTradingBankProxy:removeLayer(self)
end

return TradingBankBuyTipsLayer