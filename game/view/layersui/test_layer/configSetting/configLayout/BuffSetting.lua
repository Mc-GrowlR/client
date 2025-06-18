BuffSetting = {}

BuffSetting._config = nil
BuffSetting._data = nil
BuffSetting._cells = {}
BuffSetting._selId = 0
BuffSetting._editCell = nil
BuffSetting._fixConfig = {}

function BuffSetting.main(parent)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "buff_setting_ui/buff_setting")
    BuffSetting._ui = GUI:ui_delegate(parent)

    if GET_GAME_STATE() ~= global.MMO.GAME_STATE_WORLD then
        SL:ShowSystemTips("请进入游戏世界.......")
        return 
    end 

    BuffSetting.initConfigData()
    BuffSetting.initBtns()
    BuffSetting.showMenu()
    BuffSetting.initInputEvent()
    BuffSetting.initCheckBoxEvent()
end

function BuffSetting.close()
    print("BuffSetting.close")
end

function BuffSetting.initBtns()
    GUI:addOnClickEvent(BuffSetting._ui["Button_save"],function() 
        local fixData = {}
        for i, data in pairs(BuffSetting._data) do 
            local ID = data.ID
            BuffSetting._config[ID] = data
            if BuffSetting._fixConfig[ID] then 
                fixData[ID] = data
            end 
        end 

        SL:SaveTableToConfig(BuffSetting._config, "cfg_buff")
        SL:SaveTableToConfig(fixData, "cfg_buff", "dev/scripts/game_server_config/")
        global.FileUtilCtl:purgeCachedEntries()
        SL:ShowSystemTips("保存成功")
    end)

    GUI:addOnClickEvent(BuffSetting._ui["Button_icon"], function()
        local resPath = "res/buff_icon/1.png"
        local function callFunc(res)
            if not res or res == "" then
                return
            end

            local iconId = 1
            local temp = string.gsub(res, "res/buff_icon/", "")
            if temp then 
                iconId = string.gsub(temp, ".png", "")
                if tonumber(iconId) > 0 then 
                    BuffSetting.refreshBuffIcon(tonumber(iconId), res)

                    local id = BuffSetting._selId
                    BuffSetting._data[id].icon = tonumber(iconId) --存数据
                    BuffSetting._fixConfig[id] = id
                end 
            end 
        end
        global.Facade:sendNotification(global.NoticeTable.Layer_GUIResSelector_Open, { res = resPath, callfunc = callFunc })
    end)

    GUI:addOnClickEvent(BuffSetting._ui["Button_add"], function() 
        local key = table.maxn(BuffSetting._data)
        local maxID = key + 1
        BuffSetting._data[maxID] = {
            ID = maxID,
            name = "buff"..maxID,
            front_sfx = maxID,
            behind_sfx = 0,
            offsetx = 0,
            offsety = 0,
            speed = 1,
            icon= 0,
            -- tips = "",
            -- bufftitle = "",
            showtype = 1,          
        }

        BuffSetting._selId = maxID
        BuffSetting.showMenu()

        GUI:ListView_jumpToBottom(BuffSetting._ui["ListView_menu1"])
        SL:ShowSystemTips("添加成功")
    end)

    GUI:addOnClickEvent(BuffSetting._ui["Button_delete"], function() 
        local id = BuffSetting._selId
        local cell = BuffSetting._cells[id]
        if BuffSetting._config[id] then 
            SL:ShowSystemTips("官方BUFF 禁止删除")
            return 
        end 

        BuffSetting._data[id] = nil
        BuffSetting._cells[id] = nil

        BuffSetting._selId = 0
        BuffSetting.showMenu()
        GUI:ListView_jumpToTop(BuffSetting._ui["ListView_menu1"])
        SL:ShowSystemTips("删除成功")
    end)

    GUI:addOnClickEvent(BuffSetting._ui["Btn_yes"],function() 
        local cell = BuffSetting._cells[BuffSetting._selId]
        if not cell then 
            return 
        end 

        local name = GUI:TextInput_getString(BuffSetting._ui["Input_name"]) 
        local ui_name = GUI:getChildByName(cell, "text_name") 
        if name == "" then 
            SL:ShowSystemTips("请输入名字")
            return
        end 
        GUI:Text_setString(ui_name, name)

        BuffSetting._data[BuffSetting._selId].name = name
        GUI:setVisible(BuffSetting._ui["Panel_tips"],false)
        SL:ShowSystemTips("编辑成功")
    end)

    GUI:addOnClickEvent(BuffSetting._ui["Btn_no"],function() 
        GUI:setVisible(BuffSetting._ui["Panel_tips"],false)
    end)

    GUI:addOnClickEvent(BuffSetting._ui["Button_edit"],function() 
        local ID = BuffSetting._selId
        if BuffSetting._config[ID] then 
            SL:ShowSystemTips("官方BUFF 禁止操作")
            return 
        end 

        GUI:setVisible(BuffSetting._ui["Panel_tips"],true)
        GUI:TextInput_setString(BuffSetting._ui["Input_name"],"")
    end)

    GUI:TextInput_setInputMode(BuffSetting._ui["Input_search"], 2)
    GUI:addOnClickEvent(BuffSetting._ui["Button_search"], function() 
        BuffSetting.searchConfig()
    end)

    GUI:addOnClickEvent(BuffSetting._ui["Button_update"], function()
        LuaSendMsg(global.MsgType.MSG_CS_SERVER_CONFIG) 
        SL:ShowLoadingBar(1)
        local function updateConfig()
            SL:UpdateServerConfig("cfg_buff")
            SL:ShowSystemTips("更新服务配置表成功, 请重启客户端.......")
        end 
        SL:ScheduleOnce(updateConfig, 1.5) 
    end) 
