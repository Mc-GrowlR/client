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
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_LOOK_SUPER_EQUIP)
    PlayerSuperEquip_Look.main(data)
    self._root = PlayerSuperEquip_Look._ui.Panel_1

    self:InitEquipLayerEvent()
    self:InitEquipLayer()
end

function PlayerSuperEquipLayer:RefreshInitPos( ... )
    if PlayerSuperEquip_Look.InitHideNodePos then
        PlayerSuperEquip_Look.InitHideNodePos()
    end
end

function PlayerSuperEquipLayer:InitEquipLayerEvent()
    local posSetting = PlayerSuperEquip_Look.posSetting
    local function GetEquipDataByPos(equipPos, equipList)
        local equipItems = nil
        local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
        if equipList then
            equipItems = LookPlayerProxy:GetLookPlayerItemDataList(equipPos)
        else
            equipItems = LookPlayerProxy:GetLookPlayerItemDataByPos(equipPos, true)
        end
        return equipItems
    end

    for _, pos in pairs(posSetting) do
        local equipPanel = PlayerSuperEquip_Look._ui["Panel_pos" .. pos]
        local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
        equipPanel:setVisible(EquipProxy:CheckEquipCondition( pos,true))
        local itemMoveState = {
            begin = 1,
            moving = 2,
            end_move = 3,
        }

        local function doubleEventCallBack()
        end

        local function clickEventCallBack(panel, eventtype)
            if tolua.isnull(equipPanel) then
                return
            end
            local equipPos = pos
            if PlayerSuperEquip_Look.fictionalUIPos[pos] then 
                equipPos = PlayerSuperEquip_Look.fictionalUIPos[pos]
            end 
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            --不在道具移动
            local itemData = GetEquipDataByPos(equipPos, true)
            if not itemData or equipPanel._movingState then
                return
            end
            local panelPos = equipPanel:getWorldPosition()
            local data = {}
            data.itemData = itemData[1]
            data.pos = panelPos
            if #itemData == 2 then
                data.itemData = itemData[2]
                data.itemData2 = itemData[1]
            elseif #itemData == 3 then
                data.itemData = itemData[3]
                data.itemData2 = itemData[2]
                data.itemData3 = itemData[1]
            end
            data.lookPlayer = true
            data.from = ItemMoveProxy.ItemFrom.PALYER_EQUIP
            global.Facade:sendNotification(global.NoticeTable.Layer_ItemTips_Open, data)
        end

        local pressEventCallBack = clickEventCallBack

        local isEventPress = false
        local isMoved = true
        local isMoveNode = false
        local clickTimes = 0
        local hasEventCallOnTouchBegin = false        --只有在响应了touchbegin 时才会去响应延时方法 因为在延时后 鼠标事件的 状态已经被置掉

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
            if eventType == 0 then
                isEventPress = false
                isMoved = false
                isMoveNode = false
                hasEventCallOnTouchBegin = true

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
                    if not isEventPress then
                        -- 判断是否有双击事件
                        if doubleEventCallBack then
                            -- 记录上一次点击时间
                            if not equipPanel._lastClickTime then
                                equipPanel._lastClickTime = true
                                -- 记录单击触发
                                -- 记录进入此处时的状态，避免在延时操作后状态被改变
                                local stateOnbegin = hasEventCallOnTouchBegin
                                equipPanel._clickDelayHandler =                                 PerformWithDelayGlobal(
                                function()
                                    if clickEventCallBack and stateOnbegin then
                                        clickEventCallBack(equipPanel, eventType)
                                    end

                                    equipPanel._lastClickTime = nil
                                end,
                                global.MMO.CLICK_DOUBLE_TIME
                                )
                            else
                                if equipPanel._clickDelayHandler then
                                    UnSchedule(equipPanel._clickDelayHandler)
                                    equipPanel._clickDelayHandler = nil
                                end

                                if doubleEventCallBack then
                                    doubleEventCallBack()
                                end

                                equipPanel._lastClickTime = nil
                            end
                        else
                            if clickEventCallBack then
                                clickEventCallBack(equipPanel, eventType)
                            end
                        end
                    end
                end
                hasEventCallOnTouchBegin = false
            elseif eventType == 3 then
                hasEventCallOnTouchBegin = false
            end
        end
        equipPanel:addTouchEventListener(touchEvent)
    end
