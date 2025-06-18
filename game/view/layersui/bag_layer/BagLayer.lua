local BaseLayer = requireLayerUI("BaseLayer")
local BagLayer = class("BagLayer", BaseLayer)
-- 背包优化
function BagLayer:ctor()
    BagLayer.super.ctor(self)

    self._selectType        = 0         -- 选中的类型
    self._is_load_finish    = false     -- 背包是否加载完成
    self._is_retrieve_finsh = true      -- 是否回收加载完成
    self._powerScheduleTime = 0         -- 战力对比延迟时间
    self._chooseTagList     = {}        -- 回收设定勾选的物品
end

function BagLayer.create()
    local layer = BagLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function BagLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function BagLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_BAG_LAYER)
    local meta = {}
    meta.UpdateItems = handler(self, self.updateItems)
    meta.__index = meta
    setmetatable(Bag, meta)
    Bag.main(data and data.bag_page or 1)

    self._proxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    self._ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
	
	self:InitEditMode()
end

local function resetItemPos(item)
    local worldPos  = item:convertToWorldSpace(cc.p(0,0))
    local newPos    = cc.p(math.floor(worldPos.x), math.floor(worldPos.y))
    local pos       = cc.p(item:getPosition())
    item:setPosition(cc.pAdd(pos,cc.pSub(newPos, worldPos)))
end

function BagLayer:InitAfterCUILoad()
    if Bag.ResetInitData then
        Bag.ResetInitData()
    end

    self._BagRow     = Bag._Row or 5
    self._BagCol     = Bag._Col or global.MMO.BAG_ROW_MAX_ITEM_NUMBER
    self._PanelW     = Bag._PWidth or global.MMO.BAG_ITEM_PANEL_WIDTH
    self._PanelH     = Bag._PHeight or global.MMO.BAG_ITEM_PANEL_HEIGHT
    self._ItemH      = Bag._IHeight or self._PanelH / self._BagRow
    self._ItemW      = Bag._IWidth or self._PanelW / self._BagCol
    self._ScrollH    = Bag._ScrollHeight or self._PanelH
    self._PerPageNum = Bag._PerPageNum or global.MMO.MAX_ITEM_NUMBER
    self._MaxBagPage = Bag._MaxPage

    self._root = self._quickUI.Panel_1 --交易行截图用
    self.Panel_addItems = self._quickUI.Panel_addItems
    self.Panel_items = self._quickUI.ScrollView_items   -- 图标层

    local panelSize = self.Panel_items:getContentSize()
    local panelPos = cc.p(self.Panel_items:getPosition())
    local panelAnchorPoint = cc.p(self.Panel_items:getAnchorPoint())
    
    -- 特效层
    self.Panel_effect = ccui.Layout:create()
    self.Panel_effect:setContentSize(panelSize)
    self.Panel_effect:setPosition(panelPos)
    self.Panel_effect:setAnchorPoint(panelAnchorPoint)
    self._root:addChild(self.Panel_effect)

    -- 文本层
    self.Panel_text = ccui.Layout:create()
    self.Panel_text:setContentSize(panelSize)
    self.Panel_text:setPosition(panelPos)
    self.Panel_text:setAnchorPoint(panelAnchorPoint)
    self._root:addChild(self.Panel_text)

    self:updateItems()
    self:initMouseEvent()

    performWithDelay(self, function()
        self._is_load_finish = true
        if not self._is_retrieve_finsh then
            self:UpdateEquipRetrieveState()
        end
    end, 0.5)
end

function BagLayer:InitEditMode()
    local items = {
        "Image_bg",
        "Button_close",
        "ScrollView_items",
        "Panel_addItems",
        "Image_gold",
        "Text_goldNum",
        "Panel_1",
        "Button_store_hero_bag"
    }
    for _, widget in ipairs(items) do
        if self._quickUI[widget] then
            self._quickUI[widget].editMode = 1
        end
    end

    for i = 1, Bag._MaxPage do
        if self._quickUI["Button_page"..i] then
            self._quickUI["Button_page"..i].editMode = 1
            local btnText = self._quickUI["Button_page"..i]:getChildByName("PageText")
            if btnText then
                btnText.editMode = 1
            end
        end
    end
end

