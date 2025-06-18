local RemoteProxy = requireProxy("remote/RemoteProxy")
local HeroBagProxy = class("HeroBagProxy", RemoteProxy)
HeroBagProxy.NAME = global.ProxyTable.HeroBagProxy

local tinsert = table.insert

local function MAKE_OPER_DATA(item, isHad, number)
    local operator = {}
    operator.item = item
    operator.isHad = isHad
    operator.change = number
    operator.MakeIndex = item.MakeIndex
    return operator
end
HeroBagProxy.BAG_SELECT_TYPE = {
    TYPE_ALL   = 0, -- 全部
    TYPE_EQUIP = 1, -- 装备
    TYPE_EXP   = 2, -- 经验
    TYPE_REIN  = 3, -- 转生
    TYPE_PET   = 4, -- 宠物
    TYPE_OTHER = 5  -- 其他
}

local bag_Level = {[10] = 1, [20] = 2, [30] = 3, [35] = 4, [40] = 5}

function HeroBagProxy:ctor()
    HeroBagProxy.super.ctor(self)

    local BagVO = requireVO("remote/HeroBagVO")
    self.VOdata = BagVO.new()

    self.m_maxNum       = 40        -- 服务端发的英雄最大背包格子数
    self.m_level        = 5
    self._prompt_data   = nil       -- cfg_game_data的prompt
    self._selfDropItems = {}        -- 英雄丢弃的物品
    self._on_sell_repaire = nil     -- 正在交易或者修理中物品
    self._collimator_MakeIndex = nil    -- 记录背包选中的准星道具
end

function HeroBagProxy:setBagMaxNum(num)
    self.m_maxNum = num
    self.m_level = bag_Level[num] or 5
end

function HeroBagProxy:getBagMaxNum()
    return self.m_maxNum
end

function HeroBagProxy:getBagLevel()
    return self.m_level
 end

function HeroBagProxy:GetSelfDropItems()
    return self._selfDropItems
end

-- item提示：类似右上角满 获取cfg_game_data表的prompt字段的数据
function HeroBagProxy:GetPromptGameData()
    if not self._prompt_data then
        self._prompt_data = {}
        local prompt = SL:GetMetaValue("GAME_DATA","prompt")
        if prompt and string.len(prompt) then
            local promptArray = string.split(prompt, "|")
            for _, v in ipairs(promptArray) do
                if v and string.len(v) > 0 then
                    local valueArray = string.split(v, "#")
                    tinsert(self._prompt_data, {
                        resPath = valueArray[1],
                        posX = valueArray[2] and tonumber(valueArray[2]) or nil,
                        posY = valueArray[3] and tonumber(valueArray[3]) or nil,
                        resScale = valueArray[4] and tonumber(valueArray[4]) or nil
                    })
                end
            end
        end
    end

    if global.isWinPlayMode then
        return self._prompt_data[1] or {}
    end

    return self._prompt_data[2] or {}
end


function HeroBagProxy:Inited(bool)
    self.VOdata:Inited(bool)
end

function HeroBagProxy:GetBagData()
    return self.VOdata:GetBagData()
end

function HeroBagProxy:GetTotalItemCount()
    return self.VOdata:GetItemCount()
end

function HeroBagProxy:isToBeFull(tips)
    if tips and self.VOdata:isFull() then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(800050))
    end
    return self.VOdata:isFull()
end

function HeroBagProxy:CheckNeedSpace(itemID, itemCount, tips)
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local itemData = ItemConfigProxy:GetItemDataByIndex(itemID)
    local isLap = ItemConfigProxy:CheckItemOverLap(itemData)
    local needPos = itemCount
    if isLap then
        needPos = math.ceil(itemCount / itemData.OverLap)
    end
    local bagItemNum = self:GetTotalItemCount()
    if bagItemNum + needPos > self.m_maxNum then
        if tips then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(1021))
        end
        return false
    end
    return true
end

-- 通过唯一id获取在背包中的位置
function HeroBagProxy:GetBagPosByMakeIndex(MakeIndex)
    return self.VOdata:GetBagPosByMakeIndex(MakeIndex)
end

