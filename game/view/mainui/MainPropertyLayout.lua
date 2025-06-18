local MainPropertyLayout =class("MainPropertyLayout", function()
    return cc.Node:create()
end)
local RichTextHelp = requireUtil("RichTextHelp")

function MainPropertyLayout:ctor()
    self._quickUseCells     = {}

    self._miniChatWidth     = nil

    self._showLastChatExID      = nil   -- 固定聊天最后显示的id
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

    local ChatProxy  = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    self._listInterval, self._richVspace = ChatProxy:GetChatParam()

    return true
end

function MainPropertyLayout:InitGUI( ... )
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_PROPERTY)
    MainProperty.main()

    self:InitMiniChat()

    self:InitEditMode()
end

function MainPropertyLayout:InitEditMode()
    local items = 
    {
        "Panel_mini_chat",
        "Image_minichat_bg",
        "ListView_minichat",
        "ListView_chat_ex",
        "Panel_mini_chat_touch",
        "Image_4",
        "Image_14",
        "Image_14_0",
        "Image_14_0_0",
        "Image_17",
        "Image_17_0",
        "Image_19",
        "LoadingBar_exp",
        "Panel_hp",
        "Text_hp",
        "Text_mp",
        "Text_level",
        "Text_time",
        "Text_exp",
        "Image_1",
        "Panel_bubble_tips",
        "Panel_auto_tips",
        "Panel_quick_use_1",
        "Panel_quick_use_2",
        "Panel_quick_use_3",
        "Panel_quick_use_4",
        "Panel_quick_use_5",
        "Panel_quick_use_6",
        "btn_rein_add",
        "Image_divide",
        "LoadingBar_hp",
        "LoadingBar_mp",
        "LoadingBar_fhp",
        "Image_net",
        "Image_battery",
        "LoadingBar_battery",
        "Image_barbg",
        "Image_2",
        "Image_bar",
        "Button_chat_hide",
        "Node_quit_tip",
        "Text_FPS",
    }
    for _, widgetName in ipairs(items) do
        if self._quickUI[widgetName] then
            self._quickUI[widgetName].editMode = 1
        end
    end
end

function MainPropertyLayout:InitMiniChat()
    self._layoutMiniChat = self._quickUI["Panel_mini_chat"]
    self._imageMiniChatBG = self._quickUI["Image_minichat_bg"]
    self._listviewMiniChat = self._quickUI["ListView_minichat"]
    self._listviewChatEx = self._quickUI["ListView_chat_ex"]

    if self._listInterval then
        self._listviewMiniChat:setItemsMargin(self._listInterval)
        self._listviewChatEx:setItemsMargin(self._listInterval)
    end

    self:SetMiniChatWidth()
end

function MainPropertyLayout:GetMiniChatWidth()
    return self._miniChatWidth
end

function MainPropertyLayout:SetMiniChatWidth()
    if self._quickUI.ListView_minichat then
        self._miniChatWidth = self._quickUI.ListView_minichat:getContentSize().width
    end
end

function MainPropertyLayout:PushMiniChatCell(cell)
    if not self._listviewMiniChat then
        return
    end
    self._listviewMiniChat:pushBackCustomItem(cell)

    -- 超出限制，移除先放入的
    local limitSize = SL:GetMetaValue("GAME_DATA", "MobileMainMaxChatNum") or 7
    if #self._listviewMiniChat:getItems() > limitSize then
        self._listviewMiniChat:removeItem(0)
    end
    self._listviewMiniChat:jumpToBottom()
end

function MainPropertyLayout:OnRemoveItem(uid)
    if not uid then
        return
    end
    
    local items = self._listviewMiniChat:getItems()
    for i, item in ipairs(items) do
        if item and item.tag == uid then
            local index = self._listviewMiniChat:getIndex(item)
            self._listviewMiniChat:removeItem(index)
            self._listviewMiniChat:doLayout()
        end
    end
    local innerSize = self._listviewMiniChat:getInnerContainerSize()
    local contentSize = self._listviewMiniChat:getContentSize()
    self._listviewMiniChat:jumpToBottom()
