local BaseLayer = requireLayerUI("BaseLayer")
local SUIEditor = class("SUIEditor", BaseLayer)

local sfind   = string.find
local sformat = string.format


local Element       = require("sui/Element")
local SWidget       = require("sui/SWidget")
local SUILoader     = require("sui/SUILoader").new()
local SUIHelper     = require("sui/SUIHelper")
local LexicalHelper = require("sui/LexicalHelper")
local TxtTranslator = require("sui/TxtTranslator").new()

local unit_name = {[1] = "px 像素", [2] = "% 百分比"}
local LineColor         = cc.c4f(1, 0, 0, 0.5)

local function inputTextAble(inputText)
    return string.len(inputText:getString()) > 0
end

local function containsPoint(widget, point)
    local contentSize   = widget:getContentSize()
    local anchorPoint   = widget:getAnchorPoint()
    local worldPosition = widget:getWorldPosition()

    local minX          = worldPosition.x - anchorPoint.x * contentSize.width
    local maxX          = worldPosition.x + (1-anchorPoint.x) * contentSize.width
    local minY          = worldPosition.y - anchorPoint.y * contentSize.height
    local maxY          = worldPosition.y + (1-anchorPoint.y) * contentSize.height
    return point.x > minX and point.x < maxX and point.y > minY and point.y < maxY
end

function SUIEditor:ctor()
    SUIEditor.super.ctor(self)

    self._closeListener = {}
    self._isPressedCtrl = false

    self._swidgetBUSYs  = {}
    self._trunk_root    = nil
    
    self._autoid        = 100

    self._width_unit    = 1     -- 宽 1.像素  2.百分比
    self._height_unit   = 1     -- 高 1.像素  2.百分比
    self._x_unit        = 1     -- x  1.像素  2.百分比
    self._y_unit        = 1     -- y  1.像素  2.百分比
end

function SUIEditor.create(...)
    local layer = SUIEditor.new()
    if layer:init(...) then
        return layer
    end
    return nil
end

function SUIEditor:init(data)
    local root = CreateExport("sui_editor/main_editor.lua")
    if not root then
        return false
    end
    self:addChild(root)
    self._quickUI = ui_delegate(root)

    -- 隐藏帧率
    global.Director:setDisplayStats(false)
    
    -- 黑色背景
    self:AddPanelBackgroundEvent()
    -- 退出
    self._quickUI.Button_close:addClickEventListener(function()
        global.Facade:sendNotification(global.NoticeTable.SUIEditorClose)
    end)

    -- 切换
    local visibleSize = global.Director:getVisibleSize()
    local index = 1
    local width = 300
    self._quickUI.Button_change:addClickEventListener(function()
        index = 1 - index

        self._quickUI.Panel_act:stopAllActions()
        self._quickUI.Panel_attr:stopAllActions()
        if index == 0 then
            local positionY = self._quickUI.Panel_act:getPositionY()
            self._quickUI.Panel_act:runAction(cc.MoveTo:create(0.2, cc.p(visibleSize.width+width, positionY)))
            local positionY = self._quickUI.Panel_attr:getPositionY()
            self._quickUI.Panel_attr:runAction(cc.MoveTo:create(0.2, cc.p(visibleSize.width+width, positionY)))
        else
            local positionY = self._quickUI.Panel_act:getPositionY()
            self._quickUI.Panel_act:runAction(cc.MoveTo:create(0.2, cc.p(visibleSize.width, positionY)))
            local positionY = self._quickUI.Panel_attr:getPositionY()
            self._quickUI.Panel_attr:runAction(cc.MoveTo:create(0.2, cc.p(visibleSize.width, positionY)))
        end
    end)

    self:initAct()
    self:initAttr()
    self:initCtrl()

    self:init_tree_nodes()

    self:cleanup()

    self:initAdapet()

    -- default
    self:loadSUI("")

    return true
end

function SUIEditor:initAdapet()
    local visibleSize = global.Director:getVisibleSize()
    self._quickUI.Panel_global:setPosition(cc.p(visibleSize.width, visibleSize.height))
    self._quickUI.Panel_act:setPosition(cc.p(visibleSize.width, visibleSize.height - 40))
    self._quickUI.Panel_attr:setPosition(cc.p(visibleSize.width, 0))

    local actH = visibleSize.height-40-180
    self._quickUI.Panel_act:setContentSize(cc.size(300, actH))
    self._quickUI.Panel_edit:setContentSize(cc.size(300, actH - 160 - 45))
    self._quickUI.TextField_edit:setContentSize(cc.size(290, actH - 160 - 45 - 10))
    self._quickUI.Panel_edit:setPositionY(actH)
    self._quickUI.TextField_edit:setPositionY(actH - 160 - 45 - 5)
end

function SUIEditor:onClose()
    for _, listener in pairs(self._closeListener) do
        listener()
    end
end

function SUIEditor:addCloseEventListener(listener)
    table.insert(self._closeListener, listener)
end

function SUIEditor:initAct()
    -- add widget
    local function addSwidgetCallback(etype)
        self:create_default_swidget(etype)
    end
    self._quickUI.Button_Text:addClickEventListener(function()      addSwidgetCallback("Text")      end)
    self._quickUI.Button_RText:addClickEventListener(function()     addSwidgetCallback("RText")     end)
    self._quickUI.Button_Img:addClickEventListener(function()       addSwidgetCallback("Img")       end)
    self._quickUI.Button_Button:addClickEventListener(function()    addSwidgetCallback("Button")    end)
    self._quickUI.Button_Layout:addClickEventListener(function()    addSwidgetCallback("Layout")    end)
    self._quickUI.Button_Effect:addClickEventListener(function()    addSwidgetCallback("Effect")    end)
    self._quickUI.Button_Frames:addClickEventListener(function()    addSwidgetCallback("Frames")    end)
    self._quickUI.Button_Input:addClickEventListener(function()     addSwidgetCallback("Input")     end)
    self._quickUI.Button_CheckBox:addClickEventListener(function()  addSwidgetCallback("CheckBox")  end)
    self._quickUI.Button_ListView:addClickEventListener(function()  addSwidgetCallback("ListView")  end)
    self._quickUI.Button_ITEMBOX:addClickEventListener(function()   addSwidgetCallback("ITEMBOX")   end)
    self._quickUI.Button_ItemShow:addClickEventListener(function()  addSwidgetCallback("ItemShow")  end)
    self._quickUI.Button_EquipShow:addClickEventListener(function() addSwidgetCallback("EquipShow") end)
    self._quickUI.Button_PageView:addClickEventListener(function()  addSwidgetCallback("PageView")  end)
    
    -- cmd
    -- remove
    self._quickUI.Button_remove:addClickEventListener(function()
        self:remove_swidget_busy()
    end)

    -- output
    self._quickUI.Button_output:addClickEventListener(function()
        self:RushEditText()
        if #self._trunk_root.branches == 0 then
            return nil
        end

        local source = self:calcOutput()
        self._quickUI.TextField_edit:setString(source)

        -- 存到本地目录
        if cc.FileUtils:getInstance():isFileExist("data_config/sui_editor_export.txt") then
            -- 文件名
            local filename  = os.date("%Y %m %d %H-%M-%S")
            local folder    = cc.FileUtils:getInstance():getStringFromFile("data_config/sui_editor_export.txt")
            local path      = string.format("%s%s.txt", folder, filename)
            
            -- 检测文件夹是否存在
            if false == cc.FileUtils:getInstance():isDirectoryExist(folder) then
                cc.FileUtils:getInstance():createDirectory(folder)
                ShowSystemTips("创建文件夹 " .. folder)
            end

            -- 写入
            cc.FileUtils:getInstance():writeStringToFile(source, path)

            ShowSystemTips("导出成功 " .. path)
        end
    end)

    -- load
    self._quickUI.Button_load:addClickEventListener(function()
        self:LoadEditSui()
    end)

    -- copy 
    self._quickUI.Button_copy:addClickEventListener(function()
        if global.isWindows then
            local str = self._quickUI.TextField_edit:getString()
            if Win32BridgeCtl then 
                Win32BridgeCtl:Inst():copyToClipboard(str)
            end
        end
        DelayTouchEnabled(self._quickUI.Button_copy)
    end)

    -- clean
    self._quickUI.Button_clean:addClickEventListener(function()
        self._quickUI.TextField_edit:setString("")
    end)

    -- edit
    CreateEditBoxByTextField(self._quickUI.Panel_edit:getChildByName("TextField_edit"))

    local function modify_TransData(submit_callback, cancel_callback)
        local root = CreateExport("sui_editor/trans_to_lua.lua")
        self:addChild(root)
        local ui = ui_delegate(root)

        CreateEditBoxByTextField(ui.Panel_c1:getChildByName("TextField_nimg"))

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            ui.nativeUI:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_nimg:getString()) == 0 then
                ui.nativeUI:removeFromParent()
                return nil
            end

            local fileName = ui.TextField_nimg:getString()
            submit_callback(fileName)

            -- 
            ui.nativeUI:removeFromParent()
        end)

    end

    local function clickCB(fileName)
        local edit = self._quickUI.TextField_edit:getString()
        if string.len(edit) == 0 then
            ShowSystemTips("没有可转文本！")
            return nil
        end
        
        TxtTranslator:loadTalkContent(edit, fileName)
    end

    local clickCount = 0 
    local eventTag   = false
    self._quickUI.Button_lua:addTouchEventListener(function(_, eventType)
        if eventType == 0 then
        elseif eventType == 1 then
        elseif eventType == 2 then
            if not eventTag then
                if clickCB then
                    eventTag   = true
                    performWithDelay(self._quickUI.Button_lua, function()
                        eventTag   = false
                        if clickCB then -- 点击设置文件名
                            modify_TransData(clickCB) 
                        end
                    end, global.MMO.CLICK_DOUBLE_TIME)
                end
            else
                self._quickUI.Button_lua:stopAllActions()
                if clickCB then -- 双击直接导出
                    clickCB()
                    eventTag   = false
                end
            end 
        end
        
    end)

    self._quickUI.Button_rush:addClickEventListener(function()
        self:RushEditText()
    end)
    self._quickUI.Button_up:addClickEventListener(function()
        self:setWidgetZOrder(true)
    end)
    self._quickUI.Button_dowm:addClickEventListener(function()
        self:setWidgetZOrder(false)
    end)
    self._quickUI.Button_hor:addClickEventListener(function()
        self:SetWidthHor()
    end)
    self._quickUI.Button_ver:addClickEventListener(function()
        self:SetWidthVer()
    end)
    self._quickUI.Button_left:addClickEventListener(function()
        self:SetAlignLeft()
    end)
    self._quickUI.Button_top:addClickEventListener(function()
        self:SetAlignTop()
    end)
end

