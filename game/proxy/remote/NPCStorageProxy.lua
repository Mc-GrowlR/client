local RemoteProxy = requireProxy("remote/RemoteProxy")
local NPCStorageProxy = class("NPCStorageProxy", RemoteProxy)
NPCStorageProxy.NAME = global.ProxyTable.NPCStorageProxy

function NPCStorageProxy:ctor()
    NPCStorageProxy.super.ctor(self)

    local StorageVO = requireVO("remote/StorageVO")
    self.VOdata = StorageVO.new()

    self.storageData = {}
    self.maxPage = 1    -- 仓库的最大页
    self.npcIndex = nil
    self.touchType = 0
    self.openedCount = 0
    self.pageIndex = 1
    self._schedule_id = nil  --请求存储的计时器 0.5s
end

function NPCStorageProxy:LoadConfig()
    local maxNum = SL:GetMetaValue("GAME_DATA","warehouse_max_num") or 240
    self.maxPage = math.ceil(maxNum / global.MMO.NPC_STORAGE_MAX_PAGE)
end

-- 获取仓库的最大页
function NPCStorageProxy:GetMaxPage()
    return self.maxPage
end

function NPCStorageProxy:SetStorageData(data)
    local newList = {}
    for _, v in ipairs(data) do
        local changeData = ChangeItemServersSendDatas(v)
        table.insert(newList, changeData)
    end

    self.storageData = newList or {}

    -- clear data
    self.VOdata:ClearItemData()
    -- 更新位置
    self.VOdata:AmendHistoryPos(newList)

    local makeindex = {}
    for _, v in ipairs(newList) do 
        local itemPos = self.VOdata:GetHistoryPos(v.MakeIndex) or self.VOdata:NewItemPos()
        if itemPos then
            self.VOdata:SetItemPosData(v.MakeIndex, itemPos)
        end
        self.VOdata:AddItem(v, itemPos)
    end 

    self.VOdata:SetPosMarkData()

    -- 重新排列数据
    self.storageData = {}
    local data = {}
    data = self.VOdata:GetStorageData()
    for i, v in pairs(data) do 
        local pos = self.VOdata:GetStoragePosByMakeIndex(v.MakeIndex)
        if pos then 
            self.storageData[pos] = v
        end 
    end 
end

function NPCStorageProxy:GetStorageData()
    return self.storageData
end

function NPCStorageProxy:SetStoragePageIndex(Index)
    self.pageIndex = math.min(Index or 1, self.maxPage)
end

function NPCStorageProxy:GetStoragePageIndex()
    return self.pageIndex
end

function NPCStorageProxy:GetStorageDataByPage(page)
    local newList = {}
    if not page then
        return newList
    end

    for k, v in pairs(self.storageData) do
        if v.Where == page then
            table.insert(newList, v)
        end
    end
    
    return newList
end

function NPCStorageProxy:SetNpcIndex(idx)
    self.npcIndex = idx
end

function NPCStorageProxy:GetNpcIndex()
    return self.npcIndex
end

function NPCStorageProxy:SetOpenSize(openCount)
    local size = SL:GetMetaValue("GAME_DATA","warehouse_num")
    local setBaseSize = size and tonumber(size)
    local base = setBaseSize or 24
    local open = openCount or 0
    self.openedCount = base + open
    if self.openedCount > 240 then 
        self.openedCount = 240
    end 
    self.VOdata:SetMaxStorage(self.openedCount)
    self.VOdata:SetNewStoragePosMark()
end

function NPCStorageProxy:GetOpenSize()
    return self.openedCount
end

function NPCStorageProxy:GetTouchType()
    return self.touchType
end

function NPCStorageProxy:SetTouchType(type)
    self.touchType = type
end

function NPCStorageProxy:CleanData()
    self.storageData = {}
    self.npcIndex = nil

    if self._schedule_id then
        UnSchedule(self._schedule_id)
        self._schedule_id = nil
    end
end

function NPCStorageProxy:AddStorageData(data, where)
    local itemData = data
    if not itemData or next(itemData) == nil then
        return
    end

    -- 记录位置
    local itemPos = self.VOdata:GetHistoryPos(itemData.MakeIndex) or self.VOdata:NewItemPos()
    if itemPos then
        self.VOdata:AddItem(itemData, itemPos)
        self.VOdata:SetItemPosData(itemData.MakeIndex, itemPos)
        self.VOdata:SetPosMarkData()
    end

    itemData.Where = where
    table.insert(self.storageData, itemData)
    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Storage_Update, where)

    local data = {
        opera = global.MMO.Operator_Add,
        item = itemData,
        page = where
    }
    SLBridge:onLUAEvent(LUA_EVENT_STORAGE_DATA_CHANGE, data)
