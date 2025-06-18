-- Heroqiehuan 英雄状态配置
Heroqiehuan = {}

local posList = {
    {id = 1, name = "战 斗"}, {id = 2, name = "跟 随"},
    {id = 3, name = "休 息"}, {id = 4, name = "守 护"},
}

function Heroqiehuan.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/need_reset_pos_with_chat")

    Heroqiehuan._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    Heroqiehuan.sel = {}
    local value = SL:GetMetaValue("GAME_DATA", key) or ""
    for i, v in ipairs(string.split(value, "#")) do
        local id = tonumber(v)
        if id then
            Heroqiehuan.sel[id] = id
        end
    end

    Heroqiehuan.createCheckBoxCell()
    
    GUI:addOnClickEvent(Heroqiehuan._ui["Button_sure"], function()
        GUI:delayTouchEnabled(Heroqiehuan._ui["Button_sure"], 0.5)

        local keys = table.keys(Heroqiehuan.sel)
        table.sort(keys)
        if #keys < 3 then
            SL:ShowSystemTips("最低配置3种状态")
            return
        end
        
        local strValue = table.concat(keys, "#")

        SL:SetMetaValue("GAME_DATA", key, strValue)
        SAVE_GAME_DATA(key, strValue)
        SL:ShowSystemTips("修改成功")
    end)
end

function Heroqiehuan.createCheckBoxCell()
    local ScrollView_items = Heroqiehuan._ui["ScrollView_items"]

    for _, v in ipairs(posList) do
        local item = GUI:Layout_Create(ScrollView_items, "item" .. v.id, 0, 0, 130, 30, false)
        GUI:setTouchEnabled(item, true)
        local checkBox = GUI:CheckBox_Create(item, "checkBox", 30, 15, "res/public/1900000550.png", "res/public/1900000551.png")
        GUI:setAnchorPoint(checkBox, 0, 0.5)
        GUI:CheckBox_setSelected(checkBox, Heroqiehuan.sel[v.id] ~= nil)
        GUI:setTouchEnabled(checkBox, false)

        local checkText = GUI:Text_Create(item, "checkText", 60, 15, 14, "#ffffff", v.name)
        GUI:setAnchorPoint(checkText, 0, 0.5)

        GUI:addOnClickEvent(item, function()
            local isSel = not GUI:CheckBox_isSelected(checkBox)
            GUI:CheckBox_setSelected(checkBox, isSel)
            Heroqiehuan.sel[v.id] = isSel and v.id or nil
        end)
    end
    GUI:UserUILayout(ScrollView_items, {dir = 3, addDir = 1, colnum = 2, autosize = true, gap = {x = 10, y = 5, l = 15}})
end

return Heroqiehuan