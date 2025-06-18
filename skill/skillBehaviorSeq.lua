local skillBehavior = require("skill/skillBehavior")
local skillBehaviorSeq = class("skillBehaviorSeq", skillBehavior)

local skillPresentLaunch = require("skill/skillPresentLaunch")
local skillPresentFly    = require("skill/skillPresentFly")
local skillPresentHit    = require("skill/skillPresentHit")

function skillBehaviorSeq:ctor(id, data, config)
    skillBehaviorSeq.super.ctor(self, id, data, config)

    self._tickPresents  = {}

    self._launchPresent = nil
    self._flyPresents   = {}
    self._hitPresents   = {}

    self._presentTag    = 0
end

function skillBehaviorSeq:init()
    self._currPresent = nil
end

function skillBehaviorSeq:launch()
    skillBehaviorSeq.super.launch(self)

    if self._data.skillStage == 1 then
        self:joinLaunch()

    elseif self._data.skillStage == 2 then
        self:joinLaunchOver()

    else
        self:joinLaunch()
        self:joinLaunchOver()
    end

    if self._data.needFly then
        self:joinLaunchFly()
    end
    
    -- launch
    self:launchBehavior()
end

function skillBehaviorSeq:launchBehavior()
    if self._launchPresent then
        self._launchPresent:launch()
        return true
    end

    if #self._flyPresents > 0 then
        for _, v in pairs(self._flyPresents) do
            v:launch()
        end
        return true
    end

    return false
end

function skillBehaviorSeq:joinLaunch()
    if self._launchPresent then
        return nil
    end
    self._launchPresent = skillPresentLaunch.new(self._data, self._config, self._launchRoot, nil, self)
    self._launchPresent:init()

    self._launchPresent.tag = self._presentTag
    self._presentTag        = self._presentTag + 1
end

function skillBehaviorSeq:joinLaunchOver()
    if #self._flyPresents > 0 or #self._hitPresents > 0 then
        return nil
    end
    if not self._data.hitX or not self._data.hitY then
        return nil
    end

    local targets       = {}
    local destPos       = cc.p(self._data.hitX, self._data.hitY)
    if self._data.param and self._data.param ~= "" then
        local slices    = string.split(self._data.param, "#")
        for _, v in ipairs(slices) do
            table.insert(targets, {dest = destPos, id = v})
        end
    else
        table.insert(targets, {dest = destPos, id = nil})
    end
    for _, target in pairs(targets) do
        local flyPresent = skillPresentFly.new(self._data, self._config, self._flyRoot, target, self)
        flyPresent:init()
        flyPresent.tag  = self._presentTag
        self._presentTag= self._presentTag + 1
        table.insert(self._flyPresents, flyPresent)

        if self._config.needTarget ~= 1 or target.id ~= nil then
            local hitPresent = skillPresentHit.new(self._data, self._config, self._hitRoot, target, self)
            hitPresent:init()
            hitPresent.tag  = self._presentTag
            self._presentTag= self._presentTag + 1
            table.insert(self._hitPresents, hitPresent)

            flyPresent:setNext({hitPresent})
        end
    end

    -- bind next present
    if self._launchPresent then
        self._launchPresent:setNext(self._flyPresents)
    end
end

function skillBehaviorSeq:joinLaunchFly()
    if #self._flyPresents > 0  then
        return nil
    end
    if not self._data.hitX or not self._data.hitY then
        return nil
    end

    local targets       = {}
    local destPos       = cc.p(self._data.hitX, self._data.hitY)
    if self._data.param and self._data.param ~= "" then
        local slices    = string.split(self._data.param, "#")
        for _, v in ipairs(slices) do
            table.insert(targets, {dest = destPos, id = v})
        end
    else
        table.insert(targets, {dest = destPos, id = nil})
    end
    for _, target in pairs(targets) do
        local flyPresent = skillPresentFly.new(self._data, self._config, self._flyRoot, target, self)
        flyPresent:init()
        flyPresent.tag  = self._presentTag
        self._presentTag= self._presentTag + 1
        table.insert(self._flyPresents, flyPresent)
    end

    -- bind next present
    if self._launchPresent then
        self._launchPresent:setNext(self._flyPresents)
    end
end

function skillBehaviorSeq:onLaunch(skillPB)
    table.insert(self._tickPresents, skillPB)
end

function skillBehaviorSeq:onFinish(skillPB)
    for k, v in pairs(self._tickPresents) do
        if v.tag == skillPB.tag then
            table.remove(self._tickPresents, k)
            break
        end
    end

    --
    if #self._tickPresents == 0 then
        self:disable()
    end
end

function skillBehaviorSeq:Tick(dt)
    for _, v in pairs(self._tickPresents) do
        v:Tick(dt)
    end
end

return skillBehaviorSeq
