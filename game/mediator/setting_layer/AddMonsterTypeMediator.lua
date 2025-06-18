local BaseUIMediator = requireMediator("BaseUIMediator")
local AddMonsterTypeMediator = class('AddMonsterTypeMediator', BaseUIMediator)
AddMonsterTypeMediator.NAME = "AddMonsterTypeMediator"

function AddMonsterTypeMediator:ctor()
    AddMonsterTypeMediator.super.ctor(self)
end

function AddMonsterTypeMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_addMonsterTypeLayer_Open,
        noticeTable.Layer_addMonsterTypeLayer_Close,
    }
end

function AddMonsterTypeMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local name = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_addMonsterTypeLayer_Open == name then
        self:OpenLayer(data)
    elseif noticeTable.Layer_addMonsterTypeLayer_Close == name then
        self:CloseLayer()
    end
end

function AddMonsterTypeMediator:OpenLayer(data)
    if not self._layer then
        local path = "setting_layer/AddMonsterTypeLayer" 
        self._layer = requireLayerUI(path).create(data)
        self._type = global.UIZ.UI_NORMAL
        self._responseMoved = self._layer._quickUI.Panel_1
        AddMonsterTypeMediator.super.OpenLayer( self )
    end
end

function AddMonsterTypeMediator:CloseLayer()  
    if not self._layer then
        return 
    end 
    AddMonsterTypeMediator.super.CloseLayer( self )
end




return AddMonsterTypeMediator
