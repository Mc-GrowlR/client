-- bag_storage_row_col_max 大仓库格子设置
PCFontTypeSize = {}

function PCFontTypeSize.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/pc_font_type_size")

    PCFontTypeSize._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local fontType = 2
    local fontSize = 12
    local fontData = SL:GetMetaValue("GAME_DATA", key)
    if type(fontData) == "table" then 
        fontType = fontData[1] or 2
        fontSize = fontData[2] or 12
    else 
        local slices = string.split(SL:GetMetaValue("GAME_DATA", key), "#")
        fontType = slices[1] or 2
        fontSize = slices[2] or 12
    end 

    local input_type = PCFontTypeSize._ui["input_type"]
    local input_size = PCFontTypeSize._ui["input_size"]
    GUI:TextInput_setInputMode(input_type, 2)
    GUI:TextInput_setInputMode(input_size, 2)
    GUI:TextInput_setString(input_type, fontType)
    GUI:TextInput_setString(input_size, fontSize)
    GUI:TextInput_addOnEvent(input_type, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_type)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("不能为空")
                GUI:TextInput_setString(input_type, fontType)
                return
            end
            fontType = tonumber(inputStr)
        end
    end)
    GUI:TextInput_addOnEvent(input_size, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_size)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("不能为空")
                GUI:TextInput_setString(input_size, fontSize)
                return
            end
            fontSize = tonumber(inputStr)
        end
    end)

    GUI:addOnClickEvent(PCFontTypeSize._ui["Button_sure"], function()
        GUI:delayTouchEnabled(PCFontTypeSize._ui["Button_sure"], 0.5)

        local saveValue = string.format("%s#%s", fontType, fontSize)

        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:ShowSystemTips("修改成功")
    end)
end

return PCFontTypeSize