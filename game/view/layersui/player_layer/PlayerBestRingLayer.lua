local BaseLayer = requireLayerUI("BaseLayer")
local PlayerBestRingLayer = class("PlayerBestRingLayer", BaseLayer)

local RichTextHelper = requireUtil("RichTextHelp")

function PlayerBestRingLayer:ctor()
    PlayerBestRingLayer.super.ctor(self)
    self._hideIconPos = {}
end

function PlayerBestRingLayer.create(data)
    local ui = PlayerBestRingLayer.new()

    if ui and ui:Init(data) then
        return ui
    end

    return nil
end

function PlayerBestRingLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function PlayerBestRingLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_BESTRING)
    PlayerBestRing.main(data)
    self._root = self._ui.Panel_1

    local itemPanelSz = GUI:getContentSize(self._ui.Panel_touch)
    PlayerBestRing._Panel_width = itemPanelSz.width
    PlayerBestRing._Panel_height = itemPanelSz.height

    GUI:setSwallowTouches(self._ui.Panel_touch, false)

    self:InitUI()
    self:RefreshEquipList()

    self:InitEditMode()
end

function PlayerBestRingLayer:InitEditMode()
    for i,v in ipairs(PlayerBestRing.posSetting or {}) do
        self._ui["Image_"..v].editMode = 1
        self._ui["Image_tag"..v].editMode = 1
        self._ui["Node_"..v].editMode = 1
    end 
    local items = {
        "Image_1",
        "Image_2",
        "Image_3",
        "Button_close",
        "Panel_touch",
    }
    for i, widget in ipairs(items) do
        if self._ui[widget] then
            self._ui[widget].editMode = 1
        end
    end
end

function PlayerBestRingLayer:InitHideIconPos()
    self._hideIconPos = {}
    for i, v in ipairs(PlayerBestRing.posSetting or {}) do
        if self._ui["Image_tag" .. v] then
            local visible = self._ui["Image_tag" .. v]:isVisible()
            if not visible then
                self._hideIconPos[v] = true
            end
        end
    end
end

function PlayerBestRingLayer:InitUI()
    local function addItemIntoBag(touchPos)
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        local state = ItemMoveProxy:GetMovingItemState()
        if state then
            local goToName = ItemMoveProxy.ItemGoTo.BEST_RINGS
            local data = {}
            data.target = goToName
            data.pos = touchPos
            data.equipPos = self:GetItemBagEmptyPos(touchPos)
            ItemMoveProxy:CheckAndCallBack(data)
        else
            return -1
        end
    end
    local function setNoswallowMouse()
        return -1
    end
    global.mouseEventController:registerMouseButtonEvent(self._ui.Panel_touch,
    {
        down_r = setNoswallowMouse,
        special_r = addItemIntoBag
    }
    )
end

function PlayerBestRingLayer:RefreshEquipList()
    local panelItems = self._ui.Panel_items
    local posSetting = PlayerBestRing.posSetting

    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)

    for index, pos in ipairs(posSetting) do
        local equipPanel = GUI:getChildByName(panelItems, "Node_" .. pos)
        GUI:removeAllChildren(equipPanel)
        local data = SL:GetMetaValue("EQUIP_DATA", pos, true)
        local icon = GUI:getChildByName(panelItems, "Image_tag" .. pos)
        if not self._hideIconPos[pos]  then
            if  PlayerBestRing._HideDefaultIcon and PlayerBestRing._HideDefaultIcon[index] then 
                GUI:setVisible(icon, false)
            else
                GUI:setVisible(icon, not data)
            end
        end
        if data then
            local info = {}
            info.itemData = data
            info.index = data.Index
            info.look = true
            info.movable = true
            info.noMouseTips = true
            info.showModelEffect = true
            info.from = ItemMoveProxy.ItemFrom.BEST_RINGS
            info.lookPlayer = false
            local goodItem = GoodsItem:create(info)
            goodItem:setTag(data.MakeIndex)

            local function takeOffEquip()
                global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)

                local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
                local itemMoving = ItemMoveProxy:GetMovingItemState()
                if itemMoving then --在道具移动中
                    return
                end
                if data then
                    local takeOffEquipData = {
                        itemData = data,
                        pos = data.Where
                    }
                    ItemMoveProxy:TakeOffEquip(takeOffEquipData)
                end
            end

            goodItem = PlayerBestRing.CreateEquipItemCallBack(goodItem, info)

            -- double touch or double left mouse btn click 
            goodItem:addDoubleEventListener(takeOffEquip)
            equipPanel:addChild(goodItem)

            --移动中处理
            local itemMoving = ItemMoveProxy:GetMovingItemState()
            local itemMovingData = ItemMoveProxy:GetMovingItemData()
            if itemMoving and data and itemMovingData then --在道具移动中
                if data.MakeIndex == itemMovingData.MakeIndex then
                    global.Facade:sendNotification(global.NoticeTable.Layer_Moved_UpDate, {
                        goodItem = goodItem
                    })
                    goodItem:resetMoveState(true)
                end
            end
        end
    end
