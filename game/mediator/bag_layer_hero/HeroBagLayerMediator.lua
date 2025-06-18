local BaseUIMediator = requireMediator("BaseUIMediator")
local HeroBagLayerMediator = class('HeroBagLayerMediator', BaseUIMediator)
HeroBagLayerMediator.NAME = "HeroBagLayerMediator"

function HeroBagLayerMediator:ctor()
    HeroBagLayerMediator.super.ctor(self)
end

function HeroBagLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_HeroBag_Open,
        noticeTable.Layer_HeroBag_Close,
        noticeTable.Layer_Hero_Logout,
        noticeTable.HeroBag_Oper_Data,
        noticeTable.HeroBag_Pos_Reset,
        noticeTable.HeroBagCountChnage,
        noticeTable.HeroBag_State_Change,
        noticeTable.HeroBag_Item_Pos_Change,
        noticeTable.PlayEquip_Oper_Data_Hero,
        noticeTable.Item_Move_begin_On_HeroBagPosChang,
    }
end

function HeroBagLayerMediator:handleNotification(notification)
    local noticeName = notification:getName()
    local noticeTable = global.NoticeTable
    local noticeData = notification:getBody()

    if noticeTable.Layer_HeroBag_Open == noticeName then
        if IsForbidOpenBagOrEquip() then
            return
        end
        self:OpenLayer(noticeData)

    elseif noticeTable.Layer_HeroBag_Close == noticeName or noticeName == noticeTable.Layer_Hero_Logout then
        self:CloseLayer()

    elseif noticeTable.HeroBag_Oper_Data == noticeName then
        self:BagOper(noticeData)

    elseif noticeTable.HeroBag_Pos_Reset == noticeName or noticeTable.HeroBagCountChnage == noticeName then
        self:ResetAndUpdateItemList()

    elseif noticeTable.HeroBag_State_Change == noticeName then
        self:UpdateBagState(noticeData)

    elseif noticeTable.HeroBag_Item_Pos_Change == noticeName then
        self:RefreshBagData(noticeData)

    elseif noticeTable.PlayEquip_Oper_Data_Hero == noticeName then
        self:UpdateItemPowerCheckState()

    elseif noticeTable.Item_Move_begin_On_HeroBagPosChang == noticeName then
        self:BeginMove(noticeData)    
    end
end

function HeroBagLayerMediator:OpenLayer(data)
    local pos = nil
    if data and data.pos and next(data.pos) then
        pos = data.pos
    end

    if not self._layer then
        self._layer = requireLayerUI("bag_layer_hero/HeroBagLayer").create(data)
        self._type = global.UIZ.UI_NORMAL
        self._escClose = true
        self._resetPostion = pos
        self._GUI_ID = SLDefine.LAYERID.HeroBagLayerGUI

        HeroBagLayerMediator.super.OpenLayer(self)

        self._layer:InitGUI(data)

        -- 自定义UI
        local level = data and data.level
        if not level then
            local bagProxy = global.Facade:retrieveProxy( global.ProxyTable.HeroBagProxy )
            level = bagProxy:getBagLevel()
        end
        LoadLayerCUIConfig(string.format("%s_hero_bag_level%s", global.isWinPlayMode and "pc" or "mobile", level), self._layer)

        -- 自定义组件挂接
        local componentData = {
            root = self._layer.panel,
            index = global.SUIComponentTable.Bag_hero
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)

    elseif pos then
        self._layer:setPosition(pos.x, pos.y)
        self:setSavedPosition(pos.x, pos.y)
        global.Facade:sendNotification(global.NoticeTable.GuideLayerResetPos)

    else
        self:CloseLayer()
    end
end

function HeroBagLayerMediator:CloseLayer()
    -- 自定义组件挂接
    local componentData = {
        index = global.SUIComponentTable.Bag_hero
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    HeroBagLayerMediator.super.CloseLayer(self)
end

function HeroBagLayerMediator:BagOper(data)
    if self._layer then
        self._layer:ItemDataChange(data)
    end
end

function HeroBagLayerMediator:ResetAndUpdateItemList()
    if self._layer then
        self._layer:updateItems()
    end
end

function HeroBagLayerMediator:UpdateBagState(data)
    if self._layer then
        self._layer:UpdateBagState(data)
    end
end

function HeroBagLayerMediator:RefreshBagData(data)
    if self._layer then
        if data then
            self._layer:ItemPosChange(data)
        else
            self._layer:updateItemsList()
        end
    end
end

function HeroBagLayerMediator:UpdateItemPowerCheckState()
    if self._layer then
        self._layer:UpdateItemPowerCheckState()
    end
end

function HeroBagLayerMediator:BeginMove(data)
    if self._layer then
        self._layer:BeginMove(data.MakeIndex, data.pos)
    end
end

return HeroBagLayerMediator