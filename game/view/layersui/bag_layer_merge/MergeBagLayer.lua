local BaseLayer = requireLayerUI("BaseLayer")
local MergeBagLayer = class("MergeBagLayer", BaseLayer)

function MergeBagLayer:ctor()
    MergeBagLayer.super.ctor(self)

    self._selectType        = 0         -- 选中的类型
    self._is_load_finish    = false     -- 背包是否加载完成
    self._is_retrieve_finsh = true      -- 是否回收加载完成
    self._powerScheduleTime = 0         -- 战力对比延迟时间
    self._chooseTagList     = {}        -- 设定勾选的物品
end

function MergeBagLayer.create()
    local layer = MergeBagLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function MergeBagLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function MergeBagLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MERGE_BAG_LAYER)
    local meta = {}
    meta.UpdateItems = handler(self, self.updateItems)
    meta.__index = meta
    setmetatable(MergeBag, meta)
    MergeBag.main(data and data.showtype or 1, data and data.bag_page or 1)

    self.BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    self.HeroBagProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
    self.ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)

    self:InitEditMode()
end

function MergeBagLayer:InitEditMode()
    local items = {
        "Image_bg",
        "Button_close",
        "ScrollView_items",
        "Panel_addItems",
        "Image_gold",
        "Panel_1",
        "Button_store_mode"
    }
    for _, widget in ipairs(items) do
        if self._quickUI[widget] then
            self._quickUI[widget].editMode = 1
        end
    end

    for i = 1, MergeBag._MaxPage do
        if self._quickUI["Button_page"..i] then
            self._quickUI["Button_page"..i].editMode = 1
            local btnText = self._quickUI["Button_page"..i]:getChildByName("PageText")
            if btnText then
                btnText.editMode = 1
            end
        end
    end

    -- 英雄、主角切换
    local keys = {"BtnPlayer", "BtnHero"}
    for _, v in ipairs(keys) do
        if self._quickUI[v] then
            self._quickUI[v].editMode = 1
            local btnText = self._quickUI[v]:getChildByName("BtnText")
            if btnText then
                btnText.editMode = 1
            end
        end
    end
end

function MergeBagLayer:GetSelectPage()
    return MergeBag._selPage
end

function MergeBagLayer:InitAfterCUILoad()
    if MergeBag.ResetInitData then
        MergeBag.ResetInitData()
    end

    self._BagRow     = MergeBag._Row or 5
    self._BagCol     = MergeBag._Col or self._BagCol
    self._PanelW     = MergeBag._PWidth or global.MMO.BAG_ITEM_PANEL_WIDTH
    self._PanelH     = MergeBag._PHeight or global.MMO.BAG_ITEM_PANEL_HEIGHT
    self._ItemH      = MergeBag._IHeight or self._PanelH / self._BagRow
    self._ItemW      = MergeBag._IWidth or self._PanelW / self._BagCol
    self._ScrollH    = MergeBag._ScrollHeight or self._PanelH
    self._PerPageNum = MergeBag._PerPageNum or self._PerPageNum

    self.panel = self._quickUI.Panel_1
    self.addItemPanel = self._quickUI.Panel_addItems
    self.Panel_items = self._quickUI.ScrollView_items
    self.addItemPanel:setSwallowTouches(false)

    self:initMouseEvent()

    self:updateItems()

    performWithDelay(self, function()
        if self:IsHeroBag() then
            return
        end

        self._is_load_finish = true
        if not self._is_retrieve_finsh then
            self:UpdateEquipRetrieveState()
        end
    end, 0.5)

end

function MergeBagLayer:IsHumBag()
    return MergeBag._selType == 1
end

function MergeBagLayer:IsHeroBag()
    return MergeBag._selType == 2
end

function MergeBagLayer:getShowType()
    return MergeBag._selType
end

function MergeBagLayer:setShowType(type)
    MergeBag.onSelType(type)
end

