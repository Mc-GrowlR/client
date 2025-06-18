local BaseLayer = requireLayerUI("BaseLayer")
local TradingBankBuyLayer = class("TradingBankBuyLayer", BaseLayer)
local RichTextHelp = requireUtil("RichTextHelp")
local cjson = require("cjson")
local LayerNodeOpen = {
    "Layer_TradingBankBuyRoleLayer_Open", --
    "Layer_TradingBankBuyMoneyLayer_Open", --
    "Layer_TradingBankBuyEquipLayer_Open", --
    "Layer_TradingBankBuyMeLayer_Open", --
}

local LayerNodeClose = {
    "Layer_TradingBankBuyRoleLayer_Close",
    "Layer_TradingBankBuyMoneyLayer_Close",
    "Layer_TradingBankBuyEquipLayer_Close",
    "Layer_TradingBankBuyMeLayer_Close",
}

local BuyType = {
    Role = 1,
    Money = 2,
    Equip = 3,
    Me = 4,
}

local ShowTypeButtons = {
    BuyType.Role,
    BuyType.Money,
    BuyType.Equip,
    BuyType.Me
}

local BuyTypeName = {
    [BuyType.Role] = GET_STRING(600000001),
    [BuyType.Money] = GET_STRING(600000002),
    [BuyType.Equip] = GET_STRING(600000603),
    [BuyType.Me] = GET_STRING(600000003)
}

local TipsDesc = {
    [BuyType.Role] = GET_STRING(600000004),
    [BuyType.Money] = GET_STRING(600000005),
    [BuyType.Equip] = GET_STRING(600000604),
    [BuyType.Me] = GET_STRING(600000006)
}


local EquipListName = "ListView_equip_list"
local ListView_equip_list_index = 3

function TradingBankBuyLayer:ctor()
    TradingBankBuyLayer.super.ctor(self)
    self._tradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
end

function TradingBankBuyLayer.create(...)
    local ui = TradingBankBuyLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function TradingBankBuyLayer:Init(data)
    local path = GUI:LoadInternalExport(self, "trading_bank/trading_bank_buy")
    self._root = ui_delegate(self)
    self:InitUI(data)
    self:ReqEquipType()
    return true
end

function TradingBankBuyLayer:InitUI(data)
    self._root.Button_Type1:setVisible(false)
    self._root.Button_Type2:setVisible(false)
    
    self._tradingBankProxy:cancelEmpty(self._root.TextField_search)
    self._root.Button_search:addClickEventListener(handler(self, self.OnSearchClick))
    self:SetTip(BuyType.Role)
    self._currentBuyType = BuyType.Role
end

function TradingBankBuyLayer:InitBuyTypeBtn()
    self._buyTypeButtons = {}
    local panel, btn
    for i, type in ipairs(ShowTypeButtons) do
        btn = self._root.Button_Type1:cloneEx()
        self._root.ListView_type:pushBackCustomItem(btn)
        btn:setVisible(true)
        btn:setTitleText(BuyTypeName[type])
        btn:addClickEventListener(function()
            self:SetSelectBuyTypeButton(type)
            self:SetTip(type)
            self:SetSelectPanel(type)
            if type == BuyType.Equip then
                self:AddEquipListButton()
            elseif self._currentBuyType == BuyType.Equip then
                self:RmvEquipListButton()
            end
            self._currentBuyType = type
        end)
        btn._type = type
        table.insert(self._buyTypeButtons, btn)
    end
    self:SetSelectBuyTypeButton(ShowTypeButtons[1])
    self:SetTip(ShowTypeButtons[1])
    self:SetSelectPanel(ShowTypeButtons[1])
    self._currentBuyType = ShowTypeButtons[1]
end

function TradingBankBuyLayer:ReqEquipType()
    self._tradingBankProxy:reqEquipType(self,{},function(success, response, code)
        if success then
            local data = cjson.decode(response)
            if data.code == 200 then
                data = data.data
                local list  = data.list or {}
                dump(data,"data___")
                self._EquipTypes = {}
                table.insert(self._EquipTypes,{type = "0",name = "全部"})
                for k, v in pairs(list) do
                    table.insert(self._EquipTypes,{type = k,name = v})
                end
                TipsDesc[BuyType.Equip] = data.sell_desc or ""
                if self._currentBuyType == BuyType.Equip then 
                    self:SetTip(BuyType.Equip)
                end
                --开关
                ShowTypeButtons = {}
                local sell_config =  data.sell_config or {}
                if sell_config.role_sell_switch and sell_config.role_sell_switch == 1 then 
                    table.insert(ShowTypeButtons, BuyType.Role)
                end
                if sell_config.coin_sell_switch and sell_config.coin_sell_switch == 1 then 
                    table.insert(ShowTypeButtons, BuyType.Money)
                end
                if sell_config.equip_sell_switch and sell_config.equip_sell_switch == 1 then 
                    table.insert(ShowTypeButtons, BuyType.Equip)
                end
                table.insert(ShowTypeButtons, BuyType.Me)
                self:InitBuyTypeBtn()
            else 
                ShowSystemTips(data.msg or "")    
            end
        else
            ShowSystemTips(GET_STRING(600000617))
        end
    end)
end

