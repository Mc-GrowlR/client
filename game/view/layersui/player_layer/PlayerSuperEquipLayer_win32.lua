local BaseLayer = requireLayerUI("BaseLayer")
local PlayerSuperEquipLayer = class("PlayerSuperEquipLayer", BaseLayer)

function PlayerSuperEquipLayer:ctor()
    PlayerSuperEquipLayer.super.ctor(self)
end

function PlayerSuperEquipLayer.create(...)
    local ui = PlayerSuperEquipLayer.new()
    if ui and ui:Init(...) then
        return ui
    end

    return nil
end

function PlayerSuperEquipLayer:Init(data)
    self._ui = ui_delegate(self)
    return true
end

function PlayerSuperEquipLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_SUPER_EQUIP_WIN32)
    PlayerSuperEquip.main(data)
    self._root = self._ui.Panel_1

    self:InitEquipLayerEvent()
    self:InitEquipLayer()
    refPositionByParent(self)

    self:InitEditMode()
end

function PlayerSuperEquipLayer:InitEditMode()
    for _,v in ipairs(PlayerSuperEquip.posSetting or {}) do
        if self._ui["Panel_pos"..v] then
            if v ~= 17 and v ~= 18 and v ~= 45 and v ~= 21 then
                local bg = self._ui["Panel_pos"..v]:getChildByName("Image_bg")
                if bg then
                    bg.editMode = 1
                end
                local icon = self._ui["Panel_pos"..v]:getChildByName("Image_icon")
                if icon then
                    icon.editMode = 1
                end
                self._ui["Node_"..v].editMode = 1
            end
            self._ui["Panel_pos"..v].editMode = 1
        end
    end

    local items = {
        "Text_shizhuang",
        "Text_guildinfo",
        "Node_playerModel",
        "CheckBox_shizhuang",
        "Image_equippanel",
    }
    for _, widgetName in ipairs(items) do
        if self._ui[widgetName] then
            self._ui[widgetName].editMode = 1
        end
    end
end

function PlayerSuperEquipLayer:RefreshInitPos( ... )
    if PlayerSuperEquip.InitHideNodePos then
        PlayerSuperEquip.InitHideNodePos()
    end
end

