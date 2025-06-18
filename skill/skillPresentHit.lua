local skillPresentBase = require("skill/skillPresentBase")
local skillPresentHit = class("skillPresentHit", skillPresentBase)

function skillPresentHit:ctor(data, config, root, target, delagate)
    skillPresentHit.super.ctor(self, data, config, root, target, delagate)
end

function skillPresentHit:getType()
    return global.MMO.SKILL_PRESENT_HIT
end

function skillPresentHit:init()
    skillPresentHit.super.init(self)

    self._anim      = nil
    self._status    = -1
    self._tickAble  = false
    self._delayTime = (self._config.hitDelayTime or 0) * 0.001 / self._speed
    self._animFollow= (self._config.skillgensui or 1) == 1
end

function skillPresentHit:launch()
    skillPresentHit.super.launch(self)

    if self._config.hitID and self._config.hitID ~= -1 then
        local dir = (self._config.hitDir == 8 and self._data.dir or 0)
        local immediate = (self._config.hitID == 198)
        self._anim = global.FrameAnimManager:CreateSkillEffAnim(self._config.hitID, dir, nil, immediate)
        self._anim:setLocalZOrder(self._config.hitID)
        self._anim:setVisible(false)
        self._root:addChild(self._anim)
    end

    if not self._anim then
        self._tickAble = false
        self:launchNext()
        self:disable()
        return
    end

    local destPos       = global.sceneManager:MapPos2WorldPos(self._target.dest.x, self._target.dest.y, true)
    if self._target.id and (self._data.skillID ~= 58 and self._data.skillID ~= 581) then
        local target    = global.actorManager:GetActor(self._target.id)
        if target then
            destPos     = target:getPosition()
        end
    end
    self._anim:setPosition(cc.pAdd(destPos, global.MMO.PLAYER_AVATAR_OFFSET))
    self._anim:setVisible(false)
    self._anim:SetAnimEventCallback(
        function(_, eventType)
            if self._anim then
                self._anim:removeFromParent()
                self._anim = nil
            end
            if self._LightID then
                global.darkNodeManager:removeNode(self._LightID)
            end
            self._LightID = nil
            self._tickAble = false
            self:launchNext()
            self:disable()
        end
    )

    -- launch...
    self._status = -1
    self._tickAble = true
end

function skillPresentHit:Tick(dt)
    if not self._tickAble then
        return
    end

    if self._status == -1 then
        self._delayTime = self._delayTime - dt
        if self._delayTime <= 0 then
            self._status = 0
        end

    elseif self._status == 0 then
        self._status = 1

        -- refresh hit pos
        if self._anim then
            local dir = (self._config.hitDir == 8 and self._data.dir or 0)
            self._anim:Play(0, dir, true, self._speed)
            self._anim:setVisible(true)

            -----light 
            if not self._LightID and not (self._config.notLight and self._config.notLight == 1) then
                local destPos           = global.sceneManager:MapPos2WorldPos(self._target.dest.x, self._target.dest.y, true)
                local DarkLayerProxy    = global.Facade:retrieveProxy(global.ProxyTable.DarkLayerProxy)
                local lightData         = DarkLayerProxy.LIGHT_TYPE.Two_Skill
                self._LightID           = global.darkNodeManager:createNode({ x = destPos.x, y = destPos.y, r = lightData.r, w = lightData.w })
            end

            -- 特殊处理流行火雨
            if self._data.skillID == 58 or self._data.skillID == 581 then
            elseif self._data.skillID == 840 then --冰霜群雨
                local range = 3
                local showMapPos = {
                    {-1 * range, -1 * range }, {-1 * range, range }, { range, -1 * range }, { range, range }
                }
                self:ShowRandomAnim(self._config.hitID, showMapPos, dir)
            else
                self:refreshHitPosition()
            end

            -- sound
            local launcher  = global.actorManager:GetActor(self._data.launcherID)
            local sex       = (launcher and launcher:IsPlayer()) and launcher:GetSexID() or global.MMO.ACTOR_PLAYER_SEX_M
            global.Facade:sendNotification(global.NoticeTable.Audio_Play, { type = global.MMO.SND_TYPE_SKILL_EXPLOSION, index = self._data.skillID, sex = sex })
        end

    elseif self._status == 1 then
        -- refresh hit pos
        if self._animFollow then
            self:refreshHitPosition()
        end
    end
end

function skillPresentHit:setNodeParent(root)
    if root and self._anim then
        root:addChild(self._anim)
    end
end

function skillPresentHit:refreshHitPosition()
    if not self._anim then
        return false
    end
    if not self._target.id then
        return
    end
    local target = global.actorManager:GetActor(self._target.id)
    if not target then
        return
    end

    local destPos = target:getPosition()
    self._anim:setPosition(cc.pAdd(destPos, global.MMO.PLAYER_AVATAR_OFFSET))

    -----light 
    if self._LightID then
        global.darkNodeManager:updateNode(self._LightID, { x = destPos.x , y = destPos.y})
    end
end

-- 显示随机特效   sfxID: 特效id   showMapPos: 显示特效的地图位置   dir: 方向
local randomCount = {}  --随机特效显示的数量， 超过30个的就不显示了
function skillPresentHit:ShowRandomAnim(sfxID, showMapPos, dir)
    local sfxMaxNum = 30
    sfxID = sfxID or 204 -- 默认冰霜群雨特效
    if not randomCount[sfxID] then
        randomCount[sfxID] = 0
    end

    if randomCount[sfxID] > sfxMaxNum then
        return
    end

    local mapX = self._target.dest.x
    local mapY = self._target.dest.y
    if self._target.id and (self._data.skillID ~= 58 and self._data.skillID ~= 581) then
        local target    = global.actorManager:GetActor(self._target.id)
        if target then
            mapX = target:GetMapX()
            mapY = target:GetMapY()
        end
    end

    local sfxRoot = self._root
    local originPos = { mapX, mapY }
    for i, mapPos in ipairs(showMapPos) do
        randomCount[sfxID] = randomCount[sfxID] + 1
        if randomCount[sfxID] > sfxMaxNum then
            break
        end
        local pos = global.sceneManager:MapPos2WorldPos(mapX + mapPos[1], mapY + mapPos[2], true)
        local sfx = global.FrameAnimManager:CreateSkillEffAnim(sfxID, dir or 0)
        sfxRoot:addChild(sfx)
        sfx:setLocalZOrder(sfxID)
        sfx:Play(0, 0, true)
        sfx:setPosition(cc.pAdd(pos, global.MMO.PLAYER_AVATAR_OFFSET))
        sfx:SetAnimEventCallback(
            function(_, eventType)
                if sfx then
                    sfx:removeFromParent()
                    sfx = nil
                end
                randomCount[sfxID] = randomCount[sfxID] - 1
            end
        )
    end
end
return skillPresentHit