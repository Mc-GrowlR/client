local BaseLayer = requireLayerUI("BaseLayer")
local LoginAccountLayer = class("LoginAccountLayer", BaseLayer)

local placeHolderColor = cc.Color3B.WHITE
local inputMaxLenteh   = 50

function CheckNeedRefreshShow(sender)
    if sender:getName() == "TextField_username" or sender:getName() == "TextField_phoneId" or sender:getName() == "TextField_password" or sender:getName() == "TextField_authcode" then
        local LoginAccountMediator = global.Facade:retrieveMediator( "LoginAccountMediator" )
        if LoginAccountMediator and LoginAccountMediator._layer and LoginAccountMediator._layer.RefreshLoginTouched then
            LoginAccountMediator._layer:RefreshLoginTouched()
        end
    end
end

local function inputLimitCB(sender, eventType)
    local input = sender:getString()

    -- 排除空格
    sender:setString(string.trim(input))

    -- 数字 字母 下划线 破折号
    sender:setString(string.gsub(input, "[^A-Za-z0-9_%-]", ""))

    CheckNeedRefreshShow(sender)
end

local function inputLimitNormalCB(sender, eventType)
    local input = sender:getString()

    -- 排除空格
    sender:setString(string.trim(input))
end

local function inputLimitNumberCB(sender, eventType)
    local input = sender:getString()

    -- 排除空格
    sender:setString(string.trim(input))

    -- 替换非字母数字
    sender:setString(string.gsub(input, "[^%d]", ""))

    CheckNeedRefreshShow(sender)
end

local function findNextEditBox(sender, inputList)
    local findIndex = 1
    for index, value in ipairs(inputList) do
        if sender == value then
            findIndex = index
            break
        end
    end

    if findIndex == #inputList then
        return inputList[1]
    end
    return inputList[findIndex+1]
end

local function commonInputCB(sender, eventType, inputList, exitCB)
    if eventType == 2 then
        local input = sender:getString()
        if not sender.closeKeyboard then
            return nil
        end

        if string.find(input, "\t") then
            sender:closeKeyboard()
            exitCB(sender, eventType)

            global._editBoxEditing = nil
            local nextEditBox = findNextEditBox(sender, inputList)
            nextEditBox:touchDownAction(nextEditBox, 2)

        elseif string.find(input, "\n") then
            sender:closeKeyboard()
            exitCB(sender, eventType)
        end
    end
end

function LoginAccountLayer:ctor()
    LoginAccountLayer.super.ctor(self)
    self._proxy             = global.Facade:retrieveProxy(global.ProxyTable.AuthProxy)

    self._requestDelay      = false
    self._isFetchAssets     = false
    self._isEditing         = false

    self._loginType         = 1
end

function LoginAccountLayer.create()
    local node = LoginAccountLayer.new()
    if node:Init() then
        return node
    end
    return nil
end

function LoginAccountLayer:Init()
    self.ui = ui_delegate(self)

    return true
end

function LoginAccountLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_LOGIN_ACCOUNT)
    LoginAccount.main()

    local visibleSize = global.Director:getVisibleSize()
    self.ui.Panel_bg:setContentSize(global.Director:getVisibleSize())
    self.ui.Panel_bg:setVisible(true)
    self.ui.Panel_bg:setPosition(visibleSize.width / 2, visibleSize.height / 2)

    -- 登录
    self.ui.Button_submit:addClickEventListener(function()
        if not self._isFetchAssets then
            return false
        end

        DelayTouchEnabled(self.ui.Button_submit, 1)
        self:RequestLogin()
    end)

    -- 注册
    self.ui.Button_register:addClickEventListener(function()
        if not self._isFetchAssets then
            return false
        end

        self:ShowRegister()
    end)

    -- 修改密保
    self.ui.Button_change_question:addClickEventListener(function()
        if not self._isFetchAssets then
            return false
        end

        self:ShowChangeQuestion()
    end)

    -- 修改密码
    self.ui.Button_change_password:addClickEventListener(function()
        if not self._isFetchAssets then
            return false
        end

        self:ShowChangePassword()
    end)

    -- 绑定手机
    self.ui.Button_bind_phone:addClickEventListener(function()
        if not self._isFetchAssets then
            return false
        end

        self:ShowBindPhone()
    end)

    -- 修改手机
    self.ui.Button_change_phone:addClickEventListener(function()
        if not self._isFetchAssets then
            return false
        end

        self:ShowChangePhone()
    end)

    -- 实名认证
    self.ui.Button_identify:addClickEventListener(function()
        if not self._isFetchAssets then
            return false
        end
        
        self:ShowIdentifyID()
    end)

    self.ui.Text_phone:addClickEventListener(function ()
        self._loginType = 2
        self:ChangeLoginPanelByType()
    end)

    self.ui.Text_account:addClickEventListener(function ()
        self._loginType = 1
        self:ChangeLoginPanelByType()
    end)

    self:initResolutionUI()

    self:InitLogin()
    self:InitLoginByPhone()
    self:InitAdapte()

    self:FillCurrent()
    self:ChangeLoginPanelByType()

    self:RefreshLoginTouched()

    self:InitIntroButton()
end

function LoginAccountLayer:HideAllExt()
    self._isEditing = false
    self.ui.Node_ext:removeAllChildren()
