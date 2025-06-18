local RemoteProxy = requireProxy("remote/RemoteProxy")
local proxyUtils = requireProxy("proxyUtils")
local EquipProxy = class("EquipProxy", RemoteProxy)
EquipProxy.NAME = global.ProxyTable.Equip

function EquipProxy:ctor()
    EquipProxy.super.ctor(self)

    self._equipDataByMakeIndex = {} --item
    self._equipPosData = {}--makeindex

    self.EquipPosData = requireConfig("EquipPosTypeConfig")
    self.EquipPosType = self.EquipPosData.EquipPosTypeConfig
    self.ModelViewEquipOff = {}
    self.ModelViewHairOff = {}
    self.ItemBelongType = global.MMO.ITEM_FROM_BELONG_EQUIP
    self.posfight = {}
    self.suitnum = {}
    self.lastTakeOnPos = {}
    self.bestRingsOpen = false
    self.equipQuality = {
        DEFAULT_EQUIP = 1, --战装
        GOD_MAGIC_EQUIP = 2, --魔神装
        FASHION_EQUIP = 3 --神器(魔神武器衣服)
    }

    self:loadJson()
end

function EquipProxy:loadJson()
    local cjson    = require("cjson")

    -- 装备偏移
    local function loadEquipOffset(filename, index)
        if global.FileUtilCtl:isFileExist(filename) then
            local jsonStr = global.FileUtilCtl:getDataFromFileEx(filename)
            local jsonData = {}
            xpcall(function()
                jsonData = cjson.decode(jsonStr)
            end,
            function()
                if global.isDebugMode or global.isGMMode then
                    ShowSystemTips(string.format("json文件格式错误: %s", filename))
                end
            end
            )
            for key, value in pairs(jsonData) do
                local offValue = {
                    x = value.x,
                    y = value.y
                }
                if global.isWinPlayMode then
                    if value.x1 then
                        offValue.x = value.x1
                    end
                    if value.y1 then
                        offValue.y = value.y1
                    end
                end
                self.ModelViewEquipOff[tonumber(key) + index * 10000] = offValue
            end
        end
    end
    for i = 0, 10 do
        local filename = string.format("res/player_show/player_show_%s/equip_offest.txt", i)
        if global.FileUtilCtl:isFileExist(filename) then
            loadEquipOffset(filename, i)
        end
    end

    -- 头发偏移
    local function loadHairOffset(filename)
        if global.FileUtilCtl:isFileExist(filename) then
            local jsonStr = global.FileUtilCtl:getDataFromFileEx(filename)
            local jsonData = {}
            xpcall(function()
                jsonData = cjson.decode(jsonStr)
            end,
            function()
                if global.isDebugMode or global.isGMMode then
                    ShowSystemTips(string.format("json文件格式错误: %s", filename))
                end
            end
            )
            for key, value in pairs(jsonData) do
                local offValue = {
                    x = value.x,
                    y = value.y
                }
                if global.isWinPlayMode then
                    if value.x1 then
                        offValue.x = value.x1
                    end
                    if value.y1 then
                        offValue.y = value.y1
                    end
                end
                self.ModelViewHairOff[tonumber(key)] = offValue
            end
        end
    end
    loadHairOffset("data_config/hair_offest.txt")
end

function EquipProxy:GetEquipModelOffSet()
    return self.ModelViewEquipOff
end

function EquipProxy:GetModelHairOffSet()
    return self.ModelViewHairOff
end

function EquipProxy:GetEquipPosByStdMode(StdMode)
    local posList = self.EquipPosData.EquipPosByStdMode[StdMode]
    if posList and next(posList) then
        for k, pos in pairs(posList) do
            local equip = self:GetEquipDataByPos(pos)
            if not equip then
                return pos
            end
        end
        return posList[1]
    end
    return nil
end

-- tips部位列表
function EquipProxy:GetTipsEquipPosByStdModeList(StdMode)
    if self.EquipPosData.TipsEquipPosByStdMode[StdMode] then
        return self.EquipPosData.TipsEquipPosByStdMode[StdMode]
    end
    return self:GetEquipPosByStdModeList(StdMode)
end

