SoundSetting = {}

SoundSetting._config = nil
SoundSetting._data = nil
SoundSetting._offcialCells = {}
SoundSetting._defineCells = {}
SoundSetting._selId = nil 

-- tips
SoundSetting._typeIndex = nil
SoundSetting._typeId = nil
SoundSetting._soundType = {
    [1]= {name = "技能施法声音", formula = "10000#10#0", type = 1},
    [2]= {name = "技能飞行声音", formula = "10000#10#1", type = 1},
    [3]= {name = "技能命中声音", formula = "10000#10#2", type = 1},
    [4]= {name = "怪物出生声音", formula = "200#10#0", type = 2},
    [5]= {name = "怪物走路声音", formula = "200#10#1", type = 2},
    [6]= {name = "怪物攻击声音", formula = "200#10#2", type = 2},
    [7]= {name = "怪物死亡声音", formula = "200#10#6", type = 2},
}

function SoundSetting.main(parent)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "sound_setting_ui/sound_setting")
    SoundSetting._ui = GUI:ui_delegate(parent)



    SoundSetting.initSoundData()
    SoundSetting.initBtns()
    SoundSetting.showOfficialList()
    SoundSetting.showCustomList()
end

function SoundSetting.close()
    print("SoundSetting.close")
end

function SoundSetting.initBtns()
    GUI:addOnClickEvent(SoundSetting._ui["Button_save"],function() 
        SoundSetting._config = {}
        for i, data in pairs(SoundSetting._data) do 
            local ID = data.id
            if not SoundSetting._config[ID] then 
                SoundSetting._config[ID] = data
            end 
        end 

        SL:SaveTableToConfig(SoundSetting._config, "cfg_sound")
        global.FileUtilCtl:purgeCachedEntries()
        SL:ShowSystemTips("保存成功")
    end)

    -- 添加
    GUI:addOnClickEvent(SoundSetting._ui["Button_add"], function() 
        SoundSetting.showEditTips()
    end)

    -- 删除
    GUI:addOnClickEvent(SoundSetting._ui["Button_delete"], function() 
        local data = SoundSetting.getSoundCustomData()
        if not data or next(data) == nil then 
            return 
        end 

        local selId = SoundSetting._selId
        if not selId then 
            SL:ShowSystemTips("请选择.......")
            return 
        end 

        GUI:ListView_removeChild(SoundSetting._ui["ListView_info2"], SoundSetting._defineCells[selId])
        SoundSetting._data[selId] = nil
        SoundSetting._defineCells[selId] = nil
        SL:ShowSystemTips("删除成功")
    end)

    GUI:TextInput_setInputMode(SoundSetting._ui["Input_search1"], 2)
    GUI:addOnClickEvent(SoundSetting._ui["Button_search1"], function() 
        SoundSetting.searchSound(1)
    end)

    GUI:TextInput_setInputMode(SoundSetting._ui["Input_search2"], 2)
    GUI:addOnClickEvent(SoundSetting._ui["Button_search2"], function() 
        SoundSetting.searchSound(2)
    end)
end  

function SoundSetting.showOfficialList(index)
    local data = SoundSetting.getSoundOffcialData()
    if not data and next(data) == nil then 
        return nil
    end

    SoundSetting._offcialCells = {}
    GUI:ListView_removeAllItems(SoundSetting._ui["ListView_info1"])
    for i, v in ipairs(data) do 
        local function createCell(parent)
            return SoundSetting.createSoundCell(parent, v, 1)
        end 

        local cell_width = 460
        local cell_height = 50
        local cell = GUI:QuickCell_Create(SoundSetting._ui["ListView_info1"], "cell"..v.id, 0, 0, cell_width, cell_height, createCell)
        SoundSetting._offcialCells[v.id] = cell
        SoundSetting._offcialCells[v.id].index = i

    end

    if index then 
        GUI:ListView_jumpToBottom(SoundSetting._ui["ListView_info1"])
    end 
end 

