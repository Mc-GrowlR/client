local HeroEquipData = class( "HeroEquipData" )

--[[
   README:
   装备替换时时没有卸下消息
   服务器消息具体的顺序为
   1.删除背包道具
   2.添加替换上的装备到人物装备数据中
   3.添加装备栏卸下的道具到背包
   这样会导致 人物装备数据中没有删除
   所以前端手动删除
   故在AddItem方法中删除了同位置的历史数据
   并且刷新一遍背包 不刷新会导致背包战力对比没有刷新
]]

function HeroEquipData:ctor()
   self.dataByMakeIndex  = {}
   self.dataByPos = {}
end

function HeroEquipData:GetData()
   return self.dataByMakeIndex
end

function HeroEquipData:GetEquipPosData()
   return self.dataByPos
end

function HeroEquipData:GetDataByMakeIndex(MakeIndex)
   if self.dataByMakeIndex[MakeIndex] then
      return self.dataByMakeIndex[MakeIndex]
   end
   return nil
end

function HeroEquipData:GetDataByPos(pos)
   local item = nil
   if self.dataByPos[pos] then
      local MakeIndex = self.dataByPos[pos].MakeIndex
      item = self:GetDataByMakeIndex(MakeIndex)
   end
   return item
end

function HeroEquipData:ClearData()
   self.dataByMakeIndex  = {}
   self.dataByPos = {}
end

function HeroEquipData:AddItem(item)
   local MakeIndex = item.MakeIndex
   local Where = item.Where
   self.dataByMakeIndex[MakeIndex] = item
   if not self.dataByPos[Where] then
      self.dataByPos[Where] = {}
   elseif self.dataByPos[Where] and next(self.dataByPos[Where]) then
      -- 清除原来该位置上的装备信息
      -- local lastMakeIndex = self.dataByPos[Where].MakeIndex
      -- self.dataByMakeIndex[lastMakeIndex] = nil
   end
   self.dataByPos[Where].MakeIndex = MakeIndex
   -- 刷一遍背包
   -- 这里刷一遍是因为没有装备卸下的步骤
   -- global.Facade:sendNotification(global.NoticeTable.Bag_Item_Pos_Change)
end

function HeroEquipData:SubItem(item)
   local equip = self:GetDataByMakeIndex(item.MakeIndex)
   if equip then
      local Where = equip.Where
      self.dataByPos[Where] = nil
      self.dataByMakeIndex[item.MakeIndex] = nil
   end
end

function HeroEquipData:ChangeItem(item)
   local MakeIndex = item.MakeIndex
   if self.dataByMakeIndex[MakeIndex] then
      self.dataByMakeIndex[MakeIndex] = item
   end
end

return HeroEquipData 