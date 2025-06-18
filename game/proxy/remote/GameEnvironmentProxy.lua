local RemoteProxy = requireProxy("remote/RemoteProxy")
local GameEnvironmentProxy = class("GameEnvironmentProxy", RemoteProxy)
GameEnvironmentProxy.NAME = global.ProxyTable.GameEnvironment

function GameEnvironmentProxy:ctor()
    GameEnvironmentProxy.super.ctor(self)
    
    -- 
    self._totalMemoryType = global.MMO.MEMORY_TYPE_X
    

    self:Init()
end

function GameEnvironmentProxy:Init()
    -- 内存警告
    if global.Platform ~= cc.PLATFORM_OS_WINDOWS then
        local totalMemSize = self:GetTotalMemSize()
        if totalMemSize <= 1.2 then
            self._totalMemoryType = global.MMO.MEMORY_TYPE_L
        elseif totalMemSize <= 2.2 then
            self._totalMemoryType = global.MMO.MEMORY_TYPE_M
        elseif totalMemSize <= 4.2 then
            self._totalMemoryType = global.MMO.MEMORY_TYPE_H
        else
            self._totalMemoryType = global.MMO.MEMORY_TYPE_X
        end
    end
end

function GameEnvironmentProxy:getBoxuid()
    local boxuid = nil
    if boxuid == nil or boxuid == "" then
        boxuid = global.L_GameEnvManager:GetEnvDataByKey("uid")
    end
    return boxuid
end

function GameEnvironmentProxy:getBoxtoken()
    local boxtoken = nil
    if boxtoken == nil or boxtoken == "" then
        boxtoken = global.L_GameEnvManager:GetEnvDataByKey("new_boxtoken")
    end
    if boxtoken == nil or boxtoken == "" then
        boxtoken = global.L_GameEnvManager:GetEnvDataByKey("token")
    end
    return boxtoken
end

function GameEnvironmentProxy:IsNeedExitGame()
    if not global.isWindows then
        return false
    end

    -- PC联运
    local PCPlatform        = global.L_GameEnvManager:GetEnvDataByKey("PCPlatform")
    local user_id           = global.L_GameEnvManager:GetEnvDataByKey("user_id")
    local token             = global.L_GameEnvManager:GetEnvDataByKey("token")
    if tonumber(PCPlatform) == 1 and user_id and token then
        return true
    end

    -- -- 盒子
    -- local envProxy          = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    -- local bokuid            = envProxy:getBoxuid()
    -- local boxtoken          = envProxy:getBoxtoken()
    -- if bokuid and boxtoken then
    --     return true
    -- end

    return false
end

function GameEnvironmentProxy:IsReviewServer()
    return global.L_GameEnvManager:IsReview()
end

function GameEnvironmentProxy:GetCustomDataByKey(key)
    local currentModule = global.L_ModuleManager:GetCurrentModule()
    local moduleGameEnv = currentModule:GetGameEnv()
    local customData    = moduleGameEnv:GetCustomData()

    if not customData then
        return nil
    end
    return customData[key]
end

function GameEnvironmentProxy:GetBatteryLevel()
    return global.L_GameEnvManager:GetBattery()
end

function GameEnvironmentProxy:SetBatteryLevel(batterLevel)
    global.L_GameEnvManager:SetBattery(batterLevel)
    global.Facade:sendNotification(global.NoticeTable.BattreyChange, self:GetBatteryLevel())
    ssr.ssrBridge:OnBatteryValueChange(self:GetBatteryLevel())
    SLBridge:onLUAEvent(LUA_EVENT_BATTERYCHANGE, self:GetBatteryLevel())
end

function GameEnvironmentProxy:GetNetType()
    return global.L_GameEnvManager:GetNetType()
end

function GameEnvironmentProxy:SetNetType(t)
    -- -1:未识别 0:wifi 1:2g 2:3g 3:4g
    global.L_GameEnvManager:SetNetType(t)
    global.Facade:sendNotification(global.NoticeTable.NetStateChange, self:GetNetType())
    ssr.ssrBridge:OnNetStateChange(self:GetNetType())
    SLBridge:onLUAEvent(LUA_EVENT_NETCHANGE, self:GetNetType())
end


-- 设备物理地址
function GameEnvironmentProxy:GetMacAddress()
    return global.L_GameEnvManager:GetMacAddress()
end

-- apk info
function GameEnvironmentProxy:GetAPKVersionName()
    return global.L_GameEnvManager:GetAPKVersionName()
end

function GameEnvironmentProxy:GetAPKVersionCode()
    return global.L_GameEnvManager:GetAPKVersionCode()
end

function GameEnvironmentProxy:GetAPKPackageName()
    return global.L_GameEnvManager:GetAPKPackageName()
end

function GameEnvironmentProxy:GetChannelID()
    return global.L_GameEnvManager:GetChannelID()
end

function GameEnvironmentProxy:GetTotalMemSize()
    return global.L_GameEnvManager:GetTotalMemSize()
end

function GameEnvironmentProxy:GetTotalMemSize()
    return global.L_GameEnvManager:GetTotalMemSize()
end

function GameEnvironmentProxy:GetTotalMemoryType()
    return self._totalMemoryType
end

function GameEnvironmentProxy:GetUDID()
    return global.L_GameEnvManager:GetUDID()
end

function GameEnvironmentProxy:GetPUID()
    return global.L_GameEnvManager:GetPUID()
end

return GameEnvironmentProxy
