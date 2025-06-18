local BaseLayer = requireLayerUI("BaseLayer")
local NpcStorageLayer = class("NpcStorageLayer", BaseLayer)

-- 存取模式
local STORE_MODE = {
    normal = 1, -- 普通的双击存取
    quick  = 2, -- 快速存取
}

function NpcStorageLayer:ctor()
    self._openedCount = 0   -- 已开启格子数
    self._resetList = false -- 是否整理仓库
end

function NpcStorageLayer.create()
    local layer = NpcStorageLayer.new()
    if layer and layer:Init() then
        return layer
    end

    return nil
end

function NpcStorageLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function NpcStorageLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_NPC_STORAGE)
    local meta = {}
    meta.UpdateItems = handler(self, self.UpdateItemList)
    meta.__index = meta
    setmetatable(Storage, meta)
    Storage.main(data and data.initPage)

    self._proxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
    self._proxy:SetStoragePageIndex(Storage._selPage)
    self._proxy:SetTouchType(STORE_MODE.normal)

    self._root = self._quickUI.Panel_1
    self._panelItems = self._root:getChildByName("Panel_items")

    self:InitEditMode()
end

function NpcStorageLayer:ResetStorageData()
    if Storage.ResetStorageData then 
        Storage.ResetStorageData()
    end 

    self._openedCount = self._proxy:GetOpenSize()
    self._PerPageNum = Storage._PerPageNum or global.MMO.NPC_STORAGE_MAX_PAGE
    self._PerRowItemNum = Storage._PerRowItemNum 
    self._PerColItemNum = Storage._PerColItemNum 

    self:InitUI()
    self:InitMouseEvent()
    self:UpdateItemList()
end 

function NpcStorageLayer:InitEditMode( ... )
    local items = {
        "Image_bg",
        "Button_quick",
        "Button_reset",
        "Button_close",
        "Panel_items",
        "Panel_itemstouch",
    }
    for _, widgetName in ipairs(items) do
        if self._quickUI[widgetName] then
            self._quickUI[widgetName].editMode = 1
        end
    end

    for i = 1, Storage._MaxPage do
        if self._quickUI["Button_page"..i] then
            self._quickUI["Button_page"..i].editMode = 1
            local btnText = self._quickUI["Button_page"..i]:getChildByName("PageText")
            if btnText then
                btnText.editMode = 1
            end
        end
    end
end

function NpcStorageLayer:InitMouseEvent()
    local function addItemIntoStorage(touchPos)
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        local state = ItemMoveProxy:GetMovingItemState()
        if state then
            local goToName = ItemMoveProxy.ItemGoTo.STORAGE
            local data = {}
            data.target = goToName
            data.pos = touchPos
            ItemMoveProxy:CheckAndCallBack(data)
        else
            return -1
        end
    end

    local function setNoSwallowMouse()
        return -1
    end

    local addItemPanel = self._root:getChildByName("Panel_itemstouch")
    addItemPanel:setSwallowTouches(false)
    global.mouseEventController:registerMouseButtonEvent(addItemPanel, {
        down_r = setNoSwallowMouse,
        special_r = addItemIntoStorage
    })
end

function NpcStorageLayer:InitUI()
    -- 关闭
    local btnClose = self._root:getChildByName("Button_close")
    local function closePanel()
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Storage_Close)
    end
    btnClose:addClickEventListener(closePanel)

    -- 快速存取
    local btnQuickPut = self._root:getChildByName("Button_quick")
    local function quickPut(sender)
        local touchType = self._proxy:GetTouchType()
        if touchType == STORE_MODE.normal then
            touchType = STORE_MODE.quick
        else
            touchType = STORE_MODE.normal
        end
        self._proxy:SetTouchType(touchType)
        local text = touchType == STORE_MODE.normal and GET_STRING(90100002) or GET_STRING(90100003)
        sender:setTitleText(text)
    end
    btnQuickPut:addClickEventListener(quickPut)

    -- 整理仓库
    local btnRefresh = self._root:getChildByName("Button_reset")
    local function refreshStorage()
        DelayTouchEnabled(btnRefresh, 0.5)
        self._proxy:ArrangeStorageData(Storage._selPage)
        self._resetList = true
        self:UpdateItemList()
    end
    btnRefresh:addClickEventListener(refreshStorage)
end

