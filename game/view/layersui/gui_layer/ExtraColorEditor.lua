local BaseLayer = requireLayerUI("BaseLayer")
local ExtraColorEditor = class("ExtraColorEditor", BaseLayer)
local QuickCell = requireUtil("QuickCell")

local strim     = string.trim
local slen      = string.len
local RowNum    = 11
local exRowNum  = 4

function ExtraColorEditor:ctor()
    ExtraColorEditor.super.ctor(self)

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_ESCAPE, function ()
        self:onKeyEsc()
        return true
    end, nil, 0)

    self._selUIControl = {}

    self._Attr = {
        ["TextField_C"]  = {IMode = 6, t = 1, SetWidget = handler(self, self.SetColorC), SetUIWidget = handler(self, self.SetUIColorC)},
        ["TextField_R"]  = {IMode = 2, t = 1, SetWidget = handler(self, self.SetColorR), SetUIWidget = handler(self, self.SetUIColorR)},
        ["TextField_G"]  = {IMode = 2, t = 1, SetWidget = handler(self, self.SetColorG), SetUIWidget = handler(self, self.SetUIColorG)},
        ["TextField_B"]  = {IMode = 2, t = 1, SetWidget = handler(self, self.SetColorB), SetUIWidget = handler(self, self.SetUIColorB)},
        ["TextField_id"] = {IMode = 2, t = 4, SetWidget = handler(self, self.SetColorID), SetUIWidget = handler(self, self.SetUIColorID)},
        ["preview"]      = {t = 2, SetUIWidget = handler(self, self.SetUIPreview)},
        ["Slider_R"]     = {t = 3, SetUIWidget = handler(self, self.SetUISliderR), func = handler(self, self.onSliderREvent)},
        ["Slider_G"]     = {t = 3, SetUIWidget = handler(self, self.SetUISliderG), func = handler(self, self.onSliderGEvent)},
        ["Slider_B"]     = {t = 3, SetUIWidget = handler(self, self.SetUISliderB), func = handler(self, self.onSliderBEvent)},
    }

    self._selectItem = nil
end

function ExtraColorEditor.create(data)
    local layer = ExtraColorEditor.new()
    if layer:init(data) then
        return layer
    end
    return false
end

function ExtraColorEditor:init(data)
    local root = CreateExport("gui_editor/extra_color_editor.lua")
    if not root then
        return false
    end
    self:addChild(root)

    self._quickUI = ui_delegate(root)

    self._quickUI.Panel_Touch:setVisible(false)
    GUI:Timeline_Window1(self, function()
        self._quickUI.Panel_Touch:setVisible(true)
    end)

    self._quickUI.Panel_1:setVisible(true)

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
function ExtraColorEditor:adaptUI()
    local visible = global.Director:getVisibleSize()
    local ww = visible.width
    local hh = visible.height
    self:setPosition(cc.size(ww/2, hh/2))

    local pSizeW = self._quickUI.Panel_m:getContentSize().width
    local offX = (ww - pSizeW) / 2 
    self._quickUI.Panel_1:setPositionX(pSizeW + offX)
end

function ExtraColorEditor:InitUI()
    self:updateUIControl()

    local proxy = global.Facade:retrieveProxy(global.ProxyTable.ColorStyleProxy)
    self._Colors = proxy:GetOriConfig()
    self:updateListView()

    self._ExColors = {}
    if SL:IsFileExist("scripts/game_config/cfg_extra_color.lua") 
        or SL:IsFileExist("scripts/game_config/cfg_extra_color.luac") then
        self._ExColors = SL:Require("game_config/cfg_extra_color")
        self:UpdateExColorList()
    end
end

-- Slider Bar ---------------------------------------------------
function ExtraColorEditor:getListOffY()
    return self._quickUI.list:getInnerContainerSize().height - self._quickUI.list:getContentSize().height
end

function ExtraColorEditor:updateListPercent(percent)
    self._quickUI.slider:setPercent(percent)
    self._quickUI.list:scrollToPercentVertical(percent, 0.03, false)
end

function ExtraColorEditor:setSliderBar(percent)
    self._quickUI.slider:setPercent(percent)
end

