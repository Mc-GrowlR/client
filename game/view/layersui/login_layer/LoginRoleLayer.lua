local BaseLayer = requireLayerUI("BaseLayer")
local LoginRoleLayer = class("LoginRoleLayer", BaseLayer)

local cjson = require("cjson")

function LoginRoleLayer:ctor()
    LoginRoleLayer.super.ctor(self)
    self._path = global.MMO.PATH_RES_PRIVATE .. "login/"
    self._proxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    self.AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
    self._index = -1
    self._isRandName = false

    self._reloginCD = false
end

function LoginRoleLayer.create(...)
    local node = LoginRoleLayer.new()
    if node:Init(...) then
        return node
    end
    return nil
end

function LoginRoleLayer:Init(data)
    self._quickUI = ui_delegate(self)

    return true
end

function LoginRoleLayer:InitGUI(data)
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_LOGINROLE)
    local meta = {}
    meta.OnCreateRole = function ()
        self:ShowCreateRole()
    end
    meta.OnCloseCreateRole = function ()
        self:HideCreateRole()
    end
    meta.OnRestoreRole = function (index)
        self:RequestRestoreRole(index)
    end
    meta.OnSelectRole = function(index)
        self:SelectRole(index)
    end
    meta.OnDeleteRole = function(index)
        self:DeleteRole(index)
    end
    meta.__index = meta
    setmetatable(LoginRolePanel, meta)
    LoginRolePanel._CreateUI = nil
    LoginRolePanel._RestoreUI = nil
    LoginRolePanel._index = -1
    LoginRolePanel.main()

    self:InitAct()
    self:InitAutoButton()
    self:ShowTradingInfo()

    local checkAuto = nil

    -- 默认上次，没有就选择第一个
    local roles = self._proxy:GetRoles()
    local selectRole = self._proxy:GetSelectedRole()
    if selectRole then
        checkAuto = 1
        self:SelectRole(selectRole.index, true)
    elseif #roles > 0 then
        checkAuto = 1
        self:SelectRole(1, true)
    else
        LoginRolePanel.ShowCreateRole(true)
        if self._auto_data then
            self._auto_data[2].btn = LoginRolePanel._CreateUI and LoginRolePanel._CreateUI.Button_submit
            self:checkAutoButton(2)
        end
    end

    if LoginRolePanel.UpdateRoles then
        LoginRolePanel.UpdateRoles()
    end

    self:checkAutoButton(checkAuto)

    self:InitRequestHeartBeat()
end

function LoginRoleLayer:onRoleEnterGameDelay()
    self._reloginCD = true

    local exitCD = tonumber(global.ConstantConfig.buttonSmall) or 0
        
    -- 小退CD
    local interval  = 1 / 60
    local exitTime  = exitCD * 0.001
    local remaining = exitTime

    local contentSize = self._quickUI.Button_start:getContentSize()
    local layoutSize = cc.size(100, 40)
    local blackLayout = ccui.Layout:create()
    self._quickUI.Button_start:addChild(blackLayout)
    blackLayout:setAnchorPoint(cc.p(0.5, 0))
    blackLayout:setPosition(cc.p(contentSize.width / 2, 10))
    blackLayout:setContentSize(layoutSize)
    blackLayout:setBackGroundColor(cc.c3b(0, 0, 0))
    blackLayout:setBackGroundColorType(1)
    blackLayout:setBackGroundColorOpacity(150)

    local height  = layoutSize.height
    local percent = 100
    local function callback(dt)
        remaining = math.max(remaining - interval, 0)
        height = remaining / exitTime * layoutSize.height
        blackLayout:setContentSize(cc.size(layoutSize.width, height))

        if remaining == 0 then
            self._reloginCD = false
            blackLayout:stopAllActions()
        end
    end
    schedule(blackLayout, callback, interval)
end

