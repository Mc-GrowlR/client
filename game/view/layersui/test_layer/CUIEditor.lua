local BaseLayer = requireLayerUI("BaseLayer")
local CUIEditor = class("CUIEditor", BaseLayer)

local sfind   = string.find
local sformat = string.format

local SUIHelper = require("sui/SUIHelper")

function CUIEditor:ctor()
    CUIEditor.super.ctor(self)
    self._closeEvents = {}

    self._data = nil
    self._editOUIData = nil

    self._isPressedCtrl = false
    self._editWidgetList = {}

    self._frameKey = {
        [global.CUIKeyTable.PLAYER_FRAME]   = true,
        [global.CUIKeyTable.BAG]            = true,
        [global.CUIKeyTable.BAG_MERGE]      = true,
        [global.CUIKeyTable.NPC_STORAGE]    = true,
        [global.CUIKeyTable.LOOKPLAYER_FRAME] = true,
        [global.CUIKeyTable.HERO_MERGE_FRAME] = true,
        [global.CUIKeyTable.HERO_FRAME]     = true,
        [global.CUIKeyTable.TRADE_PLAYER_FRAME] = true,
        [global.CUIKeyTable.GUILD_FRAME]    = true,
        [global.CUIKeyTable.SOCIAL_FRAME]   = true,
        [global.CUIKeyTable.STORE_FRAME]    = true,
        [global.CUIKeyTable.SETTING_FRAME]  = true,
    }
end

function CUIEditor.create(...)
    local layer = CUIEditor.new()
    if layer:init(...) then
        return layer
    end
    return nil
end

function CUIEditor:init(data)
    self._root, self.ui = CreateExport("cui_editor/main_editor.lua")
    if not self._root then
        return false
    end
    self:addChild(self._root)
    self._data = data

    self:initKeycode()
    self:initButton()
    self:initAttr()
    
    self:initEdit()
    
    self:initAdapet()

    return true
end

function CUIEditor:initAdapet()
    local visibleSize = global.Director:getVisibleSize()
    self.ui.Panel_global:setPosition(cc.p(visibleSize.width, visibleSize.height))
    self.ui.Panel_attr:setPosition(cc.p(visibleSize.width, visibleSize.height-40))
end

function CUIEditor:onClose()
    for _, callback in ipairs(self._closeEvents) do
        callback()
    end

    local rootKey = self._data.rootKey
    local root    = self._data.root
    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
    local originUIData = SUIComponentProxy:findOriginUIData(rootKey)
    if not originUIData then
        return nil
    end

    for _, ouiData in pairs(originUIData) do
        if ouiData.widget and not tolua.isnull(ouiData.widget) then
            ouiData.widget:removeChildByName("____editCUI")
        end
    end
end

