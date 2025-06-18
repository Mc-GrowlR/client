local RemoteProxy = requireProxy("remote/RemoteProxy")
local ChatProxy = class("ChatProxy", RemoteProxy)
ChatProxy.NAME = global.ProxyTable.Chat

local cjson = require("cjson")
local strformat = string.format

-- 表情表的replace字段字符串值必须以 #开头，不然解析的时候会获取不到
local FACE_CONFIG = {
    [1] = {
        ID = 1,
        replace = "#嘿嘿",
        sfxid = 7000,
    },
    [2] = {
        ID = 2,
        replace = "#惊叹",
        sfxid = 7001,
    },
    [3] = {
        ID = 3,
        replace = "#暴笑",
        sfxid = 7002,
    },
    [4] = {
        ID = 4,
        replace = "#暴走",
        sfxid = 7003,
    },
    [5] = {
        ID = 5,
        replace = "#爱你",
        sfxid = 7004,
    },
    [6] = {
        ID = 6,
        replace = "#不满",
        sfxid = 7005,
    },
    [7] = {
        ID = 7,
        replace = "#冷汗",
        sfxid = 7006,
    },
    [8] = {
        ID = 8,
        replace = "#哈欠",
        sfxid = 7007,
    },
    [9] = {
        ID = 9,
        replace = "#好险",
        sfxid = 7008,
    },
    [10] = {
        ID = 10,
        replace = "#嘘",
        sfxid = 7009,
    },
    [11] = {
        ID = 11,
        replace = "#折磨",
        sfxid = 7010,
    },
    [12] = {
        ID = 12,
        replace = "#生气",
        sfxid = 7011,
    },
    [13] = {
        ID = 13,
        replace = "#喜欢",
        sfxid = 7012,
    },
    [14] = {
        ID = 14,
        replace = "#困",
        sfxid = 7013,
    },
    [15] = {
        ID = 15,
        replace = "#呲牙",
        sfxid = 7014,
    },
    [16] = {
        ID = 16,
        replace = "#懵",
        sfxid = 7015,
    },
    [17] = {
        ID = 17,
        replace = "#怒",
        sfxid = 7016,
    },
    [18] = {
        ID = 18,
        replace = "#互粉",
        sfxid = 7017,
    },
    [19] = {
        ID = 19,
        replace = "#思考",
        sfxid = 7018,
    },
    [20] = {
        ID = 20,
        replace = "#生病",
        sfxid = 7019,
    },
    [21] = {
        ID = 21,
        replace = "#掌嘴",
        sfxid = 7020,
    },
    [22] = {
        ID = 22,
        replace = "#可爱",
        sfxid = 7021,
    },
    [23] = {
        ID = 23,
        replace = "#阴险",
        sfxid = 7022,
    },
    [24] = {
        ID = 24,
        replace = "#恶心",
        sfxid = 7023,
    },
    [25] = {
        ID = 25,
        replace = "#修修",
        sfxid = 7024,
    },
    [26] = {
        ID = 26,
        replace = "#可怜",
        sfxid = 7025,
    },
    [27] = {
        ID = 27,
        replace = "#调皮",
        sfxid = 7026,
    },
    [28] = {
        ID = 28,
        replace = "#哭",
        sfxid = 7027,
    },
    [29] = {
        ID = 29,
        replace = "#睡觉",
        sfxid = 7028,
    },
    [30] = {
        ID = 30,
        replace = "#笑哭",
        sfxid = 7029,
    },
    [31] = {
        ID = 31,
        replace = "#无语",
        sfxid = 7030,
    },
    [32] = {
        ID = 32,
        replace = "#疑问",
        sfxid = 7031,
    },
    [33] = {
        ID = 33,
        replace = "#委屈",
        sfxid = 7032,
    },
    [34] = {
        ID = 34,
        replace = "#大佬",
        sfxid = 7033,
    },
    [35] = {
        ID = 35,
        replace = "#不屑",
        sfxid = 7034,
    },
    [36] = {
        ID = 36,
        replace = "#晕",
        sfxid = 7035,
    },
    [37] = {
        ID = 37,
        replace = "#敲你",
        sfxid = 7036,
    },
    [38] = {
        ID = 38,
        replace = "#大骂",
        sfxid = 7037,
    },
    [39] = {
        ID = 39,
        replace = "#右哼哼",
        sfxid = 7038,
    },
    [40] = {
        ID = 40,
        replace = "#抠鼻",
        sfxid = 7039,
    },
    [41] = {
        ID = 41,
        replace = "#财迷",
        sfxid = 7040,
    },
    [42] = {
        ID = 42,
        replace = "#左哼哼",
        sfxid = 7041,
    },
    [43] = {
        ID = 43,
        replace = "#衰",
        sfxid = 7042,
    },
    [44] = {
        ID = 44,
        replace = "#鄙视",
        sfxid = 7043,
    },
    [45] = {
        ID = 45,
        replace = "#偷笑",
        sfxid = 7044,
    },
    [46] = {
        ID = 46,
        replace = "#闭嘴",
        sfxid = 7045,
    },
    [47] = {
        ID = 47,
        replace = "#馋",
        sfxid = 7046,
    },
    [48] = {
        ID = 48,
        replace = "#甜笑",
        sfxid = 7047,
    },
    [49] = {
        ID = 49,
        replace = "#亲亲",
        sfxid = 7048,
    },
    [50] = {
        ID = 50,
        replace = "#鼓掌",
        sfxid = 7049,
    },
    [51] = {
        ID = 51,
        replace = "#耶",
        sfxid = 7050,
    },
    [52] = {
        ID = 52,
        replace = "#握手",
        sfxid = 7051,
    },
    [53] = {
        ID = 53,
        replace = "#厉害",
        sfxid = 7052,
    },
    [54] = {
        ID = 54,
        replace = "#爱啊",
        sfxid = 7053,
    },
    [55] = {
        ID = 55,
        replace = "#不行",
        sfxid = 7054,
    },
    [56] = {
        ID = 56,
        replace = "#好的",
        sfxid = 7055,
    },
    [57] = {
        ID = 57,
        replace = "#吸引",
        sfxid = 7056,
    },
    [58] = {
        ID = 58,
        replace = "#抱拳",
        sfxid = 7057,
    },
    [59] = {
        ID = 59,
        replace = "#公主",
        sfxid = 7058,
    },
    [60] = {
        ID = 60,
        replace = "#熊猫",
        sfxid = 7059,
    },
    [61] = {
        ID = 61,
        replace = "#汪星人",
        sfxid = 7060,
    },
    [62] = {
        ID = 62,
        replace = "#猪头",
        sfxid = 7061,
    },
    [63] = {
        ID = 63,
        replace = "#羊驼",
        sfxid = 7062,
    },
    [64] = {
        ID = 64,
        replace = "#粉兔",
        sfxid = 7063,
    },
    [65] = {
        ID = 65,
        replace = "#喵星人",
        sfxid = 7064,
    },
    [66] = {
        ID = 66,
        replace = "#凹凸曼",
        sfxid = 7065,
    },
    [67] = {
        ID = 67,
        replace = "#太阳",
        sfxid = 7066,
    },
    [68] = {
        ID = 68,
        replace = "#月亮",
        sfxid = 7067,
    },
    [69] = {
        ID = 69,
        replace = "#肥皂",
        sfxid = 7068,
    },
    [70] = {
        ID = 70,
        replace = "#玫瑰",
        sfxid = 7069,
    },
    [71] = {
        ID = 71,
        replace = "#神马",
        sfxid = 7070,
    },
    [72] = {
        ID = 72,
        replace = "#双喜",
        sfxid = 7071,
    },
    [73] = {
        ID = 73,
        replace = "#蛋糕",
        sfxid = 7072,
    },
    [74] = {
        ID = 74,
        replace = "#爱心",
        sfxid = 7073,
    },
    [75] = {
        ID = 75,
        replace = "#强壮",
        sfxid = 7074,
    },
    [76] = {
        ID = 76,
        replace = "#拍照",
        sfxid = 7075,
    },
    [77] = {
        ID = 77,
        replace = "#闹钟",
        sfxid = 7076,
    },
    [78] = {
        ID = 78,
        replace = "#萌萌哒",
        sfxid = 7077,
    },
    [79] = {
        ID = 79,
        replace = "#蜡烛",
        sfxid = 7078,
    },
    [80] = {
        ID = 80,
        replace = "#心碎",
        sfxid = 7079,
    },
    [81] = {
        ID = 81,
        replace = "#给力",
        sfxid = 7080,
    },
    [82] = {
        ID = 82,
        replace = "#碰杯",
        sfxid = 7081,
    },
    [83] = {
        ID = 83,
        replace = "#赖皮",
        sfxid = 7082,
    },
    [84] = {
        ID = 84,
        replace = "#打我呀",
        sfxid = 7083,
    },
    [85] = {
        ID = 85,
        replace = "#皱眉",
        sfxid = 7084,
    },
    [86] = {
        ID = 86,
        replace = "#郁闷",
        sfxid = 7085,
    },
    [87] = {
        ID = 87,
        replace = "#大笑",
        sfxid = 7086,
    },
    [88] = {
        ID = 88,
        replace = "#再见",
        sfxid = 7087,
    },
    [89] = {
        ID = 89,
        replace = "#难受",
        sfxid = 7088,
    },
    [90] = {
        ID = 90,
        replace = "#哈哈",
        sfxid = 7089,
    },
    [91] = {
        ID = 91,
        replace = "#伤心",
        sfxid = 7090,
    },
}

