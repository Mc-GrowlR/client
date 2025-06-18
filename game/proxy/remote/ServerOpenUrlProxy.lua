local RemoteProxy = requireProxy("remote/RemoteProxy")
local ServerOpenUrlProxy = class("ServerOpenUrlProxy", RemoteProxy)
ServerOpenUrlProxy.NAME = global.ProxyTable.ServerOpenUrlProxy

local cjson = require("cjson")

function ServerOpenUrlProxy:ctor()
    ServerOpenUrlProxy.super.ctor(self)
end

local function urlencodechar(char)
    return "%" .. string.format("%02X", string.byte(char))
end

local function urlencodeT(input)
    -- convert line endings
    input = string.gsub(tostring(input), "\n", "\r\n")

    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%-%_%~ :/=?&#])", urlencodechar)
    -- convert spaces to "+" symbols
    return string.gsub(input, " ", "+")
end

function ServerOpenUrlProxy:handle_MSG_SC_OPEN_URL(msg)
    local header = msg:GetHeader()
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return -1
    end

    dump(jsonData)
    local url = jsonData.url
    if not url or string.len(url) < 1 then
        return
    end
    if global.isIOS then
        url = urlencodeT(url)
    end
    cc.Application:getInstance():openURL(url)
end

function ServerOpenUrlProxy:onRegister()
    ServerOpenUrlProxy.super.onRegister(self)

    LuaRegisterMsgHandler(global.MsgType.MSG_SC_OPEN_URL, handler(self, self.handle_MSG_SC_OPEN_URL))
end

return ServerOpenUrlProxy