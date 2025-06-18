local RemoteProxy = requireProxy("remote/RemoteProxy")
local StallProxy = class("StallProxy", RemoteProxy)
StallProxy.NAME = global.ProxyTable.StallProxy


function StallProxy:ctor()
    StallProxy.super.ctor(self)
    self.isTrading      = false
    self.MySellData     = {}
    self.onSellData     = {}
    self.showStoreName  = nil
    self.seletedItem    = nil
    self.nowOpenStoreId = nil
    self._currencies    = {}        -- 可摆摊货币
end

function StallProxy:onRegister()
    StallProxy.super.onRegister(self)
end

function StallProxy:CheckListViewFull()
    return #self.MySellData >= global.MMO.STALL_MAX_PAGE
end

function StallProxy:AddItemIntoList(data)
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local item = BagProxy:GetItemDataByMakeIndex(data.MakeIndex)

    if item then
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        local bagPos = BagProxy:GetBagPosByMakeIndex(item.MakeIndex)
        BagProxy:DelItemData(item, true, nil, nil, true)

        item.goldtype = data.goldtype
        item.price = data.price
        item.bagPos = bagPos
        table.insert(self.MySellData, item)

        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
        ItemManagerProxy:SetItemBelong(item.MakeIndex, global.MMO.ITEM_FROM_BELONG_STALL)

        global.Facade:sendNotification(global.NoticeTable.Layer_StallLayer_SelfItemChange)
    end
end

function StallProxy:GetMySellData()
    return self.MySellData
end

function StallProxy:GetMySellDataByMakeIndex(MakeIndex)
    local data = self:GetMySellData()
    if not data or next(data) == nil then
        return nil
    end
    local item = nil
    for k, v in pairs(data) do
        if v.MakeIndex == MakeIndex then
            item = v
            break
        end
    end
    return item
end

function StallProxy:AddOnSellItems(data)
    table.insert(self.onSellData, data)
end

function StallProxy:GetOnSellData()
    return self.onSellData
end

function StallProxy:GetOnSellDataByMakeIndex(MakeIndex)
    local data = self:GetOnSellData()
    if not data or next(data) == nil then
        return nil
    end
    local item = nil
    for k, v in pairs(data) do
        if v.MakeIndex == MakeIndex then
            item = v
            break
        end
    end
    return item
end

function StallProxy:GetSelectItem()
    return self.seletedItem
end

function StallProxy:SetSelectItem(itemIndex)
    self.seletedItem = itemIndex
end

function StallProxy:GetShowStoreName()
    return self.showStoreName
end

function StallProxy:SetShowStoreName(name)
    self.showStoreName = name
end

function StallProxy:GetNowOpenStoreId()
    return self.nowOpenStoreId
end

function StallProxy:SetNowOpenStoreId(userId)
    self.nowOpenStoreId = userId
end

function StallProxy:GetMyTradingStatus()
    return self.isTrading
end

function StallProxy:SetMyTradingStatus(status)
    self.isTrading = status
end

function StallProxy:OnStallStateDataChange(data)
    if not data or next(data) == nil then
        return
    end
    if not self:GetNowOpenStoreId() then
        return nil
    end
    local userId = data.userid
    local openStatus = data.status
    local nowOpen = self:GetNowOpenStoreId()
    if openStatus and userId then
        if openStatus == 0 then
            if nowOpen == userId then
                global.Facade:sendNotification(global.NoticeTable.Layer_StallLayer_Close)
            end
        end
    end
end

function StallProxy:CleanMySellData()
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    if self.MySellData and next(self.MySellData) then
        for i, v in ipairs(self.MySellData) do
            v.goldtype = nil
            v.price = nil
            local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
            ItemManagerProxy:SetItemBelong(v.MakeIndex, global.MMO.ITEM_FROM_BELONG_STALL)
            BagProxy:AddItemDataAndNotice(v)
        end
        self.MySellData = {}
    end
end

function StallProxy:RequestPutInItem(MakeIndex)
    global.Facade:sendNotification(global.NoticeTable.Layer_Stall_Put_Open, MakeIndex)
end

