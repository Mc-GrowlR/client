local BaseUIMediator        = requireMediator( "BaseUIMediator" )
local ReinAttrMediator = class('ReinAttrMediator', BaseUIMediator )
ReinAttrMediator.NAME  = "ReinAttrMediator"

function ReinAttrMediator:ctor()
    ReinAttrMediator.super.ctor( self )
end

function ReinAttrMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Rein_Attr_Open,
        noticeTable.Layer_Rein_Attr_Close,
        noticeTable.Player_Rein_Attr_Change,
    }
end

function ReinAttrMediator:handleNotification(notification)
    local noticeName    = notification:getName()
    local noticeTable   = global.NoticeTable
    local noticeData    = notification:getBody()

    if noticeTable.Layer_Rein_Attr_Open == noticeName then
        self:OpenLayer(noticeData)
    elseif noticeTable.Layer_Rein_Attr_Close == noticeName then
        self:CloseLayer()
    elseif noticeTable.Player_Rein_Attr_Change == noticeName then
        self:UpdateLayer()
    end
end

function ReinAttrMediator:OpenLayer(Data)

    if not ( self._layer ) then
        local path = "reincarnate_attr/ReinAttrLayer"
        self._layer = requireLayerUI(path).create()
        self._type  = global.UIZ.UI_NORMAL
        self._GUI_ID = SLDefine.LAYERID.ReinAttrGUI
        ReinAttrMediator.super.OpenLayer(self)

        self._layer:InitGUI()
    
    end    
end

function ReinAttrMediator:CloseLayer()
    if self._layer then
        self._layer:OnClose()
    end
    ReinAttrMediator.super.CloseLayer(self)
end

function ReinAttrMediator:UpdateLayer()
   if self._layer then
      self._layer:UpdateData()
   end
end

return ReinAttrMediator