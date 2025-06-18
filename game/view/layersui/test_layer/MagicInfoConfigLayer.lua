local MagicInfoConfigLayer = class("MagicInfoConfigLayer", function()
    return cc.Node:create()
end)

local RichTextHelp = requireUtil("RichTextHelp")
local QuickCell = requireUtil("QuickCell")

local keys = {{
    key = "MagicID",
    onlyInt = true,
    desc = "技能ID",
    isInput = true,
    nodeName = "TextField_id"
}, {
    key = "magicName",
    desc = "技能名称",
    isInput = true,
    nodeName = "TextField_name"
}, {
    key = "HeroMagicName",
    desc = "英雄名称",
    isInput = true,
    nodeName = "TextField_hero_name"
}, {
    key = "priority",
    onlyInt = true,
    desc = "优先级",
    isInput = true,
    nodeName = "TextField_priority"
}, {
    key = "job",
    default = 0,
    desc = "职业",
    isSelect = true,
    selectValues = {{
        id = 0,
        name = "战士"
    }, {
        id = 1,
        name = "法师"
    }, {
        id = 2,
        name = "道士"
    }, {
        id = 3,
        name = "全职业"
    }},
    nodeName = "Panel_job"
}, {
    key = "action",
    default = 0,
    desc = "释放动作：攻击/施法",
    isSelect = true,
    localZorder = 99,
    selectValues = {{
        id = 0,
        name = "攻击"
    }, {
        id = 1,
        name = "施法"
    }},
    nodeName = "Panel_action"
}, {
    key = "type",
    default = 1,
    desc = "动作类型：主动/被动",
    isSelect = true,
    localZorder = 98,
    selectValues = {{
        id = 0,
        name = "被动"
    }, {
        id = 1,
        name = "主动"
    }},
    nodeName = "Panel_action_type"
}, {
    key = "launchmode",
    key_pc = "launchmode_pc",
    default = 1,
    localZorder = 97,
    desc = "释放类型:1.方向.目标（不自动选）??2.自己坐标??3方向.目标??4.自己坐标和传入坐标??5.方向和目标（必须）",
    desc_pc = "释放类型: 1.自己坐标 2.鼠标方向   3.鼠标坐标  4.鼠标所在方向(攻击锁定)   5.鼠标所在目标(魔法锁定）",
    isSelect = true,
    selectValues = {{
        id = 1,
        name = "方向.目标(不自动选)"
    }, {
        id = 2,
        name = "自己坐标"
    }, {
        id = 3,
        name = "方向.目标"
    }, {
        id = 4,
        name = "自己坐标和传入坐标"
    }, {
        id = 5,
        name = "方向和目标(必现)"
    }},
    selectValues_pc = {{
        id = 2,
        name = "鼠标方向"
    }, {
        id = 3,
        name = "鼠标坐标"
    }, {
        id = 4,
        name = "鼠标所在方向(攻击锁定)"
    }, {
        id = 5,
        name = "鼠标所在目标(魔法锁定）"
    }},
    nodeName = "Panel_action_effect"
}, {
    key = "icon",
    default = 0,
    basePath = "res/skill_icon/",
    desc = "技能图标",
    isImg = true,
    nodeName = "Image_skill_icon",
    isTouch = false,
    linkNode = {{
        nodeName = "Text_file",
        default = 0
    }}
}, {
    key = "magiclock",
    default = 0,
    desc = "魔法锁定",
    isCheckBox = true,
    checkBoxValues = {
        [0] = false,
        [1] = true,
        [false] = 0,
        [true] = 1
    }, -- 0: false   1: true
    nodeName = "CheckBox_magic_lock"
}, {
    key = "bestPos",
    default = 0,
    desc = "是否需要走位",
    isCheckBox = true,
    checkBoxValues = {
        [0] = false,
        [1] = true,
        [false] = 0,
        [true] = 1
    }, -- 0: false   1: true
    nodeName = "CheckBox_best_pos"
}, {
    key = "maxDis",
    key_pc = "maxDis_pc",
    desc = "最大攻击距离",
    default = 1,
    onlyInt = true,
    isInput = true,
    nodeName = "TextField_max_dis"
}, {
    key = "autoMinDis",
    desc = "自动走位时最小距离",
    default = 1,
    onlyInt = true,
    isInput = true,
    nodeName = "TextField_auto_min_dis"
}, {
    key = "forceDis",
    desc = "强制判断施法距离",
    default = 0,
    isCheckBox = true,
    checkBoxValues = {
        [0] = false,
        [1] = true,
        [false] = 0,
        [true] = 1
    }, -- 0: false   1: true
    nodeName = "CheckBox_force_dis"
}, {
    key = "isonoff",
    desc = "开关型技能",
    default = 0,
    isCheckBox = true,
    checkBoxValues = {
        [0] = false,
        [1] = true,
        [false] = 0,
        [true] = 1
    }, -- 0: false   1: true
    nodeName = "CheckBox_is_onoff"
}, {
    key = "isline",
    desc = "直线方向释放",
    default = 0,
    isCheckBox = true,
    checkBoxValues = {
        [0] = false,
        [1] = true,
        [false] = 0,
        [true] = 1
    }, -- 0: false   1: true
    nodeName = "CheckBox_is_line"
}, {
    key = "locktarget",
    desc = "释放后持续攻击目标",
    default = 0,
    isCheckBox = true,
    checkBoxValues = {
        [0] = false,
        [1] = true,
        [false] = 0,
        [true] = 1
    }, -- 0: false   1: true
    nodeName = "CheckBox_lock_target"
}, {
    key = "addition",
    desc = "增益型技能在没目标时会对自己释放 0.伤害型 1.是增益型  2.其他增益",
    default = 0,
    isSelect = true,
    localZOrder = 99,
    selectValues = {{
        id = 0,
        name = "伤害型"
    }, {
        id = 1,
        name = "增益型"
    }, {
        id = 2,
        name = "其它增益"
    }},
    nodeName = "Panel_launch_type"
}, {
    key = "skilltype",
    desc = "内挂显示配置",
    default = 0,
    isSelect = true,
    selectValues = {{
        id = 0,
        name = "不显示"
    }, {
        id = 1,
        name = "单体技能"
    }, {
        id = 2,
        name = "群怪技能"
    }, {
        id = 3,
        name = "回血技能"
    }, {
        id = 4,
        name = "召唤技能"
    }},
    nodeName = "Panel_priority_p"
}, {
    key = "desc",
    default = "",
    desc = "技能描述",
    isInput = true,
    isRichText = true,
    nodeName = "TextField_desc"
}, {
    key = "drivingreplace",
    default = "",
    desc = "替换快捷键",
    isInput = true,
    nodeName = "TextField_priority_p"
}, {
    key = "replace",
    desc = "学习后替代普攻快捷键",
    default = 0,
    isCheckBox = true,
    checkBoxValues = {
        [0] = false,
        [1] = true,
        [false] = 0,
        [true] = 1
    }, -- 0: false   1: true
    nodeName = "CheckBox_replace"
},{
    key = "nDesc",
    default = "",
    desc = "怒之技能描述",
    isInput = true,
    isRichText = true,
    nodeName = "TextField_desc_n"
},{
    key = "jDesc",
    default = "",
    desc = "静之技能描述",
    isInput = true,
    isRichText = true,
    nodeName = "TextField_desc_j"
},{
    key = "nIcon",
    default = 0,
    basePath = "res/skill_icon/",
    desc = "怒之技能图标",
    isImg = true,
    nodeName = "Image_skill_icon_n",
    isTouch = false,
    linkNode = {{
        nodeName = "Text_file_n",
        default = 0
    }}
},{
    key = "jIcon",
    default = 0,
    basePath = "res/skill_icon/",
    desc = "静之技能图标",
    isImg = true,
    nodeName = "Image_skill_icon_j",
    isTouch = false,
    linkNode = {{
        nodeName = "Text_file_j",
        default = 0
    }}
},{
    key = "nMagicName",
    desc = "怒之技能名称",
    isInput = true,
    nodeName = "TextField_name_n"
},{
    key = "jMagicName",
    desc = "静之技能名称",
    isInput = true,
    nodeName = "TextField_name_j"
}}

