local RemoteProxy = requireProxy("remote/RemoteProxy")
local GuildPlayerProxy = class("GuildPlayerProxy" , RemoteProxy)
GuildPlayerProxy.NAME = global.ProxyTable.GuildPlayerProxy

local cjson = require("cjson")

GuildPlayerProxy.GuildRank =
{
    chairman        = 1,        -- 会长
    viceChairman    = 2,        -- 副会长
    elite           = 3,        -- 精英
    member          = 4,        -- 会员
    rank5           = 5
}

-- 行会变更类型
GuildPlayerProxy.ChangeType = {
    DISMISS         = 0,        -- 解散
    JOIN_IN         = 1,        -- 加入
    LEAVE           = 2,        -- 离开
    CREATE          = 3         -- 创建
}

function GuildPlayerProxy:ctor()
    GuildPlayerProxy.super.ctor(self)

    self._guildName   = ""      -- 行会名字
    self._guildID     = ""      -- 行会ID
    self._rank        = 0       -- 职位
    self._donateNum   = 0       -- 当天捐献
    self._isJoinGuild = false   -- 是否加入公会

    self._first = true
end

function GuildPlayerProxy:Init()
    
end

function GuildPlayerProxy:GetRank()
    return self._rank or 0
end

function GuildPlayerProxy:SetRank(rank)
    self._rank = rank
end

function GuildPlayerProxy:GetDonateNum()
    return self._donateNum or 0
end

function GuildPlayerProxy:SetDonateNum(num)
    self._donateNum = num
end

function GuildPlayerProxy:IsJoinGuild()
    return self._isJoinGuild or false
end

function GuildPlayerProxy:SetJoinGuild(status)
    self._isJoinGuild = status
end

function GuildPlayerProxy:GetGuildName()
    return self._guildName or ""
end

function GuildPlayerProxy:SetGuildName(name)
    self._guildName = name
end

function GuildPlayerProxy:GetGuildId()
    return self._guildID or ""
end

function GuildPlayerProxy:SetGuildId(guildID)
    self._guildID = guildID
end

-- 获取行会创建时间
function GuildPlayerProxy:GetGuildCreateTime()
    return self._createTime
end

function GuildPlayerProxy:SetGuildCreateTime(createTime)
    self._createTime = createTime
end

-- 是否是会长
function GuildPlayerProxy:IsMaster(rank)
    rank = rank or self:GetRank()
    return rank == GuildPlayerProxy.GuildRank.chairman
end

-- 是否是会长或者副会长
function GuildPlayerProxy:IsChairman(rank)
    rank = rank or self:GetRank()
    return rank == GuildPlayerProxy.GuildRank.chairman or rank == GuildPlayerProxy.GuildRank.viceChairman
end

-- 初始化语音
function GuildPlayerProxy:VoiceInit()
    if not self._first and self._is_bind_player_finish and self._is_join_member_finish then
        local VoiceManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.VoiceManagerProxy)
        VoiceManagerProxy:VoiceInit()
    end
end

function GuildPlayerProxy:SetBindMainPlayerFininsh(isFinish)
    self._is_bind_player_finish = isFinish
    self:VoiceInit()
end

function GuildPlayerProxy:SetJoinMemberFinish(isFinish)
    self._is_join_member_finish = isFinish
    self:VoiceInit()
end

function GuildPlayerProxy:GetJoinMemberFinish()
    return self._is_join_member_finish
end

-- 踢人收人权限
function GuildPlayerProxy:HaveGuildPower(rank)
    rank = rank or self:GetRank()
    return rank < 3
end

function GuildPlayerProxy:GetContribute()
    return GetItemDataNumber(5)
end

