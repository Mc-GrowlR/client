-- itemTypeName 自定义道具类型名称 "stdmode#name|stdmode#name"
SetItemTypeName = {}

function SetItemTypeName.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/set_item_type_name")

    SetItemTypeName._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    SetItemTypeName._item_type_name = {}

    local arrays = string.split(SL:GetMetaValue("GAME_DATA", key) or "", "|")
    for _, v in ipairs(arrays) do
        if v and v ~= "" then
            local array = string.split(v, "#")
            if tonumber(array[1]) and array[2] then
                SetItemTypeName._item_type_name[tonumber(array[1])] = array[2]
            end
        end
    end
    
    SetItemTypeName.createCells()

    GUI:addOnClickEvent(SetItemTypeName._ui["Button_set"], function()
        SL:Require("game/view/layersui/test_layer/configSetting/configLayout/game_data/AddNewInputItem", true)
        local data = {}
        data.items = SetItemTypeName._item_type_name
        data.callback = SetItemTypeName.onSetCallback
        AddNewInputItem.main(data)
    end)

    GUI:addOnClickEvent(SetItemTypeName._ui["Button_sure"], function()
        GUI:delayTouchEnabled(SetItemTypeName._ui["Button_sure"], 0.5)

        local keys = table.keys(SetItemTypeName._item_type_name)
        table.sort(keys)
        local tValue = {}
        for _, key in ipairs(keys) do
            table.insert(tValue, key .. "#" .. SetItemTypeName._item_type_name[key])
        end
        local strValue = table.concat(tValue, "|")

        SL:SetMetaValue("GAME_DATA", key, strValue)
        SAVE_GAME_DATA(key, strValue)

        SL:ShowSystemTips("修改成功")
    end)
end

function SetItemTypeName.createCells()
    local ScrollView_items = SetItemTypeName._ui["ScrollView_items"]
    GUI:removeAllChildren(ScrollView_items)

    if not next(SetItemTypeName._item_type_name) then
        return
    end

    local keys = table.keys(SetItemTypeName._item_type_name)
    table.sort(keys)

    for _, key in ipairs(keys) do
        local item = GUI:Layout_Create(ScrollView_items, "item" .. key, 0, 0, 300, 30, false)
        GUI:Layout_setBackGroundColorType(item, 1)
        GUI:Layout_setBackGroundColor(item, "#000000")
        GUI:Layout_setBackGroundColorOpacity(item, 229)

        local text_key = GUI:Text_Create(item, "text_key", 90, 15, 14, "#ffffff", key)
        GUI:setAnchorPoint(text_key, 0, 0.5)

        local text_name = GUI:Text_Create(item, "text_name", 190, 15, 14, "#ffffff", SetItemTypeName._item_type_name[key])
        GUI:setAnchorPoint(text_name, 0, 0.5)
    end
    GUI:UserUILayout(ScrollView_items, {dir = 3, addDir = 1, colnum = 1, autosize = false, gap = {y=2}})
end

-- operType 0删除 1增加
function SetItemTypeName.onSetCallback(data, operType)
    if operType == 0 then
        SetItemTypeName._item_type_name[tonumber(data.key)] = nil
    elseif operType == 1 then
        SetItemTypeName._item_type_name[tonumber(data.key)] = data.name
    end
    SetItemTypeName.createCells()
end

return SetItemTypeName