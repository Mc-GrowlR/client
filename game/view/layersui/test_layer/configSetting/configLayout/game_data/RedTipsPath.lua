-- 红点图片路径配置 
RedTipsPath = {}

function RedTipsPath.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/red_tips_path")

    RedTipsPath._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local slices = string.split(SL:GetMetaValue("GAME_DATA", key), "|")

    local scaleMobile = slices[1] or "" 
    local scalePC = slices[2] or ""
    local input_mobile = RedTipsPath._ui["input_mobile"]
    local input_pc = RedTipsPath._ui["input_pc"]
    GUI:TextInput_setString(input_mobile, scaleMobile)
    GUI:TextInput_setString(input_pc, scalePC)
    GUI:TextInput_addOnEvent(input_mobile, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_mobile)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("缩放值不能为空")
                GUI:TextInput_setString(input_mobile, scaleMobile)
                return
            end
            scaleMobile = inputStr
        end
    end)

    GUI:TextInput_addOnEvent(input_pc, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_pc)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("缩放值不能为空")
                GUI:TextInput_setString(input_pc, scalePC)
                return
            end
            scalePC = inputStr
        end
    end)

    GUI:addOnClickEvent(RedTipsPath._ui["Button_sure"], function()
        GUI:delayTouchEnabled(RedTipsPath._ui["Button_sure"], 0.5)

        local saveValue = string.format("%s|%s", scaleMobile, scalePC)

        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:ShowSystemTips("修改成功")
    end)
end

return RedTipsPath