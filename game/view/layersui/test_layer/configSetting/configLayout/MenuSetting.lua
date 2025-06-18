MenuSetting = {}

MenuSetting._data = nil
MenuSetting._selGroup = 1
MenuSetting._selId = 1 
MenuSetting._cellsGroup = {}
MenuSetting._cells = {}

MenuSetting._config = {
    [101] = { 
		id=101,
		group_id=1,
		group_name="角色",
		desc="装备",
	},
	[102] = { 
		id=102,
		group_id=1,
		group_name="角色",
		desc="状态",
	},
	[103] = { 
		id=103,
		group_id=1,
		group_name="角色",
		desc="属性",
	},
	[104] = { 
		id=104,
		group_id=1,
		group_name="角色",
		desc="技能",
	},
	[106] = { 
		id=106,
		group_id=1,
		group_name="角色",
		desc="称号",
	},
	[1011] = { 
		id=1011,
		group_id=1,
		group_name="角色",
		desc="时装",
	},
	[120] = { 
		id=120,
		group_id=1,
		group_name="角色",
		desc="天赋",
	},
	[802] = { 
		id=802,
		group_id=4,
		group_name="社交",
		desc="附近",
	},
	[801] = { 
		id=801,
		group_id=4,
		group_name="社交",
		desc="组队",
	},
	[402] = { 
		id=402,
		group_id=4,
		group_name="社交",
		desc="好友",
	},
	[401] = { 
		id=401,
		group_id=4,
		group_name="社交",
		desc="邮件",
	},
	[1201] = { 
		id=1201,
		group_id=12,
		group_name="行会",
		desc="行会",
	},
	[1202] = { 
		id=1202,
		group_id=12,
		group_name="行会",
		desc="成员",
	},
	[1203] = { 
		id=1203,
		group_id=12,
		group_name="行会",
		desc="列表",
	},
	[300] = { 
		id=300,
		group_id=60,
		group_name="设置",
		desc="基础",
	},
	[301] = { 
		id=301,
		group_id=60,
		group_name="设置",
		desc="视距",
	},
	[302] = { 
		id=302,
		group_id=60,
		group_name="设置",
		desc="战斗",
	},
	[303] = { 
		id=303,
		group_id=60,
		group_name="设置",
		desc="保护",
	},
	[304] = { 
		id=304,
		group_id=60,
		group_name="设置",
		desc="挂机",
	},
	[305] = { 
		id=305,
		group_id=60,
		group_name="设置",
		desc="帮助",
	},
	[901] = { 
		id=901,
		group_id=9,
		group_name="商城",
		desc="热销",
	},
	[902] = { 
		id=902,
		group_id=9,
		group_name="商城",
		desc="补给",
	},
	[903] = { 
		id=903,
		group_id=9,
		group_name="商城",
		desc="强化",
	},
	[904] = { 
		id=904,
		group_id=9,
		group_name="商城",
		desc="技能",
	},
	[905] = { 
		id=905,
		group_id=9,
		group_name="商城",
		desc="充值",
	},
	[60] = { 
		id=60,
		group_id=111,
		group_name="交易行",
		desc="购买",
	},
	[61] = { 
		id=61,
		group_id=111,
		group_name="交易行",
		desc="寄售",
	},
	[62] = { 
		id=62,
		group_id=111,
		group_name="交易行",
		desc="货架",
	},
	[63] = { 
		id=63,
		group_id=111,
		group_name="交易行",
		desc="我的",
	},
	[701] = { 
		id=701,
		group_id=7,
		group_name="内功",
		desc="状态",
	},
	[702] = { 
		id=702,
		group_id=7,
		group_name="内功",
		desc="技能",
	},
	[703] = { 
		id=703,
		group_id=7,
		group_name="内功",
		desc="经络",
	},
	[704] = { 
		id=704,
		group_id=7,
		group_name="内功",
		desc="连击",
	},
}

function MenuSetting.main(parent)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "menu_setting_ui/menu_setting")
    MenuSetting._ui = GUI:ui_delegate(parent)

    MenuSetting.initConfigData()
    MenuSetting.showMenuParent()
    MenuSetting.initBtns()

end

function MenuSetting.close()
    print("MenuSetting.close")
end

