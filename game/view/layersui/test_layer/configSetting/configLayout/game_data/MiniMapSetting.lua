-- MiniMap 调整小地图大小
MiniMapSetting = {}

function MiniMapSetting.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/mini_map_setting")

    MiniMapSetting._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local slices = string.split(SL:GetMetaValue("GAME_DATA", key), "#")

    local posX, posY = tonumber(slices[1]) or "", tonumber(slices[2]) or ""
    local input_x = MiniMapSetting._ui["input_x"]
    local input_y = MiniMapSetting._ui["input_y"]
    GUI:TextInput_setString(input_x, posX)
    GUI:TextInput_setString(input_y, posY)
    GUI:TextInput_addOnEvent(input_x, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_x)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("坐标不能为空")
                GUI:TextInput_setString(input_x, posX)
                return
            end
            posX = tonumber(inputStr)
        end
    end)
    GUI:TextInput_addOnEvent(input_y, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_y)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("坐标不能为空")
                GUI:TextInput_setString(input_y, posY)
                return
            end
            posY = tonumber(inputStr)
        end
    end)

    local width, height = tonumber(slices[3]) or "", tonumber(slices[4]) or ""
    local input_w = MiniMapSetting._ui["input_w"]
    local input_h = MiniMapSetting._ui["input_h"]
    GUI:TextInput_setInputMode(input_w, 2)
    GUI:TextInput_setInputMode(input_h, 2)
    GUI:TextInput_setString(input_w, width)
    GUI:TextInput_setString(input_h, height)
    GUI:TextInput_addOnEvent(input_w, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_w)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("宽度不能为空")
                GUI:TextInput_setString(input_w, width)
                return
            end
            width = tonumber(inputStr)
        end
    end)
    GUI:TextInput_addOnEvent(input_h, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_h)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("高度不能为空")
                GUI:TextInput_setString(input_h, height)
                return
            end
            height = tonumber(inputStr)
        end
    end)

    GUI:addOnClickEvent(MiniMapSetting._ui["Button_sure"], function()
        GUI:delayTouchEnabled(MiniMapSetting._ui["Button_sure"], 0.5)

        if posX == "" or posY == "" then
            SL:ShowSystemTips("坐标不能为空")
            return
        end

        if width == "" or height == "" then
            SL:ShowSystemTips("宽高不能为空")
            return
        end

        local saveValue = string.format("%s#%s#%s#%s", posX, posY, width, height)

        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:ShowSystemTips("修改成功")
    end)
end

return MiniMapSetting