-- 通过在背包中的位置获取唯一id
function HeroBagProxy:GetMakeIndexByBagPos(pos)
    return self.VOdata:GetMakeIndexByBagPos(pos)
end

-- 通过唯一id获取物品数据
function HeroBagProxy:GetItemDataByMakeIndex(MakeIndex)
    return self.VOdata:GetItemByMakeIndex(MakeIndex)
end

-- 获取新位置
function HeroBagProxy:NewItemPos()
    return self.VOdata:NewItemPos()
end

-- 修正历史数据与当前数据位置信息
function HeroBagProxy:AmendHistoryPos(data, sort)
    self.VOdata:AmendHistoryPos(data, sort)
end

-- 清理背包数据及位置
function HeroBagProxy:CleanBagPosData()
    self.VOdata:CleanBagPosData()
end

-- 通过itemIndex获取物品数据
function HeroBagProxy:GetItemDataByItemIndex(itemIndex)
    local someItems = {}
    if not itemIndex then
        return someItems
    end
    local items = self:GetBagData()
    for _, v in pairs(items) do
        if v.Index == itemIndex then
            tinsert(someItems, v)
        end
    end
    return someItems
end

-- 通过物品名称获取物品数据
function HeroBagProxy:GetItemDataByItemName(itemName)
    if not itemName then
        return nil
    end
    local someItems = {}
    local items = self:GetBagData()
    for _, v in pairs(items) do
        if v.Name == itemName then
            tinsert(someItems, v)
        end
    end
    if not next(someItems) then
        return nil
    end
    return someItems
end

-- 通过itemIndex获取物品数量 famlilar是否包含绑定数量
function HeroBagProxy:GetItemCountByIndex(Index, famlilar)
    Index = Index or 0
    local count = 0
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local isBind, bindIndex = ItemConfigProxy:CheckItemBind(Index)
    local myCount = self.VOdata:GetItemCountByIndex(Index)
    local famlilarCount = 0
    if isBind and bindIndex ~= Index and famlilar then
        famlilarCount = self.VOdata:GetItemCountByIndex(bindIndex)
    end
    local totalCount = myCount + famlilarCount
    return totalCount
end

-- 设置正在交易或修理中
function HeroBagProxy:SetOnSellOrRepaire(MakeIndex)
    self._on_sell_repaire = MakeIndex
    global.Facade:sendNotification(global.NoticeTable.HeroBag_Item_Pos_Change)
end

-- 获取是否在交易或修理
function HeroBagProxy:GetOnSellOrRepaire()
    return self._on_sell_repaire
end

-- 清理交易或修理
function HeroBagProxy:CleanOnSellOrRepaire()
    self._on_sell_repaire = nil
    global.Facade:sendNotification(global.NoticeTable.HeroBag_Item_Pos_Change)
end

-- 添加物品
function HeroBagProxy:AddItemData(item, noNotice)
    if not item then
        return
    end

    local itemPos = self.VOdata:GetHistoryPos(item.MakeIndex) or self:NewItemPos()
    if itemPos then
        self.VOdata:SetItemPosData(item.MakeIndex, itemPos)
    end

    if not noNotice then
        self:ShowGetOrCostItems(item.OverLap or 1, item.Name)
    end

    self.VOdata:AddItem(item, itemPos)

    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    ItemManagerProxy:SetItemBelong(item.MakeIndex, global.MMO.ITEM_FROM_BELONG_HEROBAG)
end

-- 显示获得或消耗物品
function HeroBagProxy:ShowGetOrCostItems(diff, name)
    if self.VOdata:IsInited() then
        return
    end

    local nData = {}
    nData.name = name
    nData.num = math.abs(diff)
    local notice = diff > 0 and global.NoticeTable.ShowGetBagItem_Hero or global.NoticeTable.ShowCostItem_Hero
    global.Facade:sendNotification(notice, nData)
end

-- 增加物品并通知
function HeroBagProxy:AddItemDataAndNotice(item)
    self:AddItemData(item)

    local operator = {}
    operator.opera = global.MMO.Operator_Add
    operator.operID = {}
    tinsert(operator.operID, MAKE_OPER_DATA(item, false))
    global.Facade:sendNotification(global.NoticeTable.HeroBag_Oper_Data, operator)
    SLBridge:onLUAEvent(LUA_EVENT_HERO_BAG_ITEM_CAHNGE, operator)
