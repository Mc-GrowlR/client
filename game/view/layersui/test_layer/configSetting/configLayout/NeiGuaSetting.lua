NeiGuaSetting = {}

local sformat   = string.format
local sfind     = string.find
local sgsub     = string.gsub
local strim     = string.trim
local slen      = string.len
local ssplit    = string.split
local tInsert   = table.insert
local tRemove   = table.remove

local fileUtil    = global.FileUtilCtl
local pathRes     = "res/private/new_setting/icon/"
local defaultIcon = "res/private/gui_edit/ImageFile.png"

local configName  = "cfg_setup"

local pages = {
    "基础", "视距", "战斗", "保护", "挂机",
}

local SID = SLDefine.SETTINGID
local tItems = {{
        [SID.SETTING_IDX_PLAYER_NAME]           = "",             -- 人名显示
        [SID.SETTING_IDX_ONLY_NAME]             = "",               -- 只显人名
        [SID.SETTING_IDX_MONSTER_NAME]          = "",            -- 怪物显名
        [SID.SETTING_IDX_PLAYER_JOB_LEVEL]      = "",        -- 职业等级
        [SID.SETTING_IDX_HP_NUM]                = "",                  -- 数字显血
        [SID.SETTING_IDX_HP_HUD]                = "",                  -- 显示血条
        [SID.SETTING_IDX_HP_UNIT]               = "",                 -- 血量单位简写
        [SID.SETTING_IDX_LEVEL_SHOW_NAME_HUD]   = "",     -- 低于多少等级不显示等级
        [SID.SETTING_IDX_FRAME_RATE_TYPE_HIGH]  = "",     -- 高帧率模式
        [SID.SETTING_IDX_ONE_DOUBLE_ROCKER]     = "",       -- 单双摇杆
        [SID.SETTING_IDX_EQUIP_COMPARE]         = "",           -- 装备对比
        [SID.SETTING_IDX_DAMAGE_NUM]            = "",              -- 数字飘血
        [SID.SETTING_IDX_UNSAFE_TIPS]           = "",             -- 残血提示
        [SID.SETTING_IDX_AUTO_REPAIR]           = "",             -- 自动修理
        [SID.SETTING_IDX_DURABILITY_TIPS]       = "",         -- 持久提示
        [SID.SETTING_IDX_AUTO_PUT_IN_EQUIP]     = "",       -- 自动穿戴
        [SID.SETTING_IDX_LAYER_OPACITY]         = "",           -- 面板半透明
        [SID.SETTING_IDX_MONSTER_PET_VISIBLE]   = "",     -- 屏蔽宝宝
        [SID.SETTING_IDX_MONSTER_VISIBLE]       = "",         -- 屏蔽怪物
        [SID.SETTING_IDX_EFFECT_SHOW]           = "",             -- 屏蔽特效
        [SID.SETTING_IDX_TITLE_VISIBLE]         = "",           -- 隐藏称号
        [SID.SETTING_IDX_SKILL_EFFECT_SHOW]     = "",       -- 屏蔽技能
        [SID.SETTING_IDX_PLAYER_SHOW_FRIEND]    = "",      -- 屏蔽己方玩家
        [SID.SETTING_IDX_PLAYER_SIMPLE_DRESS]   = "",     -- 人物简装
        [SID.SETTING_IDX_MONSTER_SIMPLE_DRESS]  = "",    -- 怪物简装
        [SID.SETTING_IDX_BOSS_NO_SIMPLE_DRESS]  = "",    -- Boss不简装
        [SID.SETTING_IDX_IGNORE_STALL]          = "",       -- 屏蔽摆摊
        [SID.SETTING_IDX_BGMUSIC]               = "OneInput",                 -- 背景音乐
        [SID.SETTING_IDX_EFFECTMUSIC]           = "OneInput",             -- 游戏音乐
        [SID.SETTING_IDX_HERO_JOINT_SHAKE]      = "",        -- 合击震屏
        [SID.SETTING_IDX_HERO_HIDE]             = "",           -- 屏蔽英雄
        [SID.SETTING_IDX_WINDOW_SMOOTH_VIEW]    = "",             -- 平滑模式 win32才有
    },{
        [SID.SETTING_IDX_ROCKER_SHOW_DISTANCE]  = "OneInput",    -- 轮盘侧边距
        [SID.SETTING_IDX_SKILL_SHOW_DISTANCE]   = "OneInput",     -- 技能侧边距
        [SID.SETTING_IDX_CAMERA_ZOOM]           = "OneInput",             -- 地图缩放
    },{
        [SID.SETTING_IDX_HIDE_MONSTER_BODY]     = "",       -- 清理尸体
        [SID.SETTING_IDX_AUTO_MOVE]             = "",               -- 自动走位
        [SID.SETTING_IDX_ALWAYS_ATTACK]         = "",           -- 持续攻击
        [SID.SETTING_IDX_MAGIC_LOCK]            = "",              -- 魔法锁定
        [SID.SETTING_IDX_SKILL_NEXT_ATTACK]     = "",       -- 技能接平砍
        [SID.SETTING_IDX_ROCKER_CANCEL_ATTACK]  = "",    -- 摇杆取消攻击
        [SID.SETTING_IDX_BB_ATTACK_WITH]        = "",          -- 宝宝跟随
        [SID.SETTING_IDX_DU_FU_AUTOCHANGE]      = "",        -- 毒符互换
        [SID.SETTING_IDX_EXP_IGNORE]            = "",              -- 经验过滤
        [SID.SETTING_IDX_AUTO_LAUNCH]           = "",             -- 自动练功
        [SID.SETTING_IDX_BOSS_TIPS]             = "BossTips",               -- boss提醒
        [SID.SETTING_IDX_PICK_SETTING]          = "",           -- 拾取设置
        [SID.SETTING_IDX_HERO_AUTO_JOINT]       = "",         -- 自动合击
        [SID.SETTING_IDX_HERO_FOLLOW_ATTACK]    = "",      -- 跟随主角攻击
        [SID.SETTING_IDX_HERO_AUTO_LOGIN]       = "",         -- 自动召唤英雄
        [SID.SETTING_IDX_HERO_ATTACK_DODGE]     = "",       -- 英雄打怪躲避
        [SID.SETTING_IDX_DAODAOCISHA]           = "",             -- 刀刀刺杀
        [SID.SETTING_IDX_GEWEICISHA]            = "",              -- 隔位刺杀
        [SID.SETTING_IDX_MOVE_GEWEI_CISHA]      = "",        -- 移动隔位刺杀
        [SID.SETTING_IDX_SMART_BANYUE]          = "",            -- 智能半月 
        [SID.SETTING_IDX_AUTO_LIEHUO]           = "",             -- 自动烈火剑法
        [SID.SETTING_IDX_NEAR_LIEHUO]           = "",             -- 近身烈火    
        [SID.SETTING_IDX_AUTO_KAITIAN]          = "",            -- 自动开天 
        [SID.SETTING_IDX_AUTO_ZHURI]            = "",              -- 自动逐日剑法   
        [SID.SETTING_IDX_AUTO_SHIELD_OF_FORCE]  = "",    -- 武力盾       
        [SID.SETTING_IDX_AUTO_FIRE_WALL]        = "",          -- 自动火墙
        [SID.SETTING_IDX_AUTO_MOFADUN]          = "",            -- 自动魔法盾
        [SID.SETTING_IDX_AUTO_DU]               = "",                 -- 自动施毒
        [SID.SETTING_IDX_AUTO_YOULINGDUN]       = "",         -- 自动幽灵盾
        [SID.SETTING_IDX_AUTO_SSZJS]            = "",              -- 自动神圣战甲术
        [SID.SETTING_IDX_AUTO_CLOAKING]         = "",           -- 自动隐身
        [SID.SETTING_IDX_AUTO_WJZQ]             = "",               -- 自动无极真气
        [SID.SETTING_IDX_AUTO_SUMMON]           = "",             -- 自动召唤
        [SID.SETTING_IDX_AUTO_SHIELD_OF_TAOIST] = "",   -- 道力盾
        [SID.SETTING_IDX_NOT_NEED_SHIFT]        = "",          -- 免shift
        [SID.SETTING_IDX_AUTO_COMBO]            = "",           -- 自动连击
        [SID.SETTING_IDX_AUTO_ICE_PALM]         = "",           -- 自动寒冰掌
        [SID.SETTING_IDX_AUTO_BLOODTHIRSTY_S]   = "",           -- 自动噬血术
        [SID.SETTING_IDX_AUTO_BREACH_NERVE_FU]  = "",           -- 自动裂神符
        [SID.SETTING_IDX_AUTO_DEATH_EYE]        = "",           -- 自动死亡之眼
        [SID.SETTING_IDX_AUTO_ICE_SICKLE_S]     = "",           -- 自动冰镰术
        [SID.SETTING_IDX_AUTO_FLAME_ICE]        = "",           -- 自动火焰冰
        [SID.SETTING_IDX_AUTO_ICE_GROUP_RAIN]   = "",           -- 自动冰霜群雨
        [SID.SETTING_IDX_AUTO_DOUBLE_DRAGON_Z]  = "",           -- 自动双龙斩
        [SID.SETTING_IDX_AUTO_DRAGON_SHADOW_JF] = "",           -- 自动龙影剑法
        [SID.SETTING_IDX_AUTO_THUNDERBOLT_JF]   = "",           -- 自动雷霆剑法
        [SID.SETTING_IDX_AUTO_FREELY_JS]        = "",           -- 自动纵横剑术
    },{
        [SID.SETTING_IDX_HP_PROTECT1]           = "Protect",             -- 生命值低于多少使用
        [SID.SETTING_IDX_HP_PROTECT2]           = "Protect",             -- 生命值低于多少使用
        [SID.SETTING_IDX_HP_PROTECT3]           = "Protect",             -- 生命值低于多少使用
        [SID.SETTING_IDX_HP_PROTECT4]           = "Protect",             -- 生命值低于多少使用
        [SID.SETTING_IDX_MP_PROTECT1]           = "Protect",             -- 魔法值低于多少使用
        [SID.SETTING_IDX_MP_PROTECT2]           = "Protect",             -- 魔法值低于多少使用
        [SID.SETTING_IDX_MP_PROTECT3]           = "Protect",             -- 魔法值低于多少使用
        [SID.SETTING_IDX_MP_PROTECT4]           = "Protect",             -- 魔法值低于多少使用
        [SID.SETTING_IDX_PK_PROTECT]            = "Protect",             -- 红名保护
        [SID.SETTING_IDX_HP_LOW_USE_SKILL]      = "Protect",             -- 生命低于多少使用  
        [SID.SETTING_IDX_REVIVE_PROTECT]        = "Protect",             -- 复活保护  
        [SID.SETTING_IDX_REVIVE_PROTECT_HERO]   = "Protect",             -- 英雄复活保护  
        [SID.SETTING_IDX_HERO_HP_PROTECT1]      = "Protect",        -- 生命值低于多少使用
        [SID.SETTING_IDX_HERO_HP_PROTECT2]      = "Protect",        -- 生命值低于多少使用
        [SID.SETTING_IDX_HERO_HP_PROTECT3]      = "Protect",        -- 生命值低于多少使用
        [SID.SETTING_IDX_HERO_HP_PROTECT4]      = "Protect",        -- 生命值低于多少使用
        [SID.SETTING_IDX_HERO_MP_PROTECT1]      = "Protect",        -- 魔法值低于多少使用
        [SID.SETTING_IDX_HERO_MP_PROTECT2]      = "Protect",        -- 魔法值低于多少使用
        [SID.SETTING_IDX_HERO_MP_PROTECT3]      = "Protect",        -- 魔法值低于多少使用
        [SID.SETTING_IDX_HERO_MP_PROTECT4]      = "Protect",        -- 魔法值低于多少使用
        [SID.SETTING_IDX_HERO_AUTO_LOGINOUT]    = "Protect",        -- 英雄生命值低于多少自动收回              
    },{
        [SID.SETTING_IDX_BEDAMAGED_PLAYER]      = "BeDamaged",        -- 被玩家攻击时
        [SID.SETTING_IDX_N_RANGE_NO_PICK]       = "Protect",         -- N范围内有多少怪 不走去拾取
        [SID.SETTING_IDX_AUTO_GROUPSKILL]       = "",         -- 群怪技能
        [SID.SETTING_IDX_FIRST_ATTACK_MASTER]   = "",     -- 受到BB攻击时先打主人
        [SID.SETTING_IDX_AUTO_SIMPSKILL]        = "",          -- 单体技能
        [SID.SETTING_IDX_NO_ATTACK_HAVE_BELONG] = "",   -- 不抢别人归属怪物        
        [SID.SETTING_IDX_NO_MONSTAER_USE]       = "Protect",         -- 多少秒没怪物使用
        [SID.SETTING_IDX_BESIEGE_FLEE]          = "Protect",            -- 周围有多少敌人时使用
        [SID.SETTING_IDX_RED_BESIEGE_FLEE]      = "Protect",        -- 周围有多少红名时使用
        [SID.SETTING_IDX_ENEMY_ATTACK]          = "Protect",            -- 周围有敌人时主动攻击   
        [SID.SETTING_IDX_IGNORE_MONSTER]        = "BossTips",          -- 忽略怪物     
    }
}

