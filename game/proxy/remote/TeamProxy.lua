local RemoteProxy = requireProxy("remote/RemoteProxy")
local TeamProxy = class("TeamProxy", RemoteProxy)
TeamProxy.NAME = global.ProxyTable.TeamProxy

local cjson = require("cjson")
local bubbleId = 3

-- 0创建队伍 1解散队伍 2加入队伍 3离开队伍 4换队长
TeamProxy.ChangeType = {
    CREATE = 0,
    DISMISS = 1,
    JOIN_IN = 2,
    LEAVE = 3,
    UPDATE = 4,
}

function TeamProxy:ctor()
    TeamProxy.super.ctor(self)

    self._data        = {}
    self._memberMax    = 11         -- 人数上限
    self._noCallRemind = false      -- 不再提醒召集令

    self:Init()
end

function TeamProxy:Init()
    -- 我在队伍中职位 1队长 0队员
    self._data.myRank = 0
    -- 成员列表
    self._data.memberItems = {}
    -- 附近队伍列表
    self._data.nearTeamItems = {}
    -- 申请列表
    self._data.applyItems = {}
    -- 邀请列表
    self._data.inviteItems = {}
    -- 允许组队 1同意 0不同意
    self._data.permit = 0
    -- 自动同意 1同意 0不同意
    self._data.auto = 0
    -- 允许添加
    self._data.permit_add = 0
    -- 允许交易
    self._data.permit_deal = 0
    -- 允许挑战
    self._data.permit_challenge = 0
    -- 允许显示
    self._data.permit_show = 0
    -- 队伍id
    self._data.group_id = 0

    self._is_transfer_team = false -- 是否请求转移队长职位，语音需要请求者去发送消息
    self._exit_team_id = {}        -- 记录下退出队伍的id，语音请求时，升级为队长的人进行发送

    self._memberMax = tonumber(SL:GetMetaValue("GAME_DATA","team_num")) or self._memberMax
end

function TeamProxy:onRegister()
    TeamProxy.super.onRegister(self)
end

function TeamProxy:Tips(tipsStr)
    tipsStr = tipsStr or tostring(tipsStr)
    global.Facade:sendNotification(global.NoticeTable.SystemTips, tipsStr)
end

function TeamProxy:CheckMemberData()
    for _, vItem in pairs(self._data.memberItems) do
        vItem.UserID = vItem.UserID or ""
        vItem.sUserName = vItem.sUserName or ""
        vItem.Sex = vItem.Sex or 0
        vItem.Job = vItem.Job or 0
        vItem.Level = vItem.Level or 0
        vItem.Power = vItem.Power or 0
        vItem.SGuildName = vItem.SGuildName or ""
        vItem.Rand = vItem.Rand or 0
    end
end

function TeamProxy:ClearTeam()
    self:Init()

    self:ClearApplyItems()

    -- 刷新队伍
    SLBridge:onLUAEvent(LUA_EVENT_TEAM_MEMBER_UPDATE)
end

function TeamProxy:LeaveTeam()
    if self:GetMemberCount() <= 0 then
        return false
    end

    -- 清除队伍数据
    self:ClearTeam()
end

function TeamProxy:GetNearTeamItems()
    return self._data.nearTeamItems
end

function TeamProxy:ClearNearTeam()
    self._data.nearTeamItems = {}
    SLBridge:onLUAEvent(LUA_EVENT_TEAM_NEAR_UPDATE)
end

function TeamProxy:GetTeamMember()
    return self._data.memberItems
end

function TeamProxy:ClearTeamMember()
    local memberCount = self:GetMemberCount()

    self._data.memberItems = {}

    -- 踢出 离开队伍
    local VoiceManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.VoiceManagerProxy)
    if memberCount > 1 then   --退出队伍 没有返回数据 就在这里进行判断下是离开还是解散
        VoiceManagerProxy:VoiceTeam({ operateType = TeamProxy.ChangeType.LEAVE,})

    elseif memberCount == 1 then
        self._data.memberItems = {}
        VoiceManagerProxy:VoiceTeam({ operateType = TeamProxy.ChangeType.DISMISS,})
    end
end

function TeamProxy:DealTeam(userID, value)
    local myID = global.gamePlayerController:GetMainPlayerID()
    if myID == userID then
        return false
    end

    local actor = global.actorManager:GetActor(userID) 
    if not actor then
        return false
    end
    actor:SetCampValue("InTeam", value)
    requireProxy("optionsUtils"):InitHUDVisibleValue(actor, global.MMO.PLAYER_B_VISIBLE)