function BagLayer:initMouseEvent()
    self.Panel_addItems:setSwallowTouches(false)

    local function setNoswallowMouse()
        return -1
    end

    local function addItemIntoBag(touchPos)
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        local state = ItemMoveProxy:GetMovingItemState()
        local pos = self:GetItemBagEmptyPos(touchPos)
        if state and pos then
            local goToName = ItemMoveProxy.ItemGoTo.BAG
            local data = {}
            data.target = goToName
            data.pos = touchPos
            data.itemPosInbag = pos + (self._proxy:GetCurPage() - 1) * self._PerPageNum
            if data.itemPosInbag > SL:GetMetaValue("MAX_BAG") then
                return -1
            end

            ItemMoveProxy:CheckAndCallBack(data)
        else
            return -1
        end
    end

    global.mouseEventController:registerMouseButtonEvent(self.Panel_addItems, {
        down_r = setNoswallowMouse,
        special_r = addItemIntoBag
    })

    local function addGoldIntoTrade(touchPos)
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        local state = ItemMoveProxy:GetMovingItemState()
        if state then
            local goToName = ItemMoveProxy.ItemGoTo.BAG_GOLD
            local data = {}
            data.target = goToName
            data.pos = touchPos
            data.isGold = true
            ItemMoveProxy:CheckAndCallBack(data)
        else
            return -1
        end
    end

    global.mouseEventController:registerMouseButtonEvent(self._quickUI.Image_gold, {
        down_r = setNoswallowMouse,
        special_r = addGoldIntoTrade
    })

    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    local param = {}
    param.nodeFrom = ItemMoveProxy.ItemFrom.BAG_GOLD
    param.moveNode = self._quickUI.Image_gold
    param.cancelMoveCall = function()
        if self._quickUI.Image_gold and not tolua.isnull(self._quickUI.Image_gold) then
            self._quickUI.Image_gold._movingState = false
        end
    end
    RegisterNodeMovable(self._quickUI.Image_gold, param)
end

function BagLayer:GetItemBagEmptyPos(touchPos)
    local x = touchPos.x
    local y = touchPos.y
    local panelWorldPos = self.Panel_addItems:getWorldPosition()

    local posXInPanel = x - panelWorldPos.x
    if posXInPanel >= self._PanelW or posXInPanel <= 0 then
        return nil
    end

    local posYInPanel = panelWorldPos.y - y
    if posYInPanel >= self._PanelH or posYInPanel <= 0 then
        return nil
    end

    local indexX = math.ceil(posXInPanel / self._ItemW)
    local indexY = math.floor(posYInPanel / self._ItemH)
    local posIndex = indexY * self._BagCol + indexX
    if posIndex > self._PerPageNum then
        return nil
    end

    return posIndex
end

function BagLayer:updateItems()
    local children = self.Panel_items:getChildren()
    for _, item in pairs(children) do
        local name = item:getName()
        if not string.find(tostring(name), "Grid_") then
            item:removeFromParent()
        end
    end

    local text_children = self.Panel_text:getChildren()
    for _, item in pairs(text_children) do
        local name = item:getName()
        if not string.find(tostring(name), "Grid_") then
            item:removeFromParent()
        end
    end

    local effect_children = self.Panel_effect:getChildren()
    for _, item in pairs(effect_children) do
        local name = item:getName()
        if not string.find(tostring(name), "Grid_") then
            item:removeFromParent()
        end
    end

    local curPage = self._proxy:GetCurPage()
    local sIndex = self._PerPageNum * (curPage - 1) + 1
    local eIndex = sIndex + (self._PerPageNum - 1)
    local bagData = self._proxy:GetBagDataByBagPos(sIndex, eIndex)
    local maxOpen = self._proxy:GetMaxBag()

    local showData = {}
    for i = sIndex, eIndex do
        local makeIndex = self._proxy:GetMakeIndexByBagPos(i)
        local data = bagData[makeIndex]
        if data then
            table.insert(showData, data)
        end
    end

    local idx = 0
    local function showBagItemsUI()
        local loadNum = self._BagCol
        local posStart = idx * loadNum + 1
        local posEnd = idx * loadNum + loadNum
        
        if posStart > self._PerPageNum then
            self.Panel_items:stopAllActions()

            -- 加载完处理
            self:OnRefreshBagRedDot()
            self:OnRefreshChooseList()
            self:InitStallTag(sIndex, eIndex)
            global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Load_Success)
            return
        end
        
        for i = posStart, posEnd do
            local gridY = math.floor((i - 1) / self._BagCol)
            local gridX = (i - 1) % self._BagCol
            local posX = gridX * self._ItemW + self._ItemW / 2
            local posY = self._PanelH - self._ItemH / 2 - self._ItemH * gridY
            local bShowLock = i + (curPage - 1) * self._PerPageNum > maxOpen
            if bShowLock then 
                self:SetClockImag(self.Panel_items, posX, posY)    
            else 
                if showData[i] then
                    self:CreateBagItem(showData[i])
                    self:CreateItemText(showData[i])
                    self:CreateItemUpEffect(showData[i])
                end
            end 
        end

        idx = idx + 1
        performWithDelay(self.Panel_items, showBagItemsUI, 0.01)
    end

    self.Panel_items:stopAllActions()
    showBagItemsUI()

