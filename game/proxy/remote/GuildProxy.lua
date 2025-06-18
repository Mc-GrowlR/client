local RemoteProxy = requireProxy("remote/RemoteProxy")
local GuildProxy = class("GuildProxy" , RemoteProxy)
GuildProxy.NAME = global.ProxyTable.GuildProxy

local proxyUtils = requireProxy( "proxyUtils" )
local parseOneItemByJson = proxyUtils.parseOneItemByJson

local cjson = require("cjson")

function GuildProxy:ctor()
    GuildProxy.super.ctor(self)
    
    self._info = {}
    self._guildList = {}
    self._worldGuild = {}
    self._totalPage = 1     -- 行会列表总页数
    self._memberList = {}
    self._applyGuildList = {}
    self._isShowStoreRedTips  = false
    self._first = true
    self._createAutoApply = 1 -- 创建行会后是否自动同意申请入会
    self._createAutoLevel = 1 -- 创建行会后自动同意的等级
    self._createCost = {} --创建行会消耗
    self._guildTitle = {} --行会封号

    self._allyApplyList = {} --行会联盟申请列表

    self._guildWarList          = {} -- 行会战列表  自己的行会关系
    self._guildAllyList         = {} -- 行会战列表  自己的行会关系
    self._guildShaBaKeWarList   = {} -- 行会战列表  以沙巴克行会
    self._guildShaBaKeAllyList  = {} -- 行会联盟列表  以沙巴克行会
    self._guildShaBaKe          = nil -- 行会  沙巴克行会

    self._init = true
end

-- 获取世界行会列表
function GuildProxy:GetWorldGuildList(page)
    return self._guildList[page] or {}
end

function GuildProxy:getWorldGuildById(guildId)
    return self._worldGuild[guildId]
end

-- 获取行会成员列表
function GuildProxy:GetMemberList()
    return self._memberList
end

function GuildProxy:getMemberByUID(uid)
    for index ,info in pairs(self._memberList) do
        if info.UserID == uid then
            return info
        end
    end
    return nil
end

function GuildProxy:RemoveMember(uid)
    for index ,info in pairs(self._memberList) do
        if info.UserID == uid then
            self._memberList[index] = nil
        end
    end
end

function GuildProxy:ClearMemberList()
    self._memberList = {} 
end

-- 获取行会申请列表
function GuildProxy:GetApplyGuildList()
    local list = self._applyGuildList
    self._applyGuildList = {}
    return list
end

-- 获取联盟申请列表
function GuildProxy:getAllyApplyList()
    return self._allyApplyList
end

--是否是结盟行会
function GuildProxy:isGuildAlly(guildId)
    local guildInfo = self:getWorldGuildById(guildId)
    if guildInfo and guildInfo.AllyTime and guildInfo.AllyTime >= GetServerTime() then
        return true
    end
    return false
end

-- 获取行会主界面信息
function GuildProxy:GetGuildInfo()
    return self._info
end

function GuildProxy:GetGuildLevel()
    return self._info.Level or 0
end

function GuildProxy:SetGuildLevel(level)
    self._info.Level = level
end

function GuildProxy:GetGuildMemberMax()
    return self._info.membercount or 100
end

--获取行会人数
function GuildProxy:GetGuildMember()
    return self._memberList and #self._memberList or 0
end

function GuildProxy:ClearGuildInfo()
    self._info = {}

    self._guildAllyList = {}
    self._guildWarList = {}
    self._guildShaBaKeAllyList = {}
    self._guildShaBaKeWarList = {}
    self._guildShaBaKe = nil

    global.Facade:sendNotification(global.NoticeTable.RefreshGuildActorColor )
end

function GuildProxy:getAutoJoin()
    return self._info.autojoin == 1
end

function GuildProxy:getJoinLevel()
    return self._info.joinlevel or 0
end

-- 创建行会是否可以自动加入
function GuildProxy:SetCreateAutoApply(value)
    self._createAutoApply = value
end

function GuildProxy:GetCreateAutoApply(value)
    return self._createAutoApply
end

function GuildProxy:SetCreateAutoLevel(value)
    self._createAutoLevel = value
end

function GuildProxy:GetCreateAutoLevel()
    return self._createAutoLevel
end

function GuildProxy:saveGuildTitle(data)
    self._guildTitle = {}
    for i=1,20 do
        local title = data["rank"..i]
        if title then
            self._guildTitle[i] = title
        end
    end