local DROP_TOTAL_TYPE_ID = 99   -- 掉落总分类ID
local FAKE_DROP_TYPE = 77       -- 假掉落分类ID

ChatProxy.CHANNEL = {
    Common    = 0,  -- 综合
    System    = 1,  -- 系统
    Shout     = 2,  -- 喊话
    Private   = 3,  -- 私聊
    Guild     = 4,  -- 行会
    Team      = 5,  -- 组队
    Near      = 6,  -- 附近
    World     = 7,  -- 传音?世界
    Nation    = 8,  -- 国家
    Union     = 9,  -- 联盟
    Cross     = 10, -- 跨服
    GuildTips = 40, -- 行会通知
    Drop      = 100,-- 掉落
}

ChatProxy.CONFIG = {
    LimitCount      = 50,   -- 聊天限制条数
    LimitCountWin   = 200,  -- 聊天限制条数 PC
    InputLength     = 20,   -- 输入限制长度
    InputCacheCount = 10,   -- 输入历史保存条数
    TargetCount     = 10,   -- 私聊列表
}

ChatProxy.MSG_TYPE = {
    Normal     = 1,     -- 普通消息
    Position   = 2,     -- 坐标
    Equip      = 3,     -- 装备
    SystemTips = 5,     -- 系统通知消息，需使用特定的富文本解析
    FColorText = 6,     -- 系统通知消息，需使用FColor富文本解析
    SRText     = 7,     -- 系统通知消息，需使用SRText富文本解析
    Dice       = 8,     -- 猜拳
}

ChatProxy.CDTIME = {
}

ChatProxy.CHANNEL_PREFIX = {
    { channel = ChatProxy.CHANNEL.Guild,   prefix   = "!~"  },
    { channel = ChatProxy.CHANNEL.Team,    prefix   = "!!"  },
    { channel = ChatProxy.CHANNEL.Nation,  prefix   = "!#"  },
    { channel = ChatProxy.CHANNEL.Cross,   prefix   = "!$"  },
    { channel = ChatProxy.CHANNEL.Shout,   prefix   = "!"   },
    { channel = ChatProxy.CHANNEL.Private, prefix   = "/.+ ", pattern = "^/(.+) (.+)" },
    { channel = ChatProxy.CHANNEL.World,   prefix   = "@传 "},
}

ChatProxy.SAY_MAPPING = {
    ["/who"]    = "/who  ",
    ["/who "]   = "/who  ",
    ["/Total"]  = "/Total  ",
    ["/Total "] = "/Total  ",
}

function ChatProxy:ctor()
    ChatProxy.super.ctor(self)

    self:Init()
end

function ChatProxy:onRegister()
    ChatProxy.super.onRegister(self)
end

