-- 字段：setTipsAttrTitle
-- 格式例子：[基础属性1]：#250|[元素属性]：#250|[附加属性]：#250|[物品来源]：#250|[宝石属性]：#255
-- 字段描述：格式：文本#颜色Id|文本#颜色Id）
TipsAttrSetting = {}

function TipsAttrSetting.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/tips_attr")

    TipsAttrSetting._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    TipsAttrSetting._data = {}
    TipsAttrSetting._defaultData = {
        [1] = {name = "[基础属性]：", color = 154},
        [2] = {name = "[元素属性]：", color = 154},
        [3] = {name = "[附加属性]：", color = 154},
        [4] = {name = "[物品来源]：", color = 154},
        [5] = {name = "[宝石属性]：", color = 154},
    }

    local data = SL:GetMetaValue("GAME_DATA", "setTipsAttrTitle")
    if data then 
        local st1 = string.split(data, "|")
        for i, v in ipairs(st1) do
            local st2 = string.split(v, "#")
            local name = st2[1]
            local color = tonumber(st2[2])
            TipsAttrSetting._data[i] = { name = name, color = color }
        end
    end 

    for i = 1, 5 do 
        local ui_name = GUI:getChildByName(TipsAttrSetting._ui["Text_name"..i], "input_name")
        GUI:TextInput_setInputMode(ui_name, 1)
        if TipsAttrSetting._data[i] then 
            local name = TipsAttrSetting._data[i].name or ""
            GUI:TextInput_setString(ui_name, name)
        end 

        GUI:TextInput_addOnEvent(ui_name, function(_, eventType)
            if eventType == 1 then
                local inputStr = GUI:TextInput_getString(ui_name)
                if string.len(inputStr) == 0 then
                    SL:ShowSystemTips("不能为空")
                    return
                end
            end
        end)
    end 

    for i = 1, 5 do 
        local ui_color = GUI:getChildByName(TipsAttrSetting._ui["Text_color"..i], "input_color")
        GUI:TextInput_setInputMode(ui_color, 2)
        if TipsAttrSetting._data[i] then 
            local color = TipsAttrSetting._data[i].color or ""
            GUI:TextInput_setString(ui_color, color)
        end 

        GUI:TextInput_addOnEvent(ui_color, function(_, eventType)
            if eventType == 1 then
                local inputStr = GUI:TextInput_getString(ui_color)
                if string.len(inputStr) == 0 then
                    SL:ShowSystemTips("不能为空")
                    return
                end
            end
        end)
    end 


    GUI:addOnClickEvent(TipsAttrSetting._ui["Button_sure"], function()
        GUI:delayTouchEnabled(TipsAttrSetting._ui["Button_sure"], 0.5)

        for i = 1, 5 do 
            local ui_name = GUI:getChildByName(TipsAttrSetting._ui["Text_name"..i], "input_name")
            local ui_color = GUI:getChildByName(TipsAttrSetting._ui["Text_color"..i], "input_color")

            local inputName = GUI:TextInput_getString(ui_name)
            local inputColor = GUI:TextInput_getString(ui_color)

            if not TipsAttrSetting._data[i] then 
                TipsAttrSetting._data[i] = {}
            end 

            if string.len(inputName) == 0 then 
                TipsAttrSetting._data[i].name = TipsAttrSetting._defaultData[i].name
            else 
                TipsAttrSetting._data[i].name = inputName
            end 

            if string.len(inputColor) == 0 then 
                if not TipsAttrSetting._data[i] then 
                    TipsAttrSetting._data[i].color = TipsAttrSetting._defaultData[i].color
                end 
                TipsAttrSetting._data[i].color = TipsAttrSetting._defaultData[i].color
            else 
                TipsAttrSetting._data[i].color = tonumber(inputColor)
            end 
        end 

        local saveValue = ""
        for i, v in ipairs(TipsAttrSetting._data) do 
            local str = v.name.."#"..v.color
            saveValue = saveValue..str.."|"
        end 

        saveValue = string.sub(saveValue, 1, -2)
        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:ShowSystemTips("修改成功")
    end)
end

return TipsAttrSetting