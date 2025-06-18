local BaseLayer = requireLayerUI("BaseLayer")
local AuctionWorldLayer = class("AuctionWorldLayer", BaseLayer)

local QuickCell = requireUtil("QuickCell")

function AuctionWorldLayer:ctor()
    AuctionWorldLayer.super.ctor(self)
    self._proxy = global.Facade:retrieveProxy(global.ProxyTable.AuctionProxy)

    -- 职业 全部 战 法 道
    self.filterjob = {
        {
            value = 3,
            name  = GET_STRING(1088),
        },
    }
    local jobAble  = self._proxy:getJobAble()
    for key, value in pairs(jobAble) do
        if value then
            local job = (key >= 1 and key <= 3) and (key - 1) or key 
            table.insert(self.filterjob, {value = job, name = GetJobName(job)})
        end
    end
    
    -- 品阶
    self.qualities = clone(self._proxy:getQualities())
    table.insert(self.qualities, 1, {id = 0, name = GET_STRING(1088)})

    -- 货币
    self.currencies = clone(self._proxy:getCurrencies())
    table.insert(self.currencies, 1, {id = 0, name = GET_STRING(1088)})

    -- 价格
    self.filter_price = {
        {
            value = 1,
            name  = GET_STRING(30103067),
        },
        {
            value = 2,
            name  = GET_STRING(30103067),
        },
    }
    
    self._source        = 0                     -- 0.世界拍卖 1.行会拍卖
    self._cells         = {}                    -- hash
    self._items         = {}                    -- hash

    self._filter1Index  = 1
    self._filter1State  = true
    self._filter1Cells  = {}

    self._filter                = {}            -- 筛选 [1]类型  [2]职业(战法道全部0123)  [3]品级  [4]货币(1元宝 2传奇币)  [5]价格(1升序 2降序)  
    self._filterJobCell         = nil
    self._filterQualityCell     = nil
    self._filterMoneyCell       = nil
    self._filterPriceCell       = nil

    self._IsSearchItem          = nil

    self._itemConfig = self._proxy:GetItemConfig()
end

function AuctionWorldLayer.create(...)
    local ui = AuctionWorldLayer.new()
    if ui and ui:Init(...) then
        return ui
    end
    return nil
end

function AuctionWorldLayer:Init(data)
    self._quickUI = ui_delegate(self)
    return true
end

function AuctionWorldLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_AUCTION_WORLD)
    AuctionWorld.main(data.source)

    self._source = data.source or 0

    local status = true
    local function listviewEvent(_, eventType)
        if eventType == 9 or eventType == 10 then
            local innerPos = self._quickUI.ListView_items:getInnerContainerPosition()
            local itemHei = AuctionWorld._itemSize and AuctionWorld._itemSize.height or 80
            local count = #self._quickUI.ListView_items:getChildren()
            local realHei = count * itemHei + (count - 1) * self._quickUI.ListView_items:getItemsMargin()
            local contentSize = self._quickUI.ListView_items:getContentSize()
            if innerPos.y == 0 then
                if false == self._proxy:IsComplete() and status then
                    status = false
                    performWithDelay(self._quickUI.ListView_items, function()
                        status = true
                    end, 0.5)

                    if realHei < contentSize.height then
                        return
                    end
                    performWithDelay(self._quickUI.ListView_items, function()
                        self:PullItemList()
                    end, 0.01)
                end
            end
        end
    end
    self._quickUI.ListView_items:addScrollViewEventListener(listviewEvent)
    self._quickUI.ListView_items:addMouseScrollPercent()
    
    self:InitFilter()
    self:ClearItemList()
    self:PullItemList()
end

function AuctionWorldLayer:ClearItemList()
    self._proxy:Clear()
end

function AuctionWorldLayer:PullItemList()
    local quality           = self.qualities[self._filter[3]].id
    local currency          = self.currencies[self._filter[4]].id
    local job               = self.filterjob[self._filter[2]].value
    local stdmode           = self._proxy:GetStdModeByID(self._filter[1])
    local filterSrv = {
        src = self._source,
        f1  = stdmode,
        f2  = job,
        f3  = quality,
        f4  = currency,
        f5  = self._filter[5],
    }
    if self._filter[1] == 1 and self._source == 0 then
        filterSrv.f6 = self._IsSearchItem
    else
        self._IsSearchItem = nil
    end

    ShowLoadingBar(3)
    self._proxy:RequestItemList(filterSrv)
end

