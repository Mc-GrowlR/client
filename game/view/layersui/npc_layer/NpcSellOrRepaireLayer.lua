local BaseLayer = requireLayerUI("BaseLayer")
local NpcSellOrRepaireLayer = class("NpcSellOrRepaireLayer", BaseLayer)

local RichTextHelper = requireUtil("RichTextHelp")

function NpcSellOrRepaireLayer:ctor()
    self.layerType = 0
end

function NpcSellOrRepaireLayer.create()
    local layer = NpcSellOrRepaireLayer.new()
    if layer and layer:Init() then
        return layer
    end

    return nil
end

function NpcSellOrRepaireLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function NpcSellOrRepaireLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_SELL_REPAIRE)
    NPCSellRepaire.main()

    self.layerType = data and data.type or 1

    self._root = self._quickUI.Panel_1
    self.itemNode = self._quickUI.Node_item
    self.textPrice = self._quickUI.Text_price

    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)

    self.goToType = {
        [NPCProxy.EVENT_TYPE.SELL] = ItemMoveProxy.ItemGoTo.SELL,
        [NPCProxy.EVENT_TYPE.REPAIRE] = ItemMoveProxy.ItemGoTo.REPAIRE,
        [NPCProxy.EVENT_TYPE.DOSOMETHING] = ItemMoveProxy.ItemGoTo.NPC_DO_SOMETHING,
        [NPCProxy.EVENT_TYPE.NEWTYPE] = ItemMoveProxy.ItemGoTo.NEWTYPE,
    }

    self.fromType = {
        [NPCProxy.EVENT_TYPE.SELL] = ItemMoveProxy.ItemFrom.SELL,
        [NPCProxy.EVENT_TYPE.REPAIRE] = ItemMoveProxy.ItemFrom.REPAIRE,
        [NPCProxy.EVENT_TYPE.DOSOMETHING] = ItemMoveProxy.ItemFrom.NPC_DO_SOMETHING,
        [NPCProxy.EVENT_TYPE.NEWTYPE] = ItemMoveProxy.ItemFrom.NEWTYPE,
    }

    self:InitUI()

    return true
end

function NpcSellOrRepaireLayer:InitUI()
    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)

    self._quickUI.Button_close:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Sell_Repaire_Close)
    end)

    self._quickUI.Button_ok:addClickEventListener(function()
        if self.layerType == NPCProxy.EVENT_TYPE.REPAIRE then
            local NPCRepaireProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCRepaireProxy)
            NPCRepaireProxy:RequestNpcStoreRepaire()

        elseif self.layerType == NPCProxy.EVENT_TYPE.SELL then
            local NPCSellProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCSellProxy)
            NPCSellProxy:RequestNpcStoreSell()

        elseif self.layerType == NPCProxy.EVENT_TYPE.DOSOMETHING then
            local NPCDoSomethingProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCDoSomethingProxy)
            NPCDoSomethingProxy:RequestNpcDoSomething()

        elseif self.layerType == NPCProxy.EVENT_TYPE.NEWTYPE then
            local NPCNewTypeOkProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCNewTypeOkProxy)
            NPCNewTypeOkProxy:RequestNpcNewTypeOk()
        end
    end)

    local strWay = GET_STRING(90030000 + self.layerType)
    if self.layerType == NPCProxy.EVENT_TYPE.DOSOMETHING then
        local NPCDoSomethingProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCDoSomethingProxy)
        local param = NPCDoSomethingProxy:GetDoSomethingParam()
        strWay = param.Title or ""

    elseif self.layerType == NPCProxy.EVENT_TYPE.NEWTYPE then
        local NPCNewTypeOkProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCNewTypeOkProxy)
        local param = NPCNewTypeOkProxy:GetDoSomethingParam()
        strWay = param.Title or ""
    end
    self._quickUI.Text_way:setString(strWay)

    local panelTouchEvent = self._quickUI.Panel_touchEvents
    panelTouchEvent:setSwallowTouches(false)

    local function addItemIntoBag(touchPos)
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        local state = ItemMoveProxy:GetMovingItemState()
        local gotoWay = self.goToType[self.layerType]
        if state and gotoWay then
            local data = {}
            data.target = gotoWay
            data.pos = touchPos
            ItemMoveProxy:CheckAndCallBack(data)
        else
            return -1
        end
    end

    local function setNoSwallowMouse()
        return -1
    end

    global.mouseEventController:registerMouseButtonEvent(panelTouchEvent, {
        down_r = setNoSwallowMouse,
        special_r = addItemIntoBag
    })
end

function NpcSellOrRepaireLayer:UpDateLayerParam(data)
    if not data then
        return
    end

    if data.price then
        self:UpdateItemSellPrice(data.price, data.way)
    end

    if data.itemData then
        self:UpDateItems(data.itemData)
    end

    if data.reset then
        self:CleanStateAndData(data.way)
    end
end

function NpcSellOrRepaireLayer:UpdateItemSellPrice(price, way)
    if price and way == self.layerType then
        if price <= 0 then
            self.textPrice:setString(string.format(GET_STRING(3001), GET_STRING(3000)))
        else
            self.textPrice:setString(string.format(GET_STRING(3001), price))
        end
    end
end

function NpcSellOrRepaireLayer:UpDateItems(data)
    if not data and self.itemNode then
        return
    end

    self.textPrice:setVisible(true)

    self.itemNode:removeAllChildren()

    local info = {}
    info.itemData = data
    info.index = data.Index
    info.look = true
    info.movable = true
    info.from = self.fromType[self.layerType]
    local goodItem = GoodsItem:create(info)

    local function cancelCallBack()
        if self and self.textPrice then
            self.textPrice:setVisible(true)
        end
    end
    goodItem:addMoveCancelCallBack(cancelCallBack)
    self.itemNode:addChild(goodItem)
end

function NpcSellOrRepaireLayer:CleanStateAndData(way)
    if self.itemNode and way and way == self.layerType then
        self.itemNode:removeAllChildren()
    end

    if self.textPrice then
        self.textPrice:setString("")
    end

    -- 刷新一遍背包 将隐藏的刷出来
    global.Facade:sendNotification(global.NoticeTable.Bag_Item_Pos_Change)
end

function NpcSellOrRepaireLayer:OnBeginMovingState()
    if self.textPrice then
        self.textPrice:setVisible(false)
    end
end

function NpcSellOrRepaireLayer:GetLayerItemFrom()
    return self.fromType[self.layerType]
end

return NpcSellOrRepaireLayer