function MagicInfoConfigLayer:ctor()
    self._config = {}
    self._selects = {}

    self._config_type = 1 -- 配置类型(1: 通用  2: PC 3: 内功)
    self._selectID = nil
    self._allNameStr = "" -- 模糊搜索的名字格式 <magicName&MagicID><magicName&MagicID>

end

--- 获取cfg_skill_present
---@param skillID integer 技能预览ID
function MagicInfoConfigLayer:GetMagicDataByID(skillID)
    return self._config[skillID]
end

--- 更新技能表现表的数据   缓存，未保存时不会改变表的数据
---@param skillID integer 技能表现ID
---@param key string  要改变的字段名
---@param value any 要改变的值
function MagicInfoConfigLayer:UpdateMagicData(skillID, key, value)
    if not skillID or not key then
        return
    end
    local cfg = self:GetMagicDataByID(skillID)
    if cfg then
        cfg[key] = value
    end
end

function MagicInfoConfigLayer.create()
    local layout = MagicInfoConfigLayer.new()
    if layout and layout:Init() then
        return layout
    end
    return nil
end

function MagicInfoConfigLayer:Init()
    self._root = CreateExport("preview_skill/skill_magicinfo")
    if not self._root then
        return false
    end

    self:addChild(self._root)

    self._ui = ui_delegate(self._root)

    self._config = clone(requireGameConfig("cfg_magicinfo"))

    self._ui.TextField_search = CreateEditBoxByTextField(self._ui.TextField_search)
    self._ui.TextField_search:setReturnType(2)
    self._ui.TextField_search:setInputMode(6)

    local markSkillStr = ""
    local blurT = {} -- 模糊搜索表
    local searchIndex = 1
    local isNew = false
    self._ui.TextField_search:addEventListener(function(sender, eventType)
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
            self:OnSearchEvent(blurT, 1)
        end
    end)

    -- 搜索按钮
    self._ui.Button_search:addClickEventListener(function()
        searchIndex = searchIndex + 1
        if searchIndex > #blurT then
            searchIndex = 1
        end
        self:OnSearchEvent(blurT, searchIndex)
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
        global.Facade:sendNotification(global.NoticeTable.MagicInfoClose)
    end)

    -- 恢复
    self._ui.Button_recover:addClickEventListener(function()
        self:OnRecoverEvent()
    end)

    -- 保存
    self._ui.Button_save:addClickEventListener(function()
        self:OnSaveEvent()
    end)

    -- 打开目录  选中技能图标
    self._ui.Button_open_file:addClickEventListener(function()
        self:OnOpenFileEvent()
    end)

    -- 通用配置
    self._ui.Button_gm:addClickEventListener(function()
        self._config_type = 1
        self:UpdateConfigTypeButton()
    end)

    -- PC配置
    self._ui.Button_pc:addClickEventListener(function()
        self._config_type = 2
        self:UpdateConfigTypeButton()
    end)

    -- 内功配置
    self._ui.Button_ng:addClickEventListener(function()
        self._config_type = 3
        self:UpdateConfigTypeButton()
    end)

    -- 点击图片 打开目录  选中技能图标
    self._ui.Image_skill_icon:setTouchEnabled(true)
    self._ui.Image_skill_icon:addClickEventListener(function()
        self:OnOpenFileEvent()
    end)

    local suffixList = {"_n", "_j"}
    for _, suffix in ipairs(suffixList) do
        self._ui["Button_open_file" .. suffix]:addClickEventListener(function()
            self:OnOpenFileEvent(nil, suffix)
        end)
        self._ui["Image_skill_icon" .. suffix]:addClickEventListener(function()
            self:OnOpenFileEvent(nil, suffix)
        end)
    end

    for i, v in pairs(keys or {}) do
        self:UpdateConfigContorl(v, v.default)
        if v.nodeName then
            local widget = self._ui[v.nodeName]
            if widget then
                if v.isInput then
                    self._ui[v.nodeName] = CreateEditBoxByTextField(widget)
                    widget = self._ui[v.nodeName]
                    widget:setReturnType(2)
                    widget:setInputMode(6)
                    widget:addEventListener(function(sender, eventType)
                        if eventType == 0 then
                            if v.isRichText and widget.richTextStr then
                                sender:setString(widget.richTextStr)
                            end
                        elseif eventType == 3 then
                            self:OnConfigEvent(sender, v)
                        end
                    end)
                else
                    if v.isTouch ~= false then
                        widget:addClickEventListener(function(sender)
                            self:OnConfigEvent(sender, v)
                        end)
                    end
                end
            end
        end
    end

    -- 添加动作层
    global.Facade:sendNotification(global.NoticeTable.Preview_Skill_Action_Attach, {
        parent = self._ui.Panel_model
    })

    self:UpdateConfigTypeButton()
    self:UpdateMagicList()
    return true
