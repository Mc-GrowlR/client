local function getChildInSubNodes(nodeTable, key)
    if #nodeTable == 0 then
        return nil
    end
    local child = nil
    local subNodeTable = {}
    for _, v in ipairs(nodeTable) do
        if tolua.isnull(v) then
            return nil
        end
        child = v:getChildByName(key)
        if (child) then
            return child
        end
    end
    for _, v in ipairs(nodeTable) do
        local subNodes = v:getChildren()
        if #subNodes ~= 0 then
            for _, v1 in ipairs(subNodes) do
                table.insert(subNodeTable, v1)
            end
        end
    end
    return getChildInSubNodes(subNodeTable, key)
end

local function getChildByKey(parent, key)
    return getChildInSubNodes({parent}, key)
end

-- 基础指引：
-- 0 NPC面板组件            辅助参数.组件id  
-- 101 主界面左上挂节点        辅助参数.组件id  挂节点.101
-- 102 主界面右上挂节点        辅助参数.组件id  挂节点.102
-- 103 主界面左下挂节点        辅助参数.组件id  挂节点.103
-- 104 主界面右下挂节点        辅助参数.组件id  挂节点.104
-- 105 主界面左中挂节点        辅助参数.组件id  挂节点.105
-- 106 主界面上中挂节点        辅助参数.组件id  挂节点.106
-- 107 主界面右中挂节点        辅助参数.组件id  挂节点.107
-- 108 主界面下中挂节点        辅助参数.组件id  挂节点.108
-- GuideWidgetConfig.lua
local function store_func(config)
    local id = tostring(config.typeassist)
    local PageStoreLayerMediator = global.Facade:retrieveMediator("PageStoreLayerMediator")
    if not PageStoreLayerMediator or not PageStoreLayerMediator._layer then
        return nil
    end
    if not PageStoreLayerMediator._layer.itemList then
        return nil 
    end
    local chs = PageStoreLayerMediator._layer.itemList:getChildren()
    for i,v in ipairs(chs) do
        local layout = v:getChildByName("Panel_item")
        if id == (layout and tostring(layout["guide_id"])) then 
            return layout, PageStoreLayerMediator._layer
        end
    end
    return nil
