local PreviewAnimLayout = class("PreviewAnimLayout", function() return cc.Node:create() end)
local QuickCell = requireUtil("QuickCell")

local mmo = global.MMO

local Types = {
    [1] = { type = mmo.SFANIM_TYPE_PLAYER,  text = "玩 家" },
    [2] = { type = mmo.SFANIM_TYPE_MONSTER, text = "怪 物" },
    [3] = { type = mmo.SFANIM_TYPE_NPC,     text = "N P C" },
    [4] = { type = mmo.SFANIM_TYPE_SKILL,   text = "特 效" },
    [5] = { type = mmo.SFANIM_TYPE_WEAPON,  text = "武 器" },
    [6] = { type = mmo.SFANIM_TYPE_SHIELD,  text = "盾 牌" },
    [7] = { type = mmo.SFANIM_TYPE_WINGS,   text = "翅 膀" },
    [8] = { type = mmo.SFANIM_TYPE_HAIR,    text = "发 型" }
}

local cfgTypes = {
    [mmo.SFANIM_TYPE_PLAYER]  = { dir = mmo.ORIENT_LB, text = "玩家" },
    [mmo.SFANIM_TYPE_MONSTER] = { dir = mmo.ORIENT_LB, text = "怪物" },
    [mmo.SFANIM_TYPE_NPC]     = { dir = mmo.ORIENT_U,  text = "NPC" },
    [mmo.SFANIM_TYPE_SKILL]   = { dir = mmo.ORIENT_U,  text = "特效" },
    [mmo.SFANIM_TYPE_WEAPON]  = { dir = mmo.ORIENT_LB, text = "武器" },
    [mmo.SFANIM_TYPE_SHIELD]  = { dir = mmo.ORIENT_LB, text = "盾牌" },
    [mmo.SFANIM_TYPE_WINGS]   = { dir = mmo.ORIENT_LB, text = "翅膀" },
    [mmo.SFANIM_TYPE_HAIR]    = { dir = mmo.ORIENT_LB, text = "发型" }
}

local cfgZOrders = {
    [mmo.SFANIM_TYPE_PLAYER]  = {[mmo.ORIENT_U] = 2, [mmo.ORIENT_RU] = 2, [mmo.ORIENT_R] = 2, [mmo.ORIENT_RB] = 2, [mmo.ORIENT_B] = 2, [mmo.ORIENT_LB] = 2, [mmo.ORIENT_L] = 2, [mmo.ORIENT_LU] = 2},
    [mmo.SFANIM_TYPE_MONSTER] = {[mmo.ORIENT_U] = 2, [mmo.ORIENT_RU] = 2, [mmo.ORIENT_R] = 2, [mmo.ORIENT_RB] = 2, [mmo.ORIENT_B] = 2, [mmo.ORIENT_LB] = 2, [mmo.ORIENT_L] = 2, [mmo.ORIENT_LU] = 2},
    [mmo.SFANIM_TYPE_NPC]     = {[mmo.ORIENT_U] = 2, [mmo.ORIENT_RU] = 2, [mmo.ORIENT_R] = 2, [mmo.ORIENT_RB] = 2, [mmo.ORIENT_B] = 2, [mmo.ORIENT_LB] = 2, [mmo.ORIENT_L] = 2, [mmo.ORIENT_LU] = 2},
    [mmo.SFANIM_TYPE_SKILL]   = {[mmo.ORIENT_U] = 0, [mmo.ORIENT_RU] = 0, [mmo.ORIENT_R] = 0, [mmo.ORIENT_RB] = 0, [mmo.ORIENT_B] = 0, [mmo.ORIENT_LB] = 0, [mmo.ORIENT_L] = 0, [mmo.ORIENT_LU] = 0},
    [mmo.SFANIM_TYPE_WEAPON]  = {[mmo.ORIENT_U] = 1, [mmo.ORIENT_RU] = 3, [mmo.ORIENT_R] = 3, [mmo.ORIENT_RB] = 3, [mmo.ORIENT_B] = 3, [mmo.ORIENT_LB] = 3, [mmo.ORIENT_L] = 1, [mmo.ORIENT_LU] = 1},
    [mmo.SFANIM_TYPE_SHIELD]  = {[mmo.ORIENT_U] = 4, [mmo.ORIENT_RU] = 1, [mmo.ORIENT_R] = 1, [mmo.ORIENT_RB] = 1, [mmo.ORIENT_B] = 4, [mmo.ORIENT_LB] = 4, [mmo.ORIENT_L] = 4, [mmo.ORIENT_LU] = 4},
    [mmo.SFANIM_TYPE_WINGS]   = {[mmo.ORIENT_U] = 5, [mmo.ORIENT_RU] = 5, [mmo.ORIENT_R] = 5, [mmo.ORIENT_RB] = 0, [mmo.ORIENT_B] = 1, [mmo.ORIENT_LB] = 1, [mmo.ORIENT_L] = 5, [mmo.ORIENT_LU] = 5},
    [mmo.SFANIM_TYPE_HAIR]    = {[mmo.ORIENT_U] = 4, [mmo.ORIENT_RU] = 4, [mmo.ORIENT_R] = 4, [mmo.ORIENT_RB] = 4, [mmo.ORIENT_B] = 4, [mmo.ORIENT_LB] = 4, [mmo.ORIENT_L] = 4, [mmo.ORIENT_LU] = 4}
}


local cfgActs = {
    { act = mmo.ANIM_IDLE,               text = "待机", show = 1 },
    { act = mmo.ANIM_WALK,               text = "走路" },
    { act = mmo.ANIM_ATTACK,             text = "攻击" },
    { act = mmo.ANIM_SKILL,              text = "施法" },
    { act = mmo.ANIM_DIE,                text = "死亡" },
    { act = mmo.ANIM_RUN,                text = "跑步" },
    { act = mmo.ANIM_STUCK,              text = "受击" },
    { act = mmo.ANIM_SITDOWN,            text = "蹲下" },
    { act = mmo.ANIM_BORN,               text = "出生" },
    { act = mmo.ANIM_MINING,             text = "挖矿" },
    { act = mmo.ANIM_READY,              text = "预备" },
    { act = mmo.ANIM_CHANGESHAPE,        text = "变身"},
    { act = mmo.ANIM_DEATH,              text = "尸体" },
    { act = mmo.ANIM_RIDE_IDLE,          text = "骑马等待" },
    { act = mmo.ANIM_RIDE_WALK,          text = "骑马走" },
    { act = mmo.ANIM_RIDE_RUN,           text = "骑马跑" },
    { act = mmo.ANIM_RIDE_STUCK,         text = "骑马受击" },
    { act = mmo.ANIM_RIDE_DIE,           text = "骑马死亡" },
    { act = mmo.ANIM_YTPD,               text = "倚天辟地" },
    { act = mmo.ANIM_ZXC,                text = "追心刺" },
    { act = mmo.ANIM_SJS,                text = "三绝杀" },
    { act = mmo.ANIM_DYZ,                text = "断岳斩" },
    { act = mmo.ANIM_HSQJ,               text = "横扫千军" },
    { act = mmo.ANIM_FWJ,                text = "凤舞祭" },
    { act = mmo.ANIM_JLB,                text = "惊雷爆" },
    { act = mmo.ANIM_BTXD,               text = "冰天雪地" },
    { act = mmo.ANIM_SLP,                text = "双龙破" },
    { act = mmo.ANIM_HXJ,                text = "虎啸诀" },
    { act = mmo.ANIM_BGZ,                text = "八卦掌" },
    { act = mmo.ANIM_SYZ,                text = "三焰咒" },
    { act = mmo.ANIM_WJGZ,               text = "万剑归宗" },
}
--开关开启才显示
local cfgActs2 = {
    -- { act = mmo.ANIM_ASSASSIN_RUN,       text = "刺客走" },
    { act = mmo.ANIM_ASSASSIN_SNEAK,     text = "刺客潜行" },
    { act = mmo.ANIM_ASSASSIN_SMITE,     text = "刺客重击" },
    -- { act = mmo.ANIM_ASSASSIN_SKILL,     text = "刺客施法" },
    { act = mmo.ANIM_ASSASSIN_SY,        text = "刺客霜月" },
    { act = mmo.ANIM_ASSASSIN_UNKNOWN,   text = "刺客动作1" },
    { act = mmo.ANIM_ASSASSIN_XFT,       text = "刺客旋风腿" },
    { act = mmo.ANIM_JY,                 text = "箭雨1" },
    { act = mmo.ANIM_JY2,                text = "箭雨2" },
    { act = mmo.ANIM_TSZ,                text = "推山掌" },
    { act = mmo.ANIM_XLFH,               text = "降龙伏虎" },
}

