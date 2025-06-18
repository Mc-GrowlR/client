local AnimSetLayout = class("AnimSetLayout", function() return cc.Node:create() end)

local defaultCfg = {
    id                  =       0,
    type                =       1,
    sex                 =       0,
    blendmode           =       0,
    offsetx             =       0,
    offsety             =       0,
    stand_pos_x         =       0,
    stand_pos_y         =       1,
    idle_interval       =       0.25,
    walk_interval       =       0.09,
    run_interval        =       0.1,
    attack_interval     =       0.085,
    magic_interval      =       0.1,
    die_interval        =       0.12,
    stuck_interval      =       0.07,
    sitdown_interval    =       0.3,
    mining_interval     =       0.09,
    ready_interval      =       0.2
}

local radio    = 1000

local minFrame = 20
local maxFrame = 2000

function AnimSetLayout:ctor()
    self._Attr = {
        ["TF_Type"]      = { IMode = 2, Min = 1, Max = 9, SetWidget = handler(self, self.SetType), SetUIWidget = handler(self, self.SetUIType), Init = handler(self, self.InitEditBox) },
        ["TF_ID"]        = { IMode = 2, SetWidget = handler(self, self.SetID), SetUIWidget = handler(self, self.SetUIID), Init = handler(self, self.InitEditBox)  },
        ["TF_Sex"]       = { IMode = 2, Min = 0, Max = 1, SetWidget = handler(self, self.SetSex), SetUIWidget = handler(self, self.SetUISex), Init = handler(self, self.InitEditBox) },
        ["TF_BlendMode"] = { IMode = 6, Min = 0, Max = 4, SetWidget = handler(self, self.SetBlendMode), SetUIWidget = handler(self, self.SetUIBlendMode), Init = handler(self, self.InitEditBox) },

        ["TF_AnrX"] = { IMode = 6, Max = 2, Min = 0, SetWidget = handler(self, self.SetAnrX), SetUIWidget = handler(self, self.SetUIAnrX), Init = handler(self, self.InitEditBox) },
        ["TF_AnrY"] = { IMode = 6, Max = 2, Min = 0, SetWidget = handler(self, self.SetAnrY), SetUIWidget = handler(self, self.SetUIAnrY), Init = handler(self, self.InitEditBox) },
        ["TF_OffX"] = { IMode = 6, SetWidget = handler(self, self.SetOffX), SetUIWidget = handler(self, self.SetUIOffX), Init = handler(self, self.InitEditBox) },
        ["TF_OffY"] = { IMode = 6, SetWidget = handler(self, self.SetOffY), SetUIWidget = handler(self, self.SetUIOffY), Init = handler(self, self.InitEditBox) },

        ["TF_Idle"]    = { IMode = 6, Radio = radio, Min = minFrame, Max = maxFrame, SetWidget = handler(self, self.SetIdle), SetUIWidget = handler(self, self.SetUIIdle), Init = handler(self, self.InitEditBox) },
        ["TF_Walk"]    = { IMode = 6, Radio = radio, Min = minFrame, Max = maxFrame, SetWidget = handler(self, self.SetWalk), SetUIWidget = handler(self, self.SetUIWalk), Init = handler(self, self.InitEditBox) },
        ["TF_Run"]     = { IMode = 6, Radio = radio, Min = minFrame, Max = maxFrame, SetWidget = handler(self, self.SetRun), SetUIWidget = handler(self, self.SetUIRun), Init = handler(self, self.InitEditBox) },
        ["TF_Magic"]   = { IMode = 6, Radio = radio, Min = minFrame, Max = maxFrame, SetWidget = handler(self, self.SetMagic), SetUIWidget = handler(self, self.SetUIMagic), Init = handler(self, self.InitEditBox) },
        ["TF_Attack"]  = { IMode = 6, Radio = radio, Min = minFrame, Max = maxFrame, SetWidget = handler(self, self.SetAttack), SetUIWidget = handler(self, self.SetUIAttack), Init = handler(self, self.InitEditBox) },
        ["TF_Die"]     = { IMode = 6, Radio = radio, Min = minFrame, Max = maxFrame, SetWidget = handler(self, self.SetDie), SetUIWidget = handler(self, self.SetUIDie), Init = handler(self, self.InitEditBox) },
        ["TF_Stuck"]   = { IMode = 6, Radio = radio, Min = minFrame, Max = maxFrame, SetWidget = handler(self, self.SetStuck), SetUIWidget = handler(self, self.SetUIStuck), Init = handler(self, self.InitEditBox) },
        ["TF_SitDown"] = { IMode = 6, Radio = radio, Min = minFrame, Max = maxFrame, SetWidget = handler(self, self.SetSitDown), SetUIWidget = handler(self, self.SetUISitDown), Init = handler(self, self.InitEditBox) },
        ["TF_Mining"]  = { IMode = 6, Radio = radio, Min = minFrame, Max = maxFrame, SetWidget = handler(self, self.SetMining), SetUIWidget = handler(self, self.SetUIMining), Init = handler(self, self.InitEditBox) },
        ["TF_Read"]    = { IMode = 6, Radio = radio, Min = minFrame, Max = maxFrame, SetWidget = handler(self, self.SetRead), SetUIWidget = handler(self, self.SetUIRead), Init = handler(self, self.InitEditBox) },

                
        ["Text_Type"]      = { text = "类型（1-角色; 2-怪物; 3-NPC; 4-技能或特效; 6-武器; 7-盾牌; 8-翅膀; 9-发型）", a = {x = 0.15, y = 0.5},  MouseFunc = handler(self, self.OnMouseEvent) },
        ["Text_ID"]        = { text = "特效唯一ID", MouseFunc = handler(self, self.OnMouseEvent) },
        ["Text_Sex"]       = { text = "性别(0男1女)不带性的别默认0", a = {x = 0.38, y = 0.5}, MouseFunc = handler(self, self.OnMouseEvent) },
        ["Text_BlendMode"] = { text = "混合模式（0-常规; 1-变亮; 2-滤色）", MouseFunc = handler(self, self.OnMouseEvent) },

        ["Text_AnrX"]      = { text = "站位点_x（左是加）", MouseFunc = handler(self, self.OnMouseEvent) },
        ["Text_AnrY"]      = { text = "站位点_y（上是减）", MouseFunc = handler(self, self.OnMouseEvent) },
        ["Text_OffX"]      = { text = "偏移点_x（上是加）", MouseFunc = handler(self, self.OnMouseEvent) },
        ["Text_OffY"]      = { text = "偏移点_y（上是加）", MouseFunc = handler(self, self.OnMouseEvent) },

        ["Text_Idle"]      = { text = "待机_帧间隔", MouseFunc = handler(self, self.OnMouseEvent) },
        ["Text_Walk"]      = { text = "走路_帧间隔", MouseFunc = handler(self, self.OnMouseEvent) },
        ["Text_Run"]       = { text = "跑_帧间隔",   MouseFunc = handler(self, self.OnMouseEvent) },
        ["Text_Magic"]     = { text = "施法_帧间隔", MouseFunc = handler(self, self.OnMouseEvent) },
        ["Text_Attack"]    = { text = "攻击_帧间隔", MouseFunc = handler(self, self.OnMouseEvent) },
        ["Text_Die"]       = { text = "死亡_帧间隔", MouseFunc = handler(self, self.OnMouseEvent) },
        ["Text_Stuck"]     = { text = "受击_帧间隔", MouseFunc = handler(self, self.OnMouseEvent) },
        ["Text_SitDown"]   = { text = "蹲下_帧间隔", MouseFunc = handler(self, self.OnMouseEvent) },
        ["Text_Mining"]    = { text = "挖矿_帧间隔", MouseFunc = handler(self, self.OnMouseEvent) },
        ["Text_Read"]      = { text = "预备_帧间隔", MouseFunc = handler(self, self.OnMouseEvent) },

        
        ["Image_Sex"]     = { Show = 1},
        ["Image_Walk"]    = { Show = 2 },
        ["Image_Run"]     = { Show = 2 },
        ["Image_Magic"]   = { Show = 2 },
        ["Image_Attack"]  = { Show = 2 },
        ["Image_Die"]     = { Show = 2 },
        ["Image_Stuck"]   = { Show = 2 },
        ["Image_SitDown"] = { Show = 2 },
        ["Image_Mining"]  = { Show = 2 },
        ["Image_Read"]    = { Show = 2 }
    }

    global.userInputController:addKeyboardListener(cc.KeyCode.KEY_ESCAPE, function ()
        self:onKeyBackSpace()
        return true
    end, nil, 0)