end

-- 删除物品
function HeroBagProxy:DelItemData(data, showTip, noCleanPos, noNotify)
    if not data or not next(data) then
        return
    end

    local MakeIndex = data.MakeIndex
    local itemHasPos = true
    local noPosData = self.VOdata:GetBagNoPosDataByMakeIndex(MakeIndex)
    local item = self:GetItemDataByMakeIndex(MakeIndex)

    if noPosData then
        itemHasPos = false
        item = noPosData
    end

    if item then
        if not self.VOdata:IsInited() then
            global.Facade:sendNotification(global.NoticeTable.Layer_Auto_Use_UnAttach, { id = item.MakeIndex })
        end

        local operator = {}
        operator.opera = global.MMO.Operator_Sub
        operator.operID = {}
        local operitem = self:BagOperItemByMakeIndex(MakeIndex, itemHasPos)
        tinsert(operator.operID, operitem)

        self.VOdata:SubItem(MakeIndex)

        if not noCleanPos then
            self.VOdata:CleanItemPosData(MakeIndex)
        end

        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
        ItemManagerProxy:SetItemBelong(item.MakeIndex, nil)

        if not noNotify then
            global.Facade:sendNotification(global.NoticeTable.HeroBag_Oper_Data, operator)
            SLBridge:onLUAEvent(LUA_EVENT_HERO_BAG_ITEM_CAHNGE, operator)
        end

        if showTip then
            self:ShowGetOrCostItems(-(item.OverLap or 1), item.Name)
        end

        -- 缓存中的数据自动补充到背包
        local noPosData = self.VOdata:GetBagNoPosData()
        if noPosData and next(noPosData) and itemHasPos then
            for _, v in pairs(noPosData) do
                if v and next(v) then
                    self:DelItemData(v, nil, nil, true)
                    self:AddItemDataAndNotice(v, true)
                    break
                end
            end
        end
    end
end

function HeroBagProxy:BagOperItemByMakeIndex(MakeIndex, isShowInBag)
    local item = self:GetItemDataByMakeIndex(MakeIndex)
    if not isShowInBag then
        item = self.VOdata:GetBagNoPosDataByMakeIndex(MakeIndex)
    end

    local operator = {}
    if item then
        local MakeIndex = item.MakeIndex
        operator.MakeIndex = MakeIndex
        operator.item = item
    end
    return operator
end

-- 更改物品数据
function HeroBagProxy:ChangeItemData(item)
    local makeIndex = item.MakeIndex
    local newnum = item.OverLap or 1
    local diff = 0
    local data = self:GetItemDataByMakeIndex(makeIndex)
    if data then
        local oldnum = data.OverLap or 1
        diff = newnum - oldnum
        self.VOdata:ChangeItem(item)
        if diff ~= 0 then
            self:ShowGetOrCostItems(diff, item.Name)
        end
    end
    return diff
end

-- 清理背包
function HeroBagProxy:ClearItemData()
    local array = self.VOdata:GetBagData()
    for key, var in pairs(array) do
        self:DelItemData(var, nil, true)
    end

    local arrayNoPos = self.VOdata:GetBagNoPosData()
    for _, item in pairs(arrayNoPos) do
        self:DelItemData(item)
    end

    self.VOdata:ClearItemData()
end

-- 换位
function HeroBagProxy:ExchangePos(MakeIndex1, pos1, MakeIndex2, pos2)
    self.VOdata:CleanItemPosData(MakeIndex1)
    self.VOdata:CleanItemPosData(MakeIndex2)
    self.VOdata:SetItemPosData(MakeIndex1, pos1)
    self.VOdata:SetItemPosData(MakeIndex2, pos2)
    global.Facade:sendNotification(global.NoticeTable.HeroBag_Item_Pos_Change, { MakeIndex1, MakeIndex2 })
end

-- 修改位置数据
function HeroBagProxy:SetItemPosData(MakeIndex, pos)
    self.VOdata:CleanItemPosData(MakeIndex)
    self.VOdata:SetItemPosData(MakeIndex, pos)
    global.Facade:sendNotification(global.NoticeTable.HeroBag_Item_Pos_Change, { MakeIndex })
