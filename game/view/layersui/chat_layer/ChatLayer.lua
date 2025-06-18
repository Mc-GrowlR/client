local BaseLayer = requireLayerUI("BaseLayer")
local ChatLayer = class("ChatLayer", BaseLayer)

local RichTextHelp = requireUtil("RichTextHelp")
local DROP_TOTAL_TYPE_ID = 99

function ChatLayer:ctor()
    ChatLayer.super.ctor(self)

    self._path         = global.MMO.PATH_RES_PRIVATE .. "chat/"
    self._proxy        = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    self._cache        = {}
    self._inputCache   = {}
    self._receiveCells = {}
    self._guildTipsT   = 0
    self._listHei      = 475
    self._listY        = 635
    self._showLastChatExID = nil    -- 固定聊天最后显示的id
    
    self._exData = {}
    self._chatExId = 0
end

function ChatLayer.create()
    local layer = ChatLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function ChatLayer:Init()
    self._quickUI = ui_delegate(self)
    return true
end

function ChatLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_CHAT)
    local meta = {}
    meta.SetReceiveChannel = handler(self, self.SetReceiveChannel)
    meta.__index = meta
    setmetatable(Chat, meta)
    Chat.main()


    -- 初始化数据
    self._listHei = self._quickUI.ListView_cells:getContentSize().height
    self._listY   = self._quickUI.ListView_cells:getPositionY()
    self._listInterval, self._richVspace = self._proxy:GetChatParam()

    self:InitChat()
    self:InitInput()
    self:UpdateReceiving()
    self:InitExData()
    self:CheckChatExNotice(true)
end

function ChatLayer:OnWindowResized()
    if Chat and Chat.InitAdapet then
        Chat.InitAdapet()
    end
end

function ChatLayer:OnDRotationChanged()
    if Chat and Chat.InitAdapet then
        Chat.InitAdapet()
    end
end

function ChatLayer:InitChat()
    if self._listInterval then
        self._quickUI.ListView_cells:setItemsMargin(self._listInterval)
        self._quickUI.ListView_ex:setItemsMargin(self._listInterval)
    end
    -- 拖动
    local function listCallback(sender, eventType)
        if eventType == 9 or eventType == 10 then
            local innerPos = self._quickUI.ListView_cells:getInnerContainerPosition()
            if innerPos.y == 0 and self._isScrolling then
                self._isScrolling = false
                self:ShowCache()
            end
        end
    end
    self._quickUI.ListView_cells:addScrollViewEventListener(listCallback)

    self._quickUI.ListView_cells:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.Layer_ChatExtend_Exit)
    end)
end

