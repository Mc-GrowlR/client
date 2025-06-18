local gameStateInit  = class('gameStateInit')
local designSize     = cc.size( 1136, 640 )
local SplashTime     = 1.0
local SplashFadeInTime  = 0.6
local SplashFadeOutTime = 0.8

function gameStateInit:ctor()
    self._currScene = nil
end

function gameStateInit:getStateType()
    return global.MMO.GAME_STATE_INIT
end

function gameStateInit:onEnter()
    -- reset FPS
    global.Director:setAnimationInterval( 1 / 60 )

    self:InitController()
    self:InitDownloader()
    self:InitModel()
    self:InitMediator()
    self:InitDebug()

    --init randomseed
    math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )

    -- splash and goto login
    self:InitSplash() 

    if global.isWinPlayMode then 
        setCusTomCursor(global.MMO.CURSOR_TYPE_NORMAL)
    end
    return 1
end

function gameStateInit:onEnd()
    return 1
end
function gameStateInit:onExit()
    return 1
end

function gameStateInit:InitModel()
    local facade = global.Facade

    -- string_table
    local StringTable     = requireProxy( "local/StringTableProxy" )
    local stringTableInst = StringTable.new( global.ProxyTable.StringTable )
    facade:registerProxy( stringTableInst )

    -- color style
    local ColorStyleProxy = requireProxy("local/ColorStyleProxy")
    facade:registerProxy( ColorStyleProxy.new() )

    -- login proxy
    local LoginProxy = requireProxy( "remote/LoginProxy" )
    facade:registerProxy( LoginProxy.new() )

    -- Auth Proxy
    local AuthProxy = requireProxy( "remote/AuthProxy" )
    facade:registerProxy( AuthProxy.new() )

    -- 敏感词
    local SensitiveWordProxy = requireProxy( "local/SensitiveWordProxy" )
    facade:registerProxy( SensitiveWordProxy.new() )

    -- audio 
    local AudioProxy = requireProxy("local/AudioProxy")
    facade:registerProxy( AudioProxy.new() )

    -- model config proxy
    local ModelConfigProxy = requireProxy("local/ModelConfigProxy")
    facade:registerProxy( ModelConfigProxy.new() )

    -- NativeBridgeProxy
    local NativeBridgeProxy = requireProxy( "local/NativeBridgeProxy" )
    facade:registerProxy( NativeBridgeProxy.new() )

    -- local revcData = global.L_NativeBridgeManager._revcData
    -- if revcData and revcData.otherTradingBank and tostring(revcData.otherTradingBank) == "1" then 
    --     global.OtherTradingBank = true -- 联运 交易行
    -- end
    local currentModule = global.L_ModuleManager:GetCurrentModule()
    local moduleGameEnv = currentModule:GetGameEnv()
    local exchangeIsTrade    = moduleGameEnv:GetCustomDataByKey("exchangeIsTrade")
    dump(exchangeIsTrade,"exchangeIsTrade_____")
    if exchangeIsTrade and exchangeIsTrade == 1 then 
        global.OtherTradingBank = true -- 联运 交易行
    end

    --TradingBankProxy
    local TradingBankProxy = requireProxy( "remote/TradingBankProxy" )
    facade:registerProxy( TradingBankProxy.new() )

    local OtherTradingBankProxy = requireProxy( "remote/OtherTradingBankProxy" )
    facade:registerProxy( OtherTradingBankProxy.new() )
    
    --VerificationProxy
    local VerificationProxy = requireProxy( "remote/VerificationProxy" )
    facade:registerProxy( VerificationProxy.new() )

    --SUIComponentProxy
    local SUIComponentProxy = requireProxy( "remote/SUIComponentProxy" )
    facade:registerProxy( SUIComponentProxy.new() )

    -- MetaValueProxy
    local MetaValueProxy = requireProxy( "remote/MetaValueProxy" )
    facade:registerProxy( MetaValueProxy.new() )

    -- ConditionProxy
    local ConditionProxy = requireProxy( "remote/ConditionProxy" )
    facade:registerProxy( ConditionProxy.new() )

    --Data RePort
    local DataRePortProxy = requireProxy( "local/DataRePortProxy" )
    facade:registerProxy( DataRePortProxy.new() )

    -- DataTrackProxy
    local DataTrackProxy = requireProxy( "local/DataTrackProxy" )
    facade:registerProxy( DataTrackProxy.new() )
end