local cfgActFrames = {
    [mmo.ANIM_IDLE]         = "idle_interval",
    [mmo.ANIM_WALK]         = "walk_interval" ,
    [mmo.ANIM_ATTACK]       = "attack_interval",
    [mmo.ANIM_SKILL]        = "magic_interval",
    [mmo.ANIM_DIE]          = "die_interval",
    [mmo.ANIM_RUN]          = "run_interval",
    [mmo.ANIM_STUCK]        = "stuck_interval" ,
    [mmo.ANIM_SITDOWN]      = "sitdown_interval" ,
    [mmo.ANIM_BORN]         = "born_interval" ,
    [mmo.ANIM_MINING]       = "mining_interval" ,
    [mmo.ANIM_READY]        = "ready_interval" ,
    [mmo.ANIM_CHANGESHAPE]  = "changeshape_interval" ,
    [mmo.ANIM_DEATH]        = "die_interval" ,
    [mmo.ANIM_RIDE_IDLE]    = "idle_interval" ,
    [mmo.ANIM_RIDE_WALK]    = "walk_interval" ,
    [mmo.ANIM_RIDE_RUN]     = "run_interval" ,
    [mmo.ANIM_RIDE_STUCK]   = "stuck_interval" ,
    [mmo.ANIM_RIDE_DIE]     = "die_interval" ,
    [mmo.ANIM_YTPD]         = "magic_interval" ,
    [mmo.ANIM_ZXC]          = "magic_interval" ,
    [mmo.ANIM_SJS]          = "magic_interval" ,
    [mmo.ANIM_DYZ]          = "magic_interval" ,
    [mmo.ANIM_HSQJ]         = "magic_interval" ,
    [mmo.ANIM_FWJ]          = "magic_interval" ,
    [mmo.ANIM_JLB]          = "magic_interval" ,
    [mmo.ANIM_BTXD]         = "magic_interval" ,
    [mmo.ANIM_SLP]          = "magic_interval" ,
    [mmo.ANIM_HXJ]          = "magic_interval" ,
    [mmo.ANIM_BGZ]          = "magic_interval" ,
    [mmo.ANIM_SYZ]          = "magic_interval" ,
    [mmo.ANIM_WJGZ]         = "magic_interval" ,
    [mmo.ANIM_ASSASSIN_RUN]     = "run_interval",
    [mmo.ANIM_ASSASSIN_SNEAK]   = "walk_interval",
    [mmo.ANIM_ASSASSIN_SMITE]   = "attack_interval",
    [mmo.ANIM_ASSASSIN_SKILL]   = "attack_interval",
    [mmo.ANIM_ASSASSIN_SY]      = "attack_interval",
    [mmo.ANIM_ASSASSIN_UNKNOWN] = "attack_interval",
    [mmo.ANIM_ASSASSIN_XFT]     = "attack_interval",
    [mmo.ANIM_JY]               = "magic_interval",
    [mmo.ANIM_JY2]              = "magic_interval",
    [mmo.ANIM_TSZ]              = "attack_interval",
    [mmo.ANIM_XLFH]             = "attack_interval",
}

local cfgDirs = {
    { dir = mmo.ORIENT_U,                text = "0" },
    { dir = mmo.ORIENT_RU,               text = "1" },
    { dir = mmo.ORIENT_R,                text = "2" },
    { dir = mmo.ORIENT_RB,               text = "3" },
    { dir = mmo.ORIENT_B,                text = "4" },
    { dir = mmo.ORIENT_LB,               text = "5" },
    { dir = mmo.ORIENT_L,                text = "6" },
    { dir = mmo.ORIENT_LU,               text = "7" }
}

local UpdateType = {
    SPEED = 1,
    DIR   = 2,
    POS   = 3,
    BLENDMODE = 4,
    ANCHORPOINT = 5
}

local minFrame = 20
local maxFrame = 2000
local defaultInterval = 500

function PreviewAnimLayout:ctor()
    self._selType    = nil
    self._act        = mmo.ANIM_IDLE
    self._dir        = mmo.ORIENT_U
    self._sex        = mmo.ACTOR_PLAYER_SEX_M
    self._configs    = {}
    self._cacheValue = {}
    self._searchID   = -1
    self._frames     = {}
    self._preDir     = nil

    self._curSelType = 1
    self._curSelAct  = mmo.ANIM_IDLE
    self._curSelDir  = mmo.ORIENT_U
    self._curSelSex  = mmo.ACTOR_PLAYER_SEX_M
    self._curSelID   = nil

    self._selIDsList    = {}
    self._selSexList = {}

    self._KeyBoards  = {
        [cc.KeyCode.KEY_BACKSPACE] = function () self:onKeyBackSpace() end,
        [cc.KeyCode.KEY_S] = function () self:OnSaveConfig() end
    }

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_ESCAPE, function ()
        self:onKeyBackSpace()
        return true
    end, nil, 0)

    self._Attr = {
        ["TextField_blendMode"] = { IMode = 2, Max = 4, Min = 0, SetWidget = handler(self, self.SetBlendMode), SetUIWidget = handler(self, self.SetUIBlendMode), Update = handler(self, self.UpdateAnimBlendMode), Init = handler(self, self.InitEditBox) },
        ["TextField_anrX"] = { IMode = 6, Max = 2, Min = 0, SetWidget = handler(self, self.SetAnrX), SetUIWidget = handler(self, self.SetUIAnrX), Update = handler(self, self.UpdateAnimAnrX), Init = handler(self, self.InitEditBox) },
        ["TextField_anrY"] = { IMode = 6, Max = 2, Min = 0, SetWidget = handler(self, self.SetAnrY), SetUIWidget = handler(self, self.SetUIAnrY), Update = handler(self, self.UpdateAnimAnrY), Init = handler(self, self.InitEditBox) },
        ["TextField_posX"] = { IMode = 6, SetWidget = handler(self, self.SetPosX), SetUIWidget = handler(self, self.SetUIPosX), Update = handler(self, self.UpdateAnimPosX), Init = handler(self, self.InitEditBox) },
        ["TextField_posY"] = { IMode = 6, SetWidget = handler(self, self.SetPosY), SetUIWidget = handler(self, self.SetUIPosY), Update = handler(self, self.UpdateAnimPosY), Init = handler(self, self.InitEditBox) },

        ["TextField_search"] = { t = 2, IMode = 2, Min = -1, SetWidget = handler(self, self.SetSearch), SetUIWidget = handler(self, self.SetUISearch), Update = handler(self, self.UpdateSearch), Init = handler(self, self.InitEditBox) },

        ["TextField_frame"] = { IMode = 6, Min = minFrame, Max = maxFrame, SetWidget = handler(self, self.SetFrame), SetUIWidget = handler(self, self.SetUIFrame), Init = handler(self, self.InitEditBox) },
        ["Slider_speed"]    = { SetUIWidget = handler(self, self.SetUISliderProgress), SliderEvent = handler(self, self.onFrameSliderEvent) },
    }
    for i, v in ipairs(cfgActs2) do
        table.insert(cfgActs,v)
    end
