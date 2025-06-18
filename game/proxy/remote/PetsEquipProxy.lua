local RemoteProxy = requireProxy("remote/RemoteProxy")
local PetsEquipProxy = class("PetsEquipProxy", RemoteProxy)
PetsEquipProxy.NAME = global.ProxyTable.PetsEquipProxy

function PetsEquipProxy:ctor()
    PetsEquipProxy.super.ctor(self)

    self:clear()
end

function PetsEquipProxy:clear()
    local PetsEquipVO = requireVO("remote/PetsEquipVO")
    self.VOdata    = PetsEquipVO.new()
    self.ItemBelongType = global.MMO.ITEM_FROM_BELONG_PETEQUIP

    self._petsData = {}
    self._attrByPetIdx = {}
    self._curSelectPetIdx = nil
end

function PetsEquipProxy:GetPetsData(...)
    return self._petsData
end

function PetsEquipProxy:GetEquipDataByPos(petIdx, pos)
    if not petIdx or not pos then
        return nil
    end
    local data = self.VOdata:GetDataByPos(petIdx, pos)
    return data
end

function PetsEquipProxy:GetEquipDataByMakeIndex(makeIndex)
    local data = self.VOdata:GetData()
    return data[makeIndex]
end

function PetsEquipProxy:GetAllEquipData()
    local data = self.VOdata:GetData()
    return data
end

function PetsEquipProxy:ClearEquipData()
    self.VOdata:ClearData()
end

function PetsEquipProxy:GetAttrByIdx(petIdx, attrId)
    if not petIdx or not attrId then
        return
    end
    if self._attrByPetIdx[petIdx] and next(self._attrByPetIdx[petIdx]) then
        return self._attrByPetIdx[petIdx][attrId]
    end
end

function PetsEquipProxy:GetSelectPetIdx(...)
    return self._curSelectPetIdx
end

function PetsEquipProxy:AddEquipData(item, petIdx)
    local posData = self:GetEquipDataByPos(petIdx, item.Where)
    if posData then
        self.VOdata:DelEquipData(posData, petIdx)
        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
        ItemManagerProxy:SetItemBelong(posData.MakeIndex, nil)
    end
    self.VOdata:AddEquipData(item, petIdx)
    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
    ItemManagerProxy:SetItemBelong(item.MakeIndex, self.ItemBelongType)
end

function PetsEquipProxy:DelEquipData(item, petIdx)
    local MakeIndex = item.MakeIndex
    local item = self:GetEquipDataByMakeIndex(MakeIndex)
    if item then
        self.VOdata:DelEquipData(item, petIdx)
        local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
        ItemManagerProxy:SetItemBelong(item.MakeIndex, nil)
    end
end

function PetsEquipProxy:TakeBackPetByIdx(petIdx)
    for i, pet in ipairs(self._petsData) do
        if pet and pet.Idx == petIdx then
            table.remove(self._petsData, i)
            break
        end
    end

    self.VOdata:ClearDataByPetIdx(petIdx)

    if self._curSelectPetIdx and self._curSelectPetIdx == petIdx then
        self._curSelectPetIdx = nil
    end
end

function PetsEquipProxy:RequestRecallPets(petIdx, param)
    LuaSendMsg(global.MsgType.MSG_CS_RECALL_PETS_REQUEST, petIdx, param or 0, 0, 0)
end

function PetsEquipProxy:RequestPetsEquipByIdx(petIdx)
    LuaSendMsg(global.MsgType.MSG_CS_PETS_WAER_EQUIP_REQUEST, petIdx, 0, 0, 0)
end

function PetsEquipProxy:RequestPetsEquipTakeOn(makeIndex, pos, ItemName, petsIdx)
    LuaSendMsg(global.MsgType.MSG_CS_PETS_TAKEON_ITEM_REQUEST, makeIndex, pos, petsIdx, 0, ItemName, string.len(ItemName))
end

