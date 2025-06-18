local skillPresentBase = require("skill/skillPresentBase")
local skillPresentFly = class("skillPresentFly", skillPresentBase)

local effectOff = {
    [131] = { x = -25, y = 0 }
}
local offsetys = {[13] = 1, [14] = 1, [15] = 1, [19] = 1, [38] = 1, [44] = 1, [63] = 1 }--13灵魂火符 14幽灵盾 15神圣战甲术 19集体隐身术  38诅咒术 44寒冰掌 85裂神符 63噬魂沼泽需要向上偏移
local dir1t8 = {
    [9] = true
}

function skillPresentFly:ctor(data, config, root, target, delagate)
    skillPresentFly.super.ctor(self, data, config, root, target, delagate)
end

function skillPresentFly:getType()
    return global.MMO.SKILL_PRESENT_FLY
end

function skillPresentFly:init()
    skillPresentFly.super.init(self)

    self._anim          = nil
    self._status        = -1
    self._tickAble      = false
    self._delayTime     = (self._config.flyDelayTime or 0) * 0.001 / self._speed

    self._flyDir        = cc.p(0.0, 0.0)
    self._flySpeed      = ((not self._config.flySpeed or self._config.flySpeed == 0) and 1500.0 or self._config.flySpeed) * self._speed
    self._currWorldPos  = cc.p(0.0, 0.0)
    self._destWorldPos  = cc.p(0.0, 0.0)

    self._animDir       = (self._config.flyDir == 8) and 8 or 0
end

function skillPresentFly:launch()
    skillPresentFly.super.launch(self)

    if self._config.flyID and self._config.flyID ~= -1 then
        self._anim = global.FrameAnimManager:CreateSkillEffAnim(self._config.flyID)
        self._anim:setLocalZOrder(self._config.flyID)
        self._anim:setVisible(false)
        self._root:addChild(self._anim)
    end

    if self._anim == nil then
        self._tickAble = false
        self:launchNext()
        self:disable()
        return
    end

    -- fix hit pos
    local hitX = self._target.dest.x
    local hitY = self._target.dest.y
    if self._target.id then
        local target = global.actorManager:GetActor(self._target.id)
        if target then
            hitX = target:GetMapX()
            hitY = target:GetMapY()
        end
    end

    local srcWorldPos   = global.sceneManager:MapPos2WorldPos(self._data.launchX, self._data.launchY, true)
    srcWorldPos.y       = srcWorldPos.y + 40
    local destWorldPos  = global.sceneManager:MapPos2WorldPos(hitX, hitY, true)
    destWorldPos.y      = destWorldPos.y + 40
    self._currWorldPos  = srcWorldPos
    self._destWorldPos  = destWorldPos

    if effectOff[self._config.flyID] then
        srcWorldPos.x = srcWorldPos.x + effectOff[self._config.flyID].x
        srcWorldPos.y = srcWorldPos.y + effectOff[self._config.flyID].y
    end
    self._anim:setPosition(srcWorldPos)
    self._anim:setVisible(false)

    -- launch...
    self._status = -1
    self._tickAble = true
end

function skillPresentFly:Tick(dt)
    if not self._tickAble then
        return
    end

    if self._status == -1 then
        self._delayTime = self._delayTime - dt
        if self._delayTime <= 0 then
            self._status = 0
        end

    elseif self._status == 0 then
        if self._anim then
            local launcher = global.actorManager:GetActor(self._data.launcherID)

            local direction = (self._animDir == 8 and launcher and (not dir1t8[self._config.flyID])) and launcher:GetDirection() or 0
            self._anim:Stop()
            self._anim:Play(0, direction, true, self._speed)
            self._anim:setVisible(true)

            -- calc dir
            local destSub = cc.pSub(self._destWorldPos, self._currWorldPos)
            self._flyDir  = cc.pNormalize(destSub)
            local angle   = cc.pGetAngle(self._flyDir, cc.p(0, 1))
            local rotate  = (self._animDir == 0) and angle*57.29577951 or 0
            self._anim:setRotation(rotate)

            -- play sound
            local sex       = (launcher and launcher:IsPlayer()) and launcher:GetSexID() or global.MMO.ACTOR_PLAYER_SEX_M
            global.Facade:sendNotification(global.NoticeTable.Audio_Play, {type=global.MMO.SND_TYPE_SKILL_FIRE, index=self._data.skillID, sex=sex})

            -----light 
            if not self._LightID and not (self._config.notLight and self._config.notLight == 1) then
                local DarkLayerProxy = global.Facade:retrieveProxy(global.ProxyTable.DarkLayerProxy)
                local lightData = DarkLayerProxy.LIGHT_TYPE.Two_Skill
                self._LightID = global.darkNodeManager:createNode({ x = self._currWorldPos.x, y = self._currWorldPos.y, r = lightData.r, w = lightData.w })
            end
        end
        self._status = 1

    elseif self._status == 1 then
        if self._anim then
            local distance = self._flySpeed * dt

            --
            self:calcTarget()

            if self:isHitTarget(distance) then
                if self._anim then
                    self._anim:removeFromParent()
                    self._anim = nil
                end

                self._tickAble = false
                self:launchNext()
                self:disable()
                if self._LightID then
                    global.darkNodeManager:removeNode(self._LightID)
                    self._LightID = nil
                end
            else
                local displ = cc.pMul(self._flyDir, distance)
                local posNew = cc.pAdd(self._currWorldPos, displ)

                local offy = 0
                if self._data and self._data.skillID and offsetys[self._data.skillID] then
                    offy = 28
                end
                self._anim:setPosition(posNew.x, posNew.y + offy)
                self._currWorldPos = posNew
                -----light 
                if self._LightID then
                    global.darkNodeManager:updateNode(self._LightID, { x = posNew.x, y = posNew.y })
                end
            end
        end
    end
end

function skillPresentFly:setNodeParent(root)
    if self._anim and root then
        root:addChild(self._anim)
    end
end

function skillPresentFly:calcTarget()
    if self._anim and self._config.needTarget == 1 then
        if self._target.id then
            local targetActor = global.actorManager:GetActor(self._target.id)
            if targetActor then
                self._destWorldPos   = targetActor:getPosition()
                self._destWorldPos.y = self._destWorldPos.y + 40
            end
        else
            local inputProxy    = global.Facade:retrieveProxy( global.ProxyTable.PlayerInputProxy )
            local normal        = inputProxy:DirToNormalizeVec2(self._data.dir)
            local origin        = cc.p(self._data.launchX, self._data.launchY)
            local moved         = cc.pMul(normal, 25)
            local dest          = cc.pAdd(origin, moved)
            self._destWorldPos  = global.sceneManager:MapPos2WorldPos(dest.x, dest.y, true)
            self._destWorldPos.y= self._destWorldPos.y + 40
        end

        local destSub = cc.pSub(self._destWorldPos, self._currWorldPos)
        self._flyDir  = cc.pNormalize(destSub)
        local angle   = cc.pGetAngle(self._flyDir, cc.p(0, 1))
        local rotate  = (self._animDir == 0) and angle*57.29577951 or 0
        self._anim:setRotation(rotate)
    end
end

function skillPresentFly:isHitTarget(distance)
    local destSub   = cc.pSub(self._destWorldPos, self._currWorldPos)
    local destDist  = cc.pGetLength(destSub)
    return destDist <= distance*3
end

return skillPresentFly