end

function LoginAccountLayer:OnEnterLogin(data)
    self._isFetchAssets = true
end

function LoginAccountLayer:handlePressedEnter()
    if not self._isFetchAssets then
        return false
    end
    if self._isEditing then
        return false
    end

    self:RequestLogin()
end

function LoginAccountLayer:InitAdapte()
    local visibleSize = global.Director:getVisibleSize()
    self.ui.Image_bg:setContentSize(visibleSize)
    self.ui.Image_bg:loadTexture(string.format(global.MMO.PATH_RES_PRIVATE .. "login/open_door/%02d.png", 0))
    self.ui.Image_bg:setPosition(visibleSize.width / 2, visibleSize.height / 2)
end

function LoginAccountLayer:RefreshLoginTouched( ... )
    local strUserName = self._loginType == 1 and self.ui.TextField_username:getString() or  self.ui.TextField_phoneId:getString()
    local strPassword = self._loginType == 1 and self.ui.TextField_password:getString() or self.ui.TextField_authcode:getString()

    if strUserName and string.len(strUserName) > 0 and strPassword and string.len( strPassword ) > 0 then
        self.ui.Button_submit:setTouchEnabled(true)
        self.ui.Button_submit:setBright(true)
    else
        self.ui.Button_submit:setTouchEnabled(false)
        self.ui.Button_submit:setBright(false)
    end
        
end

function LoginAccountLayer:InitLogin()
    local size = global.Director:getVisibleSize()
    self.ui.Panel_login:setPosition(cc.p(size.width/2, size.height/2))
    -- 输入框
    self.ui.TextField_username:setMaxLength(inputMaxLenteh)
    self.ui.TextField_password:setInputFlag(0)

    self.ui.TextField_username:setPlaceholderFontColor(placeHolderColor)
    self.ui.TextField_password:setPlaceholderFontColor(placeHolderColor)

    local inputList     = {}
    table.insert(inputList, self.ui.TextField_username)
    table.insert(inputList, self.ui.TextField_password)

    -- 输入不可以有空格
    local function accountInputCB(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitCB(sender, eventType)
        end
    end
    self.ui.TextField_username:addEventListener(accountInputCB)

    -- 密码不可以有空格
    local function passwordInputCB(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitCB(sender, eventType)
        end
    end
    self.ui.TextField_password:addEventListener(passwordInputCB)
end

function LoginAccountLayer:InitLoginByPhone( ... )
    -- 输入框
    self.ui.TextField_phoneId:setMaxLength(11)
    self.ui.TextField_authcode:setMaxLength(6)
    self.ui.TextField_phoneId:setInputFlag(3)
    self.ui.TextField_authcode:setInputFlag(3)

    self.ui.TextField_phoneId:setPlaceholderFontColor(placeHolderColor)
    self.ui.TextField_authcode:setPlaceholderFontColor(placeHolderColor)

    local inputList     = {}
    table.insert(inputList, self.ui.TextField_phoneId)
    table.insert(inputList, self.ui.TextField_authcode)

    -- 手机号
    local function InputCB(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNumberCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNumberCB(sender, eventType)
        end
    end
    self.ui.TextField_phoneId:addEventListener(InputCB)

    -- 验证码
    self.ui.TextField_authcode:addEventListener(InputCB)

    -- 获取验证码
    self.ui.Text_remaining:setVisible(false)
    self.ui.Button_authcode:addClickEventListener(function()
        local remaining = 60
        local function callback()
            self.ui.Text_remaining:setVisible(true)
            self.ui.Text_remaining:setString(remaining)

            remaining = remaining - 1
            if remaining == 0 then
                self.ui.Text_remaining:stopAllActions()
                self.ui.Text_remaining:setVisible(false)
                self.ui.Button_authcode:setTouchEnabled(true)
            end
        end
        self.ui.Button_authcode:setTouchEnabled(false)
        self.ui.Text_remaining:stopAllActions()
        schedule(self.ui.Text_remaining, callback, 1)
        callback()


        local phone     = self.ui.TextField_phoneId:getString()
        phone           = string.trim(phone)

        -- 手机号
        if string.len(phone) <= 0 or string.len(phone) ~= 11 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009058))
            return nil
        end

        self._proxy:RequestAuthCode(phone)
    end)
end

function LoginAccountLayer:ChangeLoginPanelByType()
    if self._loginType and self._loginType == 1 then
        self.ui.Panel_account:setVisible(true)
        self.ui.Panel_phone:setVisible(false)
        self.ui.Text_phone:setVisible(true)
        self.ui.Text_phone:setTouchEnabled(true)
        self.ui.Text_account:setVisible(false)
    elseif self._loginType and self._loginType == 2 then
        self.ui.Panel_account:setVisible(false)
        self.ui.Panel_phone:setVisible(true)
        self.ui.Text_phone:setVisible(false)
        self.ui.Text_account:setTouchEnabled(true)
        self.ui.Text_account:setVisible(true)
        self.ui.TextField_authcode:setString("")
    end

    self:RefreshLoginTouched()
end

function LoginAccountLayer:FillCurrent()
    local username = self._proxy:GetUsername()
    local password = self._proxy:GetPassword()

    if username and password then
        self.ui.TextField_username:setString(username)
        self.ui.TextField_password:setString(password)
    end

    self:RefreshLoginTouched()
end

function LoginAccountLayer:RequestLogin()
    if self._requestDelay then
        return false
    end
    self._requestDelay = true
    PerformWithDelayGlobal(function()
        self._requestDelay = false
    end,1)

    if self._loginType == 1 then
        local username =  self.ui.TextField_username:getString() 
        local password =  self.ui.TextField_password:getString() 
        username = string.trim(username)
        password = string.trim(password)
        if string.len(username) <= 0 or string.len(password) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009032) )
            return nil
        end

        -- 登录
        local data = {}
        data.type = self._loginType
        data.username = username
        data.password = password
        -- self._proxy:RequestLoginAdmin(data)
        self._proxy:RequestLogin(data)

    else
        --手机号登录
        local phoneId  =  self.ui.TextField_phoneId:getString()
        local authCode =  self.ui.TextField_authcode:getString()

        phoneId = string.trim(phoneId)
        authCode = string.trim(authCode)
        if string.len(phoneId) <= 0 or string.len(authCode) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips,  GET_STRING(30009078))
            return nil
        end

    
        local data = {}
        data.phoneId = phoneId
        data.authCode = authCode
        self._proxy:RequestLoginByPhone(data)

    end
