local BaseUIMediator = requireMediator("BaseUIMediator")
local SUIComponentMediator = class("SUIComponentMediator", BaseUIMediator)
SUIComponentMediator.NAME = "SUIComponentMediator"

function SUIComponentMediator:ctor()
    SUIComponentMediator.super.ctor(self)

    self._components    = {}
    self._ssrComponents = {}
    self._suiEscWinList = {}
end

function SUIComponentMediator:listNotificationInterests()
    local noticeTable = global.NoticeTable
    return 
    {
        noticeTable.SUIComponentAttach,
        noticeTable.SUIComponentDetach,
        noticeTable.SUIComponentUpdate,
        noticeTable.Bag_Oper_Data,
        noticeTable.SUIComponentAttachBySSR,
        noticeTable.SUIComponentUpdateByLua,
        noticeTable.ReleaseMemory,
        noticeTable.Bag_Oper_Data_Delay,
    }
end

function SUIComponentMediator:handleNotification(notification)
    local noticeTable = global.NoticeTable
    local noticeID = notification:getName()
    local data = notification:getBody()

    if noticeID == noticeTable.SUIComponentAttach then
        self:onSUIComponentAttach(data)
        self:onSSRComponentAttach(data)

    elseif noticeID == noticeTable.SUIComponentDetach then
        self:onSUIComponentDetach(data)
        self:onSSRComponentDetach(data)

    elseif noticeID == noticeTable.SUIComponentUpdate then
        self:onSUIComponentUpdate(data)

    elseif noticeID == noticeTable.SUIComponentAttachBySSR then
        self:onSSRComponentUpdate(data)

    elseif noticeID == noticeTable.SUIComponentUpdateByLua then
        self:onSUIComponentUpdateByLua(data)
    
    elseif noticeID == noticeTable.ReleaseMemory then
        self:OnReleaseMemory()
        return
    end

    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
    SUIComponentProxy:checkAllTriggers(noticeID)
end

-----------------------------------------------------------------------
--- 挂接
function SUIComponentMediator:onSUIComponentAttach(data)
    local root          = data.root
    local index         = data.index

    if nil ~= self._components[index] then
        return nil
    end

    -- 
    self._components[index] = 
    {
        root            = root,
        index           = index,
        renders         = {},
    }

    -- 
    self:onSUIComponentUpdate({index = index})
end

function SUIComponentMediator:onSUIComponentDetach(data)
    local root          = data.root
    local index         = data.index

    if nil == self._components[index] then
        return nil
    end

    -- remove render
    for _, render in pairs(self._components[index].renders) do
        render:removeFromParent()
    end

    self._components[index] = nil
end
-----------------------------------------------------------------------


