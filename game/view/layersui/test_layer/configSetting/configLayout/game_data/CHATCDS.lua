-- CHATCDS 聊天信息发送内容时间间隔
CHATCDS = {}

function CHATCDS.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/chat_cd")

    CHATCDS._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local value = SL:GetMetaValue("GAME_DATA", key) or ""
    local tValue = value == "" and {} or string.split(value, "|")
    for i = 1, 10 do
        local input = CHATCDS._ui["input"..i]
        GUI:TextInput_setInputMode(input, 2)
        GUI:TextInput_setString(input, tonumber(tValue[i]) or 0)
    end

    GUI:addOnClickEvent(CHATCDS._ui["Button_sure"], function()
        for i = 1, 10 do
            local input = CHATCDS._ui["input"..i]
            local inputStr = GUI:TextInput_getString(input)
            tValue[i] = inputStr or 0
        end

        local strValue = table.concat(tValue, "|")

        GUI:delayTouchEnabled(CHATCDS._ui["Button_sure"], 0.5)
        SL:SetMetaValue("GAME_DATA", key, strValue)
        SAVE_GAME_DATA(key, strValue)
        SL:ShowSystemTips("修改成功")
    end)
end

return CHATCDS