end
 
function MainPropertyLayout:OnShowChatExNotice(data)
    self:CheckChatExNotice()
end

function MainPropertyLayout:CheckChatExNotice( showChatExId )
    if not self._listviewChatEx then
        return
    end
    local exList = self._listviewChatEx
    if #exList:getItems() >= 3 then
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
    local cWidth        = exList:getContentSize().width
    local capacitySize  = cc.size(cWidth, 17)
    local function resetListview()
        local items = exList:getItems()
        local height = 0
        local margin = exList:getItemsMargin()
        for i, v in ipairs(items) do
            local interval = i ~= #items and margin or 0
            height = height + v:getContentSize().height + interval
        end
        exList:setContentSize(cc.size(capacitySize.width, height))

        local contentSize = self._layoutMiniChat:getContentSize()
        local listviewSize = self._listviewMiniChat:getContentSize()
        self._listviewMiniChat:setContentSize(cc.size(listviewSize.width, contentSize.height-height))
        self._listviewMiniChat:jumpToBottom()
    end

    local layout        = ccui.Layout:create()
    layout:setContentSize(capacitySize)
    if BColorEnabel then 
        layout:setBackGroundColor(BColorRGB)
        layout:setBackGroundColorType(0)
        layout:setBackGroundColorOpacity(255)
    end
    
    exList:pushBackCustomItem(layout)
    resetListview()

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
        local fontSize = SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE") or 16
        local richText = RichTextHelp:CreateRichTextWithFCOLOR(str, 1000, fontSize, FColorRGB, {outlineSize = 0}, nil, self._richVspace or 0)
        richText:setTouchEnabled(true)
        richText:addClickEventListener(function()
            if data.SendName and  data.SendId then
                global.Facade:sendNotification(global.NoticeTable.PrivateChatWithTarget, {name = data.SendNameTemp, uid = data.SendId})
            end
        end)
        scrollWidget:removeAllChildren()
        scrollWidget:addChild(richText)
        richText:setAnchorPoint({x=0, y=0.5})
        richText:setPosition(cc.p(0, capacitySize.height/2))
        if BColorEnabel then
            richText:setBackgroundColor(BColorRGB)
            richText:setBackgroundColorEnable(true)
        end
        
        if scrollAble == nil then
            richText:formatText()
            scrollSize  = richText:getContentSize()
            scrollAble  = scrollSize.width > capacitySize.width
        end
        local richSize = richText:getContentSize()
        scrollWidget:setContentSize(capacitySize.width,richSize.height)
        layout:setContentSize(capacitySize.width,richSize.height)
        if remaining < 0 then
            exList:removeItem(exList:getIndex(layout))
            resetListview()
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

------------
function MainPropertyLayout:InitQuickUse()
    local showNum = 0
    if self._quickUI.Panel_quick_use and self._quickUI.Panel_quick_use:isVisible() then
        for i = 1, 6 do
            local layout = self._quickUI[string.format("Panel_quick_use_%s", i)]
            if layout and layout:isVisible() then
                showNum = showNum + 1
                local cell = self:CreateQuickUseCell(layout, {index = i})
                self._quickUseCells[i] = cell
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
            local bagProxy  = global.Facade:retrieveProxy( global.ProxyTable.Bag )
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
    
    cell.nodeItem:removeAllChildren()

    local function getCount(item)
        if item.OverLap > 1 then
            return item.OverLap
        end

        if item.StdMode == 2 and item.Dura > 0 then --使用次数
            return item.Dura < 1000 and 1 or math.floor(item.Dura / 1000)  --小于1000都为1；大于1000向下取整
        end
        return 0
    end

    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
    local info = {}
    info.from  = ItemMoveProxy.ItemFrom.QUICK_USE
    info.movable = true
    info.index = data.itemData.Index
    info.itemData = data.itemData
    local item = GoodsItem:create(info)
    cell.nodeItem:addChild(item)
    item:setCount(getCount(data.itemData))
    item:addTouchEventListener(function()
        if cell.nodeItem.touching then
            return
        end
        cell.nodeItem.touching = true
        SL:RequestUseItem(data.itemData)
        performWithDelay(cell.nodeItem, function(sender)
            sender.touching = nil
        end, 0.3)
    end, 2)

    cell.item = item
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
    cell.item:resetMoveState(data.state == 0)