end

function TeamProxy:IsTeamMember(uid)
    if not uid then
        uid = global.gamePlayerController:GetMainPlayerID()
    end
    for _, v in pairs(self._data.memberItems) do
        if v.UserID and v.UserID == uid then
            return true
        end
    end
    return false
end

function TeamProxy:IsTeamLeader(uid)
    if not uid then
        uid = global.gamePlayerController:GetMainPlayerID()
    end
    for _, v in pairs(self._data.memberItems) do
        if v.UserID == uid and v.Rand == 1 then
            return true
        end
    end
    return false
end

function TeamProxy:GetMemberCount()
    if not self._data.memberItems then
        return 0
    end

    return #self._data.memberItems
end

function TeamProxy:GetMemberMax()
    return self._memberMax
end

function TeamProxy:GetMyRank()
    return self._data.myRank
end

function TeamProxy:GetTeamLeaderId()
    return self._data.group_id or 0
end

--允许组队
function TeamProxy:GetPermitStatus()
    return self._data.permit
end

function TeamProxy:SetPermitStatus(status)
    self._data.permit = status
end

--同行会自动进队
function TeamProxy:GetAutoStatus()
    return self._data.auto
end

function TeamProxy:SetAutoStatus(status)
    self._data.auto = status
end

--允许添加
function TeamProxy:GetAddStatus()
    return self._data.permit_add
end

function TeamProxy:SetAddStatus(status)
    self._data.permit_add = status
end

--允许交易
function TeamProxy:GetDealStatus()
    return self._data.permit_deal
end

function TeamProxy:SetDealStatus(status)
    self._data.permit_deal = status
end

--允许挑战
function TeamProxy:GetChallengeStatus()
    return self._data.permit_challenge
end

function TeamProxy:SetChallengeStatus(status)
    self._data.permit_challenge = status
end

--允许显示
function TeamProxy:GetShowStatus()
    return self._data.permit_show
end

function TeamProxy:SetShowStatus(status)
    self._data.permit_show = status
end

function TeamProxy:GetNoCallRemind()
    return self._noCallRemind
end

function TeamProxy:SetNoCallRemind(status)
    self._noCallRemind = status
end

function TeamProxy:GetApplyItems()
    return self._data.applyItems
end

function TeamProxy:removeApplyItemById(id)
    if not self._data.applyItems then return end
    for index, v in pairs(self._data.applyItems) do
        if v.UserID == id then
            table.remove(self._data.applyItems, index)
            return
        end
    end
end

function TeamProxy:ClearApplyItems()
    self._data.applyItems = {}

    -- 气泡
    local tipsData = {}
    tipsData.id = bubbleId
    tipsData.status = false
    global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, tipsData)
end

function TeamProxy:GetInviteItems()
    return self._data.inviteItems
end

function TeamProxy:getInviteCount()
    local count = 0
    for _, v in pairs(self._data.inviteItems) do
        count = count + 1
    end
    return count
end

function TeamProxy:ClearInviteItems()
    self._data.inviteItems = {}

    -- 气泡
    local tipsData = {}
    tipsData.status = false
    tipsData.id = bubbleId
    global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, tipsData)
end

function TeamProxy:RespNearTeam(msg)
    local len = msg:GetDataLength()
    if len <= 0 then
        return
    end
    local msgData = msg:GetData()
    local sliceStr = msgData:ReadString(len)
    local cjson = require("cjson")
    local jsonData = cjson.decode(sliceStr)
    if not jsonData then
        return
    end

    dump(jsonData)
    local nearData = {}
    for _, v in pairs(jsonData) do
        nearData[v.UserID] = v
    end

    -- 附近队伍
    self._data.nearTeamItems = nearData
    SLBridge:onLUAEvent(LUA_EVENT_TEAM_NEAR_UPDATE)
end

function TeamProxy:RespTeamCreateSuccess(msg)
    -- 创建队伍成功
    self:Tips(GET_STRING(50000109))

    self:RequestNearTeam()

    local groupId = 0
    local msgLen = msg:GetDataLength()
    local msgHdr = msg:GetHeader()
    if msgLen > 0 then
        groupId = msg:GetData():ReadString(msgLen)
    end
    self._data.group_id = groupId

    self._data.myRank = 1
    local VoiceManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.VoiceManagerProxy)
    VoiceManagerProxy:VoiceTeam({
        operateType = TeamProxy.ChangeType.CREATE,
        myRank = 1
    })