function SUIEditor:initAttr()
    self._quickUI.TextField_link:setCursorEnabled(true)
    self._quickUI.TextField_id:setCursorEnabled(true)
    self._quickUI.TextField_sizeW:setCursorEnabled(true)
    self._quickUI.TextField_sizeH:setCursorEnabled(true)
    self._quickUI.TextField_anchorX:setCursorEnabled(true)
    self._quickUI.TextField_anchorY:setCursorEnabled(true)
    self._quickUI.TextField_posX:setCursorEnabled(true)
    self._quickUI.TextField_posY:setCursorEnabled(true)
    self._quickUI.TextField_rotate:setCursorEnabled(true)
    self._quickUI.TextField_note:setCursorEnabled(true)

    
    -----------------------------------------------------------------------
    -----------------------------------------------------------------------
    -- 像素/百分比
    local function unitCallback(sender, unit_type)
        if unit_type == "width" then
            -- 宽
            self._width_unit = 3 - self._width_unit
            
        elseif unit_type == "height" then
            -- 高
            self._height_unit = 3 - self._height_unit
            
        elseif unit_type == "x" then
            -- 坐标X
            self._x_unit = 3 - self._x_unit
            
        elseif unit_type == "y" then
            -- 坐标Y
            self._y_unit = 3 - self._y_unit
        end
        local unit      = {["width"] = self._width_unit, ["height"] = self._height_unit, ["x"] = self._x_unit, ["y"] = self._y_unit}
        sender:setString(unit_name[unit[unit_type]])
    end

    -- width
    local function widthCallback(sender)
        self._width_unit = 3 - self._width_unit
        sender:setString(unit_name[self._width_unit])

        if #self._swidgetBUSYs == 0 then
            return nil
        end

        for _, swidget in ipairs(self._swidgetBUSYs) do
            local render                    = swidget.render
            local element                   = swidget.element
            local contentSize               = render:getContentSize()
            local parentSize                = render:getParent():getContentSize()
            if self._width_unit == 1 then
                element.attr.percentwidth   = nil
                element.attr.width          = string.format("%.1f", contentSize.width)
    
            elseif self._width_unit == 2 then
                element.attr.percentwidth   = string.format("%.1f", contentSize.width / parentSize.width * 100)
                element.attr.width          = nil
            end
        end
    
        -- 
        self:update_attr()
    end

    -- height
    local function heightCallback(sender)
        self._height_unit = 3 - self._height_unit
        sender:setString(unit_name[self._height_unit])

        if #self._swidgetBUSYs == 0 then
            return nil
        end

        for _, swidget in ipairs(self._swidgetBUSYs) do
            local render                    = swidget.render
            local element                   = swidget.element
            local contentSize               = render:getContentSize()
            local parentSize                = render:getParent():getContentSize()
            if self._height_unit == 1 then
                element.attr.percentheight  = nil
                element.attr.height         = string.format("%.1f", contentSize.height)
    
            elseif self._height_unit == 2 then
                element.attr.percentheight  = string.format("%.1f", contentSize.height / parentSize.height * 100)
                element.attr.height         = nil
            end
        end
    
        -- 
        self:update_attr()
    end

    -- x
    local function xCallback(sender)
        self._x_unit = 3 - self._x_unit
        sender:setString(unit_name[self._x_unit])

        if #self._swidgetBUSYs == 0 then
            return nil
        end

        for _, swidget in ipairs(self._swidgetBUSYs) do
            local render                    = swidget.render
            local element                   = swidget.element
            local effect_pos                = render.getTurePosition and render:getTurePosition()
            local positionX                 = effect_pos and effect_pos.x or render:getPositionX()
            local parentSize                = render:getParent():getContentSize()
            if self._x_unit == 1 then
                element.attr.percentx       = nil
                element.attr.x              = string.format("%.1f", positionX)
    
            elseif self._x_unit == 2 then
                element.attr.percentx       = string.format("%.1f", positionX / parentSize.width * 100)
                element.attr.x              = nil
            end
        end
    
        -- 
        self:update_attr()
    end
    
    -- y
    local function yCallback(sender)
        self._y_unit = 3 - self._y_unit
        sender:setString(unit_name[self._y_unit])

        if #self._swidgetBUSYs == 0 then
            return nil
        end

        for _, swidget in ipairs(self._swidgetBUSYs) do
            local render                    = swidget.render
            local element                   = swidget.element
            local effect_pos                = render.getTurePosition and render:getTurePosition()
            local positionY                 = effect_pos and effect_pos.y or render:getPositionY()
            local parentSize                = render:getParent():getContentSize()
            if self._y_unit == 1 then
                element.attr.percenty       = nil
                element.attr.y              = string.format("%.1f", parentSize.height - positionY)

            elseif self._y_unit == 2 then
                element.attr.percenty       = string.format("%.1f", (parentSize.height - positionY) / parentSize.height * 100)
                element.attr.y              = nil
            end
        end
    
        -- 
        self:update_attr()
    end

    self._quickUI.Text_unit_sizeW:addClickEventListener(widthCallback)
    self._quickUI.Text_unit_sizeH:addClickEventListener(heightCallback)
    self._quickUI.Text_unit_posX:addClickEventListener(xCallback)
    self._quickUI.Text_unit_posY:addClickEventListener(yCallback)



    -----------------------------------------------------------------------
    -----------------------------------------------------------------------
    -- width
    local function sizeWidthCallback(sender, eventType)
        if eventType ~= 1 then
            return nil
        end
        if #self._swidgetBUSYs == 0 then
            return nil
        end

        for _, swidget in ipairs(self._swidgetBUSYs) do
            local render                    = swidget.render
            local element                   = swidget.element
    
            local input_width               = tonumber(self._quickUI.TextField_sizeW:getString()) or 0
    
            -- 宽
            if self._width_unit == 1 then
                element.attr.percentwidth   = nil
                element.attr.width          = input_width
    
            elseif self._width_unit == 2 then
                element.attr.percentwidth   = input_width
                element.attr.width          = nil
            end
    
            -- 
            if SUILoader.modifySizeAble(swidget) then
                local size = SUILoader.fixSize(swidget)
                render:setContentSize(size)
            end
        end

        self:update_attr()
    end

    -- height
    local function sizeHeightCallback(sender, eventType)
        if eventType ~= 1 then
            return nil
        end
        if #self._swidgetBUSYs == 0 then
            return nil
        end

        for _, swidget in ipairs(self._swidgetBUSYs) do
            local render                    = swidget.render
            local element                   = swidget.element
    
            local input_height              = tonumber(self._quickUI.TextField_sizeH:getString()) or 0
    
            -- 高
            if self._height_unit == 1 then
                element.attr.percentheight  = nil
                element.attr.height         = input_height
    
            elseif self._height_unit == 2 then
                element.attr.percentheight  = input_height
                element.attr.height         = nil
            end
    
            -- 
            if SUILoader.modifySizeAble(swidget) then
                local size = SUILoader.fixSize(swidget)
                render:setContentSize(size)
            end
        end

        self:update_attr()
    end

    -- ax
    local function anchorXCallback(sender, eventType)
        if eventType ~= 1 then
            return nil
        end
        if #self._swidgetBUSYs == 0 then
            return nil
        end
        
        for _, swidget in ipairs(self._swidgetBUSYs) do
            local render                    = swidget.render
            local element                   = swidget.element
    
            local input_ax                  = tonumber(self._quickUI.TextField_anchorX:getString()) or 0
    
            -- 
            element.attr.ax                 = input_ax
    
            -- 
            if SUILoader.modifyAnchorAble(swidget) then
                local anchor = SUILoader.fixAnchor(swidget)
                render:setAnchorPoint(anchor)
            end
        end

        self:update_attr()
    end

    -- ax
    local function anchorYCallback(sender, eventType)
        if eventType ~= 1 then
            return nil
        end
        if #self._swidgetBUSYs == 0 then
            return nil
        end
        
        for _, swidget in ipairs(self._swidgetBUSYs) do
            local render                    = swidget.render
            local element                   = swidget.element
    
            local input_ay                  = tonumber(self._quickUI.TextField_anchorY:getString()) or 0
    
            -- 
            element.attr.ay                 = input_ay
    
            -- 
            if SUILoader.modifyAnchorAble(swidget) then
                local anchor = SUILoader.fixAnchor(swidget)
                render:setAnchorPoint(anchor)
            end
        end

        self:update_attr()
    end

    -- x
    local function positionXCallback(sender, eventType)
        if eventType ~= 1 then
            return nil
        end
        if #self._swidgetBUSYs == 0 then
            return nil
        end

        for _, swidget in ipairs(self._swidgetBUSYs) do
            local render                    = swidget.render
            local element                   = swidget.element
    
            local input_x                   = tonumber(self._quickUI.TextField_posX:getString()) or 0
    
            -- x
            if self._x_unit == 1 then
                element.attr.percentx       = nil
                element.attr.x              = input_x
    
            elseif self._x_unit == 2 then
                element.attr.percentx       = input_x
                element.attr.y              = nil
            end
    
            -- 
            local position = SUILoader.fixPosition(swidget)
            render:setPosition(position)
        end

        self:update_attr()
    end

    -- y
    local function positionYCallback(sender, eventType)
        if eventType ~= 1 then
            return nil
        end
        if #self._swidgetBUSYs == 0 then
            return nil
        end

        for _, swidget in ipairs(self._swidgetBUSYs) do
            local render                    = swidget.render
            local element                   = swidget.element
    
            local input_y                   = tonumber(self._quickUI.TextField_posY:getString()) or 0
    
            -- y
            if self._y_unit == 1 then
                element.attr.percenty       = nil
                element.attr.y              = input_y
    
            elseif self._y_unit == 2 then
                element.attr.percenty       = input_y
                element.attr.y              = nil
            end
    
            -- 
            local position = SUILoader.fixPosition(swidget)
            render:setPosition(position)
        end

        self:update_attr()
    end

    -- link
    local function linkCallback(sender, eventType)
        if eventType ~= 1 then
            return nil
        end
        if #self._swidgetBUSYs == 0 then
            return nil
        end

        for _, swidget in ipairs(self._swidgetBUSYs) do
            local element                   = swidget.element
            local input                     = string.len(sender:getString()) > 0 and sender:getString() or ""
            if input and string.len(input) > 0 then
                element.attr.link           = input
            else
                element.attr.link           = nil
            end
        end

        self:update_attr()
    end
    
    -- id
    local function idCallback(sender, eventType)
        if eventType ~= 1 then
            return nil
        end
        if #self._swidgetBUSYs == 0 then
            return nil
        end

        for _, swidget in ipairs(self._swidgetBUSYs) do
            local element                   = swidget.element
            local input                     = string.len(sender:getString()) > 0 and sender:getString() or ""
            if input and string.len(input) > 0 then
                element.attr.id             = input
            else
                element.attr.id             = nil
            end
        end

        self:update_attr()
    end

    -- rotate
    local function rotateCallback(sender, eventType)
        if eventType ~= 1 then
            return nil
        end
        if #self._swidgetBUSYs == 0 then
            return nil
        end

        for _, swidget in ipairs(self._swidgetBUSYs) do
            local render                    = swidget.render
            local element                   = swidget.element
            local input                     = string.len(sender:getString()) > 0 and sender:getString() or ""
            if input and string.len(input) > 0 then
                element.attr.rotate         = input
            else
                element.attr.rotate         = nil
            end
            
            -- 
            local rotate = SUILoader.fixRotate(swidget)
            render:setRotation(rotate)
        end

        self:update_attr()
    end

    -- note
    local function noteCallback(sender, eventType)
        if eventType ~= 1 then
            return nil
        end
        if #self._swidgetBUSYs == 0 then
            return nil
        end

        for _, swidget in ipairs(self._swidgetBUSYs) do
            local element                   = swidget.element
            local input                     = string.len(sender:getString()) > 0 and sender:getString() or ""
            if input and string.len(input) > 0 then
                element.attr.note           = input
            else
                element.attr.note           = nil
            end
        end

        self:update_attr()
    end

    self._quickUI.TextField_sizeW:addEventListener(sizeWidthCallback)
    self._quickUI.TextField_sizeH:addEventListener(sizeHeightCallback)
    self._quickUI.TextField_anchorX:addEventListener(anchorXCallback)
    self._quickUI.TextField_anchorY:addEventListener(anchorYCallback)
    self._quickUI.TextField_posX:addEventListener(positionXCallback)
    self._quickUI.TextField_posY:addEventListener(positionYCallback)
    self._quickUI.TextField_link:addEventListener(linkCallback)
    self._quickUI.TextField_id:addEventListener(idCallback)
    self._quickUI.TextField_rotate:addEventListener(rotateCallback)
    self._quickUI.TextField_note:addEventListener(noteCallback)
