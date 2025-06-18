local BaseLayer = requireLayerUI("BaseLayer")
local NpcStoreLayer = class("NpcStoreLayer", BaseLayer)

local RichTextHelper = requireUtil("RichTextHelp")

function NpcStoreLayer:ctor()
    self.listPage = 1
    self.selectItemCell = nil
    self.selectItemData = nil
    self.pageMaxNums = 8
end

function NpcStoreLayer.create()
    local ui = NpcStoreLayer.new()
    if ui and ui:Init() then
        return ui
    end

    return nil
end

function NpcStoreLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function NpcStoreLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_NPC_STORE)
    NPCStore.main()

    self.pageMaxNums = NPCStore.perPageItemsCount or self.pageMaxNums

    self._customize_panel = self._quickUI.Panel_customize
    self._root = self._quickUI.Panel_1

    self:InitUI(data)
end

function NpcStoreLayer:InitUI(data)
    data = data or {}
    if not data.Items then
        data.Items = {}
    end
    self.itemList = data.Items
    self.maxPage = math.ceil(#self.itemList / self.pageMaxNums)
    self.list = UIGetChildByName(self._root, "ListView_list")
    self.btnOk = UIGetChildByName(self._root, "Button_ok")
    self.btnLast = UIGetChildByName(self._root, "Button_last")
    self.btnNext = UIGetChildByName(self._root, "Button_next")
    self.btnClose = UIGetChildByName(self._root, "Button_close")
    self.pagesText = UIGetChildByName(self._root, "Text_pages")

    self.btnClose:addClickEventListener( function()
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Store_Close)
    end)

    self.btnOk:addClickEventListener(function()
        DelayTouchEnabled(self.btnOk, 0.25)
        self:onClickOkBtnEvent()
    end)

    self.btnLast:addClickEventListener(function()
        self:changePage(true)
    end)

    self.btnNext:addClickEventListener(function()
        self:changePage(false)
    end)

    self.pagesText:setString(self.listPage .. "/" .. self.maxPage)

    self:refreshList()
end

function NpcStoreLayer:changePage(isLeft)
    if isLeft and self.listPage <= 1 then
        return
    end
    if not isLeft and self.listPage >= self.maxPage then
        return
    end

    local changePage = isLeft and -1 or 1
    self.listPage = self.listPage + changePage

    self:cleanSelectData()

    self.selectItemCell = nil

    self.pagesText:setString(self.listPage .. "/" .. self.maxPage)

    self:refreshList()
end

function NpcStoreLayer:refreshList(select_data)
    self.list:removeAllChildren()
    
    local data = self.itemList
    if not data or next(data) == nil then
        return
    end

    local beginIndex, endIndex = self:GetPageBeginAndEnd()
    for key = beginIndex, endIndex do
        local cell = self:CreateItemsListCell(data[key], key, select_data)
        if cell then
            self.list:pushBackCustomItem(cell)
        end
    end
end

function NpcStoreLayer:GetPageBeginAndEnd()
    local page = self.listPage or 1
    local maxList = #self.itemList
    if maxList < ((page - 1) * self.pageMaxNums + 1) then
        self.listPage = 1
        page = self.listPage
    end

    local beginIndex = (page - 1) * self.pageMaxNums + 1
    local endIndex = beginIndex + self.pageMaxNums - 1
    endIndex = math.min(maxList, endIndex)

    return beginIndex, endIndex
end

