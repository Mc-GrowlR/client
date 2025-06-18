-- 技能CD计算 耦合度较高，且计算频繁，相关逻辑放在这直接处理，不采用Notification方式
local CalcComboSkillCDMediator = class("CalcComboSkillCDMediator", framework.Mediator)
CalcComboSkillCDMediator.NAME = "CalcComboSkillCDMediator"

local mmax = math.max
local facade = global.Facade
local noticeTable = global.NoticeTable

function CalcComboSkillCDMediator:ctor()
    CalcComboSkillCDMediator.super.ctor(self, self.NAME)
    global.CalcComboSkillCDMediator = self
    
    self._firstTick = {}
    self._needTick = false
end

function CalcComboSkillCDMediator:listNotificationInterests()
    return {
        noticeTable.ComboSkillEnterCD,
        noticeTable.PlayerPropertyInited
    }
end

function CalcComboSkillCDMediator:handleNotification(notification)
    local id = notification:getName()
    local data = notification:getBody()
    
    if noticeTable.ComboSkillEnterCD == id then
        self:OnComboSkillEnterCD(data)

    elseif noticeTable.PlayerPropertyInited == id then
        self:Init()
    end
end

function CalcComboSkillCDMediator:Init()
    self._skillProxy = global.Facade:retrieveProxy(global.ProxyTable.Skill)
end

function CalcComboSkillCDMediator:Tick(dt)
    if not self._needTick then
        return
    end

    if not self._skillProxy then
        return
    end
    
    local endDirty = true -- end timer flag
    
    -- tick
    local function tick(skill)
        if skill.isCD then
            endDirty = false

            if self._firstTick[skill.id] then
                self._firstTick[skill.id] = nil
            else
                skill.curTime = skill.curTime - dt
                skill.curTime = mmax(skill.curTime, 0)
    
                if skill.curTime == 0 then
                    self:OnSkillExitCD(skill.id)
                else
                    local percent = skill.curTime / skill.maxTime * 100
                    local cdData = {id = skill.id, percent = percent, time = skill.curTime}
                    facade:sendNotification(noticeTable.ComboSkillCDTimeChange, cdData)
                end
            end
        end
    end

    -- combo
    local comboSkills = self._skillProxy:GetComboSkills()
    for _, skill in pairs(comboSkills) do
        -- local selectSkills = self._skillProxy:haveSetComboSkill()
        -- if table.indexof(selectSkills, skill.MagicID) then
            tick(skill)
        -- end
    end
    
    -- end timer
    if endDirty then
        self._needTick = false
    end
end

function CalcComboSkillCDMediator:OnComboSkillEnterCD(skillID)
    local player = global.gamePlayerController:GetMainPlayer()
    if not player then
        return nil
    end
    if not self._skillProxy then
        return
    end
    local config = self._skillProxy:FindConfigBySkillID(skillID)
    if not config then
        return
    end
    local skill = self._skillProxy:GetComboSkillByID(skillID)
    if not skill then
        return
    end

    -- globalCD
    local attackglobalCD    = SL:GetMetaValue("GAME_DATA","attackglobalCD") or 900
    local magicglobalCD     = SL:GetMetaValue("GAME_DATA","magicglobalCD") or 1000
    local globalCD          = (config.action == 1 and magicglobalCD or attackglobalCD) * 0.001

    -- skillCD
    local attackCD          = (player:GetAttackStepTime() / player:GetAttackSpeed())
    local magicCD           = (player:GetMagicStepTime() / player:GetMagicSpeed())
    local launchCD          = (config.action == 1 and magicCD or attackCD)

    launchCD                = math.max(globalCD, launchCD)
    local maxTime           = math.max(launchCD, skill.DelayTime*0.001)

    -- 
    skill.maxTime           = maxTime
    skill.curTime,isDouble  = self._skillProxy:GetDoubleSkillCDTime(skillID, skill.maxTime)
    skill.isCD              = skill.curTime > 0

    -- notice
    if skill.isCD then
        local cdData        = {id = skillID, percent = skill.curTime / skill.maxTime * 100, time = skill.curTime}
        local noticeTable   = global.NoticeTable
        global.Facade:sendNotification(noticeTable.ComboSkillCDTimeChange, cdData)
    end

    self._firstTick[skill.id] = true
    self._needTick = true
end

function CalcComboSkillCDMediator:OnSkillExitCD(skillID)
    if not self._skillProxy then
        return
    end
    local skill = self._skillProxy:GetComboSkillByID(skillID)
    if not skill then
        return
    end
    
    skill.isCD = false
    skill.maxTime = 0
    skill.curTime = skill.maxTime
    
    local cdData = {id = skillID, percent = 0, time = 0}
    local noticeTable = global.NoticeTable
    facade:sendNotification(noticeTable.ComboSkillCDTimeChange, cdData)
end

return CalcComboSkillCDMediator