end

----------------------------------------------------
--- 注册
function LoginAccountLayer:ShowRegister()
    self._isEditing = true

    GUI:LoadExport(self.ui.Node_ext, "login_account/login_account_register")
    local ui = ui_delegate(self.ui.Node_ext)

    local visibleSize = global.Director:getVisibleSize()
    ui.Panel_bg:setPosition(visibleSize.width / 2, visibleSize.height / 2)

    -- 关闭
    ui.Button_close:addClickEventListener(function()
        self:HideAllExt()
    end)

    -- 输入框
    ui.TextField_username:setMaxLength(inputMaxLenteh)
    ui.TextField_password:setMaxLength(inputMaxLenteh)
    ui.TextField_password_confirm:setMaxLength(inputMaxLenteh)
    ui.TextField_question:setMaxLength(inputMaxLenteh)
    ui.TextField_answer:setMaxLength(inputMaxLenteh)

    ui.TextField_username:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_password:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_password_confirm:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_question:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_answer:setPlaceholderFontColor(placeHolderColor)

    ui.TextField_password:setInputFlag(0)
    ui.TextField_password_confirm:setInputFlag(0)

    local inputList     = {}
    table.insert(inputList, ui.TextField_username)
    table.insert(inputList, ui.TextField_password)
    table.insert(inputList, ui.TextField_password_confirm)
    table.insert(inputList, ui.TextField_question)
    table.insert(inputList, ui.TextField_answer)

    -- 账号
    ui.TextField_username:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitCB(sender, eventType)
        end
    end)

    -- 密码
    ui.TextField_password:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitCB(sender, eventType)
        end
    end)

    -- 确认密码
    ui.TextField_password_confirm:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitCB(sender, eventType)
        end
    end)

    -- 密保问题
    ui.TextField_question:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNormalCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNormalCB(sender, eventType)
        end
    end)

    -- 密保答案
    ui.TextField_answer:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNormalCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNormalCB(sender, eventType)
        end
    end)

    -- 请求注册
    ui.Button_submit:addClickEventListener(function()
        DelayTouchEnabled(ui.Button_submit, 1)

        local username  = ui.TextField_username:getString()
        local password  = ui.TextField_password:getString()
        local passwordC = ui.TextField_password_confirm:getString()
        local question  = ui.TextField_question:getString()
        local answer    = ui.TextField_answer:getString()
        username  = string.trim(username)
        password  = string.trim(password)
        passwordC = string.trim(passwordC)
        -- 输入为空
        if string.len(username) <= 0 or string.len(password) <= 0 or string.len(passwordC) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009032))
            return nil
        end
        -- 密码和确认密码不同
        if passwordC ~= password then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009047))
            return nil
        end
        -- 密保问题为空
        if string.len(question) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009056))
            return nil
        end
        -- 密保答案为空
        if string.len(answer) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009057))
            return nil
        end

        if CheckPasswordIsSimple(password, username) then
            ShowSystemTips(GET_STRING(700000100))
            return
        end

        -- 登录
        local data = {}
        data.type = 1
        data.username   = username
        data.password   = password
        data.question   = question
        data.answer     = answer
        self._proxy:RequestRegister(data)
    end)
end

function LoginAccountLayer:OnAuthRegisterSuccess()
    ShowSystemTips("注册成功")

    self:HideAllExt()
    self:FillCurrent()
end

