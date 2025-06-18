local skillManager = class("skillManager")

local skillBehaviorSeq      = require("skill/skillBehaviorSeq")
local skillBehaviorDartle   = require("skill/skillBehaviorDartle")
local SKILL_ROOT_BEHIND     = 1
local SKILL_ROOT_FRONT      = 2
local Queue                 = requireUtil( "queue" )
local SKILL_BEHAVIOR_LIMIT  = 200   -- 技能特效数量上限(主玩家特效不受此限制)

function skillManager:ctor()
end

function skillManager:destory()
    if skillManager.instance then
        skillManager.instance:Cleanup()
        skillManager.instance = nil
    end
end

function skillManager:Inst()
    if not skillManager.instance then
        skillManager.instance = skillManager.new()
        skillManager.instance:Init()
    end

    return skillManager.instance
end

function skillManager:Init()
    self:Cleanup()
end

function skillManager:LoadConfig()
    self._config = requireGameConfig("cfg_skill_present")
end

function skillManager:getSkillDataByID(skillID)
    return self._config[skillID]
end

function skillManager:Cleanup()
    self._config = {}
    self._rootNode = {}
    self._behaviors = {}
    self._launchCache = {}
    self._behaviorIDPool = Queue.new()
    self._behaviorIDCount = 0
end

function skillManager:CleanupBehaviors()
    for k, v in pairs(self._rootNode) do
        v:removeAllChildren()
    end

    self._behaviors = {}
    self._launchCache = {}
    self._behaviorIDPool:clear()
    self._behaviorIDCount = 0
end

function skillManager:Tick(dt)
    local removed = {}
    for _, behavior in pairs(self._behaviors) do
        if behavior:isInvalid() then
            removed[#removed + 1] = behavior
        else
            behavior:Tick(dt)
        end
    end

    for _, behavior in pairs(removed) do
        local behaviorID = behavior:GetID()
        self:RecycleBehaviorID(behaviorID)
        self._behaviors[behaviorID] = nil
    end

    -- 表现
    while #self._launchCache > 0 do
        local launchData = table.remove(self._launchCache, 1)
        self:LaunchSkill(launchData)
    end
end

function skillManager:LaunchSkillPresent(data)
    self._launchCache[#self._launchCache + 1] = data
end

function skillManager:LaunchSkill(data)
    local skillID = data.skillID

    if not skillID then
        return false
    end

    local config = self._config[skillID]
    if not config then
        return false
    end

    -- 设置屏蔽
    if CHECK_SETTING(global.MMO.SETTING_IDX_SKILL_EFFECT_SHOW) == 1 then
        return false
    end

    -- 技能表现峰值
    if self:GetBehaviorCount() >= SKILL_BEHAVIOR_LIMIT and data.launcherID ~= global.gamePlayerController:GetMainPlayerID() then
        return false
    end
    
    -- 记录技能原ID，链接技能通过原ID计算技能速度
    data.srcSkillID = data.srcSkillID or skillID

    -- 处理连接命中特效无法连接上的问题
    local function linkSkillFunc()
        if config.linkSkill and config.linkSkill >= 1 and self._config[config.linkSkill] then
            local linkData   = clone(data)
            linkData.skillID = self._config[config.linkSkill].id
            self:LaunchSkill(linkData)
        end
    end

    -- exist behavior
    if data.skillStage then
        local behavior = nil
        for _, v in pairs(self._behaviors) do
            if not v:isInvalid() and v._data.launcherID == data.launcherID and v._data.skillStage == 1 and v._data.skillID == skillID then
                behavior = v
                break
            end
        end

        if behavior then
            behavior:setData(data)
            behavior:joinLaunchOver()

            linkSkillFunc()
            return true
        end
    end
    
    -- new behavior
    local behaviorID = self:GetBehaviorID()
    local behavior   = self:CreateSkillBehavior(behaviorID, data)
    self._behaviors[behaviorID] = behavior

    linkSkillFunc()
end

function skillManager:CreateSkillBehavior(behaviorID, data)
    local skillID = data.skillID
    local config = self._config[skillID]
    
    local behavior = nil
    if config.type == 1 then
        behavior = skillBehaviorDartle.new(behaviorID, data, config)
    else
        behavior = skillBehaviorSeq.new(behaviorID, data, config)
    end
    behavior:setNodeParent(self:GetRootNode(0 ~= config.pos), self:GetRootNode(0 ~= 0), self:GetRootNode(0 ~= config.hitPos))
    behavior:init()
    behavior:launch()

    return behavior
end

function skillManager:GetRootNode(isBehind)
    if not self._rootNode[SKILL_ROOT_BEHIND] or not self._rootNode[SKILL_ROOT_FRONT] then
        local rootB = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_SKILL_BEHIND)
        local rootF = global.sceneGraphCtl:GetSceneNode(global.MMO.NODE_SKILL)

        self._rootNode[SKILL_ROOT_BEHIND] = cc.Node:create()
        rootB:addChild(self._rootNode[SKILL_ROOT_BEHIND], 99999)
        self._rootNode[SKILL_ROOT_FRONT] = cc.Node:create()
        rootF:addChild(self._rootNode[SKILL_ROOT_FRONT], 99999)
        self._rootNode[SKILL_ROOT_BEHIND]._IsSkillEffect = true--做个标识 内挂特效屏蔽用
        self._rootNode[SKILL_ROOT_FRONT]._IsSkillEffect = true
    end

    if isBehind then
        return self._rootNode[SKILL_ROOT_BEHIND]
    else
        return self._rootNode[SKILL_ROOT_FRONT]
    end
end

function skillManager:GetBehaviorID()
    if self._behaviorIDPool:empty() then
        self._behaviorIDCount = self._behaviorIDCount + 1
        return self._behaviorIDCount
    end
    return self._behaviorIDPool:pop()
end

function skillManager:RecycleBehaviorID(id)
    self._behaviorIDPool:push(id)
end

function skillManager:GetBehaviorCount()
    return self._behaviorIDCount - self._behaviorIDPool:size()
end

return skillManager
