local RemoteProxy = requireProxy("remote/RemoteProxy")
local QuestionProxy = class("QuestionProxy", RemoteProxy)
QuestionProxy.NAME = global.ProxyTable.QuestionProxy

function QuestionProxy:ctor()
    QuestionProxy.super.ctor(self)
end

function QuestionProxy:onRegister()
    QuestionProxy.super.onRegister(self)
end

function QuestionProxy:handle_MSG_SC_SENDQUESTION(msg)
    local msgHdr = msg:GetHeader()
    local jsonData = ParseRawMsgToJson(msg)
    jsonData.time = msgHdr.recog
    dump(jsonData, "jsonData___")
    global.Facade:sendNotification(global.NoticeTable.QuestionLayer_Open, jsonData)
end

function QuestionProxy:sendAnswer(data)
    dump(data)
    LuaSendMsg(global.MsgType.MSG_CS_SENDANSWER, data)
end

function QuestionProxy:RegisterMsgHandler()
    local msgType = global.MsgType

    -- 收到消息
    LuaRegisterMsgHandler(msgType.MSG_SC_SENDQUESTION, handler(self, self.handle_MSG_SC_SENDQUESTION))--下发答题
end

return QuestionProxy