end

function BagLayer:updateItemsList()
    local children = self.Panel_items:getChildren()
    for _, item in pairs(children) do
        local name = item:getName()
        if not string.find(tostring(name), "Grid_") then
            item:removeFromParent()
        end
    end

    local text_children = self.Panel_text:getChildren()
    for _, item in pairs(text_children) do
        local name = item:getName()
        if not string.find(tostring(name), "Grid_") then
            item:removeFromParent()
        end
    end

    local effect_children = self.Panel_effect:getChildren()
    for _, item in pairs(effect_children) do
        local name = item:getName()
        if not string.find(tostring(name), "Grid_") then
            item:removeFromParent()
        end
    end

    local curPage = self._proxy:GetCurPage()
    local sIndex = self._PerPageNum * (curPage - 1) + 1
    local eIndex = sIndex + (self._PerPageNum - 1)
    local maxOpen = self._proxy:GetMaxBag()
    local bagData = self._proxy:GetBagDataByBagPos(sIndex, eIndex)

    local showData = {}
    for i = sIndex, eIndex do
        local makeIndex = self._proxy:GetMakeIndexByBagPos(i)
        local data = bagData[makeIndex]
        if data then
            table.insert(showData, data)
        end
    end

    for i = 1, self._PerPageNum do
        local gridY = math.floor((i - 1) / self._BagCol)
        local gridX = (i - 1) % self._BagCol
        local posX = gridX * self._ItemW + self._ItemW / 2
        local posY = self._PanelH - self._ItemH / 2 - self._ItemH * gridY
        local bShowLock = i + (curPage - 1) * self._PerPageNum > maxOpen
        if bShowLock then 
            self:SetClockImag(self.Panel_items, posX, posY)    
        else 
            if showData[i] then
                self:CreateBagItem(showData[i])
                self:CreateItemUpEffect(showData[i])
                self:CreateItemText(showData[i])
            end
        end
    end

    self:OnRefreshBagRedDot()
    self:OnRefreshChooseList()
    self:InitStallTag(sIndex, eIndex)
end

function BagLayer:SetClockImag(panelItems, posX, posY)
    local clockImage = ccui.ImageView:create()
    clockImage:loadTexture(Bag._lockImg)
    clockImage:setPosition(posX, posY)
    clockImage:setScale(global.isWinPlayMode and 0.5 or 1)
    panelItems:addChild(clockImage)
    clockImage:setTouchEnabled(true)
    DelayTouchEnabled(clockImage, 0.5)
    clockImage:addClickEventListener(function()
        LuaSendMsg(global.MsgType.MSG_CS_UNLOCK_BAG_SIZE)
    end)
end

function BagLayer:InitStallTag(startPos, endPos)
    local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
    local sellData = StallProxy:GetMySellData()
    for _, v in pairs(sellData) do
        local pos = v.bagPos
        if pos % self._PerPageNum == 0 then
            pos = self._PerPageNum
        else
            local posPage = math.floor(pos / self._PerPageNum)
            pos = pos - posPage * self._PerPageNum
        end

        local inPage = v.bagPos and v.bagPos >= startPos and v.bagPos <= endPos
        local item = self.Panel_items:getChildByTag(v.MakeIndex)
        if inPage and not item then
            local gridY = math.floor((pos - 1) / self._BagCol)
            local gridX = (pos - 1) % self._BagCol
            local posX = gridX * self._ItemW + self._ItemW / 2
            local posY = self._PanelH - self._ItemH / 2 - self._ItemH * gridY
            local pos = cc.p(posX, posY)
            local baitanTag = ccui.ImageView:create()
            baitanTag:loadTexture(Bag._baiTanImg)
            baitanTag:setPosition(pos)
            baitanTag:addTo(self.Panel_items)
            baitanTag:setName("BAITAN_" .. (v.MakeIndex or ""))
        end
    end
