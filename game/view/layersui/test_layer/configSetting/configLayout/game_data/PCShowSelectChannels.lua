-- PCShowSelectChannels 聊天频道切换按钮
PCShowSelectChannels = {}

local posList = {
    {id = 2, name = "喊 话"}, {id = 4, name = "行 会"},
    {id = 5, name = "组 队"}, {id = 6, name = "附 近"},
    {id = 7, name = "世 界"}, {id = 8, name = "国 家"},
    {id = 9, name = "联 盟"}, {id = 10, name = "跨 服"}
}

function PCShowSelectChannels.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/need_reset_pos_with_chat")

    PCShowSelectChannels._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    PCShowSelectChannels.sel = {}
    local value = SL:GetMetaValue("GAME_DATA", key) or ""
    for i, v in ipairs(string.split(value, "#")) do
        local id = tonumber(v)
        if id then
            PCShowSelectChannels.sel[id] = id
        end
    end

    PCShowSelectChannels.createCheckBoxCell()
    
    GUI:addOnClickEvent(PCShowSelectChannels._ui["Button_sure"], function()
        GUI:delayTouchEnabled(PCShowSelectChannels._ui["Button_sure"], 0.5)

        local keys = table.keys(PCShowSelectChannels.sel)
        table.sort(keys)
        local strValue = table.concat(keys, "#")

        SL:SetMetaValue("GAME_DATA", key, strValue)
        SAVE_GAME_DATA(key, strValue)
        SL:ShowSystemTips("修改成功")
    end)
end

function PCShowSelectChannels.createCheckBoxCell()
    local ScrollView_items = PCShowSelectChannels._ui["ScrollView_items"]

    for _, v in ipairs(posList) do
        local item = GUI:Layout_Create(ScrollView_items, "item" .. v.id, 0, 0, 130, 30, false)
        GUI:setTouchEnabled(item, true)
        local checkBox = GUI:CheckBox_Create(item, "checkBox", 30, 15, "res/public/1900000550.png", "res/public/1900000551.png")
        GUI:setAnchorPoint(checkBox, 0, 0.5)
        GUI:CheckBox_setSelected(checkBox, PCShowSelectChannels.sel[v.id] ~= nil)
        GUI:setTouchEnabled(checkBox, false)

        local checkText = GUI:Text_Create(item, "checkText", 60, 15, 14, "#ffffff", v.name)
        GUI:setAnchorPoint(checkText, 0, 0.5)

        GUI:addOnClickEvent(item, function()
            local isSel = not GUI:CheckBox_isSelected(checkBox)
            GUI:CheckBox_setSelected(checkBox, isSel)
            PCShowSelectChannels.sel[v.id] = isSel and v.id or nil
        end)
    end
    GUI:UserUILayout(ScrollView_items, {dir = 3, addDir = 1, colnum = 2, autosize = true, gap = {x = 10, y = 5, l = 15}})
end

return PCShowSelectChannels