function AuctionWorldLayer:InitFilter()
    -- 默认
    local PlayerProperty    = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local roleJob           = PlayerProperty:GetRoleJob()
    local jobAble           = self._proxy:getJobAble()
    self._filter[1]         = 1         -- 类型
    self._filter[2]         = 1         -- 职业
    self._filter[3]         = 1         -- 品阶
    self._filter[4]         = 1         -- 货币
    self._filter[5]         = 1         -- 价格升序降序

    -- 筛选 装备、材料...
    local items = self._proxy:GetCTypeInGroup()
    for _, v in ipairs(items) do
        local cell = self:CreateFilterGroup1Cell()
        self._quickUI.ListView_filter_1:pushBackCustomItem(cell.nativeUI)
        self._filter1Cells[v[1].firstlevel] = cell
        cell.Button_1:setTitleText(v[1].firstlevelname)
        cell.Button_1:addClickEventListener(function()
            if self._filter1Index ~= v[1].firstlevel then
                self._filter1State = true
                
            elseif self._filter1Index ~= 1 then
                self._filter1State = not self._filter1State
            end

            if self._filter1State then
                if self._filter1Index ~= v[1].firstlevel then
                    self._filter[1] = v[1].id
                    self:ClearItemList()
                    self:PullItemList()
                end
            end
            self:UpdateFilter1()

            self._filter1Index = v[1].firstlevel
        end)
    end

    -- 职业
    self._filterJobCell = self:CreateFilterCell()
    self._quickUI.Node_filter_job:addChild(self._filterJobCell.nativeUI)
    self._filterJobCell.Image_arrow:setVisible(false)
    self._filterJobCell.nativeUI:addClickEventListener(function()
        self:ShowFilterItems(1)
    end)
    
    -- 品级
    self._filterQualityCell = self:CreateFilterCell()
    self._quickUI.Node_filter_quality:addChild(self._filterQualityCell.nativeUI)
    self._filterQualityCell.Image_arrow:setVisible(false)
    self._filterQualityCell.nativeUI:addClickEventListener(function()
        self:ShowFilterItems(2)
    end)

    -- 货币
    self._filterMoneyCell = self:CreateFilterCell()
    self._quickUI.Node_filter_money:addChild(self._filterMoneyCell.nativeUI)
    self._filterMoneyCell.Image_arrow:setVisible(false)
    self._filterMoneyCell.nativeUI:addClickEventListener(function()
        self:ShowFilterItems(3)
    end)

    -- 价格
    self._filterPriceCell = self:CreateFilterCell()
    self._quickUI.Node_filter_price:addChild(self._filterPriceCell.nativeUI)
    self._filterPriceCell.nativeUI:addClickEventListener(function()
        self:ShowFilterItems(4)
    end)

    -- 隐藏筛选
    self:HideFilterItems()
    self._quickUI.Panel_hide_filter:addClickEventListener(function()
        self:HideFilterItems()
    end)

    self:UpdateFilter1()
    self:UpdateFilter2()
end