end

function BagLayer:getItemPosByIndex(index)
    local pos = {}
    if not index then 
        return 
    end 

    if index % self._PerPageNum == 0 then
        index = self._PerPageNum
    else
        local posPage = math.floor(index / self._PerPageNum)
        index = index - posPage * self._PerPageNum
    end

    local gridY = math.floor((index - 1) / self._BagCol)
    local gridX = (index - 1) % self._BagCol
    pos.x = gridX * self._ItemW + self._ItemW / 2
    pos.y = self._PanelH - self._ItemH / 2 - self._ItemH * gridY 

    local newPos = {}
    newPos.x = math.floor(pos.x)
    newPos.y = math.floor(pos.y)

    return newPos
end 

function BagLayer:CreateItemText(data)
    local index = self._proxy:GetBagPosByMakeIndex(data.MakeIndex) or self._proxy:NewItemPos()
    local Zorder = 2
    local info = {}
    info.itemData = data
    info.index = data.Index
    info.from = self._ItemMoveProxy.ItemFrom.BAG
    info.starLv = true

    local pos = self:getItemPosByIndex(index)
    if not pos then 
        return 
    end 

    local itemText = BagItemLayer.create(info, Zorder)
    self.Panel_text:addChild(itemText)
    itemText:setPosition(pos.x, pos.y)
    itemText:setTag(data.MakeIndex)
    resetItemPos(itemText)

    -- 移动中处理 买卖 
    local itemMoving = self._ItemMoveProxy:GetMovingItemState()
    local itemMovingData = self._ItemMoveProxy:GetMovingItemData()
    if itemMoving and itemMovingData then
        if data.MakeIndex == itemMovingData.MakeIndex then
            itemText:setVisible(false)      
        end
    end
end 

function BagLayer:CreateItemUpEffect(data)
    local index = self._proxy:GetBagPosByMakeIndex(data.MakeIndex) or self._proxy:NewItemPos()
    local Zorder = 3
    local info = {}
    info.itemData = data
    info.index = data.Index
    info.from = self._ItemMoveProxy.ItemFrom.BAG
    info.checkPower = true
    info.starLv = true
    
    local pos = self:getItemPosByIndex(index)
    if not pos then 
        return 
    end 

    local itemEffect = BagItemLayer.create(info, Zorder)
    self.Panel_effect:addChild(itemEffect)
    itemEffect:setPosition(pos.x, pos.y)
    itemEffect:setTag(data.MakeIndex)
    resetItemPos(itemEffect)
    
    -- 移动中处理 买卖 
    local itemMoving = self._ItemMoveProxy:GetMovingItemState()
    local itemMovingData = self._ItemMoveProxy:GetMovingItemData()
    if itemMoving and itemMovingData then
        if data.MakeIndex == itemMovingData.MakeIndex then
            itemEffect:setVisible(false)
        end
    end
end 