-----------------------------------------------------------------------
--- 增删改
function SUIComponentMediator:onSUIComponentUpdate(data)
    local index         = data.index
    local subid         = data.subid
    local updateAll     = (subid == nil)

    if nil == self._components[index] then
        return nil
    end
    if nil == self._components[index].root then
        return nil
    end

    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)


    if updateAll then
        -- remove all
        for _, render in pairs(self._components[index].renders) do
            render:removeFromParent()
        end
        self._components[index].renders = {}

        -- load all
        local renders   = SUIComponentProxy:loadSUIRenderAll(index, self._components[index].root)
        for subid, render in pairs(renders) do
            self._components[index].root:addChild(render)
            self._components[index].renders[subid] = render
            render:registerScriptHandler(function(state)
                if state == "exit" then
                    self._components[index].renders[subid] = nil
                end
            end)
        end

        if tonumber(SL:GetMetaValue("GAME_DATA", "missionControl") or 0) == 1 then 
            if index == global.SUIComponentTable.MainRootMission and next(renders) then
                global.Facade:sendNotification(global.NoticeTable.Layer_Assist_HideMission)
                SLBridge:onLUAEvent(LUA_EVENT_ASSIST_MISSION_SHOW, false)
            elseif index == global.SUIComponentTable.MainRootMission and (not renders or not next(renders))then
                global.Facade:sendNotification(global.NoticeTable.Layer_Assist_ShowMission)
                SLBridge:onLUAEvent(LUA_EVENT_ASSIST_MISSION_SHOW, true)
            end
        end
    else
        -- remove last subid
        if self._components[index].renders[subid] then
            self._components[index].renders[subid]:removeFromParent()
        end
        self._components[index].renders[subid] = nil

        -- load one
        local render    = SUIComponentProxy:loadSUIRender(index, subid, self._components[index].root)
        if render then
            self._components[index].root:addChild(render)
            self._components[index].renders[subid] = render
            render:registerScriptHandler(function(state)
                if state == "exit" then
                    self._components[index].renders[subid] = nil
                end
            end)
        end

        if index == global.SUIComponentTable.MainRootMission and tonumber(SL:GetMetaValue("GAME_DATA", "missionControl") or 0) == 1 then
            if render then
                global.Facade:sendNotification(global.NoticeTable.Layer_Assist_HideMission)
                SLBridge:onLUAEvent(LUA_EVENT_ASSIST_MISSION_SHOW, false)
            else
                global.Facade:sendNotification(global.NoticeTable.Layer_Assist_ShowMission)
                SLBridge:onLUAEvent(LUA_EVENT_ASSIST_MISSION_SHOW, true)
            end
        end
    end
end

----------------------------------SSR
---
function SUIComponentMediator:onSSRComponentAttach(data)
    local root          = data.root
    local index         = data.index

    if nil ~= self._ssrComponents[index] then
        return nil
    end

    -- 
    self._ssrComponents[index] = 
    {
        root            = root,
        index           = index,
        renders         = {},
    }

    -- 
    self:onSUIComponentUpdateByLua({index = index})
end

function SUIComponentMediator:onSSRComponentDetach(data)
    local root          = data.root
    local index         = data.index

    if nil == self._ssrComponents[index] then
        return nil
    end

    -- remove render
    for _, render in pairs(self._ssrComponents[index].renders) do
        if render.Stop then
            render:Stop()
        end
        render:removeFromParent()
    end

    self._ssrComponents[index] = nil
end

