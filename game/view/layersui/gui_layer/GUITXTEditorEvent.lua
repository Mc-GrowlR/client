local BaseLayer = requireLayerUI("BaseLayer")
local GUITXTEditorEvent = class("GUITXTEditorEvent", BaseLayer)

local sformat = string.format
local strim   = string.trim
local slen    = string.len
local sfind   = string.find

local OperateType = {
    EVENT = 1,
    CONDITION = 2
}

function GUITXTEditorEvent:ctor()
    GUITXTEditorEvent.super.ctor(self)

    self._selWidget    = nil
    self._selItemTag   = nil

    self._Key          = nil
    self._KeyCondition = nil
    self._KeyEvent     = nil

    self._keyData      = {}
    self._showData     = {}
    self._editData     = {}

    self._selUIControl = {}

    self._Attr = {
        ["TextField_Condition"]  = { IMode = 0, t = 1, SetWidget = handler(self, self.SetCondition), SetUIWidget = handler(self, self.SetUICondition) },
        ["TextField_Event1"]     = { IMode = 0, t = 1, SetWidget = handler(self, self.SetEvent1), SetUIWidget = handler(self, self.SetUIEvent1) },
        ["TextField_Event2"]     = { IMode = 0, t = 1, SetWidget = handler(self, self.SetEvent2), SetUIWidget = handler(self, self.SetUIEvent2) },
        ["TextField_Notice"]     = { IMode = 0, t = 1, SetWidget = handler(self, self.SetNotice), SetUIWidget = handler(self, self.SetUINotice) },

        ["btnDel"]      = { t = 2, OnClickEvent = handler(self, self.OnBtnDel) },
        ["btnUp"]       = { t = 2, OnClickEvent = handler(self, self.OnBtnUp) },
        ["btnDown"]     = { t = 2, OnClickEvent = handler(self, self.OnBtnDown) },

        ["btnClose"]    = { t = 2, OnClickEvent = handler(self, self.onClose) },
        ["btnSure"]     = { t = 2, OnClickEvent = handler(self, self.onEditComplete) },
        ["input_bg"]    = { t = 2, OnClickEvent = handler(self, self.onInputBgEvent) },
        ["btnAddEvent"] = { t = 2, OnClickEvent = handler(self, self.onNewEvent) },

        ["item_bg"]     = { t = 2, OnClickEvent = handler(self, self.onItemBgEvent) },
        ["btnAdd"]      = { t = 2, OnClickEvent = handler(self, self.onOpenInputEdit) },

        ["line_BG"]     = { t = 2, OnClickEvent = handler(self, self.onOpenOrClose) },

        ["btnOk"]       = { t = 2, OnClickEvent = handler(self, self.onSave) },
    }

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_DELETE, function ()
        self:onDelete()
        return true
    end, nil, 0)
end

function GUITXTEditorEvent.create(data)
    local layer = GUITXTEditorEvent.new()
    if layer:init(data) then
        return layer
    end
    return false
end

function GUITXTEditorEvent:init(data)
    local root = CreateExport("gui_txt_editor/att_special.lua")
    if not root then
        return false
    end
    self:addChild(root)

    self._quickUI = ui_delegate(root)

    self:InitData(data.conditions)

    self._callback = data.callback or {}

    self:InitUIAttr()

    self:updateUIControl()

    self:refreshActList()

    return true
end

function GUITXTEditorEvent:InitData(data)
    self._keyData = {}
    for i, v in ipairs(data or {}) do
        v.events_show = true
        v.conditions_show = true
        self._keyData[v.triggerName] = v
    end
    self._showData = data
end

function GUITXTEditorEvent:initTextFieldEvent(widget)
    widget:addEventListener(function(ref, eventType)
        local name = ref:getName()
        local ui = self._Attr[name]
        if not ui then
            return false
        end
        
        local str  = ref:getString()
        if eventType == 1 then
            str = strim(str)
            if slen(str or "") < 1 then
                return false
            end
            ref:setString(str)
            self:updateUIAttr(name, str)
        end
    end)
end

