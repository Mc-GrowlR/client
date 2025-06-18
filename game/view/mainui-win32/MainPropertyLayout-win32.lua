local MainPropertyLayout = class("MainPropertyLayout", function()
    return cc.Node:create()
end)

local RichTextHelp = requireUtil("RichTextHelp")
local fontpath = global.ChatAndTips_Use_Font or global.MMO.PATH_FONT2
local chatItemWid  = 500

function MainPropertyLayout:ctor()
    self._quickUseCells = {}

    self._chatCellCache = {}
    self._isScrolling   = false

    self._pSize = {}
    self._drawHWay = {}

    self._proxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)

    local CHANNEL = self._proxy.CHANNEL
    self._channelName = {
        [CHANNEL.Shout]     = "喊 话",
        [CHANNEL.Guild]     = "行 会",
        [CHANNEL.Team]      = "组 队",
        [CHANNEL.Near]      = "附 近",
        [CHANNEL.World]     = "世 界",
        [CHANNEL.Nation]    = "国 家",
        [CHANNEL.Union]     = "联 盟",
    }

    self._channelSelect = nil

    self._selectBtnShow = SL:GetMetaValue("GAME_DATA","PCShowSelectChannels") and true or false

    self._showLastChatExID  = nil   -- 固定聊天最后显示的id
end

function MainPropertyLayout.create()
    local layout = MainPropertyLayout.new()
    if layout:Init() then
        return layout
    end
    return nil
end

function MainPropertyLayout:Init()
    self._quickUI = ui_delegate(self)

    self._listInterval, self._richVspace = self._proxy:GetChatParam()

    return true
end

function MainPropertyLayout:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_PROPERTY_WIN32)
    MainProperty.main()

    if MainProperty and MainProperty._channelNameMap and next(MainProperty._channelNameMap) then
        self._channelName = MainProperty._channelNameMap
    end

    self:InitHP()
    self:InitChat()

    self:InitEditMode()
end

function MainPropertyLayout:InitEditMode()
    local items = 
    {
        "Panel_bubble_tips",
        "Panel_auto_tips",
        "Image_1",
        "Text_hp",
        "Text_mp",
        "Text_position",
        "Button_chat_1",
        "Button_chat_2",
        "Button_chat_3",
        "Button_chat_4",
        "Button_chat_5",
        "Button_chat_6",
        "Button_map",
        "Button_trade",
        "Button_guild",
        "Button_near",
        "Button_rank",
        "Button_out",
        "Button_end",
        "Button_role",
        "Button_bag",
        "Button_skill",
        "Button_voice",
        "Button_store",
        "Image_time",
        "LoadingBar_exp",
        "LoadingBar_weight",
        "Image_2",
        "Text_time",
        "Text_level",
        "Text_pkmode",
        "Button_pick",
        "Panel_quick_use_1",
        "Panel_quick_use_2",
        "Panel_quick_use_3",
        "Panel_quick_use_4",
        "Panel_quick_use_5",
        "Panel_quick_use_6",
        "Image_hp_bg",
        "LoadingBar_hp",
        "LoadingBar_mp",
        "Image_fhp_bg",
        "LoadingBar_fhp",
        "Button_herostate",
        "Button_heroinfo",
        "Button_herobag",
        "Panel_hp_sfx",
        "Panel_mp_sfx",
        "Panel_fhp_sfx",
        "Panel_hp",
        "Panel_chat",
        "Panel_act",
        "Image_act_bg",
        "Button_private",
        "btn_rein_add",
        "Image_laodBarbg",
        "Panel_loadBar",
        "Image_loadbar1",
        "Image_loadbar2",
        "Node_quit_tip",
        "Button_chat_7",
        "Image_quick_bg",
        "ListView_chat",
        "TextField_input",
        "ListView_chat_ex",
        "Button_channel_0",
        "Button_channel_1",
        "Button_channel_2",
        "Button_channel_3",
        "Button_channel_4",
        "Button_channel_5",
        "Button_channel_6",
        "Button_channel_7",
        "Button_channel_8",
        "Text_FPS",
    }
    for _, widgetName in ipairs(items) do
        if self._quickUI[widgetName] then
            self._quickUI[widgetName].editMode = 1
        end
    end
    if self._selectBtnShow then
        self._quickUI.Button_channel.editMode = 1
    end
end

function MainPropertyLayout:GetMiniChatWidth()
    return MainProperty._chatItemWid
end

function MainPropertyLayout:InitAdapet()
    if MainProperty.InitAdapet then
        MainProperty.InitAdapet()
    end
