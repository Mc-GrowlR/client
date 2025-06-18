AddNewInputItem = {}

function AddNewInputItem.main(param)
    local parent = GUI:Win_Create("AddNewInputItem", 0, 0, 0, 0, false, false, true, true)
    loadConfigSettingExport(parent, "add_new_input_item")
    AddNewInputItem._ui = GUI:ui_delegate(parent)

    AddNewInputItem.param = param
    AddNewInputItem.ScrollView_items = AddNewInputItem._ui["ScrollView_items"]

    local screenW = SL:GetMetaValue("SCREEN_WIDTH")
    local screenH = SL:GetMetaValue("SCREEN_HEIGHT")

    local Layout_close = AddNewInputItem._ui["Layout_close"]
    GUI:setContentSize(Layout_close, screenW, screenH)

    local function closeFunc()
        GUI:Win_Close(parent)
    end

    GUI:addOnClickEvent(AddNewInputItem._ui["Button_close"], closeFunc)
    GUI:addOnClickEvent(Layout_close, closeFunc)

    local input_add_id = AddNewInputItem._ui["input_add_id"]
    AddNewInputItem.input_add_id = input_add_id
    GUI:TextInput_setInputMode(input_add_id, 2)
    GUI:TextInput_setTextHorizontalAlignment(input_add_id, 1)

    local input_add_name = AddNewInputItem._ui["input_add_name"]
    AddNewInputItem.input_add_name = input_add_name
    GUI:TextInput_setTextHorizontalAlignment(input_add_name, 1)

    local Button_sure = AddNewInputItem._ui["Button_sure"]
    GUI:addOnClickEvent(Button_sure, function()
        GUI:delayTouchEnabled(Button_sure)

        local inputId = GUI:TextInput_getString(input_add_id)
        if string.len(inputId) == 0 then
            SL:ShowSystemTips("请输入要新增的ID")
            return
        end

        if AddNewInputItem.param.items[tonumber(inputId)] then
            SL:ShowSystemTips("已存在，请重新输入")
            GUI:TextInput_setString(input_add_id, "")
            return
        end

        local inputName = GUI:TextInput_getString(input_add_name)
        if string.len(inputName) == 0 then
            SL:ShowSystemTips("请输入要新增的")
            return
        end

        AddNewInputItem.param.items[tonumber(inputId)] = inputName
        AddNewInputItem.updateItems()
        if AddNewInputItem.param.callback then
            AddNewInputItem.param.callback({ key = tonumber(inputId), name = inputName }, 1)
        end
        SL:ShowSystemTips("成功新增：" .. inputId .. inputName)
        GUI:TextInput_setString(input_add_id, "")
        GUI:TextInput_setString(input_add_name, "")
    end)

    AddNewInputItem.updateItems()
end

function AddNewInputItem.updateItems()
    GUI:removeAllChildren(AddNewInputItem.ScrollView_items)
    local itemsData = AddNewInputItem.param.items or {}
    local keys = table.keys(itemsData)
    for idx, key in ipairs(keys) do
        local cell = GUI:Layout_Create(AddNewInputItem.ScrollView_items, "cell" .. key, 0, 0, 200, 34, true)
        GUI:Layout_setBackGroundColorType(cell, 1)
        GUI:Layout_setBackGroundColor(cell, idx % 2 == 0 and "#00ffff" or "#ff00ff")
        GUI:Layout_setBackGroundColorOpacity(cell, 128)

        local text_key = GUI:Text_Create(cell, "text_key", 50, 17, 16, "#FFFFFF", key)
        GUI:setAnchorPoint(text_key, 0.5, 0.5)

        local text_name = GUI:Text_Create(cell, "text_name", 133, 17, 16, "#FFFFFF", AddNewInputItem.param.items[key])
        GUI:setAnchorPoint(text_name, 0.5, 0.5)

        local btnDel = GUI:Button_Create(cell, "btnDel", 185, 17, "res/public/1900000620.png")
        GUI:setAnchorPoint(btnDel, 0.5, 0.5)
        GUI:addOnClickEvent(btnDel, function()
            if AddNewInputItem.param.callback then
                AddNewInputItem.param.callback({key = key}, 0)
            end
            table.remove(AddNewInputItem.param.items, key)
            AddNewInputItem.updateItems()
            SL:ShowSystemTips("删除成功")
        end)
    end
    GUI:UserUILayout(AddNewInputItem.ScrollView_items, { dir = 1, addDir = 1 })
end

return AddNewInputItem