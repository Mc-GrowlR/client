--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local BaseUIMediator        = requireMediator( "BaseUIMediator" )
local StallPutMediator = class('StallPutMediator', BaseUIMediator )
StallPutMediator.NAME  = "StallPutMediator"


function StallPutMediator:ctor()
    StallPutMediator.super.ctor( self )
end
 
function StallPutMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
             noticeTable.Layer_Stall_Put_Open,
             noticeTable.Layer_Stall_Put_Close,
            }
end

function StallPutMediator:handleNotification(notification)
    local notices  = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Stall_Put_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Stall_Put_Close then
        self:CloseLayer()
    end
end

function StallPutMediator:OpenLayer(noticeData)
    if not (self._layer) then
        local path = "stall_layer/StallPutLayer"
        if global.isWinPlayMode then
            path = "stall_layer/StallPutLayer_win32"
        end
        self._layer = requireLayerUI( path ).create(noticeData)
        self._type = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.StallPutGUI

        StallPutMediator.super.OpenLayer(self)
        self._layer:InitGUI(noticeData)
    else
        self:CloseLayer()
    end
end

function StallPutMediator:CloseLayer()
    StallPutMediator.super.CloseLayer( self )
end

return StallPutMediator

--endregion