end

--[[    readme:
    由于道具拖动的原因
    逻辑规则 做统一处理
    所有的 以panel作为基础 响应拖动 响应拖入 （除武器衣服头以外  原来以goodsitem做响应 现在不用）
]]
function PlayerSuperEquipLayer:InitEquipLayer()
    local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local equipDataByPos = LookPlayerProxy:GetLookPlayerItemPosData()
    for pos, data in pairs(equipDataByPos) do
        local equipPanel = PlayerSuperEquip_Look._ui["Panel_pos" .. pos]
        if equipPanel then
            local itemNode = PlayerSuperEquip_Look._ui["Node_" .. pos]
            if itemNode then
                itemNode:removeAllChildren()
            end
            
            if  EquipProxy:IsShowEquipItems(pos)  then
                local item = LookPlayerProxy:GetLookPlayerItemDataByMakeIndex(data.MakeIndex)
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
    local modelNode = PlayerSuperEquip_Look._ui.Node_playerModel
    modelNode:removeAllChildren()

    local showNakedMold = PlayerSuperEquip_Look._show_naked_mold ~= 1
    local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local equipDataByPos = LookPlayerProxy:GetLookPlayerItemPosData()
    local equipTypeConfig = EquipProxy:GetEquipTypeConfig()

    noEquipType = noEquipType or {}

    local function GetLooks(equipType, need)
        local show = {
            look = nil,
            effect = nil
        }

        -- 分离了  UIMode就不显示
        if PlayerSuperEquip_Look.realUIPos and PlayerSuperEquip_Look.realUIPos[equipType] then
            return show
        end

        if not need and equipType and equipDataByPos[equipType] then
            local MakeIndex = equipDataByPos[equipType].MakeIndex
            --移动中处理
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            local movingData = ItemMoveProxy:GetMovingItemData()
            if init and movingData and MakeIndex == movingData.MakeIndex then
                return show
            end
            local equipData = LookPlayerProxy:GetLookPlayerItemDataByMakeIndex(MakeIndex)
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
    local hairID = PlayerSuperEquip_Look.playerHairID
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

    local sex = PlayerSuperEquip_Look.playerSex
    local job = PlayerSuperEquip_Look.playerJob
    local UiModel = CreateStaticUIModel(sex, modelData, nil, {job = job})
    UiModel = PlayerSuperEquip_Look.CreateModelCallBack(UiModel, modelData)
    if UiModel then
        modelNode:addChild(UiModel)
    end

end

function PlayerSuperEquipLayer:CreateEquipItem(data, uiPos)
    -- 剑甲分离装备框不显示内观特效
    local function checkPos(uiPos)
        if PlayerSuperEquip_Look.fictionalUIPos and PlayerSuperEquip_Look.fictionalUIPos[uiPos] then 
            local pos = PlayerSuperEquip_Look.fictionalUIPos[uiPos]
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
    info.lookPlayer = true
    local goodItem = GoodsItem:create(info)
    goodItem:setPosition(0, 0)
    return PlayerSuperEquip_Look.CreateEquipItemCallBack(goodItem, info)
end

function PlayerSuperEquipLayer:UpdateEquipLayer(data)

end

function PlayerSuperEquipLayer:UpdateEquipSettingShowSUI()
    PlayerSuperEquip_Look._ui.Text_shizhuang:setVisible(false)
    PlayerSuperEquip_Look._ui.CheckBox_shizhuang:setVisible(false)
end

function PlayerSuperEquipLayer:showEquipItemsUI( pos )
    if not pos then 
        return 
    end 

    if not PlayerSuperEquip_Look.realUIPos or not PlayerSuperEquip_Look.realUIPos[pos] then 
        return 
    end 

    local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
    local data = LookPlayerProxy:GetLookPlayerItemDataByPos(pos)
    if not data then 
        return 
    end 

    local UIPos = PlayerSuperEquip_Look.realUIPos[pos]

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

    if not PlayerSuperEquip_Look.realUIPos or not PlayerSuperEquip_Look.realUIPos[pos] then 
        return 
    end 

    local UIPos = PlayerSuperEquip_Look.realUIPos[pos] 

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