----------------------------------------------------
--- 修改密保
function LoginAccountLayer:ShowChangeQuestion()
    self._isEditing = true

    GUI:LoadExport(self.ui.Node_ext, "login_account/login_account_change_question")
    local ui = ui_delegate(self.ui.Node_ext)

    local visibleSize = global.Director:getVisibleSize()
    ui.Panel_bg:setPosition(visibleSize.width / 2, visibleSize.height / 2)

    -- 关闭
    ui.Button_close:addClickEventListener(function()
        self:HideAllExt()
    end)

    -- 输入框
    ui.TextField_username:setMaxLength(inputMaxLenteh)
    ui.TextField_password:setMaxLength(inputMaxLenteh)
    ui.TextField_question:setMaxLength(inputMaxLenteh)
    ui.TextField_answer:setMaxLength(inputMaxLenteh)
    ui.TextField_question_new:setMaxLength(inputMaxLenteh)
    ui.TextField_answer_new:setMaxLength(inputMaxLenteh)

    ui.TextField_username:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_password:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_question:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_answer:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_question_new:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_answer_new:setPlaceholderFontColor(placeHolderColor)
    
    ui.TextField_password:setInputFlag(0)

    local inputList     = {}
    table.insert(inputList, ui.TextField_username)
    table.insert(inputList, ui.TextField_password)
    table.insert(inputList, ui.TextField_question)
    table.insert(inputList, ui.TextField_answer)
    table.insert(inputList, ui.TextField_question_new)
    table.insert(inputList, ui.TextField_answer_new)

    -- 账号
    local username = self._proxy:GetUsername()
    ui.TextField_username:setString(username)
    ui.TextField_username:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitCB(sender, eventType)
        end
    end)

    -- 密码
    local password = self._proxy:GetPassword()
    ui.TextField_password:setString(password)
    ui.TextField_password:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitCB(sender, eventType)
        end
    end)

    -- 原密保问题
    ui.TextField_question:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNormalCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNormalCB(sender, eventType)
        end
    end)

    -- 原密保答案
    ui.TextField_answer:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNormalCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNormalCB(sender, eventType)
        end
    end)

    -- 新密保问题
    ui.TextField_question_new:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNormalCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNormalCB(sender, eventType)
        end
    end)

    -- 新密保答案
    ui.TextField_answer_new:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNormalCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNormalCB(sender, eventType)
        end
    end)

    -- 
    ui.Button_submit:addClickEventListener(function()
        DelayTouchEnabled(ui.Button_submit, 1)

        local username  = ui.TextField_username:getString()
        local password  = ui.TextField_password:getString()
        local question  = ui.TextField_question:getString()
        local answer    = ui.TextField_answer:getString()
        local questionN = ui.TextField_question_new:getString()
        local answerN   = ui.TextField_answer_new:getString()
        username        = string.trim(username)
        password        = string.trim(password)
        question        = string.trim(question)
        answer          = string.trim(answer)
        questionN       = string.trim(questionN)
        answerN         = string.trim(answerN)
        -- 输入为空
        if string.len(username) <= 0 or string.len(password) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009032))
            return nil
        end
        -- 密保问题为空
        if string.len(question) <= 0 or string.len(questionN) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009056))
            return nil
        end
        -- 密保答案为空
        if string.len(answer) <= 0 or string.len(answerN) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009057))
            return nil
        end

        -- 修改密保
        local data = {}
        data.username       = username
        data.password       = password
        data.question       = question
        data.answer         = answer
        data.question_new   = questionN
        data.answer_new     = answerN
        self._proxy:RequestChangeMb(data)
    end)
end

function LoginAccountLayer:OnAuthChangeMbResp()
    self:HideAllExt()
    self:FillCurrent()
end

----------------------------------------------------
--- 修改密码
function LoginAccountLayer:ShowChangePassword()
    self._isEditing = true

    GUI:LoadExport(self.ui.Node_ext, "login_account/login_account_change_pwd")
    local ui = ui_delegate(self.ui.Node_ext)

    local visibleSize = global.Director:getVisibleSize()
    ui.Panel_bg:setPosition(visibleSize.width / 2, visibleSize.height / 2)

    -- 关闭
    ui.Button_close:addClickEventListener(function()
        self:HideAllExt()
    end)

    -- 切换
    ui.Text_change:addClickEventListener(function()
        self:HideAllExt()
        self:ShowChangePasswordByPhone()
    end)
    
    -- 输入框
    ui.TextField_username:setMaxLength(inputMaxLenteh)
    ui.TextField_question:setMaxLength(inputMaxLenteh)
    ui.TextField_answer:setMaxLength(inputMaxLenteh)
    ui.TextField_password:setMaxLength(inputMaxLenteh)

    ui.TextField_username:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_question:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_answer:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_password:setPlaceholderFontColor(placeHolderColor)
    
    ui.TextField_password:setInputFlag(0)

    local inputList     = {}
    table.insert(inputList, ui.TextField_username)
    table.insert(inputList, ui.TextField_question)
    table.insert(inputList, ui.TextField_answer)
    table.insert(inputList, ui.TextField_password)

    -- 账号
    local username = self._proxy:GetUsername()
    ui.TextField_username:setString(username)
    ui.TextField_username:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitCB(sender, eventType)
        end
    end)

    -- 密保问题
    ui.TextField_question:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNormalCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNormalCB(sender, eventType)
        end
    end)

    -- 密保答案
    ui.TextField_answer:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNormalCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNormalCB(sender, eventType)
        end
    end)

    -- 密码
    ui.TextField_password:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitCB(sender, eventType)
        end
    end)

    -- 
    ui.Button_submit:addClickEventListener(function()
        DelayTouchEnabled(ui.Button_submit, 1)

        local username  = ui.TextField_username:getString()
        local question  = ui.TextField_question:getString()
        local answer    = ui.TextField_answer:getString()
        local password  = ui.TextField_password:getString()
        username        = string.trim(username)
        password        = string.trim(password)
        question        = string.trim(question)
        answer          = string.trim(answer)
        -- 输入为空
        if string.len(username) <= 0 or string.len(password) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009032))
            return nil
        end
        -- 密保问题为空
        if string.len(question) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009056))
            return nil
        end
        -- 密保答案为空
        if string.len(answer) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009057))
            return nil
        end

        if CheckPasswordIsSimple(password, username) then
            ShowSystemTips(GET_STRING(700000100))
            return
        end

        -- 改密码
        local data = {}
        data.username       = username
        data.question       = question
        data.answer         = answer
        data.newpassword    = password
        self._proxy:RequestChangePwdByMb(data)
    end)