end

--- 获取模糊搜索表
---@param str string 模糊搜索的字符串
function MagicInfoConfigLayer:GetBlurNames(str)
    local names = {}
    if string.len(str) > 0 then
        for w in string.gmatch(self._allNameStr, "<([^<>]-" .. str .. "+" .. "[^<>]-)>") do
            local split = string.split(w, "&")
            local id = tonumber(split[2])
            if id then
                table.insert(names, id)
            end
        end
    end

    return names
end

function MagicInfoConfigLayer:UpdateMagicList(selectID)
    local list = self._ui.ListView_skill
    list:removeAllChildren()

    local cfgData = {}
    self._allNameStr = ""
    for k, v in pairs(self._config or {}) do
        local nameStr = "<" .. (v.magicName or "") .. "&" .. (v.MagicID or "") .. ">"
        self._allNameStr = self._allNameStr .. nameStr
        table.insert(cfgData, v)
    end

    if #cfgData > 1 then
        table.sort(cfgData, function(a, b)
            return a.MagicID < b.MagicID
        end)
    end

    for i, v in ipairs(cfgData) do
        if not selectID then
            selectID = v.MagicID
        end
        local cell = QuickCell:Create({
            wid = 200,
            hei = 50,
            createCell = function()
                local item = self:CreateMagicItem(v)
                return item
            end
        })
        cell:setName("SKILL_ITEM_" .. (v.MagicID or -1))
        cell:setTag(v.MagicID or -1)
        list:pushBackCustomItem(cell)
    end

    if selectID then
        self:JumpMagicItem(selectID, true)
    end
