local PreviewSkillLayout = class("PreviewSkillLayout", function()
    return cc.Node:create()
end)

local QuickCell = requireUtil("QuickCell")

local MODELS = {
    [1] = {
        model = global.MMO.SFANIM_TYPE_PLAYER,
        name = "人物",
        inputID = 9999
    },
    [2] = {
        model = global.MMO.SFANIM_TYPE_MONSTER,
        name = "怪物",
        inputID = 9999
    }
}

local ACTIONS = {
    [1] = {
        action = global.MMO.ACTION_ATTACK,
        name = "平砍",
        speed = 1000,
    },
    [2] = {
        action = global.MMO.ACTION_SKILL,
        name = "施法",
        speed = 1000,
    }
}

local SHOW_ZORDER= {
    [1] = {id=0,name="上层"},
    [2] = {id=1,name="下层"},
}


-- 表相关的可以修改的key
local keys = {{
    key = "id",
    onlyInt = true,
    desc = "技能表现ID",
    isInput = true,
    nodeName="TextField_id"
}, {
    key = "name",
    desc = "技能表现名",
    isInput = true,
    nodeName="TextField_name"
}, {
    key = "launchID",
    default = -1,
    onlyInt = true,
    isInputUpdate = true,
    desc = "施法特效ID",
    isInput = true,
    nodeName="TextField_launch_sfx"
}, {
    key = "launchDir",
    default = 8,
    onlyInt = true,
    isInput = true,
    desc = "施法特效方向",
    nodeName="TextField_launch_dir"
}, {
    key = "delaytime",
    default = 0,
    onlyInt = true,
    isInput = true,
    desc = "施法特效延迟时间(单位: 毫秒)",
    nodeName = "TextField_launch_dealy"
}, {
    key = "flyID",
    default = -1,
    onlyInt = true,
    isInput = true,
    isInputUpdate = true,
    desc = "飞行特效ID",
    nodeName = "TextField_fly_sfx"
}, {
    key = "flyDir",
    default = 8,
    onlyInt = true,
    isInput = true,
    desc = "飞行特效方向",
    nodeName="TextField_fly_dir"
}, {
    key = "flyDelayTime",
    default = 0,
    onlyInt = true,
    isInput = true,
    desc = "飞行特效延迟时间(单位: 毫秒)",
    nodeName = "TextField_fly_dealy"
}, {
    key = "flySpeed",
    default = 1500,
    onlyInt = true,
    isInput = true,
    desc="飞行特效速度时间(单位: 毫秒)",
    nodeName="TextField_fly_speed"
}, {
    key = "hitID",
    default = -1,
    onlyInt = true,
    isInput = true,
    isInputUpdate = true,
    desc="击中特效",
    nodeName="TextField_hit_sfx"
}, {
    key = "hitDir",
    default = 8,
    onlyInt = true,
    isInput = true,
    desc="击中特效方向",
    nodeName="TextField_hit_dir"
}, {
    key = "hitDelayTime",
    default = 0,
    color = "#17c5bd",
    onlyInt = true,
    isInput = true,
    desc = "击中特效延迟时间(单位: 毫秒)",
    nodeName="TextField_hit_dealy"
}, {
    key = "linkSkill",
    onlyInt = true,
    isResetPreview=true,
    isInputUpdate = true,
    isCanNull = true,
    isInput = true,
    desc = "链接技能ID",
    nodeName = "TextField_link_id"
}, {
    key = "type",
    default = 0,
    onlyInt = true,
    desc = "表现类型 0:普通（施法.飞行.命中）；1：地狱火"
}, {
    key = "needTarget",
    default = 1,
    onlyInt = true,
    desc = "1.必须要目标,会追踪目标,无目标不会有飞行和命中特效 0.直接释放,不需要目标,根据坐标释放",
    isCheckBox=true,
    checkBoxValues = {[0]=false,[1]=true,[false]=0,[true]=1},  --0: false   1: true
    nodeName = "CheckBox_target"
}, {
    key = "skillgensui",
    default = 1,
    onlyInt = true,
    desc = "施法特效跟随人物移动",
    isCheckBox=true,                    --是否是checbox控件
    checkBoxValues = {[0]=false,[1]=true,[false]=0,[true]=1},  --0: false   1: true
    nodeName = "CheckBox_gensui"
}, {
    key = "pos",
    default = 0,
    onlyInt = true,
    desc = "施法/飞行特效层级，0在人上面，1在人下面",
    isSelect = true,                            --是否是多选控件
    selectValues=SHOW_ZORDER,
    nodeName="Panel_launch_fly_sfx_z"
}, -- 施法/飞行特效在人物前后
{
    key = "hitPos",
    default = 0,
    onlyInt = true,
    desc = "击中特效层级，0在人上面，1在人下面",
    isSelect = true,                            --是否是多选控件
    selectValues=SHOW_ZORDER,
    nodeName="Panel_hit_sfx_z"
} -- 击中特效在人物前后
}