end

function GuildProxy:getGuildTitleByRank(rank)
    return self._guildTitle[rank]
end

function GuildProxy:getGuildTitleList()
    return self._guildTitle or {}
end

-------------------------------行会颜色  beign
function GuildProxy:IsGuildWar()
    if next(self._guildWarList) then
        return true
    end
    local MapProxy = global.Facade:retrieveProxy( global.ProxyTable.Map )
    return MapProxy:IsMapWar()
end

function GuildProxy:GetGuildWarNameColor(guildId)
    if not self:IsGuildWar() then
        return nil
    end
    
    local MapProxy = global.Facade:retrieveProxy( global.ProxyTable.Map )    
    local isMapWar = MapProxy:IsMapWar()
    if not isMapWar and tonumber(global.ConstantConfig.check_guild_color) == 1 then
        isMapWar = true
    end

    if not guildId or guildId == "" or guildId == 0 then
        return isMapWar and SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_FREE_NAME_COLOR) or nil
    end

    local GuildPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
    local myGuildId        = GuildPlayerProxy:GetGuildId()

    if not myGuildId or myGuildId == "" or myGuildId == 0 then
        return isMapWar and SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_FREE_NAME_COLOR) or nil
    end

    if (isMapWar and self._guildAllyList[guildId]) or guildId == myGuildId then
        return SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_ALLY_GUILD_NAME_COLOR)
    end

    if self._guildWarList[guildId] then
        return SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_WAR_GUILD_NAME_COLOR)
    end

    return isMapWar and SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_WAR_GUILD_NAME_COLOR) or nil
end

-- 沙巴克开启颜色
function GuildProxy:GetShaBaKeZoneNameColor(guildId)
    if not guildId or guildId == "" or guildId == 0 then
        return SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_FREE_NAME_COLOR)
    end
    
    local GuildPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
    local myGuildId = GuildPlayerProxy:GetGuildId()

    if not myGuildId or myGuildId == "" or myGuildId == 0 then
        return SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_FREE_NAME_COLOR)
    end

    -- 前提：攻沙开启且在攻沙区域
    -- 自己行会没参加攻杀， 其它行会都是绿色
    if myGuildId ~= self._guildShaBaKe and not self._guildShaBaKeWarList[myGuildId] and not self._guildShaBaKeAllyList[myGuildId] then
        return SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_FREE_NAME_COLOR)
    end

    -- 前提：攻沙开启且在攻沙区域
    -- 不参与攻沙的都是绿色
    if guildId ~= self._guildShaBaKe and not self._guildShaBaKeWarList[guildId] and not self._guildShaBaKeAllyList[guildId] then
        return SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_SHABAKE_FREE_NAME_COLOR)
    end

    -- 结盟颜色
    if myGuildId == guildId or self._guildAllyList[guildId] then
        return SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_ALLY_GUILD_NAME_COLOR)
    end

    -- 守城方都是结盟颜色
    if self._guildShaBaKeAllyList[myGuildId] and self._guildShaBaKeAllyList[guildId] then
        return SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_ALLY_GUILD_NAME_COLOR)
    end

    -- 其余参与攻沙的都是宣战颜色。
    return SL:GetMetaValue("SERVER_OPTIONS", global.MMO.SERVER_WAR_GUILD_NAME_COLOR)
end

-- 行会关系  联盟
function GuildProxy:SetGuildAllyRelation(data, diffData)
    local temp = self._guildAllyList or {}
    self._guildAllyList =  {}
    for k, v in pairs(data or {}) do
        if v and v.GuildID then
            if diffData and not temp[v.GuildID] then
                diffData[v.GuildID] = true
            end
            self._guildAllyList[v.GuildID] = v

            if self._worldGuild[v.GuildID] then
                self._worldGuild[v.GuildID].AllyTime = v.WarAllyTime
            end
        end
    end

    for k,v in pairs(self._worldGuild) do
        if not self._guildAllyList[v.GuildID] and v.AllyTime then
            v.AllyTime = nil
        end
    end

    if diffData then
        for k, v in pairs(temp) do
            if k and not self._guildAllyList[k] then
                diffData[k] = true
            end
        end
    end
end

