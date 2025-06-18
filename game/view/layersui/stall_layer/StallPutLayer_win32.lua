local BaseLayer = requireLayerUI("BaseLayer")
local StallPutLayer = class("StallPutLayer", BaseLayer)

function StallPutLayer:ctor()
    StallPutLayer.super.ctor(self)
    self.goldType = 0
    self.sellPrice = 0

    self._proxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
end

function StallPutLayer.create()
    local layer = StallPutLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function StallPutLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function StallPutLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_STALL_PUT)
    StallPut.main(data)

    self:InitTips(data)
end

function StallPutLayer:InitTips(MakeIndex)
    local openCBtn = UIGetChildByName(self._ui.PMainUI, "Button_currency_open")
    local closeCBtn = UIGetChildByName(self._ui.PMainUI, "Button_currency_close")
    local list = UIGetChildByName(self._ui.PMainUI, "ListView_currency")
    local btnCancel = UIGetChildByName(self._ui.PMainUI, "Button_cancel")
    local btnSell = UIGetChildByName(self._ui.PMainUI, "Button_sell")
    local btnClose = UIGetChildByName(self._ui.PMainUI, "Button_close")
    self._ui.TextField_price:setInputMode(2)
    self._ui.TextField_price:setString(0)
    self._ui.TextField_price:addEventListener(function(_, eventType)
            local input = tonumber(self._ui.TextField_price:getString()) or 0
            if input < 0 then
                input = 0
            end
            self.sellPrice = input
    end)

    local function CancelCallBack()
        -- 背包中的重新刷出来
        local data = {
            dropping = {
                MakeIndex = MakeIndex,
                state = 1
            }
        }
        global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
        global.Facade:sendNotification(global.NoticeTable.Layer_Stall_Put_Close)
    end
    btnClose:addClickEventListener(CancelCallBack)
    btnCancel:addClickEventListener(CancelCallBack)

    local function SellCallBack()
        local price = self._ui.TextField_price:getString()
        local isFull = self._proxy:CheckListViewFull()
        if not isFull and price and tonumber(price) > 0 and CheckCanDoSomething() then
            self._proxy:PutItemIntoAutoSellBag(MakeIndex, self.goldType, tonumber(price))
            global.Facade:sendNotification(global.NoticeTable.Layer_Stall_Put_Close)
        else
            CancelCallBack()
        end
    end
    btnSell:addClickEventListener(SellCallBack)

    local lisAction = function(is_open)
        list:stopAllActions()
        local scale = 0
        if is_open then
            list:setVisible(true)
            scale = 1
        end
        local runScale = cc.ScaleTo:create(0.1,1,scale)
        local callback = cc.CallFunc:create(function()
            if not is_open then
                list:setVisible(false)
            end
        end)
        local sequence = cc.Sequence:create(runScale, callback)
        list:runAction(sequence)
    end

    openCBtn:addClickEventListener(function()
        lisAction()
        openCBtn:setVisible(false)
        closeCBtn:setVisible(true)
    end)

    closeCBtn:addClickEventListener(function()
        lisAction(true)
        openCBtn:setVisible(true)
        closeCBtn:setVisible(false)
    end)

    closeCBtn:setVisible(true)

    self:UpdateCurrencyList()
end

--更新货币
function StallPutLayer:UpdateCurrencyList()
    local list = UIGetChildByName(self._ui.PMainUI, "ListView_currency")
    local textItem = UIGetChildByName(self._ui.PMainUI,"Text_currency_item")
    local currencies = self._proxy:getCurrencies()

    local onEvent = function(v)
        if v then
            self.goldType = v.id
            self:UpdateCurrency(v.name)
        end
    end

    for i, v in ipairs(currencies) do
        local text = textItem:cloneEx()
        text:setVisible(true)
        text:setString(v.name)
        text:setTouchEnabled(true)
        text:addClickEventListener(function()
            onEvent(v)
        end)
        list:pushBackCustomItem(text)
    end

    local listWid = list:getContentSize().width
    list:setContentSize(cc.size(listWid, 20 * (#currencies)))

    onEvent(currencies[1])
end

--更新出售的货币  currency_name：货币名
function StallPutLayer:UpdateCurrency(currency_name)
    local currecncyText = UIGetChildByName(self._ui.PMainUI, "Text_currency")
    if currency_name then
        local sform = string.format(StallPut and StallPut._currencyShowStr or GET_STRING(90170004), currency_name)
        currecncyText:setString(sform)
    else
        currecncyText:setString("")
    end
end

return StallPutLayer