local BaseUIMediator = requireMediator("BaseUIMediator")
local NPCLayerMediator = class('NPCLayerMediator', BaseUIMediator)
NPCLayerMediator.NAME = "NPCLayerMediator"

local mAbs = math.abs

function NPCLayerMediator:ctor()
    NPCLayerMediator.super.ctor(self)

    self._currentNPCID = nil
    self._npcBindWinList = {}
end

function NPCLayerMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return {
        noticeTable.Layer_NPC_Talk_Open,
        noticeTable.Layer_NPC_Talk_Close,
        noticeTable.MainPlayerActionEnded,
        noticeTable.NpcInOfView,
        noticeTable.NpcOutOfView,
        noticeTable.ChangeScene,
        noticeTable.ReleaseMemory
    }
end

function NPCLayerMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeID == noticeTable.Layer_NPC_Talk_Open then
        if global.IsReceiveRole or global.IsVisitor then  -- 收货或者试玩不要打开npc界面
            return
        end

        self:OpenLayer()

    elseif noticeID == noticeTable.Layer_NPC_Talk_Close then
        self:CloseLayer()

    elseif noticeID == noticeTable.MainPlayerActionEnded then
        self:OnMainPlayerActionEnded(data)

    elseif noticeID == noticeTable.NpcInOfView then
        self:OnNpcInOfView(data)

    elseif noticeID == noticeTable.NpcOutOfView then
        self:OnNpcOutOfView(data)

    elseif noticeID == noticeTable.ChangeScene then
        self:OnChangeScene()

    elseif noticeID == noticeTable.ReleaseMemory then
        self:OnReleaseMemory()
    end
end

function NPCLayerMediator:OpenLayer()
    local lastLayerID = nil
    if self._layer and self._layer.background then
        if self._layer.background.element.attr.layerid then
            lastLayerID = self._layer.background.element.attr.layerid
        end
    end

    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    if self._currentNPCID and self._currentNPCID ~= NPCProxy:GetCurrentNPCID() then
        self:CloseLayer()
    end

    self._currentNPCID = NPCProxy:GetCurrentNPCID()

    if not self._layer then
        self._layer = requireLayerUI("npc_layer/NpcTalkLayer").create()
        self._type = global.UIZ.UI_NORMAL

        self._forbidBagEquip = false

        -- load
        self._layer:loadTalkContent()

        -- property, ctrl by background
        if self._layer.background then
            local background     = self._layer.background
            local render         = background.render
            local element        = background.element
            self._resetPostion   = (tonumber(element.attr.reset) or 1) == 1
            self._escClose       = (tonumber(element.attr.esc) or 1)   == 1
            self._hideMain       = tonumber(element.attr.hideMain)     == 1
            self._adapet         = (tonumber(element.attr.show) or 0)  == 6             -- 加黑幕
            self._forbidBagEquip = (tonumber(element.attr.forbidBagEquip) or 0) == 1    -- 禁止打开背包/角色

            if render then
                global.mouseEventController:registerMouseMoveEvent(render)
                global.mouseEventController:registerMouseButtonEvent(render)
            end

            -- notify server npc layer open
            if background.element.attr.layerid then
                local npcProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
                npcProxy:RequestNotifyTalkOpen(background.element.attr.layerid)
            end

            -- bagPos
            if tonumber(background.element.attr.bagPos) == 1 then
                global.Facade:sendNotification(global.NoticeTable.Layer_Bag_ResetPos, { x = 0, y = 0 })

            elseif tonumber(background.element.attr.bagPos) == 3 then
                if CheckLayerOutScreen("BAG") then
                    if tonumber(background.element.attr.show) == 1 then
                        local offsetX = global.isWinPlayMode and -40 or -60
                        global.Facade:sendNotification(global.NoticeTable.Layer_Bag_ResetPos, { x = offsetX, y = 40 })
                    else
                        local offsetX = global.isWinPlayMode and 500 or 480
                        global.Facade:sendNotification(global.NoticeTable.Layer_Bag_ResetPos, { x = offsetX, y = 40 })
                    end
                end

            else
                if tonumber(background.element.attr.show) == 1 then
                    local offsetX = global.isWinPlayMode and -40 or -60
                    global.Facade:sendNotification(global.NoticeTable.Layer_Bag_ResetPos, { x = offsetX, y = 40 })
                else
                    local offsetX = global.isWinPlayMode and 500 or 480
                    global.Facade:sendNotification(global.NoticeTable.Layer_Bag_ResetPos, { x = offsetX, y = 40 })
                end
            end
        end

        NPCLayerMediator.super.OpenLayer(self)

        -- update move
        if self._layer and self._layer.background then
            local element = self._layer.background.element 
            local needMove = (tonumber(element.attr.move) or 0) == 1
            local render = self._layer.background.render
            self:setLayerMoveEnable(render, needMove)
        end

        SLBridge:onLUAEvent(LUA_EVENT_NPCLAYER_OPENSTATUS, true)

    else
        self._layer:loadTalkContent()

        -- notify server npc layer close
        if self._layer and self._layer.background then
            if lastLayerID ~= self._layer.background.element.attr.layerid then
                local npcProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
                npcProxy:RequestNotifyTalkClose(lastLayerID)
            end
        end

        -- notify server npc layer open
        if self._layer and self._layer.background then
            if lastLayerID ~= self._layer.background.element.attr.layerid then
                local npcProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
                npcProxy:RequestNotifyTalkOpen(self._layer.background.element.attr.layerid)
            end
        end

        -- update move
        if self._layer and self._layer.background then
            local element = self._layer.background.element 
            local needMove = (tonumber(element.attr.move) or 0) == 1
            local render = self._layer.background.render
            self:setLayerMoveEnable(render, needMove)
            self._resetPostion = (tonumber(element.attr.reset) or 1) == 1
            local LayerFacadeMediator = global.Facade:retrieveMediator("LayerFacadeMediator")
            if self._resetPostion then
                LayerFacadeMediator:resetLayerPostion(self)
            end
        end

        refPositionByParent(self._layer)
    end
    global.Facade:sendNotification(global.NoticeTable.GuideLayerResetPos)