-- 行会关系  宣战
function GuildProxy:SetGuildWarRelation(data,diffData)
    local temp = self._guildWarList or {}
    self._guildWarList = {}
    for k, v in pairs(data or {}) do
        if v and v.GuildID then
            if diffData and not temp[v.GuildID] then
                diffData[v.GuildID] = true
            end
            self._guildWarList[v.GuildID] = v

            if self._worldGuild[v.GuildID] then
                self._worldGuild[v.GuildID].WarTime = v.WarAllyTime
            end
        end
    end

    for k,v in pairs(self._worldGuild) do
        if not self._guildAllyList[v.GuildID] and v.WarTime then
            v.WarTime = nil
        end
    end

    if diffData then
        for k, v in pairs(temp) do
            if k and not self._guildWarList[k] then
                diffData[k] = true
            end
        end
    end
end

-- 沙巴克行会关系  联盟
function GuildProxy:SetShaBaKeGuildAllyRelation(data, diffData)
    local temp = self._guildShaBaKeAllyList or {}
    self._guildShaBaKeAllyList = {}
    for k, v in pairs(data or {}) do
        if v and v then
            if diffData and not temp[v] then
                diffData[v] = true
            end
            self._guildShaBaKeAllyList[v] = v
        end
    end

    if diffData then
        for k, v in pairs(temp) do
            if k and not self._guildShaBaKeAllyList[k] then
                diffData[k] = true
            end
        end
    end
end

-- 沙巴克行会关系  宣战
function GuildProxy:SetShaBaKeGuildWarRelation(data, diffData)
    local temp = self._guildShaBaKeWarList
    self._guildShaBaKeWarList = {}
    for k, v in pairs(data or {}) do
        if v then
            if diffData and not temp[v] then
                diffData[v] = true
            end
            self._guildShaBaKeWarList[v] = v
        end
    end

    if diffData then
        for k, v in pairs(temp) do
            if k and not self._guildShaBaKeWarList[k] then
                diffData[k] = true
            end
        end
    end
end
-------------------------------行会颜色  end
-----------------------------------------------------消息收发----------------------------------------------------

-- 行会信息
function GuildProxy:RequestGuildInfo()
    local dataStr = ""
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_BUILD_INFO_REQUEST, 0, 0, 0, 0, dataStr, string.len(dataStr))
end

function GuildProxy:ResponseGuildInfo(msg)
    local header = msg:GetHeader()
    local data = msg:GetData()
    if msg:GetDataLength() > 0 then
        local str = data:ReadString(msg:GetDataLength())
        local data = cjson.decode(str)
        if not data then
            return
        end
        local upgrade = false
        if data.Level and self._info and self._info.Level and data.Level > self._info.Level then
            upgrade = true
        end

        self._info = data
        self:saveGuildTitle(data)

        SLBridge:onLUAEvent(LUA_EVENT_GUILD_MAIN_INFO)
        --global.Facade:sendNotification(global.NoticeTable.Layer_Guild_Main_Refresh)
        global.Facade:sendNotification(global.NoticeTable.GuildInfo_Refresh)

        if self._first then
            self._first = false
            self:RequestMemberList()
        end
    end
end

-- 世界行会列表
function GuildProxy:RequestWorldGuildList(page)
    if not page then
        page = 0
    else
        page = math.max(page - 1, 0)
    end
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_LIST_REQUEST, 0, 0, 0, page)
end

function GuildProxy:GetTotalListPage( ... )
    return self._totalPage
end

function GuildProxy:handle_GUILD_LIST_RESPONSE(msg)
    local header = msg:GetHeader()
    local data = msg:GetData()
    local curPage = header.recog
    self._totalPage = header.param1
    if msg:GetDataLength() > 0 then
        local str = data:ReadString(msg:GetDataLength())
        local guildList = cjson.decode(str)
        self._guildList[curPage + 1] = guildList
        for _,v in pairs(guildList) do
            -- 结盟和宣战关系和时间由6216下发为准
            v.AllyTime = self._guildAllyList[v.GuildID] and self._guildAllyList[v.GuildID].WarAllyTime or nil
            v.WarTime  = self._guildWarList[v.GuildID] and self._guildWarList[v.GuildID].WarAllyTime or nil
            self._worldGuild[v.GuildID] = v
            self._worldGuild[v.GuildID]._page = curPage + 1
        end

        SLBridge:onLUAEvent(LUA_EVENT_GUILD_WORLDLIST, curPage + 1)     
    end

    if self._init and self._totalPage > 1 then
        self._init = false
        for i = 2, self._totalPage do
            self:RequestWorldGuildList(i)
        end
    end