function EquipProxy:GetEquipPosByStdModeList(StdMode)
    return self.EquipPosData.EquipPosByStdMode[StdMode]
end

function EquipProxy:GetEquipMappingConfig(pos)
    return self.EquipPosData.EquipPosMapping[pos]
end

-- 反向
function EquipProxy:GetDeEquipMappingConfig(pos)
    if not pos then
        return nil
    end
    for belongPos, v in pairs(self.EquipPosData.EquipPosMapping) do
        for k, position in pairs(v) do
            if position == pos then
                return belongPos
            end
        end
    end
    return nil
end

function EquipProxy:IsShowEquipItems(pos)
    local equipPos = pos or 0
    local noShowItem = {
        [self.EquipPosType.Equip_Type_Dress] = true,
        [self.EquipPosType.Equip_Type_Weapon] = true,
        [self.EquipPosType.Equip_Type_Helmet] = true,
        [self.EquipPosType.Equip_Type_Cap] = true,
        [self.EquipPosType.Equip_Type_Shield] = true,
        [self.EquipPosType.Equip_Type_Veil] = true,
        [self.EquipPosType.Equip_Type_Super_Dress] = true,
        [self.EquipPosType.Equip_Type_Super_Weapon] = true,
        [self.EquipPosType.Equip_Type_Super_Helmet] = true,
        [self.EquipPosType.Equip_Type_Super_Cap] = true,
        [self.EquipPosType.Equip_Type_Super_Shield] = true,
        [self.EquipPosType.Equip_Type_Super_Veil] = true,
        [self.EquipPosType.Equip_Fashion_Dress] = true,
        [self.EquipPosType.Equip_Fashion_Weapon] = true,
    }
    return not noShowItem[pos]
end

function EquipProxy:GetEquipTypeConfig()
    return self.EquipPosType
end

function EquipProxy:ClearEquipData()
    self._equipDataByMakeIndex = {}
    self._equipPosData = {}
end

function EquipProxy:GetEquipData()
    return self._equipDataByMakeIndex
end

function EquipProxy:GetEquipPosData()
    return self._equipPosData
end

function EquipProxy:GetEquipDataByMakeIndex(makeIndex)
    return self._equipDataByMakeIndex[makeIndex]
end

function EquipProxy:FindEquipDataByPos(pos)
    if not self._equipPosData[pos] then
        return nil
    end
    return self:GetEquipDataByMakeIndex(self._equipPosData[pos])
end

function EquipProxy:GetEquipDataByPos(pos, beginOnMoving)
    local data = self:FindEquipDataByPos(pos)
    if beginOnMoving then
        local list = self:GetEquipMappingConfig(pos) -- 单显示位置 多个装备位置共享
        if list then
            data = nil
            for _, v in ipairs(list) do
                data = self:FindEquipDataByPos(v)
                if data then
                    break
                end
            end
        end
    end
    return data
end

function EquipProxy:GetEquipDataByName(Name)
    local list = {}
    local data = self:GetEquipData()
    if not Name or Name == "" or not data or next(data) == nil then
        return list
    end
    local originName = nil
    for k, v in pairs(data) do
        originName = v.originName or v.Name
        if originName == Name then
            table.insert(list, v)
        end
    end
    return list
end

function EquipProxy:GetEquipDataPosDataList(pos)
    local data = {}
    local list = self:GetEquipMappingConfig(pos) -- 单显示位置 多个装备位置共享
    if list then
        for _, v in ipairs(list) do
            local equipData = self:FindEquipDataByPos(v)
            if equipData then
                table.insert(data, equipData)
            end
        end
    else
        local equipData = self:FindEquipDataByPos(pos)
        if equipData then
            table.insert(data, equipData)
        end
    end
    if next(data) == nil then
        data = nil
    end
    return data
end

