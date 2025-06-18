local BaseUIMediator = requireMediator("BaseUIMediator")
local GameWorldConfirmMediator = class("GameWorldConfirmMediator", BaseUIMediator)
GameWorldConfirmMediator.NAME = "GameWorldConfirmMediator"

function GameWorldConfirmMediator:ctor()
    GameWorldConfirmMediator.super.ctor(self)
    self._gameWorldTimeout = nil
end

function GameWorldConfirmMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.Layer_GameWorldConfirm_Open,
        noticeTable.Layer_GameWorldConfirm_Close,
        noticeTable.Layer_GameWorldConfirm_Update,
        noticeTable.GameWorldCheckTimeout,
        noticeTable.GameWorldInfoInitBegin,
        noticeTable.GameWorldLoadinTipsTimeout,
        noticeTable.GameWorldLoadinTipsFinish,
    }
end

function GameWorldConfirmMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_GameWorldConfirm_Open == noticeID then
        self:OpenLayer(data)

    elseif noticeTable.Layer_GameWorldConfirm_Close == noticeID then
        self:CloseLayer()

    elseif noticeTable.Layer_GameWorldConfirm_Update == noticeID then
        self:OnUpdate()

    elseif noticeTable.GameWorldCheckTimeout == noticeID then
        self:OnGameWorldCheckTimeout(data)

    elseif noticeTable.GameWorldInfoInitBegin == noticeID then
        self:OnGameWorldInfoInitBegin(data)

    elseif noticeTable.GameWorldLoadinTipsTimeout == noticeID then
        self:OnGameWorldLoadinTipsTimeout(data)

    elseif noticeTable.GameWorldLoadinTipsFinish == noticeID then
        self:OnGameWorldLoadinTipsFinish(data)

    end
end

function GameWorldConfirmMediator:OpenLayer(data)
    if not (self._layer) then
        self._layer  = requireLayerUI("game_world_confirm_layer/GameWorldConfirmLayer").create()
        self._type   = global.UIZ.UI_NORMAL
        self._voice  = false
        self._GUI_ID = SLDefine.LAYERID.GameWorldConfirmGUI
        GameWorldConfirmMediator.super.OpenLayer(self)

        self._layer:InitGUI()
    end
end

function GameWorldConfirmMediator:CloseLayer()
    GameWorldConfirmMediator.super.CloseLayer(self)
end

function GameWorldConfirmMediator:OnUpdate()
    if not self._layer then
        return false
    end

    self._layer:OnUpdate()
end

function GameWorldConfirmMediator:handlePressedEnter()
    if not self._layer then
        return false
    end

    self._layer:handlePressedEnter()
    return true
end

function GameWorldConfirmMediator:OnGameWorldCheckTimeout()
    if self._gameWorldTimeout then
        UnSchedule(self._gameWorldTimeout)
        self._gameWorldTimeout = nil
    end
    self._gameWorldTimeout = PerformWithDelayGlobal(function()
        self._gameWorldTimeout = nil

        -- 
        local function confirmCB()
            if global.isWindows then
                global.Director:endToLua()
            else
                global.L_NativeBridgeManager:GN_accountLogout()
                global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
            end
        end
    
        local data    = {}
        data.str      = GET_STRING( 30009096 )
        data.btnDesc  = { GET_STRING( 30009046 ) }
        data.callback = confirmCB
        global.Facade:sendNotification( global.NoticeTable.Layer_CommonTips_Close )
        global.Facade:sendNotification( global.NoticeTable.Layer_CommonTips_Open, data )

        -- 关闭自动重连
        global.Facade:sendNotification(global.NoticeTable.ReconnectForbidden)
        local netClient = global.gameEnvironment:GetNetClient()
        netClient:Disconnect()
    end, 20)
end

function GameWorldConfirmMediator:OnGameWorldInfoInitBegin()
    if self._gameWorldTimeout then
        UnSchedule(self._gameWorldTimeout)
        self._gameWorldTimeout = nil
    end
end

-- 获取公告超时
function GameWorldConfirmMediator:OnGameWorldLoadinTipsTimeout()
    if self._gameLoadinTipsimeout then
        UnSchedule(self._gameLoadinTipsimeout)
        self._gameLoadinTipsimeout = nil
    end

    local timeOut = 10
    ShowLoadingBar()
    self._gameLoadinTipsimeout = PerformWithDelayGlobal(function()
        self._gameLoadinTipsimeout = nil
        HideLoadingBar()

        -- 
        local function confirmCB()
            if global.isWindows then
                global.Director:endToLua()
            else
                global.L_NativeBridgeManager:GN_accountLogout()
                global.Facade:sendNotification( global.NoticeTable.RestartGame ) 
            end
        end
    
        local data    = {}
        data.str      = GET_STRING( 30009097 )
        data.btnDesc  = { GET_STRING( 30009046 ) }
        data.callback = confirmCB
        global.Facade:sendNotification( global.NoticeTable.Layer_CommonTips_Close )
        global.Facade:sendNotification( global.NoticeTable.Layer_CommonTips_Open, data )
    end, timeOut)
end

function GameWorldConfirmMediator:OnGameWorldLoadinTipsFinish()
    if self._gameLoadinTipsimeout then
        HideLoadingBar()
        UnSchedule(self._gameLoadinTipsimeout)
        self._gameLoadinTipsimeout = nil
    end
end

return GameWorldConfirmMediator
