local BaseUIMediator = requireMediator("BaseUIMediator")
local BagLayerMediator = class('BagLayerMediator', BaseUIMediator)
BagLayerMediator.NAME = "BagLayerMediator"

function BagLayerMediator:ctor()
    BagLayerMediator.super.ctor(self)
end

function BagLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Bag_Open,
        noticeTable.Layer_Bag_Close,
        noticeTable.Layer_Bag_ResetPos,
        noticeTable.Bag_Oper_Data,
        noticeTable.Bag_Item_Pos_Change,
        noticeTable.Bag_State_Change,
        noticeTable.Bag_Pos_Reset,
        noticeTable.PlayEquip_Oper_Data,
        noticeTable.Equip_Retrieve_State,
        noticeTable.Bag_Item_Collimator,
        noticeTable.Bag_Item_Choose_State,
        noticeTable.Item_Move_begin_On_BagPosChang,
        noticeTable.Item_Move_cancel_On_BagPosChang,
        noticeTable.Layer_StallLayer_SelfItemChange,
        noticeTable.Bag_Size_Change,
    }
end

function BagLayerMediator:handleNotification(notification)
    local noticeName = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData = notification:getBody()

    if noticeTable.Layer_Bag_Open == noticeName then
        if IsForbidOpenBagOrEquip() then
            return
        end
        self:OpenLayer(noticeData)

    elseif noticeTable.Layer_Bag_Close == noticeName then
        self:CloseLayer()

    elseif noticeTable.Layer_Bag_ResetPos == noticeName then
        self:ResetLayerPos(noticeData)

    elseif noticeTable.Bag_Oper_Data == noticeName then
        self:BagOper(noticeData)

    elseif noticeTable.Bag_Item_Pos_Change == noticeName then
        self:RefreshBagData(noticeData)

    elseif noticeTable.Bag_State_Change == noticeName then
        self:UpdateBagState(noticeData)

    elseif noticeTable.Bag_Pos_Reset == noticeName or noticeTable.Bag_Size_Change == noticeName then
        self:ResetBag()

    elseif noticeTable.PlayEquip_Oper_Data == noticeName then
        self:UpdateItemPowerCheckState(noticeData)

    elseif noticeTable.Equip_Retrieve_State == noticeName then
        self:UpdateEquipRetrieveState()

    elseif noticeTable.Bag_Item_Collimator == noticeName then
        self:OnBatItemCollimator(noticeData)

    elseif noticeTable.Bag_Item_Choose_State == noticeName then    
        self:UpdateBagItemChooseState(noticeData)

    elseif noticeTable.Item_Move_begin_On_BagPosChang == noticeName then
        self:BeginMove(noticeData)

    elseif noticeTable.Item_Move_cancel_On_BagPosChang == noticeName then
        self:CancelMoveBagItem(noticeData)
    
    elseif noticeTable.Layer_StallLayer_SelfItemChange == noticeName then
        self:OnRemoveBaiTanTag(noticeData)
    end
end

function BagLayerMediator:OpenLayer(data)
    local pos = nil
    local bagPage = nil
    if data and data.pos and next(data.pos) then
        pos = data.pos
    end
    if data and data.bag_page then
        bagPage = data.bag_page
    end
    if not self._layer then
        self._layer        = requireLayerUI("bag_layer/BagLayer").create(data)
        self._type         = global.UIZ.UI_NORMAL
        self._escClose     = true
        self._resetPostion = pos
        self._GUI_ID       = SLDefine.LAYERID.BagLayerGUI

        BagLayerMediator.super.OpenLayer(self)
        self._layer:InitGUI(data)

        LoadLayerCUIConfig(global.CUIKeyTable.BAG, self._layer)
        self._layer:InitAfterCUILoad()

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._quickUI.Panel_1,
            index = global.SUIComponentTable.Bag
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
        
        local bagPageBtns = Bag._bagPageBtns
        if bagPageBtns and next(bagPageBtns) then
            for index, btn in ipairs(bagPageBtns) do
                if index > 4 then
                    break
                end
                if btn and not tolua.isnull(btn) then
                    local componentData = {
                        root = btn,
                        index = global.SUIComponentTable.BagPageBtn1 + index - 1
                    }
                    global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
                end
            end
        end

    elseif pos or bagPage then
        if pos then
            self:ResetLayerPos(pos)
        end
        if bagPage then
            self._layer:ChangeBagPageEvent(bagPage)
        end

    else
        global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Close)
    end