-- 战力对比   checkPosData： 指定部位数据战力对比( {[1]={data, pos}})
function EquipProxy:GetMinPowerPosByStdMode(StdMode, param, checkPosData)
    local StdMode = StdMode or 0
    local onEquipMinPower = 0
    local minPowerPos = -1
    local hasEquip = true
    local pos = checkPosData or self:GetEquipPosByStdModeList(StdMode)
    if not pos or next(pos) == nil then
        print("this StdMode is not a equip")
        return minPowerPos, onEquipMinPower
    end

    if param.checkPos then
        local index = table.indexof(pos, param.checkPos)
        if index then
            local fristPos = pos[1]
            pos[1] = param.checkPos
            pos[index] = fristPos
        end
    end

    local isCheckPos = false
    if checkPosData then
        isCheckPos = true
    end

    for k, v in ipairs(pos) do
        local equipData = isCheckPos and v.data or self:GetEquipDataByPos(v)
        if not equipData then
            minPowerPos = isCheckPos and v.pos or v
            onEquipMinPower = 0
            hasEquip = false
            break
        end
        local equipPower = GUIFunction:GetEquipPower(equipData, param)
        if onEquipMinPower == 0 or equipPower < onEquipMinPower then
            onEquipMinPower = equipPower
            minPowerPos = isCheckPos and v.pos or v
            if StdMode == 25 then
                break
            end
        end
    end
    return minPowerPos, onEquipMinPower, hasEquip
end

function EquipProxy:GetEquipTakeOnPosByStdMode(StdMode, param)
    local StdMode = StdMode or 0
    local onEquipMinPower = 0
    local minPowerPos = -1
    local hasEquip = true
    local pos = self:GetEquipPosByStdModeList(StdMode)
    if not pos or next(pos) == nil then
        print("this StdMode is not a equip")
        return minPowerPos, onEquipMinPower
    end
    local posCount = #pos
    if posCount > 1 then
        for k, v in pairs(pos) do
            local equipData = self:GetEquipDataByPos(v)
            if not equipData then
                minPowerPos = v
                onEquipMinPower = 0
                hasEquip = false
                break
            end
        end
        if hasEquip then -- 如果没有空位
            if not self.lastTakeOnPos[pos[1]] then
                self.lastTakeOnPos[pos[1]] = 1
            else
                self.lastTakeOnPos[pos[1]] = self.lastTakeOnPos[pos[1]] + 1
                if self.lastTakeOnPos[pos[1]] > posCount then
                    self.lastTakeOnPos[pos[1]] = 1
                end
            end
            local chooseIndex = self.lastTakeOnPos[pos[1]] or 1
            local choosePos = pos[chooseIndex] or pos[1]
            local equipData = self:GetEquipDataByPos(choosePos)
            if equipData then
                local equipPower = GUIFunction:GetEquipPower(equipData, param)
                onEquipMinPower = equipPower
                minPowerPos = choosePos
            else
                minPowerPos = choosePos
                onEquipMinPower = 0
                hasEquip = false
            end
        end
    else -- 单位置 直接为改位置
        local onlyPos = pos[1]
        local equipData = self:GetEquipDataByPos(onlyPos)
        minPowerPos = onlyPos
        if not equipData then
            onEquipMinPower = 0
            hasEquip = false
        else
            local equipPower = GUIFunction:GetEquipPower(equipData, param)
            onEquipMinPower = equipPower
        end
    end
    return minPowerPos, onEquipMinPower, hasEquip
end

function EquipProxy:CheckEquipNeedSex(item, sex)
    if not item or not next(item) then
        return false
    end
    local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local stdMode = item.StdMode
    local sexOk = true
    local needSex = sex and sex or PlayerPropertyProxy:GetRoleSex()
    local equipNeedSexConfig = self.EquipPosData.EquipSexNeed or {}
    if equipNeedSexConfig[stdMode] and equipNeedSexConfig[stdMode] ~= needSex then
        sexOk = false
    end
    return sexOk
end

function EquipProxy:CheckEquipWeight(onItem, pos)
    if not onItem or not next(onItem) or not pos or pos < 0 then
        return false
    end
    local offItem = self:GetEquipDataByPos(pos)
    local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local equipNeedSexConfig = self.EquipPosData.EquipHandWeightType or {}

    local AttType = GUIFunction:PShowAttType()
    local maxWeightType = AttType.Max_Wear_Weight
    local nowWeightType = AttType.Wear_Weight
    if equipNeedSexConfig[onItem.StdMode] then
        maxWeightType = AttType.Max_Hand_Weight
        nowWeightType = AttType.Hand_Weight
    end
    local onItemWeight = onItem.Weight
    local offItemWeight = offItem and offItem.Weight or 0
    local playerMaxWeight = PlayerPropertyProxy:GetRoleAttByAttType(maxWeightType) or 0
    local nowWearWeight = PlayerPropertyProxy:GetRoleAttByAttType(nowWeightType) or 0
    local afterEquip = onItemWeight - offItemWeight + nowWearWeight
    return afterEquip <= playerMaxWeight