end

function PreviewAnimLayout.create()
    local layout = PreviewAnimLayout.new()
    if layout:Init() then
        return layout
    else
        return nil
    end
end

function PreviewAnimLayout:Init()
    local root = CreateExport("preview_anim/preview_anim")
    if not root then
        return false
    end
    self:addChild(root)
    self._quickUI = ui_delegate(self)
    
    self:InitCfg()

    -- red
    self._redPointRoot = cc.DrawNode:create()
    self._redPointRoot:setName("RED")
    self._redPointRoot:drawDot(cc.p(0, 0), 3, cc.Color4F.RED)
    self._quickUI.Node_all:addChild(self._redPointRoot, 99)

    self:setBtnSaveStatus(false)
    
    self._page = 1

    self:InitKeyBoard()
    self:InitEvent()
    self:InitInputEvent()
    self:InitList()
    self:InitTypeList(1)

    return true
end

-----------------------------------------------------------------------------------------
-- Slider Event Start
function PreviewAnimLayout:getListOffY(list)
    return list:getInnerContainerSize().height - list:getContentSize().height
end

function PreviewAnimLayout:updateListPercent(list, bar, percent)
    bar:setPercent(percent)
    list:scrollToPercentVertical(percent, 0.03, false)
end

function PreviewAnimLayout:onScrollPercent(list, bar, padding)
    local innY = list:getInnerContainerPosition().y
    local offY = self:getListOffY(list)

    local percent = math.min(math.max(0, (offY + innY + padding) / offY * 100), 100)
    self:updateListPercent(list, bar, percent)
end

function PreviewAnimLayout:onSliderEvent(ref, list)
    local offY = self:getListOffY(list)
    if offY > 0 then
        list:scrollToPercentVertical(ref:getPercent(), 0.03, false)
    else
        ref:setPercent(100)
    end
end

function PreviewAnimLayout:onScrollEvent(ref, bar)
    local posY = ref:getInnerContainerPosition().y
    local offY = self:getListOffY(ref)
    local percent = 100
    if offY > 0 then
        percent = math.min(math.max(0, (offY + posY) / offY * 100), 100)
    end
    bar:setPercent(percent)
end

function PreviewAnimLayout:InitEvent()
    self._quickUI.Button_1:addClickEventListener(function () self:onScrollPercent(self._quickUI.list_1, self._quickUI.slider_1, -30) end)
    self._quickUI.Button_2:addClickEventListener(function () self:onScrollPercent(self._quickUI.list_1, self._quickUI.slider_1, 30)  end)
    self._quickUI.Button_3:addClickEventListener(function () self:onScrollPercent(self._quickUI.list_2, self._quickUI.slider_2, -30) end)
    self._quickUI.Button_4:addClickEventListener(function () self:onScrollPercent(self._quickUI.list_2, self._quickUI.slider_2, 30)  end)
    self._quickUI.slider_1:addEventListener(function (ref) self:onSliderEvent(ref, self._quickUI.list_1) end)
    self._quickUI.slider_2:addEventListener(function (ref) self:onSliderEvent(ref, self._quickUI.list_2) end)
    self._quickUI.list_1:addMouseScrollPercent(function (percent) self._quickUI.slider_1:setPercent(percent) end)
    self._quickUI.list_2:addMouseScrollPercent(function (percent) self._quickUI.slider_2:setPercent(percent) end)
    self._quickUI.list_1:addEventListener(function (ref) self:onScrollEvent(ref, self._quickUI.slider_1) end)
    self._quickUI.list_2:addEventListener(function (ref) self:onScrollEvent(ref, self._quickUI.slider_2) end)
    self._quickUI.Button_reset:addClickEventListener(handler(self, self.onReset))
    self._quickUI.btnSave:addClickEventListener(handler(self, self.OnSaveConfig))
    self._quickUI.btnDel:addClickEventListener(handler(self, self.onDelEvent))
    self._quickUI.btnAdd:addClickEventListener(handler(self, self.onAddEvent))
    self._quickUI.btnSearch:addClickEventListener(handler(self, self.onSearchEvent))
    self._quickUI.Panel_Del:addClickEventListener(handler(self, self.onDelChildrenPage))
    self._quickUI.btnBack:addClickEventListener(handler(self, function ()
        if self._page == 2 then
            self:onKeyBackSpace()
        else
            self:onClose()
        end
    end))
end
-- Slider Event end
-----------------------------------------------------------------------------------------

function PreviewAnimLayout:InitKeyBoard()
    self._listenerKeyBoard = cc.EventListenerKeyboard:create()
    self._listenerKeyBoard:registerScriptHandler(handler(self, self.KeyBoardPressedFunc), cc.Handler.EVENT_KEYBOARD_PRESSED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self._listenerKeyBoard, 1)
end

function PreviewAnimLayout:InitList()
    for _, v in ipairs(Types) do
        local btn = self._quickUI.Button_reset:clone()
        self._quickUI.ListView_1:addChild(btn)
        btn:setVisible(true)
        btn:setTitleText(v.text)
        btn:setTag(v.type)
        btn:addClickEventListener(handler(self, self.onClickAnimType))
    end

    for i, v in ipairs(cfgDirs) do
        local btn = self._quickUI.Button_dir:clone()
        self._quickUI.ListView_2:addChild(btn)
        btn:setVisible(true)
        btn:setTitleText(v.text)
        btn:setTag(v.dir)
        btn:addClickEventListener(handler(self, self.onClickAnimDir))
    end
end

-----------------------------------------------------------------------------------------
-- Input Event Start
function PreviewAnimLayout:InitInputEvent()
    self._selUIControl = {}
    for name,d in pairs(self._Attr) do
        if name then
            local widget = self._quickUI[name]
            local Init = d.Init
            if Init then
                self._selUIControl[name] = Init(widget, d.IMode)
            end
            local SliderEvent = d.SliderEvent
            if SliderEvent then
                widget:addEventListener(SliderEvent)
                self._selUIControl[name] = widget
            end
        end
    end
