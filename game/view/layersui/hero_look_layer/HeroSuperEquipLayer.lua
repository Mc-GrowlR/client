local BaseLayer = requireLayerUI("BaseLayer")
local HeroSuperEquipLayer = class("HeroSuperEquipLayer", BaseLayer)

function HeroSuperEquipLayer:ctor()
    HeroSuperEquipLayer.super.ctor(self)
end

function HeroSuperEquipLayer.create(...)
    local ui = HeroSuperEquipLayer.new()
    if ui and ui:Init(...) then
        return ui
    end

    return nil
end
function HeroSuperEquipLayer:Init(data)
    return true
end

function HeroSuperEquipLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_HERO_LOOK_SUPER_EQUIP)
    HeroSuperEquip_Look.main(data)
    self._root = HeroSuperEquip_Look._ui.Panel_1

    self:InitEquipLayerEvent()
    self:InitEquipLayer()
end

function HeroSuperEquipLayer:RefreshInitPos( ... )
    if HeroSuperEquip_Look.InitHideNodePos then
        HeroSuperEquip_Look.InitHideNodePos()
    end
end

function HeroSuperEquipLayer:InitEquipLayerEvent()
    local posSetting = HeroSuperEquip_Look.posSetting
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
        local equipPanel = HeroSuperEquip_Look._ui["Panel_pos" .. pos]
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
            local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
            --不在道具移动
            local itemData = GetEquipDataByPos(pos, true)
            if not itemData or equipPanel._movingState then
                return
            end
            local panelPos = equipPanel:getWorldPosition()
            local data = {}
            data.itemData = itemData[1]
            local panelPos = equipPanel:getWorldPosition()
            panelPos.x = panelPos.x + 20
            panelPos.y = panelPos.y - 25
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
            data.from = ItemMoveProxy.ItemFrom.HERO_EQUIP
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
                                equipPanel._clickDelayHandler = PerformWithDelayGlobal(
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
function HeroSuperEquipLayer:InitEquipLayer()
    local LookPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.LookPlayerProxy)
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local equipDataByPos = LookPlayerProxy:GetLookPlayerItemPosData()
    for pos, data in pairs(equipDataByPos) do
        local equipPanel = HeroSuperEquip_Look._ui["Panel_pos" .. pos]
        if equipPanel then
            local itemNode = HeroSuperEquip_Look._ui["Node_" .. pos]
            if itemNode then
                itemNode:removeAllChildren()
            end
            if EquipProxy:IsShowEquipItems(pos) then
                local item = LookPlayerProxy:GetLookPlayerItemDataByMakeIndex(data.MakeIndex)
                if item then
                    local equipItems = self:CreateEquipItem(item)
                    if equipItems then
                        itemNode:addChild(equipItems)
                    end
                end
            end
        end
    end
    self:UpdatePlayerView(nil, true)
end



function HeroSuperEquipLayer:UpdatePlayerView(noEquipType, init)
    local modelNode = HeroSuperEquip_Look._ui.Node_playerModel
    modelNode:removeAllChildren()

    local showNakedMold = HeroSuperEquip_Look._show_naked_mold ~= 1
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
    local hairID = HeroSuperEquip_Look.playerHairID
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

    local sex = HeroSuperEquip_Look.playerSex
    local job = HeroSuperEquip_Look.playerJob
    local UiModel = CreateStaticUIModel(sex, modelData, nil, {job = job})
    UiModel = HeroSuperEquip_Look.CreateModelCallBack(UiModel, modelData)
    if UiModel then
        modelNode:addChild(UiModel)
    end

end

function HeroSuperEquipLayer:CreateEquipItem(data)
    if not data or next(data) == nil then
        return nil
    end
    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    local info = {}
    info.itemData = data
    info.index = data.Index
    info.noStars = true
    info.noMouseTips = true
    info.showModelEffect = true
    info.lookPlayer = true
    local goodItem = GoodsItem:create(info)
    goodItem:setPosition(0, 0)
    return HeroSuperEquip_Look.CreateEquipItemCallBack(goodItem, info)
end

function HeroSuperEquipLayer:UpdateEquipLayer(data)

end

function HeroSuperEquipLayer:ResetEquipPanelState(data)
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
    local equipPanel = HeroSuperEquip_Look._ui["Panel_pos" .. pos]
    if not equipPanel then
        return
    end
    local isShowItem = EquipProxy:IsShowEquipItems(pos)
    equipPanel._movingState = not state
    if isShowItem then
        local itemNode = HeroSuperEquip_Look._ui["Node_" .. pos]
        if HeroSuperEquip_Look._hideNodePos[pos] then
            itemNode:setVisible(false)
        else
            itemNode:setVisible(state)
        end
        itemNode:removeAllChildren()
        local item = EquipProxy:GetEquipDataByMakeIndex(data.MakeIndex)
        local equipItems = self:CreateEquipItem(item)
        if equipItems then
            itemNode:addChild(equipItems)
        end
    else
        self:UpdatePlayerView()
    end
end

function HeroSuperEquipLayer:UpdateEquipSettingShowSUI()
    HeroSuperEquip_Look._ui.Text_shizhuang:setVisible(false)
    HeroSuperEquip_Look._ui.CheckBox_shizhuang:setVisible(false)
end

return HeroSuperEquipLayer