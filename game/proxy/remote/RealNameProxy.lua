local RemoteProxy = requireProxy("remote/RemoteProxy")
local RealNameProxy = class("RealNameProxy", RemoteProxy)
RealNameProxy.NAME = global.ProxyTable.RealNameProxy

function RealNameProxy:ctor()
    RealNameProxy.super.ctor(self)
end

function RealNameProxy:onRegister()
    RealNameProxy.super.onRegister(self)
end

function RealNameProxy:handle_MSG_SM_BINDHUMMSG(msg)
    global.L_NativeBridgeManager:GN_requestRealName()
end

function RealNameProxy:RequestRealNameRes(cr)
    LuaSendMsg(global.MsgType.MSG_CM_BINDHUMMSG, 1, cr, 0, 0)
end

function RealNameProxy:RegisterMsgHandler()
    RealNameProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler(msgType.MSG_SM_BINDHUMMSG, handler(self, self.handle_MSG_SM_BINDHUMMSG))--弹实名
end

return RealNameProxy