local MT = global.SUIComponentTable
local tPos = {
    [MT.MainRootLT] = "左上",
    [MT.MainRootRT] = "右上",
    [MT.MainRootLB] = "左下",
    [MT.MainRootRB] = "右下",
    [MT.MainRootLM] = "左中",
    [MT.MainRootTM] = "上中",
    [MT.MainRootRM] = "右中",
    [MT.MainRootBM] = "下中",
}

local tPlatform = {
    [0]  = "通用",
    [1]  = "PC",
    [2]  = "手机",
    [99] = "不显示",
}

function NeiGuaSetting.main(parent)
    if not parent then
        return
    end

    loadConfigSettingExport(parent, "neigua_setting")

    NeiGuaSetting._ui = GUI:ui_delegate(parent)
   
    NeiGuaSetting._pages = {}
    NeiGuaSetting._index = 1
    NeiGuaSetting._openFile = nil

    NeiGuaSetting._items = {}
    NeiGuaSetting._itemIdx = 1

    NeiGuaSetting.panel_item = NeiGuaSetting._ui["panel_item"]
    NeiGuaSetting.Node_attach = NeiGuaSetting._ui["Node_attach"]

    NeiGuaSetting._config = SL:Require("game_config/" .. configName, true)

    NeiGuaSetting._Attr = {
        ["input_name"]      = { t = 1, IMode = 6, SetData = NeiGuaSetting.setName,   SetUI = NeiGuaSetting.setUIName },
        ["input_desc"]      = { t = 1, IMode = 6, SetData = NeiGuaSetting.setDesc,   SetUI = NeiGuaSetting.setUIDesc },
        ["input_open_x"]    = { t = 1, IMode = 6, SetData = NeiGuaSetting.setOpenX,  SetUI = NeiGuaSetting.setUIOpenX },
        ["input_open_y"]    = { t = 1, IMode = 6, SetData = NeiGuaSetting.setOpenY,  SetUI = NeiGuaSetting.setUIOpenY },
        ["input_close_x"]   = { t = 1, IMode = 6, SetData = NeiGuaSetting.setCloseX, SetUI = NeiGuaSetting.setUICloseX },
        ["input_close_y"]   = { t = 1, IMode = 6, SetData = NeiGuaSetting.setCloseY, SetUI = NeiGuaSetting.setUICloseY },
        ["btn_res_open"]    = { t = 2, SetUI = NeiGuaSetting.setIconOpen,  func = NeiGuaSetting.openIconSelector },
        ["btn_res_close"]   = { t = 2, SetUI = NeiGuaSetting.setIconClose, func = NeiGuaSetting.closeIconSelector },
        ["bg_platform"]     = { t = 2, SetUI = NeiGuaSetting.setPlatform,  func = NeiGuaSetting.onSetPlatform },
        ["bg_open"]         = { t = 2, SetUI = NeiGuaSetting.setOpenPos,   func = NeiGuaSetting.onSetOpenPos },
        ["bg_close"]        = { t = 2, SetUI = NeiGuaSetting.setClosePos,  func = NeiGuaSetting.onSetClosePos },
        ["btn_reset_open"]  = { t = 2, func = NeiGuaSetting.onResetOpen },
        ["btn_reset_close"] = { t = 2, func = NeiGuaSetting.onResetClose },
    }  

    NeiGuaSetting.initEvent()

    NeiGuaSetting.initPullDownCells()

    NeiGuaSetting.initPages()

    NeiGuaSetting.initMainPosJobName()

    local fadein = GUI:ActionFadeIn(1)
    local fadeout = GUI:ActionFadeOut(1)
    local action = GUI:ActionRepeatForever(GUI:ActionSequence(fadeout, fadein))
    GUI:runAction(NeiGuaSetting._ui["Text_notice"], action)
