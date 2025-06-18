local BaseLayer = requireLayerUI("BaseLayer")
local PreviewNodeLayer = class("PreviewNodeLayer", BaseLayer)

function PreviewNodeLayer:ctor()
    PreviewNodeLayer.super.ctor(self)
    self.selWidget = nil
end

function PreviewNodeLayer:Create()
    local ui = PreviewNodeLayer.new()
    ui:setName("PreviewNodeLayer")
    if ui and ui:Init() then
        return ui
    end
end

function PreviewNodeLayer:Init()
    self._root = CreateExport("preview_node/preview_node")
    if not self._root then
        return false
    end
    self:addChild(self._root)
    self._quickUI = ui_delegate(self._root)
    self._root:setName("preview_node")

    local function closeCallback()
        global.Facade:sendNotification( global.NoticeTable.Layer_PreviewNode_Close )
    end
    self._quickUI.Button_close:addClickEventListener(closeCallback)

    if global.sceneGraphCtl then
        self._node_root = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_ROOT)
        self._node_ui = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_UI)
        self._node_ui_normal = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_UI_NORMAL)
        self._node_ui_topmost = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_UI_TOPMOST)
    end

    self:InitUI()

    return true
end


function PreviewNodeLayer:InitUI()
    self._quickUI.Button_tree:addClickEventListener(handler(self, self.onNodeTreeChange))
    self._quickUI.Button_tree:setTag(0)

    self:InitTextField()

    self._quickUI.Button_arr:addClickEventListener(handler(self, self.onTreeArrow))
    self:addTreeNodes()

    self._quickUI.ListView_1:setSwallowTouches(false)
end

function PreviewNodeLayer:InitTextField()
    self._quickUI.TextField_name = CreateEditBoxByTextField( self._quickUI.TextField_name )
    self._quickUI.TextField_name:setInputMode(0)
    self._quickUI.TextField_AnrX = CreateEditBoxByTextField( self._quickUI.TextField_AnrX )
    self._quickUI.TextField_AnrX:setInputMode(2)
    self._quickUI.TextField_AnrX:addEventListener(function(sender, eventType)
        if eventType == 2 then
            local num = tonumber(sender:getString())
            if self.selWidget and num then
                local node = self.selWidget.widget
                if node then
                    local ay = node:getAnchorPoint().y
                    node:setAnchorPoint(num, ay)
                end
            end
        end
    end)
    self._quickUI.TextField_AnrY = CreateEditBoxByTextField( self._quickUI.TextField_AnrY )
    self._quickUI.TextField_AnrY:setInputMode(2)
    self._quickUI.TextField_AnrY:addEventListener(function(sender, eventType)
        if eventType == 2 then
            local num = tonumber(sender:getString())
            if self.selWidget and num then
                local node = self.selWidget.widget
                if node then
                    local ax = node:getAnchorPoint().x
                    node:setAnchorPoint(ax, num)
                end
            end
        end
    end)
    self._quickUI.TextField_X = CreateEditBoxByTextField( self._quickUI.TextField_X )
    self._quickUI.TextField_X:setInputMode(2)
    self._quickUI.TextField_X:addEventListener(function(sender, eventType)
        if eventType == 2 then
            local num = tonumber(sender:getString())
            if self.selWidget and num then
                local node = self.selWidget.widget
                if node then
                    node:setPositionX(num)
                    local wordPos = node:convertToWorldSpace(cc.p(0,0))
                    self._quickUI.TextField_WX:setString(wordPos.x)
                end
            end
        end
    end)
    self._quickUI.TextField_Y = CreateEditBoxByTextField( self._quickUI.TextField_Y )
    self._quickUI.TextField_Y:setInputMode(2)
    self._quickUI.TextField_Y:addEventListener(function(sender, eventType)
        if eventType == 2 then
            local num = tonumber(sender:getString())
            if self.selWidget and num then
                local node = self.selWidget.widget
                if node then
                    node:setPositionY(num)
                    local wordPos = node:convertToWorldSpace(cc.p(0,0))
                    self._quickUI.TextField_WY:setString(wordPos.y)
                end
            end
        end
    end)
    self._quickUI.TextField_W = CreateEditBoxByTextField( self._quickUI.TextField_W )
    self._quickUI.TextField_W:setInputMode(2)
    self._quickUI.TextField_W:addEventListener(function(sender, eventType)
        if eventType == 2 then
            local num = tonumber(sender:getString())
            if self.selWidget and num then
                local node = self.selWidget.widget
                if node then
                    local height = node:getContentSize().height
                    node:setContentSize(num, height)
                end
            end
        end
    end)
    self._quickUI.TextField_H = CreateEditBoxByTextField( self._quickUI.TextField_H )
    self._quickUI.TextField_H:setInputMode(2)
    self._quickUI.TextField_H:addEventListener(function(sender, eventType)
        if eventType == 2 then
            local num = tonumber(sender:getString())
            if self.selWidget and num then
                local node = self.selWidget.widget
                if node then
                    local width = node:getContentSize().width
                    node:setContentSize(width, num)
                end
            end
        end
    end)

    self._quickUI.TextField_WX = CreateEditBoxByTextField( self._quickUI.TextField_WX )
    self._quickUI.TextField_WX:setInputMode(2)
    self._quickUI.TextField_WX:addEventListener(function(sender, eventType)
        if eventType == 2 then
            local num = tonumber(sender:getString())
            if self.selWidget and num then
                local node = self.selWidget.widget
                if node then
                    local wordPos = node:convertToWorldSpace(cc.p(0,0))
                    local chaX = num - wordPos.x
                    local lx = node:getPositionX() + chaX
                    self._quickUI.TextField_X:setString(lx)
                    node:setPositionX(lx)
                end
            end
        end
    end)

    self._quickUI.TextField_WY = CreateEditBoxByTextField( self._quickUI.TextField_WY )
    self._quickUI.TextField_WY:setInputMode(2)
    self._quickUI.TextField_WY:addEventListener(function(sender, eventType)
        if eventType == 2 then
            local num = tonumber(sender:getString())
            if self.selWidget and num then
                local node = self.selWidget.widget
                if node then
                    local wordPos = node:convertToWorldSpace(cc.p(0,0))
                    local chaY = num - wordPos.y
                    local ly = node:getPositionY() + chaY
                    self._quickUI.TextField_Y:setString(ly)
                    node:setPositionY(ly)
                end
            end
        end
    end)

    self._quickUI.CheckBox_Visible:addEventListener(function(sender)
        local isSelected = sender:isSelected()
        if self.selWidget then
            local node = self.selWidget.widget
            if node then
                local nodeName = node:getName()
                node:setVisible(isSelected)
            end
        end
    end)

    self._quickUI.Button_pos:addClickEventListener(function(sender)
        if self.selWidget then
            local node = self.selWidget.widget
            if node then
                local Panel_pos = self._quickUI.Panel_pos:clone()
                local nodeSize = node:getContentSize()
                if nodeSize.width == 0 or nodeSize.height == 0 then
                    Panel_pos:setAnchorPoint(0.5, 0.5)
                end
                local minW = nodeSize.width == 0 and 50 or nodeSize.width
                local minH = nodeSize.height == 0 and 50 or nodeSize.height
                local wordPos = node:convertToWorldSpace(cc.p(0,0))
                Panel_pos:setContentSize(minW, minH)
                Panel_pos:setVisible(true)
                Panel_pos:setPosition(wordPos)
                self._root:addChild(Panel_pos)
                Panel_pos:runAction(cc.Sequence:create(
                    cc.FadeOut:create(1),
                    cc.CallFunc:create(function()
                        if Panel_pos then
                            Panel_pos:removeFromParent()
                        end
                    end)
                ))
            end
        end
    end)