end

function NPCStorageProxy:DeleteStorageData(data)
    if data and data.MakeIndex and self.storageData and next(self.storageData) then
        for k, v in pairs(self.storageData) do
            if data.MakeIndex and v.MakeIndex and data.MakeIndex == v.MakeIndex then
                -- 记录位置
                self.VOdata:SubItem(data.MakeIndex)
                self.VOdata:CleanItemPosData(data.MakeIndex)
                self.VOdata:SetPosMarkData()

                table.remove(self.storageData, k)
                global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Storage_Update, data.Where)

                local data = {
                    opera = global.MMO.Operator_Sub,
                    item = data,
                    page = data.Where
                }
                SLBridge:onLUAEvent(LUA_EVENT_STORAGE_DATA_CHANGE, data)
                break
            end
        end
    end
end

-- 更新物品的叠加数据
function NPCStorageProxy:UpdateStorageData(MakeIndex, nums)
    if MakeIndex then
        for _, v in pairs(self.storageData) do
            if v.MakeIndex and MakeIndex == v.MakeIndex then
                v.OverLap = nums
                global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Storage_Update, v.Where)

                local data = {
                    opera = global.MMO.Operator_Change,
                    item = v,
                    page = v.Where
                }
                SLBridge:onLUAEvent(LUA_EVENT_STORAGE_DATA_CHANGE, data)
                break
            end
        end
    end
end

function NPCStorageProxy:GetStorageDataByMakeIndex(MakeIndex)
    local MakeIndex = MakeIndex or 0
    local data = nil
    for _, v in pairs(self.storageData) do
        if MakeIndex and v.MakeIndex and MakeIndex == v.MakeIndex then
            data = v
            break
        end
    end
    return data
end

-- 整理仓库
function NPCStorageProxy:ArrangeStorageData(page)
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local function sortFunc(a, b)
        local powera = GUIFunction:GetEquipPower(a)
        local powerb = GUIFunction:GetEquipPower(b)
        if powera ~= powerb then
            return powera > powerb
        else
            local isBindA, bindIndexA = ItemConfigProxy:CheckItemBind(a.Index)
            local isBindB, bindIndexB = ItemConfigProxy:CheckItemBind(b.Index)
            if isBindA == isBindB then
                return a.Index < b.Index
            else
                return isBindA
            end
        end
    end 

    local data = {}
    for _, v in pairs(self.storageData) do
        table.insert(data, v)
    end
    if not data or next(data) == nil then 
        return 
    end 

    -- 按照战力排序
    table.sort(data, sortFunc)

    -- 更新位置
    self.VOdata:CleanStoragePosData()
    self.VOdata:AmendHistoryPos(data)
    self.VOdata:SetPosMarkData()

    -- 重新排列数据
    self.storageData = {}
    local data = {}
    data = self.VOdata:GetStorageData()
    for i, v in pairs(data) do 
        local pos = self.VOdata:GetStoragePosByMakeIndex(v.MakeIndex)
        if pos then 
            self.storageData[pos] = v
        end 
    end 

    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Storage_Update, page)

    local data = {
        opera = 4,  -- 整理/刷新页
        page = page
    }
    SLBridge:onLUAEvent(LUA_EVENT_STORAGE_DATA_CHANGE, data)
end 

-- 请求存储
function NPCStorageProxy:RequestSaveToStorage(MakeIndex, Name)
    local npcIndex = self:GetNpcIndex()
    if not npcIndex then
        return
    end

    if not self:CheckPutInStorageState() or self._schedule_id then
        local systipStr = self._schedule_id and GET_STRING(90100005) or GET_STRING(90100004)
        global.Facade:sendNotification(global.NoticeTable.SystemTips, systipStr)

        -- 背包中的重新刷出来
        local data = {
            storage = {
                state = 1,
                MakeIndex = MakeIndex,
            }
        }
        global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
        return
    end

    self._schedule_id = PerformWithDelayGlobal(function()
        self._schedule_id = nil
    end, 0.3)

    local pageIndex = self:GetStoragePageIndex() or 1
    LuaSendMsg(global.MsgType.MSG_CS_STORAGE_STORE_REQUEST, npcIndex, MakeIndex, pageIndex, 0, Name, string.len(Name))
end

