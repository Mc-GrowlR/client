local LeaveWorldCommand = class('LeaveWorldCommand', framework.SimpleCommand)

function LeaveWorldCommand:ctor()
end

function LeaveWorldCommand:execute(note)
    local data = note:getBody()

    -- SL
    SLBridge:onLeaveWorld()

    -- ssr
    ssr.ssrBridge:onLeaveWorld()
    
    --语音通知退出
    local VoiceManagerProxy = global.Facade:retrieveProxy( global.ProxyTable.VoiceManagerProxy )
    if VoiceManagerProxy then
        VoiceManagerProxy:VoiceExit()
    end

    -- 数据上报 游戏时长
    local DataRePortProxy = global.Facade:retrieveProxy( global.ProxyTable.DataRePortProxy )
    DataRePortProxy:PlayGame()

    if global.isWindows then
        if global.DesignSize_Win.width < global.MMO.TradingBankDesignSize.width or global.DesignSize_Win.height < global.MMO.TradingBankDesignSize.height then 
            local glview = global.Director:getOpenGLView()
            glview:setFrameSize(global.DesignSize_Win.width, global.DesignSize_Win.height)
            glview:setFrameZoomFactor(global.DeviceZoom_Win)
        end
    end

    global.Facade:sendNotification(global.NoticeTable.Delay_Exit_Game_Window_Leave_World)

    global.Facade:sendNotification(global.NoticeTable.ChangeGameState, global.MMO.GAME_STATE_ROLE)

    global.Facade:sendNotification(global.NoticeTable.Layer_Login_Role_EnterGame_Delay)

    -- 发个小退消息给服务器
    local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local netClient  = global.gameEnvironment:GetNetClient()
    LoginProxy:RequestLeaveWorldNotify()
    LoginProxy:RegisterMsgHandler()
    LoginProxy:ClearRoles()
    LoginProxy:SetTipsContent("")
    
    ---
    local TradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.TradingBankProxy)
    TradingBankProxy:RegisterMsgHandler()
    local OtherTradingBankProxy = global.Facade:retrieveProxy(global.ProxyTable.OtherTradingBankProxy)
    OtherTradingBankProxy:RegisterMsgHandler()
    OtherTradingBankProxy:setGameToken("")--清理token
    OtherTradingBankProxy:LoginOut()

    if global.darkNodeManager then
        global.darkNodeManager:clearAllNodes()
    end

    --VerificationProxy
    local VerificationProxy = global.Facade:retrieveProxy(global.ProxyTable.VerificationProxy)
    VerificationProxy:RegisterMsgHandler()
    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
    SUIComponentProxy:RegisterMsgHandler()
    SUIComponentProxy:ClearData()

    self:InitDebug()

    PerformWithDelayGlobal(function()
        netClient:Disconnect()
    
        -- 
        local ip            = LoginProxy:GetSelectedServerIp()
        local port          = LoginProxy:GetRolePort()
        local proxyport     = LoginProxy:GetSelectedServerProxyPort()
        local connectIP     = tostring(ip)
        local connectPort   = tonumber(proxyport or port)
        local Connect = function (param1Ex)
            netClient:Connect(connectIP, connectPort)

            local specialData  = LoginProxy:GetNetMsgSpecialData()
            LoginProxy:RequestRoleInfo(specialData, param1Ex)
        end
        if proxyport then 
            GET_NET_MSG_STAMP_HEAD_PARAM1_NEW(function (param1Ex)
                Connect(param1Ex)
                local LoginProxy 	= global.Facade:retrieveProxy(global.ProxyTable.Login)
                LoginProxy.param1Ex = nil
            end)
        else
            Connect()
        end
    end, 0.5)
end

function LeaveWorldCommand:InitDebug()
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

return LeaveWorldCommand
