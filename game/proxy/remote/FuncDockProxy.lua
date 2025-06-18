local RemoteProxy = requireProxy("remote/RemoteProxy")

local FuncDockProxy = class("FuncDockProxy", RemoteProxy)
FuncDockProxy.NAME = global.ProxyTable.FuncDockProxy
local cjson = require("cjson")

FuncDockProxy.FuncDockType = {
    Func_Player_Head        = 1, --点击玩家头像
    Func_Friend             = 2, --好友界面
    Func_Team               = 3, --左侧组队导航栏
    Func_Guild              = 4, --行会界面
    Func_Friend_Recent      = 5, --好友最近联系界面
    Func_Friend_Enemy       = 6, --好友仇敌界面
    Func_Friend_BlackList   = 7, --好友黑名单界面
    Func_TeamLayer          = 8, --组队界面
    Func_Monster_Head       = 9, --点击人形怪头像
    Func_Near_Player        = 10, --附近玩家
}

FuncDockProxy.BtnOperatorType = {
    look_role       = 1, --查看玩家
    add_friend      = 2, --添加好友
    chat            = 3, --私聊
    team            = 4, --组队
    trade           = 5, --交易
    invite_team     = 6, --邀请入队
    invite_guild    = 7, --邀请入会
    apply_team      = 8, --申请入队
    out_team        = 10,--踢出队伍
    set_teamLeader  = 11,--升为队长
    add_blacklist   = 12,--拉黑
    out_guild       = 13, --踢出行会
    call_teammate   = 14, --召集队员
    send_position   = 15, --发送位置
    exit_team       = 16, --退出队伍

    out_blacklist   = 21, --踢出黑名单
    delete_friend   = 22, --删除好友

    challenge       = 24, --挑战

    horse_invite    = 25, --骑马邀请

    appoint_rank1   = 101, --转移会长
    appoint_rank2   = 102, --任命副会
    appoint_rank3   = 103, --行会 任命职位
    appoint_rank4   = 104, --行会 任命职位
    appoint_rank5   = 105, --行会 任命职位
}

local FuncType = FuncDockProxy.FuncDockType
local BtnType = FuncDockProxy.BtnOperatorType

function FuncDockProxy:ctor()
    FuncDockProxy.super.ctor(self)
    self._targetName = ""
    self._targetId = nil
    self._targetType = nil
    self._playerBasic = nil --查看玩家的基础信息
end

function FuncDockProxy:clean()
    self._targetName = ""
    self._targetId = nil
    self._targetType = nil
    self._playerBasic = nil
end

function FuncDockProxy:SetTargetName(name)
    self._targetName = name
end

function FuncDockProxy:GetTargetName()
    return self._targetName
end

function FuncDockProxy:SetTargetId(id)
    self._targetId = id
end

function FuncDockProxy:GetTargetId()
    return self._targetId
end

function FuncDockProxy:SetTargetType(posType)
    self._targetType = posType
end

function FuncDockProxy:GetTargetType()
    return self._targetType
end

function FuncDockProxy:SetPlayerBasic(data)
    self._playerBasic = data
end

function FuncDockProxy:GetPlayerBasic()
    return self._playerBasic
end

function FuncDockProxy:CanOpen(data)
    if global.gamePlayerController:GetMainPlayerID() == data.targetId and (data.type ~= FuncType.Func_Team and data.type ~= FuncType.Func_TeamLayer) then
        return false
    end
    return true
end