function LoginRoleLayer:InitAct()
    -- 开始
    if self._quickUI and self._quickUI.Button_start then
        self._quickUI.Button_start:addClickEventListener(function()
            DelayTouchEnabled(self._quickUI.Button_start, 0.5)

            self:RequestEnterGame()
        end)
    end

    -- 返回
    if self._quickUI and self._quickUI.Button_leave then
        self._quickUI.Button_leave:addClickEventListener(function()
            if self._shiwan then
                return 
            end
            global.L_NativeBridgeManager:GN_accountLogout()
            global.Facade:sendNotification(global.NoticeTable.RestartGame)

            local envProxy = global.Facade:retrieveProxy(global.ProxyTable.GameEnvironment)
            if envProxy:IsNeedExitGame() then
                global.Director:endToLua()
            end
        end)
    end

    -- 创建
    if self._quickUI and self._quickUI.Button_create then
        self._quickUI.Button_create:addClickEventListener(function()
            self:CreateRole()
        end)
    end

    -- 删除
    if self._quickUI and self._quickUI.Button_delete then
        self._quickUI.Button_delete:addClickEventListener(function()
            if self._shiwan then
                return 
            end
            -- 创角/恢复中
            if LoginRolePanel._CreateUI or LoginRolePanel._RestoreUI then
                return
            end

            if LoginRolePanel.ShowDelete then
                LoginRolePanel.ShowDelete()
            end
        end)
    end

    -- 恢复
    if self._quickUI and self._quickUI.Button_restore then
        self._quickUI.Button_restore:addClickEventListener(function()
            if self._shiwan then
                return 
            end
            -- 创角中
            if LoginRolePanel._CreateUI then
                return
            end

            --展示恢复角色列表 
            self:ShowRestoreList()

        end)
    end
end

function LoginRoleLayer:CreateRole()
    if self._shiwan then
        return 
    end
    -- 创角/恢复中
    if LoginRolePanel._CreateUI or LoginRolePanel._RestoreUI then
        return
    end

    local roles = self._proxy:GetRoles()
    if #roles >= 2 then
        local data = {}
        data.str = "你可以为每个单独的账号创建两个角色"
        data.btnType = 1
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
        return false
    end
    if LoginRolePanel.ShowCreateRole then
        LoginRolePanel.ShowCreateRole()
    end

end

-- 初始化自动按钮数据   (1: 开始   2: 创角提交)
function LoginRoleLayer:InitAutoButton()
    self._need_auto_btn = nil --已经自动倒计时的按钮下标
    if not self._quickUI.Button_start then
        return
    end
    local startStr = self._quickUI.Button_start:getTitleText() or ""
    local startDelay = startStr .. "(%s)"
    self._auto_data = {
        {btn = self._quickUI.Button_start, btnName = startStr, delayStr = startDelay} --开始
    }
end

function LoginRoleLayer:ShowRestoreList()
    local roles = SL:GetMetaValue("LOGIN_DATA")
    if #roles >= 2 then
        SL:ShowSystemTips("当前已有两角色，无法恢复角色！")
        return false
    end

    -- 请求恢复角色列表
    self._proxy:RequestRestoreRoleInfo()
end

function LoginRoleLayer:onRefreshRestoreRoleUI()
    if not LoginRolePanel._RestoreUI then
        LoginRolePanel.createRestore()
    else
        return
    end
end

function LoginRoleLayer:RequestRestoreRole(index)
    if not index then
        return
    end
    local function callback(bType)
        if bType == 1 then
            local RestoreRoleDatas = self._proxy:getRestoreRoleDatas()
            if #(RestoreRoleDatas)  > 0 then
                self._proxy:RequestRestoreRole(RestoreRoleDatas[index])
            end
        end
    end
    local data = {}
    data.str = GET_STRING(30000093)
    data.btnDesc = {GET_STRING(1001), GET_STRING(1000)}
    data.callback = callback
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

function LoginRoleLayer:handlePressedEnter()
    self:RequestEnterGame()
end

function LoginRoleLayer:OnLoginServerSuccess()
    if LoginRolePanel.CloseCreateRole then
        LoginRolePanel.CloseCreateRole()
    end
    if LoginRolePanel.UpdateRoles then
        LoginRolePanel.UpdateRoles()
    end
    self:ShowTradingInfo()
    -- 默认上次，没有就选择第一个
    local roles = self._proxy:GetRoles()
    local selectRole = self._proxy:GetSelectedRole()
    if selectRole then
        self:SelectRole(selectRole.index, true)
    elseif #roles > 0 then
        self:SelectRole(1, true)
    else
        LoginRolePanel.ShowCreateRole()
    end
end

-- 创角提交
function LoginRoleLayer:SendNewRoleSubmit()
    if LoginRolePanel._CreateUI then
        local input = GUI:TextInput_getString(LoginRolePanel._CreateUI.TextInput_name)
        if string.len(input) == 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009021))
            return
        end

        -- 屏蔽数字
        for i = 0, 10 do
            local _, endPos = string.find(input, tostring(i))
            if endPos then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009101))
                return
            end
        end

        ShowLoadingBar()
        local createJob = LoginRolePanel._createJob
        local createSex = LoginRolePanel._createSex
        local isRandName = self._isRandName
        local SensitiveWordProxy = global.Facade:retrieveProxy(global.ProxyTable.SensitiveWordProxy)
        SensitiveWordProxy:IsHaveSensitiveAddFilter(input, function(status)
            HideLoadingBar()

            -- 随机的名字不检测敏感字
            if not status and not isRandName then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(1006))
                return
            end

            local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
            LoginProxy:RequestCreateRole(input, createJob, createSex)
        end)
    end
