local UserInputController = class('UserInputController', framework.Mediator)
UserInputController.NAME = "UserInputController"

local sformat = string.format
local DEBUG_TOUCH = false

local function compareKeyCode(k1, k2, checkFullSort)
    if checkFullSort then
        if #k1 == #k2 then
            for i = 1, #k1 do
                local keyCode = k1[i]
                local isEqual = false
                for j = 1, #k2 do
                    if keyCode == k2[j] then
                        isEqual = true
                        break
                    end
                end
                if not isEqual then
                    return false
                end
            end
            return true
        else
            return false
        end
    end
    return (table.concat(k1, "+") == table.concat(k2, "+"))
end

function UserInputController:ctor()
    UserInputController.super.ctor(self, self.NAME)
    
    self._keyboardListener  = nil
    self._keyboardEvents    = {}
    self._keyboardAble      = true
    self._isPressedShift    = false
    self._isPressedCtrl     = false
    self._isPressedAlt      = false

    self._cursorPosition    = {x=0,y=0}
    self._touchListener     = nil
    self._touching          = false
end

function UserInputController:destory()
    if UserInputController.instance then
        global.Facade:removeMediator(UserInputController.NAME)
        UserInputController.instance = nil
    end
end

function UserInputController:Inst()
    if not UserInputController.instance then
        UserInputController.instance = UserInputController.new()
        global.Facade:registerMediator(UserInputController.instance)
    end

    return UserInputController.instance
end

function UserInputController:onRegister()
    UserInputController.super.onRegister(self)
end

function UserInputController:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return
        {
            noticeTable.Layer_Moved_Moving,
            noticeTable.PlayerBeDamaged,
            noticeTable.MainPlayerActionBegan,
        }
end

function UserInputController:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeID == noticeTable.Layer_Moved_Moving then
        self:OnMouseMoved(data)
    elseif noticeID == noticeTable.PlayerBeDamaged then
        self:OnPlayerBeDamaged()
    elseif noticeID == noticeTable.MainPlayerActionBegan then
        self:OnMainPlayerActionBegan(data)
    end
end

function UserInputController:InitOnEnterLogin()
    self:ResetKeyboard()
    self:InitKeyCodeLogin()
end

function UserInputController:InitOnEnterRole()
    self:ResetKeyboard()
    self:InitKeyCodeLogin()
end

function UserInputController:InitOnEnterWorld()
    self:ResetKeyboard()
    self:InitKeyCodeWorld()

    self:ResetTouch()
    self:InitTouch()
end

-------------------------------------------------------------------------------
function UserInputController:isTouching()
    return self._touching
end

function UserInputController:setIsTouching(t)
    self._touching = t
end

function UserInputController:isKeyboardAble()
    return self._keyboardAble
end

function UserInputController:setKeyboardAble(able)
    self._keyboardAble = able
end
-------------------------------------------------------------------------------

----------------------------------- listener ----------------------------------
function UserInputController:onEventUserInput()
    global.Facade:sendNotification(global.NoticeTable.UserInputEventNotice)
end
----------------------------------- listener ----------------------------------


----------------------------------- keycode -----------------------------------
function UserInputController:IsPressedShift()
    return self._isPressedShift
end

function UserInputController:IsPressedCtrl()
    return self._isPressedCtrl
end

function UserInputController:IsPressedAlt()
    return self._isPressedAlt
end

function UserInputController:ResetKeyboard()
    if not self._keyboardListener then
        return
    end
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:removeEventListener(self._keyboardListener)

    self._keyboardEvents    = {}
    self._keyboardListener  = nil
    self._keyboardAble      = true
    self._isPressedShift    = false
    self._isPressedCtrl     = false
    self._isPressedAlt      = false
end

