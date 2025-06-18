-- 单独设置开或者关
TurnOff = {}

function TurnOff.main(parent, data)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "setup/turn_off")

    TurnOff._ui = GUI:ui_delegate(parent)

    TurnOff._enable = (data.default or 0) == 1

    local clickCell = TurnOff._ui["click_cell"]
    local CheckBox_able = GUI:getChildByName(clickCell, "CheckBox_able")
    local function setClickCellStatus(enable)
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_off"), not enable)
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_on"), enable)
    end

    setClickCellStatus(TurnOff._enable)

    GUI:addOnClickEvent(clickCell, function()
        TurnOff._enable = not TurnOff._enable
        setClickCellStatus(TurnOff._enable)
    end)
end

-- 外部调用，返回当前界面处理数据结果
function TurnOff.getValue()
    local ret = {}
    ret.default = TurnOff._enable and 1 or 0
    
    return ret
end

return TurnOff