end

function NeiGuaSetting.initPages()
    local ListView_page = NeiGuaSetting._ui["ListView_page"]
    GUI:ListView_addMouseScrollPercent(ListView_page)

    local function createCell(parent, k, v)
        local pageCell = GUI:Layout_Create(parent, "page_cell", 0, 0, 100, 50, false)
        GUI:Layout_setBackGroundColorType(pageCell, 1)
        GUI:Layout_setBackGroundColor(pageCell, NeiGuaSetting._index == k and "#ffbf6b" or "#000000")
        GUI:Layout_setBackGroundColorOpacity(pageCell, 140)
        GUI:setTouchEnabled(pageCell, true)

        local PageText = GUI:Text_Create(pageCell, "PageText", 50, 25, 16, "#ffffff", v)
        GUI:setAnchorPoint(PageText, 0.5, 0.5)
        GUI:Text_setTextHorizontalAlignment(PageText, 1)
        GUI:Text_enableOutline(PageText, "#000000", 1)

        GUI:addOnClickEvent(pageCell, function()
            NeiGuaSetting._index = k
            NeiGuaSetting.refreshCells()

            NeiGuaSetting._itemIdx = 1
            NeiGuaSetting.updateItems()

            NeiGuaSetting._isMobile = true
            NeiGuaSetting.setPlatformPageState()
        end)

        return pageCell
    end

    for k, v in ipairs(pages) do
        local quickCell = GUI:QuickCell_Create(ListView_page, "quickCell"..k, 0, 0, 100, 50, function(parent)
            return createCell(parent, k, v)
        end)

        NeiGuaSetting._pages[k] = quickCell
    end

    NeiGuaSetting.updateItems()

    NeiGuaSetting._isMobile = true
    NeiGuaSetting.setPlatformPageState()
end

-- 刷新 ListView
function NeiGuaSetting.refreshCells()
    for index, cell in ipairs(NeiGuaSetting._pages) do
        if cell then
            cell:Exit()
            cell:Refresh()
        end
    end
end