end

function BagLayerMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = {
        index = global.SUIComponentTable.Bag
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    if self._layer and self._layer._bagPageBtn and next(self._layer._bagPageBtn) then
        for index, btn in ipairs(self._layer._bagPageBtn) do
            if index > 4 then
                break
            end
            local componentData = {
                index = global.SUIComponentTable.BagPageBtn1 + index - 1
            }
            global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)
        end
    end
    -- 自定义组件挂接
    if self._layer then
        self._layer:OnClose()
        ssr.ssrBridge:OnCloseBag()
    end

    BagLayerMediator.super.CloseLayer(self)
end

function BagLayerMediator:ResetLayerPos(pos)
    if self._layer then
        local posX = pos.x
        local posY = pos.y
        local Panel_1 = self._layer._quickUI.Panel_1
        if Panel_1 then
            local x = Panel_1:getPositionX()
            local y = Panel_1:getPositionY()
            local visibleSize = global.Director:getVisibleSize()
            local panelSize = Panel_1:getContentSize()
            local anchorP = Panel_1:getAnchorPoint()
            local outX = nil
            local outY = nil
            if x + posX + (1 - anchorP.x) * panelSize.width > visibleSize.width then
                outX = x + posX + (1 - anchorP.x) * panelSize.width - visibleSize.width
            end
            if y + posY + (1 - anchorP.y) * panelSize.height > visibleSize.height then
                outY =  y + posY + (1 - anchorP.y) * panelSize.height - visibleSize.height
            end

            posX = posX - (outX or 0)
            posY = posY - (outY or 0)
        end
        self._layer:setPosition(posX, posY)
        self:setSavedPosition(posX, posY)
        global.Facade:sendNotification(global.NoticeTable.GuideLayerResetPos)
    end
end

-- 整理背包
function BagLayerMediator:ResetBag()
    if self._layer then
        self._layer:updateItems()
    end
end

function BagLayerMediator:BagOper(data)
    if self._layer then
        self._layer:ItemDataChange(data, data.isBaitan)
    end
end

function BagLayerMediator:RefreshBagData(data)
    if self._layer then
        if data then
            self._layer:ItemPosChange(data)
        else
            self._layer:updateItemsList()
        end
    end
end

function BagLayerMediator:BeginMove(data)
    if self._layer then
        self._layer:BeginMove(data.MakeIndex, data.pos)
    end
end

function BagLayerMediator:CancelMoveBagItem(data)
    if self._layer then
        self._layer:CancelMoveBagItem(data)
    end
end

function BagLayerMediator:UpdateBagState(data)
    if self._layer then
        self._layer:UpdateBagState(data)
    end
end

function BagLayerMediator:UpdateItemPowerCheckState(data)
    if self._layer then
        self._layer:UpdateItemPowerCheckState(data)
    end
end

function BagLayerMediator:UpdateEquipRetrieveState()
    if self._layer then
        self._layer:UpdateEquipRetrieveState()
    end
end

function BagLayerMediator:UpdateBagItemChooseState(data)
    if self._layer then
        self._layer:UpdateBagItemChooseState(data)
    end
end

function BagLayerMediator:OnBatItemCollimator(data)
    if self._layer then
        self._layer:OnBatItemCollimator(data)
    end
end

function BagLayerMediator:OnRemoveBaiTanTag(data)
    if self._layer then
        self._layer:OnRemoveBaiTanTag(data)
    end
end

return BagLayerMediator