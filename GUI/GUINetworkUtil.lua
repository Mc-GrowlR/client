local GUINetworkUtil = class("GUINetworkUtil")

local cjson     	 = require("cjson")

function GUINetworkUtil:ctor()
    self.handlers = {}
    self.luahandlers = {}

	local networkCtl = LuaNetworkController:Inst()
    local msgType = global.MsgType
    LuaRegisterMsgHandler( msgType.MSG_SC_SSR_NETWORK_RESPONSE, handler( self, self.handle_MSG_SC_SSR_NETWORK_RESPONSE ) )
    LuaRegisterMsgHandler( msgType.MSG_SC_SSR_LUA_NETWORK_RESPONSE, handler( self, self.MSG_SC_SSR_LUA_NETWORK_RESPONSE ) )

	local CodeDOMUIProxy = global.Facade:retrieveProxy(global.ProxyTable.CodeDOMUIProxy)
	CodeDOMUIProxy:InitTXTUI(self)
end

function GUINetworkUtil:handle_MSG_SC_SSR_NETWORK_RESPONSE( msg )
    local msgHdr  = msg:GetHeader()
    local msgLen  = msg:GetDataLength()
    local msgData = (msgLen > 0 and msg:GetData():ReadString(msgLen) or nil)
	self:OnMessage(msgHdr.recog, msgData)
end

function GUINetworkUtil:RegisterNetworkHandler( msgID, netCB )
    self.handlers[msgID] = netCB
end

function GUINetworkUtil:UnRegisterNetworkHandler(msgID)
    self.handlers[msgID] = nil
end

function GUINetworkUtil:OnMessage( msgID, msgData )
	SL:Print("[GUI LOG] OnMessage", msgID, msgData)

	local handler = self.handlers[msgID]
	if not handler then
		SL:Print( "[GUI LOG] GUINetworkUtil:OnMessage, Invaild handler, " .. msgID )
		return nil
	end

	handler( msgID, msgData )
end

function GUINetworkUtil:SendMsg( msgID, sendData, p1, p2, p3 )
	SL:Print("[GUI LOG] SendMsg", msgID, sendData, p1, p2, p3)

	if not msgID then
		SL:Print( "[GUI LOG] GUINetworkUtil:SendMsg, Invaild args, ", msgID )
		return nil
	end
	p1 = p1 or 0
	p2 = p2 or 0
	p3 = p3 or 0
	sendData = sendData or ""

	-- 类型容错
	local sendDataType = type(sendData)
	if sendDataType == "table" then
		sendData = cjson.encode(sendData)
	elseif sendDataType ~= "string" then
		sendData = tostring(sendData)
	end

	LuaSendMsg( global.MsgType.MSG_CS_SSR_NETWORK_REQUEST, msgID, p1, p2, p3, sendData, string.len( sendData ) )

	if SL._DEBUG then
        if string.len(sendData) > 4096 then
            SL:Print("[GUI ERROR], GUINetwork send string too long!!!", string.len(sendData), sendData)
            PrintTraceback()
        end
    end
end


---------------------------------------------------------------------
--- lua msg
function GUINetworkUtil:MSG_SC_SSR_LUA_NETWORK_RESPONSE( msg )
    local msgHdr  = msg:GetHeader()
    local msgLen  = msg:GetDataLength()
    local msgData = (msgLen > 0 and msg:GetData():ReadString(msgLen) or nil)
	self:OnLuaMessage(msgHdr.recog, msgHdr.param1, msgHdr.param2, msgHdr.param3, msgData)
end

function GUINetworkUtil:RegisterLuaNetworkHandler( msgID, netCB )
    self.luahandlers[msgID] = netCB
end

function GUINetworkUtil:UnRegisterLuaNetworkHandler(msgID)
    self.luahandlers[msgID] = nil
end

function GUINetworkUtil:OnLuaMessage( msgID, n1, n2, n3, msgData )
	SL:Print("[GUI LOG] OnLuaMessage", msgID, n1, n2, n3, msgData)

	local handler = self.luahandlers[msgID]
	if not handler then
		SL:Print( "[GUI LOG] GUINetworkUtil:OnLuaMessage, Invaild handler, " .. msgID )
		return nil
	end

	handler( msgID, n1, n2, n3, msgData )
end

function GUINetworkUtil:SendLuaMsg( msgID, n1, n2, n3, sendData )
	SL:Print("[GUI LOG] SendLuaMsg", msgID, n1, n2, n3, sendData)

	if not msgID  then
		SL:Print( "[GUI LOG] GUINetworkUtil:SendLuaMsg, Invaild args, ", msgID )
		return nil
	end
	n1 = n1 or 0
	n2 = n2 or 0
	n3 = n3 or 0
	sendData = sendData or ""
	LuaSendMsg( global.MsgType.MSG_CS_SSR_LUA_NETWORK_REQUEST, msgID, n1, n2, n3, sendData, string.len( sendData ) )

	if SL._DEBUG then
        if string.len(sendData) > 4096 then
            SL:Print("[GUI ERROR], GUINetwork send string too long!!!", string.len(sendData), sendData)
            PrintTraceback()
        end
    end
end

return GUINetworkUtil