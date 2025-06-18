local RemoteProxy = requireProxy("remote/RemoteProxy")
local AutoUseItemProxy = class("AutoUseItemProxy", RemoteProxy)
AutoUseItemProxy.NAME = global.ProxyTable.AutoUseItemProxy

local ssplit = string.split

function AutoUseItemProxy:ctor()
    AutoUseItemProxy.super.ctor(self)

    -- 脱下的装备
    self._equip_off_makeindex = {}

    -- 不显示的装备(key: 装备名/装备Index/装备唯一id)
    self._not_tip_equips = {
        [1] = {}, -- key: MakeIndex
        [2] = {}, -- key: Index
        [3] = {}, -- key: Name, value: 次数(可能有好几个)
        [99] = false, -- 总开关 是否打开提示 默认不提示
    }

    -- tips的装备数据 {key: 装备位  value: 装备唯一id}
    self._equip_tips = {
        [1] = {}, -- 人物
        [2] = {}            -- 英雄
    }
end

function AutoUseItemProxy:onRegister()
    AutoUseItemProxy.super.onRegister(self)
end

-- 记录脱下的装备
function AutoUseItemProxy:AddEquipOffMakeIndex(MakeIndex)
    if MakeIndex then
        self._equip_off_makeindex[MakeIndex] = true
    end
end

-- 判断是否是脱下的装备
function AutoUseItemProxy:IsEquipOffByMakeIndex(MakeIndex)
    local offEquip = false
    if MakeIndex and self._equip_off_makeindex[MakeIndex] then
        offEquip = true
        self._equip_off_makeindex[MakeIndex] = nil
    end
    return offEquip
end

-- 判断是否是不弹出的装备
function AutoUseItemProxy:IsEquipNotTip(data)
    if not data or not next(data) then
        return true
    end

    if self._not_tip_equips[99] then
        return true
    end

    local name = tostring(data.Name) or -1
    local Index = tostring(data.Index) or -1
    local MakeIndex = tostring(data.MakeIndex) or -1

    if self._not_tip_equips[1][MakeIndex] or self._not_tip_equips[2][Index] or self._not_tip_equips[3][name] then
        return true
    end

    return false
end

-- huoqu
function AutoUseItemProxy:GetBagPosByMakeIndex(MakeIndex)
    for i, v in ipairs(self._equip_tips) do
        for kk, vv in pairs(v) do
            if vv == MakeIndex then
                return kk
            end
        end
    end
    return nil
end

function AutoUseItemProxy:GetMakeIndexByPos(type, pos)
    if (type ~= 1 and type ~= 2) or not pos then
        return nil
    end
    local list = self._equip_tips[type] or {}
    return list[pos]
end

function AutoUseItemProxy:SetMakeIndexByPos(type, pos, makeIndex)
    type = type or 1
    if (type ~= 1 and type ~= 2) or not pos then
        return nil
    end
    self._equip_tips[type][pos] = makeIndex
end

-- 移除tips的装备数据 pos: 装备位 playerType:人物类型(1: 人物; 2: 英雄)
function AutoUseItemProxy:RemoveEquipTip(pos, playerType)
    playerType = playerType or 1
    if pos then
        self._equip_tips[playerType][pos] = nil
    end
end

-- 服务端通知不显示自动穿戴的消息
function AutoUseItemProxy:handle_MSG_SC_NOT_AUTO_TIPS_EQUIPS(msg)
    --[[        recog = 1;body = Makeindex
        recog = 2;body = ItemIdx
        recog = 3;body = ItemName
    ]]
    local header = msg:GetHeader()
    if header.recog == 1 or header.recog == 2 or header.recog == 3 then
        local msgLen = msg:GetDataLength()
        if msgLen > 0 then
            local isAdd = header.param1 ~= 1 and true or false  -- 1删除  非1添加
            local dataString = msg:GetData():ReadString(msgLen)
            local count = self._not_tip_equips[header.recog][tostring(dataString)] or 0
            count = isAdd and (count + 1) or (count - 1)
            self._not_tip_equips[header.recog][tostring(dataString)] = count > 0 and count or nil
        end
    elseif header.recog == 99 then
        local msgLen = msg:GetDataLength()
        if msgLen > 0 then
            local dataString = msg:GetData():ReadString(msgLen)
            local openValue = dataString and tonumber(dataString) or 0
            local isOpen = openValue ~= 1 and true or false  -- 1关闭(因为是不弹出, 所以关闭就是开启)  非1开启
            self._not_tip_equips[99] = not isOpen
        end
    end
end


function AutoUseItemProxy:RegisterMsgHandler()
    AutoUseItemProxy.super.RegisterMsgHandler(self)
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_NOT_AUTO_TIPS_EQUIPS, handler(self, self.handle_MSG_SC_NOT_AUTO_TIPS_EQUIPS))
end

return AutoUseItemProxy