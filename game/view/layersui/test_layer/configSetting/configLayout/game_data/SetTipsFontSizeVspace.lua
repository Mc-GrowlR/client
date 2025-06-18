-- setTipsFontSizeVspace 配置TIPS字体大小及上下间隔
SetTipsFontSizeVspace = {}

function SetTipsFontSizeVspace.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/set_tips_font_size_vspace")

    SetTipsFontSizeVspace._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local mobileFontSize, mobileV, pcFontSize, pcV = "", "", "", ""
    local setData = SL:GetMetaValue("GAME_DATA", key)
    if setData and string.len(setData) then
        if tonumber(setData) and tonumber(setData) == 0 then
        else
            local setList = string.split(setData, "|")
            if setList[1] or setList[2] then
                local dataMobile, dataPC = setList[1], setList[2]

                if dataMobile and string.len(dataMobile) > 0 then
                    local valueList = string.split(dataMobile, "#")
                    if valueList[1] and tonumber(valueList[1]) then
                        mobileFontSize = tonumber(valueList[1])
                    end
                    if valueList[2] and tonumber(valueList[2]) then
                        mobileV = tonumber(valueList[2])
                    end
                end

                if dataPC and string.len(dataPC) > 0 then
                    local valueList = string.split(dataPC, "#")
                    if valueList[1] and tonumber(valueList[1]) then
                        pcFontSize = tonumber(valueList[1])
                    end
                    if valueList[2] and tonumber(valueList[2]) then
                        pcV = tonumber(valueList[2])
                    end
                end
            end
        end
    end

    local input_mobile_font = SetTipsFontSizeVspace._ui["input_mobile_font"]
    local input_mobile_v = SetTipsFontSizeVspace._ui["input_mobile_v"]
    GUI:TextInput_setInputMode(input_mobile_font, 2)
    GUI:TextInput_setString(input_mobile_font, mobileFontSize)
    GUI:TextInput_setString(input_mobile_v, mobileV)
    GUI:TextInput_addOnEvent(input_mobile_font, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_mobile_font)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("字号不能为空")
                GUI:TextInput_setString(input_mobile_font, mobileFontSize)
                return
            end
            if tonumber(inputStr) == 0 then
                SL:ShowSystemTips("字号不能为0")
                GUI:TextInput_setString(input_mobile_font, mobileFontSize)
                return
            end
            mobileFontSize = tonumber(inputStr)
        end
    end)
    GUI:TextInput_addOnEvent(input_mobile_v, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_mobile_v)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("间隔不能为空")
                GUI:TextInput_setString(input_mobile_v, mobileV)
                return
            end
            mobileV = tonumber(inputStr)
        end
    end)

    local input_pc_font = SetTipsFontSizeVspace._ui["input_pc_font"]
    local input_pc_v = SetTipsFontSizeVspace._ui["input_pc_v"]
    GUI:TextInput_setInputMode(input_pc_font, 2)
    GUI:TextInput_setString(input_pc_font, pcFontSize)
    GUI:TextInput_setString(input_pc_v, pcV)
    GUI:TextInput_addOnEvent(input_pc_font, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_pc_font)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("字号不能为空")
                GUI:TextInput_setString(input_pc_font, pcFontSize)
                return
            end
            if tonumber(inputStr) == 0 then
                SL:ShowSystemTips("字号不能为0")
                GUI:TextInput_setString(input_pc_font, pcFontSize)
                return
            end
            pcFontSize = tonumber(inputStr)
        end
    end)
    GUI:TextInput_addOnEvent(input_pc_v, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_pc_v)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("间隔不能为空")
                GUI:TextInput_setString(input_pc_v, pcV)
                return
            end
            pcV = tonumber(inputStr)
        end
    end)

    GUI:addOnClickEvent(SetTipsFontSizeVspace._ui["Button_sure"], function()
        GUI:delayTouchEnabled(SetTipsFontSizeVspace._ui["Button_sure"], 0.5)

        if mobileFontSize == "" or mobileV == "" then
            SL:ShowSystemTips("字号不能为空")
            return
        end

        if pcFontSize == "" or pcV == "" then
            SL:ShowSystemTips("间隔不能为空")
            return
        end

        local saveValue = string.format("%s#%s|%s#%s", mobileFontSize, mobileV, pcFontSize, pcV)

        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:ShowSystemTips("修改成功")
    end)
end

return SetTipsFontSizeVspace