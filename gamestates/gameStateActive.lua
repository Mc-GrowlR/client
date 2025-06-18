local gameStateActive = class('gameStateActive')


function gameStateActive:ctor()
end


function gameStateActive:getStateType()
    return global.MMO.GAME_STATE_ACTIVE
end

function gameStateActive:onEnter()
    package.loaded["LuaExtend"] = nil

    self:InitController()
    
    self:InitUserData()

    self:InitPlatform()


    self:Init3rdparty()

    self:InitConfig()

    self:InitDebug()

    -- goto init
    global.Facade:sendNotification( global.NoticeTable.ChangeGameState, global.MMO.GAME_STATE_INIT )
    return 1
end

function gameStateActive:onEnd()--重启
    return 1
end
function gameStateActive:onExit()
    return 1
end

function gameStateActive:InitPlatform()
    global.OperatingMode        = (global.CURRENT_OPERMODE == global.OPERMODE_WINDOWS and global.MMO.OPERATING_MODE_WINDOWS or global.MMO.OPERATING_MODE_MOBILE)
    global.MouseEventOpen       = global.isWinPlayMode

    if SL._DEBUG then
        local userData = UserData:new("phone_mode_device")
        local cjson    = require("cjson")
        local key      = global.isWinPlayMode and "pc" or "phone"
        local jsonStr  = userData:getStringForKey(key, "")
        if jsonStr and string.len(jsonStr) > 0 then
            local size = cjson.decode(jsonStr)

            size = {width = ConvertToEven(size.width), height = ConvertToEven(size.height)}
            global.DeviceSize_Win = size
            global.DesignSize_Win = size
        end

        local glview = global.Director:getOpenGLView()
        glview:setFrameSize(global.DeviceSize_Win.width, global.DeviceSize_Win.height)
        glview:setFrameZoomFactor(global.DeviceZoom_Win)
    elseif cc.PLATFORM_OS_WINDOWS == global.Platform then
        global.DeviceSize_Win = {width = ConvertToEven(global.DeviceSize_Win.width), height = ConvertToEven(global.DeviceSize_Win.height)}
        local glview = global.Director:getOpenGLView()
        glview:setFrameSize(global.DeviceSize_Win.width, global.DeviceSize_Win.height)
        glview:setFrameZoomFactor(global.DeviceZoom_Win)
    end

    local frameSize   = global.Director:getOpenGLView():getFrameSize()
    local frameFactor = frameSize.width / frameSize.height
    if frameFactor > 1.8 then       -- 17:9 = 1.889
        global.DesignPolicy = cc.ResolutionPolicy.FIXED_HEIGHT
    else                            -- 16:9 = 1.778
        global.DesignPolicy = cc.ResolutionPolicy.FIXED_WIDTH
    end

    self:LoadGameSizeExtra()

    local rData = {}
    rData.rType = global.DesignPolicy
    if global.isWindows then
        rData.size  = global.DesignSize_Win
    else
        rData.size  = global.DesignSize_Oth
    end
    global.Facade:sendNotification( global.NoticeTable.ChangeResolution, rData )

    -- 输入法禁用
    if global.isWindows and disableIME then
        disableIME()
    end

    -- 下划线偏移
    if global.Director.setUnderlineOffsetY then
        global.Director:setUnderlineOffsetY(0)
    end

    -- 富文本对齐方式
    if global.Director.setRichTextVerticalAlignment then
        global.Director:setRichTextVerticalAlignment(1)
    end

    -- 文件不存在提醒
    global.FileUtilCtl:setPopupNotify(false)


    -- 窗口名
    if global.isWindows then
        local currentModule = global.L_ModuleManager:GetCurrentModule()
        local moduleGameEnv = currentModule:GetGameEnv()
        local server        = moduleGameEnv:GetSelectedServer()
        local glview        = global.Director:getOpenGLView()
        local viewName = global.L_GameEnvManager:GetEnvDataByKey("viewName")
        if viewName then
            local nameStr = string.format( "%s-%s", viewName, server.serverName)
            glview:setViewName(nameStr)
        else
            glview:setViewName(server.serverName)
        end
    end

    if not global.CUIKeyTable then
        global.CUIKeyTable  = requireConfig("CUIKeyTable")
    end

    ----------ttfScale-----
    --c++版本大于等于1
    if LuaBridgeCtl:Inst():GetModulesSwitch(global.MMO.Modules_Index_Cpp_Version) >= global.MMO.CPP_VERSION_LABEL_TTF then 
        local glview     = global.Director:getOpenGLView()
        local frameSize  = glview:getFrameSize()
        local DesignSize = glview:getDesignResolutionSize()
        local ttfscale   = 1
        if global.DesignPolicy == cc.ResolutionPolicy.FIXED_HEIGHT then 
            ttfscale = frameSize.height/DesignSize.height
        elseif global.DesignPolicy == cc.ResolutionPolicy.FIXED_WIDTH then 
            ttfscale = frameSize.width/DesignSize.width
        end
        cc.Label:setTTFAliasTexParameters(true)
        cc.Label:setTTFScaleFactor(ttfscale)
    end
