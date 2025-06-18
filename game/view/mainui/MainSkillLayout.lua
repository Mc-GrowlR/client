local MainSkillLayout = class("MainSkillLayout", function()
    return cc.Node:create()
end)

local sformat = string.format

function MainSkillLayout:ctor()
    self._path = global.MMO.PATH_RES_PRIVATE .. "main/"

    self._nodeCells = {}
    self._skillCells = {}  

    self._heroSkillCell = nil

    self.HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
end

function MainSkillLayout.create()
    local layout = MainSkillLayout.new()
    if layout:Init() then
        return layout
    end
    return nil
end

function MainSkillLayout:Init()
    self.ui = ui_delegate(self)

    return true
end

function MainSkillLayout:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_MAIN_SKILL)

    local meta = {}
    meta.ClickSkillEvent = handler(self, self.ClickSkillEvent)
    meta.click_HeroSkill = handler(self, self.click_HeroSkill)
    meta.JointHeroEffect = handler(self, self.HeroJointEffect)
    meta.ClickComboSkill = handler(self, self.ClickComboSkillEvent)
    meta.__index = meta
    setmetatable(MainSkill, meta)

    MainSkill.main()

    self:InitSkill()

    self:InitEditMode()

    self._layoutSkill = self.ui.Panel_skill
    self._layoutActive = self.ui.Panel_active

    return true
end

function MainSkillLayout:InitEditMode()

    for i = 1, 9 do
        local name = string.format("Node_cell_%s", i)
        if self.ui[name] then
            self.ui[name].editMode = 1
        end
    end

    local items = {
        "Panel_quick_find",
        "Image_player",
        "Image_monster",
        "Image_hero",
        "Button_attack",
        "Button_pick",
        "Button_change",
        "Button_Lock",
        "Node_hj_skill"
    }

    for _, widgetName in ipairs(items) do
        if self.ui[widgetName] then
            self.ui[widgetName].editMode = 1
        end
    end
end

function MainSkillLayout:UpdatePick()
    local AutoProxy = global.Facade:retrieveProxy( global.ProxyTable.Auto )
    if AutoProxy:IsPickState() then
        self.ui.Button_pick:setBright(false)
    else
        self.ui.Button_pick:setBright(true)
    end
end

function MainSkillLayout:UpdatePickupVisible(visible)
    self.ui.Button_pick:setVisible(visible)
end

function MainSkillLayout:InitSkill()
    for i = 1, 9 do
        local node = self.ui[sformat("Node_cell_%s", i)]
        table.insert(self._nodeCells, node)
    end

    -- attack
    self.ui.Button_attack:addTouchEventListener(function(_, eventType)
        if eventType == 0 then
            global.Facade:sendNotification(global.NoticeTable.LaunchAttackSkill)

            self.ui.Button_attack:stopAllActions()
            schedule(self.ui.Button_attack, function()
                global.Facade:sendNotification(global.NoticeTable.LaunchAttackSkill)
            end, 0.01)

        elseif eventType == 2 or eventType == 3 then
            self.ui.Button_attack:stopAllActions()
        end
    end)
end

function MainSkillLayout:AddSkill(data)
    local node = self._nodeCells[data.Key]
    -- skill
    local cell = self:CreateSkillCell(data)
    cell.layoutBG:removeFromParent()
    self._skillCells[data.MagicID] = cell
    node:addChild(cell.layoutBG)
    
end

function MainSkillLayout:RmvSkill(data, key)
    if not data.MagicID or not key then
        return false
    end

    local node = self._nodeCells[key]
    node:removeAllChildren()

    self._skillCells[data.MagicID] = nil

    -- cleanup select skill
    local SkillProxy  = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local selectSkill = SkillProxy:GetSelectSkill()
    if selectSkill and selectSkill == data.MagicID then
        SkillProxy:SelectSkill(nil)
    end
end

function MainSkillLayout:CleanupAllSkill()
    for _, v in pairs(self._nodeCells) do
        v:removeAllChildren()
    end

    self._skillCells = {}

    -- cleanup range skill
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    SkillProxy:SelectSkill(nil)
end

function MainSkillLayout:CreateSkillCell(data)
    local root = cc.Node:create() 
    if MainSkill and MainSkill.createSkillCell then
        local cell = MainSkill.createSkillCell(root,data)
        return cell
    end
end

function MainSkillLayout:CreateHeroSkillCell(parent,data)
    if MainSkill and MainSkill.createHeroSkillCell then
        local cell = MainSkill.createHeroSkillCell(parent, data)
        return cell
    end