local LAUNCH_EFFECT_GUI_ID = 1000
local FLY_LAUNCH_EFFECT_GUI_ID = 1001
local HIT_LAUNCH_EFFECT_GUI_ID = 1002

local PLAYER_DIR = global.MMO.ORIENT_L
local MONSTER1_DIR = global.MMO.ORIENT_R
local MONSTER2_DIR = global.MMO.ORIENT_RB

local effectOff = {
    [131] = {
        x = -25,
        y = 0
    }
}
local offsetys = {
    [13] = 1,
    [14] = 1,
    [15] = 1,
    [19] = 1,
    [38] = 1,
    [44] = 1,
    [63] = 1
} -- 13灵魂火符 14幽灵盾 15神圣战甲术 19集体隐身术  38诅咒术 44寒冰掌 85裂神符 63噬魂沼泽需要向上偏移

local dir1t8 = {
    [9] = true
}

local monsterDir = {global.MMO.ORIENT_R, global.MMO.ORIENT_RB}

function PreviewSkillLayout:ctor()
    self._config = {} -- 技能表现表数据
    self._selectID = nil -- 选中的技能表现ID
    self._markSelectID = nil -- 记录选择的技能表现ID
    self._markAddID = nil -- 标记新增的技能ID
    self._allNameStr = ""   --模糊搜索的名字格式 <name&id><name&id>

    self._select_action = global.MMO.ACTION_ATTACK -- 选中的动作
    self._select_model = 1 -- 人物：1， 怪物2
    self._select_model_id = 9999

    self._magic_spped = 1000
    self._attr_spped = 1000

    self._selects = {}              -- 多选的id
    self._selects_state = false     --是否是多选状态
end

function PreviewSkillLayout.create()
    local layout = PreviewSkillLayout.new()
    if layout and layout:Init() then
        return layout
    end
    return nil
end

--- 获取cfg_skill_present
---@param skillID integer 技能预览ID
function PreviewSkillLayout:GetPreviewSkillDataByID(skillID)
    return self._config[skillID]
end

--- 更新技能表现表的数据   缓存，未保存时不会改变表的数据
---@param skillID integer 技能表现ID
---@param key string  要改变的字段名
---@param value any 要改变的值
function PreviewSkillLayout:UpdatePreviewSkillData(skillID, key, value)
    if not skillID or not key then
        return
    end
    local cfg = self:GetPreviewSkillDataByID(skillID)
    if cfg then
        cfg[key] = value
    end
end