function gameStateInit:InitController()
    local facade = global.Facade

    -- http download
    if not global.HttpDownloader then
        global.HttpDownloader = httpDownloader:Inst()
    end

    -- environment
    if not global.gameEnvironment then
        global.gameEnvironment = gameEnviroment:Inst()
    end

    -- netClient
    local aNetClient = global.gameEnvironment:GetNetClient()
    if  aNetClient then
        if aNetClient.ResetDecoder then 
            aNetClient:ResetDecoder()
        end
    else
        aNetClient = netClient:new()
        global.gameEnvironment:SetNetClient( aNetClient )
    end

    if not global.networkCtl then 
        global.networkCtl = LuaNetworkController:Inst()
        global.networkCtl:SetNetClientPtr( aNetClient )
    end

    -- LuaBridgeCtl
    if not global.LuaBridgeCtl then
        global.LuaBridgeCtl = LuaBridgeCtl:Inst()
    end  

    -- FrameAnimManager
    if not global.FrameAnimManager then
        local actorSequFrameAnimManager = require( "animation/actorSequFrameAnimManager" )
        global.FrameAnimManager = actorSequFrameAnimManager.new()
    end 

    -- CustomCache
    if not global.CustomCache then
        local CustomCache    = requireUtil("CustomCache")
        global.CustomCache   = CustomCache.new()
    end
    
    -- SUIManager
    if not global.SUIManager then
        local SUIManager  = require( "sui/SUIManager" )
        global.SUIManager = SUIManager:Inst()
    end 

    -- SWidgetCache
    if not global.SWidgetCache then
        local SWidgetCache  = require( "sui/SWidgetCache" )
        global.SWidgetCache = SWidgetCache.new()
    end 

    -- mod bridge
    if not global.modBridgeController then
        global.modBridgeController = require("logic/ModBridgeController").new()
    end
    
    local cmd = requireCommand( "gamestates/LoadingCompletedCommand" )
    facade:registerCommand( global.NoticeTable.LoadingCompleted, cmd )
    local cmd = requireCommand( "gamestates/LoadingBeginCommand" )
    facade:registerCommand( global.NoticeTable.LoadingBegin, cmd )

    local GameWorldConfirmCommand  = requireCommand( "gamestates/GameWorldConfirmCommand" )
    facade:registerCommand(global.NoticeTable.GameWorldConfirm, GameWorldConfirmCommand)
    local GameWorldInfoInitCommand = requireCommand( "gamestates/GameWorldInfoInitCommand" )
    facade:registerCommand(global.NoticeTable.GameWorldInfoInit, GameWorldInfoInitCommand)

    -- shader
    local GrayShaderCmd   = requireCommand( "shader/GrayShaderCommand" )
    local NormalShaderCmd = requireCommand( "shader/NormalShaderCommand" )
    facade:registerCommand( global.NoticeTable.GrayNodeShader, GrayShaderCmd )
    facade:registerCommand( global.NoticeTable.NormalNodeShader, NormalShaderCmd )
end