end

function PreviewAnimLayout:InitEditBox(widget, inputMode)
    local editBox = CreateEditBoxByTextField(widget)
    editBox:setInputMode(inputMode)
    self:initTextFieldEvent(editBox)
    return editBox
end

function PreviewAnimLayout:initTextFieldEvent(widget)
    widget:addEventListener(function(ref, eventType)
        local name = ref:getName()
        local ui = self._Attr[name]
        if not ui then
            return false
        end
        local mode = ui.IMode
        local max  = ui.Max
        local min  = ui.Min
        local str  = ref:getString()

        if eventType == 1 then
            str = string.trim(str)
            if mode == 2 then
                str = tonumber(str) or min
                if min and str < min then
                    str = min
                end
                if max then
                    str = math.max(math.min(str, max), min)
                end
                ref:setString(str)
                self:updateUIAttr(name, str)
            else
                local cVal = self._cacheValue[name] or ""

                if string.len(str or "") < 1 then
                    ref:setString(cVal)
                    return false
                end
                if not tonumber(str) then
                    ref:setString(cVal)
                    return false
                end
                str = string.gsub(str, "[ .]+$", "")

                str = tonumber(str) or 0
                if min and str < min then
                    str = min
                end
                if max then
                    str = math.max(math.min(str, max), min)
                end

                ref:setString(str)
                self:updateUIAttr(name, str)
            end
        end
    end)
end

function PreviewAnimLayout:updateUIAttr(name, value)
    if name and self._Attr[name] and self._Attr[name].SetWidget then
        local isSet = false
        if self._Attr[name].t == 2 then
            isSet = true
        else
            if self._configs2[self._curSelType] and self._configs2[self._curSelType][self._curSelID] and self._configs2[self._curSelType][self._curSelID][self._curSelSex] then
                isSet = true
                self:setBtnSaveStatus(true)
            end
        end
        if isSet then
            self._Attr[name].SetWidget(value)
            if self._Attr[name].Update then
                self._Attr[name].Update(value)
            end
        end
    end
    self:updateUIControl()
end

function PreviewAnimLayout:updateUIControl()
    for name,_ in pairs(self._selUIControl) do
        if self._Attr[name] and self._Attr[name].SetUIWidget then
            local data = nil
            if self._Attr[name].t == 2 then
                data = self._searchID
            else
                if self._configs2[self._curSelType] and self._configs2[self._curSelType][self._curSelID] and self._configs2[self._curSelType][self._curSelID][self._curSelSex] then
                    data = self._configs2[self._curSelType][self._curSelID][self._curSelSex]
                end
            end
            if data then
                self._Attr[name].SetUIWidget(self._selUIControl[name], data, name)
            end
        end
    end
end

-- search box
function PreviewAnimLayout:SetSearch(value)
    self._searchID = value
end

function PreviewAnimLayout:SetUISearch(widget, value, name)
    if value == -1 then
        widget:setPlaceholderFontColor(cc.c3b(0, 0, 0))
        widget:setPlaceholderFontSize(14)
        widget:setPlaceHolder("请输入特效ID")
        widget:setString("")
    else
        widget:setString(value)
    end
    self._cacheValue[name] = value
end

function PreviewAnimLayout:UpdateSearch()
    if self._searchID == -1 then
        return false
    end

    local index = self:GetJumpRow(self._searchID)
    if index > -1 then
        self:InitTypeList(self._selType, index)
    else
        ShowSystemTips("<font color='#ff0000'>查找的ID无效</font>")
    end
end
-- end

-- frame
function PreviewAnimLayout:SetFrame(value)
    if not self._act then return false end
    self._frames[self._curSelType] = self._frames[self._curSelType] or {}
    self._frames[self._curSelType][self._curSelID] = self._frames[self._curSelType][self._curSelID] or {}
    self._frames[self._curSelType][self._curSelID][self._curSelSex] = self._frames[self._curSelType][self._curSelID][self._curSelSex] or {}
    self._frames[self._curSelType][self._curSelID][self._curSelSex][self._act] = value
end

function PreviewAnimLayout:GetCacheFrames(animType, id, sex, act)
    if not self._frames[animType] then
        return false
    end
    if not self._frames[animType][id] then
        return false
    end
    if not self._frames[animType][id][sex] then
        return false
    end

    local frames = (self._frames[animType] 
                    and self._frames[animType][id] 
                    and self._frames[animType][id][sex]) and self._frames[animType][id][sex]
    if frames then
        return frames
    end

    return false
end

function PreviewAnimLayout:GetFrame(animType, id, sex, act, intervals)
    local frames = self:GetCacheFrames(animType, id, sex, act)
    if frames and frames[act] then
        return frames[act]
    end

    if intervals and intervals[act] then
        return intervals[act] * 1000
    end

    return defaultInterval
end

function PreviewAnimLayout:SetUIFrame(widget, t, name)
    local rate  = self:GetFrame(self._curSelType, self._curSelID, self._curSelSex, self._act, t.interval)
    widget:setString(rate)
    self._cacheValue[name] = rate

    self:updateAllAnim()
end
-- end

function PreviewAnimLayout:SetUISliderProgress(widget, t)
    local rate  = self:GetFrame(self._curSelType, self._curSelID, self._curSelSex, self._act, t.interval)
    local precent = rate / 1000 * 100
    widget:setPercent(math.floor(precent))
end

function PreviewAnimLayout:onFrameSliderEvent(ref)
    local percent = ref:getPercent()
    local rate = tonumber(string.format("%.4f", percent / 100 * 1000))
    if rate < minFrame then
        rate = minFrame
    end
    self:updateUIAttr("TextField_frame", rate)
end

function PreviewAnimLayout:SetBlendMode(value)
    self._configs2[self._curSelType][self._curSelID][self._curSelSex].blendmode = value
end

function PreviewAnimLayout:SetUIBlendMode(widget, t, name)
    local value = t.blendmode
    widget:setString(value)
    self._cacheValue[name] = value
end

function PreviewAnimLayout:UpdateAnimBlendMode(value)
    self:updateAllAnim(UpdateType.BLENDMODE, {blend = value})
end

function PreviewAnimLayout:SetAnrX(value)
    self._configs2[self._curSelType][self._curSelID][self._curSelSex].stand_pos_x = value
end

function PreviewAnimLayout:SetUIAnrX(widget, t, name)
    local value = t.stand_pos_x
    widget:setString(value)
    self._cacheValue[name] = value
end

function PreviewAnimLayout:UpdateAnimAnrX(value)
    self:updateAllAnim(UpdateType.ANCHORPOINT, {x = value, y = self._configs2[self._curSelType][self._curSelID][self._curSelSex].stand_pos_y})
end

function PreviewAnimLayout:SetAnrY(value)
    self._configs2[self._curSelType][self._curSelID][self._curSelSex].stand_pos_y = value
end

function PreviewAnimLayout:SetUIAnrY(widget, t, name)
    local value = t.stand_pos_y
    widget:setString(value)
    self._cacheValue[name] = value
end

function PreviewAnimLayout:UpdateAnimAnrY(value)
    self:updateAllAnim(UpdateType.ANCHORPOINT, {x = self._configs2[self._curSelType][self._curSelID][self._curSelSex].stand_pos_x, y = value})
