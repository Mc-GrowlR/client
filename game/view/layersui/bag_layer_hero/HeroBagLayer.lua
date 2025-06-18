local BaseLayer = requireLayerUI("BaseLayer")
local HeroBagLayer = class("HeroBagLayer", BaseLayer)

local rowMax = 5
local maxnum = 10
local maxWidth = 186
local maxHeight = 75
local itemWidth = 63
local itemHeight = 63
local maxnumt = {10, 20, 30, 35, 40}

function HeroBagLayer:ctor()
    HeroBagLayer.super.ctor(self)

    self._powerScheduleTime = 0  -- 战力对比延迟时间

    self._proxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
    self.ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
end

function HeroBagLayer.create()
    local layer = HeroBagLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function HeroBagLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function HeroBagLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_BAG_LAYER)
    HeroBag.main()

    local level = data and data.level
    maxnum = level and maxnumt[level] or self._proxy:getBagMaxNum()
    rowMax = HeroBag._Col or rowMax
    itemWidth = HeroBag._IWidth or (global.isWinPlayMode and 43 or 63)
    itemHeight = HeroBag._IHeight or (global.isWinPlayMode and 43 or 63)

    self.initedLayer = nil
    self.panel = self._quickUI.Panel_1
    self.addItemPanel = self._quickUI.Panel_addItems
    self.itemPanel = self._quickUI.Panel_items

    self:initMouseEvent()

    self:updateItems()

    self:InitEditMode()
end

function HeroBagLayer:InitEditMode()
    local items = {
        "Image_bg",
        "Button_close",
        "Panel_items",
        "Panel_addItems",
        "Button_store_human_bag",
    }
    for _, widget in ipairs(items) do
        if self._quickUI[widget] then
            self._quickUI[widget].editMode = 1
        end
    end
end

function HeroBagLayer:initMouseEvent(data)
    self.addItemPanel:setSwallowTouches(false)

    local function addItemIntoBag(touchPos)
        local state = self.ItemMoveProxy:GetMovingItemState()
        if state then
            local goToName = self.ItemMoveProxy.ItemGoTo.HERO_BAG
            local data = {}
            data.target = goToName
            data.pos = touchPos
            data.itemPosInbag = self:GetItemBagEmptyPos(touchPos)
            self.ItemMoveProxy:CheckAndCallBack(data)
        else
            return -1
        end
    end

    local function setNoSwallowMouse()
        return -1
    end

    global.mouseEventController:registerMouseButtonEvent(self.addItemPanel, {
        down_r = setNoSwallowMouse,
        special_r = addItemIntoBag
    })
end

function HeroBagLayer:GetItemBagEmptyPos(touchPos)
    local x = touchPos.x
    local y = touchPos.y
    local panelWorldPos = self.addItemPanel:getWorldPosition()
    local posXInPanel = x - panelWorldPos.x
    local posYInPanel = panelWorldPos.y - y
    if posXInPanel >= maxWidth or posXInPanel <= 0 then
        return nil
    end

    if posYInPanel >= maxHeight or posYInPanel <= 0 then
        return nil
    end
    local indexX = math.ceil(posXInPanel / itemWidth)
    local indexY = math.floor(posYInPanel / itemHeight)

    local posIndex = indexY * rowMax + indexX
    if posIndex > maxnum then
        return nil
    end
    return posIndex
end

function HeroBagLayer:updateItems()
    self:changeLevel()

    self.itemPanel:removeAllChildren()
    self.initedLayer = nil
    local bagData = self._proxy:GetBagData()
    local showData = {}
    local max = rowMax

    local function initNoPosData()
        for _, data in pairs(bagData) do
            if not showData[data.MakeIndex] then
                self:CreateBagItem(data)
            end
        end
    end

    local initTimes = 2
    local initBagItems = nil
    initBagItems = function(beginIndex, endIndex)
        for j = beginIndex, endIndex do
            local itemMakeIndex = self._proxy:GetMakeIndexByBagPos(j)
            if itemMakeIndex and bagData[itemMakeIndex] then
                self:CreateBagItem(bagData[itemMakeIndex])
                showData[itemMakeIndex] = 1
            end
        end
        self.initedLayer = endIndex / max
        if endIndex < maxnum then
            local function createItems()
                local nextBeginIndex = (initTimes - 1) * max + 1
                local nextEndIndex = initTimes * max
                initTimes = initTimes + 1
                initBagItems(nextBeginIndex, nextEndIndex)
            end
            performWithDelay(self.itemPanel, createItems, 1 / 60)
        else
            self.initedLayer = 99
            initNoPosData()
            global.Facade:sendNotification(global.NoticeTable.Layer_HeroBag_Load_Success)
        end
    end
    initBagItems(1, max)
end