end

function LoginRoleLayer:RequestEnterGame()
    if self._reloginCD then
        return
    end

    if LoginRolePanel._RestoreUI then
        return
    end

    -- 创角中
    if LoginRolePanel._CreateUI then
        self:SendNewRoleSubmit()
        DelayTouchEnabled(self._quickUI.Button_start, 0.5)
        return
    end

    -- 没有选择角色
    if not self._proxy:GetSelectedRole() then
        return
    end

    -- 检测封角色
    local selectRole = self._proxy:GetSelectedRole()
    if self._proxy:CheckBnannedRole(selectRole) then
        return
    end
    -- dump(selectRole,"selectRole___")
    --是否收货角色
    if selectRole.LockChar and selectRole.LockChar == 4 then
        global.IsReceiveRole = true
        global.IsVisitor = true
    else
        global.IsReceiveRole = false
        local shiwan = global.L_GameEnvManager:GetEnvDataByKey("shiwan")
        if not shiwan or tonumber(shiwan) ~= 1 then
            global.IsVisitor = false
        end
    end

    self._proxy:RequestEnterGame()

    global.Facade:sendNotification(global.NoticeTable.Audio_Stop_BGM)
end

function LoginRoleLayer:ShowTradingInfo()
    --刚刚交易的角色加上一个图标
    local roles = self._proxy:GetRoles()
    local showLock = true
    if roles then
        for i,v in ipairs(roles) do
            if v.LockChar and ( v.LockChar == 1 or  v.LockChar == 3 ) then
                showLock = true
            elseif v.newChar and v.newChar == 1 then
                showLock = true
            elseif v.LockChar and v.LockChar == 2 then -- 试玩角色
                self._shiwan = true
            end
        end
        if showLock then 
            global.Facade:sendNotification(global.NoticeTable.Layer_Login_RoleLock_Open)
        end
    end
end

function LoginRoleLayer:ShowCreateRole()
    -- 默认请求随机名字
    if LoginRolePanel._createJob and LoginRolePanel._createSex then
        self._proxy:RequestRoleName(LoginRolePanel._createJob, LoginRolePanel._createSex)
    end

    local ui = LoginRolePanel._CreateUI
    if not ui then
        return
    end
    -- 随机名字
    GUI:addOnClickEvent(ui.Button_rand, function()
        self._proxy:RequestRoleName(LoginRolePanel._createJob, LoginRolePanel._createSex)
    end)

    GUI:TextInput_addOnEvent(ui.TextInput_name, function(sender, eventType)
        if eventType == 2 then
            if IsForbidName(true) then
                GUI:TextInput_setString(ui.TextInput_name, "")
                return
            end
            self._isRandName = false

            local input = GUI:TextInput_getString(ui.TextInput_name)
            input = string.gsub(input, "\r\n", "")
            input = string.gsub(input, "\n", "")
            input = string.gsub(input, " ", "")
            input = string.gsub(input, "　", "")
            GUI:TextInput_setString(ui.TextInput_name, input)
        end
    end)

    -- 提交
    GUI:addOnClickEvent(ui.Button_submit, function()
        self:SendNewRoleSubmit()
        GUI:delayTouchEnabled(ui.Button_submit, 0.5)
    end)

    if self._auto_data and not self._auto_data[2] and LoginRolePanel._CreateUI and LoginRolePanel._CreateUI.Button_submit then
        local submitStr = LoginRolePanel._CreateUI.Button_submit:getTitleText()
        local delayStr = submitStr .. "(%s)"
        table.insert(self._auto_data, {btn = LoginRolePanel._CreateUI.Button_submit, btnName = submitStr, delayStr = delayStr}) -- 提交
    end
end

function LoginRoleLayer:HideCreateRole()
    if self._auto_data and self._auto_data[2] and next(self._auto_data[2]) then
        self._auto_data[2].btn = nil
        self:terminateAutoButton()
    end
end

function LoginRoleLayer:OnUpdateRoles()
    self._index = -1
    self:ShowTradingInfo()
    -- 默认上次，没有就选择第一个
    local roles = self._proxy:GetRoles()
    local selectRole = self._proxy:GetSelectedRole()

    if selectRole then
        self:SelectRole(selectRole.index, true)
    elseif #roles > 0 then
        self:SelectRole(1, true)
    else
        self:SelectRole(0, true)
    end

    if LoginRolePanel.UpdateRoles then
        LoginRolePanel.UpdateRoles()
    end