end

-- 创建行会
function GuildProxy:RequestCreateGuild(guildName)
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_CREATE_REQUEST, 0, 0, 0, 0, guildName, string.len(guildName))
end

function GuildProxy:ResponseCreateGuild(msg)
    local header = msg:GetHeader()
    local data = msg:GetData()

    if header.recog == 0 then
        local GuildPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
        GuildPlayerProxy:SetJoinGuild(true)
        GuildPlayerProxy:SetRank(GuildPlayerProxy.GuildRank.chairman)

        SL:CloseGuildCreateUI()
        SL:OpenGuildMainUI()

        -- 同意自动申请入会
        local auto = self:GetCreateAutoApply()
        local autoLevel = self:GetCreateAutoLevel()
        self:RequestAutoAddMember( auto, autoLevel )

         -- 创建行会
         local VoiceManagerProxy = global.Facade:retrieveProxy( global.ProxyTable.VoiceManagerProxy )
         VoiceManagerProxy:VoiceGuildChange({
             operatorType = GuildPlayerProxy.ChangeType.CREATE
         })

        self:RequestGuildInfo()

    elseif header.recog == -1 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000075))
    elseif header.recog == -2 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000076))
    elseif header.recog == -3 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000077))
    elseif header.recog == -4 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000079))
    elseif header.recog == -5 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000090))
    elseif header.recog == -6 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000080))
    end
end

-- 行会成员列表
function GuildProxy:RequestMemberList()
    local dataStr = ""
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_MEMBER_REQUEST, 0, 0, 0, 0, dataStr, string.len(dataStr))
end

function GuildProxy:ResponseMemberList(msg)
    local header = msg:GetHeader()
    local data = msg:GetData()
    local str = data:ReadString(msg:GetDataLength())
    self._memberList = cjson.decode(str)
    if not self._memberList then
        self._memberList = {}
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_Guild_Member_Refresh)

    local GuildPlayerProxy = global.Facade:retrieveProxy( global.ProxyTable.GuildPlayerProxy )
    if not GuildPlayerProxy:GetJoinMemberFinish() then
        GuildPlayerProxy:SetJoinMemberFinish( true )
    end
end

function GuildProxy:RequestAddMember(uid)
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_ADD_MEMBER_REQUEST, 1, 0, 0, 0, uid, string.len(uid))
end

function GuildProxy:ResponseAddMember(msg)
    local header = msg:GetHeader()
    if header.recog == 1 then
        --[[
            0  成功
            -1 不是行会成员
            -2 没有行会
            -3 不是会长 副会长
            -4 拒绝加入
        ]]
        local code = header.param1
        if code == 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000036))
        elseif code == -1 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000088))
        end
    end

    -- 弹气泡处理
    if header.param2 == 0 then 
        local data = {}
        data.id = 10
        data.status = false 
        global.Facade:sendNotification( global.NoticeTable.BubbleTipsStatusChange, data )
    end 

    self:RequestMemberList()
end

function GuildProxy:RequestAllAddMember()
    local dataStr = ""
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_ADD_MEMBER_REQUEST, 2, 0, 0, 0, dataStr, string.len(dataStr))
end

function GuildProxy:RequestRefuseMember(uid)
    LuaSendMsg(global.MsgType.MS_CS_GUILD_REFUSE_MEMBER_REQUEST, 1, 0, 0, 0, uid, string.len(uid))
end

function GuildProxy:ResponseRefuseMember(msg)
    local header = msg:GetHeader()
    if header.param2 == 0 then -- 弹气泡处理
        local data = {}
        data.id = 10
        data.status = false 
        global.Facade:sendNotification( global.NoticeTable.BubbleTipsStatusChange, data )
    end 
end

function GuildProxy:RequestAutoAddMember(auto, level)
    local data = {}
    data.AutoJoin = auto
    data.JoinLevel = tonumber(level) or 1

    local jsonStr = cjson.encode(data)
    if not jsonStr then
        return nil
    end
    dump(data)
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_JOIN_CONDITON, 0, 0, 0, 0, jsonStr, string.len(jsonStr))
end