function HeroBagLayer:changeLevel()
    local bgPath = HeroBag._LevelBgImgWithMaxBagNum[maxnum]
    if not bgPath then
        bgPath = global.isWinPlayMode and "res/private/bag_ui_hero_win32/bg5.png" or "res/private/bag_ui_hero/bg5.png"
    end

    local Image_bg = self._quickUI.Image_bg
    local oldBgSize = Image_bg:getContentSize()

    Image_bg:loadTexture(bgPath)
    Image_bg:ignoreContentAdaptWithSize(true)

    local newBgSize = Image_bg:getContentSize()
    local deltaH = newBgSize.height - oldBgSize.height
    local addItemSize = self.addItemPanel:getContentSize()

    self.addItemPanel:setContentSize(addItemSize.width, addItemSize.height + deltaH)
    self.itemPanel:setContentSize(addItemSize.width, addItemSize.height + deltaH)

    self.addItemPanel:setPositionY(self.addItemPanel:getPositionY() + deltaH)
    self.itemPanel:setPositionY(self.itemPanel:getPositionY() + deltaH)
    local Button_close = self._quickUI.Button_close
    Button_close:setPositionY(Button_close:getPositionY() + deltaH)

    local newAddItemsize = self.addItemPanel:getContentSize()

    self._quickUI.Panel_2:setContentSize(newBgSize)

    local oldPanelSize = self.panel:getContentSize()
    self.panel:setContentSize(oldPanelSize.width, oldPanelSize.height + deltaH)

    local layout = ccui.LayoutComponent:bindLayoutComponent(self.panel)
    layout:refreshLayout()

    maxWidth = newAddItemsize.width
    maxHeight = newAddItemsize.height

    local visibleSize = global.Director:getVisibleSize()
    if maxnum > 30 then
        self.panel:setPositionY(visibleSize.height - 10)
    elseif maxnum >= 40 then
        self.panel:setPositionY(visibleSize.height - 5)
    end
end

function HeroBagLayer:CreateBagItem(data)
    local pos = self._proxy:GetBagPosByMakeIndex(data.MakeIndex) or self._proxy:NewItemPos()
    if pos and pos <= maxnum then
        local info = {}
        info.itemData = data
        info.index = data.Index
        info.look = true
        info.movable = true
        info.from = self.ItemMoveProxy.ItemFrom.HERO_BAG
        info.checkPower = true
        info.starLv = true
        local goodItem = GoodsItem:create(info)
        local YPos = math.floor((pos - 1) / rowMax)
        local XPos = (pos - 1) % rowMax
        local posX = XPos * itemWidth + itemWidth / 2
        local posY = maxHeight - itemHeight / 2 - itemHeight * YPos
        goodItem:setPosition(math.floor(posX), math.floor(posY))
        goodItem:setTag(data.MakeIndex)

        goodItem:addReplaceClickEventListener(function()
            if HeroBag._changeMode then--人物和英雄背包互取
                self.ItemMoveProxy:HeroBagToHumBag({ itemData = data })
                return
            end

            if global.userInputController:IsPressedShift() then
                local itemOverLapCount = data.OverLap and data.OverLap > 1
                if itemOverLapCount then
                    if self._proxy:isToBeFull(true) then
                        return false
                    end
                    -- 叠加道具批量使用
                    local function callback(btnType, editparam)
                        if editparam.editStr and editparam.editStr ~= "" then
                            if type(editparam.editStr) == "string" then
                                local num = tonumber(editparam.editStr)
                                if not num or num > data.OverLap or num <= 0 then
                                    global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(90020012))
                                    return
                                end
                                self._proxy:RequestCountItem(data.MakeIndex, num)
                            end
                        end
                    end
                    local commonData = {}
                    commonData.str = GET_STRING(90020011)
                    commonData.callback = callback
                    commonData.btnType = 1
                    commonData.showEdit = true
                    commonData.editParams = {
                        inputMode = 2,
                        str = "",
                        add = true,
                        max = data.OverLap,
                    }
                    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, commonData)
                end
                return false
            end

            local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
            local stroageType = NPCStorageProxy:GetTouchType()
            local state = stroageType > 1
            if state then
                NPCStorageProxy:RequestSaveToStorage(data.MakeIndex, data.Name)
            end
            return not state
        end)

        local function useThisItem()
            global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)
            local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
            local stroageType = NPCStorageProxy:GetTouchType()
            local state = stroageType > 0
            if state then
                NPCStorageProxy:RequestSaveToStorage(data.MakeIndex, data.Name)
            else
                local newData = clone(data)
                newData.from = self.ItemMoveProxy.ItemFrom.HERO_BAG
                local ItemUseProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemUseProxy)
                ItemUseProxy:HeroUseItem(newData)
            end
        end

        if global.isWinPlayMode then
            --right mouse btn quick use
            global.mouseEventController:registerMouseButtonEvent(goodItem, {
                down_r = useThisItem,
                double_l = useThisItem
            })
        else
            -- double touch or double left mouse btn click 
            goodItem:addDoubleEventListener(useThisItem)
        end

        self.itemPanel:addChild(goodItem)

        -- 移动中处理
        local itemMoving = self.ItemMoveProxy:GetMovingItemState()
        local itemMovingData = self.ItemMoveProxy:GetMovingItemData()
        if itemMoving and itemMovingData then
            if data.MakeIndex == itemMovingData.MakeIndex then
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_UpDate, {
                    goodItem = goodItem
                })
                goodItem:resetMoveState(true)
            end
        end

        local itemState = self:CheckItemOnSomeState(data.MakeIndex)
        if not itemState then
            goodItem:setVisible(itemState)
        end
    end