end

function MagicInfoConfigLayer:CreateMagicItem(data)
    local customPanel = self._ui.Panel_custom
    local item = customPanel:getChildByName("Panel_skill_item"):cloneEx()
    item:setName("SKILL_ITEM_" .. (data.MagicID or -1))
    item:setTag(data.MagicID or -1)
    item:removeFromParent()

    local textName = string.format("%s(%s)", data.magicName or "", data.MagicID or "")
    item:getChildByName("Text_skill_id"):setString(textName)

    -- 点击item事件
    item:addClickEventListener(function()
        self:JumpMagicItem(data.MagicID)
    end)

    -- 多选选中
    item:getChildByName("CheckBox_multiple"):addEventListener(function(sender)
        local isSelect = sender:isSelected()
        if isSelect then
            self._selects[data.MagicID] = data.MagicID
        else
            self._selects[data.MagicID] = nil
        end
    end)

    if self._selectID and self._selectID == data.MagicID then
        item:getChildByName("Panel_skill_select_color"):setVisible(true)
    end

    return item
end

function MagicInfoConfigLayer:JumpMagicItem(selectID, isJump)
    if not selectID then
        return
    end

    if selectID == self._selectID and not isJump then
        return
    end

    local list = self._ui.ListView_skill
    if not list then
        return
    end
    local cell = list:getChildByTag(selectID)
    if not cell then
        return
    end
    local item = cell:getChildByTag(selectID)
    if item then
        item:getChildByName("Panel_skill_select_color"):setVisible(true)
    end
    if self._selectID then
        local currSelectCell = list:getChildByTag(self._selectID)
        if currSelectCell then
            local currSelectItem = currSelectCell:getChildByTag(self._selectID)
            if currSelectItem then
                currSelectItem:getChildByName("Panel_skill_select_color"):setVisible(false)
            end
        end
    end
    self._selectID = cell:getTag()

    if isJump then
        local itemIndex = list:getIndex(cell)
        local index = math.max(itemIndex or 0, 0)
        list:jumpToItem(index, cc.p(0, 0), cc.p(0, 0))
    end

    self:UpdateMagicConfig()
end