end

function LoginAccountLayer:OnAuthChangePwdResp()
    self:HideAllExt()
    self:FillCurrent()
end


----------------------------------------------------
--- 修改密码 手机
function LoginAccountLayer:ShowChangePasswordByPhone()
    self._isEditing = true

    GUI:LoadExport(self.ui.Node_ext, "login_account/login_account_change_pwd_by_phone")
    local ui = ui_delegate(self.ui.Node_ext)

    local visibleSize = global.Director:getVisibleSize()
    ui.Panel_bg:setPosition(visibleSize.width / 2, visibleSize.height / 2)

    -- 关闭
    ui.Button_close:addClickEventListener(function()
        self:HideAllExt()
    end)

    -- 切换
    ui.Text_change:addClickEventListener(function()
        self:HideAllExt()
        self:ShowChangePassword()
    end)

    -- 输入框
    ui.TextField_username:setMaxLength(inputMaxLenteh)
    ui.TextField_phone:setMaxLength(11)
    ui.TextField_authcode:setMaxLength(6)
    ui.TextField_password:setMaxLength(inputMaxLenteh)

    ui.TextField_username:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_phone:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_authcode:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_password:setPlaceholderFontColor(placeHolderColor)
    
    ui.TextField_phone:setInputMode(3)
    ui.TextField_authcode:setInputMode(3)
    ui.TextField_password:setInputFlag(0)

    local inputList     = {}
    table.insert(inputList, ui.TextField_username)
    table.insert(inputList, ui.TextField_phone)
    table.insert(inputList, ui.TextField_authcode)
    table.insert(inputList, ui.TextField_password)

    -- 账号
    local username = self._proxy:GetUsername()
    ui.TextField_username:setString(username)
    ui.TextField_username:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitCB(sender, eventType)
        end
    end)

    -- 手机号
    ui.TextField_phone:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNumberCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNumberCB(sender, eventType)
        end
    end)

    -- 验证码
    ui.TextField_authcode:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNumberCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNumberCB(sender, eventType)
        end
    end)

    -- 密码
    ui.TextField_password:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitCB(sender, eventType)
        end
    end)

    -- 获取验证码
    ui.Text_remaining:setVisible(false)
    ui.Button_authcode:addClickEventListener(function()
        local remaining = 60
        local function callback()
            ui.Text_remaining:setVisible(true)
            ui.Text_remaining:setString(remaining)

            remaining = remaining - 1
            if remaining == 0 then
                ui.Text_remaining:stopAllActions()
                ui.Text_remaining:setVisible(false)
                ui.Button_authcode:setTouchEnabled(true)
            end
        end
        ui.Button_authcode:setTouchEnabled(false)
        ui.Text_remaining:stopAllActions()
        schedule(ui.Text_remaining, callback, 1)
        callback()


        local phone     = ui.TextField_phone:getString()
        phone           = string.trim(phone)

        -- 手机号
        if string.len(phone) <= 0 or string.len(phone) ~= 11 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009058))
            return nil
        end

        self._proxy:RequestAuthCode(phone)
    end)

    -- 
    ui.Button_submit:addClickEventListener(function()
        DelayTouchEnabled(ui.Button_submit, 1)

        local username      = ui.TextField_username:getString()
        local phone         = ui.TextField_phone:getString()
        local authcode      = ui.TextField_authcode:getString()
        local newpassword   = ui.TextField_password:getString()
        username            = string.trim(username)
        phone               = string.trim(phone)
        authcode            = string.trim(authcode)
        newpassword         = string.trim(newpassword)
        -- 输入为空
        if string.len(username) <= 0 or string.len(newpassword) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009032))
            return nil
        end
        -- 手机号
        if string.len(phone) <= 0 or string.len(phone) ~= 11 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009058))
            return nil
        end
        -- 验证码
        if string.len(authcode) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009059))
            return nil
        end

        if CheckPasswordIsSimple(newpassword, username) then
            ShowSystemTips(GET_STRING(700000100))
            return
        end

        -- 换手机号
        local data = {}
        data.username       = username
        data.newpassword    = newpassword
        data.phone          = phone
        data.code           = authcode
        dump(data)
        self._proxy:RequestChangePwdByPhone(data)
    end)
end

function LoginAccountLayer:OnAuthChangePwdByPhoneResp()
    self:HideAllExt()
    self:FillCurrent()
end