end

function MainPropertyLayout:InitHP()
    if not self._quickUI.Button_chat_7 then
        return
    end
    local ChatProxy    = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local mainSetReceiving = function(channel)
        if not channel then
            return
        end
        local isReceiving  = ChatProxy:isReceiving(channel)
        ChatProxy:setReceiving(channel, not isReceiving)
    end

    local mainSetTexture = function(channel, sender, texturePath)
        if not channel or not sender or not texturePath then
            return
        end        
        sender:loadTextureNormal(texturePath)
        sender:loadTexturePressed(texturePath)
    end

    -- 自动喊话开关
    local autoShoutCallback = nil
    autoShoutCallback = function(shoutInput)
        self._quickUI.Button_chat_7:stopActionByTag(888)
        if not shoutInput or shoutInput == "" then
            return
        end
        if not ChatProxy:GetAutoShoutSwitch() then
            return
        end
        local delay = ChatProxy:GetAutoShoutDelay()
        local action = schedule(self._quickUI.Button_chat_7, function()
            -- 发送 PC端根据消息内容决定频道
            self:sendChatMsg(shoutInput, ChatProxy.CHANNEL.Shout)
        end,delay)
        action:setTag(888)
    end

    local isAutoShout  = ChatProxy:GetAutoShoutSwitch()
    local path = string.format(global.MMO.PATH_RES_PRIVATE .. "main-win32/%s", isAutoShout and "190001112.png" or "190001113.png") 
    mainSetTexture(ChatProxy.CHANNEL.Shout,self._quickUI.Button_chat_7, path)
    if isAutoShout then
        local shoutInput = ChatProxy:getLocalChatDataData(ChatProxy.CHANNEL.Shout)
        autoShoutCallback(shoutInput)
    end

    self._quickUI.Button_chat_7:addClickEventListener(function(sender)
        local channel = ChatProxy.CHANNEL.Shout
        ChatProxy:SetAutoShoutSwitch(channel, not ChatProxy:GetAutoShoutSwitch())

        local isOpen = ChatProxy:GetAutoShoutSwitch()
        local path = string.format(global.MMO.PATH_RES_PRIVATE .. "main-win32/%s", isOpen and "190001112.png" or "190001113.png") 
        mainSetTexture(channel, sender, path)

        --记录自动喊话内容
        local input = self._quickUI.TextField_input:getString()
        ChatProxy:setLocalChatDataData(channel, input or "")
        autoShoutCallback(input)

        -- 发送提示
        local CHANNEL = ChatProxy.CHANNEL
        local data = {}
        data.ChannelId = CHANNEL.System
        data.Msg = isOpen and GET_STRING(30001072) or GET_STRING(30001073)
        global.Facade:sendNotification(global.NoticeTable.AddChatItem, data)
        global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_BTN_CLICK})

        if isOpen then
            if input == "" then
                return
            end
            self:sendChatMsg(input, ChatProxy.CHANNEL.Shout)
        end
    end)
    
end