function PetsEquipProxy:RequestPetsEquipTakeOff(data, petsIdx)
    local name    = data.Name
    local pos        = data.Where
    local MakeIndex = data.MakeIndex
    LuaSendMsg(global.MsgType.MSG_CS_PETS_TAKEOFF_ITEM_REQUEST, MakeIndex, pos, petsIdx, 0, name, string.len(name))
end

function PetsEquipProxy:handle_MSG_SC_PETS_TAKEON_FAIL(msg)
    local header = msg:GetHeader()

    local data = {}
    data.bRole = true
    data.isSuccess = false
    data.header = header
    --    dump(data,"MSG_SC_PETS_TAKEON_FAIL_______________")
end

function PetsEquipProxy:handle_MSG_SC_PETS_TAKEON_SUCCESS(msg)
    local header = msg:GetHeader()
    local data = {}
    data.bRole = true
    data.isSuccess = true
    data.header = header

    local petsIdx = header.param3 -- 宠物编号
    --    dump(data, "MSG_SC_PETS_TAKEON_SUCCESS_______________")
end

function PetsEquipProxy:handle_MSG_SC_PETS_TAKEOFF_SUCCESS(msg)
    local header = msg:GetHeader()
    local petsIdx = header.param3 -- 宠物编号
    -- dump(header,"handle_MSG_SC_PETS_TAKEOFF_SUCCESS___")
end

function PetsEquipProxy:handle_MSG_SC_PETS_TAKEOFF_FAIL(msg)
    local header = msg:GetHeader()
    local data = {}
    data.bRole = true
    data.isSuccess = false
    data.header = header
    --    dump(header,"handle_MSG_SC_PETS_TAKEOFF_FAIL__")
end

function PetsEquipProxy:InitPetsEquipData(petIdx, data)
    for k, equip in pairs(data) do
        if equip and equip ~= "" then
            equip = ChangeItemServersSendDatas(equip)
            self:AddEquipData(equip, petIdx)
        end
    end
end

function PetsEquipProxy:handle_MSG_SC_PETS_EQUIP_INFO(msg)
    local jsonData = ParseRawMsgToJson(msg)
    local header = msg:GetHeader()
    local petIdx = header.recog  --宠物编号
    --    dump(jsonData,"MSG_SC_PETS_EQUIP_INFO_______")
    if not jsonData or next(jsonData) == nil then
        return
    end
    self:InitPetsEquipData(petIdx, jsonData)
end

function PetsEquipProxy:handle_MSG_SC_USER_PETS_DATA_INFO(msg)
    local msgLen = msg:GetDataLength()
    local dataString = msg:GetData():ReadString(msgLen)
    -- print(dataString,"pets_____________Info")
    local function ParseStrToList(str)
        local dataList = string.split(str, ";")
        for _, data in ipairs(dataList) do
            if data and string.len(data) > 0 then
                local petParams = string.split(data, ",")
                if next(petParams) and petParams[3] then
                    local pet = {}
                    pet.Idx = tonumber(petParams[1])
                    pet.Name = petParams[2]
                    pet.Appr = tonumber(petParams[3])
                    table.insert(self._petsData, pet)
                end
            end
        end
    end
    ParseStrToList(dataString)
end

function PetsEquipProxy:handle_MSG_SC_PETS_ADD_ITEM(msg)
    local header = msg:GetHeader()
    local recog = header.recog
    local petIdx = header.param2
    local data = ParseRawMsgToJson(msg)
    -- print("------------------------------------")
    -- print(" into here to add Pets item")
    -- print("------------------------------------")
    if not recog or not data or next(data) == nil or not petIdx then
        return
    end

    data = ChangeItemServersSendDatas(data)
    data.Where = recog
    -- dump(data)
    -- print("穿戴宠物ID-----------------"..petIdx)
    self:AddEquipData(data, petIdx)
end