function SoundSetting.showCustomList(index)
    local data = SoundSetting.getSoundCustomData()
    if not data and next(data) == nil then 
        return nil
    end

    SoundSetting._defineCells = {}
    GUI:ListView_removeAllItems(SoundSetting._ui["ListView_info2"])
    for i, v in ipairs(data) do 
        local function createCell(parent)
            return SoundSetting.createSoundCell(parent, v, 2)
        end 

        local cell_width = 460
        local cell_height = 50
        local cell = GUI:QuickCell_Create(SoundSetting._ui["ListView_info2"], "cell"..v.id, 0, 0, cell_width, cell_height, createCell)
        SoundSetting._defineCells[v.id] = cell
        SoundSetting._defineCells[v.id].index = i
    end

    if index then 
        GUI:ListView_jumpToBottom(SoundSetting._ui["ListView_info2"])
    end 
end 


function SoundSetting.createSoundCell(parent, data, itype)
    loadConfigSettingExport(parent, "sound_setting_ui/menu_cell")
    local cell = GUI:getChildByName(parent, "page_cell")

    local ui_id = GUI:getChildByName(cell, "text_id") 
    GUI:Text_setString(ui_id, data.id)

    local ui_file = GUI:getChildByName(cell, "text_file") 
    GUI:Text_setString(ui_file, data.file or "无")

    local ui_desc = GUI:getChildByName(cell, "text_desc") 
    GUI:Text_setString(ui_desc, data.explain or "无")

    if itype == 2 then  
        -- select
        GUI:Layout_setBackGroundColor(cell, data.id == SoundSetting._selId and "#ffbf6b" or "#000000")

        -- btn
        GUI:addOnClickEvent(cell, function ()
            SoundSetting._selId = data.id
            SoundSetting.updateCells()
        end)
    end 

    return cell
end

function SoundSetting.updateCells()
    for i, cell in pairs(SoundSetting._defineCells) do 
        GUI:QuickCell_Exit(cell)
        GUI:QuickCell_Refresh(cell)
    end 
end 

function SoundSetting.searchSound(itype)
    local index = 1
    local ui_text = GUI:TextInput_getString(SoundSetting._ui["Input_search"..itype])
    if itype == 1 then 
        if not SoundSetting._offcialCells[tonumber(ui_text)] then 
            SL:ShowSystemTips("没有数据.......")
            return 
        end 
        index = SoundSetting._offcialCells[tonumber(ui_text)].index
    else 
        if not SoundSetting._defineCells[tonumber(ui_text)] then 
            SL:ShowSystemTips("没有数据.......")
            return 
        end 
        index = SoundSetting._defineCells[tonumber(ui_text)].index
    end 

    GUI:ListView_jumpToItem(SoundSetting._ui["ListView_info"..itype], index) 
end 