end

-- 获取背包道具的使用状态(0：使用 1：使用准星道具 2：取消准星 3：不可使用)
function HeroBagProxy:GetOnBagItemUseState(data)
    if self._collimator_MakeIndex then
        if self._collimator_MakeIndex == -1 then -- 脚本
            return 1
        end

        if data and self._collimator_MakeIndex == data.MakeIndex then
            return 2
        end

        return 1
    end

    return 0
end

-- 设置准星道具
function HeroBagProxy:SetBagCollimator(data)
    self._collimator_MakeIndex = data
end

-- 获取准星道具
function HeroBagProxy:GetBagCollimator()
    return self._collimator_MakeIndex
end

-- 清理准星道具
function HeroBagProxy:ClearBagCollimator()
    self._collimator_MakeIndex = nil
end
-- 背包数据初始化
function HeroBagProxy:handle_MSG_SC_RETURN_BAGDATA_HERO(msg)
    local header = msg:GetHeader()
    local data = ParseRawMsgToJson(msg)
    -- print("------------------------------------")
    -- print(" into here to get and set bag data")
    -- print("------------------------------------")
    if not data then
        return
    end

    local changedData = {}
    for _, v in ipairs(data) do
        local changeData = ChangeItemServersSendDatas(v)
        tinsert(changedData, changeData)
    end
    data = changedData

    -- 排序整理
    if header.recog == 1 then
        self:CleanBagPosData()
        self:AmendHistoryPos(data, true)
        global.Facade:sendNotification(global.NoticeTable.HeroBag_Pos_Reset)
        SLBridge:onLUAEvent(LUA_EVENT_REF_HERO_ITEM_LIST)
    else
        --清理缓存
        self:ClearItemData()

        --修正本地位置信息数据
        self:AmendHistoryPos(data)

        local history = {}
        for key, var in pairs(self.VOdata:GetBagData()) do
            history[var.MakeIndex] = var.MakeIndex
        end

        local operator = {}
        operator.initbool = false
        operator.opera = global.MMO.Operator_Init
        operator.operID = {}

        for _, item in pairs(data) do
            self:AddItemData(item)

            if not history[item.MakeIndex] then
                tinsert(operator.operID, MAKE_OPER_DATA(item, false))
            end
        end
        
        if not self.reconnet then
            global.Facade:sendNotification(global.NoticeTable.HeroBag_Oper_Data, operator)
            SLBridge:onLUAEvent(LUA_EVENT_HERO_BAG_ITEM_CAHNGE, operator)
        elseif self.reconnet then
            self.reconnet = false
        end

        -- 是否初始化
        if self.VOdata:IsInited() then
            self:Inited(false)
        end
    end
end

-- 增加道具
function HeroBagProxy:handle_MSG_SC_BAG_ADD_ITEM_HERO(msg)
    local header = msg:GetHeader()
    local recog = header.recog
    local data = ParseRawMsgToJson(msg)
    -- print("------------------------------------")
    -- print(" into here to add bag item")
    -- print("------------------------------------")
    if not recog or not data or next(data) == nil then
        return
    end

    if recog == -1 then
        data = ChangeItemServersSendDatas(data)
        self:AddItemData(data)

        local operator = {}
        operator.opera = global.MMO.Operator_Add
        operator.operID = {}
        tinsert(operator.operID, MAKE_OPER_DATA(data, false))
        global.Facade:sendNotification(global.NoticeTable.HeroBag_Oper_Data, operator)
        SLBridge:onLUAEvent(LUA_EVENT_HERO_BAG_ITEM_CAHNGE, operator)
    else
        data = ChangeItemServersSendDatas(data)
        local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
        data.Where = recog
        HeroEquipProxy:AddEquipData(data)
    end
end