function MainPropertyLayout:InitChat()
    self._inputIndex    = 0
    self._inputCache    = {}

    if self._listInterval then
        self._quickUI.ListView_chat:setItemsMargin(self._listInterval)
        self._quickUI.ListView_chat_ex:setItemsMargin(self._listInterval)
    end

    -- 触摸事件  用来打开输入框和监听事件
    self._quickUI.TextField_input:addTouchEventListener(function(sender, eventype)
        if eventype == 2 then
            self._quickUI.TextField_input:touchDownAction(self._quickUI.TextField_input, 2)
        end
    end)
    self:onChatEditHandler()

    global.userInputController:addKeyboardListener({cc.KeyCode.KEY_SHIFT, cc.KeyCode.KEY_1}, function()
        self._quickUI.TextField_input:setString("!")
        self._quickUI.TextField_input:touchDownAction(self._quickUI.TextField_input, 2)
    end)
    global.userInputController:addKeyboardListener({cc.KeyCode.KEY_SHIFT, cc.KeyCode.KEY_2}, function()
        self._quickUI.TextField_input:setString("@")
        self._quickUI.TextField_input:touchDownAction(self._quickUI.TextField_input, 2)
    end)
    global.userInputController:addKeyboardListener({cc.KeyCode.KEY_SHIFT, cc.KeyCode.KEY_3}, function()
        self._quickUI.TextField_input:setString("#")
        self._quickUI.TextField_input:touchDownAction(self._quickUI.TextField_input, 2)
    end)
    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_SLASH, function()
        self._quickUI.TextField_input:setString("/")
        self._quickUI.TextField_input:touchDownAction(self._quickUI.TextField_input, 2)
    end)

    -- control ↑
    local function callback()
        self._inputIndex = self._inputIndex > 1 and self._inputIndex - 1 or self._inputIndex
        if not self._inputCache[self._inputIndex] then
            return
        end
        self._quickUI.TextField_input:setString(self._inputCache[self._inputIndex])
    end
    local keycodes = {cc.KeyCode.KEY_CTRL, cc.KeyCode.KEY_UP_ARROW}
    global.userInputController:addKeyboardListener(keycodes, callback)
    local keycodes = {cc.KeyCode.KEY_RIGHT_CTRL, cc.KeyCode.KEY_UP_ARROW}
    global.userInputController:addKeyboardListener(keycodes, callback)

    -- control ↓
    local function callback()
        self._inputIndex = self._inputIndex < #self._inputCache and self._inputIndex + 1 or self._inputIndex
        if not self._inputCache[self._inputIndex] then
            return
        end
        self._quickUI.TextField_input:setString(self._inputCache[self._inputIndex])
    end
    local keycodes = {cc.KeyCode.KEY_CTRL, cc.KeyCode.KEY_DOWN_ARROW}
    global.userInputController:addKeyboardListener(keycodes, callback)
    local keycodes = {cc.KeyCode.KEY_RIGHT_CTRL, cc.KeyCode.KEY_DOWN_ARROW}
    global.userInputController:addKeyboardListener(keycodes, callback)

    -- 拖动
    local function listCallback(sender, eventType)
        if eventType == 9 or eventType == 10 then
            local innerPos = self._quickUI.ListView_chat:getInnerContainerPosition()
            if innerPos.y == 0 and self._isScrolling then
                self._isScrolling = false
                self:ShowChatCache()
            end
        end
    end
    self._quickUI.ListView_chat:addScrollViewEventListener(listCallback)
    self._quickUI.ListView_chat:addMouseScrollPercent()

    -- 频道切换开关开启
    local isOpen = SL:GetMetaValue("GAME_DATA", "PCSwitchChannelShow") and SL:GetMetaValue("GAME_DATA", "PCSwitchChannelShow") == 1 
    if isOpen then
        self._quickUI.Panel_channel:setVisible(true)
    else
        self._quickUI.Panel_channel:setVisible(false)
    end

    local receiveChannel = self._proxy:getReceiveChannel()
    local CHANNEL = self._proxy.CHANNEL
    for i = 0, 8 do
        if self._quickUI["Button_channel_" .. i] then
            self._quickUI["Button_channel_" .. i]:setBright(i ~= receiveChannel)
            self._quickUI["Button_channel_" .. i]:setTouchEnabled(i ~= receiveChannel)
            self._quickUI["Button_channel_" .. i]:addClickEventListener(function()
                local channel = i
                self._proxy:setReceiveChannel(i)
                self:UpdateReceiving()
            end)
            if isOpen then
                self._quickUI["Button_channel_"..i]:addMouseOverTips(GET_STRING(700000120 + i), {x = -10,y = -20}, {x = 1, y = 0.5})
            end
        end
    end
    
    self._quickUI.Button_channel:setVisible(self._selectBtnShow) 
    self._quickUI.Button_channel:addClickEventListener(function ( ... )
        if self._quickUI.Panel_channel_s:isVisible() then
            self:HideChannels()
        else
            self:ShowChannels()
        end
    end)

    if self._selectBtnShow then
        self._channelSelect = self._proxy:getChannel()
        local name = self._channelSelect and self._channelName[self._channelSelect]
        if name and self._quickUI.Text_channel then
            self._quickUI.Text_channel:setString(name)
        end
    end

    self:HideChannels()
end

function MainPropertyLayout:ShowChannels()
    self._quickUI.Panel_channel_s:setVisible(true)
    self._quickUI.Panel_channel_s:setPositionY(22)
    local y = self._quickUI.Button_channel:getPositionY()
    local btnHei = self._quickUI.Button_channel:getContentSize().height
    y = y + btnHei/2
    self._quickUI.Panel_channel_s:setPositionY(y)
    self._quickUI.Panel_channel_s:setPositionX(self._quickUI.Button_channel:getPositionX())
    self:InitSelectChannels()
end

function MainPropertyLayout:HideChannels()
    self._quickUI.Panel_channel_s:setVisible(false)
    self._quickUI.Panel_channel_s:setPositionY(-300)
end

