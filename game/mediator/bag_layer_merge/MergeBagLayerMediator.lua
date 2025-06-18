local BaseUIMediator = requireMediator("BaseUIMediator")
local MergeBagLayerMediator = class('MergeBagLayerMediator', BaseUIMediator)
MergeBagLayerMediator.NAME = "MergeBagLayerMediator"

function MergeBagLayerMediator:ctor()
    MergeBagLayerMediator.super.ctor(self)
end

function MergeBagLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Bag_Open,
        noticeTable.Layer_HeroBag_Open,
        noticeTable.Layer_Bag_Close,
        noticeTable.Layer_HeroBag_Close,
        noticeTable.Layer_Bag_ResetPos,
        noticeTable.Bag_Oper_Data,
        noticeTable.HeroBag_Oper_Data,
        noticeTable.Bag_Item_Pos_Change,
        noticeTable.HeroBag_Item_Pos_Change,
        noticeTable.Item_Move_begin_On_BagPosChang,
        noticeTable.Item_Move_begin_On_HeroBagPosChang,
        noticeTable.Bag_State_Change,
        noticeTable.HeroBag_State_Change,
        noticeTable.PlayEquip_Oper_Data,
        noticeTable.PlayEquip_Oper_Data_Hero,
        noticeTable.Bag_Pos_Reset,
        noticeTable.HeroBag_Pos_Reset,
        noticeTable.HeroBagCountChnage,
        noticeTable.Equip_Retrieve_State,
        noticeTable.Bag_Item_Collimator,
        noticeTable.Layer_StallLayer_SelfItemChange,
        noticeTable.Layer_Hero_Logout,
        noticeTable.Bag_Size_Change,
    }
end

function MergeBagLayerMediator:handleNotification(notification)
    local noticeName = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData = notification:getBody()
    if noticeTable.Layer_Bag_Open == noticeName then
        if IsForbidOpenBagOrEquip() then
            return
        end
        self:OpenLayer(noticeData, 1)

    elseif noticeTable.Layer_HeroBag_Open == noticeName then
        self:OpenLayer(noticeData, 2)

    elseif noticeTable.Layer_Bag_Close == noticeName or noticeTable.Layer_HeroBag_Close == noticeName then
        self:CloseLayer()

    elseif noticeTable.Layer_Bag_ResetPos == noticeName then
        self:ResetLayerPos(noticeData)

    elseif noticeTable.Bag_Oper_Data == noticeName then
        self:BagOper(noticeData, 1)

    elseif noticeTable.HeroBag_Oper_Data == noticeName then
        self:BagOper(noticeData, 2)

    elseif noticeTable.Bag_Item_Pos_Change == noticeName then
        self:RefreshBagData(noticeData, 1)

    elseif noticeTable.HeroBag_Item_Pos_Change == noticeName then
        self:RefreshBagData(noticeData, 2)

    elseif noticeTable.Item_Move_begin_On_BagPosChang == noticeName then
        self:BeginMove(noticeData, 1)

    elseif noticeTable.Item_Move_begin_On_HeroBagPosChang == noticeName then
        self:BeginMove(noticeData, 2)

    elseif noticeTable.Bag_State_Change == noticeName then
        self:UpdateBagState(noticeData, 1)

    elseif noticeTable.HeroBag_State_Change == noticeName then
        self:UpdateBagState(noticeData, 2)

    elseif noticeTable.PlayEquip_Oper_Data == noticeName then
        self:UpdateItemPowerCheckState(1)

    elseif noticeTable.PlayEquip_Oper_Data_Hero == noticeName then
        self:UpdateItemPowerCheckState(2)

    elseif noticeTable.Bag_Pos_Reset == noticeName or noticeTable.Bag_Size_Change == noticeName then
        self:ResetAndUpdateItemList(1)

    elseif noticeTable.HeroBag_Pos_Reset == noticeName or noticeTable.HeroBagCountChnage == noticeName then
        self:ResetAndUpdateItemList(2)

    elseif noticeTable.Equip_Retrieve_State == noticeName then
        self:UpdateEquipRetrieveState()

    elseif noticeTable.Bag_Item_Collimator == noticeName then
        self:OnBagItemCollimator(noticeData)

    elseif noticeTable.Layer_StallLayer_SelfItemChange == noticeName then
        self:OnRemoveBaiTanTag(noticeData)

    elseif noticeTable.Layer_Hero_Logout == noticeName then
        self:HeroOut(noticeData)        
    end