end

function gameStateActive:Init3rdparty()
    local luaBridge = LuaBridgeCtl:Inst()
    local inited    = luaBridge:IsInit3rdparty()
    if not inited then
        print( "init 3rdparty")

        local platform = cc.Application:getInstance():getTargetPlatform()
        local config   = require( "config/ThirdPartyConfig" )
        if cc.PLATFORM_OS_ANDROID == global.Platform then
            -- init bugly
            initCrashReport( config.BuglyID, config.BuglyDebug )
        end

        luaBridge:Set3rdpartyInited( true )
    else
        print( "3rdparty inited")
    end
end

function gameStateActive:InitConfig()
    cc.Texture2D.setDefaultAlphaPixelFormat( cc.TEXTURE2_D_PIXEL_FORMAT_AUTO )
    global.Director:setProjection( cc.DIRECTOR_PROJECTION2_D )

    -- game env
    local gameEnvironment = requireProxy( "remote/GameEnvironmentProxy" )
    local envInst         = gameEnvironment.new( global.ProxyTable.GameEnvironment )
    global.Facade:registerProxy( envInst )
end

function gameStateActive:LoadGameSizeExtra()
    local fileUtil  = cc.FileUtils:getInstance()
    local filename  = "dev/data_config/size_extra_config.json"
    local isExist   = fileUtil:isFileExist(filename)
    if not isExist then
        filename = "data_config/size_extra_config.json"
    end
    local jsonStr   = nil
    if fileUtil:isFileExist(filename) then
        jsonStr     = fileUtil:getDataFromFileEx(filename)
    end
    if not jsonStr or jsonStr == "" then
        return nil
    end

    local cjson = require("cjson")
    local jsonData  = cjson.decode(jsonStr)
    if not jsonData then
        return nil
    end

    if jsonData["designSize_mobile"] then
        local width = jsonData["designSize_mobile"].width or 1136
        local height = jsonData["designSize_mobile"].height or 640
        global.DesignSize_Oth = {width = width, height = height}

        if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
            if not global.isWinPlayMode and (global.isDebugMode or global.isGMMode) then
                global.DesignSize_Win = {width = width, height = height}
                global.DeviceSize_Win = {width = width, height = height}
                local glview = global.Director:getOpenGLView()
                glview:setFrameSize(global.DeviceSize_Win.width, global.DeviceSize_Win.height)
            end
        end
    end 
end

function gameStateActive:InitController()
    -- NativeBridgeCtl
    if not global.NativeBridgeCtl then
        global.NativeBridgeCtl = NativeBridgeCtl:Inst()
    end

    -- 重启CMD
    local RestartCmd = requireCommand( "gamestates/RestartGameCommand" )
    global.Facade:registerCommand( global.NoticeTable.RestartGame, RestartCmd )

    -- 设计分辨率
    local ChangeResolutionCmd = requireCommand( "ChangeResolutionCommand" )
    global.Facade:registerCommand( global.NoticeTable.ChangeResolution, ChangeResolutionCmd )
end