function ChatLayer:InitInput()
    -- 历史记录
    self._inputCache = clone(self._proxy:getInputCache())
    self._quickUI.Button_input_5:addClickEventListener(function()
        if #self._inputCache == 0 then
            return
        end
        local cache = table.remove(self._inputCache, #self._inputCache)
        self._quickUI.TextField_input:setString(cache)
    end)

    -- 发送
    self._quickUI.Button_send:addClickEventListener(function()
        local input = self._quickUI.TextField_input:getString()
        self._quickUI.TextField_input:setString("")

        -- 没有输入
        if string.len(input) <= 0 then
            global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30001020))
            return false
        end

        local function sendChatMsg(input, risk_param)
            -- 存储到输入缓存
            local chatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
            chatProxy:addInputCache(input)
            self._inputCache = clone(chatProxy:getInputCache())

            -- 发送
            local channel = chatProxy:getChannel()
            local MSG_TYPE = chatProxy.MSG_TYPE
            local sendData = { mt = MSG_TYPE.Normal, msg = input, channel = channel, risk = risk_param }
            global.Facade:sendNotification(global.NoticeTable.SendChatMsg, sendData)
        end

        local sIdx, eIdx = string.find(input, "^@传 .-")
        local special_Str = nil
        if sIdx and eIdx then
            special_Str = string.sub(input, eIdx + 1, string.len(input))
        end

        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        local channelID, content = ChatProxy:getChannelByMsg(input)
        local targetName = ChatProxy:findTargetByMsg(input)

        -- 敏感词
        if not (string.find(input, "^@.-") and not special_Str) then
            -- 后台控制不可聊天
            if IsForbidSay(true) then
                return
            end

            local SensitiveWordProxy = global.Facade:retrieveProxy(global.ProxyTable.SensitiveWordProxy)
            local chatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
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

                sendChatMsg(str, risk_param)
            end

            local data = {}
            local channel = chatProxy:getChannel()
            data.channel_id = channel
            if channel == chatProxy.CHANNEL.Private then
                local target = chatProxy:getTarget()
                if target then
                    local targetActor = global.actorManager:GetActor(target.uid)
                    data.to_role_level = targetActor and targetActor:GetLevel()
                    data.to_role_id    = target.uid
                    data.to_role_name  = target.name
                end
            end
            if channelID == chatProxy.CHANNEL.Private then
                input = content
            end
            SensitiveWordProxy:fixSensitiveTalkAddFilter(special_Str or input, handle_Func, nil, data)
        else
            sendChatMsg(input)
        end
    end)

    -- 自动喊话
    if self._quickUI.Layout_check_auto_shout and self._quickUI.Layout_check_auto_shout:isVisible() then
        local checkNomal    = self._quickUI.Layout_check_auto_shout:getChildByName("Layout_nomal")
        local checkSelect   = self._quickUI.Layout_check_auto_shout:getChildByName("Layout_select")
        local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        -- 改变自动喊话按钮
        local function changeAutoShoutButton()
            local isOpen = ChatProxy:GetAutoShoutSwitch()
            checkNomal:setVisible(not isOpen)
            checkSelect:setVisible( isOpen )
        end

        local isAutoShout  = ChatProxy:GetAutoShoutSwitch()
        self._quickUI.Layout_check_auto_shout:addClickEventListener(function(sender)
            local channel = ChatProxy.CHANNEL.Shout
            ChatProxy:SetAutoShoutSwitch(channel, not ChatProxy:GetAutoShoutSwitch())

            --记录自动喊话内容
            local input = self._quickUI.TextField_input:getString()
            ChatProxy:setLocalChatDataData( channel, input or "" )

            -- 发送提示
            local isOpen = ChatProxy:GetAutoShoutSwitch()
            local CHANNEL = ChatProxy.CHANNEL
            local data = {}
            data.ChannelId = CHANNEL.System
            data.Msg = isOpen and GET_STRING(30001072) or GET_STRING(30001073)
            global.Facade:sendNotification(global.NoticeTable.AddChatItem, data)
            global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type = global.MMO.SND_TYPE_BTN_CLICK})

            global.Facade:sendNotification(global.NoticeTable.Chat_Refresh_Mobile_AutoShout)

            changeAutoShoutButton()
            if isOpen then
                if input == "" then
                    return
                end
            end
        end)

        changeAutoShoutButton()

        global.Facade:sendNotification(global.NoticeTable.Chat_Refresh_Mobile_AutoShout, {openChat = true})
    end
end

function ChatLayer:SetReceiveChannel(channel)
    self._proxy:setReceiveChannel(channel)
    self:UpdateReceiving()
end

function ChatLayer:UpdateReceiving()
    local CHANNEL = self._proxy.CHANNEL
    local receiveChannel = self._proxy:getReceiveChannel()

    if receiveChannel == CHANNEL.Private then
        global.Facade:sendNotification(global.NoticeTable.BubbleTipsStatusChange, {id = 14, status = false})
    end

    -- 选中的
    if Chat and Chat._receiveCells then
        for channel, cell in pairs(Chat._receiveCells) do
            GUI:Button_setBrightEx(cell.channelBtn, receiveChannel ~= channel)
        end
        if Chat._ui and Chat._ui.Panel_drop_t then
            GUI:setVisible(Chat._ui.Panel_drop_t, receiveChannel == CHANNEL.Drop)
        end
    end

    -- 清理
    self._cache = {}
    self._isScrolling = false
    self._quickUI.ListView_cells:removeAllItems()

    -- 消息
    local receiveCache = self._proxy:getCache()
    for _, v in ipairs(receiveCache) do
        self:pushItem(v)
    end
    self._quickUI.ListView_cells:jumpToBottom()
end

function ChatLayer:AddInput(str)
    local CONFIG = self._proxy.CONFIG
    local textInput = self._quickUI.TextField_input

    -- 是否超出上限
    if string.utf8len(textInput:getString() .. str) > CONFIG.InputLength then
        global.Facade:sendNotification(global.NoticeTable.SystemTips, GET_STRING(30001030))
    else
        textInput:setString(textInput:getString() .. str)
    end
end

function ChatLayer:ReplaceInput(str)
    local textInput = self._quickUI.TextField_input
    textInput:setString(str)
end

function ChatLayer:GetInput()
    return self._quickUI.TextField_input:getString()
end

function ChatLayer:UpdateCDTime()
    if Chat and Chat.UpdateCDTime then
        Chat.UpdateCDTime()
    end
end

