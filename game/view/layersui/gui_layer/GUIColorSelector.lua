local BaseLayer = requireLayerUI("BaseLayer")
local GUIColorSelector = class("GUIColorSelector", BaseLayer)
local QuickCell = requireUtil("QuickCell")

local strim     = string.trim
local slen      = string.len
local RowNum    = 11

function GUIColorSelector:ctor()
    GUIColorSelector.super.ctor(self)

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_ESCAPE, function ()
        self:onKeyEsc()
        return true
    end, nil, 0)

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_DELETE, function ()
        return true
    end, nil, 0)

    self._selUIControl = {}

    self._Attr = {
        ["TextField_C"]  = { IMode = 6, t = 1, SetWidget = handler(self, self.SetColorC), SetUIWidget = handler(self, self.SetUIColorC) },
        ["TextField_R"]  = { IMode = 2, t = 1, SetWidget = handler(self, self.SetColorR), SetUIWidget = handler(self, self.SetUIColorR) },
        ["TextField_G"]  = { IMode = 2, t = 1, SetWidget = handler(self, self.SetColorG), SetUIWidget = handler(self, self.SetUIColorG) },
        ["TextField_B"]  = { IMode = 2, t = 1, SetWidget = handler(self, self.SetColorB), SetUIWidget = handler(self, self.SetUIColorB) },
        ["preview"]      = { t = 2, SetUIWidget = handler(self, self.SetUIPreview)},
        ["Slider_R"]     = { t = 3, SetUIWidget = handler(self, self.SetUISliderR), func = handler(self, self.onSliderREvent) },
        ["Slider_G"]     = { t = 3, SetUIWidget = handler(self, self.SetUISliderG), func = handler(self, self.onSliderGEvent) },
        ["Slider_B"]     = { t = 3, SetUIWidget = handler(self, self.SetUISliderB), func = handler(self, self.onSliderBEvent) }
    }
end

function GUIColorSelector.create(data)
    local layer = GUIColorSelector.new()
    if layer:init(data) then
        return layer
    end
    return false
end

function GUIColorSelector:init(data)
    local root = CreateExport("gui_editor/color_selector.lua")
    if not root then
        return false
    end
    self:addChild(root)

    self._quickUI = ui_delegate(root)

    self._quickUI.Panel_Touch:setVisible(false)
    GUI:Timeline_Window1(self, function ()
        self._quickUI.Panel_Touch:setVisible(true)
    end)

    self._Colors = {}

    self:InitEvent()

    self:adaptUI()

    self._color = data and data.color or "#FFFFFF"
    self._rgbColor = GetColorFromHexString(self._color)
    self._callfunc = data and data.callfunc
    self:InitUI()

    return true
end

-- 自适应 UI
function GUIColorSelector:adaptUI()
    local visible = global.Director:getVisibleSize()
    local ww = visible.width
    local hh = visible.height
    self:setPosition(cc.size(ww/2, hh/2))
end

-- Slider Bar ---------------------------------------------------
function GUIColorSelector:getListOffY()
    return self._quickUI.list:getInnerContainerSize().height - self._quickUI.list:getContentSize().height
end

function GUIColorSelector:updateListPercent(percent)
    self._quickUI.slider:setPercent(percent)
    self._quickUI.list:scrollToPercentVertical(percent, 0.03, false)
end

function GUIColorSelector:setSliderBar(percent)
    self._quickUI.slider:setPercent(percent)
end

function GUIColorSelector:onScrollPercent(padding)
    local innY = self._quickUI.list:getInnerContainerPosition().y
    local offY = self:getListOffY()

    local percent = math.min(math.max(0, (offY + innY + padding) / offY * 100), 100)
    self:updateListPercent(percent)
end

function GUIColorSelector:onSliderEvent()
    local offY = self:getListOffY()
    if offY > 0 then
        self._quickUI.list:scrollToPercentVertical(self._quickUI.slider:getPercent(), 0.03, false)
    else
        self._quickUI.slider:setPercent(100)
    end
end