local function getConfigFunc(group)
    local configs = {}
    local config
    for i, id in ipairs(group) do
        config = SL:GetMetaValue("SETTING_CONFIG", id)
        if config then
            if not config.order or  not tonumber(config.order) then
                config.order = 0 
            end
            table.insert(configs, config)
        end
    end
    table.sort(configs, function(a, b)
        return a.order < b.order
    end)
    return configs
end

function NeiGuaSetting.updateItems()
    local ListView_items = NeiGuaSetting._ui["ListView_items"]
    GUI:ListView_addMouseScrollPercent(ListView_items)
    GUI:ListView_removeAllItems(ListView_items)
    NeiGuaSetting._items = {}

    local function createCell(parent, k, v)
        local itemCell = GUI:Clone(NeiGuaSetting.panel_item)
        local itemUI = GUI:ui_delegate(itemCell)

        GUI:Layout_setBackGroundColor(itemUI["nativeUI"], NeiGuaSetting._itemIdx == k and "#ffbf6b" or "#000000")

        if NeiGuaSetting._itemIdx == k then
            NeiGuaSetting.updateContent(v)
        end

        GUI:Text_setString(itemUI["id"], v.id)
        GUI:Text_setString(itemUI["name"], v.content)
        local width = GUI:getContentSize(itemUI["name"]).width
        local pos = GUI:getPosition(itemUI["name"])
        if width > 255 then
            GUI:setVisible(itemUI["name"], false)
            local SCROLL = GUI:ScrollText_Create(itemCell, "SCROLL", pos.x, pos.y, 255, 14, "#ffffff", v.content)
            GUI:setAnchorPoint(SCROLL, 0.5, 0.5)
        end

        GUI:addOnClickEvent(itemCell, function()
            NeiGuaSetting._itemIdx = k
            NeiGuaSetting.refreshItemCells()
            NeiGuaSetting.updateContent(v)
        end)

        GUI:setVisible(itemCell, true)
        GUI:addChild(parent, itemCell)

        return itemCell
    end

    local items = getConfigFunc(table.keys(tItems[NeiGuaSetting._index]))
    for k, v in ipairs(items) do
        local quickCell = GUI:QuickCell_Create(ListView_items, "quickCellItem"..k, 0, 0, 100, 30, function(parent)
            return createCell(parent, k, v)
        end)

        NeiGuaSetting._items[k] = quickCell
    end    
end

-- 刷新 ListView
function NeiGuaSetting.refreshItemCells()
    for index, cell in ipairs(NeiGuaSetting._items) do
        if cell then
            cell:Exit()
            cell:Refresh()
        end
    end
end

function NeiGuaSetting.initEvent()
    -- 全局保存
    local btn_sure = NeiGuaSetting._ui["btn_sure"]
    GUI:addOnClickEvent(btn_sure, function()
        GUI:delayTouchEnabled(btn_sure, 0.5)

        local extraCfg = NeiGuaSetting._openFile.getValue()
        if next(extraCfg) then
            table.merge(NeiGuaSetting._cloneCfg, extraCfg)
        end
        
        for key, value in pairs(NeiGuaSetting._config) do
            if value.id == NeiGuaSetting._cloneCfg.id then
                NeiGuaSetting._config[key] = clone(NeiGuaSetting._cloneCfg)
                
                dump(NeiGuaSetting._pos, "NeiGuaSetting._pos:::", 10)

                if NeiGuaSetting._pos then
                    local tmpNormal, tmpPress, filterJob = "", "", ""
        
                    local normalM, normalPc = "", ""
                    if NeiGuaSetting._pos.open then
                        if NeiGuaSetting._pos.open.mobile then
                            local lid = tonumber(NeiGuaSetting._pos.open.mobile.lid) or ""
                            local x = tonumber(NeiGuaSetting._pos.open.mobile.x) or ""
                            local y = tonumber(NeiGuaSetting._pos.open.mobile.y) or ""
                            local brightPath = NeiGuaSetting._pos.open.mobile.icon or ""
                            normalM = brightPath .. "#" .. lid .. "#" .. x .. "#" .. y
                        end
                        if NeiGuaSetting._pos.open.pc then
                            local lid = tonumber(NeiGuaSetting._pos.open.pc.lid) or ""
                            local x = tonumber(NeiGuaSetting._pos.open.pc.x) or ""
                            local y = tonumber(NeiGuaSetting._pos.open.pc.y) or ""
                            local brightPath = NeiGuaSetting._pos.open.pc.icon or ""
                            normalPc = brightPath .. "#" .. lid .. "#" .. x .. "#" .. y
                        end
                        tmpNormal = normalM .. "|" .. normalPc
                    end
        
                    local pressM, pressPc = "", ""
                    if NeiGuaSetting._pos.close then
                        if NeiGuaSetting._pos.close.mobile then
                            local lid = tonumber(NeiGuaSetting._pos.close.mobile.lid) or ""
                            local x = tonumber(NeiGuaSetting._pos.close.mobile.x) or ""
                            local y = tonumber(NeiGuaSetting._pos.close.mobile.y) or ""
                            local brightPath = NeiGuaSetting._pos.close.mobile.icon or ""
                            pressM = brightPath .. "#" .. lid .. "#" .. x .. "#" .. y
                        end
                        if NeiGuaSetting._pos.close.pc then
                            local lid = tonumber(NeiGuaSetting._pos.close.pc.lid) or ""
                            local x = tonumber(NeiGuaSetting._pos.close.pc.x) or ""
                            local y = tonumber(NeiGuaSetting._pos.close.pc.y) or ""
                            local brightPath = NeiGuaSetting._pos.close.pc.icon or ""
                            pressPc = brightPath .. "#" .. lid .. "#" .. x .. "#" .. y
                        end
                        tmpPress = pressM .. "|" .. pressPc
                    end

                    if NeiGuaSetting._pos.job ~= 3 then
                        filterJob = NeiGuaSetting._pos.job
                    end
        
                    NeiGuaSetting._config[key].mainpos = tmpNormal .. "&" .. tmpPress .. "&" .. filterJob
                end  -- NeiGuaSetting._pos

                break
            end  -- value.id == NeiGuaSetting._cloneCfg.id
        end  -- for key, value in pairs(NeiGuaSetting._config)

        SL:SaveTableToConfig(NeiGuaSetting._config, configName)
        global.FileUtilCtl:purgeCachedEntries()
        local GameSettingProxy = global.Facade:retrieveProxy(global.ProxyTable.GameSettingProxy)
        GameSettingProxy:LoadConfig()
        NeiGuaSetting._config = SL:Require("game_config/" .. configName, true)
        SL:ShowSystemTips("保存成功")
    end)

    NeiGuaSetting._selUIControl = {}
    NeiGuaSetting._InputValues = {}

    for name, d in pairs(NeiGuaSetting._Attr) do
        local widget = NeiGuaSetting._ui[name]
        if widget then
            if d.t == 1 then
                GUI:TextInput_setInputMode(widget, d.IMode)
                NeiGuaSetting._selUIControl[name] = widget
                NeiGuaSetting.initTextInputEvent(widget)
            elseif d.t == 2 then
                GUI:addOnClickEvent(widget, d.func)
                NeiGuaSetting._selUIControl[name] = widget
            end
        end
    end

    GUI:addOnClickEvent(NeiGuaSetting._ui["Layout_mobile"], function()
        NeiGuaSetting._isMobile = true
        NeiGuaSetting._isSelShowControl = false
        NeiGuaSetting.setPlatformPageState()
        NeiGuaSetting.updateUIControl()
    end)

    GUI:addOnClickEvent(NeiGuaSetting._ui["Layout_pc"], function()
        NeiGuaSetting._isMobile = false
        NeiGuaSetting._isSelShowControl = false
        NeiGuaSetting.setPlatformPageState()
        NeiGuaSetting.updateUIControl()
    end)

    GUI:addOnClickEvent(NeiGuaSetting._ui["Layout_show"], function()
        NeiGuaSetting._isSelShowControl = true
        NeiGuaSetting.setPlatformPageState()
        NeiGuaSetting.updateUIControl()
    end)