function CUIEditor:initKeycode()
    -- 坐标微调
    local function eventKeyCode(addPos)
        if #self._editWidgetList == 0 then
            return nil
        end
    
        for _, ouiData in ipairs(self._editWidgetList) do
            local src_pos   = cc.p(ouiData.widget:getPositionX(), ouiData.widget:getPositionY())
            local dst_pos   = cc.pAdd(src_pos, addPos)
            ouiData.widget:setPosition(dst_pos)
        end

        self:updateAttrBUSY()
    end
    local isMoving = {}
    local nodes    = {}
    local keyCodes = {cc.KeyCode.KEY_LEFT_ARROW, cc.KeyCode.KEY_RIGHT_ARROW, cc.KeyCode.KEY_UP_ARROW, cc.KeyCode.KEY_DOWN_ARROW}
    for k, v in pairs(keyCodes) do
        nodes[v] = cc.Node:create()
        self:addChild(nodes[v])
    end
    local pressed_callback = function(keycode, evt)
        if keycode == cc.KeyCode.KEY_LEFT_ARROW or keycode == cc.KeyCode.KEY_RIGHT_ARROW or keycode == cc.KeyCode.KEY_UP_ARROW or keycode == cc.KeyCode.KEY_DOWN_ARROW then
            local addPos = nil
            if keycode == cc.KeyCode.KEY_LEFT_ARROW then
                addPos = cc.p(-1, 0)
            elseif keycode == cc.KeyCode.KEY_RIGHT_ARROW then
                addPos = cc.p(1, 0)
            elseif keycode == cc.KeyCode.KEY_UP_ARROW then
                addPos = cc.p(0, 1)
            elseif keycode == cc.KeyCode.KEY_DOWN_ARROW then
                addPos = cc.p(0, -1)
            end
            if addPos then
                eventKeyCode(addPos)
                local delay = 0.5
                for k, v in pairs(isMoving) do
                    if v then
                        delay = 0
                        break
                    end
                end
                performWithDelay(nodes[keycode], function()
                    local function callback()
                        eventKeyCode(addPos)
                    end
                    schedule(nodes[keycode], callback, 0.01)
                    isMoving[keycode] = true
                end, delay)
            end
        
        elseif keycode == cc.KeyCode.KEY_LEFT_CTRL then
            self._isPressedCtrl = true
        end
    end
    local released_callback = function(keycode, evt)
        if nodes[keycode] then
            nodes[keycode]:stopAllActions()
            isMoving[keycode] = false

        elseif keycode == cc.KeyCode.KEY_LEFT_CTRL then
            self._isPressedCtrl = false
        end

    end
    local listener = cc.EventListenerKeyboard:create()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    listener:registerScriptHandler(pressed_callback, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(released_callback, cc.Handler.EVENT_KEYBOARD_RELEASED)
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
    table.insert(self._closeEvents, function()
        eventDispatcher:removeEventListener(listener)
    end)

    -- 右键清理选中
    local function mouseRightButtonUp()
        if false == self._isPressedCtrl then
            self:unselect_swidget_busy()
            self.ui.Panel_forbidden:setVisible(false)
        end
    end
    global.mouseEventController:registerMouseButtonEvent(
        self._root,
        {
            up_r = mouseRightButtonUp,
        }
    )
end

function CUIEditor:initButton()
    -- 退出
    self.ui.Button_close:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.CUIEditorClose)
    end)

    -- 保存
    self.ui.Button_submit:addClickEventListener(function()
        local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
        SUIComponentProxy:writeCsutomUIData()
    end)

    -- 切换
    local visibleSize = global.Director:getVisibleSize()
    local index = 1
    self.ui.Button_change:addClickEventListener(function()
        index = 1 - index
        local positionX = (index == 0 and self.ui.Panel_global:getContentSize().width or visibleSize.width)
        self.ui.Panel_global:setPositionX(positionX)
        positionX = (index == 0 and self.ui.Panel_attr:getContentSize().width or visibleSize.width)
        self.ui.Panel_attr:setPositionX(positionX)
    end)

    -- 隐藏
    self.ui.Button_hide:addClickEventListener(function()
        self.ui.Panel_attr:setVisible(not self.ui.Panel_attr:isVisible())
    end)

    -- 恢复
    self.ui.Button_reset:addClickEventListener(function()
        local function callback(bType, custom)
            if bType == 1 then
                local rootKey = self._data.rootKey
                local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
                SUIComponentProxy:resetCustomUIData(rootKey)
                SUIComponentProxy:writeCsutomUIData()
                global.Facade:sendNotification(global.NoticeTable.RestartGame)
            end
        end
        local data = {}
        data.str = GET_STRING(30103400)
        data.btnDesc = {GET_STRING(1002), GET_STRING(1000)}
        data.callback = callback
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
    end)

    -- 节点树
    local index = 0
    self.ui.Button_tree:addClickEventListener(function()
        index = 1 - index
        
        self.ui.Panel_tree:setPositionX(index == 1 and self.ui.Panel_tree:getContentSize().width or 0)
    end)

    -- 菜单
    self.ui.Button_menu:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.CUIEditorClose)

        global.Facade:sendNotification( global.NoticeTable.Layer_RichTextTest_Open )
    end)
    
end

function CUIEditor:initAttr()
    self.ui.TextField_posX:setCursorEnabled(true)
    self.ui.TextField_posY:setCursorEnabled(true)
    self.ui.TextField_w:setCursorEnabled(true)
    self.ui.TextField_h:setCursorEnabled(true)

    -- 可见性
    self.ui.CheckBox_visible:addEventListener(function()
        if not self._editOUIData then
            return
        end
        self._editOUIData.widget:setVisible(self.ui.CheckBox_visible:isSelected())

        -- record
        self:updateAttr()
    end)

    -- 宽
    self.ui.TextField_w:addEventListener(function(sender, eventType)
        if eventType == 1 then
            if not self._editOUIData then
                return
            end

            local input = sender:getString()
            input       = tonumber(input) or 0
            if input <= 0 then
                return 
            end

            local contentSize = self._editOUIData.widget:getContentSize()
            if self._editOUIData.widget.ignoreContentAdaptWithSize then
                self._editOUIData.widget:ignoreContentAdaptWithSize(false)
            end
            self._editOUIData.widget:setContentSize(cc.size(input, contentSize.height))

            -- record
            self:updateAttr()
        end
    end)

    -- 高
    self.ui.TextField_h:addEventListener(function(sender, eventType)
        if eventType == 1 then
            if not self._editOUIData then
                return
            end

            local input = sender:getString()
            input       = tonumber(input) or 0
            if input <= 0 then
                return 
            end

            local contentSize = self._editOUIData.widget:getContentSize()
            if self._editOUIData.widget.ignoreContentAdaptWithSize then
                self._editOUIData.widget:ignoreContentAdaptWithSize(false)
            end
            self._editOUIData.widget:setContentSize(cc.size(contentSize.width, input))

            -- record
            self:updateAttr()
        end
    end)
end