end

function PreviewNodeLayer:onTreeArrow(ref, eventType)
    if ref:getRotation() == 0 then
        self:setTreeStatus(ref, true)
        ref:setRotation(90)
    else
        self:setTreeStatus(ref, false)
        ref:setRotation(0)
    end
end

function PreviewNodeLayer:onNodeTreeChange(ref, eventType)
    local tag = ref:getTag()
    local x = 0
    if tag > 0 then
        x = x + 220
        ref:setTag(0)
        self._quickUI.Button_tree:setRotation(180)
        self._quickUI.Panel_tree:setPositionX(220)
    else
        ref:setTag(1)
        self._quickUI.Button_tree:setRotation(0)
        self._quickUI.Panel_tree:setPositionX(1136)
    end
end


function PreviewNodeLayer:setTreeStatus(ref, status)
    if status then
        ref:setTag(0)
    else
        ref:setTag(1)
    end
    local ui = ref:getParent()
    local widget = ui.widget

    local function setOpen()
        ref.open = true
        ref:setRotation(0)
        ui.customs = {}
        local childDepth = ui.depth + 1
        local index = ui:getLocalZOrder() + 1
        local childs = widget:getChildren()
        local innerSize = self._quickUI.ListView_1:getInnerContainerSize()
        local pos = self._quickUI.ListView_1:getInnerContainerPosition()
        local listSize = self._quickUI.ListView_1:getContentSize()
        for k, node in pairs(childs) do
            local child = self:addTreeItem(node, childDepth)
            self._quickUI.ListView_1:insertCustomItem(child, index)
            table.insert(ui.customs, child)
            child.customParent = ui
            index = index + 1
        end
        
        local persent = 100
        if innerSize.height - listSize.height > 0 then
            persent = 100 - math.abs(pos.y/(innerSize.height - listSize.height) * 100)
        end
        self:updataScrollView()
        self._quickUI.ListView_1:jumpToPercentVertical(persent)
    end

    local function setClose()
        ref.open = false
        ref:setRotation(180)
        local innerSize = self._quickUI.ListView_1:getInnerContainerSize()
        local pos = self._quickUI.ListView_1:getInnerContainerPosition()
        local listSize = self._quickUI.ListView_1:getContentSize()
        self:removeListviewRefCustoms(ui)
        local persent = 100
        if innerSize.height - listSize.height > 0 then
            persent = 100 - math.abs(pos.y/(innerSize.height - listSize.height) * 100)
        end
        self:updataScrollView()
        self._quickUI.ListView_1:jumpToPercentVertical(persent)
    end

    if status then
        setOpen()
    else
        setClose()
    end
