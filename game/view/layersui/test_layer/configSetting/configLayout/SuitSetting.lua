SuitSetting = {}

SuitSetting._config = nil
SuitSetting._data = nil
SuitSetting._selId = 1 
SuitSetting._cells = {}

function SuitSetting.main(parent)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "suit_setting_ui/suit_setting")
    SuitSetting._ui = GUI:ui_delegate(parent)

    if GET_GAME_STATE() ~= global.MMO.GAME_STATE_WORLD then
        SL:ShowSystemTips("请进入游戏世界.......")
        return 
    end 

    SuitSetting.initConfigData()
    SuitSetting.initBtns()
    SuitSetting.showMenu()
end

function SuitSetting.close()
    print("SuitSetting.close")
end

function SuitSetting.initBtns()
    GUI:addOnClickEvent(SuitSetting._ui["Button_save"],function() 
        for i, data in pairs(SuitSetting._data) do 
            local id = data.Idx
            SuitSetting._config[id] = data
        end 

        SL:SaveTableToConfig(SuitSetting._config, "cfg_suit")
        global.FileUtilCtl:purgeCachedEntries()
        SL:ShowSystemTips("保存成功")

        SL:ShowLoadingBar(1)
        local function updateConfig()
            local ItemTipsProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemTipsProxy)
            ItemTipsProxy:LoadConfig()
        end 
        SL:ScheduleOnce(updateConfig, 0.5) 

        local function refreshUI()
            SuitSetting.refreshInfo(SuitSetting._data[SuitSetting._selId])
        end 
        SL:ScheduleOnce(refreshUI, 1) 
    end)

    GUI:addOnClickEvent(SuitSetting._ui["Button_add"], function()   
        local key = table.maxn(SuitSetting._data)
        local maxId = key + 1
        SuitSetting._data[maxId] = {
            Idx = maxId,
            package = "Idx"..maxId,  
            notes = "",  
        }

        SuitSetting._selId = maxId

        local function createCell(parent)
            return SuitSetting.createMenuCell(parent, SuitSetting._data[maxId])
        end 
        local cell = GUI:QuickCell_Create(SuitSetting._ui["ListView_menu"], "cell"..maxId, 0, 0, 400, 60, createCell)
        SuitSetting._cells[maxId] = cell

        SuitSetting.updateCells()
        GUI:ListView_jumpToBottom(SuitSetting._ui["ListView_menu"])
        SL:ShowSystemTips("添加成功")
    end)

    GUI:addOnClickEvent(SuitSetting._ui["Button_delete"], function() 
        local id = SuitSetting._selId
        local cell = SuitSetting._cells[id]
        GUI:ListView_removeChild(SuitSetting._ui["ListView_menu"], cell)
        SuitSetting._data[id] = nil
        SuitSetting._cells[id] = nil
        SL:ShowSystemTips("删除成功")
    end)

    GUI:TextInput_setInputMode(SuitSetting._ui["Input_id"], 3)
    GUI:addOnClickEvent(SuitSetting._ui["Button_edit"], function() 
        GUI:setVisible(SuitSetting._ui["Panel_tips"], true)
        GUI:TextInput_setString(SuitSetting._ui["Input_id"], "")
        GUI:TextInput_setString(SuitSetting._ui["Input_name"], "")
    end)

    GUI:addOnClickEvent(SuitSetting._ui["Btn_yes"],function() 
        local sId = GUI:TextInput_getString(SuitSetting._ui["Input_id"]) 
        local sName = GUI:TextInput_getString(SuitSetting._ui["Input_name"]) 

        local idStr = string.gsub(sId, "%s+", "")
        if string.len(idStr) == 0 then
            SL:ShowSystemTips("Id不能为空")
            return false
        end

        local nameStr = string.gsub(sName, "%s+", "")
        if string.len(nameStr) == 0 then
            SL:ShowSystemTips("名称不能为空")
            return false
        end

        local id = SuitSetting._selId
        local cell = SuitSetting._cells[id]
        if not SuitSetting._data[tonumber(idStr)] then 
            GUI:ListView_removeChild(SuitSetting._ui["ListView_menu"], cell)
            SuitSetting._data[id] = nil
            SuitSetting._cells[id] = nil 

            SuitSetting._data[tonumber(idStr)] = {
                Idx = tonumber(idStr),
                package = nameStr,
            }

            local function createCell(parent)
                return SuitSetting.createMenuCell(parent, SuitSetting._data[tonumber(idStr)])
            end 
            local cell = GUI:QuickCell_Create(SuitSetting._ui["ListView_menu"], "cell"..tonumber(idStr), 0, 0, 400, 60, createCell)
            SuitSetting._cells[tonumber(idStr)] = cell

            SuitSetting._selId = tonumber(idStr)

            GUI:ListView_jumpToBottom(SuitSetting._ui["ListView_menu"])
        else 
            SuitSetting._data[tonumber(idStr)].package = nameStr
            SuitSetting._selId = tonumber(idStr)
            SuitSetting.updateCells()
        end 
        GUI:setVisible(SuitSetting._ui["Panel_tips"], false)
    end)

    GUI:addOnClickEvent(SuitSetting._ui["Btn_no"],function() 
        GUI:setVisible(SuitSetting._ui["Panel_tips"], false)
    end)

    GUI:TextInput_addOnEvent(SuitSetting._ui["Input_edit"], function (_, eventType)
        if eventType == 1 then
            local id = SuitSetting._selId
            local inputStr = GUI:TextInput_getString(SuitSetting._ui["Input_edit"])
            local str = string.gsub(inputStr, "%s+", "")
            if string.len(str) == 0 then
                SL:ShowSystemTips("不能为空")
                GUI:TextInput_setString(SuitSetting._ui["Input_edit"], SuitSetting._data[id].notes)
                return false
            end

            SuitSetting._data[id].notes = inputStr

            --SuitSetting.refreshInfo(SuitSetting._data[id])
        end
    end)