----------------------------------------------------
--- 绑定手机
function LoginAccountLayer:ShowBindPhone()
    self._isEditing = true

    GUI:LoadExport(self.ui.Node_ext, "login_account/login_account_bind_phone")
    local ui = ui_delegate(self.ui.Node_ext)

    local visibleSize = global.Director:getVisibleSize()
    ui.Panel_bg:setPosition(visibleSize.width / 2, visibleSize.height / 2)

    -- 关闭
    ui.Button_close:addClickEventListener(function()
        self:HideAllExt()
    end)

    -- 输入框
    ui.TextField_username:setMaxLength(inputMaxLenteh)
    ui.TextField_question:setMaxLength(inputMaxLenteh)
    ui.TextField_answer:setMaxLength(inputMaxLenteh)
    ui.TextField_phone:setMaxLength(11)
    ui.TextField_authcode:setMaxLength(6)

    ui.TextField_username:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_question:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_answer:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_phone:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_authcode:setPlaceholderFontColor(placeHolderColor)
    
    ui.TextField_phone:setInputMode(3)
    ui.TextField_authcode:setInputMode(3)

    local inputList     = {}
    table.insert(inputList, ui.TextField_username)
    table.insert(inputList, ui.TextField_question)
    table.insert(inputList, ui.TextField_answer)
    table.insert(inputList, ui.TextField_phone)
    table.insert(inputList, ui.TextField_authcode)

    -- 账号
    local username = self._proxy:GetUsername()
    ui.TextField_username:setString(username)
    ui.TextField_username:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitCB(sender, eventType)
        end
    end)

    -- 密保问题
    ui.TextField_question:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNormalCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNormalCB(sender, eventType)
        end
    end)

    -- 密保答案
    ui.TextField_answer:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNormalCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNormalCB(sender, eventType)
        end
    end)

    -- 手机号
    ui.TextField_phone:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNumberCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNumberCB(sender, eventType)
        end
    end)

    -- 验证码
    ui.TextField_authcode:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNumberCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNumberCB(sender, eventType)
        end
    end)
    
    -- 获取验证码
    ui.Text_remaining:setVisible(false)
    ui.Button_authcode:addClickEventListener(function()
        local remaining = 60
        local function callback()
            ui.Text_remaining:setVisible(true)
            ui.Text_remaining:setString(remaining)

            remaining = remaining - 1
            if remaining == 0 then
                ui.Text_remaining:stopAllActions()
                ui.Text_remaining:setVisible(false)
                ui.Button_authcode:setTouchEnabled(true)
            end
        end
        ui.Button_authcode:setTouchEnabled(false)
        ui.Text_remaining:stopAllActions()
        schedule(ui.Text_remaining, callback, 1)
        callback()

        local phone     = ui.TextField_phone:getString()
        phone           = string.trim(phone)

        -- 手机号
        if string.len(phone) <= 0 or string.len(phone) ~= 11 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009058))
            return nil
        end

        self._proxy:RequestAuthCode(phone)
    end)


    -- 
    ui.Button_submit:addClickEventListener(function()
        DelayTouchEnabled(ui.Button_submit, 1)

        local username  = ui.TextField_username:getString()
        local question  = ui.TextField_question:getString()
        local answer    = ui.TextField_answer:getString()
        local phone     = ui.TextField_phone:getString()
        local authcode  = ui.TextField_authcode:getString()
        username        = string.trim(username)
        question        = string.trim(question)
        answer          = string.trim(answer)
        phone           = string.trim(phone)
        authcode        = string.trim(authcode)

        -- 输入为空
        if string.len(username) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009032))
            return nil
        end
        -- 密保问题为空
        if string.len(question) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009056))
            return nil
        end
        -- 密保答案为空
        if string.len(answer) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009057))
            return nil
        end
        -- 手机号
        if string.len(phone) <= 0 or string.len(phone) ~= 11 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009058))
            return nil
        end
        -- 验证码
        if string.len(authcode) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009059))
            return nil
        end

        -- 绑定手机号
        local data = {}
        data.username   = username
        data.question   = question
        data.answer     = answer
        data.phone      = phone
        data.code       = authcode
        self._proxy:RequestBindPhoneByMb(data)
    end)
end

function LoginAccountLayer:OnAuthBindPhoneResp()
    self:HideAllExt()
end