function SUIComponentMediator:onSUIComponentUpdateByLua( data )
    local index         = data.index
    local subid         = data.subid
    local updateAll     = (subid == nil)

    if nil == self._ssrComponents[index] then
        return nil
    end
    if nil == self._ssrComponents[index].root then
        return nil
    end

    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)

    if updateAll then
        -- remove all
        for _, render in pairs(self._ssrComponents[index].renders) do
            if render.Stop then
                render:Stop()
            end
            render:removeFromParent()
        end
        self._ssrComponents[index].renders = {}

        -- load all
        local data      = SUIComponentProxy:GetWidgetData(index) 
        local renders   = data 
        if renders and next(renders) then
            for subid, render in pairs(renders) do
                if render and render.content and not tolua.isnull(render.content) then
                    self._ssrComponents[index].root:addChild(render.content)
                    
                    -- 重新初始化GoodsItem/刷新特效
                    local function reInitItem(item)
                        if item._isGood then
                            if item._Clear then
                                item:_Clear()
                            end
                            if item.init and item._data then
                                local _replaceClickEvent = item._replaceClickEvent
                                local _pressCallback = item._pressCallback
                                local _doubleEvent = item._doubleEvent
                                local _itemData = item._itemData
                                local _extraLockStatus = item._extraLockStatus
                                local _greyStatus      = item._greyStatus

                                item:init(item._data)
                                item:addReplaceClickEventListener(_replaceClickEvent)
                                item:addPressCallBack(_pressCallback) 
                                item:addDoubleEventListener(_doubleEvent)
                                item:UpdateGoodsItem(_itemData)
                                item:setItemTouchSwallow(not item._noSwallow)
                                if type(_extraLockStatus) == "boolean" then
                                    item:setItemExtraLockStatus(_extraLockStatus)
                                end
                                if type(_greyStatus) == "boolean" then
                                    item:setIconGrey(_greyStatus)
                                end
                            end
                        end

                        if item.Replay then
                            item:Replay()
                        end
                    end

                    local function foreachChildren(parent)
                        reInitItem(parent)
                        local children = parent:getChildren()
                        if #children > 0 then
                            for _, child in ipairs(children) do
                                foreachChildren(child)
                            end
                        end
                    end
                    foreachChildren(render.content)
                    
                    self._ssrComponents[index].renders[subid] = render.content
                    render.content:registerScriptHandler(function(state)
                        if state == "exit" then
                            self._ssrComponents[index].renders[subid] = nil
                        end
                    end)
                end
            end
        end

        if tonumber(SL:GetMetaValue("GAME_DATA", "missionControl") or 0) == 1 then 
            if index == global.SUIComponentTable.MainRootMission and next(renders) then
                global.Facade:sendNotification(global.NoticeTable.Layer_Assist_HideMission)
                SLBridge:onLUAEvent(LUA_EVENT_ASSIST_MISSION_SHOW, false)
            elseif index == global.SUIComponentTable.MainRootMission and (not renders or not next(renders))then
                global.Facade:sendNotification(global.NoticeTable.Layer_Assist_ShowMission)
                SLBridge:onLUAEvent(LUA_EVENT_ASSIST_MISSION_SHOW, true)
            end
        end
    else
        -- remove last subid
        if self._ssrComponents[index].renders[subid] then
            self._ssrComponents[index].renders[subid]:release()
            self._ssrComponents[index].renders[subid]:removeFromParent()
        end
        self._ssrComponents[index].renders[subid] = nil

        -- load one
        local data      = SUIComponentProxy:GetWidgetData(index, subid)
        local render    = data and data.content
        if render and not tolua.isnull(render) then
            self._ssrComponents[index].root:addChild(render)
            self._ssrComponents[index].renders[subid] = render
            render:registerScriptHandler(function(state)
                if state == "exit" then
                    self._ssrComponents[index].renders[subid] = nil
                end
            end)
        end

        if index == global.SUIComponentTable.MainRootMission and tonumber(SL:GetMetaValue("GAME_DATA", "missionControl") or 0) == 1 then
            if render and not tolua.isnull(render) then
                global.Facade:sendNotification(global.NoticeTable.Layer_Assist_HideMission)
                SLBridge:onLUAEvent(LUA_EVENT_ASSIST_MISSION_SHOW, false)
            else
                global.Facade:sendNotification(global.NoticeTable.Layer_Assist_ShowMission)
                SLBridge:onLUAEvent(LUA_EVENT_ASSIST_MISSION_SHOW, true)
            end
        end
    end
end

function SUIComponentMediator:onSSRComponentUpdate( data )
    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
    SUIComponentProxy:UpdateAttachComponentByLua(data)
end

function SUIComponentMediator:OnReleaseMemory( ... )
    if self._ssrComponents and next(self._ssrComponents) then
        for _, component in pairs(self._ssrComponents) do
            if component and component.renders and next(component.renders) then
                for subid, render in pairs(component.renders) do
                    if component.renders[subid] then
                        component.renders[subid]:release()
                        component.renders[subid] = nil
                    end
                end
            end
        end
        self._ssrComponents = {}
    end
end
-----------------------------------------------------------------------
--- sui esc
function SUIComponentMediator:AddToESCList( widget )
    if widget then
        table.insert(self._suiEscWinList, widget)
    end
end

function SUIComponentMediator:CloseSUIAddWin()
    if not self._suiEscWinList or not next(self._suiEscWinList) then
        return false
    end

    local closeSuccess = false
    while not closeSuccess do
        if not next(self._suiEscWinList) then
            return closeSuccess
        end
        local win = table.remove( self._suiEscWinList, 1)
        if win and not tolua.isnull(win) then
            ssr.GUI:Win_Close(win)
            closeSuccess = true
        end
    end
    
    return closeSuccess
end


return SUIComponentMediator
