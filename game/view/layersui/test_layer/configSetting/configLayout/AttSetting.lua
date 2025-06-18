AttSetting = {}

AttSetting._config = nil
AttSetting._data = nil
AttSetting._selId = 1 
AttSetting._cells = {}
AttSetting._officalId = 200

function AttSetting.main(parent)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "att_setting_ui/att_setting")
    AttSetting._ui = GUI:ui_delegate(parent)

    AttSetting.initConfigData()
    AttSetting.initBtns()
    AttSetting.initInputEvent()
    AttSetting.showMenu()
end

function AttSetting.close()
    print("AttSetting.close")
end

function AttSetting.initBtns()
    GUI:addOnClickEvent(AttSetting._ui["Button_save"],function() 
        AttSetting._config = {}
        for i, data in pairs(AttSetting._data) do 
            local Id = data.Idx
            AttSetting._config[Id] = data
        end 

        SL:SaveTableToConfig(AttSetting._config, "cfg_att_score")
        global.FileUtilCtl:purgeCachedEntries()
        SL:ShowSystemTips("保存成功")
    end)

    GUI:addOnClickEvent(AttSetting._ui["Button_add"], function()    
        local key = table.maxn(AttSetting._data)
        if key <= AttSetting._officalId then 
            key = AttSetting._officalId
        end 

        local maxId = key + 1
        AttSetting._data[maxId] = {
            Idx = maxId,
            name = "att"..maxId,
            nbvalue="100#100#100",
            type = 1,
            desc = "",
            isshow = 0,
            sort = 999,      
        }

        local function createCell(parent)
            return AttSetting.createMenuCell(parent, AttSetting._data[maxId])
        end 
        local cell = GUI:QuickCell_Create(AttSetting._ui["ListView_menu1"], "cell"..maxId, 0, 0, 460, 65, createCell)
        AttSetting._cells[maxId] = cell
        AttSetting._selId = maxId

        AttSetting.updateCells()
        AttSetting.refreshAttInfo()
        GUI:ListView_jumpToBottom(AttSetting._ui["ListView_menu1"])
        SL:ShowSystemTips("添加成功")
    end)

    GUI:addOnClickEvent(AttSetting._ui["Button_delete"], function() 
        local id = AttSetting._selId
        if id <= AttSetting._officalId then 
            SL:ShowSystemTips("官方属性 禁止删除")
            return 
        end 

        local cell = AttSetting._cells[id]
        GUI:ListView_removeChild(AttSetting._ui["ListView_menu1"], cell)
        AttSetting._data[id] = nil
        AttSetting._cells[id] = nil
        AttSetting._selId = table.maxn(AttSetting._data)
        AttSetting.updateCells()
        AttSetting.refreshAttInfo()
        GUI:ListView_jumpToBottom(AttSetting._ui["ListView_menu1"])
        SL:ShowSystemTips("删除成功")
    end)
end  