end

function PlayerBestRingLayer:CheckItemOnSomeState(MakeIndex)
    local state = true
    local bagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    local onSellingOrRepairingMakeIndex = bagProxy:GetOnSellOrRepaire()
    if onSellingOrRepairingMakeIndex == MakeIndex then
        state = false
        return state
    end
end

function PlayerBestRingLayer:GetItemBagEmptyPos(touchPos)
    local x = touchPos.x
    local y = touchPos.y
    local panelWorldPos = self._ui.Panel_touch:getWorldPosition()
    local posXInPanel = x - panelWorldPos.x
    local posYInPanel = panelWorldPos.y - y
    if posXInPanel >= PlayerBestRing._Panel_width or posXInPanel <= 0 then
        return nil
    end

    if posYInPanel >= PlayerBestRing._Panel_height or posYInPanel <= 0 then
        return nil
    end

    -- 生肖装备位GM可以进行调整
    local retPos = nil
    local panelItems = self._ui.Panel_items
    local nodeRect = cc.rect(0, 0, global.MMO.BEST_RING_ITEM_WIDTH, global.MMO.BEST_RING_ITEM_HEIGHT)
    local inPanelPos = { x = posXInPanel, y = posYInPanel }
    for i, pos in ipairs(PlayerBestRing.posSetting or {}) do
        local equipPanel = panelItems:getChildByName("Node_" .. pos)
        if equipPanel then
            nodeRect.x = equipPanel:getPositionX() - global.MMO.BEST_RING_ITEM_WIDTH / 2
            nodeRect.y = PlayerBestRing._Panel_height - equipPanel:getPositionY() - global.MMO.BEST_RING_ITEM_HEIGHT / 2
            if inPanelPos.x >= nodeRect.x and inPanelPos.x <= nodeRect.x + nodeRect.width
            and inPanelPos.y >= nodeRect.y and inPanelPos.y <= nodeRect.y + nodeRect.height then
                retPos = pos
                break
            end
        end
    end
    return retPos
end

function PlayerBestRingLayer:ResetEquipState(data)
    local MakeIndex = data.MakeIndex
    local state = data.state and data.state >= 1

    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local itemData = EquipProxy:GetEquipDataByMakeIndex(MakeIndex)
    if not itemData then
        return
    end
    local pos = itemData.Where
    local dePos = EquipProxy:GetDeEquipMappingConfig(pos)
    pos = dePos and dePos or pos
    local panelItems = self._ui.Panel_items
    local equipPanel = panelItems:getChildByName("Node_" .. pos)
    local icon = panelItems:getChildByName("Image_tag" .. pos)
    if not equipPanel then
        return
    end
    local gooditem = equipPanel:getChildByTag(MakeIndex)
    if not gooditem then
        return
    end
    gooditem:setVisible(data.state and data.state > 0)
    gooditem._movingState = not (data.state and data.state > 0)
    if not self._hideIconPos[pos] then
        icon:setVisible(not (data.state and data.state > 0))
    end
end

function PlayerBestRingLayer:RefreshAddTouchSize()
    if self._ui.Panel_touch and not tolua.isnull(self._ui.Panel_touch) then
        local itemPanelSz = self._ui.Panel_touch:getContentSize()
        PlayerBestRing._Panel_width = itemPanelSz.width
        PlayerBestRing._Panel_height = itemPanelSz.height
    end
end

return PlayerBestRingLayer