end

function NeiGuaSetting.setPlatformPageState()
    if NeiGuaSetting._isSelShowControl then
        GUI:Layout_setBackGroundColor(NeiGuaSetting._ui["Layout_show"], "#ffbf6b")
        GUI:Layout_setBackGroundColor(NeiGuaSetting._ui["Layout_mobile"], "#000000")
        GUI:Layout_setBackGroundColor(NeiGuaSetting._ui["Layout_pc"], "#000000")
        GUI:setVisible(NeiGuaSetting._ui["LayoutShowControl"], true)
    else
        GUI:Layout_setBackGroundColor(NeiGuaSetting._ui["Layout_show"], "#000000")
        GUI:Layout_setBackGroundColor(NeiGuaSetting._ui["Layout_mobile"], NeiGuaSetting._isMobile and "#ffbf6b" or "#000000")
        GUI:Layout_setBackGroundColor(NeiGuaSetting._ui["Layout_pc"], NeiGuaSetting._isMobile and "#000000" or "#ffbf6b")
        GUI:setVisible(NeiGuaSetting._ui["LayoutShowControl"], false)
    end
end

function NeiGuaSetting.initTextInputEvent(widget)
    widget:addEventListener(function(ref, eventType)
        local name = ref:getName()
        local ui = NeiGuaSetting._Attr[name]
        if not ui then
            return false
        end
        local mode = ui.IMode
        local max  = nil
        local min  = 0
        local str  = ref:getString()

        if eventType == 1 then
            if mode == 2 then
                str = string.trim(str)
                str = tonumber(str) or 0
                if min and str < min then
                    str = min
                end
                if max then
                    str = math.max(math.min(str, max), 0)
                end
                ref:setString(str)
                NeiGuaSetting.updateUIAttr(name, str)
                NeiGuaSetting._InputValues[name] = str
            else
                if slen(str or "") <= 0 then
                    ref:setString(NeiGuaSetting._InputValues[name] or "")
                    return false
                end
                ref:setString(str)
                NeiGuaSetting.updateUIAttr(name, str)
                NeiGuaSetting._InputValues[name] = str
            end
        end
    end)
end

function NeiGuaSetting.updateUIAttr(name, value)
    if name and NeiGuaSetting._Attr[name] and NeiGuaSetting._Attr[name].SetData then
        NeiGuaSetting._Attr[name].SetData(value)
    end
    NeiGuaSetting.updateUIControl()
end

function NeiGuaSetting.updateUIControl()
    for name, _ in pairs(NeiGuaSetting._selUIControl) do
        if NeiGuaSetting._Attr[name] and NeiGuaSetting._Attr[name].SetUI then
            NeiGuaSetting._Attr[name].SetUI(NeiGuaSetting._selUIControl[name])
        end
    end
end

function NeiGuaSetting.setName(value)
    NeiGuaSetting._cloneCfg.content = value
end

function NeiGuaSetting.setUIName(widget)
    widget:setString(NeiGuaSetting._cloneCfg.content or "")
end

function NeiGuaSetting.setDesc(value)
    NeiGuaSetting._cloneCfg.tips = value
end

function NeiGuaSetting.setUIDesc(widget)
    widget:setString(NeiGuaSetting._cloneCfg.tips or "")
    local Node_desc = NeiGuaSetting._ui["Node_desc"]
    Node_desc:removeAllChildren()
    GUI:RichText_Create(Node_desc, "rich", 0, 0, NeiGuaSetting._cloneCfg.tips or "", 9999)
end

function NeiGuaSetting.setOpenX(value)
    NeiGuaSetting._pos = NeiGuaSetting._pos or {}
    local item = NeiGuaSetting._pos
    if NeiGuaSetting._isMobile then
        item.open = item.open or {}
        item.open.mobile = item.open.mobile or {}
        item.open.mobile.x = tonumber(value)
    else
        item.open = item.open or {}
        item.open.pc = item.open.pc or {}
        item.open.pc.x = tonumber(value)
    end
end

function NeiGuaSetting.setUIOpenX(widget)
    local item = NeiGuaSetting._pos
    local x = ""
    if NeiGuaSetting._isMobile then
        x = item and item.open and item.open.mobile and item.open.mobile.x or ""
    else
        x = item and item.open and item.open.pc and item.open.pc.x or ""
    end
    widget:setString(x)
end

function NeiGuaSetting.setOpenY(value)
    NeiGuaSetting._pos = NeiGuaSetting._pos or {}
    local item = NeiGuaSetting._pos
    if NeiGuaSetting._isMobile then
        item.open = item.open or {}
        item.open.mobile = item.open.mobile or {}
        item.open.mobile.y = tonumber(value)
    else
        item.open = item.open or {}
        item.open.pc = item.open.pc or {}
        item.open.pc.y = tonumber(value)
    end
end