function PreviewSkillLayout:Init()
    self._root = CreateExport( "preview_skill/preview_skill" )
    if not self._root then
        return false
    end

    self:addChild(self._root)

    self._ui = ui_delegate(self._root)

    self._config = clone(requireGameConfig("cfg_skill_present"))

    self._ui.TextField_search = CreateEditBoxByTextField(self._ui.TextField_search)
    self._ui.TextField_search:setReturnType(2)
    self._ui.TextField_search:setInputMode(6)

    local markSkillStr = ""
    local blurT = {}            --模糊搜索表
    local searchIndex = 1
    local isNew = false
    self._ui.TextField_search:addEventListener(function(sender,eventType)
        if eventType == 3 then
            local inputStr = sender:getString()
            local skillID = tonumber(inputStr)
            if not skillID then
                if inputStr ~= markSkillStr then -- 进行获取检测数据  进行模糊搜索
                    markSkillStr = inputStr
                    blurT = self:GetBlurNames(inputStr) -- 名字
                    searchIndex = 1
                end
            else
                blurT[1] = skillID
            end
            self:OnSearchEvent(blurT,1)
        end
    end)

    -- 搜索按钮
    self._ui.Button_search:addClickEventListener(function()
        searchIndex = searchIndex + 1
        if searchIndex > #blurT then
            searchIndex = 1
        end
        self:OnSearchEvent(blurT,searchIndex)
    end)

    -- 新增
    self._ui.Button_new_add:addClickEventListener(function()
        self:OnNewAddEvent()
    end)

    -- 复制新增
    self._ui.Button_copy_add:addClickEventListener(function()
        self:OnCopyNewAddEvent()
    end)

    -- 多选
    self._ui.Button_selects:addClickEventListener(function()
        self:OnMultipleSlectEvent()
    end)

    -- 删除
    self._ui.Button_delete:addClickEventListener(function()
        self:OnDelectEvent()
    end)

    -- 关闭
    self._ui.Button_close:addClickEventListener(function()
        global.Facade:sendNotification( global.NoticeTable.PreviewSkillClose )
    end)

    -- 恢复
    self._ui.Button_recover:addClickEventListener(function()
        self:OnRecoverEvent()
    end)

    -- 保存
    self._ui.Button_save:addClickEventListener(function()
        self:OnSaveEvent()
    end)

    -- 人物/怪物选择
    self._ui.Panel_modle_type:addClickEventListener(function()
        self:OnModelSelectEvent()
    end)

    -- 动作选择
    self._ui.Panel_action_speed:addClickEventListener(function()
        self:OnActionSelectEvent()
    end)

    -- 人物/怪物ID输入
    self._ui.TextField_modle_id = CreateEditBoxByTextField(self._ui.TextField_modle_id)
    self._ui.TextField_modle_id:setReturnType(2)
    self._ui.TextField_modle_id:setInputMode(6)
    self._ui.TextField_modle_id:addEventListener(function(sender,eventType)
        if eventType == 3 then
            local modelID = tonumber(sender:getString())
            if not modelID then
                ShowSystemTips("输出的模型id非数字")
            end
            self:UpdateModelInput(modelID)
        end
    end)

    -- 速度输入
    self._ui.TextField_action_speed = CreateEditBoxByTextField(self._ui.TextField_action_speed)
    self._ui.TextField_action_speed:setReturnType(2)
    self._ui.TextField_action_speed:setInputMode(6)
    self._ui.TextField_action_speed:addEventListener(function(sender,eventType)
        if eventType == 3 then
            local speed = tonumber(GUI:TextInput_getString(sender))
            self:UpdateSpeedUI(speed)
        end
    end)

    local configParent = self._ui.Panel_config
    for i, v in pairs(keys) do
        self:UpdateConfigContorl(v,v.default)
        if v.nodeName then
            local widget = self._ui[v.nodeName]
            if widget then
                if v.isInput then
                    self._ui[v.nodeName] = CreateEditBoxByTextField(widget)
                    widget = self._ui[v.nodeName]
                    widget:setReturnType(2)
                    widget:setInputMode(6)
                    widget:addEventListener(function(sender,eventType)
                        if eventType == 3 then
                            self:OnConfigEvent(sender,v)
                        end
                    end)
                else
                    widget:addClickEventListener(function(sender)
                        self:OnConfigEvent(sender,v)
                    end)
                end
            end
        end
    end

    -- 添加动作层
    global.Facade:sendNotification(global.NoticeTable.Preview_Skill_Action_Attach, {parent=self._ui.Panel_model, config = self._config})

    local player = global.gamePlayerController:GetMainPlayer()
    if player then
        ACTIONS[1].speed = player:GetAttackStepTime() / player:GetAttackSpeed() / 0.001
        ACTIONS[2].speed = player:GetMagicStepTime() / player:GetMagicSpeed() / 0.001
    end
    self:UpdatePreviewSkillUI()
    self:UpdateActionSelect()
    self:UpdateModelSelect()
    self:UpdateModelInput()
    self:UpdateSpeedUI()

    return true
