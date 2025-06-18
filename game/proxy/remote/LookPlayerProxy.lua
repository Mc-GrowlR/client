local RemoteProxy = requireProxy("remote/RemoteProxy")
local LookPlayerProxy = class("LookPlayerProxy", RemoteProxy)
LookPlayerProxy.NAME = global.ProxyTable.LookPlayerProxy

function LookPlayerProxy:ctor()
    LookPlayerProxy.super.ctor(self)
    self.lookPlayerData = {}
    self.lookPlayerItems = {}
    self.fashionData = {}
    self.fashionId = {
        dress = 4,
        weapon = 5
    }
    self.titleData = {} --称号数据
    self._titleActive = nil --激活的称号
    self._arr_looks = {} --更换的icon  (key: MakeIndex  valu: iconID)
end

function LookPlayerProxy:onRegister()
    LookPlayerProxy.super.onRegister(self)
end

function LookPlayerProxy:handle_MSG_SC_ROLE_INFO_RESPONSE(msg)
    local header = msg:GetHeader()
    local recog = header.recog
    local openID = header.param1
    local flag = header.param3
    local data = nil
    if msg:GetDataLength() > 0 then 
        data = ParseRawMsgToJson(msg)
    end
    if flag == 1 then --装备分段发
        if not self._cachaData then 
            self._cachaData = data
            self._cacheRecog = recog
            self._cacheOpenID = openID
        else
            for k,v in ipairs(data) do
                table.insert(self._cachaData.Items,v)
            end
        end
        return 
    elseif flag == 2 then --分段结束
        data = self._cachaData
        recog = self._cacheRecog
        openID = self._cacheOpenID
        self._cachaData = nil
        self._cacheRecog = nil
        self._cacheOpenID = nil
    end
    if not data  then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000057))
        return
    end
    self:ClearPlayerData()
    self:SetEmbattle(recog)
    self._titleActive = data.active

    self:SetLookPlayerFashion(data.t_dress, data.t_weapon)

    self:SetLookPlayerData(data)

    self:SetLookPlayerTitle(data.Titles)

    self:SetLookPlayerArrLooks(data.ArrLooks)

    self:SetLookPlayerItemData(data.Items)

    if openID and openID > 0 then
        openID = openID % 100
    else
        openID = nil
    end
    if not SL:GetMetaValue("GAME_DATA","ForbidShowLookLayer") then
        if data.IsHero and data.IsHero == 1 then
            if self.m_val and self.m_val.parent and not tolua.isnull(self.m_val.parent) then
                global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Open_Hero, { extent = openID or SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP, lookPlayer = true, parent = self.m_val.parent, needPage = self.m_val.needPage })
            else
                global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Open_Hero, { extent = openID or SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP, lookPlayer = true })
            end
        else
            if self.m_val and self.m_val.parent and not tolua.isnull(self.m_val.parent) then
                global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Open, { extent = openID or SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP, lookPlayer = true, parent = self.m_val.parent, needPage = self.m_val.needPage })
            else
                global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Open, { extent = openID or SLDefine.PlayerPage.MAIN_PLAYER_LAYER_EQUIP, lookPlayer = true })
            end
        end
    end

    if data.UserId then
        self.playerUid = data.UserId
    end
    ssr.ssrBridge:OnLookPlayerDataUpdate(data)
end

function LookPlayerProxy:SetLookPlayerArrLooks(data)
    local arrArray = string.split(data, "&")
    for k, vv in pairs(arrArray) do
        if vv and vv ~= "" then
            local v = string.split(vv, "#")
            local MakeIndex = v[1] and tonumber(v[1]) or nil
            if MakeIndex then
                local newLooks = v[2] and tonumber(v[2]) or 0
                local newEffect = v[3] and tonumber(v[3]) or 0
                self._arr_looks[MakeIndex] = {
                    newLooks = newLooks,
                    newEffect = newEffect
                }
            end
        end
    end
end

function LookPlayerProxy:SetLookPlayerTitle(data)
    self._titleData = {}
    if data and next(data) then
        for i, v in pairs(data) do
            local id = v[1]
            local time = v[2]

            local data = { id = id, time = time, index = i }
            self._titleData[i] = data
        end
    end
end

function LookPlayerProxy:GetLookPlayerTitle()
    return self._titleData
end

function LookPlayerProxy:GetLookPlayerTitleActive()
    return self._titleActive
end

function LookPlayerProxy:SetLookPlayerFashion(dress, weapon)
    self.fashionData[self.fashionId.dress + 10000] = dress
    self.fashionData[self.fashionId.weapon + 10000] = weapon
end

function LookPlayerProxy:GetLookPlayerFashionLooks(fashionId)
    local itemId = self.fashionData[fashionId]
    local show = {
        look = nil,
        effect = nil
    }
    if not itemId then
        return show
    end
    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local itemData = ItemConfigProxy:GetItemDataByIndex(itemId)
    if not itemData then
        return show
    end
    if itemData and itemData.Looks then
        show.look = itemData.Looks
    end
    if itemData and itemData.sEffect then
        show.effect = itemData.sEffect
    end
    return show
end

