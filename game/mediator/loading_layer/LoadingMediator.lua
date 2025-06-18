local BaseUIMediator = requireMediator("BaseUIMediator")
local LoadingMediator = class('LoadingMediator', BaseUIMediator)
LoadingMediator.NAME = "LoadingMediator"


local ui_path = global.MMO.PATH_RES_PRIVATE
local HUDFilePath = global.MMO.PATH_RES_PRIVATE .. "hud/actor_hud"

function LoadingMediator:ctor()
    LoadingMediator.super.ctor(self)

    self._textureCache = {}
    self._spriteFrameCache = {}
end

function LoadingMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
        {
            -- noticeTable.Layer_Loading_Open,
            -- noticeTable.Layer_Loading_UpdatePercent,
            noticeTable.PreloadBegin,
            noticeTable.ReleaseMemory,
        }
end

function LoadingMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.Layer_Loading_Open == noticeID then
        self:OnOpen()

    elseif noticeTable.Layer_Loading_UpdatePercent == noticeID then
        self:OnUpdatePercent(data)

    elseif noticeTable.PreloadBegin == noticeID then
        self:OnPreloadBegin()

    elseif noticeTable.ReleaseMemory == noticeID then
        self:OnReleaseMemory()

    end
end

function LoadingMediator:OnOpen()
    if not self._layer then
        self._layer = requireLayerUI("loading_layer/LoadingLayer").create()
        self._type = global.UIZ.UI_LOADING
        
        LoadingMediator.super.OpenLayer(self)
    end
end

function LoadingMediator:OnClose()
    LoadingMediator.super.CloseLayer(self)
end

function LoadingMediator:OnUpdatePercent(percent)
    if self._layer then
        self._layer:UpdatePercent(percent)
    end
end

