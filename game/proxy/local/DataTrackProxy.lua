local DebugProxy = requireProxy("DebugProxy")
local DataTrackProxy = class("DataTrackProxy", DebugProxy)
DataTrackProxy.NAME = global.ProxyTable.DataTrackProxy

local cjson = require("cjson")

function DataTrackProxy:ctor()
    DataTrackProxy.super.ctor(self)
end

-------------------------------------------------------------
--- 角色信息返回
function DataTrackProxy:OnRoleInfo(jsonData)
    if cc.PLATFORM_OS_WINDOWS ~= global.Platform then
        global.L_NativeBridgeManager:GN_onSelectServer(jsonData)
    end

    -- QQ大厅上报
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    if AuthProxy:IsQQChannel() then
        local uploadData = {}
        uploadData.user_id            = jsonData.userId
        uploadData.server_id          = jsonData.zoneId
        uploadData.server_name        = jsonData.zoneName
        AuthProxy:uploadDataQQGame(5, uploadData) 
    end
end

-------------------------------------------------------------
--- 创角
function DataTrackProxy:OnCreateRole(jsonData)
    -- 上报至 安卓层
    global.L_NativeBridgeManager:GN_onNewRole(jsonData)

    -- 友盟数据上报
    global.L_NativeBridgeManager:GN_umengUploadNewRole(jsonData)

    --需要接入pc端的sdk
    if global.L_GameEnvManager:GetEnvDataByKey("isPcSdk") then
        local jsonString = cjson.encode(jsonData)
        local methodName = "GN_onNewRole"
        NativeBridgeCtl:Inst():sendMessage2Native(methodName, jsonString)
    end

    -- 996数据上报
    local DataRePortProxy = global.Facade:retrieveProxy( global.ProxyTable.DataRePortProxy )
    DataRePortProxy:CreateRole(jsonData)

    --直播红包+飘屏群 上报需求  
    local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    AuthProxy:RequestUpLoadCreateRole(jsonData)

end

-------------------------------------------------------------
--- 进入游戏
function DataTrackProxy:OnEnterGame(jsonData)
    global.L_NativeBridgeManager:GN_onEnterGame(jsonData)

    --需要接入pc端的sdk
    local isPcSdk = global.L_GameEnvManager:GetEnvDataByKey("isPcSdk")
    if isPcSdk or global.isWindows then
        local jsonString = cjson.encode(jsonData)
        local methodName = "GN_onEnterGame"
        NativeBridgeCtl:Inst():sendMessage2Native(methodName, jsonString)
    end

    -- 数据上报  进入游戏
    local DataRePortProxy = global.Facade:retrieveProxy( global.ProxyTable.DataRePortProxy )
    DataRePortProxy:GameLogin(jsonData)
end

-------------------------------------------------------------
--- 等级改变
function DataTrackProxy:OnLevelChange(jsonData)
    global.L_NativeBridgeManager:GN_onLevelChanged(jsonData)

    --需要接入pc端的sdk
    if global.L_GameEnvManager:GetEnvDataByKey("isPcSdk") then
        local jsonString = cjson.encode(jsonData)
        local methodName = "GN_onLevelChanged"
        NativeBridgeCtl:Inst():sendMessage2Native(methodName, jsonString)
    end
end

return DataTrackProxy