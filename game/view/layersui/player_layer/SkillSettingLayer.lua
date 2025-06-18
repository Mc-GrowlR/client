local BaseLayer = requireLayerUI("BaseLayer")
local SkillSettingLayer = class("SkillSettingLayer", BaseLayer)

function SkillSettingLayer:ctor()
    SkillSettingLayer.super.ctor(self)
end

function SkillSettingLayer.create()
    local ui = SkillSettingLayer.new()
    if ui and ui:Init() then
        return ui
    end
    return nil
end

function SkillSettingLayer:Init()
    self._quickUI = ui_delegate(self)
    self._proxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    self._selected    = nil
    self._skillCells    = {}
    self._shortcutCells = {}
    return true
end

function SkillSettingLayer:InitGUI()
    SL:RequireFile(SLDefine.LUAFile.LUA_FILE_PLAYER_SKILL_SETTING)
    PlayerSkillSetting.main()

    local meta = {}
    meta.SelectSkill = handler(self, self.SelectSkill)
    meta.__index = meta
    setmetatable(PlayerSkillSetting, meta)

    -- 重置键位
    self._quickUI.Button_cleanup:addClickEventListener(function()
        local skills = self._proxy:GetSkills(true)
        for _, v in pairs(skills) do
            if v.MagicID and global.MMO.SKILL_INDEX_BASIC == v.MagicID then
                self._proxy:DelSkillKey(v.MagicID, true)
            else
                self._proxy:DelSkillKey(v.MagicID)
            end
        end

        self._proxy:SetSkillKey(global.MMO.SKILL_INDEX_BASIC, 1)
    end)

    -- 还原普攻
    self._quickUI.Button_restore_basic:addClickEventListener(function()
        self._proxy:SetSkillKey(global.MMO.SKILL_INDEX_BASIC, 1)
    end)

    self:InitShortcut()
    self:UpdateSkillCells()
    self:CleanupSelected()
end

function SkillSettingLayer:CleanupSelected()
    self._selected = nil

    for _, v in pairs(self._shortcutCells) do
        Shader_Normal(v.imageSkill)
    end
    for k, v in pairs(self._skillCells) do
        v.quickUI.sfx:setVisible(false)
    end
end

function SkillSettingLayer:SelectSkill(skillID)
    self._selected = skillID

    for k, v in pairs(self._skillCells) do
        v.quickUI.sfx:setVisible(v.skillID == skillID)
    end

    for _, v in pairs(self._shortcutCells) do
        if v.skillID == skillID then
            Shader_Grey(v.imageSkill)
        else
            Shader_Normal(v.imageSkill)
        end
    end
end