end  

function SuitSetting.showMenu()
    local data = SuitSetting.getConfigData()
    if not data and next(data) == nil then 
        return nil
    end

    GUI:ListView_removeAllItems(SuitSetting._ui["ListView_menu"])
    for i, v in pairs(data) do 
        local function createCell(parent)
            return SuitSetting.createMenuCell(parent, v)
        end 

        local cell_width = 400
        local cell_height = 60
        local cell = GUI:QuickCell_Create(SuitSetting._ui["ListView_menu"], "cell"..v.Idx, 0, 0, cell_width, cell_height, createCell)
        SuitSetting._cells[v.Idx] = cell
    end
    GUI:ListView_doLayout(SuitSetting._ui["ListView_menu"])

    SuitSetting.showEditInfo(SuitSetting._data[1])
    SuitSetting.refreshInfo(SuitSetting._data[1])
end 

function SuitSetting.createMenuCell(parent, data)
    loadConfigSettingExport(parent, "suit_setting_ui/menu_cell")
    local cell = GUI:getChildByName(parent, "page_cell")

    local ui_id = GUI:getChildByName(cell, "text_id") 
    GUI:Text_setString(ui_id, data.Idx)

    local ui_name = GUI:getChildByName(cell, "text_name") 
    GUI:Text_setString(ui_name, data.package)

    GUI:Layout_setBackGroundColor(cell, data.Idx == SuitSetting._selId and "#ffbf6b" or "#000000")

    GUI:addOnClickEvent(cell, function()
        SuitSetting._selId = data.Idx 
        SuitSetting.updateCells()
        SuitSetting.refreshInfo(data)
        SuitSetting.showEditInfo(data)
    end)

    return cell
end

function SuitSetting.updateCells()
    for i, cell in pairs(SuitSetting._cells) do 
        GUI:QuickCell_Exit(cell)
        GUI:QuickCell_Refresh(cell)
    end 
end 

function SuitSetting.showEditInfo(data)
    if not data or next(data) == nil then 
        return 
    end 

    GUI:TextInput_setString(SuitSetting._ui["Input_edit"], data.notes)
end 

function SuitSetting.refreshInfo(data)
    if not data or next(data) == nil then 
        return 
    end 

    local children = GUI:getChildren(SuitSetting._ui["Node_tips"])
    if children then 
        GUI:removeAllChildren(SuitSetting._ui["Node_tips"])
        SL:CloseItemTips()
    end 

    local suitSplit = string.split(data.notes, ":")
    local sSuitName = suitSplit[1]
    local sSuitAtt = suitSplit[2]
    local sliceStr = string.split(sSuitName, "|")
    --套装部位
    local equipName = ""
    for i = 3, #sliceStr do
        local equipSlice = string.split(sliceStr[i], "/")
        if #equipSlice >= 2 then
            if equipSlice[2] ~= nil and string.len(equipSlice[2]) > 0 then
                equipName = equipSlice[2]
                break
            end
        else
            equipName = equipSlice[1]
            break
        end
    end 

    local ItemConfigProxy = global.Facade:retrieveProxy(global.ProxyTable.ItemConfigProxy)
    local index = ItemConfigProxy:GetItemIndexByName(equipName)
    local equipData = ItemConfigProxy:GetItemDataByIndex(index)
    if equipData then
        local pos = {x = 0, y = 0}
        SL:OpenItemTips({itemData = equipData, pos = pos, node = SuitSetting._ui["Node_tips"]})
    end 
end 

function SuitSetting.initConfigData()
    local GameConfigMgrProxy = global.Facade:retrieveProxy(global.ProxyTable.GameConfigMgrProxy)
	local config = GameConfigMgrProxy:getConfigByKey("cfg_suit") or {}
    local configPath = "scripts/game_config/cfg_suit.lua"
    local devPath = global.FileUtilCtl:getDefaultResourceRootPath() .. "dev" .. "/" .. configPath
    local isFile = global.FileUtilCtl:isFileExist(devPath)
    if isFile then 
        SuitSetting._config = requireGameConfig("cfg_suit")
    else 
        SuitSetting._config = config
    end 

    local data = {}
    for i, cfg in pairs(SuitSetting._config) do 
        if not data[cfg.Idx] then 
            data[cfg.Idx] = {}
        end 
        data[cfg.Idx].Idx = cfg.Idx 
        data[cfg.Idx].package = cfg.package
        data[cfg.Idx].notes = cfg.notes or ""
    end 
    SuitSetting._data = {}
    SuitSetting._data = data
end 

function SuitSetting.getConfigData()
    local data = {}
    for i, v in pairs(SuitSetting._data) do 
        table.insert(data, v)
    end 

    table.sort(data, function(a, b) return a.Idx < b.Idx end)
    return data
end 

return SuitSetting