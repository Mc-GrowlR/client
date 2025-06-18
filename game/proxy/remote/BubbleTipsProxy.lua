local RemoteProxy = requireProxy("remote/RemoteProxy")
local BubbleTipsProxy = class("BubbleTipsProxy", RemoteProxy)
BubbleTipsProxy.NAME = global.ProxyTable.BubbleTipsProxy

local config = {
    [1] = {
        idx = 1,
        order = 1,
        img = 1900012560
    },
    [2] = {
        idx = 2,
        order = 2,
        img = 1900012564
    },
    [3] = {
        idx = 3,
        order = 3,
        img = 1900012601
    },
    [4] = {
        idx = 4,
        order = 4,
        img = 1900012602
    },
    [5] = {
        idx = 5,
        order = 5,
        img = 1900012603
    },
    [6] = {
        idx = 6,
        order = 6,
        img = 1900012604
    },
    [7] = {
        idx = 7,
        order = 7,
        img = 1900012605
    },
    [8] = {
        idx = 8,
        order = 8,
        img = 1900012562
    },
    [9] = {
        idx = 9,
        order = 9,
        img = 1900012562
    },
    [10] = {
        idx = 10,
        order = 10,
        img = 1900012562
    },
    [11] = {
        idx = 11,
        order = 11,
        img = 1900012562
    },
    [12] = {
        idx = 12,
        order = 12,
        img = 1900012605
    },
    [13] = {
        idx = 13,
        order = 13,
        img = 1900012562
    },
    [14] = {
        idx = 14,
        order = 14,
        img = 1900012607
    }
}

function BubbleTipsProxy:ctor()
    BubbleTipsProxy.super.ctor(self)

    self._config = {}
    self._configHash = {}

    self:LoadConfig()
end

function BubbleTipsProxy:onRegister()
    BubbleTipsProxy.super.onRegister(self)
end

function BubbleTipsProxy:LoadConfig()
    self._configHash = config

    -- 排序
    local temp = {}
    for _, v in pairs(self._configHash) do
        temp[#temp + 1] = v
    end
    self._config = temp
    local function sortCallback(a, b)
        return a.order > b.order
    end
    table.sort(self._config, sortCallback)
end

function BubbleTipsProxy:GetConfig()
    return self._config
end

function BubbleTipsProxy:GetConfigByID(id)
    return self._configHash[id]
end

function BubbleTipsProxy:GetOrderByID(id)
    return self._configHash[id] and self._configHash[id].order or 1
end

function BubbleTipsProxy:handle_MSG_SC_BUBBLE_TIPS_CUSTOM(msg)
    local msgLen = msg:GetDataLength()
    local msgHdr = msg:GetHeader()
    local str = ""
    if msgLen ~= 0 then
        str = msg:GetData():ReadString(msgLen)
    end

    local t = {}
    if msgHdr.recog == 0 then
        local strs = string.split(str, ",")
        local path = strs[1]
        local link = strs[2]
        local id = msgHdr.param1 or 0
        local func = function()
            local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
            SUIComponentProxy:SubmitAct({Act = link})
        end
        t = {id = "custom_" .. id, path = path, callback = func, status = true}
    else
        local id = msgHdr.param1 or 0
        t = {id = "custom_" .. id, status = false}
    end
    global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, t)
end

function BubbleTipsProxy:RegisterMsgHandler()
    BubbleTipsProxy.super.RegisterMsgHandler(self)
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_BUBBLE_TIPS_CUSTOM, handler(self, self.handle_MSG_SC_BUBBLE_TIPS_CUSTOM))
end

return BubbleTipsProxy