function MagicInfoConfigLayer:UpdateMagicConfig()
    if not self._selectID then
        return
    end
    local cfg = self._config[self._selectID]
    if not cfg then
        ShowSystemTips("未找到数据")
        cfg = {}
    end

    local isPC = self._config_type == 2

    for i, v in ipairs(keys or {}) do
        local key = v.key
        if isPC and cfg[key .. "_pc"] then
            key = key .. "_pc"
        end
        self:UpdateConfigContorl(v, cfg[key] or v.default)
    end

    local config = global.skillManager:getSkillDataByID(self._selectID)
    if cfg.action == 0 then
        global.Facade:sendNotification(global.NoticeTable.Preview_Skill_Action_Refresh, {
            action = global.MMO.ACTION_ATTACK,
            cfg = config or {}
        })
    elseif cfg.action == 1 then
        global.Facade:sendNotification(global.NoticeTable.Preview_Skill_Action_Refresh, {
            action = global.MMO.ACTION_SKILL,
            cfg = config or {}
        })
    end
end

--- 刷新配置组件修改
---@param data table keys的数据
---@param value any 修改的值
function MagicInfoConfigLayer:UpdateConfigContorl(data, value, isClick)
    if not data or not data.nodeName then
        return
    end
    local widget = self._ui[data.nodeName]
    if not widget then
        return
    end

    local isPC = self._config_type == 2
    if data.onlyInt then
        value = tonumber(value)
        if not value then
            value = isPC and data.default_pc or data.default or 0
        end
    end

    if data.isCheckBox then
        local values = isPC and data.checkBoxValues_pc or data.checkBoxValues
        local isSelected = values and values[value] or false
        if not isClick then
            widget:setSelected(isSelected == true)
        end
    elseif data.isSelect then
        local values = isPC and data.selectValues_pc or data.selectValues
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
        widget:getChildByName("Text_name"):setString(name)
    elseif data.isImg then
        local linkVale = value .. ".png"
        local imgPath = string.format("%s%s.png", global.MMO.PATH_RES_SKILL_ICON, value or "")
        if not global.FileUtilCtl:isFileExist(imgPath) then
            imgPath = string.format("%s%s.jpg", global.MMO.PATH_RES_SKILL_ICON, value or "")
            linkVale = value .. ".jpg"
        end
        widget:loadTexture(imgPath)

        if data.linkNode then
            for i, v in ipairs(data.linkNode) do
                self:UpdateConfigContorl(v, linkVale)
            end
        end
    else
        local richChild = widget:getChildByName("RICH_TEXT")
        if richChild then
            richChild:removeFromParent()
            richChild = nil
        end
        if data.isRichText then -- 如果是富文本
            local richTextSize = 14
            local richText = RichTextHelp:CreateRichTextWithFCOLOR(value or "", widget:getContentSize().width - 10,
                richTextSize)
            richText:setName("RICH_TEXT")
            richText:setAnchorPoint({
                x = 0,
                y = 1
            })
            richText:setPosition(0, widget:getContentSize().height)
            richText:formatText()
            widget:addChild(richText)
            widget:setString("")
            widget:setPlaceHolder("")
            widget.richTextStr = value or ""
        else
            widget:setString(value or "")
        end
    end

    if self._selectID and self._config[self._selectID] then
        local configKey = data.key
        if isPC and data.key_pc then
            configKey = data.key_pc
        end
        self:UpdateMagicData(self._selectID, configKey, value)

        if configKey == "action" then -- 刷新动作
            local config = global.skillManager:getSkillDataByID(self._selectID)
            if value == 0 then
                global.Facade:sendNotification(global.NoticeTable.Preview_Skill_Action_Refresh, {
                    action = global.MMO.ACTION_ATTACK,
                    cfg = config or {}
                })
            elseif value == 1 then
                global.Facade:sendNotification(global.NoticeTable.Preview_Skill_Action_Refresh, {
                    action = global.MMO.ACTION_SKILL,
                    cfg = config or {}
                })
            end
        end
    end

    return true
end

