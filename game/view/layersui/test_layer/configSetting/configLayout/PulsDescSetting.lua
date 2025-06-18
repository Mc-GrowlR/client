PulsDescSetting = {}

PulsDescSetting._config = nil
PulsDescSetting._data = nil
PulsDescSetting._selIndex = 1 
PulsDescSetting._cells = {}

function PulsDescSetting.main(parent)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "puls_desc_setting_ui/puls_desc_setting")
    PulsDescSetting._ui = GUI:ui_delegate(parent)

    PulsDescSetting.initConfigData()
    PulsDescSetting.initBtns()
    PulsDescSetting.initInputEvent()
    PulsDescSetting.showMenu()
end

function PulsDescSetting.close()
    print("PulsDescSetting.close")
end

function PulsDescSetting.initBtns()
    GUI:addOnClickEvent(PulsDescSetting._ui["Button_save"],function() 
        for i, data in ipairs(PulsDescSetting._data) do 
            local id = data.id
            PulsDescSetting._config[id] = data
        end 

        SL:SaveTableToConfig(PulsDescSetting._config, "cfg_PulsDesc")
        global.FileUtilCtl:purgeCachedEntries()
        SL:ShowSystemTips("保存成功")
    end)
end  

function PulsDescSetting.initInputEvent()
    GUI:TextInput_setInputMode(PulsDescSetting._ui["Input_name"], 5)
    GUI:TextInput_setInputMode(PulsDescSetting._ui["Input_off"], 5)
    GUI:TextInput_setInputMode(PulsDescSetting._ui["Input_on"], 5)

    local function checkSthing(inputStr)
        local str = string.gsub(inputStr, "%s+", "")
        if string.len(str) == 0 then
            SL:ShowSystemTips("不能为空")
            return false
        end
        return true
    end 

    local function refreshCell(index)
        GUI:QuickCell_Exit(PulsDescSetting._cells[index])
        GUI:QuickCell_Refresh(PulsDescSetting._cells[index])
    end 

    GUI:TextInput_addOnEvent(PulsDescSetting._ui["Input_name"], function(_, eventType)
        if eventType == 1 then
            local index = PulsDescSetting._selIndex
            local data = PulsDescSetting._data[index]
            if not data or next(data) == nil then 
                return 
            end 

            local inputStr = GUI:TextInput_getString(PulsDescSetting._ui["Input_name"])
            local bOk = checkSthing(inputStr)
            if not bOk then 
                GUI:TextInput_setString(PulsDescSetting._ui["Input_name"], data.name)
                return
            end 

            PulsDescSetting._data[index].name = inputStr

            refreshCell(index)
        end 
    end) 

    GUI:TextInput_addOnEvent(PulsDescSetting._ui["Input_off"], function(_, eventType)
        if eventType == 1 then
            local index = PulsDescSetting._selIndex
            local data = PulsDescSetting._data[index]
            if not data or next(data) == nil then 
                return 
            end 

            local inputStr = GUI:TextInput_getString(PulsDescSetting._ui["Input_off"])
            local bOk = checkSthing(inputStr)
            if not bOk then 
                GUI:TextInput_setString(PulsDescSetting._ui["Input_off"], data.unableTips)
                return
            end 

            PulsDescSetting._data[index].unableTips = inputStr

            refreshCell(index)
        end 
    end) 

    GUI:TextInput_addOnEvent(PulsDescSetting._ui["Input_on"], function(_, eventType)
        if eventType == 1 then
            local index = PulsDescSetting._selIndex
            local data = PulsDescSetting._data[index]
            if not data or next(data) == nil then 
                return 
            end 

            local inputStr = GUI:TextInput_getString(PulsDescSetting._ui["Input_on"])
            local bOk = checkSthing(inputStr)
            if not bOk then 
                GUI:TextInput_setString(PulsDescSetting._ui["Input_on"], data.openTips)
                return
            end 

            PulsDescSetting._data[index].openTips = inputStr

            refreshCell(index)
        end 
    end) 
end 

function PulsDescSetting.showMenu(index)
    local data = PulsDescSetting.getConfigData()
    if not data and next(data) == nil then 
        return nil
    end

    GUI:ListView_removeAllItems(PulsDescSetting._ui["ListView_menu"])
    for i, v in ipairs(data) do 
        local function createCell(parent)
            return PulsDescSetting.createMenuCell(parent, v, i)
        end 

        local cell_width = 200
        local cell_height = 60
        local cell = GUI:QuickCell_Create(PulsDescSetting._ui["ListView_menu"], "cell"..v.id, 0, 0, cell_width, cell_height, createCell)
        PulsDescSetting._cells[v.id] = cell
    end

    PulsDescSetting.refreshInfo()
end 

function PulsDescSetting.createMenuCell(parent, data, index)
    loadConfigSettingExport(parent, "puls_desc_setting_ui/menu_cell")
    local cell = GUI:getChildByName(parent, "page_cell")

    local ui_id = GUI:getChildByName(cell, "text_id") 
    GUI:Text_setString(ui_id, data.id)

    local ui_name = GUI:getChildByName(cell, "text_name") 
    GUI:Text_setString(ui_name, data.name)

    GUI:Layout_setBackGroundColor(cell, index == PulsDescSetting._selIndex and "#ffbf6b" or "#000000")

    GUI:addOnClickEvent(cell, function()
        PulsDescSetting._selIndex = index
        PulsDescSetting.updateCells() 
        PulsDescSetting.refreshInfo()
    end)

    return cell
end

function PulsDescSetting.updateCells()
    for i, cell in pairs(PulsDescSetting._cells) do 
        GUI:QuickCell_Exit(cell)
        GUI:QuickCell_Refresh(cell)
    end 
end 

function PulsDescSetting.refreshInfo()
    local index = PulsDescSetting._selIndex
    local data = PulsDescSetting._data[index]
    if not data or next(data) == nil then 
        return false
    end 

    local input_name = PulsDescSetting._ui["Input_name"]
    local input_off = PulsDescSetting._ui["Input_off"]
    local input_on = PulsDescSetting._ui["Input_on"]

    GUI:Text_setString(input_name, data.name)
    GUI:Text_setString(input_off, data.unableTips)
    GUI:Text_setString(input_on, data.openTips)
end 

function PulsDescSetting.initConfigData()
    PulsDescSetting._config = {}
    local config = requireGameConfig("cfg_PulsDesc")
    PulsDescSetting._config = config

    PulsDescSetting._data = {}
    for i, cfg in pairs(config) do 
        table.insert(PulsDescSetting._data, cfg)
    end 

    table.sort(PulsDescSetting._data, function(a, b) return a.id < b.id end)
end 

function PulsDescSetting.getConfigData()
    return PulsDescSetting._data or nil
end 

function PulsDescSetting.getDataByID(id)
    for i, data in pairs(PulsDescSetting._data) do 
        if data.ID == id then 
            return data
        end 
    end 
    return 
end 

return PulsDescSetting