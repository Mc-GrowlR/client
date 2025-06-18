-- attr_not_hint 不飘字属性配置
AttrNotHint = {}

function AttrNotHint.main(parent, param)
    if not parent then
        return
    end
    
    loadConfigSettingExport(parent, "game_data/attr_not_hint")

    AttrNotHint._ui = GUI:ui_delegate(parent)
    AttrNotHint.ScrollView_sel = AttrNotHint._ui["ScrollView_sel"]
    AttrNotHint.ScrollView_unSel = AttrNotHint._ui["ScrollView_unSel"]
    GUI:ListView_addMouseScrollPercent(AttrNotHint.ScrollView_sel)
    GUI:ListView_addMouseScrollPercent(AttrNotHint.ScrollView_unSel)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    AttrNotHint.sel = {}
    local value = SL:GetMetaValue("GAME_DATA", key) or ""
    for i, v in pairs(string.split(value, "#")) do
        local attid = tonumber(v)
        if attid then
            AttrNotHint.sel[attid] = attid
        end
    end

    AttrNotHint.unSel = {}
    local cfgAttr = SL:GetMetaValue("ATTR_CONFIGS")
    for k, v in pairs(cfgAttr) do
        if not AttrNotHint.sel[k] then
            AttrNotHint.unSel[k] = k
        end
    end

    AttrNotHint.createCheckBoxCell()
    
    GUI:addOnClickEvent(AttrNotHint._ui["Button_sure"], function()
        GUI:delayTouchEnabled(AttrNotHint._ui["Button_sure"], 0.5)

        local keys = table.keys(AttrNotHint.sel)
        table.sort(keys)
        local strValue = table.concat(keys, "#")

        SL:SetMetaValue("GAME_DATA", key, strValue)
        SAVE_GAME_DATA(key, strValue)
        SL:ShowSystemTips("修改成功")
    end)
end

function AttrNotHint.createCheckBoxCell()
    GUI:removeAllChildren(AttrNotHint.ScrollView_sel)

    if next(AttrNotHint.sel) then
        local keys = table.keys(AttrNotHint.sel)
        table.sort(keys)

        for _, key in ipairs(keys) do
            local item = GUI:Layout_Create(AttrNotHint.ScrollView_sel, "item" .. key, 0, 0, 100, 30, false)
            GUI:setTouchEnabled(item, true)
            local checkBox = GUI:CheckBox_Create(item, "checkBox", 0, 15, "res/public/1900000550.png", "res/public/1900000551.png")
            GUI:setAnchorPoint(checkBox, 0, 0.5)
            GUI:CheckBox_setSelected(checkBox, true)
            GUI:setTouchEnabled(checkBox, false)
    
            local cfgAtt = SL:GetMetaValue("ATTR_CONFIG", key)
            local attName = cfgAtt and cfgAtt.name or ""
            local checkText = GUI:Text_Create(item, "checkText", 27, 15, 14, "#ffffff", key .. (attName or ""))
            GUI:setAnchorPoint(checkText, 0, 0.5)

            if GUI:getContentSize(checkText).width > 50 then
                GUI:removeFromParent(checkText)
                GUI:ScrollText_Create(item, "scrollText", 27, 7, 72, 14, "#ffffff", key .. (attName or ""))
            end
    
            GUI:addOnClickEvent(item, function()
                local isSel = not GUI:CheckBox_isSelected(checkBox)
                GUI:CheckBox_setSelected(checkBox, isSel)
                AttrNotHint.sel[key] = nil
                AttrNotHint.unSel[key] = key
                AttrNotHint.createCheckBoxCell()
            end)
        end
        GUI:UserUILayout(AttrNotHint.ScrollView_sel, {dir = 3, addDir = 1, colnum = 3, autosize = false})
    end

    GUI:removeAllChildren(AttrNotHint.ScrollView_unSel)
    if next(AttrNotHint.unSel) then
        local keys = table.keys(AttrNotHint.unSel)
        table.sort(keys)

        for _, key in ipairs(keys) do
            local item = GUI:Layout_Create(AttrNotHint.ScrollView_unSel, "item" .. key, 0, 0, 100, 30, false)
            GUI:setTouchEnabled(item, true)
            local checkBox = GUI:CheckBox_Create(item, "checkBox", 0, 15, "res/public/1900000550.png", "res/public/1900000551.png")
            GUI:setAnchorPoint(checkBox, 0, 0.5)
            GUI:CheckBox_setSelected(checkBox, false)
            GUI:setTouchEnabled(checkBox, false)
    
            local cfgAtt = SL:GetMetaValue("ATTR_CONFIG", key)
            local attName = cfgAtt and cfgAtt.name or ""
            local checkText = GUI:Text_Create(item, "checkText", 27, 15, 13, "#ffffff", key .. (attName or ""))
            GUI:setAnchorPoint(checkText, 0, 0.5)

            if GUI:getContentSize(checkText).width > 50 then
                GUI:removeFromParent(checkText)
                GUI:ScrollText_Create(item, "scrollText", 27, 7, 72, 14, "#ffffff", key .. (attName or ""))
            end
    
            GUI:addOnClickEvent(item, function()
                local isSel = not GUI:CheckBox_isSelected(checkBox)
                GUI:CheckBox_setSelected(checkBox, isSel)
                AttrNotHint.sel[key] = key
                AttrNotHint.unSel[key] = nil
                AttrNotHint.createCheckBoxCell()
            end)
        end
        GUI:UserUILayout(AttrNotHint.ScrollView_unSel, {dir = 3, addDir = 1, colnum = 3, autosize = false})
    end
end

return AttrNotHint