function ChatProxy:Init()
    self._isChatting    = false                 -- 聊天中...
    self._inputCache    = {}                    -- 输入历史
    self._inputDraft    = ""                    -- 输入草稿
    self._receiveCache  = {}                    -- 聊天接收缓存
    self._receivePCCache= {}
    self._channel       = self.CHANNEL.Near     -- 当前频道
    self._receiveChannel= self.CHANNEL.Common   -- 当前聊天记录频道
    self._emoji         = {}                    -- 表情包
    self._targets       = {}                    -- 私聊列表
    self._guildPercent  = 50                    -- 行会tips
    self._TargetName    = ""                    -- 私聊名字
    self._local_chat    = {                     -- 本地缓存数据
        autoShout = {                           -- 本地开关
            [tostring(self.CHANNEL.Shout)] = 0            -- 喊话
        },
        data = {
            [tostring(self.CHANNEL.Shout)] = "",          -- 本地保存的喊话内容
            [tostring(self.CHANNEL.Private)] = "",        -- 本地保存的私聊自动回复内容
        },
        autoRely = {
            [tostring(self.CHANNEL.Private)] = 0          -- 自动回复开关
        },
        channelSwitch = {                       -- 聊天接收开关
        },
        dropSwitch = {
            ["total"] = 1,                      -- 掉落总开关
        },
    }                
    -- 聊天记录缓存
    for _, v in pairs(self.CHANNEL) do
        self._receiveCache[v] = {}
        self._receivePCCache[v] = {}
    end

    -- cd
    self._cdTime = {}
    for _, v in pairs(self.CHANNEL) do
        self._cdTime[v] = 0
    end

    local localChatData = self:getLocalChatData()
    -- 是否接收
    if not self._local_chat.channelSwitch then
        self._local_chat.channelSwitch = {}
    end
    self._receiving = {}
    for _, v in pairs(self.CHANNEL) do
        if v == self.CHANNEL.Drop then  --   仅掉落读取本地数据
            local data = localChatData and localChatData.channelSwitch
            self._local_chat.channelSwitch[v .. ""] = data and data[v ..""]
        end
        if self._local_chat.channelSwitch[v..""] == nil then
            self._receiving[v] = true
        else
            self._receiving[v] = self._local_chat.channelSwitch[v..""] == 1
        end
    end

    -- 掉落分类开关读本地数据
    if localChatData and localChatData.dropSwitch then
        self._local_chat.dropSwitch = localChatData.dropSwitch or {}
    end

    -- 自动喊话清理本地缓存数据
    self._local_chat.autoShout[tostring(self.CHANNEL.Shout)] = 0
    self._local_chat.data[tostring(self.CHANNEL.Shout)] = ""
    self:setLocalChatData()

    self._autoRelyList = {}
    self._autoRelyEnable = true

    -- PC聊天记录缓存
    self._PCPrivateCache = {}

    -- 表情包配置
    self._emoji = FACE_CONFIG

    -- 固定聊天
    self._chatExItems = {}
    self._chatExId = 0

    -- 自动喊话间隔时间(s)
    self._autoShoutDelay = 20

    -- 是否关闭假掉落消息
    self._closeFakeDrop = false
end

function ChatProxy:LoadConfig()
    -- 假掉落配置
    self._fakeDropMsgTable = {}
    local fileName = global.isIOS and "cfg_chat_drop.luac" or "cfg_chat_drop.lua"
    if global.isIOS and not global.FileUtilCtl:isFileExist("scripts/game_config/" .. fileName) then --ios的文件gm不是luac
        fileName = "cfg_chat_drop.lua"
    end

    if global.FileUtilCtl:isFileExist("scripts/game_config/" .. fileName) then
        local config = requireGameConfig(fileName)
        if self._fakeDropMsgF then
            for _, v in ipairs(config) do
                local str = self._fakeDropMsgF
                -- 参数服务端转大写传
                if v.playerName then
                    str = string.gsub(str, "%%CREATNAME", v.playerName)
                end
                if v.monsterName then
                    str = string.gsub(str, "%%NAME", v.monsterName)
                end
                if v.mapName then
                    str = string.gsub(str, "%%MAP", v.mapName)
                end
                if v.itemID then
                    str = string.gsub(str, "%%ITEMID", v.itemID)
                end
                if v.itemName then
                    str = string.gsub(str, "%%ITEM", v.itemName)
                end
                if v.g_itemName then
                    str = string.gsub(str, "%%G_ITEM", v.g_itemName)
                end
                if v.mapX then
                    str = string.gsub(str, "%%X", v.mapX)
                end
                if v.mapY then
                    str = string.gsub(str, "%%Y", v.mapY)
                end
                table.insert(self._fakeDropMsgTable, str)
            end
        end
    end
    
end

function ChatProxy:SetFakeDropParam(param)
    self._fakeDropParam = param
    if param and param.Msg then
        -- 掉落格式配置
        self._fakeDropMsgF = param.Msg
        print(self._fakeDropMsgF)
    end
end

