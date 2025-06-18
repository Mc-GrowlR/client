local BaseUIMediator = requireMediator( "BaseUIMediator" )
local CommonTipsMediator = class("CommonTipsMediator", BaseUIMediator)
CommonTipsMediator.NAME = "CommonTipsMediator"

function CommonTipsMediator:ctor()
    CommonTipsMediator.super.ctor(self)
end

function CommonTipsMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_CommonTips_Open,
        noticeTable.Layer_CommonTips_Close,
    }
end

function CommonTipsMediator:handleNotification(notification)
    local noticeName  = notification:getName()
    local noticeTable = global.NoticeTable
    local data = notification:getBody()
    if noticeTable.Layer_CommonTips_Open == noticeName then
        self:OpenLayer(data)
    elseif noticeTable.Layer_CommonTips_Close == noticeName then
        self:CloseLayer(data)
    end
end

function CommonTipsMediator:OpenLayer(data)
    if not ( self._layer ) then
        self._layer = requireLayerUI( "common_tips_layer/CommonTipsLayer" ).create()
        self._type  = global.UIZ.UI_TOBOX
        self._GUI_ID = SLDefine.LAYERID.CommonTipsGUI

        self._layer:onNodeEvent("exit", function() 
            self._layer = nil
        end)

        CommonTipsMediator.super.OpenLayer(self)
        
        GUI.ATTACH_PARENT = self._layer

        self._events = self._layer.Events
        self._callback = data.callback
        self._layer:InitGUI(data)
    end
end

function CommonTipsMediator:CloseLayer()
    CommonTipsMediator.super.CloseLayer(self)
end

function CommonTipsMediator:handlePressedEnter()
    if self._layer then
        self._layer:handlePressedEnter()
    end
    return true
end

return CommonTipsMediator