local BaseLayer = requireLayerUI("BaseLayer")
local NpcMakeDrugLayer = class("NpcMakeDrugLayer", BaseLayer)

local RichTextHelper = requireUtil("RichTextHelp")

function NpcMakeDrugLayer:ctor()
    self.listPage = 1
    self.selectItemCell = nil
    self.selectItemData = nil
end

function NpcMakeDrugLayer.create()
    local layer = NpcMakeDrugLayer.new()
    if layer and layer:Init() then
        return layer
    end

    return nil
end

function NpcMakeDrugLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function NpcMakeDrugLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAKE_DRUG)
    NPCMakeDrug.main()

    self._root = self._quickUI.Panel_1

    self:InitUI(data)
end

function NpcMakeDrugLayer:InitUI(data)
    self.itemList = data and data.items or {}
    self.maxPage = #GetPageData({ dataLength = #self.itemList, pageLength = NPCMakeDrug.perPageItemsCount })
    self.list = UIGetChildByName(self._root, "ListView_list")
    self.btnOk = UIGetChildByName(self._root, "Button_ok")
    self.btnLast = UIGetChildByName(self._root, "Button_last")
    self.btnNext = UIGetChildByName(self._root, "Button_next")
    self.btnClose = UIGetChildByName(self._root, "Button_close")

    self.btnClose:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Make_Drug_Close)
    end)

    self.btnLast:addClickEventListener(function()
        self:changePage(true)
    end)

    self.btnNext:addClickEventListener(function()
        self:changePage(false)
    end)

    self.btnOk:addClickEventListener(function()
        self:onClickOkBtnEvent()
    end)

    self:refreshList()
end

function NpcMakeDrugLayer:changePage(isLeft)
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

    self:refreshList()
end

function NpcMakeDrugLayer:refreshList()
    self.list:removeAllChildren()

    local data = self.itemList
    if not data or next(data) == nil then
        return
    end

    local beginIndex, endIndex = self:getPageBeginAndEnd()
    for key = beginIndex, endIndex do
        local cell = self:CreateItemsListCell(data[key], key)
        self.list:pushBackCustomItem(cell.layout_bg)
    end
end

function NpcMakeDrugLayer:getPageBeginAndEnd()
    local page = self.listPage or 1
    local maxList = #self.itemList
    local data = {
        dataLength = maxList
    }
    local pageData = GetPageData(data)
    local beginIndex = pageData[page].beginItem
    local endIndex = pageData[page].endItem
    return beginIndex, endIndex
end

function NpcMakeDrugLayer:CreateItemsListCell(data, key)
    local root = cc.Node:create()
    NPCMakeDrug.CreateItemCell(root)

    local layout_bg = root:getChildByName("Panel_item")
    layout_bg:removeFromParent()
    local point = layout_bg:getChildByName("Text_point")
    local textItemName = layout_bg:getChildByName("Text_itemName")
    local textItemPrice = layout_bg:getChildByName("Text_itemPrice")
    local textItemDura = layout_bg:getChildByName("Text_itemDura")
    textItemDura:setVisible(false)
    point:setVisible(false)

    if data.name then
        textItemName:setString(data.name)
    end

    if data.price then
        textItemPrice:setString(string.format(GET_STRING(3001), data.price))
    end

    if data.stock and data.subMenu and data.subMenu > 0 then
        textItemDura:setString(GET_STRING(4))
    end

    local cell = {
        layout_bg = layout_bg,
        text_name = textItemName,
        text_price = textItemPrice,
        text_dura = textItemDura,
        point = point
    }

    local function callback()
        self:cleanSelectData()
        self:chooseItems(cell, data)
        self:resetSelectItemData(data)
    end
    layout_bg:addClickEventListener(callback)

    return cell
end

function NpcMakeDrugLayer:resetSelectItemData(data)
    self.selectItemData = data or {}
end

function NpcMakeDrugLayer:getSelectItemData()
    return self.selectItemData
end

function NpcMakeDrugLayer:cleanSelectData()
    self.selectItemData = nil
end

function NpcMakeDrugLayer:chooseItems(cell, data)
    local function cleanSelectStatus()
        local textItemName = self.selectItemCell.text_name
        local textItemPrice = self.selectItemCell.text_price
        local textItemDura = self.selectItemCell.text_dura
        local point = self.selectItemCell.point
        point:setVisible(false)
        textItemDura:setVisible(data.Dura ~= nil)
        local color = cc.c3b(255, 255, 255)
        textItemName:setTextColor(color)
        textItemPrice:setTextColor(color)
        textItemDura:setTextColor(color)
        self.selectItemCell = nil
    end

    local function setSelect()
        local color = cc.c3b(255, 0, 0)
        cell.text_name:setTextColor(color)
        cell.text_price:setTextColor(color)
        cell.text_dura:setTextColor(color)
        cell.point:setVisible(true)
        cell.text_dura:setVisible(true)
        self.selectItemCell = cell
    end

    if not self.selectItemCell then
        setSelect()
    else
        cleanSelectStatus()
        setSelect()
    end
end

function NpcMakeDrugLayer:onClickOkBtnEvent()
    local data = self:getSelectItemData()
    if not data or not next(data) then
        return
    end

    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    NPCProxy:RequestNpcMakeDrug(data)
end

return NpcMakeDrugLayer