function ChatProxy:GetRandFakeDropParam()
    if self._fakeDropParam and next(self._fakeDropParam) and next(self._fakeDropMsgTable) then
        local idx = math.random(1, #self._fakeDropMsgTable)
        self._fakeDropParam.Msg = self._fakeDropMsgTable[idx]
        return self._fakeDropParam
    end

    return nil
end

function ChatProxy:OpenFakeDropTimerID()
    if not self._fakeDropMsgF then
        return
    end

    if not self:GetFakeDropShow() then
        return
    end

    if not self:GetDropTypeSwitch(FAKE_DROP_TYPE) then
        return
    end

    if not self._fakeDropTimerID then
        local function callback()
            local data = self:GetRandFakeDropParam()
            if data and next(data) then
                data.ChannelId = self.CHANNEL.Drop
                data.mt = self.MSG_TYPE.SRText
                data.dropType = FAKE_DROP_TYPE
                global.Facade:sendNotification(global.NoticeTable.AddChatItem, data)
            end
        end
        if self._needRandTime and self._fakeDropTimeLow and self._fakeDropTimeHigh then
            local time = math.random(self._fakeDropTimeLow, self._fakeDropTimeHigh)
            local function event()
                self._fakeDropTimerID = nil
                callback()
                local timeT = math.random(self._fakeDropTimeLow, self._fakeDropTimeHigh)
                self._fakeDropTimerID = PerformWithDelayGlobal(event, timeT / 1000)
            end
            self._fakeDropTimerID = PerformWithDelayGlobal(event, time / 1000)
        else
            self._fakeDropTimerID = Schedule(callback, self._fakeDropTime or 0.2)
        end
    end
end

function ChatProxy:CloseFakeDropTimerID()
    if self._fakeDropTimerID then
        UnSchedule(self._fakeDropTimerID)
        self._fakeDropTimerID = nil
    end
end

function ChatProxy:ChangeFakeDropTimerID(limitLowTimes, limitHighTimes)
    local isNeedOpen = false
    if self._fakeDropTimerID then
        isNeedOpen = true
        self:CloseFakeDropTimerID()
    end
    
    self._fakeDropTime = nil
    self._needRandTime = false

    if limitHighTimes == limitLowTimes then
        self._fakeDropTime = limitLowTimes / 1000
    else
        self._needRandTime = true
        self._fakeDropTimeLow = limitLowTimes
        self._fakeDropTimeHigh = limitHighTimes
    end
    if isNeedOpen then
        self:OpenFakeDropTimerID()
    end
end

function ChatProxy:IsCloseFakeDrop()
    return self._closeFakeDrop
end

--- 添加固定聊天数据
---@param data table  服务端下发的固定聊天数据
function ChatProxy:AddChatExItemsData(data)
    table.insert(self._chatExItems, data)
    self._chatExId = self._chatExId + 1
    data.chatExId = self._chatExId
end

--- 移除固定聊天数据
---@param data table  固定聊天数据
function ChatProxy:RemoveChatExItemsData(data, index)
    if not data then
        return
    end
    local chatExId = data.chatExId
    for i=1, index do
        if chatExId == (self._chatExItems[i] and self._chatExItems[i].chatExId) then
            table.remove(self._chatExItems, i)
            break
        end
    end
end

--- 同步固定聊天倒计时
---@param chatExId integer 自定义的唯一id
---@param value integer 倒计时
function ChatProxy:SyncChatExItemsTime(index, chatExId, value )
    for i = 1, index do
        if chatExId == (self._chatExItems[i] and self._chatExItems[i].chatExId) then
            self._chatExItems[i].Time = value
            break
        end
    end
end

--- 获取固定聊天数据
function ChatProxy:GetChatExItemsData()
    return self._chatExItems
end

function ChatProxy:ClearChatExItemsData()
    self._chatExItems = {}
end

-- 获取自动喊话时间间隔
function ChatProxy:GetAutoShoutDelay()
    return self._autoShoutDelay or 20
end

-- 设置自动喊话时间间隔
function ChatProxy:SetAutoShoutDelay(value)
    self._autoShoutDelay = value or 20
end

function ChatProxy:GetChatParam()
    if not self._listInterval then
        local set = SL:GetMetaValue("GAME_DATA", "ChatShowInterval")
        local idx = global.isWinPlayMode and 2 or 1
        if set and string.len(set) > 0 then
            local setList = string.split(set, "|")
            local param = setList[idx] and string.split(setList[idx], "#")
            if param and next(param) then
                self._listInterval = tonumber(param[1])
                self._richVspace = tonumber(param[2])
            end
        end
    end

    return self._listInterval, self._richVspace
end

function ChatProxy:OnPlayerPropertyInited()
    -- cd, config by gamedata
    local chatCDS = SL:GetMetaValue("GAME_DATA","CHATCDS")
    if chatCDS and chatCDS ~= "" then
        local cdvec = string.split(chatCDS,"|")
        self.CDTIME = {
            [self.CHANNEL.System]   = tonumber(cdvec[self.CHANNEL.System]) or 0,        -- 系统
            [self.CHANNEL.Shout]    = tonumber(cdvec[self.CHANNEL.Shout]),              -- 世界
            [self.CHANNEL.Private]  = tonumber(cdvec[self.CHANNEL.Private]),            -- 私聊
            [self.CHANNEL.Guild]    = tonumber(cdvec[self.CHANNEL.Guild]),              -- 行会
            [self.CHANNEL.Team]     = tonumber(cdvec[self.CHANNEL.Team]),               -- 组队
            [self.CHANNEL.Near]     = tonumber(cdvec[self.CHANNEL.Near]),               -- 附近
            [self.CHANNEL.World]    = tonumber(cdvec[self.CHANNEL.World]),              -- 传音
            [self.CHANNEL.Nation]   = tonumber(cdvec[self.CHANNEL.Nation]),             -- 国家
            [self.CHANNEL.Union]    = tonumber(cdvec[self.CHANNEL.Union]),              -- 联盟
            [self.CHANNEL.Cross]    = tonumber(cdvec[self.CHANNEL.Cross]),              -- 跨服
        }
    end

    self:OpenFakeDropTimerID()
end

function ChatProxy:isCommand(msg)
    return self.SAY_MAPPING[msg] ~= nil
end

function ChatProxy:fixSay(msg)
    if not string.find(msg, "/") then
        return msg
    end

    return self.SAY_MAPPING[msg] or msg
end

-- 修复私聊名字后面有输入空格时  名字获取不正确问题
function ChatProxy:fixPrivateChatMsg(findInfo)
    local name = string.trim(findInfo[3]) or ""
    local fStar, fEnd = string.find(name, " ")
    local content = ""
    if fStar and fEnd then
        content = string.sub(name, fEnd + 1, -1)
        name = string.sub(name, 1, fStar - 1)
    end
    content = content .. (findInfo[4] or "")
    return name, content
end

function ChatProxy:getChannelByMsg(msg)
    local channel = nil
    local content = msg
    for _, v in ipairs(self.CHANNEL_PREFIX) do
        local pattern = v.pattern or "^" .. v.prefix .. "(.+)"
        local find_info = { string.find(msg, pattern) }
        if find_info[1] and find_info[2] then
            channel = v.channel
            local rContent = find_info[3]
            if channel == ChatProxy.CHANNEL.Private then
                local frName, frContent = self:fixPrivateChatMsg(find_info)
                rContent = frContent
            end
            content = rContent
            break
        end
    end

    if not channel then  -- 新增 /名字 直接私聊
        local find_info = { string.find(msg, "^/.+") }
        if find_info[1] and find_info[2] then
            channel = ChatProxy.CHANNEL.Private
            content = " "
        end
    end

    return channel, content
end

function ChatProxy:findTargetByMsg(msg)
    local pattern = nil
    local res = nil
    for _, value in pairs(self.CHANNEL_PREFIX) do
        if value.channel == self.CHANNEL.Private then
            pattern = value.pattern
            break
        end
    end

    if not pattern then
        res = nil
    else
        local find_info = { string.find(msg, pattern) }
        if find_info[1] and find_info[2] then
            local rName, rContent = self:fixPrivateChatMsg(find_info)
            res = rName
        end
        if not res then
            find_info = { string.find(msg, "^/(.+)") }
            if find_info[1] and find_info[2] then
                res = string.gsub(find_info[3], " ", "")
            end
        end
    end

    return res
end

function ChatProxy:getTargetName(data)
    return self._TargetName
end

function ChatProxy:setTargetName(name)
    self._TargetName = name
end

function ChatProxy:CheckAbleToSay(channel)
    if self.CHANNEL.Private == channel then
        -- 私聊
        if (not self:getTarget()) then
            ShowSystemTips(GET_STRING(30001024))
            return false
        end

    elseif self.CHANNEL.System == channel then
        -- 系统
        ShowSystemTips(GET_STRING(30001040))
        return false
    end

    -- cding
    if self:GetCDTime(channel) > 0 then
        ShowSystemTips(string.format(GET_STRING(30001023), self:GetCDTime(channel)))
        return false
    end

    local BuffProxy = global.Facade:retrieveProxy(global.ProxyTable.Buff)
    local ret, buffid = BuffProxy:CheckChatEnable()
    if not ret then
        if buffid then
            local config = BuffProxy:GetConfigByID(buffid) or {}
            if config.bufftitle then
                ShowSystemTips(config.bufftitle)
            end
        end
        return false
    end

    return true
end

function ChatProxy:SetCDTime(channel, cd)
    self._cdTime[channel] = GetServerTime() + cd
end

function ChatProxy:GetCDTime(channel)
    return self._cdTime[channel] - GetServerTime()
end

function ChatProxy:GetCurrCDTime()
    local channel = self:getChannel()
    return self:GetCDTime(channel)
end

function ChatProxy:EnterCD(channel)
    local cdtime = self.CDTIME[channel] or 1
    self:SetCDTime(channel, cdtime)

    global.Facade:sendNotification(global.NoticeTable.Layer_Chat_EnterCD)
end

function ChatProxy:GetEmoji()
    return self._emoji
end

function ChatProxy:setChannel(channel)
    if channel == self.CHANNEL.Drop then
        channel = self.CHANNEL.Private
    end
    self._channel = channel
end

function ChatProxy:getChannel()
    return self._channel
end

function ChatProxy:setReceiveChannel(channel)
    self._receiveChannel = channel
end

function ChatProxy:getReceiveChannel()
    return self._receiveChannel
end

function ChatProxy:setIsChatting(status)
    self._isChatting = status
end

function ChatProxy:isChatting()
    return self._isChatting
end

function ChatProxy:setInputDraft(draft)
    self._inputDraft = draft
end

function ChatProxy:getInputDraft(draft)
    return self._inputDraft
end

function ChatProxy:addInputCache(input)
    table.insert(self._inputCache, input)

    if #self._inputCache > self.CONFIG.InputCacheCount then
        table.remove(self._inputCache, 1)
    end
end

function ChatProxy:getInputCache()
    return self._inputCache
end

function ChatProxy:setReceiving(channel, status)
    self._receiving[channel] = status
    self._local_chat.channelSwitch[channel..""] = status and 1 or 0
    self:setLocalChatData()

    -- system tips
    local receiveTips = {
        [self.CHANNEL.System]  = GET_STRING(30001063),
        [self.CHANNEL.Shout]   = GET_STRING(30001064),
        [self.CHANNEL.Private] = GET_STRING(30001053),
        [self.CHANNEL.Guild]   = GET_STRING(30001055),
        [self.CHANNEL.Team]    = GET_STRING(30001057),
        [self.CHANNEL.Near]    = GET_STRING(30001059),
        [self.CHANNEL.World]   = GET_STRING(30001067),
    }
    local unreceiveTips = {
        [self.CHANNEL.System]  = GET_STRING(30001065),
        [self.CHANNEL.Shout]   = GET_STRING(30001066),
        [self.CHANNEL.Private] = GET_STRING(30001054),
        [self.CHANNEL.Guild]   = GET_STRING(30001056),
        [self.CHANNEL.Team]    = GET_STRING(30001058),
        [self.CHANNEL.Near]    = GET_STRING(30001060),
        [self.CHANNEL.World]   = GET_STRING(30001068),
    }

    local tips = (status and receiveTips[channel] or unreceiveTips[channel])
    if tips then
        ShowSystemTips(tips)
    end
end

function ChatProxy:isReceiving(channel)
    if channel == self.CHANNEL.Common then
        for k, v in pairs(self._receiving) do
            if k ~= self.CHANNEL.Common and v then
                return true
            end
        end
        return false
    end
    return self._receiving[channel]
end

function ChatProxy:addTarget(target)
    for k, v in pairs(self._targets) do
        if v.uid == target.uid then
            table.remove(self._targets, k)
            break
        end
    end
    table.insert(self._targets, 1, target)

    if #self._targets > self.CONFIG.TargetCount then
        table.remove(self._targets, #self._targets)
    end
end

function ChatProxy:getTargets()
    return self._targets
end

function ChatProxy:getTarget()
    return self._targets[1]
end

function ChatProxy:getGuildPercent()
    return self._guildPercent
end

function ChatProxy:setGuildPercent(percent)
    self._guildPercent = percent
end

function ChatProxy:setLocalChatDataData(channel, data)
    channel = tostring(channel)
    if self._local_chat.data[channel] then
        self._local_chat.data[channel] = data
        self:setLocalChatData()
    end
end

function ChatProxy:getLocalChatDataData(channel)
    channel = tostring(channel)
    if self._local_chat.data[channel] then
        return self._local_chat.data[channel]
    end
    return nil
end

-- 获取聊天相关的本地缓存
function ChatProxy:getLocalChatData()
    local localChatData = UserData:new("chat_local_cache")
    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local flag = proxy:GetSelectedRoleID() or "errorName"
    local jsonData = localChatData:getStringForKey("chat" .. flag)

    if not jsonData or jsonData == "" then
        return nil
    end
    local lastJsonData = cjson.decode(jsonData)
    return lastJsonData
end

-- 设置聊天相关的本地缓存
function ChatProxy:setLocalChatData()
    local localChatData = UserData:new("chat_local_cache")
    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local flag = proxy:GetSelectedRoleID() or "errorName"
    local jsonStr = cjson.encode(self._local_chat)
    local clientData = localChatData:setStringForKey("chat" .. flag, jsonStr)
end

function ChatProxy:SetAutoReplySwitch(channel, value)
    channel = channel or self.CHANNEL.Private
    channel = tostring(channel)
    self._local_chat.autoRely[channel] = value
    self:setLocalChatData()
end

function ChatProxy:GetAutoReplySwitch(channel)
    channel = channel or self.CHANNEL.Private
    channel = tostring(channel)
    if self._local_chat.autoRely[channel] then
        return self._local_chat.autoRely[channel] == 1
    end
    return false
end

function ChatProxy:SetAutoShoutSwitch(channel, value)
    channel = channel or self.CHANNEL.Shout
    channel = tostring(channel)
    self._local_chat.autoShout[channel] = value and 1 or 0
    self:setLocalChatData()
end

function ChatProxy:GetAutoShoutSwitch(channel)
    channel = channel or self.CHANNEL.Shout
    channel = tostring(channel)
    if self._local_chat.autoShout[channel] then
        return self._local_chat.autoShout[channel] == 1
    end
    return false
end

function ChatProxy:GetFakeDropShow()
    local fakeDrop = SL:GetMetaValue("GAME_DATA", "ShowFakeDropType")
    if fakeDrop and string.len(fakeDrop) > 0 then
        local param = string.split(fakeDrop, "#")
        if param[2] and tonumber(param[2]) == 1 then
            return true
        end
    end

    return false
end

function ChatProxy:SetDropTypeSwitch(type, value)
    local key = type ~= DROP_TOTAL_TYPE_ID and ("type" .. type) or "total"
    self._local_chat.dropSwitch[key] = value and 1 or 0
    if type ~= DROP_TOTAL_TYPE_ID then
        local enable = false
        local list = self:GetDropTypeShowList()
        if self:GetFakeDropShow() then
            list[FAKE_DROP_TYPE] = true
        end
        for i, show in pairs(list) do
            if show then
                if not self._local_chat.dropSwitch["type" .. i] then
                    self._local_chat.dropSwitch["type" .. i] = 1
                end
                if self._local_chat.dropSwitch["type" .. i] == 1 then
                    enable = true
                    break
                end
            end
        end
        self._local_chat.dropSwitch["total"] = enable and 1 or 0
    end
    self:setLocalChatData()

    local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
    GameSettingProxy:SyncDataToServer()

    if type == FAKE_DROP_TYPE then
        if self._local_chat.dropSwitch[key] == 1 then
            self:OpenFakeDropTimerID()
        else
            self:CloseFakeDropTimerID()
        end
    end
end

function ChatProxy:GetDropTypeSwitch(type)
    local key = type ~= DROP_TOTAL_TYPE_ID and ("type" .. type) or "total"
    if self._local_chat.dropSwitch[key] then
        return self._local_chat.dropSwitch[key] == 1
    end
    return true
end

function ChatProxy:GetDropTypeShowList()
    if not self._showDropType then
        local data = SL:GetMetaValue("GAME_DATA", "DropTypeShow")
        self._showDropType = {}
        if data and string.len(data) > 0 then
            local tList = string.split(data, "|")
            for i, v in ipairs(tList) do
                local param1 = string.split(v, "#")
                if tonumber(param1[2]) then
                    self._showDropType[tonumber(param1[2])] = param1[1] and tonumber(param1[1]) == 1
                end
            end
        end
    end
    return self._showDropType 
end

function ChatProxy:GetDropTypeShield()
    local showList = self:GetDropTypeShowList()
    local list = {}
    local totalSwitch = self:GetDropTypeSwitch(DROP_TOTAL_TYPE_ID) --self:isReceiving(self.CHANNEL.Drop) 
    for i = 1, 10 do
        local isOpen = self:GetDropTypeSwitch(i)
        if not isOpen or not totalSwitch or not showList[i] then
            table.insert(list, i)
        end
    end
    return list
end

---------------------------------- cache begin----------------------------------
function ChatProxy:getCache()
    local channel = self:getReceiveChannel()
    local banUIDs = self._needCheckUID and self._needCheckUID[channel]
    if banUIDs and next(banUIDs) then
        if next(self._receiveCache[channel]) then
            for key = #self._receiveCache[channel], 1, -1 do
                local v = self._receiveCache[channel][key]
                for i = 1, #banUIDs do
                    local uid = banUIDs[i]
                    if uid and v and v.tag == uid then
                        local item = table.remove(self._receiveCache[channel], key)
                        item:autorelease()
                    end
                end
            end
        end
        self._needCheckUID[channel] = {}
    end
    return self._receiveCache[channel]
end

function ChatProxy:getDropCacheByType(type)
    if not type or type == DROP_TOTAL_TYPE_ID then
        return self._receiveCache[self.CHANNEL.Drop]
    end
    return self._receiveDropCache[type] or {}
end

function ChatProxy:storageItem(item, channel, dropType)
    -- 保存至对应频道
    local receiveCache = self._receiveCache[channel]
    table.insert(receiveCache, item)
    item:retain()
    while #receiveCache > self.CONFIG.LimitCount do
        local item = table.remove(receiveCache, 1)
        item:autorelease()
    end

    -- 保存至公共频道
    local receiveCache = self._receiveCache[self.CHANNEL.Common]
    table.insert(receiveCache, item)
    item:retain()
    while #receiveCache > self.CONFIG.LimitCount do
        local item = table.remove(receiveCache, 1)
        item:autorelease()
    end

end

function ChatProxy:releaseCache()
    for _, cache in pairs(self._receiveCache) do
        for _, v in pairs(cache) do
            v:autorelease()
        end
    end
    self._receiveCache = {}

    for _, cache in pairs(self._receivePCCache) do
        for _, v in pairs(cache) do
            v:autorelease()
        end
    end
    self._receivePCCache = {}

    for _, v in pairs(self._PCPrivateCache) do
        v:autorelease()
    end
    self._PCPrivateCache = {}
end

-- 私聊记录
function ChatProxy:storagePCPrivateItem(item, channel)
    -- 保存
    if not global.isWinPlayMode then return end
    local cache = self._PCPrivateCache
    table.insert(cache, item)
    item:retain()
    while #cache > self.CONFIG.LimitCountWin do
        local item = table.remove(cache, 1)
        item:autorelease()
    end
end

function ChatProxy:getPCPrivateCache(...)
    local banUIDs = self._pcPrivateCheckUID
    if banUIDs and next(banUIDs) then
        if next(self._PCPrivateCache) then
            for key = #self._PCPrivateCache, 1, -1 do
                local v = self._PCPrivateCache[key]
                for i = 1, #banUIDs do
                    local uid = banUIDs[i]
                    if uid and v and v.tag == uid then
                        local item = table.remove(self._PCPrivateCache, key)
                        item:autorelease()
                    end
                end
            end
        end
        self._pcPrivateCheckUID = {}
    end
    return self._PCPrivateCache
end

-- PC Mini
function ChatProxy:getPCCache()
    local channel = self:getReceiveChannel()
    local banUIDs = self._needCheckUID and self._needCheckUID[channel]
    if banUIDs and next(banUIDs) then
        if next(self._receivePCCache[channel]) then
            for key = #self._receivePCCache[channel], 1, -1 do
                local v = self._receivePCCache[channel][key]
                for i = 1, #banUIDs do
                    local uid = banUIDs[i]
                    if uid and v and v.tag == uid then
                        local item = table.remove(self._receivePCCache[channel], key)
                        item:autorelease()
                    end
                end
            end
        end
        self._needCheckUID[channel] = {}
    end
    return self._receivePCCache[channel]
end

function ChatProxy:storagePCItem(item, channel, dropType)
    -- 保存至对应频道
    local receiveCache = self._receivePCCache[channel]
    table.insert(receiveCache, item)
    item:retain()
    while #receiveCache > self.CONFIG.LimitCount do
        local item = table.remove(receiveCache, 1)
        item:autorelease()
    end

    -- 保存至公共频道
    local receiveCache = self._receivePCCache[self.CHANNEL.Common]
    table.insert(receiveCache, item)
    item:retain()
    while #receiveCache > self.CONFIG.LimitCountWin do
        local item = table.remove(receiveCache, 1)
        item:autorelease()
    end
end

---------------------------------- cache end----------------------------------

function ChatProxy:handle_MSG_SC_CHAT_SEND_RESULT(msg)
    --[[参数1：
    1：发言时间未到（参数2：剩余秒数）
    2：发言等级不够（参数2：需要多少级）
    3: 没有行会
    4：没有队伍
    5：私聊对方不在线
    6：没有同盟
    7: 私聊限制（双方互为好友才可以发起私聊）
    8: 会员权限不够
    ]]
    local header = msg:GetHeader()
    if header.recog == 1 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, string.format(GET_STRING(30001023), header.param1))
    elseif header.recog == 2 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, string.format(GET_STRING(30001025), header.param1))
    elseif header.recog == 3 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30001022))
    elseif header.recog == 4 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30001021))
    elseif header.recog == 5 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(1016))
    elseif header.recog == 6 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30001032))
    elseif header.recog == 7 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30001037))
    end