end

--检测附身符使用  (因为护身符可以穿戴在右手镯，当附身符有穿戴，双击以及自动使用时不能穿戴，只能拖拽穿戴)
function EquipProxy:CheckBujukUse(item, putPos)
    -- body
    if item and item.StdMode then
        if item.StdMode == 25 then
            return true, 9
        end

        return true
    end
    return false
end

function EquipProxy:CheckBestRingsSpace()
    for pos = self.EquipPosType.Equip_Type_BestRing1, self.EquipPosType.Equip_Type_BestRing12 do
        local data = self:GetEquipDataByPos(pos)
        if not data then
            return pos
        end
    end
    return false
end

function EquipProxy:GetBestRingsOpenState()
    return self.bestRingsOpen
end

function EquipProxy:SetBestRingsOpenState(state)
    self.bestRingsOpen = state
end

function EquipProxy:AddEquipData(item, isInit)
    local MakeIndex = item.MakeIndex
    local Where = item.Where

    -- 当前位置已有装备，先删除
    local lastItem = self:GetEquipDataByPos(item.Where)
    if lastItem then
        self:DelEquipData(lastItem)
    end

    -- 数据存储
    self._equipDataByMakeIndex[MakeIndex] = item
    self._equipPosData[Where] = MakeIndex

    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    ItemManagerProxy:SetItemBelong(item.MakeIndex, self.ItemBelongType)

    if not isInit then
        local sData = {}
        sData.MakeIndex = item.MakeIndex
        sData.Where = item.Where
        sData.opera = global.MMO.Operator_Add
        sData.ItemData = item
        global.Facade:sendNotification(global.NoticeTable.PlayEquip_Oper_Data, sData)

        SLBridge:onLUAEvent(LUA_EVENT_PLAYER_EQUIP_CHANGE, sData)
    end
end

function EquipProxy:DelEquipData(item)
    local MakeIndex = item.MakeIndex
    local oldItem = self:GetEquipDataByMakeIndex(MakeIndex)
    if not oldItem then
        return
    end

    -- local AutoUseItemProxy = global.Facade:retrieveProxy(global.ProxyTable.AutoUseItemProxy)
    -- AutoUseItemProxy:AddEquipOffMakeIndex(item.MakeIndex)

    -- 存储数据
    local Where = item.Where
    self._equipPosData[Where] = nil
    self._equipDataByMakeIndex[MakeIndex] = nil

    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    ItemManagerProxy:SetItemBelong(MakeIndex, nil)
    local sData = {}
    sData.MakeIndex = MakeIndex
    sData.Where = Where
    sData.opera = global.MMO.Operator_Sub
    sData.ItemData = item
    global.Facade:sendNotification(global.NoticeTable.PlayEquip_Oper_Data, sData)

    SLBridge:onLUAEvent(LUA_EVENT_PLAYER_EQUIP_CHANGE, sData)
end

function EquipProxy:ChangeEquipData(item, bagDelayUpdate, isChangeLook)
    local MakeIndex = item.MakeIndex
    local Where = item.Where
    local oldItem = self:GetEquipDataByMakeIndex(MakeIndex)
    if not oldItem then
        return
    end
    
    -- 数据存储
    self._equipDataByMakeIndex[MakeIndex] = item

    local sData = {}
    sData.MakeIndex = MakeIndex
    sData.Where = Where
    sData.opera = global.MMO.Operator_Change
    sData.bagDelayUpdate = bagDelayUpdate
    sData.isChangeLook = isChangeLook

    global.Facade:sendNotification(global.NoticeTable.PlayEquip_Oper_Data, sData)

    SLBridge:onLUAEvent(LUA_EVENT_PLAYER_EQUIP_CHANGE, sData)
