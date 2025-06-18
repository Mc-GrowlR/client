local BaseUIMediator = requireMediator("BaseUIMediator")
local AddMonsterNameLayerMediator = class('AddMonsterNameLayerMediator', BaseUIMediator)
AddMonsterNameLayerMediator.NAME = "AddMonsterNameLayerMediator"

function AddMonsterNameLayerMediator:ctor()
    AddMonsterNameLayerMediator.super.ctor(self)
end

function AddMonsterNameLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_addMonsterNameLayer_Open,
        noticeTable.Layer_addMonsterNameLayer_Close,
    }
end

function AddMonsterNameLayerMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_addMonsterNameLayer_Open == name then
        self:OpenLayer(data)
    elseif noticeTable.Layer_addMonsterNameLayer_Close == name then
        self:CloseLayer()
    end
end

function AddMonsterNameLayerMediator:OpenLayer(data)
    if not self._layer then
        local path = "setting_layer/AddMonsterNameLayer" 
        self._layer = requireLayerUI(path).create(data)
        self._type = global.UIZ.UI_NORMAL
        self._responseMoved = self._layer._quickUI.Panel_1
        AddMonsterNameLayerMediator.super.OpenLayer( self )
    end
end

function AddMonsterNameLayerMediator:CloseLayer()  
    if not self._layer then
        return 
    end 
    AddMonsterNameLayerMediator.super.CloseLayer( self )
end




return AddMonsterNameLayerMediator