end

--- 搜索事件
---@param markSkillStr string 记录上一次输入框的内容
---@param blurT table 模糊搜索表
function PreviewSkillLayout:OnSearchEvent(blurT,index)
    
    local skillID = blurT[index]
    if not skillID or not self._config[skillID] then
        ShowSystemTips("未找到对应的技能ID或者技能名称")
        return
    end

    if skillID and skillID ~= self._selectID then
        self._selectID = skillID
        self:JumpPreviewSkill(skillID,true)
    else
        self._selectID = skillID
    end
    self:OnPreviewSkill(self._selectID)
end

--- 新增事件
function PreviewSkillLayout:OnNewAddEvent()
    local maxSkillID = table.maxn(self._config)
    local newAddID = maxSkillID + 1
    self._markAddID = newAddID
    self._config[newAddID] = {}
    local cfg = self._config[newAddID]
    for i, v in ipairs(keys) do
        self:UpdatePreviewSkillData(newAddID,v.key,v.default)
    end
    self._config[newAddID].id = newAddID
    self:UpdatePreviewSkillUI(newAddID)
end

-- 复制新增事件
function PreviewSkillLayout:OnCopyNewAddEvent()
    if not self._selectID or not self._config[self._selectID] then
        ShowSystemTips("未选中需要复制的技能或者该数据已不存在")
        return
    end
    local maxSkillID = table.maxn(self._config)
    local newAddID = maxSkillID + 1
    self._markAddID = newAddID
    self._config[newAddID] = clone(self._config[self._selectID])
    self._config[newAddID].id = newAddID
    self:UpdatePreviewSkillUI(newAddID)
end

--- 多选事件
function PreviewSkillLayout:OnMultipleSlectEvent()
    self._selects = {}
    self._selects_state = not self._selects_state
    local selectsButton = self._ui.Button_selects
    selectsButton:setTitleText(self._selects_state and "取消多选" or "多选")

    local skillList = self._ui.ListView_skill
    local items = skillList:getItems()
    for k, _cell in pairs(items) do
        local cellName = _cell:getName()
        local item = _cell:getChildByName(cellName)
        if item then
            item:getChildByName("CheckBox_multiple"):setVisible(self._selects_state)
        end
    end
end

--- 删除事件
function PreviewSkillLayout:OnDelectEvent()
    if self._selects_state then
        if not next(self._selects) then
            ShowSystemTips("未选择要删除的数据")
            return
        end
    else
        if not self._selectID or not self._config[self._selectID] then
            ShowSystemTips("删除的数据不存在")
            return
        end
    end

    local function callback(bType, custom)
        if bType == 1 then
            if self._selects_state then
                for k, _id in pairs(self._selects or {}) do
                    self._config[_id]=nil
                end
            else
                self._config[self._selectID] = nil
            end
            self:OnSaveDataReLoad()
            self:UpdatePreviewSkillUI()
            ShowSystemTips("删除成功")
        end
    end
    local data = {}
    data.str = self._selects_state and string.format("多个数据将会被删除") or string.format("将会删除ID: %s 的数据", self._selectID)
    data.btnType = 2
    data.callback = callback
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

--- 恢复事件
function PreviewSkillLayout:OnRecoverEvent()
    self._markAddID = nil
    local function callback(bType, custom)
        if bType == 1 then
            local devFilePath = "dev/scripts/game_config/cfg_skill_present.lua"
            local filePath = "game_config/cfg_skill_present"
            os.remove(devFilePath)
            global.FileUtilCtl:purgeCachedEntries()
            package.loaded[filePath] = nil
            require(filePath)
            self._config = clone(requireGameConfig("cfg_skill_present"))
            self:UpdatePreviewSkillUI(self._selectID)
        end
    end
    local data = {}
    data.str = "恢复将会删除dev目录下的cfg_skill_present.lua文件"
    data.btnType = 2
    data.callback = callback
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