function LookPlayerProxy:SetLookPlayerItemData(Items)
    if not Items or not next(Items) then
        return
    end
    for k, v in pairs(Items) do
        local itemData = ChangeItemServersSendDatas(v)
        local newArrLooks = self._arr_looks[itemData.MakeIndex] or {}
        if newArrLooks.newLooks and newArrLooks.newLooks > 0 then
            itemData.Looks = newArrLooks.newLooks
        end
        if newArrLooks.newEffect and newArrLooks.newEffect > 0 then
            itemData.bEffect = newArrLooks.newEffect
        end
        self.lookPlayerItems[itemData.Where] = itemData
    end
end

function LookPlayerProxy:GetLookPlayerItemDataByPos(pos, beginOnMoving)
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local data = self.lookPlayerItems[pos]
    local list = EquipProxy:GetEquipMappingConfig(pos) -- 单显示位置 多个装备位置共享
    if beginOnMoving and list then
        data = nil
        for _, v in ipairs(list) do
            data = self.lookPlayerItems[v]
            if data then
                break
            end
        end
    end
    return data
end

function LookPlayerProxy:GetEquipDataByName(Name)
    local list = {}
    local data = self:GetLookPlayerItemPosData()
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

function LookPlayerProxy:GetLookPlayerItemDataList(pos)
    local EquipProxy = global.Facade:retrieveProxy(global.ProxyTable.Equip)
    local data = {}
    local list = EquipProxy:GetEquipMappingConfig(pos) -- 单显示位置 多个装备位置共享
    if list then
        for _, v in ipairs(list) do
            local equipData = self.lookPlayerItems[v]
            if equipData then
                table.insert(data, equipData)
            end
        end
    else
        if self.lookPlayerItems[pos] then
            table.insert(data, self.lookPlayerItems[pos])
        end
    end
    if next(data) == nil then
        data = nil
    end
    return data
end

function LookPlayerProxy:GetLookPlayerItemDataByMakeIndex(MakeIndex)
    for k, v in pairs(self.lookPlayerItems) do
        if v.MakeIndex and v.MakeIndex == MakeIndex then
            return v
        end
    end
    return nil
end

function LookPlayerProxy:GetLookPlayerItemPosData()
    return self.lookPlayerItems
end
function LookPlayerProxy:SetEmbattle(data)
    self.embattle = {}
    if data and data ~= 0 then
        self.embattle[1] = H16Bit(data)
        self.embattle[2] = L16Bit(data)
    end
end

function LookPlayerProxy:GetEmbattle()
    return self.embattle
end

function LookPlayerProxy:SetLookPlayerData(data)
    self.lookPlayerData.Job = data.Job
    self.lookPlayerData.Name = data.Name
    self.lookPlayerData.Sex = data.Sex
    self.lookPlayerData.Hair = data.Hair
    self.lookPlayerData.Color = data.Color
    self.lookPlayerData.GuildName = data.GuildName or ""
    self.lookPlayerData.RankName = data.RankName or ""
    self.lookPlayerData.SndaItemBoxOpened = data.SndaItemBoxOpened
    self.lookPlayerData.Level = data.Lv or 0
end

function LookPlayerProxy:GetLookPlayerData()
    return self.lookPlayerData
end

function LookPlayerProxy:GetLookPlayerName()
    return self.lookPlayerData.Name
end

function LookPlayerProxy:GetLookPlayerSex()
    return self.lookPlayerData.Sex
end

function LookPlayerProxy:GetLookPlayerHair()
    return self.lookPlayerData.Hair
end

function LookPlayerProxy:GetLookPlayerNameColor()
    return self.lookPlayerData.Color
end

function LookPlayerProxy:GetLookPlayerGuildName()
    return self.lookPlayerData.GuildName or ""
end

function LookPlayerProxy:GetLookPlayerGuildRankName()
    return self.lookPlayerData.RankName or ""
end

function LookPlayerProxy:GetBestRingsOpenState()
    return self.lookPlayerData.SndaItemBoxOpened
end

function LookPlayerProxy:GetLookPlayerLevel()
    return self.lookPlayerData.Level or 0
end

function LookPlayerProxy:GetLookPlayerUid()
    return self.playerUid
end

function LookPlayerProxy:GetLookPlayerJob()
    return self.lookPlayerData.Job
end

--请求通知脚本查看uid的珍宝
function LookPlayerProxy:RequestLookZhenBao(uid)
    if uid then
        LuaSendMsg(global.MsgType.MSG_CS_SCRIPT_ZHENBAO, 0, 0, 0, 0, uid, string.len(uid))
    end
end

-- 获取数据时进行清理，  因为在请求时进行清理会出现脚本发送了请求而导致数据没有进行清理的问题
function LookPlayerProxy:ClearPlayerData()
    self.lookPlayerData = {}
    self.lookPlayerItems = {}
    self.fashionData = {}
    self._arr_looks = {}
end

function LookPlayerProxy:RequestPlayerData(Uid, val)
    global.Facade:sendNotification(global.NoticeTable.Layer_Look_Player_Close, { id = global.LayerTable.PlayerLayer })
    self.playerUid = Uid
    self.m_val = val
    LuaSendMsg(global.MsgType.MSG_CS_ROLE_EQUIP_INFO_REQUEST, 0, 0, 0, 0, Uid, string.len(Uid))
end

function LookPlayerProxy:RegisterMsgHandler()
    LookPlayerProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    --预请求查看数据
    LuaRegisterMsgHandler(msgType.MSG_SC_ROLE_INFO_RESPONSE, handler(self, self.handle_MSG_SC_ROLE_INFO_RESPONSE))
end

return LookPlayerProxy