end

function ChatProxy:SendMsg(data)
    dump(data, "SendMsg_____")

    data = self:fixLimitChatMsg(data)
    local jsonStr = cjson.encode(data)
    local contentType = 1
    local content = jsonStr
    local autoTips = true
    
    local callbackCB = function(res)
        if res and global.MMO.GAME_STATE_WORLD == GET_GAME_STATE() then
            local sendStr, sendLen = Encode6BitBuf(jsonStr, string.len(jsonStr))
            LuaSendMsg(global.MsgType.MSG_CS_PLAYER_SAY, 0, 0, 0, 0, sendStr, sendLen)
        end
        -- dump(res)
        -- dump(jsonStr)
    end
    if data and data.mt == 1 then
        REQUEST_TEXT_REVIEW(contentType, data and data.Msg or "", autoTips, callbackCB)
    else
        callbackCB(true)  -- 装备 坐标不过滤
    end
end

-- 设置chat的长度显示，  最大5000字
function ChatProxy:fixLimitChatMsg(data)
    local MSG_MAX_LENGTH = 5000
    if data and type(data.Msg) == "string" then
        if data and string.utf8len(data.Msg or "") > MSG_MAX_LENGTH then
            data.Msg = stringUTF8Sub(data.Msg, 1, MSG_MAX_LENGTH)
        end
    end
    return data