function gameStateActive:InitDebug()
    -- DEBUG. reload some lua, for fast edit ui
    if global.isDebugMode or global.isGMMode then
        local keycodeFunc = {
            { 
                -- reload lua files
                keycode = {cc.KeyCode.KEY_CTRL, cc.KeyCode.KEY_F5}, 
                func = function()
                    package.loaded[ "init/initReload" ] = nil
                    require("init/initReload")
                    reload_script_files()

                    UpateGUIValueCfg()
                end
            },
            { 
                -- preview anim
                keycode = {cc.KeyCode.KEY_CTRL, cc.KeyCode.KEY_F4}, 
                func = function()
                    package.loaded["game/view/layersui/test_layer/PreviewAnimMediator"] = nil
                    global.Facade:sendNotification( global.NoticeTable.PreviewAnimOpen )
                end 
            },
            { 
                keycode = {cc.KeyCode.KEY_CTRL, cc.KeyCode.KEY_F9}, 
                func = function()
                    releaseLayerGUI("GUIEditor")
                    global.Facade:sendNotification(global.NoticeTable.Layer_GUIEditor_Open)
                end 
            },
            { 
                -- test layer
                keycode = {cc.KeyCode.KEY_CTRL,cc.KeyCode.KEY_F10}, 
                func = function()
                    global.Facade:sendNotification( global.NoticeTable.Layer_RichTextTest_Open )
                end 
            },
            { 
                keycode = {cc.KeyCode.KEY_CTRL, cc.KeyCode.KEY_F12}, 
                func = function()
                    releaseLayerGUI("GUITXTEditor")
                    global.Facade:sendNotification(global.NoticeTable.Layer_GUITXTEditor_Open)
                end 
            },
            { 
                -- debug map
                keycode = {cc.KeyCode.KEY_0}, 
                func = function()
                    global.Facade:sendNotification( global.NoticeTable.DebugMapSwitch )
                end 
            },
            { 
                -- restart game
                keycode = {cc.KeyCode.KEY_SHIFT, cc.KeyCode.KEY_ESCAPE}, 
                func = function()
                    global.Facade:sendNotification(global.NoticeTable.RestartGame)
                end 
            },
            { 
                keycode = {cc.KeyCode.KEY_CTRL, cc.KeyCode.KEY_Z}, 
                func = function()
                    local AutoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
                    if AutoProxy:IsAFKState() then
                        LuaSendMsg(global.MsgType.MSG_CS_AUTOPLAYGAME_REQUEST,2)
                        global.Facade:sendNotification(global.NoticeTable.AFKEnd)
                    else
                        LuaSendMsg(global.MsgType.MSG_CS_AUTOPLAYGAME_REQUEST,1)
                        global.Facade:sendNotification(global.NoticeTable.AFKBegin)            
                    end
                end 
            },
            { 
                keycode = {cc.KeyCode.KEY_CTRL, cc.KeyCode.KEY_F11}, 
                func = function()
                    package.loaded["game/view/layersui/test_layer/SUIEditor"] = nil
                    global.Facade:sendNotification(global.NoticeTable.SUIEditorOpen)
                end 
            },
            {
                keycode = {cc.KeyCode.KEY_TAB, cc.KeyCode.KEY_F5},
                func = function()
                    if ssrGlobal_F5FUNC then
                        ssrGlobal_F5FUNC()
                    end
                end
            },
            {
                -- CTRL+F6 打开配置表设置界面
                keycode = {cc.KeyCode.KEY_CTRL, cc.KeyCode.KEY_F6}, 
                func = function()
                    global.Facade:sendNotification(global.NoticeTable.Layer_ConfigSetting_Open)
                end
            },
            {
                keycode = {cc.KeyCode.KEY_CTRL, cc.KeyCode.KEY_F3},
                func = function()
                    global.Facade:sendNotification(global.NoticeTable.Layer_PreviewNode_Open)
                end 
            },
            {
                -- CTRL+F7  打开新增颜色编辑器
                keycode = {cc.KeyCode.KEY_CTRL, cc.KeyCode.KEY_F7}, 
                func = function()
                    global.Facade:sendNotification(global.NoticeTable.Layer_ExtraColorEditor_Open)
                end
            },
        }
        
        local inputKeyCode = {}
        local function compareKeyCode(k1, k2)
            return (table.concat(k1, "+") == table.concat(k2, "+"))
        end
        local function calcEvent()
            for _, v in ipairs(keycodeFunc) do
                if compareKeyCode(inputKeyCode, v.keycode) then
                    v.func()
                    break
                end
            end
        end

        local function pressed_callback(keycode, evt)
            table.insert(inputKeyCode, keycode)
            calcEvent()
        end
        local function released_callback(keycode, evt)
            for k, v in pairs(inputKeyCode) do
                if v == keycode then
                    table.remove(inputKeyCode, k)
                end
            end
        end
        local listener = cc.EventListenerKeyboard:create()
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
        listener:registerScriptHandler(pressed_callback, cc.Handler.EVENT_KEYBOARD_PRESSED)
        listener:registerScriptHandler(released_callback, cc.Handler.EVENT_KEYBOARD_RELEASED)
        eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
    end

end

--统一文件夹//localUserData
function gameStateActive:InitUserData()
    local module        = global.L_ModuleManager:GetCurrentModule()
    local modulePath    = module.GetSubModPath and module:GetSubModPath() or module:GetStabPath()
    local moduleGameEnv = module:GetGameEnv()
    local storagePath   = string.format("%s%s", modulePath,global.MMO.LOCAL_USERDATA)  
    local WritablePath = cc.FileUtils:getInstance():getWritablePath()
    -- 文件夹创建
    local modulePathDir = WritablePath..modulePath
    if not global.FileUtilCtl:isDirectoryExist(modulePathDir) then
        global.FileUtilCtl:createDirectory(modulePathDir)
    end
    if not global.FileUtilCtl:isDirectoryExist(WritablePath..storagePath) then
        global.FileUtilCtl:createDirectory(WritablePath..storagePath)
    end
    UserData:Cleanup()
    UserData:setVersionPath(storagePath)
end

return gameStateActive