function MergeBagLayer:initMouseEvent()
    local function addItemIntoBag(touchPos)
        local state = self.ItemMoveProxy:GetMovingItemState()
        local pos = self:GetItemBagEmptyPos(touchPos)
        if state and pos then
            local data = {}
            data.target = self:IsHumBag() and self.ItemMoveProxy.ItemGoTo.BAG or self.ItemMoveProxy.ItemGoTo.HERO_BAG
            data.pos = touchPos
            data.itemPosInbag = pos + (MergeBag._selPage - 1) * self._PerPageNum
            local bagProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)

            if self:IsHeroBag() and data.itemPosInbag > self.HeroBagProxy:getBagMaxNum() then  -- 上锁
                return -1
            end

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

    self.imageGold = self._quickUI.Image_gold

    local function addGoldIntoTrade(touchPos)
        if self:IsHeroBag() then
            return
        end

        local state = self.ItemMoveProxy:GetMovingItemState()
        if state then
            local data = {}
            data.target = self.ItemMoveProxy.ItemGoTo.BAG_GOLD
            data.pos = touchPos
            data.isGold = true
            self.ItemMoveProxy:CheckAndCallBack(data)
        else
            return -1
        end
    end

    global.mouseEventController:registerMouseButtonEvent(self.imageGold, {
        down_r = setNoSwallowMouse,
        special_r = addGoldIntoTrade
    })

    local param = {}
    param.nodeFrom = self.ItemMoveProxy.ItemFrom.BAG_GOLD
    param.moveNode = self.imageGold
    param.cancelMoveCall = function()
        if self.imageGold and not tolua.isnull(self.imageGold) then
            self.imageGold._movingState = false
        end
    end
    RegisterNodeMovable(self.imageGold, param)
end

function MergeBagLayer:GetItemBagEmptyPos(touchPos)
    local x = touchPos.x
    local y = touchPos.y
    local panelWorldPos = self.addItemPanel:getWorldPosition()
    local posXInPanel = x - panelWorldPos.x
    local posYInPanel = panelWorldPos.y - y
    if posXInPanel >= self._PanelW or posXInPanel <= 0 then
        return nil
    end

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

function MergeBagLayer:updateItems()
    -- 在道具移动中
    local itemMoving = self.ItemMoveProxy:GetMovingItemState()
    local itemMovingData = self.ItemMoveProxy:GetMovingItemData()
    if itemMoving and itemMovingData then
        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel, { MakeIndex = itemMovingData.MakeIndex })
    end

    local children = self.Panel_items:getChildren()
    for _, item in pairs(children) do
        local name = item:getName()
        if not string.find(tostring(name), "Grid_") then
            item:removeFromParent()
        end
    end
    GUI:stopAllActions(self.Panel_items)

    local startPos = self:IsHumBag() and self._PerPageNum * (MergeBag._selPage - 1) + 1 or 1
    local endPos = self:IsHumBag() and startPos + (self._PerPageNum - 1) or self._PerPageNum
    local bagProxy = self:IsHumBag() and self.BagProxy or self.HeroBagProxy
    local maxOpen = self:IsHumBag() and bagProxy:GetMaxBag() or bagProxy:getBagMaxNum()
    local bagData = self:IsHumBag() and self.BagProxy:GetBagDataByBagPos(startPos, endPos) or self.HeroBagProxy:GetBagData()
    for index = startPos, endPos do
        local pos = self:IsHumBag() and index - self._PerPageNum * (MergeBag._selPage - 1) or index
        if index > maxOpen then
            local gridY = math.floor((pos - 1) / self._BagCol)
            local gridX = (pos - 1) % self._BagCol
            local posX = gridX * self._ItemW + self._ItemW / 2
            local posY = self._PanelH - self._ItemH / 2 - self._ItemH * gridY
            self:SetClockImag(self.Panel_items, posX, posY)
        else
            local itemMakeIndex = bagProxy:GetMakeIndexByBagPos(index)
            if itemMakeIndex and bagData[itemMakeIndex] then
                self:CreateBagItem(bagData[itemMakeIndex])
            end
        end
    end

    self:OnRefreshBagRedDot()
    self:OnRefreshChooseList()
    self:InitStallTag(startPos, endPos)
    if self:IsHumBag() then
        global.Facade:sendNotification(global.NoticeTable.GuideEventBegan, { name = "GUIDE_BAG_ITEM_LOAD_SUCCESS" })
    end
