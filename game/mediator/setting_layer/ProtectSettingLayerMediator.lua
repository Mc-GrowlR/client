local BaseUIMediator = requireMediator("BaseUIMediator")
local ProtectSettingLayerMediator = class('ProtectSettingLayerMediator', BaseUIMediator)
ProtectSettingLayerMediator.NAME = "ProtectSettingLayerMediator"

function ProtectSettingLayerMediator:ctor()
    ProtectSettingLayerMediator.super.ctor(self)
end

function ProtectSettingLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_ProtectSettingLayer_Open,
        noticeTable.Layer_ProtectSettingLayer_Close,
    }
end

function ProtectSettingLayerMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_ProtectSettingLayer_Open == name then
        self:OpenLayer(data)
    elseif noticeTable.Layer_ProtectSettingLayer_Close == name then
        self:CloseLayer()
    end
end

function ProtectSettingLayerMediator:OpenLayer(data)
    if not self._layer then
        local path = "setting_layer/ProtectSettingLayer"
        self._layer = requireLayerUI(path).create(data)
        self._type = global.UIZ.UI_NORMAL
        self._responseMoved = self._layer._quickUI.Panel_1
        ProtectSettingLayerMediator.super.OpenLayer( self )
    end
end

function ProtectSettingLayerMediator:CloseLayer()  
    if not self._layer then
        return 
    end 
    ProtectSettingLayerMediator.super.CloseLayer( self )
end




return ProtectSettingLayerMediator