function AttSetting.initInputEvent()
    GUI:TextInput_setInputMode(AttSetting._ui["Input_id"], 3)
    GUI:TextInput_setInputMode(AttSetting._ui["Input_type"], 3)
    GUI:TextInput_setInputMode(AttSetting._ui["Input_show"], 3)
    GUI:TextInput_setInputMode(AttSetting._ui["Input_sort"], 3)
    GUI:TextInput_setInputMode(AttSetting._ui["Input_color"], 3)
    GUI:TextInput_setInputMode(AttSetting._ui["Input_excolor"], 3)

    local function checkSthing(inputStr)
        local str = string.gsub(inputStr, "%s+", "")
        if string.len(str) == 0 then
            SL:ShowSystemTips("不能为空")
            return false
        end
        return true
    end 

    local function refreshCell(id)
        GUI:QuickCell_Exit(AttSetting._cells[id])
        GUI:QuickCell_Refresh(AttSetting._cells[id])
    end 

    GUI:TextInput_addOnEvent(AttSetting._ui["Input_id"], function(_, eventType)
        if eventType == 1 then
            local id = AttSetting._selId
            local data = AttSetting._data[id]
            if not data or next(data) == nil then 
                return 
            end 

            local inputStr = GUI:TextInput_getString(AttSetting._ui["Input_id"])
            local bOk = checkSthing(inputStr)
            if data.Idx <= AttSetting._officalId then 
                SL:ShowSystemTips("官方数据 不能修改")
                bOk = false
            end 
            if not bOk then 
                GUI:TextInput_setString(AttSetting._ui["Input_id"], data.Idx)
                return
            end 

            AttSetting._data[id].Idx = tonumber(inputStr)

            refreshCell(id)
        end 
    end) 

    GUI:TextInput_addOnEvent(AttSetting._ui["Input_name"], function(_, eventType)
        if eventType == 1 then
            local id = AttSetting._selId
            local data = AttSetting._data[id]
            if not data or next(data) == nil then 
                return 
            end 

            local inputStr = GUI:TextInput_getString(AttSetting._ui["Input_name"])
            local bOk = checkSthing(inputStr)
            if not bOk then 
                GUI:TextInput_setString(AttSetting._ui["Input_name"], data.name)
                return
            end 

            AttSetting._data[id].name = inputStr

            refreshCell(id)
        end 
    end) 

    GUI:TextInput_addOnEvent(AttSetting._ui["Input_type"], function(_, eventType)
        if eventType == 1 then
            local id = AttSetting._selId
            local data = AttSetting._data[id]
            if not data or next(data) == nil then 
                return 
            end 

            local inputStr = GUI:TextInput_getString(AttSetting._ui["Input_type"])
            local bOk = checkSthing(inputStr)
            if data.Idx <= AttSetting._officalId then 
                SL:ShowSystemTips("官方数据 不能修改")
                bOk = false
            end 
            if not bOk then 
                GUI:TextInput_setString(AttSetting._ui["Input_type"], data.type)
                return
            end 

            AttSetting._data[id].type = tonumber(inputStr)

            refreshCell(id)
        end 
    end) 

    GUI:TextInput_addOnEvent(AttSetting._ui["Input_sort"], function(_, eventType)
        if eventType == 1 then
            local id = AttSetting._selId
            local data = AttSetting._data[id]
            if not data or next(data) == nil then 
                return 
            end 

            local inputStr = GUI:TextInput_getString(AttSetting._ui["Input_sort"])
            local bOk = checkSthing(inputStr)
            if not bOk then 
                GUI:TextInput_setString(AttSetting._ui["Input_sort"], data.sort)
                return
            end 

            AttSetting._data[id].sort = tonumber(inputStr)

            refreshCell(id)
        end 
    end) 

    GUI:TextInput_addOnEvent(AttSetting._ui["Input_show"], function(_, eventType)
        if eventType == 1 then
            local id = AttSetting._selId
            local data = AttSetting._data[id]
            if not data or next(data) == nil then 
                return 
            end 

            local inputStr = GUI:TextInput_getString(AttSetting._ui["Input_show"])
            local bOk = checkSthing(inputStr)
            if not bOk then 
                GUI:TextInput_setString(AttSetting._ui["Input_show"], data.isshow)
                return
            end 

            if tonumber(inputStr) ~= 1 and tonumber(inputStr) ~= 2 and tonumber(inputStr) ~= 0 then 
                SL:ShowSystemTips("显示数值错误")
                return
            end 

            AttSetting._data[id].isshow = tonumber(inputStr)

            refreshCell(id)
        end 
    end) 

    GUI:TextInput_addOnEvent(AttSetting._ui["Input_equipTips"], function(_, eventType)
        if eventType == 1 then
            local id = AttSetting._selId
            local data = AttSetting._data[id]
            if not data or next(data) == nil then 
                return 
            end 

            local inputStr = GUI:TextInput_getString(AttSetting._ui["Input_equipTips"])
            local bOk = checkSthing(inputStr)
            if not bOk then 
                GUI:TextInput_setString(AttSetting._ui["Input_equipTips"], data.noshowtips or "")
                return
            end 

            if tonumber(inputStr) ~= 1 and tonumber(inputStr) ~= 0 then 
                SL:ShowSystemTips("显示数值错误")
                return
            end 

            AttSetting._data[id].noshowtips = tonumber(inputStr)
        end  
    end) 

    GUI:TextInput_addOnEvent(AttSetting._ui["Input_color"], function(_, eventType)
        if eventType == 1 then
            local id = AttSetting._selId
            local data = AttSetting._data[id]
            if not data or next(data) == nil then 
                return 
            end 

            local inputStr = GUI:TextInput_getString(AttSetting._ui["Input_color"])
            local bOk = checkSthing(inputStr)
            if not bOk then 
                GUI:TextInput_setString(AttSetting._ui["Input_color"], data.color and data.color or 255)
                return
            end 

            AttSetting._data[id].color = tonumber(inputStr)
            GUI:Layout_setBackGroundColor(AttSetting._ui["panel_color"], SL:GetHexColorByStyleId(tonumber(inputStr)))
        end
    end)

    GUI:TextInput_addOnEvent(AttSetting._ui["Input_excolor"], function(_, eventType)
        if eventType == 1 then
            local id = AttSetting._selId
            local data = AttSetting._data[id]
            if not data or next(data) == nil then 
                return 
            end 

            local inputStr = GUI:TextInput_getString(AttSetting._ui["Input_excolor"])
            local bOk = checkSthing(inputStr)
            if not bOk then 
                GUI:TextInput_setString(AttSetting._ui["Input_excolor"], data.excolor and data.excolor or 255)
                return
            end 

            AttSetting._data[id].excolor = tonumber(inputStr)
            GUI:Layout_setBackGroundColor(AttSetting._ui["panel_excolor"], SL:GetHexColorByStyleId(tonumber(inputStr)))
        end
    end)

    GUI:TextInput_addOnEvent(AttSetting._ui["Input_desc"], function(_, eventType)
        if eventType == 1 then
            local id = AttSetting._selId
            local data = AttSetting._data[id]
            if not data or next(data) == nil then 
                return 
            end 

            local inputStr = GUI:TextInput_getString(AttSetting._ui["Input_desc"])
            local bOk = checkSthing(inputStr)
            if not bOk then 
                GUI:TextInput_setString(AttSetting._ui["Input_desc"], data.desc)
                return
            end 

            AttSetting._data[id].desc = inputStr

            refreshCell(id)
        end 
    end) 

    GUI:CheckBox_addOnEvent(AttSetting._ui["CB_yuansu"], function()
        local bCheck = GUI:CheckBox_isSelected(AttSetting._ui["CB_yuansu"])
        local id = AttSetting._selId
        
        AttSetting._data[id].ys = bCheck and 1 or 0
        refreshCell(id)
    end)