function GUITXTEditorEvent:InitUIAttr()
    local function func(widget, data, name)
        (({
            [1] = function()
                local editBox = CreateEditBoxByTextField(widget)
                editBox:setInputMode(data.IMode)
                self._selUIControl[name] = editBox
                self:initTextFieldEvent(editBox)
            end,
            [2] = function ()
                widget:addClickEventListener(data.OnClickEvent)
                self._selUIControl[name] = widget
            end
        })[data.t] or 
        function ()
            self._selUIControl[name] = widget
        end) ()
    end
    
    self._selUIControl = {}
    for name, data in pairs(self._Attr) do
        if name then
            local widget = self._quickUI[name]
            if widget then
                func(widget, data, name)
            end
        end
    end
end

function GUITXTEditorEvent:updateUIAttr(name, value)
    if name and self._Attr[name] and self._Attr[name].SetWidget then
        self._Attr[name].SetWidget(value)
    end
    self:updateUIControl()
end

function GUITXTEditorEvent:updateUIControl(null)
    for name,_ in pairs(self._selUIControl) do
        if self._Attr[name] then
            if self._Attr[name].SetUIWidget then
                self._Attr[name].SetUIWidget(self._selUIControl[name], null)
            end
        end
    end
end

-----------------------------------------------------------------------------
function GUITXTEditorEvent:SetCondition(value)
    self._editData["ID"] = value
end

function GUITXTEditorEvent:SetUICondition(widget, null)
    if null then
        return widget:setString("")
    end

    if not self._KeyCondition then
        return false
    end
    
    if not self._showData[self._Key] or not self._showData[self._Key].conditions or not self._showData[self._Key].conditions[self._KeyCondition] then
        return false
    end

    widget:setString(self._showData[self._Key].conditions[self._KeyCondition].ID)
end

function GUITXTEditorEvent:SetEvent1(value)
    self._editData["Act1"] = value
end

function GUITXTEditorEvent:SetUIEvent1(widget, null)
    if null then
        return widget:setString("")
    end

    if not self._KeyCondition then
        return false
    end
    
    if not self._showData[self._Key] or not self._showData[self._Key].conditions or not self._showData[self._Key].conditions[self._KeyCondition] then
        return false
    end

    widget:setString(self._showData[self._Key].conditions[self._KeyCondition].Act1)
end

function GUITXTEditorEvent:SetEvent2(value)
    self._editData["Act2"] = value
end

function GUITXTEditorEvent:SetUIEvent2(widget, null)
    if null then
        return widget:setString("")
    end

    if not self._KeyCondition then
        return false
    end
    
    if not self._showData[self._Key] or not self._showData[self._Key].conditions or not self._showData[self._Key].conditions[self._KeyCondition] then
        return false
    end

    widget:setString(self._showData[self._Key].conditions[self._KeyCondition].Act2)
end

function GUITXTEditorEvent:SetNotice(value)
    self._editData["EventID"] = value
end

function GUITXTEditorEvent:SetUINotice(widget, null)
    if null then
        return widget:setString("")
    end

    if not self._KeyEvent then
        return false
    end
    
    if not self._showData[self._Key] or not self._showData[self._Key].events or not self._showData[self._Key].events[self._KeyEvent] then
        return false
    end

    widget:setString(self._showData[self._Key].events[self._KeyEvent].EventID)
end

function GUITXTEditorEvent:OnBtnDel()
    local key = self._Key
    if not self._showData[key] then
        return false
    end

    self._keyData[self._showData[key].triggerName] = nil

    table.remove(self._showData, key)

    self:refreshActList()

    self._selWidget = nil

    self._Key = nil
end

function GUITXTEditorEvent:OnBtnUp()
    local key = self._Key
    if not self._showData[key] then
        return false
    end

    local preKey = key - 1
    if not self._showData[preKey] then
        return false
    end

    self._showData[key], self._showData[preKey] = self._showData[preKey], self._showData[key]

    self:refreshActList()
end

