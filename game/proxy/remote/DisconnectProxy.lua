local RemoteProxy     = requireProxy( "remote/RemoteProxy" )
local DisconnectProxy = class( "DisconnectProxy", RemoteProxy )
DisconnectProxy.NAME  = global.ProxyTable.Disconnect

function DisconnectProxy:ctor()
    DisconnectProxy.super.ctor( self )

    self._disconnect = false
end

function DisconnectProxy:IsDisconnect()
    return self._disconnect
end

function DisconnectProxy:SetDisconnect( value )
    self._disconnect = value
end

function DisconnectProxy:handle_MSG_SC_NETWORK_DISCONNECTED( msg )
    self:SetDisconnect( true )
    
    global.Facade:sendNotification( global.NoticeTable.Disconnect )

    SLBridge:onLUAEvent(LUA_EVENT_DISCONNECT)
end

function DisconnectProxy:handle_MSG_SC_NETWORK_ILLEGAL_MSG( msg )
    self:SetDisconnect( true )
    local header = msg:GetHeader()

    global.Facade:sendNotification( global.NoticeTable.IllegalMsg, header.param1 )
end

function DisconnectProxy:handle_MSG_SC_NETWORK_OTHERPLACE_LOGIN( msg )
    self:SetDisconnect( true )

    global.Facade:sendNotification( global.NoticeTable.OtherClientLogin )
end

function DisconnectProxy:RegisterMsgHandler()
    DisconnectProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler( msgType.MSG_SC_NETWORK_DISCONNECTED,     handler( self, self.handle_MSG_SC_NETWORK_DISCONNECTED ) )      -- 断线
    LuaRegisterMsgHandler( msgType.MSG_SC_NETWORK_ILLEGAL_MSG,      handler( self, self.handle_MSG_SC_NETWORK_ILLEGAL_MSG ) )       -- 非法消息
    LuaRegisterMsgHandler( msgType.MSG_SC_NETWORK_OTHERPLACE_LOGIN, handler( self, self.handle_MSG_SC_NETWORK_OTHERPLACE_LOGIN ) )  -- other client login
end

return DisconnectProxy