end

function NPCLayerMediator:CloseLayer()
    if not self._layer then
        return nil
    end

    if self._escClose then
        self._escClose = nil
        local npcProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
        npcProxy:Cleanup()
        return
    end

    global.Facade:sendNotification(global.NoticeTable.GuideEventEnded, { name = "GUIDE_END_NPC_TALK_LAYER_CLOSED" })

    -- reset current npcID
    self._currentNPCID = nil

    -- notify server npc layer close
    local background = self._layer.background
    if background and background.element.attr.layerid then
        local npcProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
        npcProxy:RequestNotifyTalkClose(background.element.attr.layerid)
    end

    local bagPos = background and tonumber(background.element.attr.bagPos)

    -- caching
    if self._layer.trunk then
        global.SWidgetCache:cachingTrunk(self._layer.trunk)
    end

    -- reset bag position
    if not (bagPos and bagPos == 3) then
        global.Facade:sendNotification(global.NoticeTable.Layer_Bag_ResetPos, { x = 0, y = 0 })
    end

    -- close
    NPCLayerMediator.super.CloseLayer(self)
    SLBridge:onLUAEvent(LUA_EVENT_NPCLAYER_OPENSTATUS, false)
end


function NPCLayerMediator:OnMainPlayerActionEnded(act)
    if not IsMoveAction(act) then
        return
    end

    self:CheckNpcTalkTips()
    self:CheckCloseNpcTalkLayer()
    self:CheckCloseSUIWin()
end

function NPCLayerMediator:CheckNpcTalkTips()
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return
    end

    local x = mainPlayer:GetMapX()
    local y = mainPlayer:GetMapY()

    local targetNpc = nil

    local npcVec, ncount = global.npcManager:GetNpcInCurrViewField()
    for i = 1, ncount do
        local npc = npcVec[i]
        if npc and mAbs(x - npc:GetMapX()) <= 2 and mAbs(y - npc:GetMapY()) <= 2 then
            targetNpc = npc
            break
        end
    end

    if not targetNpc then
        if self._talkButton then
            self._talkButton:removeAllChildren()
        end

        return
    end

    self:NpcTalkTips(targetNpc)
end

function NPCLayerMediator:OnNpcInOfView(npcId)
    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return
    end

    local x = mainPlayer:GetMapX()
    local y = mainPlayer:GetMapY()
    local npc = global.npcManager:FindOneNpcInCurrViewFieldById(npcId)
    if npc then
        if math.abs(x - npc:GetMapX()) <= 2 and math.abs(y - npc:GetMapY()) <= 2 then
            self:NpcTalkTips(npc)
        end
    end
end