end

function PreviewNodeLayer:removeListviewRefCustoms(ref)
    if ref.customs and next(ref.customs) then
        table.sort(ref.customs, function(a, b)
            return a:getLocalZOrder() > b:getLocalZOrder()
        end)
        for k, v in pairs(ref.customs) do
            if v.customs and next(v.customs) then
                self:removeListviewRefCustoms(v)
            end
            local indedx = v:getLocalZOrder()
            self._quickUI.ListView_1:removeItem(indedx)
        end
    end
    ref.customs = {}
end

function PreviewNodeLayer:addTreeItem(node, depth)
    local open   = false
    local ID     = node:getName()
    local children = node:getChildren()

    local ui = self._quickUI.tree_cell:clone()
    self:addTextTreeName(ui, depth)
    IterAllChild(ui, ui)

    ID = ID == "" and "NULL" or ID
    ui.TextTreeName:setString(ID)
    ui.widget = node
    ui.depth = depth

    if open then
        ui.Button_arr:setRotation(90)
    else
        ui.Button_arr:setRotation(0)
    end

    if children and next(children) then
        ui.Button_arr:setVisible(true)
        ui.customs = {}
    else
        ui.Button_arr:setVisible(false)
    end

    ui.Button_arr:setPositionX(9 + (depth-1) * 10)

    if self._selWidget and self._selWidget == node then
        ui.cell_bg_2:setVisible(true)
    end

    ui:setVisible(true)
    ui:setSwallowTouches(false)
    -- 选中
    ui:addClickEventListener(function()
        if tolua.isnull(node) then
            print("ui destor")
            return
        end
        if self.selWidget and self.selWidget.cell_bg_2 then
            self.selWidget.cell_bg_2:setVisible(false)
        end
        self.selWidget = ui
        ui.cell_bg_2:setVisible(true)

        self._quickUI.CheckBox_Visible:setSelected(node:isVisible())
        self._quickUI.TextField_name:setString(ID)
        local nodeType = node:getDescription() or ""
        if string.find(nodeType, "Node") then
            nodeType = "Node"
        elseif string.find(nodeType, "Layout") then
            nodeType = "Layout"
        end
        self._quickUI.Text_type:setString(nodeType)
        local anchorPoint = node:getAnchorPoint()
        self._quickUI.TextField_AnrX:setString(anchorPoint.x)
        self._quickUI.TextField_AnrY:setString(anchorPoint.y)
        self._quickUI.TextField_X:setString(node:getPositionX())
        self._quickUI.TextField_Y:setString(node:getPositionY())
        local contentSize = node:getContentSize()
        self._quickUI.TextField_W:setString(contentSize.width)
        self._quickUI.TextField_H:setString(contentSize.height)

        local wordPos = node:convertToWorldSpace(cc.p(0,0))
        self._quickUI.TextField_WX:setString(wordPos.x)
        self._quickUI.TextField_WY:setString(wordPos.y)

        if node == self._node_ui or node == self._node_ui_topmost then
            self._quickUI.CheckBox_Visible:setTouchEnabled(false)
        else
            self._quickUI.CheckBox_Visible:setTouchEnabled(true)
        end
    end)

    ui.childrenCount = node:getChildrenCount()
    local function scheduleCB()
        if tolua.isnull(ui) then
            print("ui destor")
            return
        end
        if not tolua.isnull(node) then
            local name = node:getName()
            if name == "list_items" then
                print(1)
            end
        end
        if tolua.isnull(node) then
            if ui.customParent and ui.customParent.customs then
                ui.customParent.childrenCount = ui.customParent.childrenCount - 1
                for k, v in pairs(ui.customParent.customs) do
                    if v == ui then
                        table.remove(ui.customParent.customs, k)
                        if #ui.customParent.customs == 0 then
                            ui.customParent.Button_arr.open = false
                            ui.customParent.Button_arr:setVisible(false)
                            ui.customParent.Button_arr:setRotation(0)
                            ui.customParent.Button_arr:setTag(1)
                        end
                        break
                    end
                end
            end

            local innerSize = self._quickUI.ListView_1:getInnerContainerSize()
            local pos = self._quickUI.ListView_1:getInnerContainerPosition()
            local listSize = self._quickUI.ListView_1:getContentSize()
            self:removeListviewRefCustoms(ui)
            local indedx = ui:getLocalZOrder()
            self._quickUI.ListView_1:removeItem(indedx)
            local persent = 100
            if innerSize.height - listSize.height > 0 then
                persent = 100 - math.abs(pos.y/(innerSize.height - listSize.height) * 100)
            end
            self:updataScrollView()
            self._quickUI.ListView_1:jumpToPercentVertical(persent)
        elseif ui.childrenCount ~= node:getChildrenCount() then
            ui.childrenCount = node:getChildrenCount()
            if ui.childrenCount > 0 then
                ui.Button_arr:setVisible(true)
            else
                ui.Button_arr:setVisible(false)
            end
            if not ui.Button_arr.open then
                return
            end
            
            local childDepth = ui.depth + 1
            local index = ui:getLocalZOrder() + 1
            local childs = node:getChildren()
            local innerSize = self._quickUI.ListView_1:getInnerContainerSize()
            local pos = self._quickUI.ListView_1:getInnerContainerPosition()
            local listSize = self._quickUI.ListView_1:getContentSize()
            local lsCustoms = clone(ui.customs)
            for k, child_node in pairs(childs) do
                local exist = false
                for _, ui_node in pairs(lsCustoms) do
                    if ui_node.widget == child_node then
                        exist = true
                        break
                    end
                end
                if exist == false then
                    local child = self:addTreeItem(child_node, childDepth)
                    self._quickUI.ListView_1:insertCustomItem(child, index)
                    table.insert(ui.customs, child)
                    child.customParent = ui
                end

                index = index + 1
            end
            
            local persent = 100
            if innerSize.height - listSize.height > 0 then
                persent = 100 - math.abs(pos.y/(innerSize.height - listSize.height) * 100)
            end
            self:updataScrollView()
            self._quickUI.ListView_1:jumpToPercentVertical(persent)
        end
    end
    schedule(ui, scheduleCB, 0.1)
    return ui
