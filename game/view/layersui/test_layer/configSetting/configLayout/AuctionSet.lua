AuctionSet = {}

AuctionSet._config = nil
AuctionSet._data = nil
AuctionSet._configName = nil
AuctionSet._editId = nil
AuctionSet._editName = ""
AuctionSet._editCell = nil

AuctionSet._selFirst = 1 -- 全部
AuctionSet._selSecond = 1 -- 全部
AuctionSet._firstCells = {}
AuctionSet._secondCells = {}
AuctionSet._allItemCells = {}
AuctionSet._checkItemCells = {}
AuctionSet._allItemMode = {}
AuctionSet._allHexCells = {}

function AuctionSet.main(parent)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "auction_ui/auction_setting")
    AuctionSet._ui = GUI:ui_delegate(parent)

    AuctionSet.initBtns()
    AuctionSet.initAuctionData()
    AuctionSet.showFirstMenu()
    AuctionSet.showSecondMenu()
    AuctionSet.createAllItems()
    AuctionSet.refreshCheckItems()
end

function AuctionSet.close()
    print("AuctionSet.close")
end

function AuctionSet.initBtns()
    GUI:addOnClickEvent(AuctionSet._ui["Button_save"],function() 
        AuctionSet.saveAuctionData()
    end)

    GUI:addOnClickEvent(AuctionSet._ui["Button_add1"],function() 
        AuctionSet.addMenuParent()
    end)

    GUI:addOnClickEvent(AuctionSet._ui["Button_del1"],function() 
        AuctionSet.deleteMenuParent()
    end)

    GUI:addOnClickEvent(AuctionSet._ui["Button_add2"],function() 
        AuctionSet.addMenuChild()
    end)

    GUI:addOnClickEvent(AuctionSet._ui["Button_del2"],function() 
        AuctionSet.deleteMenuChild()
    end)

    GUI:addOnClickEvent(AuctionSet._ui["Button_add3"],function() 
        AuctionSet.showAddCheckPanel()
    end)

    GUI:addOnClickEvent(AuctionSet._ui["Button_del3"],function() 
        AuctionSet.showDeleteCheckPanel()
    end)

    GUI:addOnClickEvent(AuctionSet._ui["Button_allin"],function() 
        if AuctionSet._selFirst == 1 and AuctionSet._selSecond == 1 then 
            SL:ShowSystemTips("禁止操作")
            return 
        end 

        local first = AuctionSet._selFirst
        local second = AuctionSet._selSecond
        local id = AuctionSet._data[first][second].id

        AuctionSet._config[id].std = AuctionSet._config[1].std
        AuctionSet._config[id].stdmode = AuctionSet._config[1].std

        AuctionSet._data[first][second].std = AuctionSet._config[1].std
        AuctionSet._data[first][second].stdmode = AuctionSet._config[1].std

        AuctionSet.refreshUI()
    end)

    GUI:addOnClickEvent(AuctionSet._ui["Button_allno"],function() 
        if AuctionSet._selFirst == 1 and AuctionSet._selSecond == 1 then 
            SL:ShowSystemTips("禁止操作")
            return 
        end 

        local first = AuctionSet._selFirst
        local second = AuctionSet._selSecond
        local id = AuctionSet._data[first][second].id

        AuctionSet._config[id].std = ""
        AuctionSet._config[id].stdmode = ""

        AuctionSet._data[first][second].std = ""
        AuctionSet._data[first][second].stdmode = ""

        AuctionSet.refreshUI()
    end)

    GUI:addOnClickEvent(AuctionSet._ui["Btn_yes"],function() 
        local cell = AuctionSet._editCell
        local name = GUI:TextInput_getString(AuctionSet._ui["Input_name"]) 
        local ui_text = GUI:getChildByName(cell, "PageText") 
        if name == "" then 
            SL:ShowSystemTips("请输入名字")
            return
        end 
        GUI:Text_setString(ui_text, name)

        local first = AuctionSet._editFirst
        local second = AuctionSet._editSecond
        local id = AuctionSet._data[first][second].id

        if AuctionSet._config[id].secondlevel == 1 then 
            AuctionSet._data[first][second].firstlevelname = name
            AuctionSet._config[id].firstlevelname = name
        else 
            AuctionSet._data[first][second].secondlevelname = name
            AuctionSet._config[id].secondlevelname = name
        end 

        GUI:setVisible(AuctionSet._ui["Panel_tips"],false)
    end)

    GUI:addOnClickEvent(AuctionSet._ui["Btn_no"],function() 
        GUI:setVisible(AuctionSet._ui["Panel_tips"],false)
    end)