function PetsEquipProxy:handle_MSG_SC_PETS_DEL_EQUIP(msg)
    local header = msg:GetHeader()
    local recog = header.recog  --位置
    local petIdx = header.param2
    local data = ParseRawMsgToJson(msg)
    -- print("------------------------------------")
    -- print(" into here to DEL Pets item")
    -- print("------------------------------------")
    if not recog or not data or next(data) == nil or not petIdx then
        return
    end

    data = ChangeItemServersSendDatas(data)
    data.Where = recog
    -- dump(data)
    -- print("脱下宠物ID-----------------"..petIdx)
    self:DelEquipData(data, petIdx)
end

function PetsEquipProxy:handle_MSG_SC_PET_PROPERTIES(msg)
    local data = ParseRawMsgToJson(msg)
    --宠物id
    local header = msg:GetHeader()
    local petIdx = header.recog
    if not petIdx then
        return
    end
    if not self._attrByPetIdx[petIdx] then
        self._attrByPetIdx[petIdx] = {}
    end

    local PShowAttType = GUIFunction:PShowAttType()

    local _attr = {}
    _attr[PShowAttType.Min_DEF]           = data.ac1   --物防
    _attr[PShowAttType.Max_DEF]           = data.ac2   --
    _attr[PShowAttType.Min_MDF]           = data.mac1  --魔防
    _attr[PShowAttType.Max_MDF]           = data.mac2
    _attr[PShowAttType.Min_ATK]           = data.dc1   --物理
    _attr[PShowAttType.Max_ATK]           = data.dc2
    _attr[PShowAttType.Min_MAT]           = data.mc1   --魔法
    _attr[PShowAttType.Max_MAT]           = data.mc2
    _attr[PShowAttType.Min_Daoshu]        = data.sc1   --道术
    _attr[PShowAttType.Max_Daoshu]        = data.sc2
    _attr[PShowAttType.HP]                = data.hp         --生命
    _attr[PShowAttType.MP]                = data.maxmp         --魔法
    _attr[PShowAttType.Weight]            = data.weight--当前重量
    _attr[PShowAttType.Max_Weight]        = data.maxweight--玩家最大负重
    _attr[PShowAttType.Wear_Weight]       = data.wearweight--穿戴负重
    _attr[PShowAttType.Max_Wear_Weight]   = data.maxwearweight--最大穿戴负重
    _attr[PShowAttType.Hand_Weight]       = data.handweight--腕力
    _attr[PShowAttType.Max_Hand_Weight]   = data.maxhandweight--当前最大可穿戴腕力
    _attr[PShowAttType.Anti_Magic]        = data.antimagic
    _attr[PShowAttType.Hit_Point]         = data.hitPoint
    _attr[PShowAttType.Speed_Point]       = data.SpeedPoint
    _attr[PShowAttType.Anti_Posion]       = data.AntiPoison
    _attr[PShowAttType.Posion_Recover]    = data.PoisonRecover
    _attr[PShowAttType.Health_Recover]    = data.HealthRecover
    _attr[PShowAttType.Spell_Recover]     = data.SpellRecover
    _attr[PShowAttType.Hit_Speed]         = data.HitSpeed
    _attr[PShowAttType.Block_Rate]        = data.GedangRate
    _attr[PShowAttType.Block_Value]       = data.GedangPower
    _attr[PShowAttType.Double_Rate]       = data.BjRate
    _attr[PShowAttType.Double_Damage]     = data.BjPoint
    _attr[PShowAttType.Defence]           = data.Abil23
    _attr[PShowAttType.Double_Defence]    = data.Abil24
    _attr[PShowAttType.More_Damage]       = data.Abil25
    _attr[PShowAttType.ATK_Defence]       = data.Abil26
    _attr[PShowAttType.MAT_Defence]       = data.Abil27
    _attr[PShowAttType.Ignore_Defence]    = data.Abil28
    _attr[PShowAttType.Bounce_Damage]     = data.Abil29
    _attr[PShowAttType.Health_Add]        = data.Abil30
    _attr[PShowAttType.Magice_Add]        = data.Abil31
    _attr[PShowAttType.More_Item]         = data.Abil32
    _attr[PShowAttType.Less_Item]         = data.Abil33
    _attr[PShowAttType.Vampire]           = data.Abil34
    _attr[PShowAttType.A_M_D_Add]         = data.Abil35
    _attr[PShowAttType.Defence_Add]       = data.Abil36
    _attr[PShowAttType.MDefence_Add]      = data.Abil37
    _attr[PShowAttType.God_Damage]        = data.Abil38
    _attr[PShowAttType.Lucky]             = data.Abil39
    _attr[PShowAttType.Monster_Damage_Value]  = data.Abil40
    _attr[PShowAttType.Monster_Damage_Per]    = data.Abil41
    _attr[PShowAttType.Anger_Recover]         = data.Abil42
    _attr[PShowAttType.Combine_Skill_Damage]  = data.Abil43
    _attr[PShowAttType.Monster_DropItem]      = data.Abil44
    _attr[PShowAttType.No_Palsy]              = data.Abil45
    _attr[PShowAttType.No_Protect]            = data.Abil46
    _attr[PShowAttType.No_Rebirth]            = data.Abil47
    _attr[PShowAttType.No_ALL]                = data.Abil48
    _attr[PShowAttType.No_Charm]              = data.Abil49
    _attr[PShowAttType.No_Fire]               = data.Abil50
    _attr[PShowAttType.No_Ice]                = data.Abil51
    _attr[PShowAttType.No_Web]                = data.Abil52
    _attr[PShowAttType.Att_UnKonw]            = data.Abil53
    _attr[PShowAttType.More_A_Damage]         = data.Abil54
    _attr[PShowAttType.Less_A_Damage]         = data.Abil55
    _attr[PShowAttType.More_M_Damage]         = data.Abil56
    _attr[PShowAttType.Less_M_Damage]         = data.Abil57
    _attr[PShowAttType.More_D_Damage]         = data.Abil58
    _attr[PShowAttType.Less_D_Damage]         = data.Abil59
    _attr[PShowAttType.More_Health_Per]       = data.Abil60
    _attr[PShowAttType.HP_Recover]            = data.Abil61
    _attr[PShowAttType.MP_Recover]            = data.Abil62
    _attr[PShowAttType.Drop_Rate]             = data.Abil65
    _attr[PShowAttType.Exp_Add_Rate]          = data.Abil66
    _attr[PShowAttType.Damage_Rate_Add]       = data.Abil67
    _attr[PShowAttType.Damage_Human]          = data.Abil68
    _attr[PShowAttType.Ice_Rate]              = data.Abil69
    _attr[PShowAttType.Defen_Ice]             = data.Abil70

    _attr[PShowAttType.Sec_Recovery_HP]       = data.Abil71
    _attr[PShowAttType.Mon_Bj_Power_Rate]     = data.Abil72
    _attr[PShowAttType.DC_Add_Rate]           = data.Abil73
    local monPKV = data.FaMeMonPK or 0
    local abil74 = data.Abil74 or 0
    _attr[PShowAttType.Monster_Damage]        = abil74 + monPKV
    _attr[PShowAttType.Monster_Damage_Percent]= data.Abil75
    _attr[PShowAttType.PK_Damage_Add_Percent] = data.Abil76
    local pk = data.FaMePK or 0
    local abil77 = data.Abil77 or 0
    _attr[PShowAttType.PK_Damage_Dec_Percent] = abil77 + pk
    _attr[PShowAttType.Penetrate]             = data.Abil78
    _attr[PShowAttType.Death_Hit_Percent]     = data.Abil79
    _attr[PShowAttType.Death_Hit_Value]       = data.Abil80
    _attr[PShowAttType.Monster_Suck_HP_Rate]  = data.Abil81
    _attr[PShowAttType.Monster_Vampire]       = data.Abil82
    _attr[PShowAttType.Less_Monster_Damage]   = data.Abil83
    _attr[PShowAttType.Drug_Recover]          = data.Abil84
    _attr[PShowAttType.Ignore_Def_Dec]        = data.Abil85
    _attr[PShowAttType.Fire_Hit_Dec_Rate]     = data.Abil86
    _attr[PShowAttType.Ergum_Hit_Dec_Rate]    = data.Abil87
    _attr[PShowAttType.Hit_Plus_Dec_Rate]     = data.Abil88
    _attr[PShowAttType.Health_Add_WPer]       = data.Abil89
    _attr[PShowAttType.Death_Hit_Dec_Percent] = data.Abil90
    _attr[PShowAttType.Sec_Recovery_MP]       = data.Abil91

    if data.CustAbil then
        for i,v in ipairs(data.CustAbil) do
            _attr[v[1]]       = v[2]
        end
    end

    self._attrByPetIdx[petIdx] = _attr
