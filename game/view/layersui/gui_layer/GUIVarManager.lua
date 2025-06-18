local BaseLayer = requireLayerUI("BaseLayer")
local GUIVarManager = class("GUIVarManager", BaseLayer)
local GUIHelper = requireLayerGUI("GUIHelper")
local Queue     = requireUtil("queue")

local sformat       = string.format
local sfind         = string.find
local sgsub         = string.gsub
local strim         = string.trim
local slen          = string.len
local ssplit        = string.split
local sreverse      = string.reverse
local ssub          = string.sub

local tInsert       = table.insert
local tRemove       = table.remove
local tSort         = table.sort

local fileUtil      = global.FileUtilCtl
local resourcePath  = fileUtil:getDefaultResourceRootPath()
local mCachePath    = global.L_ModuleManager:GetCurrentModule():GetSubModPath()
local mStabPath     = global.L_ModuleManager:GetCurrentModule():GetStabPath()

local res           = "GUIValue/"
local directory     = "dev/"  .. res
local exportFolder  = resourcePath .. mStabPath .. res
local gmFolder      = resourcePath .. directory
local cacheFolder   = fileUtil:getWritablePath() .. mCachePath .. res

local NotOptFiles   = {
    ["GUIValueInit"] = 1, ["Var_server"] = 1
}

local SetTouchTag = function (key, idx)
    return key * 10000 + idx
end

local GetKeyByTag = function (value)
    return math.floor(value / 10000)
end

local GetIdxByTag = function (value)
    return math.floor(value % 10000)
end

function GUIVarManager:ctor()
    GUIVarManager.super.ctor(self)

    self._systemTipsCells = Queue.new()

    self._selUIControl = {}

    self._Attr = {
        ["TextField_temp"] = { IMode = 6, t = 1, SetWidget = handler(self, self.SetTemp), SetUIWidget = handler(self, self.SetUITemp) },
        ["TextField_num"]  = { IMode = 2, t = 1, SetWidget = handler(self, self.SetNum), SetUIWidget = handler(self, self.SetUINum) },
        ["btnDel"]         = { t = 2, func = handler(self, self.onDel) },
        ["btnAdd"]         = { t = 2, func = handler(self, self.onAdd) },
        ["btnAddFile"]     = { t = 2, func = handler(self, self.onAdd) },
        ["btnAddVar"]      = { t = 2, func = handler(self, self.onAdd) },
        ["btnAddVal"]      = { t = 2, func = handler(self, self.onAdd) },
        ["btnClose"]       = { t = 2, func = handler(self, self.onClose) },
        ["btnSave"]        = { t = 2, func = handler(self, self.onSave) },
        ["input_bg"]       = { t = 2, func = handler(self, self.onCellBgEvent) },
        ["btnOk"]          = { t = 2, func = handler(self, self.onAddBatchEvent) },
        ["btnAddBatch"]    = { t = 2, func = handler(self, self.onOpenBatchUI) }
    }
end

function GUIVarManager.create(data)
    local layer = GUIVarManager.new()
    if layer:init(data) then
        return layer
    end
    return false
end

function GUIVarManager:init(data)
    local root = CreateExport("gui_txt_editor/var_manager.lua")
    if not root then
        return false
    end
    self:addChild(root)

    fileUtil:purgeCachedEntries()
    
    self._quickUI = ui_delegate(root)

    self._text = ""
    self._num = 1

    self:InitUIAttr()

    self:updateUIControl()

    self._Datas = self:getAllDatas()
    self._Tags  = {}

    self:CreateTableView(1)
    self:CreateTableView(2)
    self:CreateTableView(3)

    self:OnRefreshTableViewEx(1)
    self:OnRefreshTableViewEx(2)
    self:OnRefreshTableViewEx(3)

    return true
end