----------------------------------------------------
--- 换绑手机
function LoginAccountLayer:ShowChangePhone()
    self._isEditing = true

    GUI:LoadExport(self.ui.Node_ext, "login_account/login_account_change_phone")
    local ui = ui_delegate(self.ui.Node_ext)

    local visibleSize = global.Director:getVisibleSize()
    ui.Panel_bg:setPosition(visibleSize.width / 2, visibleSize.height /2)

    -- 关闭
    ui.Button_close:addClickEventListener(function()
        self:HideAllExt()
    end)

    -- 输入框
    ui.TextField_username:setMaxLength(inputMaxLenteh)
    ui.TextField_phone:setMaxLength(11)
    ui.TextField_authcode:setMaxLength(6)
    ui.TextField_phone_new:setMaxLength(11)
    ui.TextField_authcode_new:setMaxLength(6)

    ui.TextField_username:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_phone:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_authcode:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_phone_new:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_authcode_new:setPlaceholderFontColor(placeHolderColor)
    
    ui.TextField_phone:setInputMode(3)
    ui.TextField_authcode:setInputMode(3)
    ui.TextField_phone_new:setInputMode(3)
    ui.TextField_authcode_new:setInputMode(3)

    local inputList     = {}
    table.insert(inputList, ui.TextField_username)
    table.insert(inputList, ui.TextField_phone)
    table.insert(inputList, ui.TextField_authcode)
    table.insert(inputList, ui.TextField_phone_new)
    table.insert(inputList, ui.TextField_authcode_new)

    -- 账号
    local username = self._proxy:GetUsername()
    ui.TextField_username:setString(username)
    ui.TextField_username:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitCB(sender, eventType)
        end
    end)

    -- 手机号
    ui.TextField_phone:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNumberCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNumberCB(sender, eventType)
        end
    end)

    -- 验证码
    ui.TextField_authcode:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNumberCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNumberCB(sender, eventType)
        end
    end)

    -- 手机号 新
    ui.TextField_phone_new:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNumberCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNumberCB(sender, eventType)
        end
    end)

    -- 验证码 新
    ui.TextField_authcode_new:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNumberCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNumberCB(sender, eventType)
        end
    end)
    
    -- 获取验证码
    ui.Text_remaining:setVisible(false)
    ui.Button_authcode:addClickEventListener(function()
        local remaining = 60
        local function callback()
            ui.Text_remaining:setVisible(true)
            ui.Text_remaining:setString(remaining)

            remaining = remaining - 1
            if remaining == 0 then
                ui.Text_remaining:stopAllActions()
                ui.Text_remaining:setVisible(false)
                ui.Button_authcode:setTouchEnabled(true)
            end
        end
        ui.Button_authcode:setTouchEnabled(false)
        ui.Text_remaining:stopAllActions()
        schedule(ui.Text_remaining, callback, 1)
        callback()


        local phone     = ui.TextField_phone:getString()
        phone           = string.trim(phone)

        -- 手机号
        if string.len(phone) <= 0 or string.len(phone) ~= 11 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009058))
            return nil
        end

        self._proxy:RequestAuthCode(phone)
    end)

    -- 获取验证码 新
    ui.Text_remaining_new:setVisible(false)
    ui.Button_authcode_new:addClickEventListener(function()
        local remaining = 60
        local function callback()
            ui.Text_remaining_new:setVisible(true)
            ui.Text_remaining_new:setString(remaining)

            remaining = remaining - 1
            if remaining == 0 then
                ui.Text_remaining_new:stopAllActions()
                ui.Text_remaining_new:setVisible(false)
                ui.Button_authcode_new:setTouchEnabled(true)
            end
        end
        ui.Button_authcode_new:setTouchEnabled(false)
        ui.Text_remaining_new:stopAllActions()
        schedule(ui.Text_remaining_new, callback, 1)
        callback()

        local phone     = ui.TextField_phone_new:getString()
        phone           = string.trim(phone)

        -- 手机号
        if string.len(phone) <= 0 or string.len(phone) ~= 11 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009058))
            return nil
        end

        self._proxy:RequestAuthCode(phone)
    end)


    -- 
    ui.Button_submit:addClickEventListener(function()
        DelayTouchEnabled(ui.Button_submit, 1)

        local username  = ui.TextField_username:getString()
        local phone     = ui.TextField_phone:getString()
        local authcode  = ui.TextField_authcode:getString()
        local phoneN    = ui.TextField_phone_new:getString()
        local authcodeN = ui.TextField_authcode_new:getString()
        username        = string.trim(username)
        phone           = string.trim(phone)
        authcode        = string.trim(authcode)
        phoneN          = string.trim(phoneN)
        authcodeN       = string.trim(authcodeN)
        -- 输入为空
        if string.len(username) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009060))
            return nil
        end
        -- 手机号
        if string.len(phone) <= 0 or string.len(phone) ~= 11 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009058))
            return nil
        end
        -- 验证码
        if string.len(authcode) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009059))
            return nil
        end
        -- 手机号 新
        if string.len(phoneN) <= 0 or string.len(phone) ~= 11 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009058))
            return nil
        end
        -- 验证码 新
        if string.len(authcodeN) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009059))
            return nil
        end
    
        -- 换手机号
        local data = {}
        data.username   = username
        data.phone      = phone
        data.code       = authcode
        data.phone_new  = phoneN
        data.code_new   = authcodeN
        self._proxy:RequestChangePhone(data)
    end)
end