function LoadingMediator:initController()
    if not global.sceneManager then
        if global.isWinPlayMode then
            global.LuaBridgeCtl:SetModulesSwitch(global.MMO.Modules_Index_Scene_Tex_Type, 1)
            global.LuaBridgeCtl:SetModulesSwitch(global.MMO.Modules_Index_Scene_Artifact_Flag, 0)
            -- global.LuaBridgeCtl:SetModulesSwitch(global.MMO.Modules_Index_Scene_Blend_Flag, 0)
        end

        local module            = global.L_ModuleManager:GetCurrentModule()
        local modulePath        = module:GetSubModPath()
        local moduleGameEnv     = module:GetGameEnv()
        local storagePath       = cc.FileUtils:getInstance():getWritablePath() .. modulePath
        -- GM 自定义搜索路径
        local gmCachePath       = global.L_GameEnvManager:GetGMCachePath()
        if global.isWindows and gmCachePath and string.len(gmCachePath) > 0 then
            storagePath         = gmCachePath
        end
        
        local GMResUrl = moduleGameEnv.GetGMWebResUrl and moduleGameEnv:GetGMWebResUrl() or ""
        local GMResVerOri = moduleGameEnv.GetGMWebResVer and moduleGameEnv:GetGMWebResVer() or ""
        local sceneReleaseTime = tonumber(SL:GetMetaValue("GAME_DATA","sceneReleaseTime")) or 20
        global.sceneManager = tileSceneManager:Inst()
        if global.sceneManager.setGMResUrl then
            global.sceneManager:setGMResUrl(GMResUrl, storagePath)
        end
        if global.sceneManager.setGMResVer and GMResVerOri ~= "" then
            local subMod        = module:GetCurrentSubMod()
            local subModInfo    = subMod:GetSubModInfo()
            local gameid        = subMod:GetOperID()
            local xk            = subMod:GetXK()
            local channelID     = global.L_GameEnvManager:GetChannelID() or 1
            local GMResVer      = GMResVerOri

            if GetCdnSign then
                local sign  = GetCdnSign(gameid, global.modListSrvTime, xk or "")
                local param = string.format("gameId=%s&time=%s&sign=%s&channelID=%s", gameid, global.modListSrvTime, sign, channelID)
                GMResVer  = string.format("%s&%s", GMResVer, param)
                --刷新时间戳 cdn鉴权
                global.modListSrvTimeCallFuncs = global.modListSrvTimeCallFuncs or {}
                local refResTime = function ()
                    local sign  = GetCdnSign(gameid, global.modListSrvTime, xk or "")
                    local param = string.format("gameId=%s&time=%s&sign=%s&channelID=%s", gameid, global.modListSrvTime, sign, channelID)
                    local GMResVer  = string.format("%s&%s", GMResVerOri, param)
                    if global.sceneManager then 
                        global.sceneManager:setGMResVer(GMResVer)
                    end
                end
                table.insert(global.modListSrvTimeCallFuncs, refResTime)
            end
            global.sceneManager:setGMResVer(GMResVer)
        end
        if global.sceneManager.setAtlasExpiredInterval then
            local sceneReleaseTime = tonumber(global.ConstantConfig.sceneReleaseTime) or 20
            if global.L_GameEnvManager:GetEnvDataByKey("isCloudLogin") then
                sceneReleaseTime = 3
            end
            global.sceneManager:setAtlasExpiredInterval(sceneReleaseTime)
        end
        if global.sceneManager.setTextureMemLimitInMB then
            -- 内存限制
            local cloudPhoneSceneMemorySize = 300
            local cloudPhoneSceneMemoryWarn = 250
            if global.L_GameEnvManager:GetEnvDataByKey("isAliCloudPhone") then
                cloudPhoneSceneMemorySize = global.L_GameEnvManager:GetEnvDataByKey("cloudPhoneSceneMemorySize") or 80
                cloudPhoneSceneMemoryWarn = cloudPhoneSceneMemorySize - 30
            elseif global.L_GameEnvManager:GetEnvDataByKey("isCloudLogin") then
                cloudPhoneSceneMemorySize = global.L_GameEnvManager:GetEnvDataByKey("cloudPhoneSceneMemorySize") or 150
                cloudPhoneSceneMemoryWarn = cloudPhoneSceneMemorySize - 30
            end
            global.sceneManager:setTextureMemLimitInMB(cloudPhoneSceneMemorySize)

            -- 内存警告值
            if global.sceneManager.setTextureMemWarnMB then
                global.sceneManager:setTextureMemWarnMB(cloudPhoneSceneMemoryWarn)
            end
        end

        local sceneManagerHelper = require("scene/sceneManagerHelper")
        global.Facade:registerMediator( sceneManagerHelper.new() )
    end

    if not global.mouseEventController then
        local mouseEventController = require( "logic/mouseEventController" )
        global.mouseEventController = mouseEventController:Inst()
    end

    if not global.gamePlayerController then
        local gamePlayerController = require( "logic/gamePlayerController" )
        global.gamePlayerController = gamePlayerController:Inst()
    end

    if not global.netPlayerController then
        local netPlayerController = require( "logic/netPlayerController" )
        global.netPlayerController = netPlayerController:Inst()
    end

    if not global.netMonsterController then
        local netMonsterController = require( "logic/netMonsterController" )
        global.netMonsterController = netMonsterController:Inst()
    end

    if not global.netNpcController then
        local netNpcController = require( "logic/netNpcController" )
        global.netNpcController = netNpcController:Inst()
    end

    if not global.dropItemController then
        local dropItemController = require( "logic/dropItemController" )
        global.dropItemController = dropItemController:Inst()
    end

    if not global.gameMapController then
        local gameMapController = require( "logic/gameMapController" )
        global.gameMapController = gameMapController:Inst()
    end

    if not global.actorRefreshController then
        local actorRefreshController = require( "logic/actorRefreshController" )
        global.actorRefreshController = actorRefreshController:Inst()
    end

    if  not global.actorInViewController then
        local actorInViewController = require( "logic/actorInViewController" )
        global.actorInViewController = actorInViewController:Inst()
    end

    if not global.GameActorSkillController then
        local GameActorSkillController = require( "logic/GameActorSkillController" )
        global.GameActorSkillController = GameActorSkillController:Inst()
    end

    if not global.actorManager then
        local actorManager = require( "actor/actorManager" )
        global.actorManager = actorManager:Inst()
    end
    if not global.monsterManager then
        local monsterManager = require( "scene/monsterManager" )
        global.monsterManager = monsterManager:Inst()
    end

    if not global.playerManager then
        local playerManager = require( "scene/playerManager" )
        global.playerManager = playerManager:Inst()
    end

    if not global.npcManager then
        local npcManager = require( "scene/npcManager" )
        global.npcManager = npcManager:Inst()
    end

    if not global.dropItemManager then
        local dropItemManager = require( "scene/dropItemManager" )
        global.dropItemManager = dropItemManager:Inst()
    end

    if not global.sceneEffectManager then
        local sceneEffectManager = require( "scene/sceneEffectManager" )
        global.sceneEffectManager = sceneEffectManager:Inst()
    end
    if not global.darkNodeManager then
        local darkNodeManager = require( "scene/darkNodeManager" )
        global.darkNodeManager = darkNodeManager:Inst()
    end

    if not global.skillManager then
        local skillManager = require( "skill/skillManager" )
        global.skillManager = skillManager:Inst()
    end

    if not global.HUDManager then
        local actorHUDManager = require( "actor/actorHUDManager" )
        global.HUDManager = actorHUDManager:Inst()
    end

    if not global.HUDHPManager then
        local actorHUDHPManager = require( "actor/actorHUDHPManager" )
        global.HUDHPManager = actorHUDHPManager:Inst()
    end

    if not global.BuffManager then
        local BuffManager = require("buff/BuffManager")
        global.BuffManager = BuffManager:Inst()
    end

    if not global.DObstacleController then
        local DynamicObstacleController = require("logic/DynamicObstacleController")
        global.DObstacleController = DynamicObstacleController:Inst()
    end

    if not global.PathFindController then
        local PathFindController = require("logic/PathFindController")
        global.PathFindController = PathFindController:Inst()
    end

    if not global.BehaviorController then
        local BehaviorController  = require( "bt/BehaviorController" )
        global.BehaviorController = BehaviorController:Inst()
    end

    if not global.ActorEffectManager then
        local ActorEffectManager  = require( "buff/ActorEffectManager" )
        global.ActorEffectManager = ActorEffectManager:Inst()
    end

    if not global.RenderTextureManager then
        local RenderTextureManager  = require( "render/RenderTextureManager" )
        global.RenderTextureManager = RenderTextureManager:Inst()
    end