function BagLayer:CreateBagItem(data)
    local index = self._proxy:GetBagPosByMakeIndex(data.MakeIndex) or self._proxy:NewItemPos()
    local Zorder = 1
    local info = {}
    info.itemData = data
    info.index = data.Index
    info.look = true
    info.movable = true
    info.noMouseTips = not global.isWinPlayMode
    info.from = self._ItemMoveProxy.ItemFrom.BAG

    local pos = self:getItemPosByIndex(index)
    if not pos then 
        return 
    end 

    local goodItem = BagItemLayer.create(info, Zorder)
    goodItem:setPosition(pos.x, pos.y)
    goodItem:setTag(data.MakeIndex)
    self.Panel_items:addChild(goodItem)
    resetItemPos(goodItem)

    -- 单击
    goodItem:addReplaceClickEventListener(function()
        -- 判断是否双击使用
        if Bag.IsCanSingle and not Bag.IsCanSingle(data) then
            return false
        end
        
        if not global.isWinPlayMode and ssrGlobal_BagItemChooseEx then
            local isContinue = ssrGlobal_BagItemChooseEx(data.MakeIndex)
            if not isContinue then
                return false
            end
        end

        -- 人物和英雄背包互取
        if Bag._changeStoreMode then
            self._ItemMoveProxy:HumBagToHeroBag({ itemData = data })
            return false
        end

        if global.isWinPlayMode and global.userInputController:IsPressedShift() then
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
                    max = data.OverLap
                }
                global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, commonData)
            end
            return false
        end

        -- 单击快速存取
        local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
        local stroageType = NPCStorageProxy:GetTouchType()
        local state = stroageType > 1
        if state then
            NPCStorageProxy:RequestSaveToStorage(data.MakeIndex, data.Name)
        end

        return not state
    end)

    local function useThisItem()
        -- 判断是否双击使用
        if Bag.IsCanDouble and not Bag.IsCanDouble(data) then
            return false
        end
             
        local useState = self._proxy:GetOnBagItemUseState(data)
        if useState == 0 then -- 正常双击
            global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)
            local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
            local stroageType = NPCStorageProxy:GetTouchType()
            local state = stroageType > 0
            if state then
                NPCStorageProxy:RequestSaveToStorage(data.MakeIndex, data.Name)
            else
                local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
                local nowItemData = ItemManagerProxy:GetItemDataByMakeIndex(data.MakeIndex)
                SL:RequestUseItem(nowItemData)
            end

        elseif useState == 1 then -- 使用准星道具
            self._proxy:RequestCollimator(data.MakeIndex)
            if self._proxy:GetBagCollimator() then
                self._proxy:ClearBagCollimator()
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_Sight_Bead_Hide)

        elseif useState == 2 then -- 取消准星
            if self._proxy:GetBagCollimator() then
                self._proxy:ClearBagCollimator()
                self._proxy:RequestCanceCollimator()
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_Sight_Bead_Hide)
        end
    end
    
    if global.isWinPlayMode then
        local function RUseThisItem()
            if self._proxy:GetBagCollimator() then -- 准星   取消
                if self._proxy:GetBagCollimator() then
                    self._proxy:ClearBagCollimator()
                    self._proxy:RequestCanceCollimator()
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_Sight_Bead_Hide)
                return
            end
            useThisItem()
        end

        local function LClickThisItem()
            local useState = self._proxy:GetOnBagItemUseState(data)
            if useState ~= 0 then -- 准星物品
                if useState == 1 then -- 使用准星道具
                    self._proxy:RequestCollimator(data.MakeIndex)
                    if self._proxy:GetBagCollimator() then
                        self._proxy:ClearBagCollimator()
                    end
                    global.Facade:sendNotification(global.NoticeTable.Layer_Sight_Bead_Hide)
                end
            end

            return -1
        end

        -- right mouse btn quick use
        global.mouseEventController:registerMouseButtonEvent(goodItem, {
            down_r = RUseThisItem,
            double_l = useThisItem,
            special_r = LClickThisItem,
        })

    else
        -- 双击
        goodItem:addDoubleEventListener(useThisItem)

        -- 长按
        goodItem:addPressCallBack(function()
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
                    max = data.OverLap
                }
                global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, commonData)
            else
                goodItem:SetMoveEable(true)
            end
        end)
    end

    -- 移动开始事件
    goodItem:addMoveBeginCallBack(function()
        local itemText = self.Panel_text:getChildByTag(data.MakeIndex)
        local itemEffect = self.Panel_effect:getChildByTag(data.MakeIndex)

        if itemText then
            itemText:setVisible(false)
        end

        if itemEffect then
            itemEffect:setVisible(false)
        end
    end)

    -- 移动结束事件
    goodItem:addMoveEndCallBack(function()

    end)

    -- 移动取消事件 回到原点
    goodItem:addMoveCancelCallBack(function()    
        global.Facade:sendNotification(global.NoticeTable.Item_Move_cancel_On_BagPosChang, data)   
    end)

    -- 移动中处理 买卖 
    local itemMoving = self._ItemMoveProxy:GetMovingItemState()
    local itemMovingData = self._ItemMoveProxy:GetMovingItemData()
    if itemMoving and itemMovingData then
        if data.MakeIndex == itemMovingData.MakeIndex then
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_UpDate, {
                goodItem = goodItem
            })
            goodItem:resetMoveState(true)
        end
    end

    local onSomeState = self:CheckItemOnSomeState(data.MakeIndex)
    if onSomeState then
        goodItem:setVisible(false)
    end   