end

function PreviewAnimLayout:SetPosX(value)
    self._configs2[self._curSelType][self._curSelID][self._curSelSex].offsetx = value
end

function PreviewAnimLayout:SetUIPosX(widget, t, name)
    local value = t.offsetx
    widget:setString(value)
    self._cacheValue[name] = value
end

function PreviewAnimLayout:UpdateAnimPosX(value)
    self:updateAllAnim(UpdateType.POS, {x = value, y = self._configs2[self._curSelType][self._curSelID][self._curSelSex].offsety or 0})
    self._x = value
end

function PreviewAnimLayout:SetPosY(value)
    self._configs2[self._curSelType][self._curSelID][self._curSelSex].offsety = value
end

function PreviewAnimLayout:SetUIPosY(widget, t, name)
    local value = t.offsety
    widget:setString(value)
    self._cacheValue[name] = value
end

function PreviewAnimLayout:UpdateAnimPosY(value)
    self:updateAllAnim(UpdateType.POS, {x = self._configs2[self._curSelType][self._curSelID][self._curSelSex].offsetx or 0, y = value})
    self._y = value
end
-- Input Event End
-----------------------------------------------------------------------------------------

function PreviewAnimLayout:GetJumpRow(id)
    for i, v in ipairs(self._configs[self._selType] or {}) do
        if v and id and id == v.id then
            return math.ceil(i / 6)
        end
    end
    return -1
end

function PreviewAnimLayout:InitCfg()
    local configProxy = global.Facade:retrieveProxy(global.ProxyTable.ModelConfigProxy)
    local config = configProxy:RetrieveConfig()

    local min = mmo.SFANIM_TYPE_PLAYER - 1
    local max = mmo.SFANIM_TYPE_NUM + 1

    self._configs  = {}
    self._configs2 = {}
    for _, v in pairs(config) do
        local animType = v.type
        if animType > min and animType < max then
            local data = clone(v)
            self._configs[animType] = self._configs[animType] or {}
            local n = #self._configs[animType] + 1
            self._configs[animType][n] = data
            self._configs2[animType] = self._configs2[animType] or {}
            self._configs2[animType][v.id] = self._configs2[animType][v.id] or {}
            self._configs2[animType][v.id][v.sex] = data
        end
    end

    for i = min+1, max-1 do
        if self._configs[i] then
            table.sort(self._configs[i], function (a, b) 
                if a.id == b.id then
                    return a.sex < b.sex
                else
                    return a.id < b.id
                end
            end)
        end
    end
end

function PreviewAnimLayout:GetMaxFrameBox(sfx, act, dir)
    local size   = {width = 1, height = 1}
    local animIndex = GetFrameAnimIndex(act, dir)
    local animFrameVec = sfx._animDataDesc.animFrameVecs[animIndex] or {}
    for i=1, #animFrameVec do
        local spriteFrame = animFrameVec[i]:getSpriteFrame()
        local originSize = spriteFrame:getOriginalSize()
        size = {
            width = math.max(originSize.width, size.width), height = math.max(originSize.height, size.height)
        }
    end
    return size
end

function PreviewAnimLayout:dealSfxScale(sfx, sfxBox, animID, isReal)
    if isReal then
    else
        local scale = 1

        local width  = 140
        local height = 150

        if sfxBox.width > sfxBox.height then
            if sfxBox.width > width then
                scale = width / sfxBox.width
            end
        else
            if sfxBox.height > height then
                scale = height / sfxBox.height
            end
        end

        sfx:setScale(scale)

        local offset = sfx:GetOffset()
        if sfx._data then
            offset = {x = sfx._data.offsetx or 0, y = sfx._data.offsety or 0}
        end

        local p = sfx:getTurePosition()
        local a = sfx:getAnchorPoint()
        p.x = p.x - offset.x + sfxBox.width  * a.x * scale
        p.y = p.y - offset.y - sfxBox.height * (1 - a.y) * scale

        sfx:setPosition(p.x, p.y)
    end
end

function PreviewAnimLayout:createAnim(animType, animID, act, sex, dir, speed, isReal)
    local act = act or mmo.ANIM_DEFAULT
    local dir = dir or mmo.ORIENT_U
    local sex = sex or mmo.ACTOR_PLAYER_SEX_M
    local sfx = nil
    local data = self:getCfgData(animType, animID, sex)

    local function SetPos(seqFrm)
        local x = 0
        local y = 0
        if not (mmo.SFANIM_TYPE_SKILL == animType and not global.FrameAnimManager:IsNeedOffset(animID)) then
            local p = mmo.PLAYER_AVATAR_OFFSET
            x = p.x
            y = p.y
        end

        local offset = seqFrm:GetOffset()
        local offx = data.offsetx or 0
        local offy = data.offsety or 0

        local realx = offx - offset.x
        local realy = offy - offset.y
        seqFrm:setPosition(cc.p(x + realx, y + realy))

        local anrx = data.stand_pos_x or 0
        local anry = data.stand_pos_y or 0
        seqFrm:setAnchorPoint(cc.p(anrx, anry))
    end

    local function callback(_, seqFrm)
        local anr = seqFrm:GetStandPoint(animID, animType, sex)
        seqFrm:setAnchorPoint(anr)

        SetPos(seqFrm)

        local size = self:GetMaxFrameBox(seqFrm, act, dir)
        self:dealSfxScale(seqFrm, size, animID, isReal)
    end

    if mmo.SFANIM_TYPE_PLAYER == animType then
        sfx = global.FrameAnimManager:CreateActorPlayerAnim(animID, sex, act, callback, true)
    elseif mmo.SFANIM_TYPE_WEAPON == animType then
        sfx = global.FrameAnimManager:CreateActorPlayerWeaponAnim(animID, sex, act, callback, true)
    elseif mmo.SFANIM_TYPE_HAIR == animType then
        sfx = global.FrameAnimManager:CreateActorPlayerHairAnim(animID, sex, act, callback, true)
    elseif mmo.SFANIM_TYPE_WINGS == animType then
        sfx = global.FrameAnimManager:CreateActorPlayerWingsAnim(animID, sex, act, callback, true)
    elseif mmo.SFANIM_TYPE_SHIELD == animType then
        sfx = global.FrameAnimManager:CreateActorPlayerShieldAnim(animID, sex, act, callback, true)
    elseif mmo.SFANIM_TYPE_MONSTER == animType then
        sfx = global.FrameAnimManager:CreateActorMonsterAnim(animID, act, callback, sex, true)
    elseif mmo.SFANIM_TYPE_NPC == animType then
        sfx = global.FrameAnimManager:CreateActorNpcAnim(animID, callback, true)
    elseif mmo.SFANIM_TYPE_SKILL == animType then
        sfx = global.FrameAnimManager:CreateSkillEffAnim(animID, dir, callback, true)
    end

    if not sfx then
        return false
    end

    sfx._data = data

    sfx:Play(act, dir, true, speed)

    SetPos(sfx)

    -- 已经加载过
    if sfx:CheckAnimActIsLoaded() then
        local size = self:GetMaxFrameBox(sfx, act, dir)
        self:dealSfxScale(sfx, size, animID, isReal)
    end

    -- 混合模式
    global.FrameAnimManager:setBlendFunc(sfx, data.blendmode or 0)

    return sfx