end

function MergeBagLayer:updateItemsList()
    local children = self.Panel_items:getChildren()
    for _, item in pairs(children) do
        local name = item:getName()
        if not string.find(tostring(name), "Grid_") then
            item:removeFromParent()
        end
    end
    GUI:stopAllActions(self.Panel_items)

    local startPos = self:IsHumBag() and self._PerPageNum * (MergeBag._selPage - 1) + 1 or 1
    local endPos = self:IsHumBag() and startPos + (self._PerPageNum - 1) or self._PerPageNum
    local bagProxy = self:IsHumBag() and self.BagProxy or self.HeroBagProxy
    local bagData = self:IsHumBag() and bagProxy:GetBagDataByBagPos(startPos, endPos) or bagProxy:GetBagData()
    if not bagData or not next(bagData) then
        return
    end

    local maxOpen = self:IsHumBag() and bagProxy:GetMaxBag() or bagProxy:getBagMaxNum()
    for j = startPos, endPos do
        if j > maxOpen then
            local pos = j - self._PerPageNum * (MergeBag._selPage - 1)
            local gridY = math.floor((pos - 1) / self._BagCol)
            local gridX = (pos - 1) % self._BagCol
            local posX = gridX * self._ItemW + self._ItemW / 2
            local posY = self._PanelH - self._ItemH / 2 - self._ItemH * gridY
            self:SetClockImag(self.Panel_items, posX, posY)
        end
    end

    for _, data in pairs(bagData) do
        local buifenlei = data.buifenlei and tonumber(data.buifenlei) or nil
        if self._selectType == bagProxy.BAG_SELECT_TYPE.TYPE_ALL or self._selectType == buifenlei then
            self:CreateBagItem(data)
        end
    end

    self:OnRefreshBagRedDot()
    self:OnRefreshChooseList()
    self:InitStallTag(startPos, endPos)
end

function MergeBagLayer:SetClockImag(panelItems, posX, posY)
    local clockImage = ccui.ImageView:create()
    clockImage:loadTexture(MergeBag._lockImg)
    clockImage:setPosition(posX, posY)
    clockImage:setScale(1)
    panelItems:addChild(clockImage)
    clockImage:setTouchEnabled(true)
    DelayTouchEnabled(clockImage, 0.5)
    clockImage:addClickEventListener(function()
        LuaSendMsg(global.MsgType.MSG_CS_UNLOCK_BAG_SIZE)
    end)
end

function MergeBagLayer:InitStallTag(startPos, endPos)
    local StallProxy = global.Facade:retrieveProxy(global.ProxyTable.StallProxy)
    local sellData = StallProxy:GetMySellData()
    for _, v in pairs(sellData) do
        local item = self.Panel_items:getChildByTag(v.MakeIndex)
        local inPage = v.bagPos and v.bagPos >= startPos and v.bagPos <= endPos
        local pos = v.bagPos
        if pos % self._PerPageNum == 0 then
            pos = self._PerPageNum
        else
            local posPage = math.floor(pos / self._PerPageNum)
            pos = pos - posPage * self._PerPageNum
        end
        if inPage and not item then
            local gridY = math.floor((pos - 1) / self._BagCol)
            local gridX = (pos - 1) % self._BagCol
            local posX = gridX * self._ItemW + self._ItemW / 2
            local posY = self._PanelH - self._ItemH / 2 - self._ItemH * gridY
            local pos = cc.p(posX, posY)
            local baitanTag = ccui.ImageView:create()
            baitanTag:loadTexture(MergeBag._baiTanImg)
            baitanTag:setPosition(pos)
            baitanTag:addTo(self.Panel_items)
            baitanTag:setName("BAITAN_" .. (v.MakeIndex or ""))
        end
    end