end

function MainSkillLayout:OnHeroSkillInit()
    local HeroSkillProxy    = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
    local heroSkill        = HeroSkillProxy:haveHeroSkill()

    if not heroSkill then
        return nil
    end
    local data = {}
    data.MagicID = heroSkill
    self:OnHeroSkillAdd(data)

end

function MainSkillLayout:OnHeroSkillAdd(data)
    
    local HeroSkillProxy    = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
    local isHeroSkill      = HeroSkillProxy:isHeroSkill(data.MagicID)
    if not isHeroSkill then
        return nil
    end
    if self._heroSkillCell then
        return 
    end

    -- skill
    local cell = self:CreateHeroSkillCell(self.ui.Node_hj_skill,data)
    self._heroSkillCell = cell
    
end

function MainSkillLayout:OnHeroSkillDel(data)
    local HeroSkillProxy    = global.Facade:retrieveProxy(global.ProxyTable.Skill)

    self._heroSkillCell  = nil
    self.ui.Node_hj_skill:removeAllChildren()
end

function MainSkillLayout:HeroJointEffect(canuse)
    if self._heroSkillCell then
        local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
        self._heroSkillCell.nodeSFX:setVisible(canuse)
        if canuse then
            Shader_Normal(self._heroSkillCell.buttonIcon)
        else
            Shader_Grey(self._heroSkillCell.buttonIcon)
        end

    end
    
end

function MainSkillLayout:click_HeroSkill(tips)
    local HeroSkillProxy    = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
    local heroSkill        = HeroSkillProxy:haveHeroSkill()
    if not heroSkill  then
        if tips then
            ShowSystemTips("当前没有英雄技能")
        end
        return nil
    end
    
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)
    if HeroPropertyProxy:getShan()  then--在闪的时候才能放合击
        HeroPropertyProxy:ReqJointAttack()--请求合击
    end
end

function MainSkillLayout:UpdateExtraVisible()
    local HeroSkillProxy    = global.Facade:retrieveProxy(global.ProxyTable.HeroSkillProxy)
    local HeroPropertyProxy = global.Facade:retrieveProxy(global.ProxyTable.HeroPropertyProxy)

    if HeroPropertyProxy:HeroIsLogin() then
        self.ui.Node_hj_skill:setVisible(true)
    else
        self.ui.Node_hj_skill:setVisible(false)
    end
end


function MainSkillLayout:ClickSkillEvent(sender, skillID)

    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    
    -- 开关技能
    if SkillProxy:IsOnoffSkill(skillID) then
        SkillProxy:RequestSkillOnoff(skillID)
        return nil
    end

    -- 输入坐标技能
    if SkillProxy:IsInputDestSkill(skillID) then
        -- reset last select
        local lastSelect = SkillProxy:GetSelectSkill()
        if lastSelect then
            local cell = self._skillCells[lastSelect]
            if cell then
                cell.nodeSelect:removeAllChildren()
            end
            SkillProxy:SelectSkill(nil)

            if skillID == lastSelect then
                return nil
            end
        end

        -- select
        SkillProxy:SelectSkill(skillID)
        local cell = self._skillCells[skillID]
        if cell then
            local key = SkillProxy:GetSkillKey(skillID)
            local sfx = global.FrameAnimManager:CreateSFXAnim(4005)
            cell.nodeSelect:addChild(sfx)
            sfx:SetGlobalElapseEnable(true)
            sfx:Play(0, 0, true)
            sfx:setScale(key == 1 and 0.9 or 0.6)
        end

        return nil
    end

    -- 普通释放技能
    self:LaunchSkill({skillID = skillID})
end

function MainSkillLayout:LaunchSkill(data)
    local skillID = data.skillID

    if skillID == 0 and self._comboSkillID then
        skillID = self._comboSkillID
        self._comboSkillID = nil
    end
    
    local PlayerInputProxy = global.Facade:retrieveProxy(global.ProxyTable.PlayerInputProxy)
    if skillID == 0 and PlayerInputProxy:CheckMiningAble() then
        local mainPlayer    = global.gamePlayerController:GetMainPlayer()
        local destPos       = cc.p(mainPlayer:GetMapX(), mainPlayer:GetMapY())

        global.Facade:sendNotification(global.NoticeTable.UserInputMining, {dest=destPos})
    else
        global.Facade:sendNotification(global.NoticeTable.UserInputLaunch, {skillID = skillID, priority = global.MMO.LAUNCH_PRIORITY_USER})
    end
