local BaseUIMediator = requireMediator("BaseUIMediator")
local MovedLayerMediator = class("MovedLayerMediator", BaseUIMediator)
MovedLayerMediator.NAME = "MovedLayerMediator"

local sformat = string.format

function MovedLayerMediator:ctor()
    MovedLayerMediator.super.ctor(self)
end

function MovedLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Moved_Open,
        noticeTable.Layer_Moved_Begin,
        noticeTable.Layer_Moved_Moving,
        noticeTable.Layer_Moved_End,
        noticeTable.Layer_Moved_Cancel,
        noticeTable.Layer_Moved_UpDate,
        noticeTable.Layer_NPC_Storage_Close,
        noticeTable.Bag_Oper_Data,
        noticeTable.PlayEquip_Oper_Data,
        noticeTable.QuickUseItemRmv
    }
end

function MovedLayerMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local id = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Moved_Open == id then
        self:OpenLayer()
    elseif noticeTable.Layer_Moved_Begin == id then
        self:CreateMoveItem(data)
    elseif noticeTable.Layer_Moved_Moving == id then
        self:UpdatePostion(data)
    elseif noticeTable.Layer_Moved_End == id then
        self:CheckMoveEndPos(data)
    elseif noticeTable.Layer_Moved_Cancel == id then
        self:MoveItemCancel(data)
    elseif noticeTable.Layer_Moved_UpDate == id then
        self:MoveItemUpDate(data)
    elseif noticeTable.Layer_NPC_Storage_Close == id then
        self:OnSpecialCancelStorage(data)
    elseif noticeTable.Bag_Oper_Data == id then
        self:CancelBagMove(data)
    elseif noticeTable.PlayEquip_Oper_Data == id then
        self:CancelEquipMove(data)
    elseif noticeTable.QuickUseItemRmv == id then
        self:CancelQuickUseMove(data)
    end
end

function MovedLayerMediator:OpenLayer()
    if not (self._layer) then
        self._layer = requireLayerUI("moved_event_layer/MovedEventLayer").create()
        self._type = global.UIZ.UI_MOUSE

        local function onMouseBegin(pos)
            if self._layer then
                self._layer:setMoveBeginPos(pos)
            end
            return -1
        end

        local function onMouseDownR(pos)
            if self._layer then
                self._layer:setMoveBeginPos(pos)
            end
            return -1
        end

        local function onMouseMoving(updatePos)
            if self._layer then
                self._layer:setMoveBeginPos(updatePos)
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Moving,{pos = updatePos})
        end

        self._mouseBtnParam = {
            special_r = onMouseBegin,
            moving = onMouseMoving,
            down_r = onMouseDownR,
            moveTouch = true,
            swallow = -1
        }
        MovedLayerMediator.super.OpenLayer(self)
    end
end

function MovedLayerMediator:CreateMoveItem(data)
    if self._layer then
        self._layer:CreateMovingItem(data)
    end
end

function MovedLayerMediator:UpdatePostion(data)
    if self._layer then
        self._layer:UpdatePostion(data)
    end
end

function MovedLayerMediator:CheckMoveEndPos(data)
    if self._layer then
        self._layer:CleanData(data)
    end
end

function MovedLayerMediator:MoveItemCancel(data)
    if self._layer then
        self._layer:OnMoveCancelEvent(data)
    end
end

function MovedLayerMediator:MoveItemUpDate(data)
    if self._layer then
        self._layer:OnMoveItemUpDate(data)
    end
end

function MovedLayerMediator:OnSpecialCancelStorage(data)
    if self._layer then
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        self._layer:OnSpecialCanel(ItemMoveProxy.ItemFrom.STORAGE)
    end
end

function MovedLayerMediator:CancelBagMove(data)
    if self._layer then
        if not data or not next(data) then
            return
        end
        local type = data.opera
        local itemData = data.operID
        if not itemData or not next(itemData) then
            return
        end
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        if type == 2 then
            for k,v in pairs(itemData) do
                --移动中处理
                local itemMoving = ItemMoveProxy:GetMovingItemState()
                local itemMovingData = ItemMoveProxy:GetMovingItemData()
                if itemMoving and itemMovingData then --在道具移动中
                    if v.MakeIndex == itemMovingData.MakeIndex then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
                    end
                end
            end
        end
    end
end

function MovedLayerMediator:CancelEquipMove(data)
    if self._layer then
        if not data or not next(data) then
            return
        end
        local type = data.opera
        local MakeIndex = data.MakeIndex
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        if type == 2 then
            local itemMoving = ItemMoveProxy:GetMovingItemState()
            local itemMovingData = ItemMoveProxy:GetMovingItemData()
            if itemMoving and itemMovingData then --在道具移动中
                if MakeIndex == itemMovingData.MakeIndex then
                    global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
                end
            end
        end
    end
end

function MovedLayerMediator:CancelQuickUseMove(data)
    if self._layer then
        if not data or not next(data) then
            return
        end
        local itemData = data.itemData
        if not itemData or not next(itemData) then
            return
        end
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        local itemMoving = ItemMoveProxy:GetMovingItemState()
        local itemMovingData = ItemMoveProxy:GetMovingItemData()
        if itemMoving and itemMovingData then --在道具移动中
            if itemData.MakeIndex == itemMovingData.MakeIndex then
                global.Facade:sendNotification(global.NoticeTable.Layer_Moved_Cancel)
            end
        end
    end
end

return MovedLayerMediator