end 

function AttSetting.refreshAttInfo()
    local id = AttSetting._selId
    local data = AttSetting._data[id]
    if not data or next(data) == nil then 
        return false
    end 

    local input_name = AttSetting._ui["Input_name"]
    local input_id = AttSetting._ui["Input_id"]
    local input_type = AttSetting._ui["Input_type"]
    local input_show = AttSetting._ui["Input_show"]
    local input_sort = AttSetting._ui["Input_sort"]
    local input_equipTips = AttSetting._ui["Input_equipTips"]
    local input_color = AttSetting._ui["Input_color"]
    local input_excolor = AttSetting._ui["Input_excolor"]
    local input_desc = AttSetting._ui["Input_desc"]

    GUI:Text_setString(input_name, data.name)
    GUI:Text_setString(input_id, data.Idx)
    GUI:Text_setString(input_type, data.type)
    GUI:Text_setString(input_show, data.isshow)
    GUI:Text_setString(input_sort, data.sort)
    GUI:Text_setString(input_equipTips, data.noshowtips or "")
    GUI:Text_setString(input_desc, data.desc or "")

    local colorStr = tonumber(data.color) and SL:GetHexColorByStyleId(tonumber(data.color)) or "#ffffff"
    GUI:Text_setString(input_color, tonumber(data.color) and tonumber(data.color) or 255)
    GUI:Layout_setBackGroundColor(AttSetting._ui["panel_color"], colorStr)

    local colorStr2 = tonumber(data.excolor) and SL:GetHexColorByStyleId(tonumber(data.color)) or "#ffffff"
    GUI:Text_setString(input_excolor, tonumber(data.excolor) and tonumber(data.excolor) or 255)
    GUI:Layout_setBackGroundColor(AttSetting._ui["panel_excolor"], colorStr2)