end

function MergeBagLayer:CreateBagItem(data)
    local bagProxy = self:IsHumBag() and self.BagProxy or self.HeroBagProxy
    local pos = bagProxy:GetBagPosByMakeIndex(data.MakeIndex)
    if not pos then
        pos = bagProxy:NewItemPos()
    end

    local maxOpen = self:IsHumBag() and bagProxy:GetMaxBag() or bagProxy:getBagMaxNum()
    if pos and pos <= maxOpen then
        local info = {}
        info.itemData = data
        info.index = data.Index
        info.look = true
        info.movable = true
        info.noMouseTips = true
        info.from = self:IsHumBag() and self.ItemMoveProxy.ItemFrom.BAG or self.ItemMoveProxy.ItemFrom.HERO_BAG
        info.checkPower = true
        info.starLv = true
        local goodItem = GoodsItem:create(info)

        if pos % self._PerPageNum == 0 then
            pos = self._PerPageNum
        else
            local posPage = math.floor(pos / self._PerPageNum)
            pos = pos - posPage * self._PerPageNum
        end

        local gridY = math.floor((pos - 1) / self._BagCol)
        local gridX = (pos - 1) % self._BagCol
        local posX = gridX * self._ItemW + self._ItemW / 2
        local posY = self._PanelH - self._ItemH / 2 - self._ItemH * gridY
        goodItem:setPosition(posX, posY)
        goodItem:setTag(data.MakeIndex)

        -- 单击
        goodItem:addReplaceClickEventListener(function()
            if MergeBag._changeStoreMode then  -- 人物和英雄背包互取
                if self:IsHeroBag() then
                    self.ItemMoveProxy:HeroBagToHumBag({ itemData = data })
                else
                    self.ItemMoveProxy:HumBagToHeroBag({ itemData = data })
                end
                return
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
            local useState = bagProxy:GetOnBagItemUseState(data)
            if useState == 0 then  -- 正常双击
                global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)
                local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
                local stroageType = NPCStorageProxy:GetTouchType()
                local state = stroageType > 0
                if state then
                    NPCStorageProxy:RequestSaveToStorage(data.MakeIndex, data.Name)
                else
                    local ItemUseProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemUseProxy)
                    if self:IsHeroBag() then
                        local newData = clone(data)
                        newData._from = self.ItemMoveProxy.ItemFrom.HERO_BAG
                        ItemUseProxy:HeroUseItem(newData)
                    else  -- 人物
                        data.from = self.ItemMoveProxy.ItemFrom.BAG
                        ItemUseProxy:UseItem(data)
                    end
                end

            elseif useState == 1 then  -- 使用准星道具
                bagProxy:RequestCollimator(data.MakeIndex)
                if bagProxy:GetBagCollimator() then
                    bagProxy:ClearBagCollimator()
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_Sight_Bead_Hide)

            elseif useState == 2 then  -- 取消准星
                if bagProxy:GetBagCollimator() then
                    bagProxy:ClearBagCollimator()
                    bagProxy:RequestCanceCollimator()
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_Sight_Bead_Hide)
            end
        end

        -- 双击
        goodItem:addDoubleEventListener(useThisItem)

        -- 长按
        goodItem:addPressCallBack(function()
            local itemOverLapCount = data.OverLap and data.OverLap > 1
            if itemOverLapCount then
                if bagProxy:isToBeFull(true) then
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
                            bagProxy:RequestCountItem(data.MakeIndex, num)
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
        end)

        self.Panel_items:addChild(goodItem)

        -- 移动中处理
        local itemMoving = self.ItemMoveProxy:GetMovingItemState()
        local itemMovingData = self.ItemMoveProxy:GetMovingItemData()
        if itemMoving and itemMovingData then
            if data.MakeIndex == itemMovingData.MakeIndex then
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_UpDate, { goodItem = goodItem })
                goodItem:resetMoveState(true)
            end
        end

        local itemState = self:CheckItemOnSomeState(data.MakeIndex)
        if not itemState then
            goodItem:setVisible(itemState)
        end
    end