function LoginAccountLayer:ShowIdentifyID(cannotClose)
    self._isEditing = true

    GUI:LoadExport(self.ui.Node_ext, "login_account/login_account_identify")
    local ui = ui_delegate(self.ui.Node_ext)

    local visibleSize = global.Director:getVisibleSize()
    ui.Panel_bg:setPosition(visibleSize.width / 2, visibleSize.height / 2)

    -- 关闭
    ui.Button_close:addClickEventListener(function()
        self:HideAllExt()
    end)
    if cannotClose then
        ui.Button_close:setVisible(not cannotClose)
    end

    -- 输入框
    ui.TextField_name:setMaxLength(15)
    ui.TextField_IDnumber:setMaxLength(18)

    ui.TextField_name:setPlaceholderFontColor(placeHolderColor)
    ui.TextField_IDnumber:setPlaceholderFontColor(placeHolderColor)

    local inputList     = {}
    table.insert(inputList, ui.TextField_name)
    table.insert(inputList, ui.TextField_IDnumber)

    -- 姓名
    -- local username = self._proxy:GetUsername()
    -- ui.TextField_name:setString(username)
    ui.TextField_name:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitNormalCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitNormalCB(sender, eventType)
        end
    end)

    -- 身份证号
    ui.TextField_IDnumber:addEventListener(function(sender, eventType)
        commonInputCB(sender, eventType, inputList, inputLimitCB)

        if eventType == 1 or eventType == 3 or eventType == 4 then
            inputLimitCB(sender, eventType)
        end
    end)


    -- 
    ui.Button_submit:addClickEventListener(function()
        DelayTouchEnabled(ui.Button_submit, 1)

        local name      = ui.TextField_name:getString()
        local IDNumber  = ui.TextField_IDnumber:getString()
        name            = string.trim(name)
        IDNumber        = string.trim(IDNumber)
       
        -- 输入为空
        if string.len(name) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009077))
            return nil
        end
        -- 身份证号
        if string.len(IDNumber) <= 0 or string.len(IDNumber) ~= 18 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30009076))
            return nil
        end

        local data = {}
        data.name       = name
        data.IDNumber   = IDNumber
        self._proxy:RequestIdentifyID(data)
    end)
end

----------------------------------------------------
-- 分辨率
function LoginAccountLayer:initResolutionUI()
    GUI:LoadExport(self.ui.Panel_bg, "login_resolution")
    local ui = self.ui.Panel_bg:getChildByName("Panel_resolution")
    if not ui then
        return false
    end

    if not SL._DEBUG then
        ui:setVisible(false)
        return false
    end

    ui:setVisible(true)

    IterAllChild(ui, ui)

    local visibleSize = global.Director:getVisibleSize()
    ui:setPosition(cc.p(visibleSize.width-270, visibleSize.height-200))

    local size   = global.DesignSize_Win
    local width  = size.width
    local height = size.height

    ui["TextField_width"]:setString(width)
    ui["TextField_height"]:setString(height)

    local TextField_width  = ui["TextField_width"]
    local TextField_height = ui["TextField_height"]
    TextField_width:setInputMode(2)
    TextField_height:setInputMode(2)

    local function onChangeEdit(ref, eventType)
        local str = ref:getString()
        local default = ref:getName() == "TextField_height" and height or width

        if eventType == 1 then
            str = string.trim(str)
            str = tonumber(str) or default
            if str < 0 then
                str = default
            end
            ref:setString(str)
        elseif eventType == 2 then
            if ref.closeKeyboard and string.find(str, "\n") then
                ref:closeKeyboard()
            end
        end
    end

    TextField_width:addEventListener(function (ref, eventType)
        onChangeEdit(ref, eventType)
    end)

    TextField_height:addEventListener(function (ref, eventType)
        onChangeEdit(ref, eventType)
    end)

    local function onChangeResolution(isRest)
        if isRest then
            local userData = UserData:new("phone_mode_device")
            local cjson    = require("cjson")
            local key      = global.isWinPlayMode and "pc" or "phone"
            userData:setStringForKey(key, nil)
            userData:writeMapDataToFile()
            SL:ExitToLoginUI()
        else
            local _width  = tonumber(TextField_width:getString())
            local _height = tonumber(TextField_height:getString())
            if _width ~= global.DesignSize_Win.width or _height ~= global.DesignSize_Win.height then
                local userData = UserData:new("phone_mode_device")
                local cjson    = require("cjson")
                local key      = global.isWinPlayMode and "pc" or "phone"
                local value    = cjson.encode({width = _width, height = _height})
                userData:setStringForKey(key, value)
                userData:writeMapDataToFile()
                SL:ExitToLoginUI()
            end
        end
    end

    ui["btnOk"]:addClickEventListener(function ()
        onChangeResolution()
    end)

    ui["btnReset"]:addClickEventListener(function ()
        onChangeResolution(true)
    end)
end

-- 说明书
function LoginAccountLayer:InitIntroButton()
    if global.isDebugMode or global.isGMMode then
        local visibleSize = global.Director:getVisibleSize()
        local buttonIntro = ccui.Button:create()
        self.ui.Panel_bg:addChild(buttonIntro)
        buttonIntro:setPosition(cc.p(visibleSize.width - 90, visibleSize.height - 220))
        buttonIntro:loadTextureNormal("res/public/1900001022.png", 0)
        buttonIntro:loadTexturePressed("res/public/1900001023.png", 0)
        buttonIntro:setTitleFontName(global.MMO.PATH_FONT)
        buttonIntro:setTitleFontSize(16)
        buttonIntro:setTitleText("说明书")
        buttonIntro:setTitleColor(cc.c3b(248, 230, 198))
        buttonIntro:getTitleRenderer():enableOutline(cc.c3b(17, 17, 17), 2)
        buttonIntro:setTouchEnabled(true)
        buttonIntro:addClickEventListener(function()
            local url = "http://engine-doc.996m2.com/web/#/22/1351"
            cc.Application:getInstance():openURL(url)
        end)
    end
end

return LoginAccountLayer