end 

function AuctionSet.addMenuParent()
    local config = AuctionSet._config
    local data = AuctionSet._data
    local function getMaxKey(tb)
        local maxKey = nil
        for i, v in pairs(tb) do 
            if not maxKey then 
                maxKey = i
            end 
            if maxKey < i then 
                maxKey = i
            end 
        end 
        return maxKey + 1
    end 

    local maxIndex = getMaxKey(data)
    local maxId = getMaxKey(config)
    data[maxIndex] = {}
    data[maxIndex][1] = {
        id=maxId,
		firstlevel=maxIndex,
		firstlevelname="parent"..maxIndex,
		secondlevel=1,
		secondlevelname="全部",
		stdmode="",
        std="",
    }

    config[maxId] = {
        id=maxId,
		firstlevel=maxIndex,
		firstlevelname="parent"..maxIndex,
		secondlevel=1,
		secondlevelname="全部",
		stdmode="",  
        std="",    
    }

    AuctionSet._selFirst = maxIndex
    AuctionSet._selSecond = 1

    AuctionSet.setAuctionData(data)
    AuctionSet.setAuctionConfig(config)
    AuctionSet.showFirstMenu()
    AuctionSet.showSecondMenu()
    AuctionSet.refreshUI()
end 

function AuctionSet.deleteMenuParent()
    if AuctionSet._selFirst == 1 then 
        SL:ShowSystemTips("禁止删除")
        return 
    end 
    local config = AuctionSet._config
    local data = AuctionSet._data
    local id = data[AuctionSet._selFirst][AuctionSet._selSecond].id

    for i, v in pairs(data[AuctionSet._selFirst]) do 
        if config[v.id] then 
            config[v.id] = nil
        end 
    end 
    data[AuctionSet._selFirst] = nil 

    AuctionSet._selFirst = 1
    AuctionSet._selSecond = 1

    AuctionSet.setAuctionData(data)
    AuctionSet.setAuctionConfig(config)
    AuctionSet.showFirstMenu()
    AuctionSet.showSecondMenu()
    AuctionSet.refreshUI()
end 

function AuctionSet.addMenuChild()
    local config = AuctionSet._config
    local data = AuctionSet._data
    local function getMaxKey(tb)
        local maxKey = nil
        for i, v in pairs(tb) do 
            if not maxKey then 
                maxKey = i
            end 
            if maxKey < i then 
                maxKey = i
            end 
        end 
        return maxKey + 1
    end 

    local maxIndex = getMaxKey(data[AuctionSet._selFirst])
    local maxId = getMaxKey(config)
    data[AuctionSet._selFirst][maxIndex] = {
        id=maxId,
		firstlevel=AuctionSet._selFirst,
		firstlevelname=data[AuctionSet._selFirst][1].firstlevelname,
		secondlevel=maxIndex,
		secondlevelname="child"..maxIndex,
		stdmode="",
        std="",
    }

    config[maxId] = {
        id=maxId,
		firstlevel=AuctionSet._selFirst,
		firstlevelname=data[AuctionSet._selFirst][1].firstlevelname,
		secondlevel=maxIndex,
		secondlevelname="child"..maxIndex,
		stdmode="",   
        std="",   
    }

    AuctionSet._selFirst = AuctionSet._selFirst
    AuctionSet._selSecond = maxIndex

    AuctionSet.setAuctionData(data)
    AuctionSet.setAuctionConfig(config)
    AuctionSet.showFirstMenu()
    AuctionSet.showSecondMenu()
    AuctionSet.refreshUI()