end
--法阵
function EquipProxy:SetEmbattle(data)
    self.embattle = {}
    if data and data ~= 0 then
        self.embattle[1] = H16Bit(data)
        self.embattle[2] = L16Bit(data)
    end
end

function EquipProxy:GetEmbattle()
    return self.embattle
end

function EquipProxy:handle_MSG_SC_EQUIP_Embattle_RESPONSE(msg)
    local header = msg:GetHeader()
    local recog = header.recog
    self:SetEmbattle(recog)
    global.Facade:sendNotification(global.NoticeTable.Layer_Embattle_Refresh)
    SLBridge:onLUAEvent(LUA_EVENT_PLAYER_EMBATTLE_CHANGE)
end

-- --更换iconID
function EquipProxy:ChangeEquipLook(MakeIndex)
    if not MakeIndex then
        return
    end

    local item = self:GetEquipDataByMakeIndex(MakeIndex)
    if not item then
        return
    end

    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    item.Looks, item.bEffect, item.sEffect = ItemConfigProxy:GetChangeItemLook(item.MakeIndex, item.Index)
    self:ChangeEquipData(item, nil, true)
end

-- 自定义装备使用
function EquipProxy:SetCustUserItem(custUserItem)
    if not custUserItem or string.len(custUserItem) <= 0 then
        return
    end

    local ItemsConfig = requireConfig("ItemsConfig")
    ItemsConfig.EquipMapByStdMode = {}
    ItemsConfig.EquipMapByStdMode = clone(ItemsConfig.EquipMapByStdModeTemp)

    self.EquipPosData.EquipPosByStdMode = {}
    self.EquipPosData.EquipPosByStdMode = clone(self.EquipPosData.EquipPosByStdModeTemp)

    local itemArray = string.split(custUserItem, "#")
    for i, v in ipairs(itemArray) do
        local posArray = string.split(v, "=")
        local pos = posArray[1] and tonumber(posArray[1]) or nil
        local stdModeStr = posArray[2]
        if stdModeStr and string.len(stdModeStr) > 0 then
            local StdModeArray = string.split(stdModeStr, ",")
            for _i, _StdMode in ipairs(StdModeArray) do
                local StdMode = _StdMode and tonumber(_StdMode) or nil
                if StdMode and pos then
                    if not self.EquipPosData.EquipPosByStdMode[StdMode] then
                        self.EquipPosData.EquipPosByStdMode[StdMode] = {}
                    end
                    table.insert(self.EquipPosData.EquipPosByStdMode[StdMode], pos)
                    ItemsConfig.EquipMapByStdMode[StdMode] = true
                end
            end
        end
    end
end

function EquipProxy:handle_MSG_SC_PLAYER_EQUIP_ON_FAIL(msg)
    local header = msg:GetHeader()
    local data = {}
    data.isSuccess = false
    data.header = header
    global.Facade:sendNotification(global.NoticeTable.TakeOnResponse, data)

    ssr.ssrBridge:OnTakeOnEquip(data.isSuccess)
end

function EquipProxy:handle_MSG_SC_PLAYER_EQUIP_ON_SUCCESS(msg)
    local header = msg:GetHeader()
    local data = {}
    data.isSuccess = true
    data.header = header
    data.pos = header.recog
    global.Facade:sendNotification(global.NoticeTable.TakeOnResponse, data)

    ssr.ssrBridge:OnTakeOnEquip(data.isSuccess, data.pos)
end

function EquipProxy:handle_MSG_SC_PLAYER_EQUIP_OFF_SUCCESS(msg)
    local header = msg:GetHeader()
    ssr.ssrBridge:OnTakeOffEquip(true, header.recog)
    global.Facade:sendNotification(global.NoticeTable.TakeOffResponse, {isSuccess = true, pos = header.recog})
end

function EquipProxy:handle_MSG_SC_PLAYER_EQUIP_OFF_FAIL(msg)
    ssr.ssrBridge:OnTakeOffEquip({isSuccess = false})
    global.Facade:sendNotification(global.NoticeTable.TakeOffResponse, {isSuccess = false, header = msg:GetHeader()})
end

