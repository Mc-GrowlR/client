--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local BaseUIMediator        = requireMediator( "BaseUIMediator" )
local StallSetMediator = class('StallSetMediator', BaseUIMediator )
StallSetMediator.NAME  = "StallSetMediator"


function StallSetMediator:ctor()
    StallSetMediator.super.ctor( self )
end
 
function StallSetMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
             noticeTable.Layer_Stall_Set_Open,
             noticeTable.Layer_Stall_Set_Close,
            }
end

function StallSetMediator:handleNotification(notification)
    local notices  = global.NoticeTable
    local noticeName = notification:getName()
    local noticeData = notification:getBody()

    if noticeName == notices.Layer_Stall_Set_Open then
        self:OpenLayer(noticeData)
    elseif noticeName == notices.Layer_Stall_Set_Close then
        self:CloseLayer()
    end
end

function StallSetMediator:OpenLayer(noticeData)
    if not (self._layer) then
        local path = "stall_layer/StallSetLayer"
        if global.isWinPlayMode then
            path = "stall_layer/StallSetLayer_win32"
        end
        self._layer = requireLayerUI( path ).create(noticeData)
        self._type = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.StallSetGUI

        StallSetMediator.super.OpenLayer(self)
        self._layer:InitGUI(noticeData)
    else
        self:CloseLayer()
    end

end

function StallSetMediator:CloseLayer()
    StallSetMediator.super.CloseLayer( self )
end

return StallSetMediator

--endregion