function PlayerSuperEquipLayer:InitEquipLayerEvent()
    local posSetting = PlayerSuperEquip.posSetting
    local function GetEquipDataByPos(equipPos, equipList)
        local equipItems = nil
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        if equipList then
            equipItems = EquipProxy:GetEquipDataPosDataList(equipPos)
        else
            equipItems = EquipProxy:GetEquipDataByPos(equipPos, true)
        end
        return equipItems
    end

    local function UnScheduler()
        if self._delayFunc then
            global.Director:getActionManager():removeAction(self._delayFunc)
            self._delayFunc = nil
        end
    end

    for _, pos in pairs(posSetting) do
        local equipPanel = self._ui["Panel_pos" .. pos]
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        equipPanel:setVisible(EquipProxy:CheckEquipCondition( pos,false))
        local function mouseMoveCallBack()
            local uiPos = pos
            if PlayerSuperEquip.fictionalUIPos[uiPos] then 
                uiPos = PlayerSuperEquip.fictionalUIPos[uiPos]
                local data = EquipProxy:FindEquipDataByPos(uiPos)
                if not data then 
                    return
                end 
            end 

            local itemData = GetEquipDataByPos(uiPos, true)
            if itemData then
                local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
                local movingData = ItemMoveProxy:GetMovingItemData()
                if movingData then
                    return
                end
                local tipsData = {}
                tipsData.itemData = itemData[1]
                tipsData.pos = equipPanel:getWorldPosition()
                if #itemData == 2 then
                    tipsData.itemData = itemData[2]
                    tipsData.itemData2 = itemData[1]
                elseif #itemData == 3 then
                    tipsData.itemData = itemData[3]
                    tipsData.itemData2 = itemData[2]
                    tipsData.itemData3 = itemData[1]
                end
                tipsData.lookPlayer = false
                tipsData.from = ItemMoveProxy.ItemFrom.PALYER_EQUIP
                global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, tipsData)
            end
            UnScheduler()
        end
        
        local function enterItem()
            if self._delayFunc then
                return false
            end
            self._delayFunc = performWithDelay(equipPanel, function () mouseMoveCallBack() end, global.MMO.PC_TIPS_DELAY_TIME) 
        end 

        local function leaveItem()
            global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)
            UnScheduler()
        end

        global.mouseEventController:registerMouseMoveEvent(
        equipPanel,
        {
            enter = enterItem,
            leave = leaveItem,
            checkIsVisible = true
        }
        )

        equipPanel.RegisterWin32MouseMoveScrollCall = function(sender, data)
            global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Mouse_Scroll, data)
        end

        local itemMoveState = {
            begin = 1,
            moving = 2,
            end_move = 3,
        }

        local function resetMoveState(mySelf, bool, equipWhere)
            if mySelf and not tolua.isnull(mySelf) then
                mySelf._movingState = bool
                local setPos = equipWhere and equipWhere or pos
                local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
                if EquipProxy:IsShowEquipItems(setPos) then
                    local itemNode = self._ui["Node_" .. setPos]
                    if PlayerSuperEquip._hideNodePos[setPos] then
                        itemNode:setVisible(false)
                    else
                        itemNode:setVisible(not bool)
                    end
                else
                    local noEquip = nil
                    if bool then
                        noEquip = {}
                        local equipTypeConfig = EquipProxy:GetEquipTypeConfig()
                        if setPos == equipTypeConfig.Equip_Type_Dress then
                            noEquip.NoDress = true
                        elseif setPos == equipTypeConfig.Equip_Type_Weapon then
                            noEquip.NoWeapon = true
                        elseif setPos == equipTypeConfig.Equip_Type_Helmet then
                            noEquip.NoHelmet = true
                        elseif setPos == equipTypeConfig.Equip_Type_Cap then
                            noEquip.NoCap = true
                        elseif setPos == equipTypeConfig.Equip_Type_Shield then
                            noEquip.NoShield = true
                        elseif setPos == equipTypeConfig.Equip_Type_Super_Weapon then
                            noEquip.NoSuperWeapon = true
                        elseif setPos == equipTypeConfig.Equip_Type_Super_Dress then
                            noEquip.NoSuperDress = true
                        elseif setPos == equipTypeConfig.Equip_Type_Super_Helmet then
                            noEquip.NoSuperHelmet = true
                        elseif setPos == equipTypeConfig.Equip_Type_Super_Cap then
                            noEquip.NoSuperCap = true
                        elseif setPos == equipTypeConfig.Equip_Type_Super_Shield then
                            noEquip.NoSuperShield = true
                        elseif setPos == equipTypeConfig.Equip_Type_Super_Veil then
                            noEquip.NoSuperVeil = true
                        end
                    end
                    self:UpdatePlayerView(noEquip)
                end

                if PlayerSuperEquip.fictionalUIPos[pos] then 
                    local realPos = PlayerSuperEquip.fictionalUIPos[pos]
                    if bool then 
                        self:hideEquipItemsUI(realPos)
                    else 
                        self:showEquipItemsUI(realPos)
                    end 
                    self:UpdatePlayerView()
                end 
            end
        end

        local function SetGoodItemState(state, movePos)
            local equipPos = pos
            local bShare = true -- 是否共享位置 头盔 斗笠 面巾
            if PlayerSuperEquip.fictionalUIPos[pos] then 
                equipPos = PlayerSuperEquip.fictionalUIPos[pos]
                bShare = false
            end 
            local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
            local itemData = EquipProxy:GetEquipDataByPos(equipPos, bShare)
            if not itemData then
                return
            end

            if itemMoveState.begin == state then
                local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
                resetMoveState(equipPanel, true, itemData.Where)
                global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Close)
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Begin, {
                    pos = movePos,
                    itemData = itemData,
                    cancelCallBack = function()
                        resetMoveState(equipPanel, false)
                    end,
                    from = ItemMoveProxy.ItemFrom.PALYER_EQUIP
                })
            elseif itemMoveState.moving == state then

            elseif itemMoveState.end_move == state then
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_End, movePos)
            end
        end

        local function doubleEventCallBack()
            local equipPos = pos
            local bShare = true -- 是否共享位置 头盔 斗笠 面巾
            if PlayerSuperEquip.fictionalUIPos[pos] then 
                equipPos = PlayerSuperEquip.fictionalUIPos[pos]
                bShare = false
            end 
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            local itemMoving = ItemMoveProxy:GetMovingItemState()
            if itemMoving then --在道具移动中
                return
            end
            local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
            local itemData = EquipProxy:GetEquipDataByPos(equipPos, bShare)

            if itemData then
                local takeOffEquipData = {
                    itemData = itemData,
                    pos = itemData.Where
                }
                ItemMoveProxy:TakeOffEquip(takeOffEquipData)
            end
        end

        local function clickEventCallBack(panel, eventtype)
            if tolua.isnull(equipPanel) then
                return
            end
            local equipPos = pos
            if PlayerSuperEquip.fictionalUIPos[pos] then 
                equipPos = PlayerSuperEquip.fictionalUIPos[pos]
                local data = EquipProxy:FindEquipDataByPos(equipPos)
                if not data then 
                    return 
                end 
            end 
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            --不在道具移动
            local itemData = GetEquipDataByPos(equipPos, true)
            if not itemData or equipPanel._movingState then
                return
            end
            local panelPos = equipPanel:getWorldPosition()
            SetGoodItemState(itemMoveState.begin, panelPos)
        end

        local pressEventCallBack = clickEventCallBack

        local isMoved = true
        local isMoveNode = false
        local clickTimes = 0

        local function delayCallback()
            isEventPress = true

            if pressEventCallBack then
                if not pressEventCallBack then
                    return false
                end

                if not isMoved then
                    pressEventCallBack()
                    return false
                end

                local movedPos = equipPanel:getTouchMovePosition()
                local beganPos = equipPanel:getTouchBeganPosition()

                local diff = cc.pSub(movedPos, beganPos)
                local distSq = cc.pLengthSQ(diff)
                if distSq <= 100 then
                    pressEventCallBack()
                end
            end
        end

        local function touchEvent(touch, eventType)
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            local itemMoving = ItemMoveProxy:GetMovingItemState()
            if itemMoving then --在道具移动中
                return
            end
            if eventType == 0 then
                isMoved = false
                isMoveNode = false

                if pressEventCallBack then
                    performWithDelay(equipPanel, delayCallback, global.MMO.CLICK_DOUBLE_TIME)
                end
            elseif eventType == 1 then --移动端
                local movedPos = equipPanel:getTouchMovePosition()
                local beganPos = equipPanel:getTouchBeganPosition()

                local diff = cc.pSub(movedPos, beganPos)
                local distSq = cc.pLengthSQ(diff)
                if not isMoved and distSq > 100 then
                    isMoved = true
                end
            elseif eventType == 2 then
                equipPanel:stopAllActions()
                if not isMoved then
                    clickTimes = clickTimes + 1
                    if clickTimes >= 2 then
                        clickTimes = 0
                        if equipPanel._clickDelayHandler then
                            UnSchedule(equipPanel._clickDelayHandler)
                            equipPanel._clickDelayHandler = nil                            
                        end

                        if doubleEventCallBack then
                            doubleEventCallBack()
                        end
                        return
                    end

                    equipPanel._clickDelayHandler = PerformWithDelayGlobal(
                        function()
                            clickTimes = 0
                        end,
                        global.MMO.CLICK_DOUBLE_TIME
                    )

                    if not isMoveNode and pressEventCallBack then
                        pressEventCallBack(itemMoveState.begin)
                    end
                    isMoveNode = not isMoveNode
                end
            elseif eventType == 3 then
            end
        end
        equipPanel:addTouchEventListener(touchEvent)
        local function addItemIntoEquip(touchPos)
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            local state = ItemMoveProxy:GetMovingItemState()
            if state then
                local goToName = ItemMoveProxy.ItemGoTo.PALYER_EQUIP
                local data = {}
                data.target = goToName
                data.pos = touchPos
                data.equipPos = pos
                ItemMoveProxy:CheckAndCallBack(data)
            else
                return -1
            end
        end

        local function setNoswallowMouse(touchPos)
            --不在道具移动
            local itemData = GetEquipDataByPos(pos)
            if not itemData or equipPanel._movingState then
                return
            end
            local panelPos = equipPanel:getWorldPosition()
            SetGoodItemState(itemMoveState.begin, panelPos)
        end
        global.mouseEventController:registerMouseButtonEvent(
        equipPanel,
        {
            down_r = setNoswallowMouse,
            special_r = addItemIntoEquip,
            checkIsVisible = true
        }
        )
        --移动中处理
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        local itemMoving = ItemMoveProxy:GetMovingItemState()
        local itemMovingData = ItemMoveProxy:GetMovingItemData()
        local itemData = GetEquipDataByPos(pos)
        if itemMoving and itemData and itemMovingData then --在道具移动中
            if itemData.MakeIndex == itemMovingData.MakeIndex then
                resetMoveState(equipPanel, true)
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_UpDate, {
                    cancelCallBack = function()
                        resetMoveState(equipPanel, false)
                    end,
                })
            end
        end
    end