function MenuSetting.initBtns()
    GUI:addOnClickEvent(MenuSetting._ui["Button_save"],function() 
        for i, data in pairs(MenuSetting._data) do 
            local id = data.id
            MenuSetting._config[id] = data
        end 

        SL:SaveTableToConfig(MenuSetting._config, "cfg_menulayer")
        global.FileUtilCtl:purgeCachedEntries()
        SL:ShowSystemTips("保存成功")
    end)

    GUI:TextInput_addOnEvent(MenuSetting._ui["Input_value"], function (_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(MenuSetting._ui["Input_value"])
            local str = string.gsub(inputStr, "%s+", "")
            if string.len(str) == 0 then
                SL:ShowSystemTips("不能为空")
                return false
            end

            local id = MenuSetting._selId
            MenuSetting._data[id].condition = str
        end
    end)

    GUI:addOnClickEvent(MenuSetting._ui["Button_add"], function()   
        local key = table.maxn(MenuSetting._data)
        local maxId = key + 1
        local groupName = MenuSetting._config[MenuSetting._selId] and MenuSetting._config[MenuSetting._selId].group_name or "无"
        MenuSetting._data[maxId] = {
            id = maxId,
            group_id = MenuSetting._selGroup,
            desc = "desc" .. maxId,
            -- condition = "",
        }

        MenuSetting._selId = maxId

        local function createCell(parent)
            return MenuSetting.createChildCell(parent, MenuSetting._data[maxId])
        end 
        local cell = GUI:QuickCell_Create(MenuSetting._ui["ListView_menu2"], "cell"..maxId, 0, 0, 400, 60, createCell)
        MenuSetting._cells[maxId] = cell

        MenuSetting.updateChildCells()
        GUI:ListView_jumpToBottom(MenuSetting._ui["ListView_menu2"])
        SL:ShowSystemTips("添加成功")
    end)

    GUI:addOnClickEvent(MenuSetting._ui["Button_delete"], function() 
        local id = MenuSetting._selId
        if not MenuSetting._data[id] then 
            SL:ShowSystemTips("禁止操作.......")
            return 
        end 

        local cell = MenuSetting._cells[id]
        GUI:ListView_removeChild(MenuSetting._ui["ListView_menu2"], cell)
        MenuSetting._data[id] = nil
        MenuSetting._cells[id] = nil
        SL:ShowSystemTips("删除成功")
    end)

    GUI:addOnClickEvent(MenuSetting._ui["Button_edit"], function() 
        local id = MenuSetting._selId
        if not MenuSetting._data[id] then 
            SL:ShowSystemTips("禁止操作.......")
            return 
        end 
        GUI:setVisible(MenuSetting._ui["Panel_tips"], true)
        GUI:TextInput_setString(MenuSetting._ui["Input_name"], "")
    end)

    GUI:addOnClickEvent(MenuSetting._ui["Btn_yes"],function() 
        local name = GUI:TextInput_getString(MenuSetting._ui["Input_name"]) 
        local nameStr = string.gsub(name, "%s+", "")
        if string.len(nameStr) == 0 then
            SL:ShowSystemTips("描述不能为空")
            return false
        end

        local id = MenuSetting._selId
        local cell = MenuSetting._cells[id]

        MenuSetting._data[id].desc = nameStr
        GUI:QuickCell_Exit(cell)
        GUI:QuickCell_Refresh(cell)
        GUI:setVisible(MenuSetting._ui["Panel_tips"], false)
    end)

    GUI:addOnClickEvent(MenuSetting._ui["Btn_no"],function() 
        GUI:setVisible(MenuSetting._ui["Panel_tips"], false)
    end)

    GUI:addOnClickEvent(MenuSetting._ui["Button_http"],function() 
        local function callback()
            print("打开网页")
        end 
        local url = "http://engine-doc.996m2.com/web/#/22/1352"
        cc.Application:getInstance():openURL(url)
    end)
end  

-- 父页签
function MenuSetting.showMenuParent()
    local data = MenuSetting.getConfigData()
    if not data and next(data) == nil then 
        return nil
    end

    MenuSetting._selGroup = 1
    MenuSetting._selId = data[1][1].id

    GUI:ListView_removeAllItems(MenuSetting._ui["ListView_menu1"])
    for i, v in pairs(data) do 
        local function createCell(parent)
            return MenuSetting.createParentCell(parent, v)
        end 

        local cell_width = 200
        local cell_height = 60
        local cell = GUI:QuickCell_Create(MenuSetting._ui["ListView_menu1"], "cell"..i, 0, 0, cell_width, cell_height, createCell)
        MenuSetting._cellsGroup[i] = cell
    end
    GUI:ListView_doLayout(MenuSetting._ui["ListView_menu1"])

    MenuSetting.showMenuChild(data[1])
end 

function MenuSetting.createParentCell(parent, data)
    loadConfigSettingExport(parent, "menu_setting_ui/menu_cell")
    local cell = GUI:getChildByName(parent, "page_cell")
    local ui_name = GUI:getChildByName(cell, "text_name") 
 
    GUI:Text_setString(ui_name, data[1].group_name)
    GUI:Layout_setBackGroundColor(cell, data[1].group_id == MenuSetting._selGroup and "#ffbf6b" or "#000000")
    GUI:addOnClickEvent(cell, function()
        MenuSetting._selGroup = data[1].group_id 
        MenuSetting._selId = data[1].id
        MenuSetting.updateParentCells()
        MenuSetting.showMenuChild(data)
    end)

    return cell
end

function MenuSetting.updateParentCells()
    for i, cell in pairs(MenuSetting._cellsGroup) do 
        GUI:QuickCell_Exit(cell)
        GUI:QuickCell_Refresh(cell)
    end 
end 

-- 子页签
function MenuSetting.showMenuChild(data)
    if not data or next(data) == nil then 
        return
    end

    MenuSetting._cells = {}

    GUI:ListView_removeAllItems(MenuSetting._ui["ListView_menu2"])
    for i, v in pairs(data) do 
        local function createCell(parent)
            return MenuSetting.createChildCell(parent, v)
        end 

        local cell_width = 200
        local cell_height = 60
        local cell = GUI:QuickCell_Create(MenuSetting._ui["ListView_menu2"], "cell"..v.id, 0, 0, cell_width, cell_height, createCell)
        MenuSetting._cells[v.id] = cell
    end
    GUI:ListView_doLayout(MenuSetting._ui["ListView_menu2"])

    MenuSetting.refreshInfo(data[1])
end 

function MenuSetting.createChildCell(parent, data)
    loadConfigSettingExport(parent, "menu_setting_ui/menu_cell")
    local cell = GUI:getChildByName(parent, "page_cell")
    local ui_name = GUI:getChildByName(cell, "text_name") 

    GUI:Text_setString(ui_name, data.desc)
    GUI:Layout_setBackGroundColor(cell, data.id == MenuSetting._selId and "#ffbf6b" or "#000000")
    GUI:addOnClickEvent(cell, function()
        MenuSetting._selId = data.id
        MenuSetting.updateChildCells()
        MenuSetting.refreshInfo(data)
    end)
    
    return cell
end

function MenuSetting.updateChildCells()
    for i, cell in pairs(MenuSetting._cells) do 
        GUI:QuickCell_Exit(cell)
        GUI:QuickCell_Refresh(cell)
    end 
end 

function MenuSetting.refreshInfo(data)
    if not data or next(data) == nil then 
        return
    end

    local input_value = MenuSetting._ui["Input_value"]
    GUI:TextInput_setString(input_value, "")

    if data.condition then 
        GUI:TextInput_setString(input_value, data.condition)
    end 
end 

function MenuSetting.initConfigData()
    local data = {}
    MenuSetting._config = SL:Require("game_config/cfg_menulayer")
    for i, cfg in pairs(MenuSetting._config) do 
        data[cfg.id] = cfg
    end 
    MenuSetting._data = {}
    MenuSetting._data = data
end 

function MenuSetting.getConfigData()
    local data = {}
    for i, v in pairs(MenuSetting._data) do 
        local group = v.group_id
        if not group then 
            local father = v.father_id
            if father then 
                group = MenuSetting._data[father].group_id
            end 
        end 
        if not data[group] then 
            data[group] = {}
        end 
        table.insert(data[group], v)
    end 
    for i, groupData in pairs(data) do
        table.sort(groupData, function(a, b)
            return a.id < b.id
        end)
    end
    return data
end 

return MenuSetting