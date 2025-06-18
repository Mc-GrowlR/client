
PCMapCenterOffset = {}

function PCMapCenterOffset.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/pc_map_center_offset")

    PCMapCenterOffset._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local value = SL:GetMetaValue("GAME_DATA", key)
    local pcOffsetX = nil
    local pcOffsetY = nil
    if type(value) == "string"  and string.len(value) > 0 then 
        local slices = string.split(value, "|")
        if tonumber(slices[1]) and tonumber(slices[2]) then
            pcOffsetX = tonumber(slices[1])
            pcOffsetY = tonumber(slices[2])
        end
    end 

    local input_x = PCMapCenterOffset._ui["input_x"]
    local input_y = PCMapCenterOffset._ui["input_y"]
    -- GUI:TextInput_setInputMode(input_x, 2)
    -- GUI:TextInput_setInputMode(input_y, 2)
    if pcOffsetX then
        GUI:TextInput_setString(input_x, pcOffsetX)
    end
    if pcOffsetY then
        GUI:TextInput_setString(input_y, pcOffsetY)
    end
    GUI:TextInput_addOnEvent(input_x, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_x)
            if not tonumber(inputStr) then
                inputStr = ""
                GUI:TextInput_setString(input_x, "")
            end
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("X Y任一偏移不能为空")
            end
            pcOffsetX = tonumber(inputStr)
        end
    end)
    GUI:TextInput_addOnEvent(input_y, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_y)
            if not tonumber(inputStr) then
                inputStr = ""
                GUI:TextInput_setString(input_x, "")
            end
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("X Y任一偏移不能为空")
            end
            pcOffsetY = tonumber(inputStr)
        end
    end)

    GUI:addOnClickEvent(PCMapCenterOffset._ui["Button_sure"], function()
        GUI:delayTouchEnabled(PCMapCenterOffset._ui["Button_sure"], 0.5)

        if not pcOffsetX or not pcOffsetY then
            SL:ShowSystemTips("X Y任一偏移不能为空")
            return
        end

        local saveValue = string.format("%s|%s", pcOffsetX, pcOffsetY)

        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:ShowSystemTips("修改成功")
        
    end)
end

return PCMapCenterOffset