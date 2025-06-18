-- Heroqiehuanmoshi 英雄状态切换方式 0滑动 1双击
Heroqiehuanmoshi = {}

function Heroqiehuanmoshi.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/hero_nuQiTiao")

    Heroqiehuanmoshi._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    Heroqiehuanmoshi._clickCell = {}
    local value = SL:GetMetaValue("GAME_DATA", key) or 0
    Heroqiehuanmoshi._selIndex = value

    local suffix = {
        [0] = "拖屏切换模式",
        [1] = "双击切换模式",
    }
    for i = 0, 1 do
        local layout = Heroqiehuanmoshi._ui["Layout" .. i]
        GUI:addOnClickEvent(layout, function()
            Heroqiehuanmoshi.onClickCell(i)
        end)
        local layoutUI = GUI:ui_delegate(layout)
        GUI:Text_setString(layoutUI["Text"], suffix[i])
        GUI:setVisible(layoutUI["img_sel"], value == i)
        GUI:setVisible(layoutUI["img_unsel"], value ~= i)
        Heroqiehuanmoshi._clickCell[i] = layoutUI
    end

    GUI:addOnClickEvent(Heroqiehuanmoshi._ui["Button_sure"], function()
        GUI:delayTouchEnabled(Heroqiehuanmoshi._ui["Button_sure"], 0.5)

        SL:SetMetaValue("GAME_DATA", key, Heroqiehuanmoshi._selIndex)
        SAVE_GAME_DATA(key, Heroqiehuanmoshi._selIndex)
        SL:ShowSystemTips("修改成功")
    end)
end

function Heroqiehuanmoshi.onClickCell(index)
    if Heroqiehuanmoshi._selIndex == index then
        return
    end

    local oldCell = Heroqiehuanmoshi._clickCell[Heroqiehuanmoshi._selIndex]
    GUI:setVisible(oldCell["img_sel"], false)
    GUI:setVisible(oldCell["img_unsel"], true)

    Heroqiehuanmoshi._selIndex = index

    local newCell = Heroqiehuanmoshi._clickCell[Heroqiehuanmoshi._selIndex]
    GUI:setVisible(newCell["img_sel"], true)
    GUI:setVisible(newCell["img_unsel"], false)
end

return Heroqiehuanmoshi