end

function PreviewAnimLayout:getCfgData(animType, animID, sex)
    if self._configs2[animType] and self._configs2[animType][animID] and self._configs2[animType][animID][sex] then
        return self._configs2[animType][animID][sex]
    end
    return nil
end


function PreviewAnimLayout:setSelectTypeInListView3(type, isChange)
    for i, v in ipairs(self._quickUI.ListView_3:getChildren()) do
        local bright = type ~= v:getTag()
        if bright then
            v:setBright(true)
            v:setTouchEnabled(true)
            v:getChildByName("Panel_Del"):setVisible(false)
        else
            v:setBright(false)
            v:setTouchEnabled(false)
            v:getChildByName("Panel_Del"):setVisible(true)
        end
    end
    
    self._curSelType = type
    self._curSelAct  = mmo.ANIM_IDLE
    self._curSelDir  = mmo.ORIENT_U
    self._curSelSex  = mmo.ACTOR_PLAYER_SEX_M

    if isChange then
        self._selType = type
        self._selID = self._selIDsList[type]
        self._sex   = self._selSexList[type] or 0
        self:setBtnStatus(self._quickUI.ListView_1, type, true)
        self:updateActList()
        self._curSelID  = self._selIDsList[self._selType]
        self._curSelSex = self._selSexList[self._selType]
    else
        self._curSelID = self._selID
        self._selIDsList[self._selType] = self._selID

        self._curSelSex = self._sex
        self._selSexList[self._selType] = self._sex
    end

    local node = self:getSfxNode(type)
    local sfx  = node and node:getChildByName("sfx")
    if sfx then
        self._curSelAct  = (sfx._param_ and sfx._param_.act) or sfx._param_.act or self._curSelAct
        self._curSelDir  = (sfx._param_ and sfx._param_.dir) or sfx._param_.dir or self._curSelDir
        self._curSelSex  = (sfx._param_ and sfx._param_.sex) or sfx._param_.sex or self._curSelSex
        self._curSelID   = (sfx._param_ and sfx._param_.id)  or sfx._param_.id  or self._curSelID
    end

    self:updateUIControl()
end

function PreviewAnimLayout:addItemToListView3()
    local type = self._selType
    local item = self._quickUI.ListView_3:getChildByTag(type)
    if not item then
        item = self._quickUI.Button_dir:clone()
        self._quickUI.ListView_3:pushBackCustomItem(item)
        item:setTitleFontSize(14)
        item:setTitleText(cfgTypes[type].text)
        item:addClickEventListener(function () self:setSelectTypeInListView3(type, true) end)
    end
    item:setTag(type)

    self:setSelectTypeInListView3(type)
end

function PreviewAnimLayout:UpdatePreview()
    local name = "node_"..self._selType
    local node = self._quickUI.Node_all:getChildByName(name)
    if not node then
        node = cc.Node:create()
        node:setName(name)
        self._quickUI.Node_all:addChild(node, self._selType)
    end

    if self._selType > mmo.SFANIM_TYPE_NPC then
        self:delAllItems(node)
    else
        for _, i in pairs({mmo.SFANIM_TYPE_PLAYER, mmo.SFANIM_TYPE_MONSTER, mmo.SFANIM_TYPE_NPC}) do
            local node = self:getSfxNode(i)
            if node then
                self:delAllItems(node)
            end
        end
    end
    local sfx = self:createAnim(self._selType, self._selID, self._act, self._sex, self._dir, self:getSpeed(), true)
    sfx:setName("sfx")
    sfx._param_ = {
        act = self._act, dir = self._dir, sex = self._sex, id = self._selID
    }
    node:addChild(sfx)
end

function PreviewAnimLayout:delAllItems(widget)
    widget:removeAllChildren()
end

function PreviewAnimLayout:getSfxNode(i)
    return self._quickUI.Node_all:getChildByName("node_"..i)
end

function PreviewAnimLayout:setBtnStatus(list, tag, isset)
    for i, btn in ipairs(list:getChildren()) do
        local isTouch = btn:getTag() ~= tag
        btn:setBright(isTouch)
        if not isset then
            btn:setTouchEnabled(isTouch)
        end
    end
end

function PreviewAnimLayout:onClickAnimDir(ref)
    local dir = ref:getTag()
    self._dir = dir
    self._preDir = dir
    self:setBtnStatus(self._quickUI.ListView_2, self._dir)
    self:UpdatePreview()
    self:updateAllAnim()
end

function PreviewAnimLayout:onClickAnimType(ref)
    self:InitTypeList(ref:getTag())
end

function PreviewAnimLayout:InitTypeList(type, jumpRow, isNotReset)
    if self._selType ~= type then
        self:setBtnStatus(self._quickUI.ListView_1, type, true)
        self:SetSearch(-1)
        self:SetUISearch(self._selUIControl["TextField_search"], -1, "TextField_search")
        self._selType = type
    end

    self._preDir = nil

    if isNotReset then
    else
        self._selID   = nil
        self._sex     = mmo.ACTOR_PLAYER_SEX_M
        self:setSelSfxID()
    end
    self._act = mmo.ACTION_IDLE
    self._dir = self._dir or mmo.ORIENT_U
    self:hideActList()
    self:updateListView(self._quickUI.list_1, self._quickUI.Panel_item_1, self._quickUI.slider_1, self._configs[type], 6, handler(self, self.onClickTypeEvent), jumpRow)

    global.FrameAnimManager:unloadAllUnusedAnimData()
end

function PreviewAnimLayout:onClickTypeEvent(eventType)
    if eventType == 0 then
        performWithDelay(self, function() self._clickTime = 0 end, global.MMO.CLICK_DOUBLE_TIME)
    elseif eventType == 2 then
        self._clickTime = self._clickTime + 1
        if self._clickTime == 2 then
            self:updateActList()
        else
            self:setSelSfxID()
            self:refreshCells()
        end
    end
end

function PreviewAnimLayout:onClickActEvent(eventType)
    if eventType == 2 then
        self._dir = self._preDir and self._preDir or cfgTypes[self._selType].dir
        self:setBtnStatus(self._quickUI.ListView_2, self._dir)
        self:UpdatePreview()
        self:updateAllAnim()

        self._x = self._configs2[self._selType][self._selID][self._sex].offsetx or 0
        self._y = self._configs2[self._selType][self._selID][self._sex].offsety or 0
        self:updateUIControl()

        self:setSelSfxID()
        self:refreshCells()

        self:addItemToListView3()
    end
end

function PreviewAnimLayout:hideTypeList()
    self._quickUI.ListView_2:setVisible(true)
    self._quickUI.ListView_3:setVisible(true)

    self._quickUI.Panel_preview:setVisible(true)
    self._quickUI.Panel_set:setVisible(true)
    self._quickUI.Panel_slider_2:setVisible(true)

    self._quickUI.list_1:setVisible(false)
    self._quickUI.Panel_slider_1:setVisible(false)
    self._quickUI.Panel_search:setVisible(false)

    self._page = 2
end