end

function AnimSetLayout.create(data)
    local layout = AnimSetLayout.new()
    if layout:Init(data) then
        return layout
    else
        return nil
    end
end

function AnimSetLayout:Init(data)
    local root = CreateExport("preview_anim/anim_set")
    if not root then
        return false
    end
    self:addChild(root)
    self._quickUI = ui_delegate(self)
    
    self._Cfg = defaultCfg
    self._cacheValue = {}

    self._Cfg.type = data.type or 1
    self._configs  = data.configs
    self._callback = data.callback
    self._Cfg.id   = self:GetDefaultMaxID()

    self:InitEvent()
    self:InitInputEvent()
    
    self:UpdateUIControl()

    return true
end

-----------------------------------------------------------------------------------------

function AnimSetLayout:InitEvent()
    self._quickUI.btnClose:addClickEventListener(handler(self, self.onClose))
    self._quickUI.btnCancel:addClickEventListener(handler(self, self.onClose))
    self._quickUI.btnSave:addClickEventListener(handler(self, self.onSave))
end

-----------------------------------------------------------------------------------------
-- Input Event Start
function AnimSetLayout:InitInputEvent()
    self._selUIControl = {}
    for name,d in pairs(self._Attr) do
        local widget = self._quickUI[name]
        local Init = d.Init
        if Init then
            self._selUIControl[name] = Init(widget, d.IMode)
        end
        local MouseFunc = d.MouseFunc
        if MouseFunc then
            MouseFunc(widget, d.text, d.a)
        end
        local Show = d.Show
        if Show then
            if Show == 2 and (self._Cfg.type == global.MMO.SFANIM_TYPE_NPC or self._Cfg.type == global.MMO.SFANIM_TYPE_SKILL) then
                widget:setVisible(true)
                widget:setLocalZOrder(3)
            elseif Show == 1 and (self._Cfg.type == global.MMO.SFANIM_TYPE_NPC or self._Cfg.type == global.MMO.SFANIM_TYPE_SKILL or self._Cfg.type == global.MMO.SFANIM_TYPE_MONSTER) then
                widget:setVisible(true)
                widget:setLocalZOrder(3)
            else
                widget:setVisible(false)
            end
        end
    end
