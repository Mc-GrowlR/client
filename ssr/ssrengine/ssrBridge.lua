local ssrBridge = class("ssrBridge")

function ssrBridge:ctor()
    self._ssrObjs = {}
    self._ssrMediators = {}

    self.uiRootN = nil
    self.uiRootT = nil
end

function ssrBridge:EnterWorld()
    -- ssr network init
    ssr.NetworkUtil = SL.NetworkUtil

    -- init ssr game mod
    if global.FileUtilCtl:isFileExist("scripts/ssr/ssrgame/ssrmain.lua") or global.FileUtilCtl:isFileExist("scripts/ssr/ssrgame/ssrmain.luac") then
        ssr.print("ssr was deprecated, use [SLFramework] instead please!")
        ssr.print("ssr was deprecated, use [SLFramework] instead please!")
        ssr.print("ssr was deprecated, use [SLFramework] instead please!")
        ssr.print("ssr was deprecated, use [SLFramework] instead please!")
        ssr.print("ssr was deprecated, use [SLFramework] instead please!")
        
        package.loaded["ssr/ssrgame/ssrmain"] = nil
        require("ssr/ssrgame/ssrmain")
    end
end

function ssrBridge:LeaveWorld()
    ssr.GUI.WinLayers = {} 
    ssr.GUI.Mediators = {} 
    ssr.ssrBridge.LUAEvent = {}

    local files = ssr.define.LUAFile
    for k, v in pairs(files) do
        package.loaded[v] = nil
    end
end

-------------------------------------------------------------
-- ssr event
function ssrBridge:_registerObj(obj)
    self._ssrObjs[obj.NAME] = obj
end

function ssrBridge:_dispatchEventObj(eventName, eventData)
    for _, v in pairs(self._ssrObjs) do
        v:onEvent(eventName, eventData)
    end

    local mediatorList = self._ssrMediators[eventName]
    if mediatorList and next(mediatorList) then
        for _, v in pairs(mediatorList) do
            local func  = v.func
            local ID = v.GUI_ID
            if ID and ssr.GUI.WinLayers[ID] and not tolua.isnull(ssr.GUI.WinLayers[ID]) then
                if ( eventName == "OnGUINewWinClose" and eventData and ID == eventData ) or  eventName ~= "OnGUINewWinClose" then
                    if type(func) == "function" then
                        func(eventData)
                    end
                end
            end
        end
    end

    -- ss
    if not ssr.ssrBridge.LUAEvent then
        return
    end

    if not ssr.ssrBridge.LUAEvent[eventName] then
        return
    end

    for eventTag, eventCB in pairs(ssr.ssrBridge.LUAEvent[eventName]) do
        eventCB(eventData, eventTag)
    end
end

function ssrBridge:NewWin_RegisterGameEvent(win, eventName, func)
    if not self._ssrMediators[eventName] then
        self._ssrMediators[eventName] = {}
    end
    local mediator = win.mediator
    local ID       = win.ID
    local data = {
        GUI_ID   = ID,
        func     = func
    }

    self._ssrMediators[eventName][ID] = data
end

function ssrBridge:addToUINormal(child, obj)
    self.uiRootN:addChild(child, 1)

    local LayerFacadeMediator = global.Facade:retrieveMediator("LayerFacadeMediator")
    if obj and obj._layer then
        obj._mediatorName = "__SSR_GUI_BASEOBJ"..(obj.NAME and "_"..obj.NAME  or "")
        LayerFacadeMediator:AddSSROBJNormalMediator(obj)
    end
end

function ssrBridge:addToUITips(child)
    self.uiRootT:addChild(child, 4)
end

function ssrBridge:addToUINotice(child, mainIndex)
    self.uiRootT:addChild(child, 6)
end

function ssrBridge:addToUIMain(child, mainIndex)
    local idxList = {
        MAIN_NODE_LT = 101,
        MAIN_NODE_RT = 102,
        MAIN_NODE_LB = 103,
        MAIN_NODE_RB = 104,
        MAIN_NODE_MT = 106,
        MAIN_NODE_MB = 108,
    }
    if mainIndex and idxList[mainIndex] then
        local parent = ssr.GUI:GetSUIParent(idxList[mainIndex])
        parent:addChild(child)
        return
    end

    local data = {}
    data.child = child
    data.index = mainIndex
    global.Facade:sendNotification(global.NoticeTable.Layer_Main_AddChild, data)
