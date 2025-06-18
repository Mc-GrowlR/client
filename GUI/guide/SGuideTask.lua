local SGuideTask = class("SGuideTask")

function SGuideTask:ctor(data--[[,config]])
    self._GuideFuncConfig = requireConfig("GuideWidgetConfig.lua")
    self._GuideEventConfig = requireConfig("GuideEventConfig.lua")
    self._data = data
    self._mainID = data and tonumber(data.id)
    self._uiID   = data and tonumber(data.param)-- or data.param
    self._ssrWidget = data and data.guideWidget
    self._ssrParent = data and data.guideParent
    self._desc      = data and data.guideDesc 
    self._clickCallback = data and data.clickCB
    self._autoExcute    = data and tonumber(data.autoExcute)
    self._isForce       = data and data.isForce

    self._mainType      = data and tonumber(data.mainIdx)  -- 主界面
    self._hideMask      = data and data.hideMask           -- 禁止蒙版

    ----
    self._widget = nil
    self._parent = nil
    self._position  = nil
    self._contenSize = nil
    self._active = true
    
end

function SGuideTask:GetWidget()
    return self._widget
end

function SGuideTask:GetParent()
    return self._parent
end

function SGuideTask:GetConfig()
    return self._data
end

function SGuideTask:IsForce()
    return self._isForce and true or false
end

function SGuideTask:SetAutoExcute( time )
    if time and tonumber(time) then
        self._autoExcute = tonumber(time)
    end
end

function SGuideTask:Start( ... )
    if not self._active then return end
    self._layoutBlack = ccui.Layout:create()
    self._layoutBlack:setContentSize(global.Director:getVisibleSize())
    self._layoutBlack:setTouchEnabled(true)
    self._layoutBlack:setSwallowTouches(true)
    self._layoutBlack:addTouchEventListener(function ( sender, eventType)
        if eventType == 0 then
        end
    end)

    global.Director:getRunningScene():addChild(self._layoutBlack,999)

    if self._mainID  then
        local getNodesFunc = self._GuideFuncConfig[self._mainID]
        if not getNodesFunc then
            self._active = false
            return 
        end

        local temp = { typeassist = self._uiID }
        self._widget, self._parent = getNodesFunc(temp)

        if self._mainID == 110 then--如果是任务就先把框漏出来
            global.Facade:sendNotification(global.NoticeTable.Layer_Assist_ChangeHide, true)
        elseif self._mainID == 109 then -- 按钮模块 切换
            global.Facade:sendNotification(global.NoticeTable.GuideEnterTransition, {name = "GUIDE_BEGIN_SKILL_BUTTON"})
        elseif self._mainID == 1 or self._mainID == 47 then -- 背包 英雄背包 的双击使用
            if self._mainID == 1 then 
                local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
                self._BagPage = BagProxy:GetBagPageByMakeIndex(self._uiID)
                if self._BagPage and self._parent then --页数不对  得切换 一下
                    local curPage = self._parent.GetSelectPage and self._parent:GetSelectPage() or SL:GetMetaValue("BAG_PAGE_CUR")
                    if curPage ~= self._BagPage then
                        global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Open, {bag_page = self._BagPage})
                    end
                end
            end
            
            if self._uiID ~= -1 then
                self._clickCallback = function ()
                    local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
                    local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
                    local nowItemData = ItemManagerProxy:GetItemDataByMakeIndex(self._uiID)
                    local ItemUseProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemUseProxy)
                    if self._mainID == 1 then
                        nowItemData.from = ItemMoveProxy.ItemFrom.BAG
                        ItemUseProxy:UseItem(nowItemData)
                    else
                        nowItemData.from = ItemMoveProxy.ItemFrom.HERO_BAG
                        ItemUseProxy:HeroUseItem(nowItemData)
                    end
                end
            end
        end

        --关闭chat
        global.Facade:sendNotification(global.NoticeTable.Layer_Chat_Close)
        if not self._widget or not self._parent then
            self._scheduleId = PerformWithDelayGlobal(function()
                if self._layoutBlack then
                    self._layoutBlack:removeFromParent()
                    self._layoutBlack = nil
                end
                self._widget, self._parent = getNodesFunc(temp)
                if not self._widget or not self._parent then
                    self._active = false
                    return
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_SGuide_Open, self)
            end, 1)
        else
            if self._layoutBlack then
                self._layoutBlack:removeFromParent()
                self._layoutBlack = nil
            end
            global.Facade:sendNotification(global.NoticeTable.Layer_SGuide_Open, self)
        end

    elseif self._ssrWidget and self._ssrParent and self._active then
        self._widget = self._ssrWidget
        self._parent = self._ssrParent

        if tolua.isnull(self._widget) or tolua.isnull(self._parent) then
            self._widget = nil
            self._parent = nil
            return
        end

        -- if not self._clickCallback then
        --     self._clickCallback = not tolua.isnull(self._widget) and global.ScriptHandlerMgr:getObjectHandler(self._widget)
        -- end

        if self._layoutBlack then
            self._layoutBlack:removeFromParent()
            self._layoutBlack = nil
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_SGuide_Open, self)
        
    end
end

function SGuideTask:onGuideNodeChange(data)
    -- dump(data,"onGuideNodeChange___")
    if   self._active then
        if data.widget then
            self._widget = data.widget
        else
            self._position = data.pos
            self._contentSize = data.size
        end
        -- self._widget = data.widget

        global.Facade:sendNotification(global.NoticeTable.Layer_SGuide_Open, self)
        if self._scheduleId then
            UnSchedule(self._scheduleId)
            self._scheduleId = nil
        end
        if self._layoutBlack then
            self._layoutBlack:removeFromParent()
            self._layoutBlack = nil
        end
    end
end

function SGuideTask:IsActive()
    return self._active
end

function SGuideTask:Exit()
    global.Facade:sendNotification(global.NoticeTable.Layer_SGuide_Close)
    -- self._active = false
end

function SGuideTask:Destory( ... )
    global.Facade:sendNotification(global.NoticeTable.Layer_SGuide_Close)
    self._active = false
    self._widget = nil
    self._parent = nil
end

return SGuideTask
