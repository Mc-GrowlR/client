-- 充值最大和最小 
RechargeNum = {}

function RechargeNum.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/recharge_num")

    RechargeNum._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local slices = string.split(SL:GetMetaValue("GAME_DATA", key), "|")
    local minNum = SL:GetMetaValue("GAME_DATA", "minRecharge")
    local maxNum = SL:GetMetaValue("GAME_DATA", "maxRecharge")

    local input_min = RechargeNum._ui["input_min"]
    local input_max = RechargeNum._ui["input_max"]
    GUI:TextInput_setInputMode(input_min, 2)
    GUI:TextInput_setInputMode(input_max, 2)
    GUI:TextInput_setMaxLength(input_min, 8)
    GUI:TextInput_setMaxLength(input_max, 8)
    GUI:TextInput_setString(input_min, minNum)
    GUI:TextInput_setString(input_max, maxNum)
    GUI:TextInput_addOnEvent(input_min, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_min)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("不能为空")
                GUI:TextInput_setString(input_min, minNum)
                return
            end
            minNum = inputStr
        end
    end)

    GUI:TextInput_addOnEvent(input_max, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_max)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("不能为空")
                GUI:TextInput_setString(input_max, maxNum)
                return
            end
            maxNum = inputStr
        end
    end)

    GUI:addOnClickEvent(RechargeNum._ui["Button_sure"], function()
        GUI:delayTouchEnabled(RechargeNum._ui["Button_sure"], 0.5)

        local inputStr = GUI:TextInput_getString(input_min)
        minNum = tonumber(inputStr) or minNum
        local inputStr = GUI:TextInput_getString(input_max)
        maxNum = tonumber(inputStr) or maxNum

        SL:SetMetaValue("GAME_DATA", "minRecharge", minNum)
        SL:SetMetaValue("GAME_DATA", "maxRecharge", maxNum)

        SAVE_GAME_DATA("minRecharge", minNum)
        SAVE_GAME_DATA("maxRecharge", maxNum)


        SL:ShowSystemTips("修改成功")
    end)
end

return RechargeNum