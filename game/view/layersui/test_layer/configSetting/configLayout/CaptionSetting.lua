CaptionSetting = {}

CaptionSetting._config = nil
CaptionSetting._data = nil
CaptionSetting._selId = 1 
CaptionSetting._cells = {}
CaptionSetting._showType = 1

function CaptionSetting.main(parent)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "caption_setting_ui/caption_setting")
    CaptionSetting._ui = GUI:ui_delegate(parent)

    if GET_GAME_STATE() ~= global.MMO.GAME_STATE_WORLD then
        SL:ShowSystemTips("请进入游戏世界.......")
        return 
    end 

    CaptionSetting.initConfigData()
    CaptionSetting.initBtns()
    CaptionSetting.showMenu()

    CaptionSetting.refreshInfo(CaptionSetting._data[1])
    CaptionSetting.refreshAttShow(CaptionSetting._data[1])
end

function CaptionSetting.close()
    print("CaptionSetting.close")
end

function CaptionSetting.initBtns()
    GUI:addOnClickEvent(CaptionSetting._ui["Button_save"],function() 
        CaptionSetting._config = {}
        for i, data in pairs(CaptionSetting._data) do 
            local id = data.id
            CaptionSetting._config[id] = data
        end 

        SL:SaveTableToConfig(CaptionSetting._config, "cfg_custpro_caption")
        global.FileUtilCtl:purgeCachedEntries()
        SL:ShowSystemTips("保存成功")
    end)

    GUI:addOnClickEvent(CaptionSetting._ui["Btn_yes"],function() 
        local inputStr = GUI:TextInput_getString(CaptionSetting._ui["Input_id"])
        local str = string.gsub(inputStr, "%s+", "")
        if string.len(str) == 0 then
            SL:ShowSystemTips("id不能为空")
            GUI:TextInput_setString(CaptionSetting._ui["Input_id"], "")
            return false
        end

        if tonumber(str) == 0 then 
            SL:ShowSystemTips("id不能为0")
            GUI:TextInput_setString(CaptionSetting._ui["Input_id"], "")
            return false
        end 

        local checkRepeat = CaptionSetting.checkRepeatId(tonumber(str))
        if checkRepeat then 
            SL:ShowSystemTips("id重复")
            return 
        end 

        local key = table.maxn(CaptionSetting._data)
        local maxId = tonumber(str)
        CaptionSetting._data[maxId] = {
            id = maxId,
            icon = "1=res/public/0.png#res/public/0.png",
            value = "<攻击：%s/FCOLOR=255>",  
        }

        CaptionSetting._selId = maxId

        local function createCell(parent)
            return CaptionSetting.createMenuCell(parent, CaptionSetting._data[maxId])
        end 
        local cell = GUI:QuickCell_Create(CaptionSetting._ui["ListView_menu"], "cell"..maxId, 0, 0, 300, 60, createCell)
        CaptionSetting._cells[maxId] = cell

        CaptionSetting.updateCells()
        CaptionSetting.refreshInfo(CaptionSetting._data[CaptionSetting._selId])
        CaptionSetting.refreshAttShow(CaptionSetting._data[CaptionSetting._selId])
        GUI:ListView_jumpToBottom(CaptionSetting._ui["ListView_menu"])
        SL:ShowSystemTips("添加成功")
        GUI:setVisible(CaptionSetting._ui["Panel_tips"], false)
    end)

    GUI:addOnClickEvent(CaptionSetting._ui["Btn_no"],function() 
        GUI:setVisible(CaptionSetting._ui["Panel_tips"], false)
    end)

    GUI:TextInput_setInputMode(CaptionSetting._ui["Input_id"], 2)

    GUI:addOnClickEvent(CaptionSetting._ui["Button_add"],function() 
        GUI:setVisible(CaptionSetting._ui["Panel_tips"], true)
        GUI:TextInput_setString(CaptionSetting._ui["Input_id"], "")
    end)

    GUI:addOnClickEvent(CaptionSetting._ui["Button_delete"],function() 
        if CaptionSetting._selId >= 1 and CaptionSetting._selId <= 30 then 
            SL:ShowSystemTips("官方id 禁止删除.......")
            return 
        end 

        local id = CaptionSetting._selId
        local cell = CaptionSetting._cells[id]
        GUI:ListView_removeChild(CaptionSetting._ui["ListView_menu"], cell)
        CaptionSetting._data[id] = nil
        CaptionSetting._cells[id] = nil

        CaptionSetting._selId = 1
        CaptionSetting.updateCells()
        CaptionSetting.refreshInfo(CaptionSetting._data[CaptionSetting._selId])
        CaptionSetting.refreshAttShow(CaptionSetting._data[CaptionSetting._selId])
        GUI:ListView_jumpToTop(CaptionSetting._ui["ListView_menu"])
        SL:ShowSystemTips("删除成功")
    end)

    GUI:TextInput_addOnEvent(CaptionSetting._ui["Input_edit"], function (_, eventType)
        if eventType == 1 then
            local id = CaptionSetting._selId
            local inputStr = GUI:TextInput_getString(CaptionSetting._ui["Input_edit"])
            local str = string.gsub(inputStr, "%s+", "")
            if string.len(str) == 0 then
                SL:ShowSystemTips("不能为空")
                GUI:TextInput_setString(CaptionSetting._ui["Input_edit"], CaptionSetting._data[id].value)
                return false
            end

            CaptionSetting._data[id].value = str
            CaptionSetting.refreshAttShow(CaptionSetting._data[id])
        end
    end)

    GUI:addOnClickEvent(CaptionSetting._ui["Button_pathMobile"], function()
        local resPath = "res/"
        local function callFunc(res)
            if not res or res == "" then
                return
            end

            local id = CaptionSetting._selId
            if CaptionSetting._data[id].icon == "" then 
                CaptionSetting._data[id].icon = "1=res/public/0.png#res/public/0.png"
            end 

            local tSplit = string.split(CaptionSetting._data[id].icon, "=")
            local tIcon = string.split(tSplit[2], "#")
            local strIcon = tSplit[1] .. "=" .. res .. "#" .. tIcon[2]
            CaptionSetting._data[id].icon = strIcon
            CaptionSetting.refreshInfo(CaptionSetting._data[id])
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_GUIResSelector_Open, { res = resPath, callfunc = callFunc })
    end) 

    GUI:addOnClickEvent(CaptionSetting._ui["Button_pathPC"], function()
        local resPath = "res/"
        local function callFunc(res)
            if not res or res == "" then
                return
            end

            local id = CaptionSetting._selId
            if CaptionSetting._data[id].icon == "" then 
                CaptionSetting._data[id].icon = "1=res/public/0.png#res/public/0.png"
            end 
            local tSplit = string.split(CaptionSetting._data[id].icon, "=")
            local tIcon = string.split(tSplit[2], "#")
            local strIcon = tSplit[1] .. "=" .. tIcon[1] .. "#" .. res
            CaptionSetting._data[id].icon = strIcon
            CaptionSetting.refreshInfo(CaptionSetting._data[id])
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_GUIResSelector_Open, { res = resPath, callfunc = callFunc })
    end) 

    GUI:TextInput_setInputMode(CaptionSetting._ui["Input_itype"], 2)
    GUI:TextInput_addOnEvent(CaptionSetting._ui["Input_itype"], function (_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(CaptionSetting._ui["Input_itype"])
            local str = string.gsub(inputStr, "%s+", "")
            if string.len(str) == 0 then
                SL:ShowSystemTips("不能为空")
                GUI:TextInput_setString(CaptionSetting._ui["Input_itype"], 1)
                return false
            end

            if tonumber(str) == 0 or tonumber(str) == 1 or tonumber(str) == 2 then 
                local selId = CaptionSetting._selId
                CaptionSetting._data[selId].icon = ""
                CaptionSetting.refreshTypeShow(tonumber(str))
                CaptionSetting.refreshInfo(CaptionSetting._data[selId])
            else 
                SL:ShowSystemTips("请输入正确类型")
                GUI:TextInput_setString(CaptionSetting._ui["Input_itype"], 1)
            end 
        end
    end)

    GUI:TextInput_setInputMode(CaptionSetting._ui["Input_effectMobile"], 2)
    GUI:TextInput_addOnEvent(CaptionSetting._ui["Input_effectMobile"], function (_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(CaptionSetting._ui["Input_effectMobile"])
            local str = string.gsub(inputStr, "%s+", "")
            if string.len(str) == 0 then
                SL:ShowSystemTips("不能为空")
                GUI:TextInput_setString(CaptionSetting._ui["Input_effectMobile"], 4510)
            end
    
            local selId = CaptionSetting._selId
            local effectMB = str or 4510
            local effectPC = GUI:TextInput_getString(CaptionSetting._ui["Input_effetPc"]) or 0
            CaptionSetting._data[selId].icon = "2="..effectMB.."#"..effectPC
            CaptionSetting.refreshInfo(CaptionSetting._data[selId])
        end
    end)

    GUI:TextInput_setInputMode(CaptionSetting._ui["Input_effetPc"], 2)
    GUI:TextInput_addOnEvent(CaptionSetting._ui["Input_effetPc"], function (_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(CaptionSetting._ui["Input_effetPc"])
            local str = string.gsub(inputStr, "%s+", "")
            if string.len(str) == 0 then
                SL:ShowSystemTips("不能为空")
                GUI:TextInput_setString(CaptionSetting._ui["Input_effetPc"], 4510)
            end
    
            local selId = CaptionSetting._selId
            local effectMB = GUI:TextInput_getString(CaptionSetting._ui["Input_effectMobile"]) or 0
            local effectPC = str or 4510
            CaptionSetting._data[selId].icon = "2="..effectMB.."#"..effectPC
            CaptionSetting.refreshInfo(CaptionSetting._data[selId])
        end
    end)

end  

function CaptionSetting.showMenu()
    local data = CaptionSetting.getConfigData()
    if not data and next(data) == nil then 
        return nil
    end

    GUI:ListView_removeAllItems(CaptionSetting._ui["ListView_menu"])
    for i, v in pairs(data) do 
        local function createCell(parent)
            return CaptionSetting.createMenuCell(parent, v)
        end 

        local cell_width = 300
        local cell_height = 60
        local cell = GUI:QuickCell_Create(CaptionSetting._ui["ListView_menu"], "cell"..v.id, 0, 0, cell_width, cell_height, createCell)
        CaptionSetting._cells[v.id] = cell
    end
    GUI:ListView_doLayout(CaptionSetting._ui["ListView_menu"])
end 

function CaptionSetting.createMenuCell(parent, data)
    loadConfigSettingExport(parent, "caption_setting_ui/menu_cell")
    local cell = GUI:getChildByName(parent, "page_cell")

    local ui_id = GUI:getChildByName(cell, "text_id") 
    GUI:Text_setString(ui_id, data.id)

    local ui_name = GUI:getChildByName(cell, "text_name") 
    GUI:Text_setString(ui_name, data.desc or "无")

    GUI:Layout_setBackGroundColor(cell, data.id == CaptionSetting._selId and "#ffbf6b" or "#000000")

    GUI:addOnClickEvent(cell, function()
        CaptionSetting._selId = data.id 
        CaptionSetting.updateCells()

        CaptionSetting.refreshInfo(data)
        CaptionSetting.refreshAttShow(data)
    end)

    return cell
end

function CaptionSetting.updateCells()
    for i, cell in pairs(CaptionSetting._cells) do 
        GUI:QuickCell_Exit(cell)
        GUI:QuickCell_Refresh(cell)
    end 
end 

function CaptionSetting.refreshTypeShow(itype)
    local showType = itype

    GUI:setVisible(CaptionSetting._ui["Text_mobileIcon"], showType == 1)
    GUI:setVisible(CaptionSetting._ui["Text_pcIcon"], showType == 1)
    GUI:setVisible(CaptionSetting._ui["Text_effectMobile"], showType == 2)
    GUI:setVisible(CaptionSetting._ui["Text_effectPc"], showType == 2)
end 

function CaptionSetting.refreshInfo(data)
    GUI:removeAllChildren(CaptionSetting._ui["img_mobile"])
    GUI:removeAllChildren(CaptionSetting._ui["img_pc"])
    GUI:Image_loadTexture(CaptionSetting._ui["img_mobile"], "res/public/0.png")
    GUI:Image_loadTexture(CaptionSetting._ui["img_pc"], "res/public/0.png")


    GUI:Text_setString(CaptionSetting._ui["Text_pathMobile"], "")
    GUI:Text_setString(CaptionSetting._ui["Text_pathPC"], "")

    GUI:Text_setString(CaptionSetting._ui["Input_effectMobile"], "")
    GUI:Text_setString(CaptionSetting._ui["Input_effetPc"], "")

    if not data or next(data) == nil then 
        return 
    end 

    if not data.icon or string.len(data.icon) == 0 then 
        return 
    end 

    local tSplit = string.split(data.icon, "=")
    local showType = tonumber(tSplit[1])
    local tIcon = string.split(tSplit[2], "#")

    local mobileIcon = string.gsub(tIcon[1], "%s+", "") 
    local pcIcon = string.gsub(tIcon[2], "%s+", "") 

    if mobileIcon and string.len(mobileIcon) > 0 then 
        if showType == 1 then 
            GUI:Image_loadTexture(CaptionSetting._ui["img_mobile"], mobileIcon)
            GUI:Text_setString(CaptionSetting._ui["Text_pathMobile"], mobileIcon)
        end 

        if showType == 2 then 
            GUI:Effect_Create(CaptionSetting._ui["img_mobile"],"effect_mobile"..data.id, 0, 0, 0, mobileIcon)
            GUI:TextInput_setString(CaptionSetting._ui["Input_effectMobile"], mobileIcon)
        end
    end 

    if pcIcon and string.len(pcIcon) > 0 then 
        if showType == 1 then 
            GUI:Image_loadTexture(CaptionSetting._ui["img_pc"], pcIcon)
            GUI:Text_setString(CaptionSetting._ui["Text_pathPC"], pcIcon)
        end 

        if showType == 2 then 
            GUI:Effect_Create(CaptionSetting._ui["img_pc"],"effect_pc"..data.id, 0, 0, 0, pcIcon)
            GUI:TextInput_setString(CaptionSetting._ui["Input_effetPc"], pcIcon)
        end
    end 

    CaptionSetting._showType = showType

    GUI:TextInput_setString(CaptionSetting._ui["Input_itype"], CaptionSetting._showType)
    CaptionSetting.refreshTypeShow(CaptionSetting._showType)
end 

function CaptionSetting.refreshAttShow(data)
    if not data or next(data) == nil then 
        return 
    end 

    GUI:removeAllChildren(CaptionSetting._ui["Node_att"])
    local customDesc = data.value --CaptionSetting._data[22].value
    local rich = GUI:RichTextFCOLOR_Create(CaptionSetting._ui["Node_att"], "rich", 0, 0, customDesc, 400, 15)
    GUI:setAnchorPoint(rich, 0, 1)
    GUI:TextInput_setString(CaptionSetting._ui["Input_edit"], data.value)
end 

function CaptionSetting.initConfigData()
    CaptionSetting._config = {}
    local GameConfigMgrProxy = global.Facade:retrieveProxy(global.ProxyTable.GameConfigMgrProxy)
	local config = GameConfigMgrProxy:getConfigByKey("cfg_custpro_caption") or {}
    local configPath = "scripts/game_config/cfg_custpro_caption.lua"
    local devPath = global.FileUtilCtl:getDefaultResourceRootPath() .. "dev" .. "/" .. configPath
    local isFile = global.FileUtilCtl:isFileExist(devPath)
    if isFile then 
        CaptionSetting._config = SL:RequireFile(configPath)
    else 
        CaptionSetting._config = config
    end 

    local data = {}
    for i, cfg in pairs(CaptionSetting._config) do 
        data[cfg.id] = cfg
    end 

    CaptionSetting._data = {}
    CaptionSetting._data = data
end 

function CaptionSetting.getConfigData()
    local data = {}
    for i, v in pairs(CaptionSetting._data) do 
        table.insert(data, v)
    end 

    table.sort(data, function(a, b) return a.id < b.id end)
    return data
end 

function CaptionSetting.getDataPcIcon()
    local path = ""
    local id = CaptionSetting._selId
    local data = CaptionSetting._data[id]
    if not data or next(data) == nil then 
        return nil
    end

    local tSplit = string.split(data.icon, "=")
    local tIcon = string.split(tSplit[2], "#")
    local pcIcon = string.gsub(tIcon[2], "%s+", "") 

    if pcIcon and string.len(pcIcon) > 0 then 
        path = pcIcon
    end 

    return path
end 

function CaptionSetting.checkRepeatId(id)
    for i, v in pairs(CaptionSetting._data) do 
        if v.id == id then 
            return true
        end 
    end 
    return false
end 


return CaptionSetting