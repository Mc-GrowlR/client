local BaseUIMediator = requireMediator( "BaseUIMediator" )
local NearPlayerMediator = class("NearPlayerMediator", BaseUIMediator)
NearPlayerMediator.NAME = "NearPlayerMediator"

function NearPlayerMediator:ctor()
    NearPlayerMediator.super.ctor( self )
end

function NearPlayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_NearPlayer_Attach,
        noticeTable.Layer_NearPlayer_UnAttach,
    }
end

function NearPlayerMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()
    
    if noticeTable.Layer_NearPlayer_Attach == noticeName then
        self:AttachLayer(noticeData)

    elseif noticeTable.Layer_NearPlayer_UnAttach == noticeName then
        self:UnAttachLayer()
    end
end

function NearPlayerMediator:AttachLayer(data)
    if not self._layer then
        local layer = requireLayerUI("near_player/NearPlayerLayer").create(data)
        if layer and data and data.parent then
            data.parent:addChild(layer)
            self._layer = layer
            
            -- for GUI
            GUI.ATTACH_PARENT = self._layer
            self._layer:InitGUI()
        end
    end
end

function NearPlayerMediator:UnAttachLayer()
    if self._layer then
        self._layer:removeFromParent()
        self._layer = nil
    end
end

return NearPlayerMediator