function AuctionWorldLayer:UpdateFilter1()
    -- 组1
    for i, v in ipairs(self._filter1Cells) do
        local config = self._proxy:GetCTypeByID(self._filter[1])
        local status = (i == config.firstlevel and self._filter1State)
        v.Button_1:setBright(status)
        local titleColor = GetColorFromHexString(status and AuctionWorld.Group1CellColorSel or AuctionWorld.Group1CellColorNormal)
        v.Button_1:setTitleColor(titleColor)
    end
    -- 组2
    if self._filter1State then
        local config = self._proxy:GetCTypeByID(self._filter[1])
        local items = self._proxy:GetCTypeItemsByGroup(config.firstlevel)

        -- rmv
        local ListView_filter_1 = self._quickUI.ListView_filter_1
        local child = ListView_filter_1:getChildByName("listview")
        if child then
            ListView_filter_1:removeChild(child)
        end

        if #items > 0 then
            local listview = ccui.ListView:create()
            listview:setName("listview")
            listview:setTouchEnabled(true)
            listview:setClippingEnabled(true)
            listview:setClippingType(0)
            listview:addMouseScrollPercent()
            ListView_filter_1:insertCustomItem(listview, config.firstlevel)
            ListView_filter_1:setClippingType(0)
        
            local cells = {}
            local jumpIndex = 0
            local itemSize = nil
            for i, v in ipairs(items) do
                local selected  = (v.secondlevel == config.secondlevel)
                jumpIndex       = (selected and i or jumpIndex)

                local cell = self:CreateFilterGroup2Cell()
                listview:pushBackCustomItem(cell.nativeUI)
                table.insert(cells, cell)
                cell.Text_name:setString(v.secondlevelname)
                cell.Image_1:setVisible(selected)
                cell.Image_2:setVisible(selected)

                cell.nativeUI:addClickEventListener(function()
                    -- record
                    self._filter[1] = v.id
                    local tconfig   = self._proxy:GetCTypeByID(self._filter[1])
                    for k, vcell in pairs(cells) do
                        vcell.Image_1:setVisible(items[k].secondlevel == tconfig.secondlevel)
                        vcell.Image_2:setVisible(items[k].secondlevel == tconfig.secondlevel)
                    end

                    -- pull list
                    self:ClearItemList()
                    self:PullItemList()
                end)

                if not itemSize then
                    itemSize = cell.nativeUI:getContentSize()
                end
            end

            local listWid  = ListView_filter_1:getContentSize().width
            local listHei  = math.min(itemSize.height * #items, 187)
            listview:setContentSize(cc.size(listWid, listHei))
            
            jumpIndex = jumpIndex - 1
            listview:jumpToItem(jumpIndex, cc.p(0, 0), cc.p(0, 0))
        end        
    else
        -- rmv
        local child = self._quickUI.ListView_filter_1:getChildByName("listview")
        if child then
            self._quickUI.ListView_filter_1:removeChild(child)
        end
    end
end

function AuctionWorldLayer:UpdateFilter2()
    -- 职业
    local item = self.filterjob[self._filter[2]]
    self._filterJobCell.Text_1:setString(item.name)

    -- 品质
    local item = self.qualities[self._filter[3]]
    self._filterQualityCell.Text_1:setString(item and item.name)

    -- 货币
    local item = self.currencies[self._filter[4]]
    self._filterMoneyCell.Text_1:setString(item and item.name)

    -- 价格
    local item = self.filter_price[self._filter[5]]
    local path = self._filter[5] == 1 and AuctionWorld.FilterPriceArrowUp or AuctionWorld.FilterPriceArrowDown
    self._filterPriceCell.Text_1:setString(item.name)
    self._filterPriceCell.Image_arrow:loadTexture(path)
end

function AuctionWorldLayer:ShowFilterItems(index)
    local itemH = nil
    local filterBgPosX = 0
    local filter_bg = self._quickUI.Image_filter_bg
    local ListView_filter = self._quickUI.ListView_filter_3
    filter_bg:setVisible(true)
    ListView_filter:removeAllItems()
    self._quickUI.Panel_hide_filter:setVisible(true)

    local cells = {}
    local items = {}

    if index == 1 then
        items = self.filterjob
        self._filterJobCell.Image_pull:setFlippedY(true)
        filterBgPosX = self._quickUI.Node_filter_job:getPositionX()

    elseif index == 2 then
        items = self.qualities
        self._filterQualityCell.Image_pull:setFlippedY(true)
        filterBgPosX = self._quickUI.Node_filter_quality:getPositionX()

    elseif index == 3 then
        items = self.currencies
        self._filterMoneyCell.Image_pull:setFlippedY(true)
        filterBgPosX = self._quickUI.Node_filter_money:getPositionX()

    elseif index == 4 then
        items = self.filter_price
        self._filterPriceCell.Image_pull:setFlippedY(true)
        filterBgPosX = self._quickUI.Node_filter_price:getPositionX()
    end

    for i, v in ipairs(items) do
        local cell = self:CreateFilterCell()
        table.insert(cells, cell)

        if not itemH then
            itemH = cell.nativeUI:getContentSize().height
        end

        cell.Text_1:setString(v.name)
        cell.Image_pull:setVisible(false)
        cell.Image_arrow:setVisible(index == 4)
        cell.Image_arrow:loadTexture(v.value == 1 and AuctionWorld.FilterPriceArrowUp or AuctionWorld.FilterPriceArrowDown)

        cell.nativeUI:addClickEventListener(function()
            self._filter[index+1] = i

            dump(self._filter)

            self:UpdateFilter2()
            self:HideFilterItems()

            self:ClearItemList()
            self:PullItemList()
        end)
    end

    local itemWid = ListView_filter:getContentSize().width
    local height  = math.min(#cells, AuctionWorld.MaxFilterCells) * (itemH or 32)
    filter_bg:setPositionX(filterBgPosX)
    filter_bg:setContentSize({width=itemWid + 5, height=height + 5})
    ListView_filter:setContentSize({width=itemWid, height=height})
    for i, v in ipairs(cells) do
        ListView_filter:pushBackCustomItem(v.nativeUI)
    end
    ListView_filter:setTouchEnabled(false)
end

function AuctionWorldLayer:HideFilterItems()
    self._quickUI.Image_filter_bg:setVisible(false)
    self._quickUI.Panel_hide_filter:setVisible(false)
    self._quickUI.ListView_filter_3:removeAllItems()

    self._filterJobCell.Image_pull:setFlippedY(false)
    self._filterQualityCell.Image_pull:setFlippedY(false)
    self._filterMoneyCell.Image_pull:setFlippedY(false)
    self._filterPriceCell.Image_pull:setFlippedY(false)
end

function AuctionWorldLayer:CreateFilterCell(data)
    local root = cc.Node:create()
    AuctionWorld.CreateFilterCell(root)
    local layout = root:getChildByName("Panel_1")
    layout:removeFromParent()
    local ui = ui_delegate(layout)

    return ui
end

function AuctionWorldLayer:CreateFilterGroup1Cell(data)
    local root = cc.Node:create()
    AuctionWorld.CreateFilterGroup1Cell(root)
    local layout = root:getChildByName("Panel_1")
    layout:removeFromParent()
    local ui = ui_delegate(layout)

    return ui
end

function AuctionWorldLayer:CreateFilterGroup2Cell(data)
    local root = cc.Node:create()
    AuctionWorld.CreateFilterGroup2Cell(root)
    local layout = root:getChildByName("Panel_1")
    layout:removeFromParent()
    local ui = ui_delegate(layout)

    return ui
end

function AuctionWorldLayer:OnAuctionItemListClear()
    if AuctionWorld and AuctionWorld.OnClearItemList then
        AuctionWorld.OnClearItemList()
    end
end

function AuctionWorldLayer:OnAuctionItemListResp(data)
    local items = data.items
    local source = data.source

    if data.source ~= self._source then
        return
    end

    if AuctionWorld and AuctionWorld.OnPullItemList then
        AuctionWorld.OnPullItemList(items)
    end
end

function AuctionWorldLayer:OnAuctionItemDel(data)
    local item   = data.item

    if AuctionWorld and AuctionWorld.OnAuctionItemDel then
        AuctionWorld.OnAuctionItemDel(item)
    end
end

function AuctionWorldLayer:OnAuctionItemChange(data)
    local item = data.item

    if AuctionWorld and AuctionWorld.OnAuctionItemChange then
        AuctionWorld.OnAuctionItemChange(item)
    end
end

function AuctionWorldLayer:OnAuctionWorldItemSearchByName(data)
    local matchIndexStr = self:SearchAllItemsByKeyWord(data)
    if not matchIndexStr or string.len(matchIndexStr) == 0 then
        self._IsSearchItem  = nil
    else
        self._IsSearchItem  = matchIndexStr
    end

    self._filter1State = true
    self._filter1Index = 1
    self._filter[1]    = 1         
    self._filter[2]    = 1         
    self._filter[3]    = 1         
    self._filter[4]    = 1         
    self._filter[5]    = 1        
    self:ClearItemList()
    self:PullItemList()

    self:UpdateFilter1()
    self:UpdateFilter2()
end

function AuctionWorldLayer:SearchAllItemsByKeyWord(str)
    if not str or string.len(str) == 0 then
        ShowSystemTips(GET_STRING(700000021))
        return nil
    end
   
    local matchItems = {}

    local specialR  = {"%[", "%]", "%(","%)","%*"}
    for _, key in ipairs(specialR) do
        str = string.gsub(str, key, "%"..key)
    end
    
    if string.len( str ) > 32 then
        ShowSystemTips(GET_STRING(700000021))
        return nil
    end

    for _, v  in pairs(self._itemConfig) do
        if #matchItems > 36 then
            break
        end
        if string.find(v.Name, str) then
            table.insert( matchItems, v.Index )
        end
    end

    if #matchItems > 35 then
        ShowSystemTips(GET_STRING(700000020))
        return nil
    elseif #matchItems == 0 then
        ShowSystemTips(GET_STRING(700000021))
    end

    local matchIndexStr = table.concat( matchItems, ",")
    -- dump(matchIndexStr, "====MatchIndexList====")
    return matchIndexStr
    
end

return AuctionWorldLayer