end

function SUIEditor:initCtrl()
    -- 坐标微调
    local function eventKeyCode(addPos)
        if #self._swidgetBUSYs == 0 then
            return nil
        end

        for _, swidget in ipairs(self._swidgetBUSYs) do
            local render    = swidget.render
            if swidget.trunk and swidget.trunk.element and swidget.trunk.element.type and (swidget.trunk.element.type == "ListView" or swidget.trunk.element.type == "PageView") then
                break
            end
            local element   = swidget.element
            local src_pos   = cc.p(render:getPositionX(), render:getPositionY())
            if render.getTurePosition then
                src_pos = render:getTurePosition()
            end
            local dst_pos   = cc.pAdd(src_pos, addPos)
            render:setPosition(dst_pos)
            local effect_pos = render.getTurePosition and render:getTurePosition()
    
            local positionX             = effect_pos and effect_pos.x or render:getPositionX()
            local positionY             = effect_pos and effect_pos.y or render:getPositionY()
            local parentSize            = render:getParent():getContentSize()
            -- x
            if self._x_unit == 1 then
                element.attr.x          = sformat("%.1f", positionX)
                
            elseif self._x_unit == 2 then
                element.attr.percentx   = sformat("%.1f", positionX / parentSize.width * 100)
            end
            
            -- y
            if self._y_unit == 1 then
                element.attr.y          = sformat("%.1f", parentSize.height - positionY)
                
            elseif self._y_unit == 2 then
                element.attr.percenty   = sformat("%.1f", (parentSize.height - positionY) / parentSize.height * 100)
            end
        end

        self:update_attr()
    end

    local function eventChangeSize(addSize)
        if #self._swidgetBUSYs == 0 then
            return nil
        end
        for _, swidget in ipairs(self._swidgetBUSYs) do
            local render = swidget.render
            local element = swidget.element
            local oldSize = render:getContentSize()
            render:setContentSize(oldSize.width + addSize.width,oldSize.height + addSize.height)
            element.attr.percentwidth   = nil
            element.attr.width = oldSize.width + addSize.width
            element.attr.height = oldSize.height + addSize.height
        end
        self:update_attr()
    end
    local isMoving = {}
    local nodes    = {}
    local keyCodes = {
        cc.KeyCode.KEY_LEFT_ARROW, cc.KeyCode.KEY_RIGHT_ARROW, cc.KeyCode.KEY_UP_ARROW, cc.KeyCode.KEY_DOWN_ARROW,
        cc.KeyCode.KEY_W, cc.KeyCode.KEY_S, cc.KeyCode.KEY_A, cc.KeyCode.KEY_D,
    }
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
        elseif keycode == cc.KeyCode.KEY_DELETE then
            self:remove_swidget_busy()

        elseif keycode == cc.KeyCode.KEY_LEFT_CTRL then
            self._isPressedCtrl = true
        elseif keycode == cc.KeyCode.KEY_W or keycode == cc.KeyCode.KEY_S or keycode == cc.KeyCode.KEY_A or keycode == cc.KeyCode.KEY_D then
            local addSize = nil
            if keycode == cc.KeyCode.KEY_W then
                addSize = cc.size(0, -1)
            elseif keycode == cc.KeyCode.KEY_S then
                addSize = cc.size(0, 1)
            elseif keycode == cc.KeyCode.KEY_A then
                addSize = cc.size(-1, 0)
            elseif keycode == cc.KeyCode.KEY_D then
                addSize = cc.size(1, 0)
            end
            if addSize then
                eventChangeSize(addSize)
                local delay = 0.5
                for k, v in pairs(isMoving) do
                    if v then
                        delay = 0
                        break
                    end
                end
                performWithDelay(nodes[keycode], function()
                    local function callback()
                        eventChangeSize(addSize)
                    end
                    schedule(nodes[keycode], callback, 0.01)
                    isMoving[keycode] = true
                end, delay)
            end
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

    self:addCloseEventListener(function()
        eventDispatcher:removeEventListener(listener)
    end)
end

function SUIEditor:calcOutput()
    if #self._trunk_root.branches == 0 then
        return nil
    end

    -- 解析单个swidget
    local ignores = {"tax", "tay", "tpercentx", "tpercenty"}
    local function isIngore(key)
        for _, v in ipairs(ignores) do
            if v == key then
                return true
            end
        end
        return false
    end
    local function parse_swidget(swidget)
        local element = swidget.element
        local kvmap   = {}
        for k, v in pairs(element.attr) do
            if isIngore(k) then
            else
                if string.len(tostring(v)) == 0 then
                elseif k=="id" and sfind(v, "default_") then
                elseif k=="children" then
                else
                    -- \ 加个换行
                    if element.type=="RText" and k=="text" then
                        -- v = string.gsub(v,"\\", "\\\r\n")
                    end
    
                    if sfind(k, "img") then
                        v = SUIHelper.fixImageFileName(v)
                    end
                    table.insert(kvmap, sformat("%s=%s", k, v))
                end
            end
        end
        -- chilren
        if #swidget.branches > 0 then
            local children = "{"
            for i, branch in ipairs(swidget.branches) do
                children = children .. branch.element.attr.id
                if i ~= #swidget.branches then
                    children = children .. ","
                end
            end
            children = children .. "}"
            table.insert(kvmap, sformat("%s=%s", "children", children))
        end
        -- 排序
        local rank = 
        {
            note    =0,
            id      =1,
            children=2,
            a       =3, 
            ax      =4, 
            ay      =5, 
            x       =6, 
            y       =7, 
            percentx=8, 
            percenty=9, 
            width   =10, 
            height  =11, 
            percentwidth=12, 
            percentheight=13,
            rotate  =14,
            boxindex=15,
            stdmode =16,
            tips    =17,
            tipsx   =18,
            tipsy   =19,
            itemid  =20,
            itemcount=21,
            scale = 22,
            speed = 23,
            text=999, 
            link=1000,
        }
        table.sort(kvmap, function(a, b)
            local key1      = string.split(a, "=")[1]
            local key2      = string.split(b, "=")[1]
            local rank_a    = rank[key1] or 100
            local rank_b    = rank[key2] or 100
            return rank_a < rank_b
        end)

        return sformat("<%s|%s>", element.type, table.concat(kvmap, "|"))
    end

    local output = ""
    -- 递归计算输出
    local function parse_swidgets(swidgets)
        if #swidgets == 0 then
            return nil
        end

        for index, swidget in ipairs(swidgets) do
            output = output .. parse_swidget(swidget)
            output = output .. "\r\n"

            -- 
            parse_swidgets(swidget.branches)
        end
    end
    parse_swidgets(self._trunk_root.branches)

    return output  
end

function SUIEditor:cleanup()
    self._quickUI.Node_ui:removeAllChildren()
    self._swidgetBUSYs  = {}
    self._autoid        = 100

    self:reset_attr()
    self:reset_trunk_root()
    self:update_tree_nodes()
    self:reset_forbidden_attr()
end

function SUIEditor:loadSUI(source)
    self:cleanup()

    -- 
    local ext           = {isImmediate = true}
    self._trunk_root    = SUILoader:load(source, nil, nil, ext)
    self._quickUI.Node_ui:addChild(self._trunk_root.render)

    -- autoid
    self._autoid = SUIHelper.getSWidgetsMaxID(self._trunk_root)
    
    -- edit mode
    local function display_swidgets(tswidgets)
        if #tswidgets == 0 then
            return nil
        end

        for _, swidget in ipairs(tswidgets) do
            self:add_swidget_command(swidget)

            display_swidgets(swidget.branches)
        end
    end
    display_swidgets(self._trunk_root.branches)

    -- 
    self:update_tree_nodes()
end

function SUIEditor:reset_trunk_root()
    local _, rect               = checkNotchPhone(true)
    local deviceWid             = rect.width
    local deviceHei             = rect.height
    self._trunk_root            = SWidget.new()
    self._trunk_root.element    = Element.new("Layout")
    self._trunk_root.depth      = 0
    self._trunk_root.render     = ccui.Layout:create()
    self._trunk_root.render:setContentSize(cc.size(deviceWid, deviceHei))
    self._trunk_root.render:setPositionX(rect.x)
    self._quickUI.Node_ui:addChild(self._trunk_root.render)
end

