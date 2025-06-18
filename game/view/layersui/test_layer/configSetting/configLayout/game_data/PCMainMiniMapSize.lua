-- PCMainMiniMapSize 开关二级小地图及配置大小 -- w#h|skip  w#h|skip&w#h
PCMainMiniMapSize = {}

function PCMainMiniMapSize.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/pc_main_mini_map_size")

    PCMainMiniMapSize._ui = GUI:ui_delegate(parent)

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end

    local width, height, width2, height2
    local skip = false
    local setData = SL:GetMetaValue("GAME_DATA", key)
    if setData and string.len(setData) > 0 then
        local sizeList = string.split(setData, "|")
        if sizeList[1] and string.len(sizeList[1]) > 0 then
            local tSize = string.split(sizeList[1], "#")
            width, height = tonumber(tSize[1]), tonumber(tSize[2])
        end

        if tonumber(sizeList[2]) then
            skip = tonumber(sizeList[2]) == 1
        else
            local data = string.split(sizeList[2], "&")
            skip = tonumber(data[1]) and tonumber(data[1]) == 1
            if data[2] and string.len(data[2]) > 0 then
                local tSize = string.split(data[2], "#")
                width2, height2 = tonumber(tSize[1]), tonumber(tSize[2])
            end
        end
    end

    local input_width = PCMainMiniMapSize._ui["input_width"]
    local input_height = PCMainMiniMapSize._ui["input_height"]
    GUI:TextInput_setInputMode(input_width, 2)
    GUI:TextInput_setInputMode(input_width, 2)
    GUI:TextInput_setString(input_width, width or "")
    GUI:TextInput_setString(input_height, height or "")
    GUI:TextInput_addOnEvent(input_width, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_width)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("宽度不能为空")
                GUI:TextInput_setString(input_width, width or "")
                return
            end
            if tonumber(inputStr) == 0 then
                SL:ShowSystemTips("宽度不能为0")
                GUI:TextInput_setString(input_width, width or "")
                return
            end
            width = tonumber(inputStr)
        end
    end)
    GUI:TextInput_addOnEvent(input_height, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_height)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("高度不能为空")
                GUI:TextInput_setString(input_height, height or "")
                return
            end
            if tonumber(inputStr) == 0 then
                SL:ShowSystemTips("高度不能为0")
                GUI:TextInput_setString(input_height, height or "")
                return
            end
            height = tonumber(inputStr)
        end
    end)

    local input_width2 = PCMainMiniMapSize._ui["input_width2"]
    local input_height2 = PCMainMiniMapSize._ui["input_height2"]
    GUI:TextInput_setInputMode(input_width2, 2)
    GUI:TextInput_setInputMode(input_height2, 2)
    GUI:TextInput_setString(input_width2, width2 or "")
    GUI:TextInput_setString(input_height2, height2 or "")
    GUI:TextInput_addOnEvent(input_width2, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_width2)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("宽度不能为空")
                GUI:TextInput_setString(input_width2, width2 or "")
                return
            end
            if tonumber(inputStr) == 0 then
                SL:ShowSystemTips("宽度不能为0")
                GUI:TextInput_setString(input_width2, width2 or "")
                return
            end
            width2 = tonumber(inputStr)
        end
    end)
    GUI:TextInput_addOnEvent(input_height2, function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_height2)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("高度不能为空")
                GUI:TextInput_setString(input_height2, height2 or "")
                return
            end
            if tonumber(inputStr) == 0 then
                SL:ShowSystemTips("高度不能为0")
                GUI:TextInput_setString(input_width2, height2 or "")
                return
            end
            height2 = tonumber(inputStr)
        end
    end)

    local parent = GUI:Node_Create(PCMainMiniMapSize._ui["nativeUI"], "node", 0, 0)
    loadConfigSettingExport(parent, "game_data/click_cell")
    local clickCell = GUI:getChildByName(parent, "click_cell")
    GUI:removeFromParent(clickCell)
    GUI:removeFromParent(parent)

    GUI:addChild(PCMainMiniMapSize._ui["nativeUI"], clickCell)
    GUI:setPosition(clickCell, 60, 335)

    local Text_desc = GUI:getChildByName(clickCell, "Text_desc")
    GUI:Text_setFontSize(Text_desc, 13)
    GUI:Text_setString(Text_desc, "二级小地图开关")

    local CheckBox_able = GUI:getChildByName(clickCell, "CheckBox_able")

    local function setClickCellStatus(enable)
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_off"), not enable)
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_on"), enable)
    end

    setClickCellStatus(skip)

    GUI:addOnClickEvent(clickCell, function()
        skip = not skip
        setClickCellStatus(skip)
    end)

    GUI:addOnClickEvent(PCMainMiniMapSize._ui["Button_sure"], function()
        GUI:delayTouchEnabled(PCMainMiniMapSize._ui["Button_sure"], 0.5)

        if not tonumber(width) then
            SL:ShowSystemTips("小地图宽度不能为空")
            return
        end

        if not tonumber(height) then
            SL:ShowSystemTips("小地图高度不能为空")
            return
        end

        if not tonumber(width2) then
            SL:ShowSystemTips("二级地图宽度不能为空")
            return
        end

        if not tonumber(height2) then
            SL:ShowSystemTips("二级地图高度不能为空")
            return
        end

        local saveValue = string.format("%s#%s|%s&%s#%s", width, height, skip and 1 or 0, width2, height2)

        SL:SetMetaValue("GAME_DATA", key, saveValue)
        SAVE_GAME_DATA(key, saveValue)

        SL:ShowSystemTips("修改成功")
    end)
end

return PCMainMiniMapSize