function GUITXTEditorEvent:OnBtnDown()
    local key = self._Key
    if not self._showData[key] then
        return false
    end

    local nextKey = key + 1
    if not self._showData[nextKey] then
        return false
    end

    self._showData[key], self._showData[nextKey] = self._showData[nextKey], self._showData[key]

    self:refreshActList()
end

-----------------------------------------------------------------------------

function GUITXTEditorEvent:setSelect()
    local childrens = self._quickUI.ScrollView_1:getChildren()
    for i = 1, #childrens do
        local item = childrens[i]
        if item and item:isVisible() then
            local isSel = item == self._selWidget and true or false
            item:getChildByName("select"):setVisible(isSel)
            GUI:Button_setBrightEx(item:getChildByName("btnDel"), isSel)
            GUI:Button_setBrightEx(item:getChildByName("btnUp"), isSel)
            GUI:Button_setBrightEx(item:getChildByName("btnDown"), isSel)
        end
    end
end

function GUITXTEditorEvent:onInputBgEvent(sender, eventType)
    self._click = self._click or 0

    if self._selWidget ~= sender:getParent() then
        self._click = 0
    end

    if eventType == 0 then
        performWithDelay(sender, function() self._click = 0 end, global.MMO.CLICK_DOUBLE_TIME)
    elseif eventType ~= 1 then
        local widget = sender:getParent()
        self._selWidget = widget
        self._Key = widget:getTag()

        self._click = self._click + 1

        if self._click ~= 2 then
            self:setSelect()
            self:initRightList(true)
            return false
        end

        widget:getChildByName("select"):setVisible(false)

        local input = widget:getChildByName("Input")
        input:touchDownAction(input, 2)

        self._click = 0
        sender:stopAllActions()
    end
end

function GUITXTEditorEvent:setSelect2()
    local childrens = self._quickUI.ScrollView_2:getChildren()
    for i = 1, #childrens do
        local item = childrens[i]
        if item and item:isVisible() then
            local isSel = item:getTag() == self._selItemTag and true or false
            item:getChildByName("select"):setVisible(isSel)
        end
    end
end

function GUITXTEditorEvent:onItemBgEvent(sender)
    self._selItemTag = sender:getParent():getTag()
    self:setSelect2()
end