end

function ChatProxy:handle_MSG_SC_CHAT_MESSAGE(msg)
    local jsonData = ParseRawMsgToJson(msg)
    -- dump(jsonData,"handle_MSG_SC_CHAT_MESSAGE__")
    if (not jsonData) then
        return
    end

    jsonData.mt = tonumber(jsonData.mt) or self.MSG_TYPE.Normal


    global.Facade:sendNotification(global.NoticeTable.AddChatItem, jsonData)

    -- 附近聊天同步到玩家说话 --头顶的字除了正常字都不显示
    if (jsonData.ChannelId == self.CHANNEL.Near or jsonData.ChannelId == self.CHANNEL.Shout)
        and jsonData.SendId and (tonumber(jsonData.mt) == nil or tonumber(jsonData.mt) == self.MSG_TYPE.Normal) then

        if self:isReceiving(jsonData.ChannelId) then
            global.Facade:sendNotification(global.NoticeTable.ActorSay, jsonData)
        end
    end

    local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
    if global.isWinPlayMode and jsonData.ChannelId == self.CHANNEL.Private and jsonData.SendId and jsonData.SendId ~= mainPlayerID then
        -- 是否自动回复
        local autoContent = self:getLocalChatDataData(self.CHANNEL.Private)
        if self:GetAutoReplySwitch(self.CHANNEL.Private) and autoContent and string.len(autoContent) > 0 then
            table.insert(self._autoRelyList, { SendId = jsonData.SendId, SendName = jsonData.SendName, content = autoContent })
            if self._autoRelyEnable then
                self:CheckAutoReply()
            end
        end
    end

    if jsonData.ChannelId == self.CHANNEL.Private and jsonData.SendId and jsonData.SendId ~= mainPlayerID then
        if global.isWinPlayMode then
            local PrivateChatMediator = global.Facade:retrieveMediator("PrivateChatMediator")
            if PrivateChatMediator and PrivateChatMediator._layer then
                return
            end
        else
            local ChatMediator = global.Facade:retrieveMediator("ChatMediator")
            if ChatMediator and ChatMediator._layer and self._receiveChannel == self.CHANNEL.Private then
                return
            end
        end

        local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
        if FriendProxy:isInBlacklist(jsonData.SendId) then
            return
        end

        if not self:isReceiving(jsonData.ChannelId) then
            return
        end

        local function callback()
            if global.isWinPlayMode then
                global.Facade:sendNotification(global.NoticeTable.Layer_Private_Chat_Open)
            else
                global.Facade:sendNotification(global.NoticeTable.Layer_Chat_Open, 3)
            end
            global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, { id = 14, status = false })
        end

        local data    = {}
        data.id    = 14
        data.status = true
        data.callback = callback
        global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, data)
    end
