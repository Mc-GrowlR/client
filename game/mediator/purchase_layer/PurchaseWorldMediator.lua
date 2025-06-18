local BaseUIMediator = requireMediator("BaseUIMediator")
local PurchaseWorldMediator = class('PurchaseWorldMediator', BaseUIMediator)
PurchaseWorldMediator.NAME = "PurchaseWorldMediator"

function PurchaseWorldMediator:ctor()
    PurchaseWorldMediator.super.ctor(self)
end

function PurchaseWorldMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_PurchaseWorld_Open,
        noticeTable.Layer_PurchaseWorld_Close,
    }
end

function PurchaseWorldMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_PurchaseWorld_Open == noticeID then
        self:OnOpen(data)

    elseif noticeTable.Layer_PurchaseWorld_Close == noticeID then
        self:OnClose()
    end
end

function PurchaseWorldMediator:OnOpen(data)
    if not (self._layer) then
        self._layer = requireLayerUI("purchase_layer/PurchaseWorldLayer").create(data)
        data.parent:addChild(self._layer)

        -- for GUI
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)
    end
end

function PurchaseWorldMediator:OnClose()
    if not self._layer then
        return false
    end

    if PurchaseWorld and PurchaseWorld.OnClose then
        PurchaseWorld.OnClose()
    end
    self._layer:removeFromParent()
    self._layer = nil
end

return PurchaseWorldMediator