--- 保存数据事件
function PreviewSkillLayout:OnSaveEvent()
    local haveID = ""
    local function callback(bType, custom)
        if bType == 1 then
            local newID = tonumber(self._ui.TextField_id:getString())
            if not self._config[newID] then
                local newCfg = self._config[self._selectID]
                self._config[self._selectID] = nil 
                self._config[newID] = {}
                self._config[newID] = newCfg
                self._selectID = newID
                for i, v in ipairs(keys) do
                    v.default = newCfg[v.key]
                    self:UpdatePreviewSkillData(self._selectID,v.key,v.default)
                end
            end
            self:OnSaveDataReLoad()
            self:UpdatePreviewSkillUI(self._selectID)
            ShowSystemTips("保存完成")
        end
    end
    local data = {}
    if haveID and haveID ~= "" then
        data.str = string.format("ID：%s数据已存在，该操作将会替换已有的数据", haveID)
    else
        data.str = string.format("确认是否要保存")
    end
    data.btnType = 2
    data.callback = callback
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

--- func 配置事件
---@param sender userdata 配置的组件
---@param data table keys的数据
function PreviewSkillLayout:OnConfigEvent(sender,data)
    if not self._selectID or not self._config[self._selectID] then
        ShowSystemTips("修改的内容不存在，无效果")
    end

    if data.isInput and data.key == "id" then 
        local inputId = tonumber(sender:getString())
        if self._config[inputId] then 
            sender:setString(self._selectID)
            ShowSystemTips("技能ID重复")
            return 
        end 
    end 

    local value = nil
    if data.isCheckBox then -- checkbox
        value = sender:isSelected()
    elseif data.isSelect then
        value = sender.SelectIndex or data.default
        local listViewZ = sender:getChildByName("ListView_z")
        local isShow = listViewZ:isVisible()
        isShow = not isShow
        listViewZ:setVisible(isShow)
        sender:getChildByName("Image_arrow"):setRotation(isShow and 90 or 270)

        if isShow then
            listViewZ:removeAllChildren()
            for index, v in ipairs(data.selectValues or {}) do
                local item = self:CreateConfigSelectItem(data,index)
                listViewZ:pushBackCustomItem(item)
            end
        end
    elseif data.isInput then
        value = sender:getString()
    else
        return
    end
    self:UpdateConfigContorl(data,value)
end

--- 模型选项事件
function PreviewSkillLayout:OnModelSelectEvent()
    local modelPanel = self._ui.Panel_modle_type
    local listViewModel = modelPanel:getChildByName("ListView_modles")
    listViewModel:removeAllChildren()

    local isShow = listViewModel:isVisible()
    isShow = not isShow
    listViewModel:setVisible(isShow)
    modelPanel:getChildByName("Image_arrow"):setRotation(isShow and 90 or 270)

    if isShow then
        for i, v in ipairs(MODELS) do
            local item = self:CreateModelItem(v,i)
            listViewModel:pushBackCustomItem(item)
        end
    end
end

--- 创建模型选项Item
---@param data table MODELS的数据
---@param i any MODELS的key
function PreviewSkillLayout:CreateModelItem(data,i)
    local customPanel = self._ui.Panel_custom
    local item = customPanel:getChildByName("Panel_modle_item"):cloneEx()
    item:removeFromParent()

    item:getChildByName("Text_name"):setString(data.name or "")
    
    item:addClickEventListener(function()
        local widget = self._ui.Panel_modle_type
        self._select_model = data.model
        if widget.SelectIndex ~= i then
            self:UpdatePlayerModelTX()
        end
        widget.SelectIndex = i
        self:OnModelSelectEvent()
        self:UpdateModelSelect()
        self:UpdateModelInput()

        
    end)
    return item
end