-- 行会申请列表
function GuildProxy:RequestApplyGuildList()
    local dataStr = ""
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_JOIN_LIST_REQUEST)
end

function GuildProxy:ResponseApplyGuildList(msg)
    local header = msg:GetHeader()
    local data = msg:GetData()
    if msg:GetDataLength() > 0 then
        local str = data:ReadString(msg:GetDataLength())
        self._applyGuildList = cjson.decode(str)
        if not self._applyGuildList then
            self._applyGuildList = {}
            return 
        end

        local GuildPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
        if GuildPlayerProxy:IsChairman() then
            -- 主界面气泡
            local function callback()
                SL:OpenGuildApplyListUI()
            end

            local data    = {}
            data.id       = 10
            data.status   = #self._applyGuildList > 0 
            data.callback = callback
            global.Facade:sendNotification( global.NoticeTable.BubbleTipsStatusChange, data )
            global.Facade:sendNotification( global.NoticeTable.Layer_Guild_ApplyList_Refresh )
        end
    end    
end


function GuildProxy:RequestEditNotice(notice)
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_NOTICE,0, 0, 0, 0,notice,string.len(notice))
end

function GuildProxy:ResponseEditNotice(msg)
    local header = msg:GetHeader()
    local data = msg:GetData()

    --  1: 参数1为结果 header.param1
    --  0：成功
    -- -3：权限不够
    -- -4：文字太长
    self:RequestGuildInfo()
end

function GuildProxy:RequestGuildInviteOther(uid)
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_INVITE_OTHER_REQUEST,0, 0, 0, 0,uid,string.len(uid))
end

function GuildProxy:ResponseGuildInviteOther(msg)
    local header = msg:GetHeader()

    if header.recog == 0 then
        --成功
    elseif header.recog == -3 then
        --邀请玩家已经有行会
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000070))
    elseif header.recog == -4 then
        --自己行会为空
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000071))
    elseif header.recog == -6 then
        --玩家上次退会时间未到
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000072))
    elseif header.recog == -5 then
        --权限不够
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000073))
    elseif header.recog == -2 then
        --邀请玩家不在线
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000074))
    elseif header.recog == -7 then
        --行会已满
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000056))
    end
end

function GuildProxy:ResponseGuildInviteEnter( msg )
    local header = msg:GetHeader()
    local data = msg:GetData()
    local length = msg:GetDataLength()
    if length > 0 then
        local str = data:ReadString( length )
        local jsonData = cjson.decode(str)
        if not jsonData then
            return
        end

        local data = { }
        data.str = string.format( GET_STRING( 50000003 ) , jsonData.Name , jsonData.GuildName )
        data.btnType = 2
        data.callback = function( tag )
            if tag == 1 then
                self:RequestGuildAcceptInvite( jsonData.UserID )
            end
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
    end
end

function GuildProxy:RequestGuildAcceptInvite( param )
    LuaSendMsg( global.MsgType.MSG_CS_GUILD_ACCEPT_INVITE_REQUEST,0, 0, 0, 0,param,string.len( param ) )
end

function GuildProxy:ResponseGuildAcceptInvite( msg )
    local header = msg:GetHeader()
    local data = msg:GetData()
    dump(header)

    self:RequestGuildInfo()
end

--更新行会职位
function GuildProxy:ResponseUpdateGuildJob(msg)
    local header = msg:GetHeader()
    local data = msg:GetData()
    if msg:GetDataLength() > 0 then
        local str = data:ReadString(msg:GetDataLength())
        local list = cjson.decode(str)
        for id,job in pairs(list) do
            for _,v in pairs(self._memberList) do
                if v.UserID == id then
                    if job == 1 then
                        --会长
                        self._info.AdminName = v.ChrName
                        self._info.AdminId = id
                    end

                    v.Rank = job
                end
            end
        end
    end
end

--创建行会消耗
function GuildProxy:RequestGuildCreateCost()
    LuaSendMsg( global.MsgType.MSG_CS_GUILD_CREATE_COST_REQUEST )
end