function CUIEditor:initEdit()
    local rootKey = self._data.rootKey
    local root    = self._data.root
    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
    local originUIData = SUIComponentProxy:findOriginUIData(rootKey)
    if not originUIData then
        return nil
    end

    root:setLocalZOrder(99999)

    local function addEditWidget(ouiData)
        local contentSize  = ouiData.widget:getContentSize()
        contentSize.width  = math.max(30, contentSize.width)
        contentSize.height = math.max(30, contentSize.height)
        local layout = ccui.Layout:create()
        ouiData.widget:addChild(layout)
        layout:setAnchorPoint(cc.p(0.5, 0.5))
        layout:setPosition(cc.p(ouiData.widget:getContentSize().width/2, ouiData.widget:getContentSize().height/2))
        layout:setName("____editCUI")
        layout:setContentSize(contentSize)
        layout:setTouchEnabled(true)
        layout:setLocalZOrder(9999)
        layout:setBackGroundColor(cc.c3b(0xff, 0xff, 0x00))
        layout:setBackGroundColorType(1)
        layout:setBackGroundColorOpacity(50)

        local offset        = cc.p(0,0)
        local lastPos       = cc.p(0,0)
        local clickCount    = 0
        local eventTag      = false
        layout:addTouchEventListener(function(_, eventType)
            if eventType == 0 then
                eventTag = false
                lastPos = layout:getTouchBeganPosition()
                -- 
                clickCount      = clickCount+1
                layout:stopAllActions()
                performWithDelay(layout, function()
                    clickCount = 0
                end, 0.2)

            elseif eventType == 1 then
                if eventTag == false then
                    if self._isPressedCtrl then
                        if not self:isSWidgetBUSY(ouiData.widget) then
                            self:select_swidget_busy(ouiData, true)
                        end
                    else
                        self:unselect_swidget_busy()
                        self:select_swidget_busy(ouiData)
                    end
                    eventTag = true
                end

                local movePos   = layout:getTouchMovePosition()
                local psub      = cc.pSub(movePos, lastPos)
                lastPos         = layout:getTouchMovePosition()
                for _, ouiData in ipairs(self._editWidgetList) do
                    local positionX = ouiData.widget:getPositionX() + psub.x
                    local positionY = ouiData.widget:getPositionY() + psub.y
                    ouiData.widget:setPositionX(positionX)
                    ouiData.widget:setPositionY(positionY)
                end
                self:updateAttrBUSY()

            elseif eventType == 2 then

                -- 
                if clickCount == 2 then
                    clickCount = 0
                    self:unselect_swidget_busy()
                    self:select_swidget_busy(ouiData)
                    self:modifyWidget(ouiData)
                else
                    if false == eventTag then
                        -- 选择
                        if self._isPressedCtrl then
                            if self:isSWidgetBUSY(ouiData.widget) then
                                self:unselect_swidget_busy(ouiData.widget)
                            else
                                self:select_swidget_busy(ouiData, true)
                            end
                        else
                            self:unselect_swidget_busy()
                            self:select_swidget_busy(ouiData)
                        end
                    end
                end
                self:updateAttrBUSY()
            end
        end)

        -- 节点树
        local name   = SUIComponentProxy:findCUINameByWidgetKey(rootKey, ouiData.key)
        local troot  = CreateExport("cui_editor/tree_node.lua")
        local layout = troot:getChildByName("Panel_1")
        layout:removeFromParent()
        local ui     = ui_delegate(layout)
        self.ui.ListView_tree:pushBackCustomItem(ui.nativeUI)
        ui.Text_1:setString(name)
        ui.nativeUI.key = ouiData.key
        local nodeClick = 0
        ui.nativeUI:addClickEventListener(function()
            ui.Panel_2:runAction(cc.Sequence:create(cc.Blink:create(0.3, 3), cc.Show:create()))

            self:unselect_swidget_busy()
            self:select_swidget_busy(ouiData)
            self:updateAttrBUSY()

            nodeClick      = nodeClick+1
            ui.nativeUI:stopAllActions()
            performWithDelay(ui.nativeUI, function()
                nodeClick = 0
            end, 0.2)

            if nodeClick == 2 then
                nodeClick = 0
                self:modifyWidget(ouiData)
            end

        end)
    end
    local uiData = clone(originUIData)
    local orderData = SUIComponentProxy:getCUIOrderDataByRoot(rootKey)
    for _, widgetKey in ipairs(orderData) do
        if uiData[widgetKey] then
            local ouiData = uiData[widgetKey]
            addEditWidget(ouiData)
            uiData[widgetKey] = nil
        end
    end
    for _, ouiData in pairs(uiData) do
        addEditWidget(ouiData)
    end
end

function CUIEditor:selectEdit(ouiData)
    if self._editOUIData then
        self._editOUIData.widget:getChildByName("____editCUI"):setBackGroundColor(cc.c3b(0xff, 0xff, 0x00))
        self._editOUIData = nil
    end
    if ouiData then
        self._editOUIData = ouiData
        self._editOUIData.widget:getChildByName("____editCUI"):setBackGroundColor(cc.c3b(0xff, 0x00, 0x00))
    end
end

function CUIEditor:isSWidgetBUSY(targetWidget)
    if #self._editWidgetList == 0 then
        return false
    end

    for _, ouiData in ipairs(self._editWidgetList) do
        if targetWidget == ouiData.widget then
            return true
        end
    end

    return false
end

function CUIEditor:select_swidget_busy(ouiData, addition)
    if self:isSWidgetBUSY(ouiData.widget) then
        return nil
    end

    if not addition then
        for _, swidget in ipairs(self._editWidgetList) do
            swidget.widget:getChildByName("____editCUI"):setBackGroundColor(cc.c3b(0xff, 0xff, 0x00))
            local itemList = self.ui.ListView_tree:getItems()
            for _, item in ipairs(itemList) do
                if item.key == swidget.key then
                    item:setBackGroundColorType(0)
                    break
                end
            end
        end
        self._editWidgetList = {}
        self._editOUIData = nil
        
    end

    table.insert( self._editWidgetList , ouiData )
    for _, swidget in ipairs(self._editWidgetList) do
        if swidget.widget:getChildByName("____editCUI") then
            swidget.widget:getChildByName("____editCUI"):setBackGroundColor(cc.c3b(0xff, 0x00, 0x00))
        end
        local itemList = self.ui.ListView_tree:getItems()
        for _, item in ipairs(itemList) do
            if item.key == swidget.key then
                item:setBackGroundColor(cc.c3b(0xff, 0x00, 0x00))
                item:setBackGroundColorType(1)
                break
            end
        end
    end
    local editNum = #self._editWidgetList
    if editNum ~= 0 then
        self._editOUIData = self._editWidgetList[editNum]
    else
        self._editOUIData = nil
    end