end

function BagLayer:CheckItemOnSomeState(MakeIndex)
    local onSellOrRepaireMakeIndex = self._proxy:GetOnSellOrRepaire()
    if self._proxy:GetOnSellOrRepaire() == MakeIndex then
        return true
    end

    local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
    local onTradingData = TradeProxy:GetSelfItemData()
    if onTradingData[MakeIndex] then
        return true
    end

    return false
end

function BagLayer:ItemDataChange(data, isBaitan)
    if not data or not next(data) then
        return
    end

    local itemData = data.operID
    if not itemData or not next(itemData) then
        return
    end

    local type = data.opera
    if type == global.MMO.Operator_Add or type == global.MMO.Operator_Init then
        for _, v in pairs(itemData) do
            local pos = self._proxy:GetBagPosByMakeIndex(v.item.MakeIndex)
            local startPos = self._PerPageNum * (self._proxy:GetCurPage() - 1) + 1
            local endPos = startPos + self._PerPageNum - 1
            if pos and pos >= startPos and pos <= endPos then
                local buifenlei = v.item.buifenlei and tonumber(v.item.buifenlei) or nil
                if self._selectType == self._proxy.BAG_SELECT_TYPE.TYPE_ALL or self._selectType == buifenlei then
                    self:CreateBagItem(v.item)
                    self:CreateItemText(v.item)
                    self:CreateItemUpEffect(v.item)
                    self:OnRemoveBaiTanTag(v.item)
                end
            end
        end

    elseif type == global.MMO.Operator_Sub then
        for _, v in pairs(itemData) do
            local item = self.Panel_items:getChildByTag(v.MakeIndex)
            local itemText = self.Panel_text:getChildByTag(v.MakeIndex)
            local itemEffect = self.Panel_effect:getChildByTag(v.MakeIndex)

            if isBaitan then
                local pos = cc.p(item:getPosition())
                local baitanTag = ccui.ImageView:create()
                baitanTag:loadTexture(Bag._baiTanImg)
                baitanTag:setPosition(pos)
                baitanTag:addTo(self.Panel_items)
                baitanTag:setName("BAITAN_" .. (v.MakeIndex or ""))
            end           

            if item then
                item:stopAllActions()
                item:removeFromParent()
                item = nil
            end

            if itemText then
                itemText:stopAllActions()
                itemText:removeFromParent()
                itemText = nil
            end

            if itemEffect then
                itemEffect:stopAllActions()
                itemEffect:removeFromParent()
                itemEffect = nil
            end
        end

    elseif type == global.MMO.Operator_Change then
        for _, v in pairs(itemData) do
            local thisItemData = self._proxy:GetItemDataByMakeIndex(v.MakeIndex)
            local buifenlei = thisItemData.buifenlei and tonumber(thisItemData.buifenlei) or nil

            local item = self.Panel_items:getChildByTag(v.MakeIndex)
            if item and thisItemData then
                if self._selectType == self._proxy.BAG_SELECT_TYPE.TYPE_ALL or self._selectType == buifenlei then
                    item:UpdateItemData(thisItemData)
                end
            end

            local itemText = self.Panel_text:getChildByTag(v.MakeIndex)
            if itemText and thisItemData then 
                if self._selectType == self._proxy.BAG_SELECT_TYPE.TYPE_ALL or self._selectType == buifenlei then
                    itemText:UpdateItemText(thisItemData)
                end 
            end 

            local itemEffect = self.Panel_effect:getChildByTag(v.MakeIndex)
            if itemEffect and thisItemData then 
                if self._selectType == self._proxy.BAG_SELECT_TYPE.TYPE_ALL or self._selectType == buifenlei then
                    itemEffect:UpdateItemEffect(thisItemData)
                end 
            end 
        end
    end
end

function BagLayer:OnRemoveBaiTanTag(data)
    if data and next(data) and data.MakeIndex then
        local baitanTag = self.Panel_items:getChildByName("BAITAN_" .. data.MakeIndex)
        if baitanTag then
            baitanTag:removeFromParent()
            baitanTag = nil
        end
    end
