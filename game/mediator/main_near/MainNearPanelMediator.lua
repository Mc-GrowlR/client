local BaseUIMediator        = requireMediator( "BaseUIMediator" )
local MainNearPanelMediator = class('MainNearPanelMediator', BaseUIMediator )
MainNearPanelMediator.NAME  = "MainNearPanelMediator"

function MainNearPanelMediator:ctor()
   MainNearPanelMediator.super.ctor( self )
end

function MainNearPanelMediator:listNotificationInterests()
   local noticeTable = global.NoticeTable
   return {
      noticeTable.Layer_MainNear_Open,
      noticeTable.Layer_MainNear_Close,
      noticeTable.Layer_MainNear_Refresh,
      noticeTable.ActorRevive,
      noticeTable.ActorInOfView,
      noticeTable.ActorOutOfView,
      noticeTable.ActorPlayerDie,
      noticeTable.ActorMonsterDie,
      noticeTable.ActorMonsterBirth,
      noticeTable.ActorMonsterCave,
      noticeTable.RefreshActorHP,
      noticeTable.TargetChange,
      noticeTable.PlayerPKModeChange,
   }
end

function MainNearPanelMediator:handleNotification(notification)
   local noticeID    = notification:getName()
   local noticeTable = global.NoticeTable
   local data        = notification:getBody()

   if noticeTable.Layer_MainNear_Open == noticeID then
      self:OpenLayer(data)

   elseif noticeTable.Layer_MainNear_Close == noticeID then
      self:CloseLayer()

   elseif noticeTable.Layer_MainNear_Refresh == noticeID then
      self:OnMainNearRefresh( data )

   elseif noticeTable.ActorRevive == noticeID then
      self:OnActorRevive(data)

   elseif noticeTable.ActorInOfView == noticeID then
      self:OnActorInOfView(data)

   elseif noticeTable.ActorOutOfView == noticeID then
      self:OnActorOutOfView(data)
      
   elseif noticeTable.ActorPlayerDie == noticeID then
      self:OnActorDie(data)

   elseif noticeTable.ActorMonsterDie == noticeID then
      self:OnActorDie(data)

   elseif noticeTable.ActorMonsterBirth == noticeID then
      self:OnActorMonsterBirth(data)

   elseif noticeTable.ActorMonsterCave == noticeID then
      self:OnActorMonsterCave(data)

   elseif noticeTable.RefreshActorHP == noticeID then
      self:OnRefreshActorHP(data)

   elseif noticeTable.TargetChange == noticeID then
      self:OnTargetChange(data)

   elseif noticeTable.PlayerPKModeChange == noticeID then
      self:OnPlayerPKStateChange(data)

   end
end

function MainNearPanelMediator:OpenLayer(data)
   if not ( self._layer ) then
      self._layer    = requireLayerUI("main_near/MainNearPanel").create(data)
      self._type     = global.UIZ.UI_NORMAL
      self._escClose = true
      self._GUI_ID   = SLDefine.LAYERID.MainNearGUI

      MainNearPanelMediator.super.OpenLayer(self)

      self._layer:InitGUI(data)
   else
      self:CloseLayer()
   end    
end

function MainNearPanelMediator:CloseLayer()
   MainNearPanelMediator.super.CloseLayer(self)
end

function MainNearPanelMediator:OnMainNearRefresh( data )
   if self._layer then
      self._layer:OnMainNearRefresh( data )
   end
end

function MainNearPanelMediator:OnActorRevive( data )
   if self._layer then 
      self._layer:OnActorRevive(data)
   end
end

function MainNearPanelMediator:OnActorInOfView( data )
   if self._layer then 
      self._layer:OnActorInOfView(data)
   end
end

function MainNearPanelMediator:OnActorOutOfView( data )
   if self._layer then 
      self._layer:OnActorOutOfView(data)
   end
end

function MainNearPanelMediator:OnActorDie( data )
   if self._layer then 
      self._layer:OnActorDie(data)
   end
end

function MainNearPanelMediator:OnActorMonsterBirth(data)
   if not self._layer then
      return
   end
   self._layer:OnActorMonsterBirth(data)
end

function MainNearPanelMediator:OnActorMonsterCave(data)
   if not self._layer then
      return
   end
   self._layer:OnActorMonsterCave(data)
end

function MainNearPanelMediator:OnRefreshActorHP( data )
   if self._layer then 
      self._layer:OnRefreshActorHP(data)
   end
end

function MainNearPanelMediator:OnTargetChange( data )
   if self._layer then 
      self._layer:OnTargetChange(data)
   end
end

function MainNearPanelMediator:OnPlayerPKStateChange( data )
   if self._layer then 
      self._layer:OnPlayerPKStateChange(data)
   end
end

return MainNearPanelMediator