function GUIVarManager:InitUIAttr()
    local function func(widget, data, name)
        (({
            [1] = function()
                local editBox = CreateEditBoxByTextField(widget)
                editBox:setInputMode(data.IMode)
                self._selUIControl[name] = editBox
                self:initTextFieldEvent(editBox)
            end,
            [2] = function ()
                widget:addTouchEventListener(data.func)
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

function GUIVarManager:initTextFieldEvent(widget)
    widget:addEventListener(function(ref, eventType)
        local name = ref:getName()
        local ui = self._Attr[name]
        if not ui then
            return false
        end
        
        local str  = ref:getString()
        if eventType == 1 then
            str = strim(str)
            ref:setString(str)
            self:updateUIAttr(name, str)
        end
    end)
end

function GUIVarManager:updateUIAttr(name, value)
    if name and self._Attr[name] and self._Attr[name].SetWidget then
        self._Attr[name].SetWidget(value)
    end
    self:updateUIControl()
end

function GUIVarManager:updateUIControl()
    for name,_ in pairs(self._selUIControl) do
        if self._Attr[name] then
            if self._Attr[name].SetUIWidget then
                self._Attr[name].SetUIWidget(self._selUIControl[name])
            end
        end
    end
end

function GUIVarManager:SetTemp(value)
    self._text = value
end

function GUIVarManager:SetUITemp(widget)
    widget:setString(self._text)
end

function GUIVarManager:SetNum(value)
    self._num = tonumber(value) or 1
end

function GUIVarManager:SetUINum(widget)
    widget:setString(self._num)
end

function GUIVarManager:onAddBatchEvent(sender, eventType)
    if eventType ~= ccui.TouchEventType.ended then
        return false
    end

    local text = self._text
    if slen(text) < 1 then
        GUIHelper.CteateShowTips(self, self._systemTipsCells, "Key不能为空")
        return false
    end

    local key = 3

    if not self._Datas[key] then
        return false
    end

    if not self._Idx1 then
        return false
    end

    if not self._Idx2 then
        return false
    end

    self._Datas[key][self._Idx1][self._Idx2] = {}

    local intVal = tonumber(text)
    
    local srname
    sgsub(text, "$%(%s*<%s*(.-)%s*>%s*,%s*(.-)%s*%)", function ( a,b ) srname = "$(<H>, " .. b .. "%s)" end)

    for i = 1, self._num do
        local name = intVal and intVal + i or (srname and sformat(srname, i) or text .. "_" .. i)
        tInsert(self._Datas[key][self._Idx1][self._Idx2], {name = name, selected = false, actived = false})
    end

    self:OnSelectedCell(3, 1)
    self:UpdateTableViewNum(3) 
end

function GUIVarManager:onOpenBatchUI(sender, eventType)
    if eventType == 2 then
        self._quickUI.Panel_more:setVisible(not self._quickUI.Panel_more:isVisible())
    end
end

function GUIVarManager:getFileName(str)
    local rerStr = sreverse(str)
    local _, i   = sfind(rerStr, "/")
    local len    = slen(str)
    local st     = len - i + 2
    return ssub(str, st, len-4), ssub(str, 1, st-1)
end

function GUIVarManager:getAllDatas()
    local items1 = {}
    local items2 = {}
    local items3 = {}

    local filenames = {}

    local loadfiles = function (file)
        local name, path = self:getFileName(file)

        if filenames[name] then
            return false
        end
        filenames[name] = true

        if NotOptFiles[name] then
        else
            local n = #items1 + 1
            local selected = n == 1 and true or false
            items1[n] = {name = name, path = file, selected = selected, actived = false}


            items2[n] = {}

            local path = sformat("GUIValue/%s", name)
            local txtFile = fileUtil:getStringFromFile(fileUtil:fullPathForFilename(path..".lua"))
            txtFile = sgsub(sgsub(txtFile, "= function", "= [[function"), "end", "end]]")

            local iotabs = load(txtFile)()

            local tabs = SL:Require(path, true)
            local keys = table.keys(tabs)
            tSort(keys, function (a, b) return a < b end)

            for j = 1, #keys do
                local key = keys[j]

                local k = #items2[n] + 1
                local selected = k == 1 and true or false
                items2[n][k] = {name = key, selected = selected, actived = false}


                items3[n] = items3[n] or {}
                items3[n][k] = {}

                local value = tabs[key]

                if type(value) == "table" then
                    for _, sv in ipairs(iotabs[key]) do
                        sgsub(sv, "VALUE%((.-),(.-)%)", function (s1, s2)
                            local s, Is = sgsub(s1, "<%s*T_(.-)%s*>", "$<T_%1>")
                            if Is == 1 then
                                sv = sgsub(s, "\"", "")
                            else
                                s1, s2 = sgsub(strim(s1), "\"", ""), sgsub(strim(s2), "\"", "")
                                sv = sformat("$(%s, %s)", s1, s2)
                            end
                        end)
                        print(sv)
                        
                        local m = #items3[n][k] + 1
                        
                        local selected = false
                        if n == 1 and k == 1 and m == 1 then
                            selected = true
                        end

                        items3[n][k][m] = {name = sv, selected = selected, actived = false}
                    end
                else
                    local notCanActive = false
                    local name = value
                    local func = nil
                    if type(value) == "function" then
                        notCanActive = true
                        name = "函数(不支持修改)"
                        func = iotabs[key]
                    end

                    local m = #items3[n][k] + 1

                    local selected = false
                    if n == 1 and k == 1 and m == 1 then
                        selected = true
                    end
                    
                    items3[n][k][m] = {name = name, selected = selected, actived = false, notCanActive = notCanActive, func = func}
                end
            end
        end
    end

    for _, folder in ipairs({exportFolder, cacheFolder, gmFolder}) do
        local listfiles = fileUtil:listFiles(folder)
        -- 跳过 2 条
        tRemove(listfiles, 1)
        tRemove(listfiles, 1)

        for i, file in ipairs(listfiles) do
            file = sgsub(file, "[/]+$", "")
            if sfind(file, ".lua") then
                loadfiles(file)
            end
        end
    end

    return {items1, items2, items3}
end

function GUIVarManager:OnRefreshTableViewEx(key)
    self._quickUI["TableView_"..key]:reloadDataEx()
end

function GUIVarManager:OnRefreshTableView(key)
    self._quickUI["TableView_"..key]:reloadData()
end

function GUIVarManager:UpdateTableViewNum(key)
    self._quickUI["TableView_"..key]:setTableViewCellsNumHandler(function ()
        if key == 1 then
            return #self._Datas[key]
        end
        if key == 2 then
            return #self._Datas[key][self._Idx1] 
        end
        if key == 3 then
            return #self._Datas[key][self._Idx1][self._Idx2]
        end
    end)
end

function GUIVarManager:OnSelectedCell(key, index)
    local funcSelected = function (datas)
        local index = index or #datas
        for i, v in ipairs(datas) do
            v.selected, v.actived = index == i, false
        end
    end

    if key == 1 then
        funcSelected(self._Datas[key] or {})
    end
    if key == 2 then
        funcSelected(self._Datas[key][self._Idx1] or {})
    end
    if key == 3 then
        funcSelected(self._Datas[key][self._Idx1][self._Idx2] or {})
    end
end

function GUIVarManager:onCellBgEvent(sender, eventType)
    local SetSelected = function (key, idx, status)
        if key == 1 then
            if self._Datas[key][idx] then
                self._Datas[key][idx].selected = status
            end
        elseif key == 2 then
            if self._Datas[key][self._Idx1][idx] then
                self._Datas[key][self._Idx1][idx].selected = status
            end
        elseif key == 3 then
            if self._Datas[key][self._Idx1][self._Idx2][idx] then
                self._Datas[key][self._Idx1][self._Idx2][idx].selected = status
            end
        end
    end
    
    local SetActived = function (key, idx, status)
        if key == 1 then
            if self._Datas[key][idx] then
                self._Datas[key][idx].actived = status
            end
        elseif key == 2 then
            if self._Datas[key][self._Idx1][idx] then
                self._Datas[key][self._Idx1][idx].actived = status
            end
        elseif key == 3 then
            if self._Datas[key][self._Idx1][self._Idx2][idx] then
                self._Datas[key][self._Idx1][self._Idx2][idx].actived = status
            end
        end
    end

    self._CLICK_NUM_ = self._CLICK_NUM_ or 0

    if eventType == 0 then
        if not self._ScheduleID then
            self._ScheduleID = SL:ScheduleOnce(function ()
                self._CLICK_NUM_ = 0
                self._ScheduleID = nil
            end, global.MMO.CLICK_DOUBLE_TIME)
        end
    elseif eventType ~= 1 then
        self._CLICK_NUM_ = self._CLICK_NUM_ + 1

        if not self._ScheduleID then
            return false
        end
        
        local newTag = sender:getTag()

        -- 当前
        local key = GetKeyByTag(newTag)
        local idx = GetIdxByTag(newTag)
        SetSelected(key, idx, true)

        local oldTag = self._Tags[key]

        if not oldTag then

        elseif oldTag ~= newTag then
            -- 上次
            local key2 = GetKeyByTag(oldTag)
            local idx2 = GetIdxByTag(oldTag)
            SetSelected(key2, idx2, false)
            SetActived(key2, idx2, false)
        else
            SetActived(key, idx, self._CLICK_NUM_ > 1)
        end

        if key == 1 then
            self._Idx1 = idx
            self._Idx2 = 1
            self:OnRefreshTableViewEx(key)
            self:OnSelectedCell(2, 1)
            self:UpdateTableViewNum(2)

            self:OnSelectedCell(3, 1)
            self:UpdateTableViewNum(3)
        elseif key == 2 then
            self._Idx2 = idx
            self:OnRefreshTableViewEx(key)
            self:OnSelectedCell(3, 1)
            self:UpdateTableViewNum(3)
        elseif key == 3 then
            self:OnRefreshTableViewEx(key)
        end

        self._Tags[key] = newTag
    end
end

function GUIVarManager:onDel(sender)
    local tag = sender:getTag()
    local key, idx = GetKeyByTag(tag), GetIdxByTag(tag)

    local function removeKey1(key)
        local datas = self._Datas[key]
        tRemove(datas, idx)
        local n = #datas
        if n < 1 then
            self._Datas = {{}, {{}}, {{{}}}}
            self:UpdateTableViewNum(1)
            self:UpdateTableViewNum(2)
            self:UpdateTableViewNum(3)
            return false
        end
        local seln = idx > n and n or idx
        self._Idx1 = seln
        self._Idx2 = 1
        self._Tags[1] = 10000 + seln
        self:OnSelectedCell(1, seln)
        self:UpdateTableViewNum(1)

        local datas = self._Datas[2]
        tRemove(datas, idx)
        self:OnSelectedCell(2, 1)
        self:UpdateTableViewNum(2)

        local datas = self._Datas[3]
        tRemove(datas, idx)
        self:OnSelectedCell(3, 1)
        self:UpdateTableViewNum(3)
    end

    local function removeKey2(key)
        local datas = self._Datas[key][self._Idx1]
        local n = #datas
        if n < 2 then
            removeKey1(1)
            self:OnRefreshTableView(1)
            return false
        end

        tRemove(datas, idx)
        local n = n - 1
        local seln = idx > n and n or idx
        self._Idx2 = seln
        self._Tags[2] = 20000 + seln
        self:OnSelectedCell(2, seln)
        self:UpdateTableViewNum(2)

        local datas = self._Datas[3][self._Idx1]
        tRemove(datas, idx)
        self:OnSelectedCell(3, 1)
        self:UpdateTableViewNum(3)
    end

    if key == 1 then
        removeKey1(1)
    elseif key == 2 then
        removeKey2(2)
    elseif key == 3 then
        local datas = self._Datas[key][self._Idx1][self._Idx2]
        local n = #datas
        if n < 2 then
            removeKey2(2)
            self:OnRefreshTableView(2)
            return false
        end

        tRemove(datas, idx)
        local n = n - 1
        local seln = idx > n and n or idx
        self._Tags[3] = 20000 + seln
        self:OnSelectedCell(3, seln)
        self:UpdateTableViewNum(3)
    end
end

function GUIVarManager:onAdd(sender, eventType)
    if eventType ~= 2 then
        return false
    end

    local tag = sender:getTag()
    local key = GetKeyByTag(tag)

    local datas = nil
    if key == 1 then
        datas = self._Datas[key] or {}
        tInsert(datas, {name = "文件名", selected = false, actived = false})
        local n = #datas
        self._Idx1 = n
        self._Idx2 = 1
        self._Tags[1] = 10000 + self._Idx1
        self:OnSelectedCell(1, n)
        self:UpdateTableViewNum(1)

        local datas = self._Datas[2] or {}
        tInsert(datas, {{name = "变量名", selected = false, actived = false}})
        self:OnSelectedCell(2, 1)
        self:UpdateTableViewNum(2)

        local datas = self._Datas[3] or {}
        tInsert(datas, {{{name = "值", selected = false, actived = false}}})
        self:OnSelectedCell(3, 1)
        self:UpdateTableViewNum(3)
    elseif key == 2 then
        local datas = self._Datas[key][self._Idx1] or {}
        tInsert(datas, {name = "变量名", selected = false, actived = false})
        local n = #datas
        self._Idx2 = n
        self._Tags[2] = 20000 + self._Idx2
        self:OnSelectedCell(2, n)
        self:UpdateTableViewNum(2)

        local datas = self._Datas[3][self._Idx1] or {}
        tInsert(datas, {{name = "值", selected = false, actived = false}})
        self:OnSelectedCell(3, 1)
        self:UpdateTableViewNum(3)
    elseif key == 3 then
        local datas = self._Datas[key][self._Idx1][self._Idx2] or {}
        tInsert(datas, {name = "值", selected = false, actived = false})

        local n = #datas
        self:OnSelectedCell(3, n)
        self:UpdateTableViewNum(3)  
    end
end

function GUIVarManager:SaveCfg(name, strs)
    local path = sformat("dev/GUIValue/%s.lua", name)
    fileUtil:writeStringToFile(strs, path)
    fileUtil:purgeCachedEntries()
end

function GUIVarManager:onSave(sender)
    local files = self._Datas[1] or {}
    local keys  = self._Datas[2] or {}
    local vars  = self._Datas[3] or {}

    local function GetValStr(value, i)
        local Is, name = GUIHelper.FormatServerVarSHOW(value)
        if Is then
            return sformat("[%s] = function (i) return %s end", i, name)
        else
            return sformat("[%s] = '%s'", i, value)
        end 
    end

    for i, file in ipairs(files) do
        local name = file.name

        local strs = nil

        local ks = keys[i] or {}
        for j = 1, #ks do
            local v_ks = ks[j]
            if v_ks then
                local k = v_ks.name

                strs = strs and sformat("%s\n\t%s", strs, "[\""..k.."\"] = ") or sformat("\t%s", "[\""..k.."\"] = ")

                local vStrs = nil
                local v = ""
                local rs = vars[i][j] or {}
                local n_rs = #rs

                if n_rs > 1 then
                    for m, v_rs in ipairs(rs) do
                        v = GetValStr(v_rs.name, m)
                        vStrs = vStrs and sformat("%s\n\t\t%s,", vStrs, v) or sformat("\t\t%s,", v)
                    end

                    vStrs = sformat("{\n%s\n\t},", vStrs)
                else
                    local func = rs[1].func
                    if func then
                        v = func
                    else
                        v = rs[1].name
                        v = type(v) == "string" and sformat("\"%s\"", v) or v
                    end

                    vStrs = vStrs and sformat("%s\n%s,", vStrs, v) or sformat("%s,", v)
                end

                strs = sformat("%s%s", strs, vStrs)
            end
        end
        
        self:SaveCfg(name, sformat("return \n{\n%s\n}", strs))
    end
end

function GUIVarManager:addTextField(parent)
    local onEditFunc = function (sender, eventType)
        local updateData = function (value)
            local tag = sender:getTag()
            sender:setString(value)

            local key, idx = GetKeyByTag(tag), GetIdxByTag(tag)
            if key == 1 then
                local oldName = self._Datas[key][idx].name
                if oldName == value then
                    return false
                end

                local isExist = false
                for i, v in ipairs(self._Datas[key]) do
                    if i ~= idx and v.name == value then
                        isExist = true
                        break
                    end
                end
                if isExist then
                    return ShowSystemTips("文件名冲突")
                end

                self._Datas[key][idx].name = value
            elseif key == 2 then
                local oldName = self._Datas[key][self._Idx1][idx].name
                if oldName == value then
                    return false
                end

                local isExist = false
                for i, v in ipairs(self._Datas[key][self._Idx1]) do
                    if i ~= idx and v.name == value then
                        isExist = true
                        break
                    end
                end
                if isExist then
                    return ShowSystemTips("变量名冲突")
                end

                self._Datas[key][self._Idx1][idx].name = value
            elseif key == 3 then
                local oldName = self._Datas[key][self._Idx1][self._Idx2][idx].name
                if oldName == value then
                    return false
                end
                self._Datas[key][self._Idx1][self._Idx2][idx].name = value
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

    local input = GUI:TextInput_Create(parent, "Input", 8, 16, 154, 20, 14)
    GUI:TextInput_setPlaceHolder(input, "Test")
    GUI:setAnchorPoint(input, 0, 0.5)
    GUI:TextInput_setInputMode(input, 6)
    GUI:TextInput_addOnEvent(input, onEditFunc)
    GUI:setTouchEnabled(input, false)

    return input
end

function GUIVarManager:CreateTableView(key)
    local createItem = function (cell, idx)
        local item = self._quickUI.item:clone()
        item:setSwallowTouches(false)
        cell:addChild(item)
        item:setVisible(true)
        item:setPosition(cc.p(0, 0))

        local datas = {}
        if key == 1 then
            datas = self._Datas[key]
        elseif key == 2 then
            datas = self._Datas[key][self._Idx1]
        elseif key == 3 then
            datas = self._Datas[key][self._Idx1][self._Idx2] or {}
        end

        local data = datas[idx]

        local tag = SetTouchTag(key, idx)
        
        self._Tags[key] = self._Tags[key] or tag
        
        local Input = item:getChildByName("Input") or self:addTextField(item, key)
        GUI:TextInput_setString(Input, data.name)
        Input:setTag(tag)

        if data.actived and not data.notCanActive then
            Input:touchDownAction(Input, 2)
        end

        local select = item:getChildByName("select")
        select:setVisible(data.selected)

        local input_bg = item:getChildByName("input_bg")
        input_bg:setTag(tag)
        input_bg:setSwallowTouches(false)

        local btnDel = item:getChildByName("btnDel")
        btnDel:setTag(tag)
        
        local btnAdd = item:getChildByName("btnAdd")
        btnAdd:setTag(tag)

        local isLast = #datas == idx
        btnAdd:setVisible(isLast)

        if key == 1 then
            self._selUIControl["btnAddFile"]:setTag(tag)
        elseif key == 2 then
            self._selUIControl["btnAddVar"]:setTag(tag)
        elseif key == 3 then
            self._selUIControl["btnAddVal"]:setTag(tag)
        end
    end

    local list = self._quickUI["List_"..key]
    local size = list:getContentSize()
    local p    = cc.p(list:getPosition())

    local data = {}
    if key == 1 then
        self._Idx1 = 1
        data = self._Datas[key] or {}
    elseif key == 2 then
        self._Idx2 = 1
        self._Datas[key] = self._Datas[key] or {}
        data = self._Datas[key][self._Idx1] or {}
    elseif key == 3 then
        self._Datas[key] = self._Datas[key] or {}
        self._Datas[key][self._Idx1] = self._Datas[key][self._Idx1] or {}
        data = self._Datas[key][self._Idx1][self._Idx2] or {}
    end
    
	local TableView = GUI:TableView_Create(self._quickUI.Panel_1, "TableView_" .. key, p.x, p.y, size.width, size.height, 1, 200, 35, #data)
	GUI:TableView_setBackGroundColor(TableView, "#969664")
	GUI:setTouchEnabled(TableView, true)
	GUI:setSwallowTouches(TableView, false)

	GUI:TableView_setCellCreateEvent(TableView, function(cell, idx)
		createItem(cell, idx)
	end)

	GUI:TableView_scrollToCell(TableView, 1)
end

-- 关闭界面
function GUIVarManager:onClose()
    global.Facade:sendNotification(global.NoticeTable.Layer_GUIVarManager_Close)
end

return GUIVarManager