end

function MainSkillLayout:ClickComboSkillEvent(skillID)
    
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)

    if skillID and skillID ~= 0 then
        -- 开关技能
        if SkillProxy:IsOnoffSkill(skillID) then
            SkillProxy:RequestSkillOnoff(skillID, true)
            self._comboSkillID = skillID
            return nil
        end

        -- 普通释放技能
        self:LaunchSkill({skillID = skillID})
    end
end

function MainSkillLayout:OnSkillAdd(data)
    -- 没有快捷键
    if (not data.Key) or (data.Key == 0) then
        return false
    end

    -- 已存在
    if self._skillCells[data.MagicID] then
        print("MAIN SKILL ADD ERROR: EXIST SKILL. ID: " .. data.MagicID)
        return false
    end

    self:AddSkill(data)
end

function MainSkillLayout:OnSkillDel(data)
    -- 没有快捷键
    if (not data.Key) or (data.Key == 0) then
        return false
    end

    -- 不存在
    if not self._skillCells[data.MagicID] then
        return false
    end

    self:RmvSkill(data, data.Key)
end

function MainSkillLayout:OnSkillSkillUpdate(data)
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)

    -- 没有快捷键
    if (not data.Key) or (data.Key == 0) then
        return false
    end

    -- 不存在
    if not self._skillCells[data.MagicID] then
        return false
    end

    local skillCell = self._skillCells[data.MagicID]
    local iconPath  = SkillProxy:GetIconPathByID(data.MagicID)
    skillCell.buttonIcon:loadTextureNormal(iconPath)
end

function MainSkillLayout:OnSkillChangeKey(data)
    local last = data.last
    local skill = data.skill

    -- remove
    self:OnSkillDel(last)
    
    -- add
    self:OnSkillAdd(skill)
end

function MainSkillLayout:OnSkillDeleteKey(data)
    -- 没有快捷键
    if (not data.delKey) or (data.delKey == 0) then
        return false
    end

    -- 不存在
    if not self._skillCells[data.skill.MagicID] then
        return false
    end

    self:RmvSkill(data.skill, data.delKey)
end

function MainSkillLayout:OnSkillCDTimeChange(data)
    local skillCell =  self._skillCells[data.id]
    if skillCell then
        skillCell.progressCD:setVisible(data.percent ~= 0)
        skillCell.progressCD:setPercentage(data.percent)
        skillCell.CDTime:setString(data.percent ~= 0 and string.format("%.1f", data.time) or "")
    end
end

function MainSkillLayout:OnSkillOn(data)
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local cell = self._skillCells[data.skillID]
    if cell then
        local key = SkillProxy:GetSkillKey(data.skillID)
        local sfx = global.FrameAnimManager:CreateSFXAnim(4005)
        cell.nodeON:removeAllChildren()
        cell.nodeON:addChild(sfx)
        sfx:SetGlobalElapseEnable(true)
        sfx:Play(0, 0, true)
        sfx:setScale(key == 1 and 0.9 or 0.6)
    end
end

function MainSkillLayout:OnSkillOff(data)
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local cell = self._skillCells[data.skillID]
    if cell then
        cell.nodeON:removeAllChildren()
    end
end

function MainSkillLayout:OnClearSelectSkill(skillID)
    if not skillID then
        return false
    end
    local cell = self._skillCells[skillID]
    if cell then
        cell.nodeSelect:removeAllChildren()
    end
end

function MainSkillLayout:OnPlayerEquipChange()
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local skillData  = SkillProxy:GetSkillByKey(1)
    local skillCell  = self._skillCells[0]
    if skillCell and skillData then
        local buttonIcon = skillCell.buttonIcon
        local path = SkillProxy:GetIconPathByID(skillData.MagicID)
        buttonIcon:loadTextureNormal(path)
    end
end

function MainSkillLayout:OnGuideEnterTransition(data)
    if data.extent then
        MainSkill.ChangeShowIndex(MainSkill._showIndex == 1 and 2 or 1)
    else
        if data.name == "GUIDE_BEGIN_SKILL_BUTTON" then
            MainSkill.ChangeShowIndex(2)
        elseif data.name == "GUIDE_BEGIN_SKILL_CHANGE_BUTTON" then
            MainSkill.ChangeShowIndex(1)
        end
    end
end

function MainSkillLayout:IsSkillPanelShow( ... )
    return MainSkill._showIndex == 1
end

return MainSkillLayout
