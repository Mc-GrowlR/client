local RemoteProxy = requireProxy("remote/RemoteProxy")
local MissionProxy = class("MissionProxy", RemoteProxy)
MissionProxy.NAME = global.ProxyTable.MissionProxy

function MissionProxy:ctor()
    MissionProxy.super.ctor(self)

    self._data = {}
    self._data.items = {}
end

function MissionProxy:onRegister()
    MissionProxy.super.onRegister(self)
end

-- 任务置顶
function MissionProxy:RespMissionTop(msg)
    local msgHdr = msg:GetHeader()
    local recog = msgHdr.recog
    global.Facade:sendNotification(global.NoticeTable.Layer_Assist_MissionTop, recog)
    SLBridge:onLUAEvent(LUA_EVENT_ASSIST_MISSION_TOP, recog)
end

function MissionProxy:CalcMissionOrderByID(id)
    local item = self:GetMissionByID(id)
    return item.order or 0
end

function MissionProxy:GetMissionByID(id)
    return self._data.items[id]
end

function MissionProxy:RequestSubmitMission(missionID)
    local item = self:GetMissionByID(missionID)
    self:SubmitMission(item)
end

function MissionProxy:SubmitMission(item)
    SendTableToServer(global.MsgType.MSG_SC_MISSION_SUBMIT, item)
end

function MissionProxy:RespMission(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return nil
    end
    self:UpdateMission(jsonData)
end

function MissionProxy:UpdateMission(item)
    -- item = {
    --     type = xx,
    --     head = {
    --         content = xx,
    --         color = xx,
    --     },
    --     body = {
    --         content = xx,
    --         color = xx,
    --     }
    --     flag = xx, 0 未接取 1进行中 2完成未提交
    -- }
    -- 有head表示增加或者修改
    -- 没有head表示删除
    -- 单条处理，有head就是新增或者修改，否则为删除
    if item.head then
        self:ChangeMissionItem(item)
    else
        -- 数据上报移除需要任务名
        if self._data.items[item.type] then
            local content = self._data.items[item.type].head and self._data.items[item.type].head.content
            item.oldHead = {
                content = content
            }
        end
        self:RemoveMissionItem(item)
    end

    local NativeBridgeProxy = global.Facade:retrieveProxy( global.ProxyTable.NativeBridgeProxy )
    NativeBridgeProxy:GN_Mission( item )

end

function MissionProxy:ChangeMissionItem(item)
    -- 任务是否已存在
    if self._data.items[item.type] then
        self._data.items[item.type] = item
        global.Facade:sendNotification(global.NoticeTable.Layer_Assist_MissionChange, item)
        SLBridge:onLUAEvent(LUA_EVENT_ASSIST_MISSION_CHANGE, item)
    else
        self._data.items[item.type] = item
        global.Facade:sendNotification(global.NoticeTable.Layer_Assist_MissionAdd, item)
        SLBridge:onLUAEvent(LUA_EVENT_ASSIST_MISSION_ADD, item)
    end
end

function MissionProxy:RemoveMissionItem(item)
    if not self._data.items[item.type] then
        return false
    end
    self._data.items[item.type] = nil
    global.Facade:sendNotification(global.NoticeTable.Layer_Assist_MissionRemove, item)
    SLBridge:onLUAEvent(LUA_EVENT_ASSIST_MISSION_REMOVE, item)
end

function MissionProxy:RegisterMsgHandler()
    MissionProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler(msgType.MSG_SC_MISSION_CHANGE, handler(self, self.RespMission))
    LuaRegisterMsgHandler(msgType.MSG_SC_MISSION_TOP, handler(self, self.RespMissionTop))
end

return MissionProxy