--- 更新模型选项显示
function PreviewSkillLayout:UpdateModelSelect()
    local modelPanel = self._ui.Panel_modle_type

    local name = ""
    for i, v in ipairs(MODELS) do
        if self._select_model == v.model then
            name = v.name
            break
        end
    end

    modelPanel:getChildByName("Text_modle"):setString(name)
end

--- 动作选项事件
function PreviewSkillLayout:OnActionSelectEvent()
    local actionPanel = self._ui.Panel_action_speed
    local listViewaction = actionPanel:getChildByName("ListView_action")
    listViewaction:removeAllChildren()

    local isShow = listViewaction:isVisible()
    isShow = not isShow
    listViewaction:setVisible(isShow)
    actionPanel:getChildByName("Image_arrow"):setRotation(isShow and 90 or 270)

    if isShow then
        for i, v in ipairs(ACTIONS) do
            local item = self:CreateActionItem(v,i)
            listViewaction:pushBackCustomItem(item)
        end
    end
end

--- 创建动作选项Item
---@param data table ACTIONS的数据
---@param i any ACTIONS的key
function PreviewSkillLayout:CreateActionItem(data,i)
    local customPanel = self._ui.Panel_custom
    local item = customPanel:getChildByName("Panel_action_item"):cloneEx()
    item:removeFromParent()

    item:getChildByName("Text_name"):setString(data.name or "")
    
    item:addClickEventListener(function()
        local widget = self._ui.Panel_action_speed
        widget.SelectIndex = i
        self._select_action = data.action
        self:OnActionSelectEvent()
        self:UpdateActionSelect()
        self:UpdateSpeedUI()
    end)
    return item
end

--- 刷新动作选项显示
function PreviewSkillLayout:UpdateActionSelect()
    local modelPanel = self._ui.Panel_action_speed

    local name = ""
    for i, v in ipairs(ACTIONS) do
        if self._select_action == v.action then
            name = v.name
            break
        end
    end

    modelPanel:getChildByName("Text_action"):setString(name)
end

--- 创建配置选择Item
---@param data table keys的数据
---@param index any selectValues的key
function PreviewSkillLayout:CreateConfigSelectItem(data,index)
    local customPanel = self._ui.Panel_custom
    local item = customPanel:getChildByName("Panel_z_item"):cloneEx()
    item:removeFromParent()

    local selectData = data.selectValues and index and data.selectValues[index] or {}
    item:getChildByName("Text_name"):setString(selectData.name)
    
    item:addClickEventListener(function()
        local parent = self._ui.Panel_config
        local widget = parent:getChildByName(data.nodeName)
        widget.SelectIndex = selectData.id
        self:OnConfigEvent(widget,data)
    end)
    return item
end

--- 刷新配置组件UI
---@param selectID integer 技能表现ID
function PreviewSkillLayout:UpdateConfigUI( selectID )
    local cfg = {}
    if selectID and self._config[selectID] then
        cfg = self._config[selectID]
    end

    for i, v in ipairs(keys) do
        self:UpdateConfigContorl(v,cfg[v.key] or v.default)
    end
end

--- 更新速度Input UI
---@param inputValue any 速度值
function PreviewSkillLayout:UpdateSpeedUI(inputValue)
    local action = self._select_action or global.MMO.ACTION_ATTACK
    local speed = inputValue or 1000

    local index = 1
    for k, v in pairs(ACTIONS) do
        if v.action == action then
            index = k
            break
        end
    end

    if inputValue then
        if ACTIONS[index] then
            ACTIONS[index].speed = inputValue
        end
    else
        if not ACTIONS[index] then
            ACTIONS[index] = {}
        end
        if not ACTIONS[index].speed then
            ACTIONS[index].speed = 1000
        end
        speed = ACTIONS[index] and ACTIONS[index].speed or 1000
    end

    GUI:TextInput_setString(self._ui.TextField_action_speed, speed)

    local refrshParam = nil
    if action == global.MMO.ACTION_ATTACK then
        refrshParam = "attrSpeed"
    elseif action == global.MMO.ACTION_SKILL then
        refrshParam = "magicSpeed"
    end
    if refrshParam then
        local param = {
            [refrshParam] = speed,
            action = self._select_action
        }
        global.Facade:sendNotification(global.NoticeTable.Preview_Skill_Action_Refresh,param)
    end