function GuildPlayerProxy:handle_GUILD_PLAYER_INFO(msg)
    local head = msg:GetHeader()
    local data = msg:GetData()
    local oldRank = self:GetRank()
    local oldGuildID = self:GetGuildId()
    
    if msg:GetDataLength() > 0 then
        local str = data:ReadString(msg:GetDataLength())
        local info = cjson.decode(str)
        if not info then
            return
        end

        local guildId = info.guildId
        if string.len(oldGuildID) > 0 and not guildId then
            -- 发送退出行会消息
            local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
            GuildProxy:ClearMemberList()
            global.Facade:sendNotification(global.NoticeTable.Exit_Guild)
            ssr.ssrBridge:OnJoinOrExitGuild(2)
        end

        self:SetRank(info.Rank)
        self:SetGuildId(guildId)
        self:SetGuildName(info.guildName)
        self:SetDonateNum(info.GuildGold)
        self:SetGuildCreateTime(info.CreateTime)

        if info.GuildRelation and info.GuildRelation ~= "" then
            local jsonData = cjson.decode(info.GuildRelation)

            local diffData  = {}
            local GuildProxy= global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
            GuildProxy:SetGuildAllyRelation(jsonData.GuildAllList, diffData)
            GuildProxy:SetGuildWarRelation(jsonData.GuildWarList, diffData)
            global.Facade:sendNotification(global.NoticeTable.RefreshGuildActorColor, {guilds=diffData})
        end
    end

    local newGuildID   = self:GetGuildId()
    local oldHaveGuild = string.len(oldGuildID) > 0
    local newHaveGuild = string.len(newGuildID) > 0

    if newHaveGuild then
        self:SetJoinGuild(true)

        global.Facade:sendNotification(global.NoticeTable.Join_Guild)
        local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
        GuildProxy:RequestGuildInfo()
    else
        self:SetJoinGuild(false)
        self._is_join_member_finish = true
    end

    if not oldHaveGuild and newHaveGuild then
        ssr.ssrBridge:OnJoinOrExitGuild(1, self:GetGuildName())
    end

    SL:onLUAEvent(LUA_EVENT_PLAYER_GUILD_INFO_CHANGE)

    if self._first then --语音初始化
        if self._is_bind_player_finish and self._is_join_member_finish then
            local VoiceManagerProxy = global.Facade:retrieveProxy( global.ProxyTable.VoiceManagerProxy )
            VoiceManagerProxy:VoiceInit()
        end
    else
        if oldHaveGuild and newGuildID == oldGuildID then
            if oldRank ~= self:GetRank() then --职位改变
                local VoiceManagerProxy = global.Facade:retrieveProxy( global.ProxyTable.VoiceManagerProxy )
                VoiceManagerProxy:VoiceGuildRoleChange()
            end
        end
        self._exit_guildid = oldGuildID             --保存下离开时的行会id
        if oldHaveGuild and not newHaveGuild and not self._is_diss_guildid then  --离开
            local VoiceManagerProxy = global.Facade:retrieveProxy( global.ProxyTable.VoiceManagerProxy )
            VoiceManagerProxy:VoiceGuildChange({
                operatorType = GuildPlayerProxy.ChangeType.LEAVE,
                guildId = oldGuildID
            })
        elseif oldGuildID ~= newGuildID then -- 刷新行会信息
            if oldHaveGuild then
                local VoiceManagerProxy = global.Facade:retrieveProxy( global.ProxyTable.VoiceManagerProxy )
                VoiceManagerProxy:VoiceGuildChange({
                    operatorType = GuildPlayerProxy.ChangeType.LEAVE,
                    guildId = oldGuildID
                })
            end

            -- 有比赛战模式脚本那直接换行会的情况， 没走198号消息， 统一在这判断是否加入
            local guildId = self:GetGuildId()
            if guildId and guildId ~= "" and not self:IsMaster() then
                local VoiceManagerProxy = global.Facade:retrieveProxy( global.ProxyTable.VoiceManagerProxy )
                VoiceManagerProxy:VoiceGuildChange({
                    operatorType = GuildPlayerProxy.ChangeType.JOIN_IN,
                    guildId = newGuildID
                })
            end
        end
    end

    self._first = false
end

function GuildPlayerProxy:RequestApplyGuild(guildId)
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_APPLY_REQUEST, 0, 0, 0, 0, guildId, string.len(guildId))
end

function GuildPlayerProxy:ResponseApplyGuild(msg)
    local header = msg:GetHeader()
    local data = msg:GetData()
    -- 判断是否成功
    if header.recog == 0 then
        local guildId = nil
        if msg:GetDataLength() > 0 then
            guildId = data:ReadString(msg:GetDataLength())
        end

        -- 显示行会主界面
        global.Facade:sendNotification(global.NoticeTable.Layer_GuildFrame_Refresh)
        
    elseif header.recog == -2 then
        --已经有行会
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000066))
    elseif header.recog == -3 then
        --申请的行会为空
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000067))
    elseif header.recog == -4 then
        --已经申请过
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000068))
    elseif header.recog == -5 then
        --cd中
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000069))
    elseif header.recog == -6 then
        --人数已满
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000082))
    end
end

function GuildPlayerProxy:RequestGuildExit()
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_EXIT_REQUEST, 0, 0, 0, 0, "", 0)
end

function GuildPlayerProxy:ResponseGuildExit(msg)
    local recog = msg:GetHeader().recog
    if recog == 0 then
        SL:CloseGuildMainUI()
    elseif recog == -3 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000091))
    end
end

