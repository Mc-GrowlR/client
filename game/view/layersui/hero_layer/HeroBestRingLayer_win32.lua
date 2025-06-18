local BaseLayer = requireLayerUI("BaseLayer")
local HeroBestRingLayer = class("HeroBestRingLayer", BaseLayer)

local RichTextHelper = requireUtil("RichTextHelp")

function HeroBestRingLayer:ctor()
    HeroBestRingLayer.super.ctor(self)
    self._hideIconPos = {}
end

function HeroBestRingLayer.create(data)
    local ui = HeroBestRingLayer.new()

    if ui and ui:Init(data) then
        return ui
    end

    return nil
end

function HeroBestRingLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function HeroBestRingLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_BESTRING_WIN32)
    HeroBestRing.main(data)
    self._root = HeroBestRing._ui.Panel_1

    local itemPanelSz = GUI:getContentSize(HeroBestRing._ui.Panel_touch)
    HeroBestRing._Panel_width = itemPanelSz.width
    HeroBestRing._Panel_height = itemPanelSz.height

    GUI:setSwallowTouches(HeroBestRing._ui.Panel_touch, false)

    self:InitUI()
    self:RefreshEquipList()
    refPositionByParent(self)

    self:InitEditMode()
end

function HeroBestRingLayer:InitEditMode()
    for i,v in ipairs(HeroBestRing.posSetting or {}) do
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

function HeroBestRingLayer:InitHideIconPos()
    self._hideIconPos = {}
    for i, v in ipairs(HeroBestRing.posSetting or {}) do
        if self._ui["Image_tag" .. v] then
            local visible = self._ui["Image_tag" .. v]:isVisible()
            if not visible then
                self._hideIconPos[v] = true
            end
        end
    end
end

function HeroBestRingLayer:InitUI()
    local function addItemIntoBag(touchPos)
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        local state = ItemMoveProxy:GetMovingItemState()
        if state then
            local goToName = ItemMoveProxy.ItemGoTo.HERO_BEST_RINGS
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
    global.mouseEventController:registerMouseButtonEvent(HeroBestRing._ui.Panel_touch,
    {
        down_r = setNoswallowMouse,
        special_r = addItemIntoBag
    }
    )
end

function HeroBestRingLayer:RefreshEquipList()
    local panelItems = HeroBestRing._ui.Panel_items
    local posSetting = HeroBestRing.posSetting

    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)

    local function UnScheduler()
        if self._delayFunc then
            global.Director:getActionManager():removeAction(self._delayFunc)
            self._delayFunc = nil
        end
    end

    for index, pos in ipairs(posSetting) do
        local equipPanel = GUI:getChildByName(panelItems, "Node_" .. pos)
        GUI:removeAllChildren(equipPanel)
        local data = SL:GetMetaValue("H.EQUIP_DATA", pos, true)
        local icon = GUI:getChildByName(panelItems, "Image_tag" .. pos)
        if not self._hideIconPos[pos]  then
            if  HeroBestRing._HideDefaultIcon and HeroBestRing._HideDefaultIcon[index] then 
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
            info.from = ItemMoveProxy.ItemFrom.HERO_BEST_RINGS
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
                    ItemMoveProxy:TakeOffEquip_Hero(takeOffEquipData)
                end
            end

            local function mouseMoveCallBack()
                if goodItem._movingState then
                    return
                end
                local tipsData = {}
                tipsData.itemData = data
                tipsData.pos = goodItem:getWorldPosition()
                tipsData.lookPlayer = false
                tipsData.from = ItemMoveProxy.ItemFrom.HERO_BEST_RINGS
                global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, tipsData)
                UnScheduler()
            end

            local function enterItem()
                if self._delayFunc then
                    return false
                end
                self._delayFunc = performWithDelay(goodItem, function () mouseMoveCallBack() end, global.MMO.PC_TIPS_DELAY_TIME) 
            end 

            local function leaveItem()
                global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)
                UnScheduler()
            end

            global.mouseEventController:registerMouseMoveEvent(
            goodItem,
            {
                enter = enterItem,
                leave = leaveItem,
                checkIsVisible = true
            }
            )

            --right mouse btn quick use
            global.mouseEventController:registerMouseButtonEvent(
            goodItem,
            {
                down_r = takeOffEquip,
                double_l = takeOffEquip
            }
            )
            goodItem = HeroBestRing.CreateEquipItemCallBack(goodItem, info)
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

function HeroBestRingLayer:CheckItemOnSomeState(MakeIndex)
    local state = true
    local HeroBagProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroBagProxy)
    local onSellingOrRepairingMakeIndex = HeroBagProxy:GetOnSellOrRepaire()
    if onSellingOrRepairingMakeIndex == MakeIndex then
        state = false
        return state
    end
end

function HeroBestRingLayer:GetItemBagEmptyPos(touchPos)
    local x = touchPos.x
    local y = touchPos.y
    local panelWorldPos = HeroBestRing._ui.Panel_touch:getWorldPosition()
    local posXInPanel = x - panelWorldPos.x
    local posYInPanel = panelWorldPos.y - y
    if posXInPanel >= HeroBestRing._Panel_width or posXInPanel <= 0 then
        return nil
    end

    if posYInPanel >= HeroBestRing._Panel_height or posYInPanel <= 0 then
        return nil
    end

    -- 生肖装备位GM可以进行调整
    local retPos = nil
    local panelItems = HeroBestRing._ui.Panel_items
    local nodeRect = cc.rect(0, 0, global.MMO.BEST_RING_ITEM_WIDTH, global.MMO.BEST_RING_ITEM_HEIGHT)
    local inPanelPos = { x = posXInPanel, y = posYInPanel }
    for i, pos in ipairs(HeroBestRing.posSetting or {}) do
        local equipPanel = panelItems:getChildByName("Node_" .. pos)
        if equipPanel then
            nodeRect.x = equipPanel:getPositionX() - global.MMO.BEST_RING_ITEM_WIDTH / 2
            nodeRect.y = HeroBestRing._Panel_height - equipPanel:getPositionY() - global.MMO.BEST_RING_ITEM_HEIGHT / 2
            if inPanelPos.x >= nodeRect.x and inPanelPos.x <= nodeRect.x + nodeRect.width
            and inPanelPos.y >= nodeRect.y and inPanelPos.y <= nodeRect.y + nodeRect.height then
                retPos = pos
                break
            end
        end
    end
    return retPos
end

function HeroBestRingLayer:ResetEquipState(data)
    local MakeIndex = data.MakeIndex
    local state = data.state and data.state >= 1

    local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
    local itemData = HeroEquipProxy:GetEquipDataByMakeIndex(MakeIndex)
    if not itemData then
        return
    end
    local pos = itemData.Where
    local dePos = HeroEquipProxy:GetDeEquipMappingConfig(pos)
    pos = dePos and dePos or pos
    local panelItems = HeroBestRing._ui.Panel_items
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

function HeroBestRingLayer:RefreshAddTouchSize()
    if HeroBestRing._ui.Panel_touch and not tolua.isnull(HeroBestRing._ui.Panel_touch) then
        local itemPanelSz = HeroBestRing._ui.Panel_touch:getContentSize()
        HeroBestRing._Panel_width = itemPanelSz.width
        HeroBestRing._Panel_height = itemPanelSz.height
    end
end

return HeroBestRingLayer