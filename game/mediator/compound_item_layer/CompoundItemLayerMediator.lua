local BaseUIMediator = requireMediator("BaseUIMediator")
local CompoundItemLayerMediator = class('CompoundItemLayerMediator', BaseUIMediator)
CompoundItemLayerMediator.NAME = "CompoundItemLayerMediator"

function CompoundItemLayerMediator:ctor()
    CompoundItemLayerMediator.super.ctor(self)
end

function CompoundItemLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_CompoundItemLayer_Open, 
        noticeTable.Layer_CompoundItemLayer_Close,
        noticeTable.Layer_CompoundItemLayer_Update,
        noticeTable.PlayerMoneyChange, 
        noticeTable.Bag_Oper_Data, 
        noticeTable.PlayEquip_Oper_Data,
        noticeTable.QuickUseItemAdd,
        noticeTable.QuickUseItemRmv,
        noticeTable.QuickUseItemChange,
        noticeTable.QuickUseItemRefresh
    }
end

function CompoundItemLayerMediator:handleNotification(notification)
    local noticeName = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData = notification:getBody()

    if noticeTable.Layer_CompoundItemLayer_Open == noticeName then
        self:OpenLayer(noticeData)

    elseif noticeTable.Layer_CompoundItemLayer_Close == noticeName then
        self:CloseLayer()

    elseif noticeTable.Layer_CompoundItemLayer_Update == noticeName then
        self:UpdateCompoundRedPoint(noticeData)

    elseif noticeTable.PlayerMoneyChange == noticeName then
        self:UpdateMoneyCount(noticeData)

    elseif noticeTable.Bag_Oper_Data == noticeName or noticeTable.PlayEquip_Oper_Data == noticeName then
        self:UpdateItemsCount(noticeData, noticeTable.PlayEquip_Oper_Data == noticeName)

    elseif noticeTable.QuickUseItemAdd == noticeName 
        or noticeTable.QuickUseItemRmv == noticeName
        or noticeTable.QuickUseItemChange == noticeName then
        self:UpdateItemsCountByQuickUse(noticeData, noticeName)
    end
end

function CompoundItemLayerMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer = requireLayerUI("compund_item_layer/CompoundItemLayer").create(data)
        self._type = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.CompoundItemGUI
        CompoundItemLayerMediator.super.OpenLayer(self)

        self._layer:InitGUI(data)

        LoadLayerCUIConfig(global.CUIKeyTable.COMPOUND_ITEMS, self._layer)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer._layout_bg:getChildByName("Panel_show"),
            index = global.SUIComponentTable.ItemCompound
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

function CompoundItemLayerMediator:CloseLayer()
    if not self._layer then
        return false
    end

    -- 自定义组件卸载
    local componentData = {
        index = global.SUIComponentTable.ItemCompound
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
    ItemCompoundProxy:SetOnCompoundIndex()

    CompoundItemLayerMediator.super.CloseLayer(self)
end

function CompoundItemLayerMediator:UpdateCompoundRedPoint(noticeData)
    SL:onLUAEvent(LUA_EVENT_COMPOUND_RED_POINT, noticeData)
end


function CompoundItemLayerMediator:UpdateMoneyCount(data)
    if not data or next(data) == nil then
        return
    end
    local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)
    ItemCompoundProxy:OnMoneyChangeCount(data.id, data.count)
end

function CompoundItemLayerMediator:UpdateItemsCount(data, equip)
    if not data or not next(data) then
        return
    end
    local ItemCompoundProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemCompoundProxy)

    local itemList = data.operID or {}
    if equip then
        itemList = {{
            item = data.ItemData
        }}
    end
    if data.opera == global.MMO.Operator_Init then
        for k, v in pairs(itemList) do
            ItemCompoundProxy:OnItemChange(v.item.Index, true)
        end
    elseif data.opera == global.MMO.Operator_Add then
        for k, v in pairs(itemList) do
            if equip then
                ItemCompoundProxy:OnEquipChange(v.item.Where)
            else
                ItemCompoundProxy:OnItemChange(v.item.Index, true)
            end
        end
    elseif data.opera == global.MMO.Operator_Sub then
        for k, v in pairs(itemList) do
            if equip then
                ItemCompoundProxy:OnEquipChange(v.item.Where)
            else
                ItemCompoundProxy:OnItemChange(v.item.Index, false)
            end
        end
    elseif data.opera == global.MMO.Operator_Change and not equip then
        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
        local Item_Type = ItemManagerProxy:GetItemSettingType()
        for k, v in pairs(itemList) do
            local change = v.change or 0
            if change ~= 0 then
                ItemCompoundProxy:OnItemChange(v.item.Index, change > 0)
            else
                local itemType = ItemManagerProxy:GetItemType(v.item)
                if itemType == Item_Type.Equip then
                    ItemCompoundProxy:OnItemChange(v.item.Index, false)
                end
            end
        end
    end
end

function CompoundItemLayerMediator:UpdateItemsCountByQuickUse(noticeData, noticeName)
    if not noticeData or not next(noticeData) or not noticeData.itemData then
        return
    end
    local noticeTable = global.NoticeTable
    local data = {
        opera = noticeTable.QuickUseItemAdd == noticeName and global.MMO.Operator_Add or global.MMO.Operator_Sub,
        operID = {}
    }
    if noticeTable.QuickUseItemChange == noticeName then
        data.opera = noticeData.isAdd and global.MMO.Operator_Add or global.MMO.Operator_Sub
    end
    table.insert(data.operID, {item = noticeData.itemData})
    self:UpdateItemsCount(data, false)
end

return CompoundItemLayerMediator