function GuildPlayerProxy:RequestAppointRank(uid, rank)
    if uid and rank then
        local jsonStr = cjson.encode({UserID = uid, Rank = rank})
        LuaSendMsg(global.MsgType.MSG_SC_GUILD_APPOINT_RANK_REQUEST, 0, 0, 0, 0, jsonStr, string.len(jsonStr))
    end
end

function GuildPlayerProxy:ResponseAppointRank(msg)
    local header = msg:GetHeader()
    local data = msg:GetData()

    --  0 成功
    -- -3 不是成员
    -- -4 操作者没有权限
    -- -5 不能同级操作
    -- -6 不能是自己

    if header.recog == 0 then
        -- 更新职位显示
        if msg:GetDataLength() > 0 then
            local str = data:ReadString(msg:GetDataLength())    
            local jsonData = cjson.decode(str)

            local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
            local member = GuildProxy:getMemberByUID(jsonData.UserID)
            if member then
                member.Rank = jsonData.Rank
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_Guild_Member_Rank_Refresh, jsonData)
            global.Facade:sendNotification(global.NoticeTable.SystemTips,GET_STRING(50000021))
        end

    elseif header.recog == -7 then  -- 人数已满
        global.Facade:sendNotification(global.NoticeTable.SystemTips,GET_STRING(50000020))
    end
end

function GuildPlayerProxy:ResponsePlayerAppointed(msg)
    local header = msg:GetHeader()
    local data = msg:GetData()

    local length = msg:GetDataLength()
    if length > 0 then
        local name = data:ReadString(length)
        global.Facade:sendNotification(global.NoticeTable.SystemTips, string.format(GET_STRING(50000022), name, GetGuildOfficialName(header.recog)))
    end
end

function GuildPlayerProxy:RequestRemoveMember(UserID)
    if UserID then
        LuaSendMsg(global.MsgType.MSG_CS_GUILD_SUB_MEMBER_REQUEST, 0, 0, 0, 0, UserID, string.len(UserID))
    end
end

function GuildPlayerProxy:ResponseRemoveMember(msg)
    local recog = msg:GetHeader().recog
    if recog == 0 then
        global.Facade:sendNotification(global.NoticeTable.Layer_Guild_Member_Remove)
    elseif recog == -1 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000092))
    elseif recog == -3 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000086))
    elseif recog == -4 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000093))
    elseif recog == -5 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000088))
    end
end

function GuildPlayerProxy:RequestDissolveGuild()
    LuaSendMsg(global.MsgType.MSG_CS_GUILD_DISSOLVE_REQUEST, 0, 0, 0, 0, "", 0)
end

function GuildPlayerProxy:ResponseDissolveGuild(msg)
    local recog = msg:GetHeader().recog
    if recog == 0 then
        local guildId = self._exit_guildid or self:GetGuildId()
        -- 解散成功,数据重置
        self:SetRank(0)
        self:SetDonateNum(0)
        self:SetJoinGuild(false)

        local VoiceManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.VoiceManagerProxy)
        VoiceManagerProxy:VoiceGuildChange({
            operatorType = GuildPlayerProxy.ChangeType.DISMISS, 
            guildId = guildId
        })

        self._exit_guildid = nil
        self._is_diss_guildid = false

        SL:CloseGuildMainUI()
    elseif recog == -1 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000094))
    end
end

function GuildPlayerProxy:ResponseDissolveGuildBroadcast(msg)
    local header = msg:GetHeader()
    local data = msg:GetData()

    -- 解散成功,数据重置
    self:SetRank(0)
    self:SetDonateNum(0)
    self:SetJoinGuild(false)

    SL:CloseGuildMainUI()
end

function GuildPlayerProxy:onRegister()
    GuildPlayerProxy.super.onRegister(self)

    -- 行会成员 行会信息
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_SHOW_INTRODUCE_RESPONSE,function(msg) self:handle_GUILD_PLAYER_INFO(msg) end)

    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_APPLY_RESPONSE,function(msg) self:ResponseApplyGuild(msg) end)

    -- 退出行会
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_EXIT_RESPONSE,function(msg) self:ResponseGuildExit(msg) end)

    -- 委派职务
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_APPOINT_RANK_RESPONSE,function(msg) self:ResponseAppointRank(msg) end)

    -- 被委派的玩家
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_PLAYER_APPOINTED,function(msg) self:ResponsePlayerAppointed(msg) end)

    -- 移除会员
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_SUB_MEMBER_RESPONSE,function(msg) self:ResponseRemoveMember(msg) end)

    -- 解散行会
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_DISSOLVE_RESPONSE,function(msg) self:ResponseDissolveGuild(msg) end)

    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GUILD_DISSOLVE_RESPONSE_BROADCAST,function(msg) self:ResponseDissolveGuildBroadcast(msg) end)
end

return GuildPlayerProxy