local BaseLayer = requireLayerUI("BaseLayer")
local TradeLayer = class("TradeLayer", BaseLayer)

local RichTextHelp = requireUtil("RichTextHelp")

local sformat = string.format

function TradeLayer:ctor()
    TradeLayer.super.ctor(self)
end

function TradeLayer.create()
    local layer = TradeLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function TradeLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function TradeLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_TRADE)
    Trade.main()

    self._proxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
    self._ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)

    self._ui.Button_trade:addClickEventListener(function()
        self._proxy:RequestTradeEnd()
    end)

    self._ui.Button_lock:addClickEventListener(function()
        self._proxy:RequestChangeLock()
    end)

    local isForbid = SL:GetMetaValue("SERVER_OPTION", SW_KEY_NO_SELL_MONEY) == true
    if isForbid then
        self._ui.Panel_addGold:setTouchEnabled(false)
        self._ui.Panel_self:getChildByName("Image_gold"):setTouchEnabled(false)
        self._ui.Panel_self:getChildByName("Text_gold"):setString( GET_STRING(90180025) )
        self._ui.Panel_other:getChildByName("Text_gold"):setString( GET_STRING(90180025) )
    end
    self._ui.Panel_self:getChildByName("Image_forbid"):setVisible(isForbid)
    self._ui.Panel_other:getChildByName("Image_forbid"):setVisible(isForbid)

    self:InitBag()

    self:RegisterMouseEvent()
end 

function TradeLayer:InitBag()
    local data = {pos = {x = 0, y = 0}}
    SL:OpenBagUI(data) 
end

function TradeLayer:RegisterMouseEvent()
    self._ui.Panel_itemTouch:setSwallowTouches(false)

    local ui_imgGold = self._ui.Panel_self:getChildByName("Image_gold")
    ui_imgGold:addClickEventListener(function()
        self._ItemMoveProxy:AddGoldToTrade()
    end)

    self._ui.Panel_addGold:addClickEventListener(function()
        self._ItemMoveProxy:AddGoldToTrade()
    end)

    local function setNoswallowMouse()
        return -1
    end

    local function addItemIntoTrade(touchPos)
        local state = self._ItemMoveProxy:GetMovingItemState()
        if state then
            local goToName = self._ItemMoveProxy.ItemGoTo.TRADE
            local data = {}
            data.target = goToName
            data.pos = touchPos
            data.itemPosInbag = self:GetItemBagEmptyPos(touchPos)
            self._ItemMoveProxy:CheckAndCallBack( data )
        else
            return -1
        end
    end

    global.mouseEventController:registerMouseButtonEvent(
        self._ui.Panel_itemTouch,
        {
            down_r = setNoswallowMouse,
            special_r = addItemIntoTrade
        }
    )

    local function addGoldIntoTrade(touchPos)
        local state = self._ItemMoveProxy:GetMovingItemState()
        if state then
            local goToName = self._ItemMoveProxy.ItemGoTo.TRADE
            local data = {}
            data.target = goToName
            data.pos = touchPos
            data.isGold = true
            data.itemPosInbag = self:GetItemBagEmptyPos(touchPos)
            self._ItemMoveProxy:CheckAndCallBack( data )
        else
            return -1
        end
    end

    global.mouseEventController:registerMouseButtonEvent(ui_imgGold, {down_r = setNoswallowMouse, special_r = addGoldIntoTrade})
    local param = {}
    param.nodeFrom = self._ItemMoveProxy.ItemFrom.TRADE_GOLD
    param.moveNode = ui_imgGold
    param.cancelMoveCall = function()
        ui_imgGold._movingState = false
    end
    RegisterNodeMovable(ui_imgGold, param)
end

function TradeLayer:GetItemBagEmptyPos( touchPos )
    local x = touchPos.x
    local y = touchPos.y
    local panelWorldPos = self._ui.Panel_itemTouch:getWorldPosition()
    local panelSize = self._ui.Panel_itemTouch:getContentSize()
    local posXInPanel = x - panelWorldPos.x
    local posYInPanel = panelWorldPos.y - y
    if posXInPanel >= panelSize.width or posXInPanel <= 0 then
        return nil
    end

    if posYInPanel >= panelSize.height or posYInPanel <= 0 then
        return nil
    end
    local indexX = math.ceil(posXInPanel/global.MMO.TRADE_ITEM_SIZE_WIDTH)
    local indexY = math.floor(posYInPanel/global.MMO.TRADE_ITEM_SIZE_HEIGHT)

    local posIndex = indexY*global.MMO.TRADE_ROW_MAX_ITEM_NUMBER + indexX
    if posIndex > global.MMO.TRADE_MAX_ITEM_NUMBER then
        return nil
    end
    return posIndex
end

function TradeLayer:UpdateItemList( param )
    if not param or not next(param) then
        return
    end

    local panel = self._ui.Panel_self
    local items = self._proxy:GetSelfItemData()
    if param.way == 1 then -- 1为交易方的 其他为自己的
        panel = self._ui.Panel_other
        items = self._proxy:GetOtherItemData()
    end

    local panelItem = panel:getChildByName("Panel_item")
    panelItem:removeAllChildren()

    local itemHeight = global.MMO.TRADE_ITEM_SIZE_HEIGHT
    local itemWidth = global.MMO.TRADE_ITEM_SIZE_WIDTH
    local maxHeight = global.MMO.TRADE_ITEM_PANEL_HEIGHT
    local maxWidth = global.MMO.TRADE_ITEM_PANEL_WIDTH
    local rowMax = global.MMO.TRADE_ROW_MAX_ITEM_NUMBER
    local pos = 1
    for MakeIndex,data in pairs(items) do
        if pos > global.MMO.TRADE_MAX_ITEM_NUMBER then
            return
        end
        local info = {}
        info.itemData = data
        info.index = data.Index
        info.look = true
        info.movable = param.way ~= 1
        info.from = self._ItemMoveProxy.ItemFrom.TRADE
        local goodItem = GoodsItem:create( info )
        local YPos = math.floor((pos-1)/rowMax)
        local XPos = (pos-1)%rowMax
        local posX = XPos*(itemWidth + 1.5) + itemWidth/2   -- 底图带框 适当偏移
        local posY = maxHeight - itemHeight/2 - itemHeight*YPos
        goodItem:setPosition(posX,posY)
        goodItem:setTag(data.MakeIndex)

        local function QuickPutOut()
            self._proxy:TradeItemQuickPutOut(data)
        end
        goodItem:addDoubleEventListener(QuickPutOut)

        if global.isWinPlayMode then
            local function mouseMoveCallBack()
                if goodItem._movingState then
                    return
                end
                local tipsData = {}
                tipsData.itemData = data
                tipsData.pos = goodItem:getWorldPosition()
                global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, tipsData)

            end

            local function leaveItem()
                global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)
            end

            global.mouseEventController:registerMouseMoveEvent(
                goodItem,
                {
                    enter = mouseMoveCallBack,
                    leave = leaveItem
                }
            )
        end
        panelItem:addChild(goodItem)
        pos = pos + 1
    end
end

return TradeLayer