end

--[[    readme:
    由于道具拖动的原因
    逻辑规则 做统一处理
    所有的 以panel作为基础 响应拖动 响应拖入 （除武器衣服头以外  原来以goodsitem做响应 现在不用）
]]
function PlayerSuperEquipLayer:InitEquipLayer()
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local equipDataByPos = EquipProxy:GetEquipPosData()
    for pos, data in pairs(equipDataByPos) do
        local equipPanel = self._ui["Panel_pos" .. pos]
        if equipPanel then
            local itemNode = self._ui["Node_" .. pos]
            if itemNode then
                itemNode:removeAllChildren()
            end
            if EquipProxy:IsShowEquipItems(pos) then
                local item = EquipProxy:GetEquipDataByMakeIndex(data)
                if item then
                    local equipItems = self:CreateEquipItem(item, pos)
                    if equipItems then
                        itemNode:addChild(equipItems)
                    end
                end
            end
        end
        self:showEquipItemsUI(pos)
    end
    self:UpdatePlayerView(nil, true)
end



function PlayerSuperEquipLayer:UpdatePlayerView(noEquipType, init)
    local modelNode = self._ui.Node_playerModel
    modelNode:removeAllChildren()

    local showNakedMold = PlayerSuperEquip._show_naked_mold ~= 1
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local equipDataByPos = EquipProxy:GetEquipPosData()
    local equipTypeConfig = EquipProxy:GetEquipTypeConfig()

    noEquipType = noEquipType or {}

    local function GetLooks(equipType, need)
        local show = {
            look = nil,
            effect = nil
        }

        -- 分离了  UIMode就不显示
        if PlayerSuperEquip.realUIPos and PlayerSuperEquip.realUIPos[equipType] then
            return show
        end

        if not need and equipType and equipDataByPos[equipType] then
            local MakeIndex = equipDataByPos[equipType]
            --移动中处理
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            local movingData = ItemMoveProxy:GetMovingItemData()
            if init and movingData and MakeIndex == movingData.MakeIndex then
                return show
            end
            local equipData = EquipProxy:GetEquipDataByMakeIndex(MakeIndex)
            if equipType == equipTypeConfig.Equip_Type_Super_Dress then
                if showNakedMold and equipData and equipData.shonourSell and tonumber(equipData.shonourSell) == 1 then --xslm==1不显示裸模
                    showNakedMold = false
                end
            end

            if equipData and equipData.Looks then
                show.look = equipData.Looks
            end
            if equipData and equipData.sEffect then
                show.effect = equipData.sEffect
            end
            return show
        end
        return show
    end
    local hairID = SL:GetMetaValue("HAIR")
    local clothShow = GetLooks(equipTypeConfig.Equip_Type_Super_Dress, noEquipType.NoSuperDress)
    local weaponShow = GetLooks(equipTypeConfig.Equip_Type_Super_Weapon, noEquipType.NoSuperWeapon)
    local headShow = GetLooks(equipTypeConfig.Equip_Type_Super_Helmet, noEquipType.NoSuperHelmet)
    local capShow = GetLooks(equipTypeConfig.Equip_Type_Super_Cap, noEquipType.NoSuperCap)
    local shieldShow = GetLooks(equipTypeConfig.Equip_Type_Super_Shield, noEquipType.NoSuperShield)
    local veilShow = GetLooks(equipTypeConfig.Equip_Type_Super_Veil, noEquipType.NoSuperVeil)

    local modelData = {
        clothID = clothShow.look,
        clothEffectID = clothShow.effect,
        weaponID = weaponShow.look,
        weaponEffectID = weaponShow.effect,
        headID = headShow.look,
        headEffectID = headShow.effect,
        hairID = hairID,
        capID = capShow.look,
        capEffectID = capShow.effect,
        veilID = veilShow.look,
        shieldID = shieldShow.look,
        shieldEffectID = shieldShow.effect,
        notShowMold = not showNakedMold,
        notShowHair = not showNakedMold,
    }

    local sex = SL:GetMetaValue("SEX")
    local job = SL:GetMetaValue("JOB")
    local UiModel = CreateStaticUIModel(sex, modelData, nil, {job = job})
    UiModel = PlayerSuperEquip.CreateModelCallBack(UiModel, modelData)
    if UiModel then
        modelNode:addChild(UiModel)
    end