function NeiGuaSetting.setUIOpenY(widget)
    local item = NeiGuaSetting._pos
    local y = ""
    if NeiGuaSetting._isMobile then
        y = item and item.open and item.open.mobile and item.open.mobile.y or ""
    else
        y = item and item.open and item.open.pc and item.open.pc.y or ""
    end
    widget:setString(y)
end

function NeiGuaSetting.setCloseX(value)
    NeiGuaSetting._pos = NeiGuaSetting._pos or {}
    local item = NeiGuaSetting._pos
    if NeiGuaSetting._isMobile then
        item.close = item.close or {}
        item.close.mobile = item.close.mobile or {}
        item.close.mobile.x = tonumber(value)
    else
        item.close = item.close or {}
        item.close.pc = item.close.pc or {}
        item.close.pc.x = tonumber(value)
    end
end

function NeiGuaSetting.setUICloseX(widget)
    local item = NeiGuaSetting._pos
    local x = ""
    if NeiGuaSetting._isMobile then
        x = item and item.close and item.close.mobile and item.close.mobile.x or ""
    else
        x = item and item.close and item.close.pc and item.close.pc.x or ""
    end
    widget:setString(x)
end

function NeiGuaSetting.setCloseY(value)
    NeiGuaSetting._pos = NeiGuaSetting._pos or {}
    local item = NeiGuaSetting._pos
    if NeiGuaSetting._isMobile then
        item.close = item.close or {}
        item.close.mobile = item.close.mobile or {}
        item.close.mobile.y = tonumber(value)
    else
        item.close = item.close or {}
        item.close.pc = item.close.pc or {}
        item.close.pc.y = tonumber(value)
    end
end

function NeiGuaSetting.setUICloseY(widget)
    local item = NeiGuaSetting._pos
    local y = ""
    if NeiGuaSetting._isMobile then
        y = item and item.close and item.close.mobile and item.close.mobile.y or ""
    else
        y = item and item.close and item.close.pc and item.close.pc.y or ""
    end
    widget:setString(y)
end

function NeiGuaSetting.openIconSelector()
    -- 选择文件
    local function callFunc(res)
        if not res or res == "" then
            return
        end

        if not string.find(res, pathRes) then
            return
        end

        NeiGuaSetting._pos = NeiGuaSetting._pos or {}
        local item = NeiGuaSetting._pos
        if NeiGuaSetting._isMobile then
            item.open = item.open or {}
            item.open.mobile = item.open.mobile or {}
            item.open.mobile.icon = sgsub(res, pathRes, "")
        else
            item.open = item.open or {}
            item.open.pc = item.open.pc or {}
            item.open.pc.icon = sgsub(res, pathRes, "")
        end            

        NeiGuaSetting.updateUIControl()
    end

    local item = NeiGuaSetting._pos
    local icon = ""
    if NeiGuaSetting._isMobile then
        icon = item and item.open and item.open.mobile and item.open.mobile.icon or ""
    else
        icon = item and item.open and item.open.pc and item.open.pc.icon or ""
    end
    local iconPath = pathRes .. (icon == "" and "mpbar.png" or icon)

    global.Facade:sendNotification(global.NoticeTable.Layer_GUIResSelector_Open, { res = iconPath, callfunc = callFunc })
end

function NeiGuaSetting.setIconOpen(widget)
    local item = NeiGuaSetting._pos
    local icon = ""
    if NeiGuaSetting._isMobile then
        icon = item and item.open and item.open.mobile and item.open.mobile.icon or ""
    else
        icon = item and item.open and item.open.pc and item.open.pc.icon or ""
    end
    local iconPath = icon == "" and defaultIcon or (pathRes .. icon)
    if fileUtil:isFileExist(iconPath) then
        GUI:Image_loadTexture(NeiGuaSetting._ui["img_res_open"], iconPath)
    end
end

function NeiGuaSetting.closeIconSelector()
    -- 选择文件
    local function callFunc(res)
        if not res or res == "" then
            return
        end

        if not string.find(res, pathRes) then
            return
        end

        NeiGuaSetting._pos = NeiGuaSetting._pos or {}
        local item = NeiGuaSetting._pos
        if NeiGuaSetting._isMobile then
            item.close = item.close or {}
            item.close.mobile = item.close.mobile or {}
            item.close.mobile.icon = sgsub(res, pathRes, "")
        else
            item.close = item.close or {}
            item.close.pc = item.close.pc or {}
            item.close.pc.icon = sgsub(res, pathRes, "")
        end 

        NeiGuaSetting.updateUIControl()
    end

    local item = NeiGuaSetting._pos
    local icon = ""
    if NeiGuaSetting._isMobile then
        icon = item and item.close and item.close.mobile and item.close.mobile.icon or ""
    else
        icon = item and item.close and item.close.pc and item.close.pc.icon or ""
    end
    local iconPath = pathRes .. (icon == "" and "mpbar.png" or icon)

    global.Facade:sendNotification(global.NoticeTable.Layer_GUIResSelector_Open, { res = iconPath, callfunc = callFunc })
end

function NeiGuaSetting.setIconClose(widget)
    local item = NeiGuaSetting._pos
    local icon = ""
    if NeiGuaSetting._isMobile then
        icon = item and item.close and item.close.mobile and item.close.mobile.icon or ""
    else
        icon = item and item.close and item.close.pc and item.close.pc.icon or ""
    end
    local iconPath = icon == "" and defaultIcon or (pathRes .. icon)
    if fileUtil:isFileExist(iconPath) then
        GUI:Image_loadTexture(NeiGuaSetting._ui["img_res_close"], iconPath)
    end
end