function StallProxy:PutItemIntoAutoSellBag(MakeIndex, goldType, price)
    if not MakeIndex or not goldType or not price then
        return
    end
    local data = {}
    data.MakeIndex = MakeIndex
    data.goldtype = goldType
    data.price = price
    self:AddItemIntoList(data)
end

function StallProxy:PutOutItem(MakeIndex, onlyRemove)
    if not MakeIndex then
        return
    end
    if not onlyRemove and not CheckCanDoSomething() then
        return
    end
    local deleteIndex = nil
    local item = nil
    for i, v in ipairs(self.MySellData) do
        if v.MakeIndex == MakeIndex then
            deleteIndex = i
            item = v
            break
        end
    end
    if deleteIndex and item then
        table.remove(self.MySellData, deleteIndex)
        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
        ItemManagerProxy:SetItemBelong(deleteIndex, global.MMO.ITEM_FROM_BELONG_STALL)

        if not onlyRemove then
            item.goldtype = nil
            item.price = 0
            local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
            BagProxy:AddItemDataAndNotice(item)
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_StallLayer_SelfItemChange, item)
    end
end

function StallProxy:RequestAutoStall(name, cancel)
    if not cancel and (not name or name == "") then
        ShowSystemTips(GET_STRING(90170003))
        return
    end
    local data = {}
    data.name = name or ""
    if cancel then
        -- data.items = nil --发送的数据不要有key:items
    else
        for i, v in ipairs(self.MySellData) do
            if not data.items then
                data.items = {}
            end
            local sellData = {}
            sellData.makeindex = v.MakeIndex
            sellData.goldtype = v.goldtype
            sellData.price = v.price
            table.insert(data.items, sellData)
        end
    end
    if not cancel and not CheckCanDoSomething(true) then
        ShowSystemTips(GET_STRING(90170002))
        return
    end
    SendTableToServer(global.MsgType.MSG_CS_REQUEST_AUTO_STALL, data)
end

function StallProxy:RequestBuyItem(MakeIndex)
    local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
    local itemData = self:GetOnSellDataByMakeIndex(MakeIndex)
    if not itemData then
        return
    end
    local payInfo = {
        itemID = itemData.goldtype,
        itemNum = itemData.Price,
        bOneID = true,
    }
    if not PayProxy:CheckItemCountEX(payInfo) then
        return
    end
    local userid = self:GetNowOpenStoreId()
    if not userid then
        return
    end
    local data = {}
    data.userid = userid
    data.items = {
        makeindex = MakeIndex
    }
    SendTableToServer(global.MsgType.MSG_CS_REQUEST_STALL_BUY_ITEM, data)
end

function StallProxy:RequestItemList(userId)
    if not userId then
        return
    end
    local data = {}
    data.userid = userId
    SendTableToServer(global.MsgType.MSG_CS_REQUEST_STALL_INFO, data)
end

function StallProxy:ResponItemList(msg)
    local header = msg:GetHeader()
    local data = ParseRawMsgToJson(msg)
    if not data then
        return
    end

    self:CleanNowData()
    if data.items and next(data.items) then
        for i, v in ipairs(data.items) do
            local itemData = ChangeItemServersSendDatas(v)
            itemData.goldtype = v.goldtype
            self:AddOnSellItems(itemData)
        end
    end

    self:SetShowStoreName(data.name)

    self:SetNowOpenStoreId(data.userid)

    global.Facade:sendNotification(global.NoticeTable.Layer_StallLayer_ItemChange)

    SL:OpenStallLayerUI({ buy = true })
end

function StallProxy:CleanNowData()
    self.onSellData = {}
    self.showStoreName = nil
    self:SetNowOpenStoreId(nil)
end

function StallProxy:getCurrencies()
    return self._currencies
end

function StallProxy:addCurrency(item)
    table.insert(self._currencies, { id = item.Index, name = item.Name, item = item })
end

function StallProxy:clearCurrencies()
    self._currencies = {}
end

function StallProxy:RegisterMsgHandler()
    local msgType = global.MsgType

    -- 摆摊列表
    LuaRegisterMsgHandler(msgType.MSG_SC_RESPONE_STALL_INFO, handler(self, self.ResponItemList))
end

return StallProxy