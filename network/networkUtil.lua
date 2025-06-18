local cjson = require("cjson")
local slen = string.len

_LOG_RECV_NET_MSG = {}
_LOG_RECV_ABLE    = false
_LOG_SEND_NET_MSG = {}
_LOG_SEND_ABLE    = false

function LuaRegisterMsgHandler(msgID, netCB)
    global.networkCtl:RegisterLuaHandler(msgID, function(msg)
        netCB(msg)

        -- 统计收到服务端的消息号
        if _DEBUG and _LOG_RECV_ABLE then
            _LOG_RECV_NET_MSG[msgID] = _LOG_RECV_NET_MSG[msgID] or {}
            _LOG_RECV_NET_MSG[msgID].hits = (_LOG_RECV_NET_MSG[msgID].hits or 0) + 1
            _LOG_RECV_NET_MSG[msgID].msgId = msgID
            _LOG_RECV_NET_MSG[msgID].dataLen = msg:GetDataLength()
        end
    end)
end

function LuaSendMsg(...)
    global.networkCtl:SendMsg(...)

    -- 统计收到服务端的消息号
    if _DEBUG and _LOG_SEND_ABLE then
        local data = {...}
        local msgID = data[1]
        local dataLen = data[7]
        
        _LOG_SEND_NET_MSG[msgID] = _LOG_SEND_NET_MSG[msgID] or {}
        _LOG_SEND_NET_MSG[msgID].hits = (_LOG_SEND_NET_MSG[msgID].hits or 0) + 1
        _LOG_SEND_NET_MSG[msgID].msgId = msgID
        _LOG_SEND_NET_MSG[msgID].dataLen = dataLen or 0
    end
end

function SendTableToServer(msgID, tableData)
    local jsonStr = cjson.encode(tableData)
    if not jsonStr then
        print(msgID, "json data encode error")
        return nil
    end

    LuaSendMsg(msgID, 0, 0, 0, 0, jsonStr, slen(jsonStr))
end

function SendUserIDToServer(msgID, userID)
    if nil == userID or type(userID) ~= "string" then
        print(msgID, "userID error")
        return nil
    end

    local sendData = {
        UserID = userID
    }

    SendTableToServer(msgID, sendData)
end

function CheckMsgDataLen(msg)
    local dataLen = msg:GetDataLength()
    local msgHdr = msg:GetHeader()
    if dataLen <= 0 then
        print(msgHdr.msgId, ": data is empty or overflowed!", dataLen)
        return false
    end

    return true
end

function ParseRawMsgToJson(msg)
    if not CheckMsgDataLen(msg) then
        return nil
    end

    local msgLen = msg:GetDataLength()
    local msgHdr = msg:GetHeader()
    local dataString = msg:GetData():ReadString(msgLen)
    local jsonData = nil

    local function decodeJson()
        jsonData = cjson.decode(dataString)
    end

    if pcall(decodeJson) then
    else
        print("ParseRawMsgToJson ERROR", msgHdr.msgId, dataString)
    end

    if not jsonData then
        print(msgHdr.msgId, ": data decode to json error!")
        return nil
    end

    return jsonData
end