end

function TeamProxy:RespTeamCreateFailed(msg)
    -- 创建队伍失败
    self:Tips(GET_STRING(50000110))
end

function TeamProxy:RespTeamMemberUpdate(msg)
    local len = msg:GetDataLength()
    if len <= 0 then
        return
    end
    local msgData = msg:GetData()
    local sliceStr = msgData:ReadString(len)
    local jsonData = cjson.decode(sliceStr)
    if not jsonData then
        return
    end

    dump(jsonData)

    local isDel = false

    -- 检测是否有成员退出
    for _,a in pairs(self._data.memberItems) do
        if a then
            local isQuit = true
            for _,b in pairs(jsonData) do
                if a.UserID == b.UserID then
                    isQuit = false
                    break
                end
            end
            if isQuit then
                self._exit_team_id[a.UserID] = true
                global.Facade:sendNotification(global.NoticeTable.SystemTips, string.format(GET_STRING(50000120), a.sUserName))
                SLBridge:onLUAEvent(LUA_EVENT_LEAVETEAM, a.sUserName)
                self:DealTeam(a.UserID, false)
                isDel = true
                break
            end
        end
    end

    -- 没有成员退出，则查看是否有新增
    if isDel == false then
        for _,a in pairs(jsonData) do
            if a then
                local isJoin = true
                for _,b in pairs(self._data.memberItems) do
                    if a.UserID == b.UserID then
                        isJoin = false
                        break
                    end
                end
                if isJoin then
                    SLBridge:onLUAEvent(LUA_EVENT_JOINTEAM, a.sUserName)
                    self:DealTeam(a.UserID, true)
                end
            end
        end
    end

    -- 上次组队
    local lastMemberCount = #self._data.memberItems or 0

    -- 整理队伍信息，自己如果不是队长，放到第二位
    -- 自己在队伍的信息（队长/队员）
    local myRank = self:GetMyRank()
    self._data.myRank = 0
    self._data.memberItems = {}
    local proxyPlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
    local roleUID = proxyPlayerProperty:GetRoleUID()
    local isJoin = false
    local isUpdate = false
    local groupId = self:GetTeamLeaderId()
    local teamUserId = nil --队长id
    for _, v in pairs(jsonData) do
        -- 是否是队长
        if self._data.myRank == 0 and v.UserID == roleUID and v.Rand == 1 then
            self._data.myRank = 1
            isUpdate = myRank ~= self._data.myRank
        end

        if self._exit_team_id[v.UserID] then
            self._exit_team_id[v.UserID] = nil
        end

        if v.Rand == 1 then
            table.insert(self._data.memberItems, 1, v)
            self._data.group_id = v.GroupID
            teamUserId = v.UserID
        elseif v.UserID == roleUID then
            isUpdate = true
            if next(self._data.memberItems) then
                table.insert(self._data.memberItems, 2, v)
                isJoin = true
            else
                table.insert(self._data.memberItems, v)
            end
        else
            table.insert(self._data.memberItems, v)
        end
    end
    self:CheckMemberData()

    -- 广播组队
    SLBridge:onLUAEvent(LUA_EVENT_TEAM_MEMBER_UPDATE)

    if self._data.myRank == 0 then
        self:ClearApplyItems()
    end

    if lastMemberCount ~= #self._data.memberItems then
        if isJoin then
            local VoiceManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.VoiceManagerProxy)
            VoiceManagerProxy:VoiceTeam({
                operateType = TeamProxy.ChangeType.JOIN_IN
            })
        end
    end

    if isUpdate and myRank and myRank ~= self._data.myRank then
        local isVoice = false
        if self._data.myRank == 1 then
            isVoice = true
        end
        local newMyRank = self._data.myRank
        local newTeamUerId = nil
        if next(self._exit_team_id) then
            if self._exit_team_id[roleUID] then
                isVoice = false
            end
        else
            if not self._is_transfer_team then
                isVoice = false
            elseif myRank == 1 then
                newMyRank = myRank
                newTeamUerId = teamUserId
                isVoice = true
            end
        end

        if isVoice then
            self._exit_team_id = {}
            local VoiceManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.VoiceManagerProxy)
            VoiceManagerProxy:VoiceTeam({
                operateType = TeamProxy.ChangeType.UPDATE,
                myRank = newMyRank,
                teamUserId = newTeamUerId
            })
        end
    end
    self._is_transfer_team = false
