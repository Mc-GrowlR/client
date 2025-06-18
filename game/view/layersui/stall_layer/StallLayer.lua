local BaseLayer = requireLayerUI("BaseLayer")
local StallLayer = class("StallLayer", BaseLayer)

function StallLayer:ctor()
    StallLayer.super.ctor(self)
    self.selectTag = nil
end

function StallLayer.create()
    local layer = StallLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function StallLayer:Init()
    self._ui = ui_delegate(self)
    return true
end

function StallLayer:InitGUI(param)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_STALL)
    Stall.main(param)

    self._StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
    self._ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)

    -- buy: true 购买; 否则查看自己
    self.sell = param and param.buy or false

    self._itemWid = Stall._itemWid or (global.isWinPlayMode and global.MMO.STALL_ITEM_WIDTH_WIN or global.MMO.STALL_ITEM_WIDTH)
    self._itemHei = Stall._itemHei or (global.isWinPlayMode and global.MMO.STALL_ITEM_HEIGHT_WIN or global.MMO.STALL_ITEM_HEIGHT)
    self._itemPanelWid = Stall._itemPanelWid or (global.isWinPlayMode and global.MMO.STALL_ITEM_PANEL_WIDTH_WIN or global.MMO.STALL_ITEM_PANEL_WIDTH)
    self._itemPanelHei = Stall._itemPanelHei or (global.isWinPlayMode and global.MMO.STALL_ITEM_PANEL_HEIGHT_WIN or global.MMO.STALL_ITEM_PANEL_HEIGHT)
    self._maxNum        = Stall._maxNum or global.MMO.STALL_MAX_PAGE
    self._rowMax       = Stall._rowMaxItemNum or global.MMO.STALL_ROW_MAX_ITEM_NUMBER

    self:InitEvent()
    self:InitMouseEvent()

    self:UpdateStallLayerInfo()

    self:InitEditMode()
end

function StallLayer:InitMouseEvent()
    local function addItemIntoBag(touchPos)
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        local state = ItemMoveProxy:GetMovingItemState()
        if state and self.sell == false then
            local goToName = ItemMoveProxy.ItemGoTo.AUTO_TRADE
            local data = {}
            data.target = goToName
            data.pos = touchPos
            data.itemPosInbag = self:GetItemBagEmptyPos(touchPos)
            ItemMoveProxy:CheckAndCallBack( data )
        else
            return -1
        end
    end
    global.mouseEventController:registerMouseButtonEvent(
        self._ui.Panel_addItem,
        {
            down_r = function () return -1 end, 
            special_r = addItemIntoBag
        }
    )
end

function StallLayer:InitEvent()
    local function closePanel()
        if not self._StallProxy:GetMyTradingStatus() then
            self._StallProxy:CleanMySellData()
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_StallLayer_Close)
    end
    self._ui.Button_close:addClickEventListener(closePanel)

    local function cancelTrade()
        self._StallProxy:CleanMySellData()
        self._StallProxy:RequestAutoStall("", true)
        global.Facade:sendNotification(global.NoticeTable.Layer_StallLayer_Close)
    end
    self._ui.Button_cancel:addClickEventListener(cancelTrade)

    local function autoTrade()
        if self.sell then
            local selectItem = self._StallProxy:GetSelectItem()
            if selectItem then
                self._StallProxy:RequestBuyItem(selectItem)
            else
                ShowSystemTips(GET_STRING(90170007))
            end
        else
            local data = self._StallProxy:GetMySellData()
            if data and next(data) then
                global.Facade:sendNotification(global.NoticeTable.Layer_Stall_Set_Open)
            end
        end
    end
    self._ui.Button_do:addClickEventListener(autoTrade)
end

function StallLayer:InitEditMode()
    local items = {
        "Image_move",
        "Image_info1",
        "Image_info2",
        "Image_frame1",
        "Image_frame2",
        "Image_title",
        "Text_titleName",
        "Text_itemName",
        "Text_price",
        "Button_close",
        "Button_cancel",
        "Button_do"
    }
    for _, widget in ipairs(items) do
        if self._ui[widget] then
            self._ui[widget].editMode = 1
        end
    end
end

function StallLayer:GetNowStatus()
    return self.sell
end

function StallLayer:GetItemBagEmptyPos(touchPos)
    local x = touchPos.x
    local y = touchPos.y
    local panelWorldPos = self._ui.Panel_addItem:getWorldPosition()
    local posXInPanel   = x - panelWorldPos.x
    local posYInPanel   = panelWorldPos.y - y
    if posXInPanel >= self._itemPanelWid or posXInPanel <= 0 then
        return false
    end
    if posYInPanel >= self._itemPanelHei or posYInPanel <= 0 then
        return false
    end
    local indexX = math.ceil(posXInPanel / self._itemWid)
    local indexY = math.floor(posYInPanel / self._itemHei)

    local posIndex = indexY * self._rowMax + indexX
    if posIndex > self._maxNum then
        return false
    end
    return posIndex
end

function StallLayer:UpdateStallLayerInfo()
    if Stall and Stall.UpdateStallPanelInfo then
        Stall.UpdateStallPanelInfo()
    end
end

return StallLayer