end

function AnimSetLayout:InitEditBox(widget, inputMode)
    local editBox = CreateEditBoxByTextField(widget)
    editBox:setInputMode(inputMode)
    editBox:setTextHorizontalAlignment(1)
    self:initTextFieldEvent(editBox)
    return editBox
end

function AnimSetLayout:OnMouseEvent(widget, str, anr)
    if global.mouseEventController then
        widget:addMouseOverTips(str, {x = 0, y = 0}, anr or {x = 0.5, y = 0.5}, nil, true)
    end
end

function AnimSetLayout:initTextFieldEvent(widget)
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
                str = tonumber(str) or 0
                if min and str < min then
                    str = min
                end
                if max then
                    str = math.max(math.min(str, max), min or 0)
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

function AnimSetLayout:updateUIAttr(name, value)
    if name and self._Attr[name] and self._Attr[name].SetWidget then
        self._Attr[name].SetWidget(value, self._Attr[name].Radio)
        self._cacheValue[name] = value
    end
    self:UpdateUIControl()
end

function AnimSetLayout:UpdateUIControl()
    for name,_ in pairs(self._selUIControl) do
        if self._Attr[name] and self._Attr[name].SetUIWidget then
            self._Attr[name].SetUIWidget(self._selUIControl[name], name, self._Attr[name].Radio)
        end
    end
end

function AnimSetLayout:SetType(value)
    self._Cfg.type = value
end
function AnimSetLayout:SetUIType(widget, name)
    local value = self._Cfg.type
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetID(value)
    self._Cfg.id = value
end
function AnimSetLayout:SetUIID(widget, name)
    local value = self._Cfg.id
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetSex(value)
    self._Cfg.sex = value
end
function AnimSetLayout:SetUISex(widget, name)
    local value = self._Cfg.sex
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetBlendMode(value)
    self._Cfg.blendmode = value