end 

function AttSetting.showMenu()
    local data = AttSetting.getAttData()
    if not data and next(data) == nil then 
        return nil
    end

    GUI:ListView_removeAllItems(AttSetting._ui["ListView_menu1"])
    for i, v in pairs(data) do 
        local function createCell(parent)
            return AttSetting.createMenuCell(parent, v)
        end 

        local cell_width = 460
        local cell_height = 65
        local cell = GUI:QuickCell_Create(AttSetting._ui["ListView_menu1"], "cell"..v.Idx, 0, 0, cell_width, cell_height, createCell)
        AttSetting._cells[v.Idx] = cell
    end

    AttSetting.refreshAttInfo()
end 

function AttSetting.createMenuCell(parent, data)
    loadConfigSettingExport(parent, "att_setting_ui/menu_cell")
    local cell = GUI:getChildByName(parent, "page_cell")

    local ui_id = GUI:getChildByName(cell, "text_id") 
    GUI:Text_setString(ui_id, data.Idx)

    local ui_name = GUI:getChildByName(cell, "text_name") 
    GUI:Text_setString(ui_name, data.name)

    local ui_type = GUI:getChildByName(cell, "text_type") 
    GUI:Text_setString(ui_type, data.type)

    local ui_show = GUI:getChildByName(cell, "text_show") 
    GUI:Text_setString(ui_show, data.isshow)

    local ui_sort = GUI:getChildByName(cell, "text_sort") 
    GUI:Text_setString(ui_sort, data.sort)

    local ui_yuansu = GUI:getChildByName(cell, "text_yuansu") 
    GUI:Text_setString(ui_yuansu, data.ys == 1 and "是" or "否")

    GUI:Layout_setBackGroundColor(cell, data.Idx == AttSetting._selId and "#ffbf6b" or "#000000")

    GUI:addOnClickEvent(cell, function()
        AttSetting._selId = data.Idx
        AttSetting.updateCells()   
        AttSetting.refreshAttInfo()
    end)

    return cell
end

function AttSetting.updateCells()
    for i, cell in pairs(AttSetting._cells) do 
        GUI:QuickCell_Exit(cell)
        GUI:QuickCell_Refresh(cell)
    end 
end 

function AttSetting.initConfigData()
    AttSetting._config = {}
    local config = SL:RequireFile("game_config/cfg_att_score.lua")

    -- 服务开关 修改属性为万分比
    if GET_GAME_STATE() == global.MMO.GAME_STATE_WORLD then
        local bFixMagicMiss = SL:GetMetaValue("SERVER_OPTION", "NewMagicMissType")
        if bFixMagicMiss then 
            config[15].type = 2
        end 

        local bFixOther = SL:GetMetaValue("SERVER_OPTION", "UseYSNewCalType")
        if bFixOther then 
            for i = 21, 31 do 
                config[i].type = 2
            end 
            config[43].type = 2
            config[72].type = 2
        end 
    end 

    AttSetting._config = config

    local data = {}
    for i, cfg in pairs(AttSetting._config) do 
        data[cfg.Idx] = cfg
    end 

    AttSetting._data = {}
    AttSetting._data = data
end 

function AttSetting.getAttData()
    local data = {}
    for i, v in pairs(AttSetting._data) do 
        table.insert(data, v)
    end 

    table.sort(data, function(a, b) return a.Idx < b.Idx end)
    return data
end 

return AttSetting