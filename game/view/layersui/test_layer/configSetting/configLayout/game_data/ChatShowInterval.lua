ChatShowInterval = {}

local setData = {
    [1] = {id = 1, value = 0, ui = "input_mob_chat"},
    [2] = {id = 2, value = 0, ui = "input_mob_rich"},
    [3] = {id = 3, value = 0, ui = "input_pc_chat"},
    [4] = {id = 4, value = 0, ui = "input_pc_rich"},
}

function ChatShowInterval.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/chat_show_interval")
    ChatShowInterval._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local ui = ChatShowInterval._ui

    -- 聊天条目间隔#富文本行间间隔  手机端|PC端  10#15|5#10
    local tempData = {}
    local value = SL:GetMetaValue("GAME_DATA", key)
    if value and string.len(value) > 0 then
        local st = string.split(value, "|")
        for i, str in ipairs(st) do 
            local st2 = string.split(str, "#")
            for j, str2 in ipairs(st2) do 
                table.insert(tempData, tonumber(str2))
            end 
        end 
    end

    for i, v in ipairs(tempData) do 
        if setData[i] then 
            setData[i].value = v
        end
    end  

    for i, data in ipairs(setData) do 
        local ui_input = ui[data.ui]
        if ui_input then 
            GUI:TextInput_setString(ui_input, data.value)
        end 
    end 

    GUI:addOnClickEvent(ChatShowInterval._ui["Button_sure"], function()
        GUI:delayTouchEnabled(ChatShowInterval._ui["Button_sure"], 0.5)

        local saveValue = ChatShowInterval.getInputInfo()

        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:ShowSystemTips("修改成功")
    end)
end

function ChatShowInterval.getInputInfo()
    local ui = ChatShowInterval._ui
    local info = ""
    local tempData = {}
    for i, data  in ipairs(setData) do 
        local ui_input = ui[data.ui]
        if ui_input then 
            local inputNum = tonumber( GUI:TextInput_getString(ui_input) )
            table.insert(tempData, inputNum)
        end 
    end 

    info = tempData[1].."#"..tempData[2].."|"..tempData[3].."#"..tempData[4]

    return info
end 


return ChatShowInterval