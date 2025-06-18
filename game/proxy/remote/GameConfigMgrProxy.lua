local RemoteProxy = requireProxy("remote/RemoteProxy")
local GameConfigMgrProxy = class("GameConfigMgrProxy", RemoteProxy)
GameConfigMgrProxy.NAME = global.ProxyTable.GameConfigMgrProxy

local cjson = require("cjson")

local function getPath()
    local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    if not LoginProxy then
        return "configs_origin"
    end
    local selectServer = LoginProxy:GetSelectedServer()
    if not selectServer then
        return "configs_origin"
    end
    return string.format("configs_%s", selectServer.stab)
end

function GameConfigMgrProxy:ctor()
    GameConfigMgrProxy.super.ctor(self)
    
    self._configs = {}
    self._serverConfigs = {}

    self._updateHandler = {}

    self:readLocalConfig()
end

function GameConfigMgrProxy:getConfigByKey(key)
    local config = self._configs[key]
    if not config then
        return nil
    end
    return config.Value
end

function GameConfigMgrProxy:readLocalConfig()
    local path     = getPath()
    local userData = UserData:new(path)
    local jsonStr  = userData:getStringForKey("configs", "")
    if not jsonStr or string.len(jsonStr) <= 0 then
        return 
    end
    local jsonData = cjson.decode(jsonStr)
    for k, v in pairs(jsonData) do
        self:decodeConfigs(v)
    end
end

function GameConfigMgrProxy:saveLocalConfig()
    local path     = getPath()
    local userData = UserData:new(path)
    local jsonStr  = self:encodeConfigs(self._configs)
    userData:setStringForKey("configs", jsonStr)
end

function GameConfigMgrProxy:encodeConfigs()
    local jsonStr = cjson.encode(self._configs)
    return jsonStr
end

function GameConfigMgrProxy:decodeConfigs(config)
    self._configs[config.LableName] = config
end

function GameConfigMgrProxy:getContentFix()
    local fixxed = {}
    for k, v in pairs(self._configs) do
        fixxed[v.LableName] = v.Ver
    end
    return fixxed
end

function GameConfigMgrProxy:getServerConfingByKey(key)
    local config = self._serverConfigs[key]
    if not config then
        return nil
    end
    return config
end 

function GameConfigMgrProxy:RespGameConfig(msg)
    local header = msg:GetHeader()
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return
    end

    self:decodeConfigs(jsonData)
    self:saveLocalConfig()
    print("++++++++++++++new config, LableName: " .. jsonData.LableName .. "  Ver: " .. jsonData.Ver)
 
    -- 更新
    local handler = self._updateHandler[jsonData.LableName]
    if header.param1 == 1 and handler then
        handler()
    end
end

function GameConfigMgrProxy:handle_MSG_SC_GAME_DATA_SET(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return
    end
    if next(jsonData) then
        for key, value in pairs(jsonData) do
            if tonumber(value) then
                global.ConstantConfig[key] = tonumber(value)
            else
                global.ConstantConfig[key] = value
            end
            if key == "warehouse_max_num" then
                local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
                NPCStorageProxy:LoadConfig()
            end
        end
    end
end

function GameConfigMgrProxy:handle_MSG_MSG_SC_SERVER_CONFIG(msg)
    local jsonData = ParseRawMsgToJson(msg)
    if not jsonData then
        return
    end

    if jsonData.LableName == "cfg_Buff" then 
        jsonData.LableName = "cfg_buff"

        if next(jsonData.Value) then
            local data = {}
            for i, v in pairs(jsonData.Value) do 
                data[v.ID] = v
            end 
            self._serverConfigs[jsonData.LableName] = data
        end
    end 

    if jsonData.LableName == "cfg_Magic" then 
        jsonData.LableName = "cfg_magicinfo"
    end 

end

function GameConfigMgrProxy:RegisterMsgHandler()
    GameConfigMgrProxy.super.RegisterMsgHandler(self)

    local configKey = "cfg_stditem"
    self:RegisterUpdateConfigHandler(configKey, function()
        local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
        ItemConfigProxy:LoadConfig()
    end)

    local configKey = "cfg_suit"
    self:RegisterUpdateConfigHandler(configKey, function()
        local ItemTipsProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemTipsProxy)
        ItemTipsProxy:LoadConfig()
    end)

    local msgType = global.MsgType
    LuaRegisterMsgHandler(msgType.MSG_SC_GAME_CONFIG, handler(self, self.RespGameConfig))
    LuaRegisterMsgHandler(msgType.MSG_SC_GAME_DATA_SET, handler(self, self.handle_MSG_SC_GAME_DATA_SET))
    LuaRegisterMsgHandler(msgType.MSG_SC_SERVER_CONFIG, handler(self, self.handle_MSG_MSG_SC_SERVER_CONFIG))
end

function GameConfigMgrProxy:RegisterUpdateConfigHandler(configKey, callback)
    self._updateHandler[configKey] = callback
end

return GameConfigMgrProxy