-- 刷新条件列表
function GUITXTEditorEvent:initRightList(init)
    local list = self._quickUI.ScrollView_2
    self:setVisibleInList(list)

    self._rightData = {}

    local key = self._Key

    local events_show, conditions_show = false, false
    local conditions, events = {}, {}
    local nCondition, nEvent = 0, 0

    dump(self._showData, "---showData---", 6)

    if self._showData[key] then
        events_show, conditions_show = init and false or self._showData[key].events_show, init and false or self._showData[key].conditions_show
        conditions, events = self._showData[key].conditions or conditions, self._showData[key].events or events
        nCondition, nEvent = #conditions, #events

        self._rightData = {
            [OperateType.EVENT] = {
                events = events,
                events_show = events_show,
                name = "事件"
            },
            [OperateType.CONDITION] = {
                conditions = conditions,
                conditions_show = conditions_show,
                name = "条件"
            }
        }
    else
        self._rightData = {
            [OperateType.EVENT] = {
                events = {},
                events_show = false,
                name = "事件"
            },
            [OperateType.CONDITION] = {
                conditions = {},
                conditions_show = false,
                name = "条件"
            }
        }
    end

    local num = 2
    num = events_show and num + nEvent or num
    num = conditions_show and num + nCondition or num

    local realhh = num * 35
    local listhh = list:getContentSize().height
    realhh = math.max(realhh, listhh)
    list:setInnerContainerSize({width = list:getContentSize().width, height = realhh})

    local loadUIVisible1 = function (item, flag, last)
        -- 折叠
        if flag == "ADD" then
            item["line_BG"]:setVisible(true)
            item["line1"]:setVisible(true)
            item["line2"]:setVisible(true)
            item["line4"]:setVisible(true)

            item["line5"]:setVisible(false)
            item["line6"]:setVisible(false)

            if last then
                item["line3"]:setVisible(false)
                item["line7"]:setVisible(false)
            else
                item["line3"]:setVisible(true)
                item["line7"]:setVisible(false)
            end
        elseif flag == "SUB" then
            item["line_BG"]:setVisible(true)
            item["line1"]:setVisible(true)
            item["line2"]:setVisible(false)
            item["line4"]:setVisible(true)

            item["line5"]:setVisible(false)
            item["line6"]:setVisible(false)


            if last then
                item["line3"]:setVisible(false)
                item["line7"]:setVisible(false)
            else
                item["line3"]:setVisible(true)
                item["line7"]:setVisible(false)
            end
        elseif flag == "NO" then
            item["line_BG"]:setVisible(false)
            item["line1"]:setVisible(false)
            item["line2"]:setVisible(false)
            item["line3"]:setVisible(false)
            item["line4"]:setVisible(false)
    
            item["line5"]:setVisible(true)
            item["line6"]:setVisible(true)

            if last then
                item["line7"]:setVisible(false)  
            else
                item["line7"]:setVisible(true)
            end
        end

        item["select"]:setVisible(false)
        
        item["lines2"]:setVisible(false)

        item:setVisible(true)
    end

    local loadUIVisible2 = function (item)
        item["line_BG"]:setVisible(false)
        item["line1"]:setVisible(false)
        item["line2"]:setVisible(false)
        item["line3"]:setVisible(false)
        item["line4"]:setVisible(false)

        item["line5"]:setVisible(false)
        item["line6"]:setVisible(true)
        item["line7"]:setVisible(true)

        item["select"]:setVisible(false)
    end

    local loadUIVisible3 = function (item, visible, visible2)
        item["line11"]:setVisible(true)
        item["line12"]:setVisible(true)
        item["line13"]:setVisible(visible)

        item["select"]:setVisible(false)

        loadUIVisible2(item)

        item:setVisible(true)

        item["btnAdd"]:setVisible(false)

        item["lines1"]:setVisible(visible2)
    end


    local loadItemNum = function (item, i)
        item["Text_num"]:setString(i)
    end

    local loadItemTag = function (item, i)
        item["btnAdd"]:setTag(i)
    end

    local loadItemInfo = function (item, str, i, isTouch, key)
        local txtName = item["Text_name"]
        txtName:setString(str)
        txtName:setTag(i)
        txtName._key = key
        txtName:setTouchEnabled(isTouch)
        txtName:setSwallowTouches(false)
        txtName:addClickEventListener(handler(self, self.onOpenInputEdit))
    end

    local setPosition = function (item, p)
        item:setPosition(p)
    end

    local createItem = function (i)
        local item = list:getChildByTag(i)
        if item then
            return item
        end

        item = self._quickUI.item_2:clone()
        item:setTag(i)
        list:addChild(item)

        IterAllChild(item, item)

        return item
    end

    local index = 0
    for i = 1, 2 do
        local item = createItem(i)

        local flag = "NO"
        if i == 1 then
            if nEvent > 0 then
                flag = events_show and "SUB" or "ADD"
            end
        else
            if nCondition > 0 then
                flag = conditions_show and "SUB" or "ADD"
            end
        end
        loadUIVisible1(item, flag, i == 2)

        index = index + 1
        loadItemNum(item, index)
        loadItemTag(item, i)

        item["line_BG"]:setTag(i)

        local data = self._rightData[i]
        loadItemInfo(item, data.name, i, false)

        setPosition(item, cc.p(12, realhh - index * 35))


        if events_show and i == OperateType.EVENT then
            for k, v in ipairs(data.events) do
                local item = createItem(k + 100)

                loadUIVisible3(item, k ~= nEvent, true)
                
                index = index + 1
                loadItemNum(item, index)
                loadItemTag(item, index)

                local events = {}
                for _, event in ipairs(string.split(v.EventID, "\n")) do
                    event = string.rtrim(event)
                    table.insert(events, _ ~= 1 and "; " .. event or event)
                end

                local str = #events > 1 and table.concat(events) or (events[1] or "")
                loadItemInfo(item, str, i, true)

                setPosition(item, cc.p(40, realhh - index * 35))

                item["Text_num"]:setPositionX(-17)
                item["lines1"]:setPositionX(2)
            end
        end

        if conditions_show and i == OperateType.CONDITION then
            for k, v in ipairs(data.conditions) do
                local item = createItem(k + 1000)

                loadUIVisible3(item, k ~= nCondition, false)
                
                index = index + 1
                loadItemNum(item, index)
                loadItemTag(item, index)

                local acts1 = {}
                for _, act in ipairs(string.split(v.Act1, "\n")) do
                    act = string.rtrim(act)
                    table.insert(acts1, _ ~= 1 and "; " .. act or act)
                end

                local acts2 = {}
                for _, act in ipairs(string.split(v.Act2, "\n")) do
                    act = string.rtrim(act)
                    table.insert(acts2, _ ~= 1 and "; " .. act or act)
                end

                local a1 = #acts1 > 1 and table.concat(acts1) or (acts1[1] or "")
                local a2 = #acts2 > 1 and table.concat(acts2) or (acts2[1] or "")
                local str = v.ID and sformat("if %s then %s else %s end", v.ID, a1, a2) or ""

                loadItemInfo(item, str, i, true, k)

                setPosition(item, cc.p(40, realhh - index * 35))

                item["Text_num"]:setPositionX(-17)
                item["lines1"]:setPositionX(2)
            end
        end
    end