function ExtraColorEditor:onScrollPercent(padding)
    local innY = self._quickUI.list:getInnerContainerPosition().y
    local offY = self:getListOffY()

    local percent = math.min(math.max(0, (offY + innY + padding) / offY * 100), 100)
    self:updateListPercent(percent)
end

function ExtraColorEditor:onSliderEvent()
    local offY = self:getListOffY()
    if offY > 0 then
        self._quickUI.list:scrollToPercentVertical(self._quickUI.slider:getPercent(), 0.03, false)
    else
        self._quickUI.slider:setPercent(100)
    end
end

function ExtraColorEditor:onScrollEvent()
    local posY = self._quickUI.list:getInnerContainerPosition().y
    local offY = self:getListOffY()
    local percent = 100
    if offY > 0 then
        percent = math.min(math.max(0, (offY + posY) / offY * 100), 100)
    end
    self._quickUI.slider:setPercent(percent)
end

function ExtraColorEditor:InitEvent()
    self._quickUI.Button_1:addClickEventListener(function()
        self:onScrollPercent(-30)
    end)
    self._quickUI.Button_2:addClickEventListener(function()
        self:onScrollPercent(30)
    end)
    self._quickUI.Button_11:addClickEventListener(function()
        self:onExScrollPercent(-30)
    end)
    self._quickUI.Button_22:addClickEventListener(function()
        self:onExScrollPercent(30)
    end)
    self._quickUI.slider:addEventListener(handler(self, self.onSliderEvent))
    self._quickUI.list:addEventListener(handler(self, self.onScrollEvent))
    self._quickUI.list:addMouseScrollPercent(handler(self, self.setSliderBar))
    self._quickUI.slider_1:addEventListener(handler(self, self.onExSliderEvent))
    self._quickUI.List_color:addEventListener(handler(self, self.onExScrollEvent))
    self._quickUI.List_color:addMouseScrollPercent(handler(self, self.setExSliderBar))
    self._quickUI.btnClose:addClickEventListener(handler(self, self.onClose))
    self._quickUI.btnCancel:addClickEventListener(handler(self, self.onCancel))
    self._quickUI.btnSure:addClickEventListener(handler(self, self.onSure))

    self._selUIControl = {}
    for name, d in pairs(self._Attr) do
        if name then
            local widget = self._quickUI[name]
            if widget then
                if d.t == 1 or d.t == 4 then
                    local editBox = CreateEditBoxByTextField(widget)
                    editBox:setInputMode(d.IMode)
                    self._selUIControl[name] = editBox
                    self:initTextFieldEvent(editBox, d.t)
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

function ExtraColorEditor:initTextFieldEvent(widget, type)
    if type == 1 then 
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
    elseif type == 4 then -- 颜色ID
        widget:addEventListener(function(ref, eventType)
            local name = ref:getName()
            local ui = self._Attr[name]
            if not ui then
                return false
            end
            local str  = ref:getString()
            local min = 256
            if eventType == 1 then
                str = strim(str)
                str = tonumber(str) or 0
                str = math.max(str, min)
                ref:setString(str)
                self:updateUIAttr(name, str)
            end
        end)
    end
end

function ExtraColorEditor:updateUIAttr(name, value)
    if name and self._Attr[name] and self._Attr[name].SetWidget then
        self._Attr[name].SetWidget(value)
    end
    self:updateUIControl()
end

function ExtraColorEditor:updateUIControl()
    for name, _ in pairs(self._selUIControl) do
        if self._Attr[name] then
            if self._Attr[name].SetUIWidget then
                self._Attr[name].SetUIWidget(self._selUIControl[name])
            end
        end
    end

end

function ExtraColorEditor:setColor()
    self._selUIControl["TextField_C"]:setString(string.upper(GetColorHexFromRBG(self._rgbColor)))
end

function ExtraColorEditor:SetColorC(value)
    self._rgbColor = GetColorFromHexString(value)
end

function ExtraColorEditor:SetUIColorC(widget)
    self:setColor()
end

function ExtraColorEditor:SetColorR(value)
    self._rgbColor.r = value
end

function ExtraColorEditor:SetUIColorR(widget)
    widget:setString(self._rgbColor.r)
end

function ExtraColorEditor:SetColorG(value)
    self._rgbColor.g = value
end

function ExtraColorEditor:SetUIColorG(widget)
    widget:setString(self._rgbColor.g)