end

function PetsEquipProxy:handle_MSG_SC_PETS_SELECTED_ORBACK(msg)
    local header = msg:GetHeader()
    local recog = header.recog
    local isBack = header.param2 and header.param2 == 1
    if isBack and recog then    -- 收回
        self:TakeBackPetByIdx(recog)
    else                        -- 当前选中
        self._curSelectPetIdx = recog
    end
end

function PetsEquipProxy:onRegister()
    PetsEquipProxy.super.onRegister(self)
end

function PetsEquipProxy:RegisterMsgHandler()
    PetsEquipProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    --初始化装备信息
    LuaRegisterMsgHandler(msgType.MSG_SC_PETS_EQUIP_INFO, handler(self, self.handle_MSG_SC_PETS_EQUIP_INFO))
    -- 装备穿上确认-成功
    LuaRegisterMsgHandler(msgType.MSG_SC_PETS_TAKEON_SUCCESS, handler(self, self.handle_MSG_SC_PETS_TAKEON_SUCCESS))
    -- 装备穿上确认-失败
    LuaRegisterMsgHandler(msgType.MSG_SC_PETS_TAKEON_FAIL, handler(self, self.handle_MSG_SC_PETS_TAKEON_FAIL))
    -- 装备脱下确认-成功
    LuaRegisterMsgHandler(msgType.MSG_SC_PETS_TAKEOFF_SUCCESS, handler(self, self.handle_MSG_SC_PETS_TAKEOFF_SUCCESS))
    -- 装备脱下确认-失败
    LuaRegisterMsgHandler(msgType.MSG_SC_PETS_TAKEOFF_FAIL, handler(self, self.handle_MSG_SC_PETS_TAKEOFF_FAIL))

    -- 宠物信息下发
    LuaRegisterMsgHandler(msgType.MSG_SC_USER_PETS_DATA_INFO, handler(self, self.handle_MSG_SC_USER_PETS_DATA_INFO))
    -- 宠物装备增加
    LuaRegisterMsgHandler(msgType.MSG_SC_PETS_ADD_ITEM, handler(self, self.handle_MSG_SC_PETS_ADD_ITEM))
    -- 宠物装备删除(脱下)
    LuaRegisterMsgHandler(msgType.MSG_SC_PETS_DEL_EQUIP, handler(self, self.handle_MSG_SC_PETS_DEL_EQUIP))
    -- 宠物属性下发
    LuaRegisterMsgHandler(msgType.MSG_SC_PET_PROPERTIES, handler(self, self.handle_MSG_SC_PET_PROPERTIES))
    -- 下发当前选中/收回宠物
    LuaRegisterMsgHandler(msgType.MSG_SC_PETS_SELECTED_ORBACK, handler(self, self.handle_MSG_SC_PETS_SELECTED_ORBACK))
end

return PetsEquipProxy