function NpcStorageLayer:UpdateItemList(page)
    self._panelItems:removeAllChildren()

    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local maxHeight = Storage._PHeight
    local maxWidth =  Storage._PWidth
    local itemHeight = maxHeight / self._PerColItemNum
    local itemWidth = maxWidth / self._PerRowItemNum  
    local notOpenedIndex = Storage._selPage * self._PerPageNum - self._openedCount

    if notOpenedIndex > 0 then
        local clockPos = self._PerPageNum - notOpenedIndex + 1
        local noOpen = math.floor(notOpenedIndex / self._PerPageNum)
        clockPos = noOpen > 0 and 1 or clockPos
        for i = clockPos, self._PerPageNum do
            local gridY = math.floor((clockPos - 1) / self._PerRowItemNum)
            local gridX = (clockPos - 1) % self._PerRowItemNum
            local posX = gridX * itemWidth + itemWidth / 2
            local posY = maxHeight - itemHeight / 2 - itemHeight * gridY

            local clockImage = ccui.ImageView:create()
            clockImage:loadTexture(Storage.lockImg or global.MMO.PATH_RES_PUBLIC .. "icon_tyzys_01.png")
            clockImage:setPosition(posX, posY)
            clockImage:setScale(global.isWinPlayMode and 0.7 or 1)
            self._panelItems:addChild(clockImage)
            clockImage:setName("clock_" .. i)

            clockPos = clockPos + 1
        end
    end

    local isWinMode = SL:GetMetaValue("WINPLAYMODE")
    local storage_row_col = SL:GetMetaValue("GAME_DATA", "bag_storage_row_col_max")
    local bBig = false  -- 是否大仓库
    if isWinMode and storage_row_col then
        local slices = string.split(storage_row_col, "|")
        local row = tonumber(slices[1]) or 8
        local col = tonumber(slices[2]) or 6
        if row * col > global.MMO.NPC_STORAGE_MAX_PAGE then 
            bBig = true
        end 
    end 

    local itemData = {}
    if bBig then 
        itemData = self._proxy:GetStorageData()
    else 
        itemData = self._proxy:GetStorageDataByPage(Storage._selPage)
    end 
    
    if not itemData or next(itemData) == nil then
        return
    end

    -- TODO:这里只是本地整理，重新打开又是未整理状态，之前的做法是进仓库强制排序
    -- if self._resetList then
    --     table.sort(itemData, function(a, b)
    --         local powera = GetItemPowerValue(a)
    --         local powerb = GetItemPowerValue(b)
    --         if powera ~= powerb then
    --             return powera > powerb
    --         else
    --             local isBindA, bindIndexA = ItemConfigProxy:CheckItemBind(a.Index)
    --             local isBindB, bindIndexB = ItemConfigProxy:CheckItemBind(b.Index)
    --             if isBindA == isBindB then
    --                 return a.Index < b.Index
    --             else
    --                 return isBindA
    --             end
    --         end
    --     end)
    -- end

    self._resetList = false

    local pos = 1
    for _, data in pairs(itemData) do
        if pos > Storage._selPage * self._PerPageNum then
            break
        end

        local info = {}
        info.itemData = data
        info.index = data.Index
        info.look = true
        info.movable = true
        info.starLv = true
        info.from = ItemMoveProxy.ItemFrom.STORAGE
        local goodItem = GoodsItem:create(info)

        local gridY = math.floor((pos - 1) / self._PerRowItemNum)
        local gridX = (pos - 1) % self._PerRowItemNum
        local posX = gridX * itemWidth + itemWidth / 2
        local posY = maxHeight - itemHeight / 2 - itemHeight * gridY
        goodItem:setPosition(posX, posY)
        goodItem:setTag(data.MakeIndex)

        -- 取出物品
        local function putOutStorageItem()
            global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)
            self._proxy:RequestPutOutStorageData(data.MakeIndex, data.Name)
        end

        -- 单击
        goodItem:addReplaceClickEventListener(function()
            local touchType = self._proxy:GetTouchType()
            local isQuick = touchType == STORE_MODE.quick
            if isQuick then
                putOutStorageItem()
            end
            return not isQuick
        end)

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

            global.mouseEventController:registerMouseMoveEvent(goodItem, {
                enter = mouseMoveCallBack,
                leave = leaveItem
            })

            -- 双击和右键取出
            global.mouseEventController:registerMouseButtonEvent(goodItem, {
                down_r = putOutStorageItem,
                double_l = putOutStorageItem
            })
        else
            -- 双击取出
            goodItem:addDoubleEventListener(putOutStorageItem)
        end

        self._panelItems:addChild(goodItem)

        pos = pos + 1
    end
end

function NpcStorageLayer:UpdateStorageItemState(data)
    if data and next(data) then
        if data.resetItem then
            self:UpdatePutOutData(data.resetItem)
        end
    end
end

function NpcStorageLayer:UpdatePutOutData(data)
    if data and next(data) then
        local onPutOutNode = self._panelItems:getChildByTag(data.MakeIndex)
        if onPutOutNode then
            onPutOutNode:setVisible(data.state and data.state > 0)
            onPutOutNode._movingState = not (data.state and data.state > 0)
        end
    end
end

function NpcStorageLayer:UpdateStorageOpenNum()
    local lastIndex = math.min(self._openedCount - (Storage._selPage - 1) * self._PerPageNum, self._PerPageNum)
    self._openedCount = self._proxy:GetOpenSize()
    local openIndex = math.min(self._openedCount - (Storage._selPage - 1) * self._PerPageNum, self._PerPageNum)
    if openIndex > 0 then
        if openIndex <= lastIndex then
            return
        end
        for i = lastIndex + 1, openIndex do
            if self._panelItems:getChildByName("clock_" .. i) then
                self._panelItems:removeChildByName("clock_" .. i)
            end
        end
    end
end

return NpcStorageLayer