-- bag_row_col_max 大背包格子设置
SetBagRowColMax = {}

function SetBagRowColMax.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/set_bag_row_col_max")

    SetBagRowColMax._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local slices = string.split(SL:GetMetaValue("GAME_DATA", key), "|")

    local row, col = tonumber(slices[1]) or 8, tonumber(slices[2]) or 5
    local input_row = SetBagRowColMax._ui["input_row"]
    local input_col = SetBagRowColMax._ui["input_col"]
    GUI:TextInput_setInputMode(input_row, 2)
    GUI:TextInput_setInputMode(input_col, 2)
    GUI:TextInput_setString(input_row, row)
    GUI:TextInput_setString(input_col, col)
    GUI:TextInput_addOnEvent(input_row, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_row)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("横向格子不能为空")
                GUI:TextInput_setString(input_row, row)
                return
            end
            if tonumber(inputStr) == 0 then
                SL:ShowSystemTips("横向格子不能为0")
                GUI:TextInput_setString(input_row, row)
                return
            end
            row = tonumber(inputStr)
        end
    end)
    GUI:TextInput_addOnEvent(input_col, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_col)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("纵向格子不能为空")
                GUI:TextInput_setString(input_col, col)
                return
            end
            if tonumber(inputStr) == 0 then
                SL:ShowSystemTips("纵向格子不能为0")
                GUI:TextInput_setString(input_col, col)
                return
            end
            col = tonumber(inputStr)
        end
    end)

    GUI:addOnClickEvent(SetBagRowColMax._ui["Button_sure"], function()
        GUI:delayTouchEnabled(SetBagRowColMax._ui["Button_sure"], 0.5)

        local saveValue = string.format("%s|%s", row, col)

        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:ShowSystemTips("修改成功")
    end)
end

return SetBagRowColMax