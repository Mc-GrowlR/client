local BaseUIMediator = requireMediator("BaseUIMediator")
local ChatMediator = class("ChatMediator", BaseUIMediator)
ChatMediator.NAME = "ChatMediator"

local ChatParseHelp = requireView("layersui/chat_layer/ChatParseHelp")
local PARSE_INTERVAL = 1/50
local Queue                     = requireUtil( "queue" )

function ChatMediator:ctor()
    ChatMediator.super.ctor(self)

    self._parseItems = Queue.new()
    self._parseEnable = true
    
    self._parseSystemItems = Queue.new()
    self._parseSystemEnable = true

    self._parseMiniItems = Queue.new()
    self._parseMiniEnable = true

    self._parsePCPItems = Queue.new()
    self._parsePCPEnable = true
end

function ChatMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_Chat_Open,
        noticeTable.Layer_Chat_Close,
        noticeTable.Layer_Chat_EnterCD,
        noticeTable.Layer_Chat_PushInput,
        noticeTable.Layer_Chat_ReplaceInput,
        noticeTable.SendChatMsg,
        noticeTable.AddChatItem,
        noticeTable.ChatTargetChange,
        noticeTable.PrivateChatWithTarget,
        noticeTable.ReleaseMemory,
        noticeTable.WindowResized,
        noticeTable.PlayerPropertyInited,
        noticeTable.DRotationChanged,
        noticeTable.ShowChatExNotice,
        noticeTable.AddChatExItem,
        noticeTable.MainExChatClean,
        noticeTable.ChatFakeDropChange,
        noticeTable.Layer_Chat_RemoveItem,
    }
end

function ChatMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeTable.Layer_Chat_Open == noticeID then
        self:OnOpen(data)

    elseif noticeTable.Layer_Chat_Close == noticeID then
        self:OnClose()

    elseif noticeTable.Layer_Chat_EnterCD == noticeID then
        self:OnEnterCD()

    elseif noticeTable.Layer_Chat_PushInput == noticeID then
        self:OnPushInput(data)

    elseif noticeTable.Layer_Chat_ReplaceInput == noticeID then
        self:OnReplaceInput(data)

    elseif noticeTable.SendChatMsg == noticeID then
        self:OnSendChatMsg(data)

    elseif noticeTable.AddChatItem == noticeID then
        ssr.ssrBridge:OnAddChatItem(data)
        self:OnAddChatItem(data)

    elseif noticeTable.ChatTargetChange == noticeID then
        self:OnChatTargetChange(data)

    elseif noticeTable.PrivateChatWithTarget == noticeID then
        self:OnPrivateChatWithTarget(data)

    elseif noticeTable.ReleaseMemory == noticeID then
        self:OnReleaseMemory()

    elseif noticeTable.WindowResized == noticeID then
        self:OnWindowResized(data)

    elseif noticeTable.PlayerPropertyInited == noticeID then
        self:OnPlayerPropertyInited(data)

    elseif noticeTable.DRotationChanged == noticeID then
        self:OnDRotationChanged(data)

    elseif noticeTable.ShowChatExNotice == noticeID then
        self:OnShowChatExNotice(data)
    
    elseif noticeTable.AddChatExItem == noticeID then
        self:OnAddChatExItem( data )
    
    elseif noticeTable.MainExChatClean == noticeID then
        self:OnMainExChatClean(data)
    
    elseif noticeTable.ChatFakeDropChange == noticeID then
        self:OnChatFakeDropChange()
    
    elseif noticeTable.Layer_Chat_RemoveItem == noticeID then
        self:OnRemoveItem(data)
    end
end

function ChatMediator:OnOpen(channel)
    if not (self._layer) then
        self._layer = requireLayerUI("chat_layer/ChatLayer").create()

        local data = {}
        data.child = self._layer
        data.index = global.MMO.MAIN_NODE_CHAT_MAIN
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)

        GUI.ATTACH_PARENT = self._layer
        self._layer:InitGUI()

        -- 设置聊天状态为 打开
        local proxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        proxy:setIsChatting(true)

        -- 草稿填入
        self:OnPushInput(proxy:getInputDraft())

        if channel and tonumber(channel) then
            self._layer:SwitchToPrivateChannel(tonumber(channel))
        end
    end
end

function ChatMediator:OnClose()
    if not self._layer then
        return false
    end

    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)

    -- 状态: 关闭
    proxy:setIsChatting(false)

    -- 草稿存储
    proxy:setInputDraft(self._layer:GetInput())

    global.Facade:sendNotification(global.NoticeTable.Layer_ChatExtend_Exit)

    self._layer:removeFromParent()
    self._layer = nil
