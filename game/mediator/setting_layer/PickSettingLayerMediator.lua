local BaseUIMediator = requireMediator("BaseUIMediator")
local PickSettingLayerMediator = class('PickSettingLayerMediator', BaseUIMediator)
PickSettingLayerMediator.NAME = "PickSettingLayerMediator"

function PickSettingLayerMediator:ctor()
    PickSettingLayerMediator.super.ctor(self)
end

function PickSettingLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_pickSettingLayer_Open,
        noticeTable.Layer_pickSettingLayer_Close,
    }
end

function PickSettingLayerMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_pickSettingLayer_Open == name then
        self:OpenLayer(data)
    elseif noticeTable.Layer_pickSettingLayer_Close == name then
        self:CloseLayer()
    end
end

function PickSettingLayerMediator:OpenLayer(data)
    if not self._layer then
        local path =  global.isWinPlayMode and "setting_layer/PickSettingLayer_win32" or "setting_layer/PickSettingLayer" 
        self._layer = requireLayerUI(path).create(data)
        self._type = global.UIZ.UI_NORMAL
        -- self._responseMoved = self._layer._quickUI.Panel_1
        -- local parent = self._layer._quickUI.Node_1
        -- global.Facade:sendNotification(global.NoticeTable.Layer_SettingAutoPick_Open,{parent = parent})
        PickSettingLayerMediator.super.OpenLayer( self )
    end
end

function PickSettingLayerMediator:CloseLayer() 
    if not self._layer then
        return 
    end 
    -- global.Facade:sendNotification(global.NoticeTable.Layer_SettingAutoPick_Close)
    PickSettingLayerMediator.super.CloseLayer( self )
end


return PickSettingLayerMediator
