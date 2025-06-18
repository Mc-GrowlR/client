-- noDigMonsters 隐藏挖取怪物图标 "1#2#3#9#10#11#12#13#14#15#16#17#18#19#20#21#22#23#24#25#26"
NoDigMonsters = {}

local localSaveKey = "NoDigMonstersValue"

function NoDigMonsters.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/no_dig_monsters")

    NoDigMonsters._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    -- local value
    local localValue = SL:GetLocalString(localSaveKey)
    local tLocalValue = localValue ~= "" and string.split(localValue, "|") or {}
    NoDigMonsters._tLocalValue = {}
    for _, value in ipairs(tLocalValue) do
        local tValue = string.split(value, "#")
        if tonumber(tValue[1]) and tonumber(tValue[2]) then
            NoDigMonsters._tLocalValue[tonumber(tValue[1])] = tonumber(tValue[2])
        end
    end

    local value = SL:GetMetaValue("GAME_DATA", key) or ""
    for _, v in ipairs(string.split(value, "#")) do
        if tonumber(v) then
            NoDigMonsters._tLocalValue[tonumber(v)] = 1
        end
    end
    
    NoDigMonsters.createCheckBoxCell()

    GUI:addOnClickEvent(NoDigMonsters._ui["Button_set"], function()
        SL:Require("game/view/layersui/test_layer/configSetting/configLayout/game_data/AddNewItem", true)
        local data = {}
        local keys = table.keys(NoDigMonsters._tLocalValue)
        table.sort(keys)
        data.items = keys
        data.suffix = ""
        data.inputPlaceHolder = "请输入怪物IDX"
        data.callback = NoDigMonsters.onSetCallback
        AddNewItem.main(data)
    end)

    GUI:addOnClickEvent(NoDigMonsters._ui["Button_sure"], function()
        GUI:delayTouchEnabled(NoDigMonsters._ui["Button_sure"], 0.5)

        local keys = table.keys(NoDigMonsters._tLocalValue)
        table.sort(keys)
        local tValue = {}
        local tLocal = {}
        for _, key in ipairs(keys) do
            table.insert(tLocal, key.."#"..NoDigMonsters._tLocalValue[key])
            if NoDigMonsters._tLocalValue[key] == 1 then
                table.insert(tValue, key)
            end
        end
        local strValue = table.concat(tValue, "#")
        local strLocal = table.concat(tLocal, "|")

        SL:SetMetaValue("GAME_DATA", key, strValue)
        SAVE_GAME_DATA(key, strValue)

        SL:SetLocalString(localSaveKey, strLocal)

        SL:ShowSystemTips("修改成功")
    end)
end

function NoDigMonsters.createCheckBoxCell()
    local ScrollView_items = NoDigMonsters._ui["ScrollView_items"]
    GUI:removeAllChildren(ScrollView_items)

    if not next(NoDigMonsters._tLocalValue) then
        return
    end

    local keys = table.keys(NoDigMonsters._tLocalValue)
    table.sort(keys)

    for _, key in ipairs(keys) do
        local item = GUI:Layout_Create(ScrollView_items, "item" .. key, 0, 0, 75, 30, false)
        GUI:setTouchEnabled(item, true)
        local checkBox = GUI:CheckBox_Create(item, "checkBox", 0, 15, "res/public/1900000550.png", "res/public/1900000551.png")
        GUI:setAnchorPoint(checkBox, 0, 0.5)
        GUI:CheckBox_setSelected(checkBox, NoDigMonsters._tLocalValue[key] == 1)
        GUI:setTouchEnabled(checkBox, false)

        local checkText = GUI:Text_Create(item, "checkText", 30, 15, 14, "#ffffff", key)
        GUI:setAnchorPoint(checkText, 0, 0.5)

        GUI:addOnClickEvent(item, function()
            local isSel = not GUI:CheckBox_isSelected(checkBox)
            GUI:CheckBox_setSelected(checkBox, isSel)
            NoDigMonsters._tLocalValue[key] = isSel and 1 or 0
            dump(NoDigMonsters._tLocalValue, "NoDigMonsters._tLocalValue:::")
        end)
    end
    GUI:UserUILayout(ScrollView_items, {dir = 3, addDir = 1, colnum = 4, autosize = true})
end

-- operType 0删除 1增加
function NoDigMonsters.onSetCallback(data, operType)
    if operType == 0 then
        NoDigMonsters._tLocalValue[tonumber(data)] = nil
    elseif operType == 1 then
        NoDigMonsters._tLocalValue[tonumber(data)] = 1
    end
    NoDigMonsters.createCheckBoxCell()
end

return NoDigMonsters