function NPCStorageProxy:RequestSaveToStorageAllPage(MakeIndex, Name)
    --请求存储
    local npcIndex = self:GetNpcIndex()
    if not npcIndex then
        return
    end
    local pageIndex = 1
    for i = 1, self.maxPage do
        local index = i
        local openCount = self.openedCount
        local pageData = self:GetStorageDataByPage(index)
        local itemCount = #pageData
        local thisPageOpenCount = openCount - (index-1) * global.MMO.NPC_STORAGE_MAX_PAGE
        if thisPageOpenCount > global.MMO.NPC_STORAGE_MAX_PAGE then
            thisPageOpenCount = global.MMO.NPC_STORAGE_MAX_PAGE
        end
        if itemCount < thisPageOpenCount then
            pageIndex = i
            break
        end
        pageIndex = nil
    end
    if not pageIndex or self._schedule_id then
        local systipStr = self._schedule_id and GET_STRING(90100005) or GET_STRING(90100004)
        global.Facade:sendNotification(global.NoticeTable.SystemTips, systipStr)
        -- 背包中的重新刷出来
        local data = {
            storage = {
                MakeIndex = MakeIndex,
                state = 1
            }
        }
        global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
        return
    end

    self._schedule_id = PerformWithDelayGlobal(function()
        self._schedule_id = nil
    end, 0.3)
    LuaSendMsg(global.MsgType.MSG_CS_STORAGE_STORE_REQUEST, npcIndex, MakeIndex, pageIndex, 0, Name, string.len(Name))
end

function NPCStorageProxy:CheckPutInStorageState()
    local index = self:GetStoragePageIndex()
    local pageData = self:GetStorageDataByPage(index)
    local itemCount = #pageData
    local thisPageOpenCount = self.openedCount - (index - 1) * global.MMO.NPC_STORAGE_MAX_PAGE

    local isWinMode = SL:GetMetaValue("WINPLAYMODE")
    local storage_row_col = SL:GetMetaValue("GAME_DATA", "bag_storage_row_col_max")
    local bBig = false  -- 是否大仓库
    if isWinMode and storage_row_col then
        local slices = string.split(storage_row_col, "|")
        local row = tonumber(slices[1]) or 8
        local col = tonumber(slices[2]) or 6
        if row * col > global.MMO.NPC_STORAGE_MAX_PAGE then 
            bBig = true
        end 
    end 
    if not bBig and thisPageOpenCount > global.MMO.NPC_STORAGE_MAX_PAGE then
        thisPageOpenCount = global.MMO.NPC_STORAGE_MAX_PAGE
    end
    return itemCount < thisPageOpenCount
end

--请求仓库数据
function NPCStorageProxy:RequestStorageData()
    LuaSendMsg(global.MsgType.MSG_CS_STORAGEDATA_REQUEST, 0, 0, 0, 0, 0, 0)
end

-- 请求取出
function NPCStorageProxy:RequestPutOutStorageData(MakeIndex, Name)
    local npcIndex = self:GetNpcIndex()
    if not npcIndex then
        return
    end

    -- 背包已满，仓库中重新刷出来
    local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
    if BagProxy:isToBeFull(true) then
        local data = {
            resetItem = {
                state = 1,
                MakeIndex = MakeIndex,
            }
        }
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Storage_Item_State, data)
        return
    end

    LuaSendMsg(global.MsgType.MSG_CS_STORAGE_PICK_OUT_REQUEST, npcIndex, MakeIndex, 0, 0, Name, string.len(Name))
end

function NPCStorageProxy:handle_MSG_SC_STOR_DATA(msg)
    dump("handle_MSG_SC_STOR_DATA___")
    local data = ParseRawMsgToJson(msg)
    if not data or not next(data) then
        return
    end

    self:CleanData()

    self:SetOpenSize(data.Count)

    self:SetStorageData(data.Items)

    self:SetNpcIndex(data.index)

    local npcProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    npcProxy:Cleanup()

    local header = msg:GetHeader()
    local isself = header.recog == 1 --是自己请求的还是脚本发的
    if not isself then
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Storage_Open)
    end
end

function NPCStorageProxy:handle_MSG_SC_STORAGE_STORE_STORED_ADD(msg)
    print("存仓成功")
    local header = msg:GetHeader()
    local MakeIndex = header.recog
    if MakeIndex and MakeIndex ~= 0 then
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        local item = BagProxy:GetItemDataByMakeIndex(MakeIndex)
        if item then
            local pageIdnex = header.param1
            self:AddStorageData(item, pageIdnex)
            BagProxy:DelItemData(item, true)
        end
    end
end

function NPCStorageProxy:handle_MSG_SC_STORAGE_STORE_FULL(msg)
    print("存仓失败， 仓库满")
    local header = msg:GetHeader()
    local MakeIndex = header.recog
    if MakeIndex then
        -- 背包中的重新刷出来
        local data = {
            storage = {
                state = 1,
                MakeIndex = MakeIndex,
            }
        }
        global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
    end
end