function EquipProxy:handle_MSG_SC_PALYER_EQUIP_INFO(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData or next(jsonData) == nil then
        return
    end

    for k, equip in pairs(jsonData) do
        if equip and equip ~= "" then
            equip = ChangeItemServersSendDatas(equip)
            self:AddEquipData(equip, true)
        end
    end

    global.Facade:sendNotification(global.NoticeTable.PlayEquip_Oper_Init)
    ssr.ssrBridge:OnPlayerEquipInit()
    SLBridge:onLUAEvent(LUA_EVENT_PLAYER_EQUIP_CHANGE, {opera = global.MMO.Operator_Init})
end

function EquipProxy:RequestBestRingsOpenState()
    LuaSendMsg(global.MsgType.MSG_CS_PLAYER_EQUIP_BEST_RINGS_STATE, 0, 0, 0, 0)
end

-- 获取装备条件
function EquipProxy:GetEquipCondition( pos )
    if not self.equipConditions then
        self.equipConditions = {}
        local equipConditions = SL:GetMetaValue("GAME_DATA","zhanguxianshi") or ""
        if equipConditions and equipConditions ~= "" then
            local paramStr = string.split(equipConditions, "-")
            for i,v in ipairs(paramStr) do
                local equipPosAndCondtions = v
                if equipPosAndCondtions and equipPosAndCondtions ~= "" then
                    local param = string.split(equipPosAndCondtions, "&")
                    local equipPos = tonumber(param[1])
                    local conditions = param[2]
                    if equipPos then
                        self.equipConditions[equipPos] = conditions
                    end
                end
            end
        end
    end
    return self.equipConditions[pos]
end
function EquipProxy:CheckEquipCondition( pos,lookPlayer )
    local equipCondition = self:GetEquipCondition( pos )
    if equipCondition then
        local checkConditions = equipCondition or ""
        local ConditionProxy = global.Facade:retrieveProxy(global.ProxyTable.ConditionProxy)
        if ConditionProxy:CheckCondition(checkConditions) then
            return true
        else
            return false
        end
    end
    return true
end
function EquipProxy:handle_MSG_SC_PLAYER_EQUIP_BEST_RINGS_STATE(msg)
    local header = msg:GetHeader()
    local state = header.recog == 1
    local isOpen = false
    if self.bestRingsOpen and state then
        isOpen = true
    end
    self:SetBestRingsOpenState(state)
    global.Facade:sendNotification(global.NoticeTable.Layer_PlayerBestRing_State, { isOpen = isOpen })
    SLBridge:onLUAEvent(LUA_EVENT_BESTRINGBOX_STATE, {isOpen = isOpen})
end

function EquipProxy:onRegister()
    EquipProxy.super.onRegister(self)
end

function EquipProxy:RegisterMsgHandler()
    EquipProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    --初始化装备信息
    LuaRegisterMsgHandler(msgType.MSG_SC_PALYER_EQUIP_INFO, handler(self, self.handle_MSG_SC_PALYER_EQUIP_INFO))
    -- 装备穿上确认-成功
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_EQUIP_ON_SUCCESS, handler(self, self.handle_MSG_SC_PLAYER_EQUIP_ON_SUCCESS))
    -- 装备穿上确认-失败
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_EQUIP_ON_FAIL, handler(self, self.handle_MSG_SC_PLAYER_EQUIP_ON_FAIL))
    -- 装备脱下确认-成功
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_EQUIP_OFF_SUCCESS, handler(self, self.handle_MSG_SC_PLAYER_EQUIP_OFF_SUCCESS))
    -- 装备脱下确认-失败
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_EQUIP_OFF_FAIL, handler(self, self.handle_MSG_SC_PLAYER_EQUIP_OFF_FAIL))
    -- 首饰盒开启状态
    LuaRegisterMsgHandler(msgType.MSG_SC_PLAYER_EQUIP_BEST_RINGS_STATE, handler(self, self.handle_MSG_SC_PLAYER_EQUIP_BEST_RINGS_STATE))
    -- 法阵
    LuaRegisterMsgHandler(msgType.MSG_SC_EQUIP_Embattle_RESPONSE,handler(self, self.handle_MSG_SC_EQUIP_Embattle_RESPONSE) )
end

return EquipProxy