function SUIEditor:update_attr()
    if #self._swidgetBUSYs == 0 then
        return nil
    end

    for _, swidget in ipairs(self._swidgetBUSYs) do
        -- 
        local render  = swidget.render
        local element = swidget.element
        
        -- 
        local visibleSize   = global.Director:getVisibleSize()
        local contentSize   = render:getContentSize()
    
        local ax            = element.attr.ax or 0
        local ay            = element.attr.ay or 1
        local percentwidth  = element.attr.percentwidth 
        local percentheight = element.attr.percentheight
        local width         = element.attr.width or contentSize.width
        local height        = element.attr.height or contentSize.height
        local percentx      = element.attr.percentx
        local percenty      = element.attr.percenty
        local x             = element.attr.x or 0
        local y             = element.attr.y or 0
        local rotate        = element.attr.rotate or 0
        local note          = element.attr.note or ""
    
        
        -- 宽
        if percentwidth then
            self._quickUI.TextField_sizeW:setString(sformat("%.1f", percentwidth))
            self._width_unit = 2
        else
            self._quickUI.TextField_sizeW:setString(sformat("%.1f", width))
            self._width_unit = 1
        end
        self._quickUI.Text_unit_sizeW:setString(unit_name[self._width_unit])
    
    
        -- 高
        if percentheight then
            self._quickUI.TextField_sizeH:setString(sformat("%.1f", percentheight))
            self._height_unit = 2
        else
            self._quickUI.TextField_sizeH:setString(sformat("%.1f", height))
            self._height_unit = 1
        end
        self._quickUI.Text_unit_sizeH:setString(unit_name[self._height_unit])
    
        
        -- 锚点
        self._quickUI.TextField_anchorX:setString(sformat("%.1f", ax))
        self._quickUI.TextField_anchorY:setString(sformat("%.1f", ay))
        
    
        -- x
        if percentx then
            self._quickUI.TextField_posX:setString(sformat("%.1f", percentx))
            self._x_unit = 2
        else
            self._quickUI.TextField_posX:setString(sformat("%.1f", x))
            self._x_unit = 1
        end
        self._quickUI.Text_unit_posX:setString(unit_name[self._x_unit])
        
        
        -- y
        if percenty then
            self._quickUI.TextField_posY:setString(sformat("%.1f", percenty))
            self._y_unit = 2
        else
            self._quickUI.TextField_posY:setString(sformat("%.1f", y))
            self._y_unit = 1
        end
        self._quickUI.Text_unit_posY:setString(unit_name[self._y_unit])
    
        -- link
        self._quickUI.TextField_link:setString(element.attr.link or "")
    
        -- id
        self._quickUI.TextField_id:setString((nil == element.attr.id or "" == element.attr.id or sfind(element.attr.id, "default_")) and "" or element.attr.id)
        
        -- rotate
        self._quickUI.TextField_rotate:setString(rotate)
    
        -- note
        self._quickUI.TextField_note:setString(element.attr.note or "")
    
        -- draw debug rect
        local contentSize = (swidget.element.type == "Effect" and cc.size(50, 50) or render:getContentSize())
        swidget.drawRect:clear()
        swidget.drawRect:drawRect({x = 0, y = 0}, {x = contentSize.width, y = contentSize.height}, cc.c4f(1, 0, 0, 0.5))
        swidget.layout:setContentSize(contentSize)
    end
end

function SUIEditor:reset_attr()
    self._quickUI.TextField_sizeW:setString(sformat("%.1f", 0))
    self._quickUI.TextField_sizeH:setString(sformat("%.1f", 0))

    self._quickUI.TextField_anchorX:setString(sformat("%.1f", 0))
    self._quickUI.TextField_anchorY:setString(sformat("%.1f", 0))
    
    self._quickUI.TextField_posX:setString(sformat("%.1f", 0))
    self._quickUI.TextField_posY:setString(sformat("%.1f", 0))

    self._quickUI.TextField_link:setString("")

    self._quickUI.TextField_id:setString("")

    self._width_unit    = 1
    self._height_unit   = 1
    self._x_unit        = 1
    self._y_unit        = 1
    self._quickUI.Text_unit_sizeW:setString(unit_name[self._width_unit])
    self._quickUI.Text_unit_sizeH:setString(unit_name[self._height_unit])
    self._quickUI.Text_unit_posX:setString(unit_name[self._x_unit])
    self._quickUI.Text_unit_posY:setString(unit_name[self._y_unit])
end

function SUIEditor:reset_forbidden_attr()
    self._quickUI.Panel_forbidden:setVisible(true)
end

function SUIEditor:unable_forbidden_attr()
    self._quickUI.Panel_forbidden:setVisible(false)
end

function SUIEditor:remove_swidget_busy()
    if #self._swidgetBUSYs == 0 then
        return nil
    end

    for _, swidget in ipairs(self._swidgetBUSYs) do
        self:remove_swidget(swidget)
    end
    self._swidgetBUSYs = {}

    self:reset_forbidden_attr()
    self:reset_attr()
    self:update_tree_nodes()
end

function SUIEditor:reset_all_swidget_busy()
    if #self._swidgetBUSYs == 0 then
        return nil
    end

    for _, swidget in ipairs(self._swidgetBUSYs) do
        swidget.drawRect:setVisible(false)
    end
    self._swidgetBUSYs = {}
end

function SUIEditor:unselect_swidget_busy(targetWidget)
    if #self._swidgetBUSYs == 0 then
        return nil
    end

    if nil == targetWidget then
        for _, swidget in ipairs(self._swidgetBUSYs) do
            swidget.drawRect:setVisible(false)
        end
        self._swidgetBUSYs = {}
    else
        for i, swidget in ipairs(self._swidgetBUSYs) do
            if swidget == targetWidget then
                swidget.drawRect:setVisible(false)
                table.remove(self._swidgetBUSYs, i)
                break
            end
        end
    end

    local forbidden = #self._swidgetBUSYs == 0
    if forbidden then
        self:reset_forbidden_attr()
    else
        self:unable_forbidden_attr()
    end

    self:reset_attr()
end

function SUIEditor:select_swidget_busy(swidget, addition)
    if self:isSWidgetBUSY(swidget) then
        return nil
    end

    if not addition then
        for _, swidget in ipairs(self._swidgetBUSYs) do
            swidget.drawRect:setVisible(false)
        end
        self._swidgetBUSYs  = {}
    end

    local forbiddenSize     = false
    local forbiddenAnchor   = false
    local forbiddenPos      = false
    table.insert(self._swidgetBUSYs, swidget)
    for _, swidget in ipairs(self._swidgetBUSYs) do
        swidget.drawRect:setVisible(true)
        forbiddenSize       = swidget and SUILoader.modifySizeAble(swidget)
        forbiddenAnchor     = swidget and SUILoader.modifyAnchorAble(swidget)
        if swidget and swidget.trunk and swidget.trunk.element.type and (swidget.trunk.element.type == "ListView" or swidget.trunk.element.type == "PageView") then
            forbiddenPos = true
        end
    end
    self._quickUI.Panel_forbidden_size:setVisible(false == forbiddenSize)
    self._quickUI.Panel_forbidden_anchor:setVisible(false == forbiddenAnchor)
    self._quickUI.Panel_forbidden_pos:setVisible(forbiddenPos)

    local forbidden = #self._swidgetBUSYs == 0
    if forbidden then
        self:reset_forbidden_attr()
    else
        self:unable_forbidden_attr()
    end

    self:update_attr()
end

function SUIEditor:isSWidgetBUSY(target)
    if #self._swidgetBUSYs == 0 then
        return false
    end

    for _, swidget in ipairs(self._swidgetBUSYs) do
        if target == swidget then
            return true
        end
    end

    return false
end

function SUIEditor:find_swidget_by_id(id)
    if #self._trunk_root.branches == 0 then
        return nil
    end

    local target = nil
    local function find_swidget(swidgets)
        if swidgets and #swidgets > 0 then
            for _, swidget in ipairs(swidgets) do
                if swidget.element.attr.id == id then
                    target = swidget
                    break
                else
                    find_swidget(swidget.branches)
                end
            end
        end
    end
    find_swidget(self._trunk_root.branches)

    return target
end

function SUIEditor:add_swidget_to_view(swidget, parentID, insert_index)
    if nil == parentID or "" == parentID then
        self._trunk_root:addChild(swidget.render)
        if insert_index then
            table.insert(self._trunk_root.branches, insert_index, swidget)
        else
            table.insert(self._trunk_root.branches, swidget)
        end

        local zorder = self._trunk_root:getChildrenCount()
        swidget.render:setLocalZOrder(zorder)
    else
        local parent = self:find_swidget_by_id(parentID)
        parent.render:addChild(swidget.render)
        table.insert(parent.branches, swidget)
    end
end

function SUIEditor:add_swidget_command(swidget)
    local render        = swidget.render
    local element       = swidget.element
    local contentSize   = (swidget.element.type == "Effect" and cc.size(50, 50) or render:getContentSize())

    -- draw rect
    local drawNode = cc.DrawNode:create()
    render:addChild(drawNode)
    drawNode:drawRect({x = 0, y = 0}, {x = contentSize.width, y = contentSize.height}, cc.c4f(1, 0, 0, 0.5))
    drawNode:setVisible(false)
    swidget.drawRect = drawNode

    -- touch layout
    local layout = ccui.Layout:create()
    if tolua.iskindof(render,"ccui.ListView") then
        local node = cc.Node:create()
        node:setLocalZOrder(9999)
        node:addChild(layout)
        render:addChild(node)
    else
        render:addChild(layout)
    end
    layout:setContentSize(contentSize)
    layout:setTouchEnabled(true)
    layout:setLocalZOrder(1)
    swidget.layout = layout

    
    local lastPos           = nil
    local clickCount        = 0
    local eventTag          = false
    layout:addTouchEventListener(function(_, eventType)
        if eventType == 0 then
            eventTag        = false
            lastPos         = layout:getTouchBeganPosition()

            -- 
            clickCount      = clickCount + 1
            layout:stopAllActions()
            performWithDelay(layout, function()
                clickCount = 0
            end, 0.2)
        
        elseif eventType == 1 then
            if false == eventTag then
                if self._isPressedCtrl then
                    if not self:isSWidgetBUSY(swidget) then
                        self:select_swidget_busy(swidget, true)
                    end
                else
                    self:reset_all_swidget_busy()
                    self:select_swidget_busy(swidget)
                end
                eventTag = true
            end

            local movePos   = layout:getTouchMovePosition()
            local psub      = cc.pSub(movePos, lastPos)
            lastPos         = layout:getTouchMovePosition()

            for _, swidget in ipairs(self._swidgetBUSYs) do
                local render                = swidget.render
                local itemElement           = swidget.element
                local pos                   = cc.p(render:getPositionX(), render:getPositionY())
                if render.getTurePosition then
                    pos = render:getTurePosition()
                end
                render:setPosition(cc.pAdd(pos, psub))

                local effect_pos            = render.getTurePosition and render:getTurePosition()
                local positionX             = effect_pos and effect_pos.x or render:getPositionX()
                local positionY             = effect_pos and effect_pos.y or render:getPositionY()
                local parentSize            = render:getParent():getContentSize()
                -- x
                if self._x_unit == 1 then
                    itemElement.attr.x          = sformat("%.1f", positionX)
                    
                elseif self._x_unit == 2 then
                    itemElement.attr.percentx   = sformat("%.1f", positionX / parentSize.width * 100)
                end
                
                -- y
                if self._y_unit == 1 then
                    itemElement.attr.y          = sformat("%.1f", parentSize.height - positionY)
                    
                elseif self._y_unit == 2 then
                    itemElement.attr.percenty   = sformat("%.1f", (parentSize.height - positionY) / parentSize.height * 100)
                end
            end
            self:update_attr()

        elseif eventType == 2 then
            if clickCount == 2 then
                clickCount = 0
                self:modify_swidget(swidget)
            else
                if false == eventTag then
                    -- 选择
                    if self._isPressedCtrl then
                        if self:isSWidgetBUSY(swidget) then
                            self:unselect_swidget_busy(swidget)
                        else
                            self:select_swidget_busy(swidget, true)
                        end
                    else
                        self:reset_all_swidget_busy()
                        self:select_swidget_busy(swidget)
                    end
                end
            end
        end
    end)