-- 删除道具
function HeroBagProxy:handle_MSG_SC_BAG_DEL_ITEM_HERO(msg)
    local data = ParseRawMsgToJson(msg)
    -- print("------------------------------------")
    -- print(" into here to delete bag item")
    -- print("------------------------------------")
    if not data or next(data) == nil then
        return
    end

    local itemMakeIndex = data.MakeIndex or data.makeindex
    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    local itemBelong = ItemManagerProxy:GetItemBelong(itemMakeIndex)
    if not itemBelong then
        return
    end

    data = ChangeItemServersSendDatas(data)

    if itemBelong == global.MMO.ITEM_FROM_BELONG_HEROBAG then
        self:DelItemData(data, true)

    elseif itemBelong == global.MMO.ITEM_FROM_BELONG_HEROEQUIP then
        local HeroEquipProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
        HeroEquipProxy:DelEquipData(data)
    end
end

-- 更新道具
function HeroBagProxy:handle_MSG_SC_BAG_UPDATE_ITEM_HERO(msg)
    local data = ParseRawMsgToJson(msg)
    -- print("------------------------------------")
    -- print(" into here to update herobag item")
    -- print("------------------------------------")
    if not data or next(data) == nil then
        return
    end

    local itemMakeIndex = data.MakeIndex or data.makeindex
    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    local itemBelong = ItemManagerProxy:GetItemBelong(itemMakeIndex)
    if not itemBelong then
        return
    end

    data = ChangeItemServersSendDatas(data)

    if global.MMO.ITEM_FROM_BELONG_HEROBAG == itemBelong then
        local operator = {}
        operator.opera = global.MMO.Operator_Change
        operator.operID = {}
        local diff = self:ChangeItemData(data)
        tinsert(operator.operID, MAKE_OPER_DATA(data, true, diff))
        global.Facade:sendNotification(global.NoticeTable.HeroBag_Oper_Data, operator)
        SLBridge:onLUAEvent(LUA_EVENT_HERO_BAG_ITEM_CAHNGE, operator)
    elseif global.MMO.ITEM_FROM_BELONG_HEROEQUIP == itemBelong then
        local proxy = global.Facade:retrieveProxy(global.ProxyTable.HeroEquipProxy)
        proxy:ChangeEquipData(data, true, true)
    end

    -- for item update.
    local updateData =    {
        from = itemBelong,
        item = data,
    }
    global.Facade:sendNotification(global.NoticeTable.ItemUpdate, updateData)
end

-- 道具使用失败
function HeroBagProxy:handle_MSG_SC_BAG_ITEM_USE_FAILED_HERO(msg)
    print("道具使用失败消息")
    local header = msg:GetHeader()
    local makeIndex = header.recog
    local itemData = self:GetItemDataByMakeIndex(makeIndex)
    if itemData and itemData.StdMode == 49 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000321))
    end
end

-- 道具拾取失败 -1背包满 -2负重满 -3物品禁止拾取
function HeroBagProxy:handle_MSG_SC_DROP_ITEM_GET_FAILED(msg)
    local header = msg:GetHeader()
    local recog = header.recog
    if recog == -1 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(800050))
    elseif recog == -2 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(800052))
    elseif recog == -3 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(800056))
    end
end

-- 丢弃道具成功
function HeroBagProxy:handle_MSG_SC_DROP_ITEM_SUCCESS(msg)
    local header = msg:GetHeader()
    local MakeIndex = header.recog
    if MakeIndex then
        tinsert(self._selfDropItems, MakeIndex)
        if #self._selfDropItems > 100 then  -- 记录自己丢弃的物品   挂机拾取的时候忽略
            table.remove(self._selfDropItems, 1)
        end

        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
        local belong = ItemManagerProxy:GetItemBelong(MakeIndex)
        if global.MMO.ITEM_FROM_BELONG_HEROBAG == belong then
            -- 背包中的重新刷出来
            local data = {
                dropping = {
                    MakeIndex = MakeIndex,
                    state = 1
                }
            }
            global.Facade:sendNotification(global.NoticeTable.HeroBag_State_Change, data)
        end
    end
end

-- 丢弃道具失败
function HeroBagProxy:handle_MSG_SC_DROP_ITEM_FAILED(msg)
    local header = msg:GetHeader()
    local MakeIndex = header.recog
    if MakeIndex then
        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
        local belong = ItemManagerProxy:GetItemBelong(MakeIndex)
        if global.MMO.ITEM_FROM_BELONG_HEROBAG == belong then
            -- 背包中的重新刷出来
            local data = {
                dropping = {
                    MakeIndex = MakeIndex,
                    state = 1
                }
            }
            global.Facade:sendNotification(global.NoticeTable.HeroBag_State_Change, data)
        end
    end
