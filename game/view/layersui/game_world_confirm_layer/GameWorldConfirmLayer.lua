local BaseLayer = requireLayerUI("BaseLayer")
local GameWorldConfirmLayer = class("GameWorldConfirmLayer", BaseLayer)

local RichTextHelp = requireUtil("RichTextHelp")

function GameWorldConfirmLayer:ctor()
    GameWorldConfirmLayer.super.ctor(self)
end

function GameWorldConfirmLayer.create()
    local layer = GameWorldConfirmLayer.new()
    if layer:Init() then
        return layer
    end
    return nil
end

function GameWorldConfirmLayer:Init()
    self._quickUI = ui_delegate(self)

    self._scheduleNode = cc.Node:create()
    self:addChild(self._scheduleNode)

    return true
end

function GameWorldConfirmLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_GAME_WORLD_CONFIRM)
    GameWorldConfirm.main()

    -- 确认
    self._quickUI.ConfirmButton:addClickEventListener(function()
        self:enterGameWorld()
    end)

    local remaining = 3
    local function callback()
        self._quickUI.RemainingText:setString(string.format("(%s)", remaining))

        remaining = remaining - 1
        if remaining < 0 then
            self:enterGameWorld()
        end
    end
    schedule(self._scheduleNode, callback, 1)
    callback()

    self:OnUpdate()

    return true
end

function GameWorldConfirmLayer:OnUpdate()
    -- content
    local contentLayout = self._quickUI.ContentLayout 
    contentLayout:removeAllChildren()
    
    local LoginProxy = global.Facade:retrieveProxy(global.ProxyTable.Login)
    local content = LoginProxy:GetTipsContent()
    if not content or content == "" then
        return nil
    end

    local contentSize = contentLayout:getContentSize()
    local richContent = RichTextHelp:CreateRichTextWithXML(content, contentSize.width, 16)
    richContent:setAnchorPoint({x=0.5, y=1})
    contentLayout:addChild(richContent)
    richContent:setPosition({x=contentSize.width/2, y=contentSize.height})
end

function GameWorldConfirmLayer:handlePressedEnter()
    self:enterGameWorld()
end

function GameWorldConfirmLayer:enterGameWorld()
    global.Facade:sendNotification(global.NoticeTable.Layer_GameWorldConfirm_Close)
    global.Facade:sendNotification(global.NoticeTable.GameWorldConfirm)
    global.Facade:sendNotification(global.NoticeTable.GameWorldCheckTimeout)
end

return GameWorldConfirmLayer
