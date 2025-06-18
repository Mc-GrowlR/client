-- Heronuqitiao 英雄怒气条样式 0圆形 1条形
Heronuqitiao = {}

function Heronuqitiao.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/hero_nuQiTiao")

    Heronuqitiao._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    Heronuqitiao._clickCell = {}
    local value = SL:GetMetaValue("GAME_DATA", key) or 0
    Heronuqitiao._selIndex = value

    for i = 0, 1 do
        local layout = Heronuqitiao._ui["Layout" .. i]
        GUI:addOnClickEvent(layout, function()
            Heronuqitiao.onClickCell(i)
        end)
        local layoutUI = GUI:ui_delegate(layout)
        GUI:setVisible(layoutUI["img_sel"], value == i)
        GUI:setVisible(layoutUI["img_unsel"], value ~= i)
        Heronuqitiao._clickCell[i] = layoutUI
    end

    GUI:addOnClickEvent(Heronuqitiao._ui["Button_sure"], function()
        GUI:delayTouchEnabled(Heronuqitiao._ui["Button_sure"], 0.5)

        SL:SetMetaValue("GAME_DATA", key, Heronuqitiao._selIndex)
        SAVE_GAME_DATA(key, Heronuqitiao._selIndex)
        SL:ShowSystemTips("修改成功")
    end)
end

function Heronuqitiao.onClickCell(index)
    if Heronuqitiao._selIndex == index then
        return
    end

    local oldCell = Heronuqitiao._clickCell[Heronuqitiao._selIndex]
    GUI:setVisible(oldCell["img_sel"], false)
    GUI:setVisible(oldCell["img_unsel"], true)

    Heronuqitiao._selIndex = index

    local newCell = Heronuqitiao._clickCell[Heronuqitiao._selIndex]
    GUI:setVisible(newCell["img_sel"], true)
    GUI:setVisible(newCell["img_unsel"], false)
end

return Heronuqitiao