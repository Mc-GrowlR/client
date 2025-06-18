local RemoteProxy = requireProxy("remote/RemoteProxy")
local FriendProxy = class("FriendProxy", RemoteProxy)
FriendProxy.NAME = global.ProxyTable.FriendProxy

local cjson = require("cjson")

-- 服务端的好友类型
FriendProxy.FriendType = {
    Friend    = 1, -- 好友
    Blacklist = 2, -- 黑名单
    Apply     = 3, -- 申请的好友
}

function FriendProxy:ctor()
    self._maxFriend = 100            -- 最大好友人数
    self._friendData = {}            -- 好友列表
    self._friendDataName = {}        -- 好友列表 名称做索引
    self._applyData = {}             -- 申请的好友列表
    self._blacklistData = {}         -- 黑名单

    FriendProxy.super.ctor(self)
end

-- 登录时要请求的数据
function FriendProxy:loginRequest()
    self:RequestFriendList()
    self:requestFriendBlockList()
end

-- 获取最大好友数量
function FriendProxy:getMaxFriendNum()
    return self._maxFriend
end

-- type 1：好友 2: 黑名单 3：申请列表
function FriendProxy:addFriendData(data, type)
    if data == nil then
        return false
    end

    if type == FriendProxy.FriendType.Friend then
        self._friendData[data.UserId] = data
        self._friendDataName[data.Name] = data
        self:removeBlockData(data.UserId)

    elseif type == FriendProxy.FriendType.Blacklist then
        self._blacklistData[data.UserId] = data
        self:removeFriendData(data.UserId)

    elseif type == FriendProxy.FriendType.Apply then
        self._applyData[data.Name] = data    
    end
end

-- 获取好友列表
function FriendProxy:getFriendData()
    return self._friendData
end

-- 根据名字获取好友列表
function FriendProxy:getFriendDataByUid(uid)
    return self._friendData[uid]
end

-- 根据name获取好友
function FriendProxy:getFriendDataByUname(uname)
    return self._friendDataName[uname]
end

-- 从好友列表移除
function FriendProxy:removeFriendData(uid)
    self._friendData[uid] = nil
end

-- 获取好友申请数据
function FriendProxy:getApplyData()
    return self._applyData
end

-- 删除好友申请数据
function FriendProxy:deleteApplyData(uname)
    self._applyData[uname] = nil
end

function FriendProxy:clearApplyData()
    self._applyData = {}
end

-- 获取黑名单列表
function FriendProxy:getBlacklistData()
    return self._blacklistData
end

-- 判断是否是黑名单
function FriendProxy:isInBlacklist(uid)
    if self._blacklistData[uid] then
        return true
    end
    return false
end

-- 根据id获取黑名单列表
function FriendProxy:getBlacklistDataByUid(uid)
    return self._blacklistData[uid]
end

-- 根据玩家昵称获取黑名单
function FriendProxy:getBlacklistDataByUName(uName)
    for _, v in pairs(self._blacklistData) do
        if v.Name == uName then
            return v
        end
    end
    return nil
end

-- 从黑名单列表移除
function FriendProxy:removeBlockData(uid)
    self._blacklistData[uid] = nil
end

-- 请求好友列表
function FriendProxy:RequestFriendList()
    LuaSendMsg(global.MsgType.MSG_CS_FRIEND_LIST_REQUEST)
end

-- 请求黑名单列表
function FriendProxy:requestFriendBlockList()
    LuaSendMsg(global.MsgType.MSG_CS_FRIEND_BLACK_List_REQUEST)
end

-- 请求添加好友
function FriendProxy:requestAddFriend(uid, uname)
    local cjson = require("cjson")
    local jsonData = cjson.encode({ UserId = uid, Name = uname })
    LuaSendMsg(global.MsgType.MSG_CS_FRIEND_ADD_REQUEST, 0, 0, 0, 0, jsonData, string.len(jsonData))
end

-- 请求删除好友
function FriendProxy:requestDelFriend(uid)
    local cjson = require("cjson")
    local jsonData = cjson.encode({ UserId = uid })
    LuaSendMsg(global.MsgType.MSG_CS_FRIEND_DELETE_REQUEST, 0, 0, 0, 0, jsonData, string.len(jsonData))
end

-- 同意好友申请
function FriendProxy:requestAgreeFriendApply(uname)
    local cjson = require("cjson")
    local jsonData = cjson.encode({ Name = uname })
    LuaSendMsg(global.MsgType.MSG_CS_FRIEND_AGREE_REQUEST, 0, 0, 0, 0, jsonData, string.len(jsonData))
end

-- 请求添加黑名单
function FriendProxy:requestAddBlackList(uid, uname)
    local cjson = require("cjson")
    local jsonData = cjson.encode({ UserId = uid, Name = uname })
    LuaSendMsg(global.MsgType.MSG_CS_FRIEND_ADD_BLACK_List_REQUEST, 0, 0, 0, 0, jsonData, string.len(jsonData))
end

-- 请求移除黑名单玩家
function FriendProxy:requestOutBlackList(uid)
    local cjson = require("cjson")
    local jsonData = cjson.encode({ UserId = uid })
    LuaSendMsg(global.MsgType.MSG_CS_FRIEND_OUT_BLACK_List_REQUEST, 0, 0, 0, 0, jsonData, string.len(jsonData))
