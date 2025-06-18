local skillPresentBase = require("skill/skillPresentBase")
local skillPresentLaunch = class("skillPresentLaunch", skillPresentBase)

function skillPresentLaunch:ctor(data, config, root, target, delagate)
    skillPresentLaunch.super.ctor(self, data, config, root, target, delagate)
end

function skillPresentLaunch:getType()
    return global.MMO.SKILL_PRESENT_LAUNCH
end

function skillPresentLaunch:init()
    skillPresentLaunch.super.init(self)

    self._anim = nil
    self._status = -1
    self._tickAble = false

    -- delay
    self._delayTime = (self._config.delaytime or 0) * 0.001 / self._speed
    self._animFollow = (self._config.skillgensui or 0) == 1
end

function skillPresentLaunch:launch()
    skillPresentLaunch.super.launch(self)

    --
    if self._config.launchID and self._config.launchID ~= -1 then
        local isCreateAnim = true
        if self._data and self._data.skillID == 85 then --裂神符技能
            local launcher = global.actorManager:GetActor(self._data.launcherID)
            if launcher and launcher:IsMonster() then
                isCreateAnim = false
            end
        end

        if isCreateAnim then
            local dir = (self._config.launchDir == 8 and self._data.dir or 0)
            self._anim = global.FrameAnimManager:CreateSkillEffAnim(self._config.launchID, dir)
            self._anim:setLocalZOrder(self._config.launchID)
            self._anim:setVisible(false)
            self._root:addChild(self._anim)
        end
    end

    if self._anim == nil then
        self:launchNext()
        self:disable()
        return
    end

    -- // Launch animation
    local srcPos = global.sceneManager:MapPos2WorldPos(self._data.launchX, self._data.launchY, true)
    self._anim:setPosition(cc.pAdd(srcPos, global.MMO.PLAYER_AVATAR_OFFSET))
    self._anim:SetAnimEventCallback(
        function(_, eventType)
            if self._anim then
                self._anim:removeFromParent()
                self._anim = nil
            end
            if self._LightID then
                global.darkNodeManager:removeNode(self._LightID)
                self._LightID = nil
            end
            self._tickAble = false
            self:launchNext()
            self:disable()
        end
    )
    -----light 
    if not self._LightID and not (self._config.notLight and self._config.notLight == 1) then
        local DarkLayerProxy = global.Facade:retrieveProxy(global.ProxyTable.DarkLayerProxy)
        local lightData = DarkLayerProxy.LIGHT_TYPE.Two_Skill
        self._LightID = global.darkNodeManager:createNode({ x = srcPos.x, y = srcPos.y, r = lightData.r, w = lightData.w })
    end

    -- launch...
    self._status = -1
    self._tickAble = true

    -- 
    if self._delayTime <= 0 then
        self._status = 1
        self:launchAnim()
    end
end

function skillPresentLaunch:Tick(dt)
    if not self._tickAble then
        return
    end

    if self._status == -1 then
        -- delay for launch state
        self._delayTime = self._delayTime - dt
        if self._delayTime <= 0 then
            self._status = 0
        end

    elseif self._status == 0 then
        self._status = 1
        self:launchAnim()

    elseif self._status == 1 then
        self:refreshLaunchPosition()
    end
end

function skillPresentLaunch:launchAnim()
    self:animationLaunchBeforeSFX()

    -- anim
    if self._anim then
        local dir = (self._config.launchDir == 8 and self._data.dir or 0)
        self._anim:Play(0, dir, true, self._speed)
        self._anim:setVisible(true)
    end

    -- sound
    local launcher  = global.actorManager:GetActor(self._data.launcherID)
    local sex       = (launcher and launcher:IsPlayer()) and launcher:GetSexID() or global.MMO.ACTOR_PLAYER_SEX_M
    global.Facade:sendNotification(global.NoticeTable.Audio_Play, { type = global.MMO.SND_TYPE_SKILL_START, index = self._data.skillID, sex = sex })

    -- 
    if self._animFollow == false and self._config.flyID == -1 and self._config.hitID == -1 then
        self._tickAble = false
        self:launchNext()
        self:disable()
    end
end

function skillPresentLaunch:refreshLaunchPosition()
    if not self._anim then
        return
    end
    if not self._animFollow then
        return
    end
    local launcher = global.actorManager:GetActor(self._data.launcherID)
    if not launcher then
        return
    end

    local srcPos = launcher:getPosition()
    self._anim:setPosition(cc.pAdd(srcPos, global.MMO.PLAYER_AVATAR_OFFSET))

    if self._LightID then
        global.darkNodeManager:updateNode(self._LightID, { x = srcPos.x, y = srcPos.y })
    end
end

function skillPresentLaunch:addLaunchLight(srcPos)
    local light = nil
    if not (self._config.notLight and self._config.notLight == 1) then
        local DarkLayerProxy = global.Facade:retrieveProxy(global.ProxyTable.DarkLayerProxy)
        local lightData = DarkLayerProxy.LIGHT_TYPE.Two_Skill
        light = global.darkNodeManager:createNode({ x = srcPos.x, y = srcPos.y, r = lightData.r, w = lightData.w })
    end
    return light
end

function skillPresentLaunch:animationLaunchBeforeSFX()
    if self._data and self._data.launcherID then
        local launcher = global.actorManager:GetActor(self._data.launcherID)
        if launcher and launcher:IsMonster() and launcher:GetAnimationID() == 800 then -- 火龙神
            self:animationLightning({-500, 0 }, { 50, -300 })
        end
    end
end

-- 闪电集
function skillPresentLaunch:animationLightning(xRandom, yRandom)
    local launcher = global.actorManager:GetActor(self._data.launcherID)
    if not launcher then
        return nil
    end

    local sfxID     = 1038
    local srcPos    = launcher:getPosition()
    local sfxCount  = 2
    local dir       = 5

    local function animationSfx(sfx_count)
        if sfx_count > sfxCount then
            return
        end
        local removeCount = 0
        for i = 1, 6 do
            PerformWithDelayGlobal(function()
                local pos = cc.p(srcPos.x + (math.random(xRandom[1], xRandom[2]) or 0), srcPos.y + (math.random(yRandom[1], yRandom[2]) or 0))
                local sfx = global.FrameAnimManager:CreateSkillEffAnim(sfxID, math.random(0, dir) or 0)
                self._root:addChild(sfx)
                sfx:setLocalZOrder(sfxID)
                sfx:Play(0, 0, true)
                sfx:setPosition(cc.pAdd(pos, global.MMO.PLAYER_AVATAR_OFFSET))

                local light = self:addLaunchLight(pos)

                sfx:SetAnimEventCallback(
                    function(_, eventType)
                        if sfx then
                            sfx:removeFromParent()
                            sfx = nil
                            if light then
                                global.darkNodeManager:removeNode(light)
                            end
                        end
                        removeCount = removeCount + 1
                        if removeCount == 5 then
                            animationSfx(sfx_count + 1)
                        end
                    end
                )

            end, 0.11 * i)
        end
    end
    animationSfx(1)
end

return skillPresentLaunch