local BaseUIMediator = requireMediator( "BaseUIMediator" )
local TeamMediator = class("TeamMediator", BaseUIMediator)
TeamMediator.NAME = "TeamMediator"

function TeamMediator:ctor()
    TeamMediator.super.ctor( self )
end

function TeamMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Team_Attach,
        noticeTable.Layer_Team_UnAttach,
    }
end

function TeamMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    
    if noticeTable.Layer_Team_Attach == noticeName then
        self:AttachLayer(noticeData)

    elseif noticeTable.Layer_Team_UnAttach == noticeName then
        self:UnAttachLayer()
    end
end

function TeamMediator:AttachLayer(data)
    if not self._layer then
        local layer = requireLayerUI("team_layer/TeamLayer").create(data)
        if layer and data and data.parent then
            data.parent:addChild(layer)
            self._layer = layer

            -- for GUI
            GUI.ATTACH_PARENT = self._layer
            self._layer:InitGUI(data)            
        end
    end
end

function TeamMediator:UnAttachLayer()
    if self._layer then
        self._layer:CloseLayer()
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return TeamMediator