--- func 配置事件
---@param sender userdata 配置的组件
---@param data table keys的数据
function MagicInfoConfigLayer:OnConfigEvent(sender, data)
    local cfg = {}
    if not self._selectID or not self._config[self._selectID] then
        ShowSystemTips("修改的内容不存在，无效果")
        cfg = self._config[self._selectID]
    end

    if data.isInput and data.key == "MagicID" then
        local inputId = tonumber(sender:getString())
        if self._config[inputId] then
            sender:setString(self._selectID)
            ShowSystemTips("技能ID重复")
            return
        end
    end

    if data.localZorder then
        sender:setLocalZOrder(data.localZorder)
    end

    local isPC = self._config_type == 2
    local default = isPC and data.default_pc or data.default

    local value = nil
    if data.isCheckBox then -- checkbox
        value = not sender:isSelected()
        local values = data.checkBoxValues
        if not tonumber(value) then
            value = values[value]
        end
    elseif data.isSelect then
        value = sender.SelectIndex or default
        local list = sender:getChildByName("ListView_all")
        local isShow = list:isVisible()
        isShow = not isShow
        list:setVisible(isShow)
        sender:getChildByName("Image_arrow"):setRotation(isShow and 90 or 270)

        if isShow then
            list:removeAllChildren()
            local sz = list:getContentSize()
            local values = (isPC and data.selectValues_pc) or data.selectValues or {}
            for index, v in ipairs(values) do
                local item = self:CreateConfigSelectItem(data, index, sz)
                list:pushBackCustomItem(item)
            end
        end
    elseif data.isInput then
        value = sender:getString()
    elseif data.isImg then
        sender:loadTexture(string.format("%s%s.png", data.basePath, cfg.icon or ""))
    else
        return
    end
    self:UpdateConfigContorl(data, value, true)
end

--- 创建配置选择Item
---@param data table keys的数据
---@param index any selectValues的key
function MagicInfoConfigLayer:CreateConfigSelectItem(data, index, size)
    local customPanel = self._ui.Panel_custom
    local item = customPanel:getChildByName("Panel_multiple_item"):cloneEx()
    if size and size.width then
        local itemSizeH = item:getContentSize().height
        item:setContentSize(cc.size(size.width, itemSizeH))
        item:getChildByName("Text_name"):setPositionX(size.width / 2)
    end
    item:removeFromParent()

    local isPC = self._config_type == 2
    local values = isPC and data.selectValues_pc or data.selectValues or {}
    local selectData = values[index] or {}
    item:getChildByName("Text_name"):setString(selectData.name)

    item:addClickEventListener(function()
        -- local parent = self._ui[data.nodeName]
        local widget = self._ui[data.nodeName]
        widget.SelectIndex = selectData.id
        self:OnConfigEvent(widget, data)
    end)
    return item
end

--- 搜索事件
---@param markSkillStr string 记录上一次输入框的内容
---@param blurT table 模糊搜索表
function MagicInfoConfigLayer:OnSearchEvent(blurT, index)

    local skillID = blurT[index]
    if not skillID or not self._config[skillID] then
        ShowSystemTips("未找到对应的技能ID或者技能名称")
        return
    end

    if skillID and skillID ~= self._selectID then
        self:JumpMagicItem(skillID, true)
    else
        self._selectID = skillID
    end
end

function MagicInfoConfigLayer:OnNewAddEvent()
    local maxMagicID = table.maxn(self._config)
    local newAddID = maxMagicID + 1
    self._markAddID = newAddID
    self._config[newAddID] = {}
    local cfg = self._config[newAddID]
    for i, v in ipairs(keys or {}) do
        self:UpdateMagicData(newAddID, v.key, v.default)
    end
    self._config[newAddID].MagicID = newAddID
    self._selectID = newAddID
    self:UpdateMagicList(newAddID)
end

-- 复制新增事件
function MagicInfoConfigLayer:OnCopyNewAddEvent()
    if not self._selectID or not self._config[self._selectID] then
        ShowSystemTips("未选中需要复制的技能或者该数据已不存在")
        return
    end
    local maxSkillID = table.maxn(self._config)
    local newAddID = maxSkillID + 1
    self._markAddID = newAddID
    self._config[newAddID] = clone(self._config[self._selectID])
    self._config[newAddID].MagicID = newAddID
    self:UpdateMagicList(newAddID)
end

