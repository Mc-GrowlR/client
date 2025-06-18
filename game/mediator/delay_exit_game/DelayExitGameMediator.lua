local DebugMediator = requireMediator("DebugMediator")
local DelayExitGameMediator = class('DelayExitGameMediator', DebugMediator)
DelayExitGameMediator.NAME = "DelayExitGameMediator"

function DelayExitGameMediator:ctor()
    DelayExitGameMediator.super.ctor(self, self.NAME)

    self._game_init_finish = false
    self:onIsCanWindownCloseState()
end

function DelayExitGameMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
            noticeTable.GameWorldInitComplete, 
            noticeTable.Delay_Exit_Game_Window_Close_Notice,
            noticeTable.Delay_Exit_Game_Window_Leave_World,
    }
end

function DelayExitGameMediator:handleNotification(notification)
    local noticeID = notification:getName()
    local notices = global.NoticeTable
    local data = notification:getBody()

    if notices.GameWorldInitComplete == noticeID then
        self._game_init_finish = true
        self:onIsCanWindownCloseState()
    elseif notices.Delay_Exit_Game_Window_Close_Notice == noticeID then
        self:onGameWindowCloseNotice()
    elseif notices.Delay_Exit_Game_Window_Leave_World == noticeID then
        self:onLeaveWorld()
    end
end

--- PC端 关闭按钮状态
function DelayExitGameMediator:onIsCanWindownCloseState()
    if self._game_init_finish and global.L_GameEnvManager:GetEnvDataByKey("pc_close_secoend_tips") == 1 then
        local NativeBridgeProxy = global.Facade:retrieveProxy(global.ProxyTable.NativeBridgeProxy)
        NativeBridgeProxy:GN_IsCan_Windown_Close_State({
            state = 0
        })
        return
    end

    local CloseGameID = global.L_GameEnvManager:GetEnvDataByKey("CloseGameID")
    if (self._game_init_finish and CHECK_SERVER_OPTION("DelayBQuit")) or CloseGameID then -- 延迟刷新
        local NativeBridgeProxy = global.Facade:retrieveProxy(global.ProxyTable.NativeBridgeProxy)
        NativeBridgeProxy:GN_IsCan_Windown_Close_State({
            state = 0
        })
    end
end

--- PC端 点击关闭按钮时通知
function DelayExitGameMediator:onGameWindowCloseNotice()
    if global.L_GameEnvManager:GetEnvDataByKey("pc_close_secoend_tips") == 1 then
        if self._game_init_finish then
            local function callback(bType, custom)
                if bType == 1 then
                    local CloseGameID = global.L_GameEnvManager:GetEnvDataByKey("CloseGameID")
                    if CloseGameID then
                        -- 5. 关闭 触发SDK调用[特殊SDK]
                        local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
                        AuthProxy:uploadData(5, {gameInitFinish=self._game_init_finish})
                        return
                    end
                    global.Director:endToLua()
                end
            end
            local data = {}
            data.str = GET_STRING(30003079)
            data.btnType = 2
            data.callback = callback
            global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        end
        return
    end

    local CloseGameID = global.L_GameEnvManager:GetEnvDataByKey("CloseGameID")
    if not ((self._game_init_finish and CHECK_SERVER_OPTION("DelayBQuit")) or CloseGameID) then
        return
    end
    if CloseGameID then
        -- 5. 关闭 触发SDK调用[特殊SDK]
        local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
        AuthProxy:uploadData(5, {gameInitFinish=self._game_init_finish})
        return
    end

    local function checkExitGame(atype)
        if atype == 1 then
            if self._game_init_finish then
                global.userInputController:RequestToOutGame()
                return
            end
            local glview = global.Director:getOpenGLView()
            glview:endToLua()
        end
    end

    local data = {}
    data.str = GET_STRING(30003036)
    data.btnType = 2
    data.callback = checkExitGame
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

function DelayExitGameMediator:onLeaveWorld()
    if global.L_GameEnvManager:GetEnvDataByKey("pc_close_secoend_tips") == 1 then
        self._game_init_finish = false
        return
    end

    local CloseGameID = global.L_GameEnvManager:GetEnvDataByKey("CloseGameID")
    if CHECK_SERVER_OPTION("DelayBQuit") or CloseGameID then -- 延迟刷新
        local NativeBridgeProxy = global.Facade:retrieveProxy(global.ProxyTable.NativeBridgeProxy)
        NativeBridgeProxy:GN_IsCan_Windown_Close_State({
            state = 1
        })
    end
end

return DelayExitGameMediator