function SoundSetting.showEditTips()
    SoundSetting.cleanTipsInfo()

    local bVisible = GUI:getVisible(SoundSetting._ui["Panel_tips"])
    GUI:setVisible(SoundSetting._ui["Panel_tips"], not bVisible)

    local ui_inputId = SoundSetting._ui["Input_id"]
    local ui_inputName = SoundSetting._ui["Input_name"]
    local ui_inputDesc = SoundSetting._ui["Input_desc"]

    GUI:TextInput_setInputMode(ui_inputId, 2)
    GUI:TextInput_setInputMode(ui_inputName, 6)
    GUI:TextInput_setInputMode(ui_inputDesc, 6)

    GUI:addOnClickEvent(SoundSetting._ui["Btn_yes"], function ()
        local id = SoundSetting._typeId
        if not SoundSetting._typeIndex then 
            SL:ShowSystemTips("请选择类型")
            return 
        end 

        local checkRepeat = SoundSetting.checkRepeatId(tonumber(id))
        if checkRepeat then 
            SL:ShowSystemTips("id重复")
            return 
        end 

        local name = GUI:Text_getString(ui_inputName)
        if name == "" then 
            SL:ShowSystemTips("名字不能为空")
            return 
        end

        local desc = GUI:Text_getString(ui_inputDesc)

        -- 添加data
        local data = {}
        data.id = tonumber(id) 
        data.file = name 
        data.explain = desc
        data.flag = 1

        local maxIndex = table.maxn(SoundSetting._data) + 1
        SoundSetting._data[maxIndex] = data
        SoundSetting._selId = data.id

        SoundSetting.showCustomList(maxIndex)
        GUI:setVisible(SoundSetting._ui["Panel_tips"], false)
        SL:ShowSystemTips("添加成功")
    end)

    GUI:addOnClickEvent(SoundSetting._ui["Btn_no"], function ()
        GUI:setVisible(SoundSetting._ui["Panel_tips"], false)
    end)

    GUI:addOnClickEvent(SoundSetting._ui["Button_arrow"], function ()
        local bShow = GUI:getVisible(SoundSetting._ui["ListView_item"])
        GUI:setVisible(SoundSetting._ui["ListView_item"], not bShow)

        SoundSetting.showSoundTypeList()
    end) 

    GUI:TextInput_addOnEvent(ui_inputId, function (_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(ui_inputId)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("id不能为空")
                return 
            end

            SoundSetting.showSelectName()
        end
    end)
end 

function SoundSetting.cleanTipsInfo()
    SoundSetting._typeIndex = nil
    GUI:Text_setString(SoundSetting._ui["Text_showName"], "")
    GUI:Text_setString(SoundSetting._ui["Text_show"], "下拉选择")
    GUI:Text_setString(SoundSetting._ui["Input_id"], "")
    GUI:Text_setString(SoundSetting._ui["Input_name"], "")
    GUI:Text_setString(SoundSetting._ui["Input_desc"], "")
end 

function SoundSetting.showSoundTypeList()
    GUI:ListView_removeAllItems(SoundSetting._ui["ListView_item"])
    for i , v in ipairs(SoundSetting._soundType) do 
        local item = GUI:Clone(SoundSetting._ui["Panel_item"])
        GUI:setVisible(item, true)
        GUI:ListView_pushBackCustomItem(SoundSetting._ui["ListView_item"], item)

        local ui_type = GUI:getChildByName(item, "Text_typeName")
        GUI:Text_setString(ui_type, v.name)

        GUI:addOnClickEvent(item, function()
            SoundSetting.cleanTipsInfo()
            SoundSetting._typeIndex = i
            GUI:setVisible(SoundSetting._ui["ListView_item"], false)
            GUI:Text_setString(SoundSetting._ui["Text_show"], v.name)
            if SoundSetting._soundType[i].type == 1 then 
                GUI:TextInput_setPlaceHolder(SoundSetting._ui["Input_id"], "请输入技能MagicID.......")
            else 
                GUI:TextInput_setPlaceHolder(SoundSetting._ui["Input_id"], "请输入怪物Appr.......")
            end 
        end)
    end 
end

function SoundSetting.showSelectName()
    local iType = SoundSetting._typeIndex 
    if not iType then 
        return 
    end 

    local id = tonumber( GUI:TextInput_getString(SoundSetting._ui["Input_id"]) )
    local itype = SoundSetting._soundType[iType].type
    local split = string.split(SoundSetting._soundType[iType].formula, "#")
    SoundSetting._typeId = tonumber(split[1]) + (id * tonumber(split[2])) + tonumber(split[3])

    local name = ""
    if itype == 1 then 
        name = SL:GetMetaValue("SKILL_NAME", id)
    else 
        name = "怪物"
    end 

    GUI:Text_setString(SoundSetting._ui["Text_showName"], string.format("目标:%s, 生成ID:%s", name, SoundSetting._typeId))
end 

function SoundSetting.checkRepeatId(id)
    for i, v in pairs(SoundSetting._data) do 
        if v.id == id then 
            return true
        end 
    end 
    return false
end 

function SoundSetting.initSoundData()
    SoundSetting._config = {}
    SoundSetting._config = SL:RequireFile("game_config/cfg_sound.lua")

    local temp = {}
    for i, cfg in pairs(SoundSetting._config) do 
        table.insert(temp, cfg)
    end 
    table.sort(temp, function(a, b) return a.id < b.id end)

    SoundSetting._data = {}
    for i, data in ipairs(temp) do 
        if not SoundSetting._data[data.id] then 
            SoundSetting._data[data.id] = data
        end 
    end 

    return SoundSetting._data
end 

function SoundSetting.getSoundOffcialData()
    local data = {}
    for i, v in pairs(SoundSetting._data) do 
        if not v.flag then 
            table.insert(data, v)
        end 
    end 
    table.sort(data, function(a, b) return a.id < b.id end)

    return data
end 

function SoundSetting.getSoundCustomData()
    local data = {}
    for i, v in pairs(SoundSetting._data) do 
        if v.flag and v.flag == 1 then 
            table.insert(data, v)
        end 
    end  
    table.sort(data, function(a, b) return a.id < b.id end)
    
    return data
end 

return SoundSetting