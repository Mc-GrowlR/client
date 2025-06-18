PickSetting = {}

PickSetting._config = nil
PickSetting._data = nil
PickSetting._selId = 1 
PickSetting._cells = {}

function PickSetting.main(parent)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "pick_setting_ui/pick_setting")
    PickSetting._ui = GUI:ui_delegate(parent)

    PickSetting.initConfigData()
    PickSetting.initBtns()
    PickSetting.showMenu()
end

function PickSetting.close()
    print("PickSetting.close")
end

function PickSetting.initBtns()
    GUI:addOnClickEvent(PickSetting._ui["Button_save"],function() 
        PickSetting._config = {}
        for i, data in pairs(PickSetting._data) do 
            local id = data.group
            PickSetting._config[id] = data
        end 

        SL:SaveTableToConfig(PickSetting._config, "cfg_pick_set")
        global.FileUtilCtl:purgeCachedEntries()
        SL:ShowSystemTips("保存成功")
    end)

    GUI:addOnClickEvent(PickSetting._ui["Button_add"], function()   
        local key = table.maxn(PickSetting._data)
        local maxId = key + 1
        PickSetting._data[maxId] = {
            group = maxId,
            name = "group"..maxId,    
        }

        PickSetting._selId = maxId

        local function createCell(parent)
            return PickSetting.createMenuCell(parent, PickSetting._data[maxId])
        end 
        local cell = GUI:QuickCell_Create(PickSetting._ui["ListView_menu"], "cell"..maxId, 0, 0, 400, 60, createCell)
        PickSetting._cells[maxId] = cell

        PickSetting.updateCells()
        GUI:ListView_jumpToBottom(PickSetting._ui["ListView_menu"])
        SL:ShowSystemTips("添加成功")
    end)

    GUI:addOnClickEvent(PickSetting._ui["Button_delete"], function() 
        local id = PickSetting._selId
        local cell = PickSetting._cells[id]
        GUI:ListView_removeChild(PickSetting._ui["ListView_menu"], cell)
        PickSetting._data[id] = nil
        PickSetting._cells[id] = nil
        SL:ShowSystemTips("删除成功")
    end)
    
    GUI:addOnClickEvent(PickSetting._ui["Button_edit"], function() 
        GUI:setVisible(PickSetting._ui["Panel_tips"], true)
        GUI:TextInput_setString(PickSetting._ui["Input_group"], "")
        GUI:TextInput_setString(PickSetting._ui["Input_name"], "")
    end)

    GUI:addOnClickEvent(PickSetting._ui["Btn_yes"],function() 
        local group = GUI:TextInput_getString(PickSetting._ui["Input_group"]) 
        local name = GUI:TextInput_getString(PickSetting._ui["Input_name"]) 

        local groupStr = string.gsub(group, "%s+", "")
        if string.len(groupStr) == 0 then
            SL:ShowSystemTips("组别不能为空")
            return false
        end

        -- if tonumber(group) then 
        --     if PickSetting._data[tonumber(group)] then 
        --         SL:ShowSystemTips("组别重复")
        --         return false  
        --     end 
        -- end 

        local nameStr = string.gsub(name, "%s+", "")
        if string.len(nameStr) == 0 then
            SL:ShowSystemTips("名称不能为空")
            return false
        end

        local id = PickSetting._selId
        local cell = PickSetting._cells[id]
        if not PickSetting._data[tonumber(group)] then 
            GUI:ListView_removeChild(PickSetting._ui["ListView_menu"], cell)
            PickSetting._data[id] = nil
            PickSetting._cells[id] = nil 

            PickSetting._data[tonumber(group)] = {
                group = tonumber(group),
                name = name,
            }

            local function createCell(parent)
                return PickSetting.createMenuCell(parent, PickSetting._data[tonumber(group)])
            end 
            local cell = GUI:QuickCell_Create(PickSetting._ui["ListView_menu"], "cell"..tonumber(group), 0, 0, 400, 60, createCell)
            PickSetting._cells[tonumber(group)] = cell

            PickSetting._selId = tonumber(group)

            GUI:ListView_jumpToBottom(PickSetting._ui["ListView_menu"])
        else 
            PickSetting._data[tonumber(group)].name = name
            PickSetting._selId = tonumber(group)
            PickSetting.updateCells()
        end 
        GUI:setVisible(PickSetting._ui["Panel_tips"], false)
    end)

    GUI:addOnClickEvent(PickSetting._ui["Btn_no"],function() 
        GUI:setVisible(PickSetting._ui["Panel_tips"], false)
    end)

    GUI:TextInput_setInputMode(PickSetting._ui["Input_group"], 3)
end  

function PickSetting.showMenu()
    local data = PickSetting.getConfigData()
    if not data and next(data) == nil then 
        return nil
    end

    GUI:ListView_removeAllItems(PickSetting._ui["ListView_menu"])
    for i, v in pairs(data) do 
        local function createCell(parent)
            return PickSetting.createMenuCell(parent, v)
        end 

        local cell_width = 400
        local cell_height = 60
        local cell = GUI:QuickCell_Create(PickSetting._ui["ListView_menu"], "cell"..v.group, 0, 0, cell_width, cell_height, createCell)
        PickSetting._cells[v.group] = cell
    end
    GUI:ListView_doLayout(PickSetting._ui["ListView_menu"])
end 

function PickSetting.createMenuCell(parent, data)
    loadConfigSettingExport(parent, "pick_setting_ui/menu_cell")
    local cell = GUI:getChildByName(parent, "page_cell")

    local ui_id = GUI:getChildByName(cell, "text_id") 
    GUI:Text_setString(ui_id, data.group)

    local ui_name = GUI:getChildByName(cell, "text_name") 
    GUI:Text_setString(ui_name, data.name)

    GUI:Layout_setBackGroundColor(cell, data.group == PickSetting._selId and "#ffbf6b" or "#000000")

    GUI:addOnClickEvent(cell, function()
        PickSetting._selId = data.group 
        PickSetting.updateCells()
    end)

    return cell
end

function PickSetting.updateCells()
    for i, cell in pairs(PickSetting._cells) do 
        GUI:QuickCell_Exit(cell)
        GUI:QuickCell_Refresh(cell)
    end 
end 

function PickSetting.initConfigData()
    PickSetting._config = {}
    local config = SL:RequireFile("game_config/cfg_pick_set.lua")
    PickSetting._config = config

    local data = {}
    for i, cfg in pairs(PickSetting._config) do 
        data[cfg.group] = cfg
    end 

    PickSetting._data = {}
    PickSetting._data = data
end 

function PickSetting.getConfigData()
    local data = {}
    for i, v in pairs(PickSetting._data) do 
        table.insert(data, v)
    end 

    table.sort(data, function(a, b) return a.group < b.group end)
    return data
end 

function PickSetting.getDataByID(id)
    for i, data in pairs(PickSetting._data) do 
        if data.ID == id then 
            return data
        end 
    end 
    return 
end 

return PickSetting