end

function ChatMediator:OnEnterCD()
    if self._layer then
        self._layer:UpdateCDTime()
    end
end

function ChatMediator:OnPushInput(input)
    if self._layer then
        self._layer:AddInput(input)
    end
end

function ChatMediator:OnSendChatMsg(data)
    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local CHANNEL = proxy.CHANNEL
    local MSG_TYPE = proxy.MSG_TYPE

    local MapProxy = global.Facade:retrieveProxy(global.ProxyTable.Map)
    if MapProxy:IsForbidSay() then
        -- exclude gm
        if not (type(data.msg) == "string" and string.find(data.msg, "^@.-")) then
            ShowSystemChat(GET_STRING(30001069), 255, 249)
            return nil
        end
    end

    if not data or not data.msg then
        print("error: function ChatMediator:OnSendChatMsg(data) 1")
        return nil
    end

    data.mt        = data.mt or MSG_TYPE.Normal
    data.msg       = (data.mt == nil or data.mt == MSG_TYPE.Normal) and proxy:fixSay(data.msg) or data.msg
    data.originMsg = data.msg

    -- PC端指定频道, 但内容为私聊则发送私聊
    if global.isWinPlayMode and data.channel and type(data.msg) == "string" then
        local channel, content = proxy:getChannelByMsg(data.msg)
        if channel and channel == CHANNEL.Private then
            data.msg     = content
            data.channel = channel

            local targetName = proxy:findTargetByMsg(data.originMsg)
            if targetName then
                proxy:addTarget({ name = targetName })
            end
        end
    end

    -- PC端不指定频道，由内容决定
    if global.isWinPlayMode and nil == data.channel and type(data.msg) == "string" then
        local channel, content = proxy:getChannelByMsg(data.msg)
        channel      = channel or CHANNEL.Near
        data.msg     = content
        data.channel = channel

        if data.channel == CHANNEL.Private then
            local targetName = proxy:findTargetByMsg(data.originMsg)
            if targetName then
                proxy:addTarget({ name = targetName })
            end
        end
    end

    -- 兼容PC端前缀
    if not global.isWinPlayMode and (data.mt == nil or data.mt == MSG_TYPE.Normal) then
        local channel, content = proxy:getChannelByMsg(data.msg)
        if channel and channel ~= CHANNEL.Private then
            data.msg     = content
            data.channel = channel
        end
    end

    -- 手机端添加 任何频道都能私聊的功能
    if not global.isWinPlayMode and type(data.msg) == "string" then
        local channel, content = proxy:getChannelByMsg(data.msg)
        if channel and channel == CHANNEL.Private then
            data.msg     = content
            data.channel = channel
            local targetName = proxy:findTargetByMsg(data.originMsg)
            if targetName then
                proxy:addTarget({ name = targetName })
            end
        end
    end

    if not data.channel then
        print("error: function ChatMediator:OnSendChatMsg(data) 2")
        return nil
    end

    -- 是否可发送
    if not proxy:CheckAbleToSay(data.channel) then
        local checkMsg = data.originMsg or data.msg or ""
        if not (type(checkMsg) == "string" and string.sub(checkMsg, 1, 1) == "@") then -- 如果是@开头的GM命令，要进行发送
            return nil
        end
    end

    -- 消息结构
    local item     = {}
    item.mt        = data.mt
    item.Msg       = data.msg
    item.ChannelId = data.channel

    -- 行会
    if data.channel == CHANNEL.Guild then
        local GuildPlayerProxy = global.Facade:retrieveProxy(global.ProxyTable.GuildPlayerProxy)
        if not GuildPlayerProxy:IsJoinGuild() then
            ShowSystemTips(GET_STRING(30001044))
            return nil
        end
    end
    -- 队伍
    if data.channel == CHANNEL.Team then
        local TeamProxy = global.Facade:retrieveProxy(global.ProxyTable.TeamProxy)
        if not TeamProxy:IsTeamMember() then
            ShowSystemTips(GET_STRING(30001045))
            return nil
        end
    end
    -- 私聊
    if data.channel == CHANNEL.Private then
        local target = proxy:getTarget()
        if not target then
            ShowSystemTips(GET_STRING(30001046))
            return nil
        end
        -- 黑名单
        local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
        if FriendProxy:isInBlacklist(target.uid) then
            ShowSystemTips(GET_STRING(30001075))
            return nil
        end

        item.Target     = target.name
        item.TargetID   = target.uid
        proxy:setTargetName(target.name or "")
    end

    if data.channel == CHANNEL.Nation then
        local PlayerProperty = global.Facade:retrieveProxy(global.ProxyTable.PlayerProperty)
        if not PlayerProperty:IsJoinNation() then
            ShowSystemTips(GET_STRING(30001074))
            return
        end
    end

    -- 风险等级
    item.risk = data.risk

    -- send...
    proxy:SendMsg(item)

    -- cd... exclude gm
    if not (type(data.msg) == "string" and string.find(data.msg, "^@.-")) then
        proxy:EnterCD(data.channel)
    end