end

function MainPropertyLayout:CreateQuickUseCell(parent, data)
    if MainProperty and MainProperty.CreateQuickUseCell then
        MainProperty.CreateQuickUseCell(parent)
    end
    local layout = parent:getChildByName("Panel_cell")
    if not layout then
        return
    end
    local imageBG  = layout:getChildByName("Image_bg")
    local nodeItem = layout:getChildByName("Node_item")
    local layoutQuick = layout:getChildByName("Panel_quick")

    layout:addClickEventListener(function()
        local QuickUseProxy = global.Facade:retrieveProxy(global.ProxyTable.QuickUseProxy)
        local quickUseItem = QuickUseProxy:GetQucikUseDataByPos(data.index)
        if not quickUseItem then
            return nil
        end
        SL:RequestUseItem(quickUseItem)
    end)

    local function addItemIntoBag(touchPos)
        local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
        local state = ItemMoveProxy:GetMovingItemState()
        if state then
           local goToName = ItemMoveProxy.ItemGoTo.QUICK_USE
           local ndata = {}
           ndata.target = goToName
           ndata.pos = touchPos
           ndata.posInQuickUse = data.index
           ItemMoveProxy:CheckAndCallBack( ndata )
        else
           return -1
        end
     end
     local function setNoswallowMouse()
        return -1
     end
     global.mouseEventController:registerMouseButtonEvent(
        layoutQuick,
        {
           down_r = setNoswallowMouse,
           special_r = addItemIntoBag
        }
     )

    return {
        layout = layout,
        nodeItem = nodeItem,
    }
end

---------------
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
            local richText = RichTextHelp:CreateRichTextWithXML(str, width, SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE") or 16, "#ffffff")
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
    if self._listviewChatEx then
        self._listviewChatEx:stopAllActions()
        self._listviewChatEx:removeAllItems()
        self._showLastChatExID = nil
    end
end

function MainPropertyLayout:OnRefreshMobileAutoShout(data)
    if data and data.openChat and self._fristCheckAuto then
        return
    end

    if not self._fristCheckAuto then
        self._fristCheckAuto = true
    end

    local ChatProxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    local isOpen    = ChatProxy:GetAutoShoutSwitch()
    if not isOpen then
        self._layoutMiniChat:stopActionByTag(888)
        return
    end

    local shoutInput = ChatProxy:getLocalChatDataData(ChatProxy.CHANNEL.Shout)
    if not shoutInput or shoutInput == "" then
        return
    end

    -- 发送
    local function sendChatMsg(input, channel)
        if not channel or not ChatProxy:CheckAbleToSay(channel) then
            return
        end
        local MSG_TYPE = ChatProxy.MSG_TYPE
        local sendData = {mt = MSG_TYPE.Normal, msg = input, channel = channel}
        global.Facade:sendNotification(global.NoticeTable.SendChatMsg, sendData)
    end

    -- 自动喊话开关
    local autoShoutCallback = nil
    autoShoutCallback = function(shoutInput)
        self._layoutMiniChat:stopActionByTag(888)
        if not shoutInput or shoutInput == "" then
            return
        end
        if not ChatProxy:GetAutoShoutSwitch() then
            return
        end
        local delay = ChatProxy:GetAutoShoutDelay()
        local action = schedule(self._layoutMiniChat, function()
            -- 发送
            sendChatMsg(shoutInput, ChatProxy.CHANNEL.Shout)
        end, delay)
        action:setTag(888)
    end
    autoShoutCallback(shoutInput)
end

function MainPropertyLayout:AfterCUILoadFunc()
    self:SetMiniChatWidth()
    self:InitQuickUse()
end

return MainPropertyLayout