function MainPropertyLayout:InitSelectChannels()
    local listChilds = self._quickUI.ListView_channel:getChildren()
    if #listChilds > 0 then
        return
    end
    self._channelCells = {}
    local showChannels = {6} 
    if SL:GetMetaValue("GAME_DATA", "PCShowSelectChannels") and string.len(SL:GetMetaValue("GAME_DATA", "PCShowSelectChannels")) > 0 then
        local list = string.split(SL:GetMetaValue("GAME_DATA","PCShowSelectChannels"), "#")
        for _, index in ipairs(list) do
            if index and tonumber(index) then
                if tonumber(index) == 6 then
                    table.remove(showChannels, 1)
                end
                table.insert(showChannels, tonumber(index))
            end
        end
    end
    if not next(showChannels) then
        self:HideChannels()
        return
    end

    for _, id in ipairs(showChannels) do
        while true do 
            if not self._channelName[id] then
                break
            end

            local name = self._channelName[id]
            local cell = self._quickUI.channel_cell:cloneEx()
            cell:setVisible(true)
            cell:getChildByName("Text_title"):setString(name)
            cell:getChildByName("Image_selected"):setVisible(id == self._proxy:getChannel())

            cell:setTouchEnabled(true)
            cell:addClickEventListener(function()
                self:HideChannels()
                self:SelectChannel(id)
                self:OnRefreshChannelSelect()
            end)
            self._quickUI.ListView_channel:pushBackCustomItem(cell)

            self._channelCells[id] = cell
            break
        end
    end

    local count = #self._quickUI.ListView_channel:getChildren()
    local listWid = self._quickUI.ListView_channel:getContentSize().width
    local listHei = count * (self._quickUI.channel_cell:getContentSize().height)
    self._quickUI.ListView_channel:setContentSize(cc.size(listWid, listHei))
    self._quickUI.Panel_channel_s:setContentSize(cc.size(listWid + 4, listHei + 6))
    self._quickUI.Image_channel_bg:setContentSize(cc.size(listWid + 4, listHei + 6))
    self._quickUI.Image_channel_bg:setPositionY((listHei + 6) / 2)
end

function MainPropertyLayout:OnRefreshChannelSelect()
    local curChannel = self._proxy:getChannel()

    if self._channelCells and next(self._channelCells) then
        for i, cell in pairs(self._channelCells) do
            self._channelCells[i]:getChildByName("Image_selected"):setVisible(i == curChannel)
        end
    end

    local name = self._channelName[curChannel]
    self._quickUI.Text_channel:setString(name)
end

function MainPropertyLayout:UpdateReceiving()
    local receiveChannel = self._proxy:getReceiveChannel()

    -- 选中
    for i = 0, 8 do
        if self._quickUI["Button_channel_" .. i] then
            self._quickUI["Button_channel_" .. i]:setBright(i ~= receiveChannel)
            self._quickUI["Button_channel_" .. i]:setTouchEnabled(i ~= receiveChannel)
        end
    end

    -- 清理
    self._cache = {}
    self._isScrolling = false
    self._quickUI.ListView_chat:removeAllItems()

    -- 消息
    local receiveCache = self._proxy:getPCCache()
    for _, v in ipairs(receiveCache) do
        self:PushChatCell(v)
    end
    self._quickUI.ListView_chat:jumpToBottom()
end

function MainPropertyLayout:SelectChannel(channel)
    self._proxy:setChannel(channel)
    self._channelSelect = channel
    
    local CHANNEL = self._proxy.CHANNEL
    local target  = self._proxy:getTarget()
    local channel = self._proxy:getChannel()
    if channel == CHANNEL.Private and target then
        self:OnPrivateChatWithTarget(target)
    end
end

-- 监听聊天输入框
function MainPropertyLayout:onChatEditHandler()
    self._lastInput = ""
    self._quickUI.TextField_input:addEventListener(function(sender, eventType)
        if eventType == 4 then
            if string.len(self._quickUI.TextField_input:getString()) > 0 then
                self:sendChatMsg()
            end
        elseif eventType == 2 or eventType == 0 then
            local str = sender:getString()
            local target = self._proxy:getTarget()
            if self._lastInput == "" and str == "/" and target then
                self:OnPrivateChatWithTarget(target)
            end
            self._lastInput = str
        end

    end)
end

-- 更新恢复聊天框未聚焦状态:  关闭Keyboard
function MainPropertyLayout:OnRefreshRecoverEditBox()
    if self._quickUI.TextField_input.closeKeyboard then
        self._quickUI.TextField_input:closeKeyboard()
    end
end