end

function PlayerSuperEquipLayer:CreateEquipItem(data, uiPos)
    -- 剑甲分离装备框不显示内观特效
    local function checkPos(uiPos)
        if PlayerSuperEquip.fictionalUIPos and PlayerSuperEquip.fictionalUIPos[uiPos] then 
            local pos = PlayerSuperEquip.fictionalUIPos[uiPos]
            if pos == GUIDefine.EquipPosUI.Equip_Type_Dress or pos == GUIDefine.EquipPosUI.Equip_Type_Weapon then
                return false
            end
        end
        return true
    end

    if not data or next(data) == nil then
        return nil
    end
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    local info = {}
    info.itemData = data
    info.index = data.Index
    info.noStars = true
    info.noMouseTips = true
    info.showModelEffect = checkPos(uiPos)
    info.from = ItemMoveProxy.ItemFrom.PALYER_EQUIP
    info.lookPlayer = false
    local goodItem = GoodsItem:create(info)
    goodItem:setPosition(0, 0)
    return PlayerSuperEquip.CreateEquipItemCallBack(goodItem, info)
end

function PlayerSuperEquipLayer:UpdateEquipLayer(data)
    if not data or next(data) == nil then
        return
    end
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local operatorType = data.opera
    local MakeIndex = data.MakeIndex
    local pos = data.Where

    local uiPos = pos

    if PlayerSuperEquip.realUIPos[pos] then 
        uiPos = PlayerSuperEquip.realUIPos[pos]
    else 
        local dePos = EquipProxy:GetDeEquipMappingConfig(pos)
        pos = dePos and dePos or pos
        uiPos = pos
    end 
    
    local equipPanel = self._ui["Panel_pos" .. uiPos]
    if not equipPanel or (equipPanel and equipPanel:isVisible() == false) then
        return
    end
    equipPanel._movingState = false

    local itemNode = self._ui["Node_" .. uiPos]
    local isShowItem = EquipProxy:IsShowEquipItems(pos)
    if global.MMO.Operator_Add == operatorType or global.MMO.Operator_Init == operatorType then
        if isShowItem then
            if not PlayerSuperEquip._hideNodePos[pos] then
                itemNode:setVisible(true)
            else
                itemNode:setVisible(false)
            end
            itemNode:removeAllChildren()
            local item = EquipProxy:GetEquipDataByMakeIndex(data.MakeIndex)
            local equipItems = self:CreateEquipItem(item, uiPos)
            if equipItems then
                itemNode:addChild(equipItems)
            end
        else
            self:UpdatePlayerView()
            self:showEquipItemsUI(pos)
        end
    elseif global.MMO.Operator_Sub == operatorType then
        if isShowItem then
            itemNode:removeAllChildren()
        else
            self:UpdatePlayerView()
            self:hideEquipItemsUI(pos)
        end
    elseif global.MMO.Operator_Change == operatorType then
        -- 如果更新的装备不是更新Look  不进行更新内观的刷新
        if not data.isChangeLook then
            return
        end

        if isShowItem then
            if not PlayerSuperEquip._hideNodePos[pos] then
                itemNode:setVisible(true)
            else
                itemNode:setVisible(false)
            end
            local item = EquipProxy:GetEquipDataByMakeIndex(data.MakeIndex)
            local goodsItem = itemNode:getChildren()[1]
            if goodsItem and not tolua.isnull(goodsItem) then
                goodsItem:UpdateGoodsItem(item)
            end
        else
            self:UpdatePlayerView()
        end
    end