function PreviewAnimLayout:hideActList()
    self._quickUI.ListView_2:setVisible(false)
    self._quickUI.ListView_3:setVisible(false)

    self._quickUI.Panel_preview:setVisible(false)
    self._quickUI.Panel_set:setVisible(false)
    self._quickUI.Panel_slider_1:setVisible(true)

    self._quickUI.list_2:setVisible(false)
    self._quickUI.Panel_slider_2:setVisible(false)
    self._quickUI.Panel_search:setVisible(true)

    self._page = 1
end

-- 加载 Item 到 ListView
function PreviewAnimLayout:updateListView(list, itemObj, bar, data, colnum, callback, jumpRow)
    self:delAllItems(list)

    if not (data and next(data)) then
        return false
    end

    local createCell = function (i)
        local item = itemObj:clone()
        item:setVisible(true)

        local maxI = colnum * i
        for j = colnum, 1, -1 do
            self:refreshItemData(item:getChildByName("Item_"..(colnum-j+1)), data[maxI-j+1], callback)
        end

        return item
    end

    local releaseSfxRes = function (i)
        local maxI = colnum * i
        for j = colnum, 1, -1 do
            local d = data[maxI-j+1]
            if d then
                global.FrameAnimManager:unloadUnusedAnimDataByTypeID(self._selType, d.id)
            end
        end
    end

    self._cells = {}
    local row = math.ceil(#data / colnum)
    local itemSize = itemObj:getContentSize()

    for i = 1, row do
        local quickCell = QuickCell:Create({
            wid = itemSize.width, 
            hei = itemSize.height, 
            createCell   = function() return createCell(i) end,
            exitCallback = function () releaseSfxRes(i) end
        })
        list:addChild(quickCell)
        self._cells[i] = quickCell
    end

    list:setVisible(true)
    bar:setVisible(true)

    list:requestDoLayout()

    local function JumpTo()
        performWithDelay(self, function () self:updateListPercent(list, bar, 0) end, 0.01)
    end

    if jumpRow and jumpRow > 0 then
        list:jumpToItem(jumpRow, cc.p(0,0), cc.p(0, 0))
        self:onScrollPercent(list, bar, 0)
    else
        JumpTo()
    end
end

-- 属性列表 Item
function PreviewAnimLayout:refreshItemData(item, data, callback)
    if not (data and next(data)) then
        return item:setVisible(false)
    end
    IterAllChild(item, item)

    local animID = data.id
    local act = data.act
    local sex = data.sex
    local dir = cfgTypes[self._selType].dir

    local sfx = self:createAnim(self._selType, animID, act, sex, dir)
    item["sfx"]:addChild(sfx)

    item["Text"]:setString(data.tip or animID)

    local color = cc.c3b(255, 255, 255)
    if data.tip then
        if self._act == act then
            color = cc.c3b(255, 0, 0)
        end
    else
        if self._selID == animID and self._sex == sex then
            color = cc.c3b(255, 0, 0)
        end
    end
    item["Text"]:setColor(color)

    self._clickTime = self._clickTime or 0
    item:addTouchEventListener(function (_, eventType) 
        self._selID  = animID
        self._act    = act
        self._sex    = sex
        self._dir    = self._preDir and self._preDir or dir

        if callback then 
            callback(eventType)
        end
    end)

    item:setVisible(true)
end

function PreviewAnimLayout:updateActList()
    local data = {}
    for _, v in ipairs(cfgActs) do
        local isLoad = false
        if mmo.SFANIM_TYPE_NPC == self._selType or mmo.SFANIM_TYPE_SKILL == self._selType then
            isLoad = v.show == 1
        else
            isLoad = true
        end
        if isLoad then
            local n = #data + 1
            data[n] = {id = self._selID, act = v.act, sex = self._sex, tip = v.text}
        end
    end

    local function IsHaveNpc()
        for _, i in pairs({mmo.SFANIM_TYPE_PLAYER, mmo.SFANIM_TYPE_MONSTER, mmo.SFANIM_TYPE_NPC}) do
            local node = self:getSfxNode(i)
            if node then
                return true
            end
        end
        return false
    end

    local node = self:getSfxNode(self._selType)
    local sfx  = node and node:getChildByName("sfx")
    if sfx then
        self._act = (sfx._param_ and sfx._param_.act) or sfx._param_.act or self._act
    else
        self._act = mmo.ANIM_IDLE
    end
    self:hideTypeList()
    self:updateListView(self._quickUI.list_2, self._quickUI.Panel_item_2, self._quickUI.slider_2, data, 3, handler(self, self.onClickActEvent))

    if #data > 0 then
        self._sex = data[1].sex
        self._dir = cfgTypes[self._selType].dir
        self:onClickActEvent(2)
    end
end

-- 刷新 ListView
function PreviewAnimLayout:refreshCells()
    for index, cell in ipairs(self._cells) do
        if cell then
            cell:Exit()
            cell:Refresh()
        end
    end
end

function PreviewAnimLayout:getAnimRate(animType, id, sex, act, interval)
    local frames = self:GetCacheFrames(animType, id, sex, act)
    if frames and frames[act] then
        return frames[act] / 1000
    end
    return interval
end                                                                                          

function PreviewAnimLayout:getSpeed(animType, id, sex, act)
    if self._configs2[animType] and self._configs2[animType][id] and self._configs2[animType][id][sex] then
        local intervals = self._configs2[animType][id][sex].interval
        if intervals and intervals[act] then
            local interval = intervals[act]
            interval = act == global.MMO.ANIM_SKILL and interval * 0.75 or interval
            return tonumber(string.format("%.3f", interval / self:getAnimRate(animType, id, sex, act, interval)))
        end
    end
    return 1
end

function PreviewAnimLayout:updateAllAnim(optType, params)
    local animType = self._curSelType

    local node = self:getSfxNode(animType)
    local sfx  = node and node:getChildByName("sfx")
    if sfx then
        if optType == UpdateType.POS then
            sfx:setPosition(cc.pAdd(cc.pSub(sfx:getTurePosition(), {x = self._x or 0, y = self._y or 0}), params))
        elseif optType == UpdateType.BLENDMODE then
            global.FrameAnimManager:setBlendFunc(sfx, params.blend)
            self:refreshCells()
        elseif optType == UpdateType.ANCHORPOINT then
            sfx:setAnchorPoint(params)
        end
    end

    for animType, v in pairs(cfgTypes) do
        local node = self:getSfxNode(animType)
        local sfx  = node and node:getChildByName("sfx")

        if sfx then
            local sex = (sfx._param_ and sfx._param_.sex) or sfx._param_.sex or mmo.ACTOR_PLAYER_SEX_M
            local id  = (sfx._param_ and sfx._param_.id) or sfx._param_.id
            local act = (sfx._param_ and sfx._param_.act) or sfx._param_.act

            local dir = self._dir

            sfx:Stop()

            local speed = self:getSpeed(animType, id, sex, act)
            sfx:Play(act, dir, true, speed)

            local order = cfgZOrders[animType][dir] or 0
            node:setLocalZOrder(order)
        end
    end
end

function PreviewAnimLayout:setSelSfxID()
    if self._selID then
        self._quickUI.Text_ID:setString("ID: "..self._selID)
        self._quickUI.btnDel:setColor(cc.c3b(165, 42, 42))
        self._quickUI.btnDel:setTouchEnabled(true)
    else
        self._quickUI.Text_ID:setString("")
        self._quickUI.btnDel:setColor(cc.c3b(77, 77, 77))
        self._quickUI.btnDel:setTouchEnabled(false)
    end
end

function PreviewAnimLayout:setBtnSaveStatus(normal)
    if normal then
        self._quickUI.btnSave:setColor(cc.c3b(0, 128, 0))
        self._quickUI.btnSave:setTouchEnabled(true)
    else
        self._quickUI.btnSave:setColor(cc.c3b(77, 77, 77))
        self._quickUI.btnSave:setTouchEnabled(false)
    end
end

function PreviewAnimLayout:onReset()
    for animType, v in pairs(cfgTypes) do
        local node = self:getSfxNode(animType)
        if node then
            self:delAllItems(node)
        end
    end
    self._frames = {}
    self:InitCfg()
    self:refreshCells()
    self:setBtnSaveStatus(false)

    for i, v in ipairs(self._quickUI.ListView_3:getChildren()) do
        v:removeFromParent()
        v = nil
    end
    self._quickUI.ListView_3:requestDoLayout()

    self._selIDsList = {}
    self._selSexList = {}
end

-- Esc 退出键
function PreviewAnimLayout:onKeyBackSpace()
    local isVisible = self._quickUI.list_2:isVisible()
    if isVisible then
        return self:InitTypeList(self._selType, self:GetJumpRow(self._selID), true)
    end
    cc.Director:getInstance():getEventDispatcher():removeEventListener(self._listenerKeyBoard)
    self:onClose()
end

-- 键盘事件注册
function PreviewAnimLayout:KeyBoardPressedFunc(keycode, evt)
    if not self._KeyBoards then
        return false
    end
    if self._KeyBoards[keycode] then
        self._KeyBoards[keycode]()
    end
end

function PreviewAnimLayout:onClose()
    global.Facade:sendNotification(global.NoticeTable.PreviewAnimClose)
end

function PreviewAnimLayout:onSearchEvent()
    if self._searchID == -1 then
        ShowSystemTips("<font color='#ff0000'>请输入有效ID</font>")
        return false
    end
    self:UpdateSearch()
end

function PreviewAnimLayout:onDelChildrenPage()
    local node = self:getSfxNode(self._curSelType)
    if node then
        self:delAllItems(node)
    end

    self._frames[self._curSelType] = nil

    self:InitCfg()

    local list = self._quickUI.ListView_3

    if list:getChildrenCount() < 1 then
        self:setBtnSaveStatus(false)
    end

    local item = list:getChildByTag(self._curSelType)
    if item then
        item:removeFromParent()
        item = nil
    end
    
    list:requestDoLayout()

    self._selIDsList[self._curSelType] = false
    self._selSexList[self._curSelType] = false

    local funcSel = function ()
        for _, item in ipairs(list:getChildren()) do
            if item then
                self:setSelectTypeInListView3(item:getTag(), true)
                break
            end
        end
    end
    performWithDelay(self, funcSel, 0.01)
end

function PreviewAnimLayout:onAddEvent()
    global.Facade:sendNotification(global.NoticeTable.AnimSetOpen, {type = self._selType, configs = self._configs, callback = handler(self, self.onAddCallBack)})
end

function PreviewAnimLayout:onAddCallBack(data)
    local config = SL:Require("game_config/cfg_model_info", true)
    config[#config+1] = data
    self:OnSaveRelodCfg(config)
end

function PreviewAnimLayout:onDelEvent()
    local function onSureDel()
        local config = SL:Require("game_config/cfg_model_info", true)
        for k, v in pairs(config) do
            local animType = v.type
            if animType == self._selType and v.id == self._selID  then
                local isDel = false
                if animType == mmo.SFANIM_TYPE_MONSTER or animType == mmo.SFANIM_TYPE_NPC or animType == mmo.SFANIM_TYPE_SKILL then
                    isDel = true
                elseif v.sex == self._sex then
                    isDel = true
                end
                if isDel then
                    config[k] = nil
                    return self:OnSaveRelodCfg(config)
                end
            end
        end
    end

    if not self._selID then
        return false
    end

    local name = ""
    for k, v in pairs(Types) do
        if v.type == self._selType then
            name = v.text
            break
        end
    end

    local data = {}
    data.str = string.format("是否移除[<font color='#ff0000'>%s</font>] ID为<font color='#ff0000'>%s</font>的特效?", name, self._selID)
    data.btnType = 2
    data.callback = function (bType)
        if bType == 1 then 
            onSureDel()
        end
    end
    global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, data)
end

-- 配置保存
function PreviewAnimLayout:OnSaveConfig()
    local data = {}
    local num  = 0
    for animType, v in pairs(cfgTypes) do
        local node = self:getSfxNode(animType)
        local sfx  = node and node:getChildByName("sfx")
        if sfx then
            local sex = (sfx._param_ and sfx._param_.sex) or sfx._param_.sex or mmo.ACTOR_PLAYER_SEX_M
            local id  = (sfx._param_ and sfx._param_.id) or sfx._param_.id

            local anr = sfx:getAnchorPoint()
            local blend = 0
            local x     = tonumber(self._selUIControl["TextField_posX"]:getString()) or 0
            local y     = tonumber(self._selUIControl["TextField_posY"]:getString()) or 0

            if self._configs2[animType] and self._configs2[animType][id] and self._configs2[animType][id][sex] then
                blend   = self._configs2[animType][id][sex].blendmode or blend
                x       = self._configs2[animType][id][sex].offsetx   or x
                y       = self._configs2[animType][id][sex].offsety   or y
            end

            data[animType] = data[animType] or {}
            data[animType][id] = data[animType][id] or {}
            data[animType][id][sex] = { 
                anr = anr, 
                blend = blend,
                pos = {x = x, y = y},
                frames = self:GetCacheFrames(animType, id, sex) or {}
            }

            num = num + 1
        end
    end

    if not next(data) then return false end

    local config = SL:Require("game_config/cfg_model_info", true)
    for k, v in pairs(config) do
        local d = (data[v.type] and data[v.type][v.id] and data[v.type][v.id][v.sex]) and data[v.type][v.id][v.sex]
        if d then
            v.blendmode   = d.blend
            v.offsetx     = d.pos.x
            v.offsety     = d.pos.y
            v.stand_pos_x = d.anr.x
            v.stand_pos_y = d.anr.y

            local frames  = d.frames or {}
            for act, interval in pairs(frames) do
                if act and cfgActFrames[act] then
                    v[cfgActFrames[act]] =  tonumber(interval) / 1000
                end
            end
            
            num = num - 1
            if num < 1 then
                break
            end
        end
    end
    self:OnSaveRelodCfg(config)
end

function PreviewAnimLayout:OnSaveRelodCfg(config)
    SL:SaveTableToConfig(config, "cfg_model_info")
    
    global.FileUtilCtl:purgeCachedEntries()
    
    -- 重新加载数据
    local configProxy = global.Facade:retrieveProxy(global.ProxyTable.ModelConfigProxy)
    configProxy:Reload()

    self:InitCfg()
    self:InitTypeList(self._selType)
end

return PreviewAnimLayout