end

--- 刷新配置组件修改
---@param data table keys的数据
---@param value any 修改的值
function PreviewSkillLayout:UpdateConfigContorl(data,value)
    if not data or not data.nodeName then
        return
    end
    local widget = self._ui[data.nodeName]
    if not widget then
        return
    end

    if data.onlyInt then
        value = tonumber(value)
        if not value then
            value = data.default or 0
        end
    end

    if data.isCheckBox then -- checkbox
        local values = data.checkBoxValues
        local isSelected = values and values[value] or false
        widget:setSelected(isSelected)
    elseif data.isSelect then
        local values = data.selectValues
        local name = ""
        if value and values then
            for i, v in pairs(values) do
                if v.id == value then
                    name = v.name
                    break
                end
            end
        else
            local selectData = values and value and values[value]
            name = selectData and selectData.name or ""
        end
        widget:getChildByName("Text_z"):setString(name)
    else
        widget:setString(value or "")
    end

    if self._selectID and self._config[self._selectID] then
        self:UpdatePreviewSkillData(self._selectID,data.key,value)

        if data.isResetPreview then
            self:OnPreviewSkill(self._selectID)
        end
    end

    return true
end

--- 更新技能表现id
---@param seletID integer 技能表现ID
function PreviewSkillLayout:UpdatePreviewSkillUI(seletID)
    local cfgData = {}
    self._allNameStr = ""
    for k, v in pairs(self._config or {}) do
        local nameStr = "<" .. (v.name or "") .. "&" .. (v.id or "") .. ">"
        self._allNameStr = self._allNameStr ..  nameStr
        table.insert(cfgData, v)
    end

    if #cfgData > 1 then
        table.sort(cfgData, function(a, b)
            return a.id < b.id
        end)
    end

    local searchPanel = self._ui.Panel_search
    local skillList = searchPanel:getChildByName("ListView_skill")
    skillList:removeAllChildren()

    for i, cfg in ipairs(cfgData) do
        if not seletID then
            seletID = cfg.id
        end
        local cell = QuickCell:Create({
            wid = 200,
            hei = 50,
            createCell = function()
                local item = self:CreatePreviewSkillItem(cfg)
                return item
            end
        })
        cell:setName("SKILL_ITEM_"..(cfg.id or -1))
        skillList:pushBackCustomItem(cell)
    end

    if seletID then
        self:JumpPreviewSkill(seletID,true)
    end
end

--- --创建技能item
---@param data table cfg_skill_present表数据
function PreviewSkillLayout:CreatePreviewSkillItem(data)
    local customPanel = self._ui.Panel_custom
    local item = customPanel:getChildByName("Panel_skill_item"):cloneEx()
    item:setName("SKILL_ITEM_"..(data.id or -1))
    item:removeFromParent()
    self:UpdatePreviewSkillItem(item,data)

    -- 点击item事件
    item:addClickEventListener( function()
        self:JumpPreviewSkill(data.id)
    end)

    -- 多选选中
    item:getChildByName("CheckBox_multiple"):addEventListener(function(sender)
        local isSelect = sender:isSelected()
        if isSelect then
            self._selects[data.id] = data.id
        else
            self._selects[data.id] = nil
        end
    end)

    if self._selectID and self._selectID == data.id then
        item:getChildByName("Panel_skill_select_color"):setVisible(true)
    end

    return item
end

--- 刷新技能item数据
---@param item userdata itemNode
---@param data table cfg_skill_present表数据
function PreviewSkillLayout:UpdatePreviewSkillItem(item,data)
    if not item then
        return
    end
    data = data or {}
    local skillID = string.format("%s(%s)",data.name or "",data.id or "-1")
    item:getChildByName("Text_skill_id"):setString(skillID)
end