function GuildProxy:handle_MSG_SC_GUILD_CREATE_COST_RESPONSE(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end

    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local data = {
        index = ItemConfigProxy:GetItemIndexByName(jsonData.item),
        gold = jsonData.gold,
        item = jsonData.item,
    }
    self._createCost = data

    SLBridge:onLUAEvent(LUA_EVENT_GUILD_CREATE)
end

function GuildProxy:getCreateCost()
    return self._createCost
end

--设置行会封号
function GuildProxy:RequestSetGuildTitle(data)
    --[[
        rank1 = "xx",
        rank2 = "xx",
        rank3 = "xx",
        rank4 = "xx",
        rank5 = "xx"
    ]]
    local jsonStr = cjson.encode(data)
    if not jsonStr then
        return nil
    end
    LuaSendMsg(global.MsgType.MSG_CS_SET_GUILD_TITLE_REQUEST, 0, 0, 0, 0, jsonStr, string.len(jsonStr))
end

function GuildProxy:handle_MSG_SC_SET_GUILD_TITLE_RESPONSE(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end
    
    self:saveGuildTitle(jsonData)
    global.Facade:sendNotification(global.NoticeTable.Layer_Guild_Member_Refresh)
end

--行会宣战
function GuildProxy:RequestGuildSponsor(guildId, param)
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_WAR_SPONEOR_REQUEST, param, 0, 0, 0, guildId,string.len( guildId ))
end

function GuildProxy:handle_MSG_SC_GUILD_WAR_SPONEOR_REPONSE(msg)
    local header = msg:GetHeader()
    if header.recog == 0 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001420)) 
        -- GuildProxy:RequestWorldGuildList()

    elseif header.recog == -1 then
        --当前还没行会
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001416))   
    elseif header.recog == -2 then
        --宣战的行会不存在
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001417))   
    elseif header.recog == -3 then
        --已经是宣战状态
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001418))   
    elseif header.recog == -4 then
        --宣战费用不足
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001419))   
    elseif header.recog == -5 then
        --权限不足
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001413))   
    elseif header.recog == -6 then
        --不能对自己的行会宣战
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001421))   
    end
end

--申请结盟
function GuildProxy:RequestGuildAlly(guildId, param)
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_ALLY_SPONEOR_REQUEST, param, 0, 0, 0, guildId,string.len( guildId ))
end

function GuildProxy:handle_MSG_SC_GUILD_ALLY_SPONEOR_REPONSE(msg)
    local header = msg:GetHeader()
    dump(header)

    local recog = header.recog
    if recog == 0 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001434))
    elseif recog == -1 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001435))
    elseif recog == -2 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001436))
    elseif recog == -3 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001437))
    elseif recog == -4 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001438))
    elseif recog == -5 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001439))
    elseif recog == -6 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001440))
    elseif recog == -7 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001441))
    elseif recog == -8 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001442))
    elseif recog == -9 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001443))
    elseif recog == -10 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001451))
    end
end

--结盟操作
function GuildProxy:RequestGuildAllOperationy(guildId, param)
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_ALLY_OPERATION_REQUEST, param, 0, 0, 0, guildId,string.len( guildId ))
end

function GuildProxy:handle_MSG_SC_GUILD_ALLY_OPERATION_REPONSE(msg)
    local header = msg:GetHeader()
    dump(header)

    local recog = header.recog
    if recog == 0 then
        -- self:RequestWorldGuildList()
    elseif recog == -1 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001444))
    elseif recog == -2 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001445))
    elseif recog == -3 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001446))
    elseif recog == -4 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50001447))
    end
end

--结盟申请列表
function GuildProxy:RequestGuildAllyApplyList()
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_ALLY_APPLYLIST_REQUEST)
end

function GuildProxy:handle_MSG_SC_GUILD_ALLY_APPLYLIST_REPONSE(msg)
    local header = msg:GetHeader()
    local jsonData = ParseRawMsgToJson(msg) or {}

    self._allyApplyList = jsonData
    
    local function callback()
        SL:OpenGuildAllyApplyUI()
    end
    local data    = {}
    data.id       = 13
    data.status   = #self._allyApplyList > 0 
    data.callback = callback
    global.Facade:sendNotification( global.NoticeTable.BubbleTipsStatusChange, data )

    SLBridge:onLUAEvent(LUA_EVENT_GUILDE_ALLY_APPLY_UPDATE)
end

function GuildProxy:handle_MSG_SC_GUILD_ALLY_BACK_REPONSE(msg)
    local header = msg:GetHeader()

    local data = msg:GetData()
    local name = data:ReadString(msg:GetDataLength())
    local recog = header.recog
    if recog == 1 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, string.format(GET_STRING(50001448), name))
        -- self:RequestWorldGuildList()
    elseif recog == 2 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, string.format(GET_STRING(50001449), name))
    end