end

-- 背包位置改变
function BagLayer:ItemPosChange(data)
    if not data or next(data) == nil then
        return
    end

    for _, MakeIndex in pairs(data) do
        -- 清空原位置内容
        local item = self.Panel_items:getChildByTag(MakeIndex)
        local reddot
        if item then
            reddot = item:getChildByName("_RedDot_")
            if reddot then
                reddot:retain()
                reddot:removeFromParent()
            end
            item:stopAllActions()
            item:removeFromParent()
            item = nil
        end

        local itemText = self.Panel_text:getChildByTag(MakeIndex)
        if itemText then 
            itemText:stopAllActions()
            itemText:removeFromParent()
            itemText = nil
        end 

        local itemEffect = self.Panel_effect:getChildByTag(MakeIndex)
        if itemEffect then 
            itemEffect:stopAllActions()
            itemEffect:removeFromParent()
            itemEffect = nil
        end 

        -- 创建现位置内容
        local itemData = self._proxy:GetItemDataByMakeIndex(MakeIndex)
        if itemData then
            self:CreateBagItem(itemData)
            self:CreateItemText(itemData)
            self:CreateItemUpEffect(itemData)
            -- 红点
            if reddot then
                local item = self.Panel_items:getChildByTag(MakeIndex)
                if item then
                    if reddot.sfxID then -- 是特效
                        local pos = cc.p(reddot:getPosition())
                        local sfxID = reddot.sfxID
                        reddot:release()
                        reddot = global.FrameAnimManager:CreateSFXAnim(sfxID)

                        if reddot then
                            reddot:Play(0, 0, true)
                            reddot:setName("_RedDot_")
                            item:addChild(reddot)
                            reddot:setPosition(pos)
                            reddot.sfxID = sfxID
                        end
                    else
                        item:addChild(reddot)
                        reddot:release()
                    end
                end
            end
        end
    end
end

function BagLayer:BeginMove(MakeIndex, pos)
    if not MakeIndex then
        return
    end

    local isOnSelling = self._proxy:GetOnSellOrRepaire() == MakeIndex
    local gooditem = self.Panel_items:getChildByTag(MakeIndex)
    if gooditem and not tolua.isnull(gooditem) and not isOnSelling then
        gooditem:showIteminfo(nil, pos)
    end
end

function BagLayer:CancelMoveBagItem(data)
    if not data or next(data) == nil then 
        return 
    end 

    local itemText = self.Panel_text:getChildByTag(data.MakeIndex)
    local itemEffect = self.Panel_effect:getChildByTag(data.MakeIndex)

    if itemText then
        itemText:setVisible(true)
    end

    if itemEffect then
        itemEffect:setVisible(true)
    end
end

function BagLayer:UpdateBagState(data)
    if not data then
        return
    end

    if data.goldState then
        self._quickUI.Image_gold._movingState = data.goldState < 1

    elseif data.trading then
        self:UpdateMovingData(data.trading)

    elseif data.storage then
        self:UpdateMovingData(data.storage)

    elseif data.dropping then -- 丢弃失败
        self:UpdateMovingData(data.dropping)
    end
end

function BagLayer:UpdateMovingData(data)
    if not data or not next(data) then
        return
    end

    local movingNode = self.Panel_items:getChildByTag(data.MakeIndex)
    if movingNode then
        movingNode:setVisible(data.state and data.state > 0)
        movingNode._movingState = not (data.state and data.state > 0)
    end

    local movingText = self.Panel_text:getChildByTag(data.MakeIndex)
    if movingText then
        movingText:setVisible(data.state and data.state > 0)
        movingText._movingState = not (data.state and data.state > 0)
    end

    local movingEffect = self.Panel_effect:getChildByTag(data.MakeIndex)
    if movingEffect then
        movingEffect:setVisible(data.state and data.state > 0)
        movingEffect._movingState = not (data.state and data.state > 0)
    end
end

function BagLayer:UpdateItemPowerCheckState(data)
    local function CheckPow()

        for _, goodItem in ipairs(self.Panel_effect:getChildren()) do
            if goodItem and goodItem.setItemPowerTag then
                goodItem:setItemPowerTag()
            end
        end
    end

    if data and data.bagDelayUpdate then
        if not self._powerScheduleTime or self._powerScheduleTime == 0 then
            self._powerScheduleTime = 3
            performWithDelay(self, function()
                CheckPow()
                self._powerScheduleTime = 0
            end, self._powerScheduleTime)
        end
    else
        CheckPow()
    end