end

function ExtraColorEditor:SetColorB(value)
    self._rgbColor.b = value 
end

function ExtraColorEditor:SetUIColorB(widget)
    widget:setString(self._rgbColor.b)
end

function ExtraColorEditor:SetColorID(value)
    self._colorID = value
end

function ExtraColorEditor:SetUIColorID(widget)
    widget:setString(self._colorID or "")
end

function ExtraColorEditor:SetUIPreview(widget)
    widget:setBackGroundColor(self._rgbColor)
end

function ExtraColorEditor:SetUISliderR(widget)
    widget:setPercent(math.floor(self._rgbColor.r / 255 * 100))
end

function ExtraColorEditor:SetUISliderG(widget)
    widget:setPercent(math.floor(self._rgbColor.g / 255 * 100))
end

function ExtraColorEditor:SetUISliderB(widget)
    widget:setPercent(math.floor(self._rgbColor.b / 255 * 100))
end

function ExtraColorEditor:onSliderREvent(widget)
    local precent = widget:getPercent()
    local r = math.floor(precent / 100 * 255)
    self._rgbColor.r = r

    self._selUIControl["TextField_R"]:setString(r)
    self:updateUIControl()
end

function ExtraColorEditor:onSliderGEvent(widget)
    local precent = widget:getPercent()
    local g = math.floor(precent / 100 * 255)
    self._rgbColor.g = g

    self._selUIControl["TextField_G"]:setString(g)
    self:updateUIControl()
end

function ExtraColorEditor:onSliderBEvent(widget)
    local precent = widget:getPercent()
    local b = math.floor(precent / 100 * 255)
    self._rgbColor.b = b

    self._selUIControl["TextField_B"]:setString(b)
    self:updateUIControl()
end

-- 加载 Item 到 ListView
function ExtraColorEditor:updateListView()
    local list = self._quickUI.list
    self._quickUI.list:removeAllChildren()

    local function _CreateCell(i)
        local item = self._quickUI.Panel_item:clone()
        item:setTag(i)
        item:setVisible(true)

        local maxI = RowNum * i
        for i = RowNum, 1, -1 do
            local item = item:getChildByName("item" .. (RowNum - i + 1))
            local data = self._Colors[maxI - i + 1]
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
function ExtraColorEditor:refreshItemData(item, data)
    if not (data and next(data)) then
        item:setVisible(false)
        return false
    end
    IterAllChild(item, item)
    item:setVisible(true)
    
    local color = data.colour
    local isSelect = self._color == color and self._colorID == data.id
    item["select"]:setVisible(isSelect)
    if isSelect then
        self._selectItem = item
    end

    local rgbColor = GetColorFromHexString(color)
    item:setBackGroundColor(rgbColor)

    if item["Text_id"] then
        item["Text_id"]:setString(data.id)
    end

    local isEx = self._ExColors and self._ExColors[data.id]

    -- 
    item:addTouchEventListener(function(_, eventType)
        if eventType == 2 then
            self._color = color
            self._rgbColor = rgbColor
            self._colorID = data.id

            self:refreshCells(isEx)
            self:updateUIControl()
        end
    end)
end

-- 刷新 ListView
function ExtraColorEditor:refreshCells(isEx)
    if self._selectItem and self._selectItem["select"] then
        self._selectItem["select"]:setVisible(false)
    end
    if not isEx then
        for index, cell in ipairs(self._cells) do
            if cell then
                cell:Exit()
                cell:Refresh()
            end
        end
    else
        for index, cell in ipairs(self._exCells) do
            if cell then
                cell:Exit()
                cell:Refresh()
            end
        end
    end
end

