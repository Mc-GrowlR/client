-- BOSS提示、屏蔽怪物列表
BossTips = {}

function BossTips.main(parent, data)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "setup/boss_tips")

    BossTips._ui = GUI:ui_delegate(parent)
    
    BossTips._enable = (data.default or 0) == 1
    BossTips._tNames = string.split(data.names or "", "#")
    for k, v in ipairs(BossTips._tNames) do
        if v == "" then
            table.remove(BossTips._tNames, k)
        end
    end
    BossTips._items = {}

    -- 开启关闭
    local clickCell = BossTips._ui["click_cell"]
    local CheckBox_able = GUI:getChildByName(clickCell, "CheckBox_able")
    local function setClickCellStatus(enable)
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_off"), not enable)
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_on"), enable)
    end

    setClickCellStatus(BossTips._enable)

    GUI:addOnClickEvent(clickCell, function()
        BossTips._enable = not BossTips._enable
        setClickCellStatus(BossTips._enable)
    end)

    -- 输入框
    BossTips._inputName = ""
    local input = BossTips._ui["input"]
    BossTips.input = input
    GUI:TextInput_addOnEvent(input, function(sender, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(sender)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("名字不能为空")
                GUI:TextInput_setString(sender, BossTips._inputName)
                return
            end

            BossTips._inputName = inputStr
        end
    end)

    -- 添加
    GUI:addOnClickEvent(BossTips._ui["btn_add"], function()
        local inputStr = GUI:TextInput_getString(BossTips.input)
        if string.len(inputStr) == 0 then
            SL:ShowSystemTips("名字不能为空")
            return
        end

        table.insert(BossTips._tNames, inputStr)
        BossTips._index = #BossTips._tNames
        BossTips.initItems()
        SL:ShowSystemTips("添加成功")
    end)

    -- 删除
    GUI:addOnClickEvent(BossTips._ui["btn_del"], function()
        if not BossTips._index or not BossTips._tNames[BossTips._index] or BossTips._tNames[BossTips._index] == "" then
            return
        end

        table.remove(BossTips._tNames, BossTips._index)

        BossTips._index = 1
        BossTips.initItems()
        SL:ShowSystemTips("删除成功")
    end)

    -- 修改
    GUI:addOnClickEvent(BossTips._ui["btn_change"], function()
        if not BossTips._index or not BossTips._tNames[BossTips._index] or BossTips._tNames[BossTips._index] == "" then
            return
        end

        local inputStr = GUI:TextInput_getString(BossTips.input)
        if string.len(inputStr) == 0 then
            SL:ShowSystemTips("名字不能为空")
            return
        end
        
        BossTips._tNames[BossTips._index] = inputStr

        BossTips.initItems()
        SL:ShowSystemTips("修改成功")
    end)

    BossTips._index = 1
    BossTips.initItems()
end

function BossTips.initItems()
    local list_items = BossTips._ui["list_items"]
    GUI:ListView_addMouseScrollPercent(list_items)
    GUI:ListView_removeAllItems(list_items)
    BossTips._items = {}
    BossTips._inputName = ""
    GUI:TextInput_setString(BossTips.input, BossTips._inputName)

    local function createCell(parent, k, v)
        local pageCell = GUI:Layout_Create(parent, "page_cell", 0, 0, 260, 20, false)
        GUI:Layout_setBackGroundColorType(pageCell, 1)
        GUI:Layout_setBackGroundColor(pageCell, BossTips._index == k and "#ffbf6b" or "#000000")
        GUI:Layout_setBackGroundColorOpacity(pageCell, 140)
        GUI:setTouchEnabled(pageCell, true)

        local PageText = GUI:Text_Create(pageCell, "PageText", 130, 10, 14, "#ffffff", v)
        GUI:setAnchorPoint(PageText, 0.5, 0.5)
        GUI:Text_setTextHorizontalAlignment(PageText, 1)
        GUI:Text_enableOutline(PageText, "#000000", 1)

        GUI:addOnClickEvent(pageCell, function()
            BossTips._inputName = v
            BossTips._index = k
            GUI:TextInput_setString(BossTips.input, BossTips._inputName)
            BossTips.refreshCells()
        end)

        if BossTips._index == k then
            BossTips._inputName = v
            GUI:TextInput_setString(BossTips.input, BossTips._inputName)
        end

        return pageCell
    end

    for k, v in ipairs(BossTips._tNames) do
        if v ~= "" then
            local quickCell = GUI:QuickCell_Create(list_items, "quickCell"..k, 0, 0, 260, 20, function(parent)
                return createCell(parent, k, v)
            end)

            BossTips._items[k] = quickCell
        end
    end

    GUI:ListView_jumpToItem(list_items, BossTips._index - 1)
end

-- 刷新 ListView
function BossTips.refreshCells()
    for index, cell in ipairs(BossTips._items) do
        if cell then
            cell:Exit()
            cell:Refresh()
        end
    end
end

-- 外部调用，返回当前界面处理数据结果
function BossTips.getValue()
    local ret = {}
    ret.default = BossTips._enable and 1 or 0
    if next(BossTips._tNames) then
        local strNames = table.concat(BossTips._tNames, "#")
        ret.names = strNames
    end
    
    return ret
end

return BossTips