function GUIColorSelector:onScrollEvent()
    local posY = self._quickUI.list:getInnerContainerPosition().y
    local offY = self:getListOffY()
    local percent = 100
    if offY > 0 then
        percent = math.min(math.max(0, (offY + posY) / offY * 100), 100)
    end
    self._quickUI.slider:setPercent(percent)
end

function GUIColorSelector:InitEvent()
    self._quickUI.Button_1:addClickEventListener(function () self:onScrollPercent(-30) end)
    self._quickUI.Button_2:addClickEventListener(function () self:onScrollPercent(30)  end)
    self._quickUI.slider:addEventListener(handler(self, self.onSliderEvent))
    self._quickUI.list:addEventListener(handler(self, self.onScrollEvent))
    self._quickUI.list:addMouseScrollPercent(handler(self, self.setSliderBar))
    self._quickUI.btnClose:addClickEventListener(handler(self, self.onClose))
    self._quickUI.btnCancel:addClickEventListener(handler(self, self.onClose))
    self._quickUI.btnSure:addClickEventListener(handler(self, self.onSure))

    self._selUIControl = {}
    for name,d in pairs(self._Attr) do
        if name then
            local widget = self._quickUI[name]
            if widget then
                if d.t == 1 then
                    local editBox = CreateEditBoxByTextField(widget)
                    editBox:setInputMode(d.IMode)
                    self._selUIControl[name] = editBox
                    self:initTextFieldEvent(editBox)
                elseif d.t == 3 then
                    widget:addEventListener(d.func)
                    self._selUIControl[name] = widget
                else
                    self._selUIControl[name] = widget
                end
            end
        end
    end
end

function GUIColorSelector:initTextFieldEvent(widget)
    widget:addEventListener(function(ref, eventType)
        local name = ref:getName()
        local ui = self._Attr[name]
        if not ui then
            return false
        end
        local mode = ui.IMode
        local max  = 255
        local min  = 0
        local str  = ref:getString()

        if eventType == 1 then
            str = strim(str)
            if mode == 2 then
                str = tonumber(str) or 0
                if min and str < min then
                    str = min
                end
                if max then
                    str = math.max(math.min(str, max), 0)
                end
                ref:setString(str)
                self:updateUIAttr(name, str)
            else
                if slen(str or "") < 1 then
                    return false
                end
                ref:setString(str)
                self:updateUIAttr(name, str)
            end
        end
    end)
end

function GUIColorSelector:updateUIAttr(name, value)
    if name and self._Attr[name] and self._Attr[name].SetWidget then
        self._Attr[name].SetWidget(value)
    end
    self:updateUIControl()
end

function GUIColorSelector:updateUIControl()
    for name,_ in pairs(self._selUIControl) do
        if self._Attr[name] then
            if self._Attr[name].SetUIWidget then
                self._Attr[name].SetUIWidget(self._selUIControl[name])
            end
        end
    end
end

function GUIColorSelector:InitUI()
    self:updateUIControl()

    local proxy = global.Facade:retrieveProxy(global.ProxyTable.ColorStyleProxy)
    self._Colors = proxy:GetConfig()
    self:updateListView()
end

function GUIColorSelector:setColor()
    self._selUIControl["TextField_C"]:setString(string.upper(GetColorHexFromRBG(self._rgbColor)))
end

function GUIColorSelector:SetColorC(value)
    self._rgbColor = GetColorFromHexString(value)
end

function GUIColorSelector:SetUIColorC(widget)
    self:setColor()
end

function GUIColorSelector:SetColorR(value)
    self._rgbColor.r = value
end

function GUIColorSelector:SetUIColorR(widget)
    widget:setString(self._rgbColor.r)
end

function GUIColorSelector:SetColorG(value)
    self._rgbColor.g = value
end

function GUIColorSelector:SetUIColorG(widget)
    widget:setString(self._rgbColor.g)
end

function GUIColorSelector:SetColorB(value)
    self._rgbColor.b = value 
end

function GUIColorSelector:SetUIColorB(widget)
    widget:setString(self._rgbColor.b)
end

function GUIColorSelector:SetUIPreview(widget)
    widget:setBackGroundColor(self._rgbColor)
end

function GUIColorSelector:SetUISliderR(widget)
    widget:setPercent(math.floor(self._rgbColor.r / 255 * 100))
