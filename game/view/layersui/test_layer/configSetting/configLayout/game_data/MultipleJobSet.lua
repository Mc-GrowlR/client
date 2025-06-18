MultipleJobSet = {}

local setData = {
    [2] = {id = 2, ui = "input_name"},
    [3] = {id = 3, ui = "input_hud_str"},
    [4] = {id = 4, ui = "input_create_id_m"},
    [5] = {id = 5, ui = "input_create_id_f"},
    [6] = {id = 6, ui = "input_g_id_m"},
    [7] = {id = 7, ui = "input_g_id_f"},
    [8] = {id = 8, ui = "input_feature_id"},
    [9] = {id = 9, ui = "input_model_m"},
    [10] = {id = 10, ui = "input_model_f"},
}

MultipleJobSet._modelPath = "res/private/player_model/"

function MultipleJobSet.main(parent, param)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "game_data/multiple_job_set")
    MultipleJobSet._ui = GUI:ui_delegate(parent)
    MultipleJobSet._id = 5 

    local key = param.key
    if not key or string.len(key) <= 0 then
        return
    end
    MultipleJobSet._key = key

    local ui = MultipleJobSet._ui

    MultipleJobSet.initOpenCell()
    MultipleJobSet.initPullDownCells()
    MultipleJobSet.initData()

    GUI:addOnClickEvent(MultipleJobSet._ui["Button_sure"], function()
        GUI:delayTouchEnabled(MultipleJobSet._ui["Button_sure"], 0.5)

        local saveValue = MultipleJobSet.getInputInfo()

        SL:SetMetaValue("GAME_DATA", key .. MultipleJobSet._id, saveValue)
        SAVE_GAME_DATA(key .. MultipleJobSet._id, saveValue)

        SL:ShowSystemTips("保存成功")
    end)

    for i = 1, 2 do
        local selBtn = MultipleJobSet._ui["sel_btn_" .. i]
        GUI:addOnClickEvent(selBtn, function()
            local function callFunc(res)
                if not res or res == "" then
                    return
                end

                if not string.find(res, MultipleJobSet._modelPath) then
                    return
                end

                local name = string.gsub(res, MultipleJobSet._modelPath, "")
                name = string.gsub(name, "(.png)$", "")
                local key = (i == 1 and "m" or "f")
                MultipleJobSet["model_pic_" .. key] = name
                GUI:TextInput_setString(MultipleJobSet._ui["input_model_" .. key], name)
            end

            local imgName = MultipleJobSet["model_pic_" .. key]
            local resPath = MultipleJobSet._modelPath .. ((imgName and imgName ~= "") and imgName or string.format("%08d", 460))
            global.Facade:sendNotification(global.NoticeTable.Layer_GUIResSelector_Open, {res = resPath .. ".png", callfunc = callFunc})
        end)
    end

end

function MultipleJobSet.initData()
    MultipleJobSet._setData = {}
    local value = SL:GetMetaValue("GAME_DATA", MultipleJobSet._key .. MultipleJobSet._id)
    if value and string.len(value) > 0 then
        local param = string.split(value, "|")
        MultipleJobSet["open_" .. MultipleJobSet._id] = tonumber(param[1]) == 1
        MultipleJobSet._setData[2] = param[2]
        MultipleJobSet._setData[3] = param[3]
        MultipleJobSet._setData[4] = tonumber(param[4])
        MultipleJobSet._setData[5] = tonumber(param[5])
        MultipleJobSet._setData[6] = tonumber(param[6])
        MultipleJobSet._setData[7] = tonumber(param[7])
        MultipleJobSet._setData[8] = tonumber(param[8])
        MultipleJobSet._setData[9] = param[9]
        MultipleJobSet["model_pic_m"] = param[9]
        MultipleJobSet._setData[10] = param[10]
        MultipleJobSet["model_pic_f"] = param[10]
    end 

    local ui = MultipleJobSet._ui
    for i = 2, 10 do 
        local ui_name = setData[i] and setData[i].ui
        local ui_input = ui_name and ui[ui_name]
        if ui_input then 
            GUI:TextInput_setString(ui_input, MultipleJobSet._setData[i] or "")
            if i >= 4 and i <= 8 then
                GUI:TextInput_setInputMode(ui_input, 2) 
            end
        end 
    end 

    if MultipleJobSet.Panel_off and MultipleJobSet.Panel_on then
        local enable = MultipleJobSet["open_" .. MultipleJobSet._id]
        GUI:setVisible(MultipleJobSet.Panel_off, not enable)
        GUI:setVisible(MultipleJobSet.Panel_on, enable)
    end
    GUI:Text_setString(MultipleJobSet._ui["Text_select_job"], string.format("自定义职业%s", MultipleJobSet._id))
    GUI:setRotation(MultipleJobSet._ui["arrow_job"], 0)
end

