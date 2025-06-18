-- 保护
Protect = {}

local SID = SLDefine.SETTINGID

function Protect.main(parent, data)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "setup/protect")

    Protect._ui = GUI:ui_delegate(parent)
    
    Protect._enable = (data.default or 0) == 1
    Protect._default1 = data.default1
    Protect._default2 = data.default2
    Protect._time = data.time
    Protect._tIndexs = string.split(data.indexs or "", "#")
    for k, v in ipairs(Protect._tIndexs) do
        if v == "" then
            table.remove(Protect._tIndexs, k)
        end
    end
    Protect._items = {}

    -- 开启关闭
    local clickCell = Protect._ui["click_cell"]
    local CheckBox_able = GUI:getChildByName(clickCell, "CheckBox_able")
    local function setClickCellStatus(enable)
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_off"), not enable)
        GUI:setVisible(GUI:getChildByName(CheckBox_able, "Panel_on"), enable)
    end

    setClickCellStatus(Protect._enable)

    GUI:addOnClickEvent(clickCell, function()
        Protect._enable = not Protect._enable
        setClickCellStatus(Protect._enable)
    end)

    -- 输入保护血量
    local input_hp = Protect._ui["input_hp"]
    Protect.input_hp = input_hp
    GUI:TextInput_setInputMode(input_hp, 2)
    GUI:TextInput_addOnEvent(input_hp, function(sender, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(sender)
            if string.len(inputStr) == 0 then
                Protect._default1 = nil
                GUI:TextInput_setString(sender, Protect._default1 or "")
                return
            end

            inputStr = math.max(0, tonumber(inputStr))
            Protect._default1 = tonumber(inputStr)
            GUI:TextInput_setString(sender, Protect._default1)
        end
    end)
    GUI:TextInput_setString(input_hp, Protect._default1 or "")

    -- 输入使用间隔
    local input_time = Protect._ui["input_time"]
    Protect.input_time = input_time
    GUI:TextInput_setInputMode(input_time, 2)
    GUI:TextInput_addOnEvent(input_time, function(sender, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(sender)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("间隔不能为空")
                GUI:TextInput_setString(sender, Protect._time)
                return
            end

            inputStr = math.max(0, tonumber(inputStr))
            Protect._time = tonumber(inputStr)
            GUI:TextInput_setString(sender, Protect._time)
        end
    end)
    GUI:TextInput_setString(input_time, Protect._time or "")

    -- 输入道具
    Protect._propId = ""
    local input = Protect._ui["input"]
    Protect.input = input
    GUI:TextInput_setInputMode(input, 2)
    GUI:TextInput_addOnEvent(input, function(sender, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(sender)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("ID不能为空")
                GUI:TextInput_setString(sender, Protect._propId)
                return
            end

            Protect._propId = inputStr
        end
    end)

    -- 添加
    GUI:addOnClickEvent(Protect._ui["btn_add"], function()
        local inputStr = GUI:TextInput_getString(Protect.input)
        if string.len(inputStr) == 0 then
            SL:ShowSystemTips("ID不能为空")
            return
        end

        for k, v in ipairs(Protect._tIndexs) do
            if v == inputStr then
                SL:ShowSystemTips("已存在")
                return
            end
        end

        table.insert(Protect._tIndexs, inputStr)
        Protect._index = #Protect._tIndexs
        Protect.initItems()
        SL:ShowSystemTips("添加成功")
    end)

    -- 删除
    GUI:addOnClickEvent(Protect._ui["btn_del"], function()
        if not Protect._index or not Protect._tIndexs[Protect._index] or Protect._tIndexs[Protect._index] == "" then
            return
        end

        table.remove(Protect._tIndexs, Protect._index)

        Protect._index = 1
        Protect.initItems()
        SL:ShowSystemTips("删除成功")
    end)

    -- 修改
    GUI:addOnClickEvent(Protect._ui["btn_change"], function()
        if not Protect._index or not Protect._tIndexs[Protect._index] or Protect._tIndexs[Protect._index] == "" then
            return
        end

        local inputStr = GUI:TextInput_getString(Protect.input)
        if string.len(inputStr) == 0 then
            SL:ShowSystemTips("ID不能为空")
            return
        end
        
        Protect._tIndexs[Protect._index] = inputStr

        Protect.initItems()
        SL:ShowSystemTips("修改成功")
    end)

    Protect._index = 1
    Protect.initItems()

    -- 重排界面
    -- 红名保护，只有使用间隔，没有血量保护
    if data.id == SID.SETTING_IDX_PK_PROTECT then
        GUI:setVisible(Protect._ui["bg_input_hp"], false)
        GUI:setPositionY(Protect._ui["bg_input_time"], GUI:getPositionY(Protect._ui["bg_input_hp"]))
    
    -- 道士生命低于多少使用回血技能和英雄生命值低于多少自动收回 ，只有血量保护，没有使用间隔和道具id
    elseif data.id == SID.SETTING_IDX_HP_LOW_USE_SKILL or data.id == SID.SETTING_IDX_HERO_AUTO_LOGINOUT then
        GUI:setVisible(Protect._ui["bg_input_time"], false)
        GUI:setVisible(Protect._ui["Node_list"], false)

    -- N范围内有多少怪 不走去拾取，只有血量保护，没有使用间隔和道具id，改掉前后缀
    elseif data.id == SID.SETTING_IDX_N_RANGE_NO_PICK then
        GUI:setVisible(Protect._ui["bg_input_time"], false)
        GUI:setVisible(Protect._ui["Node_list"], false) 
        GUI:Text_setString(Protect._ui["hp_prefix"], "身边")
        GUI:Text_setString(Protect._ui["hp_surfix"], "格有怪时不捡物")
        GUI:setPositionX(Protect._ui["bg_input_hp"], 45) 

    -- 多少秒没怪物使用，有血量保护，没有使用间隔，有道具id，改掉前后缀
    elseif data.id == SID.SETTING_IDX_NO_MONSTAER_USE then
        GUI:setVisible(Protect._ui["bg_input_time"], false)
        GUI:Text_setString(Protect._ui["hp_prefix"], "寻路")
        GUI:Text_setString(Protect._ui["hp_surfix"], "秒没怪时使用道具")
        GUI:setPositionX(Protect._ui["bg_input_hp"], 45)    
        
    -- 周围N格内有敌人时主动攻击，只有血量保护，没有使用间隔和道具id，改掉前后缀
    elseif data.id == SID.SETTING_IDX_ENEMY_ATTACK then
        GUI:setVisible(Protect._ui["bg_input_time"], false)
        GUI:setVisible(Protect._ui["Node_list"], false) 
        GUI:Text_setString(Protect._ui["hp_prefix"], "身边")
        GUI:Text_setString(Protect._ui["hp_surfix"], "格有敌人时主动攻击")
        GUI:setPositionX(Protect._ui["bg_input_hp"], 45)

    -- 周围N格内有M敌人或红名时使用道具
    elseif data.id == SID.SETTING_IDX_BESIEGE_FLEE or data.id == SID.SETTING_IDX_RED_BESIEGE_FLEE then
        GUI:setVisible(Protect._ui["bg_input_hp"], false)
        GUI:setVisible(Protect._ui["bg_input_time"], false)
        GUI:setVisible(Protect._ui["bg_input_default1"], true)

        -- 输入周围格子数
        local input_default1 = Protect._ui["input_default1"]
        Protect.input_default1 = input_default1
        GUI:TextInput_setInputMode(input_default1, 2)
        GUI:TextInput_addOnEvent(input_default1, function(sender, eventType)
            if eventType == 1 then
                local inputStr = GUI:TextInput_getString(sender)
                if string.len(inputStr) == 0 then
                    Protect._default1 = nil
                    GUI:TextInput_setString(sender, Protect._default1 or "")
                    return
                end

                inputStr = math.max(0, tonumber(inputStr))
                Protect._default1 = tonumber(inputStr)
                GUI:TextInput_setString(sender, Protect._default1)
            end
        end)
        GUI:TextInput_setString(input_default1, Protect._default1 or "")

        -- 输入人数
        local input_default2 = Protect._ui["input_default2"]
        Protect.input_default2 = input_default2
        GUI:TextInput_setInputMode(input_default2, 2)
        GUI:TextInput_addOnEvent(input_default2, function(sender, eventType)
            if eventType == 1 then
                local inputStr = GUI:TextInput_getString(sender)
                if string.len(inputStr) == 0 then
                    Protect._default2 = nil
                    GUI:TextInput_setString(sender, Protect._default2 or "")
                    return
                end

                inputStr = math.max(0, tonumber(inputStr))
                Protect._default2 = tonumber(inputStr)
                GUI:TextInput_setString(sender, Protect._default2)
            end
        end)
        GUI:TextInput_setString(input_default2, Protect._default2 or "")
    end
end

function Protect.initItems()
    local list_items = Protect._ui["list_items"]
    GUI:ListView_addMouseScrollPercent(list_items)
    GUI:ListView_removeAllItems(list_items)
    Protect._items = {}
    Protect._propId = ""
    GUI:TextInput_setString(Protect.input, Protect._propId)

    local function createCell(parent, k, v)
        local pageCell = GUI:Layout_Create(parent, "page_cell", 0, 0, 88, 20, false)
        GUI:Layout_setBackGroundColorType(pageCell, 1)
        GUI:Layout_setBackGroundColor(pageCell, Protect._index == k and "#ffbf6b" or "#000000")
        GUI:Layout_setBackGroundColorOpacity(pageCell, 140)
        GUI:setTouchEnabled(pageCell, true)

        local PageText = GUI:Text_Create(pageCell, "PageText", 44, 10, 14, "#ffffff", v)
        GUI:setAnchorPoint(PageText, 0.5, 0.5)
        GUI:Text_setTextHorizontalAlignment(PageText, 1)
        GUI:Text_enableOutline(PageText, "#000000", 1)

        GUI:addOnClickEvent(pageCell, function()
            Protect._propId = v
            Protect._index = k
            GUI:TextInput_setString(Protect.input, Protect._propId)
            Protect.refreshCells()
        end)

        if Protect._index == k then
            Protect._propId = v
            GUI:TextInput_setString(Protect.input, Protect._propId)
        end

        return pageCell
    end

    for k, v in ipairs(Protect._tIndexs) do
        if v ~= "" then
            local quickCell = GUI:QuickCell_Create(list_items, "quickCell"..k, 0, 0, 260, 20, function(parent)
                return createCell(parent, k, v)
            end)

            Protect._items[k] = quickCell
        end
    end

    GUI:ListView_jumpToItem(list_items, Protect._index - 1)
end

-- 刷新 ListView
function Protect.refreshCells()
    for index, cell in ipairs(Protect._items) do
        if cell then
            cell:Exit()
            cell:Refresh()
        end
    end
end

-- 外部调用，返回当前界面处理数据结果
function Protect.getValue()
    local ret = {}
    ret.default = Protect._enable and 1 or 0
    ret.default1 = tonumber(Protect._default1)
    ret.default2 = tonumber(Protect._default2)
    ret.time = tonumber(Protect._time)
    if next(Protect._tIndexs) then
        table.walk(Protect._tIndexs, function(v, k) return tonumber(v) end)
        local strIndexs = table.concat(Protect._tIndexs, "#")
        ret.indexs = strIndexs
    end

    return ret
end

return Protect