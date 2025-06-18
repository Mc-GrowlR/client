-- currency_shield 屏蔽货币消耗提示 "不显示的id1|不显示的id2#不播放声音的id1|不播放声音的id2"
CurrencyShield = {}

local localSaveKey = "CurrencyShieldValue"

function CurrencyShield.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/currency_shield")

    CurrencyShield._ui = GUI:ui_delegate(parent)

    CurrencyShield.noShowList = {}
    CurrencyShield.noSoundList = {}

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    -- local value
    local localValue = SL:GetLocalString(localSaveKey)
    local tLocalValue = localValue ~= "" and string.split(localValue, "|") or {}
    CurrencyShield._tLocalValue = {}
    for _, value in ipairs(tLocalValue) do
        local tValue = string.split(value, "#")
        CurrencyShield._tLocalValue[tonumber(tValue[1])] = tonumber(tValue[2])
    end

    local value = SL:GetMetaValue("GAME_DATA", key)
    local noShowString = value and string.split(value, "#")
    if noShowString and noShowString[1] and noShowString[1] ~= "" then
        local no_show_list = string.split(noShowString[1], "|")
        for k, v in pairs(no_show_list) do
            CurrencyShield.noShowList[tonumber(v)] = 1
            CurrencyShield._tLocalValue[tonumber(v)] = 1
        end
    end

    -- no sound 
    if noShowString and noShowString[2] and noShowString[2] ~= "" then
        local no_sound_list = string.split(noShowString[2], "|")
        for k, v in pairs(no_sound_list) do
            CurrencyShield.noSoundList[tonumber(v)] = 1
        end
    end

    CurrencyShield.createCheckBoxCell()

    GUI:addOnClickEvent(CurrencyShield._ui["Button_set"], function()
        SL:Require("game/view/layersui/test_layer/configSetting/configLayout/game_data/AddNewItem", true)
        local data = {}
        local keys = table.keys(CurrencyShield._tLocalValue)
        table.sort(keys)
        data.items = keys
        data.inputPlaceHolder = "请输入货币id"
        data.callback = CurrencyShield.onSetCallback
        AddNewItem.main(data)
    end)

    GUI:addOnClickEvent(CurrencyShield._ui["Button_sure"], function()
        GUI:delayTouchEnabled(CurrencyShield._ui["Button_sure"], 0.5)

        local keysLocal = table.keys(CurrencyShield._tLocalValue)
        table.sort(keysLocal)
        local tLocal = {}
        local noShowKeys = {}
        for _, key in ipairs(keysLocal) do
            table.insert(tLocal, key .. "#" .. CurrencyShield._tLocalValue[key])
            if CurrencyShield._tLocalValue[key] > 0 then
                table.insert(noShowKeys, key)
            end
        end
        local strLocal = table.concat(tLocal, "|")
        SL:SetLocalString(localSaveKey, strLocal)

        table.sort(noShowKeys)
        local noSoundKeys = table.keys(CurrencyShield.noSoundList)
        table.sort(noSoundKeys)
        local strValue = table.concat(noShowKeys, "|") .. "#" .. table.concat(noSoundKeys, "|")
        SL:SetMetaValue("GAME_DATA", key, strValue)
        SAVE_GAME_DATA(key, strValue)

        SL:ShowSystemTips("修改成功")
    end)
end

function CurrencyShield.createCheckBoxCell()
    local ScrollView_items = CurrencyShield._ui["ScrollView_items"]
    GUI:removeAllChildren(ScrollView_items)

    if not next(CurrencyShield._tLocalValue or {}) then
        return
    end

    local keys = table.keys(CurrencyShield._tLocalValue)
    table.sort(keys)

    for _, key in ipairs(keys) do
        local item = GUI:Layout_Create(ScrollView_items, "item" .. key, 0, 0, 100, 30, false)
        GUI:setTouchEnabled(item, true)
        local checkBox = GUI:CheckBox_Create(item, "checkBox", 0, 15, "res/public/1900000550.png", "res/public/1900000551.png")
        GUI:setAnchorPoint(checkBox, 0, 0.5)
        GUI:CheckBox_setSelected(checkBox, CurrencyShield._tLocalValue[key] == 1)
        GUI:setTouchEnabled(checkBox, false)

        local checkText = GUI:Text_Create(item, "checkText", 30, 15, 14, "#ffffff", key .. SL:GetMetaValue("ITEM_NAME", key))
        GUI:setAnchorPoint(checkText, 0, 0.5)

        GUI:addOnClickEvent(item, function()
            local isSel = not GUI:CheckBox_isSelected(checkBox)
            GUI:CheckBox_setSelected(checkBox, isSel)
            CurrencyShield._tLocalValue[key] = isSel and 1 or 0
            CurrencyShield.noShowList[key] = isSel and 1 or nil
            CurrencyShield.noSoundList[key] = isSel and 1 or nil
            dump(CurrencyShield._tLocalValue, "CurrencyShield._tLocalValue:::")
        end)
    end
    GUI:UserUILayout(ScrollView_items, { dir = 3, addDir = 1, colnum = 3, autosize = true })
end

-- operType 0删除 1增加
function CurrencyShield.onSetCallback(data, operType)
    if operType == 0 then
        CurrencyShield._tLocalValue[tonumber(data)] = nil
        CurrencyShield.noShowList[tonumber(data)] = nil
        CurrencyShield.noSoundList[tonumber(data)] = nil
    elseif operType == 1 then
        CurrencyShield._tLocalValue[tonumber(data)] = 1
        CurrencyShield.noShowList[tonumber(data)] = 1
        CurrencyShield.noSoundList[tonumber(data)] = 1
    end
    CurrencyShield.createCheckBoxCell()
end

return CurrencyShield