end

function PreviewNodeLayer:addTreeNodes()
    self._quickUI.ListView_1:removeAllChildren()
    
    if global.isGMMode then
        if global.sceneGraphCtl == nil then return end
        self.mainRoot = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_UI)
    elseif global.isDebugMode then
        self.mainRoot = global.Director:getRunningScene()
    end

    local childs = self.mainRoot:getChildren()
    for k, node in pairs(childs) do
        local ui = self:addTreeItem(node, 1)
        self._quickUI.ListView_1:pushBackCustomItem(ui)
    end
end

function PreviewNodeLayer:addTextTreeName(node, depth)
    local colorList = {"#FF0000","#FFFFFF","#00FF00","#FF00FF","#FFFF00","#90EE90","#1E90FF","#FFA500"}
    local x = 18 + (depth-1) * 10
    local color = SL:GetColorCfg(depth)
    color = colorList[depth%#colorList + 1]

    local TextTreeName = GUI:Text_Create(node, "TextTreeName", x, 12, 14, color, "")
    GUI:setAnchorPoint(TextTreeName, 0, 0.5)
end

function PreviewNodeLayer:updataScrollView()
    local width = 220
    local children = self._quickUI.ListView_1:getChildren()
    for k, v in pairs(children) do
        local TextTreeName = v:getChildByName("TextTreeName")
        if TextTreeName then
            local posX = GUI:getPositionX(TextTreeName)
            local size = GUI:getContentSize(TextTreeName)
            if size and size.width then
                local textWidth = size.width + posX
                if textWidth > width then
                    width = textWidth
                end
            end
        end
    end

    local innerSize = self._quickUI.ScrollView_1:getInnerContainerSize()
    local pos = self._quickUI.ScrollView_1:getInnerContainerPosition()
    local listSize = self._quickUI.ScrollView_1:getContentSize()
    local persent = 100
    if innerSize.width - listSize.width > 0 then
        persent = math.abs(pos.x/(innerSize.width - listSize.width) * 100)
    end

    self._quickUI.ListView_1:setContentSize(width, 400)
    self._quickUI.ScrollView_1:setInnerContainerSize(cc.size(width, 400))
    self._quickUI.ScrollView_1:jumpToPercentHorizontal(persent)
end

return PreviewNodeLayer