end

function TeamProxy:RespLeaveTeam(msg)
    -- 踢出队伍的时候，参数是3. 离开队伍的时候，带的参数是2，这两个是有区别的
    local header = msg:GetHeader()
    dump(header)
    if header.recog == 3 then
        -- 被踢出队伍
        self:Tips(GET_STRING(50000112))
    elseif header.recog == 2 then
        -- 离开队伍
        self:Tips(GET_STRING(50000111))
    end

    -- 队伍职位变为队员
    self._data.myRank = 0

    -- 清空队伍成员
    self:ClearTeamMember()

    -- 清空申请列表
    self:ClearApplyItems()

    -- 请求附近队伍
    self:ClearNearTeam()
    self:RequestNearTeam()

    -- 刷新队伍
    SLBridge:onLUAEvent(LUA_EVENT_TEAM_MEMBER_UPDATE)

    local VoiceManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.VoiceManagerProxy)
    VoiceManagerProxy:VoiceTeam({
        operateType = TeamProxy.ChangeType.LEAVE
    })
end

function TeamProxy:RespTeamInvite(msg)
    local header = msg:GetHeader()
    dump(header)
    local len = msg:GetDataLength()
    local voiceTeanChangeType = nil  --语音需要的改变类型
    if header.recog == 0 then
        --邀请入队成功
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000102))

    elseif header.recog == 1 then
        --组队人数上限
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000103))

    elseif header.recog == 2 then
        --已有队伍 
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000104))

    elseif header.recog == 4 then
        --队伍解散
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000105))
        voiceTeanChangeType = TeamProxy.ChangeType.DISMISS

    elseif header.recog == 5 then
        --申请入队失败
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000106))

    elseif header.recog == 6 then
        --已经申请
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000107))

    elseif header.recog == 7 then
        --申请成功
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000108))

    elseif header.recog == 8 then
        --有人申请入队
        local function callback()
            global.Facade:sendNotification(global.NoticeTable.Layer_TeamApply_Open)
        end
        local data = {}
        data.id = bubbleId
        data.status = true
        data.callback = callback
        global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, data)

    elseif header.recog == 9 then
        --申请人下线或死亡
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000114))

    elseif header.recog == 10 then
        --申请人已经入队
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000115))

    elseif header.recog == 11 or header.recog == 12 then
        --11，12=带有字串消息
        if len > 0 then
            local msgData = msg:GetData()
            local tipsStr = msgData:ReadString(len)
            global.Facade:sendNotification(global.NoticeTable.SystemTips, tipsStr)
        end

    elseif header.recog == 13 then
        --踢出队员成功
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000116))

    elseif header.recog == 14 then
        --对方没设置允许组队
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000123))
    end

    if voiceTeanChangeType then
        local VoiceManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.VoiceManagerProxy)
        VoiceManagerProxy:VoiceGuildRoleChange({
            operateType = voiceTeanChangeType,
        })
    end
end

function TeamProxy:showApplyBubbleTips()
    local function callback()
        global.Facade:sendNotification(global.NoticeTable.Layer_TeamApply_Open)
    end

    local applyList = self:GetApplyItems()
    local status = applyList and table.nums(applyList) > 0

    local data = {}
    data.id = bubbleId
    data.status = status
    data.callback = callback
    global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, data)
end

function TeamProxy:RespTeamApplyList(msg)
    local len = msg:GetDataLength()
    if len <= 0 then
        return
    end
    local msgData = msg:GetData()
    local sliceStr = msgData:ReadString(len)
    local jsonData = cjson.decode(sliceStr)
    dump(jsonData)
    if not jsonData or type(jsonData) ~= "table" then
        return
    end

    self._data.applyItems = jsonData
    SLBridge:onLUAEvent(LUA_EVENT_TEAM_APPLY_UPDATE)

    self:showApplyBubbleTips()
end