end

function GUITXTEditorEvent:refreshRightList()
    self:initRightList()
end

function GUITXTEditorEvent:setVisibleInList(list)
    local childrens = list:getChildren()
    for i = 1, #childrens do
        local item = childrens[i]
        if item then
            item:setVisible(false)
        end
    end
end

function GUITXTEditorEvent:addTextField(parent)
    local onEditFunc = function (sender, eventType)
        local updateData = function (value)
            local key = sender:getTag()
            sender:setString(value)

            if self._showData[key] then
                self._showData[key].triggerName = value
            end
        end

        local preInputStr = sender:getString()
        if eventType == 1 then
            local inputStr = strim(sender:getString())
            if slen(inputStr) > 0 then
                updateData(inputStr)
            end
            sender:getParent():getChildByName("select"):setVisible(true)
        elseif eventType == 2 then
            local str = sender:getString()
            if sender.closeKeyboard and sfind(str, "\n") then
                sender:closeKeyboard()
                local inputStr = strim(str)
                if slen(inputStr) > 0 and inputStr ~= preInputStr then
                    updateData(inputStr)
                end
            end
        end
    end

    local input = GUI:TextInput_Create(parent, "Input", 10, 16, 451, 20, 14)
    GUI:TextInput_setPlaceHolder(input, "新建触发器")
    GUI:setAnchorPoint(input, 0, 0.5)
    GUI:TextInput_setInputMode(input, 6)
    GUI:TextInput_addOnEvent(input, onEditFunc)
    GUI:setTouchEnabled(input, false)
end

-- 刷新行为列表
function GUITXTEditorEvent:refreshActList()
    local list = self._quickUI.ScrollView_1
    self:setVisibleInList(list)

    local realhh = #self._showData * 41 - 3
    local listhh = list:getContentSize().height
    realhh = math.max(realhh, listhh)
    list:setInnerContainerSize({width = list:getContentSize().width, height = realhh})

    for i, v in ipairs(self._showData) do
        local item = list:getChildByTag(i)
        if not item then
            item = self._quickUI.item:clone()
            list:addChild(item)
            item:setTag(i)
            self:addTextField(item, i)
        end
        item:setPosition(cc.p(3, realhh - i * 41 + 3))
        item:setVisible(true)

        local Input = item:getChildByName("Input")
        GUI:TextInput_setString(Input, v.triggerName or "")

        Input:setTag(i)

        GUI:Button_setBrightEx(item:getChildByName("btnDel"), false)
        GUI:Button_setBrightEx(item:getChildByName("btnUp"), false)
        GUI:Button_setBrightEx(item:getChildByName("btnDown"), false)
        
        item:getChildByName("select"):setVisible(false)
    end