end

function GUIColorSelector:SetUISliderG(widget)
    widget:setPercent(math.floor(self._rgbColor.g / 255 * 100))
end

function GUIColorSelector:SetUISliderB(widget)
    widget:setPercent(math.floor(self._rgbColor.b / 255 * 100))
end

function GUIColorSelector:onSliderREvent(widget)
    local precent = widget:getPercent()
    local r = math.floor(precent / 100 * 255)
    self._rgbColor.r = r

    self._selUIControl["TextField_R"]:setString(r)
    self:updateUIControl()
end

function GUIColorSelector:onSliderGEvent(widget)
    local precent = widget:getPercent()
    local g = math.floor(precent / 100 * 255)
    self._rgbColor.g = g

    self._selUIControl["TextField_G"]:setString(g)
    self:updateUIControl()
end

function GUIColorSelector:onSliderBEvent(widget)
    local precent = widget:getPercent()
    local b = math.floor(precent / 100 * 255)
    self._rgbColor.b = b

    self._selUIControl["TextField_B"]:setString(b)
    self:updateUIControl()
end

-- 加载 Item 到 ListView
function GUIColorSelector:updateListView()
    local list = self._quickUI.list
    self._quickUI.list:removeAllChildren()

    local function _CreateCell(i)
        local item = self._quickUI.Panel_item:clone()
        item:setTag(i)
        item:setVisible(true)

        local maxI = RowNum * i
        for i = RowNum, 1, -1 do
            local item = item:getChildByName("item"..(RowNum - i + 1))
            local data = self._Colors[maxI-i+1]
            self:refreshItemData(item, data)
        end

        return item
    end

    local row = math.ceil(#self._Colors / RowNum)
    self._index = 0
    self._cells = {}
    for i = 1, row do
        local quickCell = QuickCell:Create({
            wid = 340,
            hei = 20,
            createCell = function() return _CreateCell(i) end})
        self._cells[i] = quickCell
        self._quickUI.list:addChild(quickCell)
    end

    if self._color then
        local index = 0
        for i, v in ipairs(self._Colors) do
            if v and v.colour == self._color then
                index = math.ceil(i / RowNum)
                break
            end
        end
        if index > 0 then
            list:jumpToItem(index, cc.p(0,0), cc.p(0, 0))
            self:onScrollPercent(0)
        else
            self:updateListPercent(0)
        end
    else
        self:updateListPercent(0)
    end
end

-- 属性列表 Item
function GUIColorSelector:refreshItemData(item, data)
    if not (data and next(data)) then
        item:setVisible(false)
        return false
    end
    IterAllChild(item, item)
    item:setVisible(true)
    
    local color = data.colour
    item["select"]:setVisible(self._color == color)

    local rgbColor = GetColorFromHexString(color)
    item:setBackGroundColor(rgbColor)

    -- 双击事件
    self._clickTime = self._clickTime or 0
    item:addTouchEventListener(function(_, eventType)
        if eventType == 0 then
            performWithDelay(self, function() self._clickTime = 0 end, global.MMO.CLICK_DOUBLE_TIME)
        elseif eventType == 2 then
            self._clickTime = self._clickTime + 1

            self._color = color
            self._rgbColor = rgbColor

            self:refreshCells()
            self:updateUIControl()

            if self._clickTime == 2 then
                self._clickTime = 0
                self:onSure()
            end
        end
    end)
end

-- 刷新 ListView
function GUIColorSelector:refreshCells( )
    for index, cell in ipairs(self._cells) do
        if cell then
            cell:Exit()
            cell:Refresh()
        end
    end
end

-- 关闭界面
function GUIColorSelector:onClose()
    global.Facade:sendNotification(global.NoticeTable.Layer_GUIColorSelector_Close)
end

function GUIColorSelector:onSure()
    if self._callfunc then
        self._callfunc(GetColorHexFromRBG(self._rgbColor))
    end
    self:onClose()
end

-- Esc 退出键
function GUIColorSelector:onKeyEsc()
    self:onClose()
end
---------------------------------------------------------------

return GUIColorSelector