end

function SUIEditor:remove_swidget(swidget)
    if #self._trunk_root.branches == 0 then
        return nil
    end

    local function remove_target(swidgets)
        if swidgets and #swidgets > 0 then
            for index, target in ipairs(swidgets) do
                if swidget == target then
                    table.remove(swidgets, index)
                    target.render:removeFromParent()
                    break
                else
                    remove_target(target.branches)
                end
            end
        end
    end
    remove_target(self._trunk_root.branches)
end

function SUIEditor:create_default_swidget(etype)
    self._autoid = nil

    -- 
    local element               = nil
    if etype == "Text" then
        element                 = Element.new("Text")
        element.attr.id         = self._autoid
        element.attr.x          = 25
        element.attr.y          = 20
        element.attr.text       = "Text"
        element.attr.size       = 18
        element.attr.color      = 255

    elseif etype == "RText" then
        element                 = Element.new("RText")
        element.attr.id         = self._autoid
        element.attr.x          = 25
        element.attr.y          = 20
        element.attr.size       = 18
        element.attr.color      = 255
        element.attr.text       = "<RText/FCOLOR=255><RText/FCOLOR=254>"
        
    elseif etype == "Img" then
        element                 = Element.new("Img")
        element.attr.id         = self._autoid
        element.attr.img        = "public/1900000651_3.png"

    elseif etype == "Button" then
        element                 = Element.new("Button")
        element.attr.id         = self._autoid
        element.attr.nimg       = "public/00000361.png"
        element.attr.pimg       = "public/00000362.png"
        element.attr.mimg       = "public/00000363.png"
        element.attr.text       = "Button"
        element.attr.size       = 18
        element.attr.color      = 255
        
    elseif etype == "Layout" then
        element                 = Element.new("Layout")
        element.attr.id         = self._autoid
        element.attr.color      = 255
        element.attr.width      = 200
        element.attr.height     = 200
        
    elseif etype == "Effect" then
        element                 = Element.new("Effect")
        element.attr.id         = self._autoid
        element.attr.effectid   = 4521
        element.attr.effecttype = 0
        element.attr.speed      = 1
        element.attr.scale      = 1
        element.attr.x          = 50
        element.attr.y          = 50
        
    elseif etype == "Frames" then
        element                 = Element.new("Frames")
        element.attr.id         = self._autoid
        element.attr.prefix     = "public/word_fubentg_"
        element.attr.suffix     = ".png"
        element.attr.count      = 10
        element.attr.speed      = 100
        element.attr.loop       = -1

    elseif etype == "Input" then
        element                 = Element.new("Input")
        element.attr.id         = self._autoid
        element.attr.inputid    = 1
        element.attr.type       = 0
        element.attr.width      = 100
        element.attr.height     = 25
        element.attr.color      = 255
        element.attr.size       = 16
        
    elseif etype == "CheckBox" then
        element                 = Element.new("CheckBox")
        element.attr.id         = self._autoid
        element.attr.checkboxid = 1
        element.attr.nimg       = "public/1900000550.png"
        element.attr.pimg       = "public/1900000551.png"
        element.attr.default    = 1

    elseif etype == "ListView" then
        element                 = Element.new("ListView")
        element.attr.id         = self._autoid
        element.attr.width      = 200
        element.attr.height     = 200
        element.attr.color      = 255

    elseif etype == "ITEMBOX" then
        element                 = Element.new("ITEMBOX")
        element.attr.id         = self._autoid
        element.attr.width      = 70
        element.attr.height     = 70
        element.attr.boxindex   = 0
        element.attr.img        = "public/1900000651_3.png"
        element.attr.stdmode    = "*"

    elseif etype == "ItemShow" then
        element                 = Element.new("ItemShow")
        element.attr.id         = self._autoid
        element.attr.width      = 70
        element.attr.height     = 70
        element.attr.itemid     = 1
        element.attr.itemcount  = 1
        element.attr.showtips   = 1
        element.attr.bgtype     = 1

    elseif etype == "EquipShow" then
        element                 = Element.new("EquipShow")
        element.attr.id         = self._autoid
        element.attr.width      = 70
        element.attr.height     = 70
        element.attr.index      = 1
        element.attr.showtips   = 1
        element.attr.bgtype     = 1

    elseif etype == "PageView" then
        element                 = Element.new("PageView")
        element.attr.id         = self._autoid
        element.attr.width      = 200
        element.attr.height     = 200
        element.attr.color      = 255
    end

    if element then
        local swidget       = SWidget.new()
        swidget.element     = element
        swidget.render      = SUILoader:load_render(swidget)
        self._trunk_root:addBranch(swidget)
        self._trunk_root:addBranchRender(swidget)
        SUILoader.loadSWidgetAttr(swidget)
        self:add_swidget_command(swidget)

        self:update_tree_nodes()
    end
end