end

function MergeBagLayerMediator:OpenLayer(data, showtype)
    local pos = nil
    local bagPage = nil
    if data and data.pos and next(data.pos) then
        pos = data.pos
    end
    if data and data.bag_page then
        bagPage = data.bag_page
    end
    if not (self._layer) then
        if showtype == 2 then
            local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
            if not HeroPropertyProxy:HeroIsLogin() then  -- 没召唤
                ShowSystemTips(GET_STRING(600000209))
                return
            end
        end

        self._layer = requireLayerUI("bag_layer_merge/MergeBagLayer").create()
        self._type = global.UIZ.UI_NORMAL
        self._escClose = true
        self._resetPostion = pos
        self._GUI_ID = SLDefine.LAYERID.MergeBagLayerGUI

        MergeBagLayerMediator.super.OpenLayer(self)
        self._layer:InitGUI({showtype = showtype, bag_page = data and data.bag_page})

        LoadLayerCUIConfig(global.CUIKeyTable.BAG_MERGE, self._layer)
        self._layer:InitAfterCUILoad()

        -- 自定义组件挂接
        local componentData = {
            root = self._layer.panel,
            index = global.SUIComponentTable.Bag
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

        local bagPageBtns = MergeBag._bagPageBtns
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
        
        if showtype == 1 then
            global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Load_Success)
        else 
            global.Facade:sendNotification(global.NoticeTable.Layer_HeroBag_Load_Success)
        end
    elseif pos or bagPage then
        if pos then
            self:ResetLayerPos(pos)
        end
        if bagPage then
            if showtype ~= self._layer:getShowType() then
                self._layer:setShowType(showtype)
            end
            self._layer:ChangeBagPageEvent(bagPage)
        end

    else
        if showtype == self._layer:getShowType() then
            global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Close)
            global.Facade:sendNotification(global.NoticeTable.Layer_HeroBag_Close)
        else
            self._layer:setShowType(showtype)
        end
    end
end

function MergeBagLayerMediator:CloseLayer()
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

    if self._layer then
        self._layer:OnClose()
        ssr.ssrBridge:OnCloseBag()
    end

    MergeBagLayerMediator.super.CloseLayer(self)
end

function MergeBagLayerMediator:ResetLayerPos(pos)
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

function MergeBagLayerMediator:BagOper(data, showtype)
    if self._layer then
        if self._layer:getShowType() == showtype then
            self._layer:ItemDataChange(data, data.isBaitan)
        end
    end
end

function MergeBagLayerMediator:RefreshBagData(data, showtype)
    if self._layer then
        if showtype == self._layer:getShowType() then
            if data then
                self._layer:ItemPosChange(data)
            else
                self._layer:updateItemsList()
            end
        end
    end
end

function MergeBagLayerMediator:BeginMove(data, showtype)
    if self._layer then
        if showtype == self._layer:getShowType() then
            self._layer:BeginMove(data.MakeIndex, data.pos)
        end
    end
end

function MergeBagLayerMediator:UpdateBagState(data, showtype)
    if self._layer then
        if showtype == self._layer:getShowType() then
            self._layer:UpdateBagState(data)
        end
    end
end

function MergeBagLayerMediator:UpdateItemPowerCheckState(showtype)
    if self._layer then
        if showtype == self._layer:getShowType() then
            self._layer:UpdateItemPowerCheckState()
        end
    end
end

function MergeBagLayerMediator:ResetAndUpdateItemList(showtype)
    if self._layer then
        if showtype == self._layer:getShowType() then
            self._layer:updateItems()
        end
    end
end

function MergeBagLayerMediator:UpdateEquipRetrieveState()
    if self._layer then
        self._layer:UpdateEquipRetrieveState()
    end
end

function MergeBagLayerMediator:OnBagItemCollimator(data)
    if self._layer then
        self._layer:OnBagItemCollimator(data)
    end
end

function MergeBagLayerMediator:OnRemoveBaiTanTag(data)
    if self._layer then
        self._layer:OnRemoveBaiTanTag(data)
    end
end

function MergeBagLayerMediator:HeroOut()
    if self._layer then
        if self._layer:getShowType() == 2 then
            self._layer:setShowType(1)
        end
    end
end

return MergeBagLayerMediator