end

function ChatProxy:CheckAutoReply()
    if self._autoRelyEnable and next(self._autoRelyList) then
        self._autoRelyEnable = false

        local function autoReplyCB()
            local item = table.remove(self._autoRelyList, 1)
            if item and item.content and item.SendId and item.SendName then
                local autoContent = item.content
                local target = { uid = item.SendId, name = item.SendName }
                self:addTarget(target)

                local function toSendMsg(input, risk_param)
                    local sendData = { mt = self.MSG_TYPE.Normal, msg = input, channel = self.CHANNEL.Private, risk = risk_param }
                    global.Facade:sendNotification(global.NoticeTable.SendChatMsg, sendData)

                    self._autoRelyEnable = true
                    self:CheckAutoReply()
                end

                -- 敏感词
                if not string.find(autoContent, "^@.-") then
                    local SensitiveWordProxy = global.Facade:retrieveProxy(global.ProxyTable.SensitiveWordProxy)
                    local function handle_Func(state, str, risk_param)
                        if not str then
                            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(1006))
                            self._autoRelyEnable = true
                            return
                        end

                        toSendMsg(str, risk_param)
                    end
                    local data = {}
                    data.channel_id = self.CHANNEL.Private
                    if target then
                        local targetActor = global.actorManager:GetActor(target.uid)
                        data.to_role_level = targetActor and targetActor:GetLevel()
                        data.to_role_id    = target.uid
                        data.to_role_name = target.name
                    end
                    SensitiveWordProxy:fixSensitiveTalkAddFilter(autoContent, handle_Func, nil, data)
                end
            end
        end

        if self:GetCDTime(self.CHANNEL.Private) > 0 then
            PerformWithDelayGlobal(autoReplyCB, self:GetCDTime(self.CHANNEL.Private))
        else
            autoReplyCB()
        end
    end