end
local config = {
    -- npc面板组件
    [0] = function(config)
        local NPCLayerMediator = global.Facade:retrieveMediator("NPCLayerMediator")
        if not NPCLayerMediator._layer then
            return nil
        end
        local widget = getChildByKey(NPCLayerMediator._layer, tostring(config.typeassist))
        local parent = NPCLayerMediator._layer
        return widget, parent
    end,
    -- 背包道具
    [1] = function(config)

        local BagLayerMediator = global.Facade:retrieveMediator("BagLayerMediator")
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        if HeroPropertyProxy:getIsMergePanelMode() then
            BagLayerMediator = global.Facade:retrieveMediator("MergeBagLayerMediator")--合并面板模式
            if not BagLayerMediator._layer or not BagLayerMediator._layer.Panel_items or BagLayerMediator._layer:getShowType() ~= 1 then
                return nil
            end
            
        else
            if not BagLayerMediator._layer or not BagLayerMediator._layer.Panel_items then
                return nil
            end
        end
        local Panel_items = BagLayerMediator._layer.Panel_items
        if not Panel_items then
            return nil
        end 
        local items = Panel_items:getChildren()
        local widget = nil
        if tonumber(config.typeassist) == -1 then 
            widget = BagLayerMediator._layer._quickUI.Button_store_hero_bag or BagLayerMediator._layer._quickUI.Button_store_mode
        else
            for i, v in ipairs(items) do
                if v:getTag() == tonumber(config.typeassist) then
                    widget = v
                    break
                end
            end
        end
        local parent = BagLayerMediator._layer
        return widget, parent
        
    end,
    -- 人物装备位
    [2] = function(config)
        local PlayerEquipLayerMediator = global.Facade:retrieveMediator("PlayerEquipLayerMediator")
        if not PlayerEquipLayerMediator._layer or not PlayerEquipLayerMediator._layer._root  then
            return nil
        end
        local widget = getChildByKey(PlayerEquipLayerMediator._layer._root, "Panel_pos"..tostring(config.typeassist))
        if not widget then --没找到装备位找自定义的
            widget = getChildByKey(PlayerEquipLayerMediator._layer, tostring(config.typeassist))
        end 
        local parent = PlayerEquipLayerMediator._layer
        return widget, parent
    end,
     -- 英雄背包
    [3] = function(config)
        local HeroBagLayerMediator = global.Facade:retrieveMediator("HeroBagLayerMediator")
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        local isMergeMode = false
        if HeroPropertyProxy:getIsMergePanelMode() then
            isMergeMode = true
            HeroBagLayerMediator = global.Facade:retrieveMediator("MergeBagLayerMediator")
            if not HeroBagLayerMediator._layer or not HeroBagLayerMediator._layer.Panel_items or HeroBagLayerMediator._layer:getShowType() ~= 2 then
                return nil
            end
        else
            if not HeroBagLayerMediator._layer or not HeroBagLayerMediator._layer.itemPanel then
                return nil
            end
        end
        local Panel_items = isMergeMode and HeroBagLayerMediator._layer.Panel_items or HeroBagLayerMediator._layer.itemPanel
        if not Panel_items then
            return nil
        end 
        local items = Panel_items:getChildren()
        local widget = nil
        if tonumber(config.typeassist) ~= -1 then 
            for i, v in ipairs(items) do
                if v:getTag() == tonumber(config.typeassist) then
                    widget = v
                    break
                end
            end
        end
        local parent = HeroBagLayerMediator._layer
        return widget, parent
        
    end,
    -- 背包挂接组件
    [7] = function(config)
        local BagLayerMediator = global.Facade:retrieveMediator("BagLayerMediator")
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        if HeroPropertyProxy:getIsMergePanelMode() then
            BagLayerMediator = global.Facade:retrieveMediator("MergeBagLayerMediator")
            if not BagLayerMediator._layer  or BagLayerMediator._layer:getShowType() ~= 1 then
                return nil
            end
        else
            if not BagLayerMediator._layer then
                return nil
            end

        end
        local widget = getChildByKey(BagLayerMediator._layer, tostring(config.typeassist))
        local parent = BagLayerMediator._layer
        return widget, parent
    end,
    --商店
    [9] = store_func,
    [10] = store_func,
    [11] = store_func,
    [12] = store_func,
    --英雄状态板
    [40] = function(config)
        --1 英雄头像   2 状态   3 背包 4召唤/收回
        local  widget, parent
        local uiid = tonumber(config.typeassist) 
        if uiid > 4 or uiid < 1 then
            return
        end
        if uiid == 1 or not global.isWinPlayMode then
            local HeroStateLayerMediator = global.Facade:retrieveMediator("HeroStateLayerMediator")
            if not HeroStateLayerMediator._layer then
                return nil
            end
            
            local child = {"Image_head", "Button_state", "Button_bag", "Button_hero"}

             widget = getChildByKey(HeroStateLayerMediator._layer, child[tonumber(config.typeassist)])
             parent = HeroStateLayerMediator._layer
           
        else
            local MainPropertyMediator = global.Facade:retrieveMediator("MainPropertyMediator")
            if not MainPropertyMediator._layer then
                return 
            end
            local child = {"Image_head", "Button_heroinfo", "Button_herobag", "Button_herostate"}

            widget = getChildByKey(MainPropertyMediator._layer, child[tonumber(config.typeassist)])
            parent = MainPropertyMediator._layer
        end

        if uiid < 4 then
            local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
            if not HeroPropertyProxy:HeroIsLogin() then
                return 
            end
        end
        return widget, parent
        
    end,
     -- 英雄装备位
    [41] = function(config)
        local HeroEquipLayerMediator = global.Facade:retrieveMediator("HeroEquipLayerMediator")
        if not HeroEquipLayerMediator._layer or not HeroEquipLayerMediator._layer._root  then
            return nil
        end
        local widget = getChildByKey(HeroEquipLayerMediator._layer._root, "Panel_pos"..tostring(config.typeassist))
        local parent = HeroEquipLayerMediator._layer
        return widget, parent
    end,


    -- 主界面 挂接组件 左上
    [101] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_SUI_LT], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,
    
    -- 主界面 挂接组件 右上
    [102] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_SUI_RT], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,
    
    -- 主界面 挂接组件 左下
    [103] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_SUI_LB], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,

    -- 主界面 挂接组件 右下
    [104] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_SUI_RB], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,
    
    -- 主界面 挂接组件 左中
    [105] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_SUI_LM], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,
    
    -- 主界面 挂接组件 上中
    [106] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_SUI_TM], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,
    
    -- 主界面 挂接组件 右中
    [107] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_SUI_RM], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,
    
    -- 主界面 挂接组件 下中
    [108] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_SUI_BM], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,
    
    -- 主界面技能模块 按钮
    [109] = function(config)
        local MainSkillMediator = global.Facade:retrieveMediator("MainSkillMediator")
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainSkillMediator or not MainRootMediator or not MainSkillMediator._layer or not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainSkillMediator._layer._layoutActive, tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,
    
    -- 导航栏 任务
    [110] = function(config)
        local  MainAssistMediator = global.Facade:retrieveMediator("MainAssistMediator")
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainAssistMediator then
            return nil
        end
        if not MainAssistMediator._layer then
            return nil
        end
        if not MainRootMediator._layer then
            return nil
        end
        if not global.isWinPlayMode then
            if MainAssistMediator._layer._assistGroup ~= 2 then
                return nil
            end

            if MainAssistMediator._layer._contentIndex ~= 1 then
                return nil
            end
        end
        
        local listview = MainAssistMediator._layer._listviewCells
        if not listview then
            return nil
        end
        listview:doLayout()
        local cell = MainAssist and MainAssist._missionCells and MainAssist._missionCells[tonumber(config.typeassist)]
        if not cell then--没找到任务的 找挂接按钮
            local widget = getChildByKey(MainAssistMediator._layer, tostring(config.typeassist))
            local parent = MainAssistMediator._layer
            return widget,parent
        end

        if not cell.quickUI or not cell.quickUI.Button_act then
            return
        end

        local anchorY   = listview:getAnchorPoint().y
        local limitYMAX = listview:getWorldPosition().y + listview:getContentSize().height * (1 - anchorY)
        local limitYMIN = listview:getWorldPosition().y - listview:getContentSize().height * anchorY
        local btnAnY    = cell.quickUI.Button_act:getAnchorPoint().y
        local cellYMAX  = cell.quickUI.Button_act:getWorldPosition().y + cell.quickUI.Button_act:getContentSize().height * (1 - btnAnY)
        local cellYMIN  = cell.quickUI.Button_act:getWorldPosition().y - cell.quickUI.Button_act:getContentSize().height * btnAnY
        if cellYMAX > limitYMAX or cellYMIN < limitYMIN then
            local idx = listview:getIndex(cell.quickUI.nativeUI)
            if idx then
                listview:jumpToItem(idx, cc.p(0, 0), cc.p(0, 0))
            end
            -- return nil    
        end
        
        local widget = cell.quickUI.Button_act
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,

    -- 主界面 挂接组件 最底左上
    [1001] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_BOTTOM_LT], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,
    
    -- 主界面 挂接组件 最底右上
    [1002] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_BOTTOM_RT], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,
    
    -- 主界面 挂接组件 最底左下
    [1003] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_BOTTOM_LB], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,

    -- 主界面 挂接组件 最底右下
    [1004] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_BOTTOM_RB], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,

    -- 主界面 挂接组件 最顶左上
    [1101] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_SUI_TOP_LT], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,
    
    -- 主界面 挂接组件 最顶右上
    [1102] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_SUI_TOP_RT], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,
    
    -- 主界面 挂接组件 最顶左下
    [1103] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_SUI_TOP_LB], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,

    -- 主界面 挂接组件 最顶右下
    [1104] = function(config)
        local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
        if not MainRootMediator._layer then
            return nil
        end

        local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_SUI_TOP_RB], tostring(config.typeassist))
        local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
        return widget, parent
    end,

    -- 996盒子导航
    [111] = function(config)
        local  Box996MainLayerMediator = global.Facade:retrieveMediator("Box996MainLayerMediator")
     
        if not Box996MainLayerMediator._layer then
            return nil
        end
        local widget,parent
        local index = tonumber(config.typeassist)
        parent = Box996MainLayerMediator._layer._ui.Panel_1
        if index == 5 then 
            widget = Box996MainLayerMediator._layer._ui.Button_close
        elseif index >= 1 and index <= 4 then 
            widget = Box996MainLayerMediator._layer._ui["Button_"..index]
        else 
            widget = getChildByKey(Box996MainLayerMediator._layer._ui.Node_child, tostring(config.typeassist))
        end
        return widget, parent
    end,
    -- 双端背包 等按钮  因为要支持pc只能固定id  100-102 个人信息 背包 技能信息
    [200] = function(config)
        if global.isWinPlayMode then
            local num = tonumber(config.typeassist)
            if num < 100 or num >102 then
                return nil
            end
            local MainPropertyMediator = global.Facade:retrieveMediator("MainPropertyMediator")
            if not MainPropertyMediator._layer then 
                return nil
            end
            local btnname = {"Button_role", "Button_bag", "Button_skill"}
            local widget = MainPropertyMediator._layer._quickUI[btnname[num - 99]]
            local parent = MainPropertyMediator._layer
            return widget, parent
        else
            local MainRootMediator = global.Facade:retrieveMediator("MainRootMediator")
            if not MainRootMediator._layer then
                return nil
            end

            local widget = getChildByKey(MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_SUI_RB], tostring(config.typeassist))
            local parent = MainRootMediator._layer._nodes[global.MMO.MAIN_NODE_GUIDE]
            return widget, parent 
        end
    end,
    --右下角切换按钮
    [201] = function (config)
        local num = tonumber(config.typeassist)
        if global.isWinPlayMode then
            return nil
        end
         local MainSkillMediator = global.Facade:retrieveMediator("MainSkillMediator")
        if not MainSkillMediator or not MainSkillMediator._layer then 
            return nil
        end
        if not MainSkillMediator._layer.ui or not MainSkillMediator._layer.ui.Button_change then
            return nil
        end
        return MainSkillMediator._layer.ui.Button_change, MainSkillMediator._layer
    end,
    --玩家主面板
    [202] = function(config)
        local num = tonumber(config.typeassist)
        
        local PlayerFrameMediator 
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        if HeroPropertyProxy:getIsMergePanelMode() then--合并面板模式
            PlayerFrameMediator = global.Facade:retrieveMediator("MergePlayerLayerMediator")
        else
            PlayerFrameMediator = global.Facade:retrieveMediator("PlayerFrameMediator")
        end
        if not PlayerFrameMediator or not PlayerFrameMediator._layer then
            return nil
        end
        local parent = PlayerFrameMediator._layer
        if num >= 1 and num <= 6 then
            local btnList = PlayerFrameMediator._layer._ui.Panel_btnList 
            local btn = {1, 2, 3, 4, 6, 11}
            local name = "Button_" .. btn[num]
            local ch =  btnList:getChildByName(name)
            if ch then
                return ch, parent
            end
        elseif num >= 101 and num <= 104 then   -- 内功页签按钮
            local btnList = PlayerFrameMediator._layer._ui.Panel_btnList_ng
            if btnList and btnList:isVisible() then
                local name = "Button_" .. (num % 100)
                local btn = btnList:getChildByName(name)
                if btn then
                    return btn, parent
                end
            end
        elseif num == 1001 or num == 1002 then  -- 基础/内功
            local layout = PlayerFrameMediator._layer._ui.topLayout
            if layout and layout:isVisible() then
                local btnNameL = {
                    [1001] = "base_btn",
                    [1002] = "ng_btn"
                }
                local btn = layout:getChildByName(btnNameL[num])
                if btn then
                    return btn, parent
                end
            end
        else 
            local ch = getChildByKey(PlayerFrameMediator._layer, tostring(config.typeassist))
            return ch, parent
        end
        return nil
    end,
    --英雄主面板
    [203] = function(config)
        local num = tonumber(config.typeassist)
        
        local PlayerFrameMediator 
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        if HeroPropertyProxy:getIsMergePanelMode() then--合并面板模式
            PlayerFrameMediator = global.Facade:retrieveMediator("MergePlayerLayerMediator")
        else
           PlayerFrameMediator = global.Facade:retrieveMediator("HeroFrameMediator")
        end
        if not PlayerFrameMediator or not PlayerFrameMediator._layer then
            return nil
        end
        local parent = PlayerFrameMediator._layer
        if num >= 1 and num <= 6 then
            local btnList = PlayerFrameMediator._layer._ui.Panel_btnList 
            local btn = {1, 2, 3, 4, 6, 11}
            local name = "Button_" .. btn[num]
            local ch =  btnList:getChildByName(name)
            if ch then
                return ch, parent
            end
        elseif num >= 101 and num <= 104 then   -- 内功页签按钮
            local btnList = PlayerFrameMediator._layer._ui.Panel_btnList_ng
            if btnList and btnList:isVisible() then
                local name = "Button_" .. (num % 100)
                local btn = btnList:getChildByName(name)
                if btn then
                    return btn, parent
                end
            end
        elseif num == 1001 or num == 1002 then  -- 基础/内功
            local layout = PlayerFrameMediator._layer._ui.topLayout
            if layout and layout:isVisible() then
                local btnNameL = {
                    [1001] = "base_btn",
                    [1002] = "ng_btn"
                }
                local btn = layout:getChildByName(btnNameL[num])
                if btn then
                    return btn, parent
                end
            end
        else 
            local ch = getChildByKey(PlayerFrameMediator._layer, tostring(config.typeassist))
            return ch, parent
        end
        return nil
    end,
    -- 人物经脉面板-按钮
    [204] = function(config)
        local mediator = global.Facade:retrieveMediator("PlayerInternalMeridianLayerMediator")
        if not mediator._layer or not mediator._layer._root then
            return nil
        end
        local idList = {2, 3, 4, 5, 1}
        local idx = tonumber(config.typeassist)
        local parent = mediator._layer
        if mediator._layer._ui.Panel_content and idx then
            local name = idList[idx] and string.format("Button_%s", idList[idx])
            local widget = name and mediator._layer._ui.Panel_content:getChildByName(name)
            if widget then
                return widget, parent
            end
        end
        -- 找挂接的
        local widget = getChildByKey(mediator._layer, tostring(config.typeassist))
        return widget, parent
    end,
    -- 英雄经脉面板-按钮
    [205] = function(config)
        local mediator = global.Facade:retrieveMediator("HeroInternalMeridianLayerMediator")
        if not mediator._layer or not mediator._layer._root then
            return nil
        end
        local idList = {2, 3, 4, 5, 1}
        local idx = tonumber(config.typeassist)
        local parent = mediator._layer
        if mediator._layer._ui.Panel_content and idx then
            local name = idList[idx] and string.format("Button_%s", idList[idx])
            local widget = name and mediator._layer._ui.Panel_content:getChildByName(name)
            if widget then
                return widget, parent
            end
        end
        -- 找挂接的
        local widget = getChildByKey(mediator._layer, tostring(config.typeassist))
        return widget, parent
    end,
    --人物状态面板
    [211] = function(config)
        local PlayerBaseAttLayerMediator = global.Facade:retrieveMediator("PlayerBaseAttLayerMediator")
        if not PlayerBaseAttLayerMediator._layer or not PlayerBaseAttLayerMediator._layer._root  then
            return nil
        end
        local widget = getChildByKey(PlayerBaseAttLayerMediator._layer, tostring(config.typeassist))
        local parent = PlayerBaseAttLayerMediator._layer
        return widget, parent
    end,
    --人物属性面板
    [212] = function(config)
        local PlayerExtraAttLayerMediator = global.Facade:retrieveMediator("PlayerExtraAttLayerMediator")
        if not PlayerExtraAttLayerMediator._layer or not PlayerExtraAttLayerMediator._layer._root  then
            return nil
        end
        local widget = getChildByKey(PlayerExtraAttLayerMediator._layer, tostring(config.typeassist))
        local parent = PlayerExtraAttLayerMediator._layer
        return widget, parent
    end,
    --人物技能面板
    [213] = function(config)
        local PlayerSkillLayerMediator = global.Facade:retrieveMediator("PlayerSkillLayerMediator")
        if not PlayerSkillLayerMediator._layer or not PlayerSkillLayerMediator._layer._root  then
            return nil
        end
        local widget = getChildByKey(PlayerSkillLayerMediator._layer, tostring(config.typeassist))
        local parent = PlayerSkillLayerMediator._layer
        return widget, parent
    end,
    --人物称号面板
    [214] = function(config)
        local PlayerTitleLayerMediator = global.Facade:retrieveMediator("PlayerTitleLayerMediator")
        if not PlayerTitleLayerMediator._layer or not PlayerTitleLayerMediator._layer._root  then
            return nil
        end
        local widget = getChildByKey(PlayerTitleLayerMediator._layer, tostring(config.typeassist))
        local parent = PlayerTitleLayerMediator._layer
        return widget, parent
    end,
    --人物时装面板
    [215] = function(config)
        local PlayerSuperEquipMediator = global.Facade:retrieveMediator("PlayerSuperEquipMediator")
        if not PlayerSuperEquipMediator._layer or not PlayerSuperEquipMediator._layer._root  then
            return nil
        end
        local widget = getChildByKey(PlayerSuperEquipMediator._layer, tostring(config.typeassist))
        local parent = PlayerSuperEquipMediator._layer
        return widget, parent
    end,
    --英雄状态面板
    [231] = function(config)
        local HeroBaseAttLayerMediator = global.Facade:retrieveMediator("HeroBaseAttLayerMediator")
        if not HeroBaseAttLayerMediator._layer or not HeroBaseAttLayerMediator._layer._root  then
            return nil
        end
        local widget = getChildByKey(HeroBaseAttLayerMediator._layer, tostring(config.typeassist))
        local parent = HeroBaseAttLayerMediator._layer
        return widget, parent
    end,
    --英雄属性面板
    [232] = function(config)
        local HeroExtraAttLayerMediator = global.Facade:retrieveMediator("HeroExtraAttLayerMediator")
        if not HeroExtraAttLayerMediator._layer or not HeroExtraAttLayerMediator._layer._root  then
            return nil
        end
        local widget = getChildByKey(HeroExtraAttLayerMediator._layer, tostring(config.typeassist))
        local parent = HeroExtraAttLayerMediator._layer
        return widget, parent
    end,
    --英雄技能面板
    [233] = function(config)
        local HeroSkillLayerMediator = global.Facade:retrieveMediator("HeroSkillLayerMediator")
        if not HeroSkillLayerMediator._layer or not HeroSkillLayerMediator._layer._root  then
            return nil
        end
        local widget = getChildByKey(HeroSkillLayerMediator._layer, tostring(config.typeassist))
        local parent = HeroSkillLayerMediator._layer
        return widget, parent
    end,
    --英雄称号面板
    [234] = function(config)
        local HeroTitleLayerMediator = global.Facade:retrieveMediator("HeroTitleLayerMediator")
        if not HeroTitleLayerMediator._layer or not HeroTitleLayerMediator._layer._root  then
            return nil
        end
        local widget = getChildByKey(HeroTitleLayerMediator._layer, tostring(config.typeassist))
        local parent = HeroTitleLayerMediator._layer
        return widget, parent
    end,
    --英雄时装面板
    [235] = function(config)
        local HeroSuperEquipMediator = global.Facade:retrieveMediator("HeroSuperEquipMediator")
        if not HeroSuperEquipMediator._layer or not HeroSuperEquipMediator._layer._root  then
            return nil
        end
        local widget = getChildByKey(HeroSuperEquipMediator._layer, tostring(config.typeassist))
        local parent = HeroSuperEquipMediator._layer
        return widget, parent
    end,
    -- 内挂- 保护 
    [303] = function(config)
        local SettingProtectMediator = global.Facade:retrieveMediator("SettingProtectMediator")
        if not SettingProtectMediator._layer or not SettingProtectMediator._layer:GetSUIParent() then
            return nil
        end
        local widget = getChildByKey(SettingProtectMediator._layer, tostring(config.typeassist))
        local parent = SettingProtectMediator._layer
        return widget, parent
    end
}

return config
