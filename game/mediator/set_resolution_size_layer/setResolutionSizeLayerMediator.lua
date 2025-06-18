local BaseUIMediator        = requireMediator( "BaseUIMediator" )
local setResolutionSizeLayerMediator = class('setResolutionSizeLayerMediator', BaseUIMediator )
setResolutionSizeLayerMediator.NAME  = "setResolutionSizeLayerMediator"

function setResolutionSizeLayerMediator:ctor()
    setResolutionSizeLayerMediator.super.ctor( self )
end

function setResolutionSizeLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_setResolutionSize_Open,
        noticeTable.Layer_setResolutionSize_Close,
    }
end

function setResolutionSizeLayerMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()

    if noticeTable.Layer_setResolutionSize_Open == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_setResolutionSize_Close == noticeName then
        self:CloseLayer()
    end
end

function setResolutionSizeLayerMediator:OpenLayer()
    if not global.isWinPlayMode then 
        return
    end
    if not self._layer then
        self._layer = requireLayerUI("set_resolution_size_layer/setResolutionSizeLayer").create()
        self._type  = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.SetWinSizeGUI
        setResolutionSizeLayerMediator.super.OpenLayer(self)

        self._layer:InitGUI()
    else
        self:CloseLayer()
    end
end

function setResolutionSizeLayerMediator:CloseLayer()
    if not self._layer then
        return
    end
    setResolutionSizeLayerMediator.super.CloseLayer(self)
end


return setResolutionSizeLayerMediator