end

function GUITXTEditorEvent:getDefaultName()
    for i = 1, 50 do
        local name = sformat("新建触发%s", i)
        if not self._keyData[name] then
            return name
        end
    end
    return nil
end

function GUITXTEditorEvent:addData()
    local name = self:getDefaultName()
    if not name then
        return ShowSystemTips("最多支持50个触发")
    end
    self._keyData[name] = {}
    self._showData[#self._showData+1] = {name = name}
end

function GUITXTEditorEvent:onNewEvent()
    DelayTouchEnabled(self._quickUI.btnAddEvent, 0.2)
    self:addData()
    self:refreshActList()
end

function GUITXTEditorEvent:onOpenInputEdit(sender)
    local optType = sender:getTag()

    if optType == OperateType.CONDITION then
        self._quickUI.Image_condition:setVisible(true)
        self._quickUI.Image_notice:setVisible(false)
    elseif optType == OperateType.EVENT then
        self._quickUI.Image_condition:setVisible(false)
        self._quickUI.Image_notice:setVisible(true)
    end

    self._quickUI.btnSure:setTag(optType)

    self._quickUI.Panel_Edit:setVisible(true)

    self._KeyCondition = sender._key or ((self._showData[self._Key] and self._showData[self._Key].conditions) and #self._showData[self._Key].conditions + 1 or 1)

    self._KeyEvent = 1

    if sender._key then
        self:updateUIControl(false)
    else
        self._editData = {}
        self:updateUIControl(true)
    end
end

function GUITXTEditorEvent:onEditComplete(sender)
    self._quickUI.Panel_Edit:setVisible(false)

    if not self._showData[self._Key] then
        return false
    end

    local optType = sender:getTag()
    if optType == OperateType.CONDITION then
        self._showData[self._Key].conditions = self._showData[self._Key].conditions or {}

        local oldData = self._showData[self._Key].conditions[self._KeyCondition] or {}

        local ID   = self._editData["ID"]   or (oldData["ID"])
        local Act1 = self._editData["Act1"] or (oldData["Act1"] or ";")
        local Act2 = self._editData["Act2"] or (oldData["Act2"] or ";")
        if not ID then
            return false
        end

        self._showData[self._Key].conditions[self._KeyCondition] = {ID = ID, Act1 = Act1, Act2 = Act2}
        self._showData[self._Key].conditions_show = true
    elseif optType == OperateType.EVENT then
        self._showData[self._Key].events = self._showData[self._Key].events or {}

        local data = {
            EventID = self._editData["EventID"]
        }

        self._showData[self._Key].events[self._KeyEvent] = data

        self._showData[self._Key].events_show = true
    end

    self:refreshRightList()
end

function GUITXTEditorEvent:onOpenOrClose(sender)
    local type = sender:getTag()
    if type == OperateType.EVENT then
        self._showData[self._Key].events_show = not self._showData[self._Key].events_show
    elseif type == OperateType.CONDITION then
        self._showData[self._Key].conditions_show = not self._showData[self._Key].conditions_show
    end
    self:refreshRightList()
end

function GUITXTEditorEvent:onDelete()
    local tag = self._selItemTag 
    if not tag then
        return false
    end

    local item = self._quickUI["ScrollView_2"]:getChildByTag(tag)
    if not item then
        return false
    end

    if tag > 1000 then
        tag = tag % 1000
        table.remove(self._showData[self._Key].conditions, tag)
        self:refreshRightList()
    elseif tag > 100 then
        tag = tag % 100
        table.remove(self._showData[self._Key].events, tag)
        self:refreshRightList()
    end
end

function GUITXTEditorEvent:onSave()
    if self._callback then
        self._callback(self._showData)
    end
    
    self:onClose()
end

-- 关闭界面
function GUITXTEditorEvent:onClose()
    global.Facade:sendNotification(global.NoticeTable.Layer_GUITXTEditorEvent_Close)
end

return GUITXTEditorEvent