function UserInputController:InitKeyboardListener()
    local inputKeyCode = {}
    local function onEventPressedCB()
        if not self._keyboardAble then
            return
        end

        global.userInputController:onEventUserInput()

        local count = #self._keyboardEvents
        for i = count, 1, -1 do
            local v = self._keyboardEvents[i]
            if compareKeyCode(inputKeyCode, v.keyCode, v.checkFullSort) then
                if v.pressedCB then
                    v.pressedCB()
                end

                -- auto event perssed callback
                if v.interval and v.interval > 0 then
                    if nil == v.timerID then
                        v.timerID = Schedule(function()
                            global.userInputController:onEventUserInput()

                            if v.pressedCB then
                                v.pressedCB(true)
                            end
                        end, v.interval)
                    end
                end

                break
            end
        end
    end

    local function onEventReleaseCB(keycode)
        global.userInputController:onEventUserInput()

        -- 
        for _, v in ipairs(self._keyboardEvents) do
            if v.timerID then
                UnSchedule(v.timerID)
                v.timerID = nil
            end
        end

        -- releaseCB
        local count = #self._keyboardEvents
        for i = count, 1, -1 do
            local v = self._keyboardEvents[i]
            if compareKeyCode({keycode}, v.keyCode) then
                if v.releaseCB then
                    v.releaseCB()
                end
                break
            end
        end
    end

    local function pressed_callback(keycode, evt)
        table.insert(inputKeyCode, keycode)
        onEventPressedCB()
    end
    local function released_callback(keycode, evt)
        for k, v in pairs(inputKeyCode) do
            if v == keycode then
                table.remove(inputKeyCode, k)
            end
        end
        onEventReleaseCB(keycode)
    end
    self._keyboardListener = cc.EventListenerKeyboard:create()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    self._keyboardListener:registerScriptHandler(pressed_callback, cc.Handler.EVENT_KEYBOARD_PRESSED)
    self._keyboardListener:registerScriptHandler(released_callback, cc.Handler.EVENT_KEYBOARD_RELEASED)
    eventDispatcher:addEventListenerWithFixedPriority(self._keyboardListener, 1)
end

function UserInputController:addKeyboardListener(keyCode, pressedCB, releaseCB, interval, checkFullSort)
    interval = interval or 1
    if not keyCode then
        print("ERROR++++++++++++++++++++++++, keyCode is empty")
        return
    end
    if type(keyCode) == "number" then
        local t = {}
        table.insert(t, keyCode)
        keyCode = t
    end
    local listener      = {}
    listener.keyCode    = keyCode
    listener.pressedCB  = pressedCB
    listener.releaseCB  = releaseCB
    listener.interval   = interval
    listener.checkFullSort = checkFullSort
    table.insert(self._keyboardEvents, listener)
end

function UserInputController:rmvKeyboardListener(keyCode)
    if type(keyCode) == "number" then
        local t = {}
        table.insert(t, keyCode)
        keyCode = t
    end

    local count = #self._keyboardEvents
    for i = count, 1, -1 do
        local v = self._keyboardEvents[i]
        if compareKeyCode(v.keyCode, keyCode) then
            table.remove(self._keyboardEvents, i)
            return true
        end
    end
    return false
end

function UserInputController:updateKeyboardListener( keyCode, pressedCB, releaseCB, interval )
    if not keyCode then
        print("ERROR++++++++++++++++++++++++, keyCode is empty")
        return
    end
    if type(keyCode) == "number" then
        local t = {}
        table.insert(t, keyCode)
        keyCode = t
    end
    for k, v in pairs(self._keyboardEvents) do
        if compareKeyCode(v.keyCode, keyCode, v.checkFullSort) then
            if pressedCB then v.pressedCB = pressedCB end
            if releaseCB then v.releaseCB = releaseCB end
            if interval then v.interval = interval end
            return true
        end
    end
    return false
end

function UserInputController:InitKeyCodeLogin()
    self:InitKeyboardListener()
    
    -- ENTER 确认当前界面
    local pressedCB = function()
        global.Facade:sendNotification(global.NoticeTable.Layer_Enter_Current)
    end
    local keyCodes = cc.KeyCode.KEY_ENTER
    global.userInputController:addKeyboardListener(keyCodes, pressedCB, nil, 0)
    local keyCodes = cc.KeyCode.KEY_KP_ENTER
    global.userInputController:addKeyboardListener(keyCodes, pressedCB, nil, 0)
end