end

-- 返回服务好友列表（请求/删除都会发送该消息）
function FriendProxy:handle_MSG_SC_FRIEND_LIST_RESPONSE(msg)
    --[[        
        Name
        UserId
        Job
        Online
        Level
        Guild
    ]]
    if msg:GetDataLength() <= 0 then
        return
    end

    local jsonData = ParseRawMsgToJson(msg)

    for name,_ in pairs(self._friendDataName) do
        if name then
            local isQuit = true
            for k,v in pairs(jsonData) do
                if v and v.Name and name == v.Name then
                    isQuit = false
                    break
                end
            end
            if isQuit then
                SLBridge:onLUAEvent(LUA_EVENT_REMFIREND, name)
                break
            end
        end
    end

    self._friendData = {}
    self._friendDataName = {}

    if not jsonData then
        SLBridge:onLUAEvent(LUA_EVENT_FRIEND_LIST_UPDATE)
        return
    end

    for _, v in pairs(jsonData) do
        self:addFriendData(v, FriendProxy.FriendType.Friend)
    end

    SLBridge:onLUAEvent(LUA_EVENT_FRIEND_LIST_UPDATE)
end

-- 添加好友结果
function FriendProxy:handle_MSG_SC_FRIEND_ADD_RESPONSE(msg)
    local header = msg:GetHeader()
    if header.recog == 0 then
        -- 申请发送成功
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(300000017))
        global.Facade:sendNotification(global.NoticeTable.Layer_AddFriend_Close)

    elseif header.recog == 1 then
        -- 收到好友添加申请
        if msg:GetDataLength() > 0 then
            local jsonData = ParseRawMsgToJson(msg)
            self:addFriendData(jsonData, FriendProxy.FriendType.Apply)

            local data = {}
            data.id = 5
            data.status = true
            data.callback = function()
                SL:OpenFriendApplyUI()
            end
            global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, data)
            global.Facade:sendNotification(global.NoticeTable.Layer_FriendApply_Refresh)
        end

    elseif header.recog == -1 then
        -- 要申请添加的好友不在线
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(300000016))
    end
end

-- 对方同意加好友
function FriendProxy:handle_MSG_SC_FRIEND_OTHER_ADD_RESPONSE(msg)
    if msg:GetDataLength() <= 0 then
        return
    end

    local jsonData = ParseRawMsgToJson(msg)
    local userName = jsonData.Name
    global.Facade:sendNotification(global.NoticeTable.SystemTips, string.format(GET_STRING(300000018), userName))

    SLBridge:onLUAEvent(LUA_EVENT_ADDFIREND, userName)

    FriendProxy:RequestFriendList()
end

-- 黑名单列表返回
function FriendProxy:handle_MSG_SC_FRIEND_BLACK_List_RESPONSE(msg)
    if msg:GetDataLength() <= 0 then
        return
    end

    local jsonData = ParseRawMsgToJson(msg)
    self._blacklistData = {}

    if not jsonData then
        SLBridge:onLUAEvent(LUA_EVENT_FRIEND_LIST_UPDATE)
        return
    end

    for _, v in pairs(jsonData) do
        self:addFriendData(v, FriendProxy.FriendType.Blacklist)
    end

    SLBridge:onLUAEvent(LUA_EVENT_FRIEND_LIST_UPDATE)
end

-- 加入黑名单结果
function FriendProxy:handle_MSG_SC_FRIEND_ADD_BLACK_List_RESPONSE(msg)
    if msg:GetDataLength() <= 0 then
        return
    end

    local jsonData = ParseRawMsgToJson(msg)
    global.Facade:sendNotification(global.NoticeTable.SystemTips, string.format(GET_STRING(300000022), jsonData.Name))

    self:requestFriendBlockList()
end

function FriendProxy:RegisterMsgHandler()
    FriendProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType
    
    LuaRegisterMsgHandler(msgType.MSG_SC_FRIEND_LIST_RESPONSE, handler(self, self.handle_MSG_SC_FRIEND_LIST_RESPONSE))                      -- 好友列表
    LuaRegisterMsgHandler(msgType.MSG_SC_FRIEND_ADD_RESPONSE, handler(self, self.handle_MSG_SC_FRIEND_ADD_RESPONSE))                        -- 添加好友结果
    LuaRegisterMsgHandler(msgType.MSG_SC_FRIEND_OTHER_ADD_RESPONSE, handler(self, self.handle_MSG_SC_FRIEND_OTHER_ADD_RESPONSE))            -- 对方同意加好友
    LuaRegisterMsgHandler(msgType.MSG_SC_FRIEND_BLACK_List_RESPONSE, handler(self, self.handle_MSG_SC_FRIEND_BLACK_List_RESPONSE))          -- 黑名单列表
    LuaRegisterMsgHandler(msgType.MSG_SC_FRIEND_ADD_BLACK_List_RESPONSE, handler(self, self.handle_MSG_SC_FRIEND_ADD_BLACK_List_RESPONSE))  -- 加入黑名单结果
end

return FriendProxy