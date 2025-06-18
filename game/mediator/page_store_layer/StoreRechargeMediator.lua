local BaseUIMediator = requireMediator("BaseUIMediator")
local RechargeMediator = class('RechargeMediator', BaseUIMediator)
RechargeMediator.NAME = "RechargeMediator"

function RechargeMediator:ctor()
    RechargeMediator.super.ctor(self)
end

function RechargeMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Recharge_Open,
        noticeTable.Layer_Recharge_Close,
    }
end

function RechargeMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Recharge_Open == name then
        self:OpenLayer(data)
        
    elseif noticeTable.Layer_Recharge_Close == name then
        self:CloseLayer(data)
    end
end

function RechargeMediator:OpenLayer(data)
    if not (self._layer) then
        local group = data.extent
        self._layer = requireLayerUI("page_store_layer/StoreRechageLayer").create(group)
        data.parent:addChild(self._layer)
        refPositionByParent(self._layer)

        -- for GUI
        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()

        -- 自定义组件挂接
        local componentData = {
            root  = self._layer._quickUI.Panel_input,
            index = global.SUIComponentTable.Recharge
        }
        global.Facade:sendNotification(global.NoticeTable.SUIComponentAttach, componentData)
    end
end

function RechargeMediator:CloseLayer(data)
    if not self._layer then
        return
    end

    local componentData = 
    {
        index = global.SUIComponentTable.Recharge
    }
    global.Facade:sendNotification(global.NoticeTable.SUIComponentDetach, componentData)

    self._layer:removeFromParent()
    self._layer = nil
end

return RechargeMediator
