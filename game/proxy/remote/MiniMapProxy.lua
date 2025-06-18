local RemoteProxy = requireProxy("remote/RemoteProxy")
local MiniMapProxy = class("MiniMapProxy", RemoteProxy)
MiniMapProxy.NAME = global.ProxyTable.MiniMapProxy

function MiniMapProxy:ctor()
    MiniMapProxy.super.ctor(self)

    self._monsters = {}
    self._teamData = {}
    self._portalConfig = {}
end

function MiniMapProxy:LoadConfig()
    self._portalConfig = requireGameConfig("cfg_mapdesc")
end

function MiniMapProxy:getMonsters()
    return self._monsters
end

function MiniMapProxy:getPortals()
    local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    local mapID = mapProxy:GetMapID()
    local items = {}
    for _, v in pairs(self._portalConfig) do
        if tostring(v.mapid) == mapID then
            table.insert(items, v)
        end
    end
    return items
end

function MiniMapProxy:getTeams()
    return self._teamData
end

function MiniMapProxy:RespMonsters(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return nil
    end

    self._monsters = jsonData
    SLBridge:onLUAEvent("LUA_EVENT_MINIMAP_MONSTER")
end

function MiniMapProxy:RequestMonsters()
    local mapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    local mapID = mapProxy:GetMapID()
    if not mapID then
        return
    end
    LuaSendMsg(global.MsgType.MSG_CS_MINIMAP_MONSTERS_POINT, 0, 0, 0, 0, mapID, string.len(mapID))
end

function MiniMapProxy:RespTeamMemebersData(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return nil
    end
    self._teamData = jsonData
    SLBridge:onLUAEvent("LUA_EVENT_MINIMAP_TEAM", jsonData)
end

function MiniMapProxy:RequestTeamMemberData()
    LuaSendMsg(global.MsgType.MSG_CS_TEAMMEMEBER_DATA)
end

function MiniMapProxy:RegisterMsgHandler()
    MiniMapProxy.super.RegisterMsgHandler(self)
    local msgType = global.MsgType

    LuaRegisterMsgHandler(msgType.MSG_SC_MINIMAP_MONSTERS_POINT, handler(self, self.RespMonsters))
    LuaRegisterMsgHandler(msgType.MSG_SC_MINIMAP_TEAM_DATA, handler(self, self.RespTeamMemebersData))
end

return MiniMapProxy