end

function ChatMediator:OnAddChatExItem( data )
    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    proxy:AddChatExItemsData( data )
    if self._layer then
        self._layer:AddChatExItemsData(data)
    end
    global.Facade:sendNotification(global.NoticeTable.ShowChatExNotice, data)
end

function ChatMediator:OnAddChatItem(data)
    if not data then
        return
    end

    data.FColor     = data.FColor or 0
    data.BColor     = data.BColor or 255
    
    local proxy     = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local CONFIG    = proxy.CONFIG
    local CHANNEL   = proxy.CHANNEL

    -- receiving
    if not proxy:isReceiving(data.ChannelId) then
        return false
    end

    if data.ChannelId == proxy.CHANNEL.Drop and data.dropType and not proxy:GetDropTypeSwitch(data.dropType) then
        return false
    end

    -- 黑名单
    local FriendProxy = global.Facade:retrieveProxy(global.ProxyTable.FriendProxy)
    if data.SendId and data.SendName and FriendProxy:isInBlacklist(data.SendId) then
        return false
    end

    -- item
    if data.ChannelId ~= CHANNEL.System and data.ChannelId ~= CHANNEL.Drop then
        self._parseItems:push(data)
        while self._parseItems:size() > CONFIG.LimitCount do
            self._parseItems:pop()
        end
        if self._parseEnable then
            self:CheckParseItems()
        end
    else
        -- 系统频道单独缓存
        self._parseSystemItems:push(data)
        while self._parseSystemItems:size() > CONFIG.LimitCount do
            self._parseSystemItems:pop()
        end
        if self._parseSystemEnable then
            self:CheckParseSystemItems()
        end
    end

    -- mini
    self._parseMiniItems:push(data)
    local  LimitCount = global.isWinPlayMode and CONFIG.LimitCountWin or 10
    while self._parseMiniItems:size() > LimitCount do
        self._parseMiniItems:pop()
    end
    if self._parseMiniEnable then
        self:CheckParseMiniItems()
    end

    --PC Private
    if global.isWinPlayMode and data.ChannelId == CHANNEL.Private then
        self._parsePCPItems:push(data)
        while self._parsePCPItems:size() > CONFIG.LimitCountWin do
            self._parsePCPItems:pop()
        end
        if self._parsePCPEnable then
            self:CheckParsePCPItems()
        end
    end

end

function ChatMediator:CheckParseItems()
    if self._parseEnable and not self._parseItems:empty() then
        self._parseEnable = false

        -- parse
        local function callback()
            local item = self._parseItems:pop()
            self:ParseItem(item)
        end
        PerformWithDelayGlobal(callback, 1 / 60)

        -- delay parse next
        local function callback()
            self._parseEnable = true
            self:CheckParseItems()
        end
        PerformWithDelayGlobal(callback, PARSE_INTERVAL)
    end
end

function ChatMediator:CheckParseSystemItems()
    if self._parseSystemEnable and not self._parseSystemItems:empty() then
        self._parseSystemEnable = false

        -- parse
        local function callback()
            local item = self._parseSystemItems:pop()
            self:ParseItem(item)
        end
        PerformWithDelayGlobal(callback, 1 / 60)

        -- delay parse next
        local function callback()
            self._parseSystemEnable = true
            self:CheckParseSystemItems()
        end
        PerformWithDelayGlobal(callback, PARSE_INTERVAL)
    end
end

function ChatMediator:CheckParseMiniItems()
    if self._parseMiniEnable and not self._parseMiniItems:empty() then
        self._parseMiniEnable = false

        -- parse
        local item = self._parseMiniItems:pop()
        self:ParseMiniItem(item)

        -- delay parse next
        local function callback()
            self._parseMiniEnable = true
            self:CheckParseMiniItems()
        end
        PerformWithDelayGlobal(callback, PARSE_INTERVAL)
    end
end

