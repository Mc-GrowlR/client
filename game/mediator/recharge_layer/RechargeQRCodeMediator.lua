local BaseUIMediator = requireMediator("BaseUIMediator")
local RechargeQRCodeMediator = class("RechargeQRCodeMediator", BaseUIMediator)
RechargeQRCodeMediator.NAME = "RechargeQRCodeMediator"

function RechargeQRCodeMediator:ctor()
    RechargeQRCodeMediator.super.ctor(self)
end

function RechargeQRCodeMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.Layer_Recharge_QRCode_Open,
        noticeTable.Layer_Recharge_QRCode_Close,
        noticeTable.RechargeReceivedResp,
    }
end

function RechargeQRCodeMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Recharge_QRCode_Open == name then
        self:OpenLayer(data)

    elseif noticeTable.Layer_Recharge_QRCode_Close == name then
        self:CloseLayer(data)

    elseif noticeTable.RechargeReceivedResp == name then
        self:OnRechargeReceived(data)
    end
end

function RechargeQRCodeMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer = requireLayerUI("recharge_layer/RechargeQRCodeLayer").create()

        self._type = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.RechargeQRCodeGUI
        RechargeQRCodeMediator.super.OpenLayer(self)

        self._layer:InitGUI()
    end

    if self._layer then
        self._layer:ShowQRCode(data)
    end
end

function RechargeQRCodeMediator:CloseLayer(data)
    RechargeQRCodeMediator.super.CloseLayer(self)
end

function RechargeQRCodeMediator:OnRechargeReceived(data)
    if not self._layer then
        return nil
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_Recharge_QRCode_Close)
end

return RechargeQRCodeMediator