end
function AnimSetLayout:SetUIBlendMode(widget, name)
    local value = self._Cfg.blendmode
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetAnrX(value)
    self._Cfg.stand_pos_x = value
end
function AnimSetLayout:SetUIAnrX(widget, name)
    local value = self._Cfg.stand_pos_x
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetAnrY(value)
    self._Cfg.stand_pos_y = value
end
function AnimSetLayout:SetUIAnrY(widget, name)
    local value = self._Cfg.stand_pos_y
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetOffX(value)
    self._Cfg.offsetx = value
end
function AnimSetLayout:SetUIOffX(widget, name)
    local value = self._Cfg.offsetx
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetOffY(value)
    self._Cfg.offsety = value
end
function AnimSetLayout:SetUIOffY(widget, name)
    local value = self._Cfg.offsety
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetIdle(value, radio)
    self._Cfg.idle_interval = value / radio
end
function AnimSetLayout:SetUIIdle(widget, name, radio)
    local value = self._Cfg.idle_interval * radio
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetWalk(value, radio)
    self._Cfg.walk_interval = value / radio
end
function AnimSetLayout:SetUIWalk(widget, name, radio)
    local value = self._Cfg.walk_interval * radio
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetRun(value, radio)
    self._Cfg.run_interval = value / radio
end
function AnimSetLayout:SetUIRun(widget, name, radio)
    local value = self._Cfg.run_interval * radio
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetMagic(value, radio)
    self._Cfg.magic_interval = value / radio
end
function AnimSetLayout:SetUIMagic(widget, name, radio)
    local value = self._Cfg.magic_interval * radio
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetAttack(value, radio)
    self._Cfg.attack_interval = value / radio
end
function AnimSetLayout:SetUIAttack(widget, name, radio)
    local value = self._Cfg.attack_interval * radio
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetDie(value, radio)
    self._Cfg.die_interval = value / radio
end
function AnimSetLayout:SetUIDie(widget, name, radio)
    local value = self._Cfg.die_interval * radio
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetStuck(value, radio)
    self._Cfg.stuck_interval = value / radio
end
function AnimSetLayout:SetUIStuck(widget, name, radio)
    local value = self._Cfg.stuck_interval * radio
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetSitDown(value, radio)
    self._Cfg.sitdown_interval = value / radio
end
function AnimSetLayout:SetUISitDown(widget, name, radio)
    local value = self._Cfg.sitdown_interval * radio
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetMining(value, radio)
    self._Cfg.mining_interval = value / radio
end
function AnimSetLayout:SetUIMining(widget, name, radio)
    local value = self._Cfg.mining_interval * radio
    self._cacheValue[name] = value
    widget:setString(value)
end

function AnimSetLayout:SetRead(value, radio)
    self._Cfg.ready_interval = value / radio
end
function AnimSetLayout:SetUIRead(widget, name, radio)
    local value = self._Cfg.ready_interval * radio
    self._cacheValue[name] = value
    widget:setString(value)
end

-- Input Event End
-----------------------------------------------------------------------------------------

function AnimSetLayout:GetDefaultMaxID(type)
    local maxID = 0
    for k, v in pairs(self._configs[self._Cfg.type]) do
        local ID = v.id
        if ID ~= 9999 and ID > maxID then
            maxID = ID
        end
    end
    maxID = maxID + 1
    if maxID == 9999 then
        maxID = maxID + 1
    end
    return maxID
end

function AnimSetLayout:IsExistID()
    for k, v in pairs(self._configs[self._Cfg.type]) do
        local ID = v.id
        if self._Cfg.id == v.id then
            return true
        end
    end
    return false
end

function AnimSetLayout:onSave()
    if self:IsExistID() then
        global.Facade:sendNotification(global.NoticeTable.Layer_CommonTips_Open, {str = "ID重复, 配置中已存在", btnType = 1})
        return false
    end
    if self._callback then
        self._callback(self._Cfg)
    end
    self:onClose()
end

-- Esc 退出键
function AnimSetLayout:onKeyBackSpace()
    self:onClose()
end

function AnimSetLayout:onClose()
    global.Facade:sendNotification(global.NoticeTable.AnimSetClose)
end

return AnimSetLayout