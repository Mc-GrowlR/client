local BaseUIMediator = requireMediator("BaseUIMediator")
local PurchaseMyMediator = class('PurchaseMyMediator', BaseUIMediator)
PurchaseMyMediator.NAME = "PurchaseMyMediator"

function PurchaseMyMediator:ctor()
    PurchaseMyMediator.super.ctor(self)
end

function PurchaseMyMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_PurchaseMy_Open,
        noticeTable.Layer_PurchaseMy_Close,
    }
end

function PurchaseMyMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_PurchaseMy_Open == noticeID then
        self:OnOpen(data)

    elseif noticeTable.Layer_PurchaseMy_Close == noticeID then
        self:OnClose()
    end
end

function PurchaseMyMediator:OnOpen(data)
    if not (self._layer) then
        self._layer = requireLayerUI("purchase_layer/PurchaseMyLayer").create(data)
        data.parent:addChild(self._layer)

        -- for GUI
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)        
    end
end

function PurchaseMyMediator:OnClose()
    if not self._layer then
        return false
    end

    if PurchaseMy and PurchaseMy.OnClose then
        PurchaseMy.OnClose()
    end
    self._layer:removeFromParent()
    self._layer = nil
end

return PurchaseMyMediator
