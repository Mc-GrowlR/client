
local SkillItem = class("SkillItem", function() return ccui.Widget:create() end)

function SkillItem:ctor()
end

function SkillItem:init(data)
    -- self:InitWidgetConfig("skill/skill_item")
    -- self.ui = ui_delegate(self._widget)
    local Panel_1 = GUI:Layout_Create(self, "Panel_1", 0, 0, 60, 60, false)
    GUI:setAnchorPoint(Panel_1, 0.50, 0.50)
    -- Create Image_icon
    local Image_icon = GUI:Image_Create(Panel_1, "Image_icon", 30, 30, "Default/ImageFile.png")
    GUI:setContentSize(Image_icon, 60, 60)
    GUI:setIgnoreContentAdaptWithSize(Image_icon, false)
    GUI:setAnchorPoint(Image_icon, 0.50, 0.50)
    GUI:setTouchEnabled(Image_icon, false)
    self.Image_icon = Image_icon

    local contentSize = Panel_1:getContentSize()
    self:setContentSize(contentSize)
    self:setAnchorPoint({x=0.5,y=0.5})

    Panel_1:setPosition(contentSize.width * 0.5, contentSize.height * 0.5)

    self:Cleanup()
    self:setSkillID(data)

    return true
end

function SkillItem:OnEnter()
end

function SkillItem:OnExit()
end

function SkillItem:Cleanup()
end

function SkillItem:setSkillID(skillID)
    local SkillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
    local iconPath   = SkillProxy:GetIconRectPathByID(skillID)
    if not iconPath then
        return nil
    end
    self.Image_icon:loadTexture(iconPath)
end

return SkillItem