function MultipleJobSet.initOpenCell()
    loadConfigSettingExport(MultipleJobSet._ui.Node_open, "game_data/click_cell")
    local clickCell = GUI:getChildByName(MultipleJobSet._ui.Node_open, "click_cell")
    GUI:setPosition(clickCell, -10, 6)

    local Text_desc = GUI:getChildByName(clickCell, "Text_desc")
    GUI:Text_setFontSize(Text_desc, 13)
    GUI:Text_setString(Text_desc, "开关")

    local CheckBox_able = GUI:getChildByName(clickCell, "CheckBox_able")
    MultipleJobSet.Panel_off = GUI:getChildByName(CheckBox_able, "Panel_off")
    MultipleJobSet.Panel_on = GUI:getChildByName(CheckBox_able, "Panel_on")

    local function setClickCellStatus(enable)
        GUI:setVisible(MultipleJobSet.Panel_off, not enable)
        GUI:setVisible(MultipleJobSet.Panel_on, enable)
    end

    setClickCellStatus(MultipleJobSet["open_" .. MultipleJobSet._id])

    GUI:addOnClickEvent(clickCell, function()
        local id = MultipleJobSet._id
        MultipleJobSet["open_" .. id] = not MultipleJobSet["open_" .. id]
        setClickCellStatus(MultipleJobSet["open_" .. id])
    end)
end

function MultipleJobSet.initPullDownCells()
    MultipleJobSet.Image_pulldown_bg = MultipleJobSet._ui["Image_pulldown_bg"]
    MultipleJobSet.ListView_pulldown = GUI:getChildByName(MultipleJobSet.Image_pulldown_bg, "ListView_pulldown")
    MultipleJobSet.Layout_hide_pullDownList = MultipleJobSet._ui["Layout_hide_pullDownList"]
    GUI:setSwallowTouches(MultipleJobSet.Layout_hide_pullDownList, false)
    GUI:addOnClickEvent(MultipleJobSet.Layout_hide_pullDownList, function()
        MultipleJobSet.hidePullDownCells()
    end)

    local function showItems(callBackFunc, width, maxHeight)
        GUI:ListView_removeAllItems(MultipleJobSet.ListView_pulldown)

        for i = 5, 15 do
            local Image_bg = GUI:Image_Create(MultipleJobSet.ListView_pulldown, "Image_bg" .. i, 0, 0, "res/public/1900000668.png")
            GUI:Image_setScale9Slice(Image_bg, 51, 51, 10, 10)
            GUI:setContentSize(Image_bg, width, 28)
            GUI:setIgnoreContentAdaptWithSize(Image_bg, false)
            GUI:setTouchEnabled(Image_bg, true)

            local text_name = GUI:Text_Create(Image_bg, "text_name", 49, 14, 14, "#FFFFFF", string.format("自定义职业%s", i))
            GUI:setAnchorPoint(text_name, 0.5, 0.5)

            GUI:addOnClickEvent(Image_bg, function()
                callBackFunc(i)
                MultipleJobSet.hidePullDownCells()
            end)
        end
        local count = GUI:ListView_getItemCount(MultipleJobSet.ListView_pulldown)

        local width, height = width, math.min(28 * count, maxHeight or 9999999)

        GUI:setContentSize(MultipleJobSet.ListView_pulldown, width, height)
        GUI:setPositionX(MultipleJobSet.ListView_pulldown, (width + 2) / 2)
        GUI:setContentSize(MultipleJobSet.Image_pulldown_bg, width + 2, height + 2)
        GUI:setPositionY(MultipleJobSet.ListView_pulldown, height + 1)
    end

    local bg_job = MultipleJobSet._ui["bg_job"]
    local width = GUI:getContentSize(bg_job).width
    GUI:addOnClickEvent(bg_job, function()
        showItems(function(index)
            MultipleJobSet._id = index
            MultipleJobSet.initData()
        end, width, 400)
        local node_pos = GUI:getPosition(bg_job)
        GUI:setPosition(MultipleJobSet.Image_pulldown_bg, node_pos.x, node_pos.y)
        GUI:setVisible(MultipleJobSet.Image_pulldown_bg, true)
        GUI:setVisible(MultipleJobSet.Layout_hide_pullDownList, true)
        GUI:setRotation(MultipleJobSet._ui["arrow_job"], 180)
    end)
end

function MultipleJobSet.hidePullDownCells()
    GUI:setVisible(MultipleJobSet.Image_pulldown_bg, false)
    GUI:setVisible(MultipleJobSet.Layout_hide_pullDownList, false)
    GUI:ListView_removeAllItems(MultipleJobSet.ListView_pulldown)

    GUI:setRotation(MultipleJobSet._ui["arrow_job"], 0)
end

function MultipleJobSet.getInputInfo()
    local ui = MultipleJobSet._ui
    local info = ""
    local tempData = {}
    for i = 2, 10 do
        local ui_name = setData[i] and setData[i].ui
        local ui_input = ui_name and ui[ui_name]
        if ui_input then 
            local inputStr = GUI:TextInput_getString(ui_input)
            if i == 9 then
                inputStr = MultipleJobSet["model_pic_m"] or ""
            elseif i == 10 then
                inputStr = MultipleJobSet["model_pic_f"] or ""
            end
            table.insert(tempData, inputStr)
        end 
    end 


    local openValue = MultipleJobSet["open_" .. MultipleJobSet._id] and 1 or 0
    local value = table.concat(tempData, "|")
    info = openValue .. "|" .. value

    return info
end 


return MultipleJobSet