end

function MergeBagLayer:CheckItemOnSomeState(MakeIndex)
    local bagProxy = self:IsHumBag() and self.BagProxy or self.HeroBagProxy
    local onSellOrRepaireMakeIndex = bagProxy:GetOnSellOrRepaire()
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

function MergeBagLayer:ItemDataChange(data, isBaitan)
    if not data or not next(data) then
        return
    end

    local itemData = data.operID
    if not itemData or not next(itemData) then
        return
    end

    local type = data.opera
    local bagProxy = self:IsHumBag() and self.BagProxy or self.HeroBagProxy
    if type == global.MMO.Operator_Add or type == global.MMO.Operator_Init then
        for _, v in pairs(itemData) do
            local pos = bagProxy:GetBagPosByMakeIndex(v.item.MakeIndex)
            local startPos = self._PerPageNum * (MergeBag._selPage - 1) + 1
            local endPos = startPos + (self._PerPageNum - 1)
            if pos and pos >= startPos and pos <= endPos then
                local buifenlei = v.item.buifenlei and tonumber(v.item.buifenlei) or nil
                if self._selectType == bagProxy.BAG_SELECT_TYPE.TYPE_ALL or self._selectType == buifenlei then
                    self:CreateBagItem(v.item)
                    self:OnRemoveBaiTanTag(v.item)
                end
            end
        end

    elseif type == global.MMO.Operator_Sub then
        for _, v in pairs(itemData) do
            local item = self.Panel_items:getChildByTag(v.MakeIndex)

            if isBaitan then
                local pos = cc.p(item:getPosition())
                local baitanTag = ccui.ImageView:create()
                baitanTag:loadTexture(MergeBag._baiTanImg)
                baitanTag:setPosition(pos)
                baitanTag:addTo(self.Panel_items)
                baitanTag:setName("BAITAN_" .. (v.MakeIndex or ""))
            end

            if item then
                item:stopAllActions()
                item:removeFromParent()
                item = nil
            end
        end

    elseif type == global.MMO.Operator_Change then
        for _, v in pairs(itemData) do
            local item = self.Panel_items:getChildByTag(v.MakeIndex)
            local thisItemData = bagProxy:GetItemDataByMakeIndex(v.MakeIndex)
            if item and thisItemData then
                local buifenlei = thisItemData.buifenlei and tonumber(thisItemData.buifenlei) or nil
                if self._selectType == bagProxy.BAG_SELECT_TYPE.TYPE_ALL or self._selectType == buifenlei then
                    item:UpdateGoodsItem(thisItemData)
                end
            end
        end
    end
end

function MergeBagLayer:OnRemoveBaiTanTag(data)
    if data and next(data) and data.MakeIndex then
        local baitanTag = self.Panel_items:getChildByName("BAITAN_" .. data.MakeIndex)
        if baitanTag then
            baitanTag:removeFromParent()
            baitanTag = nil
        end
    end
end

function MergeBagLayer:ItemPosChange(data)
    if not data or next(data) == nil then
        return
    end

    local bagProxy = self:IsHumBag() and self.BagProxy or self.HeroBagProxy
    for _, MakeIndex in pairs(data) do
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

        local itemData = bagProxy:GetItemDataByMakeIndex(MakeIndex)
        if itemData then
            self:CreateBagItem(itemData)
            -- 红点
            if reddot then
                local item = self.Panel_items:getChildByTag(MakeIndex)
                if item then
                    if reddot.sfxID then  -- 是特效 
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