function NpcStoreLayer:CreateItemsListCell(data, key, select_data)
    local row, col = self:GetItemRowAndCol(key)
    local cell = nil
    if col == 1 then
        cell = self._customize_panel:getChildByName("Panel_item"):cloneEx()
    else
        cell = self.list:getItem(row - 1)
    end
    local item = cell:getChildByName("Panel_item" .. col)
    item:setVisible(true)
    local textItemName = item:getChildByName("Text_item_name")
    local textItemPrice = item:getChildByName("Text_item_price")
    local layout_bg = item:getChildByName("Image_item_bg")
    local iconBg = item:getChildByName("Image_icon_bg")
    local Node_itemshow = item:getChildByName("Node_itemshow")

    item:setName(tostring(key))

    if data.MakeIndex then
        item:setTag(data.MakeIndex)
    end

    if data.Name then
        textItemName:setString(data.Name)
    end

    if data.Price then
        textItemPrice:setString(string.format(GET_STRING(3001), data.Price))
    end

    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local Index = data.Index or ItemConfigProxy:GetItemIndexByName(data.Name)

    if Index then
        local itemCfg = ItemConfigProxy:GetItemDataByIndex(Index)
        if next(itemCfg) and data.Dura and data.DuraMax then
            itemCfg.Dura = data.Dura
            itemCfg.DuraMax = data.DuraMax
        else
            itemCfg = nil
        end
        local goodsItem = GoodsItem:create({ itemData = itemCfg, index = Index, look = true })
        goodsItem:setPosition(cc.p(iconBg:getContentSize().width/2, iconBg:getContentSize().height/2))
        iconBg:addChild(goodsItem)
    end

    local function callback()
        self:cleanSelectData()
        self:chooseItems(item, data)
        self:resetSelectItemData(data)
    end
    layout_bg:addClickEventListener(callback)

    if select_data and select_data.MakeIndex == data.MakeIndex then
        callback()
    end

    if col == 1 then
        return cell
    end

    return nil
end

-- 获取行列
function NpcStoreLayer:GetItemRowAndCol(index)
    local row = math.floor(index / 2)
    local col = 1

    if row > (self.pageMaxNums / 2) then
        row = row % (self.pageMaxNums / 2)
        if row == 0 then
            row = 4
        end
    end

    if index % 2 == 0 then
        col = 2
    end
    return row, col
end

function NpcStoreLayer:resetSelectItemData(data)
    self.selectItemData = data or {}
end

function NpcStoreLayer:getSelectItemData()
    return self.selectItemData
end

function NpcStoreLayer:cleanSelectData()
    self.selectItemData = nil
end

function NpcStoreLayer:chooseItems(item, data)
    local function cleanSelectStatus()
        local textItemName = self.selectItemCell:getChildByName("Text_item_name")
        local textItemPrice = self.selectItemCell:getChildByName("Text_item_price")
        local color = cc.c3b(255, 255, 255)
        textItemName:setTextColor(color)
        textItemPrice:setTextColor(color)
        self.selectItemCell = nil
    end

    local function setSelect()
        local textItemName = item:getChildByName("Text_item_name")
        local textItemPrice = item:getChildByName("Text_item_price")
        local color = cc.c3b(255, 0, 0)
        textItemName:setTextColor(color)
        textItemPrice:setTextColor(color)
        self.selectItemCell = item
    end

    if not self.selectItemCell then
        setSelect()
    else
        cleanSelectStatus()
        setSelect()
    end
end

function NpcStoreLayer:onClickOkBtnEvent()
    local data = self:getSelectItemData()
    if not data or not next(data) then
        return
    end

    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    -- has menu
    if data.SubMenu and data.SubMenu > 0 then
        NPCProxy:RequestNpcStoreItemList(data)

    -- auto buy        
    else
        NPCProxy:RequestNpcStoreBuy(data)
    end
end

function NpcStoreLayer:RemoveItems(MakeIndex)
    if MakeIndex and self.list then
        local cells = self.list:getItems()
        local removeTBIndex = nil
        for key, _cell in ipairs(cells) do
            for i = 1, 2 do
                local item = _cell:getChildByTag(MakeIndex)
                if item then
                    removeTBIndex = tonumber(item:getName())
                    break
                end
            end
        end

        if removeTBIndex then
            table.remove(self.itemList, removeTBIndex)
        end

        if self:getSelectItemData() then
            self:cleanSelectData()
            self.selectItemCell = nil
            self:refreshList()
        end
    end
end

return NpcStoreLayer