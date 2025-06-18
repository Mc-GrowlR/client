local DebugMediator      = requireMediator( "DebugMediator" )
local DisconnectMediator = class('DisconnectMediator', DebugMediator)
DisconnectMediator.NAME  = "DisconnectMediator"

-- 服务器被攻击，迁移DNS解析需要时间，这里一直重连，重连时玩家可以主动选择退出
-- 2024.02.26, suntong 让连10次失败后不再连接，弹窗提醒玩家退出。

local TOTAL_TRY_MAX      = 10	-- x次后弹出提醒框，并终止重连
local WAIT_TIME          = 3


function DisconnectMediator:ctor()
    DisconnectMediator.super.ctor( self, self.NAME )

    self._totalTry = 0
    self._forbidden = false
	self._otherClient = false
end

function DisconnectMediator:listNotificationInterests()
	local noticeTable = global.NoticeTable
	return  
	{
		noticeTable.Disconnect,
		noticeTable.IllegalMsg,
		noticeTable.OtherClientLogin,
		noticeTable.ConnectGameWorld,
		noticeTable.ReconnectForbidden,
	}
end


function DisconnectMediator:handleNotification(notification)
	local noticeID = notification:getName()
	local notices  = global.NoticeTable
	local data     = notification:getBody()

	if notices.Disconnect == noticeID then
		self:onDisconnect()

	elseif notices.IllegalMsg == noticeID then
		self:onIllegalMsg( data )

	elseif notices.OtherClientLogin == noticeID then
		self:onOtherClientLogin()

	elseif notices.ConnectGameWorld == noticeID then
		self:onConnectGameWorld()

	elseif notices.ReconnectForbidden == noticeID then
		self:onReconnectForbidden()

	end
end 

function DisconnectMediator:startReconnect()
	ShowLoadingBar()

	self._totalTry = 0
	PerformWithDelayGlobal( handler( self, self.connect ), WAIT_TIME )
end

function DisconnectMediator:stopReconnect()
	HideLoadingBar()
end

function DisconnectMediator:tryReconnect()
	-- 重连禁用
	if self._forbidden then
		return 
	end

	self:startReconnect()
end

function DisconnectMediator:connect()
	-- 重连禁用
	if self._forbidden then
		return 
	end

    local AuthProxy    = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    local loginProxy   = global.Facade:retrieveProxy( global.ProxyTable.Login )
    local netClient    = global.gameEnvironment:GetNetClient()

    local ip          = loginProxy:GetSelectedServerIp()
    local port        = loginProxy:GetGameServerPort()
    local proxyport   = loginProxy:GetSelectedServerProxyPort()
    local connectIP   = tostring(ip)
    local connectPort = tonumber(proxyport or port)

    release_print("-------------------------------------- reconnect", connectIP, connectPort, self._totalTry)
	local Connect = function (param1Ex)
		local ret = netClient:Connect(connectIP, connectPort)
		release_print("connect state", ret)

		-- connect success
		if 1 == ret then
			-- // *#账号/角色名字/角色ID/parma4/server_key/0!
			local LoginProxy 	= global.Facade:retrieveProxy(global.ProxyTable.Login)
			local AuthProxy 	= global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
			local account   	= AuthProxy:GetUID()
			local currentModule = global.L_ModuleManager:GetCurrentModule()
			local moduleGameEnv = currentModule:GetGameEnv()
			local whitelist     = (moduleGameEnv:IsWhitelist() == true and 1 or 0)
			local envProxy      = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
			local cert          = global.L_NativeBridgeManager.GetCertification and global.L_NativeBridgeManager:GetCertification()
			local adult         = global.L_NativeBridgeManager.GetAdult and global.L_NativeBridgeManager:GetAdult()
			cert                = (cert == true) and 1 or 0
			adult               = (adult == true) and 1 or 0
			local isboxlogin    =  global.L_GameEnvManager:GetEnvDataByKey("isBoxLogin") or 0
			local isBatchMsg    = (global.LuaBridgeCtl:GetModulesSwitch(global.MMO.Modules_Index_Net_BatchMsg) == 1) and 1 or 0
			-- android:0, ios:1  except:2
			local platform = 2
			if cc.PLATFORM_OS_ANDROID == global.Platform or global.isOHOS then
				platform = 0
			elseif cc.PLATFORM_OS_IPAD == global.Platform or cc.PLATFORM_OS_IPHONE == global.Platform then
				platform = 1
			end
			local sendStr = string.format("*#%s/%s/%s/%d/%s/0/%s/%s/%s/%s/%s/%s",
				account,
				LoginProxy:GetSelectedRoleName(),
				LoginProxy:GetSelectedRoleID(),
				netClient:GetNetMessageTypeSData(),
				platform,
				envProxy:GetChannelID(),
				whitelist,
				cert,
				adult,
				isboxlogin,
				isBatchMsg
			)

			local recog = GET_NET_MSG_STAMP_HEAD_RECOG()
			local param1 = param1Ex or GET_NET_MSG_STAMP_HEAD_PARAM1()
			local param2 = tonumber(loginProxy:GetMainSelectedServerId() or loginProxy:GetSelectedServerId()) or 0
			local param3 = tonumber(loginProxy:GetGameServerPort()) or 0
			LuaSendMsg(global.MsgType.MSG_CS_RELOGIN_SERVER, recog, param1, param2, param3, sendStr, string.len(sendStr))

			global.Facade:sendNotification(global.NoticeTable.GameWorldCheckTimeout)
			
			-- set dispatch msg enable:true
			global.LuaBridgeCtl:SetModulesSwitch( global.MMO.Modules_Index_Enable_Disconnect_Msg, 1 )
			
			-- 
			self:stopReconnect()
		else
			self._totalTry = self._totalTry + 1
			if self._totalTry >= TOTAL_TRY_MAX then
				self:stopReconnect()
				self:showReconnectTips()
			else
				PerformWithDelayGlobal( handler( self, self.connect ), WAIT_TIME )
			end
		end
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
end


