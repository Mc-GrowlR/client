local BaseUIMediator = requireMediator( "BaseUIMediator" )
local CommonBubleInfoMediator = class("CommonBubleInfoMediator", BaseUIMediator)
CommonBubleInfoMediator.NAME = "CommonBubleInfoMediator"

function CommonBubleInfoMediator:ctor()
    CommonBubleInfoMediator.super.ctor( self )
end

function CommonBubleInfoMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.Layer_CommonBubbleInfo_Open,
        noticeTable.Layer_CommonBubbleInfo_Close,
    }
end

function CommonBubleInfoMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_CommonBubbleInfo_Open == noticeID then
        self:OpenLayer(data)
        
    elseif noticeTable.Layer_CommonBubbleInfo_Close == noticeID then
        self:CloseLayer()
    end
end

function CommonBubleInfoMediator:OpenLayer(data)
    if not ( self._layer ) then
        local layer = requireLayerUI( "common_tips_layer/CommonBubbleInfoLayer" ).create(data)
        self._layer = layer
        self._type = global.UIZ.UI_TOBOX

        CommonBubleInfoMediator.super.OpenLayer(self)

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(data)
    else
        if CommonBubbleInfo and CommonBubbleInfo.InitUI then
            CommonBubbleInfo.InitUI(data)
        end
    end
end

function CommonBubleInfoMediator:CloseLayer()
    CommonBubleInfoMediator.super.CloseLayer(self)
end

return CommonBubleInfoMediator