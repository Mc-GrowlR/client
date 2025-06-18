-- ItemLock 配置绑定物品图标显示
ItemLock = {}

function ItemLock.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/item_lock")

    ItemLock._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    ItemLock._clickCell = {}
    local value = SL:GetMetaValue("GAME_DATA", key) or 1
    ItemLock._selIndex = value

    for i = 0, 2 do
        local layout = ItemLock._ui["Layout" .. i]
        GUI:addOnClickEvent(layout, function()
            ItemLock.onClickCell(i)
        end)
        local layoutUI = GUI:ui_delegate(layout)
        GUI:setVisible(layoutUI["img_sel"], value == i)
        GUI:setVisible(layoutUI["img_unsel"], value ~= i)
        ItemLock._clickCell[i] = layoutUI
    end

    GUI:addOnClickEvent(ItemLock._ui["Button_sure"], function()
        GUI:delayTouchEnabled(ItemLock._ui["Button_sure"], 0.5)

        SL:SetMetaValue("GAME_DATA", key, ItemLock._selIndex)
        SAVE_GAME_DATA(key, ItemLock._selIndex)
        SL:ShowSystemTips("修改成功")
    end)
end

function ItemLock.onClickCell(index)
    if ItemLock._selIndex == index then
        return
    end

    local oldCell = ItemLock._clickCell[ItemLock._selIndex]
    GUI:setVisible(oldCell["img_sel"], false)
    GUI:setVisible(oldCell["img_unsel"], true)

    ItemLock._selIndex = index

    local newCell = ItemLock._clickCell[ItemLock._selIndex]
    GUI:setVisible(newCell["img_sel"], true)
    GUI:setVisible(newCell["img_unsel"], false)
end

return ItemLock