-- 发送聊天数据   input：聊天内容
function MainPropertyLayout:sendChatMsg(sendMsg, channelID)    
    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local MSG_TYPE  = ChatProxy.MSG_TYPE
    local channel   = ChatProxy:getChannel()
    local input     = sendMsg or self._quickUI.TextField_input:getString()
    channelID       = channelID or self._channelSelect

    -- 换掉空格
    input = string.trim(input)
    input = string.gsub(input, "[\t\n\r]", "")

    local input = sendMsg or self._quickUI.TextField_input:getString()
    self._quickUI.TextField_input:setString("")

    -- 没有输入
    if string.len(input) <= 0 then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30001020))
        return false
    end

    local function toSendMsg( input, risk_param)
        -- 存储到输入缓存
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        ChatProxy:addInputCache(input)
        self._inputCache = clone(ChatProxy:getInputCache())
        self._inputIndex = #self._inputCache+1

        -- 发送 PC端根据消息内容决定频道
        local MSG_TYPE  = ChatProxy.MSG_TYPE
        local sendData  = {mt = MSG_TYPE.Normal, msg = input, channel = channelID, risk = risk_param}
        global.Facade:sendNotification(global.NoticeTable.SendChatMsg, sendData)

    end

    local sIdx, eIdx = string.find(input, "^@传 .-")
    local special_Str = nil
    if sIdx and eIdx then
        special_Str = string.sub(input, eIdx + 1, string.len(input))
    end

    local channel, content = ChatProxy:getChannelByMsg(input)
    local targetName = ChatProxy:findTargetByMsg(input)

    -- 敏感词
    if not (string.find(input, "^@.-") and not special_Str) then
        -- 后台控制不可聊天
        if IsForbidSay(true) then
            return
        end
        
        local SensitiveWordProxy = global.Facade:retrieveProxy(global.ProxyTable.SensitiveWordProxy)
        local function handle_Func(state, str, risk_param)
            if not str then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(1006))
                return
            end

            if special_Str then
                str = "@传 " .. str
            elseif targetName then
                str = string.format("/%s %s", targetName, str)
            end

            toSendMsg(str, risk_param)
        end
        local data = {}
        data.channel_id = channel
        if channel == ChatProxy.CHANNEL.Private then
            local target = ChatProxy:getTarget()
            if target then
                local targetActor   = global.actorManager:GetActor(target.uid)
                data.to_role_level  = targetActor and targetActor:GetLevel()
                data.to_role_id     = target.uid
                data.to_role_name   = target.name
            end
            input = content
        end
        SensitiveWordProxy:fixSensitiveTalkAddFilter(special_Str or input, handle_Func, nil, data)

    else
        toSendMsg(input)
    end
end

function MainPropertyLayout:handlePressedEnter()
    if self._quickUI.TextField_input then
        self._quickUI.TextField_input:touchDownAction(self._quickUI.TextField_input, 2)
    end
end