end

function LoadingMediator:InitGetServerTimeSchedule()
    if GetModListServerTime then
        GetModListServerTime()
        Schedule(function ()
            GetModListServerTime()
        end, 3*60*60)--三小时刷新一次资源请求时间戳 
    end
end

function LoadingMediator:OnPreloadBegin()
    self:autoReleaseTexture()
    self:initController()
    self:InitGetServerTimeSchedule()
    
    -- 预加载资源
    self._textureCache[HUDFilePath] = global.TextureCache:addImage(HUDFilePath .. ".png")
    self._textureCache[HUDFilePath]:retain()
    global.SpriteFrameCache:addSpriteFrames(HUDFilePath .. ".plist")
    local filelist = {9990, 9991, 9992, 9993, 9994, 9995, 9996, 9999}
    for i, v in ipairs(filelist) do
        local filename = string.format("actor_hud_%s.png", v)
        local spriteFrame = global.SpriteFrameCache:getSpriteFrame(filename)
        self._spriteFrameCache[filename] = spriteFrame
        self._spriteFrameCache[filename]:retain()
    end

    print( "preload begin" )
    global.LoadingHelper:AddExtraRef()
    global.LoadingHelper:ReleaseExtraRef()
end

function LoadingMediator:autoReleaseTexture()
    -- remove unused textures, 10min
    local envProxy      = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
    local totalMemType  = envProxy:GetTotalMemoryType()
    local tickT         = 600
    if totalMemType == global.MMO.MEMORY_TYPE_L then
        tickT = 120
    elseif totalMemType == global.MMO.MEMORY_TYPE_M then
        tickT = 240
    elseif totalMemType == global.MMO.MEMORY_TYPE_H then
        tickT = 600
    elseif totalMemType == global.MMO.MEMORY_TYPE_X then
        tickT = 600
    end

    local interval = 10*60
    if global.L_GameEnvManager:GetEnvDataByKey("isAliCloudPhone") then
        interval = 10
    end
    Schedule(function()
        global.TextureCache:removeUnusedTextures()
        global.SWidgetCache:releaseLimit()
    end, interval)
end

function LoadingMediator:OnReleaseMemory()
    -- 纹理
    for k, texture in pairs(self._textureCache) do
        texture:release()
    end
    self._textureCache = {}

    -- 精灵帧
    for k, spriteFrame in pairs(self._spriteFrameCache) do
        spriteFrame:release()
    end
    self._spriteFrameCache = {}
end

function LoadingMediator:handle_MSG_SC_GAME_HELLO_TIPS( msg )
    local jsonData = ParseRawMsgToJson( msg )
    jsonData       = jsonData or {}

    if not self._loadingTipFinsh then
        self._loadingTipFinsh = true
        -- 公告完成
        global.Facade:sendNotification(global.NoticeTable.GameWorldLoadinTipsFinish)

        -- begin loading
        global.Facade:sendNotification( global.NoticeTable.LoadingBegin )
    end

    -- 广播
    global.Facade:sendNotification(global.NoticeTable.ConnectGameWorld)
    
    local tipsContent   = global.isWinPlayMode and jsonData.PcMsg or jsonData.Msg
    local LoginProxy    = global.Facade:retrieveProxy(global.ProxyTable.Login)
    LoginProxy:SetTipsContent(tipsContent)
    LoginProxy:SetServiceVer(jsonData.ver)
    global.Facade:sendNotification(global.NoticeTable.Layer_GameWorldConfirm_Update)

    local mainPlayerID = jsonData.UserID
    print( "main player ID", mainPlayerID )
    global.gamePlayerController:SetMainPlayerID( mainPlayerID )
    global.playerManager:SetMainPlayerID( mainPlayerID )
end

function LoadingMediator:onRegister()
    LuaRegisterMsgHandler(global.MsgType.MSG_SC_GAME_HELLO_TIPS, handler(self, self.handle_MSG_SC_GAME_HELLO_TIPS))
end


return LoadingMediator
