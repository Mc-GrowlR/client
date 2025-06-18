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
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_LOOK_BESTRING_WIN32)
    PlayerBestRing_Look.main(data)
    self._root = PlayerBestRing_Look._ui.Panel_1

    local itemPanelSz = GUI:getContentSize(PlayerBestRing_Look._ui.Panel_touch)
    PlayerBestRing_Look._Panel_width = itemPanelSz.width
    PlayerBestRing_Look._Panel_height = itemPanelSz.height

    GUI:setSwallowTouches(PlayerBestRing_Look._ui.Panel_touch, false)

    self:InitUI()
    self:RefreshEquipList()
    refPositionByParent(self)
end

function PlayerBestRingLayer:InitHideIconPos()
    self._hideIconPos = {}
    for i, v in ipairs(PlayerBestRing_Look.posSetting or {}) do
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
    global.mouseEventController:registerMouseButtonEvent(PlayerBestRing_Look._ui.Panel_touch,
    {
        down_r = setNoswallowMouse,
        special_r = addItemIntoBag
    }
    )
end

function PlayerBestRingLayer:RefreshEquipList()
    local panelItems = PlayerBestRing_Look._ui.Panel_items
    local posSetting = PlayerBestRing_Look.posSetting

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
        local data = SL:GetMetaValue("L.M.EQUIP_DATA", pos)
        local icon = GUI:getChildByName(panelItems, "Image_tag" .. pos)
        if not self._hideIconPos[pos]  then
            if  PlayerBestRing_Look._HideDefaultIcon and PlayerBestRing_Look._HideDefaultIcon[index] then 
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
            local function mouseMoveCallBack()
                if goodItem._movingState then
                    return
                end
                local tipsData = {}
                tipsData.itemData = data
                tipsData.pos = goodItem:getWorldPosition()
                tipsData.lookPlayer = true
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
            goodItem = PlayerBestRing_Look.CreateEquipItemCallBack(goodItem, info)
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

function PlayerBestRingLayer:GetItemBagEmptyPos(touchPos)
    local x = touchPos.x
    local y = touchPos.y
    local panelWorldPos = PlayerBestRing_Look._ui.Panel_touch:getWorldPosition()
    local posXInPanel = x - panelWorldPos.x
    local posYInPanel = panelWorldPos.y - y
    if posXInPanel >= PlayerBestRing_Look._Panel_width or posXInPanel <= 0 then
        return nil
    end

    if posYInPanel >= PlayerBestRing_Look._Panel_height or posYInPanel <= 0 then
        return nil
    end

    -- 生肖装备位GM可以进行调整
    local retPos = nil
    local panelItems = PlayerBestRing_Look._ui.Panel_items
    local nodeRect = cc.rect(0, 0, global.MMO.BEST_RING_ITEM_WIDTH, global.MMO.BEST_RING_ITEM_HEIGHT)
    local inPanelPos = { x = posXInPanel, y = posYInPanel }
    for i, pos in ipairs(PlayerBestRing_Look.posSetting or {}) do
        local equipPanel = panelItems:getChildByName("Node_" .. pos)
        if equipPanel then
            nodeRect.x = equipPanel:getPositionX() - global.MMO.BEST_RING_ITEM_WIDTH / 2
            nodeRect.y = PlayerBestRing_Look._Panel_height - equipPanel:getPositionY() - global.MMO.BEST_RING_ITEM_HEIGHT / 2
            if inPanelPos.x >= nodeRect.x and inPanelPos.x <= nodeRect.x + nodeRect.width
            and inPanelPos.y >= nodeRect.y and inPanelPos.y <= nodeRect.y + nodeRect.height then
                retPos = pos
                break
            end
        end
    end
    return retPos
end


function PlayerBestRingLayer:RefreshAddTouchSize()
    if PlayerBestRing_Look._ui.Panel_touch and not tolua.isnull(PlayerBestRing_Look._ui.Panel_touch) then
        local itemPanelSz = PlayerBestRing_Look._ui.Panel_touch:getContentSize()
        PlayerBestRing_Look._Panel_width = itemPanelSz.width
        PlayerBestRing_Look._Panel_height = itemPanelSz.height
    end
end

return PlayerBestRingLayer