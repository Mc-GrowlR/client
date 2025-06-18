-- 单独设置开或者关
SingleSwitchSetting = {}

function SingleSwitchSetting.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/single_switch")
    SingleSwitchSetting.parent = parent

    SingleSwitchSetting._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    SingleSwitchSetting._value = (tonumber(SL:GetMetaValue("GAME_DATA", key)) or 0) > 0

    SingleSwitchSetting.createClickCell()

    GUI:addOnClickEvent(SingleSwitchSetting._ui["Button_sure"], function()
        GUI:delayTouchEnabled(SingleSwitchSetting._ui["Button_sure"], 0.5)
        local saveValue = SingleSwitchSetting._value and 1 or 0
        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)
        SL:ShowSystemTips("修改成功")
    end)
end

function SingleSwitchSetting.createClickCell()
    loadConfigSettingExport(SingleSwitchSetting.parent, "game_data/click_cell")
    local clickCell = SingleSwitchSetting._ui["click_cell"]
    local CheckBox_able = GUI:getChildByName(clickCell, "CheckBox_able")
    GUI:setPosition(clickCell, 90, 275)

    local function setClickCellStatus(enable)
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_off"), not enable)
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_on"), enable)
    end

    setClickCellStatus(SingleSwitchSetting._value)

    GUI:addOnClickEvent(clickCell, function()
        SingleSwitchSetting._value = not SingleSwitchSetting._value
        setClickCellStatus(SingleSwitchSetting._value)
    end)
end

return SingleSwitchSetting