end

-- 更新背包回收勾选
function BagLayer:UpdateEquipRetrieveState(retrive_data)
    self._is_retrieve_finsh = false

    if not self._is_load_finish then
        return
    end

    local curPage = self._proxy:GetCurPage()
    local startPos = self._PerPageNum * (curPage - 1) + 1
    local endPos = startPos + (self._PerPageNum - 1)
    local bagData = self._proxy:GetBagDataByBagPos(startPos, endPos)
    local EquipRetrieveProxy = global.Facade:retrieveProxy(global.ProxyTable.EquipRetrieveProxy)
    local retrieveList = EquipRetrieveProxy:GetRetrieveList()

    for _, data in pairs(bagData) do
        local showTag = false
        if retrieveList[data.MakeIndex] then
            showTag = true
            self._chooseTagList[data.MakeIndex] = true
        else
            self._chooseTagList[data.MakeIndex] = nil
        end
        local goodsItem = self.Panel_items:getChildByTag(data.MakeIndex)
        if goodsItem then
            goodsItem:SetChooseState(showTag)
        end
    end

    self._is_retrieve_finsh = true
end

function BagLayer:OnRefreshChooseList()
    for makeIndex, _ in pairs(self._chooseTagList or {}) do
        local goodsItem = self.Panel_items:getChildByTag(makeIndex)
        if goodsItem then
            goodsItem:SetChooseState(true)
        end
    end
end

-- 主动勾选背包物品 传唯一ID 当前页
function BagLayer:UpdateBagItemChooseState(dataList)
    dataList = dataList or {}

    local curPage = self._proxy:GetCurPage()
    local startPos = self._PerPageNum * (curPage - 1) + 1
    local endPos = startPos + (self._PerPageNum - 1)

    local retrieveList = {}
    for _, makeIndex in ipairs(dataList) do
        retrieveList[makeIndex] = makeIndex
    end

    local bagData = self._proxy:GetBagDataByBagPos(startPos, endPos)
    for _, data in pairs(bagData) do
        local showTag = false
        if retrieveList and retrieveList[data.MakeIndex] then
            showTag = true
            self._chooseTagList[data.MakeIndex] = true
        else
            self._chooseTagList[data.MakeIndex] = nil
        end

        local goodsItem = self.Panel_items:getChildByTag(data.MakeIndex)
        if goodsItem then
            goodsItem:SetChooseState(showTag)
        end
    end
end

-- 显示准星
function BagLayer:OnBatItemCollimator(MakeIndex)
    if MakeIndex then
        local gooditem = self.Panel_items:getChildByTag(MakeIndex)
        if gooditem then
            global.Facade:sendNotification(global.NoticeTable.Layer_Sight_Bead_Show, {pos = gooditem:getWorldPosition()})
        end
    end
end

function BagLayer:OnRefreshBagRedDot()
    local RedDotProxy = global.Facade:retrieveProxy(global.ProxyTable.RedDotProxy)
    for id, data in pairs(RedDotProxy:GetBagRedDot() or {}) do
        global.Facade:sendNotification(global.NoticeTable.Layer_RedDot_refData, data)
    end
end

-- 背包切页事件
function BagLayer:ChangeBagPageEvent(page)
    local selectPage = SL:GetMetaValue("BAG_PAGE_CUR")
    if page and page ~= selectPage then
        if Bag and Bag._bagPageBtns and Bag._bagPageBtns[page] then
            local widget = GUI:getChildByName(Bag._bagPageBtns[page], "TouchSize")
            if widget then
                SL:WinClick(widget)
            end
        end
    end
end

function BagLayer:OnClose()
    if self._proxy:GetBagCollimator() then
        self._proxy:ClearBagCollimator()
        self._proxy:RequestCanceCollimator()
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_Sight_Bead_Hide)

    global.Facade:sendNotification(global.NoticeTable.GuideEventEnded, {
        name = "GUIDE_BAG_LAYER_CLOSED",
        bag_page = self._proxy:GetCurPage() or 1
    })
end

return BagLayer