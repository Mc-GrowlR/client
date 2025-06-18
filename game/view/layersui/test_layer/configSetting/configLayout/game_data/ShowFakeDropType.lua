-- ShowFakeDropType 假掉落配置
ShowFakeDropType = {}

local FAKE_DROP_TYPE = 77
function ShowFakeDropType.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/drop_type_show")

    ShowFakeDropType._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local value = SL:GetMetaValue("GAME_DATA", key) or ""
    local tValue = {}
    if value and string.len(value) > 0 then
        local param = string.split(value, "#")
        local id = FAKE_DROP_TYPE
        if id then
            tValue[id] = {open = tonumber(param[2]) == 1, name = param[1] or ""}
        end
    end

    local ScrollView_items = ShowFakeDropType._ui["ScrollView_items"]

    local input = {}
    if not next(tValue) then
        tValue[FAKE_DROP_TYPE] = {}
    end
    for id, v in pairs(tValue) do
        local cell = ShowFakeDropType.createCell()
        GUI:addChild(ScrollView_items, cell)

        local enable = v and v.open or false
        local CheckBox_able = GUI:getChildByName(cell, "CheckBox_able")
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_off"), not enable)
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_on"), enable)

        local name = v and v.name or ""
        local input_name = GUI:getChildByName(cell, "Input_name")
        GUI:TextInput_setString(input_name, name)
        GUI:TextInput_setPlaceHolder(input_name, "分类0")
        input[id] = input_name

        GUI:addOnClickEvent(cell, function()
            local enable = tValue[id] and tValue[id].open or false
            enable = not enable
            GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_off"), not enable)
            GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_on"), enable)
            tValue[id] = tValue[id] or {} 
            tValue[id].open = enable
        end)
    end

    GUI:UserUILayout(ScrollView_items, {dir = 3, gap = {x = 0, l = 2},  addDir = 1, colnum = 2, autosize = true,})

    GUI:addOnClickEvent(ShowFakeDropType._ui["Button_sure"], function()
        GUI:delayTouchEnabled(ShowFakeDropType._ui["Button_sure"], 0.5)
        local saveValue = ""
        if next(tValue) then
            local name = GUI:TextInput_getString(input[FAKE_DROP_TYPE]) or ""
            local isOpen = tValue[FAKE_DROP_TYPE] and tValue[FAKE_DROP_TYPE].open or false
            if isOpen or (string.len(name) > 0) then
                local value1 = isOpen and 1 or 0
                saveValue = string.format("%s#%s", name, value1)
            end
        end
        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)
        SL:ShowSystemTips("修改成功")
    end)
end

function ShowFakeDropType.createCell()
    local parent = GUI:Node_Create(-1, "node", 0, 0)
    loadConfigSettingExport(parent, "game_data/drop_type_cell")
    local cell = GUI:getChildByName(parent, "click_cell")
    GUI:removeFromParent(cell)
    return cell
end

return ShowFakeDropType