DamageNumSetting = {}

local Queue = requireUtil("queue")
local _pathRes = "res/private/damage_num/"
local ascii = {
    ":", ";", "<", "=", ">", "?", "@",
    "A", "B", "C", "D", "E", "F", "G",
    "H", "I", "J", "K", "L", "M", "N",
    "O", "P", "Q", "R", "S", "T", "U",
    "V", "W", "X", "Y", "Z",
}

local PARAM_TYPE = {
    TIME_PARAM     = 1,
    ANCHOR_PARAM   = 2,
    MOVEBY_ACTION  = 3,
    SCALETO_ACTION = 4,
    FADETO_ACTION  = 5,
    DELAY_ACTION   = 6,
    MAX            = 6,
}

local duration = 0.2
local test_num = "123450"
local original_pos = {x = 100, y = 10}
local new_pos = cc.pAdd(original_pos, global.MMO.PLAYER_AVATAR_OFFSET)


local tActInput = {
    ["input_time"]     = {actType  = 1, paramKey = "value", min = 0, cannotEmpty = true,},
    ["input_anchorX"]  = {actType  = 2, paramKey = "x",     min = 0,},
    ["input_anchorY"]  = {actType  = 2, paramKey = "y",     min = 0,},
    ["input_offsetX"]  = {actType  = 3, paramKey = "x",},
    ["input_offsetY"]  = {actType  = 3, paramKey = "y",},
    ["input_scale"]    = {actType  = 4, paramKey = "value", min = 0, max = 100},
    ["input_opacity"]  = {actType  = 5, paramKey = "value", min = 0, max = 1,},
    ["input_waitting"] = {actType  = 6, paramKey = "value", min = 0 },
    ["inputX"]         = {paramKey = "x",},
    ["inputY"]         = {paramKey = "y",},
}

local function getPrefix(len)
    return table.concat(ascii, "", 1, len) .. "/"
end

local function getAftherfix(len, starfix)
    return table.concat(ascii, "", starfix or 1, len)
end

-- 设置开关按钮状态
local function setSwitchCellStatus(switch, enable)
    enable = enable and true or false
    GUI:setVisible(GUI:getChildByName(switch, "Panel_off"), not enable)
    GUI:setVisible(GUI:getChildByName(switch, "Panel_on"), enable)
end

local function checkSplitParam(param)
    if not param or string.len(param) <= 0 then
        return false
    end

    return true
end

