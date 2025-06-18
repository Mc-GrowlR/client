local BaseUIMediator = requireMediator("BaseUIMediator")
local BossTipsLayerMediator = class('BossTipsLayerMediator', BaseUIMediator)
BossTipsLayerMediator.NAME = "BossTipsLayerMediator"

function BossTipsLayerMediator:ctor()
    BossTipsLayerMediator.super.ctor(self)
end

function BossTipsLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_BossTipsLayer_Open,
        noticeTable.Layer_BossTipsLayer_Close,
    }
end

function BossTipsLayerMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_BossTipsLayer_Open == name then
        self:OpenLayer(data)
    elseif noticeTable.Layer_BossTipsLayer_Close == name then
        self:CloseLayer()
    end
end

function BossTipsLayerMediator:OpenLayer(data)
    if not self._layer then
        local path = "setting_layer/BossTipsLayer" 
        self._layer = requireLayerUI(path).create(data)
        self._type = global.UIZ.UI_NORMAL
        -- self._responseMoved = self._layer._quickUI.Panel_1
        BossTipsLayerMediator.super.OpenLayer( self )
    end
end

function BossTipsLayerMediator:CloseLayer() 
    if not self._layer then
        return 
    end 
    self._layer:OnClose()
    BossTipsLayerMediator.super.CloseLayer( self )
end

return BossTipsLayerMediator