end

--结盟申请列表
function GuildProxy:RequestGuildCrazy(type)
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_CRAZY_REQUEST, type)
end

--取消结盟
function GuildProxy:RequestGuildCancelAlly(guildId)
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_CANCEL_ALLY__REQUEST, 0, 0, 0, 0, guildId,string.len( guildId ))
end

function GuildProxy:handle_MSG_SC_GUILD_CANCEL_ALLY_REPONSE(msg)
    -- self:RequestWorldGuildList()
end

--取消宣战
function GuildProxy:RequestGuildCancelWar(guildId)
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_CANCEL_WAR_REQUEST, 0, 0, 0, 0, guildId,string.len( guildId ))
end

function GuildProxy:handle_MSG_SC_GUILD_CANCEL_WAR_REPONSE(msg)
    -- self:RequestWorldGuildList()
end

-- 用于前端的攻击对象判断，行会结盟、宣战都会经过该触发，参数1：1开启，0关闭，参数2：宣战、结盟时间，字符串为 行会ID。
-- WarTime 宣战， AllyTime 结盟
function GuildProxy:handle_MSG_SC_REFRESH_ALLY_GUILD(msg)
    local header = msg:GetHeader()
    local isOpen = header.recog

    local guildName = ""
    local data = msg:GetData()
    local guildID = data:ReadString(msg:GetDataLength())
    if self._worldGuild[guildID] then
        self._worldGuild[guildID].AllyTime = header.param1
        if isOpen == 0 then
            self._worldGuild[guildID].AllyTime = nil
        end
        guildName = self._worldGuild[guildID].GuildName
        self:RequestWorldGuildList(self._worldGuild[guildID]._page)
    end

    if isOpen == 0 then
        self._guildAllyList[guildID] = nil
    else
        self._guildAllyList[guildID] = {
            GuildID = guildID,
            GuildName = guildName,
            WarAllyTime = header.param1
        }
    end

    local diffData = {[guildID] = true}
    global.Facade:sendNotification(global.NoticeTable.RefreshGuildActorColor,{guilds=diffData})
end

function GuildProxy:handle_MSG_SC_REFRESH_WAR_GUILD(msg)
    local header = msg:GetHeader()
    local isOpen = header.recog

    local guildName = ""
    local data = msg:GetData()
    local guildID = data:ReadString(msg:GetDataLength())
    if self._worldGuild[guildID] then
        self._worldGuild[guildID].WarTime = header.param1
        if isOpen == 0 then
            self._worldGuild[guildID].WarTime = nil
        end
        guildName = self._worldGuild[guildID].GuildName
        self:RequestWorldGuildList(self._worldGuild[guildID]._page)
    end

    local isWarState = self:IsGuildWar()
    if isOpen == 0 then
        self._guildWarList[guildID] = nil
    else
        self._guildWarList[guildID] = {
            GuildID = guildID,
            GuildName = guildName,
            WarAllyTime = header.param1
        }
    end

    local diffData = nil
    if isWarState == self:IsGuildWar() then
        diffData = {[guildID] = true}
    end
    global.Facade:sendNotification(global.NoticeTable.RefreshGuildActorColor,{guilds=diffData})
end

-- 行会关系消息
function GuildProxy:handle_MSG_SC_GUILDRELATION(msg)
    local jsonData = ParseRawMsgToJson(msg) or {}

    local diffData = {}
    self:SetGuildAllyRelation(jsonData.GuildAllList, diffData)
    self:SetGuildWarRelation(jsonData.GuildWarList, diffData)

    -- 有改变   自身行会也要刷新
    if next(diffData) then
        local GuildPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
        local myGuildId = GuildPlayerProxy:GetGuildId()
        if myGuildId and diffData ~= "" then
            diffData[myGuildId] = true
        end
    end

    global.Facade:sendNotification( global.NoticeTable.RefreshGuildActorColor, {guilds=diffData} )
end

