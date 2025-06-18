local BaseLayer = requireLayerUI("BaseLayer")
local PrivateChatLayer = class("PrivateChatLayer", BaseLayer)

function PrivateChatLayer:ctor()
    PrivateChatLayer.super.ctor(self)
    
    self._proxy = global.Facade:retrieveProxy(global.ProxyTable.Chat)
    self._autoStr = ""
end

function PrivateChatLayer.create(data)
    local layer = PrivateChatLayer.new()
    if layer:Init(data) then
        return layer
    else
        return nil
    end
end

function PrivateChatLayer:Init()
    self.ui = ui_delegate(self)

    return true
end

function PrivateChatLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PRIVATE_CHAT_WIN32)
    PrivateChat.main()

    self:InitListEvent()
    self:InitUI()

    self.ui.Button_close:addClickEventListener(function ( ... )
        global.Facade:sendNotification(global.NoticeTable.Layer_Private_Chat_Close)
    end)
end

function PrivateChatLayer:InitUI()
    
    local CHANNEL = self._proxy.CHANNEL
    local receiveChannel = self._proxy:getReceiveChannel()

    -- 清理
    self._cache = {}
    self._isScrolling = false
    self.ui.ListView_cells:removeAllItems()

    -- 消息
    local receiveCache = self._proxy:getPCPrivateCache()
    for _, v in ipairs(receiveCache) do
        self:pushItem(v)
    end
    self.ui.ListView_cells:jumpToBottom()

    --自动回复
    local isSelected = self._proxy:GetAutoReplySwitch(CHANNEL.Private)
    self.ui.CheckBox_1:setZoomScale(-0.1)
    self.ui.CheckBox_1:setSelected(isSelected)
    self.ui.CheckBox_1:addEventListener(function()
        local isSelected = self.ui.CheckBox_1:isSelected()
        self._proxy:SetAutoReplySwitch(CHANNEL.Private, isSelected and 1 or 0)
    end)

    self._editBox = self.ui.TextField_1
    self._editBox:addEventListener(function (sender, eventType)
        if eventType == 2 or eventType == 3 or eventType == 4 then
            self._autoStr = self._editBox:getString()
            self._autoStr = string.trim(self._autoStr)
            self._autoStr = string.gsub(self._autoStr, "[\t\n\r]", "")
            self._editBox:setString(self._autoStr)
            self._proxy:setLocalChatDataData(self._proxy.CHANNEL.Private, self._autoStr)
        end
    end)
    local str = self._proxy:getLocalChatDataData(self._proxy.CHANNEL.Private)
    if str and string.len(str) then
        self._autoStr = str 
        self._editBox:setString(str)
    end
    
end

function PrivateChatLayer:InitListEvent( ... )
    --------------------
    local pSize = self.ui.Image_2:getContentSize()
    local progressBar = self.ui.Image_bar
    progressBar:setTouchEnabled(true)
 
    local innerSize     = self.ui.ListView_cells:getInnerContainerSize()
    local contentSize   = self.ui.ListView_cells:getContentSize()
    local arrowHei      = 16
  
    local bodyHei   = progressBar:getContentSize().height
    local originY   = arrowHei + bodyHei/2
    local minY      = originY
    local maxY      = pSize.height - arrowHei - bodyHei/2
    local hei       = pSize.height - 2*arrowHei - bodyHei

    local function setPercent(p)
        self._percent = p
        local posY  = (1-p)*hei + originY
        posY        = math.min(math.max(posY, minY), maxY)
        progressBar:setPositionY(posY)
    end
    local function bodyCallback(sender, eventType)
        if eventType == 1 then
            local movePos   = sender:getTouchMovePosition()
            local convertP  = self.ui.Image_2:convertToNodeSpace(movePos)
            local posY      = convertP.y
            local p         = (hei - (posY - originY)) / hei
            p               = math.min(math.max(p, 0), 1)
            self.ui.ListView_cells:jumpToPercentVertical(p*100)
            if p == 1 then
                self._isScrolling = false
                self:ShowCache()
            end
        end
    end
    local function scrollCallback(sender, eventType)
        if eventType == 9 then
            local innerPos      = sender:getInnerContainerPosition()
            local innerSize     = sender:getInnerContainerSize()
            local contentSize   = sender:getContentSize()
            local percentHeight = (innerSize.height - contentSize.height)
            local percent       = percentHeight > 0 and (percentHeight + innerPos.y) / percentHeight or 1
            setPercent(percent)
            if percent == 1 then
                self._isScrolling = false
                self:ShowCache()
            end
        end
    end
    progressBar:addTouchEventListener(bodyCallback)
    setPercent(0)
    self.ui.ListView_cells:addScrollViewEventListener(scrollCallback)

    ---
    local function UpOrDown(isUp)
        if not self._percent then return end
        local innerSize     = self.ui.ListView_cells:getInnerContainerSize()
        local contentSize   = self.ui.ListView_cells:getContentSize()
        if innerSize.height - contentSize.height <= 0 then
            return
        end

        local per = (14*2)/(innerSize.height - contentSize.height)
        self._percent = self._percent + (isUp and -per or per )
        local p     = self._percent
        local posY  = (1-p)*hei + originY
        posY        = math.min(math.max(posY, minY), maxY)
        progressBar:setPositionY(posY)

        local p         = (hei - (posY - originY)) / hei
        p               = math.min(math.max(p, 0), 1)
        self.ui.ListView_cells:jumpToPercentVertical(p*100)
    end
    self.ui.Image_down:setTouchEnabled(true)
    self.ui.Image_down:addClickEventListener(function()
        UpOrDown()
    end)

    self.ui.Image_up:setTouchEnabled(true)
    self.ui.Image_up:addClickEventListener(function()
        UpOrDown(true)
    end)
end

function PrivateChatLayer:pushItem(item)
    local CONFIG = self._proxy.CONFIG
    self.ui.ListView_cells:pushBackCustomItem(item)
    performWithDelay(self.ui.ListView_cells,function () 
        if #self.ui.ListView_cells:getItems() > CONFIG.LimitCount then
            self.ui.ListView_cells:removeItem(0)
        end
        self.ui.ListView_cells:jumpToBottom()
    end,0)
end

function PrivateChatLayer:AddItem(item)
    local CONFIG = self._proxy.CONFIG
    
    -- 是否正在拖动
    local listviewCells = self.ui.ListView_cells
    if next(listviewCells:getItems()) then
        local lastItem  = listviewCells:getItem(#listviewCells:getItems() - 1)
        local csize     = lastItem:getContentSize()
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
    
        while #self._cache > CONFIG.LimitCount do
            local item = table.remove(self._cache, 1)
            item:autorelease()
        end
    else
        self:pushItem(item)
        self.ui.ListView_cells:jumpToBottom() 
    end
end

function PrivateChatLayer:RemoveItem(uid)
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
    
    local items = self.ui.ListView_cells:getItems()
    local isRemoved = false
    for i, item in ipairs(items) do
        if item and item.tag == uid then
            local index = self.ui.ListView_cells:getIndex(item)
            self.ui.ListView_cells:removeItem(index)
            isRemoved = true
        end
    end
    if not isRemoved then
        return
    end

    self.ui.ListView_cells:jumpToBottom()
    if self._isScrolling then
        self:ShowCache()
    end
end

function PrivateChatLayer:ShowCache()
    -- 缓存填充
    while #self._cache > 0 do
        local item = table.remove(self._cache, 1)
        item:autorelease()
        self:pushItem(item)
    end
    self.ui.ListView_cells:jumpToBottom()
end

return  PrivateChatLayer