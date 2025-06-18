local StorageVO = class( "StorageVO" )

function StorageVO:ctor()
   self.posMark = {}   --仓库位置 有序 k = pos
   self.posData = {}   --仓库位置 k = makeindex
   self.storageVo = {} --仓库数据 k = maekindex
   self.itemCount = 0
   self.storageMax = global.MMO.NPC_STORAGE_MAX_PAGE
   self.itemCountByIndex = {}
   self.isInited = false

   self:InitStoragePosMark()
end

function StorageVO:InitStoragePosMark()
   local storagePosData = self:GetPosMarkData()
   if not self.isInited or not storagePosData then 
      for i = 1, self.storageMax do
         self.posMark[i] = 0
      end
      self:SetPosMarkData()
   else 
      self.posMark = storagePosData
   end 
end

function StorageVO:SetMaxStorage(maxStorage)
   self.storageMax = maxStorage
end

function StorageVO:GetMaxStorage()
   return self.storageMax or 0
end

function StorageVO:SetNewStoragePosMark()
   local newPosMark = {}
   for i = 1, self.storageMax do
       if not self.posMark[i] or self.posMark[i] == 0 then
           newPosMark[i] = 0
       else
           newPosMark[i] = self.posMark[i]
       end
   end
   self.posMark = newPosMark
end

function StorageVO:GetHistoryPos(MakeIndex)
   for k, v in pairs(self.posMark) do
      if v == MakeIndex then
         return k
      end
   end
   return nil
end

-- 从头开始 找到空位就返回pos
function StorageVO:NewItemPos()
   for i = 1, self.storageMax do
      if self.posMark[i] and self.posMark[i] == 0 then
         return i
      end
   end
   return nil
end

-- 保存位置数据
function StorageVO:SetItemPosData(MakeIndex, pos)
   self.posData[MakeIndex] = pos
   if pos then
      self.posMark[pos] = MakeIndex
   end
end

-- 增
function StorageVO:AddItem(item, pos)
   local MakeIndex = item.MakeIndex
   if pos then
      self.storageVo[MakeIndex] = item
      self.itemCount = self.itemCount + 1
      self:ChangeItemCountByIndex(item.Index, item.OverLap)
   end
end

-- 删
function StorageVO:SubItem(MakeIndex)
   if self.storageVo[MakeIndex] then
      local item = self.storageVo[MakeIndex]
      self:ChangeItemCountByIndex(item.Index,-item.OverLap)
      self.storageVo[MakeIndex] = nil
      self.itemCount = self.itemCount - 1
   end
end

-- 改
function StorageVO:AmendHistoryPos(data)
   if not data then
      return
   end

   local newItems = {}
   local newPosMark = {}
   for i = 1, self.storageMax do 
      newPosMark[i] = 0
   end 

   for i, item in pairs(data) do
      local historyPos = self:GetHistoryPos(item.MakeIndex)
      if historyPos then
         newPosMark[historyPos] = item.MakeIndex
      else
         table.insert(newItems, item)
      end
   end

   for i = 1, #newPosMark do 
      self.posMark[i] = newPosMark[i]
   end 
 
   for i, v in ipairs(newItems) do
      local newPos = self:NewItemPos()
      if newPos then 
         self.posMark[newPos] = v.MakeIndex
         self.posData[v.MakeIndex] = newPos
      end 
   end
end

function StorageVO:ChangeItemCountByIndex(Index, diff)
   if not Index then
      return
   end
   if not self.itemCountByIndex then
      self.itemCountByIndex = {}
   end
   local diffCount = diff or 0
   local oldCount = self.itemCountByIndex[Index] or 0
   local newCount = oldCount + diffCount
   self.itemCountByIndex[Index] = newCount > 0 and newCount or 0
end

function StorageVO:CleanItemPosData(MakeIndex)
   local historyPos = self.posData[MakeIndex]
   if historyPos then
      self.posData[MakeIndex] = nil
      self.posMark[historyPos] = 0
   end 

   local newPosMark = {}
   for i = 1, self.storageMax do
      newPosMark[i] = 0
   end

   local temp = {}
   for i = 1, self.storageMax do 
      if self.posMark[i] > 0 then 
         table.insert(temp, self.posMark[i])
      end  
   end 

   for i, makeindex in ipairs(temp) do 
      newPosMark[i] = makeindex
      if self.posData[makeindex] then 
         self.posData[makeindex] = i
      end 
   end 

   self.posMark = newPosMark
end

function StorageVO:CleanStoragePosData()
   self.posMark = {}
   self.posData = {}
   for i = 1, self.storageMax do
      self.posMark[i] = 0
   end
end

function StorageVO:ClearItemData()
   self.storageVo = {}
   self.itemCount = 0
   self.itemCountByIndex = {}
end

function StorageVO:GetStorageData()
   return self.storageVo
end

function StorageVO:GetStoragePosByMakeIndex(MakeIndex)
   return self.posData[MakeIndex]
end

-- 本地仓库位置信息
function StorageVO:GetPosMarkData()
   local PosData = UserData:new("NPCStoragePosData")
   local proxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
   local flag = proxy:GetSelectedRoleID() or "errorName"

   local inited = PosData:getBoolForKey("storage_inited"..flag)
   if not inited then 
      self.isInited = false
      PosData:setBoolForKey( "storage_inited"..flag, true )
   else 
      self.isInited = true
   end 

   local clientData = PosData:getStringForKey( "storage"..flag )
   if not clientData or clientData == "" then
      return nil
   end

   local cjson = require( "cjson" )
   local lastJsonData = cjson.decode(clientData)
   return lastJsonData
end

function StorageVO:SetPosMarkData()
   local PosData = UserData:new("NPCStoragePosData")
   local proxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
   local flag = proxy:GetSelectedRoleID() or "errorName"
   local cjson = require( "cjson" )
   local storagePosData = cjson.encode(self.posMark)
   local clientData = PosData:setStringForKey( "storage"..flag, storagePosData )
end

return StorageVO