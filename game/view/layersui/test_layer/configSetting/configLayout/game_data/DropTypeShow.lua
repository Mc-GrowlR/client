-- DropTypeShow 掉落分类显示
DropTypeShow = {}

function DropTypeShow.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/drop_type_show")

    DropTypeShow._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local value = SL:GetMetaValue("GAME_DATA", key) or ""
    local tmpValue = value == "" and {} or string.split(value, "|")
    local tValue = {}
    for _, value in ipairs(tmpValue) do
        if value and string.len(value) > 0 then
            local param = string.split(value, "#")
            local id = param[2] and tonumber(param[2])
            if id then
                tValue[id] = {open = tonumber(param[1]) == 1, name = param[3] or ""}
            end
        end
    end

    local ScrollView_items = DropTypeShow._ui["ScrollView_items"]

    local input = {}
    for id = 1, 10 do
        local cell = DropTypeShow.createCell()
        GUI:addChild(ScrollView_items, cell)

        local enable = tValue[id] and tValue[id].open or false
        local CheckBox_able = GUI:getChildByName(cell, "CheckBox_able")
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_off"), not enable)
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_on"), enable)

        local name = tValue[id] and tValue[id].name or ""
        local input_name = GUI:getChildByName(cell, "Input_name")
        GUI:TextInput_setString(input_name, name)
        GUI:TextInput_setPlaceHolder(input_name, "分类" .. id)
        input[id] = input_name

        GUI:addOnClickEvent(cell, function()
            local enable = tValue[id] and tValue[id].open or false
            enable = not enable
            GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_off"), not enable)
            GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_on"), enable)
            tValue[id] = tValue[id] or {} 
            tValue[id].open = enable
        end)
    end

    GUI:UserUILayout(ScrollView_items, {dir = 3, gap = {x = 0, l = 2},  addDir = 1, colnum = 2, autosize = true,})

    GUI:addOnClickEvent(DropTypeShow._ui["Button_sure"], function()
        GUI:delayTouchEnabled(DropTypeShow._ui["Button_sure"], 0.5)
        local data = {}
        for i = 1, 10 do
            local name = GUI:TextInput_getString(input[i]) or ""
            local isOpen = tValue[i] and tValue[i].open or false
            if isOpen or (string.len(name) > 0) then
                local value1 = isOpen and 1 or 0
                table.insert(data, string.format("%s#%s#%s", value1, i, name))
            end
        end
        local saveValue = table.concat(data, "|")
        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)
        SL:ShowSystemTips("修改成功")
    end)
end

function DropTypeShow.createCell()
    local parent = GUI:Node_Create(-1, "node", 0, 0)
    loadConfigSettingExport(parent, "game_data/drop_type_cell")
    local cell = GUI:getChildByName(parent, "click_cell")
    GUI:removeFromParent(cell)
    return cell
end

return DropTypeShow