function FuncDockProxy:IsShowBtn(type, index)
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    local GuildProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildProxy)
    local GuildPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
    local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
    local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)

    -- 英雄，只有查看
    local target = global.actorManager:GetActor(self._targetId)
    if target and target:IsHero() and BtnType.look_role ~= index then
        return false
    end

    local show = true
    if type == FuncType.Func_Team or type == FuncType.Func_TeamLayer then
        if global.gamePlayerController:GetMainPlayerID() == self._targetId then
            show = BtnType.call_teammate == index or BtnType.send_position == index or BtnType.exit_team == index
        else
            if BtnType.call_teammate == index or BtnType.send_position == index or BtnType.exit_team == index then
                show = false

            elseif BtnType.set_teamLeader == index or BtnType.out_team == index then
                show = TeamProxy:IsTeamLeader()
            end
        end

    elseif type == FuncType.Func_Guild then
        local isMaster = GuildPlayerProxy:IsMaster()
        local isChairman = GuildPlayerProxy:IsChairman()
        local info = GuildProxy:getMemberByUID(self._targetId)
        local rank = info.Rank
        if BtnType.appoint_rank2 == index or BtnType.appoint_rank4 == index or BtnType.appoint_rank3 == index or BtnType.appoint_rank1 == index
            or BtnType.appoint_rank5 == index then
            show = false
            if isChairman and info and info.Rank then
                if isMaster then
                    show = true

                else
                    if BtnType.appoint_rank3 == index then
                        show = rank ~= GuildPlayerProxy.GuildRank.elite and not GuildPlayerProxy:IsChairman(rank)
                    elseif BtnType.appoint_rank4 == index then
                        show = rank ~= GuildPlayerProxy.GuildRank.member and not GuildPlayerProxy:IsChairman(rank)
                    elseif BtnType.appoint_rank5 == index then
                        show = rank ~= GuildPlayerProxy.GuildRank.rank5 and not GuildPlayerProxy:IsChairman(rank)
                    elseif BtnType.appoint_rank2 == index then
                        show = false
                    end
                end
            end
        end
        if BtnType.out_guild == index then
            show = isMaster or (isChairman and not GuildPlayerProxy:IsChairman(rank))
        elseif BtnType.invite_team == index then
            show = info.Online == 1
        end

    elseif type == FuncType.Func_Player_Head then
        if not FriendProxy:isInBlacklist( self._targetId ) then
            if BtnType.invite_team == index then
                if self._playerBasic and self._playerBasic.group == 1 then
                    show = false
                end
    
            elseif BtnType.apply_team == index then
                if (self._playerBasic and self._playerBasic.group == 0) or TeamProxy:GetMemberCount() > 0 then
                    show = false
                end
    
            elseif BtnType.invite_guild == index then
                if (self._playerBasic and self._playerBasic.guild) or not GuildPlayerProxy:IsJoinGuild() then
                    show = false
                end
            end

        else
            show = false
            if BtnType.look_role == index then
                show = true
            end
        end
        
        if BtnType.look_role == index and target and target:IsHumanoid() then --人形怪
            local disHeadLookHumanoid = tonumber(SL:GetMetaValue("GAME_DATA","disHeadLookHumanoid")) == 1
            if disHeadLookHumanoid then
                show = false
            end
        end
    end

    if index == BtnType.add_friend then
        show = not FriendProxy:getFriendDataByUid( self._targetId ) and PlayerPropertyProxy:GetRoleUID() ~= self._targetId
    elseif index == BtnType.add_blacklist then
        --拉黑
        show = not FriendProxy:isInBlacklist( self._targetId )
    elseif index == BtnType.out_blacklist then
        --移除黑名单
        show = FriendProxy:isInBlacklist( self._targetId )
    elseif BtnType.invite_team == index then
        if TeamProxy:IsTeamMember(self._targetId) then
            show = false
        end
    elseif BtnType.trade == index then
        if tonumber(SL:GetMetaValue("GAME_DATA","CloseTradeFunc")) == 1 then
            show = false
        end
    elseif BtnType.horse_invite == index then --骑马邀请
        local mainActor = global.gamePlayerController:GetMainPlayer()
        if not mainActor or (mainActor and not mainActor:IsDoubleHorse()) then --不是双人坐骑
            show = false
        end
        local targetActor = global.actorManager:GetActor(self._targetId)
        if not targetActor or not targetActor:IsPlayer() then
            show = false
        end
        if mainActor and mainActor:IsDoubleHorse() and mainActor:GetHorseCopilotID() then --双人坐骑已满
            show = false
        end
    end

    return show
end

--队伍召集令
function FuncDockProxy:TeamCallFunc()
    local PayProxy = global.Facade:retrieveProxy(global.ProxyTable.PayProxy)
    local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
    local memberCount = TeamProxy:GetMemberCount()
    if memberCount <= 0 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000260))
        return
    elseif memberCount == 1 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000263))
        return
    end

    local itemIndex = SL:GetMetaValue("GAME_DATA","Team_assembled") or 3020001
    local costDataParam = {
        itemID = itemIndex,
        itemNum = 1,
    }
    if PayProxy:CheckItemCountEX(costDataParam) then
        local data    = {}
        data.btnType  = 2
        data.str      = GET_STRING( 50000262 )
        data.callback = function(type ,custom)
            if 1 == type then
                UseItemByIndex(itemIndex)
            end
        end
        global.Facade:sendNotification( global.NoticeTable.Layer_CommonTips_Open, data )
    end
end

function FuncDockProxy:onRegister()
    FuncDockProxy.super.onRegister(self)
end

function FuncDockProxy:requestLookStatus(uid,isHero)
    local hero = isHero and 1 or 0
    LuaSendMsg(global.MsgType.MSG_SC_LOOK_STATUS_REQUEST, hero, 0, 0, 0, uid, string.len(uid))
end

local function handle_MSG_SC_LOOK_STATUS_RESPONSE(msg)
    local header = msg:GetHeader()
    local len = msg:GetDataLength()
    if header.recog == -1 then
        --不在线
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(1009))
        return
    end
    if len > 0 then
        local data = msg:GetData()
        local sliceStr = data:ReadString(len)
        local cjson = require("cjson")
        local jsonData = cjson.decode(sliceStr)
        if not jsonData then
            return
        end
        dump(jsonData)
        global.Facade:sendNotification(global.NoticeTable.Layer_Func_Dock_Response, jsonData)
    end
end

function FuncDockProxy:RegisterMsgHandler()
    FuncDockProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler(msgType.MSG_SC_LOOK_STATUS_RESPONSE, handle_MSG_SC_LOOK_STATUS_RESPONSE)
end

return FuncDockProxy
