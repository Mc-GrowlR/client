-- 字段：NGEXPcoordinate
-- 格式例子：10#450|10#300|250#0|1
-- 字段描述：内功经验显示坐标(PC端X坐标#PC端Y坐标|移动端X坐标#移动端Y坐标|前景色#背景色|最低内功经验显示)
NGEXPcoordinate = {}

function NGEXPcoordinate.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/ng_exp_coordinate")

    NGEXPcoordinate._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local data = SL:GetMetaValue("GAME_DATA", "NGEXPcoordinate")
    if not data then 
        data = "0#0|0#0|250#0|0"
    end 

    local pointList = {}
    local expLimit = 0
    local slicesP = string.split(data, "|")
    for index, slice in ipairs(slicesP) do
        if index == #slicesP then
            expLimit = tonumber(slice)
            break
        end
        local pointXY = string.split(slice, "#")
        local X = tonumber(pointXY[1])
        local Y = tonumber(pointXY[2])
        pointList[index] = { X = X, Y = Y }
    end

    local pcX, pcY = pointList[1].X, pointList[1].Y
    local input_pc_x = NGEXPcoordinate._ui["input_pc_x"]
    local input_pc_y = NGEXPcoordinate._ui["input_pc_y"]
    GUI:TextInput_setInputMode(input_pc_x, 2)
    GUI:TextInput_setInputMode(input_pc_y, 2)
    GUI:TextInput_setString(input_pc_x, pcX)
    GUI:TextInput_setString(input_pc_y, pcY)
    GUI:TextInput_addOnEvent(input_pc_x, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_pc_x)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("坐标不能为空")
                GUI:TextInput_setString(input_pc_x, pcX)
                return
            end
            pcX = tonumber(inputStr)
        end
    end)
    GUI:TextInput_addOnEvent(input_pc_y, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_pc_y)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("坐标不能为空")
                GUI:TextInput_setString(input_pc_y, pcY)
                return
            end
            pcY = tonumber(inputStr)
        end
    end)

    local mobileX, mobileY = pointList[2].X, pointList[2].Y
    local input_mobile_x = NGEXPcoordinate._ui["input_mobile_x"]
    local input_mobile_y = NGEXPcoordinate._ui["input_mobile_y"]
    GUI:TextInput_setInputMode(input_mobile_x, 2)
    GUI:TextInput_setInputMode(input_mobile_y, 2)
    GUI:TextInput_setString(input_mobile_x, mobileX)
    GUI:TextInput_setString(input_mobile_y, mobileY)
    GUI:TextInput_addOnEvent(input_mobile_x, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_mobile_x)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("坐标不能为空")
                GUI:TextInput_setString(input_mobile_x, mobileX)
                return
            end
            mobileX = tonumber(inputStr)
        end
    end)
    GUI:TextInput_addOnEvent(input_mobile_y, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_mobile_y)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("坐标不能为空")
                GUI:TextInput_setString(input_mobile_y, mobileY)
                return
            end
            mobileY = tonumber(inputStr)
        end
    end)

    local Layout_color_f = NGEXPcoordinate._ui["Layout_color_f"]
    local Layout_color_b = NGEXPcoordinate._ui["Layout_color_b"]
    local colorId_f = pointList[3].X
    local colorId_b = pointList[3].Y
    GUI:Layout_setBackGroundColor(Layout_color_f, SL:GetHexColorByStyleId(colorId_f))
    GUI:Layout_setBackGroundColor(Layout_color_b, SL:GetHexColorByStyleId(colorId_b))

    local input_color_f = NGEXPcoordinate._ui["input_color_f"]
    local input_color_b = NGEXPcoordinate._ui["input_color_b"]
    GUI:TextInput_setInputMode(input_color_f, 2)
    GUI:TextInput_setInputMode(input_color_b, 2)
    GUI:TextInput_setString(input_color_f, colorId_f)
    GUI:TextInput_setString(input_color_b, colorId_b)

    local function checkColorId(inputId)
        local colorId = tonumber(inputId)
        if not colorId then
            SL:ShowSystemTips("请输入颜色值")
            return false
        end

        if colorId < 0 or colorId > 255 then
            SL:ShowSystemTips("只能输入0~255的颜色值")
            return false
        end

        return true
    end

    GUI:TextInput_addOnEvent(input_color_f, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_color_f)
            if not checkColorId(inputStr) then
                GUI:TextInput_setString(input_color_f, colorId_f)
                return
            end

            colorId_f = tonumber(inputStr)
            
            GUI:Layout_setBackGroundColor(Layout_color_f, SL:GetHexColorByStyleId(colorId_f))
        end
    end)

    GUI:TextInput_addOnEvent(input_color_b, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_color_b)
            if not checkColorId(inputStr) then
                GUI:TextInput_setString(input_color_b, colorId_b)
                return
            end

            colorId_b = tonumber(inputStr)
            
            GUI:Layout_setBackGroundColor(Layout_color_b, SL:GetHexColorByStyleId(colorId_b))
        end
    end)

    local input_exp = NGEXPcoordinate._ui["input_exp"]
    GUI:TextInput_setInputMode(input_exp, 2)
    GUI:TextInput_setString(input_exp, expLimit)
    GUI:TextInput_addOnEvent(input_exp, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_exp)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("经验值不能为空")
                GUI:TextInput_setString(input_exp, expLimit)
                return
            end
            expLimit = tonumber(inputStr)
        end
    end)


    GUI:addOnClickEvent(NGEXPcoordinate._ui["Button_sure"], function()
        GUI:delayTouchEnabled(NGEXPcoordinate._ui["Button_sure"], 0.5)

        local saveValue = string.format("%s#%s|%s#%s|%s#%s|%s", pcX, pcY, mobileX, mobileY, colorId_f, colorId_b, expLimit)

        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:ShowSystemTips("修改成功")
    end)
end

return NGEXPcoordinate