end

-------------------------------------------------------------
-- GUI
function ssrBridge:setGUIParent(index, parent)
    ssr.GUI:SetGUIParent(index, parent)
    GUI:SetGUIParent(index, parent)
end

-------------------------------------------------------------
-- game event
function ssrBridge:onInitRootWorld(uiN, uiT)
    self.uiRootN = uiN
    self.uiRootT = uiT
end


function ssrBridge:onWorldInfoInit()
    --
    self:_dispatchEventObj("onWorldInfoInit")

    self:EnterWorld()
end

function ssrBridge:onDisconnect()
    self:_dispatchEventObj("onDisconnect")
end

function ssrBridge:onReconnect()
    self:_dispatchEventObj("onReconnect")
end

function ssrBridge:onMapInfoChange(data)
    self:_dispatchEventObj("onMapInfoChange", data)
end

function ssrBridge:onChangeScene(data)
    self:_dispatchEventObj("onChangeScene", data)
end

function ssrBridge:onPlayerPropertyInited()
    self:_dispatchEventObj("onPlayerPropertyInited")
end

function ssrBridge:onPlayerLevelChange(currlevel, lastlevel)
    self:_dispatchEventObj("onPlayerLevelChange", {currlevel = currlevel, lastlevel = lastlevel})
end

function ssrBridge:onPlayerPropertyChange()
    self:_dispatchEventObj("onPlayerPropertyChange")
end

function ssrBridge:OnPlayerManaChange(curHP, maxHP, curMP, maxMP, roleName)
    self:_dispatchEventObj("onPlayerManaChange", {curHP = curHP, maxHP = maxHP, curMP = curMP, maxMP = maxMP, roleName = roleName})
end

function ssrBridge:OnPlayerNameInited( roleName )
    self:_dispatchEventObj("OnPlayerNameInited", {roleName = roleName})
end

function ssrBridge:OnPlayerMoneyChange(data)
    self:_dispatchEventObj("OnPlayerMoneyChange", data)
end

function ssrBridge:OnTargetChange(actorID, actorName, curHP, maxHP, level, type, masterID, typeID, mapX, mapY)
    if not actorID then
        self:_dispatchEventObj("OnTargetChange", {})
    end
    self:_dispatchEventObj("OnTargetChange", {actorID = actorID, actorName = actorName, curHP = curHP, maxHP = maxHP, level = level, type = type, masterID = masterID, typeID = typeID, mapX = mapX, mapY = mapY})
end

function ssrBridge:OnRefreshTargetHP(actorID, curHP, maxHP)
    self:_dispatchEventObj("OnRefreshTargetHP", {actorID = actorID, curHP = curHP, maxHP = maxHP})
end

function ssrBridge:OnTakeOnEquip(isSuccess, pos)
    self:_dispatchEventObj("OnTakeOnEquip", {isSuccess = isSuccess, pos = pos})
end

function ssrBridge:OnTakeOffEquip(isSuccess, pos)
    self:_dispatchEventObj("OnTakeOffEquip", {isSuccess = isSuccess, pos = pos})
end

function ssrBridge:OnChangePKStateSuccess(pkMode)
    self:_dispatchEventObj("OnChangePKStateSuccess", {pkMode = pkMode})
end

function ssrBridge:OnBatteryValueChange(value)
    self:_dispatchEventObj("OnBatteryValueChange", value)
end

function ssrBridge:OnPlayerExpChange(changed)
    self:_dispatchEventObj("OnPlayerExpChange", {changed = changed})
end

function ssrBridge:OnNetStateChange(type)
    self:_dispatchEventObj("OnNetStateChange", {type = type})
end

function ssrBridge:OnBagOperData(data)
    self:_dispatchEventObj("OnBagOperData", data)
end

function ssrBridge:OnActionBegin(type)
    if type and type == global.MMO.ACTION_RUN then
        type = 2
    end
    self:_dispatchEventObj("OnActionBegin", type)