function gameStateInit:InitDownloader()
    -- HttpDownloader
    local module        = global.L_ModuleManager:GetCurrentModule()
    local modulePath    = module.GetSubModPath and module:GetSubModPath() or module:GetStabPath()
    local moduleGameEnv = module:GetGameEnv()
    local rootDomain    = moduleGameEnv:GetSceneDownloadUrl()
    local resVersionOri = moduleGameEnv.GetSceneDownloadVer and moduleGameEnv:GetSceneDownloadVer() or moduleGameEnv:GetResVersion()
    local storagePath   = cc.FileUtils:getInstance():getWritablePath() .. modulePath
    
    local subMod        = module:GetCurrentSubMod()
    local subModInfo    = subMod:GetSubModInfo()
    local gameid        = subMod:GetOperID()
    local xk            = subMod:GetXK()
    local channelID     = global.L_GameEnvManager:GetChannelID() or 1
    local resVersion    = resVersionOri

    if GetCdnSign then
        local sign  = GetCdnSign(gameid, global.modListSrvTime, xk or "")
        local param = string.format("gameId=%s&time=%s&sign=%s&channelID=%s", gameid, global.modListSrvTime, sign, channelID)
        resVersion  = string.format("%s&%s", resVersionOri, param)
        
        --刷新时间戳 cdn鉴权
        global.modListSrvTimeCallFuncs = {}
        local refResTime = function ()
            local sign  = GetCdnSign(gameid, global.modListSrvTime, xk or "")
            local param = string.format("gameId=%s&time=%s&sign=%s&channelID=%s", gameid, global.modListSrvTime, sign, channelID)
            local resVersion  = string.format("%s&%s", resVersionOri, param)
            global.HttpDownloader:SetResourceVer(resVersion)
        end
        table.insert(global.modListSrvTimeCallFuncs, refResTime)
    end

    global.HttpDownloader:SetTimeOut(30)
    global.HttpDownloader:SetSpeedLimit(0)
    global.HttpDownloader:SetResourceVer(resVersion)
    global.HttpDownloader:SetDownloadURL(rootDomain)
    global.HttpDownloader:SetDownloadDir(storagePath)
    global.HttpDownloader:SetDownloadProgress(nil)


    -- 文件夹创建
    if not global.FileUtilCtl:isDirectoryExist(storagePath) then
        global.FileUtilCtl:createDirectory(storagePath)
    end
    local stabPath = cc.FileUtils:getInstance():getWritablePath() .. module:GetStabPath()
    if not global.FileUtilCtl:isDirectoryExist(stabPath) then
        global.FileUtilCtl:createDirectory(stabPath)
    end
    local items =
    {
        "anim/",
        "anim/effect/",
        "anim/hair/",
        "anim/monster/",
        "anim/npc/",
        "anim/player/",
        "anim/weapon/",
        "anim/shield/",
        "anim/wings/",

        "mp3/",
        
        "scene/",
        "scene/map/",
        "scene/objects/",
        "scene/smtiles/",
        "scene/tiles/",
        "scene/uiminimap/",
    }
    for _, v in ipairs(items) do
        local path = storagePath .. v
        if not global.FileUtilCtl:isDirectoryExist(path) then
            global.FileUtilCtl:createDirectory(path)
        end
        local path = stabPath .. v
        if not global.FileUtilCtl:isDirectoryExist(path) then
            global.FileUtilCtl:createDirectory(path)
        end
    end

    -- dev
    if global.isWindows and (global.isDebugMode or global.isGMMode) then
        local items = 
        {
            "res",
            "res/buff_icon",
            "res/custom",
            "res/item",
            "res/item_ground",
            "res/player_show",
            "res/skill_icon",
            "res/skill_icon_c",
            "res/Topwear",
            "res/private",
            "res/public",
    
            "anim",
            "anim/effect",
            "anim/hair",
            "anim/monster",
            "anim/npc",
            "anim/player",
            "anim/weapon",
            "anim/shield/",
            "anim/wings/",
    
            "mp3",
            
            "scene",
            "scene/map",
            "scene/objects",
            "scene/smtiles",
            "scene/tiles",
            "scene/uiminimap",
            
            "data_config",
            "data_config/ui_config",

            "scripts",
            "scripts/game_config",

            "GUILayout",
            "GUIExport",
            "GUIValue",
            ".996",
            "fonts",
        }
        local devPath = global.FileUtilCtl:getDefaultResourceRootPath() .. "dev"
        for _, v in ipairs(items) do
            local path = devPath .. "/" .. v
            if not global.FileUtilCtl:isDirectoryExist(path) then
                global.FileUtilCtl:createDirectory(path)
            end
        end

        -- fix configs
        local fixPath = devPath .. "/data_config/msg_decoder_config.txt"
        if global.FileUtilCtl:isFileExist(fixPath) then
            local fullPath = global.FileUtilCtl:fullPathForFilename(fixPath)
            global.FileUtilCtl:removeFile( fixPath )
            global.FileUtilCtl:purgeCachedEntries()
        end
    end

    -- GM网络资源 边玩边下
    global.ResDownloader = require("assets_downloader/ResDownloader").new()
    global.ResDownloader:init()
end