function TradingBankBuyLayer:AddEquipListButton()
    if not self._EquipTypes then 
        ShowSystemTips(GET_STRING(600000620))
        return 
    end
    local ListView_equip_list = ccui.ListView:create()
    GUI:setName(ListView_equip_list, EquipListName)
	GUI:ListView_setItemsMargin(ListView_equip_list, 2)
	GUI:setTouchEnabled(ListView_equip_list, true)
    GUI:ListView_setClippingEnabled(ListView_equip_list, true)
    GUI:ListView_setGravity(ListView_equip_list, 2)

    local buyTypeNum = #ShowTypeButtons
    local buyTypeMargin = GUI:ListView_getItemsMargin(self._root.ListView_type)
    local listTypeContentSize = self._root.ListView_type:getContentSize()
    local buyTypeBtnSize = self._root.Button_Type1:getContentSize()
    
    local equipTypeNum = #self._EquipTypes
    local equipTypeMargin = GUI:ListView_getItemsMargin(ListView_equip_list)
    local equipTypeBtnSize = self._root.Button_Type2:getContentSize()

    local maxEquipTypeListHeight = listTypeContentSize.height - buyTypeBtnSize.height * buyTypeNum - buyTypeMargin * (buyTypeNum - 1)
    local equipTypeListHeight = math.min(maxEquipTypeListHeight, equipTypeBtnSize.height * equipTypeNum + equipTypeMargin * (equipTypeNum - 1))
    ListView_equip_list:setContentSize(listTypeContentSize.width, equipTypeListHeight)
    self._equipTypeButtons = {}
    for i, v in ipairs(self._EquipTypes) do
        local name = v.name
        local type = v.type
        local buttonType2 = self._root.Button_Type2:cloneEx()
        buttonType2:setVisible(true)
        -- buttonType2:setPositionX(0)
        buttonType2:setTitleText(name)
        buttonType2:addClickEventListener(function()
            global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyEquipLayer_TypeChange, { type = type })
            self:SetEquipTypeButton(type)
        end)
        ListView_equip_list:pushBackCustomItem(buttonType2)
        table.insert(self._equipTypeButtons, buttonType2)
        buttonType2._type = type
    end
    self:SetEquipTypeButton("0")--全部
    self._root.ListView_type:insertCustomItem(ListView_equip_list, ListView_equip_list_index)
end

function TradingBankBuyLayer:RmvEquipListButton()
    local equipList = self._root.ListView_type:getItem(ListView_equip_list_index)
    if equipList:getName() == EquipListName then
        self._root.ListView_type:removeItem(ListView_equip_list_index)
    end
end

function TradingBankBuyLayer:SetEquipTypeButton(type)
    for i, btn in ipairs(self._equipTypeButtons) do
        btn:setEnabled(btn._type ~= type)
        btn:setTitleFontSize(global.isWinPlayMode and 12 or 15)
        local selColor = global.isWinPlayMode and "#e6e7a7" or "#f8e6c6"
        GUI:Button_setTitleColor(btn, type == btn._type and selColor or "#807256")
        GUI:Button_titleEnableOutline(btn, "#111111", 2)
    end
end

function TradingBankBuyLayer:SetSelectPanel(type)
    self:RemovePanel()
    global.Facade:sendNotification(global.NoticeTable[LayerNodeOpen[type]], { parent = self._root.Node_1 })
    
    if type ~= BuyType.Me then 
        local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
        TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingBuyLayerSecondTab, {second_level_tab_name = BuyTypeName[type]})
    end
end

function TradingBankBuyLayer:SetSelectBuyTypeButton(type)
    for i, btn in ipairs(self._buyTypeButtons) do
        btn:setEnabled(type ~= btn._type)
        btn:setTitleFontSize(global.isWinPlayMode and 13 or 16)
        local selColor = global.isWinPlayMode and "#e6e7a7" or "#f8e6c6"
        GUI:Button_setTitleColor(btn, type == btn._type and selColor or "#807256")
        GUI:Button_titleEnableOutline(btn, "#111111", 2)
    end
end

function TradingBankBuyLayer:SetTip(type)
    local str = TipsDesc[type]
    self._root.Text_tip:setString(str)
    if type == BuyType.Role then
        self._root.Text_tip:setPositionY(68)
        self._root.Image_bottom:setVisible(true)
        self._root.TextField_search:setPlaceHolder(GET_STRING(600000605))
    elseif type == BuyType.Equip then
        self._root.Text_tip:setPositionY(68)
        self._root.Image_bottom:setVisible(true)
        self._root.TextField_search:setPlaceHolder(GET_STRING(600000606))
    else
        self._root.Text_tip:setPositionY(48)
        self._root.Image_bottom:setVisible(false)
    end
end

function TradingBankBuyLayer:OnSearchClick()
    --搜索
    local name = self._root.TextField_search:getString()
    dump(name, "name____")
    dump(self._currentBuyType,"self._currentBuyType___")
    if self._currentBuyType == BuyType.Role then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyRoleLayer_Search, name)
    elseif self._currentBuyType == BuyType.Equip then
        global.Facade:sendNotification(global.NoticeTable.Layer_TradingBankBuyEquipLayer_Search, name)
    end

    local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    TradingBankProxy:doTrack(TradingBankProxy.UpLoadData.TraingBuySearchClick,{search_name = name})
end
function TradingBankBuyLayer:RemovePanel()
    global.Facade:sendNotification(global.NoticeTable[LayerNodeClose[self._currentBuyType]])
end

function TradingBankBuyLayer:ExitLayer()
    self._tradingBankProxy:removeLayer(self)
end

return TradingBankBuyLayer