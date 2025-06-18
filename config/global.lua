global = global or {}
local M = global

M.frameworkCore = "mmoclient"

-- ************************** init cpp ctl **************************
-- init cocos2d ctl
M.Director               = cc.Director:getInstance()
M.FileUtilCtl            = cc.FileUtils:getInstance()
M.Platform               = cc.Application:getInstance():getTargetPlatform()
M.Scheduler              = M.Director:getScheduler()
M.GLProgramCache         = cc.GLProgramCache:getInstance()
M.TextureCache           = M.Director:getTextureCache()
M.SpriteFrameCache       = cc.SpriteFrameCache:getInstance()
M.ScriptHandlerMgr       = ScriptHandlerMgr:getInstance()
    
-- init mmoclient ctl
M.networkCtl             = nil
M.sceneGraphCtl          = nil
M.gamePlayerController   = nil
M.netPlayerController    = nil
M.sceneManager           = nil
M.actorManager           = nil
M.monsterManager         = nil
M.playerManager          = nil
M.npcManager             = nil
M.dropItemManager        = nil
M.sceneEffectManager     = nil
M.FrameAnimManager       = nil
M.LuaBridgeCtl           = nil
M.BuffManager            = nil
M.gameWorldController    = nil
M.userInputController    = nil
M.BehaviorController     = nil
M.ActorEffectManager     = nil
M.modBridgeController    = nil
M.HttpDownloader         = nil          -- 下载(URL)
M.gameEnvironment        = nil
M.gameStateCtl           = nil
M.NativeBridgeCtl        = nil
M.skillManager           = nil
M.HUDManager             = nil
M.ResDownloader          = nil
M.JsonProtoHelper        = nil
M.ssrBridge              = nil
M.darkNodeManager        = nil


-- init lua global member
M.Facade                 = nil          -- pureMVC facade
M.GameStateController    = nil
M.DesignPolicy           = cc.ResolutionPolicy.FIXED_WIDTH

M.ActorAttr              = {}

-- ************************** init cpp ctl end **************************

-- ************************** world ui zOrder **************************
M.UIZ = 
{
    UI_BOTTOM                   = -3,               -- 战争迷雾最底层
    UI_RTOUCH                   = -2,               -- 按键触摸层
    UI_MAIN                     = -1,               -- 主界面
    UI_NORMAL                   = 1,                -- 正常界面(全屏)
    UI_FUNC                     = 2,                -- 功能按钮
    UI_LOADING                  = 3,                -- loading层
    UI_TOBOX                    = 4,                -- 弹出框
    UI_LOADINGBAR               = 5,                -- 菊花转
    UI_NOTICE                   = 6,                -- 滚动层提示
    UI_MOUSE                    = 7,                -- 鼠标操作层
    UI_MASK                     = 8,                -- 遮盖一切
}
-- ************************** world ui zOrder end **************************


-- macro
M.isWindows = M.Platform == cc.PLATFORM_OS_WINDOWS
M.isAndroid = M.Platform == cc.PLATFORM_OS_ANDROID
M.isIOS = M.Platform == cc.PLATFORM_OS_IPAD or M.Platform == cc.PLATFORM_OS_IPHONE
M.isOHOS = M.Platform == cc.PLATFORM_OS_HARMONY
M.isMobile = M.isAndroid or M.isIOS or M.isOHOS

-- play mode
M.isWinPlayMode = global.CURRENT_OPERMODE == global.OPERMODE_WINDOWS

-- init notice table 
M.NoticeTable = require( "config/NotificationTable" )


-- init Proxy table
M.ProxyTable = require( "config/ProxyTable" )

-- init Game Constants
M.MMO = require( "config/mmoConstants" )

-- init MsgType
require("network/netMessageDef")
M.MsgType = MsgType

M.JsonMsgType            = require("network/jsonproto/JsonMessageTable")
M.ActMessageTable        = requireConfig("ActMessageTable")
M.LayerTable             = requireConfig("LayerTable")
M.SUIComponentTable      = requireConfig("SUIComponentTable")
M.BehaviorConfig         = requireConfig("BehaviorConfig")
M.ConstantConfig         = requireConfig("ConstantConfig")