function MainPropertyLayout:OnAddChatItem(cell)
    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local CONFIG    = ChatProxy.CONFIG

    -- 是否正在拖动
    local listviewCells = self._quickUI.ListView_chat
    if next(listviewCells:getItems()) then
        local lastItem  = listviewCells:getItem(#listviewCells:getItems() - 1)
        local size      = lastItem:getContentSize()
        local aPoint    = lastItem:getAnchorPoint()
        local worldPosY = lastItem:getWorldPosition().y - (size.height * aPoint.y) 
        local listviewY = listviewCells:getWorldPosition().y
        -- 是否屏幕外
        if worldPosY < listviewY then
            self._isScrolling = true
        end
    end

    if self._isScrolling then
        -- 正在拖动，消息缓存
        cell:retain()
        table.insert(self._chatCellCache, cell)
    
        while #self._chatCellCache > CONFIG.LimitCountWin do
            local cell = table.remove(self._chatCellCache, 1)
            cell:autorelease()
        end
    else
        self:PushChatCell(cell)
        self._quickUI.ListView_chat:jumpToBottom()
    end
end

function MainPropertyLayout:OnRemoveItem(uid)
    if not uid then
        return
    end
    if self._isScrolling then
        if next(self._chatCellCache) then
            for i = #self._chatCellCache, 1, -1 do
                local item = self._chatCellCache[i]
                if item and item.tag == uid then
                    table.remove(self._chatCellCache, i)
                    item:autorelease()
                end
            end
        end
    end
    
    local items = self._quickUI.ListView_chat:getItems()
    local isRemoved = false
    for i, item in ipairs(items) do
        if item and item.tag == uid then
            local index = self._quickUI.ListView_chat:getIndex(item)
            self._quickUI.ListView_chat:removeItem(index)
            isRemoved = true
        end
    end
    if not isRemoved then
        return
    end

    self._quickUI.ListView_chat:jumpToBottom()
    if self._isScrolling then
        self:ShowChatCache()
    end
end

function MainPropertyLayout:PushChatCell(cell)
    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local CONFIG    = ChatProxy.CONFIG

    -- 超出限制，移除先放入的
    self._quickUI.ListView_chat:pushBackCustomItem(cell)
    if #self._quickUI.ListView_chat:getItems() > CONFIG.LimitCountWin then
        self._quickUI.ListView_chat:removeItem(0)
    end
end

function MainPropertyLayout:ShowChatCache()
    -- 缓存填充
    while #self._chatCellCache > 0 do
        local cell = table.remove(self._chatCellCache, 1)
        cell:autorelease()
        self:PushChatCell(cell)
    end
    self._quickUI.ListView_chat:jumpToBottom()
end

function MainPropertyLayout:OnPrivateChatWithTarget(data)
    local prefix = string.format("/%s ", data.name)
    self._quickUI.TextField_input:setString(prefix)
end

function MainPropertyLayout:OnFillChatInput(data)
    if data and string.len(data) > 0 then
        if self._quickUI.TextField_input then
            self._quickUI.TextField_input:setString(data)
        end
    end
end

function MainPropertyLayout:OnShowChatExNotice(data)
    self:CheckChatExNotice()
end

function MainPropertyLayout:CheckChatExNotice()
    local listviewCells = self._quickUI.ListView_chat_ex
    if not listviewCells or #listviewCells:getItems() >= 3 then
        return
    end

    local proxy      = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local chatExItms = proxy:GetChatExItemsData()
    if #chatExItms == 0 then
        self._showLastChatExID = nil
        return
    end

    local chatExId = self._showLastChatExID and (self._showLastChatExID + 1) or 1
    local data = chatExItms[chatExId]
    if not data then
        return
    end

    self._showLastChatExID = chatExId

    data.Time         = data.Time or 5
    if data.Time <= 0 then
        proxy:RemoveChatExItemsData(data, self._showLastChatExID)
        self._showLastChatExID = self._showLastChatExID - 1
        self:CheckChatExNotice()
        return
    end

    data.Label          = data.Label or ""
    data.Y              = data.Y or 0
    data.Count          = data.Count or 1
    data.FColor         = data.FColor or 255
    data.BColor         = data.BColor or 255
    data.SendNameTemp   = data.SendName or ""
    local FColorRGB     = GET_COLOR_BYID_C3B(data.FColor)
    local BColorRGB     = GET_COLOR_BYID_C3B(data.BColor)
    local BColorEnabel  = data.BColor ~= -1
    local capacitySize  = cc.size(MainProperty._chatItemWid or chatItemWid, 12)
    local layout        = ccui.Layout:create()
    layout:setContentSize(capacitySize)
    if BColorEnabel then
        layout:setBackGroundColor(BColorRGB)
        layout:setBackGroundColorType(0)
        layout:setBackGroundColorOpacity(255) 
    end
    
    listviewCells:pushBackCustomItem(layout)
    if MainProperty.RefreshListView then
        MainProperty.RefreshListView()
    end

    local scrollWidget  = ccui.Widget:create()
    layout:addChild(scrollWidget)
    scrollWidget:setContentSize(capacitySize)
    scrollWidget:setAnchorPoint(cc.p(0,0))
    scrollWidget:setPosition(cc.p(0,0))

    local scrollAble = nil
    local scrollSize = cc.size(0,0)
    local remaining  = data.Time
    local Msg = Msg_formatPercent(data.Msg)
    local hasFormat = string.find(Msg,"%%") 
    local showName = data.SendName and (data.SendName .. ": ") or ""
    local function callback()
        remaining = math.min(remaining, data.Time)
        proxy:SyncChatExItemsTime(self._showLastChatExID, data.chatExId, remaining)

        local name = showName or ""
        local str = name..(hasFormat and string.format(Msg, remaining) or Msg)
        local fontSize = SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE")
        local richText = RichTextHelp:CreateRichTextWithFCOLOR(str, 1000, fontSize, FColorRGB, nil, nil, nil, fontpath, {outlineSize = 0}, nil, self._richVspace or 0)
        richText:setTouchEnabled(true)
        richText:addClickEventListener(function()
            local mainPlayerID = global.gamePlayerController:GetMainPlayerID()
            if data.SendId and data.SendName and data.SendId ~= mainPlayerID then
                global.Facade:sendNotification(global.NoticeTable.PrivateChatWithTarget, {name = data.SendNameTemp, uid = data.SendId})
            else
                local msg = string.format(data.Msg, remaining)
                global.Facade:sendNotification(global.NoticeTable.PCFillChatInput, msg)
            end
        end)
        scrollWidget:removeAllChildren()
        scrollWidget:addChild(richText)
        richText:setAnchorPoint({x = 0, y = 0.5})
        richText:setPosition(cc.p(0, math.floor(capacitySize.height/2)))
        if BColorEnabel then
            richText:setBackgroundColor(BColorRGB)
            richText:setBackgroundColorEnable(true)
        end
        richText:formatText()
        refPositionByParent(richText)
        if scrollAble == nil then
            scrollSize  = richText:getContentSize()
            scrollAble  = scrollSize.width > capacitySize.width
        end

        if remaining < 0 then
            listviewCells:removeItem(listviewCells:getIndex(layout))
            if MainProperty.RefreshListView then
                MainProperty.RefreshListView()
            end

            proxy:RemoveChatExItemsData(data, self._showLastChatExID)
            self._showLastChatExID = self._showLastChatExID - 1
            self:CheckChatExNotice()
        end

        remaining = remaining - 1
    end
    schedule(layout, callback, 1)
    callback()

    -- 滚动
    if scrollAble then
        local actionT = (scrollSize.width - capacitySize.width) / 50
        local action  = cc.Sequence:create(
            cc.MoveTo:create(actionT, cc.p(capacitySize.width - scrollSize.width, 0)),
            cc.DelayTime:create(3),
            cc.MoveTo:create(0, cc.p(0, 0))
        )
        scrollWidget:runAction(cc.RepeatForever:create(action))
    end
end

--------------------------------------------------------------------
function MainPropertyLayout:InitQuickUse()
    local showNum = 0
    if self._quickUI.Panel_quick and self._quickUI.Panel_quick:isVisible() then
        for i = 1, 6 do
            local layout = self._quickUI[string.format("Panel_quick_use_%s", i)]
            if layout and layout:isVisible() then
                showNum = showNum + 1
                local nodeItem = cc.Node:create()
                layout:addChild(nodeItem)
                local contentSize = layout:getContentSize()
                nodeItem:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
                self._quickUseCells[i] = {layout = layout, nodeItem = nodeItem}

                local layoutSwallow = ccui.Layout:create()
                layout:addChild(layoutSwallow)
                layoutSwallow:setContentSize(contentSize)
                layoutSwallow:setAnchorPoint(cc.p(0.5,0.5))
                layoutSwallow:setPosition(cc.p(contentSize.width*0.5, contentSize.height*0.5))
                layoutSwallow:setTouchEnabled(true)
                layoutSwallow:setSwallowTouches(false)
                layoutSwallow._noAutoRegisterMouseSwollow = true

                local function addItemIntoBag(touchPos)
                    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
                    local state = ItemMoveProxy:GetMovingItemState()
                    local canMove = layout and layout:isVisible()
                    if state and canMove then
                        local goToName      = ItemMoveProxy.ItemGoTo.QUICK_USE
                        local ndata         = {}
                        ndata.target        = goToName
                        ndata.pos           = touchPos
                        ndata.posInQuickUse = i
                        ItemMoveProxy:CheckAndCallBack( ndata )
                    else
                        return -1
                    end
                end
                local function setNoswallowMouse()
                    return -1
                end
                global.mouseEventController:registerMouseButtonEvent(
                    layoutSwallow,
                    {
                        down_r = setNoswallowMouse,
                        special_r = addItemIntoBag
                    }
                )
            end
        end
    end
    SL:SetMetaValue("QUICK_USE_NUM", showNum)

    self:UpdateQuickUse()
end

function MainPropertyLayout:UpdateQuickUse()
    for k, v in pairs(self._quickUseCells) do
        v.nodeItem:removeAllChildren()
    end

    local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
    local quickUseData = QuickUseProxy:GetQuickUseData()
    for k, v in pairs(quickUseData) do
        self:AddQuickUseItem({index = k, itemData = v})
    end

end

function MainPropertyLayout:AddQuickUseItem(data)
    local cell = self._quickUseCells[data.index]
    local function dealSpecialQuickUse()
        local index = data.index
        local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
        local size = QuickUseProxy:GetQuickUseSize()
        local quickUseData = QuickUseProxy:GetQuickUseData()
        local quickUseList = QuickUseProxy:GetQuickUseLocalList()

        local replaceCell = nil
        for i = 1, size do
            if not quickUseData[i] and self._quickUseCells[i] and i ~= index then
                replaceCell = self._quickUseCells[i]
                cell = replaceCell
                quickUseData[i] = quickUseData[index]
                quickUseData[index] = nil

                quickUseList[i] = quickUseList[index]
                quickUseList[index] = 0
                QuickUseProxy:SetQuickPosMarkData()
                break
            end
        end

        -- 无替代则放回背包
        if not replaceCell then
            local bagProxy  = global.Facade:retrieveProxy(global.ProxyTable.Bag)
            local item = data.itemData
            bagProxy:AddItemData(item)
            
            --清数据
            quickUseList[index] = 0
            QuickUseProxy:SetQuickPosMarkData()

            return true
        end
    end

    if not cell then
        if dealSpecialQuickUse() then
            return
        end
    end

    local function getCount(item)
        if item.OverLap > 1 then
            return item.OverLap
        end

        if item.StdMode == 2 and item.Dura > 0 then --使用次数
            return item.Dura < 1000 and 1 or math.floor(item.Dura / 1000)
        end
        return 0
    end

    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    local info      = {}
    info.from       = ItemMoveProxy.ItemFrom.QUICK_USE
    info.movable    = true
    info.index      = data.itemData.Index
    info.itemData   = data.itemData
    local goodsItem = GoodsItem:create(info)
    cell.nodeItem:removeAllChildren()
    cell.nodeItem:addChild(goodsItem)
    goodsItem:setCount(getCount(data.itemData))
    global.mouseEventController:registerMouseButtonEvent(
        goodsItem,
        {
            double_l = function()
                SL:RequestUseItem(data.itemData)
            end,
            up_r = function()
                SL:RequestUseItem(data.itemData)
            end,
        }
    )

    -- 延迟0.15s显示goodsitem
    goodsItem:setVisible(false)
    goodsItem:stopAllActions()
    performWithDelay(goodsItem, function()
        goodsItem:setVisible(true)
    end, 0.15)

    cell.goodsItem = goodsItem
end

function MainPropertyLayout:RmvQuickUseItem(data)
    local cell = self._quickUseCells[data.index]
    if not cell then
        return
    end
    cell.nodeItem:removeAllChildren()
end

function MainPropertyLayout:ChangeQuickUseItem(data)
    self:RmvQuickUseItem(data)
    self:AddQuickUseItem(data)
end

function MainPropertyLayout:RefreshQuickUseItem(data)
    local cell = self._quickUseCells[data.pos]
    if not cell then
        return
    end
    cell.goodsItem:resetMoveState(data.state == 0)
end

function MainPropertyLayout:Cleanup()
end

function MainPropertyLayout:OnAddQuitTimeTips( data )
    if not data or not data.time or not data.type then
        return
    end
    local time 
    local type = data.type  -- 1 小退 2 大退

    if self._quickUI.Node_quit_tip then
        self._quickUI.Node_quit_tip:stopAllActions()
        local function refreshTime()
            if not time then
                time = data.time
            else 
                time = time - 1
            end
            local str = string.format(GET_STRING(700000110 + type), time)
            self._quickUI.Node_quit_tip:removeAllChildren()
            local width = global.Director:getVisibleSize().width
            local richText = RichTextHelp:CreateRichTextWithXML(str, width, (SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE") or 16) + 1, "#ffffff")
            richText:setAnchorPoint(0.5, 0)
            richText:formatText()
            self._quickUI.Node_quit_tip:addChild(richText)
        end
        schedule(self._quickUI.Node_quit_tip, refreshTime, 1)
        refreshTime()
    end
end

function MainPropertyLayout:OnRemoveQuitTimeTips()
    if self._quickUI.Node_quit_tip then
        self._quickUI.Node_quit_tip:stopAllActions()
        self._quickUI.Node_quit_tip:removeAllChildren()
    end
end

function MainPropertyLayout:OnMainExChatClean()
    if self._quickUI.ListView_chat_ex then 
        self._quickUI.ListView_chat_ex:stopAllActions()
        self._quickUI.ListView_chat_ex:removeAllItems()
        self._showLastChatExID = nil
    end
end

function MainPropertyLayout:AfterCUILoadFunc()
    self:InitAdapet()
    self:InitQuickUse()
end

function MainPropertyLayout:UpdatePickupVisible(visible)
    if self._quickUI.Button_pick then
        self._quickUI.Button_pick:setVisible(visible)
    end
end

return MainPropertyLayout