end

function CUIEditor:unselect_swidget_busy(targetWidget)
    if #self._editWidgetList == 0 then
        return nil
    end

    if not targetWidget then
        for _, swidget in ipairs(self._editWidgetList) do
            if swidget.widget:getChildByName("____editCUI") then
                swidget.widget:getChildByName("____editCUI"):setBackGroundColor(cc.c3b(0xff, 0xff, 0x00))
            end
            local itemList = self.ui.ListView_tree:getItems()
            for _, item in ipairs(itemList) do
                if item.key == swidget.key then
                    item:setBackGroundColorType(0)
                    break
                end
            end
        end
        self._editWidgetList = {}
        self._editOUIData = nil
    else
        for i, swidget in ipairs(self._editWidgetList) do
            if swidget.widget == targetWidget then
                swidget.widget:getChildByName("____editCUI"):setBackGroundColor(cc.c3b(0xff, 0xff, 0x00))
                table.remove( self._editWidgetList, i)
                local itemList = self.ui.ListView_tree:getItems()
                for _, item in ipairs(itemList) do
                    if item.key == swidget.key then
                        item:setBackGroundColorType(0)
                        break
                    end
                end
                break
            end
        end
        local editNum = #self._editWidgetList
        if editNum ~= 0 then
            self._editOUIData = self._editWidgetList[editNum]
        else
            self._editOUIData = nil
        end
    end
end

function CUIEditor:updateAttr()
    self.ui.Panel_forbidden:setVisible(true)
    if not self._editOUIData then
        return nil
    end
    local rootKey = self._data.rootKey
    local root    = self._data.root
    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
    local customUIData = SUIComponentProxy:findCustomUIData(rootKey)
    if not customUIData then
        return nil
    end
    if not customUIData[self._editOUIData.key] then
        customUIData[self._editOUIData.key] = {}
    end
    local cuiData = customUIData[self._editOUIData.key]
    
    self.ui.Panel_forbidden:setVisible(false)

    -- 可见性
    cuiData.visible = self._editOUIData.widget:isVisible() and 1 or 0
    local visible   = (cuiData.visible == 1)
    self.ui.CheckBox_visible:setSelected(visible)

    -- 偏移
    cuiData.offsetx = math.floor(self._editOUIData.widget:getPositionX() - self._editOUIData.x)
    cuiData.offsety = math.floor(self._editOUIData.widget:getPositionY() - self._editOUIData.y)
    self.ui.TextField_posX:setString(math.floor(cuiData.offsetx))
    self.ui.TextField_posY:setString(math.floor(cuiData.offsety))

    -- 宽高
    cuiData.width = math.floor(self._editOUIData.widget:getContentSize().width)
    cuiData.height = math.floor(self._editOUIData.widget:getContentSize().height)
    self.ui.TextField_w:setString(math.floor(cuiData.width))
    self.ui.TextField_h:setString(math.floor(cuiData.height))
end

function CUIEditor:updateAttrBUSY()
    self.ui.Panel_forbidden:setVisible(true)
    if #self._editWidgetList == 0 then
        return nil
    end

    local rootKey = self._data.rootKey
    local root    = self._data.root
    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
    local customUIData = SUIComponentProxy:findCustomUIData(rootKey)
    if not customUIData then
        return nil
    end

    for _, ouiData in ipairs(self._editWidgetList) do 
        
        if not customUIData[ouiData.key] then
            customUIData[ouiData.key] = {}
        end
        local cuiData = customUIData[ouiData.key]
        
        self.ui.Panel_forbidden:setVisible(false)

        -- 可见性
        cuiData.visible = ouiData.widget:isVisible() and 1 or 0
        local visible   = (cuiData.visible == 1)
        self.ui.CheckBox_visible:setSelected(visible)

        -- 偏移
        cuiData.offsetx = math.floor(ouiData.widget:getPositionX() - ouiData.x)
        cuiData.offsety = math.floor(ouiData.widget:getPositionY() - ouiData.y)
        self.ui.TextField_posX:setString(math.floor(cuiData.offsetx))
        self.ui.TextField_posY:setString(math.floor(cuiData.offsety))

        -- 宽高
        cuiData.width = ouiData.widget:getContentSize().width
        cuiData.height = ouiData.widget:getContentSize().height
        self.ui.TextField_w:setString(math.floor(cuiData.width))
        self.ui.TextField_h:setString(math.floor(cuiData.height))
    end
end