end 

function AuctionSet.deleteMenuChild()
    if AuctionSet._selSecond == 1 then 
        SL:ShowSystemTips("禁止删除")
        return 
    end 
    local config = AuctionSet._config
    local data = AuctionSet._data
    local id = data[AuctionSet._selFirst][AuctionSet._selSecond].id

    config[id] = nil
    data[AuctionSet._selFirst][AuctionSet._selSecond] = nil 

    AuctionSet._selSecond = 1

    AuctionSet.setAuctionData(data)
    AuctionSet.setAuctionConfig(config)
    AuctionSet.showFirstMenu()
    AuctionSet.showSecondMenu()
    AuctionSet.refreshUI()
end 

function AuctionSet.showAddCheckPanel()
    GUI:setVisible(AuctionSet._ui["Panel_add"], true)
    GUI:setVisible(AuctionSet._ui["Panel_del"], false)
    
    local function checkStdMode(ui_input, str)
        local strInput = string.gsub(str, "%s+", "")
        if string.len(strInput) == 0 then
            SL:ShowSystemTips("不能为空")
            GUI:TextInput_setString(ui_input, "")
            return false
        end  

        if AuctionSet._configName[tonumber(strInput)] then
            SL:ShowSystemTips("类型重复")
            GUI:TextInput_setString(ui_input, "")
            return false
        end 

        return true
    end 

    local function checkStdName(ui_input, str)
        local strInput = string.gsub(str, "%s+", "")
        if string.len(strInput) == 0 then
            SL:ShowSystemTips("不能为空")
            GUI:TextInput_setString(ui_input, "")
            return false
        end  

        for i, v in pairs(AuctionSet._configName) do 
            if v.name == strInput then 
                return false
            end 
        end 

        return true
    end 

    GUI:addOnClickEvent(AuctionSet._ui["Button_addOk"], function()
        local mode = GUI:TextInput_getString(AuctionSet._ui["Input_stdmode"])
        local name = GUI:TextInput_getString(AuctionSet._ui["Input_stdname"])
        local checkMode = checkStdMode(AuctionSet._ui["Input_stdmode"], mode)
        local checkName = checkStdName(AuctionSet._ui["Input_stdname"], name)
        if checkMode and checkName then 
            AuctionSet._configName[tonumber(mode)] = {}
            AuctionSet._configName[tonumber(mode)].name = name
            AuctionSet._data[1][1].stdmode = AuctionSet._data[1][1].stdmode.."#"..mode
            AuctionSet._data[1][1].std = AuctionSet._data[1][1].std..mode.."#"

            AuctionSet.refreshAllUI()
            GUI:setVisible(AuctionSet._ui["Panel_add"], false)
        end  
    end)

    GUI:addOnClickEvent(AuctionSet._ui["Button_addNo"], function()
        GUI:setVisible(AuctionSet._ui["Panel_add"], false)
    end)
end 