--被邀请
function TeamProxy:handle_MSG_SC_TEAM_INVITE(msg)
    local len = msg:GetDataLength()
    if len <= 0 then
        return
    end
    local msgData = msg:GetData()
    local sliceStr = msgData:ReadString(len)
    local jsonData = cjson.decode(sliceStr)
    dump(jsonData)
    if (not jsonData) or type(jsonData) ~= "table" then
        return
    end

    if self:GetPermitStatus() == 0 then
        self:RequestApplyRefuse(jsonData.UserID)
        return
    end

    self._data.inviteItems[jsonData.UserID] = jsonData

    local function callback()
        local count = self:getInviteCount()
        if count == 1 then
            SL:OpenTeamBeInvite(jsonData)
            global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, { id = bubbleId, status = false })

        elseif count > 1 then
            local tipsData = {}
            tipsData.list = {}
            for _, v in pairs(self:GetInviteItems()) do
                local data = {}
                data.str = string.format(GET_STRING(50000119), v.sUserName)
                data.agreeCall = function()
                    if v.bMaster then
                        self:RequestInviteAgree(v.UserID)
                    else
                        self:RequestApply(v.GroupId)
                    end
                end
                data.disAgreeCall = function()
                    self:RequestInviteRefuse(v.UserID)
                    if self:getInviteCount() == 0 then
                        global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, { id = bubbleId, status = false })
                    end
                end
                table.insert(tipsData.list, data)
            end

            local MainPropertyMediator = global.Facade:retrieveMediator("MainPropertyMediator")
            if MainPropertyMediator then
                local node = MainPropertyMediator:GetBubbleButtonByID(bubbleId)
                if node and not tolua.isnull(node) then
                    tipsData.pos = node:getWorldPosition()
                end
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_CommonBubbleInfo_Open, tipsData)
        end
    end
    local data = {}
    data.id = bubbleId
    data.status = true
    data.callback = callback
    global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, data)
end

--允许组队
function TeamProxy:RespPermitStatus(msg)
    local header = msg:GetHeader()
    local jsonData = ParseRawMsgToJson(msg)
    -- dump(jsonData)
    if jsonData then
        self:SetPermitStatus(jsonData.AllowGroup or 0)
        self:SetAutoStatus(header.AllowGGroup or 0)
        self:SetAddStatus(jsonData.AllowAdd or 0)
        self:SetDealStatus(jsonData.AllowDeal or 0)
        self:SetChallengeStatus(jsonData.AllowChallenge or 0)
        self:SetShowStatus(jsonData.AllowShow or 0)
    end
end

function TeamProxy:RequestCreateTeam()
    -- 创建队伍
    LuaSendMsg(global.MsgType.MSG_CS_TEAM_CREATE_REQUEST)
end

function TeamProxy:RequestLeaveTeam()
    -- 退出队伍
    -- print("退出队伍")
    LuaSendMsg(global.MsgType.MSG_CS_TEAM_LEAVE)

    local mediator = global.Facade:retrieveMediator("NoticeMediator")
    if mediator:GetEffectsData()[3] then
        local teamId = self:GetTeamLeaderId()
        for _, v in ipairs(mediator:GetEffectsData()[3]) do
            global.Facade:sendNotification(global.NoticeTable.Layer_Notice_RemoveChild, tostring(v))
        end
        mediator:GetEffectsData()[3] = {}
    end
    self._exit_team_id = {}
end

function TeamProxy:RequestNearTeam()
    -- 请求附近队伍
    LuaSendMsg(global.MsgType.MSG_CS_TEAM_NEAR_TEAM_REQUEST)
end

function TeamProxy:RequestInvite(uid, name)
    --没有队伍先创建一个
    if self:GetMemberCount() == 0 then
        self:RequestCreateTeam()
    elseif self:GetMemberCount() >= self:GetMemberMax() then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000122))
        return
    end

    local params = {}
    if uid then
        params.userId = uid
    elseif name then
        params.userName = name
    end
    local jsonData = cjson.encode(params)

    dump(jsonData)

    -- 邀请入队
    LuaSendMsg(global.MsgType.MSG_CS_TEAM_INVITE_REQUEST, 0, 0, 0, 0, jsonData, string.len(jsonData))
end

function TeamProxy:RequestApply(uid)
    -- 申请入队
    if self:GetMemberCount() > 0 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000121))
        return
    end
    LuaSendMsg(global.MsgType.MSG_CS_TEAM_APPLY, 0, 0, 0, 0, uid, string.len(uid))
end

function TeamProxy:RequestApplyData()
    -- 请求申请列表
    LuaSendMsg(global.MsgType.MSG_CS_TEAM_APPLY_LIST_REQUEST)
end

