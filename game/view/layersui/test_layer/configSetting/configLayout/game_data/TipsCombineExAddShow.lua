-- TipsCombineExAddShow Tips批量附加属性显示规则
TipsCombineExAddShow = {}

function TipsCombineExAddShow.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/tips_combine_add")

    TipsCombineExAddShow._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    TipsCombineExAddShow._clickCell = {}
    local value = SL:GetMetaValue("GAME_DATA", key) or 0
    TipsCombineExAddShow._selIndex = value

    for i = 0, 2 do
        local layout = TipsCombineExAddShow._ui["Layout" .. i]
        GUI:addOnClickEvent(layout, function()
            TipsCombineExAddShow.onClickCell(i)
        end)
        local layoutUI = GUI:ui_delegate(layout)
        GUI:setVisible(layoutUI["img_sel"], value == i)
        GUI:setVisible(layoutUI["img_unsel"], value ~= i)
        TipsCombineExAddShow._clickCell[i] = layoutUI
    end

    GUI:addOnClickEvent(TipsCombineExAddShow._ui["Button_sure"], function()
        GUI:delayTouchEnabled(TipsCombineExAddShow._ui["Button_sure"], 0.5)

        SL:SetMetaValue("GAME_DATA", key, TipsCombineExAddShow._selIndex)
        SAVE_GAME_DATA(key, TipsCombineExAddShow._selIndex)
        SL:ShowSystemTips("修改成功")
    end)
end

function TipsCombineExAddShow.onClickCell(index)
    if TipsCombineExAddShow._selIndex == index then
        return
    end

    local oldCell = TipsCombineExAddShow._clickCell[TipsCombineExAddShow._selIndex]
    GUI:setVisible(oldCell["img_sel"], false)
    GUI:setVisible(oldCell["img_unsel"], true)

    TipsCombineExAddShow._selIndex = index

    local newCell = TipsCombineExAddShow._clickCell[TipsCombineExAddShow._selIndex]
    GUI:setVisible(newCell["img_sel"], true)
    GUI:setVisible(newCell["img_unsel"], false)
end

return TipsCombineExAddShow