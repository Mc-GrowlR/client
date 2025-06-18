local RemoteProxy    = requireProxy( "remote/RemoteProxy" )
local AttrConfigProxy = class( "AttrConfigProxy", RemoteProxy )
AttrConfigProxy.NAME  = global.ProxyTable.AttrConfigProxy

function AttrConfigProxy:ctor()
   AttrConfigProxy.super.ctor( self )
   self.ItemsConfig = requireConfig("ItemsConfig")
   self._attribute = {}

   self._attTypes = {} --属性类型  表中的属性id
end

function AttrConfigProxy:LoadConfig()
   self._attribute = requireGameConfig("cfg_att_score")

   local index = 1
   -- 兼容scolor
   for _, v in pairs(self._attribute) do
      v.color = v.color or v.scolor
      self._attTypes[index] = v.Idx
      index = index + 1
   end

   -- 服务开关 修改属性为万分比
   local bFixMagicMiss = CHECK_SERVER_OPTION("NewMagicMissType")
   if bFixMagicMiss then 
      self._attribute[15].type = 2
   end 

   local bFixOther = CHECK_SERVER_OPTION("UseYSNewCalType")
   if bFixOther then 
      for i = 21, 31 do 
         self._attribute[i].type = 2
      end 
      self._attribute[43].type = 2
      self._attribute[72].type = 2
   end 
end

function AttrConfigProxy:GetAttTypes()
   return self._attTypes or {}
end

function AttrConfigProxy:GetAttConfigByAttId( attId )
   return self._attribute[attId]
end

function AttrConfigProxy:GetAttConfig()
   return self._attribute
end

function AttrConfigProxy:GetItemsConfigEquipMapByStdMode()
   local EquipMapByStdMode = self.ItemsConfig.EquipMapByStdMode
   return EquipMapByStdMode
end

function AttrConfigProxy:GetItemsConfigDuraMapByShap()
   local DuraMapByShap = self.ItemsConfig.DuraMapByShap
   return DuraMapByShap
end

function AttrConfigProxy:GetItemsConfigQuickUsable()
   local QuickUseStdMode = self.ItemsConfig.QuickUseStdMode
   return QuickUseStdMode
end

function AttrConfigProxy:GetItemsExtraShowLasting()
   local ItemsShowLasting = self.ItemsConfig.ItemsShowLasting
   return ItemsShowLasting
end

function AttrConfigProxy:onRegister()
   AttrConfigProxy.super.onRegister( self )
end

return AttrConfigProxy