function CUIEditor:modifyWidget(ouiData)
    -- if not self._editOUIData then
    --     return
    -- end
    self._editOUIData = ouiData

    local rootKey = self._data.rootKey
    local root    = self._data.root
    local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
    local customUIData = SUIComponentProxy:findCustomUIData(rootKey)
    if not customUIData then
        return nil
    end

    local cuiData = customUIData[self._editOUIData.key]

    -- imageview
    local function modify_ImageView(submit_callback, cancel_callback)
        local root, ui = CreateExport("cui_editor/cuieditor_Img.lua")
        self:addChild(root)

        local visibleSize = global.Director:getVisibleSize()
        ui.Panel_1:setContentSize(visibleSize.width, visibleSize.height)

        CreateEditBoxByTextField(ui.Panel_3:getChildByName("TextField_img"))

        if self._editOUIData.key == "#Panel_1#Image_gold" then
            ui.Panel_3_0:setVisible(true) 
            if cuiData.movable then
                local visible   = (cuiData.movable == 1)
                ui.CheckBox_movable:setSelected(visible)
            else
                ui.CheckBox_movable:setSelected(true)
            end
           
        end

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            ui.root:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_img:getString()) == 0 then
                ui.root:removeFromParent()
                return nil
            end

            -- 图片
            local img = ui.TextField_img:getString()
            local fullPath = getResFullPath(img)
            fullPath =  SUIHelper.fixImageFileName(fullPath)
            if not global.FileUtilCtl:isFileExist(fullPath) then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, "文件不存在！！")
                return
            end
            self._editOUIData.widget:loadTexture(fullPath)
            cuiData.img = fullPath

            if ui.CheckBox_movable:isVisible() then
                cuiData.movable = ui.CheckBox_movable:isSelected() and 1 or 0
            end


            -- 
            ui.root:removeFromParent()
        end)

        -- 图片
        local renderer = self._editOUIData.widget:getVirtualRenderer()
        local resfile, restype = SUIHelper.getResFile(renderer)
        ui.TextField_img:setString(resfile)

        -- 
        ui.Button_N_Res:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_img)
        end)
    end

    -- Button
    local function modify_Button(submit_callback, cancel_callback)
        local root, ui = CreateExport("cui_editor/cuieditor_Button.lua")
        self:addChild(root)

        local visibleSize = global.Director:getVisibleSize()
        ui.Panel_1:setContentSize(visibleSize.width, visibleSize.height)

        CreateEditBoxByTextField(ui.Panel_3:getChildByName("TextField_nimg"))
        CreateEditBoxByTextField(ui.Panel_4:getChildByName("TextField_pimg"))
        CreateEditBoxByTextField(ui.Panel_6:getChildByName("TextField_dimg"))
        CreateEditBoxByTextField(ui.Panel_5:getChildByName("TextField_text"))

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            ui.root:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_nimg:getString()) == 0 then
                ui.root:removeFromParent()
                return nil
            end

            -- 正常图片
            local img = ui.TextField_nimg:getString()
            local fullPath = getResFullPath(img)
            fullPath =  SUIHelper.fixImageFileName(fullPath)
            if not global.FileUtilCtl:isFileExist(fullPath) then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, "文件不存在！")
                return
            end
            self._editOUIData.widget:loadTextureNormal(fullPath)
            cuiData.nimg = fullPath

            -- 按下图片
            local img = ui.TextField_pimg:getString()
            local fullPath = getResFullPath(img)
            fullPath =  SUIHelper.fixImageFileName(fullPath)
            if not global.FileUtilCtl:isFileExist(fullPath) and string.len(img) ~= 0 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, "文件不存在！")
                return
            end
            self._editOUIData.widget:loadTexturePressed(fullPath)
            cuiData.pimg = fullPath

            -- 禁用图片
            local img = ui.TextField_dimg:getString()
            local fullPath = getResFullPath(img)
            fullPath =  SUIHelper.fixImageFileName(fullPath)
            if not global.FileUtilCtl:isFileExist(fullPath) and string.len(img) ~= 0 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, "文件不存在！")
                return
            end
            self._editOUIData.widget:loadTextureDisabled(fullPath)
            cuiData.dimg = fullPath

            -- 按钮文本
            local input = ui.TextField_text:getString()
            self._editOUIData.widget:setTitleText(input)
            cuiData.text = input
            if self._editOUIData.key == "#Panel_1#Button_4" and string.find(input, "#") and rootKey == global.CUIKeyTable.BAG_MERGE then
                local textList = string.split(input, "#")
                self._editOUIData.widget:setTitleText(textList[1])
            end
            if self._editOUIData.key == "Panel_1#Button_quick" and string.find(input, "#") and rootKey == global.CUIKeyTable.NPC_STORAGE then
                local textList = string.split(input, "#")
                local NPCStorageProxy = global.Facade:retrieveProxy(global.ProxyTable.NPCStorageProxy)
                local touchType = NPCStorageProxy:GetTouchType() or 1
                self._editOUIData.widget:setTitleText(textList[touchType])
            end
            -- 
            ui.root:removeFromParent()
        end)

        -- 正常图片
        local renderer = self._editOUIData.widget:getRendererNormal()
        local resfile, restype = SUIHelper.getResFile(renderer)
        ui.TextField_nimg:setString(resfile)

        -- 按下图片
        local renderer = self._editOUIData.widget:getRendererClicked()
        local resfile, restype = SUIHelper.getResFile(renderer)
        ui.TextField_pimg:setString(resfile)

        --禁用图片
        local renderer = self._editOUIData.widget:getRendererDisabled()
        local resfile, restype = SUIHelper.getResFile(renderer)
        ui.TextField_dimg:setString(resfile)

        -- 按钮文本
        local text = self._editOUIData.widget:getTitleText()
        ui.TextField_text:setString(text)

        if self._editOUIData.key == "#Panel_1#Button_4" and rootKey == global.CUIKeyTable.BAG_MERGE then
            local btnData = FindCustomUIDataByKey(global.CUIKeyTable.BAG_MERGE, "#Panel_1#Button_4")
            if btnData and btnData.text then
                ui.TextField_text:setString(btnData.text) 
            else
                local str = string.format("%s#%s", GET_STRING(600000212), GET_STRING(600000213))
                ui.TextField_text:setString(str) 
            end
        end

        if self._editOUIData.key == "Panel_1#Button_quick" and rootKey == global.CUIKeyTable.NPC_STORAGE then
            local btnData = FindCustomUIDataByKey(global.CUIKeyTable.NPC_STORAGE, "Panel_1#Button_quick")
            if btnData and btnData.text then
                ui.TextField_text:setString(btnData.text) 
            else
                local str = string.format("%s#%s", GET_STRING(90100002), GET_STRING(90100003))
                ui.TextField_text:setString(str) 
            end
        end

        -- 
        ui.Button_N_Res:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_nimg)
        end)

        ui.Button_P_Res:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_pimg)
        end)

        ui.Button_D_Res:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_dimg)
        end)
    end

    -- 英雄召唤收回按钮 特殊处理
    local function modify_Hero_Button(submit_callback, cancel_callback)
        local root, ui = CreateExport("cui_editor/cuieditor_Hero_Button.lua")
        self:addChild(root)

        local visibleSize = global.Director:getVisibleSize()
        ui.Panel_1:setContentSize(visibleSize.width, visibleSize.height)

        CreateEditBoxByTextField(ui.Panel_3:getChildByName("TextField_nimg_z"))
        CreateEditBoxByTextField(ui.Panel_4:getChildByName("TextField_pimg_z"))
        CreateEditBoxByTextField(ui.Panel_3_0:getChildByName("TextField_nimg_s"))
        CreateEditBoxByTextField(ui.Panel_4_0:getChildByName("TextField_pimg_s"))

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            ui.root:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_nimg_z:getString()) == 0 and string.len(ui.TextField_nimg_s:getString()) == 0 then
                ui.root:removeFromParent()
                return nil
            end

            local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
            local isLogin =  HeroPropertyProxy:HeroIsLogin()

            -- 召唤正常图片
            local img = ui.TextField_nimg_z:getString()
            local fullPath = getResFullPath(img)
            fullPath =  SUIHelper.fixImageFileName(fullPath)
            if not global.FileUtilCtl:isFileExist(fullPath) and string.len(img) ~= 0 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, "文件不存在！")
                return
            end
            if not isLogin then
                self._editOUIData.widget:loadTextureNormal(fullPath)
            end
            cuiData.nimgCall = fullPath

            -- 召唤按下图片
            local img = ui.TextField_pimg_z:getString()
            local fullPath = getResFullPath(img)
            fullPath =  SUIHelper.fixImageFileName(fullPath)
            if not global.FileUtilCtl:isFileExist(fullPath) and string.len(img) ~= 0 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, "文件不存在！")
                return
            end
            if not isLogin then
                self._editOUIData.widget:loadTexturePressed(fullPath)
            end
            cuiData.pimgCall = fullPath


            -- 收回正常图片
            local img = ui.TextField_nimg_s:getString()
            local fullPath = getResFullPath(img)
            fullPath =  SUIHelper.fixImageFileName(fullPath)
            if not global.FileUtilCtl:isFileExist(fullPath) and string.len(img) ~= 0 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, "文件不存在！")
                return
            end
            if isLogin then
                self._editOUIData.widget:loadTextureNormal(fullPath)
            end
            cuiData.nimgBack = fullPath

            -- 收回按下图片
            local img = ui.TextField_pimg_s:getString()
            local fullPath = getResFullPath(img)
            fullPath =  SUIHelper.fixImageFileName(fullPath)
            if not global.FileUtilCtl:isFileExist(fullPath) and string.len(img) ~= 0 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, "文件不存在！")
                return
            end
            if isLogin then
                self._editOUIData.widget:loadTexturePressed(fullPath)
            end
            cuiData.pimgBack = fullPath

            -- 
            ui.root:removeFromParent()
        end)

        local cuiData = nil
        local rootKey = self._data.rootKey
        local SUIComponentProxy = global.Facade:retrieveProxy(global.ProxyTable.SUIComponentProxy)
        local customUIData = SUIComponentProxy:findCustomUIData(rootKey)
        if  customUIData and customUIData[self._editOUIData.key] then
            cuiData = customUIData[self._editOUIData.key]
        end

        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        local isLogin =  HeroPropertyProxy:HeroIsLogin()

        -- 召唤正常图片
        local renderer = self._editOUIData.widget:getRendererNormal()
        local resfile, restype = SUIHelper.getResFile(renderer)
        local nimgCall = cuiData and cuiData.nimgCall 
        if nimgCall and string.len(nimgCall) > 0 then
            ui.TextField_nimg_z:setString(nimgCall)
        elseif not isLogin then
            ui.TextField_nimg_z:setString(resfile)
        end
        

        -- 召唤按下图片
        local renderer = self._editOUIData.widget:getRendererClicked()
        local resfile, restype = SUIHelper.getResFile(renderer)
        local pimgCall = cuiData and cuiData.pimgCall
        if pimgCall and string.len(pimgCall) > 0 then
            ui.TextField_pimg_z:setString(pimgCall)
        elseif not isLogin then
            ui.TextField_pimg_z:setString(resfile)
        end

        -- 收回正常图片
        local renderer = self._editOUIData.widget:getRendererNormal()
        local resfile, restype = SUIHelper.getResFile(renderer)
        local nimgBack = cuiData and cuiData.nimgBack
        if nimgBack and string.len(nimgBack) > 0 then
            ui.TextField_nimg_s:setString(nimgBack)
        elseif isLogin then
            ui.TextField_nimg_s:setString(resfile)
        end

        -- 收回按下图片
        local renderer = self._editOUIData.widget:getRendererClicked()
        local resfile, restype = SUIHelper.getResFile(renderer)
        local pimgBack = cuiData and cuiData.pimgBack
        if pimgBack and string.len(pimgBack) > 0 then
            ui.TextField_pimg_s:setString(pimgBack)
        elseif isLogin then
            ui.TextField_pimg_s:setString(resfile)
        end

        -- 
        ui.Button_N_Res_Z:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_nimg_z)
        end)

        ui.Button_P_Res_Z:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_pimg_z)
        end)

        ui.Button_N_Res_S:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_nimg_s)
        end)

        ui.Button_P_Res_S:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_pimg_s)
        end)

    end

    -- Text
    local function modify_Text(submit_callback, cancel_callback)
        print("modify text")
        local root, ui = CreateExport("cui_editor/cuieditor_Text.lua")
        self:addChild(root)

        local visibleSize = global.Director:getVisibleSize()
        ui.Panel_1:setContentSize(visibleSize.width, visibleSize.height)

        CreateEditBoxByTextField(ui.Panel_3:getChildByName("TextField_fontSize"))
        CreateEditBoxByTextField(ui.Panel_4:getChildByName("TextField_fontColor"))

        local canModStr = false
        if self._frameKey[rootKey] and (string.find(self._editOUIData.key, "PageText") or string.find(self._editOUIData.key, "Text_name")) then
            ui.Panel_5:setVisible(true)
            canModStr = true
            CreateEditBoxByTextField(ui.Panel_5:getChildByName("TextField_text"))
        end

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            ui.root:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_fontSize:getString()) == 0 and string.len(ui.TextField_fontColor:getString()) == 0 then
                ui.root:removeFromParent()
                return nil
            end

            -- 字体大小
            local fontSize  = ui.TextField_fontSize:getString()
            self._editOUIData.widget:setFontSize(tonumber(fontSize))
            cuiData.fontSize = fontSize

            -- 字体颜色
            local fontColor = ui.TextField_fontColor:getString()
            if string.find(fontColor, "#") then
                self._editOUIData.widget:setTextColor(GetColorFromHexString(fontColor))
                cuiData.color = fontColor
            else
                self._editOUIData.widget:setTextColor(GET_COLOR_BYID_C3B(tonumber(fontColor)))
                cuiData.color = GET_COLOR_BYID(tonumber(fontColor))
            end

            -- 文本内容
            if canModStr then
                local str = ui.TextField_text:getString()
                self._editOUIData.widget:setString(str)
                cuiData.text = str
            end

            -- 
            ui.root:removeFromParent()
        end)

        -- 字体大小
        local Fsize = self._editOUIData.widget:getFontSize()
        ui.TextField_fontSize:setString(Fsize)

        -- 字体颜色
        local Fcolor = self._editOUIData.widget:getTextColor()
        ui.TextField_fontColor:setString(GetColorHexFromRBG(Fcolor))

        -- 文本内容
        if canModStr then
            local str = self._editOUIData.widget:getString()
            ui.TextField_text:setString(str)
        end

    end

    local function modify_LoadingBar(submit_callback, cancel_callback)
        local root, ui = CreateExport("cui_editor/cuieditor_Img.lua")
        self:addChild(root)

        local visibleSize = global.Director:getVisibleSize()
        ui.Panel_1:setContentSize(visibleSize.width, visibleSize.height)

        CreateEditBoxByTextField(ui.Panel_3:getChildByName("TextField_img"))

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            ui.root:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_img:getString()) == 0 then
                ui.root:removeFromParent()
                return nil
            end

            -- 图片
            local img = ui.TextField_img:getString()
            local fullPath = getResFullPath(img)
            fullPath =  SUIHelper.fixImageFileName(fullPath)
            if not global.FileUtilCtl:isFileExist(fullPath) then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, "文件不存在！！")
                return
            end
            self._editOUIData.widget:loadTexture(fullPath)
            cuiData.img = fullPath
            -- 
            ui.root:removeFromParent()
        end)

        -- 图片
        local renderer = self._editOUIData.widget:getVirtualRenderer()

        local texture = renderer:getTexture()
        -- local filename = global.TextureCache:getTextureFilePath(texture)
        local fullPath = texture:getPath()
        local fileT = string.split(fullPath, "/res/")
        local resfile = fileT[2] and global.MMO.PATH_RES_CUSTOM..fileT[2] or ""
       
        ui.TextField_img:setString(resfile)

        --
        ui.Button_N_Res:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_img)
        end)
    end

    local function modify_CheckBox(submit_callback, cancel_callback)
        local root, ui = CreateExport("cui_editor/cuieditor_CheckBox.lua")
        self:addChild(root)

        local visibleSize = global.Director:getVisibleSize()
        ui.Panel_1:setContentSize(visibleSize.width, visibleSize.height)

        CreateEditBoxByTextField(ui.Panel_3:getChildByName("TextField_bimg"))
        CreateEditBoxByTextField(ui.Panel_4:getChildByName("TextField_fimg"))

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            ui.root:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_bimg:getString()) == 0 then
                ui.root:removeFromParent()
                return nil
            end

            -- 背景样式
            local img = ui.TextField_bimg:getString()
            local fullPath = getResFullPath(img)
            fullPath =  SUIHelper.fixImageFileName(fullPath)
            if not global.FileUtilCtl:isFileExist(fullPath) then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, "文件不存在！")
                return
            end
            self._editOUIData.widget:loadTextureBackGround(fullPath)
            cuiData.bimg = fullPath

            -- 标识样式
            local img = ui.TextField_fimg:getString()
            local fullPath = getResFullPath(img)
            fullPath =  SUIHelper.fixImageFileName(fullPath)
            if not global.FileUtilCtl:isFileExist(fullPath) and string.len(img) ~= 0 then
                global.Facade:sendNotification(global.NoticeTable.SystemTips, "文件不存在！")
                return
            end
            self._editOUIData.widget:loadTextureFrontCross(fullPath)
            cuiData.fimg = fullPath

            -- 
            ui.root:removeFromParent()
        end)

        -- 背景
        local renderer = self._editOUIData.widget:getRendererBackground()
        local fullPath = renderer:getTexture():getPath()
        local fileT = string.split(fullPath, "/res/")
        local resfile = fileT[2] and global.MMO.PATH_RES_CUSTOM..fileT[2] or ""
        ui.TextField_bimg:setString(resfile)

        -- 标识
        local renderer = self._editOUIData.widget:getRendererFrontCross()
        local fullPath = renderer:getTexture():getPath()
        local fileT = string.split(fullPath, "/res/")
        local resfile = fileT[2] and global.MMO.PATH_RES_CUSTOM..fileT[2] or ""
        ui.TextField_fimg:setString(resfile)

        --
        ui.Button_N_Res:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_bimg)
        end)

        ui.Button_P_Res:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_fimg)
        end)

    end

    local function modify_Node(submit_callback, cancel_callback)
        print("modify Equip Node")
        local root, ui = CreateExport("cui_editor/cuieditor_Node.lua")
        self:addChild(root)

        local visibleSize = global.Director:getVisibleSize()
        ui.Panel_1:setContentSize(visibleSize.width, visibleSize.height)

        CreateEditBoxByTextField(ui.Panel_3:getChildByName("TextField_order"))

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            ui.root:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_order:getString()) == 0 then
                ui.root:removeFromParent()
                return nil
            end

            -- zOrder
            local order  = ui.TextField_order:getString()
            self._editOUIData.widget:setLocalZOrder(tonumber(order))
            cuiData.zorder = tonumber(order)

            -- 
            ui.root:removeFromParent()
        end)

        -- zOrder
        local order = self._editOUIData.widget:getLocalZOrder()
        ui.TextField_order:setString(order)

    end

    local classname = tolua.type(self._editOUIData.widget)
    if classname == "ccui.ImageView" then
        modify_ImageView()
        
    elseif classname == "ccui.Button" then
        if self._editOUIData and self._editOUIData.key == "#Button_hero" then
            modify_Hero_Button()
        else
            modify_Button()
        end

    elseif classname == "ccui.Text" then
        modify_Text()
    
    elseif classname == "ccui.Layout"  then
        local list = {
            "Panel_pos0",
            "Panel_pos1",
            "Panel_pos16",
            "Panel_pos55",
        }
        if string.find(rootKey, "equip") then
            for _, key in ipairs(list) do
                if string.find(self._editOUIData.key, key) then
                    modify_Node()
                    break
                end
            end
        end

        -- 时装
        local list = {
            "Panel_pos17",
            "Panel_pos18",
            "Panel_pos21",
        }
        if string.find(rootKey, "superEquip") then
            for _, key in ipairs(list) do
                if string.find(self._editOUIData.key, key) then
                    modify_Node()
                    break
                end
            end
        end

    elseif classname == "ccui.LoadingBar" then
        modify_LoadingBar()
    
    elseif classname == "ccui.CheckBox" then
        modify_CheckBox()

    elseif classname == "cc.Node" then
        if string.find(rootKey, "equip") or string.find(rootKey, "superEquip") then
            modify_Node()
        end
    end
end

function CUIEditor:onOpenResSelector(widget)
    local originRes = ""
    if widget.getString then
        local str = widget:getString()
        if str and string.len(str) > 0 then
            originRes = str
        end
    end
    local function callFunc(res)
        widget:setString(res)
    end
    
    global.Facade:sendNotification(global.NoticeTable.Layer_GUIResSelector_Open, {res = originRes, callfunc = callFunc})
end

return CUIEditor