function gameStateInit:InitMediator()
    local facade = global.Facade

    -- scene
    local scene     = cc.Scene:create()
    local currScene = global.Director:getRunningScene()
    if not currScene then
        global.Director:runWithScene( scene )
    else
        global.Director:replaceScene( scene )
    end
    self._currScene = scene

    if not global.mouseEventController then
        local mouseEventController = require( "logic/mouseEventController" )
        global.mouseEventController = mouseEventController:Inst()
    end

    -- register audio mgr
    local AudioMediator = requireMediator( "audio/AudioMediator" )
    local audioMediator = AudioMediator.new()
    facade:registerMediator( audioMediator )

    -- rigister layer facade
    local LayerFacadeMediator = requireMediator( "LayerFacadeMediator" )
    local lFMediator          = LayerFacadeMediator.new()
    lFMediator:InitOnEnterActive( scene )
    facade:registerMediator( lFMediator )

    local NoticeProxy = requireProxy( "remote/NoticeProxy" )
    local noticeProxy = NoticeProxy.new()
    facade:registerProxy( noticeProxy )

    -- notice
    local MediatorClass = requireMediator( "message_layer/NoticeMediator" )
    local mediator      = MediatorClass.new()
    facade:registerMediator( mediator )

    -- loadingbar layer
    local LoadingBarMediator = requireMediator( "loading_layer/LoadingBarMediator" )
    local loadingBarMediator = LoadingBarMediator.new()
    facade:registerMediator( loadingBarMediator )

    -- commonTips
    local MediatorClass = requireMediator( "common_tips_layer/CommonTipsMediator" )
    local mediator      = MediatorClass.new()
    facade:registerMediator( mediator )

    local Mediator     = requireMediator("common_tips_layer/CommonDescTipsMediator")
    global.Facade:registerMediator(Mediator.new())

    --
    local GameWorldConfirmMediator = requireMediator("game_world_confirm_layer/GameWorldConfirmMediator")
    facade:registerMediator(GameWorldConfirmMediator.new())

    -- login
    local LoginAccountMediator    = requireMediator("login_layer/LoginAccountMediator")
    local loginServerMediator     = requireMediator("login_layer/LoginServerMediator")
    local loginRoleMediator       = requireMediator("login_layer/LoginRoleMediator")
    local loginRoleLockMediator   = requireMediator("login_layer/LoginRoleLockMediator")
    local loginVersionMediator    = requireMediator("login_layer/LoginVersionMediator")
    facade:registerMediator(LoginAccountMediator.new())
    facade:registerMediator(loginServerMediator.new())
    facade:registerMediator(loginRoleMediator.new())
    facade:registerMediator(loginRoleLockMediator.new())
    facade:registerMediator(loginVersionMediator.new())

    -- 
    local UserInputController = require("logic/UserInputController")
    global.userInputController = UserInputController:Inst()


    local Mediator     = requireMediator( "trading_bank_layer/TradingBankPhoneLayerMediator" )
    global.Facade:registerMediator( Mediator.new() )
    local Mediator     = requireMediator( "trading_bank_layer/TradingBankTipsLayerMediator" )
    global.Facade:registerMediator( Mediator.new() )
    local Mediator     = requireMediator( "trading_bank_layer/TradingBankTips2LayerMediator" )
    global.Facade:registerMediator( Mediator.new() )
    -------------------三方交易行
    local Mediator     = requireMediator( "trading_bank_layer_other/TradingBankPhoneLayerMediator_other" )
    global.Facade:registerMediator( Mediator.new() )
    local Mediator     = requireMediator( "trading_bank_layer_other/TradingBankTipsLayerMediator_other" )
    global.Facade:registerMediator( Mediator.new() )
    local Mediator     = requireMediator( "trading_bank_layer_other/TradingBankTips2LayerMediator_other" )
    global.Facade:registerMediator( Mediator.new() )

    local Mediator     = requireMediator( "common_tips_layer/CommonVerificationMediator" )
    global.Facade:registerMediator( Mediator.new() )

    -- delay exit game
    local Mediator     = requireMediator( "delay_exit_game/DelayExitGameMediator" ) 
    global.Facade:registerMediator( Mediator.new() )
end

