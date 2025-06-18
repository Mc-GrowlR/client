local GuideTask = class("GuideTask")

function GuideTask:ctor(data--[[,config]])
    self._GuideWidgetConfig = requireConfig("GuideWidgetConfig.lua")
    self._GuideEventConfig = requireConfig("GuideEventConfig.lua")
    self._data = data
    self._widget = nil
    self._parent = nil
    self._position  = nil
    self._contenSize = nil
    self._active = true
end


function GuideTask:GetWidget()
    return self._widget
end

function GuideTask:GetParent()
    return self._parent
end

function GuideTask:Enter()
    local idx = tonumber(self._data.mainId)
    local id = tonumber(self._data.uiId)
    self._mainID = idx
    self._uiID = id
    dump(self._data,"mainId__")
    ---------------------创建个吞噬触摸的
     local layoutBlack = ccui.Layout:create()
    layoutBlack:setContentSize(global.Director:getVisibleSize())
    layoutBlack:setTouchEnabled(true)
    layoutBlack:addTouchEventListener(function (sender,eventType)
        if eventType == 0 then
            dump("touch____")
            layoutBlack:setSwallowTouches(true)
        end
    end)
    self._layoutBlack = layoutBlack
    global.Director:getRunningScene():addChild(layoutBlack,999)
    -----------------------------
    -----------------------直接找控件
    local getNodesFunc = self._GuideWidgetConfig[idx]
    if not getNodesFunc then
        self._active = false
        return 
    end
    local temp = { typeassist = self._data.uiId }
    self._widget, self._parent = getNodesFunc(temp)
    self._StartEventName = self._GuideEventConfig[idx] and self._GuideEventConfig[idx].startEventTag
    self._EndEventName = self._GuideEventConfig[idx] and self._GuideEventConfig[idx].closeEventTag
    self.getNodesFunc = getNodesFunc
    dump(self._widget,"控件:")
    dump(self._parent,"父节点:")
    if idx == 110 then--如果是任务就先把框漏出来
        global.Facade:sendNotification(global.NoticeTable.Layer_Assist_ChangeHide, true)

    elseif idx == 109 then -- 按钮模块 切换
        global.Facade:sendNotification(global.NoticeTable.GuideEnterTransition, {name = "GUIDE_BEGIN_SKILL_BUTTON"})
    elseif idx == 1 or idx == 47 then -- 背包 英雄背包 的双击使用
        if idx == 1 then 
            local BagProxy = global.Facade:retrieveProxy(global.ProxyTable.Bag)
            self._BagPage =  BagProxy:GetBagPageByMakeIndex(self._data.uiId)
            if self._BagPage and self._parent then --页数不对  得切换 一下
                local curPage = self._parent.GetSelectPage and self._parent:GetSelectPage() or SL:GetMetaValue("BAG_PAGE_CUR")
                if curPage ~= self._BagPage then
                    global.Facade:sendNotification(global.NoticeTable.Layer_Bag_Open, {bag_page = self._BagPage})
                end
            end
        end
        
        if id ~= -1 then
            self._clickCallback = function ()
                local ItemManagerProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemManagerProxy)
                local ItemMoveProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemMoveProxy)
                local nowItemData = ItemManagerProxy:GetItemDataByMakeIndex(id)
                local ItemUseProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemUseProxy)
                if idx == 1 then
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
    if not self._widget or not self._parent then--有一个没有  就等一秒或等消息重新找
           self._scheduleId = PerformWithDelayGlobal(function()
                if self._layoutBlack then
                    self._layoutBlack:removeFromParent()
                    self._layoutBlack = nil
                end
                self._widget, self._parent = getNodesFunc(temp)
                dump(self._widget,"控件2:")
                dump(self._parent,"父节点2:")
                if not self._widget or not self._parent then--还没有直接gg
                    self._active = false
                    return
                end
                global.Facade:sendNotification(global.NoticeTable.Layer_Guide_Open, self)
           end, 1)
    else
        if self._layoutBlack then
            self._layoutBlack:removeFromParent()
            self._layoutBlack = nil
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_Guide_Open, self)
    end



















    -- function func()
    --     local getNodesFunc = self._GuideWidgetConfig[idx]
    --     if not getNodesFunc then
    --         return 
    --     end
        
    --     local temp = { typeassist = self._data.uiId }
    --     self._widget, self._parent ,self._wait= getNodesFunc(temp)
    --     -- get guide node
    --     -- self._widget, self._parent = event(self._config, self._data)
    --     if self._wait then
    --         local id = tonumber(self._data.uiId)
    --         dump(id,"id_____")
    --         if id and id >20000 then
    --             id = id - 20000
    --         end
    --         global.Facade:sendNotification(global.NoticeTable.Layer_Equip_Retrieve_Get_CheckBox_Pos,{id=id})
    --     end
    --     if layoutBlack and not tolua.isnull(layoutBlack) then
    --         layoutBlack:removeFromParent()
    --         layoutBlack = nil
    --     end
    --     if (not self._widget) or (not self._parent) then
    --         dump(self._widget,"控件:")
    --         dump(self._parent,"父节点:")
    --         return nil
    --     end
    --     if idx == 110 then--如果是任务就先把框漏出来
    --         global.Facade:sendNotification(global.NoticeTable.MainAssistLayout_Show_Assist)
    --     elseif idx == 1000 then --回收这里 要特殊操作
    --         self._clickCallback = function ()
    --             local id = tonumber(self._data.uiId)
    --             local state = false
    --             if id and id >20000 then--大于20000强制打钩
    --                 id = id - 20000
    --                 state = true          
    --             end

    --             if id == 20000 then
    --                 local EquipRetrieveProxy = global.Facade:retrieveProxy(global.ProxyTable.EquipRetrieveProxy)
    --                 EquipRetrieveProxy:RequestRetreive()
    --                 return
    --             end
    --             global.Facade:sendNotification(global.NoticeTable.Layer_Equip_Retrieve_Set_CheckBox_State,{id=id,state=state}) 
    --         end

    --     end
    --     --关闭chat
    --     global.Facade:sendNotification(global.NoticeTable.Layer_Chat_Close)
    --     -- open guide layer
       
    --     local delayTime = 0
    --     if self._wait then
    --         delayTime = 0.6
    --         local layoutBlack = ccui.Layout:create()
    --         layoutBlack:setContentSize(global.Director:getVisibleSize())
    --         layoutBlack:setTouchEnabled(true)
    --         layoutBlack:addTouchEventListener(function (sender,eventType)
    --             if eventType == 0 then
    --                 layoutBlack:setSwallowTouches(true)
    --             end
    --         end)
    --         global.Director:getRunningScene():addChild(layoutBlack,999)
    --         local fun2 = function ()
    --             if layoutBlack and not tolua.isnull(layoutBlack) then
    --                 layoutBlack:removeFromParent()
    --                 layoutBlack = nil
    --             end
    --             global.Facade:sendNotification(global.NoticeTable.Layer_Guide_Open, self)
    --         end
    --         PerformWithDelayGlobal(fun2,delayTime)
    --     else
    --         global.Facade:sendNotification(global.NoticeTable.Layer_Guide_Open, self)
    --     end
        
    -- end
    -- local delayTime2 = 0.3
    -- if idx == 1000 then
    --     delayTime2 = 0.2
    -- end
    -- PerformWithDelayGlobal(func,delayTime2)    

