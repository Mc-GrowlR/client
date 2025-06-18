-- NeedResetPosWithChat 隐藏聊天窗口UI
NeedResetPosWithChat = {}

local posList = {
    {id = 1, name = "1快捷栏"}, {id = 2, name = "2快捷栏"},
    {id = 3, name = "3快捷栏"}, {id = 4, name = "4快捷栏"},
    {id = 5, name = "5快捷栏"}, {id = 6, name = "6快捷栏"},
    {id = 9, name = "血量"},
    {id = 8, name = "血量背景图"},
    {id = 10, name = "条形怒气条"},
    {id = 7, name = "寻路/挂机提示"},
}

function NeedResetPosWithChat.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/need_reset_pos_with_chat")

    NeedResetPosWithChat._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    NeedResetPosWithChat.sel = {}
    local value = SL:GetMetaValue("GAME_DATA", key) or ""
    for i, v in ipairs(string.split(value, "#")) do
        local id = tonumber(v)
        if id then
            NeedResetPosWithChat.sel[id] = id
        end
    end

    NeedResetPosWithChat.createCheckBoxCell()
    
    GUI:addOnClickEvent(NeedResetPosWithChat._ui["Button_sure"], function()
        GUI:delayTouchEnabled(NeedResetPosWithChat._ui["Button_sure"], 0.5)

        local keys = table.keys(NeedResetPosWithChat.sel)
        table.sort(keys)
        local strValue = table.concat(keys, "#")

        SL:SetMetaValue("GAME_DATA", key, strValue)
        SAVE_GAME_DATA(key, strValue)
        SL:ShowSystemTips("修改成功")
    end)
end

function NeedResetPosWithChat.createCheckBoxCell()
    local ScrollView_items = NeedResetPosWithChat._ui["ScrollView_items"]

    for _, v in ipairs(posList) do
        local item = GUI:Layout_Create(ScrollView_items, "item" .. v.id, 0, 0, 100, 30, false)
        GUI:setTouchEnabled(item, true)
        local checkBox = GUI:CheckBox_Create(item, "checkBox", 0, 15, "res/public/1900000550.png", "res/public/1900000551.png")
        GUI:setAnchorPoint(checkBox, 0, 0.5)
        GUI:CheckBox_setSelected(checkBox, NeedResetPosWithChat.sel[v.id] ~= nil)
        GUI:setTouchEnabled(checkBox, false)

        local checkText = GUI:Text_Create(item, "checkText", 30, 15, 14, "#ffffff", v.name)
        GUI:setAnchorPoint(checkText, 0, 0.5)

        GUI:addOnClickEvent(item, function()
            local isSel = not GUI:CheckBox_isSelected(checkBox)
            GUI:CheckBox_setSelected(checkBox, isSel)
            NeedResetPosWithChat.sel[v.id] = isSel and v.id or nil
        end)
    end
    GUI:UserUILayout(ScrollView_items, {dir = 3, addDir = 1, colnum = 3, autosize = true, rownums = {3, 3, 2, 2}})
end

return NeedResetPosWithChat