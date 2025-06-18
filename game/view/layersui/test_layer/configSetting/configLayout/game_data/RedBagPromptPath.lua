-- 红点图片路径配置 
RedBagPromptPath = {}

local UI_NAME_MOBILE = {
    "input_m_path",
    "input_m_x",
    "input_m_y",
    "input_m_scale",
}

local UI_NAME_PC = {
    "input_pc_path",
    "input_pc_x",
    "input_pc_y",
    "input_pc_scale",
}

function RedBagPromptPath.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/red_bag_prompt_path")

    RedBagPromptPath._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local slices = string.split(SL:GetMetaValue("GAME_DATA", key), "|")
    local pcInfo = string.split(slices[1],"#")
    local mobleInfo = string.split(slices[2],"#")

    for i = 1, #UI_NAME_MOBILE do 
        local name = UI_NAME_MOBILE[i]
        local ui_input = RedBagPromptPath._ui[name]
        GUI:TextInput_setString(ui_input, mobleInfo[i] or "")
        GUI:TextInput_addOnEvent(ui_input, function(_, eventType)
            if eventType == 1 then
                local inputStr = GUI:TextInput_getString(ui_input)
                if string.len(inputStr) == 0 then
                    SL:ShowSystemTips("缩放值不能为空")
                    GUI:TextInput_setString(ui_input, mobleInfo[i] or "")
                    return
                end

                mobleInfo[i] = inputStr
            end
        end)
    end 

    for i = 1, #UI_NAME_PC do 
        local name = UI_NAME_PC[i]
        local ui_input = RedBagPromptPath._ui[name]
        GUI:TextInput_setString(ui_input, pcInfo[i] or "")
        GUI:TextInput_addOnEvent(ui_input, function(_, eventType)
            if eventType == 1 then
                local inputStr = GUI:TextInput_getString(ui_input)
                if string.len(inputStr) == 0 then
                    SL:ShowSystemTips("缩放值不能为空")
                    GUI:TextInput_setString(ui_input, mobleInfo[i] or "")
                    return
                end

                pcInfo[i] = inputStr
            end
        end)
    end 

    GUI:addOnClickEvent(RedBagPromptPath._ui["Button_sure"], function()
        GUI:delayTouchEnabled(RedBagPromptPath._ui["Button_sure"], 0.5)

        local mobileStr = mobleInfo[1].."#"..mobleInfo[2].."#"..mobleInfo[3].."#"..mobleInfo[4]
        local pcStr = pcInfo[1].."#"..pcInfo[2].."#"..pcInfo[3].."#"..pcInfo[4]
        local saveStr = mobileStr.."|"..pcStr

        SL:SetMetaValue("GAME_DATA", key, saveStr)
        SAVE_GAME_DATA(key, saveStr)

        SL:ShowSystemTips("修改成功")
    end)
end

return RedBagPromptPath