local function parseActionParam(param)
    if (not param) or (#param <= 0) then
        return nil
    end

    local paramType = tonumber(param[1])
    if not paramType or paramType < 1 or paramType > PARAM_TYPE.MAX then
        return nil
    end

    local ret = { type = paramType }
    if paramType == PARAM_TYPE.ANCHOR_PARAM or paramType == PARAM_TYPE.MOVEBY_ACTION then
        ret.x = tonumber(param[2] or 0)
        ret.y = tonumber(param[3] or 0)
        ret.duration = duration
    elseif paramType == PARAM_TYPE.TIME_PARAM then
        duration = tonumber(param[2]) or 0.2
        ret.value = duration
        ret.duration = duration
    else
        ret.value = tonumber(param[2]) or 1
        ret.duration = duration
    end

    return ret
end

local function parseAllStepParam(all_steps_param)
    if not checkSplitParam(all_steps_param) then
        return {}
    end

    -- 1#X#Y|2#0.5|3#0.5|1#X#Y&1#X#Y
    local steps_actions = {}
    local steps_param = string.split(all_steps_param, "&")
    for _, step_param in ipairs(steps_param) do               -- steps
        if checkSplitParam(step_param) then
            local actions = {}
            local actions_param = string.split(step_param, "|")
            for _, action_param in ipairs(actions_param) do   -- actions
                if checkSplitParam(action_param) then
                    local param = string.split(action_param, "#")
                    if #param > 0 then
                        local action_data = parseActionParam(param)
                        if action_data then
                            table.insert(actions, action_data)
                        end
                    end
                end
            end

            if #actions > 0 then
                table.insert(steps_actions, actions)
            end
        end
    end
    -- SL:Dump(steps_actions, "all steps actions")

    return steps_actions
end

local function parseOffsetParam(param)
    if not checkSplitParam(param) then
        return {}
    end

    local ret = {}
    local all_offsets_param = string.split(param, "|")
    for _, offset_param in ipairs(all_offsets_param) do
        local offset = string.split(offset_param, "#")
        table.insert(ret, cc.p(tonumber(offset[1]) or 0, tonumber(offset[2]) or 0))
    end

    return ret
end

local function releaseCache(cache)
    if not cache:empty() then
        local size = cache:size()
        for i = 1, size do
            local node = cache:pop()
            node:autorelease()
        end

        cache:clear()
    end
end

local function saveConfig()
    SL:SaveTableToConfig(DamageNumSetting._config, "cfg_damage_number")
    global.FileUtilCtl:purgeCachedEntries()
    DamageNumSetting.loadConfig()
    SL:ShowSystemTips("保存成功")
end

function DamageNumSetting.initData()
    DamageNumSetting._curCfg = nil
    DamageNumSetting._name = ""
    DamageNumSetting._id = nil
    DamageNumSetting._zOrder = nil
    DamageNumSetting._type = 1      -- 飘字类型 1艺术字 文本+数值，2单图片文字，3艺术字 文本(无数值)  4艺术字 带单位
    DamageNumSetting._prefixLen = nil      -- 前缀长度
    DamageNumSetting._prefix = nil      -- 前缀
    DamageNumSetting._width = nil   -- 宽度
    DamageNumSetting._height = nil  -- 高度
    DamageNumSetting._sfxId = nil   -- 特效
    DamageNumSetting._shake = false  -- 是否需要震屏
    DamageNumSetting._hpWarning = false  -- 是否需要低血警示
    DamageNumSetting._selActPage = nil    -- 动画配置区选择的页签
    DamageNumSetting._selActCellIdx = nil  -- 动画列表选择的索引
    DamageNumSetting._resPath = nil  -- 图片资源名称
    DamageNumSetting._ownActParam = {}  -- 自身动画参数
    DamageNumSetting._otherActParam = {}  -- 他人动画参数
    DamageNumSetting._actOffsetParam = {}  -- 动画节点位置，防止重叠
    DamageNumSetting._offsetDatas = {}
    DamageNumSetting._labelCache = Queue.new()
    DamageNumSetting._spriteCache = Queue.new()
    DamageNumSetting._cloneCurActParam = {}  -- 方便恢复动作
    DamageNumSetting._enable = true -- 飘字开关
end

function DamageNumSetting.loadConfig()
    DamageNumSetting._config = SL:Require("game_config/cfg_damage_number", true)
    DamageNumSetting._configWithId = {}
    for k, v in pairs(DamageNumSetting._config) do
        DamageNumSetting._configWithId[v.id] = v
    end
end

function DamageNumSetting.main(parent)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "damage_number_setting")

    DamageNumSetting._ui = GUI:ui_delegate(parent)
    DamageNumSetting._Panel_1 = DamageNumSetting._ui["Panel_1"]
    DamageNumSetting._Layout_prefixLenMask = DamageNumSetting._ui["Layout_prefixLenMask"]
    DamageNumSetting._lv_action = DamageNumSetting._ui["lv_action"]
    DamageNumSetting._Text_res_name = DamageNumSetting._ui["Text_res_name"]
    DamageNumSetting._img_res = DamageNumSetting._ui["img_res"]
    GUI:setVisible(DamageNumSetting._img_res, false)
    DamageNumSetting._Layout_show = DamageNumSetting._ui["Layout_show"]

    DamageNumSetting._pages = {}
    DamageNumSetting._index = 0

    DamageNumSetting.initData()

    DamageNumSetting.loadConfig()

    DamageNumSetting.initPages()
    DamageNumSetting.initContent()

    -- 默认跳到第一个
    DamageNumSetting.pageTo(1)

    local fadein = GUI:ActionFadeIn(1)
    local fadeout = GUI:ActionFadeOut(1)
    local action = GUI:ActionRepeatForever(GUI:ActionSequence(fadeout, fadein))
    GUI:runAction(DamageNumSetting._ui["Text_notice"], action)

    -- 新增飘字
    local btn_add = DamageNumSetting._ui["btn_add"]
    GUI:addOnClickEvent(btn_add, function()
        GUI:delayTouchEnabled(btn_add)
        local pageKeys = table.keys(DamageNumSetting._configWithId)
        table.sort(pageKeys)
        local id = (pageKeys[#pageKeys] or 0) + 1
        local tmpCfg = {}
        tmpCfg.id = id
        tmpCfg.name = "新增" .. id   
        DamageNumSetting._config[id] = tmpCfg
        saveConfig()
        DamageNumSetting.initPages(id)
        DamageNumSetting.pageTo(id)
        SL:ShowSystemTips("新增飘字成功")
    end)

    local function getSelPage(children)
        local ret = {}
        for idx, child in ipairs(children) do
            local checkBox = GUI:getChildByName(child, "checkBox")
            local isSel = GUI:CheckBox_isSelected(checkBox)
            if isSel then
                local v = GUI:Win_GetParam(child)
                ret[v.id] = v
            end
        end
        return ret
    end

    -- 复制新增飘字
    local btn_copy = DamageNumSetting._ui["btn_copy"]
    GUI:addOnClickEvent(btn_copy, function()
        GUI:delayTouchEnabled(btn_copy)

        local selPage = getSelPage(GUI:ListView_getItems(DamageNumSetting._ui["ListView_page"]))
        if not next(selPage) then
            SL:ShowSystemTips("请勾选要复制新增的飘字")
            return
        end

        local selKeys = table.keys(selPage)
        table.sort(selKeys)

        local pageKeys = table.keys(DamageNumSetting._configWithId)
        table.sort(pageKeys)
        local startId = pageKeys[#pageKeys] or 0

        local jumpid = clone(startId)

        for _, idx in ipairs(selKeys) do
            startId = startId + 1
            local v = selPage[idx]
            local tmpCfg = clone(v)
            tmpCfg.id = startId
            tmpCfg.name = (tmpCfg.name and tmpCfg.name ~= "" and tmpCfg.name or "复制新增") .. "_" .. startId  
            DamageNumSetting._config[startId] = tmpCfg
        end
    
        saveConfig()

        -- 跳转到复制新增的第一个
        DamageNumSetting.initPages(jumpid + 1)
        DamageNumSetting.pageTo(jumpid + 1)
        SL:ShowSystemTips("复制新增飘字成功")
    end)

    -- 删除飘字
    local btn_del = DamageNumSetting._ui["btn_del"]
    GUI:addOnClickEvent(btn_del, function()
        GUI:delayTouchEnabled(btn_del)

        local selPage = getSelPage(GUI:ListView_getItems(DamageNumSetting._ui["ListView_page"]))
        if not next(selPage) then
            SL:ShowSystemTips("请勾选要删除的飘字")
            return
        end

        -- 先删除勾选的，再拿key排序
        local cfg = clone(DamageNumSetting._config)
        for k, v in pairs(cfg) do
            if selPage[v.id] then
                cfg[k] = nil
            end
        end

        local cfgKeys = table.keys(cfg)
        table.sort(cfgKeys)

        DamageNumSetting._config = {}
        for _, key in ipairs(cfgKeys) do
            local v = cfg[key]
            DamageNumSetting._config[v.id] = v
        end

        saveConfig()

        DamageNumSetting.initPages()
        local keys = table.keys(DamageNumSetting._configWithId)
        table.sort(keys)
        if next(keys) then
            DamageNumSetting.pageTo(keys[1])
        end
        SL:ShowSystemTips("删除飘字成功")
    end)

    local function paramAct2Str(tParam)
        -- dump(tParam, "paramAct2Str:::", 10)
        local retStr = ""
        if tParam and next(tParam) then
            for k, v in ipairs(tParam) do
                local strOneAct = ""
                for idx, act in ipairs(v) do
                    local strAct = ""
                    if act.type == PARAM_TYPE.ANCHOR_PARAM or act.type == PARAM_TYPE.MOVEBY_ACTION then
                        strAct = string.format("%s#%s#%s", act.type, act.x, act.y)
                    else
                        strAct = string.format("%s#%s", act.type, act.value)
                    end
                    strOneAct = strOneAct .. strAct .. (idx == #v and "" or "|")
                end
                retStr = retStr .. strOneAct .. (k == #tParam and "" or "&")
            end
        end
        return retStr
    end

    local function paramOffset2Str(tParam)
        -- dump(tParam, "paramOffset2Str:::", 10)
        local retStr = ""
        if tParam and next(tParam) then
            for k, v in ipairs(tParam) do
                retStr = retStr .. (v.x or 0) .. "#" .. (v.y or 0) .. (k == #tParam and "" or "|")
            end
        end
        return retStr
    end

    local btn_sure = DamageNumSetting._ui["btn_sure"]
    GUI:addOnClickEvent(btn_sure, function()
        GUI:delayTouchEnabled(btn_sure, 0.5)
        local curCfg = DamageNumSetting._curCfg
        curCfg.enable = DamageNumSetting._enable and 1 or 0
        curCfg.name = DamageNumSetting._name or ""
        curCfg.id = DamageNumSetting._id
        curCfg.zOrder = DamageNumSetting._zOrder or 1
        curCfg.shake = DamageNumSetting._shake and 1 or nil
        curCfg.damage_type = DamageNumSetting._hpWarning and 1 or nil
        curCfg.animID = DamageNumSetting._sfxId
        curCfg.width = DamageNumSetting._width
        curCfg.height = DamageNumSetting._height        
        curCfg.type = DamageNumSetting._type or 1
        curCfg.res = string.gsub(DamageNumSetting._resPath, _pathRes, "")
        if curCfg.type == 2 then
            curCfg.prefix = ""
        elseif curCfg.type == 4 then
            --_aftherfixLen
            local prefixLen = tonumber(DamageNumSetting._prefixLen) or 0
            curCfg.prefix = getPrefix(prefixLen) or "/"
            curCfg.afterfix = getAftherfix((tonumber(DamageNumSetting._aftherfixLen) or 9)+prefixLen, prefixLen+1) or ""
        else
            curCfg.prefix = getPrefix(tonumber(DamageNumSetting._prefixLen) or 0) or "/"
        end
        local strOwnParam = paramAct2Str(DamageNumSetting._ownActParam)
        curCfg.own_param = strOwnParam
        local strOtherParam = paramAct2Str(DamageNumSetting._otherActParam)
        curCfg.other_param = strOtherParam
        local strOffsetParam = paramOffset2Str(DamageNumSetting._actOffsetParam)
        curCfg.offset_param = string.len(strOffsetParam) > 0 and strOffsetParam or nil
        
        DamageNumSetting._config[curCfg.id] = {}
        DamageNumSetting._config[curCfg.id] = curCfg
        saveConfig()
    end)
end

function DamageNumSetting.initPages(id)
    DamageNumSetting._pages = {}
    local ListView_page = DamageNumSetting._ui["ListView_page"]
    GUI:ListView_removeAllItems(ListView_page)
    GUI:ListView_addMouseScrollPercent(ListView_page)

    local pageKeys = table.keys(DamageNumSetting._configWithId)
    table.sort(pageKeys)

    local jumidx = nil
    local findIdx = 0
    for k, key in ipairs(pageKeys) do
        local v = DamageNumSetting._configWithId[key]
        local pageCell = GUI:Layout_Create(ListView_page, "page_cell" .. k, 260, 330, 200, 50, false)
        GUI:Layout_setBackGroundColorType(pageCell, 1)
        GUI:Layout_setBackGroundColor(pageCell, "#000000")
        GUI:Layout_setBackGroundColorOpacity(pageCell, 140)
        GUI:setTouchEnabled(pageCell, true)

        local PageId = GUI:Text_Create(pageCell, "PageId", 36, 25, 16, "#ffffff", v.id)
        GUI:setAnchorPoint(PageId, 0, 0.5)
        GUI:Text_enableOutline(PageId, "#000000", 1)

        local PageText = GUI:Text_Create(pageCell, "PageText", 130, 25, 16, "#ffffff", v.name or "")
        GUI:setAnchorPoint(PageText, 0.5, 0.5)
        GUI:Text_setTextHorizontalAlignment(PageText, 1)
        GUI:Text_enableOutline(PageText, "#000000", 1)
        GUI:Text_setMaxLineWidth(PageText, 120)

        GUI:Win_SetParam(pageCell, v)

        GUI:addOnClickEvent(pageCell, function()
            DamageNumSetting.pageTo(v.id)
        end)

        -- 勾选复选框
        local checkBox = GUI:CheckBox_Create(pageCell, "checkBox", 20, 25, "res/public/1900000550.png", "res/public/1900000551.png")
        GUI:setAnchorPoint(checkBox, 0.5, 0.5)
        GUI:CheckBox_setSelected(checkBox, false)
        local TouchSize = GUI:Layout_Create(checkBox, "TouchSize", 15, 14, 40, 50, false)
        GUI:setAnchorPoint(TouchSize, 0.50, 0.50)
        GUI:setTouchEnabled(TouchSize, true)
        GUI:setVisible(TouchSize, false)

        DamageNumSetting._pages["pageCell" .. v.id] = pageCell

        if not jumidx and id and id == v.id then
            jumidx = findIdx
        else
            findIdx = findIdx + 1
        end
    end

    GUI:ListView_jumpToItem(ListView_page, jumidx or 1)
end

function DamageNumSetting.initContent()
    -- 开关
    local Layout_enable = DamageNumSetting._ui["Layout_enable"]
    local switch_enable = GUI:getChildByName(Layout_enable, "CheckBox_able")
    DamageNumSetting._switch_enable = switch_enable
    GUI:addOnClickEvent(Layout_enable, function()
        DamageNumSetting._enable = not DamageNumSetting._enable
        setSwitchCellStatus(switch_enable, DamageNumSetting._enable)
    end)
    setSwitchCellStatus(switch_enable, DamageNumSetting._enable)


    -- 标题 name
    local input_name = DamageNumSetting._ui["input_name"]
    DamageNumSetting._input_name = input_name
    GUI:TextInput_addOnEvent(input_name, function(sender, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_name)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("名称不能为空")
                GUI:TextInput_setString(input_name, DamageNumSetting._name)
                return
            end

            DamageNumSetting._name = inputStr
        end
    end)

    -- 飘字ID
    local input_id = DamageNumSetting._ui["input_id"]
    DamageNumSetting._input_id = input_id
    GUI:TextInput_setInputMode(input_id, 2)
    GUI:TextInput_addOnEvent(input_id, function(sender, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_id)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("ID不能为空")
                GUI:TextInput_setString(input_id, DamageNumSetting._id)
                return
            end

            local id = tonumber(inputStr)

            if DamageNumSetting._configWithId[id] then
                SL:ShowSystemTips("ID重复了，请检查列表")
                GUI:TextInput_setString(input_id, DamageNumSetting._id)
                return
            end

            -- 更新
            local oldId = clone(DamageNumSetting._id)
            DamageNumSetting._id = id
            for k, v in pairs(DamageNumSetting._config) do
                if oldId == v.id then
                    v.id = id
                    DamageNumSetting._config[id] = v
                    DamageNumSetting._config[k] = nil
                    saveConfig()
                    DamageNumSetting.initPages(DamageNumSetting._id)
                    DamageNumSetting.pageTo(DamageNumSetting._id)
                end
            end
        end
    end)

    -- zOrder
    local input_zOrder = DamageNumSetting._ui["input_zOrder"]
    DamageNumSetting._input_zOrder = input_zOrder
    GUI:TextInput_addOnEvent(input_zOrder, function(sender, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_zOrder)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("层级不能为空")
                GUI:TextInput_setString(input_zOrder, DamageNumSetting._zOrder)
                return
            end

            if not tonumber(inputStr) then
                SL:ShowSystemTips("层级必须为数字")
                GUI:TextInput_setString(input_zOrder, DamageNumSetting._zOrder)
                return
            end

            DamageNumSetting._zOrder = tonumber(inputStr)
        end
    end)

    local inputNumNoZero = {
        ["input_imgW"] = { key = "_width", tips = "宽度" },
        ["input_imgH"] = { key = "_height", tips = "高度" },
        ["input_sfx"] = { key = "_sfxId", tips = "特效id", canEmpty = true,},
    }

    -- 图片尺寸
    local input_imgW = DamageNumSetting._ui["input_imgW"]
    local input_imgH = DamageNumSetting._ui["input_imgH"]
    DamageNumSetting._input_imgW = input_imgW
    DamageNumSetting._input_imgH = input_imgH
    GUI:TextInput_setInputMode(input_imgW, 2)
    GUI:TextInput_setInputMode(input_imgH, 2)
    local function onInputNumNoZero(sender, eventType)
        if eventType == 1 then
            local senderName = GUI:getName(sender)
            local inputCfg = inputNumNoZero[senderName]
            local inputStr = GUI:TextInput_getString(sender)
            if not inputCfg.canEmpty and string.len(inputStr) == 0 then
                SL:ShowSystemTips(inputNumNoZero[senderName].tips .. "不能为空")
                GUI:TextInput_setString(sender, DamageNumSetting[inputNumNoZero[senderName].key] or "")
                return
            end

            if tonumber(inputStr) == 0 then
                SL:ShowSystemTips(inputNumNoZero[senderName].tips .. "不能为0")
                GUI:TextInput_setString(sender, DamageNumSetting[inputNumNoZero[senderName].key] or "")
                return
            end

            DamageNumSetting[inputNumNoZero[senderName].key] = tonumber(inputStr)

            DamageNumSetting.ThrowAction()
        end
    end
    GUI:TextInput_addOnEvent(input_imgW, onInputNumNoZero)
    GUI:TextInput_addOnEvent(input_imgH, onInputNumNoZero)

    -- 特效显示
    local input_sfx = DamageNumSetting._ui["input_sfx"]
    DamageNumSetting._input_sfx = input_sfx
    GUI:TextInput_setInputMode(input_sfx, 2)
    GUI:TextInput_addOnEvent(input_sfx, onInputNumNoZero)

    -- 震屏开关
    local Layout_shake = DamageNumSetting._ui["Layout_shake"]
    DamageNumSetting._Layout_shake = Layout_shake
    local switch_shake = GUI:getChildByName(Layout_shake, "CheckBox_able")
    DamageNumSetting._switch_shake = switch_shake
    GUI:addOnClickEvent(Layout_shake, function()
        DamageNumSetting._shake = not DamageNumSetting._shake
        setSwitchCellStatus(switch_shake, DamageNumSetting._shake)
        if DamageNumSetting._shake then
            local data    = {}
            data.time     = 1000
            data.distance = 20
            global.Facade:sendNotification(global.NoticeTable.ShakeScene, data)
    
            if GUI:getActionByTag(DamageNumSetting._Panel_1, 1234) then
                GUI:stopActionByTag(DamageNumSetting._Panel_1, 1234)
                GUI:setPosition(DamageNumSetting._Panel_1, 0, 0)
            end
    
            local time = data.time and data.time * 0.001 or 0.7
            local x = data.distance or 10
            local y = data.distance or 10
    
            local shake = GUI:Timeline_Shake(DamageNumSetting._Panel_1, time, x, y)
            GUI:setTag(shake, 1234)
        end
    end)
    setSwitchCellStatus(switch_shake, DamageNumSetting._shake)

    -- 低血警示
    local Layout_LowHpWarning = DamageNumSetting._ui["Layout_LowHpWarning"]
    local switch_hpWarning = GUI:getChildByName(Layout_LowHpWarning, "CheckBox_able")
    DamageNumSetting._switch_hpWarning = switch_hpWarning
    GUI:addOnClickEvent(Layout_LowHpWarning, function()
        DamageNumSetting._hpWarning = not DamageNumSetting._hpWarning
        setSwitchCellStatus(switch_hpWarning, DamageNumSetting._hpWarning)
        if DamageNumSetting._hpWarning then
            DamageNumSetting._HurtTipsLayer = requireLayerUI("hurt_tips_layer/HurtTipsLayer").create()
            global.Facade:sendNotification(global.NoticeTable.Layer_Notice_AddChild, {child = DamageNumSetting._HurtTipsLayer})
            SL:ScheduleOnce(function()
                if DamageNumSetting._HurtTipsLayer then
                    GUI:removeFromParent(DamageNumSetting._HurtTipsLayer)
                    DamageNumSetting._HurtTipsLayer = nil
                end
            end, 5)
        else
            if DamageNumSetting._HurtTipsLayer then
                GUI:removeFromParent(DamageNumSetting._HurtTipsLayer)
                DamageNumSetting._HurtTipsLayer = nil
            end
        end
    end)
    setSwitchCellStatus(switch_hpWarning, DamageNumSetting._hpWarning)

    -- 飘字类型
    for i = 1, 4 do
        local layout = DamageNumSetting._ui["Layout_type" .. i]
        GUI:addOnClickEvent(layout, function()
            DamageNumSetting._type = i
            DamageNumSetting.setTypeState()
            DamageNumSetting.ThrowAction()
        end)
    end

    -- 前缀长度
    local input_prefixLen = DamageNumSetting._ui["input_prefixLen"]
    DamageNumSetting._input_prefixLen = input_prefixLen
    GUI:TextInput_setInputMode(input_prefixLen, 2)
    GUI:TextInput_addOnEvent(input_prefixLen, function(sender, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_prefixLen)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("文字长度不能为空")
                GUI:TextInput_setString(sender, DamageNumSetting._prefixLen or "")
                return
            end

            DamageNumSetting._prefixLen = tonumber(inputStr)

            DamageNumSetting.ThrowAction()
        end
    end)

    -- 后缀长度
    local input_aftherfixLen = DamageNumSetting._ui["input_aftherfixLen"]
    DamageNumSetting._input_aftherfixLen = input_aftherfixLen
    GUI:TextInput_setInputMode(input_aftherfixLen, 2)
    GUI:TextInput_addOnEvent(input_aftherfixLen, function(sender, eventType)
        if eventType == 1 then
            local inputStr = GUI:TextInput_getString(input_aftherfixLen)
            if string.len(inputStr) == 0 then
                SL:ShowSystemTips("文字长度不能为空")
                GUI:TextInput_setString(sender, DamageNumSetting._aftherfixLen or "")
                return
            end

            DamageNumSetting._aftherfixLen = tonumber(inputStr)

            DamageNumSetting.ThrowAction()
        end
    end)

    -- act 配置页签
    for i = 1, 3 do
        local btnActPage = DamageNumSetting._ui["act_page" .. i]
        GUI:addOnClickEvent(btnActPage, function()
            DamageNumSetting.onBtnActPage(i)
        end)
    end

    -- act input
    for k, v in pairs(tActInput) do
        v.oldValue = nil
        local input = DamageNumSetting._ui[k]
        if v.onlyNum then
            GUI:TextInput_setInputMode(input, 2)
        end
        GUI:TextInput_addOnEvent(input, function(sender, eventType)
            if eventType == 1 then
                local oldValue = v.oldValue or ""
                local inputStr = GUI:TextInput_getString(sender)
                if string.len(inputStr) == 0 and v.cannotEmpty then
                    SL:ShowSystemTips("输入内容不能为空")
                    GUI:TextInput_setString(sender, oldValue)
                    return
                end

                if string.len(inputStr) > 0 then
                    if not tonumber(inputStr) then
                        SL:ShowSystemTips("请输入数字")
                        GUI:TextInput_setString(sender, oldValue)
                        return
                    end

                    local inputNum = tonumber(inputStr)
                    if v.min and inputNum < v.min then
                        SL:ShowSystemTips("请输入大于等于" .. v.min .. "的数字")
                        GUI:TextInput_setString(sender, oldValue)
                        return
                    elseif v.max and inputNum > v.max then
                        GUI:TextInput_setString(sender, oldValue)
                        SL:ShowSystemTips("请输入小于等于" .. v.max .. "的数字")
                        return
                    end
                end

                v.oldValue = tonumber(inputStr)

                -- dump(DamageNumSetting._cloneCurActParam, "DamageNumSetting._cloneCurActParam>>>old")

                if DamageNumSetting._selActPage <= 2 then
                    if not next(DamageNumSetting._cloneCurActParam) then
                        local tmpParam = {}
                        tmpParam.type = v.actType
                        tmpParam.duration = 0
                        tmpParam[v.paramKey] = tonumber(inputStr)
                        table.insert(DamageNumSetting._cloneCurActParam, tmpParam)
                    else
                        if v.actType == 1 then
                            for _, vv in ipairs(DamageNumSetting._cloneCurActParam) do
                                vv.duration = tonumber(inputStr)
                                if vv.type == 1 then
                                    vv.value = tonumber(inputStr)
                                end
                            end
                        else
                            -- 删除空的，否则修改或新增
                            if tonumber(inputStr) == nil then
                                local findFlag = nil
                                for kk, vv in ipairs(DamageNumSetting._cloneCurActParam) do
                                    if vv.type == v.actType then
                                        findFlag = kk
                                        break
                                    end
                                end

                                if findFlag then
                                    for i = findFlag, #DamageNumSetting._cloneCurActParam do
                                        if i < #DamageNumSetting._cloneCurActParam then
                                            DamageNumSetting._cloneCurActParam[i] = DamageNumSetting._cloneCurActParam[i + 1]
                                        else
                                            DamageNumSetting._cloneCurActParam[i] = nil
                                        end
                                    end
                                end
                            else
                                local findFlag = false
                                for _, vv in ipairs(DamageNumSetting._cloneCurActParam) do
                                    if vv.type == v.actType then
                                        vv[v.paramKey] = tonumber(inputStr)
                                        findFlag = true
                                        break
                                    end
                                end
        
                                if not findFlag then
                                    local tmpParam = {}
                                    tmpParam.type = v.actType
                                    tmpParam.duration = DamageNumSetting._cloneCurActParam[1].value
                                    tmpParam[v.paramKey] = tonumber(inputStr)
                                    table.insert(DamageNumSetting._cloneCurActParam, tmpParam)
                                end
                            end
                        end
                    end
                else
                    DamageNumSetting._cloneCurActParam[v.paramKey] = tonumber(inputStr)
                end

                -- dump(DamageNumSetting._cloneCurActParam, "DamageNumSetting._cloneCurActParam>>>new")

                DamageNumSetting.ThrowAction()
            end
        end)
    end

    -- 记录动作
    local btn_act_save = DamageNumSetting._ui["btn_act_save"]
    GUI:addOnClickEvent(btn_act_save, function()
        GUI:delayTouchEnabled(btn_act_save)
        local actPage = DamageNumSetting._selActPage
        local actParam = actPage == 1 and DamageNumSetting._ownActParam or DamageNumSetting._otherActParam
        if not next(DamageNumSetting._cloneCurActParam) then
            return
        end
        if not actParam[DamageNumSetting._selActCellIdx] then
            actParam[1] = DamageNumSetting._cloneCurActParam
            DamageNumSetting.onBtnActPage(DamageNumSetting._selActPage or 1)
        else
            actParam[DamageNumSetting._selActCellIdx] = DamageNumSetting._cloneCurActParam
        end
        SL:ShowSystemTips("当前动作已保存")
    end)

    -- 恢复动作
    local btn_act_reload = DamageNumSetting._ui["btn_act_reload"]
    GUI:addOnClickEvent(btn_act_reload, function()
        GUI:delayTouchEnabled(btn_act_reload)
        DamageNumSetting.onBtnActPage(DamageNumSetting._selActPage or 1, true)
        SL:ShowSystemTips("当前动作已恢复")
    end)

    -- 删除动作
    local btn_act_del = DamageNumSetting._ui["btn_act_del"]
    GUI:addOnClickEvent(btn_act_del, function()
        GUI:delayTouchEnabled(btn_act_del)
        local actPage = DamageNumSetting._selActPage
        local actParam = actPage == 1 and DamageNumSetting._ownActParam or DamageNumSetting._otherActParam
        for k, v in ipairs(actParam) do
            if k >= DamageNumSetting._selActCellIdx and k < #actParam then
                actParam[k] = actParam[k + 1]
            elseif k == #actParam then
                actParam[k] = nil
            end
        end
        DamageNumSetting.onBtnActPage(DamageNumSetting._selActPage or 1)
        SL:ShowSystemTips("动作已删除")
    end)

    -- 复制动作
    local btn_act_copy = DamageNumSetting._ui["btn_act_copy"]
    GUI:addOnClickEvent(btn_act_copy, function()
        GUI:delayTouchEnabled(btn_act_copy)
        local actPage = DamageNumSetting._selActPage
        local actParam = actPage == 1 and DamageNumSetting._ownActParam or DamageNumSetting._otherActParam
        table.insert(actParam, DamageNumSetting._cloneCurActParam)
        DamageNumSetting.onBtnActPage(DamageNumSetting._selActPage or 1, false, true)
        SL:ShowSystemTips("动作已复制")
    end)

    -- 记录位置
    local btn_pos_save = DamageNumSetting._ui["btn_pos_save"]
    GUI:addOnClickEvent(btn_pos_save, function()
        GUI:delayTouchEnabled(btn_pos_save)
        if not next(DamageNumSetting._cloneCurActParam) then
            return
        end
        if not DamageNumSetting._actOffsetParam[DamageNumSetting._selActCellIdx] then
            DamageNumSetting._actOffsetParam[1] = DamageNumSetting._cloneCurActParam
            DamageNumSetting.onBtnActPage(DamageNumSetting._selActPage or 1)
        else
            DamageNumSetting._actOffsetParam[DamageNumSetting._selActCellIdx] = DamageNumSetting._cloneCurActParam
        end
        SL:ShowSystemTips("当前位置已保存")
    end)

    -- 恢复位置
    local btn_pos_reload = DamageNumSetting._ui["btn_pos_reload"]
    GUI:addOnClickEvent(btn_pos_reload, function()
        GUI:delayTouchEnabled(btn_pos_reload)
        DamageNumSetting.onBtnActPage(DamageNumSetting._selActPage or 1, true)
        SL:ShowSystemTips("当前位置已恢复")
    end)

    -- 删除位置
    local btn_pos_del = DamageNumSetting._ui["btn_pos_del"]
    GUI:addOnClickEvent(btn_pos_del, function()
        GUI:delayTouchEnabled(btn_pos_del)
        local actParam = DamageNumSetting._actOffsetParam
        for k, v in ipairs(actParam) do
            if k >= DamageNumSetting._selActCellIdx and k < #actParam then
                actParam[k] = actParam[k + 1]
            elseif k == #actParam then
                actParam[k] = nil
            end
        end
        DamageNumSetting.onBtnActPage(DamageNumSetting._selActPage or 1)
        SL:ShowSystemTips("位置已删除")
    end)

    -- 复制位置
    local btn_pos_copy = DamageNumSetting._ui["btn_pos_copy"]
    GUI:addOnClickEvent(btn_pos_copy, function()
        GUI:delayTouchEnabled(btn_pos_copy)
        table.insert(DamageNumSetting._actOffsetParam, DamageNumSetting._cloneCurActParam)
        DamageNumSetting.onBtnActPage(DamageNumSetting._selActPage or 1, false, true)
        SL:ShowSystemTips("位置已复制")
    end)

    -- 选择文件
    local btn_res = DamageNumSetting._ui["btn_res"]
    GUI:addOnClickEvent(btn_res, function()
        local function callFunc(res)
            if not res or res == "" then
                return
            end

            if not string.find(res, _pathRes) then
                return
            end

            DamageNumSetting.updateResContent(res)

            DamageNumSetting.ThrowAction()
        end

        local resPath = (DamageNumSetting._resPath and DamageNumSetting._resPath ~= "") and DamageNumSetting._resPath or _pathRes .. "word_bjwz_01.png"
        global.Facade:sendNotification(global.NoticeTable.Layer_GUIResSelector_Open, { res = resPath, callfunc = callFunc })
    end)
    DamageNumSetting._Text_res_name = DamageNumSetting._ui["Text_res_name"]

    -- 资源配置区域，放一个练功师
    local animNode = GUI:Effect_Create(DamageNumSetting._Layout_show, "animNode", new_pos.x, new_pos.y, 2, 72, 0, 0, 4)

    -- 练功师脚底基准点
    local standPointRoot = cc.DrawNode:create()
    DamageNumSetting._Layout_show:addChild(standPointRoot, 99)
    standPointRoot:drawDot(original_pos, 4, cc.Color4F.RED)

    -- 基准点
    local textStand = GUI:Text_Create(DamageNumSetting._Layout_show, "textStand", 95, 10, 14, "#FF0000", "基准点→")
    GUI:setAnchorPoint(textStand, 1, 0.5)
end

function DamageNumSetting.setTypeState()
    for i = 1, 4 do 
        local ui_sel = GUI:getChildByName(DamageNumSetting._ui["Layout_type"..i], "img_sel")
        local ui_unsel = GUI:getChildByName(DamageNumSetting._ui["Layout_type"..i], "img_unsel")

        GUI:setVisible(ui_sel, DamageNumSetting._type == i)
        GUI:setVisible(ui_unsel, not (DamageNumSetting._type == i))
    end 

    -- 单图片时文字长度不可用
    local isSelImg = DamageNumSetting._type ~= 1 and DamageNumSetting._type ~= 4
    GUI:setVisible(DamageNumSetting._Layout_prefixLenMask, isSelImg)
    GUI:TextInput_setString(DamageNumSetting._input_prefixLen, isSelImg and "" or DamageNumSetting._prefixLen or "")

    GUI:setVisible(DamageNumSetting._ui.bg_input_aftherfixLen, DamageNumSetting._type == 4)
    GUI:setVisible(DamageNumSetting._ui.btn_help_aftherfixLen, DamageNumSetting._type == 4)

    -- 没有文字前缀 type == 3 不可用
    -- GUI:setVisible(DamageNumSetting._ui["Layout_type3"], DamageNumSetting._curCfg.prefix == ":;<=/")
end

function DamageNumSetting.pageTo(index)
    if DamageNumSetting._HurtTipsLayer then
        GUI:removeFromParent(DamageNumSetting._HurtTipsLayer)
        DamageNumSetting._HurtTipsLayer = nil
    end
    
    DamageNumSetting._index = index

    local cfgSel = DamageNumSetting._configWithId[DamageNumSetting._index]

    for _, uiPage in pairs(DamageNumSetting._pages) do
        local param = GUI:Win_GetParam(uiPage)
        local isSel = param.id == cfgSel.id and true or false
        GUI:Layout_setBackGroundColor(uiPage, isSel and "#ffbf6b" or "#000000")
    end

    DamageNumSetting.updateContent()
end

function DamageNumSetting.updateContent()
    local curCfg = DamageNumSetting._configWithId[DamageNumSetting._index]
    if not curCfg then
        return
    end

    -- dump(curCfg, "curCfg:::")

    DamageNumSetting.initData()

    DamageNumSetting._curCfg = curCfg

    -- 开关
    DamageNumSetting._enable = tonumber(curCfg.enable or 1) == 1
    setSwitchCellStatus(DamageNumSetting._switch_enable, DamageNumSetting._enable)

    -- 标题 name
    DamageNumSetting._name = curCfg.name or ""
    GUI:TextInput_setString(DamageNumSetting._input_name, DamageNumSetting._name)

    -- 飘字ID
    DamageNumSetting._id = curCfg.id or ""
    GUI:TextInput_setString(DamageNumSetting._input_id, DamageNumSetting._id)

    -- zOrder
    DamageNumSetting._zOrder = curCfg.zOrder or ""
    GUI:TextInput_setString(DamageNumSetting._input_zOrder, DamageNumSetting._zOrder)

    -- 震屏开关
    DamageNumSetting._shake = (tonumber(curCfg.shake) or 0) == 1
    setSwitchCellStatus(DamageNumSetting._switch_shake, DamageNumSetting._shake)

    -- 低血警示
    DamageNumSetting._hpWarning = (tonumber(curCfg.damage_type) or 0) == 1
    setSwitchCellStatus(DamageNumSetting._switch_hpWarning, DamageNumSetting._hpWarning)

    -- 特效显示
    DamageNumSetting._sfxId = curCfg.animID
    GUI:TextInput_setString(DamageNumSetting._input_sfx, DamageNumSetting._sfxId or "")

    -- 图片宽
    DamageNumSetting._width = curCfg.width
    GUI:TextInput_setString(DamageNumSetting._input_imgW, DamageNumSetting._width or "")

    -- 图片高
    DamageNumSetting._height = curCfg.height
    GUI:TextInput_setString(DamageNumSetting._input_imgH, DamageNumSetting._height or "")

    -- 飘字类型
    DamageNumSetting._type = curCfg.type or 1
    DamageNumSetting.setTypeState()

    -- 前缀 为了方便玩家理解，起始字符“/”不计入长度内，保存时再加上
    if DamageNumSetting._type == 1 or DamageNumSetting._type == 4 then
        local prefix = curCfg.prefix or ""
        if string.len(prefix) > 0 then
            DamageNumSetting._prefixLen = string.len(prefix) - 1
        else
            DamageNumSetting._prefixLen = 0
        end
        GUI:TextInput_setString(DamageNumSetting._input_prefixLen, DamageNumSetting._prefixLen)
        
        local afterfix = curCfg.afterfix or ""
        if string.len(afterfix) > 0 then
            DamageNumSetting._aftherfixLen = string.len(afterfix)
        else
            DamageNumSetting._aftherfixLen = 0
        end
        GUI:TextInput_setString(DamageNumSetting._input_aftherfixLen, DamageNumSetting._aftherfixLen)
    else
        DamageNumSetting._prefixLen = nil
    end

    DamageNumSetting._ownActParam = parseAllStepParam(curCfg.own_param)
    DamageNumSetting._otherActParam = parseAllStepParam(curCfg.other_param)
    DamageNumSetting._actOffsetParam = parseOffsetParam(curCfg.offset_param)

    local resPath = curCfg.res and _pathRes .. curCfg.res or ""
    DamageNumSetting._resPath = resPath

    DamageNumSetting.onBtnActPage(DamageNumSetting._selActPage or 1)

    DamageNumSetting.updateResContent(resPath)
end

-- Tips
local pageTips = {
    "配置主玩家飘血动画",
    "配置网络玩家飘血动画",
    "配置飘血位置，多个位置时轮询位置，防止飘血过快导致重叠",
}

function DamageNumSetting.onBtnActPage(index, isReload, isCopy)
    DamageNumSetting._selActPage = index

    local worldPos = GUI:p(GUI:getWorldPosition(DamageNumSetting._ui["act_page" .. DamageNumSetting._selActPage]))
    SL:SHOW_DESCTIP(pageTips[DamageNumSetting._selActPage], nil, {x = worldPos.x + 67, y = worldPos.y + 2}, {x = 0.5, y = 0}, 1)

    for i = 1, 3 do
        local btnActPage = DamageNumSetting._ui["act_page" .. i]
        GUI:Layout_setBackGroundColor(btnActPage, DamageNumSetting._selActPage == i and "#ffbf6b" or "#000000")
    end

    DamageNumSetting.updateActContent(isReload, isCopy)
end

-- 飘字起始位置:
-- 锚点为(0, 0), 位置在(0, 60)，缩放为1，透明度为1，无需等待即可进入“动作1”
-- 第1个动作:
-- 锚点为(0, 0), 在0.3秒,X坐标偏移:0, Y坐标偏移:100，同时缩放到1，透明度设置到1，需等待1秒进入下一个动作
local function getActTips(idx, param)
    if not idx or not param or not next(param) then
        return ""
    end

    -- dump(param)

    local strAchor, strPos, strScale, strOpacity, strDelay = nil, "", "", "", nil
    local actTime = 0
    for k, v in ipairs(param) do
        if v.type == PARAM_TYPE.TIME_PARAM then
            actTime = v.value

        elseif v.type == PARAM_TYPE.ANCHOR_PARAM then
            strAchor = string.format("锚点为(%s, %s)，", v.x, v.y)

        elseif v.type == PARAM_TYPE.MOVEBY_ACTION then
            if idx == 1 then
                strPos = string.format("位置为(%s, %s)，", v.x or 0, v.y or 0)
            else
                strPos = string.format("X坐标偏移:%s， Y坐标偏移:%s，", v.x or 0, v.y or 0)
            end
            
        elseif v.type == PARAM_TYPE.SCALETO_ACTION then
            if idx == 1 then
                strScale = string.format("缩放为%s，", v.value)
            else
                strScale = string.format("缩放到%s，", v.value)
            end

        elseif v.type == PARAM_TYPE.FADETO_ACTION then
            if idx == 1 then
                strOpacity = string.format("透明度为%s，", v.value)
            else
                strOpacity = string.format("透明度设置为%s，", v.value)
            end

        elseif v.type == PARAM_TYPE.DELAY_ACTION then
            strDelay = string.format("需要等待%s秒", v.value)
        end
    end

    local retStr = ""
    if idx == 1 then
        strAchor = strAchor or "锚点为(0, 0)，"
        strDelay = (strDelay or "无需等待即可") .. "进入\"动作1\""
        retStr = string.format("飘字起始位置:\\%s%s%s%s%s", strAchor, strPos, strScale, strOpacity, strDelay)
    else
        local strTime = string.format("在%s秒时间内，", actTime)
        strDelay = (strDelay or "无需等待即可") .. "进入下一个动作"
        retStr = string.format("第%d个动作:\\%s%s%s%s%s%s%s", idx - 1, strAchor or "", strTime, strPos, strPos == "" and "" or "同时", strScale, strOpacity, strDelay)        
    end

    -- print(retStr)

    return retStr
end

function DamageNumSetting.updateActContent(isReload, isCopy)
    GUI:setVisible(DamageNumSetting._ui["Layout_action1"], DamageNumSetting._selActPage <= 2)
    GUI:setVisible(DamageNumSetting._ui["Layout_action2"], DamageNumSetting._selActPage == 3)

    if not DamageNumSetting._curCfg then
        return
    end

    local tParam = nil
    if DamageNumSetting._selActPage == 1 then
        tParam = DamageNumSetting._ownActParam
    elseif DamageNumSetting._selActPage == 2 then
        tParam = DamageNumSetting._otherActParam
    elseif DamageNumSetting._selActPage == 3 then
        tParam = DamageNumSetting._actOffsetParam
    end
    if not tParam then
        return
    end

    -- SL:Dump(tParam, "all steps actions")

    GUI:ListView_removeAllItems(DamageNumSetting._lv_action)
    if not tParam or not next(tParam) then
        DamageNumSetting._cloneCurActParam = {}
        DamageNumSetting.resetActInputs()
        if DamageNumSetting._testSchedule then
            SL:UnSchedule(DamageNumSetting._testSchedule)
            DamageNumSetting._testSchedule = nil
        end
        return
    end

    DamageNumSetting._selActCellIdx = DamageNumSetting._selActCellIdx or 1
    if isReload then
        DamageNumSetting._selActCellIdx = DamageNumSetting._selActCellIdx
    elseif isCopy then
        local actParam = {}
        local actPage = DamageNumSetting._selActPage
        if actPage == 1 then
            actParam = DamageNumSetting._ownActParam
        elseif actPage == 2 then
            actParam = DamageNumSetting._otherActParam
        elseif actPage == 3 then
            actParam = DamageNumSetting._actOffsetParam
        end
        DamageNumSetting._selActCellIdx = #actParam
    else
        DamageNumSetting._selActCellIdx = 1
    end

    local selPage = DamageNumSetting._selActPage

    for k, v in ipairs(tParam) do
        local actCell = GUI:Layout_Create(DamageNumSetting._lv_action, "actCell" .. k, 0, 0, 76, 30, false)
        GUI:Layout_setBackGroundColorType(actCell, 1)
        GUI:Layout_setBackGroundColor(actCell, "#000000")
        GUI:Layout_setBackGroundColorOpacity(actCell, 255)
        GUI:setTouchEnabled(actCell, true)

        local name = k == 1 and "起始位置" or "动作" .. (k > 1 and k - 1)
        if DamageNumSetting._selActPage == 3 then
            name = "位置" .. k
        end
        local PageText = GUI:Text_Create(actCell, "PageText", 38, 15, 14, "#ffffff", name)
        GUI:setAnchorPoint(PageText, 0.5, 0.5)
        GUI:Text_setTextHorizontalAlignment(PageText, 1)
        GUI:Text_enableOutline(PageText, "#000000", 1)

        GUI:addOnClickEvent(actCell, function()
            DamageNumSetting.onSelActCell(k)
            
            local actPage = DamageNumSetting._selActPage
            local actParam = actPage == 1 and DamageNumSetting._ownActParam or DamageNumSetting._otherActParam
            local curParam = actParam[k]
            local showTips = actPage <= 2 and getActTips(k, curParam) or ""
            if showTips ~= "" then
                local worldPos = GUI:p(GUI:getWorldPosition(actCell))
                SL:SHOW_DESCTIP(showTips, 320, {x = worldPos.x + 80, y = worldPos.y + 30}, {x = 0, y = 1}, 1)
            end
        end)
    end

    DamageNumSetting.onSelActCell(DamageNumSetting._selActCellIdx)
end

function DamageNumSetting.onSelActCell(selActCellIdx)
    for k, v in pairs(tActInput) do
        v.oldValue = nil
    end

    DamageNumSetting._selActCellIdx = selActCellIdx
    DamageNumSetting._cloneCurActParam = {}

    for k, v in ipairs(GUI:ListView_getItems(DamageNumSetting._lv_action)) do
        local isSel = DamageNumSetting._selActCellIdx == k and true or false
        GUI:Layout_setBackGroundColor(v, isSel and "#ffbf6b" or "#000000")
        if isSel then
            DamageNumSetting.resetActInputs()
            if DamageNumSetting._selActPage <= 2 then
                local actPage = DamageNumSetting._selActPage
                local actParam = actPage == 1 and DamageNumSetting._ownActParam or DamageNumSetting._otherActParam
                local curParam = actParam[k]
                DamageNumSetting._cloneCurActParam = clone(curParam)
                DamageNumSetting.updateActParamContent(curParam)
            else
                local actParam = DamageNumSetting._actOffsetParam
                local curParam = actParam[k]
                DamageNumSetting._cloneCurActParam = clone(curParam)
                DamageNumSetting.updatePosParamContent(curParam)
            end
        end
    end
end

local actInputs = {
    "input_time",
    { x = "input_anchorX", y = "input_anchorY",},
    { x = "input_offsetX", y = "input_offsetY",},
    "input_scale",
    "input_opacity",
    "input_waitting",
}

function DamageNumSetting.updateActParamContent(param)
    -- dump(param, "updateActParamContent:::")

    for k, v in ipairs(actInputs) do
        local data = nil
        for _, p in ipairs(param) do
            if p.type == k then
                data = p
                break
            end
        end
        if type(v) == "string" then
            local value = data and data.value
            GUI:TextInput_setString(DamageNumSetting._ui[v], value or "")
        else
            if k == 2 or k == 3 then
                local valueX = data and data.x
                GUI:TextInput_setString(DamageNumSetting._ui[v.x], valueX or "")

                local valueY = data and data.y
                GUI:TextInput_setString(DamageNumSetting._ui[v.y], valueY or "")
            end
        end
    end

    DamageNumSetting.ThrowAction()
end

function DamageNumSetting.resetActInputs()
    for _, actInput in ipairs(actInputs) do
        if type(actInput) == "table" then
            GUI:TextInput_setString(DamageNumSetting._ui[actInput.x], "")
            GUI:TextInput_setString(DamageNumSetting._ui[actInput.y], "")
        else
            GUI:TextInput_setString(DamageNumSetting._ui[actInput], "")
        end
    end

    GUI:TextInput_setString(DamageNumSetting._ui["inputX"], "")
    GUI:TextInput_setString(DamageNumSetting._ui["inputY"], "")
end

function DamageNumSetting.updatePosParamContent(param)
    -- dump(param, "updatePosParamContent:::")

    local valueX = param.x
    GUI:TextInput_setString(DamageNumSetting._ui["inputX"], valueX or "")

    local valueY = param.y
    GUI:TextInput_setString(DamageNumSetting._ui["inputY"], valueY or "")

    DamageNumSetting.ThrowAction()
end

function DamageNumSetting.updateResContent(res)
    DamageNumSetting._resPath = res
    GUI:Text_setString(DamageNumSetting._Text_res_name, "未选择文件")
    GUI:setVisible(DamageNumSetting._img_res, false)
    if not res or res == "" then
        return
    end

    GUI:Text_setString(DamageNumSetting._Text_res_name, string.gsub(res, _pathRes, ""))
    GUI:setVisible(DamageNumSetting._img_res, true)
    GUI:Image_loadTexture(DamageNumSetting._img_res, res)
end

local function throw(actType, actParam, offsetParam)
    if actType == 1 then
        DamageNumSetting.ThrowDamageNum(actParam, offsetParam)
    elseif actType == 2 then
        DamageNumSetting.ThrowSprite(actParam, offsetParam)
    elseif actType == 3 then
        DamageNumSetting.ThrowDamageText(actParam, offsetParam)
    elseif actType == 4 then
        DamageNumSetting.ThrowDamageNumPoint(actParam, offsetParam)
    end
end

function DamageNumSetting.ThrowAction()
    if not DamageNumSetting._selActCellIdx then
        return
    end

    if DamageNumSetting._testSchedule then
        SL:UnSchedule(DamageNumSetting._testSchedule)
        DamageNumSetting._testSchedule = nil
    end

    -- 重组数据
    local actParam = {}
    local offsetParam = clone(DamageNumSetting._actOffsetParam)
    local actPage = DamageNumSetting._selActPage
    if actPage == 1 then
        actParam = clone(DamageNumSetting._ownActParam)
        actParam[DamageNumSetting._selActCellIdx] = DamageNumSetting._cloneCurActParam
        DamageNumSetting._testSchedule = SL:Schedule(function()
            throw(DamageNumSetting._type, actParam, offsetParam)
        end, 0.2)
    elseif actPage == 2 then
        actParam = clone(DamageNumSetting._otherActParam)
        actParam[DamageNumSetting._selActCellIdx] = DamageNumSetting._cloneCurActParam
        DamageNumSetting._testSchedule = SL:Schedule(function()
            throw(DamageNumSetting._type, actParam, offsetParam)
        end, 0.2)
    elseif actPage == 3 then
        actParam = clone(DamageNumSetting._ownActParam)
        offsetParam[DamageNumSetting._selActCellIdx] = DamageNumSetting._cloneCurActParam
        for i = 1, #offsetParam do
            throw(DamageNumSetting._type, actParam, offsetParam)
        end
    end

    -- 特效
    if tonumber(DamageNumSetting._sfxId) then
        GUI:removeChildByName(DamageNumSetting._Layout_show, "EFFECT")
        local sfx = GUI:Effect_Create(DamageNumSetting._Layout_show, "EFFECT", new_pos.x, new_pos.y, 0, tonumber(DamageNumSetting._sfxId))
        if sfx then
            GUI:Effect_addOnCompleteEvent(sfx, function ()
                GUI:removeFromParent(sfx)
            end)
        end
    end
end

-------------------------------------------run action--------------------------------------------------
function DamageNumSetting.createLabel(cfg)
    if not cfg.res or cfg.res == "" then
        SL:ShowSystemTips("请在右下方资源配置区选择飘字文件")
        return nil
    end

    if not cfg.width or not cfg.height then
        SL:ShowSystemTips("请在图片尺寸区配置飘字宽度和高度")
        return nil
    end

    local displayNode = nil
    local cache = DamageNumSetting._labelCache
    if cache:empty() then
        displayNode = ccui.TextAtlas:create()
    else
        displayNode = cache:pop()
        displayNode:autorelease()
    end

    if displayNode then
        displayNode:setProperty("", cfg.res, cfg.width, cfg.height, "/")
        GUI:setAnchorPoint(displayNode, 0, 0)
    end

    return displayNode
end

function DamageNumSetting.createSprite(cfg)
    if not cfg.res or cfg.res == "" then
        return nil
    end

    if not global.FileUtilCtl:isFileExist(cfg.res) then
        return nil
    end

    local displayNode = nil
    local cache = DamageNumSetting._spriteCache
    if cache:empty() then
        displayNode = cc.Sprite:create()
    else
        displayNode = cache:pop()
        displayNode:autorelease()
    end

    if displayNode then
        local tex = global.TextureCache:addImage(cfg.res)
        if tex then
            displayNode:initWithTexture(tex)
        end
        GUI:setAnchorPoint(displayNode, 0, 0)
    end

    return displayNode
end

function DamageNumSetting.ThrowDamageNum(actParam, offsetParam)
    -- 1.create node
    local config = {}
    config.res = DamageNumSetting._resPath
    config.width = DamageNumSetting._width
    config.height = DamageNumSetting._height
    local displayNode = DamageNumSetting.createLabel(config)
    if not displayNode then
        return nil
    end

    -- 2.setting node
    local prefix = getPrefix(DamageNumSetting._prefixLen or 0) or ""

    GUI:TextAtlas_setString(displayNode, prefix .. test_num)
    GUI:setPosition(displayNode, original_pos.x, original_pos.y)
    GUI:setLocalZOrder(displayNode, tonumber(DamageNumSetting._zOrder) or 0)
    GUI:addChild(DamageNumSetting._Layout_show, displayNode)

    -- 3.offset
    local offset = DamageNumSetting.traceOffset(DamageNumSetting._index, displayNode, offsetParam)

    -- 4.create animation
    DamageNumSetting.createActions(DamageNumSetting._index, displayNode, actParam, 1, offset)
end

function DamageNumSetting.ThrowSprite(actParam, offsetParam)
    -- 1.create node
    local config = {}
    config.res = DamageNumSetting._resPath
    local displayNode = DamageNumSetting.createSprite(config)
    if not displayNode then
        return nil
    end

    -- 2.setting node
    GUI:setPosition(displayNode, original_pos.x, original_pos.y)
    GUI:setLocalZOrder(displayNode, tonumber(DamageNumSetting._zOrder) or 0)
    GUI:addChild(DamageNumSetting._Layout_show, displayNode)

    -- 3.offset
    local offset = DamageNumSetting.traceOffset(DamageNumSetting._index, displayNode, offsetParam)

    -- 4.create animation
    DamageNumSetting.createActions(DamageNumSetting._index, displayNode, actParam, 1, offset)
end

function DamageNumSetting.ThrowDamageText(actParam, offsetParam)
    -- 1.create node
    local config = {}
    config.res = DamageNumSetting._resPath
    config.width = DamageNumSetting._width
    config.height = DamageNumSetting._height
    local displayNode = DamageNumSetting.createLabel(config)
    if not displayNode then
        return nil
    end

    local config = DamageNumSetting._curCfg
    if config then 
        if config.prefix ~= ":;<=/" then 
            return 
        end 
    end 

    -- 2.setting node
    GUI:TextAtlas_setString(displayNode, ":;<=")
    GUI:setPosition(displayNode, original_pos.x, original_pos.y)
    GUI:setLocalZOrder(displayNode, tonumber(DamageNumSetting._zOrder) or 0)
    GUI:addChild(DamageNumSetting._Layout_show, displayNode)

    -- 3.offset
    local offset = DamageNumSetting.traceOffset(DamageNumSetting._index, displayNode, offsetParam)

    -- 4.create animation
    DamageNumSetting.createActions(DamageNumSetting._index, displayNode, actParam, 1, offset)
end

function DamageNumSetting.ThrowDamageNumPoint(actParam, offsetParam)
    -- 1.create node
    local config = {}
    config.res = DamageNumSetting._resPath
    config.width = DamageNumSetting._width
    config.height = DamageNumSetting._height
    local displayNode = DamageNumSetting.createLabel(config)
    if not displayNode then
        return nil
    end

    -- 2.setting node
    local prefixLen     = DamageNumSetting._prefixLen or 0
    local afterfix      = getAftherfix((tonumber(DamageNumSetting._aftherfixLen) or 9) + prefixLen, prefixLen+1) or ""
    local prefix        = getPrefix((DamageNumSetting._prefixLen or 0)) or ""

    local originNum = tostring(test_num)
    local charLen = string.len(originNum)
    local charStr = ""
    local sampNum = ""
    local poinNum = ""
    local unit    = 1
    if charLen >= 17 then
        unit = 10000000000000000
        charStr = string.sub(afterfix, 8, 9)
        sampNum = string.sub(originNum, 1, charLen - 16)
        poinNum = string.sub(originNum, charLen - 15, charLen)
    elseif charLen >= 13 then
        unit = 1000000000000
        charStr = string.sub(afterfix, 6, 7)
        sampNum = string.sub(originNum, 1, charLen - 12)
        poinNum = string.sub(originNum, charLen - 11, charLen)
    elseif charLen >= 9 then
        unit = 100000000
        charStr = string.sub(afterfix, 4, 5)
        sampNum = string.sub(originNum, 1, charLen - 8)
        poinNum = string.sub(originNum, charLen - 7, charLen)
    elseif charLen >= 5 then
        unit = 10000
        charStr = string.sub(afterfix, 2, 3)
        sampNum = string.sub(originNum, 1, charLen - 4)
        poinNum = string.sub(originNum, charLen - 3, charLen)
    else
        sampNum = originNum
    end

    local unitFunc = function(num)
        local pointBit = 2
        if pointBit == 0 then
            return math.floor(num)
        end
        local iNum, fNum = math.modf(num)
        local fDecimal = math.pow(10, tostring(pointBit))
        local newFNum = math.floor(tostring(fNum * fDecimal))
        local newINum = iNum + (newFNum / fDecimal)
        return newINum
    end

    poinNum = tonumber(poinNum)
    if poinNum and poinNum > 0 then
        poinNum = unitFunc(poinNum/unit)
        if tonumber(sampNum) then
            poinNum = poinNum + tonumber(sampNum)
        end
        sampNum = ""
        poinNum = string.gsub(poinNum.."", "%." , string.sub(afterfix, 1, 1))
    else
        poinNum = ""
    end

    GUI:TextAtlas_setString(displayNode, prefix .. sampNum .. poinNum .. charStr)
    GUI:setPosition(displayNode, original_pos.x, original_pos.y)
    GUI:setLocalZOrder(displayNode, tonumber(DamageNumSetting._zOrder) or 0)
    GUI:addChild(DamageNumSetting._Layout_show, displayNode)

    -- 3.offset
    local offset = DamageNumSetting.traceOffset(DamageNumSetting._index, displayNode, offsetParam)

    -- 4.create animation
    DamageNumSetting.createActions(DamageNumSetting._index, displayNode, actParam, 1, offset)
end

local function _createActionToTable(node, action_table, action_param, speed, isInit, offset)
    if not action_param then
        return false
    end
    local action_type = action_param.type

    local action = nil
    local action_time = action_param.duration or 0.2
    action_time = action_time * speed
    if action_type == PARAM_TYPE.MOVEBY_ACTION then
        local value = cc.p(action_param.x or 0, action_param.y or 0)
        if isInit and action_time <= 0 then
            node:setPositionX(node:getPositionX() + value.x + offset.x)
            node:setPositionY(node:getPositionY() + value.y + offset.y)
        else
            action = cc.MoveBy:create(action_time, value)
        end
    elseif action_type == PARAM_TYPE.SCALETO_ACTION then
        local value = action_param.value or 1
        if isInit and action_time <= 0 then
            node:setScale(value)
        else
            action = cc.ScaleTo:create(action_time, value, value)
        end
    elseif action_type == PARAM_TYPE.FADETO_ACTION then
        local value = (action_param.value or 1) * 255
        if isInit and action_time <= 0 then
            node:setOpacity(value)
        else
            action = cc.FadeTo:create(action_time, value)
        end
    elseif action_type == PARAM_TYPE.DELAY_ACTION then
        local value = action_param.value or 0.2
        action = cc.DelayTime:create(value * speed)
    elseif action_type == PARAM_TYPE.ANCHOR_PARAM then
        local value = cc.p(action_param.x or 0, action_param.y or 0)
        if isInit then
            node:setAnchorPoint(value)
        else
            local function setAnchor()
                node:setAnchorPoint(value)
            end
            action = cc.CallFunc:create(setAnchor)
        end
    end

    if action then
        action_table[#action_table + 1] = action
    end
end

function DamageNumSetting.createActions(type, node, actionsDatas, speed, offset)
    if nil == offset then
        offset = { x = 0, y = 0 }
    end

    local all_actions = {}
    for i, actionsData in ipairs(actionsDatas) do
        local step_actions = {}
        for _, actionData in ipairs(actionsData) do
            _createActionToTable(node, step_actions, actionData, speed, 1 == i, offset)
        end

        if #step_actions > 0 then
            all_actions[#all_actions + 1] = cc.Spawn:create(step_actions)
        end
    end

    -- 回收阶段
    local function callback()
        DamageNumSetting.onAnimationEnd(type, node)
    end
    all_actions[#all_actions + 1] = cc.CallFunc:create(callback)

    if #all_actions > 0 then
        local action = cc.Sequence:create(all_actions)
        node:runAction(action)
    end
end

function DamageNumSetting.onAnimationEnd(type, targetNode)
    targetNode:setScale(1)
    targetNode:setOpacity(255)
    targetNode:stopAllActions()
    targetNode:retain()
    targetNode:removeFromParent()

    -- push to cache
    if iskindof(targetNode, "ccui.TextAtlas") then
        DamageNumSetting._labelCache:push(targetNode)
    else
        DamageNumSetting._spriteCache:push(targetNode)
    end

    DamageNumSetting.unTraceOffset(type, targetNode)
end

function DamageNumSetting.traceOffset(type, node, offsetParams)
    if not offsetParams or #offsetParams <= 0 then
        return { x = 0, y = 0 }
    end

    local offsetData = DamageNumSetting._offsetDatas[type]
    if not offsetData then
        offsetData = {
            ref = 0,
            freeIndex = 1,
            indexes = {}
        }
        DamageNumSetting._offsetDatas[type] = offsetData
    end


    offsetData.ref = offsetData.ref + 1
    offsetData.indexes[offsetData.freeIndex] = true
    node.idx = offsetData.freeIndex

    local offsetCount = #offsetParams
    if offsetData.ref >= offsetCount then
        offsetData.freeIndex = (offsetData.ref % offsetCount) + 1
    else
        for i = offsetData.freeIndex, offsetCount do
            if not offsetData.indexes[i] then
                offsetData.freeIndex = i
                break
            end
        end
    end

    local retPos = offsetParams[node.idx]
    retPos.x = retPos.x or 0
    retPos.y = retPos.y or 0

    return retPos
end

function DamageNumSetting.unTraceOffset(type, node)
    local offsetData = DamageNumSetting._offsetDatas[type]
    if offsetData then
        offsetData.ref = offsetData.ref - 1
        if node.idx then
            if node.idx < offsetData.freeIndex then
                offsetData.freeIndex = node.idx
            end

            offsetData.indexes[node.idx] = false
            node.idx = nil
        end
    end
end
-----------------------------------------run action end------------------------------------------------

function DamageNumSetting.close()
    print("DamageNumSetting.close")

    releaseCache(DamageNumSetting._labelCache)
    releaseCache(DamageNumSetting._spriteCache)

    if DamageNumSetting._testSchedule then
        SL:UnSchedule(DamageNumSetting._testSchedule)
        DamageNumSetting._testSchedule = nil
    end
end

return DamageNumSetting