function ChatMediator:CheckParsePCPItems()
    if self._parsePCPEnable and not self._parsePCPItems:empty() then
        self._parsePCPEnable = false

        -- parse
        local function callback()
            local item = self._parsePCPItems:pop()
            self:ParsePCPItem(item)
        end
        PerformWithDelayGlobal(callback, 1 / 60)

        -- delay parse next
        local function callback()
            self._parsePCPEnable = true
            self:CheckParsePCPItems()
        end
        PerformWithDelayGlobal(callback, PARSE_INTERVAL)
    end
end

function ChatMediator:ParseItem(data)
    if not data then
        return
    end
    local item = ChatParseHelp:parseItem(data)
    if not item then
        return
    end
    item.tag = data.SendId
    self:AddItem(item, data.ChannelId, data.dropType)

    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    proxy:storageItem(item, data.ChannelId, data.dropType)
end

function ChatMediator:AddItem(item, channel, dropType)
    if not self._layer then
        return false
    end

    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local CHANNEL = proxy.CHANNEL
    local receiveChannel = proxy:getReceiveChannel()
    if (receiveChannel == CHANNEL.Common) or (receiveChannel == channel) or (receiveChannel == CHANNEL.Guild and channel == CHANNEL.GuildTips) then
        self._layer:AddItem(item, channel, dropType)
    end
end

function ChatMediator:ParseMiniItem(data)
    if not data then
        return
    end

    local item = ChatParseHelp:parseMiniItem(data)
    if not item then
        return
    end
    item.tag = data.SendId

    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local CHANNEL = ChatProxy.CHANNEL
    local receiveChannel = ChatProxy:getReceiveChannel()
    if (receiveChannel == data.ChannelId) or (receiveChannel == CHANNEL.Common) or (receiveChannel == CHANNEL.Guild and data.ChannelId == CHANNEL.GuildTips) then
        global.Facade:sendNotification(global.NoticeTable.Layer_ChatMini_AddItem, item)
    end

    local isOpen = tonumber(SL:GetMetaValue("GAME_DATA","PCSwitchChannelShow")) == 1
    if global.isWinPlayMode and isOpen then
        local proxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        proxy:storagePCItem(item, data.ChannelId, data.dropType)
    end
end

function ChatMediator:ParsePCPItem(data)
    if not data then
        return
    end

    local chatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    if data.ChannelId == chatProxy.CHANNEL.Private and global.isWinPlayMode then
        local item = ChatParseHelp:parsePCPrivateItem(data)
        if not item then
            return
        end
        item.tag = data.SendId
        global.Facade:sendNotification(global.NoticeTable.Layer_Private_Chat_AddItem, item)

        local proxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
        proxy:storagePCPrivateItem(item, data.ChannelId)
    end
end

function ChatMediator:OnRemoveItem(uid)
    if not self._layer then
        return false
    end

    self._layer:RemoveItem(uid)
end

function ChatMediator:OnReplaceInput(input)
    if not self._layer then
        return false
    end
    self._layer:ReplaceInput(input)
end

function ChatMediator:OnChatTargetChange(data)
    if not self._layer then
        return false
    end
    if Chat and Chat.UpdateTarget then
        Chat.UpdateTarget()
    end
end

function ChatMediator:OnPrivateChatWithTarget(data)
    if global.isWinPlayMode then
        return nil
    end

    if not self._layer then
        global.Facade:sendNotification(global.NoticeTable.Layer_Chat_Open)
    end

    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local CHANNEL = proxy.CHANNEL

    if Chat and Chat.SelectChannel then
        Chat.SelectChannel(CHANNEL.Private)
    end

    local target = {uid = data.uid, name = data.name}
    proxy:addTarget(target)
    global.Facade:sendNotification(global.NoticeTable.ChatTargetChange, target)
end

function ChatMediator:OnReleaseMemory()
    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    proxy:releaseCache()
end

function ChatMediator:OnWindowResized(data)
    if not self._layer then
        return nil
    end
    self._layer:OnWindowResized(data)
end

function ChatMediator:OnPlayerPropertyInited(data)
    local proxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    proxy:OnPlayerPropertyInited()
end

function ChatMediator:OnDRotationChanged(data)
    if not self._layer then
        return nil
    end
    self._layer:OnDRotationChanged(data)
end

function ChatMediator:OnShowChatExNotice(data)
    if not self._layer then
        return nil
    end
    self._layer:OnShowChatExNotice(data)
end

function ChatMediator:OnMainExChatClean()
    if not self._layer then
        return nil
    end
    self._layer:OnMainExChatClean()
end

function ChatMediator:OnChatFakeDropChange()
    if not self._layer then
        return nil
    end

    self._layer:OnChatFakeDropChange()
end

return ChatMediator