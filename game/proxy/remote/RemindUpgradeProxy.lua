local RemoteProxy = requireProxy("remote/RemoteProxy")
local RemindUpgradeProxy = class("RemindUpgradeProxy", RemoteProxy)
RemindUpgradeProxy.NAME = global.ProxyTable.RemindUpgradeProxy

local cjson = require("cjson")

function RemindUpgradeProxy:ctor()
    RemindUpgradeProxy.super.ctor(self)
    self.m_btns = {}--用键值对吧 防id重复
end

function RemindUpgradeProxy:handle_MSG_SC_BESTRONG_TIPS(msg)
    local msgLen = msg:GetDataLength()
    local msgHdr = msg:GetHeader()
    local str = ""
    if msgLen ~= 0 then
        str = msg:GetData():ReadString(msgLen)
    end

    if msgHdr.recog == 0 then
        -- id name link
        local strs = string.split(str,",")
        local id = tonumber(strs[1])
        local name = strs[2]
        for i = 1,2 do
            if #strs>0 then 
                table.remove(strs,1)
            end
        end
        local link = table.concat( strs, ",")
        local data = {id = id,name = name,link = link} 
        self:refData(id,true,data)
    else
        local id = msgHdr.param1 or 0
        self:refData(id,false)
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_BeStrong_refButton)
end

--data {id = id,name = name,link = link} 
function RemindUpgradeProxy:refData(id,status,data)
    if status then 
        self.m_btns[id] = data
    else
        if self.m_btns[id]  then
            self.m_btns[id] = nil
        end
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_BeStrong_refButton)
end

function RemindUpgradeProxy:getButtonData()
    return self.m_btns
end

function RemindUpgradeProxy:RegisterMsgHandler()
    RemindUpgradeProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler(global.MsgType.MSG_SC_BESTRONG_TIPS, handler(self, self.handle_MSG_SC_BESTRONG_TIPS) )
end

return RemindUpgradeProxy