function SUIEditor:modify_swidget(swidget)
    local element = swidget.element
    local etype   = element.type

    ------------------------------------------------------------------
    ------------------------------------------------------------------
    -- Text
    local function modify_Text(submit_callback, cancel_callback)
        local root = CreateExport("sui_editor/creator_Text.lua")
        self:addChild(root)
        local ui = ui_delegate(root)

        CreateEditBoxByTextField(ui.Panel_3:getChildByName("TextField_text"))
        CreateEditBoxByTextField(ui.Panel_9:getChildByName("TextField_9"))

        ui.TextField_color:setCursorEnabled(true)
        ui.TextField_fontsize:setCursorEnabled(true)
        ui.TextField_10:setCursorEnabled(true)
        ui.TextField_11:setCursorEnabled(true)

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            ui.nativeUI:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_text:getString()) == 0 then
                ui.nativeUI:removeFromParent()
                return nil
            end

            local text          = ui.TextField_text:getString()
            text                = string.gsub(text, "[\t\n\r]", "")
            if string.len(text) == 0 then
                ui.nativeUI:removeFromParent()
                return nil
            end

            element.attr.text   = text
            element.attr.size   = tonumber(ui.TextField_fontsize:getString())
            element.attr.color  = ui.TextField_color:getString()
            element.attr.tips   = ui.TextField_9:getString()
            element.attr.tipsx  = ui.TextField_10:getString()
            element.attr.tipsy  = ui.TextField_11:getString()

            submit_callback(swidget)

            -- 
            ui.nativeUI:removeFromParent()
        end)

        -- 
        if element.attr.text then
            ui.TextField_text:setString(element.attr.text)
        end
        if element.attr.color then
            ui.TextField_color:setString(element.attr.color)
        end
        if element.attr.size then
            ui.TextField_fontsize:setString(element.attr.size)
        end
        if element.attr.tips then
            ui.TextField_9:setString(element.attr.tips)
        end
        if element.attr.tipsx then
            ui.TextField_10:setString(element.attr.tipsx)
        end
        if element.attr.tipsy then
            ui.TextField_11:setString(element.attr.tipsy)
        end
    end

    -- RText
    local function modify_RText(submit_callback, cancel_callback)
        local root = CreateExport("sui_editor/creator_RText.lua")
        self:addChild(root)
        local ui = ui_delegate(root)

        CreateEditBoxByTextField(ui.Panel_3:getChildByName("TextField_text"))
        CreateEditBoxByTextField(ui.Panel_9:getChildByName("TextField_9"))

        ui.TextField_10:setCursorEnabled(true)
        ui.TextField_11:setCursorEnabled(true)

        ui.TextField_color:setCursorEnabled(true)
        ui.TextField_fontsize:setCursorEnabled(true)

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            ui.nativeUI:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_text:getString()) == 0 then
                ui.nativeUI:removeFromParent()
                return nil
            end

            local text          = ui.TextField_text:getString()
            text                = string.gsub(text, "[\t\n\r]", "")
            if string.len(text) == 0 then
                ui.nativeUI:removeFromParent()
                return nil
            end

            element.attr.text   = text
            element.attr.size   = tonumber(ui.TextField_fontsize:getString())
            element.attr.color  = tonumber(ui.TextField_color:getString())
            element.attr.tips   = ui.TextField_9:getString()
            element.attr.tipsx  = ui.TextField_10:getString()
            element.attr.tipsy  = ui.TextField_11:getString()

            submit_callback(swidget)

            -- 
            ui.nativeUI:removeFromParent()
        end)

        -- 
        if element.attr.text then
            ui.TextField_text:setString(element.attr.text)
        end
        if element.attr.color then
            ui.TextField_color:setString(element.attr.color)
        end
        if element.attr.size then
            ui.TextField_fontsize:setString(element.attr.size)
        end
        if element.attr.tips then
            ui.TextField_9:setString(element.attr.tips)
        end
        if element.attr.tipsx then
            ui.TextField_10:setString(element.attr.tipsx)
        end
        if element.attr.tipsy then
            ui.TextField_11:setString(element.attr.tipsy)
        end
    end

    -- Img
    local function modify_Img(submit_callback, cancel_callback)
        local root = CreateExport("sui_editor/creator_Img.lua")
        self:addChild(root)
        local ui = ui_delegate(root)

        CreateEditBoxByTextField(ui.Panel_3:getChildByName("TextField_img"))
        CreateEditBoxByTextField(ui.Panel_8:getChildByName("TextField_8"))

        ui.TextField_left:setCursorEnabled(true)
        ui.TextField_right:setCursorEnabled(true)
        ui.TextField_top:setCursorEnabled(true)
        ui.TextField_bottom:setCursorEnabled(true)
        ui.TextField_9:setCursorEnabled(true)
        ui.TextField_10:setCursorEnabled(true)
        ui.TextField_11:setCursorEnabled(true)

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            ui.nativeUI:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_img:getString()) == 0 then
                ui.nativeUI:removeFromParent()
                return nil
            end

            local lastAttr              = clone(element.attr)

            -- 九宫格
            if ui.CheckBox_scale9:isSelected() then
                element.attr.scale9l    = tonumber(ui.TextField_left:getString()) or 0
                element.attr.scale9r    = tonumber(ui.TextField_right:getString()) or 0
                element.attr.scale9t    = tonumber(ui.TextField_top:getString()) or 0
                element.attr.scale9b    = tonumber(ui.TextField_bottom:getString()) or 0
            else
                element.attr.scale9l    = nil
                element.attr.scale9r    = nil
                element.attr.scale9t    = nil
                element.attr.scale9b    = nil
            end

            -- 背景图
            if ui.CheckBox_bg:isSelected() then
                element.attr.bg         = 1
            else
                element.attr.bg         = nil
            end
            -- esc关闭
            element.attr.esc            = (ui.CheckBox_bg:isSelected() and ui.CheckBox_esc:isSelected()) and 1 or 0
            element.attr.img            = ui.TextField_img:getString()
            element.attr.tips           = ui.TextField_8:getString()
            element.attr.tipsx          = ui.TextField_9:getString()
            element.attr.tipsy          = ui.TextField_10:getString()
            element.attr.rotate         = ui.TextField_10:getString()
            element.attr.show           = ui.TextField_11:getString()

            if element.attr.bg and tonumber(element.attr.bg) == 1 and lastAttr.show ~= element.attr.show then
                local source = self:calcOutput()
                self._quickUI.TextField_edit:setString(source)
                self:loadSUI(source)
            else
                submit_callback(swidget)
            end

            -- 
            ui.nativeUI:removeFromParent()
        end)

        ui.Button_N_Res:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_img)
        end)

        -- 
        if element.attr.img then
            ui.TextField_img:setString(element.attr.img)
        end
        if element.attr.scale9l and element.attr.scale9r and element.attr.scale9t and element.attr.scale9b then
            ui.CheckBox_scale9:setSelected(true) 
            ui.TextField_left:setString(element.attr.scale9l)
            ui.TextField_right:setString(element.attr.scale9r)
            ui.TextField_top:setString(element.attr.scale9t)
            ui.TextField_bottom:setString(element.attr.scale9b)
        else
            ui.CheckBox_scale9:setSelected(false) 
        end
        ui.CheckBox_bg:setSelected(tonumber(element.attr.bg) == 1)
        ui.CheckBox_esc:setSelected(tonumber(element.attr.bg) == 1 and (tonumber(element.attr.esc) == 1 or tonumber(element.attr.esc) == nil))
        if element.attr.tips then
            ui.TextField_8:setString(element.attr.tips)
        end
        if element.attr.tipsx then
            ui.TextField_9:setString(element.attr.tipsx)
        end
        if element.attr.tipsy then
            ui.TextField_10:setString(element.attr.tipsy)
        end
        if element.attr.show then
            ui.TextField_11:setString(element.attr.show)
        end
    end

    -- Button
    local function modify_Button(submit_callback, cancel_callback)
        local root = CreateExport("sui_editor/creator_Button.lua")
        self:addChild(root)
        local ui = ui_delegate(root)

        CreateEditBoxByTextField(ui.Panel_3:getChildByName("TextField_nimg"))
        CreateEditBoxByTextField(ui.Panel_4:getChildByName("TextField_pimg"))
        CreateEditBoxByTextField(ui.Panel_5:getChildByName("TextField_text"))
        CreateEditBoxByTextField(ui.Panel_8:getChildByName("TextField_8"))
        CreateEditBoxByTextField(ui.Panel_9:getChildByName("TextField_9"))

        ui.TextField_color:setCursorEnabled(true)
        ui.TextField_fontsize:setCursorEnabled(true)
        ui.TextField_10:setCursorEnabled(true)
        ui.TextField_11:setCursorEnabled(true)

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            ui.nativeUI:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_nimg:getString()) == 0 then
                ui.nativeUI:removeFromParent()
                return nil
            end

            element.attr.text   = ui.TextField_text:getString()
            element.attr.size   = tonumber(ui.TextField_fontsize:getString())
            element.attr.color  = ui.TextField_color:getString()
            element.attr.nimg   = ui.TextField_nimg:getString()
            element.attr.pimg   = ui.TextField_pimg:getString()
            element.attr.mimg   = ui.TextField_8:getString()
            element.attr.tips   = ui.TextField_9:getString()
            element.attr.tipsx  = ui.TextField_10:getString()
            element.attr.tipsy  = ui.TextField_11:getString()


            submit_callback(swidget)

            -- 
            ui.nativeUI:removeFromParent()
        end)

        ui.Button_N_Res:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_nimg)
        end)

        ui.Button_P_Res:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_pimg)
        end)

        ui.Button_T_Res:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_8)
        end)

        -- 
        if element.attr.text then
            ui.TextField_text:setString(element.attr.text)
        end
        if element.attr.color then
            ui.TextField_color:setString(element.attr.color)
        end
        if element.attr.size then
            ui.TextField_fontsize:setString(element.attr.size)
        end
        if element.attr.nimg then
            ui.TextField_nimg:setString(element.attr.nimg)
        end
        if element.attr.pimg then
            ui.TextField_pimg:setString(element.attr.pimg)
        end
        if element.attr.mimg then
            ui.TextField_8:setString(element.attr.mimg)
        end
        if element.attr.tips then
            ui.TextField_9:setString(element.attr.tips)
        end
        if element.attr.tipsx then
            ui.TextField_10:setString(element.attr.tipsx)
        end
        if element.attr.tipsy then
            ui.TextField_11:setString(element.attr.tipsy)
        end
    end

    -- Layout
    local function modify_Layout(submit_callback, cancel_callback)
        local root = CreateExport("sui_editor/creator_Layout.lua")
        self:addChild(root)
        local ui = ui_delegate(root)

        ui.TextField_color:setCursorEnabled(true)

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            cancel_callback()
            ui.nativeUI:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            element.attr.color  = ui.TextField_color:getString()

            submit_callback(swidget)

            -- 
            ui.nativeUI:removeFromParent()
        end)

        -- 
        if element.attr.color then
            ui.TextField_color:setString(element.attr.color)
        end
    end

    -- Effect
    local function modify_Effect(submit_callback, cancel_callback)
        local root = CreateExport("sui_editor/creator_Effect.lua")
        self:addChild(root)
        local ui = ui_delegate(root)

        ui.TextField_3:setCursorEnabled(true)
        ui.TextField_4:setCursorEnabled(true)
        ui.TextField_5:setCursorEnabled(true)
        ui.TextField_6:setCursorEnabled(true)
        ui.TextField_7:setCursorEnabled(true)
        ui.TextField_8:setCursorEnabled(true)

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            cancel_callback()
            ui.nativeUI:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            element.attr.effectid   = tonumber(ui.TextField_3:getString()) or 1
            element.attr.effecttype = tonumber(ui.TextField_4:getString()) or 0
            element.attr.act        = tonumber(ui.TextField_5:getString()) or 0
            element.attr.dir        = tonumber(ui.TextField_6:getString()) or 0
            element.attr.speed      = tonumber(ui.TextField_7:getString()) or 1
            element.attr.scale      = tonumber(ui.TextField_8:getString()) or 1

            submit_callback(swidget)

            -- 
            ui.nativeUI:removeFromParent()
        end)

        -- 
        ui.TextField_3:setString(element.attr.effectid or 1)
        ui.TextField_4:setString(element.attr.effecttype or 0)
        ui.TextField_5:setString(element.attr.act or 0)
        ui.TextField_6:setString(element.attr.dir or 5)
        ui.TextField_7:setString(element.attr.speed or 1)
        ui.TextField_8:setString(element.attr.scale or 1)
    end

    -- Frames
    local function modify_Frames(submit_callback, cancel_callback)
        local root = CreateExport("sui_editor/creator_Frames.lua")
        self:addChild(root)
        local ui = ui_delegate(root)

        CreateEditBoxByTextField(ui.Panel_c1:getChildByName("TextField_1"))
        CreateEditBoxByTextField(ui.Panel_c2:getChildByName("TextField_2"))

        ui.TextField_3:setCursorEnabled(true)
        ui.TextField_4:setCursorEnabled(true)
        ui.TextField_5:setCursorEnabled(true)

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            ui.nativeUI:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            element.attr.prefix         = ui.TextField_1:getString()
            element.attr.suffix         = ui.TextField_2:getString()
            element.attr.count          = ui.TextField_3:getString()
            element.attr.speed          = ui.TextField_4:getString()
            element.attr.loop           = ui.TextField_5:getString()

            submit_callback(swidget)

            -- 
            ui.nativeUI:removeFromParent()
        end)

        -- 
        ui.TextField_1:setString(element.attr.prefix or "")
        ui.TextField_2:setString(element.attr.suffix or "")
        ui.TextField_3:setString(element.attr.count or "")
        ui.TextField_4:setString(element.attr.speed or "")
        ui.TextField_5:setString(element.attr.loop or "")
    end

    -- Input
    local function modify_Input(submit_callback, cancel_callback)
        local root = CreateExport("sui_editor/creator_Input.lua")
        self:addChild(root)
        local ui = ui_delegate(root)

        ui.TextField_1:setCursorEnabled(true)
        ui.TextField_2:setCursorEnabled(true)
        ui.TextField_3:setCursorEnabled(true)
        ui.TextField_4:setCursorEnabled(true)
        ui.TextField_5:setCursorEnabled(true)
        ui.TextField_6:setCursorEnabled(true)
        ui.TextField_7:setCursorEnabled(true)
        ui.TextField_8:setCursorEnabled(true)
        ui.TextField_9:setCursorEnabled(true)
        ui.TextField_10:setCursorEnabled(true)
        ui.TextField_11:setCursorEnabled(true)

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            cancel_callback()
            ui.nativeUI:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            element.attr.inputid    = ui.TextField_1:getString()
            element.attr.type       = tonumber(ui.TextField_2:getString())
            element.attr.place      = inputTextAble(ui.TextField_3) and ui.TextField_3:getString() or nil
            element.attr.placecolor = inputTextAble(ui.TextField_4) and tonumber(ui.TextField_4:getString()) or nil
            element.attr.width      = tonumber(ui.TextField_5:getString()) or 50
            element.attr.height     = tonumber(ui.TextField_6:getString()) or 20
            element.attr.color      = tonumber(ui.TextField_7:getString()) or 255
            element.attr.size       = tonumber(ui.TextField_8:getString()) or 18
            element.attr.mincount   = inputTextAble(ui.TextField_9) and tonumber(ui.TextField_9:getString()) or nil
            element.attr.maxcount   = inputTextAble(ui.TextField_10) and tonumber(ui.TextField_10:getString()) or nil
            element.attr.errortips  = inputTextAble(ui.TextField_11) and ui.TextField_11:getString() or nil

            submit_callback(swidget)

            -- 
            ui.nativeUI:removeFromParent()
        end)

        -- 
        ui.TextField_1:setString(element.attr.inputid)
        ui.TextField_2:setString(element.attr.type or 0)
        ui.TextField_3:setString(element.attr.place or "")
        ui.TextField_4:setString(element.attr.placecolor or "")
        ui.TextField_5:setString(element.attr.width or 50)
        ui.TextField_6:setString(element.attr.height or 20)
        ui.TextField_7:setString(element.attr.color or 255)
        ui.TextField_8:setString(element.attr.size or 18)
        ui.TextField_9:setString(element.attr.mincount or "")
        ui.TextField_10:setString(element.attr.maxcount or "")
        ui.TextField_11:setString(element.attr.errortips or "")
    end

    -- CheckBox
    local function modify_CheckBox(submit_callback, cancel_callback)
        local root = CreateExport("sui_editor/creator_CheckBox.lua")
        self:addChild(root)
        local ui = ui_delegate(root)

        CreateEditBoxByTextField(ui.Panel_c1:getChildByName("TextField_nimg"))
        CreateEditBoxByTextField(ui.Panel_c2:getChildByName("TextField_pimg"))

        ui.TextField_default:setCursorEnabled(true)
        ui.TextField_4:setCursorEnabled(true)

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            ui.nativeUI:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_nimg:getString()) == 0 then
                ui.nativeUI:removeFromParent()
                return nil
            end

            element.attr.nimg       = ui.TextField_nimg:getString()
            element.attr.pimg       = ui.TextField_pimg:getString()
            element.attr.default    = tonumber(ui.TextField_default:getString())
            element.attr.checkboxid = ui.TextField_4:getString()

            submit_callback(swidget)

            -- 
            ui.nativeUI:removeFromParent()
        end)

        ui.Button_N_Res:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_nimg)
        end)

        ui.Button_P_Res:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_pimg)
        end)

        -- 
        ui.TextField_nimg:setString(element.attr.nimg)
        ui.TextField_pimg:setString(element.attr.pimg)
        ui.TextField_default:setString(element.attr.default or "")
        ui.TextField_4:setString(element.attr.checkboxid)
    end

    -- ListView
    local function modify_ListView(submit_callback, cancel_callback)
        local root = CreateExport("sui_editor/creator_ListView.lua")
        self:addChild(root)
        local ui = ui_delegate(root)

        ui.TextField_color:setCursorEnabled(true)
        ui.TextField_dir:setCursorEnabled(true)
        ui.TextField_margin:setCursorEnabled(true)

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            cancel_callback()
            ui.nativeUI:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            element.attr.color  = ui.TextField_color:getString()
            element.attr.direction = tonumber(ui.TextField_dir:getString()) or 1
            element.attr.margin = tonumber(ui.TextField_margin:getString()) or 0

            submit_callback(swidget)

            -- 
            ui.nativeUI:removeFromParent()
        end)

        -- 
        if element.attr.color then
            ui.TextField_color:setString(element.attr.color)
        end
        ui.TextField_dir:setString(element.attr.direction or 1)
        ui.TextField_margin:setString(element.attr.margin or 0)
    end

    -- ITEMBOX
    local function modify_ITEMBOX(submit_callback, cancel_callback)
        local root = CreateExport("sui_editor/creator_ITEMBOX.lua")
        self:addChild(root)
        local ui = ui_delegate(root)

        CreateEditBoxByTextField(ui.Panel_c1:getChildByName("TextField_1"))

        ui.TextField_2:setCursorEnabled(true)
        ui.TextField_3:setCursorEnabled(true)
        ui.TextField_4:setCursorEnabled(true)
        ui.TextField_5:setCursorEnabled(true)
        ui.TextField_6:setCursorEnabled(true)

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            cancel_callback()
            ui.nativeUI:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_1:getString()) == 0 then
                ui.nativeUI:removeFromParent()
                return nil
            end
            if string.len(ui.TextField_2:getString()) == 0 then
                ui.nativeUI:removeFromParent()
                return nil
            end


            element.attr.img        = ui.TextField_1:getString()
            element.attr.boxindex   = ui.TextField_2:getString()
            element.attr.stdmode    = ui.TextField_3:getString()
            element.attr.tips       = ui.TextField_4:getString()
            element.attr.tipsx      = ui.TextField_5:getString()
            element.attr.tipsy      = ui.TextField_6:getString()

            submit_callback(swidget)

            -- 
            ui.nativeUI:removeFromParent()
        end)

        ui.Button_N_Res:addClickEventListener(function()
            self:onOpenResSelector(ui.TextField_1)
        end)

        -- 
        if element.attr.img then
            ui.TextField_1:setString(element.attr.img)
        end
        if element.attr.boxindex then
            ui.TextField_2:setString(element.attr.boxindex)
        end
        if element.attr.stdmode then
            ui.TextField_3:setString(element.attr.stdmode)
        end
        if element.attr.tips then
            ui.TextField_4:setString(element.attr.tips)
        end
        if element.attr.tipsx then
            ui.TextField_5:setString(element.attr.tipsx)
        end
        if element.attr.tipsy then
            ui.TextField_6:setString(element.attr.tipsy)
        end
    end

    -- ItemShow
    local function modify_ItemShow(submit_callback, cancel_callback)
        local root = CreateExport("sui_editor/creator_ItemShow.lua")
        self:addChild(root)
        local ui = ui_delegate(root)

        ui.TextField_1:setCursorEnabled(true)
        ui.TextField_2:setCursorEnabled(true)
        ui.TextField_4:setCursorEnabled(true)

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            cancel_callback()
            ui.nativeUI:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_1:getString()) == 0 then
                ui.nativeUI:removeFromParent()
                return nil
            end


            element.attr.itemid     = ui.TextField_1:getString()
            element.attr.itemcount  = ui.TextField_2:getString()
            element.attr.showtips   = ui.CheckBox_3:isSelected() and 1 or 0
            element.attr.bgtype     = ui.TextField_4:getString()

            submit_callback(swidget)

            -- 
            ui.nativeUI:removeFromParent()
        end)

        -- 
        if element.attr.itemid then
            ui.TextField_1:setString(element.attr.itemid)
        end
        if element.attr.itemcount then
            ui.TextField_2:setString(element.attr.itemcount)
        end
        if element.attr.showtips then
            ui.CheckBox_3:setSelected(tonumber(element.attr.showtips) == 1)
        end
        if element.attr.bgtype then
            ui.TextField_4:setString(element.attr.bgtype)
        end
    end

    -- EquipShow
    local function modify_EquipShow(submit_callback, cancel_callback)
        local root = CreateExport("sui_editor/creator_EquipShow.lua")
        self:addChild(root)
        local ui = ui_delegate(root)

        ui.TextField_1:setCursorEnabled(true)
        ui.TextField_4:setCursorEnabled(true)

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            cancel_callback()
            ui.nativeUI:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            if string.len(ui.TextField_1:getString()) == 0 then
                ui.nativeUI:removeFromParent()
                return nil
            end


            element.attr.index      = ui.TextField_1:getString()
            element.attr.showtips   = ui.CheckBox_3:isSelected() and 1 or 0
            element.attr.bgtype     = ui.TextField_4:getString()

            submit_callback(swidget)

            -- 
            ui.nativeUI:removeFromParent()
        end)

        -- 
        if element.attr.index then
            ui.TextField_1:setString(element.attr.index)
        end
        if element.attr.showtips then
            ui.CheckBox_3:setSelected(tonumber(element.attr.showtips) == 1)
        end
        if element.attr.bgtype then
            ui.TextField_4:setString(element.attr.bgtype)
        end
    end

    -- PageView
    local function modify_PageView(submit_callback, cancel_callback)
        local root = CreateExport("sui_editor/creator_Layout.lua")
        self:addChild(root)
        local ui = ui_delegate(root)

        ui.TextField_color:setCursorEnabled(true)

        -- cancel
        ui.Button_cancel:addClickEventListener(function()
            cancel_callback()
            ui.nativeUI:removeFromParent()
        end)

        -- submit
        ui.Button_submit:addClickEventListener(function()
            element.attr.color  = ui.TextField_color:getString()

            submit_callback(swidget)

            -- 
            ui.nativeUI:removeFromParent()
        end)

        -- 
        if element.attr.color then
            ui.TextField_color:setString(element.attr.color)
        end
    end
    ------------------------------------------------------------------
    ------------------------------------------------------------------

    -- submit
    local function submit_callback(swidget, newrender)
        -- clear select
        self:unselect_swidget_busy(swidget)

        local newrender = SUILoader:load_render(swidget)
        swidget:replaceRender(newrender)

        -- draw
        SUILoader.loadSWidgetAttr(swidget)

        -- command
        self:add_swidget_command(swidget)

        -- select
        self:select_swidget_busy(swidget, self._isPressedCtrl)
    end

    -- cancel
    local function cancel_callback()
    end


    -- 
    if etype == "Text" then
        modify_Text(submit_callback, cancel_callback)
    
    elseif etype == "RText" then
        modify_RText(submit_callback, cancel_callback)
        
    elseif etype == "Img" then
        modify_Img(submit_callback, cancel_callback)
        
    elseif etype == "Button" then
        modify_Button(submit_callback, cancel_callback)
        
    elseif etype == "Layout" then
        modify_Layout(submit_callback, cancel_callback)
        
    elseif etype == "Effect" then
        modify_Effect(submit_callback, cancel_callback)
        
    elseif etype == "Frames" then
        modify_Frames(submit_callback, cancel_callback)
        
    elseif etype == "Input" then
        modify_Input(submit_callback, cancel_callback)
        
    elseif etype == "CheckBox" then
        modify_CheckBox(submit_callback, cancel_callback)

    elseif etype == "ListView" then
        modify_ListView(submit_callback, cancel_callback)

    elseif etype == "ITEMBOX" then
        modify_ITEMBOX(submit_callback, cancel_callback)

    elseif etype == "ItemShow" then
        modify_ItemShow(submit_callback, cancel_callback)

    elseif etype == "EquipShow" then
        modify_EquipShow(submit_callback, cancel_callback)

    elseif etype == "PageView" then
        modify_PageView(submit_callback, cancel_callback)
    end