end

-- 英雄背包到人物背包失败
function HeroBagProxy:handle_MSG_SC_HEROBAG_TO_HUMBAG_FAIL(msg)
    local header = msg:GetHeader()
    local MakeIndex = header.recog
    dump(header, "handle_MSG_SC_HEROBAG_TO_HUMBAG_FAIL")

    if MakeIndex then
        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
        local belong = ItemManagerProxy:GetItemBelong(MakeIndex)
        if global.MMO.ITEM_FROM_BELONG_HEROBAG == belong then
            -- 背包中的重新刷出来
            local data = {
                dropping = {
                    MakeIndex = MakeIndex,
                    state = 1
                }
            }
            global.Facade:sendNotification(global.NoticeTable.HeroBag_State_Change, data)
        end
    end
end

-- 叠加道具
function HeroBagProxy:RequestItemTwoToOne(MakeIndex1, MakeIndex2)
    LuaSendMsg(global.MsgType.MSG_CS_ITEM_TWO_TO_ONE, MakeIndex1, MakeIndex2, 0, 0)
end

-- 拆分道具
function HeroBagProxy:RequestCountItem(makeIndex, num)
    LuaSendMsg(global.MsgType.MSG_CS_ITEM_NUMBER_CHANGE, makeIndex, num, 0, 0)
end

--请求人物背包到英雄背包
function HeroBagProxy:RequestHumBagToHeroBag(makeindex, ItemName)
    dump({ makeindex, ItemName }, "RequestHumBagToHeroBag___")
    LuaSendMsg(global.MsgType.MSG_CS_HUMBAG_TO_HEROBAG, makeindex, 0, 0, 0, ItemName, string.len(ItemName))
end

--请求英雄背包到人物背包
function HeroBagProxy:RequestHeroBagToHumBag(makeindex, ItemName)
    dump({ makeindex, ItemName }, "RequestHeroBagToHumBag")
    LuaSendMsg(global.MsgType.MSG_CS_HEROBAG_TO_HUMBAG, makeindex, 0, 0, 0, ItemName, string.len(ItemName))
end

function HeroBagProxy:onRegister()
    HeroBagProxy.super.onRegister(self)
end

function HeroBagProxy:RegisterMsgHandler()
    HeroBagProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType
    
    LuaRegisterMsgHandler(msgType.MSG_SC_RETURN_BAGDATA_HERO, handler(self, self.handle_MSG_SC_RETURN_BAGDATA_HERO))
    LuaRegisterMsgHandler(msgType.MSG_SC_BAG_ADD_ITEM_HERO, handler(self, self.handle_MSG_SC_BAG_ADD_ITEM_HERO))
    LuaRegisterMsgHandler(msgType.MSG_SC_BAG_DEL_ITEM_HERO, handler(self, self.handle_MSG_SC_BAG_DEL_ITEM_HERO))
    LuaRegisterMsgHandler(msgType.MSG_SC_BAG_UPDATE_ITEM_HERO, handler(self, self.handle_MSG_SC_BAG_UPDATE_ITEM_HERO))
    LuaRegisterMsgHandler(msgType.MSG_SC_BAG_ITEM_USE_FAILED_HERO, handler(self, self.handle_MSG_SC_BAG_ITEM_USE_FAILED_HERO))
    LuaRegisterMsgHandler(msgType.MSG_SC_DROP_ITEM_SUCCESS_HERO, handler(self, self.handle_MSG_SC_DROP_ITEM_SUCCESS))
    LuaRegisterMsgHandler(msgType.MSG_SC_DROP_ITEM_FAILED_HERO, handler(self, self.handle_MSG_SC_DROP_ITEM_FAILED))
    LuaRegisterMsgHandler(msgType.MSG_SC_HEROBAG_TO_HUMBAG_FAIL, handler(self, self.handle_MSG_SC_HEROBAG_TO_HUMBAG_FAIL))
end

return HeroBagProxy