--- 多选事件
function MagicInfoConfigLayer:OnMultipleSlectEvent()
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
function MagicInfoConfigLayer:OnDelectEvent()
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
                    self._config[_id] = nil
                end
            else
                self._config[self._selectID] = nil
            end
            self:OnSaveDataReLoad()
            self:UpdateMagicList()
            ShowSystemTips("删除成功")
        end
    end
    local data = {}
    data.str = self._selects_state and string.format("多个数据将会被删除") or
                   string.format("将会删除ID: %s 的数据", self._selectID)
    data.btnType = 2
    data.callback = callback
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

--- 恢复事件
function MagicInfoConfigLayer:OnRecoverEvent()
    self._markAddID = nil
    local function callback(bType, custom)
        if bType == 1 then
            local devFilePath = "dev/scripts/game_config/cfg_magicinfo.lua"
            local filePath = "game_config/cfg_magicinfo"
            os.remove(devFilePath)
            global.FileUtilCtl:purgeCachedEntries()
            package.loaded[filePath] = nil
            require(filePath)
            self._config = clone(requireGameConfig("cfg_magicinfo"))
            self:UpdateMagicList(self._selectID)
        end
    end
    local data = {}
    data.str = "恢复将会删除dev目录下的cfg_magicinfo.lua文件"
    data.btnType = 2
    data.callback = callback
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

--- 保存数据事件
function MagicInfoConfigLayer:OnSaveEvent()
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
                    self:UpdateMagicData(self._selectID, v.key, v.default)
                end
            end
            self:OnSaveDataReLoad()
            self:UpdateMagicList(self._selectID)
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

function MagicInfoConfigLayer:OnOpenFileEvent(resPath, suffix)
    resPath = resPath or "res/skill_icon/"
    suffix = suffix or ""
    local suffixMap = {
        ["_n"] = {skillType = 2, cfgKey = "nIcon"},
        ["_j"] = {skillType = 4, cfgKey = "jIcon"}
    }
    local configKey = suffixMap[suffix] and suffixMap[suffix].cfgKey or "icon"
    if self._selectID then
        local skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
        local iconPath = skillProxy:GetIconRectPathByID(self._selectID)
        if iconPath then
            resPath = iconPath
        end
        if suffix and suffixMap[suffix] then
            local skillType = suffixMap[suffix].skillType
            iconPath = skillProxy:GetNGIconRectPath(self._selectID, skillType)
            resPath = iconPath or resPath
        end
    end
    local function callFunc(res)
        if not res or res == "" then
            self._ui["Text_file" .. suffix]:setString("未选中文件")
            return
        end
        self._ui["Image_skill_icon" .. suffix]:loadTexture(res)

        local pngName = string.gsub(res, "res/skill_icon/", "")
        local icon = string.gsub(pngName, ".png", "")
        icon = string.gsub(pngName, ".jpg", "")
        
        self:UpdateMagicData(self._selectID, configKey, icon)
        self._ui["Text_file" .. suffix]:setString(pngName)
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_GUIResSelector_Open, {
        res = resPath,
        callfunc = callFunc
    })
end

--- 保存数据
function MagicInfoConfigLayer:OnSaveDataReLoad()
    self._markAddID = nil
    SL:SaveTableToConfig(self._config, "cfg_magicinfo")
    global.FileUtilCtl:purgeCachedEntries()
    SL:Require("game_config/cfg_magicinfo", true)
end

function MagicInfoConfigLayer:UpdateConfigTypeButton()
    local isGMBright = not (self._config_type == 1)
    local isPCBright = not (self._config_type == 2)
    local isNGBright = not (self._config_type == 3)
    self._ui.Button_gm:setBright(isGMBright)
    self._ui.Button_gm:setTouchEnabled(isGMBright)
    self._ui.Button_pc:setBright(isPCBright)
    self._ui.Button_pc:setTouchEnabled(isPCBright)
    self._ui.Button_ng:setBright(isNGBright)
    self._ui.Button_ng:setTouchEnabled(isNGBright)
    if self._config_type == 1 or self._config_type == 2 then
        self:UpdateMagicConfig()
    end
    self._ui.Panel_ng_config:setVisible(not isNGBright)
    self._ui.TextField_priority_p:setVisible(isNGBright)
end

--- 关闭界面
function MagicInfoConfigLayer:OnClose()
    global.Facade:sendNotification(global.NoticeTable.Preview_Skill_Action_UnAttach)
end

return MagicInfoConfigLayer