--- 跳转对应的技能表现
---@param selectID integer 技能表现ID
---@param isJump boolean 是否跳转动作
function PreviewSkillLayout:JumpPreviewSkill(selectID,isJump)
    if not selectID then
        return
    end
    local searchPanel = self._ui.Panel_search
    local skillList = searchPanel:getChildByName("ListView_skill")
    local item = skillList:getChildByName("SKILL_ITEM_"..selectID)
    if not item then
        return
    end
    
    local panel = item:getChildByName("SKILL_ITEM_"..selectID)
    if panel then
        panel:getChildByName("Panel_skill_select_color"):setVisible(true)
    end

    if self._selectID then
        local lastItem = skillList:getChildByName("SKILL_ITEM_"..self._selectID)
        if lastItem then
            local panel = lastItem:getChildByName("SKILL_ITEM_"..self._selectID)
            if panel then
                panel:getChildByName("Panel_skill_select_color"):setVisible(false)
            end
        end
    end

    self._selectID = selectID

    if isJump then
        local itemIndex = skillList:getIndex(item)
        local index = math.max(itemIndex or 0, 0)
        skillList:jumpToItem(index,cc.p(0, 0), cc.p(0, 0))
    end

    local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local skillCfg = skillProxy:FindConfigBySkillID(selectID)
    local action = self._select_action
    if skillCfg and skillCfg.action then
        if skillCfg.action == 1 then
            self._select_action = global.MMO.ACTION_SKILL
        else
            self._select_action = global.MMO.ACTION_ATTACK
        end
    end

    if action ~= self._select_action then
        self:UpdateActionSelect()
        self:UpdateSpeedUI()
    end
    self:OnPreviewSkill(selectID)
    self:UpdateConfigUI(selectID)
end

--- 更新人物模型
---@param txID integer 模型ID
function PreviewSkillLayout:UpdatePlayerModelTX(txID)
    local param = {
        playerid = txID,
        model = self._select_model
    }
    global.Facade:sendNotification(global.NoticeTable.Preview_Skill_Action_Refresh,param)
end

--- 刷新模型ID输入
---@param inputValue any 模型ID
function PreviewSkillLayout:UpdateModelInput(inputValue)
    local widget = self._ui.Panel_modle_type
    local modelData = MODELS[widget.SelectIndex or 1]
    if inputValue then
        modelData.inputID = inputValue
    else
        inputValue = modelData.inputID
    end
    modelData.inputID = inputValue
    self._select_model_id = inputValue
    self._ui.TextField_modle_id:setString(inputValue)
    self:UpdatePlayerModelTX(inputValue)
end

--- 获取模糊搜索表
---@param str string 模糊搜索的字符串
function PreviewSkillLayout:GetBlurNames( str )
    local names = {}
    if string.len(str) > 0 then
        for w in string.gmatch(self._allNameStr,"<([^<>]-" .. str.."+" .. "[^<>]-)>") do
            local split = string.split(w,"&")
            local id = tonumber(split[2])
            if id then
                table.insert(names,id)
            end
        end
    end

    return names
end

--- 保存数据
function PreviewSkillLayout:OnSaveDataReLoad()
    self._markAddID = nil
    SL:SaveTableToConfig(self._config, "cfg_skill_present")
    global.FileUtilCtl:purgeCachedEntries()
    SL:Require("game_config/cfg_skill_present", true)
    global.skillManager:LoadConfig()
end

--- 执行预览
---@param skillID integer 预览id
---@param noPlayStarAction boolean 不执行起手式动作
function PreviewSkillLayout:OnPreviewSkill(skillID, noPlayStarAction)
    if not skillID then
        return
    end
    local config = self._config[skillID]
    if not config then
        return
    end

    local param = {
        cfg = config,
        action = self._select_action or global.MMO.ACTION_ATTACK
    }
    global.Facade:sendNotification(global.NoticeTable.Preview_Skill_Action_Refresh,param)
end


--- 关闭界面
function PreviewSkillLayout:OnClose()
    global.Facade:sendNotification(global.NoticeTable.Preview_Skill_Action_UnAttach)
end

return PreviewSkillLayout