function gameStateInit:InitDebug()
    -- for debug anim
    if global.isDebugMode or global.isGMMode then
        local Mediator = requireMediator( "test_layer/PreviewAnimMediator" ).new()
        global.Facade:registerMediator( Mediator )
    end

    if global.isDebugMode or global.isGMMode then
        local Mediator = requireMediator( "test_layer/AnimSetMediator" ).new()
        global.Facade:registerMediator( Mediator )
    end

    -- sui
    if global.isDebugMode or global.isGMMode then
        local Mediator = requireMediator( "test_layer/SUIEditorMediator" ).new()
        global.Facade:registerMediator( Mediator )
    end

    -- cui
    if global.isDebugMode or global.isGMMode then
        local Mediator  = requireMediator( "test_layer/CUIEditorMediator" ).new()
        global.Facade:registerMediator( Mediator )
    end

    if global.isDebugMode or global.isGMMode then
        local Mediator = requireMediator( "test_layer/PreviewSkillMediator" ).new()
        global.Facade:registerMediator( Mediator )
    end

    if global.isDebugMode or global.isGMMode then
        local Mediator = requireMediator( "test_layer/ConfigSettingMediator" ).new()
        global.Facade:registerMediator( Mediator )
    end

    if global.isDebugMode or global.isGMMode then
        local Mediator = requireMediator( "test_layer/PreviewAnimActionMediator" ).new()
        global.Facade:registerMediator( Mediator )
    end

    if global.isDebugMode or global.isGMMode then
        local Mediator = requireMediator( "test_layer/MagicInfoConfigMediator" ).new()
        global.Facade:registerMediator( Mediator )
    end

    if global.isDebugMode or global.isGMMode then
        local Mediator     = requireMediator( "test_layer/PreviewNodeMediator" )
        global.Facade:registerMediator( Mediator.new() )
    end

    -- gui
    if global.isDebugMode or global.isGMMode then
        local Mediator = requireMediator( "gui_layer/GUIEditorMediator" ).new()
        global.Facade:registerMediator( Mediator )

        local Mediator = requireMediator( "gui_layer/GUITXTEditorMediator" ).new()
        global.Facade:registerMediator( Mediator )

        local Mediator = requireMediator( "gui_layer/GUITXTEditorEventMediator" ).new()
        global.Facade:registerMediator( Mediator )
    end

    -- gui res selector
    if global.isDebugMode or global.isGMMode then
        local Mediator  = requireMediator( "gui_layer/GUIResSelectorMediator" ).new()
        global.Facade:registerMediator( Mediator )
    end

    if global.isDebugMode or global.isGMMode then
        local Mediator = requireMediator("gui_layer/ExtraColorEditorMediator").new()
        global.Facade:registerMediator(Mediator)
    end

    -- gui color selector
    if global.isDebugMode or global.isGMMode then
        local Mediator  = requireMediator( "gui_layer/GUIColorSelectorMediator" ).new()
        global.Facade:registerMediator( Mediator )
    end

    -- gui var manager
    if global.isDebugMode or global.isGMMode then
        local Mediator  = requireMediator( "gui_layer/GUIVarManagerMediator" ).new()
        global.Facade:registerMediator( Mediator )
    end
end

function gameStateInit:InitSplash()
    local function finishCB()
        global.Facade:sendNotification( global.NoticeTable.ChangeGameState, global.MMO.GAME_STATE_LOGIN )
    end

    -- 本次游戏只闪一次
    -- record splash switch
    if global.LuaBridgeCtl:GetModulesSwitch(global.MMO.Modules_Index_Enable_Splash) == 1 then
        finishCB()
        return
    end
    global.LuaBridgeCtl:SetModulesSwitch(global.MMO.Modules_Index_Enable_Splash, 1)

    -- 闪屏配置
    local splash = 
    {
        {filename = "splash.png"},
    }

    -- 未配置
    if not splash or not next(splash) then
        finishCB()
        return
    end

    -- show
    local items = clone(splash)
    local function showSplashAuto()
        if #items <= 0 then
            finishCB()
            return
        end

        local item      = table.remove(items, 1)
        local filename  = item.filename

        -- config error
        if not filename or "" == filename then
            showSplashAuto()
            return
        end

        -- check file exist
        local splashPath = global.MMO.PATH_RES_PRIVATE .. "splash/" .. filename
        if not global.FileUtilCtl:isFileExist( splashPath ) then
            showSplashAuto()
            return
        end

        -- image
        local origin   = global.Director:getVisibleOrigin()
        local viewSize = global.Director:getVisibleSize()
        local image    = ccui.ImageView:create()
        image:loadTexture( splashPath )
        image:setPosition( viewSize.width * 0.5, viewSize.height * 0.5 )
        image:setAnchorPoint( 0.5, 0.5 )
        self._currScene:addChild( image )

        local function callback()
            showSplashAuto()
        end
        image:setOpacity( 0 )
        image:runAction( cc.Sequence:create( 
            cc.FadeIn:create( SplashFadeInTime ),
            cc.DelayTime:create( SplashTime ),
            cc.FadeTo:create( SplashFadeOutTime, 20 ),
            cc.CallFunc:create( callback ),
            cc.RemoveSelf:create()
        ) )

        -- remove texture cache
        global.TextureCache:removeTextureForKey( splashPath )
    end

    showSplashAuto()
end


return gameStateInit