function NPCStorageProxy:handle_MSG_SC_STORAGE_STORE_FORBIDDEN(msg)
    print("存仓失败")
    local header = msg:GetHeader()
    local MakeIndex = header.recog
    if MakeIndex then
        -- 背包中的重新刷出来
        local data = {
            storage = {
                state = 1,
                MakeIndex = MakeIndex,
            }
        }
        global.Facade:sendNotification(global.NoticeTable.Bag_State_Change, data)
    end
end

function NPCStorageProxy:handle_MSG_SC_STORAGE_PICK_OUT_FORBIDDEN(msg)
    print("取出失败")
    local header = msg:GetHeader()
    local MakeIndex = header.recog
    if MakeIndex then
        -- 仓库中重新刷出来
        local data = {
            resetItem = {
                state = 1,
                MakeIndex = MakeIndex,
            }
        }
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Storage_Item_State, data)
    end
end

function NPCStorageProxy:handle_MSG_SC_STORAGE_PICK_OUT_SUCC(msg)
    print("取出成功")
    local header = msg:GetHeader()
    local MakeIndex = header.recog
    if MakeIndex and MakeIndex ~= 0 then
        local item = self:GetStorageDataByMakeIndex(MakeIndex)
        if item then
            self:DeleteStorageData(item)
        end
    end

end

function NPCStorageProxy:handle_MSG_SC_STORAGE_PICK_OUT_FULL(msg)
    print("背包满 取出失败")
    local header = msg:GetHeader()
    local MakeIndex = header.recog
    if MakeIndex then
        -- 背包已满，仓库中重新刷出来
        local data = {
            resetItem = {
                state = 1,
                MakeIndex = MakeIndex,
            }
        }
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Storage_Item_State, data)
    end
end

function NPCStorageProxy:handle_MSG_SC_STORAGE_UPDATE(msg)
    local header = msg:GetHeader()
    local MakeIndex = header.recog
    if MakeIndex and MakeIndex ~= 0 then
        local itemNums = header.param1
        self:UpdateStorageData(MakeIndex, itemNums)

        local bagMakeIndex = ParseRawMsgToJson(msg)
        local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
        local item = BagProxy:GetItemDataByMakeIndex(bagMakeIndex)

        if item then
            BagProxy:DelItemData(item, true)
        end
    end
end

function NPCStorageProxy:handle_MSG_SC_STORAGE_COUNT_CHANGE(msg)
    local header = msg:GetHeader()
    local count = header.recog
    self:SetOpenSize(count)

    global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Storage_Size_Change)
end

function NPCStorageProxy:RegisterMsgHandler()
    NPCStorageProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType
    
    -- 仓库数据
    LuaRegisterMsgHandler(msgType.MSG_SC_STOR_DATA, handler(self, self.handle_MSG_SC_STOR_DATA))
    -- 存仓成功
    LuaRegisterMsgHandler(msgType.MSG_SC_STORAGE_STORE_STORED_ADD, handler(self, self.handle_MSG_SC_STORAGE_STORE_STORED_ADD))
    -- 仓库满 存仓失败
    LuaRegisterMsgHandler(msgType.MSG_SC_STORAGE_STORE_FULL, handler(self, self.handle_MSG_SC_STORAGE_STORE_FULL))
    -- 其他 存仓失败
    LuaRegisterMsgHandler(msgType.MSG_SC_STORAGE_STORE_FORBIDDEN, handler(self, self.handle_MSG_SC_STORAGE_STORE_FORBIDDEN))
    -- 其他 取出失败
    LuaRegisterMsgHandler(msgType.MSG_SC_STORAGE_PICK_OUT_FORBIDDEN, handler(self, self.handle_MSG_SC_STORAGE_PICK_OUT_FORBIDDEN))
    -- 取出成功
    LuaRegisterMsgHandler(msgType.MSG_SC_STORAGE_PICK_OUT_SUCC, handler(self, self.handle_MSG_SC_STORAGE_PICK_OUT_SUCC))
    -- 背包满 取出失败
    LuaRegisterMsgHandler(msgType.MSG_SC_STORAGE_PICK_OUT_FULL, handler(self, self.handle_MSG_SC_STORAGE_PICK_OUT_FULL))
    --仓库，存物品时候，存的叠加物品，需要更新
    LuaRegisterMsgHandler(msgType.MSG_SC_STORAGE_UPDATE, handler(self, self.handle_MSG_SC_STORAGE_UPDATE))
    -- 仓库格子数增加
    LuaRegisterMsgHandler(msgType.MSG_SC_STORAGE_COUNT_CHANGE, handler(self, self.handle_MSG_SC_STORAGE_COUNT_CHANGE))
end

return NPCStorageProxy