function DisconnectMediator:dialogCallback( type ,custom )
	if 1 == type then
		-- PC上默认退出，方便获取新的登录信息以及更新exe
        if global.isWindows then
            global.Director:endToLua()
		else
			global.L_NativeBridgeManager:GN_accountLogout()
			global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
        end
	end
end

function DisconnectMediator:onDisconnect()
	-- set dispatch msg enable:false
	global.LuaBridgeCtl:SetModulesSwitch( global.MMO.Modules_Index_Enable_Disconnect_Msg, 0 )

	local VoiceManagerProxy = global.Facade:retrieveProxy( global.ProxyTable.VoiceManagerProxy )
	if VoiceManagerProxy then
		VoiceManagerProxy:VoiceExit()
	end

	self:tryReconnect()
end

function DisconnectMediator:onConnectGameWorld()
    -- 重连时才响应658消息
    local DisconnectProxy = global.Facade:retrieveProxy( global.ProxyTable.Disconnect )
    if false == DisconnectProxy:IsDisconnect() then
        return false
    end

    -- enter world
    local loginProxy = global.Facade:retrieveProxy( global.ProxyTable.Login )
    loginProxy:EnterWorld(true)
end

function DisconnectMediator:onReconnectForbidden()
    self._forbidden = true
	local NativeBridgeProxy = global.Facade:retrieveProxy( global.ProxyTable.NativeBridgeProxy )
    NativeBridgeProxy:GN_DetachSucceedByServer()
end

function DisconnectMediator:onIllegalMsg( code )
	-- set dispatch msg enable:false
	global.LuaBridgeCtl:SetModulesSwitch(global.MMO.Modules_Index_Enable_Disconnect_Msg, 0)

	-- disconnect
	local netClient = global.gameEnvironment:GetNetClient()
	netClient:Disconnect()


	local data    = {}
	data.str      = string.format(GET_STRING(800805), code)
	data.btnDesc  = {GET_STRING(800802)}
	data.callback = handler(self, self.dialogCallback)
	global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

function DisconnectMediator:onOtherClientLogin()
	-- 试玩模式
    if global.IsVisitor then
        return nil
    end
	if self._otherClient then
		return nil
	end
	self._otherClient = true
	
	self:onReconnectForbidden()
	
	local data    = {}
	data.str      = GET_STRING(800801)
	data.btnDesc  = {GET_STRING(800802)}
	data.callback = handler(self, self.dialogCallback)
	global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)

	-- 通知native层native层
	if global.L_NativeBridgeManager.GN_otherClientLogin then
		global.L_NativeBridgeManager:GN_otherClientLogin()
	end
end

function DisconnectMediator:showReconnectTips()
	local function confirmCB()
		if global.isWindows then
            global.Director:endToLua()
		else
			global.L_NativeBridgeManager:GN_accountLogout()
			global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
        end
	end
	
	local data    = {}
	data.str      = GET_STRING(800804)
	data.btnDesc  = {GET_STRING( 800802 )}
	data.callback = confirmCB
	global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Close)
	global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

function DisconnectMediator.OnUnloaded()
	global.Facade:removeMediator( DisconnectMediator.NAME )

	DisconnectMediator.super.OnUnloaded()
end

function DisconnectMediator.Onloaded()
	local mediator = DisconnectMediator.new()
	global.Facade:registerMediator( mediator )

	DisconnectMediator.super.Onloaded()
end


return DisconnectMediator
