-- 单独设置时间、道具id等单个输入
SingleInputSetting = {}

function SingleInputSetting.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/single_input")

    SingleInputSetting._ui = GUI:ui_delegate(parent)

    local prefix = param.config and param.config.prefix or ""
    local input_prefix = SingleInputSetting._ui["input_prefix"]
    GUI:Text_setString(input_prefix, prefix)

    local suffix = param.config and param.config.suffix or ""
    GUI:Text_setString(SingleInputSetting._ui["input_suffix"], suffix)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local input = SingleInputSetting._ui["input"]
    local value = SL:GetMetaValue("GAME_DATA", key) or ""
    local canInputString = param.config and param.config.inputString or 0
    canInputString = canInputString or 0
    GUI:TextInput_setString(input, value)
    if canInputString ~= 1 then
        GUI:TextInput_setInputMode(input, 2)
    end

    local prefixPosX = GUI:getPositionX(input_prefix)
    local prefixW = GUI:getContentSize(input_prefix).width
    if prefixPosX - prefixW <= 3 then
        GUI:setAnchorPoint(input_prefix, 0, 0.5)
        GUI:setPositionX(input_prefix, 10)

        local input_bg = SingleInputSetting._ui["input_bg"]
        GUI:setAnchorPoint(input_bg, 0, 1)
        GUI:setPosition(input_bg, 10, 270)
        GUI:setContentSize(input_bg, 280, 26)

        GUI:setContentSize(input, 280, 25)
    end

    GUI:addOnClickEvent(SingleInputSetting._ui["Button_sure"], function()
        local inputStr = GUI:TextInput_getString(input)
        if string.len(inputStr) <= 0 then
            SL:ShowSystemTips("请输入修改内容")
            return
        end

        local checkNum = param.config and param.config.checkNum and param.config.checkNum == 1
        if (canInputString ~= 1 or checkNum) then
            if tonumber(inputStr) == nil then
                SL:ShowSystemTips("请输入数字")
                GUI:TextInput_setString(input, value)
                return
            end

            if tonumber(inputStr) == 0 then
                SL:ShowSystemTips("不可设置为0")
                GUI:TextInput_setString(input, value)
                return
            end
        end

        GUI:delayTouchEnabled(SingleInputSetting._ui["Button_sure"], 0.5)

        local saveStr = canInputString ~= 1 and tonumber(inputStr) or inputStr

        SL:SetMetaValue("GAME_DATA", key, saveStr)
        SAVE_GAME_DATA(key, saveStr)
        SL:ShowSystemTips("修改成功")
    end)
end

return SingleInputSetting