function AuctionSet.showDeleteCheckPanel()
    GUI:setVisible(AuctionSet._ui["Panel_add"], false)
    GUI:setVisible(AuctionSet._ui["Panel_del"], true)

    local function checkStdMode(ui_input, str)
        local strInput = string.gsub(str, "%s+", "")
        if string.len(strInput) == 0 then
            SL:ShowSystemTips("不能为空")
            GUI:TextInput_setString(ui_input, "")
            return false
        end  

        if not AuctionSet._configName[tonumber(strInput)] then
            SL:ShowSystemTips("类型不存在")
            GUI:TextInput_setString(ui_input, "")
            return false
        end 

        return true
    end 

    GUI:addOnClickEvent(AuctionSet._ui["Button_delOk"], function()
        local mode = GUI:TextInput_getString(AuctionSet._ui["Input_delmode"])

        local checkMode = checkStdMode(AuctionSet._ui["Input_delmode"], mode)
        if checkMode then 
            AuctionSet._configName[tonumber(mode)] = nil
            local stdmode = "#"..AuctionSet._data[1][1].stdmode.."#"
            local temp = string.gsub(stdmode, "#"..mode.."#", "#")
            local new_stdmode = string.sub(temp, 2, -2)
            AuctionSet._data[1][1].stdmode = new_stdmode

            local std = AuctionSet._data[1][1].std
            local new_std = string.gsub(std, "#"..mode.."#", "#")
            AuctionSet._data[1][1].std = new_std

            AuctionSet.refreshAllUI()
            GUI:setVisible(AuctionSet._ui["Panel_del"], false)
        end  
    end)

    GUI:addOnClickEvent(AuctionSet._ui["Button_delNo"], function()
        GUI:setVisible(AuctionSet._ui["Panel_del"], false)
    end)
end 

function AuctionSet.showFirstMenu()
    local data = AuctionSet.getAuctionData()
    if not data and next(data) == nil then 
        return nil
    end

    local function refreshState()
        for i, v in pairs(data) do 
            GUI:Layout_setBackGroundColor(AuctionSet._firstCells[i], i == AuctionSet._selFirst and "#ffbf6b" or "#000000")
        end 
    end 

    GUI:ListView_removeAllItems(AuctionSet._ui["ListView_menu1"])
    for i, v in pairs(data) do 
        local cell = AuctionSet.createFirstMenuCell(v[1])
        GUI:ListView_pushBackCustomItem(AuctionSet._ui["ListView_menu1"],cell)
        AuctionSet._firstCells[i] = cell

        local ui_text = GUI:getChildByName(cell, "PageText") 
        GUI:Text_setString(ui_text, v[1].firstlevelname)

        local clickCallBack = function()
            AuctionSet._selFirst = i
            AuctionSet._selSecond = 1
            refreshState()
            AuctionSet.showSecondMenu()
            AuctionSet.refreshUI()
        end
        local doubleClickCallBack = function()
            AuctionSet._editFirst = v[1].firstlevel
            AuctionSet._editSecond = v[1].secondlevel
            AuctionSet._editName = GUI:Text_getString(ui_text)
            AuctionSet._editCell = cell
            GUI:setVisible(AuctionSet._ui["Panel_tips"],true)
            GUI:TextInput_setString(AuctionSet._ui["Input_name"],"")
        end

        AuctionSet.addDoubleEventListener(cell, { clickCallBack = clickCallBack, doubleClickCallBack = doubleClickCallBack })
    end

    refreshState()
end 

function AuctionSet.addDoubleEventListener(node, param)
    local clickCallBack = param.clickCallBack
    local doubleClickCallBack = param.doubleClickCallBack
    GUI:addOnTouchEvent(node,function(sender, type)
        if type == 0 then
            if node._clicking then
                if doubleClickCallBack then
                    doubleClickCallBack()
                end
                GUI:stopAllActions(node)
                node._clicking = false
            else
                node._clicking = true
                SL:scheduleOnce(node, function()
                    node._clicking = false
                    if clickCallBack then
                        clickCallBack()
                    end
                end, SLDefine.CLICK_DOUBLE_TIME)
            end
        end
    end)

end

function AuctionSet.createFirstMenuCell(data)
    local parent = GUI:Widget_Create(AuctionSet._ui["Panel_main"], "widget"..data.id, 0, 0)
    loadConfigSettingExport(parent, "auction_ui/menu_cell")
    local cell = GUI:getChildByName(parent, "page_cell") 
    GUI:removeFromParent(parent)
    GUI:removeFromParent(cell)
    return cell
end

