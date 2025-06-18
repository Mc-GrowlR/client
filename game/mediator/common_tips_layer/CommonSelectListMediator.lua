local BaseUIMediator = requireMediator( "BaseUIMediator" )
local CommonSelectListMediator = class('CommonSelectListMediator', BaseUIMediator)
CommonSelectListMediator.NAME = "CommonSelectListMediator"

function CommonSelectListMediator:ctor()
    CommonSelectListMediator.super.ctor(self, self.NAME)
end

function CommonSelectListMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
        {
            noticeTable.Layer_Common_SelectList_Open,
            noticeTable.Layer_Common_SelectList_Close,
        }
end

function CommonSelectListMediator:handleNotification(notification)
    local noticeID = notification:getName()
    local notices = global.NoticeTable
    local data = notification:getBody()
    
    if notices.Layer_Common_SelectList_Open == noticeID then
        self:OpenLayer(data)
    
    elseif notices.Layer_Common_SelectList_Close == noticeID then
        self:CloseLayer()
    end
end

function CommonSelectListMediator:OpenLayer(data)
    if not ( self._layer ) then
        local layer = requireLayerUI( "common_tips_layer/CommonSelectListPanel" ).create(data)
        self._layer         = layer
        self._type          = global.UIZ.UI_TOBOX
        self._hideMain      = false
        CommonSelectListMediator.super.OpenLayer( self )

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)
    end
end

function CommonSelectListMediator:CloseLayer()
    CommonSelectListMediator.super.CloseLayer( self )
end

return CommonSelectListMediator