end

function GuideTask:onGuideNodeChange(data)
    dump(data,"onGuideNodeChange___")
    if   self._active then
       if data.widget then
            self._widget = data.widget
        else
            self._position = data.pos
            self._contentSize = data.size
       end
        -- self._widget = data.widget

        global.Facade:sendNotification(global.NoticeTable.Layer_Guide_Open, self)
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
function GuideTask:isActive()
    return self._active
end
function GuideTask:onEventBegan(data)
    dump(data,"onEventBegan__")
    dump(self._StartEventName,"__StartEventName")
    dump(self._data,"_data__")
    if self._StartEventName  then
        if self._StartEventName == data.name and self._active then
             local temp = { typeassist = self._data.uiId }
             -- dump(temp,"temp__")
            self._widget, self._parent = self.getNodesFunc(temp)
            dump({self._widget, self._parent},"收到消息")
            if self._widget and self._parent then
                global.Facade:sendNotification(global.NoticeTable.Layer_Guide_Open, self)
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
    end
    
end
function GuideTask:OnGuideEventEnded(data)
    dump(data,"OnGuideEventEnded__")
    dump(self._EndEventName,"_EndEventName")
    if self._EndEventName  then
        if self._EndEventName == data.name and self._active then
            if self._BagPage and data.bag_page then
                if self._BagPage == data.bag_page then --背包有多页  相同的页数才能退
                    self:Exit()
                end
            else
                self:Exit()
            end
        end
    end
    
end

function GuideTask:Exit()
    global.Facade:sendNotification(global.NoticeTable.Layer_Guide_Close)
    self._active = false
end
return GuideTask