function NPCLayerMediator:NpcTalkTips(targetNpc)
    if not targetNpc then
        return
    end

    if not CHECK_SERVER_OPTION(global.MMO.SERVER_OPTION_NPC_BUTTON) then
        return
    end

    if self._talkButton then
        self._talkButton:removeAllChildren()  
    else
        local winSz = global.Director:getVisibleSize()
        local moveY = global.isWinPlayMode and 0 or -88
        self._talkButton = cc.Node:create()
        self._talkButton:retain()
        self._talkButton:setPosition(cc.p(180, winSz.height / 2 + moveY))
        local data = {}
        data.child = self._talkButton
        data.index = global.MMO.MAIN_NODE_MB
        global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)
    end

    local imagePopBg = ccui.ImageView:create()
    self._talkButton:addChild(imagePopBg)
    imagePopBg:loadTexture(global.MMO.PATH_RES_PUBLIC .. "bg_bubble_1.png")
    imagePopBg:setAnchorPoint(0, 0)
    imagePopBg:setTouchEnabled(true)
    imagePopBg:setName("touch")
    imagePopBg:addClickEventListener(function()
        local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
        NPCProxy:CheckTalk(targetNpc:GetID())
    end)

    local label = ccui.Text:create()
    imagePopBg:addChild(label)
    label:setAnchorPoint(0.5, 0.5)
    label:setFontName(global.MMO.PATH_FONT2)
    local bubbleName = targetNpc:GetBubbleName() or targetNpc:GetName()
    label:setString(bubbleName)
    label:setPosition(imagePopBg:getContentSize().width / 2, imagePopBg:getContentSize().height * 0.6)
    label:setFontSize(SL:GetMetaValue("GAME_DATA","DEFAULT_FONT_SIZE") or 16)
    GUI:Text_setTextColor(label, "#ffffff")
    GUI:Text_enableOutline(label, "#111111", 1)
end

function NPCLayerMediator:CheckCloseNpcTalkLayer()
    if not self._layer then
        return
    end

    local mainPlayer = global.gamePlayerController:GetMainPlayer()
    if not mainPlayer then
        return
    end

    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    local clickNPCID = NPCProxy:GetCurrentClickNPCID()
    if not clickNPCID then
        return
    end

    local npc = global.npcManager:FindOneNpcInCurrViewFieldById(clickNPCID)
    if not npc then
        return
    end

    local x = mainPlayer:GetMapX()
    local y = mainPlayer:GetMapY()
    local dis = math.max(math.abs(x - npc:GetMapX()), math.abs(y - npc:GetMapY()))
    if dis >= 8 then
        global.Facade:sendNotification(global.NoticeTable.Layer_NPC_Talk_Close)
    end
end

function NPCLayerMediator:OnNpcOutOfView(npcId)
    local NPCProxy = global.Facade:retrieveProxy(global.ProxyTable.NPC)
    NPCProxy:CheckNpcTalkLayerClose(npcId)

    GUI:Win_CloseByNPCID(npcId)
end

function NPCLayerMediator:OnChangeScene()
    if self._talkButton then
        self._talkButton:removeAllChildren()
    end
    self:CheckCloseSUIWin()
end

function NPCLayerMediator:OnReleaseMemory()
    if self._talkButton then
        self._talkButton:release()
        self._talkButton = nil
    end
end

function NPCLayerMediator:AddWinBindNPCIdx(widget, npcID)
    if not widget or not npcID then
        return
    end
    npcID = tostring(npcID)
    if not self._npcBindWinList[npcID] then
        self._npcBindWinList[npcID] = {}
    end
    table.insert(self._npcBindWinList[npcID], widget)
end

function NPCLayerMediator:CheckCloseSUIWin(...)
    for npcID, winList in pairs(self._npcBindWinList) do        
        local function closeBindWins()
            for _, win in ipairs(winList) do
                if win and not tolua.isnull(win) then
                    ssr.GUI:Win_Close(win)
                end
            end
            self._npcBindWinList[npcID] = {}
        end
        
        local npc = global.npcManager:FindOneNpcInCurrViewFieldById(npcID)
        if not npc then
            closeBindWins()
        else
            local mainPlayer = global.gamePlayerController:GetMainPlayer()
            if mainPlayer then
                local x = mainPlayer:GetMapX()
                local y = mainPlayer:GetMapY()
                local dis = math.max(math.abs(x - npc:GetMapX()), math.abs(y - npc:GetMapY()))
                if dis >= 8 then
                    closeBindWins()
                end
            end
        end
    end
end

return NPCLayerMediator