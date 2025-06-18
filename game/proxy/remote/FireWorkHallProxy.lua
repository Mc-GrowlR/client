
local RemoteProxy = requireProxy("remote/RemoteProxy")
local FireWorkHallProxy = class("FireWorkHallProxy",RemoteProxy)
FireWorkHallProxy.NAME = global.ProxyTable.FireWorkHallProxy

function FireWorkHallProxy:ctor()

    FireWorkHallProxy.super.ctor( self )
end

--@region 服务器消息  播放特效
--@msg: 服务器数据
--@endregion
function FireWorkHallProxy:handle_MSG_SC_FIRE_WORK_TX_REPONSE( msg )
    local header = msg:GetHeader()
    local len = msg:GetDataLength()
    local data  = msg:GetData()
    local sliceStr = data:ReadString( len )
    local cjson = require( "cjson" )
    local jsonData = cjson.decode(sliceStr)
    local data = {
        effid = header.param1,
        userid = jsonData.UserID
    }
    dump(header)
    dump(jsonData)
    global.Facade:sendNotification(global.NoticeTable.Layer_Fire_Work_Hall_Show,data)
end

function FireWorkHallProxy:RegisterMsgHandler()
    FireWorkHallProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler( msgType.MSG_SC_FIRE_WORK_TX_REPONSE,  handler(self, self.handle_MSG_SC_FIRE_WORK_TX_REPONSE) )
end

function FireWorkHallProxy.Onloaded()
end

function FireWorkHallProxy.OnUnloaded()
end

return FireWorkHallProxy