end

function HeroBagLayer:CheckItemOnSomeState(MakeIndex)
    local onSellOrRepaireMakeIndex = self._proxy:GetOnSellOrRepaire()
    if onSellOrRepaireMakeIndex == MakeIndex then
        return false
    end

    local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
    local onTradingData = TradeProxy:GetSelfItemData()
    if onTradingData[MakeIndex] then
        return false
    end

    return true
end

function HeroBagLayer:ItemDataChange(data)
    if not data or not next(data) then
        return
    end

    local type = data.opera
    local itemData = data.operID
    if not itemData or not next(itemData) then
        return
    end

    if type == global.MMO.Operator_Add or type == global.MMO.Operator_Init then
        if not self.initedLayer then
            return
        end

        for _, v in pairs(itemData) do
            local pos = self._proxy:GetBagPosByMakeIndex(v.item.MakeIndex)
            if pos and pos < self.initedLayer * rowMax then
                self:CreateBagItem(v.item)
            end
        end

    elseif type == global.MMO.Operator_Sub then
        for _, v in pairs(itemData) do
            local item = self.itemPanel:getChildByTag(v.MakeIndex)
            if item then
                item:stopAllActions()
                item:removeFromParent()
                item = nil
            end
        end

    elseif type == global.MMO.Operator_Change then
        for _, v in pairs(itemData) do
            local item = self.itemPanel:getChildByTag(v.MakeIndex)
            local thisItemData = self._proxy:GetItemDataByMakeIndex(v.MakeIndex)
            if item and thisItemData then
                item:UpdateGoodsItem(thisItemData)
                item:setVisible(false)
                performWithDelay(item, function()
                    if item and not tolua.isnull(item) then
                        item:setVisible(true)
                    end
                end, 0.15)
            end
        end
    end
end

function HeroBagLayer:UpdateBagState(data)
    if not data then
        return
    end

    if data.trading then
        self:UpdateMovingData(data.trading)

    elseif data.storage then
        self:UpdateMovingData(data.storage)

    elseif data.dropping then
        self:UpdateMovingData(data.dropping)
    end
end

function HeroBagLayer:UpdateMovingData(data)
    if not data or not next(data) then
        return
    end

    local MakeIndex = data.MakeIndex
    local onMovingNode = self.itemPanel:getChildByTag(MakeIndex)
    if onMovingNode then
        onMovingNode:setVisible(data.state and data.state > 0)
        onMovingNode._movingState = not (data.state and data.state > 0)
    end
end

function HeroBagLayer:ItemPosChange(data)
    if not data or next(data) == nil then
        return
    end

    for k, MakeIndex in pairs(data) do
        local item = self.itemPanel:getChildByTag(MakeIndex)
        if item then
            item:stopAllActions()
            item:removeFromParent()
            item = nil
        end
        local itemData = self._proxy:GetItemDataByMakeIndex(MakeIndex)
        if itemData then
            self:CreateBagItem(itemData)
        end
    end
end

function HeroBagLayer:updateItemsList()
    self.itemPanel:removeAllChildren()

    local bagData = self._proxy:GetBagData()
    if not bagData or not next(bagData) then
        return
    end

    for _, data in pairs(bagData) do
        self:CreateBagItem(data)
    end
end

function HeroBagLayer:UpdateItemPowerCheckState(data)
    local itemPowerFunc = function()
        local childs = self.itemPanel:getChildren()
        for _, goodItem in ipairs(childs) do
            if goodItem and goodItem.setItemPowerTag then
                goodItem:setItemPowerTag()
            end
        end
    end

    if data and data.bagDelayUpdate then
        if not self._powerScheduleTime or self._powerScheduleTime == 0 then
            self._powerScheduleTime = 3
            performWithDelay(self, function()
                itemPowerFunc()
                self._powerScheduleTime = 0
            end, self._powerScheduleTime)
        end
    else
        itemPowerFunc()
    end

end

function HeroBagLayer:BeginMove(MakeIndex, pos)
    if not MakeIndex then
        return
    end

    local isOnSelling = false
    local onSellOrRepaireMakeIndex = self._proxy:GetOnSellOrRepaire()
    if onSellOrRepaireMakeIndex == MakeIndex then
        isOnSelling = true
    end

    local gooditem = self.itemPanel:getChildByTag(MakeIndex)
    if gooditem and not tolua.isnull(gooditem) and not isOnSelling then
        gooditem:showIteminfo(nil, pos)
    end
end

return HeroBagLayer