-- 沙巴克开启关闭消息
function GuildProxy:handle_MSG_SC_UNDERWAR(msg)
    local header = msg:GetHeader()
    local jsonData = ParseRawMsgToJson(msg) or {}

    if self._guildShaBaKe ~= jsonData.Castle then
        self._guildShaBaKeAllyList = {}
        self._guildShaBaKeWarList = {}
    end
    
    self._guildShaBaKe = jsonData.Castle

    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    MapProxy:SetShaBaKeOpen(header.recog == 1)

    local diffData = {}
    self:SetShaBaKeGuildAllyRelation(jsonData.GuildAllList, diffData)
    self:SetShaBaKeGuildWarRelation(jsonData.GuildWarList, diffData)

    global.Facade:sendNotification( global.NoticeTable.RefreshGuildActorColor, {guilds=diffData} )
end

function GuildProxy:onRegister()
    GuildProxy.super.onRegister(self)
end

function GuildProxy:RegisterMsgHandler()
    -- 创建行会
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_CREATE_RESPONSE, handler(self, self.ResponseCreateGuild))

    -- 行会成员列表
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_MEMBER_RESPONSE, handler(self, self.ResponseMemberList))

    -- 行会主界面信息
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_BUILD_INFO, handler(self, self.ResponseGuildInfo))

    --世界行会列表
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_LIST_RESPONSE, handler(self, self.handle_GUILD_LIST_RESPONSE))

    -- 入会申请列表
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_JOIN_LIST_RESPONSE, handler(self, self.ResponseApplyGuildList))

    -- 同意入会申请
    LuaRegisterMsgHandler(global.MsgType.MSG_CS_GUILD_ADD_MEMBER_RESPONSE, handler(self, self.ResponseAddMember))

    -- 拒绝入会申请
    LuaRegisterMsgHandler(global.MsgType.MS_CS_GUILD_REFUSE_MEMBER_RESPONSE, handler(self, self.ResponseRefuseMember))

    -- 修改公告
    LuaRegisterMsgHandler(global.MsgType.MSG_CS_GUILD_NOTICE_RESPONSE, handler(self, self.ResponseEditNotice))

    -- 邀请入会结果
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_INVITE_OTHER_RESPONSE, handler(self, self.ResponseGuildInviteOther))

    -- 被邀请入会信息
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_INVITE_ENTER_RESPONSE, handler(self, self.ResponseGuildInviteEnter))

    -- 接受邀请入会
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_ACCEPT_INVITE_RESPONSE, handler(self, self.ResponseGuildAcceptInvite))

    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_UPDATE_JOB_UPDATE, handler(self, self.ResponseUpdateGuildJob))

    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_CREATE_COST_RESPONSE, handler(self, self.handle_MSG_SC_GUILD_CREATE_COST_RESPONSE) )
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_SET_GUILD_TITLE_RESPONSE, handler(self, self.handle_MSG_SC_SET_GUILD_TITLE_RESPONSE) )

    --结盟 宣战
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_WAR_SPONEOR_REPONSE, handler(self, self.handle_MSG_SC_GUILD_WAR_SPONEOR_REPONSE))
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_ALLY_SPONEOR_REPONSE, handler(self, self.handle_MSG_SC_GUILD_ALLY_SPONEOR_REPONSE))
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_ALLY_OPERATION_REPONSE, handler(self, self.handle_MSG_SC_GUILD_ALLY_OPERATION_REPONSE))
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_ALLY_APPLYLIST_REPONSE, handler(self, self.handle_MSG_SC_GUILD_ALLY_APPLYLIST_REPONSE))
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_ALLY_BACK_REPONSE, handler(self, self.handle_MSG_SC_GUILD_ALLY_BACK_REPONSE))
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_CANCEL_ALLY_REPONSE, handler(self, self.handle_MSG_SC_GUILD_CANCEL_ALLY_REPONSE))
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_CANCEL_WAR_REPONSE, handler(self, self.handle_MSG_SC_GUILD_CANCEL_WAR_REPONSE))

    LuaRegisterMsgHandler(global.MsgType.MSG_SC_REFRESH_ALLY_GUILD, handler(self, self.handle_MSG_SC_REFRESH_ALLY_GUILD))
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_REFRESH_WAR_GUILD, handler(self, self.handle_MSG_SC_REFRESH_WAR_GUILD))

    -- 行会关系 服务端会及时刷新
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILDRELATION, handler(self, self.handle_MSG_SC_GUILDRELATION))
    -- 沙巴克行会的关系列表
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_UNDERWAR, handler(self, self.handle_MSG_SC_UNDERWAR))
end

return GuildProxy
--endregion