function SkillSettingLayer:UpdateSkillCells()
    self._skillCells = {}
    self._quickUI.ScrollView_skills:removeAllChildren()

    local skills = self._proxy:GetSkills(true, true)
    skills = HashToSortArray(skills, function(a, b)
        local a_info = self._proxy:FindConfigBySkillID(a.MagicID)
        local b_info = self._proxy:FindConfigBySkillID(b.MagicID)
        if not a_info or not b_info then
            return false
        end
        if not a_info.index or not b_info.index then
            return false
        end
        return a_info.index < b_info.index
    end)
    local itemWid = 95
    local itemHei = 110
    local innerWid = 385
    local innerHei = math.max(math.ceil(#skills / 3) * 110, 410)
    self._quickUI.ScrollView_skills:setInnerContainerSize(cc.size(innerWid, innerHei))
    for i, v in ipairs(skills) do
        local cell = PlayerSkillSetting.CreateSkillCell(self._quickUI.ScrollView_skills, v.MagicID)
        self._skillCells[v.MagicID] = cell

        local x = (i - 1) % 3 * itemWid
        local y = innerHei - math.floor((i - 1) / 3) * itemHei
        cell.quickUI.nativeUI:setPosition(cc.p(x, y))
    end

    self:CleanupSelected()
end

function SkillSettingLayer:InitShortcut()
    for i = 1, 9 do
        local function callback()
            self:OnEventShortcut(i)
        end

        self._shortcutCells[i] = {}
        local imageBG = self._quickUI.Panel_shortcut:getChildByName(string.format("Image_skill_%s", i))
        imageBG:setTouchEnabled(true)
        imageBG:addClickEventListener(callback)
        self._shortcutCells[i].imageBG = imageBG

        local imageSkill = ccui.ImageView:create()
        local contentSize = imageBG:getContentSize()
        imageBG:addChild(imageSkill)
        imageSkill:setVisible(false)
        imageSkill:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
        imageSkill:ignoreContentAdaptWithSize(false)
        imageSkill:setContentSize(i == 1 and cc.size(78, 78) or cc.size(53, 53))
        self._shortcutCells[i].imageSkill = imageSkill
    end

    local skills = self._proxy:GetSkills(false, true)
    for _, v in pairs(skills) do
        if v.MagicID == 0 then

        end
        if v.Key and (v.Key >= 1 and v.Key <= 9) then
            self:OnSkillChangeKey({ skill = v }, true)
        end
    end
end

function SkillSettingLayer:OnEventShortcut(key)
    if not self._selected then
        return nil
    end

    -- special basic skill
    if self._selected ~= global.MMO.SKILL_INDEX_BASIC and key ~= 1 then
        local baseKeySkill = self._proxy:GetSkillByKey(1) or {}
        if not baseKeySkill or baseKeySkill.id == self._selected then
            self._proxy:SetSkillKey(0, 1)
        end
    end

    -- new key
    self._proxy:SetSkillKey(self._selected, key)

    self:CleanupSelected()
end

function SkillSettingLayer:OnSkillChangeKey(data, isInit)
    if not data.skill.Key or not (data.skill.Key >= 1 and data.skill.Key <= 9) then
        return nil
    end
    local shortcutCell = self._shortcutCells[data.skill.Key]
    if not shortcutCell then
        return nil
    end

    -- reset last
    if data.last then
        self:OnSkillDeleteKey({ key = data.last.Key, skillID = data.last.MagicID })
    end

    -- new key
    local path = self._proxy:GetIconPathByID(data.skill.MagicID)
    shortcutCell.imageSkill:setVisible(true)
    shortcutCell.imageSkill:loadTexture(path)
    shortcutCell.skillID = data.skill.MagicID
    shortcutCell.key    = data.skill.Key

    if not isInit and data.skill.MagicID ~= global.MMO.SKILL_INDEX_BASIC and global.FileUtilCtl:isFileExist(path) then
        local startPos    = cc.p(0, 0)
        local endPos        = shortcutCell.imageSkill:getWorldPosition()
        local ctrlPos    = cc.p(0, 0)
        for k, v in pairs(self._skillCells) do
            if v.skillID == data.skill.MagicID then
                startPos = v.quickUI.Image_icon:getWorldPosition()
                break
            end
        end
        startPos = self._quickUI.PMainUI:convertToNodeSpace(startPos)
        endPos = self._quickUI.PMainUI:convertToNodeSpace(endPos)
        ctrlPos = { x = startPos.x + math.abs(endPos.x - startPos.x) * 0.4, y = startPos.y + 200 }

        local motionStreak = cc.MotionStreak:create(0.12, 1, 50, cc.c3b(255, 255, 255), path)
        self._quickUI.PMainUI:addChild(motionStreak)
        motionStreak:setPosition(startPos)
        motionStreak:reset()
        motionStreak:runAction(cc.Sequence:create(
        cc.EaseSineInOut:create(cc.BezierTo:create(0.7, { startPos, ctrlPos, endPos })),
        cc.RemoveSelf:create()
        ))

        local scale = shortcutCell.imageSkill:getContentSize().width / 65
        local imageA = ccui.ImageView:create(path)
        self._quickUI.PMainUI:addChild(imageA)
        imageA:ignoreContentAdaptWithSize(false)
        imageA:setContentSize(cc.size(65, 65))
        imageA:setPosition(startPos)
        imageA:runAction(cc.Sequence:create(
        cc.CallFunc:create(function()
            shortcutCell.imageSkill:setVisible(false)
        end),
        cc.ScaleTo:create(0, 1),
        cc.EaseSineInOut:create(cc.Spawn:create(
        cc.BezierTo:create(0.7, { startPos, ctrlPos, endPos }),
        cc.FadeTo:create(0.7, 150), cc.ScaleTo:create(0.7, scale))
        ),
        cc.CallFunc:create(function()
            shortcutCell.imageSkill:setVisible(true)
        end),
        cc.RemoveSelf:create()
        ))

    end
end

function SkillSettingLayer:OnSkillDeleteKey(data)
    local key    = data.key
    if not key or not (key >= 1 and key <= 9) then
        return nil
    end

    local shortcutCell = self._shortcutCells[key]
    if not shortcutCell then
        return nil
    end
    shortcutCell.imageSkill:setVisible(false)
    shortcutCell.skillID = nil
    shortcutCell.key    = nil
end

return SkillSettingLayer