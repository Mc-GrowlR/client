local BaseUIMediator        = requireMediator( "BaseUIMediator" )
local TreasureBoxMediator = class('TreasureBoxMediator', BaseUIMediator )
TreasureBoxMediator.NAME  = "TreasureBoxMediator"

function TreasureBoxMediator:ctor()
    TreasureBoxMediator.super.ctor( self )
end

function TreasureBoxMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
      noticeTable.Layer_Treasure_Box_Open,
      noticeTable.Layer_Treasure_Box_Close,
      noticeTable.Layer_Treasure_Box_Refresh,
    }
end

function TreasureBoxMediator:handleNotification(notification)
   local noticeName    = notification:getName()
   local noticeTable   = global.NoticeTable
   local noticeData    = notification:getBody()

   if noticeTable.Layer_Treasure_Box_Open == noticeName then
      self:OpenLayer(noticeData)
   elseif noticeTable.Layer_Treasure_Box_Close == noticeName then
      self:CloseLayer()
    elseif noticeTable.Layer_Treasure_Box_Refresh == noticeName then 
      self:ShowOpenAnim(noticeData)
   end
end

function TreasureBoxMediator:OpenLayer(Data)
    if not ( self._layer ) then
        self._layer = requireLayerUI("gold_box_layer/TreasureBoxLayer").create(Data)
        self._type  = global.UIZ.UI_FUNC
        self._action = false
        TreasureBoxMediator.super.OpenLayer(self)

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI(Data)

        global.Facade:sendNotification(global.NoticeTable.Layer_Gold_Box_Refresh, Data)
    end
end

function TreasureBoxMediator:ShowOpenAnim(noticeData)
    if self._layer then 
        self._layer:OpenBoxAnim(noticeData)
    else
        global.Facade:sendNotification(global.NoticeTable.Layer_Gold_Box_Open, noticeData)
    end
end

function TreasureBoxMediator:CloseLayer()
    TreasureBoxMediator.super.CloseLayer(self)
end

return TreasureBoxMediator