-- 
function ExtraColorEditor:UpdateExColorList()
    local list = self._quickUI.List_color
    self._quickUI.List_color:removeAllChildren()

    local config = {}
    if next(self._ExColors) then
       config = SL:HashToSortArray(self._ExColors, function(a, b)
           return a.id < b.id
       end)
    end

    local function _CreateCell(i)
        local item = self._quickUI.Panel_add_cell:clone()
        item:setTag(i)
        item:setVisible(true)

        local maxI = exRowNum * i
        for i = exRowNum, 1, -1 do
            local item = item:getChildByName("item" .. (exRowNum - i + 1))
            local param = config[maxI - i + 1]
            if param and param.id then 
                local data = self._ExColors[param.id]
                self:refreshItemData(item, data)
            else
                item:setVisible(false)
            end
        end

        return item
    end

    local col = math.ceil(#config / exRowNum)
    self._exCells = {}
    for i = 1, col do
        local quickCell = QuickCell:Create({
            wid = 220,
            hei = 36,
            createCell = function() return _CreateCell(i) end})
        self._exCells[i] = quickCell
        self._quickUI.List_color:pushBackCustomItem(quickCell)
    end

    if self._color then
        local index = 0
        for i, v in ipairs(self._ExColors) do
            if v and v.colour == self._color then
                index = math.ceil(i / exRowNum)
                break
            end
        end
        if index > 0 then
            list:jumpToItem(index, cc.p(0,0), cc.p(0, 0))
            self:onExScrollPercent(0)
        else
            self:updateExListPercent(0)
        end
    else
        self:updateExListPercent(0)
    end
end

-- Ex Slider Bar ---------------------------------------------------
function ExtraColorEditor:getExListOffY()
    return self._quickUI.List_color:getInnerContainerSize().height - self._quickUI.List_color:getContentSize().height
end

function ExtraColorEditor:updateExListPercent(percent)
    self._quickUI.slider_1:setPercent(percent)
    self._quickUI.List_color:scrollToPercentVertical(percent, 0.03, false)
end

function ExtraColorEditor:setExSliderBar(percent)
    self._quickUI.slider_1:setPercent(percent)
end

function ExtraColorEditor:onExScrollPercent(padding)
    local innY = self._quickUI.List_color:getInnerContainerPosition().y
    local offY = self:getExListOffY()

    local percent = math.min(math.max(0, (offY + innY + padding) / offY * 100), 100)
    self:updateExListPercent(percent)
end

function ExtraColorEditor:onExSliderEvent()
    local offY = self:getExListOffY()
    if offY > 0 then
        self._quickUI.List_color:scrollToPercentVertical(self._quickUI.slider_1:getPercent(), 0.03, false)
    else
        self._quickUI.slider_1:setPercent(100)
    end
end

function ExtraColorEditor:onExScrollEvent()
    local posY = self._quickUI.List_color:getInnerContainerPosition().y
    local offY = self:getListOffY()
    local percent = 100
    if offY > 0 then
        percent = math.min(math.max(0, (offY + posY) / offY * 100), 100)
    end
    self._quickUI.slider_1:setPercent(percent)
end
-----------------------------------------------------------------------

-- 关闭界面
function ExtraColorEditor:onClose()
    global.Facade:sendNotification(global.NoticeTable.Layer_ExtraColorEditor_Close)

    local ColorStyleProxy = global.Facade:retrieveProxy(global.ProxyTable.ColorStyleProxy)
    ColorStyleProxy:LoadConfig()
end

function ExtraColorEditor:onSure()
    if not self._colorID or self._colorID <= 255 then
        return
    end
    if not self._ExColors then
        self._ExColors = {}
    end
    local colorID = self._colorID
    local config = self._ExColors[colorID]
    if not config then
        config = {id = colorID, colour = GetColorHexFromRBG(self._rgbColor)}
        self._ExColors[colorID] = config
    else
        config.colour = GetColorHexFromRBG(self._rgbColor)
    end
    self._color = config.colour

    -- 刷新新增颜色列表
    self:UpdateExColorList()

    self:SaveColorCfg()
end

function ExtraColorEditor:onCancel()
    if not self._colorID or self._colorID <= 255 then
        return
    end
    if not self._ExColors or not next(self._ExColors) then
        return
    end
    local colorID = self._colorID
    if self._ExColors[colorID] then
        self._ExColors[colorID] = nil
    end
    
    -- 刷新新增颜色列表
    self:UpdateExColorList()

    self:SaveColorCfg()
end

function ExtraColorEditor:SaveColorCfg()
    SL:SaveTableToConfig(self._ExColors, "cfg_extra_color", nil, nil, true)
    global.FileUtilCtl:purgeCachedEntries()
end

-- Esc 退出键
function ExtraColorEditor:onKeyEsc()
    self:onClose()
end
---------------------------------------------------------------

return ExtraColorEditor