end

function LoginRoleLayer:SelectRole(index, isInit)
    if LoginRolePanel._index == index and not isInit then
        return false
    end
    local roles = self._proxy:GetRoles()
    if  roles[index] and ( roles[index].LockChar == 1 or roles[index].LockChar == 3) then
        if not isInit then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(600000166))
            return 
        else
            index =- 1
        end
    end

    self._proxy:SetSelectedRole(roles[index])

    if LoginRolePanel.SelectRole then
        LoginRolePanel.SelectRole(index, isInit)
    end
    
end

function LoginRoleLayer:DeleteRole(index)
    local roles = SL:GetMetaValue("LOGIN_DATA")
    if not index or not roles[index] then
        return
    end
    local roleInfo = roles[index]
    self._proxy:RequestDeleteRole(roleInfo.roleid)
end

function LoginRoleLayer:OnRandNameResp(name)
    if LoginRolePanel._CreateUI then
        self._isRandName = true
        GUI:Text_setString(LoginRolePanel._CreateUI.TextInput_name, name)
    end
end

-- 检查需要自动的按钮    needAutoBtnIndex: 自动按钮的下标(1: 开始  2: 创角提交)
function LoginRoleLayer:checkAutoButton(needAutoBtnIndex)
    if not needAutoBtnIndex then
        return
    end
    -- body
    local currentModule = global.L_ModuleManager:GetCurrentModule()
    local moduleGameEnv = currentModule:GetGameEnv()
    local loginData = moduleGameEnv:GetLoginData()
    local autoBoot = global.L_GameEnvManager:GetEnvDataByKey("isAutoBoot")

    if not autoBoot then
        return
    end

    -- 倒计时3s自动开始
    local btnData = self._auto_data[needAutoBtnIndex]
    if not btnData or not btnData.btn then
        return
    end

    self._need_auto_btn = needAutoBtnIndex
    local btn = btnData.btn
    local delay = btnData.delay or 20
    local function callback()
        if delay < 0 then
            self:terminateAutoButton()
            return
        end
        btn:setTitleText(string.format(btnData.delayStr or "", delay))
        delay = delay - 1
        if delay == 0 then
            if needAutoBtnIndex == 1 then
                self:RequestEnterGame()
            elseif needAutoBtnIndex == 2 then
                self:SendNewRoleSubmit()
            end
        end
    end

    btn:stopAllActions()
    schedule(btn, callback, 1)
    callback()

    self:touchTerminateAutoButton()
end

-- 停止需要自动的按钮    needAutoBtnIndex: 自动按钮的下标(1: 开始  2: 创角提交)
function LoginRoleLayer:terminateAutoButton()
    if not self._need_auto_btn then
        return
    end

    local needAutoBtnIndex = self._need_auto_btn
    self._need_auto_btn = nil

    local currentModule = global.L_ModuleManager:GetCurrentModule()
    local moduleGameEnv = currentModule:GetGameEnv()
    local autoBoot = global.L_GameEnvManager:GetEnvDataByKey("isAutoBoot")
    if not autoBoot then
        return
    end

    local btnData = self._auto_data[needAutoBtnIndex]
    if not btnData or not btnData.btn then
        return
    end
    local btn = btnData.btn
    btn:stopAllActions()
    btn:setTitleText(btnData.btnName or "")
end

-- 创建触摸层    用来停止自动按钮
function LoginRoleLayer:touchTerminateAutoButton()
    if self._tochAutoPanel then
        return
    end

    local panel = ccui.Layout:create()
    panel:setContentSize(global.Director:getVisibleSize())
    panel:setTouchEnabled(true)
    panel:setSwallowTouches(false)

    self:addChild(panel, 999)

    self._tochAutoPanel = panel

    panel:addClickEventListener(
        function()
            if self._need_auto_btn then
                self:terminateAutoButton()
            end
        end
    )
end

-- 上报心跳
function LoginRoleLayer:InitRequestHeartBeat()
    if global.L_NativeBridgeManager.PCCheckMedthodName and global.L_NativeBridgeManager:PCCheckMedthodName("GN_onHeartbeat") then
        AddGlobalScheduleFunc(
            "GN_requestHeartBeat",
            function()
                local data = {}
                local currModule = global.L_ModuleManager:GetCurrentModule()
                local AuthProxy = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)
                data.gameid = tostring(currModule:GetOperID())
                data.userId = tostring(AuthProxy:GetUID())
                global.L_NativeBridgeManager:GN_requestHeartBeat(data)
            end,
            10
        )
    end
end

return LoginRoleLayer