function ChatLayer:AddItem(item, channel, dropType)

    -- 是否正在拖动
    local listviewCells = self._quickUI.ListView_cells
    if next(listviewCells:getItems()) then
        local lastItem = listviewCells:getItem(#listviewCells:getItems() - 1)
        local csize    = lastItem:getContentSize()
        local worldPosY = lastItem:getWorldPosition().y
        local listviewY = listviewCells:getWorldPosition().y - listviewCells:getContentSize().height
        -- 是否屏幕外
        if worldPosY < listviewY then
            self._isScrolling = true
        end
    end

    if self._isScrolling then
        -- 正在拖动，消息缓存
        item:retain()
        table.insert(self._cache, item)

        while #self._cache > self._proxy.CONFIG.LimitCount do
            local item = table.remove(self._cache, 1)
            item:autorelease()
        end
    else
        self:pushItem(item)
        self._quickUI.ListView_cells:jumpToBottom()
    end
end

function ChatLayer:RemoveItem(uid)
    if not uid then
        return
    end
    if self._isScrolling then
        if next(self._cache) then
            for i = #self._cache, 1, -1 do
                local item = self._cache[i]
                if item and item.tag == uid then
                    table.remove(self._cache, i)
                    item:autorelease()
                end
            end
        end
    end
    
    local items = self._quickUI.ListView_cells:getItems()
    local isRemoved = false
    for i, item in ipairs(items) do
        if item and item.tag == uid then
            local index = self._quickUI.ListView_cells:getIndex(item)
            self._quickUI.ListView_cells:removeItem(index)
            isRemoved = true
        end
    end
    if not isRemoved then
        return
    end

    self._quickUI.ListView_cells:jumpToBottom()
    if self._isScrolling then
        self:ShowCache()
    end
end

function ChatLayer:ShowCache()
    -- 缓存填充
    while #self._cache > 0 do
        local item = table.remove(self._cache, 1)
        item:autorelease()
        self:pushItem(item)
    end
    self._quickUI.ListView_cells:jumpToBottom()
end

function ChatLayer:pushItem(item)
    local CONFIG = self._proxy.CONFIG
    self._quickUI.ListView_cells:pushBackCustomItem(item)
    performWithDelay(self._quickUI.ListView_cells, function()
        if #self._quickUI.ListView_cells:getItems() > CONFIG.LimitCount then
            self._quickUI.ListView_cells:removeItem(0)
        end
        self._quickUI.ListView_cells:jumpToBottom()
    end, 0)
end

function ChatLayer:OnShowChatExNotice()
    self:CheckChatExNotice()
end

function ChatLayer:InitExData()
    self._exData = clone(self._proxy:GetChatExItemsData())
    for _, data in ipairs(self._exData) do
        self._chatExId = self._chatExId + 1
        data.chatExId = self._chatExId
    end
end

function ChatLayer:GetChatExItemsData()
    return self._exData
end

function ChatLayer:RemoveChatExItemsData(data, index)
    if not data then
        return
    end
    local chatExId = data.chatExId
    for i = 1, index do
        if chatExId == (self._exData[i] and self._exData[i].chatExId) then
            local t = table.remove(self._exData, i)
            break
        end
    end
end

function ChatLayer:AddChatExItemsData( data )
    table.insert(self._exData, data)
    self._chatExId = self._chatExId + 1
    data.chatExId = self._chatExId
end

function ChatLayer:CheckChatExNotice(isInit)
    local listviewCells = self._quickUI.ListView_ex
    if #listviewCells:getItems() >= 3 then
        return
    end

    local chatExItms = self:GetChatExItemsData()
    if #chatExItms == 0 then
        self._showLastChatExID = nil
        local cWidth = listviewCells:getContentSize().width
        listviewCells:setContentSize(cc.size(cWidth, 0))
        return
    end
    local chatExId = self._showLastChatExID and (self._showLastChatExID + 1) or 1
    local data = chatExItms[chatExId]
    if not data then
        return
    end

    self._showLastChatExID = chatExId

    data.Time = data.Time or 5
    if data.Time <= 0 then
        self:RemoveChatExItemsData(data, self._showLastChatExID)
        self._showLastChatExID = self._showLastChatExID - 1
        self:CheckChatExNotice()
        return
    end
    
    data.Label        = data.Label or ""
    data.Y            = data.Y or 0
    data.Count        = data.Count or 1
    data.FColor       = data.FColor or 255
    data.BColor       = data.BColor or 255
    data.SendNameTemp = data.SendName or ""

    local BColorEnable = data.BColor ~= -1
    local FColorRGB    = GET_COLOR_BYID_C3B(data.FColor)
    local BColorRGB    = GET_COLOR_BYID_C3B(data.BColor)
    local cWidth       = listviewCells:getContentSize().width
    local capacitySize = cc.size(cWidth, 17)

    local function resetListview()
        local items = listviewCells:getItems()
        local height = 0
        local margin = listviewCells:getItemsMargin()
        for i, v in ipairs(items) do
            local interval = i ~= #items and margin or 0
            height = height + v:getContentSize().height + interval
        end
        listviewCells:setContentSize(cc.size(capacitySize.width, height))

        local listviewSize = self._quickUI.ListView_cells:getContentSize()
        self._quickUI.ListView_cells:setContentSize(cc.size(listviewSize.width, self._listHei - height))
        self._quickUI.ListView_cells:setPositionY(self._listY - height)
        self._quickUI.ListView_cells:jumpToBottom()
    end

    local layout = ccui.Layout:create()
    layout:setContentSize(capacitySize)
    if BColorEnable then
        layout:setBackGroundColor(BColorRGB)
        layout:setBackGroundColorType(0)
        layout:setBackGroundColorOpacity(255)
    end

    listviewCells:pushBackCustomItem(layout)
    resetListview()

    local scrollWidget = ccui.Widget:create()
    layout:addChild(scrollWidget)
    scrollWidget:setContentSize(capacitySize)
    scrollWidget:setAnchorPoint(cc.p(0, 0))
    scrollWidget:setPosition(cc.p(0, 0))

    local scrollAble = nil
    local scrollSize = cc.size(0, 0)
    local remaining = data.Time
    local showName = data.SendName and (data.SendName .. ": ") or ""
    local function callback()

        local name = showName or ""
        local str  = name .. string.format(data.Msg, remaining)
        local fontSize = SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE") or 16
        local richText = RichTextHelp:CreateRichTextWithFCOLOR(str, 1000, fontSize, FColorRGB, {outlineSize = 0}, nil, self._richVspace or 0)
        richText:setTouchEnabled(true)
        richText:addClickEventListener(function()
            if data.SendName and data.SendId then
                global.Facade:sendNotification(global.NoticeTable.PrivateChatWithTarget, { name = data.SendNameTemp, uid = data.SendId })
            end
        end)
        scrollWidget:removeAllChildren()
        scrollWidget:addChild(richText)
        richText:setAnchorPoint({ x = 0, y = 0.5 })
        richText:setPosition(cc.p(0, capacitySize.height / 2))
        if BColorEnable then
            richText:setBackgroundColor(BColorRGB)
            richText:setBackgroundColorEnable(true)
        end
        if scrollAble == nil then
            richText:formatText()
            scrollSize = richText:getContentSize()
            scrollAble = scrollSize.width > capacitySize.width
        end
        local richTextsize = richText:getContentSize()
        scrollWidget:setContentSize(capacitySize.width, richTextsize.height)
        layout:setContentSize(capacitySize.width, richTextsize.height)
        if remaining < 0 then
            listviewCells:removeItem(listviewCells:getIndex(layout))
            resetListview()
            self:RemoveChatExItemsData(data, chatExId)
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
        local action = cc.Sequence:create(
            cc.MoveTo:create(actionT, cc.p(capacitySize.width - scrollSize.width, 0)),
            cc.DelayTime:create(3),
            cc.MoveTo:create(0, cc.p(0, 0))
        )
        scrollWidget:runAction(cc.RepeatForever:create(action))
    end

    if isInit then
        self:CheckChatExNotice(isInit)
    end
end

function ChatLayer:SwitchToPrivateChannel(channel)
    self:SetReceiveChannel(channel)

    local CHANNEL = self._proxy.CHANNEL
    if (channel ~= CHANNEL.Common and channel ~= CHANNEL.System) then
        if Chat and Chat.HideChannels and Chat.SelectChannel then
            Chat.HideChannels()
            Chat.SelectChannel(channel)
        end
    end
end

function ChatLayer:OnMainExChatClean()
    if self._quickUI.ListView_ex then
        self._quickUI.ListView_ex:stopAllActions()
        self._quickUI.ListView_ex:removeAllItems()
        self._showLastChatExID = nil
        self._exData = {}
    end
end

function ChatLayer:OnChatFakeDropChange()
    local receiveChannel = self._proxy:getReceiveChannel()
    local CHANNEL = self._proxy.CHANNEL
    if receiveChannel == CHANNEL.Drop then
        if Chat and Chat.RefreshFakeDropType then
            Chat.RefreshFakeDropType()
        end
    end
end

return ChatLayer