-- menu2
function AuctionSet.showSecondMenu()
    local data = AuctionSet.getAuctionData()
    if not data and next(data) == nil then 
        return nil
    end

    GUI:ListView_removeAllItems(AuctionSet._ui["ListView_menu2"])
    local menuData = data[AuctionSet._selFirst]

    local function refreshState()
        for i, v in pairs(menuData) do 
            GUI:Layout_setBackGroundColor(AuctionSet._secondCells[i], i == AuctionSet._selSecond and "#ffbf6b" or "#000000")
        end 
    end 

    for i, v in pairs(menuData) do 
        local cell = AuctionSet.createSecondMenuCell(v)
        GUI:ListView_pushBackCustomItem(AuctionSet._ui["ListView_menu2"],cell)
        AuctionSet._secondCells[i] = cell

        local ui_text = GUI:getChildByName(cell, "PageText") 
        GUI:Text_setString(ui_text,v.secondlevelname)

        local clickCallBack = function()
            AuctionSet._selSecond = i
            refreshState()
            AuctionSet.refreshUI()
        end
        local doubleClickCallBack = function()
            AuctionSet._editFirst = AuctionSet._selFirst
            AuctionSet._editSecond = i
            AuctionSet._editName = GUI:Text_getString(ui_text)
            AuctionSet._editCell = cell
            GUI:setVisible(AuctionSet._ui["Panel_tips"],true)
            GUI:TextInput_setString(AuctionSet._ui["Input_name"],"")
        end

        AuctionSet.addDoubleEventListener(cell, { clickCallBack = clickCallBack, doubleClickCallBack = doubleClickCallBack })
    end 
    
    refreshState()
end 

function AuctionSet.createSecondMenuCell(data)
    local parent = GUI:Widget_Create(AuctionSet._ui["Panel_main"], "widget"..data.id, 0, 0)
    loadConfigSettingExport(parent, "auction_ui/menu_cell")
    local cell = GUI:getChildByName(parent, "page_cell") 
    GUI:removeFromParent(parent)
    GUI:removeFromParent(cell)
    return cell
end

-- items
function AuctionSet.createAllItems()
    GUI:removeAllChildren(AuctionSet._ui["SV_normal"])
    local data = AuctionSet.getAuctionData()
    if not data or next(data) == nil then 
        return nil
    end

    local stdmode = string.sub(data[1][1].std, 2, -2)
    local tMode = string.split(stdmode, "#")
    if not tMode or next(tMode) == nil then 
        return nil
    end
    table.sort(tMode, function(a, b) return tonumber(a) < tonumber(b) end)
    AuctionSet._allItemMode = tMode

    local bgSize = GUI:ScrollView_getInnerContainerSize(AuctionSet._ui["SV_normal"])
    local menuSize = {width = 125, height = 36}
    local innerH =  math.ceil( table.nums(AuctionSet._allItemMode) / (bgSize.width / menuSize.width) ) * menuSize.height
    GUI:ScrollView_setInnerContainerSize(AuctionSet._ui["SV_normal"], bgSize.width, innerH)

    local posX = 0
    local posY = 0
    local row = 0
    local line = math.floor(bgSize.width / menuSize.width)
    
    for i, v in pairs(AuctionSet._allItemMode) do 
        if math.fmod(i-1,line) == 0 and i > line then --取余
            row = row + 1
            posX = 0 
            posY = innerH - (menuSize.height) * row - menuSize.height
        else
            posX = menuSize.width * (i-1 - row * line) 
            posY = innerH - (menuSize.height) * row - menuSize.height
        end  
        
        local function createCell(parent)
            local layout = AuctionSet.createAllCells(parent, v)
            return layout
        end

        local quickCell = GUI:QuickCell_Create(AuctionSet._ui["SV_normal"], "SV_normal"..v, posX, posY, menuSize.width, menuSize.height, createCell)
        AuctionSet._allItemCells[v] = quickCell
    end 
end 