end

function ssrBridge:OnPetActionBegin(actorID, type, mapX, mapY, actorName)
    self:_dispatchEventObj("OnPetActionBegin", {actorID = actorID, type = type, mapX = mapX, mapY = mapY, actorName = actorName})
end

function ssrBridge:OnSkillAdd(data)
    self:_dispatchEventObj("OnSkillAdd", data)
end

function ssrBridge:OnSkillDel(data)
    self:_dispatchEventObj("OnSkillDel", data)
end

function ssrBridge:OnSkillUpdate(data)
    self:_dispatchEventObj("OnSkillUpdate", data)
end

function ssrBridge:OnAddChatItem( data )
    self:_dispatchEventObj("OnAddChatItem", data)
end

function ssrBridge:OnLookPlayerDataUpdate(data)
    self:_dispatchEventObj("OnLookPlayerDataUpdate", data)
end

function ssrBridge:OnAutoFightBegin( ... )
    self:_dispatchEventObj("OnAutoFightBegin")
end

function ssrBridge:OnAutoFightEnd( ... )
    self:_dispatchEventObj("OnAutoFightEnd")
end

function ssrBridge:OnPlayerEquipInit( ... )
    self:_dispatchEventObj("OnPlayerEquipInit")
end

function ssrBridge:OnCloseBag( ... )
    self:_dispatchEventObj("OnCloseBag")
end

function ssrBridge:OnJoinOrExitGuild(type, guildName)
    -- 1加入 2退出
    self:_dispatchEventObj("OnJoinOrExitGuild", {type = type, guildName = guildName})
end

function ssrBridge:OnPreBagOperData(data)
    self:_dispatchEventObj("OnPreBagOperData", data)
end

function ssrBridge:OnAcrossDay()
    self:_dispatchEventObj("OnAcrossDay")
end

function ssrBridge:OnRichTextOpenUrl(data)  -- ...
    self:_dispatchEventObj("OnRichTextOpenUrl", data)
end

function ssrBridge:OnMainPlayerDie()
    self:_dispatchEventObj("OnMainPlayerDie")
end

function ssrBridge:OnMainPlayerRevive()
    self:_dispatchEventObj("OnMainPlayerRevive")
end

function ssrBridge:OnMainPlayerBuffChange()
    self:_dispatchEventObj("OnMainPlayerBuffChange")
end

function ssrBridge:OnQuickUseOperData(data)
    self:_dispatchEventObj("OnQuickUseOperData", data)
end

function ssrBridge:OnGUINewWinClose(data)
    self:_dispatchEventObj("OnGUINewWinClose", data)
end

function ssrBridge:OnClickChatPlayerMsg(playerId, playerName, widget)
    local data = {
        playerId = playerId,
        playerName = playerName,
        widget = widget
    }
    self:_dispatchEventObj("OnClickChatPlayerMsg", data)
end

function ssrBridge:OnStoreDataRefreshByPage(data, page)
    local data = {
        pageData = data,
        pageId = page,
    }
    self:_dispatchEventObj("OnStoreDataRefreshByPage", data)
end

function ssrBridge:OnOpenOrCloseMiniMap(data)
    self:_dispatchEventObj("OnOpenOrCloseMiniMap", data)
end

function ssrBridge:OnItemTipsMouseScroll(data)
    self:_dispatchEventObj("OnItemTipsMouseScroll", data)
end

function ssrBridge:OnAutoMoveBegin(data)
    self:_dispatchEventObj("OnAutoMoveBegin", data)
end

function ssrBridge:OnAutoMoveEnd()
    self:_dispatchEventObj("OnAutoMoveEnd")
end

------------------
function ssrBridge:onLeaveWorld()
    self:_dispatchEventObj("onLeaveWorld")

    self:LeaveWorld()
end

function ssrBridge:onRestartGame()
    self:_dispatchEventObj("onRestartGame")
end

function ssrBridge:onGameSuspend()
    self:_dispatchEventObj("onGameSuspend")
end

function ssrBridge:onGameResumed()
    self:_dispatchEventObj("onGameResumed")
end

return ssrBridge