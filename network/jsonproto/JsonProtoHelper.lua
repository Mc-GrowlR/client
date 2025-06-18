local JsonProtoHelper = class("JsonProtoHelper")
local Message = require( "network/jsonproto/message")
local slen = string.len

function JsonProtoHelper:ctor()
    self.handlers = {}
end

function JsonProtoHelper:init()
    local networkCtl = LuaNetworkController:Inst()
    local msgType    = global.MsgType
    LuaRegisterMsgHandler( msgType.MSG_SC_JSON_PROTO_HELPER_RESPONSE, handler( self, self.handle_JSON_MESSAGE ) )
end

function JsonProtoHelper:handle_JSON_MESSAGE( msg )
	local len = msg:GetDataLength()
	if len <= 0 then
		print( "handle_JSON_MESSAGE, len <= 0!" )
		return nil
	end

	local ServerTimeProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerTimeProxy)
	if ServerTimeProxy:IsKfState() then
		return nil
	end

	local header   = msg:GetHeader()
	local model	   = header.recog 
	local data     = msg:GetData()
	local jsonStr  = data:ReadString( len )
	local json_msg = Message.new()
	-- print("json proto event", model, jsonStr)
	if not json_msg:load( jsonStr, header ) then
		print( "json message error", "len:" .. tostring( len ) .. jsonStr )
		return nil
	end


	self:OnMessage(model, json_msg )
end

function JsonProtoHelper:RegisterJsonHandler( model, handler )
    self.handlers[model] = handler
end

function JsonProtoHelper:OnMessage(model, json_msg )
	local action  = json_msg:getAction()
	local tmpStr  = "model:" .. tostring( model )
	--跨服状态屏蔽
	local ServerTimeProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerTimeProxy)
	if ServerTimeProxy:IsKfState() then
		return nil
	end

	if not action then
		print( "JsonProtoHelper:OnMessage, Invaild arg, " .. tmpStr )
		return nil
	end


	local handler  = self.handlers[model]
	if not handler or not handler[action] then
		print( "JsonProtoHelper:OnMessage, Invaild handler, " .. tmpStr )
		return nil
	end


	local callback = handler[action]
	callback( handler, json_msg:getData() )
end

function JsonProtoHelper:SendMsg(model, script, action, data, ex1, ex2, ex3 )
	--跨服状态屏蔽
	local ServerTimeProxy = global.Facade:retrieveProxy(global.ProxyTable.ServerTimeProxy)
	if ServerTimeProxy:IsKfState() then
		return nil
	end
	
	if not model or not script then
		print( "JsonProtoHelper:SendMsg, Invaild arg, ", model, script )
		return nil
	end
	local msg     = Message.new(action, data, ex1, ex2, ex3)
	local jsonStr = msg:dump()
	LuaSendMsg( global.MsgType.MSG_CS_JSON_PROTO_HELPER_REQUEST, model, script, 0, 0, jsonStr, slen( jsonStr ) )
end

return JsonProtoHelper