end  

function BuffSetting.searchConfig()
    local index = 1
    local ui_text = GUI:TextInput_getString(BuffSetting._ui["Input_search"])
    if not BuffSetting._cells[tonumber(ui_text)] then 
        SL:ShowSystemTips("没有数据.......")
        return 
    end 
    index = BuffSetting._cells[tonumber(ui_text)].index

    BuffSetting._selId = tonumber(ui_text)
    BuffSetting.showMenu()
    GUI:ListView_jumpToItem(BuffSetting._ui["ListView_menu1"], index) 
end 


function BuffSetting.initInputEvent()
    local id = BuffSetting._selId
    local data = BuffSetting._data[id]
    local inputEvent = {
        {name = "Input_sfx1_audio", value = data.buff_audio, isAllChar=true},
        {name = "Input_sfx1", value = data.front_sfx},
        {name = "Input_sfx2", value = data.behind_sfx},
        {name = "Input_speed", value = data.speed},
        {name = "Input_x", value = data.offsetx, isAllChar=true},
        {name = "Input_y", value = data.offsety, isAllChar=true},
    }

    local function refreshEffect()
        local showData = BuffSetting._data[BuffSetting._selId]
        local param = {
            ID = showData.ID,
            front_sfx = showData.front_sfx,
            behind_sfx = showData.behind_sfx,
            speed = showData.speed,
            offsetx = showData.offsetx,
            offsety = showData.offsety,
            color = showData.color,
            scale = showData.buff_sacle
        }
        BuffSetting.refreshBuffEffect(param)
    end 

    local function refreshModel()
        local showData = BuffSetting._data[BuffSetting._selId]
        local param = {
            color = showData.color,
            scale = showData.buff_sacle,
            avatar = showData.avatar
        }
        BuffSetting.refreshPlayerModel(param)
    end 

    for i, input in pairs(inputEvent) do 
        local name = input.name
        GUI:TextInput_setInputMode(BuffSetting._ui[name], 6)

        GUI:TextInput_addOnEvent(BuffSetting._ui[name], function(_, eventType)
            if eventType == 1 then
                local inputStr = GUI:TextInput_getString(BuffSetting._ui[name])
                if string.len(inputStr) == 0 and name ~= "Input_sfx1_audio" then
                    SL:ShowSystemTips("不能为空")
                    GUI:TextInput_setString(BuffSetting._ui[name], input.value)
                    return
                end

                if not input.isAllChar and tonumber(inputStr) == nil then 
                    SL:ShowSystemTips("只能为数字")
                    GUI:TextInput_setString(BuffSetting._ui[name], input.value)
                    return
                end 
    
                local id = BuffSetting._selId --存数据
                if name == "Input_sfx1" then 
                    BuffSetting._data[id].front_sfx = tonumber(inputStr)
                elseif name == "Input_sfx2" then 
                    BuffSetting._data[id].behind_sfx = tonumber(inputStr)
                elseif name == "Input_speed" then
                    BuffSetting._data[id].speed = tonumber(inputStr)
                elseif name == "Input_x" then
                    BuffSetting._data[id].offsetx = inputStr--tonumber(inputStr)
                elseif name == "Input_y" then
                    BuffSetting._data[id].offsety = inputStr--tonumber(inputStr)
                elseif name == "Input_sfx1_audio" then
                    BuffSetting._data[id].buff_audio = tonumber(inputStr)
                end 

                BuffSetting._fixConfig[id] = id
                refreshEffect()
            end
        end)
    end 
    
    GUI:TextInput_addOnEvent(BuffSetting._ui["Input_title"], function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(BuffSetting._ui["Input_title"])

            local id = BuffSetting._selId --存数据
            BuffSetting._data[id].bufftitle = string.len(inputStr) ~= 0 and inputStr or nil
            BuffSetting._fixConfig[id] = id
        end
    end)

    GUI:TextInput_addOnEvent(BuffSetting._ui["Input_tips"], function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(BuffSetting._ui["Input_tips"])

            local id = BuffSetting._selId --存数据
            BuffSetting._data[id].tips = string.len(inputStr) ~= 0 and inputStr or nil
            BuffSetting._fixConfig[id] = id
        end
    end)

    GUI:TextInput_addOnEvent(BuffSetting._ui["Input_color"], function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(BuffSetting._ui["Input_color"])
            local id = BuffSetting._selId --存数据
            BuffSetting._data[id].color = tonumber(inputStr)
            BuffSetting._fixConfig[id] = id
            GUI:Layout_setBackGroundColor(BuffSetting._ui["panel_color"], SL:GetHexColorByStyleId(tonumber(inputStr) or 255))
            refreshModel()
        end
    end)

    GUI:TextInput_addOnEvent(BuffSetting._ui["Input_scale"], function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(BuffSetting._ui["Input_scale"])
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("不能为空")
                GUI:TextInput_setString(BuffSetting._ui["Input_scale"], "")
                return
            end

            local id = BuffSetting._selId --存数据
            BuffSetting._data[id].buff_sacle = tonumber(inputStr)
            BuffSetting._fixConfig[id] = id
            refreshModel()
        end
    end)

    GUI:TextInput_addOnEvent(BuffSetting._ui["Input_avatar"], function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(BuffSetting._ui["Input_avatar"])
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("不能为空")
                GUI:TextInput_setString(BuffSetting._ui["Input_avatar"], "")
                return
            end

            local id = BuffSetting._selId --存数据
            BuffSetting._data[id].avatar = inputStr
            BuffSetting._fixConfig[id] = id
            refreshModel()
        end
    end)

    GUI:TextInput_setInputMode(BuffSetting._ui["Input_sort"], 2)
    GUI:TextInput_addOnEvent(BuffSetting._ui["Input_sort"], function(_, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(BuffSetting._ui["Input_sort"])
            local id = BuffSetting._selId --存数据
            BuffSetting._data[id].sort = tonumber(inputStr)
            BuffSetting._fixConfig[id] = id
        end
    end)
end 

function BuffSetting.initCheckBoxEvent()
    GUI:addOnClickEvent(BuffSetting._ui["CheckBox_lookOther"], function(sender)
        local isSel = not GUI:CheckBox_isSelected(sender)
        local id = BuffSetting._selId --存数据
        BuffSetting._data[id].other_look = isSel and 1 or 0
        BuffSetting._fixConfig[id] = id
    end)
end

function BuffSetting.showMenu(key)
    local data = BuffSetting.getBuffData()
    if not data and next(data) == nil then 
        return nil
    end

    GUI:ListView_removeAllItems(BuffSetting._ui["ListView_menu1"])
    for i, v in pairs(data) do 
        local cell = BuffSetting.createMenuCell(v.ID)
        GUI:ListView_pushBackCustomItem(BuffSetting._ui["ListView_menu1"], cell)
        BuffSetting._cells[v.ID] = cell
        BuffSetting._cells[v.ID].index = i
        local ui_id = GUI:getChildByName(cell, "text_id") 
        GUI:Text_setString(ui_id, v.ID)

        local ui_name = GUI:getChildByName(cell, "text_name") 
        GUI:Text_setString(ui_name, v.name)

        GUI:addOnClickEvent(cell, function()
            BuffSetting._selId = v.ID
            BuffSetting._editCell = cell

            BuffSetting.refreshMenuState() 

            local param = {
                ID = v.ID,
                front_sfx = v.front_sfx,
                behind_sfx = v.behind_sfx,
                speed = v.speed,
                offsetx = v.offsetx,
                offsety = v.offsety,
                color = v.color,
                scale = v.buff_sacle,
                sort = v.sort,
                other_look = v.other_look,
                param = v.param
            }
            -- 模型avatar
            local modelParam = {
                color = v.color,
                scale = v.buff_sacle,
                avatar = v.avatar
            }
            BuffSetting.refreshPlayerModel(modelParam)
            BuffSetting.refreshBuffEffect(param)
            BuffSetting.refreshBuffParam(param)
            BuffSetting.refreshBuffTitle(v.bufftitle)
            BuffSetting.refreshBuffTips(v.tips)
            BuffSetting.refreshBuffIcon(v.icon)         
        end)
    end

    BuffSetting.refreshMenuState()

    local showData = key and BuffSetting._data[key] or BuffSetting._data[BuffSetting._selId]
    local param = {
        ID = showData.ID,
        front_sfx = showData.front_sfx,
        behind_sfx = showData.behind_sfx,
        speed = showData.speed,
        offsetx = showData.offsetx,
        offsety = showData.offsety,
        sort = showData.sort,
        other_look = showData.other_look,
    }
    local modelParam = {
        color = showData.color,
        scale = showData.buff_sacle,
        avatar = showData.avatar or "4#4#0"
    }
    -- 模型avatar
    BuffSetting.refreshPlayerModel(modelParam)
    BuffSetting.refreshBuffEffect(param)
    BuffSetting.refreshBuffParam(param)
    BuffSetting.refreshBuffTitle(showData.bufftitle)
    BuffSetting.refreshBuffTips(showData.tips)
    BuffSetting.refreshBuffIcon(showData.icon)
end 

function BuffSetting.addDoubleEventListener(node, param)
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

function BuffSetting.refreshMenuState()
    local data = BuffSetting.getBuffData()
    if not data and next(data) == nil then 
        return nil
    end
    
    for i, v in pairs(data) do 
        GUI:Layout_setBackGroundColor(BuffSetting._cells[v.ID], v.ID == BuffSetting._selId and "#ffbf6b" or "#000000")
    end 
end 

function BuffSetting.createMenuCell(id)
    local parent = GUI:Widget_Create(BuffSetting._ui["Panel_main"], "widget"..id, 0, 0)
    loadConfigSettingExport(parent, "buff_setting_ui/menu_cell")
    local cell = GUI:getChildByName(parent, "page_cell") 
    GUI:removeFromParent(parent)
    GUI:removeFromParent(cell)
    return cell
end

function BuffSetting.refreshPlayerModel(param)
    -- avatar
    if not param or not param.avatar or param.avatar == "" then 
        param.avatar = "4#4#0"
    end 

    local data = string.split(param.avatar, "#")
    if tonumber(data[1]) and tonumber(data[2]) then 
        local effectType = tonumber(data[1]) or 4 -- 4人物
        local effectId = tonumber(data[2]) or 4
        GUI:removeAllChildren(BuffSetting._ui["Node_model"])
        BuffSetting._model = nil

        local sex = tonumber(data[3]) or 0
        local act = global.MMO.ACTION_IDLE
        local dir = 4
        BuffSetting._model = GUI:Effect_Create(BuffSetting._ui["Node_model"], "model", 0, 0, effectType, effectId, sex, act, dir)
    else 
        SL:ShowSystemTips("参数错误")
    end 
     
    -- 模型颜色
    BuffSetting.setModelColor(SL:GetColorByStyleId(255))
    if param and param.color then 
        if param.color == 0 then 
            param.color = 255
        end 
        BuffSetting.setModelColor(SL:GetColorByStyleId(param.color))
    end 

    -- 模型缩放
    BuffSetting.setModelScale(1)
    if param and param.scale then 
        if param.scale == "" then 
            param.scale = 1
        end
        BuffSetting.setModelScale(param.scale)
    end 
end 

function BuffSetting.refreshBuffEffect(param)
    GUI:removeAllChildren(BuffSetting._ui["Node_buff"])
    GUI:removeAllChildren(BuffSetting._ui["Node_behind"])
    local id = param.ID
    if not id then 
        return 
    end 

    -- 模型静止
    BuffSetting._model:Play(global.MMO.ACTION_IDLE, 4, true, 1)

    -- 麻痹 正常
    local p = global.GLProgramCache:getGLProgram("ShaderPositionTextureColor_noMVP") 
    BuffSetting._model:setGLProgram(p)

    -- 隐身 正常
    BuffSetting.setEffectHide(255)

    if id == global.MMO.BUFF_ID_FREEZED_GRAY then -- 麻痹
        local p = global.GLProgramCache:getGLProgram("ShaderUIGrayScale")
        BuffSetting._model:setGLProgram(p)  
    elseif id == global.MMO.BUFF_ID_CLOAKING then -- 隐身
        BuffSetting.setEffectHide(155)
    elseif id == global.MMO.BUFF_ID_POISONING_RED then -- 红毒
        local color = cc.c3b(128, 0x00, 0x00)
        BuffSetting.setModelColor(color)
    elseif id == global.MMO.BUFF_ID_POISONING_GREEN then -- 绿毒
        local color = cc.c3b(0x00, 128, 0x00)
        BuffSetting.setModelColor(color)
    elseif id == global.MMO.BUFF_ID_ICE then -- 冰冻
        BuffSetting.setEffectIce()
    elseif id == global.MMO.BUFF_ID_ANGEL_SHIELD then -- 神圣战甲术
        BuffSetting.setEffectAngelShield()
    elseif id == global.MMO.BUFF_ID_GHOST_SHIELD then -- 幽灵盾
        BuffSetting.setEffectGhostShield()
    elseif id == 6 then -- 无极真气
        BuffSetting.setEffectWuJiShield()
    elseif id == 7 then -- 护体神盾
        BuffSetting.setEffectHuTiShield()
        
    end 

    if param and param.front_sfx and param.front_sfx > 0 then 
        local offsetxArray = string.split(param.offsetx or "0", "#")
        local offsetyArray = string.split(param.offsety or "0", "#") 
        local x = offsetxArray[1]
        local y = offsetyArray[1]
        local speed = param.speed and math.max(param.speed, 1) or 1
        local sex = 1
        local act = 0
        local dir = 0
        local effectType = 0 -- 特效

        GUI:removeAllChildren(BuffSetting._ui["Node_buff"])
        local buff = GUI:Effect_Create(BuffSetting._ui["Node_buff"], "buff", x, y, effectType, param.front_sfx, sex, act, dir, speed)
    end

    if param and param.behind_sfx and param.behind_sfx > 0 then 
        local offsetxArray = string.split(param.offsetx or "0", "#")
        local offsetyArray = string.split(param.offsety or "0", "#") 
        local x = offsetxArray[1]
        local y = offsetyArray[1]
        local speed = param.speed and math.max(param.speed, 1) or 1
        local sex = 1
        local act = 0
        local dir = 0
        local effectType = 0 -- 特效

        GUI:removeAllChildren(BuffSetting._ui["Node_behind"])
        local buff = GUI:Effect_Create(BuffSetting._ui["Node_behind"], "buff_behind", x, y, effectType, param.behind_sfx, sex, act, dir, speed)
    end
end 

function BuffSetting.setEffectHide(value)
    GUI:setOpacity(BuffSetting._model, value)
end 

function BuffSetting.setModelColor(color)
    local effectColor = color or cc.c3b(0xff, 0xff, 0xff)
    BuffSetting._model:setColor(effectColor)
end 

function BuffSetting.setModelScale(scale)
    BuffSetting._model:setScale(scale)
end 

function BuffSetting.setEffectAngelShield()
    local effectType = 3 -- 技能
    local effectId = 25
    local sex = 1
    local act = 0
    local dir = 0
    local speed = 1
    GUI:Effect_Create(BuffSetting._ui["Node_buff"], "skill", 0, 0, effectType, effectId, sex, act, dir, speed)
    BuffSetting._model:Play(global.MMO.ACTION_SKILL, 4, true, speed)
end 

function BuffSetting.setEffectGhostShield()
    local effectType = 3 -- 技能
    local effectId = 24
    local sex = 1
    local act = 0
    local dir = 0
    local speed = 1
    GUI:Effect_Create(BuffSetting._ui["Node_buff"], "skill", 0, 0, effectType, effectId, sex, act, dir, speed)
    BuffSetting._model:Play(global.MMO.ACTION_SKILL, 4, true, speed)
end 

function BuffSetting.setEffectWuJiShield()
    local effectType = 3 -- 技能
    local effectId = 63
    local sex = 1
    local act = 0
    local dir = 0
    local speed = 1
    GUI:Effect_Create(BuffSetting._ui["Node_buff"], "skill", 0, 0, effectType, effectId, sex, act, dir, speed)
    BuffSetting._model:Play(global.MMO.ACTION_SKILL, 4, true, speed)
end 

function BuffSetting.setEffectHuTiShield()
    local effectType = 3 -- 技能
    local effectId = 141
    local sex = 1
    local act = 0
    local dir = 0
    local speed = 1
    GUI:Effect_Create(BuffSetting._ui["Node_buff"], "skill", 0, 0, effectType, effectId, sex, act, dir, speed)
    BuffSetting._model:Play(global.MMO.ACTION_SKILL, 4, true, speed)
end 

function BuffSetting.setEffectIce()
    local GL_P = cc.GLProgram:createWithFilenames( "shader/position_texture_color_nomvp.vert", "shader/highlight_ice_color_nomvp.frag" )
    global.GLProgramCache:addGLProgram( GL_P, "ShaderIceColor_noMVP" )

    if GL_P then
        BuffSetting._model:setGLProgram( GL_P )
    end
end

-- buff参数
function BuffSetting.refreshBuffParam(param)
    local Input_sfx1_audio = BuffSetting._ui["Input_sfx1_audio"]
    local Input_sfx1 = BuffSetting._ui["Input_sfx1"]
    local Input_sfx2 = BuffSetting._ui["Input_sfx2"]
    local Input_speed = BuffSetting._ui["Input_speed"]
    local Input_x = BuffSetting._ui["Input_x"]
    local Input_y = BuffSetting._ui["Input_y"]
    local Input_color = BuffSetting._ui["Input_color"]
    local Input_scale = BuffSetting._ui["Input_scale"]
    local Input_avatar = BuffSetting._ui["Input_avatar"]
    local Input_sort = BuffSetting._ui["Input_sort"]
    local Check_otherLook = BuffSetting._ui["CheckBox_lookOther"]

    GUI:TextInput_setString(Input_sfx1_audio, param.buff_audio and param.buff_audio or "")
    GUI:TextInput_setPlaceHolder(Input_sfx1_audio, "无")

    GUI:setTouchEnabled(Input_sfx1, param.front_sfx and true or false)
    GUI:TextInput_setString(Input_sfx1, param.front_sfx and param.front_sfx or "无")

    GUI:setTouchEnabled(Input_sfx2, param.behind_sfx and true or false)
    GUI:TextInput_setString(Input_sfx2, param.behind_sfx and param.behind_sfx or "无")

    GUI:setTouchEnabled(Input_speed, param.front_sfx and true or false)
    GUI:TextInput_setString(Input_speed, param.front_sfx and param.speed or "无")


    local isTouch = (param.front_sfx or param.behind_sfx) and true or false
    GUI:setTouchEnabled(Input_x, isTouch)
    GUI:TextInput_setString(Input_x, (param.front_sfx or param.behind_sfx) and param.offsetx or (isTouch and "" or "无"))
    GUI:TextInput_setPlaceholderFontSize(Input_x, 14)
    GUI:TextInput_setPlaceHolder(Input_x, "x#骑马x#骑马显示")

    GUI:setTouchEnabled(Input_y, (param.front_sfx or param.behind_sfx) and true or false)
    GUI:TextInput_setString(Input_y, (param.front_sfx or param.behind_sfx) and param.offsety or (isTouch and "" or "无"))
    GUI:TextInput_setPlaceholderFontSize(Input_y, 14)
    GUI:TextInput_setPlaceHolder(Input_y, "y#骑马y#骑马显示")

    -- 颜色
    local color = param.color and param.color or 255
    GUI:Layout_setBackGroundColor(BuffSetting._ui["panel_color"], SL:GetHexColorByStyleId(color))
    GUI:TextInput_setString(Input_color, "")
    GUI:TextInput_setPlaceHolder(Input_color, "255")

    -- 缩放
    GUI:TextInput_setString(Input_scale, param.scale and param.scale or 1)

    -- avatar
    GUI:TextInput_setString(Input_avatar, param.avatar and param.avatar or "无")

    -- 图标排序
    GUI:TextInput_setString(Input_sort, param.sort or "")

    -- 勾选他人可见
    GUI:CheckBox_setSelected(Check_otherLook, param.other_look == 1)
end 

-- 触发buff文字
function BuffSetting.refreshBuffTitle(bufftitle)
    local titleStr = ""
    if bufftitle then 
        titleStr = bufftitle
    end 

    local Input_title = BuffSetting._ui["Input_title"]
    GUI:Text_setString(Input_title, titleStr)
end

-- 图标Tips内容显示
function BuffSetting.refreshBuffTips(tips)
    local tipsStr = ""
    if tips then 
        tipsStr = tips
    end 

    local Input_tips = BuffSetting._ui["Input_tips"]
    GUI:Text_setString(Input_tips, tipsStr)
end

-- 显示Buff图标
function BuffSetting.refreshBuffIcon(icon, path)
    local iconId = 1
    if icon then 
        iconId = icon
    end 

    local path = string.format("%s%s.png", global.MMO.PATH_RES_BUFF_ICON, iconId)
    GUI:Image_loadTexture(BuffSetting._ui["Image_icon"], path)

    local iconPath = string.format("res/buff_icon/%s.png", iconId)
    if path then 
        iconPath = path
    end 

    GUI:Text_setString(BuffSetting._ui["Text_path"], iconPath)
end

function BuffSetting.initConfigData()
    BuffSetting._config = {}
    local config = requireGameConfig("cfg_buff")
    BuffSetting._config = config

    local data = {}
    for i, v in pairs(config) do 
        data[v.ID] = v
    end 
    BuffSetting._data = {}
    BuffSetting._data = data

    local configPath = "scripts/game_server_config/cfg_buff.lua"
    local devPath = global.FileUtilCtl:getDefaultResourceRootPath() .. "dev/" .. configPath
    local isFile = global.FileUtilCtl:isFileExist(devPath)
    if isFile then 
        BuffSetting._fixConfig  = require(devPath)
    else 
        BuffSetting._fixConfig = {}
    end  
end 

function BuffSetting.getBuffData()
    local data = {}
    for i, v in pairs(BuffSetting._data) do 
        if v.front_sfx then 
            v.front_sfx = BuffSetting.parseBuffValue(v.front_sfx) and BuffSetting.parseBuffValue(v.front_sfx).sfxID or 0
        end 

        if v.behind_sfx then 
            v.behind_sfx = BuffSetting.parseBuffValue(v.behind_sfx) and BuffSetting.parseBuffValue(v.behind_sfx).sfxID or 0
        end 

        if v.front_sfx_stuck then 
            v.front_sfx_stuck = BuffSetting.parseBuffValue(v.front_sfx_stuck) and BuffSetting.parseBuffValue(v.front_sfx_stuck).sfxID or 0
        end
        table.insert(data, v)
    end 

    table.sort(data, function(a, b) return a.ID < b.ID end)
    return data
end 

function BuffSetting.parseBuffValue( value )
    if not value then
        return nil
    end
    value = tostring(value)
    if string.len(value) == 0 then
        return nil
    end

    local offsetList = string.split(value, "|")
    value = offsetList[1]
    local unOffset = offsetList[2] and tonumber(offsetList[2]) or 0
    local slices = string.split( value, "#" )
    return { sfxID = tonumber(slices[1]) or tonumber(slices[2]), loop = tonumber(slices[3]) or 0, is8dir = slices[4], unOffset = unOffset}
end

return BuffSetting