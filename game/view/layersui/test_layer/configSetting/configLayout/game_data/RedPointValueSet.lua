
RedPointValueSet = {}

function RedPointValueSet.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/red_point_value_set")

    RedPointValueSet._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    RedPointValueSet._originData = {}

    local sValue = SL:GetMetaValue("GAME_DATA", "RedPointValue")
    if sValue and string.len(sValue) > 0 then 
        local data = string.split(sValue, "|")
        for i, v in ipairs(data) do
            local st = string.split(v, "#")
            local name = st[1]
            local value = st[2]
            RedPointValueSet._originData[i] = { name = name, value = value }
        end
    end 

    local input_name = RedPointValueSet._ui["input_name"]
    GUI:TextInput_setInputMode(input_name, 1)
    GUI:TextInput_setString(input_name, "")

    local input_value = RedPointValueSet._ui["input_value"]
    GUI:TextInput_setInputMode(input_value, 1)
    GUI:TextInput_setString(input_value, "")

    GUI:TextInput_addOnEvent(input_name, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_name)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("变量名不能为空")
                GUI:TextInput_setString(input_name, "")
                return
            end
        end
    end)

    GUI:TextInput_addOnEvent(input_value, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_value)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("变量值不能为空")
                GUI:TextInput_setString(input_value, "")
                return
            end
        end
    end)

    GUI:addOnClickEvent(RedPointValueSet._ui["Button_add"], function()
        local name = GUI:TextInput_getString(input_name)
        local value = GUI:TextInput_getString(input_value)
        if string.len(name) == 0 then
            SL:ShowSystemTips("变量名不能为空")
            return
        end

        if string.len(value) == 0 then
            SL:ShowSystemTips("变量值不能为空")
            return
        end

        for i, v in ipairs(RedPointValueSet._originData) do 
            if name == v.name then 
                SL:ShowSystemTips("变量名重复")
                return 
            end 

            if value == v.value then 
                SL:ShowSystemTips("变量值重复")
                return 
            end 
        end 

        GUI:TextInput_setString(input_name, "")
        GUI:TextInput_setString(input_value, "")

        local data = {}
        data.name = name 
        data.value = value
        table.insert(RedPointValueSet._originData, data)

        RedPointValueSet.refresRankDescList()
    end)

    GUI:addOnClickEvent(RedPointValueSet._ui["Button_clear"], function()
        RedPointValueSet._originData = {}
        GUI:TextInput_setString(input_name, "")
        GUI:TextInput_setString(input_value, "")

        GUI:ListView_removeAllItems(RedPointValueSet._ui["LV_item"])
    end)

    GUI:addOnClickEvent(RedPointValueSet._ui["Button_sure"], function()
        GUI:delayTouchEnabled(RedPointValueSet._ui["Button_sure"], 0.5)

        local saveValue = ""
        for i, v in ipairs(RedPointValueSet._originData) do 
            local str = v.name.."#"..v.value
            saveValue = saveValue..str.."|"
        end 

        if string.len(saveValue) == 0 then 
            SL:ShowSystemTips("请添加")
            return 
        end 

        saveValue = string.sub(saveValue, 1, -2)
        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:ShowSystemTips("修改成功")
    end)

    RedPointValueSet.refresRankDescList()
end

function RedPointValueSet.refresRankDescList()
    GUI:ListView_removeAllItems(RedPointValueSet._ui["LV_item"])
    GUI:setVisible(RedPointValueSet._ui["panel_cell"], false)
    for i, v in ipairs(RedPointValueSet._originData) do 
        local cell = GUI:Clone(RedPointValueSet._ui["panel_cell"])
        GUI:setVisible(cell, true)
        GUI:ListView_pushBackCustomItem(RedPointValueSet._ui["LV_item"], cell)

        local ui_name = GUI:getChildByName(cell, "Text_name")
        GUI:Text_setString(ui_name, v.name)

        local ui_value = GUI:getChildByName(cell, "Text_value")
        GUI:Text_setString(ui_value, v.value)
    end
end

return RedPointValueSet