end

--自动喊话时间
function ChatProxy:handle_SC_CHAT_AUTO_DELAY(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if (not jsonData) then
        return
    end
    local sayMsgCD = tonumber(jsonData.SayMsgCD)
    if sayMsgCD and sayMsgCD > 0 then
        sayMsgCD = sayMsgCD / 1000
    end
    self:SetAutoShoutDelay(sayMsgCD)
end

-- 通知开关假掉落
function ChatProxy:handle_MSG_SC_STOP_FAKE_DROP(msg)
    local msgHdr = msg:GetHeader()
    if msgHdr.recog == 0 then
        self:CloseFakeDropTimerID()
        self._closeFakeDrop = true
    elseif msgHdr.recog == 1 then
        if self:GetFakeDropShow() then
            self:SetDropTypeSwitch(FAKE_DROP_TYPE, true)
            local isReceiving = self:GetDropTypeSwitch(DROP_TOTAL_TYPE_ID)
            self:setReceiving(self.CHANNEL.Drop, isReceiving)
        end
        self:OpenFakeDropTimerID()
        self._closeFakeDrop = false
    end
    global.Facade:sendNotification(global.NoticeTable.ChatFakeDropChange)
end

-- 掉落消息参数
function ChatProxy:handle_MSG_SC_ITEM_DROP_MSG_NEW(msg)
    local msgHdr = msg:GetHeader()
    local jsonData = ParseRawMsgToJson(msg)
    if (not jsonData) then
        return
    end

    if not self._fakeDropMsgF then
        releasePrint("error: server not send drop_msg_format!")
        return
    end

    local mapX = msgHdr.recog
    local mapY = msgHdr.param1
    local itemID = msgHdr.param2
    local dropType = msgHdr.param3
    if dropType == 0 then
        return
    end

    local param = jsonData.Params
    local playerName = param[1] or ""
    local monsterName = param[2] or ""
    local mapName = param[3] or ""
    local g_itemName = param[4] or ""

    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local itemName = ItemConfigProxy:GetItemNameByIndex(itemID) or ""


    local str = self._fakeDropMsgF
    str = string.gsub(str, "%%CREATNAME", playerName)
    str = string.gsub(str, "%%NAME", monsterName)
    str = string.gsub(str, "%%MAP", mapName)
    str = string.gsub(str, "%%ITEMID", itemID)
    str = string.gsub(str, "%%ITEM", itemName)
    str = string.gsub(str, "%%G_ITEM", g_itemName)
    str = string.gsub(str, "%%X", mapX)
    str = string.gsub(str, "%%Y", mapY)

    local data = {
        BColor      = jsonData.BColor,
        FColor      = jsonData.FColor,
        Msg         = str,
        ChannelId   = self.CHANNEL.Drop,
        mt          = self.MSG_TYPE.SRText,
        dropType    = dropType
    }
    global.Facade:sendNotification(global.NoticeTable.AddChatItem, data)
end

function ChatProxy:handle_MSG_SC_FAKE_DROP_SPEED_UP(msg)
    local msgHdr = msg:GetHeader()
    dump(msgHdr)
    local limitLowTimes = msgHdr.recog
    local limitHighTimes = msgHdr.param1
    self:ChangeFakeDropTimerID(limitLowTimes, limitHighTimes)
end

function ChatProxy:handle_MSG_SC_BAN_PLAYER_CHAT_RECORDS(msg)
    local msgLen = msg:GetDataLength()
    if msgLen <= 0 then
        return 
    end
    local uid = msg:GetData():ReadString(msgLen)
    releasePrint(uid, "_ban_player_id")

    self._needCheckUID = {}
    for _, channel in pairs(self.CHANNEL) do
        if not self._needCheckUID[channel] then
            self._needCheckUID[channel] = {}
        end
        table.insert(self._needCheckUID[channel], uid)
    end
    if global.isWinPlayMode then
        if not self._pcPrivateCheckUID then
            self._pcPrivateCheckUID = {}
        end
        table.insert(self._pcPrivateCheckUID, uid)
    end

    if global.isWinPlayMode then
        global.Facade:sendNotification(global.NoticeTable.Layer_Private_Chat_RemoveItem, uid)
    else
        global.Facade:sendNotification(global.NoticeTable.Layer_Chat_RemoveItem, uid)
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_ChatMini_RemoveItem, uid)    

end

function ChatProxy:RegisterMsgHandler()
end

--改为进入游戏世界之后再注册 有时候没进入世界就收到消息了
function ChatProxy:RegisterMsgHandlerAfterEnterWorld()
    local msgType = global.MsgType
    
    -- 收到消息
    LuaRegisterMsgHandler(msgType.MSG_SC_CHAT_MESSAGE, handler(self, self.handle_MSG_SC_CHAT_MESSAGE))
    -- 发送失败结果
    LuaRegisterMsgHandler(msgType.MSG_SC_CHAT_SEND_RESULT, handler(self, self.handle_MSG_SC_CHAT_SEND_RESULT))
    --自动喊话时间
    LuaRegisterMsgHandler(msgType.MSG_SC_CHAT_AUTO_DELAY, handler(self, self.handle_SC_CHAT_AUTO_DELAY))
    -- 移除假掉落
    LuaRegisterMsgHandler(msgType.MSG_SC_STOP_FAKE_DROP, handler(self, self.handle_MSG_SC_STOP_FAKE_DROP))
    -- 物品掉落消息
    LuaRegisterMsgHandler(msgType.MSG_SC_ITEM_DROP_MSG_NEW, handler(self, self.handle_MSG_SC_ITEM_DROP_MSG_NEW))
    -- 假掉落速度改变
    LuaRegisterMsgHandler(msgType.MSG_SC_FAKE_DROP_SPEED_UP, handler(self, self.handle_MSG_SC_FAKE_DROP_SPEED_UP))
    -- 封禁玩家消息
    LuaRegisterMsgHandler(msgType.MSG_SC_BAN_PLAYER_CHAT_RECORDS, handler(self, self.handle_MSG_SC_BAN_PLAYER_CHAT_RECORDS))
end

return ChatProxy