function NeiGuaSetting.showItems(items, callBackFunc, maxHeight)
    GUI:ListView_removeAllItems(NeiGuaSetting.ListView_pulldown)

    local keys = table.keys(items)
    table.sort(keys)

    local maxWidth = 80

    for _, key in ipairs(keys) do
        local Image_bg = GUI:Image_Create(NeiGuaSetting.ListView_pulldown, "Image_bg"..key, 0, 0, "res/public/1900000668.png")
        GUI:Image_setScale9Slice(Image_bg, 51, 51, 10, 10)
        GUI:setContentSize(Image_bg, 80, 28)
        GUI:setIgnoreContentAdaptWithSize(Image_bg, false)
        GUI:setTouchEnabled(Image_bg, true)

        local text_name = GUI:Text_Create(Image_bg, "text_name", 40, 14, 14, "#FFFFFF", items[key])
        GUI:setAnchorPoint(text_name, 0.5, 0.5)
        local width = GUI:getContentSize(text_name).width
        width = math.max(width, 80)
        maxWidth = math.max(maxWidth, width)

        GUI:addOnClickEvent(Image_bg, function()
            callBackFunc(key)
            NeiGuaSetting.hidePullDownCells()
        end)
    end

    local height = math.min(28 * #keys, maxHeight or 9999999)

    GUI:setContentSize(NeiGuaSetting.ListView_pulldown, maxWidth, height)
    GUI:setContentSize(NeiGuaSetting.Image_pulldown_bg, maxWidth + 2, height + 2)
    GUI:setPositionY(NeiGuaSetting.ListView_pulldown, height + 1)

    for _, item in ipairs(GUI:ListView_getItems(NeiGuaSetting.ListView_pulldown)) do
        GUI:setContentSize(item, maxWidth, 28)
        GUI:setPositionX(GUI:getChildByName(item, "text_name"), maxWidth / 2)
    end
end

function NeiGuaSetting.setPlatform(widget)
    local strPlatform = tPlatform[NeiGuaSetting._cloneCfg.platform or 0]
    GUI:Text_setString(NeiGuaSetting._ui["Text_platform"], strPlatform)
end

function NeiGuaSetting.onSetPlatform()
    NeiGuaSetting.showItems(tPlatform, function(index)
        NeiGuaSetting._cloneCfg.platform = index
        GUI:Text_setString(NeiGuaSetting._ui["Text_platform"], tPlatform[index])
    end)

    local node_pos = GUI:getPosition(NeiGuaSetting._ui["bg_platform"])
    GUI:setAnchorPoint(NeiGuaSetting.Image_pulldown_bg, 0.5, 1)
    GUI:setPosition(NeiGuaSetting.Image_pulldown_bg, node_pos.x, node_pos.y)
    GUI:setVisible(NeiGuaSetting.Image_pulldown_bg, true)
    GUI:setVisible(NeiGuaSetting.Layout_hide_pullDownList, true)
    GUI:setRotation(NeiGuaSetting._ui["arrow_platform"], 180)    
end

function NeiGuaSetting.setOpenPos(widget)
    local item = NeiGuaSetting._pos
    local posIdx = ""
    if NeiGuaSetting._isMobile then
        posIdx = item and item.open and item.open.mobile and item.open.mobile.lid or nil
    else
        posIdx = item and item.open and item.open.pc and item.open.pc.lid or nil
    end

    GUI:Text_setString(NeiGuaSetting._ui["Text_open"], "")
    if posIdx then
        GUI:Text_setString(NeiGuaSetting._ui["Text_open"], tPos[posIdx] or "")
    end
end

function NeiGuaSetting.onSetOpenPos()
    NeiGuaSetting.showItems(tPos, function(index)
        NeiGuaSetting._pos = NeiGuaSetting._pos or {}
        local item = NeiGuaSetting._pos
        if NeiGuaSetting._isMobile then
            item.open = item.open or {}
            item.open.mobile = item.open.mobile or {}
            item.open.mobile.lid = index
        else
            item.open = item.open or {}
            item.open.pc = item.open.pc or {}
            item.open.pc.lid = index
        end

        GUI:Text_setString(NeiGuaSetting._ui["Text_open"], tPos[index])
    end)

    local node_pos = GUI:getPosition(NeiGuaSetting._ui["bg_open"])
    GUI:setAnchorPoint(NeiGuaSetting.Image_pulldown_bg, 0.5, 0)
    GUI:setPosition(NeiGuaSetting.Image_pulldown_bg, node_pos.x, node_pos.y)
    GUI:setVisible(NeiGuaSetting.Image_pulldown_bg, true)
    GUI:setVisible(NeiGuaSetting.Layout_hide_pullDownList, true)
    GUI:setRotation(NeiGuaSetting._ui["arrow_open"], 0)  
end

function NeiGuaSetting.setClosePos(widget)
    local item = NeiGuaSetting._pos
    local posIdx = ""
    if NeiGuaSetting._isMobile then
        posIdx = item and item.close and item.close.mobile and item.close.mobile.lid or nil
    else
        posIdx = item and item.close and item.close.pc and item.close.pc.lid or nil
    end

    GUI:Text_setString(NeiGuaSetting._ui["Text_close"], "")
    if posIdx then
        GUI:Text_setString(NeiGuaSetting._ui["Text_close"], tPos[posIdx] or "")
    end
end

function NeiGuaSetting.onSetClosePos()
    NeiGuaSetting.showItems(tPos, function(index)
        NeiGuaSetting._pos = NeiGuaSetting._pos or {}
        local item = NeiGuaSetting._pos
        if NeiGuaSetting._isMobile then
            item.close = item.close or {}
            item.close.mobile = item.close.mobile or {}
            item.close.mobile.lid = index
        else
            item.close = item.close or {}
            item.close.pc = item.close.pc or {}
            item.close.pc.lid = index
        end

        GUI:Text_setString(NeiGuaSetting._ui["Text_close"], tPos[index])
    end)

    local node_pos = GUI:getPosition(NeiGuaSetting._ui["bg_close"])
    GUI:setAnchorPoint(NeiGuaSetting.Image_pulldown_bg, 0.5, 0)
    GUI:setPosition(NeiGuaSetting.Image_pulldown_bg, node_pos.x, node_pos.y)
    GUI:setVisible(NeiGuaSetting.Image_pulldown_bg, true)
    GUI:setVisible(NeiGuaSetting.Layout_hide_pullDownList, true)
    GUI:setRotation(NeiGuaSetting._ui["arrow_close"], 0)  
end

function NeiGuaSetting.onResetOpen()
    local item = NeiGuaSetting._pos
    if NeiGuaSetting._isMobile then
        if NeiGuaSetting._pos and NeiGuaSetting._pos.open and NeiGuaSetting._pos.open.mobile then
            NeiGuaSetting._pos.open.mobile = nil
            NeiGuaSetting.updateUIControl()
        end
    else
        if NeiGuaSetting._pos and NeiGuaSetting._pos.open and NeiGuaSetting._pos.open.pc then
            NeiGuaSetting._pos.open.pc = nil
            NeiGuaSetting.updateUIControl()
        end
    end
end

function NeiGuaSetting.onResetClose()
    local item = NeiGuaSetting._pos
    if NeiGuaSetting._isMobile then
        if NeiGuaSetting._pos and NeiGuaSetting._pos.close and NeiGuaSetting._pos.close.mobile then
            NeiGuaSetting._pos.close.mobile = nil
            NeiGuaSetting.updateUIControl()
        end
    else
        if NeiGuaSetting._pos and NeiGuaSetting._pos.close and NeiGuaSetting._pos.close.pc then
            NeiGuaSetting._pos.close.pc = nil
            NeiGuaSetting.updateUIControl()
        end
    end
end

function NeiGuaSetting.initPullDownCells()
    NeiGuaSetting.Image_pulldown_bg = NeiGuaSetting._ui["Image_pulldown_bg"]
    NeiGuaSetting.ListView_pulldown = NeiGuaSetting._ui["ListView_pulldown"]
    NeiGuaSetting.Layout_hide_pullDownList = NeiGuaSetting._ui["Layout_hide_pullDownList"]

    GUI:setSwallowTouches(NeiGuaSetting.Layout_hide_pullDownList, false)
    GUI:addOnClickEvent(NeiGuaSetting.Layout_hide_pullDownList, function()
        NeiGuaSetting.hidePullDownCells()
    end)
end

function NeiGuaSetting.hidePullDownCells()
    GUI:setVisible(NeiGuaSetting.Image_pulldown_bg, false)
    GUI:setVisible(NeiGuaSetting.Layout_hide_pullDownList, false)
    GUI:ListView_removeAllItems(NeiGuaSetting.ListView_pulldown)

    GUI:setRotation(NeiGuaSetting._ui["arrow_platform"], 0)
    GUI:setRotation(NeiGuaSetting._ui["arrow_open"], 180)
    GUI:setRotation(NeiGuaSetting._ui["arrow_close"], 180)
end

function NeiGuaSetting.updateContent(v)
    local newCfg = SL:GetMetaValue("SETTING_CONFIG", v.id)
    NeiGuaSetting._cloneCfg = clone(newCfg)
    NeiGuaSetting._pos = nil
    if newCfg.mainpos and newCfg.mainpos ~= "" then
        local openAndClose = ssplit(newCfg.mainpos, "&")
        local item = {}
        -- open
        if openAndClose[1] and openAndClose[1] ~= "" then
            item.open = {}
            local slicesPos = ssplit(openAndClose[1], "|")
            -- 移动
            if slicesPos[1] and slicesPos[1] ~= "" then
                local tmp = {}
                local slicesPosM = ssplit(slicesPos[1], "#")
                tmp.icon = slicesPosM[1]
                tmp.lid = tonumber(slicesPosM[2])
                tmp.x = tonumber(slicesPosM[3])
                tmp.y = tonumber(slicesPosM[4])
                item.open.mobile = tmp
            end

            -- PC
            if slicesPos[2] and slicesPos[2] ~= "" then
                local tmp = {}
                local slicesPosPC = ssplit(slicesPos[2], "#")
                tmp.icon = slicesPosPC[1]
                tmp.lid = tonumber(slicesPosPC[2])
                tmp.x = tonumber(slicesPosPC[3])
                tmp.y = tonumber(slicesPosPC[4])
                item.open.pc = tmp
            end
        end
        -- close
        if openAndClose[2] and openAndClose[2] ~= "" then
            item.close = {}
            local slicesPos = ssplit(openAndClose[2], "|")
            -- 移动
            if slicesPos[1] and slicesPos[1] ~= "" then
                local tmp = {}
                local slicesPosM = ssplit(slicesPos[1], "#")
                tmp.icon = slicesPosM[1]
                tmp.lid = tonumber(slicesPosM[2])
                tmp.x = tonumber(slicesPosM[3])
                tmp.y = tonumber(slicesPosM[4])
                item.close.mobile = tmp
            end

            -- PC
            if slicesPos[2] and slicesPos[2] ~= "" then
                local tmp = {}
                local slicesPosPC = ssplit(slicesPos[2], "#")
                tmp.icon = slicesPosPC[1]
                tmp.lid = tonumber(slicesPosPC[2])
                tmp.x = tonumber(slicesPosPC[3])
                tmp.y = tonumber(slicesPosPC[4])
                item.close.pc = tmp
            end
        end
        -- job
        if openAndClose[3] and openAndClose[3] ~= "" then
            item.job = openAndClose[3]
        end

        NeiGuaSetting._pos = item
    end

    NeiGuaSetting.updateCurConfig(newCfg)

    NeiGuaSetting.updateUIControl()

    local job = tonumber(NeiGuaSetting._pos and NeiGuaSetting._pos.job) or 3
    NeiGuaSetting.onClickMainPosJobCell(job)
end

function NeiGuaSetting.updateCurConfig(v)
    GUI:removeAllChildren(NeiGuaSetting.Node_attach)
    NeiGuaSetting._openFile = nil

    local fileName = tItems[NeiGuaSetting._index][v.id]
    fileName = fileName == "" and "TurnOff" or fileName

    local filePath = "game/view/layersui/test_layer/configSetting/configLayout/setup/" .. fileName
    NeiGuaSetting._openFile = SL:RequireFile(filePath)
    NeiGuaSetting._openFile.main(NeiGuaSetting.Node_attach, v)
end

function NeiGuaSetting.initMainPosJobName()
    local job = tonumber(NeiGuaSetting._pos and NeiGuaSetting._pos.job) or 3
    for i = 0, 3 do
        local layout = NeiGuaSetting._ui["LayoutControl" .. i]
        local text = GUI:GetWindow(layout, "Text")
        if text and i < 3 then
            GUI:Text_setString(text, string.format("仅%s显示", SL:GetMetaValue("JOB_NAME", i)))
        end
        GUI:addOnClickEvent(layout, function()
            NeiGuaSetting.onClickMainPosJobCell(i)
        end)
        if i == job then
            GUI:setVisible(GUI:GetWindow(layout, "img_sel"), true)
            GUI:setVisible(GUI:GetWindow(layout, "img_unsel"), false)
        end
    end
end

function NeiGuaSetting.onClickMainPosJobCell(job)
    NeiGuaSetting._pos = NeiGuaSetting._pos or {}
    NeiGuaSetting._pos.job = job

    for i = 0, 3 do
        local cell = NeiGuaSetting._ui["LayoutControl" .. i]
        GUI:setVisible(GUI:GetWindow(cell, "img_sel"), i == job)
        GUI:setVisible(GUI:GetWindow(cell, "img_unsel"), i ~= job)
    end
end

function NeiGuaSetting.close()
    print("NeiGuaSetting.close")
    NeiGuaSetting._openFile = nil
end

return NeiGuaSetting