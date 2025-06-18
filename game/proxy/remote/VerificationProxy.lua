local RemoteProxy = requireProxy("remote/RemoteProxy")
local VerificationProxy = class("VerificationProxy", RemoteProxy)
VerificationProxy.NAME = global.ProxyTable.VerificationProxy
local cjson = require("cjson")

function VerificationProxy:ctor()
    VerificationProxy.super.ctor(self)
end

function VerificationProxy:onRegister()
    VerificationProxy.super.onRegister(self)
end

function VerificationProxy:handle_MSG_SC_IMG_VERIFICATION(msg)
    local msgLen = msg:GetDataLength()
    local msgHdr = msg:GetHeader()
    local time = msgHdr.recog
    local dataString = msg:GetData():ReadString(msgLen)
    local jsonData = {}
    local imgs = string.split(dataString, "&")
    jsonData.bgImg = imgs[1]
    jsonData.Img = imgs[2]
    jsonData.time = time
    global.Facade:sendNotification(global.NoticeTable.VerificationLayer_Open, jsonData)
end

function VerificationProxy:handle_MSG_SC_IMG_VERIFICATION_RESULT(msg)
    local msgHdr = msg:GetHeader()
    dump(msgHdr, "msgHdr___")
    if msgHdr.recog == 1 then --成功了
        HideLoadingBar()
        global.Facade:sendNotification(global.NoticeTable.VerificationLayer_Close)
    elseif msgHdr.recog >= 3 then --次数到了  gg
        HideLoadingBar()
        global.Facade:sendNotification(global.NoticeTable.VerificationLayer_Close)
        -- 重连禁用
        global.Facade:sendNotification(global.NoticeTable.ReconnectForbidden)

        local function callback(bType, custom)
            global.L_NativeBridgeManager:GN_accountLogout()
            global.Facade:sendNotification(global.NoticeTable.RestartGame)
        end
        local data = {}
        data.str    = GET_STRING(30009061)
        data.btnDesc = { GET_STRING(30009046) }
        data.callback = callback
        data.hideCloseBtn = true
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
    end
end

function VerificationProxy:sendPos(x, y)
    dump({ x, y }, "sendPos")
    LuaSendMsg(global.MsgType.MSG_CS_IMG_VERIFICATION_POS, x, y)
end

function VerificationProxy:RegisterMsgHandler()
    local msgType = global.MsgType
    LuaRegisterMsgHandler(msgType.MSG_SC_IMG_VERIFICATION, handler(self, self.handle_MSG_SC_IMG_VERIFICATION))--下发的验证图片
    LuaRegisterMsgHandler(msgType.MSG_SC_IMG_VERIFICATION_RESULT, handler(self, self.handle_MSG_SC_IMG_VERIFICATION_RESULT))--验证结果
end

return VerificationProxy