function AuctionSet.createAllCells(parent, stdmode)
    loadConfigSettingExport(parent, "auction_ui/checkBox_cell")
    local cell = GUI:getChildByName(parent, "checkBox_cell") 

    local ui_name = GUI:getChildByName(cell, "Text_name")
    local strName = AuctionSet._configName[tonumber(stdmode)] and AuctionSet._configName[tonumber(stdmode)].name or "未命名"
    local name = stdmode..strName
    GUI:Text_setString(ui_name, name)

    local ui_box = GUI:getChildByName(cell, "CheckBox")

    GUI:addOnClickEvent(cell, function() 
        local bCheck = GUI:CheckBox_isSelected(ui_box)
        GUI:CheckBox_setSelected(ui_box, not bCheck)
        AuctionSet.refreshCheckItems(stdmode, not bCheck)
    end)

    local first = AuctionSet._selFirst
    local second = AuctionSet._selSecond
    local bFind = string.find(AuctionSet._data[first][second].std, "#"..stdmode.."#", 1, true)
    GUI:CheckBox_setSelected(ui_box, bFind ~= nil)
    return cell
end

-- 刷新
function AuctionSet.refreshCheckItems(mode, bCheck)
    GUI:removeAllChildren(AuctionSet._ui["SV_select"])

    local first = AuctionSet._selFirst
    local second = AuctionSet._selSecond
    local id = AuctionSet._data[first][second].id
    local allId = AuctionSet._data[first][1].id

    if mode then 
        local newStd = ""
        local newAll = ""
        if bCheck then
            if AuctionSet._data[first][second].std == "" then 
                newStd = "#"..mode.."#"
            else 
                newStd = AuctionSet._config[id].std..mode.."#"
            end 

            if AuctionSet._data[first][1].std == "" then 
                newAll = "#"..mode.."#"
            else 
                local bFind = string.find(AuctionSet._config[allId].std, "#"..mode.."#", 1, true)
                if not bFind then 
                    newAll = AuctionSet._config[allId].std..mode.."#"
                else 
                    newAll = AuctionSet._config[allId].std
                end 
            end 
        else 
            newStd = string.gsub(AuctionSet._config[id].std, "#"..mode.."#", "#")
            newAll = string.gsub(AuctionSet._config[allId].std, "#"..mode.."#", "#")

            if newStd == "#" then 
                newStd = ""           
            end 

            if newAll == "#" then 
                newAll = ""
            end 
        end 

        AuctionSet._config[id].std = newStd
        AuctionSet._data[first][second].std = newStd
        AuctionSet._config[allId].std = newAll
        AuctionSet._data[first][1].std = newAll

        AuctionSet._config[id].stdmode = newStd
        AuctionSet._data[first][second].stdmode = newStd
        AuctionSet._config[allId].stdmode = newAll
        AuctionSet._data[first][1].stdmode = newAll
    end 

    if AuctionSet._data[first][second].std == "" then 
        return 
    end 

    local selStr = string.sub(AuctionSet._data[first][second].std, 2, -2)
    local selMode = string.split(selStr, "#")
    if not selMode or next(selMode) == nil then 
        return 
    end
    table.sort(selMode, function(a, b) return tonumber(a) < tonumber(b) end)

    local bgSize = GUI:ScrollView_getInnerContainerSize(AuctionSet._ui["SV_select"])
    local menuSize = {width = 125, height = 36}
    local innerH =  math.ceil( table.nums(selMode) / (bgSize.width / menuSize.width) ) * menuSize.height
    if innerH < bgSize.height then 
        innerH = bgSize.height
    end 
    GUI:ScrollView_setInnerContainerSize(AuctionSet._ui["SV_select"], bgSize.width, innerH)

    local posX = 0
    local posY = 0
    local row = 0
    local line = math.floor(bgSize.width / menuSize.width)
    for i, v in pairs(selMode) do 
        if math.fmod(i-1,line) == 0 and i > line then --取余
            row = row + 1
            posX = 0 
            posY = innerH - (menuSize.height) * row - menuSize.height
        else
            posX = menuSize.width * (i-1 - row * line) 
            posY = innerH - (menuSize.height) * row - menuSize.height
        end  

        local function createCell(parent)
            local layout = AuctionSet.createCheckCells(parent, v)
            return layout
        end

        local quickCell = GUI:QuickCell_Create(AuctionSet._ui["SV_select"], "SV_select"..v, posX, posY, menuSize.width, menuSize.height, createCell)
        AuctionSet._checkItemCells[v] = quickCell
    end 
