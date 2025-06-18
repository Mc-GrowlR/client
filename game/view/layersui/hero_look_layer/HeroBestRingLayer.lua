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
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_LOOK_BESTRING)
    HeroBestRing_Look.main(data)
    self._root = HeroBestRing_Look._ui.Panel_1

    local itemPanelSz = GUI:getContentSize(HeroBestRing_Look._ui.Panel_touch)
    HeroBestRing_Look._Panel_width = itemPanelSz.width
    HeroBestRing_Look._Panel_height = itemPanelSz.height

    GUI:setSwallowTouches(HeroBestRing_Look._ui.Panel_touch, false)

    self:InitUI()
    self:RefreshEquipList()
end

function HeroBestRingLayer:InitHideIconPos()
    self._hideIconPos = {}
    for i, v in ipairs(HeroBestRing_Look.posSetting or {}) do
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
    global.mouseEventController:registerMouseButtonEvent(HeroBestRing_Look._ui.Panel_touch,
    {
        down_r = setNoswallowMouse,
        special_r = addItemIntoBag
    }
    )
end

function HeroBestRingLayer:RefreshEquipList()
    local panelItems = HeroBestRing_Look._ui.Panel_items
    local posSetting = HeroBestRing_Look.posSetting

    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)

    for index, pos in ipairs(posSetting) do
        local equipPanel = GUI:getChildByName(panelItems, "Node_" .. pos)
        GUI:removeAllChildren(equipPanel)
        local data = SL:GetMetaValue("L.M.EQUIP_DATA", pos)
        local icon = GUI:getChildByName(panelItems, "Image_tag" .. pos)
        if not self._hideIconPos[pos]  then
            if  HeroBestRing_Look._HideDefaultIcon and HeroBestRing_Look._HideDefaultIcon[index] then 
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
            info.movable = false
            info.noMouseTips = true
            info.showModelEffect = true
            info.from = ItemMoveProxy.ItemFrom.BEST_RINGS
            info.lookPlayer = true
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

            goodItem = HeroBestRing_Look.CreateEquipItemCallBack(goodItem, info)
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

function HeroBestRingLayer:GetItemBagEmptyPos(touchPos)
    local x = touchPos.x
    local y = touchPos.y
    local panelWorldPos = HeroBestRing_Look._ui.Panel_touch:getWorldPosition()
    local posXInPanel = x - panelWorldPos.x
    local posYInPanel = panelWorldPos.y - y
    if posXInPanel >= HeroBestRing_Look._Panel_width or posXInPanel <= 0 then
        return nil
    end

    if posYInPanel >= HeroBestRing_Look._Panel_height or posYInPanel <= 0 then
        return nil
    end

    -- 生肖装备位GM可以进行调整
    local retPos = nil
    local panelItems = HeroBestRing_Look._ui.Panel_items
    local nodeRect = cc.rect(0, 0, global.MMO.BEST_RING_ITEM_WIDTH, global.MMO.BEST_RING_ITEM_HEIGHT)
    local inPanelPos = { x = posXInPanel, y = posYInPanel }
    for i, pos in ipairs(HeroBestRing_Look.posSetting or {}) do
        local equipPanel = panelItems:getChildByName("Node_" .. pos)
        if equipPanel then
            nodeRect.x = equipPanel:getPositionX() - global.MMO.BEST_RING_ITEM_WIDTH / 2
            nodeRect.y = HeroBestRing_Look._Panel_height - equipPanel:getPositionY() - global.MMO.BEST_RING_ITEM_HEIGHT / 2
            if inPanelPos.x >= nodeRect.x and inPanelPos.x <= nodeRect.x + nodeRect.width
            and inPanelPos.y >= nodeRect.y and inPanelPos.y <= nodeRect.y + nodeRect.height then
                retPos = pos
                break
            end
        end
    end
    return retPos
end

function HeroBestRingLayer:RefreshAddTouchSize()
    if HeroBestRing_Look._ui.Panel_touch and not tolua.isnull(HeroBestRing_Look._ui.Panel_touch) then
        local itemPanelSz = HeroBestRing_Look._ui.Panel_touch:getContentSize()
        HeroBestRing_Look._Panel_width = itemPanelSz.width
        HeroBestRing_Look._Panel_height = itemPanelSz.height
    end
end

return HeroBestRingLayer