end

function SUIEditor:onOpenResSelector(widget)
    local originRes = ""
    if widget.getString then
        local str = widget:getString()
        if str and string.len(str) > 0 then
            originRes = string.format("res/%s", str)
        end
    end
    local function callFunc(res)
        local data = string.split(res, "res/")
        if data and data[2] then
            widget:setString(data[2])
        end
    end
    
    global.Facade:sendNotification(global.NoticeTable.Layer_GUIResSelector_Open, {res = originRes, callfunc = callFunc})
end

function SUIEditor:init_tree_nodes()
    local index = 0
    self._quickUI.Button_tree:addClickEventListener(function()
        index = 1 - index
        
        self._quickUI.Panel_tree:stopAllActions()
        if index == 0 then
            self._quickUI.Panel_tree:runAction(cc.MoveTo:create(0.2, cc.p(0,0)))
        else
            self._quickUI.Panel_tree:runAction(cc.MoveTo:create(0.2, cc.p(200,0)))
        end
    end)
end

function SUIEditor:update_tree_nodes()
    self._quickUI.ListView_tree:removeAllItems()
    self._tree_nodes = {}

    local function foreach(swidgets)
        if #swidgets == 0 then
            return
        end

        -- 
        for _, swidget in ipairs(swidgets) do
            local tree_node = self:create_tree_node(swidget)
            self._quickUI.ListView_tree:pushBackCustomItem(tree_node.nativeUI)
            self._tree_nodes[swidget] = tree_node

            -- 
            foreach(swidget.branches)
        end
    end
    foreach({self._trunk_root})
