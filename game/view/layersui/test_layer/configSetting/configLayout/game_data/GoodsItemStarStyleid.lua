-- goods_item_star_styleid 装备强化自定义数字显示 "colorid#offX#offY|PC"
ItemStarStyle = {}

function ItemStarStyle.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/goods_item_star_styleid")

    ItemStarStyle._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    ItemStarStyle._sliceM = {255, 0, 0}
    ItemStarStyle._sliceP = {255, 0, 0}

    local value = SL:GetMetaValue("GAME_DATA", key)
    if value then
        local slices = string.split(value, "|")
        if slices[1] and slices[1] ~= "" then
            ItemStarStyle._sliceM = string.split(slices[1], "#")
        end

        if slices[2] and slices[2] ~= "" then
            ItemStarStyle._sliceP = string.split(slices[2], "#")
        end
    end

    ItemStarStyle._Attr = {
        ["input_pc_color"]     = { IMode = 2, SetData = ItemStarStyle.setPCColor,       SetUI = ItemStarStyle.setUIPCColor },
        ["input_pc_x"]         = { IMode = 6, SetData = ItemStarStyle.setPCX,           SetUI = ItemStarStyle.setUIPCX },
        ["input_pc_y"]         = { IMode = 6, SetData = ItemStarStyle.setPCY,           SetUI = ItemStarStyle.setUIPCY },
        ["input_mobile_color"] = { IMode = 2, SetData = ItemStarStyle.setMobileColor,   SetUI = ItemStarStyle.setUIMobileColor },
        ["input_mobile_x"]     = { IMode = 6, SetData = ItemStarStyle.setMobileX,       SetUI = ItemStarStyle.setUIMobileX },
        ["input_mobile_y"]     = { IMode = 6, SetData = ItemStarStyle.setMobileY,       SetUI = ItemStarStyle.setUIMobileY, },
    }

    ItemStarStyle.Layout_color_pc = ItemStarStyle._ui["Layout_color_pc"]
    ItemStarStyle.Layout_color_mobile = ItemStarStyle._ui["Layout_color_mobile"]

    ItemStarStyle._selUIControl = {}
    ItemStarStyle._InputValues = {}

    for name, d in pairs(ItemStarStyle._Attr) do
        local widget = ItemStarStyle._ui[name]
        if widget then
            GUI:TextInput_setInputMode(widget, d.IMode)
            GUI:TextInput_setPlaceholderFontSize(widget, 14)
            ItemStarStyle._selUIControl[name] = widget
            widget:addEventListener(function(ref, eventType)
                local name = ref:getName()
                local ui = ItemStarStyle._Attr[name]
                if not ui then
                    return false
                end
                local mode = ui.IMode
                local max  = 255
                local min  = 0
                local str  = ref:getString()
        
                if eventType == 1 then
                    if mode == 2 then
                        str = string.trim(str)
                        str = tonumber(str) or 0
                        if min and str < min then
                            str = min
                        end
                        if max then
                            str = math.max(math.min(str, max), 0)
                        end
                        str = ItemStarStyle._InputValues[name] or str
                        ref:setString(str)
                        ItemStarStyle.updateUIAttr(name, str)
                        ItemStarStyle._InputValues[name] = str
                    else
                        if string.len(str or "") <= 0 then
                            ref:setString(ItemStarStyle._InputValues[name] or "")
                            return false
                        end
                        ref:setString(str)
                        ItemStarStyle.updateUIAttr(name, str)
                        ItemStarStyle._InputValues[name] = str
                    end
                end
            end)
        end
    end

    GUI:addOnClickEvent(ItemStarStyle._ui["Button_sure"], function()
        GUI:delayTouchEnabled(ItemStarStyle._ui["Button_sure"], 0.5)

        local strM = table.concat(ItemStarStyle._sliceM, "#")
        local strP = table.concat(ItemStarStyle._sliceP, "#")
        local saveValue = string.format("%s|%s", strM, strP)

        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:ShowSystemTips("修改成功")
    end)

    ItemStarStyle.updateUIControl()
end

function ItemStarStyle.updateUIAttr(name, value)
    if name and ItemStarStyle._Attr[name] and ItemStarStyle._Attr[name].SetData then
        ItemStarStyle._Attr[name].SetData(value)
    end
    ItemStarStyle.updateUIControl()
end

function ItemStarStyle.updateUIControl()
    for name, _ in pairs(ItemStarStyle._selUIControl) do
        if ItemStarStyle._Attr[name] and ItemStarStyle._Attr[name].SetUI then
            ItemStarStyle._Attr[name].SetUI(ItemStarStyle._selUIControl[name])
        end
    end
end

function ItemStarStyle.setPCColor(value)
    ItemStarStyle._sliceP[1] = tonumber(value)
end

function ItemStarStyle.setUIPCColor(widget)
    local colorid = tonumber(ItemStarStyle._sliceP[1] or 255)
    widget:setString(colorid)
    GUI:Layout_setBackGroundColor(ItemStarStyle.Layout_color_pc, SL:GetHexColorByStyleId(colorid))
end

function ItemStarStyle.setPCX(value)
    ItemStarStyle._sliceP[2] = tonumber(value)
end

function ItemStarStyle.setUIPCX(widget)
    widget:setString(ItemStarStyle._sliceP[2] or 0)
end

function ItemStarStyle.setPCY(value)
    ItemStarStyle._sliceP[3] = tonumber(value)
end

function ItemStarStyle.setUIPCY(widget)
    widget:setString(ItemStarStyle._sliceP[3] or 0)
end

function ItemStarStyle.setMobileColor(value)
    ItemStarStyle._sliceM[1] = tonumber(value)
end

function ItemStarStyle.setUIMobileColor(widget)
    local colorid = tonumber(ItemStarStyle._sliceM[1] or 255)
    widget:setString(colorid)
    GUI:Layout_setBackGroundColor(ItemStarStyle.Layout_color_mobile, SL:GetHexColorByStyleId(colorid))
end

function ItemStarStyle.setMobileX(value)
    ItemStarStyle._sliceM[2] = tonumber(value)
end

function ItemStarStyle.setUIMobileX(widget)
    widget:setString(ItemStarStyle._sliceM[2] or 0)
end

function ItemStarStyle.setMobileY(value)
    ItemStarStyle._sliceM[3] = tonumber(value)
end

function ItemStarStyle.setUIMobileY(widget)
    widget:setString(ItemStarStyle._sliceM[3] or 0)
end

return ItemStarStyle