function UserInputController:InitKeyCodeWorld()
    self:InitKeyboardListener()

    if not global.isWinPlayMode then
        return nil
    end

    ---------------------------------------------------------------------------
    -- F1-F8技能
    for i = 1, 8 do
        local callback = function(isAuto)
            local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
            local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
            local skill = SkillProxy:GetSkillByKey(i)
            if not skill then
                return false
            end
            local skillID = skill.MagicID

            -- 开关技能
            if SkillProxy:IsOnoffSkill(skillID) then
                if isAuto then
                    return
                end
                SkillProxy:RequestSkillOnoff(skillID)
                return
            end
            
            local destPos = inputProxy:getCursorMapPosition()
            global.Facade:sendNotification(global.NoticeTable.UserInputLaunch, {skillID = skillID, destPos = destPos})
        end
        local releaseCB = function()
            local autoProxy = global.Facade:retrieveProxy( global.ProxyTable.Auto )
            autoProxy:ClearLaunchFirstSkill()
        end
        local keyCodes = cc.KeyCode[string.format("KEY_F%s", i)]
        local tag = nil
        self:addKeyboardListener(keyCodes, callback,releaseCB,0.1)
    end
    -- CTRL+F1 - CTRL+F8技能
    for i = 1, 8 do
        local callback = function(isAuto)
            local inptuProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
            local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
            local skill = SkillProxy:GetSkillByKey(i+8)
            if not skill then
                return false
            end
            local skillID = skill.MagicID

            -- 开关技能
            if SkillProxy:IsOnoffSkill(skillID) then
                if isAuto then
                    return
                end
                SkillProxy:RequestSkillOnoff(skillID)
                return
            end

            -- 技能释放
            local destPos = inptuProxy:getCursorMapPosition()
            global.Facade:sendNotification(global.NoticeTable.UserInputLaunch, {skillID = skillID, destPos = destPos})
        end
        local releaseCB = function()
            local autoProxy = global.Facade:retrieveProxy( global.ProxyTable.Auto )
            autoProxy:ClearLaunchFirstSkill()
        end
        local keyCodes = {cc.KeyCode.KEY_CTRL, cc.KeyCode[string.format("KEY_F%s", i)]}
        local tag = nil
        self:addKeyboardListener(keyCodes, callback, releaseCB, 0.1)
    end

    -- 1-6使用物品
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    for i = 1, 6 do
        local interval   = 1
        local scheduleID = nil

        local function useItemCB()
            local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
            local quickUseData = QuickUseProxy:GetQucikUseDataByPos(i)
            if quickUseData then
                local ItemUseProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemUseProxy)
                ItemUseProxy:UseItem(quickUseData)
            end
        end

        local function pressedCB()
            local cuiEditorMediator = global.Facade:retrieveMediator("CUIEditorMediator")
            if cuiEditorMediator and cuiEditorMediator._layer then
                return
            end
            useItemCB()
            if scheduleID then
                UnSchedule(scheduleID)
                scheduleID = nil
            end
            scheduleID = Schedule(useItemCB, interval)
        end
        local function releaseCB()
            if scheduleID then
                UnSchedule(scheduleID)
                scheduleID = nil
            end
        end
        self:addKeyboardListener(cc.KeyCode[string.format("KEY_%s", i)], pressedCB, releaseCB)
    end

    -- shift+左键持续攻击
    local pressedCB = function()
        self._isPressedShift = true
        global.Facade:sendNotification(global.NoticeTable.UserPressedShift)
    end
    local releaseCB = function()
        self._isPressedShift = false
        global.Facade:sendNotification(global.NoticeTable.UserReleaseShift)
    end
    local keyCodes = cc.KeyCode.KEY_LEFT_SHIFT
    self:addKeyboardListener(keyCodes, pressedCB, releaseCB, -1)

    -- ctrl
    local pressedCB = function()
        self._isPressedCtrl = true
    end
    local releaseCB = function()
        self._isPressedCtrl = false
    end
    local keyCodes = cc.KeyCode.KEY_CTRL
    self:addKeyboardListener(keyCodes, pressedCB, releaseCB, -1)

    -- F9包裹
    local pressedCB = function()
        JUMPTO(7)
    end
    local keyCodes = cc.KeyCode.KEY_F9
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)
    
    -- F10装备
    local pressedCB = function()
        SL:OpenMyPlayerUI({extent = 1, isFast = true})
    end
    local keyCodes = cc.KeyCode.KEY_F10
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)
    
    -- F11技能
    local pressedCB = function()
        SL:OpenMyPlayerUI({extent = 4, isFast = true})
    end
    local keyCodes = cc.KeyCode.KEY_F11
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    -- T交易
    local pressedCB = function()
        if (CHECK_SERVER_OPTION(global.MMO.SERVER_OPTION_TRADE_DEAL) == true) then
            local TradeProxy = global.Facade:retrieveProxy(global.ProxyTable.TradeProxy)
            TradeProxy:SendTradeRequest()
        end
    end
    local keyCodes = cc.KeyCode.KEY_T
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    -- G行会
    local pressedCB = function()
        JUMPTO(31)
    end
    local keyCodes = cc.KeyCode.KEY_G
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    -- ALT-X返回角色
    local pressedCB = function()
        local function callback(bType, custom)
            if bType == 1 then
                global.Facade:sendNotification(global.NoticeTable.RequestLeaveWorld)
            end
        end
        local data = {}
        data.str = GET_STRING(30003056)
        data.btnDesc = {GET_STRING(1001), GET_STRING(1000)}
        data.callback = callback
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
    end
    local keyCodes = {cc.KeyCode.KEY_ALT, cc.KeyCode.KEY_X}
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    -- ALT-Q退出游戏
    local pressedCB = function()
        local function callback(bType, custom)
            if bType == 1 then
                global.userInputController:RequestToOutGame()
            end
        end
        local data = {}
        data.str = GET_STRING(30003036)
        data.btnDesc = {GET_STRING(1001), GET_STRING(1000)}
        data.callback = callback
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
    end
    local keyCodes = {cc.KeyCode.KEY_ALT, cc.KeyCode.KEY_Q}
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    -- CTRL_H 切换攻击模式
    local pressedCB = function()
        local pkModeTB = {0, 1, 4, 5, 6, 3, 2, 7}
        local PlayerPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local canMode = {}
        for _, v in ipairs(pkModeTB) do
            if PlayerPropertyProxy:IsShowCurMode(v) then
                table.insert( canMode, v)
            end
        end
        local function getPKModeIndex(pkm) 
            for k, v in pairs(canMode) do
                if pkm == v then
                    return k
                end
            end
            return 1
        end

        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        local pkMode         = PlayerProperty:GetPKMode()
        local index          = getPKModeIndex(pkMode)
        local nextPKMode     = canMode[(index >= #canMode and 1 or index+1)]
        PlayerProperty:RequestChangePKMode(nextPKMode)
    end
    local keyCodes = {cc.KeyCode.KEY_LEFT_CTRL, cc.KeyCode.KEY_H}
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    -- CTRL+A 召唤物休息或者攻击
    local pressedCB = function()
        local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
        if not SummonsProxy:IsAlived() then
            return false
        end

        local SummonsProxy  = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
        local currMode      = SummonsProxy:GetMode()
        local nextMode      = currMode == 4 and 2 or 4
        SummonsProxy:RequestModeChange(nextMode)
    end
    local keyCodes = {cc.KeyCode.KEY_LEFT_CTRL, cc.KeyCode.KEY_A}
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    -- F12内挂
    local pressedCB = function()
        global.Facade:sendNotification(global.NoticeTable.Layer_SettingFrame_Open)
    end
    local keyCodes = cc.KeyCode.KEY_F12
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    -- 波浪键 ` ~ 拾取当前位置道具
    local pressedCB = function()
        global.dropItemController:PickMainPlayerPosItem( )
    end
    local keyCodes = cc.KeyCode.KEY_GRAVE
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    -- ALT
    local pressedCB = function()
        self._isPressedAlt = true
    end
    local releaseCB = function()
        self._isPressedAlt = false
    end
    local keyCodes = cc.KeyCode.KEY_ALT
    global.userInputController:addKeyboardListener(keyCodes, pressedCB, releaseCB)

    -- 拍卖
    local pressedCB = function()
        if tonumber(SL:GetMetaValue("GAME_DATA","OpenAuctionByP")) == 1 then
            return 
        end
        JUMPTO(27)
    end
    local keyCodes = cc.KeyCode.KEY_P
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)
    
    -- ESC 关闭当前界面
    local pressedCB = function()
        local cuiEditorMediator = global.Facade:retrieveMediator("CUIEditorMediator")
        if cuiEditorMediator and cuiEditorMediator._layer then
            global.Facade:sendNotification(global.NoticeTable.CUIEditorClose)
        end

        local SUIComponentMediator = global.Facade:retrieveMediator("SUIComponentMediator") 
        local isClosed = SUIComponentMediator:CloseSUIAddWin()

        local isClosedEx = false
        if not isClosed then
            if ssrGlobal_ESCCloseWinEvent then
                isClosedEx = ssrGlobal_ESCCloseWinEvent()
            end
        end
        
        if not isClosed and not isClosedEx then
            global.Facade:sendNotification(global.NoticeTable.Layer_Close_Current)
        end
    end
    local keyCodes = cc.KeyCode.KEY_ESCAPE
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)

    --英雄切换攻击模式
    local keyCodes = {cc.KeyCode.KEY_CTRL,cc.KeyCode.KEY_E}
    local pressedCB = function()
        if HeroPropertyProxy:HeroIsLogin() then
            HeroPropertyProxy:RequestChangeHeroMode()
        end
    end
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    --切换锁定目标ctrl+w
    local keyCodes = {cc.KeyCode.KEY_CTRL,cc.KeyCode.KEY_W}
    local pressedCB = function()
        GUIFunction:OnSwitchLockTarget_Hero()
    end
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    --守护位置ctrl+q
    local keyCodes = {cc.KeyCode.KEY_CTRL,cc.KeyCode.KEY_Q}
    local pressedCB = function()
        if HeroPropertyProxy:HeroIsLogin() then
            local touchPos =   self:GetCursorPos()
            local touchPosInWorld = Screen2World(touchPos)
            local X,Y = global.sceneManager:WorldPos2MapPos(touchPosInWorld)
            HeroPropertyProxy:RequestTargetXY(X,Y)
        end
    end
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    --宠物锁定目标ctrl+r
    local keyCodes = {cc.KeyCode.KEY_CTRL,cc.KeyCode.KEY_R}
    local pressedCB = function()
        local SummonsProxy = global.Facade:retrieveProxy(global.ProxyTable.SummonsProxy)
        if not SummonsProxy:IsAlived() then 
            return 
        end
            local touchPos =   self:GetCursorPos()
            local touchPosInWorld = Screen2World(touchPos)
            local actor = global.actorManager:Pick(touchPosInWorld)
            local proxyUtils      = requireProxy( "proxyUtils" )
            if actor and proxyUtils.checkEnemyTag(actor) == 1 then
                local lockID =  SummonsProxy:GetLockTargetID()
                if  lockID == actor:GetID() then --已锁定 
                    SummonsProxy:ReqUnLockActorByID(actor:GetID())
                else
                    SummonsProxy:ReqLockActorByID(actor:GetID())

                end
            end
    end
    
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    --开启合击ctrl+s
    local keyCodes = {cc.KeyCode.KEY_CTRL,cc.KeyCode.KEY_S}
    local pressedCB = function()
        if HeroPropertyProxy:HeroIsLogin() then
            if HeroPropertyProxy:getShan()  then--在闪的时候才能放合击
                HeroPropertyProxy:ReqJointAttack()--请求合击
            end
        end
    end
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    --骑马邀请快捷键
    local keyCodes = {cc.KeyCode.KEY_CTRL,cc.KeyCode.KEY_L}
    local pressedCB = function()
        local mainActor = global.gamePlayerController:GetMainPlayer()
        if not mainActor then --主玩家不在
            return
        end
        if not mainActor:IsDoubleHorse() then --主玩家不是双人坐骑
            ShowSystemTips(GET_STRING(310000801))
            return
        end
        if mainActor:GetHorseCopilotID() then --主玩家的双人坐骑已满
            ShowSystemTips(GET_STRING(310000802))
            return
        end

        local inputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        local targetID = inputProxy:GetTargetID()
        if not targetID then --没有选中者
            return
        end
        local targetActor = global.actorManager:GetActor(targetID)
        if not targetActor then --选中者没找到
            ShowSystemTips(GET_STRING(310000803))
            return
        end
        if not targetActor:IsPlayer() then --选择者不是角色玩家
            ShowSystemTips(GET_STRING(310000805))
            return
        end

        local mainPos = cc.p( mainActor:GetMapX(), mainActor:GetMapY() )
        local targetPos = cc.p( targetActor:GetMapX(), targetActor:GetMapY() )
        if cc.pGetDistance( mainPos,targetPos ) > 3 then
            ShowSystemTips(GET_STRING(310000804))
            return
        end
        local HorseProxy = global.Facade:retrieveProxy( global.ProxyTable.HorseProxy )
        HorseProxy:RequestHorseUpInvite( targetID )
    end
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    --截图
    local keyCodes = {cc.KeyCode.KEY_PAUSE}
    local pressedCB = function()
        local FileUtils = cc.FileUtils:getInstance()
        local WritablePath = FileUtils:getWritablePath()
        local saveDir = WritablePath.."Images"
        if not  FileUtils:isDirectoryExist(saveDir) then
            FileUtils:createDirectory(saveDir)
        end
        local prepath = saveDir.."/capture"
        local begin = 1
        while(1) do
            local filename = string.format("%s%s.png",prepath,begin)
            if FileUtils:isFileExist(filename) then
                begin = begin + 1
            else
                cc.utils:captureScreen(function(isOK,path)
                    if isOK then
                        ShowSystemTips(string.format(GET_STRING(600000315),path))
                    end
                end, filename)
                break
            end   
        end
    end
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    --商店ctrl+B
    local keyCodes = {cc.KeyCode.KEY_CTRL,cc.KeyCode.KEY_B}
    local pressedCB = function()
        JUMPTO(9)
    end
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    --快速组队alt+W
    local keyCodes = {cc.KeyCode.KEY_ALT,cc.KeyCode.KEY_W}
    local pressedCB = function()
        local touchPos =   self:GetCursorPos()
        local touchPosInWorld = Screen2World(touchPos)
        local actor = global.actorManager:Pick(touchPosInWorld)

        if actor then
            local targetID = actor:GetID()
            local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
            if TeamProxy:IsTeamMember(targetID) then 
                return 
            else
                TeamProxy:RequestInvite(targetID)
            end
        end
    end
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    --自动挂机
    local keyCodes = {cc.KeyCode.KEY_CTRL,cc.KeyCode.KEY_ALT, cc.KeyCode.KEY_X}
    local pressedCB = function()
        local disableKeys = SL:GetMetaValue("GAME_DATA","disableKeys")
        if disableKeys and disableKeys ~= "" then 
            local Keys = string.split(disableKeys,"#")
            local key = tonumber(Keys[1]) or 0
            if key == 1 then 
                return 
            end
        end
        local AutoProxy = global.Facade:retrieveProxy(global.ProxyTable.Auto)
        if AutoProxy:IsAFKState() then
            LuaSendMsg(global.MsgType.MSG_CS_AUTOPLAYGAME_REQUEST,2)
            global.Facade:sendNotification(global.NoticeTable.AFKEnd)
        else
            LuaSendMsg(global.MsgType.MSG_CS_AUTOPLAYGAME_REQUEST,1)
            global.Facade:sendNotification(global.NoticeTable.AFKBegin)
        end
    end
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    -- CTRL+D 连击技能
    local keyCodes = {cc.KeyCode.KEY_CTRL, cc.KeyCode.KEY_D}
    local pressedCB = function(isAuto)
        local selectSkills = SL:GetMetaValue("SET_COMBO_SKILLS")
        if not selectSkills or not selectSkills[1] then
            return false
        end
        local skillID = selectSkills[1]
        local num = #selectSkills
        local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        if skillID then
            for i = 1, num do
                local id = selectSkills[i]
                if id and id ~= 0 then
                    if skillProxy:IsInCD(id) then
                        return
                    end
                end
            end
        end

        -- 开关技能
        if SkillProxy:IsOnoffSkill(skillID) then
            if isAuto then
                return
            end
            SkillProxy:RequestSkillOnoff(skillID)
            return
        end

        -- 技能释放
        local inptuProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
        local destPos = inptuProxy:getCursorMapPosition()
        global.Facade:sendNotification(global.NoticeTable.UserInputLaunch, {skillID = skillID, destPos = destPos})
    end
    local releaseCB = function()
        local autoProxy = global.Facade:retrieveProxy( global.ProxyTable.Auto )
        autoProxy:ClearLaunchFirstSkill()
    end
    global.userInputController:addKeyboardListener(keyCodes, pressedCB, releaseCB, 0.1)

    -- ENTER 确认当前界面
    local pressedCB = function()
        global.Facade:sendNotification(global.NoticeTable.Layer_Enter_Current)
    end
    
    local keyCodes = cc.KeyCode.KEY_ENTER
    global.userInputController:addKeyboardListener(keyCodes, pressedCB, nil, 0)
    local keyCodes = cc.KeyCode.KEY_KP_ENTER
    global.userInputController:addKeyboardListener(keyCodes, pressedCB, nil, 0)

    -- 上下键滚动聊天
    local function scrollChatFunc(isUp, isPage)
        local MainPropertyMediator = global.Facade:retrieveMediator("MainPropertyMediator")
        local layer = MainPropertyMediator and MainPropertyMediator._layer
        local list = layer._quickUI.ListView_chat
        if not list then return end

        local innerSize     = list:getInnerContainerSize()
        local contentSize   = list:getContentSize()
        local innerPos      = list:getInnerContainerPosition()
        if innerSize.height - contentSize.height <= 0 then
            return
        end

        local pageHei       = contentSize.height
        local scrollY       = isPage and pageHei or 14
        local mHei          = innerSize.height - contentSize.height
        local percent       = (mHei + innerPos.y + (isUp and -scrollY or scrollY )) / mHei * 100
        percent             = math.min(math.max(0, percent), 100)
        list:scrollToPercentVertical(percent, 0.03, false)
    end

    local keyCodes = cc.KeyCode.KEY_UP_ARROW
    local pressedCB = function()
        scrollChatFunc(true)
    end
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    local keyCodes = cc.KeyCode.KEY_DOWN_ARROW
    local pressedCB = function()
        scrollChatFunc(false)
    end
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    --Page UP/DOWN 聊天翻页
    local keyCodes = cc.KeyCode.KEY_PG_UP
    local pressedCB = function()
        scrollChatFunc(true, true)
    end
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)

    local keyCodes = cc.KeyCode.KEY_PG_DOWN
    local pressedCB = function()
        scrollChatFunc(false, true)
    end
    global.userInputController:addKeyboardListener(keyCodes, pressedCB)
end
----------------------------------- keycode -----------------------------------

----------------------------------- touch   -----------------------------------
function UserInputController:ResetTouch()
    if not self._touchListener then
        return nil
    end
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:removeEventListener(self._touchListener)

    self._cursorPosition    = {x=0,y=0}
    self._touchListener     = nil
    self._touching          = false
end

function UserInputController:InitTouch()
    local labelDebug = nil
    if DEBUG_TOUCH then
        --********* Debug
        local visibleSize = global.Director:getVisibleSize()
        local origin = global.Director:getVisibleOrigin()
        local label = cc.Label:createWithTTF("", "fonts/font2.ttf", 24)
        labelDebug = label
        
        -- position the label on the center of the screen
        label:enableOutline(cc.Color4B.BLACK, 1)
        label:setAnchorPoint(cc.p(0.5, 1.0))
        label:setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height)
        global.sceneGraphCtl:GetUiNormal():addChild(label, 9991)
    end
    
    local function updateDebugInfoStr(position)
        if (labelDebug) then
            local touchPos = Screen2World(position)
            if not touchPos then
                return nil
            end
            -- [Debug] grid pos
            local mapX, mapY = global.sceneManager:WorldPos2MapPos(touchPos)
            touchPos = global.sceneManager:MapPos2WorldPos(mapX, mapY, true)
            
            local debugInfo = string.format("[Mx%d,My:%d][tx:%d,ty:%d]", mapX, mapY, touchPos.x, touchPos.y)
            labelDebug:setString(debugInfo)
        end
    end
    
    
    --********* Input ( touch )
    local function began(touch, event)
        if not global.gamePlayerController:GetMainPlayer() then
            return false
        end

        local touchPos  = touch:getLocation()
        local touchWay  = global.MMO.MOVE_EVENT_TOUCH_AND_MOUSE_L
        local eventType = cc.Handler.EVENT_TOUCH_BEGAN
        global.gamePlayerController:HandleTouchEndEvent(touchPos, touchWay, eventType)

        local data = {
            way = global.MMO.MOVE_EVENT_TOUCH_AND_MOUSE_L,
            pos = touch:getLocation()
        }
        global.Facade:sendNotification(global.NoticeTable.keepMovingBegin, data)
        return true
    end
    local function moved(touch, event)
        if (DEBUG_TOUCH) then
            updateDebugInfoStr(touch:getLocation())
        end
        
        if not global.gamePlayerController:GetMainPlayer() then
            return
        end
        
        local data = {
            way = global.MMO.MOVE_EVENT_TOUCH_AND_MOUSE_L,
            pos = touch:getLocation()
        }
        global.Facade:sendNotification(global.NoticeTable.keepMovingUpdate, data)
    end
    local function ended(touch, event)
        if (DEBUG_TOUCH) then
            updateDebugInfoStr(touch:getLocation())
        end
        
        if not global.gamePlayerController:GetMainPlayer() then
            return
        end
        global.Facade:sendNotification(global.NoticeTable.keepMovingEnded)
    end
    local function cancelled(touch, event)
        if (DEBUG_TOUCH) then
            updateDebugInfoStr(touch:getLocation())
        end
        
        if not global.gamePlayerController:GetMainPlayer() then
            return
        end
        global.Facade:sendNotification(global.NoticeTable.keepMovingEnded)
    end
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    self._touchListener = cc.EventListenerTouchOneByOne:create()
    self._touchListener:registerScriptHandler(began, cc.Handler.EVENT_TOUCH_BEGAN)
    self._touchListener:registerScriptHandler(moved, cc.Handler.EVENT_TOUCH_MOVED)
    self._touchListener:registerScriptHandler(ended, cc.Handler.EVENT_TOUCH_ENDED)
    self._touchListener:registerScriptHandler(cancelled, cc.Handler.EVENT_TOUCH_CANCELLED)
    dispatcher:addEventListenerWithSceneGraphPriority(self._touchListener, global.gameWorldController)
end
----------------------------------- touch   -----------------------------------


----------------------------------- mouse event -------------------------------
function UserInputController:OnMouseMoved(data)
    
    self._cursorPosition = data.pos
end

function UserInputController:GetCursorPos()
    return self._cursorPosition
end
----------------------------------- mouse event -------------------------------


-------------------------------------------------------------------------------
function UserInputController:RequestToOutGame( ... )
    local function quit( ... )
        if self._timerID then
            UnSchedule( self._timerID )
            self._timerID = nil
            global.Facade:sendNotification(global.NoticeTable.Main_Remove_QuitTimeTips)
        end
        local glview = global.Director:getOpenGLView()
        glview:endToLua()
    end

    if self._timerID then
        UnSchedule( self._timerID )
        self._timerID = nil
    end

    if self._leaveID then
        UnSchedule( self._leaveID )
        self._leaveID = nil
    end
   
    if CHECK_SERVER_OPTION("DelayBQuit") then
        local delayTime = CHECK_SERVER_OPTION("nBQuitTime")
        if delayTime and tonumber(delayTime) then
            global.Facade:sendNotification(global.NoticeTable.Main_Add_QuitTimeTips, {time = tonumber(delayTime), type = 2})
            self._timerID = Schedule( quit,  tonumber(delayTime))
        else
            quit()
        end
    else
        quit()
    end

end

function UserInputController:RequestLeaveWorld( ... )
    local function leave( ... )
        if self._leaveID then
            UnSchedule( self._leaveID )
            self._leaveID = nil
            global.Facade:sendNotification(global.NoticeTable.Main_Remove_QuitTimeTips)
        end

        local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
        LoginProxy:RequestSoftClose()
    end

    if self._leaveID then
        UnSchedule( self._leaveID )
        self._leaveID = nil
    end

    if self._timerID then
        UnSchedule( self._timerID )
        self._timerID = nil
    end
   
    if CHECK_SERVER_OPTION("boDelaySQuit") then
        local delayTime = CHECK_SERVER_OPTION("nSQuitTime")
        if delayTime and tonumber(delayTime) then
            global.Facade:sendNotification(global.NoticeTable.Main_Add_QuitTimeTips, {time = tonumber(delayTime), type = 1})
            self._leaveID = Schedule( leave,  tonumber(delayTime))
        else
            leave()
        end
    else
        leave()
    end
end

function UserInputController:OnPlayerBeDamaged( ... )
    if self._timerID and CHECK_SERVER_OPTION("boBQuitStruckBreak") then
        UnSchedule( self._timerID )
        self._timerID = nil
        global.Facade:sendNotification(global.NoticeTable.Main_Remove_QuitTimeTips)
    end

    if self._leaveID and CHECK_SERVER_OPTION("boSQuitStruckBreak") then
        UnSchedule( self._leaveID )
        self._leaveID = nil
        global.Facade:sendNotification(global.NoticeTable.Main_Remove_QuitTimeTips)
    end
end

function UserInputController:OnMainPlayerActionBegan(act)
    if not IsMoveAction(act) then
        return
    end

    if self._timerID and CHECK_SERVER_OPTION("boBQuitMoveBreak") then
        UnSchedule( self._timerID )
        self._timerID = nil
        global.Facade:sendNotification(global.NoticeTable.Main_Remove_QuitTimeTips)
    end

    if self._leaveID and CHECK_SERVER_OPTION("boSQuitMoveBreak") then
        UnSchedule( self._leaveID )
        self._leaveID = nil
        global.Facade:sendNotification(global.NoticeTable.Main_Remove_QuitTimeTips)
    end
end


return UserInputController