end

function SUIEditor:create_tree_node(swidget)
    local root   = CreateExport("sui_editor/tree_node.lua")
    local layout = root:getChildByName("Panel_1")
    layout:removeFromParent()
    local ui     = ui_delegate(layout)

    ui.Text_1:setString(swidget.element.type)
    ui.Text_1:setPositionX(swidget.depth * 10)

    -- 
    ui.Panel_2:setOpacity(0)
    if swidget.trunk then
        local tree_node_tmp = nil
        local clickCount    = 0
        ui.nativeUI:addTouchEventListener(function(sender, eventType)
            if eventType == 0 then
                ui.Panel_2:setOpacity(255)
                self:select_swidget_busy(swidget, self._isPressedCtrl)
    
                -- 
                clickCount = clickCount+1
                layout:stopAllActions()
                performWithDelay(layout, function()
                    clickCount = 0
                end, 0.5)
    
            elseif eventType == 1 then
                local beganPos  = sender:getTouchBeganPosition()
                local movePos   = sender:getTouchMovePosition()
                
                if nil == tree_node_tmp and math.abs(movePos.y - beganPos.y) >= 10 then
                    local tmp_root  = CreateExport("sui_editor/tree_node.lua")
                    local layout    = tmp_root:getChildByName("Panel_1")
                    layout:removeFromParent()
                    self._quickUI.Panel_tree:addChild(layout)
                    tree_node_tmp   = ui_delegate(layout)
                    tree_node_tmp.Text_1:setString(swidget.element.type)
                    tree_node_tmp.Text_1:setPositionX(swidget.depth * 10)
                end
                if tree_node_tmp then
                    local nodePos   = self._quickUI.Panel_tree:convertToNodeSpace(movePos)
                    tree_node_tmp.nativeUI:setPosition(nodePos)
                end
    
                for k, v in pairs(self._tree_nodes) do
                    if k ~= swidget then
                        v.Panel_2:setOpacity(0)
                    end
                end
                for k, v in pairs(self._tree_nodes) do
                    if k ~= swidget and k ~= swidget.trunk then
                        if containsPoint(v.nativeUI, movePos) then
                            v.Panel_2:setOpacity(255)
                            break
                        end
                    end
                end
    
            elseif eventType == 2 then
                for k, v in pairs(self._tree_nodes) do
                    v.Panel_2:setOpacity(0)
                end
                if tree_node_tmp then
                    tree_node_tmp.nativeUI:removeFromParent()
                    tree_node_tmp = nil
                end

                -- 双击了
                if clickCount == 2 then
                    clickCount = 0

                end
    
            elseif eventType == 3 then
                for k, v in pairs(self._tree_nodes) do
                    v.Panel_2:setOpacity(0)
                end
                if tree_node_tmp then
                    tree_node_tmp.nativeUI:removeFromParent()
                    tree_node_tmp = nil
    
                    local parent    = nil
                    local endPos    = sender:getTouchEndPosition()
                    for k, v in pairs(self._tree_nodes) do
                        if k ~= swidget and k ~= swidget.trunk then
                            if containsPoint(v.nativeUI, endPos)  then
                                parent = k
                                break
                            end
                        end
                    end
                    if parent then
                        if nil == swidget.element.attr.id or "" == swidget.element.attr.id or sfind(swidget.element.attr.id, "default_") then
                            ShowSystemTips("请先设置组件ID")
                            return nil
                        end
    
                        swidget.trunk:removeBranch(swidget)
                        parent:addBranch(swidget)
                        parent:addBranchRender(swidget)
                        self:update_tree_nodes()
                        self:update_attr()
                        SUILoader.loadSWidgetAttr(swidget)
                    end
                end
            end
        end)
    else
        -- 全选
        ui.nativeUI:addTouchEventListener(function()
            local function foreach(swidgets)
                if #swidgets == 0 then
                    return
                end
        
                -- 
                for _, swidget in ipairs(swidgets) do
                    self:select_swidget_busy(swidget, true)
        
                    -- 
                    foreach(swidget.branches)
                end
            end
            foreach(self._trunk_root.branches)
        end)
    end

    return ui
end

function SUIEditor:RushEditText()
    local source = self:calcOutput()
    self._quickUI.TextField_edit:setString(source)
end

function SUIEditor:LoadEditSui()
    local edit = self._quickUI.TextField_edit:getString()
    if string.len(edit) == 0 then
        return nil
    end
    self:loadSUI(edit)
end

function SUIEditor:setWidgetZOrder(moveType)
    local index = -1
    for k,swidget in pairs(self._swidgetBUSYs) do
        index = swidget.index
        break
    end
    if moveType == true and index < #self._trunk_root.branches then
        self._trunk_root.branches[index] , self._trunk_root.branches[index + 1] = self._trunk_root.branches[index + 1] , self._trunk_root.branches[index]
        index = index + 1
    elseif moveType == false and index > 1 then
        self._trunk_root.branches[index] , self._trunk_root.branches[index - 1] = self._trunk_root.branches[index - 1] , self._trunk_root.branches[index]
        index = index - 1
    end
    self:RushEditText()
    self:LoadEditSui()
    self:select_swidget_busy(self._trunk_root.branches[index])
end

function SUIEditor:AddPanelBackgroundEvent()
    self._drawNode = cc.DrawNode:create(2)
    self:addChild(self._drawNode)
    local beginPos
    self._quickUI.Panel_background:addTouchEventListener(function(_, eventType)
        if eventType == 0 then
            if false == self._isPressedCtrl then
                self:unselect_swidget_busy()
            end
            beginPos = self._quickUI.Panel_background:getTouchBeganPosition()
        elseif eventType == 1 then
            local movePos = self._quickUI.Panel_background:getTouchMovePosition()
            self._drawNode:clear()
            self._drawNode:drawRect(beginPos, movePos, LineColor)
        elseif eventType == 2 or eventType == 3 then
            self._drawNode:clear()
            local endPos = self._quickUI.Panel_background:getTouchEndPosition()
            local cpos1 = cc.p(beginPos.x, 640 - beginPos.y)
            local cpos2 = cc.p(endPos.x, 640 - endPos.y)
            local minX = cpos1.x
            local maxX = cpos2.x
            if cpos1.x > cpos2.x then
                minX = cpos2.x
                maxX = cpos1.x
            end
            local minY = cpos1.y
            local maxY = cpos2.y
            if cpos1.y > cpos2.y then
                minY = cpos2.y
                maxY = cpos1.y
            end

            for _, swidget in pairs(self._trunk_root.branches) do
                local render = swidget.render
                local wPosX, wPosY = render:getPosition()
                local parentSize = render:getParent():getContentSize()
                wPosY = parentSize.height - wPosY
                if wPosX and wPosY and wPosX > minX and wPosX < maxX and wPosY > minY and wPosY < maxY then
                    self:select_swidget_busy(swidget, true)
                end
            end
        end
    end)
end

function SUIEditor:SetWidthHor()
    local sortWidthTab = {}
    local minX = 99999
    local maxX = 0
    for k, swidget in pairs(self._swidgetBUSYs) do
        table.insert(sortWidthTab, swidget)
        local sx = tonumber(swidget.element.attr.x)
        if sx < minX then minX = sx end
        if sx > maxX then maxX = sx end
    end
    table.sort(sortWidthTab, function(a, b)
        local ax = tonumber(a.element.attr.x)
        local bx = tonumber(b.element.attr.x)
        return ax < bx
    end)
    local intervalX = math.floor((maxX - minX) / (#sortWidthTab - 1))
    for k, swidget in pairs(sortWidthTab) do
        local element = swidget.element
        element.attr.x = minX + intervalX * (k - 1)
    end
    self:RushEditText()
    self:LoadEditSui()
end

function SUIEditor:SetWidthVer()
    local sortWidthTab = {}
    local minY = 99999
    local maxY = 0
    for k, swidget in pairs(self._swidgetBUSYs) do
        table.insert(sortWidthTab, swidget)
        local sy = tonumber(swidget.element.attr.y)
        if sy < minY then minY = sy end
        if sy > maxY then maxY = sy end
    end
    table.sort(sortWidthTab, function(a, b)
        local ay = tonumber(a.element.attr.y)
        local by = tonumber(b.element.attr.y)
        return ay < by
    end)
    local intervalY = math.floor((maxY - minY) / (#sortWidthTab - 1))
    for k, swidget in pairs(sortWidthTab) do
        local element = swidget.element
        element.attr.y = minY + intervalY * (k -1)
    end
    self:RushEditText()
    self:LoadEditSui()
end

function SUIEditor:SetAlignLeft()
    local minX 
    for _, swidget in pairs(self._swidgetBUSYs) do
        local sX = tonumber(swidget.element.attr.x) or 0
        if not minX then
            minX = sX
        end
        if sX < minX then minX = sX end
    end

    for _, swidget in pairs(self._swidgetBUSYs) do
        swidget.element.attr.ax = 0
        swidget.element.attr.x = minX
    end

    self:RushEditText()
    self:LoadEditSui()
end

function SUIEditor:SetAlignTop()
    local topY 
    for _, swidget in pairs(self._swidgetBUSYs) do
        local sY = tonumber(swidget.element.attr.y) or 0
        if not topY then
            topY = sY
        end
        if sY < topY then topY = sY end
    end

    for _, swidget in pairs(self._swidgetBUSYs) do
        swidget.element.attr.ay = 1
        swidget.element.attr.y = topY
    end

    self:RushEditText()
    self:LoadEditSui()
end

return SUIEditor
