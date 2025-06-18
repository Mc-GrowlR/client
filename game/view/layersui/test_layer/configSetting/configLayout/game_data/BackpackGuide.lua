-- BackpackGuide 穿戴/拆分按钮配置
BackpackGuide = {}

local localSaveKey = "BackpackGuideValue3"

function BackpackGuide.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/backpack_guide")

    BackpackGuide._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local value = SL:GetMetaValue("GAME_DATA", key)  -- "1#1#41|42|43|44"
    if string.len(value) <= 0 then
        return
    end

    local tValue = string.split(value, "#")

    BackpackGuide._value1 = (tonumber(tValue[1]) or 0) > 0
    BackpackGuide._value2 = (tonumber(tValue[2]) or 0) > 0
    BackpackGuide._value3 = tValue[3]
    
    local localValue3 = SL:GetLocalString(localSaveKey)  -- 本地存的,41#1|42#0|43#1|44#1   实际配置的,41#43#44
    local tLocalValue3 = localValue3 ~= "" and string.split(localValue3, "|") or {}
    BackpackGuide._localValue3 = {}
    for index, value in ipairs(tLocalValue3) do
        local tValue = string.split(value, "#")
        BackpackGuide._localValue3[tonumber(tValue[1])] = tonumber(tValue[2])
    end

    local tValue3 = BackpackGuide._value3 ~= "" and string.split(BackpackGuide._value3, "|") or {}
    for index, value in ipairs(tValue3) do
        BackpackGuide._localValue3[tonumber(value)] = 1
    end
    
    BackpackGuide.createClickCell()
    BackpackGuide.createCheckBoxCell()

    GUI:addOnClickEvent(BackpackGuide._ui["Button_set"], function()
        SL:Require("game/view/layersui/test_layer/configSetting/configLayout/game_data/AddNewItem", true)
        local data = {}
        local keys = table.keys(BackpackGuide._localValue3)
        table.sort(keys)
        data.items = keys
        data.suffix = "道具"
        data.inputPlaceHolder = "请输入StdMode分类"
        data.callback = BackpackGuide.onSetCallback
        AddNewItem.main(data)
    end)

    GUI:addOnClickEvent(BackpackGuide._ui["Button_sure"], function()
        GUI:delayTouchEnabled(BackpackGuide._ui["Button_sure"], 0.5)
        local value1 = BackpackGuide._value1 and 1 or 0
        local value2 = BackpackGuide._value2 and 1 or 0
        local keys = table.keys(BackpackGuide._localValue3)
        table.sort(keys)
        local selProps = {}
        local localProps = {}
        for _, key in ipairs(keys) do
            table.insert(localProps, key.."#"..BackpackGuide._localValue3[key])
            if BackpackGuide._localValue3[key] == 1 then
                table.insert(selProps, key)
            end
        end
        local strSel = table.concat(selProps, "|")
        local strLocal = table.concat(localProps, "|")

        local saveValue = string.format("%s#%s#%s", value1, value2, strSel)
        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:SetLocalString(localSaveKey, strLocal)

        SL:ShowSystemTips("修改成功")
    end)
end

function BackpackGuide.createClickCell()
    for i = 1, 2 do
        local parent = GUI:Node_Create(BackpackGuide._ui["nativeUI"], "node", 0, 0)
        loadConfigSettingExport(parent, "game_data/click_cell")
        local clickCell = GUI:getChildByName(parent, "click_cell")
        GUI:removeFromParent(clickCell)
        GUI:removeFromParent(parent)

        GUI:addChild(BackpackGuide._ui["nativeUI"], clickCell)
        GUI:setPosition(clickCell, i == 1 and 40 or 190, 300)

        local Text_desc = GUI:getChildByName(clickCell, "Text_desc")
        GUI:Text_setFontSize(Text_desc, 13)
        GUI:Text_setString(Text_desc, i == 1 and "穿戴按钮开关" or "拆分按钮开关")

        local CheckBox_able = GUI:getChildByName(clickCell, "CheckBox_able")

        local function setClickCellStatus(enable)
            GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_off"), not enable)
            GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_on"), enable)
        end

        setClickCellStatus(BackpackGuide["_value" .. i])

        GUI:addOnClickEvent(clickCell, function()
            BackpackGuide["_value" .. i] = not BackpackGuide["_value" .. i]
            setClickCellStatus(BackpackGuide["_value" .. i])
        end)
    end
end

function BackpackGuide.createCheckBoxCell()
    local ScrollView_items = BackpackGuide._ui["ScrollView_items"]
    GUI:removeAllChildren(ScrollView_items)

    if not next(BackpackGuide._localValue3) then
        return
    end

    local keys = table.keys(BackpackGuide._localValue3)
    table.sort(keys)

    for _, key in ipairs(keys) do
        local item = GUI:Layout_Create(ScrollView_items, "item" .. key, 0, 0, 75, 30, false)
        GUI:setTouchEnabled(item, true)
        local checkBox = GUI:CheckBox_Create(item, "checkBox", 0, 15, "res/public/1900000550.png", "res/public/1900000551.png")
        GUI:setAnchorPoint(checkBox, 0, 0.5)
        GUI:CheckBox_setSelected(checkBox, BackpackGuide._localValue3[key] == 1)
        GUI:setTouchEnabled(checkBox, false)

        local checkText = GUI:Text_Create(item, "checkText", 30, 15, 14, "#ffffff", key .. "道具")
        GUI:setAnchorPoint(checkText, 0, 0.5)

        GUI:addOnClickEvent(item, function()
            local isSel = not GUI:CheckBox_isSelected(checkBox)
            GUI:CheckBox_setSelected(checkBox, isSel)
            BackpackGuide._localValue3[key] = isSel and 1 or 0
            dump(BackpackGuide._localValue3, "BackpackGuide._localValue3:::")
        end)
    end
    GUI:UserUILayout(ScrollView_items, {dir = 3, addDir = 1, colnum = 4, autosize = true})
end

-- operType 0删除 1增加
function BackpackGuide.onSetCallback(data, operType)
    if operType == 0 then
        BackpackGuide._localValue3[tonumber(data)] = 0
    elseif operType == 1 then
        BackpackGuide._localValue3[tonumber(data)] = 1
    end
    BackpackGuide.createCheckBoxCell()
end

return BackpackGuide