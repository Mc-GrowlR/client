-- HumanPaperback 人物简装外观显示 "6#32|7#31|8#33"  clothID|weaponID
HumanPaperback = {}

function HumanPaperback.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/human_paperback")

    HumanPaperback._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local features = { {}, {}, {} }
    local temp = SL:GetMetaValue("GAME_DATA", "HumanPaperback")
    if temp then
        local slices = string.split(temp, "|")
        for i, slice in ipairs(slices) do
            local slice2 = string.split(slice, "#")
            features[i] = { tonumber(slice2[1]), tonumber(slice2[2]) }
        end
    end

    local input = {}
    for i = 1, 3 do
        input[i] = input[i] or {}
        for j = 1, 2 do
            local inputCell = HumanPaperback._ui["input" .. i .. "_" .. j]
            GUI:TextInput_setInputMode(inputCell, 2)
            GUI:TextInput_setString(inputCell, features[i][j] or "")
            input[i][j] = inputCell
        end
    end

    for i = 4, 15 do
        local cell = HumanPaperback.createCell()
        GUI:ListView_pushBackCustomItem(HumanPaperback._ui.ListView, cell)
        local ui = ui_delegate(cell)

        input[i] = input[i] or {}
        GUI:Text_setString(ui.Text_job, GetJobName(i))
        GUI:TextInput_setInputMode(ui.input_weapon, 2)
        GUI:TextInput_setString(ui.input_weapon, features[i] and features[i][1] or "")
        input[i][1] = ui.input_weapon
        GUI:TextInput_setInputMode(ui.input_cloth, 2)
        GUI:TextInput_setString(ui.input_cloth, features[i] and features[i][2] or "")
        input[i][2] = ui.input_cloth
    end

    GUI:addOnClickEvent(HumanPaperback._ui["Button_sure"], function()
        GUI:delayTouchEnabled(HumanPaperback._ui["Button_sure"], 0.5)

        local saveValue = ""
        for i = 1, 15 do
            local str1 = input[i][1] and GUI:TextInput_getString(input[i][1]) or ""
            local str2 = input[i][2] and GUI:TextInput_getString(input[i][2]) or ""
            saveValue = saveValue .. str1 .. "#" .. str2 .. (i ~= 15 and "|" or "")
        end

        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:ShowSystemTips("修改成功")
    end)
end

function HumanPaperback.createCell()
    local parent = GUI:Node_Create(-1, "node", 0, 0)
    loadConfigSettingExport(parent, "game_data/human_paperback_cell")
    local cell = GUI:getChildByName(parent, "Layout_cell")
    GUI:removeFromParent(cell)

    return cell
end

return HumanPaperback