end

function PlayerSuperEquipLayer:ResetEquipPanelState(data)
    if not data or next(data) == nil then
        return
    end
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
    local equipPanel = self._ui["Panel_pos" .. pos]
    if not equipPanel then
        return
    end
    local isShowItem = EquipProxy:IsShowEquipItems(pos)
    equipPanel._movingState = not state
    if isShowItem then
        local itemNode = self._ui["Node_" .. pos]
        if PlayerSuperEquip._hideNodePos[pos] then
            itemNode:setVisible(false)
        else
            itemNode:setVisible(state)
        end
        itemNode:removeAllChildren()
        local item = EquipProxy:GetEquipDataByMakeIndex(data.MakeIndex)
        local equipItems = self:CreateEquipItem(item, pos)
        if equipItems then
            itemNode:addChild(equipItems)
        end
    else
        self:UpdatePlayerView()
    end
end

function PlayerSuperEquipLayer:UpdateEquipSettingShowSUI()
end

function PlayerSuperEquipLayer:showEquipItemsUI( pos )
    if not pos then 
        return 
    end 

    if not PlayerSuperEquip.realUIPos or not PlayerSuperEquip.realUIPos[pos] then 
        return 
    end 

    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local data = EquipProxy:GetEquipDataByPos(pos)
    if not data then 
        return 
    end 

    local UIPos = PlayerSuperEquip.realUIPos[pos]

    local itemPanel = self._ui["Panel_pos"..UIPos]
    local bShow = itemPanel:isVisible()
    if not bShow then 
        return 
    end 

    local itemNode = self._ui["Node_"..UIPos]
    if not itemNode then   
        return 
    end 

    GUI:setVisible(itemNode, true)
    itemNode:removeAllChildren()

    local equipItems = self:CreateEquipItem(data, UIPos)
    itemNode:addChild(equipItems)    
end

function PlayerSuperEquipLayer:hideEquipItemsUI( pos )
    if not pos then 
        return 
    end 

    if not PlayerSuperEquip.realUIPos or not PlayerSuperEquip.realUIPos[pos] then 
        return 
    end 

    local UIPos = PlayerSuperEquip.realUIPos[pos] 

    local itemPanel = self._ui["Panel_pos"..UIPos]
    local bShow = itemPanel:isVisible()
    if not bShow then 
        return 
    end 

    local itemNode = self._ui["Node_"..UIPos]
    if not itemNode then   
        return 
    end 

    GUI:setVisible(itemNode, false)
    itemNode:removeAllChildren()   
end

return PlayerSuperEquipLayer