function MergeBagLayer:BeginMove(MakeIndex, pos)
    if not MakeIndex then
        return
    end

    local bagProxy = self:IsHumBag() and self.BagProxy or self.HeroBagProxy
    local isOnSelling = bagProxy:GetOnSellOrRepaire() == MakeIndex

    local gooditem = self.Panel_items:getChildByTag(MakeIndex)
    if gooditem and not tolua.isnull(gooditem) and not isOnSelling then
        gooditem:showIteminfo(nil, pos)
    end
end

function MergeBagLayer:UpdateBagState(data)
    if not data then
        return
    end

    if data.goldState then
        self.imageGold._movingState = data.goldState < 1

    elseif data.trading then
        self:UpdateMovingData(data.trading)

    elseif data.storage then
        self:UpdateMovingData(data.storage)

    elseif data.dropping then
        self:UpdateMovingData(data.dropping)
    end
end

function MergeBagLayer:UpdateMovingData(data)
    if not data or not next(data) then
        return
    end

    local onMovingNode = self.Panel_items:getChildByTag(data.MakeIndex)
    if onMovingNode then
        onMovingNode:setVisible(data.state and data.state > 0)
        onMovingNode._movingState = not (data.state and data.state > 0)
    end
end

function MergeBagLayer:UpdateItemPowerCheckState(data)
    local function CheckPow()
        for i, goodItem in ipairs(self.Panel_items:getChildren()) do
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

--更新背包回收勾选
function MergeBagLayer:UpdateEquipRetrieveState(retrive_data)
    self._is_retrieve_finsh = false

    if not self._is_load_finish then
        return
    end

    local bagProxy = self:IsHumBag() and self.BagProxy or self.HeroBagProxy
    local startPos = self:IsHumBag() and self._PerPageNum * (MergeBag._selPage - 1) + 1 or 1
    local bagData = self:IsHumBag() and bagProxy:GetBagDataByBagPos(startPos, startPos + self._PerPageNum - 1) or bagProxy:GetBagData()
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

function MergeBagLayer:OnRefreshChooseList()
    for makeIndex, _ in pairs(self._chooseTagList or {}) do
        local goodsItem = self.Panel_items:getChildByTag(makeIndex)
        if goodsItem then
            goodsItem:SetChooseState(true)
        end
    end
end

-- 显示准星
function MergeBagLayer:OnBagItemCollimator(MakeIndex)
    if MakeIndex then
        local gooditem = self.Panel_items:getChildByTag(MakeIndex)
        if gooditem then
            global.Facade:sendNotification(global.NoticeTable.Layer_Sight_Bead_Show, { pos = gooditem:getWorldPosition() })
        end
    end
end

function MergeBagLayer:OnRefreshBagRedDot()
    local RedDotProxy = global.Facade:retrieveProxy(global.ProxyTable.RedDotProxy)
    for id, data in pairs(RedDotProxy:GetBagRedDot() or {}) do
        global.Facade:sendNotification(global.NoticeTable.Layer_RedDot_refData, data)
    end
end

-- 背包切页事件
function MergeBagLayer:ChangeBagPageEvent(page)
    local selectPage = SL:GetMetaValue("BAG_PAGE_CUR")
    if page and page ~= selectPage then
        if MergeBag and MergeBag._bagPageBtns and MergeBag._bagPageBtns[page] then
            local widget = GUI:getChildByName(MergeBag._bagPageBtns[page], "TouchSize")
            if widget then
                SL:WinClick(widget)
            end
        end
    end
end

function MergeBagLayer:OnClose()
    if self:IsHumBag() then
        if self.BagProxy:GetBagCollimator() then
            self.BagProxy:ClearBagCollimator()
            self.BagProxy:RequestCanceCollimator()
        end
        global.Facade:sendNotification(global.NoticeTable.GuideEventEnded, { name = "GUIDE_BAG_LAYER_CLOSED", bag_page = MergeBag._selPage or 1 })
        global.Facade:sendNotification(global.NoticeTable.Layer_Sight_Bead_Hide)
    end
end

return MergeBagLayer