function TeamProxy:RequestApplyAgree(uid)
    if self:GetMemberCount() >= self:GetMemberMax() then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(50000122))
        return
    end
    -- 同意申请
    self:removeApplyItemById(uid)
    LuaSendMsg(global.MsgType.MSG_CS_TEAM_APPLY_CONFIRM, 0, 0, 0, 0, uid, string.len(uid))

    self:showApplyBubbleTips()
end

function TeamProxy:RequestApplyRefuse(uid)
    -- 拒绝申请
    self:removeApplyItemById(uid)
    LuaSendMsg(global.MsgType.MSG_CS_TEAM_APPLY_CONFIRM, 1, 0, 0, 0, uid, string.len(uid))

    self:showApplyBubbleTips()
end

function TeamProxy:RequestInviteRefuse(uid)
    -- 拒绝邀请
    self._data.inviteItems[uid] = nil
    LuaSendMsg(global.MsgType.MSG_CS_TEAM_APPLY_CONFIRM, 1, 0, 0, 0, uid, string.len(uid))
    local function callback()
        global.Facade:sendNotification(global.NoticeTable.Layer_TeamApply_Open)
    end
    local status = self._data.inviteItems and table.nums(self._data.inviteItems) > 0
    local data = {}
    data.id = bubbleId
    data.status = status
    data.callback = callback
    global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, data)
end

function TeamProxy:RequestInviteAgree(uid)
    -- 同意邀请
    LuaSendMsg(global.MsgType.MSG_CS_TEAM_INVITE_AGREE, 0, 0, 0, 0, uid, string.len(uid))

    self._data.inviteItems[uid] = nil
    for _, v in pairs(self:GetInviteItems()) do
        self:RequestApplyRefuse(v.UserID)
    end
    self:ClearInviteItems()
end

function TeamProxy:RequestSubMember(uid)
    -- 请求T人
    LuaSendMsg(global.MsgType.MSG_CS_TEAM_SUB_REQUEST, 0, 0, 0, 0, uid, string.len(uid))
end

function TeamProxy:RequestTransferLeader(uid)
    -- 移交队长
    self._is_transfer_team = true
    LuaSendMsg(global.MsgType.MSG_CS_TEAM_TRANSFER_LEADER, 0, 0, 0, 0, uid, string.len(uid))
end

function TeamProxy:RequestPermit()
    -- 允许组队
    local status = self:GetPermitStatus()
    local auto = self:GetAutoStatus()

    local params = {}
    params.AllowGroup = self:GetPermitStatus()
    params.AllowGGroup = self:GetAutoStatus()
    params.AllowAdd = self:GetAddStatus()
    params.AllowDeal = self:GetDealStatus()
    params.AllowChallenge = self:GetChallengeStatus()
    params.AllowShow = self:GetShowStatus()
    local jsonData = cjson.encode(params)
    LuaSendMsg(global.MsgType.MSG_CS_TEAM_PERMIT_REQUEST, status, auto, 0, 0, jsonData, string.len(jsonData))
end

function TeamProxy:RegisterMsgHandler()
    TeamProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    -- 附近队伍
    LuaRegisterMsgHandler(msgType.MSG_CS_TEAM_NEAR_TEAM_RESPONSE, handler(self, self.RespNearTeam))
    -- 更新队伍信息
    LuaRegisterMsgHandler(msgType.MSG_SC_TEAM_UPDATE_MEMBER, handler(self, self.RespTeamMemberUpdate))
    -- 创建队伍 成功
    LuaRegisterMsgHandler(msgType.MSG_CS_TEAM_CREATE_SUCCESS_RESPONSE, handler(self, self.RespTeamCreateSuccess))
    -- 创建队伍 失败
    LuaRegisterMsgHandler(msgType.MSG_CS_TEAM_CREATE_FAIL_RESPONSE, handler(self, self.RespTeamCreateFailed))
    -- 邀请玩家 回执
    LuaRegisterMsgHandler(msgType.MSG_SC_TEAM_INVITE_RESPONSE, handler(self, self.RespTeamInvite))
    -- 申请列表 回执
    LuaRegisterMsgHandler(msgType.MSG_SC_TEAM_APPLY_LIST_REPONSE, handler(self, self.RespTeamApplyList))
    -- 被邀请
    LuaRegisterMsgHandler(msgType.MSG_SC_TEAM_INVITE, handler(self, self.handle_MSG_SC_TEAM_INVITE))
    --允许组队
    LuaRegisterMsgHandler(msgType.MSG_SC_TEAM_PERMIT_REPONSE, handler(self, self.RespPermitStatus))
end

return TeamProxy