end 

function AuctionSet.createCheckCells(parent, stdmode)
    loadConfigSettingExport(parent, "auction_ui/checkBox_cell2")
    local cell = GUI:getChildByName(parent, "checkBox_cell") 
    local ui_name = GUI:getChildByName(cell, "Text_name")
    local strName = AuctionSet._configName[tonumber(stdmode)] and AuctionSet._configName[tonumber(stdmode)].name or "未命名"
    local name = stdmode..strName
    GUI:Text_setString(ui_name, name)
    return cell
end

function AuctionSet.refreshUI()
    AuctionSet.refreshCheckItems()
end 

function AuctionSet.refreshAllUI()
    AuctionSet.createAllItems()
    AuctionSet.refreshCheckItems()
end 

function AuctionSet.getFirstSecondByStdMode(stdmode)
    local modeData = {}
    modeData.first = nil
    modeData.second = nil
    for i, v in pairs(AuctionSet._config) do 
        if (v.firstlevel > 1 and v.secondlevel > 1) or (v.secondnum and v.secondnum == 0) then 
            local data = string.split(v.stdmode, "#")
            for j, w in pairs(data) do 
                if stdmode == w then 
                    modeData.first = v.firstlevel
                    modeData.second = v.secondlevel
                    return modeData
                end 
            end
        end 
    end 
    return nil
end 

function AuctionSet.saveAuctionData()
    for i, cfg in pairs(AuctionSet._config) do 
        if cfg.id ~= 1 then 
            local s, e, v= string.find(cfg.stdmode, "(#)", 1, false)
            if s == 1 and e == 1 and v == "#" then 
                local newMode = string.sub(cfg.stdmode, 2, -2)
                cfg.stdmode = newMode
            end
        end 
    end 

    SL:SaveTableToConfig(AuctionSet._config, "cfg_auction_type")
    global.FileUtilCtl:purgeCachedEntries()

    SL:SaveTableToConfig(AuctionSet._configName, "cfg_auction_name")
    global.FileUtilCtl:purgeCachedEntries()
    SL:ShowSystemTips("保存成功")
end 

function AuctionSet.initAuctionData()
    AuctionSet._data = {}
    AuctionSet._config = {}
    local config = requireGameConfig("cfg_auction_type")
    for i, cfg in pairs(config) do 
        if not cfg.std then 
            cfg.std = "#"..cfg.stdmode.."#"
        end 


        if not AuctionSet._data[cfg.firstlevel] then 
            AuctionSet._data[cfg.firstlevel] = {}
            table.insert(AuctionSet._data[cfg.firstlevel], cfg)
        else
            table.insert(AuctionSet._data[cfg.firstlevel], cfg)
        end 
    end 

    AuctionSet._config = config

    for i, v in pairs(AuctionSet._data) do 
        table.sort(v, function(a, b) return a.id < b.id end)
    end 

    AuctionSet._configName = {}
    AuctionSet._configName = requireGameConfig("cfg_auction_name") 
end 

function AuctionSet.setAuctionData(data)
    local function sortData(a, b)
        if a and a.id and b and b.id then 
            return a.id < b.id
        end 
    end 
    for i, v in pairs(data) do 
        table.sort(v, sortData)
    end 
    AuctionSet._data = data
end 

function AuctionSet.getAuctionData()
    return AuctionSet._data or nil
end 

function AuctionSet.setAuctionConfig(config)
    AuctionSet._config = config
end 

function AuctionSet.getAuctionConfig()
    return AuctionSet._config or nil
end 

return AuctionSet