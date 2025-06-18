AddNewItem = {}

function AddNewItem.main(param)
    local parent = GUI:Win_Create("AddNewItem", 0, 0, 0, 0, false, false, true, true)
    loadConfigSettingExport(parent, "add_new_item")
    AddNewItem._ui = GUI:ui_delegate(parent)

    AddNewItem.param = param
    AddNewItem.ScrollView_items = AddNewItem._ui["ScrollView_items"]

    local screenW = SL:GetMetaValue("SCREEN_WIDTH")
    local screenH = SL:GetMetaValue("SCREEN_HEIGHT")

    local Layout_close = AddNewItem._ui["Layout_close"]
    GUI:setContentSize(Layout_close, screenW, screenH)

    local function closeFunc()
        GUI:Win_Close(parent)
    end

    GUI:addOnClickEvent(AddNewItem._ui["Button_close"], closeFunc)
    GUI:addOnClickEvent(Layout_close, closeFunc)

    local TextInput = AddNewItem._ui["TextInput"]
    AddNewItem.TextInput = TextInput
    GUI:TextInput_setTextHorizontalAlignment(TextInput, 1)
    GUI:TextInput_setPlaceHolder(TextInput, AddNewItem.param.inputPlaceHolder or "")

    local Button_sure = AddNewItem._ui["Button_sure"]
    GUI:addOnClickEvent(Button_sure, function()
        GUI:delayTouchEnabled(Button_sure)
        local inputStr = GUI:TextInput_getString(TextInput)
        if string.len(inputStr) == 0 then
            SL:ShowSystemTips(AddNewItem.param.inputPlaceHolder or "请输入要新增的内容")
            return
        end

        if table.indexof(AddNewItem.param.items, inputStr) then
            SL:ShowSystemTips("已存在，请重新输入")
            GUI:TextInput_setString(TextInput, "")
            return
        end

        local inputNum = tonumber(inputStr)
        table.insert(AddNewItem.param.items, inputNum)
        AddNewItem.updateItems()
        if AddNewItem.param.callback then
            AddNewItem.param.callback(inputNum, 1)
        end
        SL:ShowSystemTips("成功新增："..inputNum)
        GUI:TextInput_setString(TextInput, "")
    end)

    AddNewItem.updateItems()
end

function AddNewItem.updateItems()
    GUI:removeAllChildren(AddNewItem.ScrollView_items)
    local itemsData = AddNewItem.param.items or {}
    local suffix = AddNewItem.param.suffix
    for key, value in ipairs(itemsData) do
        local cell = GUI:Layout_Create(AddNewItem.ScrollView_items, "cell" .. key, 0, 0, 200, 34, true)
        GUI:Layout_setBackGroundColorType(cell, 1)
        GUI:Layout_setBackGroundColor(cell, key%2==0 and "#00ffff" or "#ff00ff")
        GUI:Layout_setBackGroundColorOpacity(cell, 128)
        local strSuffix = suffix or SL:GetMetaValue("ITEM_NAME", value)
        local textValue = GUI:Text_Create(cell, "textValue", 100, 17, 16, "#ffffff", value..strSuffix)
        GUI:setAnchorPoint(textValue, 0.5, 0.5)
        local btnDel = GUI:Button_Create(cell, "btnDel", 178, 17, "res/public/1900000620.png")
        GUI:setAnchorPoint(btnDel, 0.5, 0.5)
        GUI:addOnClickEvent(btnDel, function()
            if AddNewItem.param.callback then
                AddNewItem.param.callback(value, 0)
            end
            table.remove(AddNewItem.param.items, key)
            AddNewItem.updateItems()
            SL:ShowSystemTips("删除成功")
        end)
    end
    GUI:UserUILayout(AddNewItem.ScrollView_items, {dir=1, addDir=1})
end

return AddNewItem